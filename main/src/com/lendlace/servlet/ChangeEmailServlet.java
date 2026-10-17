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
 * Self-service email change for any logged-in user.
 * The user MUST re-enter their CURRENT password, which is verified against
 * the stored PBKDF2 hash, before the email is updated. The target user comes
 * only from the server-side session - never from a request parameter - so one
 * user cannot change another user's email.
 *
 * Validation:
 * - email format: ^[^@\s]+@[^@\s]+\.[^@\s]+$
 * - duplicate emails rejected via the unique key on users.email
 * (plus an explicit pre-check for a friendlier message)
 * - roles are NEVER changed here; accounts are never deleted
 * - every successful change writes an audit row (no passwords logged)
 */
@WebServlet("/changeEmail")
public class ChangeEmailServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("loggedUser");

        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String back = "OWNER".equalsIgnoreCase(user.getRole())
                ? "owner-profile.jsp"
                : "profile.jsp";

        String newEmail = request.getParameter("newEmail");
        String currentPassword = request.getParameter("currentPassword");

        // 1. validate the new email format
        if (newEmail == null || newEmail.trim().isEmpty()
                || !newEmail.trim().matches("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$")) {
            response.sendRedirect(back + "?emailError=validate");
            return;
        }
        newEmail = newEmail.trim().toLowerCase();

        // 2. verify the CURRENT password against the stored hash
        String stored = new UserDAO().getStoredPassword(user.getUserId());
        if (stored == null || !PasswordUtil.verify(currentPassword, stored)) {
            response.sendRedirect(back + "?emailError=current");
            return;
        }

        // 3. prevent changing to the same email
        if (newEmail.equalsIgnoreCase(user.getEmail())) {
            response.sendRedirect(back + "?emailError=same");
            return;
        }

        UserDAO dao = new UserDAO();

        // 4. explicit duplicate check for a friendly message
        // (the DB unique key enforces this too, in case of a race)
        if (dao.emailExists(newEmail)) {
            response.sendRedirect(back + "?emailError=duplicate");
            return;
        }

        // 5. update
        if (dao.changeEmail(user.getUserId(), newEmail)) {
            // keep the session object in sync
            user.setEmail(newEmail);
            session.setAttribute("loggedUser", user);
            dao.auditCredentialChange(user.getUserId(), "self", "EMAIL_CHANGE",
                    "email changed to " + newEmail);
            response.sendRedirect(back + "?emailSuccess=1");
        } else {
            response.sendRedirect(back + "?emailError=db");
        }
    }
}
