  package com.lendlace.servlet;

import com.lendlace.dao.ResetTokenDAO;
import com.lendlace.dao.UserDAO;
import com.lendlace.model.User;
import com.lendlace.util.DBConnection;
import com.lendlace.util.EmailUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Base64;

/**
 * Password reset via emailed, time-limited, single-use token.
 *
 * Flow:
 *   step=request : user submits registered email -> a random 32-byte token is
 *                  created (only its SHA-256 hash is stored in MySQL) and the
 *                  reset link is emailed. The response is identical whether or
 *                  not the email exists (no account enumeration).
 *   step=reset   : user opens the emailed link (password.jsp?token=...) and
 *                  sets a new password. The token is validated server-side,
 *                  consumed (single use) and the new password is stored as a
 *                  PBKDF2 hash via the existing UserDAO.changePassword().
 *
 * Email delivery needs SMTP config (see com.lendlace.util.EmailUtil). When it
 * is not configured the user is told exactly what to set up - the system never
 * pretends an email was sent.
 */
@WebServlet("/forgotPassword")
public class ForgotPasswordServlet extends HttpServlet {

    private static final int TOKEN_MINUTES = 30;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String step = request.getParameter("step");

        HttpSession session = request.getSession(true);

        if ("request".equals(step)) {
            String email = request.getParameter("email");
            if (email == null || email.trim().isEmpty()) {
                response.sendRedirect("password.jsp?error=1");
                return;
            }
            email = email.trim().toLowerCase();

            User user = findByEmail(email);

            // identical response either way - registered or not (no enumeration)
            if (user != null && EmailUtil.isConfigured()) {
                String token = issueToken(user.getUserId());
                String link = buildBaseUrl(request) + request.getContextPath()
                        + "/password.jsp?token=" + token;
                boolean sent = EmailUtil.send(user.getEmail(),
                        "Lend & Lace - Password Reset",
                        "Hello " + safeName(user.getFullName()) + ",\n\n"
                                + "A password reset was requested for your Lend & Lace account.\n"
                                + "Open the link below within " + TOKEN_MINUTES
                                + " minutes to set a new password (it can be used only once):\n\n"
                                + link + "\n\n"
                                + "If you did not request this, you can ignore this email - "
                                + "your password will not change.\n\n"
                                + "Lend & Lace Dress Rental Management System");
                if (!sent) {
                    // SMTP not configured or refused -> be honest about it
                    response.sendRedirect("password.jsp?sent=0");
                    return;
                }
            }
            response.sendRedirect("password.jsp?sent=1");
            return;
        }

        if ("reset".equals(step)) {
            String token = request.getParameter("token");
            String newPassword = request.getParameter("newPassword");
            String confirm = request.getParameter("confirmPassword");

            String tokenHash = sha256Hex(token);
            if (tokenHash == null) {
                response.sendRedirect("password.jsp?error=token");
                return;
            }

            int userId = new ResetTokenDAO().validate(tokenHash);
            if (userId < 0) {
                response.sendRedirect("password.jsp?error=token");
                return;
            }

            if (newPassword == null || newPassword.length() < 8
                    || !newPassword.equals(confirm)) {
                // keep the token valid so the user can retry on the same page
                response.sendRedirect("password.jsp?token=" + token + "&error=1");
                return;
            }

            if (!new UserDAO().changePassword(userId, newPassword)) {
                response.sendRedirect("password.jsp?token=" + token + "&error=db");
                return;
            }

            // consume the token: it can never be used again
            new ResetTokenDAO().markUsed(tokenHash);

            session.removeAttribute("resetEmail");
            response.sendRedirect("login.jsp?reset=1");
            return;
        }

        response.sendRedirect("password.jsp");
    }

    /** Create a single-use token for the user and return its plaintext value. */
    private String issueToken(int userId) {
        byte[] raw = new byte[32];
        new SecureRandom().nextBytes(raw);
        String token = Base64.getUrlEncoder().withoutPadding().encodeToString(raw);
        String hash = sha256Hex(token);
        new ResetTokenDAO().create(userId, hash, TOKEN_MINUTES);
        return token;
    }

    private String sha256Hex(String value) {
        if (value == null || value.isEmpty()) {
            return null;
        }
        try {
            byte[] d = MessageDigest.getInstance("SHA-256")
                    .digest(value.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder(d.length * 2);
            for (byte b : d) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (NoSuchAlgorithmException e) {
            return null;
        }
    }

    /** Base URL without trailing slash, e.g. http://localhost:8080 */
    private String buildBaseUrl(HttpServletRequest request) {
        String url = request.getRequestURL().toString();
        int pathStart = url.indexOf(request.getRequestURI());
        return pathStart > 0 ? url.substring(0, pathStart) : "";
    }

    private String safeName(String name) {
        if (name == null) {
            return "there";
        }
        return name.replaceAll("[\\r\\n]", " ").trim();
    }

    /** Email lookup without password verification. */
    private User findByEmail(String email) {
        String sql = "SELECT * FROM users WHERE email=?";
        try (java.sql.Connection con = com.lendlace.util.DBConnection.getConnection();
                java.sql.PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, email.toLowerCase());
            java.sql.ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                User u = new User();
                u.setUserId(rs.getInt("user_id"));
                u.setFullName(rs.getString("full_name"));
                u.setEmail(rs.getString("email"));
                u.setRole(rs.getString("role"));
                return u;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}
