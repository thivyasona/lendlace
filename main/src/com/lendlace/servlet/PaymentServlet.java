package com.lendlace.servlet;

import com.lendlace.dao.BookingDAO;
import com.lendlace.dao.PaymentDAO;
import com.lendlace.model.Booking;
import com.lendlace.model.Payment;
import com.lendlace.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet("/payment")
public class PaymentServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        // must be logged in and may only pay for their OWN booking
        HttpSession session = request.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("loggedUser");
        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int bookingId;
        String method = request.getParameter("paymentMethod");
        try {
            bookingId = Integer.parseInt(request.getParameter("bookingId"));
        } catch (NumberFormatException e) {
            response.sendRedirect("my-bookings.jsp?payment=failed");
            return;
        }

        // ownership check: the booking must belong to this user
        Booking booking = new BookingDAO().getBookingById(bookingId);
        if (booking == null || booking.getCustomerId() != user.getUserId()) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Access denied: you can only pay for your own bookings.");
            return;
        }
        // server decides the amount, never the form
        double amount = booking.getGrandTotal();
        if (method == null || method.trim().isEmpty()) {
            method = "Cash";
        }

        Payment payment = new Payment();
        payment.setBookingId(bookingId);
        payment.setPaymentMethod(method);
        payment.setAmount(amount);
        payment.setPaymentStatus("Paid");

        PaymentDAO paymentDAO = new PaymentDAO();
        BookingDAO bookingDAO = new BookingDAO();

        if(paymentDAO.makePayment(payment)){

            bookingDAO.updateBookingStatus(bookingId,"Confirmed");

            response.sendRedirect("my-bookings.jsp?payment=success");

        }else{

            response.sendRedirect("payment.jsp?payment=failed");

        }
    }
}