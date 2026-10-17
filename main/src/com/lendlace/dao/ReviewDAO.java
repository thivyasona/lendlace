package com.lendlace.dao;

import com.lendlace.model.Review;
import com.lendlace.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class ReviewDAO {

    // Add Review
    public boolean addReview(Review review) {

        String sql = "INSERT INTO reviews(user_id,dress_id,rating,review) VALUES(?,?,?,?)";

        try {

            Connection con = DBConnection.getConnection();

            PreparedStatement ps = con.prepareStatement(sql);

            ps.setInt(1, review.getUserId());
            ps.setInt(2, review.getDressId());
            ps.setInt(3, review.getRating());
            ps.setString(4, review.getReview());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
    // Get Reviews by User
    public List<Review> getReviewsByUser(int userId) {

        List<Review> list = new ArrayList<>();

        String sql = "SELECT * FROM reviews WHERE user_id=? ORDER BY review_id DESC";

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql);
        ) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Review review = new Review();
                review.setReviewId(rs.getInt("review_id"));
                review.setUserId(rs.getInt("user_id"));
                review.setDressId(rs.getInt("dress_id"));
                review.setRating(rs.getInt("rating"));
                review.setReview(rs.getString("review"));
                review.setReviewDate(rs.getString("review_date"));
                list.add(review);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
    // Get Reviews by Dress
    public List<Review> getReviewsByDress(int dressId) {

        List<Review> list = new ArrayList<>();

        String sql = "SELECT * FROM reviews WHERE dress_id=?";

        try {

            Connection con = DBConnection.getConnection();

            PreparedStatement ps = con.prepareStatement(sql);

            ps.setInt(1, dressId);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                Review review = new Review();

                review.setReviewId(rs.getInt("review_id"));
                review.setUserId(rs.getInt("user_id"));
                review.setDressId(rs.getInt("dress_id"));
                review.setRating(rs.getInt("rating"));
                review.setReview(rs.getString("review"));
                review.setReviewDate(rs.getString("review_date"));

                list.add(review);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }
    // Get All Reviews
public List<Review> getAllReviews() {

    List<Review> list = new ArrayList<>();

    String sql = "SELECT r.*, u.full_name AS user_name FROM reviews r "
               + "LEFT JOIN users u ON r.user_id=u.user_id "
               + "ORDER BY r.review_id DESC";

    try {

        Connection con = DBConnection.getConnection();

        PreparedStatement ps = con.prepareStatement(sql);

        ResultSet rs = ps.executeQuery();

        while (rs.next()) {

            Review review = new Review();

            review.setReviewId(rs.getInt("review_id"));
            review.setUserId(rs.getInt("user_id"));
            review.setDressId(rs.getInt("dress_id"));
            review.setRating(rs.getInt("rating"));
            review.setReview(rs.getString("review"));
            review.setReviewDate(rs.getString("review_date"));
            review.setUserName(rs.getString("user_name"));

            list.add(review);
        }

    } catch (Exception e) {

        e.printStackTrace();
    }

    return list;
}// Delete Review
public boolean deleteReview(int reviewId) {

    String sql = "DELETE FROM reviews WHERE review_id=?";

    try {

        Connection con = DBConnection.getConnection();

        PreparedStatement ps = con.prepareStatement(sql);

        ps.setInt(1, reviewId);

        return ps.executeUpdate() > 0;

    } catch (Exception e) {

        e.printStackTrace();
    }

    return false;
}
// Get Review By ID
public Review getReviewById(int reviewId) {

    String sql = "SELECT * FROM reviews WHERE review_id=?";

    try {

        Connection con = DBConnection.getConnection();

        PreparedStatement ps = con.prepareStatement(sql);

        ps.setInt(1, reviewId);

        ResultSet rs = ps.executeQuery();

        if (rs.next()) {

            Review review = new Review();

            review.setReviewId(rs.getInt("review_id"));
            review.setUserId(rs.getInt("user_id"));
            review.setDressId(rs.getInt("dress_id"));
            review.setRating(rs.getInt("rating"));
            review.setReview(rs.getString("review"));
            review.setReviewDate(rs.getString("review_date"));

            return review;
        }

    } catch (Exception e) {

        e.printStackTrace();
    }

    return null;
}
// Update Review
public boolean updateReview(Review review) {

    String sql = "UPDATE reviews SET rating=?, review=? WHERE review_id=?";

    try {

        Connection con = DBConnection.getConnection();

        PreparedStatement ps = con.prepareStatement(sql);

        ps.setInt(1, review.getRating());
        ps.setString(2, review.getReview());
        ps.setInt(3, review.getReviewId());

        return ps.executeUpdate() > 0;

    } catch (Exception e) {

        e.printStackTrace();
    }

    return false;
}
}