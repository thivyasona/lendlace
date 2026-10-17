<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="java.util.List"%>
<%@ page import="com.lendlace.model.Dress"%>
<%@ page import="com.lendlace.model.User"%>
<%
User browseUser = (User) session.getAttribute("loggedUser");
boolean loggedCustomer = browseUser != null && "CUSTOMER".equalsIgnoreCase(browseUser.getRole());
boolean loggedOwner = browseUser != null && "OWNER".equalsIgnoreCase(browseUser.getRole());
boolean loggedAdmin = browseUser != null && "ADMIN".equalsIgnoreCase(browseUser.getRole());
List<Dress> dresses = (List<Dress>) request.getAttribute("dressList");

if (dresses == null) {
    response.sendRedirect("browse-dresses");
    return;
}
String qCategory = request.getParameter("category");
String qSize = request.getParameter("size");
String qColor = request.getParameter("color");
String qBrand = request.getParameter("brand");
String qOccasion = request.getParameter("occasion");
String qStatus = request.getParameter("status");
String qSearch = request.getParameter("search");
String qMaxPrice = request.getParameter("maxPrice");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport"
content="width=device-width, initial-scale=1.0">
<title>Browse Dresses | Dress Rental Management System</title>
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
background-image:
    linear-gradient(120deg, rgba(51,23,44,.85), rgba(74,32,64,.65)),
    url("assets/images/dress6.jpg");
background-size:cover;
background-position:center;
background-attachment:fixed;
}
/* keep the filter sidebar readable over the photo backdrop */
.filter-card{
background:#fff;
}
/* ================= NAVBAR ================= */
.navbar{
background:#33172C;
box-shadow:0 5px 15px rgba(51,23,44,.2);
}
.navbar-brand{
font-size:28px;
font-weight:700;
}
.nav-link{
color:white!important;
margin-left:15px;
}
.nav-link:hover{
color:#C9B8E8!important;
}
/* Search */
.search-box{
width:350px;
}
.search-box input{
border-radius:30px;
}
/* Sidebar */
.filter-card{
border:none;
border-radius:20px;
box-shadow:0 5px 15px rgba(0,0,0,.10);
padding:20px;
position:sticky;
top:90px;
}
/* Dress Card */
.dress-card{
background:#fff;
border:none;
border-radius:20px;
overflow:hidden;
transition:.3s;
box-shadow:0 5px 15px rgba(74,32,64,.10);
}
.dress-card:hover{
transform:translateY(-8px);
}
.dress-card img{
height:320px;
width:100%;
object-fit:cover;
display:block;
}
/* Equal card heights in the grid: cards fill their column and the
   action buttons align at the bottom of every card. */
.dress-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(280px,1fr));gap:1.5rem;align-items:stretch;}
.dress-grid .dress-card{height:100%;}
.dress-grid .dress-card .card-body{display:flex;flex-direction:column;}
.dress-grid .dress-card .d-grid{margin-top:auto;}
@media (max-width:576px){
.dress-grid{grid-template-columns:1fr;}
}
.price{
font-size:22px;
font-weight:700;
color:#6B3A5B;
}
.badge-available{
background:#198754;
}
.badge-booked{
background:#dc3545;
}
</style>
</head>
<body>
<!-- NAVBAR -->
<nav class="navbar navbar-expand-lg navbar-dark">
<div class="container">
<a class="navbar-brand" href="index.jsp">
<i class="bi bi-bag-heart-fill"></i>
Dress Rental
</a>
<button
class="navbar-toggler"
data-bs-toggle="collapse"
data-bs-target="#menu">
<span class="navbar-toggler-icon"></span>
</button>
<div class="collapse navbar-collapse"
id="menu">
<form class="d-flex mx-auto search-box"
      action="browse-dresses"
      method="get">

    <input
        class="form-control"
        type="search"
        name="search"
        value="<%= qSearch == null ? "" : qSearch %>"
        placeholder="Search Dresses...">

    <button
        class="btn btn-light ms-2"
        type="submit">
        <i class="bi bi-search"></i>
    </button>

</form>
<ul class="navbar-nav ms-auto">
<% if (loggedCustomer) { %>
<li class="nav-item">
<a class="nav-link" href="wishlist.jsp">
Wishlist
</a>
</li>
<li class="nav-item">
<a class="nav-link" href="my-bookings.jsp">
Bookings
</a>
</li>
<li class="nav-item">
<a class="nav-link" href="profile.jsp">
My Account (<%= browseUser.getFullName() %>)
</a>
</li>
<li class="nav-item">
<a class="nav-link text-warning" href="logout">
Logout
</a>
</li>
<% } else if (loggedOwner) { %>
<li class="nav-item">
<a class="nav-link" href="owner-dashboard.jsp">
Owner Dashboard
</a>
</li>
<li class="nav-item">
<a class="nav-link text-warning" href="logout">
Logout
</a>
</li>
<% } else if (loggedAdmin) { %>
<li class="nav-item">
<a class="nav-link" href="admin-dashboard.jsp">
Admin Dashboard
</a>
</li>
<li class="nav-item">
<a class="nav-link text-warning" href="logout">
Logout
</a>
</li>
<% } else { %>
<li class="nav-item">
<a class="nav-link" href="login.jsp">
Login
</a>
</li>
<li class="nav-item">
<a class="nav-link" href="register.jsp">
Register
</a>
</li>
<% } %>
</ul>

</div>

</div>

</nav>

<div class="container-fluid mt-4">

<div class="row">

<div class="col-lg-3">

<div class="filter-card">
<form action="browse-dresses" method="get">

<h4>

Filters

</h4>

<hr>

<label>

Category

</label>
<select class="form-select mb-3" name="category" onchange="this.form.submit()">

    <option value="All Categories" <%= "All Categories".equals(qCategory) || qCategory == null ? "selected" : "" %>>All Categories</option>

    <option value="Bridal Wear" <%= "Bridal Wear".equals(qCategory) ? "selected" : "" %>>Bridal Wear</option>

    <option value="Reception Wear" <%= "Reception Wear".equals(qCategory) ? "selected" : "" %>>Reception Wear</option>

    <option value="Party Wear" <%= "Party Wear".equals(qCategory) ? "selected" : "" %>>Party Wear</option>

    <option value="Saree" <%= "Saree".equals(qCategory) ? "selected" : "" %>>Saree</option>

    <option value="Lehenga" <%= "Lehenga".equals(qCategory) ? "selected" : "" %>>Lehenga</option>

    <option value="Gown" <%= "Gown".equals(qCategory) ? "selected" : "" %>>Gown</option>

</select>
<label>

Size

</label>

<select class="form-select mb-3" name="size">

<option value="All Sizes" <%= qSize == null || "All Sizes".equals(qSize) ? "selected" : "" %>>All Sizes</option>

<option value="XS" <%= "XS".equals(qSize) ? "selected" : "" %>>XS</option>

<option value="S" <%= "S".equals(qSize) ? "selected" : "" %>>S</option>

<option value="M" <%= "M".equals(qSize) ? "selected" : "" %>>M</option>

<option value="L" <%= "L".equals(qSize) ? "selected" : "" %>>L</option>

<option value="XL" <%= "XL".equals(qSize) ? "selected" : "" %>>XL</option>

</select>
<label>

Color

</label>

<select class="form-select mb-3" name="color">

<option value="All Colors" <%= qColor == null || "All Colors".equals(qColor) ? "selected" : "" %>>All Colors</option>

<option value="Red" <%= "Red".equals(qColor) ? "selected" : "" %>>Red</option>
<option value="Blue" <%= "Blue".equals(qColor) ? "selected" : "" %>>Blue</option>
<option value="Black" <%= "Black".equals(qColor) ? "selected" : "" %>>Black</option>
<option value="White" <%= "White".equals(qColor) ? "selected" : "" %>>White</option>
<option value="Pink" <%= "Pink".equals(qColor) ? "selected" : "" %>>Pink</option>
<option value="Green" <%= "Green".equals(qColor) ? "selected" : "" %>>Green</option>
<option value="Yellow" <%= "Yellow".equals(qColor) ? "selected" : "" %>>Yellow</option>
</select>
<label>
Brand
</label>
<select class="form-select mb-3" name="brand">
<option value="All Brands" <%= qBrand == null || "All Brands".equals(qBrand) ? "selected" : "" %>>All Brands</option>
<option value="Manyavar" <%= "Manyavar".equals(qBrand) ? "selected" : "" %>>Manyavar</option>
<option value="Biba" <%= "Biba".equals(qBrand) ? "selected" : "" %>>Biba</option>
<option value="FabIndia" <%= "FabIndia".equals(qBrand) ? "selected" : "" %>>FabIndia</option>
<option value="W for Women" <%= "W for Women".equals(qBrand) ? "selected" : "" %>>W for Women</option>
<option value="Global Desi" <%= "Global Desi".equals(qBrand) ? "selected" : "" %>>Global Desi</option>
</select>
<label>
Occasion
</label>
<select class="form-select mb-3" name="occasion">
<option value="All Occasions" <%= qOccasion == null || "All Occasions".equals(qOccasion) ? "selected" : "" %>>All Occasions</option>
<option value="Wedding" <%= "Wedding".equals(qOccasion) ? "selected" : "" %>>Wedding</option>
<option value="Reception" <%= "Reception".equals(qOccasion) ? "selected" : "" %>>Reception</option>
<option value="Festival" <%= "Festival".equals(qOccasion) ? "selected" : "" %>>Festival</option>
<option value="Party" <%= "Party".equals(qOccasion) ? "selected" : "" %>>Party</option>
<option value="Engagement" <%= "Engagement".equals(qOccasion) ? "selected" : "" %>>Engagement</option>
<option value="Casual" <%= "Casual".equals(qOccasion) ? "selected" : "" %>>Casual</option>
</select>
<label>
Price Range
</label>
<input
type="range"
class="form-range"
name="maxPrice"
id="maxPrice"
min="100"
max="5000"
value="<%= qMaxPrice == null ? "1500" : qMaxPrice %>"
oninput="document.getElementById('priceLabel').innerText = 'â‚¹100 - â‚¹' + this.value">
<p id="priceLabel">â‚¹100 - â‚¹<%= qMaxPrice == null ? "5000" : qMaxPrice %></p>
<label>
Minimum Rating
</label>
<select class="form-select mb-3" name="rating">
<option>All Ratings</option>
<option>5</option>
<option>4+</option>
<option>3+</option>
<option>2+</option>
</select>
<label>
Availability
</label>
<select class="form-select mb-4" name="status">
<option value="All" <%= qStatus == null || "All".equals(qStatus) ? "selected" : "" %>>All</option>
<option value="Available" <%= "Available".equals(qStatus) ? "selected" : "" %>>Available</option>
<option value="Not Available" <%= "Not Available".equals(qStatus) ? "selected" : "" %>>Booked</option>
</select>
<button type="submit" class="btn btn-primary w-100">
    Apply Filters
</button>
</form>
</div>
</div>
<!-- ================= DRESS LIST ================= -->

<div class="col-lg-9">
<div class="d-flex justify-content-between align-items-center mb-4">
<h4 class="text-white">
Showing <%= dresses.size() %> Dresses
</h4>
<select class="form-select w-auto">
<option>Sort By</option>
<option>
Latest Uploads
</option>
<option>
Price Low to High
</option>
<option>
Price High to Low
</option>
<option>
Highest Rated
</option>
<option>
Most Popular
</option>
</select>
</div>
<div class="dress-grid">
<!-- Dress Card 1 -->
<% if (dresses.isEmpty()) { %>
<div class="col-12 text-center py-5">
<h5 class="text-muted">No dresses match your filters.</h5>
<a href="browse-dresses" class="btn btn-outline-primary mt-2">Clear Filters</a>
</div>
<% } %>
<% for (Dress dress : dresses) { String dImg = (dress.getImage() == null || dress.getImage().isEmpty()) ? "assets/images/image-unavailable.jpg" : dress.getImage(); %>
<div>
    <div class="card dress-card">
        <img src="<%= dImg %>"
             class="card-img-top"
             alt="<%= dress.getDressName() %>">
        <div class="card-body">
            <div class="d-flex justify-content-between">
                <span class="badge badge-available">
                    <%= dress.getStatus() %>
                </span>
                <button class="btn btn-sm btn-outline-danger" onclick="addWishlist(<%= dress.getDressId() %>)">
                    <i class="bi bi-heart"></i>
                </button>
            </div>

            <h5 class="mt-3">
                <%= dress.getDressName() %>
            </h5>
            <p class="text-muted mb-1">
                Brand : <%= dress.getBrand() %>
            </p>

            <p class="text-muted mb-1">
                Category : <%= dress.getCategory() %>
            </p>
            <p class="text-muted mb-1">
                Size : <%= dress.getSize() %>
            </p>
            <p class="text-muted mb-1">
                Color : <%= dress.getColor() %>
            </p>
            <p class="text-muted mb-1">
                Occasion : <%= dress.getOccasion() %>
            </p>
            <div class="price">
                &#8377;<%= String.format("%,.0f", dress.getPricePerDay()) %> / Day
            </div>
            <p>
                Security Deposit : &#8377;<%= String.format("%,.0f", dress.getSecurityDeposit()) %>
            </p>
            <div class="d-grid gap-2">
                <% if (loggedCustomer) { %>
                <a href="DressServlet?action=view&dressId=<%= dress.getDressId() %>"
    class="btn btn-primary">
    View Details
</a>
<a href="booking.jsp?dressId=<%= dress.getDressId() %>"
   class="btn btn-success">
    Book Now
</a>
                <% } else { %>
                <a href="DressServlet?action=view&dressId=<%= dress.getDressId() %>"
    class="btn btn-primary">
    View Details
</a>
<a href="login.jsp" class="btn btn-success">
    Login to Book
</a>
                <% } %>
            </div>
        </div>
    </div>
</div>
<% } %>

</div>
</div>
<!-- ================= FOOTER ================= -->
<footer class="bg-dark text-white mt-5 py-5">
<div class="container">
<div class="row">
<div class="col-md-4">
<h4>
Dress Rental
</h4>
<p>
Find premium dresses for weddings, parties, festivals and every special occasion.
</p>
</div>
<div class="col-md-4">
<h4>
Quick Links
</h4>
<ul class="list-unstyled">
<li><a href="about.jsp" class="text-white text-decoration-none">About Us</a></li>
<li><a href="contact.jsp" class="text-white text-decoration-none">Contact Us</a></li>
<li>FAQ</li>
<li>Privacy Policy</li>
<li>Terms & Conditions</li>
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
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
function addWishlist(id){

    const form = document.createElement("form");

    form.method = "POST";
    form.action = "wishlist";

    const input = document.createElement("input");

    input.type = "hidden";
    input.name = "dressId";
    input.value = id;

    form.appendChild(input);

    document.body.appendChild(form);

    form.submit();
}
</script>
</body>
</html>
