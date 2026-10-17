package com.lendlace.servlet;

import com.lendlace.dao.BookingDAO;
import com.lendlace.model.Booking;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/ownerBooking")
public class OwnerBookingServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        com.lendlace.model.User user = (com.lendlace.model.User) request.getSession()
                .getAttribute("loggedUser");
        if (user == null || !"OWNER".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect("login.jsp");
            return;
        }

        String idValue = request.getParameter("bookingId");
        String action = request.getParameter("action");
        if (idValue == null || action == null) {
            response.sendRedirect("owner-bookings.jsp?bookingUpdate=failed");
            return;
        }

        int bookingId;
        try {
            bookingId = Integer.parseInt(idValue);
        } catch (NumberFormatException e) {
            response.sendRedirect("owner-bookings.jsp?bookingUpdate=failed");
            return;
        }

        BookingDAO dao = new BookingDAO();

        boolean updated;
        if ("approve".equals(action) || "reject".equals(action)) {
            // dates come from the booking row itself, never from the form
            Booking booking = dao.getBookingById(bookingId);
            if (booking == null) {
                response.sendRedirect("owner-bookings.jsp?bookingUpdate=failed");
                return;
            }
            // OWNERSHIP + PENDING + OVERLAP CHECK, atomically:
            // - the booking must belong to a dress owned by this owner
            // - only still-PENDING bookings can be processed (no repeats)
            // - accepting is refused when an APPROVED booking already covers
            //   the same dates (clear message via bookingUpdate=conflict)
            String newStatus = "approve".equals(action) ? "Approved" : "Rejected";
            int result = dao.updateStatusIfPendingForOwner(
                    bookingId, user.getUserId(), newStatus,
                    booking.getStartDate(), booking.getEndDate());

            if (result == -1) {
                response.sendRedirect("owner-dashboard.jsp?bookingUpdate=conflict");
                return;
            }
            updated = result == 1;

            // NOTIFICATIONS - only after the DB update actually changed the row
            // (result == 1). Repeated clicks return 0, so no duplicate mails are
            // sent for an unchanged status.
            if (updated) {
                try {
                    com.lendlace.model.Booking fresh = dao.getBookingById(bookingId);
                    if (fresh != null) {
                        boolean mailed = "approve".equals(action)
                                ? com.lendlace.util.BookingEmailService.sendBookingApproved(fresh)
                                : com.lendlace.util.BookingEmailService.sendBookingRejected(fresh);
                        if (!mailed) {
                            System.err.println("Booking " + bookingId
                                    + ": decision email not delivered (logged for retry)");
                        }
                    }
                } catch (Exception mailEx) {
                    // the status change is already saved; never reverse it on mail failure
                    System.err.println("Notification step skipped: "
                            + mailEx.getClass().getSimpleName());
                }
            }
        } else {
            updated = false;
        }

        response.sendRedirect("owner-bookings.jsp?bookingUpdate="
                + (updated ? "success" : "failed"));
    }
}