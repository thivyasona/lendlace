package com.lendlace.servlet;

import com.lendlace.dao.BookingDAO;
import com.lendlace.model.Booking;
import com.lendlace.model.User;

import java.io.IOException;
import java.time.temporal.ChronoUnit;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/bookDress")
public class BookingServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {
     HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("loggedUser") == null) {

        response.sendRedirect("login.jsp");
        return;
    }
    User user = (User) session.getAttribute("loggedUser");

    // SERVER-SIDE RESTRICTION: only customers create bookings
    if (!"CUSTOMER".equalsIgnoreCase(user.getRole())) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN,
                "Access denied: only customers can book dresses.");
        return;
    }

    // SUSPENDED ACCOUNTS CANNOT CREATE NEW BOOKINGS (re-check from MySQL,
    // not from the session, so a suspension always applies immediately)
    String acctStatus = new com.lendlace.dao.CustomerDAO().getStatus(user.getUserId());
    if ("SUSPENDED".equalsIgnoreCase(acctStatus)) {
        session.invalidate();
        response.sendRedirect("login.jsp?suspended=1");
        return;
    }

        Booking booking = new Booking();
        booking.setCustomerId(user.getUserId());

        int dressId;
        try {
            dressId = Integer.parseInt(request.getParameter("dressId"));
        } catch (NumberFormatException e) {
            response.sendRedirect("browse-dresses.jsp?error=1");
            return;
        }

        // load the dress from MySQL: prices and ownership come from the DB, not the form
        com.lendlace.model.Dress dress = new com.lendlace.dao.DressDAO().getDressById(dressId);
        if (dress == null) {
            response.sendRedirect("browse-dresses.jsp?error=1");
            return;
        }

        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        if (startDate == null || endDate == null
                || !startDate.matches("\\d{4}-\\d{2}-\\d{2}")
                || !endDate.matches("\\d{4}-\\d{2}-\\d{2}")
                || endDate.compareTo(startDate) < 0) {
            response.sendRedirect("booking.jsp?dressId=" + dressId + "&error=1");
            return;
        }

        // compute rental days and totals server-side (client values are never trusted)
        long days;
        try {
            days = ChronoUnit.DAYS.between(
                    java.time.LocalDate.parse(startDate),
                    java.time.LocalDate.parse(endDate)) + 1;
        } catch (Exception e) {
            response.sendRedirect("booking.jsp?dressId=" + dressId + "&error=1");
            return;
        }
        if (days < 1 || days > 60) {
            response.sendRedirect("booking.jsp?dressId=" + dressId + "&error=1");
            return;
        }

        // SERVER-SIDE OVERLAP CHECK: the requested window must not collide with
        // any Pending/Approved/Confirmed booking of the same dress.
        BookingDAO overlapDao = new BookingDAO();
        if (overlapDao.hasOverlappingBooking(dressId, startDate, endDate)) {
            response.sendRedirect("booking.jsp?dressId=" + dressId + "&error=unavailable");
            return;
        }

        double rentalCost = dress.getPricePerDay() * days;
        double deposit = dress.getSecurityDeposit();

        booking.setDressId(dressId);
        booking.setStartDate(startDate);
        booking.setEndDate(endDate);
        booking.setRentalDays((int) days);
        booking.setRentalCost(rentalCost);
        booking.setSecurityDeposit(deposit);
        booking.setGrandTotal(rentalCost + deposit); // deposit is refundable, added per project convention
        booking.setSize(request.getParameter("size"));
        booking.setStatus("Pending");


        BookingDAO dao = new BookingDAO();

        if (dao.addBooking(booking)) {

            // NOTIFICATIONS (after the row is safely committed):
            // - addBooking does not return the generated key, so re-read the
            //   customer's latest booking to get the real booking id for the mails.
            // - An email failure must never corrupt or reverse the saved booking;
            //   the redirect below is unchanged either way.
            try {
                com.lendlace.model.Booking saved =
                        dao.getLatestBookingByCustomer(user.getUserId());
                if (saved != null && saved.getDressId() == dressId
                        && startDate.equals(saved.getStartDate())) {
                    boolean mailed = com.lendlace.util.BookingEmailService
                            .sendBookingRequested(saved);
                    if (!mailed) {
                        // recorded in email_notification_log by the service
                        System.err.println("Booking " + (saved == null ? "?" : saved.getBookingId())
                                + ": notification not delivered (logged for retry)");
                    }
                }
            } catch (Exception mailEx) {
                System.err.println("Notification step skipped: "
                        + mailEx.getClass().getSimpleName());
            }

            response.sendRedirect("my-bookings.jsp?success=1");

        } else {

            response.sendRedirect("booking.jsp?error=1");

        }
    }
}