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
 * Authenticated password change for CUSTOMER and OWNER accounts.
 * Reached from profile.jsp / owner-profile.jsp.
 * The target user is ALWAYS taken from the server-side session,
 * never from a request parameter, so one user can never change
 * another user's password by editing the URL or form.
 */
@WebServlet("/changePassword")
public class ChangePasswordServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        User user = session == null ? null : (User) session.getAttribute("loggedUser");

        if (user == null || "ADMIN".equalsIgnoreCase(user.getRole())) {
            // not logged in, or admins use the dedicated admin flow
            response.sendRedirect("login.jsp");
            return;
        }

        String back = "OWNER".equalsIgnoreCase(user.getRole())
                ? "owner-profile.jsp"
                : "profile.jsp";

        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        // basic validation
        if (currentPassword == null || currentPassword.isEmpty()
                || newPassword == null || newPassword.length() < 8
                || !newPassword.equals(confirmPassword)) {
            response.sendRedirect(back + "?pwdError=validate");
            return;
        }

        // verify the CURRENT password against the stored (hashed) value
        String stored = null;
        try {
            stored = new UserDAO().getStoredPassword(user.getUserId());
        } catch (Exception e) {
            e.printStackTrace();
        }

        if (stored == null || !PasswordUtil.verify(currentPassword, stored)) {
            response.sendRedirect(back + "?pwdError=current");
            return;
        }

        // prevent re-using the same password
        if (PasswordUtil.verify(newPassword, stored)) {
            response.sendRedirect(back + "?pwdError=same");
            return;
        }

        // save the new password (hashed inside changePassword)
        if (new UserDAO().changePassword(user.getUserId(), newPassword)) {
            response.sendRedirect(back + "?pwdSuccess=1");
        } else {
            response.sendRedirect(back + "?pwdError=db");
        }
    }
}
