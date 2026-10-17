package com.lendlace.servlet;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.lendlace.model.User;

@WebServlet("/admin")
public class AdminServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        // verify the authenticated session and the DB-backed role on the server
        HttpSession session = request.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("loggedUser");

        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        if (!"ADMIN".equalsIgnoreCase(user.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Access denied: administrator privileges required.");
            return;
        }

        String action = request.getParameter("action");

        if ("users".equals(action)) {

            response.sendRedirect("admin-dashboard.jsp#customers");

        } else if ("dresses".equals(action)) {

            response.sendRedirect("manage-dresses.jsp");

        } else if ("bookings".equals(action)) {

            response.sendRedirect("admin-dashboard.jsp#bookings");

        } else {

            response.sendRedirect("admin-dashboard.jsp");

        }
    }
}