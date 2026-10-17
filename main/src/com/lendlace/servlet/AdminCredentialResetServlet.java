package com.lendlace.servlet;

import com.lendlace.dao.UserDAO;
import com.lendlace.model.User;
import com.lendlace.util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * ADMIN-ONLY credential reset for any account.
 *
 * Authorization:
 * - the caller's role must be ADMIN, taken from the server-side session
 * (the AuthFilter also guards this URL on every request)
 * - the admin must re-type their OWN current password, which is verified
 * against the stored PBKDF2 hash - so a stolen idle session cannot
 * silently reset other accounts
 *
 * What this can do (only what is explicitly asked for):
 * - reset another account's PASSWORD (hashed with the project's existing
 * PBKDF2 utility; never stored as plaintext)
 * - reset another account's EMAIL (validated, duplicates rejected)
 *
 * What this can NEVER do:
 * - change roles
 * - delete accounts
 * - reset all accounts to one shared password is not a feature of this
 * servlet: each request touches exactly one account
 *
 * Audit: every successful reset writes a row to credential_audit_log with
 * the admin's email as actor. Passwords are never written to the log.
 */
@WebServlet("/adminCredentialReset")
public class AdminCredentialResetServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User admin = session == null ? null : (User) session.getAttribute("loggedUser");

        if (admin == null || !"ADMIN".equalsIgnoreCase(admin.getRole())) {
            response.sendRedirect("login.jsp");
            return;
        }

        // the admin must confirm their own password (defense against session theft)
        String adminPassword = request.getParameter("adminPassword");
        String adminStored = new UserDAO().getStoredPassword(admin.getUserId());
        if (adminStored == null || !PasswordUtil.verify(adminPassword, adminStored)) {
            response.sendRedirect("admin-accounts.jsp?resetError=auth");
            return;
        }

        String userIdRaw = request.getParameter("targetUserId");
        int targetUserId;
        try {
            targetUserId = Integer.parseInt(userIdRaw);
        } catch (Exception e) {
            response.sendRedirect("admin-accounts.jsp?resetError=validate");
            return;
        }

        UserDAO dao = new UserDAO();
        User target = dao.getUserById(targetUserId);
        if (target == null) {
            response.sendRedirect("admin-accounts.jsp?resetError=notfound");
            return;
        }

        String action = request.getParameter("resetAction"); // "password" or "email"
        boolean updated = false;

        if ("password".equals(action)) {
            String newPassword = request.getParameter("newPassword");
            String confirmPassword = request.getParameter("confirmPassword");

            if (newPassword == null || newPassword.length() < 8
                    || !newPassword.equals(confirmPassword)) {
                response.sendRedirect("admin-accounts.jsp?resetError=validate");
                return;
            }

            updated = dao.changePassword(target.getUserId(), newPassword);
            if (updated) {
                dao.auditCredentialChange(target.getUserId(), admin.getEmail(),
                        "ADMIN_PASSWORD_RESET",
                        "password reset by admin for " + target.getEmail());
            }
        } else if ("email".equals(action)) {
            String newEmail = request.getParameter("newEmail");

            if (newEmail == null || newEmail.trim().isEmpty()
                    || !newEmail.trim().matches("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$")) {
                response.sendRedirect("admin-accounts.jsp?resetError=validate");
                return;
            }
            newEmail = newEmail.trim().toLowerCase();

            if (newEmail.equalsIgnoreCase(target.getEmail())) {
                response.sendRedirect("admin-accounts.jsp?resetError=same");
                return;
            }

            // duplicate check (the DB unique key also enforces this)
            if (dao.emailExists(newEmail)) {
                response.sendRedirect("admin-accounts.jsp?resetError=duplicate");
                return;
            }

            updated = dao.changeEmail(target.getUserId(), newEmail);
            if (updated) {
                dao.auditCredentialChange(target.getUserId(), admin.getEmail(),
                        "ADMIN_EMAIL_RESET",
                        "email changed from " + target.getEmail() + " to " + newEmail);
            }
        } else {
            response.sendRedirect("admin-accounts.jsp?resetError=validate");
            return;
        }

        response.sendRedirect("admin-accounts.jsp?resetResult="
                + (updated ? "success" : "db"));
    }
}
