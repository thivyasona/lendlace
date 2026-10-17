package com.lendlace.dao;

import com.lendlace.model.User;
import com.lendlace.util.DBConnection;
import com.lendlace.util.PasswordUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {

    public User login(String email, String password) {

        User user = null;

        // password is verified in Java (hash check); only email is used as a filter
        String sql = "SELECT * FROM users WHERE email=?";

        try {

            Connection con = DBConnection.getConnection();

            PreparedStatement ps = con.prepareStatement(sql);

            ps.setString(1, email == null ? "" : email.trim().toLowerCase());

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {

                String stored = rs.getString("password");

                if (PasswordUtil.verify(password, stored)) {

                    user = new User();

                    user.setUserId(rs.getInt("user_id"));
                    user.setFullName(rs.getString("full_name"));
                    user.setEmail(rs.getString("email"));
                    user.setPassword(stored);
                    user.setPhone(rs.getString("phone"));
                    user.setAddress(rs.getString("address"));
                    user.setRole(rs.getString("role"));
                    user.setProfileImage(rs.getString("profile_image"));
                    user.setCreatedAt(rs.getString("created_at"));

                    // transparently migrate legacy plaintext passwords to hashes
                    if (PasswordUtil.needsRehash(stored)) {
                        updatePasswordHash(user.getUserId(), PasswordUtil.hash(password));
                    }
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return user;
    }

    /** Used by login() to upgrade legacy plaintext rows to hashed values. */
    private void updatePasswordHash(int userId, String hash) {
        String sql = "UPDATE users SET password=? WHERE user_id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, hash);
            ps.setInt(2, userId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /** Change a password (hashed). Used by profile/password pages. */
    public boolean changePassword(int userId, String newPlainPassword) {
        String sql = "UPDATE users SET password=? WHERE user_id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, PasswordUtil.hash(newPlainPassword));
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Change a user's email address. The email must already be validated and
     * lowercase/trimmed by the caller; duplicate-email protection is enforced
     * by the unique key on users.email (the UPDATE simply fails if taken).
     */
    public boolean changeEmail(int userId, String newEmail) {
        String sql = "UPDATE users SET email=? WHERE user_id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, newEmail);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            // unique-key violation (duplicate email) or other DB error
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Insert an audit row for a credential change.
     * NEVER pass passwords into detail - only emails or 'current/new' labels.
     */
    public void auditCredentialChange(int targetUserId, String actor,
                                      String action, String detail) {
        String sql = "INSERT INTO credential_audit_log(target_user, actor, action, detail) VALUES(?,?,?,?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, targetUserId);
            ps.setString(2, actor == null ? "system" : actor);
            ps.setString(3, action);
            ps.setString(4, detail);
            ps.executeUpdate();
        } catch (Exception e) {
            // audit failure must not block the credential change itself,
            // but it is logged loudly so the gap is visible
            System.err.println("AUDIT WRITE FAILED for user " + targetUserId + ": "
                    + e.getClass().getSimpleName());
        }
    }

    /** Fetch only the stored (hashed) password of a user - used to verify the current password. */
    public String getStoredPassword(int userId) {
        String sql = "SELECT password FROM users WHERE user_id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getString("password");
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean register(User user) {

        String sql = "INSERT INTO users(full_name,email,password,phone,address,role,profile_image) VALUES(?,?,?,?,?,?,?)";

        try {

            Connection con = DBConnection.getConnection();

            PreparedStatement ps = con.prepareStatement(sql);

            ps.setString(1, user.getFullName());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPassword());
            ps.setString(4, user.getPhone());
            ps.setString(5, user.getAddress());
            ps.setString(6, user.getRole());
            ps.setString(7, user.getProfileImage());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            // duplicate email (unique key violation) or other DB error
            e.printStackTrace();
        }

        return false;
    }

    public boolean emailExists(String email) {
        String sql = "SELECT COUNT(*) FROM users WHERE email=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1) > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return true; // fail closed
    }

    public boolean adminExists() {
        String sql = "SELECT COUNT(*) FROM users WHERE role='ADMIN'";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1) > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return true; // fail closed
    }

    public int countByRole(String role) {
        String sql = "SELECT COUNT(*) FROM users WHERE role=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, role);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public List<User> getUsersByRole(String role) {
        List<User> list = new ArrayList<>();
        String sql = "SELECT * FROM users WHERE role=? ORDER BY user_id DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, role);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                User u = new User();
                u.setUserId(rs.getInt("user_id"));
                u.setFullName(rs.getString("full_name"));
                u.setEmail(rs.getString("email"));
                u.setPhone(rs.getString("phone"));
                u.setAddress(rs.getString("address"));
                u.setRole(rs.getString("role"));
                u.setProfileImage(rs.getString("profile_image"));
                u.setCreatedAt(rs.getString("created_at"));
                list.add(u);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /** Fetch a user by id (used to show real owner details on dress pages). */
    public User getUserById(int userId) {
        String sql = "SELECT * FROM users WHERE user_id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                User u = new User();
                u.setUserId(rs.getInt("user_id"));
                u.setFullName(rs.getString("full_name"));
                u.setEmail(rs.getString("email"));
                u.setPhone(rs.getString("phone"));
                u.setAddress(rs.getString("address"));
                u.setRole(rs.getString("role"));
                u.setProfileImage(rs.getString("profile_image"));
                u.setCreatedAt(rs.getString("created_at"));
                return u;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean updateUser(User user) {

        String sql = "UPDATE users SET full_name=?, email=?, phone=?, address=? WHERE user_id=?";

        try {

            Connection con = DBConnection.getConnection();

            PreparedStatement ps = con.prepareStatement(sql);

            ps.setString(1, user.getFullName());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPhone());
            ps.setString(4, user.getAddress());
            ps.setInt(5, user.getUserId());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }
}