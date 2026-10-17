package com.lendlace.dao;

import com.lendlace.model.Wishlist;
import com.lendlace.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class WishlistDAO {

    // Add to Wishlist
    public boolean addToWishlist(Wishlist wishlist) {

        String sql = "INSERT INTO wishlist(user_id,dress_id) VALUES(?,?)";

        try {

            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql);

            ps.setInt(1, wishlist.getUserId());
            ps.setInt(2, wishlist.getDressId());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
    // Remove from Wishlist
    public boolean removeFromWishlist(int userId, int dressId) {
        String sql = "DELETE FROM wishlist WHERE user_id=? AND dress_id=?";
        try {
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, userId);
            ps.setInt(2, dressId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
    // Get Wishlist by User
    public List<Wishlist> getWishlistByUser(int userId) {

        List<Wishlist> list = new ArrayList<>();

        String sql = "SELECT * FROM wishlist WHERE user_id=?";

        try {

            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql);

            ps.setInt(1, userId);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                Wishlist wishlist = new Wishlist();

                wishlist.setWishlistId(rs.getInt("wishlist_id"));
                wishlist.setUserId(rs.getInt("user_id"));
                wishlist.setDressId(rs.getInt("dress_id"));
                wishlist.setAddedOn(rs.getString("added_on"));

                list.add(wishlist);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }
    // Check Wishlist
public boolean isInWishlist(int userId, int dressId) {

    String sql = "SELECT * FROM wishlist WHERE user_id=? AND dress_id=?";

    try {

        Connection con = DBConnection.getConnection();

        PreparedStatement ps = con.prepareStatement(sql);

        ps.setInt(1, userId);
        ps.setInt(2, dressId);

        ResultSet rs = ps.executeQuery();

        return rs.next();

    } catch (Exception e) {

        e.printStackTrace();
    }

    return false;
}
// Get Wishlist Count
public int getWishlistCount(int userId) {

    String sql = "SELECT COUNT(*) FROM wishlist WHERE user_id=?";

    try {

        Connection con = DBConnection.getConnection();

        PreparedStatement ps = con.prepareStatement(sql);

        ps.setInt(1, userId);

        ResultSet rs = ps.executeQuery();

        if (rs.next()) {

            return rs.getInt(1);
        }

    } catch (Exception e) {
    System.out.println("======== WISHLIST ERROR ========");
    e.printStackTrace();
    System.out.println("================================");
}

    return 0;
}
}