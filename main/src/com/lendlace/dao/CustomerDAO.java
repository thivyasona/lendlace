package com.lendlace.dao;

import com.lendlace.model.Booking;
import com.lendlace.model.User;
import com.lendlace.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Admin customer-management queries. Everything here runs against the real
 * MySQL tables (users, bookings) with PreparedStatements - no fabricated data.
 *
 * Account status uses the users.status column:
 * 'ACTIVE' (default) | 'SUSPENDED'
 */
public class CustomerDAO {

    /** Row of the Manage Customers list: profile + live booking statistics. */
    public static class CustomerRow {
        public User user;
        public int totalBookings;
        public int completedBookings; // Approved/Confirmed/Completed
        public int pendingBookings;
    }

    private User mapUser(ResultSet rs) throws SQLException {
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

    /**
     * Search / filter / sort the customer list.
     * q: name or email substring (nullable), status: 'ACTIVE'|'SUSPENDED'|null,
     * sort: 'registered' (default) | 'bookings'.
     */
    public List<CustomerRow> searchCustomers(String q, String status, String sort) {
        List<CustomerRow> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder(
            "SELECT u.*, COUNT(b.booking_id) AS total_bookings, " +
            "SUM(CASE WHEN LOWER(b.status) IN ('approved','confirmed','completed') THEN 1 ELSE 0 END) AS completed_bookings, " +
            "SUM(CASE WHEN LOWER(b.status)='pending' THEN 1 ELSE 0 END) AS pending_bookings " +
            "FROM users u LEFT JOIN bookings b ON b.customer_id=u.user_id " +
            "WHERE u.role='CUSTOMER' ");

        boolean hasQuery = q != null && !q.trim().isEmpty();
        if (hasQuery) sql.append("AND (u.full_name LIKE ? OR u.email LIKE ?) ");
        boolean hasStatus = "SUSPENDED".equalsIgnoreCase(status) || "ACTIVE".equalsIgnoreCase(status);
        if (hasStatus) sql.append("AND UPPER(u.status)=? ");

        sql.append("GROUP BY u.user_id ORDER BY ");
        if ("bookings".equalsIgnoreCase(sort)) {
            sql.append("total_bookings DESC, u.user_id ASC");
        } else {
            sql.append("u.created_at DESC, u.user_id DESC");
        }

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            int i = 1;
            if (hasQuery) {
                ps.setString(i++, "%" + q.trim() + "%");
                ps.setString(i++, "%" + q.trim() + "%");
            }
            if (hasStatus) ps.setString(i++, status.toUpperCase());
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                CustomerRow row = new CustomerRow();
                row.user = mapUser(rs);
                row.user.setPassword(null); // never expose hashes to the UI
                row.totalBookings = rs.getInt("total_bookings");
                row.completedBookings = rs.getInt("completed_bookings");
                row.pendingBookings = rs.getInt("pending_bookings");
                list.add(row);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /** Counts used for suspend/reactivate guards and statistics. */
    public static class BookingCounts {
        public int total;
        public int pending;
        public int approved;
        public int paid;
    }

    public BookingCounts countBookings(int customerId) {
        BookingCounts c = new BookingCounts();
        String sql = "SELECT COUNT(*) AS total, " +
                "SUM(CASE WHEN LOWER(status)='pending' THEN 1 ELSE 0 END) AS pending, " +
                "SUM(CASE WHEN LOWER(status) IN ('approved','confirmed') THEN 1 ELSE 0 END) AS approved " +
                "FROM bookings WHERE customer_id=?";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                c.total = rs.getInt("total");
                c.pending = rs.getInt("pending");
                c.approved = rs.getInt("approved");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        // unresolved payments for this customer's bookings
        String sql2 = "SELECT COUNT(*) FROM payments p JOIN bookings b ON p.booking_id=b.booking_id " +
                "WHERE b.customer_id=? AND LOWER(p.payment_status)='paid'";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql2)) {
            ps.setInt(1, customerId);
            ResultSet rs = ps.executeQuery();
            if (rs.next())
                c.paid = rs.getInt(1);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return c;
    }

    /** Persistently suspend a CUSTOMER account. Refuses ADMIN/OWNER rows. */
    public boolean setStatus(int customerId, boolean suspended) {
        String sql = "UPDATE users SET status=? WHERE user_id=? AND role='CUSTOMER'";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, suspended ? "SUSPENDED" : "ACTIVE");
            ps.setInt(2, customerId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /** Status of a single user, for the suspend guard and login check. */
    public String getStatus(int userId) {
        String sql = "SELECT status FROM users WHERE user_id=?";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next())
                return rs.getString("status");
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Hard delete of a CUSTOMER. Blocked when booking history exists
     * (bookings/dresses/payments FKs reference the customer, and history must
     * be preserved) - callers must offer Deactivate instead. Returns:
     * 1 = deleted, 0 = not found / not a customer, -1 = blocked by history.
     */
    public int deleteCustomerIfNoHistory(int customerId) {
        BookingCounts c = countBookings(customerId);
        if (c.total > 0 || c.paid > 0)
            return -1;
        String sql = "DELETE FROM users WHERE user_id=? AND role='CUSTOMER'";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            return ps.executeUpdate() > 0 ? 1 : 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    /** Booking history for the View Details page (reuse of existing joins). */
    public List<Booking> getBookingHistory(int customerId) {
        return new BookingDAO().getBookingsByCustomer(customerId);
    }
}
