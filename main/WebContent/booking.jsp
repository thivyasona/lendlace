<%@ page import="com.lendlace.dao.DressDAO" %>
<%@ page import="com.lendlace.model.Dress" %>

<%
String id = request.getParameter("dressId");

if(id == null){
    response.sendRedirect("browse-dresses");
    return;
}

DressDAO dao = new DressDAO();
Dress dress = dao.getDressById(Integer.parseInt(id));

if(dress == null){
    response.sendRedirect("browse-dresses");
    return;
}
%>

<!DOCTYPE html>
<html lang="en">

<head>

<meta charset="UTF-8">

<meta name="viewport"
content="width=device-width, initial-scale=1.0">

<title>

Confirm Booking | Dress Rental Management System

</title>

<!-- Bootstrap -->

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
rel="stylesheet">

<!-- Bootstrap Icons -->

<link rel="stylesheet"
href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">

<!-- Google Font -->

<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap"
rel="stylesheet">

<style>

*{

margin:0;
padding:0;
box-sizing:border-box;
font-family:'Poppins',sans-serif;

}

body{

background:#FAF6F0;

}

.navbar{

background:#33172C;

}

.booking-card{

background:white;

border-radius:20px;

box-shadow:0 8px 20px rgba(0,0,0,.1);

padding:30px;

}

.summary-card{

background:white;

border-radius:20px;

box-shadow:0 8px 20px rgba(0,0,0,.1);

padding:30px;

position:sticky;

top:90px;

}

.price{

font-size:30px;

font-weight:bold;

color:#6B3A5B;

}

.table td{

padding:12px;

}

</style>

</head>

<body>

<!-- NAVBAR -->

<nav class="navbar navbar-expand-lg navbar-dark">

<div class="container">

<a class="navbar-brand"

href="customer-dashboard.jsp">

<i class="bi bi-bag-heart-fill"></i>

Dress Rental

</a>

</div>

</nav>

<div class="container py-5">

<div class="row">

<!-- LEFT -->

<div class="col-lg-8">

<div class="booking-card">

<h2 class="mb-4">

Confirm Your Booking

</h2>

<% if ("unavailable".equals(request.getParameter("error"))) { %>
<div class="alert alert-danger">
    <i class="bi bi-calendar-x-fill"></i>
    This dress is already booked for the selected dates. Please choose a different rental window
    (check the availability calendar on the dress details page).
</div>
<% } else if ("1".equals(request.getParameter("error"))) { %>
<div class="alert alert-danger"><i class="bi bi-x-circle-fill"></i> Could not create the booking. Please check your details and try again.</div>
<% } %>

<div class="row">

<div class="col-md-4">
<img
id="dressImage"
src="<%= dress.getImage() %>"
class="img-fluid rounded">
</div>

<div class="col-md-8">

<h3 id="dressName"><%= dress.getDressName() %></h3>

<p>

Brand :
<b><%= dress.getBrand() %></b>

</p>

<p>

Category :
<b><%= dress.getCategory() %></b>

</p>

<p>

Rental Price :

<span class="price" id="dressPrice">&#8377;<%= String.format("%,.0f", dress.getPricePerDay()) %> / Day
</span>

</p>

</div>


</div>

<hr>

<h4>

Rental Details

</h4>

<div class="row">

<div class="col-md-6">

<label>

Rental Start Date

</label>

<input

type="date"

id="startDate"

class="form-control"

onchange="calculateBooking()">

</div>

<div class="col-md-6">

<label>

Rental End Date

</label>

<input

type="date"

id="endDate"

class="form-control"

onchange="calculateBooking()">

</div>

</div>

<br>

<div class="row">

<div class="col-md-6">

<label>

Select Size

</label>

<select class="form-select" id="size" name="size">

<option>

M

</option>

<option>

L

</option>

<option>

XL

</option>

</select>

</div>

<div class="col-md-6">

<label>

Quantity

</label>

<input

type="number"

value="1"

min="1"

class="form-control">

</div>

</div>
<br>

<h4>

Customer Information

</h4>

<div class="row">

<div class="col-md-6">

<label>

Full Name

</label>

<input

type="text"

class="form-control"

placeholder="Enter Full Name"

required>

</div>

<div class="col-md-6">

<label>

Mobile Number

</label>

<input

type="tel"

class="form-control"

placeholder="Enter Mobile Number"

required>

</div>

</div>

<br>

<div class="row">

<div class="col-md-6">

<label>

Email Address

</label>

<input

type="email"

class="form-control"

placeholder="Enter Email Address"

required>

</div>

<div class="col-md-6">

<label>

Delivery Address

</label>

<textarea

class="form-control"

rows="2"

placeholder="Enter Delivery Address"></textarea>

</div>

</div>

<br>

<h4>

Special Instructions

</h4>

<textarea

class="form-control"

rows="4"

placeholder="Any special requests for this booking?"></textarea>

</div>

</div>

<!-- ================= BOOKING SUMMARY ================= -->

<div class="col-lg-4">

<div class="summary-card">

<h3 class="mb-4">

Booking Summary

</h3>
<div class="alert alert-warning text-center">
    Booking Status :
    <span id="bookingStatus" class="badge bg-warning">
        Pending Owner Approval
    </span>
</div>

<table class="table">

<tr>

<td>

Rental Price / Day

</td>
<td id="summaryPrice">
&#8377;<%= String.format("%,.0f", dress.getPricePerDay()) %> / Day
</td>

</tr>

<tr>

<td>

Rental Days

</td>

<td id="days">

0

</td>

</tr>

<tr>

<td>

Rental Amount

</td>

<td id="rent">

&#8377;0

</td>

</tr>

<tr>

<td>

Security Deposit

</td>

<td>&#8377;<%= String.format("%,.0f", dress.getSecurityDeposit()) %></td>

</tr>

<tr>

<td>

Delivery Charge

</td>

<td>

&#8377;150

</td>

</tr>

<tr>

<td>

Platform Fee

</td>

<td>

&#8377;50

</td>

</tr>

</table>

<hr>

<div class="mb-3">

<label>

Coupon Code

</label>

<div class="input-group">

<input

type="text"

class="form-control"

placeholder="Enter Coupon Code">

<button

class="btn btn-outline-primary">

Apply

</button>

</div>

</div>

<h3 class="text-success">

Grand Total :

<span id="total">

&#8377;2,200

</span>

</h3>
<form id="bookingForm" action="bookDress" method="post">

<input type="hidden" name="dressId" value="<%= dress.getDressId() %>">
<input type="hidden" id="formStartDate" name="startDate">
<input type="hidden" id="formEndDate" name="endDate">
<input type="hidden" id="formTotalDays" name="totalDays">
<input type="hidden" id="formTotalAmount" name="totalAmount">
<input type="hidden" id="formSize" name="size">

<div class="d-grid gap-3 mt-4">

<button
type="button"
class="btn btn-primary w-100"
onclick="confirmBooking()">
Confirm Booking
</button>

<button
id="paymentBtn"
type="button"
class="btn btn-success w-100"
disabled>
Waiting for Owner Approval
</button>

<button
type="button"
class="btn btn-outline-danger"
onclick="window.location.href='dress-details.jsp'">
Cancel Booking
</button>

</div>

</form>
<div class="mt-4">
<div class="form-check">
<input
class="form-check-input"
type="checkbox"
required>
<label class="form-check-label">
I agree to the Terms & Conditions and Rental Policy.
</label>
</div>
</div>
</div>
</div>
</div>
</div>
<!-- ================= PAYMENT METHOD ================= -->
<section class="container pb-5">
<div class="row">
<div class="col-lg-8">
<div class="booking-card mt-4">
<h3 class="mb-4">
Select Payment Method
</h3>
<div class="form-check mb-3">
<input
class="form-check-input"
type="radio"
name="payment"
checked>
<label class="form-check-label">
<i class="bi bi-credit-card"></i> Credit / Debit Card
</label>
</div>
<div class="form-check mb-3">
<input
class="form-check-input"
type="radio"
name="payment">
<label class="form-check-label">
<i class="bi bi-phone"></i> UPI
</label>
</div>
<div class="form-check mb-3">
<input
class="form-check-input"
type="radio"
name="payment">
<label class="form-check-label">
<i class="bi bi-bank"></i> Net Banking
</label>
</div>
<div class="form-check mb-4">
<input class="form-check-input" type="radio" name="payment">
<label class="form-check-label">
<i class="bi bi-cash-coin"></i> Cash on Delivery (If Available)
</label>

</div>

<hr>

<h4>

Rental Policy

</h4>

<ul>

<li>

Rental charges are calculated on a per-day basis.

</li>

<li>

Security deposit will be refunded after successful dress return.

</li>

<li>
Late returns may incur additional charges.
</li>
<li>
Damaged dresses may result in partial or full deposit deduction.
</li>
<li>
Bookings can be cancelled only before the rental start date.
</li>
<li>
Customers must return the dress in its original condition.
</li>
</ul>
<hr>
<div class="alert alert-success">
<i class="bi bi-shield-check"></i>
Your payment and personal information are protected using secure encryption.
</div>
</div>
</div>
</div>
</section>
<!-- ================= FOOTER ================= -->
<footer class="bg-dark text-white py-5">
<div class="container">
<div class="row">
<div class="col-md-4">
<h4>

Lend &amp; Lace

</h4>

<p>

Rent premium dresses for every special occasion at affordable prices.

</p>
</div>
<div class="col-md-4">
<h4>
Quick Links
</h4>
<ul class="list-unstyled">
<li>
<a href="about.jsp" class="text-white text-decoration-none">About Us</a>
</li>
<li>
<a href="contact.jsp" class="text-white text-decoration-none">Contact Us</a>
</li>
<li>

Privacy Policy

</li>

<li>

Terms & Conditions

</li>

</ul>

</div>

<div class="col-md-4">

<h4>

Follow Us

</h4>

<i class="bi bi-facebook fs-2 me-3"></i>

<i class="bi bi-instagram fs-2 me-3"></i>

<i class="bi bi-twitter-x fs-2 me-3"></i>

<i class="bi bi-youtube fs-2"></i>

</div>

</div>

<hr>

<p class="text-center mb-0">

Â© 2026 Dress Rental Management System. All Rights Reserved.

</p>

</div>

</footer>

<!-- ================= JAVASCRIPT ================= -->
<script>
let pricePerDay = <%= dress.getPricePerDay() %>;

document.getElementById("summaryPrice").innerHTML =
"&#8377;<%= String.format("%,.0f", dress.getPricePerDay()) %> / Day";

function calculateBooking(){

    const deposit = <%= dress.getSecurityDeposit() %>;
    const delivery = 150;
    const platform = 50;

    const start = document.getElementById("startDate").value;
    const end = document.getElementById("endDate").value;

    if(start==="" || end===""){
        return;
    }

    const startDate = new Date(start);
    const endDate = new Date(end);

    if(endDate < startDate){
        alert("End date cannot be before Start date.");
        return;
    }
    const days = Math.floor((endDate-startDate)/(1000*60*60*24))+1;
    const rent = days * pricePerDay;
    const grandTotal = rent + deposit + delivery + platform;

    document.getElementById("days").innerHTML = days;
    document.getElementById("rent").innerHTML = "&#8377;" + rent;
    document.getElementById("total").innerHTML = "&#8377;" + grandTotal;
    document.getElementById("formStartDate").value = start;
document.getElementById("formEndDate").value = end;
document.getElementById("formTotalDays").value = days;
document.getElementById("formTotalAmount").value = grandTotal;
}
function saveBooking() {
    // no-op: booking persistence is handled server-side by /bookDress (MySQL)
}
function confirmBooking() {

    const start = document.getElementById("startDate").value;
    const end = document.getElementById("endDate").value;
    const today = new Date().toISOString().split("T")[0];
    if (start < today) {
    alert("Booking cannot start before today.");
    return;
}

    const name = document.querySelector('input[type="text"]').value.trim();
    const mobile = document.querySelector('input[type="tel"]').value.trim();
    const email = document.querySelector('input[type="email"]').value.trim();
    const address = document.querySelector("textarea").value.trim();

    const agree = document.querySelector(".form-check-input").checked;
    if(start==""){
        alert("Please select Rental Start Date");
        return;
    }
    if(end==""){
        alert("Please select Rental End Date");
        return;
    }
    if(name==""){
        alert("Please enter Full Name");
        return;
    }
    if(mobile==""){
    alert("Please enter Mobile Number");
    return;
}
if(!/^[6-9]\d{9}$/.test(mobile)){
    alert("Enter a valid 10-digit Mobile Number");
    return;
}
    if(email==""){
        alert("Please enter Email Address");
        return;
    }
    if(!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)){
    alert("Enter a valid Email Address");
    return;
}
    if(address==""){
        alert("Please enter Delivery Address");
        return;
    }
    if(!agree){
        alert("Please accept Terms & Conditions");
        return;
    }
    document.getElementById("formSize").value = document.getElementById("size").value;
    saveBooking();
    document.getElementById("bookingForm").submit();
}
// Booking status is displayed from the URL param after redirect to my-bookings.jsp.
// No localStorage is used.
</script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>