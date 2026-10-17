<%@ page import="com.lendlace.model.User" %>
<%@ page import="com.lendlace.dao.DressDAO" %>
<%@ page import="com.lendlace.dao.BookingDAO" %>
<%@ page import="com.lendlace.dao.WishlistDAO" %>
<%@ page import="com.lendlace.model.Dress" %>
<%@ page import="com.lendlace.model.Booking" %>
<%@ page import="com.lendlace.model.Wishlist" %>
<%@ page import="java.util.List" %>
<%
com.lendlace.model.User custUser = (com.lendlace.model.User) session.getAttribute("loggedUser");
if (custUser == null) {
    response.sendRedirect("login.jsp");
    return;
}
if (!"CUSTOMER".equalsIgnoreCase(custUser.getRole())) {
    // Admins go to admin dashboard, owners to owner dashboard
    if ("ADMIN".equalsIgnoreCase(custUser.getRole())) {
        response.sendRedirect("admin-dashboard.jsp");
    } else {
        response.sendRedirect("owner-dashboard.jsp");
    }
    return;
}
// ---- dynamic data from MySQL ----
DressDAO dressDAO = new DressDAO();
BookingDAO bookingDAO = new BookingDAO();
WishlistDAO wishlistDAO = new WishlistDAO();
List<Dress> trendingDresses = dressDAO.getAllDresses();
if (trendingDresses == null) trendingDresses = new java.util.ArrayList<>();
if (trendingDresses.size() > 6) trendingDresses = trendingDresses.subList(0, 6);
List<Booking> myBookings = bookingDAO.getBookingsByCustomer(custUser.getUserId());
List<Wishlist> myWishlist = wishlistDAO.getWishlistByUser(custUser.getUserId());
// resolve wishlist dress details
java.util.Map<Integer, Dress> dressMap = new java.util.HashMap<>();
for (Dress d : dressDAO.getAllDresses()) { dressMap.put(d.getDressId(), d); }
%>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">
    <title>Customer Dashboard | Dress Rental Management System</title>
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
            background:#FAF6F0 url('assets/images/dress7.jpg') no-repeat center center fixed;
            background-size:cover;
        }

        body::before {
            content: '';
            position: fixed;
            inset: 0;
            background: rgba(250, 246, 240, 0.93);
            z-index: -1;
        }

        .navbar{
            background:#33172C;
            box-shadow:0 5px 15px rgba(51,23,44,.2);
        }
        .navbar-brand{
            font-size:28px;
            font-weight:700;
        }
        .nav-link{
            color:white !important;
            margin-left:15px;
        }
        .nav-link:hover{
            color:#C9B8E8 !important;
        }
        /* Search */
        .search-box{
            width:350px;
        }
        .search-box input{
            border-radius:30px;
        }
        /* Hero */
        .hero{
            background:
                linear-gradient(120deg, rgba(51,23,44,.88), rgba(74,32,64,.68)),
                url("assets/images/dress8.jpg") center/cover no-repeat;
            color:#fff;
            padding:70px 0;
        }
        .hero h1{
            font-size:45px;
            font-weight:700;
        }
        .hero p{
            font-size:18px;
            margin-top:15px;
        }
        .hero img{
            max-height:350px;
        }
        .dashboard-card{
            border:none;
            border-radius:20px;
            background:#fff;
            transition:.3s;
            box-shadow:0 8px 20px rgba(74,32,64,.10);

        }
        .dashboard-card:hover{
            transform:translateY(-8px);

        }
    </style>
</head>
<body>

<!-- ================= NAVBAR ================= -->
<nav class="navbar navbar-expand-lg navbar-dark">
<div class="container">
<a class="navbar-brand" href="customer-dashboard.jsp">
    <i class="bi bi-bag-heart-fill"></i>
    Dress Rental
</a>
<button
class="navbar-toggler"
type="button"
data-bs-toggle="collapse"
data-bs-target="#menu">
<span class="navbar-toggler-icon"></span>
</button>
<div class="collapse navbar-collapse" id="menu">
<form class="d-flex mx-auto search-box">
<input
class="form-control"
type="search"
placeholder="Search Dresses...">
</form>
<ul class="navbar-nav ms-auto">
<li class="nav-item">
<a class="nav-link" href="customer-dashboard.jsp">
<i class="bi bi-house-fill"></i>
Home
</a>
</li>

<li class="nav-item">
<a class="nav-link" href="wishlist.jsp">
<i class="bi bi-heart-fill"></i>
Wishlist
</a>
</li>

<li class="nav-item">
<a class="nav-link" href="my-bookings.jsp">
<i class="bi bi-calendar-check-fill"></i>
My Bookings
</a>
</li>

<li class="nav-item">
<a class="nav-link" href="my-reviews.jsp">
<i class="bi bi-star-fill"></i>
My Reviews
</a>
</li>
<li class="nav-item dropdown">
<a
class="nav-link dropdown-toggle"
href="#"
role="button"
data-bs-toggle="dropdown">

<i class="bi bi-person-circle"></i>
My Account

</a>

<ul class="dropdown-menu dropdown-menu-end">

<li>
<a class="dropdown-item" href="profile.jsp">
Profile
</a>
</li>

<li>
<a class="dropdown-item" href="profile.jsp">
Settings
</a>
</li>
<li><hr class="dropdown-divider"></li>
<li>
<a class="dropdown-item" href="logout">
Logout
</a>
</li>
</ul>
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
<h1>
Welcome Back, <%= custUser.getFullName() %>
</h1>
<p>
Browse premium dresses, book instantly, manage your rentals,
and discover the latest fashion collections.
</p>
<a href="browse-dresses"
class="btn btn-warning btn-lg mt-3">
Browse Dresses
</a>
</div>
<div class="col-lg-6 text-center">
<img
src="assets/images/dress5.jpg"
class="img-fluid"
alt="Dashboard">
</div>
</div>
</div>
</section>

<!-- ================= DASHBOARD STATS (from MySQL) ================= -->
<div class="container mt-5">
<div class="row g-4">
<div class="col-lg-3 col-md-6">
<div class="card dashboard-card">
<div class="card-body text-center">
<h1 class="text-primary">
<%= myBookings == null ? 0 : myBookings.size() %>
</h1>
<h5>
Total Bookings
</h5>
</div>
</div>
</div>
<div class="col-lg-3 col-md-6">
<div class="card dashboard-card">
<div class="card-body text-center">
<h1 class="text-success">
<% int activeCount = 0; if (myBookings != null) for (Booking ab : myBookings) if ("Approved".equalsIgnoreCase(ab.getStatus()) || "Confirmed".equalsIgnoreCase(ab.getStatus())) activeCount++; %>
<%= activeCount %>
</h1>
<h5>
Active Rentals
</h5>
</div>
</div>
</div>
<div class="col-lg-3 col-md-6">
<div class="card dashboard-card">
<div class="card-body text-center">
<h1 class="text-danger">
<%= myWishlist == null ? 0 : myWishlist.size() %>
</h1>
<h5>
Wishlist
</h5>
</div>
</div>
</div>
<div class="col-lg-3 col-md-6">
<div class="card dashboard-card">
<div class="card-body text-center">
<h1 class="text-warning">
<%= new com.lendlace.dao.ReviewDAO().getReviewsByUser(custUser.getUserId()).size() %>
</h1>
<h5>Reviews</h5>
</div>
</div>
</div>
</div>
</div>
<!-- ================= FEATURED CATEGORIES ================= -->
<section class="container py-5">
<h2 class="text-center mb-5">Featured Categories</h2>
<div class="row g-4">
<div class="col-lg-3 col-md-6">
<div class="card dashboard-card text-center">
<div class="card-body">
<h1 class="text-primary"><i class="bi bi-gem"></i></h1>
<h5>Bridal</h5>
<p>Luxury bridal collections.</p>
<a href="browse-dresses?category=Bridal Wear" class="btn btn-primary">
    View Dresses
</a>
</div>
</div>
</div>
<div class="col-lg-3 col-md-6">
<div class="card dashboard-card text-center">
<div class="card-body">
<h1 class="text-danger"><i class="bi bi-stars"></i></h1>
<h5>Party Wear</h5>
<p>Elegant party outfits.</p>
<a href="browse-dresses?category=Party Wear" class="btn btn-primary">
    View Dresses
</a>
</div>
</div>
</div>
<div class="col-lg-3 col-md-6">
<div class="card dashboard-card text-center">
<div class="card-body">
<h1 class="text-success"><i class="bi bi-flower1"></i></h1>
<h5>Saree</h5>
<p>Traditional saree collections.</p>
<a href="browse-dresses?category=Saree" class="btn btn-primary">
    View Dresses
</a>
</div>
</div>
</div>
<div class="col-lg-3 col-md-6">
<div class="card dashboard-card text-center">
<div class="card-body">
<h1 class="text-info"><i class="bi bi-person-dress"></i></h1>
<h5>Gown</h5>
<p>Elegant gowns for every occasion.</p>
<a href="browse-dresses?category=Gown" class="btn btn-primary">
    View Dresses
</a>
</div>
</div>
</div>
</div>
</section>
<!-- ================= TRENDING DRESSES ================= -->
<!-- ================= TRENDING DRESSES (from MySQL) ================= -->
<section class="container pb-5">
<h2 class="text-center mb-5">
Trending Dresses
</h2>
<div class="row g-4">
<% if (trendingDresses.isEmpty()) { %>
<p class="text-center text-muted">No dresses available yet.</p>
<% } %>
<% for (Dress td : trendingDresses) { String tdImg = (td.getImage() == null || td.getImage().isEmpty()) ? "assets/images/image-unavailable.jpg" : td.getImage(); %>
<div class="col-lg-4">
<div class="card dashboard-card">
<img
src="<%= tdImg %>"
class="card-img-top"
alt="<%= td.getDressName() %>">
<div class="card-body">
<h5><%= td.getDressName() %></h5>
<p>&#8377;<%= String.format("%,.0f", td.getPricePerDay()) %> / Day</p>
<div class="d-flex justify-content-between">
<a href="DressServlet?action=view&dressId=<%= td.getDressId() %>" class="btn btn-primary">
    View
</a>
<button class="btn btn-outline-danger"
onclick="addWishlist(<%= td.getDressId() %>)">
    <i class="bi bi-heart"></i>
</button>
</div>
</div>
</div>
</div>
<% } %>
</div>
</section>
<!-- ================= MY BOOKINGS (from MySQL) ================= -->
<section class="container pb-5">
<h2 class="text-center mb-5">My Bookings</h2>
<div class="table-responsive">
<table class="table table-bordered table-hover align-middle">
<thead class="table-dark">
<tr>
<th>Booking ID</th>
<th>Dress</th>
<th>Rental Dates</th>
<th>Status</th>
<th>Total</th>
<th>Action</th>
</tr>
</thead>
<tbody>
<% if (myBookings == null || myBookings.isEmpty()) { %>
<tr><td colspan="6" class="text-center text-muted">No bookings yet. <a href="browse-dresses">Browse dresses</a> to make your first booking.</td></tr>
<% } %>
<% for (Booking mb : myBookings) { %>
<tr>
<td>#<%= mb.getBookingId() %></td>
<td><%= mb.getDressName() == null ? "Dress #" + mb.getDressId() : mb.getDressName() %></td>
<td><%= mb.getStartDate() %> - <%= mb.getEndDate() %></td>
<td>
<span class="badge bg-<%= "Approved".equalsIgnoreCase(mb.getStatus()) || "Confirmed".equalsIgnoreCase(mb.getStatus()) ? "success" : ("Rejected".equalsIgnoreCase(mb.getStatus()) ? "danger" : "warning text-dark") %>">
<%= mb.getStatus() == null ? "PENDING" : mb.getStatus().toUpperCase() %>
</span>
</td>
<td>&#8377;<%= String.format("%,.0f", mb.getGrandTotal()) %></td>
<td>
<a href="my-bookings.jsp"
class="btn btn-sm btn-primary">
View
</a>
</td>
</tr>
<% } %>
</tbody>
</table>
</div>
</section>
<!-- ================= MY WISHLIST (from MySQL) ================= -->
<section class="container pb-5">
<h2 class="text-center mb-5">My Wishlist</h2>
<div class="row g-4">
<% if (myWishlist == null || myWishlist.isEmpty()) { %>
<p class="text-center text-muted">Your wishlist is empty. Add dresses from <a href="browse-dresses">Browse Dresses</a>.</p>
<% } %>
<% for (Wishlist w : myWishlist) { Dress wd = dressMap.get(w.getDressId()); if (wd == null) continue; String wImg = (wd.getImage() == null || wd.getImage().isEmpty()) ? "assets/images/image-unavailable.jpg" : wd.getImage(); %>
<div class="col-lg-4">
<div class="card dashboard-card">
<img
src="<%= wImg %>"
class="card-img-top"
alt="<%= wd.getDressName() %>">
<div class="card-body">
<h5><%= wd.getDressName() %></h5>
<p>&#8377;<%= String.format("%,.0f", wd.getPricePerDay()) %> / Day</p>
<div class="d-grid gap-2">
<a href="DressServlet?action=view&dressId=<%= wd.getDressId() %>" class="btn btn-primary">
    View Details
</a>
<a href="wishlist?action=remove&dressId=<%= wd.getDressId() %>" class="btn btn-outline-danger">
    Remove
</a>
</div>
</div>
</div>
</div>
<% } %>
</div>
</section>
<!-- ================= NOTIFICATIONS (from MySQL) ================= -->
<section class="container pb-5">
<h2 class="text-center mb-5">Notifications</h2>
<div class="list-group">
<% if (myBookings == null || myBookings.isEmpty()) { %>
<div class="list-group-item">
<h5><i class="bi bi-info-circle text-secondary"></i> Nothing yet</h5>
<p>Your booking updates will appear here.</p>
</div>
<% } %>
<% for (Booking nb : myBookings) {
       if (nb.getStatus() == null) continue;
       String st = nb.getStatus();
       if ("Confirmed".equalsIgnoreCase(st) || "Approved".equalsIgnoreCase(st)) { %>
<div class="list-group-item">
<h5><i class="bi bi-check-circle-fill text-success"></i> Booking APPROVED</h5>
<p>Your booking <b>#<%= nb.getBookingId() %></b>
<%= nb.getDressName() == null ? "" : "(" + nb.getDressName() + ")" %>
has been confirmed successfully.</p>
<small class="text-muted"><%= nb.getStartDate() %> - <%= nb.getEndDate() %></small>
</div>
<% } else if ("Pending".equalsIgnoreCase(st)) { %>
<div class="list-group-item">
<h5><i class="bi bi-hourglass-split text-warning"></i> Booking PENDING</h5>
<p>Your booking <b>#<%= nb.getBookingId() %></b>
<%= nb.getDressName() == null ? "" : "(" + nb.getDressName() + ")" %>
is awaiting owner approval.</p>
<small class="text-muted"><%= nb.getStartDate() %> - <%= nb.getEndDate() %></small>
</div>
<% } else if ("Rejected".equalsIgnoreCase(st)) { %>
<div class="list-group-item">
<h5><i class="bi bi-x-circle-fill text-danger"></i> Booking REJECTED</h5>
<p>Your booking <b>#<%= nb.getBookingId() %></b>
<%= nb.getDressName() == null ? "" : "(" + nb.getDressName() + ")" %>
was rejected by the owner.</p>
<small class="text-muted"><%= nb.getStartDate() %> - <%= nb.getEndDate() %></small>
</div>
<% } %> <% } %>
</div>
</section>
<!-- ================= MY RENTAL HISTORY (from MySQL) ================= -->
<section class="container pb-5">
<h2 class="text-center mb-5">Rental History</h2>
<table class="table table-bordered table-hover">
<thead class="table-dark">
<tr>
<th>Dress</th>
<th>Start Date</th>
<th>End Date</th>
<th>Status</th>
</tr>
</thead>
<tbody>
<% if (myBookings == null || myBookings.isEmpty()) { %>
<tr><td colspan="4" class="text-center text-muted">No rental history yet.</td></tr>
<% } %>
<% for (Booking rh : myBookings) { %>
<tr>
<td><%= rh.getDressName() == null ? "Dress #" + rh.getDressId() : rh.getDressName() %></td>
<td><%= rh.getStartDate() %></td>
<td><%= rh.getEndDate() %></td>
<td>
<span class="badge bg-<%= "Confirmed".equalsIgnoreCase(rh.getStatus()) || "Approved".equalsIgnoreCase(rh.getStatus()) ? "success" : ("Rejected".equalsIgnoreCase(rh.getStatus()) ? "danger" : "warning text-dark") %>">
<%= rh.getStatus() == null ? "PENDING" : rh.getStatus().toUpperCase() %>
</span>
</td>
</tr>
<% } %>
</tbody>
</table>
</section>
<!-- ================= PROFILE ================= -->
<section class="container pb-5">
<h2 class="text-center mb-5">My Profile</h2>
<div class="row justify-content-center">
<div class="col-lg-8">
<div class="card shadow border-0">
<div class="card-body p-4">
<div class="text-center mb-4">
<img
src="<%= (custUser.getProfileImage()==null||custUser.getProfileImage().isEmpty()) ? "assets/images/default-user.png" : custUser.getProfileImage() %>"
class="rounded-circle"
width="130"
height="130">
<h3 class="mt-3"><%= custUser.getFullName() %></h3>
<p class="text-muted">Customer Account</p>
</div>
<hr>
<div class="row">
<div class="col-md-6 mb-3">
<label class="form-label">
Full Name
</label>
<input
type="text"
class="form-control"
value="<%= custUser.getFullName() %>"
readonly>
</div>
<div class="col-md-6 mb-3">
<label class="form-label">
Email
</label>
<input
type="email"
class="form-control"
value="<%= custUser.getEmail() %>"
readonly>
</div>
</div>
<div class="row">
<div class="col-md-6 mb-3">
<label class="form-label">
Mobile Number
</label>
<input
type="text"
class="form-control"
value="<%= custUser.getPhone() == null ? "-" : custUser.getPhone() %>"
readonly>
</div>
<div class="col-md-6 mb-3">
<label class="form-label">
City
</label>
<input
type="text"
class="form-control"
value="<%= custUser.getAddress() == null || custUser.getAddress().isEmpty() ? "-" : custUser.getAddress() %>"
readonly>
</div>
<div class="text-center mt-4">
<a href="profile.jsp"
class="btn btn-primary">
Edit Profile
</a>
<a href="logout"
class="btn btn-danger ms-2">
Logout
</a>
</div>
</div>
</div>
</div>
</div>
</section>

<!-- ================= OFFER BANNER ================= -->
<section class="container mb-5">
<div class="card text-center p-5 text-white"
style="background:linear-gradient(120deg,#33172C,#6B3A5B); border:none; border-radius:20px;">
<h2><i class="bi bi-percent"></i> Special Weekend Offer</h2>
<p class="mt-3">
Get up to <strong>20% OFF</strong> on rentals above &#8377;3000.
Offer valid for a limited time.
</p>
<a href="browse-dresses"
class="btn btn-warning mt-3">
Explore Dresses
</a>
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
<p>Premium dress rental platform for every occasion.</p>
</div>
<div class="col-md-4">
<h4>
Quick Links
</h4>
<ul class="list-unstyled">
<li><a href="profile.jsp" class="text-white text-decoration-none">My Profile</a></li>
<li><a href="my-bookings.jsp" class="text-white text-decoration-none">Bookings</a></li>
<li><a href="wishlist.jsp" class="text-white text-decoration-none">Wishlist</a></li>
<li><a href="contact.jsp" class="text-white text-decoration-none">Contact Us</a></li>
</ul>
</div>
<div class="col-md-4">
<h4>
Follow Us
</h4>
<i class="bi bi-facebook fs-3 me-3"></i>
<i class="bi bi-instagram fs-3 me-3"></i>
<i class="bi bi-twitter-x fs-3 me-3"></i>
<i class="bi bi-youtube fs-3"></i>
</div>
</div>
<hr>
<p class="text-center mb-0">
&copy; 2026 Lend &amp; Lace Dress Rental Management System. All Rights Reserved.
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

