package com.lendlace.model;

public class Wishlist {

    private int wishlistId;
    private int userId;
    private int dressId;
    private String addedOn;

    public Wishlist() {
    }

    public Wishlist(int wishlistId, int userId, int dressId, String addedOn) {
        this.wishlistId = wishlistId;
        this.userId = userId;
        this.dressId = dressId;
        this.addedOn = addedOn;
    }

    public int getWishlistId() {
        return wishlistId;
    }

    public void setWishlistId(int wishlistId) {
        this.wishlistId = wishlistId;
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

    public String getAddedOn() {
        return addedOn;
    }

    public void setAddedOn(String addedOn) {
        this.addedOn = addedOn;
    }
}