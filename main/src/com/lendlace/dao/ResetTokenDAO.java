package com.lendlace.dao;

import com.lendlace.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.time.LocalDateTime;

/**
 * Storage for password-reset tokens.
 *
 * Security model:
 * - The token value emailed to the user is 32 random bytes (base64url).
 * - Only its SHA-256 hash is stored in MySQL (column token_hash), so a
 * database leak does not expose usable reset links.
 * - Tokens expire after 30 minutes and are single-use (used_at is set
 * when consumed; a used or expired token is rejected and removed).
 */
public class ResetTokenDAO {

    /**
     * Insert a new token hash for a user. Older tokens for that user are removed
     * first.
     */
    public boolean create(int userId, String tokenHash, int validMinutes) {
        String del = "DELETE FROM password_reset_tokens WHERE user_id=?";
        String ins = "INSERT INTO password_reset_tokens(user_id, token_hash, expires_at) VALUES(?,?,?)";
        try (Connection con = DBConnection.getConnection()) {
            try (PreparedStatement ps = con.prepareStatement(del)) {
                ps.setInt(1, userId);
                ps.executeUpdate();
            }
            try (PreparedStatement ps = con.prepareStatement(ins)) {
                ps.setInt(1, userId);
                ps.setString(2, tokenHash);
                ps.setTimestamp(3, Timestamp.valueOf(LocalDateTime.now().plusMinutes(validMinutes)));
                return ps.executeUpdate() > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Validate a token hash: must exist, be unexpired and unused.
     * Returns the owning user_id, or -1 when invalid.
     * Expired/used rows are deleted so they can never be reused.
     */
    public int validate(String tokenHash) {
        String sql = "SELECT user_id, expires_at, used_at FROM password_reset_tokens WHERE token_hash=?";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, tokenHash);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                int userId = rs.getInt("user_id");
                Timestamp expires = rs.getTimestamp("expires_at");
                Timestamp used = rs.getTimestamp("used_at");
                if (used != null || expires == null
                        || expires.toInstant().isBefore(java.time.Instant.now())) {
                    deleteByHash(con, tokenHash); // never reusable
                    return -1;
                }
                return userId;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    /** Mark a token as consumed. */
    public void markUsed(String tokenHash) {
        String sql = "UPDATE password_reset_tokens SET used_at=CURRENT_TIMESTAMP WHERE token_hash=?";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, tokenHash);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void deleteByHash(Connection con, String tokenHash) {
        try (PreparedStatement ps = con.prepareStatement(
                "DELETE FROM password_reset_tokens WHERE token_hash=?")) {
            ps.setString(1, tokenHash);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
