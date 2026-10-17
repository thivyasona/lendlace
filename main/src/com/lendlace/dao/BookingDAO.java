package com.lendlace.dao;

import com.lendlace.model.Booking;
import com.lendlace.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
public class BookingDAO {
    // Add Booking
    public boolean addBooking(Booking booking) {
        String sql = "INSERT INTO bookings(customer_id,dress_id,start_date,end_date,rental_days,rental_cost,security_deposit,grand_total,size,status) VALUES(?,?,?,?,?,?,?,?,?,?)";
        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, booking.getCustomerId());
            ps.setInt(2, booking.getDressId());
            ps.setString(3, booking.getStartDate());
            ps.setString(4, booking.getEndDate());
            ps.setInt(5, booking.getRentalDays());
            ps.setDouble(6, booking.getRentalCost());
            ps.setDouble(7, booking.getSecurityDeposit());
            ps.setDouble(8, booking.getGrandTotal());
            ps.setString(9, booking.getSize());
            ps.setString(10, booking.getStatus());

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
    public Booking getBookingById(int bookingId){

    Booking b = null;

    String sql =
    "SELECT b.*, d.dress_name, d.image, d.price_per_day " +
    "FROM bookings b " +
    "LEFT JOIN dresses d ON b.dress_id=d.dress_id " +
    "WHERE b.booking_id=?";

    try(
        Connection con = DBConnection.getConnection();
        PreparedStatement ps = con.prepareStatement(sql);
    ){

        ps.setInt(1, bookingId);

        ResultSet rs = ps.executeQuery();

        if(rs.next()){

            b = new Booking();

            b.setBookingId(rs.getInt("booking_id"));
            b.setCustomerId(rs.getInt("customer_id"));
            b.setDressId(rs.getInt("dress_id"));
            b.setStartDate(rs.getString("start_date"));
            b.setEndDate(rs.getString("end_date"));
            b.setRentalDays(rs.getInt("rental_days"));
            b.setGrandTotal(rs.getDouble("grand_total"));
            b.setStatus(rs.getString("status"));
            b.setDressName(rs.getString("dress_name"));
            b.setImage(rs.getString("image"));
            b.setPricePerDay(rs.getDouble("price_per_day"));

        }

    }catch(Exception e){
        e.printStackTrace();
    }

    return b;
}
    // Get All Bookings
    public List<Booking> getAllBookings() {
        List<Booking> list = new ArrayList<>();
        String sql = "SELECT * FROM bookings";
        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()
        ) {
            while (rs.next()) {
                Booking booking = new Booking();

                booking.setBookingId(rs.getInt("booking_id"));
                booking.setCustomerId(rs.getInt("customer_id"));
                booking.setDressId(rs.getInt("dress_id"));
                booking.setStartDate(rs.getString("start_date"));
                booking.setEndDate(rs.getString("end_date"));
                booking.setRentalDays(rs.getInt("rental_days"));
                booking.setRentalCost(rs.getDouble("rental_cost"));
                booking.setSecurityDeposit(rs.getDouble("security_deposit"));
                booking.setGrandTotal(rs.getDouble("grand_total"));
                booking.setSize(rs.getString("size"));
                booking.setStatus(rs.getString("status"));

                list.add(booking);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
    public Booking getLatestBookingByCustomer(int customerId) {
    Booking booking = null;
    String sql =
        "SELECT b.*, d.dress_name, d.image, d.price_per_day " +
        "FROM bookings b " +
        "LEFT JOIN dresses d ON b.dress_id = d.dress_id " +
        "WHERE b.customer_id=? " +
        "ORDER BY b.booking_id DESC LIMIT 1";
    try (
        Connection con = DBConnection.getConnection();
        PreparedStatement ps = con.prepareStatement(sql)
    ) {
        ps.setInt(1, customerId);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            booking = new Booking();

            booking.setBookingId(rs.getInt("booking_id"));
            booking.setCustomerId(rs.getInt("customer_id"));
            booking.setDressId(rs.getInt("dress_id"));
            booking.setStartDate(rs.getString("start_date"));
            booking.setEndDate(rs.getString("end_date"));
            booking.setRentalDays(rs.getInt("rental_days"));
            booking.setRentalCost(rs.getDouble("rental_cost"));
            booking.setSecurityDeposit(rs.getDouble("security_deposit"));
            booking.setGrandTotal(rs.getDouble("grand_total"));
            booking.setSize(rs.getString("size"));
            booking.setStatus(rs.getString("status"));

            booking.setDressName(rs.getString("dress_name"));
            booking.setImage(rs.getString("image"));
            booking.setPricePerDay(rs.getDouble("price_per_day"));
        }

    } catch (Exception e) {
        e.printStackTrace();
    }

    return booking;
}
public List<Booking> getBookingsByCustomer(int customerId) {
    List<Booking> list = new ArrayList<>();

    // LEFT JOIN so booking history survives a dress being deleted
    String sql = "SELECT b.*, d.dress_name, d.image, d.price_per_day, d.security_deposit " +
                 "FROM bookings b LEFT JOIN dresses d ON b.dress_id=d.dress_id WHERE b.customer_id=? ORDER BY booking_id DESC";

    try (
        Connection con = DBConnection.getConnection();
        PreparedStatement ps = con.prepareStatement(sql);
    ) {

        ps.setInt(1, customerId);

        ResultSet rs = ps.executeQuery();

        while (rs.next()) {

            Booking booking = new Booking();

            booking.setBookingId(rs.getInt("booking_id"));
            booking.setDressId(rs.getInt("dress_id"));
            booking.setStartDate(rs.getString("start_date"));
            booking.setEndDate(rs.getString("end_date"));
            booking.setRentalDays(rs.getInt("rental_days"));
            booking.setRentalCost(rs.getDouble("rental_cost"));
            booking.setSecurityDeposit(rs.getDouble("security_deposit"));
            booking.setPricePerDay(rs.getDouble("price_per_day"));
            booking.setGrandTotal(rs.getDouble("grand_total"));
            booking.setStatus(rs.getString("status"));
            booking.setDressName(rs.getString("dress_name"));
            booking.setImage(rs.getString("image"));

            list.add(booking);
        }

    } catch (Exception e) {
        e.printStackTrace();
    }

    return list;
}
public List<Booking> getAllBookingsForAdmin() {
    List<Booking> list = new ArrayList<>();
    String sql = "SELECT b.*, d.dress_name, u.full_name AS customer_name " +
                 "FROM bookings b " +
                 "LEFT JOIN dresses d ON b.dress_id=d.dress_id " +
                 "LEFT JOIN users u ON b.customer_id=u.user_id " +
                 "ORDER BY b.booking_id DESC";
    try (Connection con = DBConnection.getConnection();
         PreparedStatement ps = con.prepareStatement(sql);
         ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
            Booking b = new Booking();
            b.setBookingId(rs.getInt("booking_id"));
            b.setCustomerId(rs.getInt("customer_id"));
            b.setDressId(rs.getInt("dress_id"));
            b.setStartDate(rs.getString("start_date"));
            b.setEndDate(rs.getString("end_date"));
            b.setStatus(rs.getString("status"));
            b.setGrandTotal(rs.getDouble("grand_total"));
            b.setDressName(rs.getString("dress_name"));
            b.setCustomerName(rs.getString("customer_name"));
            list.add(b);
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
    return list;
}

public List<Booking> getPendingBookings() {

    List<Booking> list = new ArrayList<>();

    String sql =
    "SELECT b.*, d.dress_name, d.image, u.full_name AS customer_name " +
    "FROM bookings b " +
    "JOIN dresses d ON b.dress_id=d.dress_id " +
    "JOIN users u ON b.customer_id=u.user_id " +
    "WHERE b.status='Pending'";

    try(
        Connection con=DBConnection.getConnection();
        PreparedStatement ps=con.prepareStatement(sql);
    ){

        ResultSet rs=ps.executeQuery();

        while(rs.next()){

            Booking b=new Booking();

            b.setBookingId(rs.getInt("booking_id"));
            b.setDressName(rs.getString("dress_name"));
            b.setImage(rs.getString("image"));
            b.setStartDate(rs.getString("start_date"));
            b.setEndDate(rs.getString("end_date"));
            b.setStatus(rs.getString("status"));
            b.setCustomerName(rs.getString("customer_name"));

            list.add(b);
        }

    }catch(Exception e){
        e.printStackTrace();
    }

    return list;
}
    public boolean updateBookingStatus(int bookingId, String status) {

        if (!"Approved".equalsIgnoreCase(status)
                && !"Rejected".equalsIgnoreCase(status)
                && !"Confirmed".equalsIgnoreCase(status)) {
            return false;
        }

        String sql = "UPDATE bookings SET status = ? "
                   + "WHERE booking_id = ? AND status IN ('Pending','Approved')";

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setString(1, status);
            ps.setInt(2, bookingId);

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * SERVER-SIDE availability check: true when the dress already has a
     * Pending/Approved/Confirmed booking overlapping [startDate, endDate].
     * The client cannot bypass this - it is called from BookingServlet before
     * the row is ever inserted, and totals are recalculated there too.
     */
    public boolean hasOverlappingBooking(int dressId, String startDate, String endDate) {
        String sql = "SELECT COUNT(*) FROM bookings "
                   + "WHERE dress_id=? "
                   + "AND status IN ('Pending','Approved','Confirmed') "
                   + "AND start_date <= ? AND end_date >= ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, dressId);
            ps.setString(2, endDate);
            ps.setString(3, startDate);
            ResultSet rs = ps.executeQuery();
            return rs.next() && rs.getInt(1) > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return true; // fail closed: never double-book on a DB error
        }
    }

    /**
     * Overlap check used when ACCEPTING a booking: true if a different
     * APPROVED/CONFIRMED booking of the same dress overlaps the requested
     * window. Pending requests do NOT block acceptance on their own.
     */
    public boolean hasOverlappingAccepted(int dressId, String startDate,
                                          String endDate, int excludeBookingId) {
        String sql = "SELECT COUNT(*) FROM bookings "
                   + "WHERE dress_id=? AND booking_id<>? "
                   + "AND status IN ('Approved','Confirmed') "
                   + "AND start_date <= ? AND end_date >= ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, dressId);
            ps.setInt(2, excludeBookingId);
            ps.setString(3, endDate);
            ps.setString(4, startDate);
            ResultSet rs = ps.executeQuery();
            return rs.next() && rs.getInt(1) > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return true; // fail closed
        }
    }

    /**
     * Atomic, transactional status update used by the owner accept/reject
     * flow. The WHERE clause guarantees only a still-PENDING booking that
     * belongs to a dress owned by ownerId can change - which prevents both
     * repeated submissions and forged bookingId/dressId parameters.
     * Returns 1 on success, 0 when the booking was already processed,
     * -1 on overlap conflict, -2 on error.
     */
    public int updateStatusIfPendingForOwner(int bookingId, int ownerId, String newStatus,
                                             String startDate, String endDate) {
        Connection con = null;
        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false);

            // lock the booking row and confirm it is still pending and owned
            PreparedStatement lock = con.prepareStatement(
                "SELECT b.dress_id FROM bookings b " +
                "JOIN dresses d ON b.dress_id=d.dress_id " +
                "WHERE b.booking_id=? AND d.owner_id=? " +
                "AND LOWER(b.status)='pending' FOR UPDATE");
            lock.setInt(1, bookingId);
            lock.setInt(2, ownerId);
            ResultSet rs = lock.executeQuery();
            if (!rs.next()) {
                con.rollback();
                return 0; // not found, not pending, or not owned by this owner
            }
            int dressId = rs.getInt(1);

            // before accepting, make sure no APPROVED booking overlaps these dates
            if ("Approved".equalsIgnoreCase(newStatus)) {
                PreparedStatement ov = con.prepareStatement(
                    "SELECT COUNT(*) FROM bookings " +
                    "WHERE dress_id=? AND booking_id<>? " +
                    "AND status IN ('Approved','Confirmed') " +
                    "AND start_date <= ? AND end_date >= ?");
                ov.setInt(1, dressId);
                ov.setInt(2, bookingId);
                ov.setString(3, endDate);
                ov.setString(4, startDate);
                ResultSet ors = ov.executeQuery();
                if (ors.next() && ors.getInt(1) > 0) {
                    con.rollback();
                    return -1; // conflict with an already-accepted booking
                }
            }

            PreparedStatement upd = con.prepareStatement(
                "UPDATE bookings SET status=? WHERE booking_id=?");
            upd.setString(1, newStatus);
            upd.setInt(2, bookingId);
            int n = upd.executeUpdate();
            con.commit();
            return n > 0 ? 1 : 0;
        } catch (Exception e) {
            e.printStackTrace();
            try { if (con != null) con.rollback(); } catch (Exception ignore) {}
            return -2;
        } finally {
            try { if (con != null) { con.setAutoCommit(true); con.close(); } }
            catch (Exception ignore) {}
        }
    }

    /**
     * Pending bookings for dresses owned by the given owner only, with full
     * price details for the Booking Requests card (customer name, deposit,
     * totals, image). Used by the owner dashboard.
     */
    public List<Booking> getPendingBookingsByOwnerFull(int ownerId) {
        List<Booking> list = new ArrayList<>();
        String sql =
            "SELECT b.*, d.dress_name, d.image, d.price_per_day, d.security_deposit, " +
            "u.full_name AS customer_name " +
            "FROM bookings b " +
            "JOIN dresses d ON b.dress_id=d.dress_id " +
            "JOIN users u ON b.customer_id=u.user_id " +
            "WHERE LOWER(b.status)='pending' AND d.owner_id=? " +
            "ORDER BY b.booking_id DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, ownerId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Booking b = new Booking();
                b.setBookingId(rs.getInt("booking_id"));
                b.setCustomerId(rs.getInt("customer_id"));
                b.setDressId(rs.getInt("dress_id"));
                b.setStartDate(rs.getString("start_date"));
                b.setEndDate(rs.getString("end_date"));
                b.setRentalDays(rs.getInt("rental_days"));
                b.setRentalCost(rs.getDouble("rental_cost"));
                b.setSecurityDeposit(rs.getDouble("security_deposit"));
                b.setGrandTotal(rs.getDouble("grand_total"));
                b.setSize(rs.getString("size"));
                b.setStatus(rs.getString("status"));
                b.setDressName(rs.getString("dress_name"));
                b.setImage(rs.getString("image"));
                b.setPricePerDay(rs.getDouble("price_per_day"));
                b.setCustomerName(rs.getString("customer_name"));
                list.add(b);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Recently processed (Approved/Rejected) bookings for an owner, so the
     * dashboard shows the outcome of past decisions.
     */
    public List<Booking> getProcessedBookingsByOwner(int ownerId) {
        List<Booking> list = new ArrayList<>();
        String sql =
            "SELECT b.*, d.dress_name, d.image, u.full_name AS customer_name " +
            "FROM bookings b " +
            "JOIN dresses d ON b.dress_id=d.dress_id " +
            "JOIN users u ON b.customer_id=u.user_id " +
            "WHERE d.owner_id=? AND LOWER(b.status) IN ('approved','rejected','confirmed') " +
            "ORDER BY b.booking_id DESC LIMIT 10";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, ownerId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Booking b = new Booking();
                b.setBookingId(rs.getInt("booking_id"));
                b.setDressId(rs.getInt("dress_id"));
                b.setStartDate(rs.getString("start_date"));
                b.setEndDate(rs.getString("end_date"));
                b.setRentalDays(rs.getInt("rental_days"));
                b.setGrandTotal(rs.getDouble("grand_total"));
                b.setStatus(rs.getString("status"));
                b.setDressName(rs.getString("dress_name"));
                b.setImage(rs.getString("image"));
                b.setCustomerName(rs.getString("customer_name"));
                list.add(b);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * All bookings for dresses owned by the given owner (used by the owner
     * dashboard so stats show only THIS owner's dresses, never other owners').
     */
    public List<Booking> getBookingsByOwner(int ownerId) {
        List<Booking> list = new ArrayList<>();
        String sql = "SELECT b.* FROM bookings b " +
                     "JOIN dresses d ON b.dress_id=d.dress_id " +
                     "WHERE d.owner_id=? ORDER BY b.booking_id DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, ownerId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Booking b = new Booking();
                b.setBookingId(rs.getInt("booking_id"));
                b.setCustomerId(rs.getInt("customer_id"));
                b.setDressId(rs.getInt("dress_id"));
                b.setStartDate(rs.getString("start_date"));
                b.setEndDate(rs.getString("end_date"));
                b.setRentalDays(rs.getInt("rental_days"));
                b.setRentalCost(rs.getDouble("rental_cost"));
                b.setSecurityDeposit(rs.getDouble("security_deposit"));
                b.setGrandTotal(rs.getDouble("grand_total"));
                b.setSize(rs.getString("size"));
                b.setStatus(rs.getString("status"));
                list.add(b);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Pending bookings for dresses owned by the given owner only.
     * Previously every owner saw every owner's pending requests.
     */
    public List<Booking> getPendingBookingsByOwner(int ownerId) {
        List<Booking> list = new ArrayList<>();
        String sql =
            "SELECT b.*, d.dress_name, d.image, u.full_name AS customer_name " +
            "FROM bookings b " +
            "JOIN dresses d ON b.dress_id=d.dress_id " +
            "JOIN users u ON b.customer_id=u.user_id " +
            "WHERE b.status='Pending' AND d.owner_id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, ownerId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Booking b = new Booking();
                b.setBookingId(rs.getInt("booking_id"));
                b.setCustomerId(rs.getInt("customer_id"));
                b.setDressId(rs.getInt("dress_id"));
                b.setDressName(rs.getString("dress_name"));
                b.setImage(rs.getString("image"));
                b.setStartDate(rs.getString("start_date"));
                b.setEndDate(rs.getString("end_date"));
                b.setRentalDays(rs.getInt("rental_days"));
                b.setRentalCost(rs.getDouble("rental_cost"));
                b.setSecurityDeposit(rs.getDouble("security_deposit"));
                b.setGrandTotal(rs.getDouble("grand_total"));
                b.setStatus(rs.getString("status"));
                b.setCustomerName(rs.getString("customer_name"));
                list.add(b);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
