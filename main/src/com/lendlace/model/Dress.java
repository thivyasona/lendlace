package com.lendlace.model;

public class Dress {

    private int dressId;
    private int ownerId;
    private String dressName;
    private String category;
    private String brand;
    private String color;
    private String size;
    private String occasion;
    private double pricePerDay;
    private double securityDeposit;
    private String description;
    private String image;
    private String video;
    private String status;
    private String availableFrom;
    private String availableTo;

    public Dress() {
    }

    public Dress(int dressId, int ownerId, String dressName, String category,
                 String brand, String color, String size, String occasion,
                 double pricePerDay, double securityDeposit,
                 String description, String image,
                 String video, String status) {

        this.dressId = dressId;
        this.ownerId = ownerId;
        this.dressName = dressName;
        this.category = category;
        this.brand = brand;
        this.color = color;
        this.size = size;
        this.occasion = occasion;
        this.pricePerDay = pricePerDay;
        this.securityDeposit = securityDeposit;
        this.description = description;
        this.image = image;
        this.video = video;
        this.status = status;
    }

    public int getDressId() {
        return dressId;
    }

    public void setDressId(int dressId) {
        this.dressId = dressId;
    }

    public int getOwnerId() {
        return ownerId;
    }

    public void setOwnerId(int ownerId) {
        this.ownerId = ownerId;
    }

    public String getDressName() {
        return dressName;
    }

    public void setDressName(String dressName) {
        this.dressName = dressName;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getBrand() {
        return brand;
    }

    public void setBrand(String brand) {
        this.brand = brand;
    }

    public String getColor() {
        return color;
    }

    public void setColor(String color) {
        this.color = color;
    }

    public String getSize() {
        return size;
    }

    public void setSize(String size) {
        this.size = size;
    }

    public String getOccasion() {
        return occasion;
    }

    public void setOccasion(String occasion) {
        this.occasion = occasion;
    }

    public double getPricePerDay() {
        return pricePerDay;
    }

    public void setPricePerDay(double pricePerDay) {
        this.pricePerDay = pricePerDay;
    }

    public double getSecurityDeposit() {
        return securityDeposit;
    }

    public void setSecurityDeposit(double securityDeposit) {
        this.securityDeposit = securityDeposit;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getImage() {
        return image;
    }

    public void setImage(String image) {
        this.image = image;
    }

    public String getVideo() {
        return video;
    }

    public void setVideo(String video) {
        this.video = video;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
    public String getAvailableFrom() {
    return availableFrom;
    }  
    public void setAvailableFrom(String availableFrom) {
    this.availableFrom = availableFrom;
    }
    public String getAvailableTo() {
    return availableTo;
    }
    public void setAvailableTo(String availableTo) {
    this.availableTo = availableTo;
}
}