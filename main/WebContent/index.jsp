<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.lendlace.dao.DressDAO" %>
<%@ page import="com.lendlace.model.Dress" %>
<%@ page import="java.util.List" %>
<%
    // Trending dresses come from MySQL â€” no hardcoded demo content
    List<Dress> trending = new DressDAO().getAllDresses();
    if (trending == null) trending = new java.util.ArrayList<>();
    if (trending.size() > 3) trending = trending.subList(0, 3);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lend &amp; Lace | Dress Rental Management System</title>
    <!-- Bootstrap -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link rel="stylesheet"
        href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <!-- Custom CSS -->
    <link rel="stylesheet" href="style.css">
</head>
<body>
<!-- ================= NAVBAR ================= -->
<nav class="navbar navbar-expand-lg navbar-dark bg-dark sticky-top">
    <div class="container">
        <a class="navbar-brand fw-bold" href="index.jsp">
            <i class="bi bi-bag-heart-fill"></i>
            Lend &amp; Lace
        </a>
        <button class="navbar-toggler"
            type="button"
            data-bs-toggle="collapse"
            data-bs-target="#menu">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="menu">
            <ul class="navbar-nav ms-auto">
                <li class="nav-item">
                    <a class="nav-link active"
                       href="index.jsp">
                        Home
                    </a>
                </li>
                <li class="nav-item">
                   <a class="nav-link" href="browse-dresses">
                     Browse Dresses
                   </a>
                </li>
                <li class="nav-item">
                  <a class="nav-link" href="#categories">
                     Categories
                  </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="about.jsp">
                     About
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="#contact">
                     Contact
                    </a>
                </li>
                <li class="nav-item">
                    <a class="btn btn-outline-light ms-2"
                       href="login.jsp">
                        Login
                    </a>
                </li>
                <li class="nav-item">
                    <a class="btn btn-warning ms-2"
                       href="register.jsp">

                        Register
                    </a>
                </li>
            </ul>
        </div>
    </div>
</nav>

<!-- ================= HERO ================= -->
<section class="hero">
<div class="container">
<div class="row align-items-center">
<div class="col-lg-6">
<h1>Find Your Perfect Dress</h1>
<p>Rent beautiful dresses for weddings,parties, festivals and every special occasion.</p>
<a href="browse-dresses"
class="btn btn-primary btn-lg">
Browse Dresses
</a>
<a href="register.jsp"
class="btn btn-outline-light btn-lg ms-2">
Become Owner
</a>
</div>
<div class="col-lg-6 text-center">
<img
src="assets/images/dress3.jpg"
class="img-fluid rounded shadow"
alt="Dress Rental">
</div>
</div>
</div>
</section>

<!-- ================= CATEGORIES ================= -->
<section class="container py-5" id="categories">
<h2 class="text-center mb-5">Categories</h2>
<div class="row g-4">
<div class="col-md-3">
<div class="card category-card">
<div class="card-body text-center">
<a href="browse-dresses?category=Bridal Wear">
    Bridal Wear
</a>
</div>
</div>
</div>
<div class="col-md-3">
<div class="card category-card">
<div class="card-body text-center">
<a href="browse-dresses?category=Party Wear">
    Party Wear
</a>
</div>
</div>
</div>
<div class="col-md-3">
<div class="card category-card">
<div class="card-body text-center">
<a href="browse-dresses?category=Saree">
    Saree
</a>
</div>
</div>
</div>
<div class="col-md-3">
<div class="card category-card">
<div class="card-body text-center">
<a href="browse-dresses?category=Gown">
    Gown
</a>
</div>
</div>
</div>
</div>
</section>

<!-- ================= TRENDING (from MySQL) ================= -->
<section class="container py-5">
<h2 class="text-center mb-5">Trending Dresses</h2>
<div class="row g-4">
<% if (trending.isEmpty()) { %>
    <p class="text-center text-muted">New dresses are coming soon. Owners can <a href="login.jsp">login</a> to add dresses.</p>
<% } %>
<% for (Dress t : trending) { String tImg = (t.getImage() == null || t.getImage().isEmpty()) ? "assets/images/image-unavailable.jpg" : t.getImage(); %>
<div class="col-lg-4">
<div class="card shadow">
<img src="<%= tImg %>"
class="card-img-top">
<div class="card-body">
<h5><%= t.getDressName() %></h5>
<p>&#8377;<%= String.format("%,.0f", t.getPricePerDay()) %> / Day</p>
<a href="DressServlet?action=view&dressId=<%= t.getDressId() %>" class="btn btn-primary">
View Details
</a>
</div>
</div>
</div>
<% } %>
</div>
</section>
<!-- ================= WHY US ================= -->
<section class="why-us py-5">
<div class="container">
<h2 class="text-center mb-2 why-title">Why Choose Us</h2>
<p class="text-center text-muted mb-5 why-sub">Premium dresses, verified owners, and a rental experience you can trust.</p>
<div class="row g-4 text-center">
<div class="col-md-3">
<div class="why-card h-100">
<div class="why-icon"><i class="bi bi-patch-check-fill"></i></div>
<h5>Verified Owners</h5>
<p class="text-muted small mb-0">Every dress owner is identity-checked before listing, so you rent with confidence.</p>
</div>
</div>
<div class="col-md-3">
<div class="why-card h-100">
<div class="why-icon"><i class="bi bi-cash-coin"></i></div>
<h5>Affordable Prices</h5>
<p class="text-muted small mb-0">Designer wear for a fraction of the retail price, with transparent per-day pricing.</p>
</div>
</div>
<div class="col-md-3">
<div class="why-card h-100">
<div class="why-icon"><i class="bi bi-shield-lock-fill"></i></div>
<h5>Secure Booking</h5>
<p class="text-muted small mb-0">Hashed passwords, protected accounts, and payments recorded safely in our database.</p>
</div>
</div>
<div class="col-md-3">
<div class="why-card h-100">
<div class="why-icon"><i class="bi bi-arrow-repeat"></i></div>
<h5>Easy Returns</h5>
<p class="text-muted small mb-0">Flexible rental windows and a simple return process with a refundable deposit.</p>
</div>
</div>
</div>
</div>
</section>
<!-- ================= CONTACT ================= -->
<section class="container py-5" id="contact">
    <h2 class="text-center mb-4">Contact Us</h2>
    <div class="row">
        <div class="col-lg-6">
            <h5>Email</h5>
            <p>support@dressrental.com</p>
            <h5>Phone</h5>
            <p>Contact information coming soon</p>
            <h5>Address</h5>
            <p>Chennai, Tamil Nadu, India</p>
        </div>
        <div class="col-lg-6">
            <form action="contact.jsp">
                <input type="text"
                       class="form-control mb-3"
                       placeholder="Your Name" required>
                <input type="email"
                       class="form-control mb-3"
                       placeholder="Your Email" required>
                <textarea class="form-control mb-3"
                          rows="4"
                          placeholder="Your Message" required></textarea>
                <button type="submit" class="btn btn-primary">
                    Send Message
                </button>
            </form>
        </div>
    </div>
</section>
<!-- ================= FOOTER ================= -->
<footer class="bg-dark text-white py-5">
<div class="container">
<div class="row">
<div class="col-md-4">
<h4>Lend &amp; Lace</h4>
<p>Find premium dresses for rent at affordable prices.</p>
</div>
<div class="col-md-4">
<h4>Quick Links</h4>
<ul class="list-unstyled">
<li><a href="about.jsp" class="text-white text-decoration-none">About</a></li>
<li><a href="contact.jsp" class="text-white text-decoration-none">Contact</a></li>
<li><a href="privacy.jsp" class="text-white text-decoration-none">Privacy</a></li>
<li><a href="terms.jsp" class="text-white text-decoration-none">Terms</a></li>
</ul>
</div>
<div class="col-md-4">
<h4>Follow Us</h4>
<i class="bi bi-facebook fs-2"></i>
<i class="bi bi-instagram fs-2 ms-3"></i>
<i class="bi bi-twitter-x fs-2 ms-3"></i>
</div>
</div>
<hr>
<p class="text-center">&copy; 2026 Lend &amp; Lace Dress Rental Management System</p>
</div>
</footer>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
