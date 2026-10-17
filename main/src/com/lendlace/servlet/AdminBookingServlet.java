package com.lendlace.servlet;

import com.lendlace.dao.BookingDAO;
import com.lendlace.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/adminBooking")
public class AdminBookingServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        jakarta.servlet.http.HttpSession session = request.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("loggedUser");
        if (user == null || !"ADMIN".equalsIgnoreCase(user.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Admin access required");
            return;
        }

        String idValue = request.getParameter("bookingId");
        String action = request.getParameter("action");
        int bookingId;
        String newStatus;
        try {
            bookingId = Integer.parseInt(idValue);
        } catch (Exception e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid booking ID");
            return;
        }
        if ("approve".equalsIgnoreCase(action)) {
            newStatus = "Approved";
        } else if ("reject".equalsIgnoreCase(action)) {
            newStatus = "Rejected";
        } else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid booking action");
            return;
        }

        boolean updated = new BookingDAO().updateBookingStatus(bookingId, newStatus);
        if (!updated) {
            response.sendRedirect("admin-dashboard.jsp?bookingUpdate=failed#bookings");
        } else {
            response.sendRedirect("admin-dashboard.jsp?bookingUpdate=success#bookings");
        }
    }
}
