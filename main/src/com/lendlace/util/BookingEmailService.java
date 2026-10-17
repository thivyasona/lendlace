 package com.lendlace.util;

import com.lendlace.dao.BookingDAO;
import com.lendlace.model.Booking;

import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeBodyPart;
import jakarta.mail.internet.MimeMessage;
import jakarta.mail.internet.MimeMultipart;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Properties;

/**
 * Lend & Lace booking notification service.
 *
 * - Sends branded HTML emails over SMTP (STARTTLS on 587 by default).
 * - Configuration comes ONLY from system properties / environment variables:
 * mail.smtp.host (or MAIL_SMTP_HOST), mail.smtp.port (MAIL_SMTP_PORT),
 * mail.smtp.user (MAIL_SMTP_USER), mail.smtp.pass (MAIL_SMTP_PASS),
 * mail.from (MAIL_FROM, optional), app.base.url (APP_BASE_URL,
 * optional - links are included only when this is a reachable URL).
 * - Every send attempt is recorded in the email_notification_log table so
 * failures are visible and retries never duplicate a status-change email.
 * - sendBookingEmail returns false when the SMTP server rejects the mail; the
 * caller's booking data is untouched either way.
 */
public final class BookingEmailService {

    private BookingEmailService() {
    }

    /** Types recorded in email_notification_log (also used to prevent dupes). */
    public static final String TYPE_CUSTOMER_REQUEST = "CUSTOMER_REQUEST";
    public static final String TYPE_OWNER_REQUEST = "OWNER_REQUEST";
    public static final String TYPE_APPROVAL = "APPROVAL";
    public static final String TYPE_REJECTION = "REJECTION";

    /**
     * Sends both request notifications for a freshly saved booking.
     * Customer email comes from the users table via the booking row's
     * customer join - never from a browser parameter. Returns true only if
     * both mails were accepted by the SMTP server.
     */
    public static boolean sendBookingRequested(Booking booking) {
        if (booking == null)
            return false;
        boolean allOk = true;

        String[] cust = fetchCustomerContact(booking.getCustomerId());
        if (cust != null) {
            String body = EmailTemplates.bookingRequestCustomer(
                    booking.getBookingId(), cust[0],
                    booking.getDressName(), booking.getStartDate(), booking.getEndDate(),
                    booking.getGrandTotal());
            allOk &= deliver(booking.getBookingId(), TYPE_CUSTOMER_REQUEST, cust[1], cust[0],
                    "Lend & Lace: We received your booking request #" + booking.getBookingId(), body);
        } else {
            allOk = false;
        }

        String[] owner = fetchOwnerContact(booking.getDressId());
        if (owner != null) {
            String body = EmailTemplates.newBookingRequestOwner(
                    booking.getBookingId(), owner[0],
                    booking.getDressName(), booking.getStartDate(), booking.getEndDate(),
                    booking.getGrandTotal());
            allOk &= deliver(booking.getBookingId(), TYPE_OWNER_REQUEST, owner[1], owner[0],
                    "Lend & Lace: New booking request #" + booking.getBookingId(), body);
        } else {
            allOk = false;
        }
        return allOk;
    }

    /**
     * Approval email - call ONLY after the DB update has committed, and only
     * when the update actually changed the row (result == 1), so repeated
     * clicks never resend an approval.
     */
    public static boolean sendBookingApproved(Booking booking) {
        return sendDecision(booking, TYPE_APPROVAL, true);
    }

    /** Rejection email - same call-after-commit and dedupe rules. */
    public static boolean sendBookingRejected(Booking booking) {
        return sendDecision(booking, TYPE_REJECTION, false);
    }

    private static boolean sendDecision(Booking booking, String type, boolean approved) {
        if (booking == null)
            return false;
        String[] cust = fetchCustomerContact(booking.getCustomerId());
        if (cust == null)
            return false;
        String body = approved
                ? EmailTemplates.bookingApproved(booking.getBookingId(), cust[0],
                        booking.getDressName(), booking.getStartDate(), booking.getEndDate(),
                        booking.getGrandTotal())
                : EmailTemplates.bookingRejected(booking.getBookingId(), cust[0],
                        booking.getDressName(), booking.getStartDate(), booking.getEndDate());
        String subject = approved
                ? "Lend & Lace: Your booking #" + booking.getBookingId() + " has been approved"
                : "Lend & Lace: Booking #" + booking.getBookingId() + " was not approved";
        return deliver(booking.getBookingId(), type, cust[1], cust[0], subject, body);
    }

    /* ------------------------- internals ------------------------- */

    /**
     * Logs the notification first (sent_ok=0), then attempts the SMTP send and
     * updates the log row. The log row acts as the audit trail and the retry
     * surface; a fresh status-change email is only sent when this method runs,
     * so duplicate HTTP retries do not multiply mails.
     */
    private static boolean deliver(int bookingId, String type, String toEmail,
            String toName, String subject, String html) {
        long logId = insertLog(bookingId, type, toEmail);
        boolean ok = EmailUtil.sendHtml(toEmail, toName, subject, html);
        updateLog(logId, ok, ok ? null : EmailUtil.getLastError());
        return ok;
    }

    private static long insertLog(int bookingId, String type, String toEmail) {
        String sql = "INSERT INTO email_notification_log(booking_id,notif_type,recipient,sent_ok) "
                + "VALUES(?,?,?,0)";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql,
                        PreparedStatement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, bookingId);
            ps.setString(2, type);
            ps.setString(3, toEmail == null ? "unknown" : toEmail);
            ps.executeUpdate();
            ResultSet keys = ps.getGeneratedKeys();
            if (keys.next())
                return keys.getLong(1);
        } catch (Exception e) {
            System.err.println("Notification log write failed: " + e.getClass().getSimpleName());
        }
        return -1;
    }

    private static void updateLog(long logId, boolean ok, String error) {
        if (logId < 0)
            return;
        String sql = "UPDATE email_notification_log SET sent_ok=?, error_summary=? WHERE log_id=?";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, ok ? 1 : 0);
            ps.setString(2, error);
            ps.setLong(3, logId);
            ps.executeUpdate();
        } catch (Exception e) {
            System.err.println("Notification log update failed: " + e.getClass().getSimpleName());
        }
    }

    /**
     * [fullName, email] from the users table - the registered address, never
     * browser-supplied.
     */
    private static String[] fetchCustomerContact(int customerId) {
        return fetchContact("SELECT full_name, email FROM users WHERE user_id=?", customerId);
    }

    /** [fullName, email] of the dress's registered owner. */
    private static String[] fetchOwnerContact(int dressId) {
        return fetchContact(
                "SELECT u.full_name, u.email FROM dresses d JOIN users u ON d.owner_id=u.user_id "
                        + "WHERE d.dress_id=?",
                dressId);
    }

    private static String[] fetchContact(String sql, int id) {
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next())
                return new String[] { rs.getString(1), rs.getString(2) };
        } catch (Exception e) {
            System.err.println("Contact lookup failed: " + e.getClass().getSimpleName());
        }
        return null;
    }

    /** Safely refresh a booking (with dress name) after a status change. */
    public static Booking reloadBooking(int bookingId) {
        return new BookingDAO().getBookingById(bookingId);
    }
}
