package com.lendlace.util;

import com.lendlace.model.User;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Server-side, DB-backed role enforcement.
 * The role comes ONLY from the authenticated session (which was populated by
 * LoginServlet from MySQL). Anything sent by the browser is ignored.
 *
 * Rules:
 * - Not logged in -> redirect to login.jsp
 * - customer on admin URL -> access denied (403), then their dashboard
 * - owner on admin URL -> access denied (403), then their dashboard
 * - admin on owner URLs -> allowed (admin manages everything)
 * - customer on owner URLs -> access denied (403), then their dashboard
 */
public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        String path = request.getServletPath() == null
                ? "" : request.getServletPath().toLowerCase();

        // the new password-change servlet is shared by CUSTOMER and OWNER
        if (path.equals("/changepassword") || path.equals("/changeemail")) {
            chain.doFilter(req, res);
            return;
        }

        // Customer-only URLs: anything the CUSTOMER needs after logging in
        boolean customerArea = path.equals("/customer-dashboard.jsp")
                || path.equals("/my-bookings.jsp") || path.equals("/my-reviews.jsp")
                || path.equals("/wishlist.jsp") || path.equals("/profile.jsp")
                || path.equals("/booking.jsp") || path.equals("/payment.jsp")
                || path.equals("/booking-success.jsp") || path.equals("/wishlist")
                || path.equals("/review") || path.equals("/payment")
                || path.equals("/updateProfile");

        // Owner-only URLs
        boolean ownerArea = path.equals("/owner-dashboard.jsp")
                || path.equals("/add-dress.jsp") || path.equals("/edit-dress.jsp")
                || path.equals("/manage-dresses.jsp") || path.equals("/owner-bookings.jsp")
                || path.equals("/owner-profile.jsp") || path.equals("/earnings.jsp")
                || path.equals("/reviews.jsp") || path.equals("/addDress")
                || path.equals("/updatedress") || path.equals("/deletedress")
                || path.equals("/ownerbooking");

        // Admin-only URLs
        boolean adminArea = path.equals("/admin-dashboard.jsp")
                || path.equals("/admin-accounts.jsp") || path.equals("/admincredentialreset")
                || path.equals("/adminbooking") || path.equals("/admin");

        // Dress-management servlets must be OWNER (admin read-only views excluded)
        HttpSession session = request.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("loggedUser");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String role = user.getRole() == null ? "" : user.getRole().toUpperCase();

        if (adminArea && !"ADMIN".equals(role)) {
            deny(request, response, role);
            return;
        }
        if (ownerArea && !"OWNER".equals(role) && !"ADMIN".equals(role)) {
            deny(request, response, role);
            return;
        }
        if (customerArea && !"CUSTOMER".equals(role) && !"OWNER".equals(role)
                && !"ADMIN".equals(role)) {
            deny(request, response, role);
            return;
        }

        chain.doFilter(req, res);
    }

    private void deny(HttpServletRequest request, HttpServletResponse response, String role)
            throws IOException {
        response.setHeader("Cache-Control", "no-store");
        if ("OWNER".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/owner-dashboard.jsp?access=denied");
        } else if ("ADMIN".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/admin-dashboard.jsp?access=denied");
        } else {
            // customers and anyone unknown get an explicit 403 access-denied page
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Access denied: this page requires a different role.");
        }
    }
}
