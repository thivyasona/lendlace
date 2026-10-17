package com.lendlace.servlet;

import com.lendlace.dao.UserDAO;
import com.lendlace.model.User;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String selectedRole = request.getParameter("role");

        if (email == null || password == null || selectedRole == null
                || email.trim().isEmpty() || password.isEmpty()
                || selectedRole.trim().isEmpty()) {
            response.sendRedirect("login.jsp?error=1");
            return;
        }

        UserDAO dao = new UserDAO();

        User user = dao.login(email.trim(), password);

        if (user != null) {

            // SUSPENDED ACCOUNTS CANNOT LOG IN (status persisted in MySQL)
            String status = new com.lendlace.dao.CustomerDAO().getStatus(user.getUserId());
            if ("SUSPENDED".equalsIgnoreCase(status)) {
                response.sendRedirect("login.jsp?suspended=1");
                return;
            }

            // SECURITY: the chosen "Login as" role must match the role stored in MySQL.
            // A customer selecting "Login as Owner" or "Login as Admin" is rejected;
            // the session role always comes from the database, never from the form.
            if (!selectedRole.trim().equalsIgnoreCase(user.getRole())) {
                response.sendRedirect("login.jsp?role=1");
                return;
            }

            // session fixation protection: invalidate any pre-existing session first
            HttpSession oldSession = request.getSession(false);
            if (oldSession != null) oldSession.invalidate();

            HttpSession session = request.getSession(true);
            session.setAttribute("loggedUser", user);
            session.setMaxInactiveInterval(30 * 60); // 30 minute timeout

            // route strictly by the role stored in MySQL, not the form
            if ("ADMIN".equalsIgnoreCase(user.getRole())) {
                response.sendRedirect("admin-dashboard.jsp");
            } else if ("OWNER".equalsIgnoreCase(user.getRole())) {
                response.sendRedirect("owner-dashboard.jsp");
            } else {
                response.sendRedirect("customer-dashboard.jsp");
            }
        } else {
            response.sendRedirect("login.jsp?error=1");
        }
    }
}