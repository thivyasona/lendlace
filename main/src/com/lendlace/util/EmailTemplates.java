package com.lendlace.util;

/**
 * Lend & Lace branded HTML email templates.
 * Kept separate from booking logic on purpose (spec item 7).
 *
 * Rules:
 * - Amounts are shown ONLY when a value >= 0 was passed (unreliable data ->
 * the amount is omitted, never guessed).
 * - A "View booking" link is included ONLY when app.base.url (or APP_BASE_URL)
 * is configured - never a fabricated localhost link for real customers.
 * - No passwords, session ids, or payment credentials are ever embedded.
 */
public final class EmailTemplates {

    private EmailTemplates() {
    }

    private static final String PURPLE_DARK = "#4A2040";
    private static final String PURPLE = "#6B3A5B";
    private static final String CREAM = "#FAF6F0";
    private static final String GREEN = "#2E7D32";
    private static final String RED = "#C62828";
    private static final String AMBER = "#B26A00";

    /* Brand-consistent responsive shell */
    private static String shell(String title, String preheader, String bodyHtml) {
        String link = baseUrl();
        String cta = "";
        if (link != null) {
            cta = "<tr><td style=\"padding:8px 32px 32px 32px;\">\n"
                    + "<a href=\"" + esc(link) + "\" "
                    + "style=\"display:inline-block;background:" + PURPLE_DARK + ";color:#ffffff;"
                    + "font-family:Georgia,serif;font-size:14px;padding:12px 26px;border-radius:24px;"
                    + "text-decoration:none;\">Visit Lend &amp; Lace</a>\n"
                    + "</td></tr>";
        }
        return "<!DOCTYPE html>\n"
                + "<html lang=\"en\"><head><meta charset=\"UTF-8\">\n"
                + "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\n"
                + "<title>" + esc(title) + "</title></head>\n"
                + "<body style=\"margin:0;padding:0;background:" + CREAM + ";\">\n"
                + "<div style=\"display:none;max-height:0;overflow:hidden;\">" + esc(preheader) + "</div>\n"
                + "<table role=\"presentation\" width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" "
                + "style=\"background:" + CREAM + ";padding:24px 12px;\">\n"
                + "<tr><td align=\"center\">\n"
                + "<table role=\"presentation\" width=\"600\" cellpadding=\"0\" cellspacing=\"0\" "
                + "style=\"width:600px;max-width:100%;background:#ffffff;border-radius:16px;"
                + "overflow:hidden;box-shadow:0 4px 14px rgba(74,32,64,0.12);\">\n"

                + "<tr><td style=\"background:" + PURPLE_DARK + ";padding:22px 32px;text-align:center;\">\n"
                + "<span style=\"color:#ffffff;font-family:Georgia,serif;font-size:22px;"
                + "letter-spacing:1px;\">Lend &amp; Lace</span><br>\n"
                + "<span style=\"color:#E8D5E0;font-size:11px;letter-spacing:2px;"
                + "text-transform:uppercase;\">Dress Rental</span>\n"
                + "</td></tr>\n"

                + "<tr><td style=\"padding:28px 32px 8px 32px;font-family:Georgia,serif;"
                + "font-size:22px;color:" + PURPLE_DARK + ";\">" + title + "</td></tr>\n"

                + "<tr><td style=\"padding:0 32px 16px 32px;font-family:Arial,Helvetica,sans-serif;"
                + "font-size:14px;line-height:1.6;color:#4B3A45;\">\n"
                + bodyHtml
                + "</td></tr>\n"
                + cta
                + "<tr><td style=\"padding:18px 32px;background:#F3E9EE;font-family:Arial,Helvetica,"
                + "sans-serif;font-size:11px;color:#8A6E7D;text-align:center;\">\n"
                + "&copy; 2026 Lend &amp; Lace Dress Rental. This is an automated notification.\n"
                + "</td></tr>\n"
                + "</table>\n"
                + "</td></tr></table>\n"
                + "</body></html>";
    }

    private static String detailTable(String reference, String dress, String dates, String amountLine) {
        StringBuilder sb = new StringBuilder();
        sb.append("<table role=\"presentation\" cellpadding=\"0\" cellspacing=\"0\" ")
                .append("width=\"100%\" style=\"border-collapse:collapse;margin:12px 0;\">\n");
        sb.append(detailRow("Booking reference", reference));
        sb.append(detailRow("Dress", dress));
        sb.append(detailRow("Rental dates", dates));
        if (amountLine != null)
            sb.append(detailRow("Total (rental + refundable deposit)", amountLine));
        sb.append("</table>");
        return sb.toString();
    }

    private static String detailRow(String label, String value) {
        return "<tr>"
                + "<td style=\"padding:8px 0;font-family:Arial,Helvetica,sans-serif;font-size:13px;"
                + "color:#8A6E7D;width:40%;border-bottom:1px solid #EFE3EA;\">" + esc(label) + "</td>"
                + "<td style=\"padding:8px 0;font-family:Arial,Helvetica,sans-serif;font-size:13px;"
                + "font-weight:bold;color:" + PURPLE_DARK + ";border-bottom:1px solid #EFE3EA;\">"
                + esc(value) + "</td></tr>";
    }

    private static String statusBanner(String text, String color) {
        return "<span style=\"display:inline-block;padding:6px 16px;border-radius:20px;"
                + "background:" + color + ";color:#ffffff;font-family:Arial,Helvetica,sans-serif;"
                + "font-size:13px;font-weight:bold;\">" + esc(text) + "</span>";
    }

    private static String esc(String s) {
        if (s == null)
            return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
                .replace("\"", "&quot;");
    }

    private static String baseUrl() {
        String b = System.getenv("APP_BASE_URL");
        if (b == null || b.isEmpty())
            b = System.getProperty("app.base.url");
        if (b == null || b.isEmpty())
            return null; // no link when unconfigured
        if (!b.startsWith("http://") && !b.startsWith("https://"))
            return null;
        return b;
    }

    private static String money(double v) {
        return "\u20B9" + String.format("%,.2f", v); // Indian Rupee sign, brand default
    }

    /* ------------------------- templates ------------------------- */

    /** Customer: request received, awaiting owner decision (NOT approved). */
    public static String bookingRequestCustomer(int bookingId, String customerName,
            String dressName, String start, String end,
            double grandTotal) {
        String body = "<p>Dear " + esc(customerName) + ",</p>"
                + "<p>Thank you for your booking request with <b>Lend &amp; Lace</b>. "
                + "We have received it successfully and it is now <b>awaiting the dress "
                + "owner's decision</b>. We will email you as soon as the owner responds.</p>"
                + "<p>" + statusBanner("Status: Awaiting owner decision", AMBER) + "</p>"
                + detailTable("#" + bookingId, dressName, start + " to " + end,
                        grandTotal >= 0 ? money(grandTotal) : null)
                + "<p style=\"margin-top:14px;\">Please note: this is a confirmation of "
                + "receipt only - the booking is <b>not yet approved</b>. No payment is "
                + "required at this stage.</p>";
        return shell("Booking Request Received", "Your request #" + bookingId
                + " for " + dressName + " is awaiting the owner's decision.", body);
    }

    /** Owner: a new request needs review. */
    public static String newBookingRequestOwner(int bookingId, String ownerName,
            String dressName, String start, String end,
            double grandTotal) {
        String body = "<p>Dear " + esc(ownerName) + ",</p>"
                + "<p>A customer has requested to rent <b>" + esc(dressName) + "</b> from your "
                + "collection. Please review this request in your owner dashboard.</p>"
                + "<p>" + statusBanner("Action needed: review request", PURPLE) + "</p>"
                + detailTable("#" + bookingId, dressName, start + " to " + end,
                        grandTotal >= 0 ? money(grandTotal) : null)
                + "<p style=\"margin-top:14px;\">The request is currently <b>pending</b> - "
                + "the dress is not reserved until you approve it.</p>";
        return shell("New Booking Request", "Booking #" + bookingId + " for "
                + dressName + " needs your review.", body);
    }

    /** Customer: owner approved. */
    public static String bookingApproved(int bookingId, String customerName,
            String dressName, String start, String end,
            double grandTotal) {
        String body = "<p>Dear " + esc(customerName) + ",</p>"
                + "<p>Good news! Your booking request has been <b>approved</b> by the "
                + "dress owner.</p>"
                + "<p>" + statusBanner("Status: Approved", GREEN) + "</p>"
                + detailTable("#" + bookingId, dressName, start + " to " + end,
                        grandTotal >= 0 ? money(grandTotal) : null)
                + "<p style=\"margin-top:14px;\">Please log in to your Lend &amp; Lace "
                + "account to arrange the payment and complete your rental. (This email "
                + "confirms the booking decision only - it is not a payment confirmation.)</p>";
        return shell("Booking Approved", "Booking #" + bookingId + " for "
                + dressName + " has been approved.", body);
    }

    /** Customer: owner rejected. */
    public static String bookingRejected(int bookingId, String customerName,
            String dressName, String start, String end) {
        String body = "<p>Dear " + esc(customerName) + ",</p>"
                + "<p>We are sorry - your booking request was <b>not approved</b> by "
                + "the dress owner. The dates may no longer be available, or the owner "
                + "may have declined this request.</p>"
                + "<p>" + statusBanner("Status: Rejected", RED) + "</p>"
                + detailTable("#" + bookingId, dressName, start + " to " + end, null)
                + "<p style=\"margin-top:14px;\">You can browse the collection any time "
                + "and request another dress.</p>";
        return shell("Booking Not Approved", "Booking #" + bookingId + " for "
                + dressName + " was not approved.", body);
    }
}
