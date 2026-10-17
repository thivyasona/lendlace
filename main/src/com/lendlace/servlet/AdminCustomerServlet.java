package com.lendlace.servlet;

import com.lendlace.dao.CustomerDAO;
import com.lendlace.dao.CustomerDAO.CustomerRow;
import com.lendlace.dao.CustomerDAO.BookingCounts;
import com.lendlace.dao.UserDAO;
import com.lendlace.model.Booking;
import com.lendlace.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

/**
 * Admin customer management: list (search/filter/sort), view details,
 * suspend/reactivate, deactivate, and guarded delete.
 *
 * Security:
 * - Every request re-checks the ADMIN role from the session (DB-backed role).
 * - The admin's own account can never be suspended/deactivated/deleted here.
 * - Only CUSTOMER rows are ever modified.
 * - Customer email addresses used elsewhere come from the users table, never
 * from browser parameters.
 */
@WebServlet("/adminCustomer")
public class AdminCustomerServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User admin = currentAdmin(request);
        if (admin == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        CustomerDAO dao = new CustomerDAO();

        String action = request.getParameter("action");

        // --- View details (forwards to a JSP section on the dashboard page) ---
        if ("view".equals(action)) {
            Integer customerId = parseInt(request.getParameter("customerId"));
            if (customerId == null) {
                response.sendRedirect("adminCustomer?custMsg=invalid");
                return;
            }
            // Only customers can be viewed through this feature
            UserDAO udao = new UserDAO();
            User customer = udao.getUserById(customerId);
            if (customer == null || !"CUSTOMER".equalsIgnoreCase(customer.getRole())) {
                response.sendRedirect("adminCustomer?custMsg=invalid");
                return;
            }
            List<Booking> history = dao.getBookingHistory(customerId);
            String status = dao.getStatus(customerId);
            request.setAttribute("viewCustomer", customer);
            request.setAttribute("viewHistory", history);
            request.setAttribute("viewStatus", status);
            request.setAttribute("viewCounts", dao.countBookings(customerId));
            // forward keeps the search/filter/sort state in the URL
            RequestParams.forwardWithParams(request, response, "admin-dashboard.jsp");
            return;
        }

        // --- Default: list with search/filter/sort ---
        String q = request.getParameter("q");
        String status = request.getParameter("status");
        String sort = request.getParameter("sort");
        List<CustomerRow> customers = dao.searchCustomers(q, status, sort);
        request.setAttribute("customerRows", customers);
        request.setAttribute("custQ", q == null ? "" : q);
        request.setAttribute("custStatus", status == null ? "" : status);
        request.setAttribute("custSort", sort == null ? "registered" : sort);
        RequestParams.forwardWithParams(request, response, "admin-dashboard.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User admin = currentAdmin(request);
        if (admin == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");
        Integer customerId = parseInt(request.getParameter("customerId"));
        if (action == null || customerId == null) {
            response.sendRedirect("adminCustomer?custMsg=invalid");
            return;
        }

        // The admin's own account is protected from every state change here.
        if (admin.getUserId() == customerId) {
            response.sendRedirect("adminCustomer?custMsg=self");
            return;
        }

        CustomerDAO dao = new CustomerDAO();

        switch (action) {
            case "suspend": {
                // double-check the target is a CUSTOMER and not already suspended
                if (dao.setStatus(customerId, true)) {
                    invalidateSessionsOf(customerId);
                    response.sendRedirect("adminCustomer?custMsg=suspended");
                } else {
                    response.sendRedirect("adminCustomer?custMsg=failed");
                }
                return;
            }
            case "reactivate": {
                response.sendRedirect("adminCustomer?custMsg="
                        + (dao.setStatus(customerId, false) ? "reactivated" : "failed"));
                return;
            }
            case "deactivate": {
                // Deactivate = suspend (persistent, reversible, keeps all history)
                if (dao.setStatus(customerId, true)) {
                    invalidateSessionsOf(customerId);
                    response.sendRedirect("adminCustomer?custMsg=suspended");
                } else {
                    response.sendRedirect("adminCustomer?custMsg=failed");
                }
                return;
            }
            case "delete": {
                // Guarded hard delete: refused when any booking/payment history exists
                BookingCounts c = dao.countBookings(customerId);
                if (c.total > 0 || c.paid > 0) {
                    response.sendRedirect("adminCustomer?custMsg=deleteblocked");
                    return;
                }
                int result = dao.deleteCustomerIfNoHistory(customerId);
                if (result == 1) {
                    invalidateSessionsOf(customerId);
                    response.sendRedirect("adminCustomer?custMsg=deleted");
                } else if (result == -1) {
                    response.sendRedirect("adminCustomer?custMsg=deleteblocked");
                } else {
                    response.sendRedirect("adminCustomer?custMsg=failed");
                }
                return;
            }
            default:
                response.sendRedirect("adminCustomer?custMsg=invalid");
        }
    }

    private User currentAdmin(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null)
            return null;
        User user = (User) session.getAttribute("loggedUser");
        if (user == null || !"ADMIN".equalsIgnoreCase(user.getRole()))
            return null;
        return user;
    }

    /** Invalidate any live web session belonging to the affected customer. */
    private void invalidateSessionsOf(int customerId) {
        try {
            for (HttpSession s : com.lendlace.util.SessionRegistry.all()) {
                Object attr = s.getAttribute("loggedUser");
                if (attr instanceof User && ((User) attr).getUserId() == customerId) {
                    s.invalidate();
                }
            }
        } catch (Exception e) {
            // session cleanup must never block the account update
            System.err.println("Session cleanup skipped: " + e.getClass().getSimpleName());
        }
    }

    private Integer parseInt(String v) {
        if (v == null)
            return null;
        try {
            int n = Integer.parseInt(v.trim());
            return n > 0 ? n : null;
        } catch (NumberFormatException e) {
            return null;
        }
    }

    /** Tiny helper: carry the list query params across the forward. */
    static class RequestParams {
        static void forwardWithParams(HttpServletRequest request,
                HttpServletResponse response,
                String path) throws ServletException, IOException {
            // append original query string so list state survives the forward
            String qs = request.getQueryString();
            if (qs != null && !qs.isEmpty()) {
                request.getRequestDispatcher(path + "?" + qs).forward(request, response);
            } else {
                request.getRequestDispatcher(path).forward(request, response);
            }
        }
    }
}
