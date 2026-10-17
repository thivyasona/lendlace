package com.lendlace.model;
public class Booking {
    private int bookingId;
    private int customerId;
    private int dressId;
    private String startDate;
    private String endDate;
    private int rentalDays;
    private double rentalCost;
    private double securityDeposit;
    private double grandTotal;
    private String size;
    private String status;
    private String dressName;
    private String customerName;
    private String image;
    private double pricePerDay;
    public int getBookingId() {
        return bookingId;
    }
    public void setBookingId(int bookingId) {
        this.bookingId = bookingId;
    }
    public int getCustomerId() {
        return customerId;
    }
    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }
    public int getDressId() {
        return dressId;
    }
    public void setDressId(int dressId) {
        this.dressId = dressId;
    }
    public String getStartDate() {
        return startDate;
    }
    public void setStartDate(String startDate) {
        this.startDate = startDate;
    }
    public String getEndDate() {
        return endDate;
    }
    public void setEndDate(String endDate) {
        this.endDate = endDate;
    }
    public int getRentalDays() {
        return rentalDays;
    }
    public void setRentalDays(int rentalDays) {
        this.rentalDays = rentalDays;
    }
    public double getRentalCost() {
        return rentalCost;
    }
    public void setRentalCost(double rentalCost) {
        this.rentalCost = rentalCost;
    }
    public double getSecurityDeposit() {
        return securityDeposit;
    }
    public void setSecurityDeposit(double securityDeposit) {
        this.securityDeposit = securityDeposit;
    }
    public double getGrandTotal() {
        return grandTotal;
    }
    public void setGrandTotal(double grandTotal) {
        this.grandTotal = grandTotal;
    }
    public String getSize() {
        return size;
    }
    public void setSize(String size) {
        this.size = size;
    }
    public String getStatus() {
        return status;
    }
    public void setStatus(String status) {
        this.status = status;
    }
    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }

    public String getDressName() {
    return dressName;
}

public void setDressName(String dressName) {
    this.dressName = dressName;
}

public String getImage() {
    return image;
}

public void setImage(String image) {
    this.image = image;
}

public double getPricePerDay() {
    return pricePerDay;
}

public void setPricePerDay(double pricePerDay) {
    this.pricePerDay = pricePerDay;
}
}