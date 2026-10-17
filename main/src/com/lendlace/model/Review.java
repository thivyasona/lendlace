package com.lendlace.model;

public class Review {

    private int reviewId;
    private int userId;
    private int dressId;
    private int rating;
    private String review;
    private String reviewDate;
    private String userName;

    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }

    public Review() {
    }

    public Review(int reviewId, int userId, int dressId,
                  int rating, String review, String reviewDate) {
        this.reviewId = reviewId;
        this.userId = userId;
        this.dressId = dressId;
        this.rating = rating;
        this.review = review;
        this.reviewDate = reviewDate;
    }

    public int getReviewId() {
        return reviewId;
    }

    public void setReviewId(int reviewId) {
        this.reviewId = reviewId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public int getDressId() {
        return dressId;
    }

    public void setDressId(int dressId) {
        this.dressId = dressId;
    }

    public int getRating() {
        return rating;
    }

    public void setRating(int rating) {
        this.rating = rating;
    }

    public String getReview() {
        return review;
    }

    public void setReview(String review) {
        this.review = review;
    }

    public String getReviewDate() {
        return reviewDate;
    }

    public void setReviewDate(String reviewDate) {
        this.reviewDate = reviewDate;
    }
}