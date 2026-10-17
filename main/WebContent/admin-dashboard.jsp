<%@ page import="java.util.List" %>
<%@ page import="com.lendlace.dao.BookingDAO" %>
<%@ page import="com.lendlace.dao.CustomerDAO" %>
<%@ page import="com.lendlace.dao.UserDAO" %>
<%@ page import="com.lendlace.dao.DressDAO" %>
<%@ page import="com.lendlace.model.Booking" %>
<%@ page import="com.lendlace.model.User" %>
<%@ page import="com.lendlace.model.Dress" %>
<%
User adminUser = (User) session.getAttribute("loggedUser");
if (adminUser == null || !"ADMIN".equalsIgnoreCase(adminUser.getRole())) {
    response.sendRedirect("login.jsp");
    return;
}
BookingDAO bookingDAO = new BookingDAO();
UserDAO userDAO = new UserDAO();
DressDAO dressDAO = new DressDAO();
List<Booking> adminBookings = bookingDAO.getAllBookingsForAdmin();
List<User> adminCustomers = userDAO.getUsersByRole("CUSTOMER");
List<User> adminOwners = userDAO.getUsersByRole("OWNER");
List<Dress> adminDresses = dressDAO.getAllDresses();
int totalBookings = adminBookings.size();
int pendingBookings = 0;
for (Booking b : adminBookings) {
    if ("Pending".equalsIgnoreCase(b.getStatus())) pendingBookings++;
}
String bookingUpdate = request.getParameter("bookingUpdate");

// --- Customer management data (real MySQL, via CustomerDAO) ---
CustomerDAO custDAO = new CustomerDAO();
String custQ = request.getParameter("q");
String custStatus = request.getParameter("status");
String custSort = request.getParameter("sort");
String custMsg = request.getParameter("custMsg");
String viewIdParam = request.getParameter("customerId");
java.util.List<CustomerDAO.CustomerRow> customerRows =
        custDAO.searchCustomers(custQ, custStatus, custSort);

// View Details target (only when ?action=view&customerId=NN)
User viewCustomer = (User) request.getAttribute("viewCustomer");
List<Booking> viewHistory = (List<Booking>) request.getAttribute("viewHistory");
String viewStatus = (String) request.getAttribute("viewStatus");
CustomerDAO.BookingCounts viewCounts =
        (CustomerDAO.BookingCounts) request.getAttribute("viewCounts");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Admin Dashboard | Dress Rental Management System</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link rel="stylesheet"
href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
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
/* compact, professional Manage Dresses card.
   The stretching came from the Bootstrap .card img { height:320px }
   rule in style.css applied to every card image plus grid stretching:
   fixed, compact image height + align-items-start on the grid row. */
.manage-grid{
    display:grid;
    grid-template-columns:repeat(auto-fill,minmax(240px,1fr));
    gap:1.25rem;
    align-items:start;
}
.manage-card{
    border:none;
    border-radius:14px;
    overflow:hidden;
    background:#fff;
    box-shadow:0 4px 12px rgba(74,32,64,.10);
    display:flex;
    flex-direction:column;
    height:100%;
    max-height:300px;
}
.manage-card-img{
    height:130px;
    object-fit:cover;
    width:100%;
    flex:0 0 auto;
}
.manage-card-body{
    padding:12px 14px;
    text-align:center;
    display:flex;
    flex-direction:column;
    justify-content:center;
    gap:4px;
    flex:1 1 auto;
    min-height:0;
}
.manage-card-title{
    font-family:'Playfair Display',serif;
    font-size:.98rem;
    font-weight:600;
    margin-bottom:2px;
    color:#4A2040;
    white-space:nowrap;
    overflow:hidden;
    text-overflow:ellipsis;
}
.manage-card-price{
    color:#6B3A5B;
    font-weight:600;
    margin-bottom:6px;
    font-size:.9rem;
}
@media (max-width:768px){
    .manage-card-img{height:150px;}
    .manage-grid{grid-template-columns:repeat(auto-fill,minmax(220px,1fr));}
}
.navbar{
background:#33172C;
}
.hero{
    position:relative;
    color:#fff;
    background:
        linear-gradient(120deg, rgba(51,23,44,.9), rgba(74,32,64,.7)),
        url("assets/images/dress8.jpg") center/cover no-repeat;
    padding:60px 0;
}
.dashboard-card{
border:none;
border-radius:20px;
background:#fff;
box-shadow:0 8px 20px rgba(74,32,64,.10);
transition:.3s;
}
.dashboard-card:hover{
transform:translateY(-8px);
}
.card-body{
padding:25px;
}
.table thead.table-dark{
background:#33172C !important;
}
section h2, .section-title-plum{
    font-family:'Playfair Display',serif;
    color:#4A2040;
}
</style>
</head>
<body>

<!-- ================= NAVBAR ================= -->

<nav class="navbar navbar-expand-lg navbar-dark">
<div class="container">
<a class="navbar-brand fw-bold" href="admin-dashboard.jsp">
<i class="bi bi-shield-lock-fill"></i>
Lend &amp; Lace Admin
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
    <a class="nav-link" href="admin-dashboard.jsp">Dashboard</a>
</li>

<li class="nav-item">
    <a class="nav-link" href="#customers">Customers</a>
</li>

<li class="nav-item">
    <a class="nav-link" href="owner-dashboard.jsp">Owners</a>
</li>

<li class="nav-item">
    <a class="nav-link" href="admin-accounts.jsp">Accounts</a>
</li>

<li class="nav-item">
    <a class="nav-link" href="manage-dresses.jsp">Dresses</a>
</li>

<li class="nav-item">
    <a class="nav-link" href="#bookings">Bookings</a>
</li>

<li class="nav-item">
    <a class="nav-link" href="#reports">Reports</a>
</li>

<li class="nav-item">
    <a class="nav-link" href="profile.jsp">Profile</a>
</li>

<li class="nav-item">
    <a class="nav-link text-warning" href="logout">Logout</a>
</li>
</ul>
</div>
</div>
</nav>

<!-- ================= HERO ================= -->

<section class="hero" id="dashboard">
<div class="container">
<div class="row align-items-center">
<div class="col-lg-6">
<h1><i class="bi bi-shield-lock-fill"></i> Welcome Admin</h1>
<p>Manage customers, dress owners, dresses, bookings, reports and the complete Lend &amp; Lace platform from one dashboard.</p>
</div>
</div>
</div>
</div>
</section>

<!-- ================= STATISTICS ================= -->

<section class="container py-5">
<div class="row g-4">
<div class="col-md-3">
<div class="card dashboard-card">
<div class="card-body text-center">
<h2 class="text-primary"><%= adminCustomers.size() %></h2>
<h5>Total Customers</h5>
</div>
</div>
</div>
<div class="col-md-3">
<div class="card dashboard-card">
<div class="card-body text-center">
<h2 class="text-success"><%= adminOwners.size() %></h2>
<h5>Dress Owners</h5>
</div>
</div>
</div>
<div class="col-md-3">
<div class="card dashboard-card">
<div class="card-body text-center">
<h2 class="text-warning"><%= adminDresses.size() %></h2>
<h5>Total Dresses</h5>
</div>
</div>
</div>
<div class="col-md-3">
<div class="card dashboard-card">
<div class="card-body text-center">
<h2 class="text-danger"><%= totalBookings %></h2>
<h5>Bookings</h5>
</div>
</div>
</div>
</div>
</section>
<!-- ================= MANAGE CUSTOMERS ================= -->
<section class="container pb-5" id="customers">
<h2 class="text-center mb-4">Manage Customers</h2>
<jsp:include page="/WEB-INF/fragments/manage-customers-section.jsp" />
</section>
<!-- ================= MANAGE OWNERS ================= -->
<section class="container pb-5" id="owners">
<h2 class="text-center mb-4">Manage Dress Owners</h2>
<% if (adminOwners.isEmpty()) { %>
<p class="text-center text-muted">No dress owners registered yet.</p>
<% } else { %>
<div class="table-responsive">
<table class="table table-bordered table-hover">
<thead class="table-dark">
<tr>
<th>ID</th>
<th>Owner Name</th>
<th>Email</th>
<th>Phone</th>
<th>Status</th>
</tr>
</thead>
<tbody>
<% for (User o : adminOwners) { %>
<tr>
<td><%= o.getUserId() %></td>
<td><%= o.getFullName() %></td>
<td><%= o.getEmail() %></td>
<td><%= o.getPhone() == null ? "â€”" : o.getPhone() %></td>
<td><span class="badge bg-success">Active</span></td>
</tr>
<% } %>
</tbody>
</table>
</div>
<% } %>
</section>
<!-- ================= MANAGE DRESSES ================= -->
<section class="container pb-5" id="dresses">
<h2 class="text-center mb-3">Manage Dresses</h2>
<p class="text-center text-muted mb-4"><i class="bi bi-info-circle"></i> Compact overview below. Full dress management lives on the dedicated <a href="manage-dresses.jsp">Manage Dresses</a> page.</p>
<% if (adminDresses.isEmpty()) { %>
<p class="text-center text-muted">No dresses listed yet.</p>
<% } else { %>
<div class="manage-grid">
<% for (Dress d : adminDresses) { String dStatus = d.getStatus() == null ? "Available" : d.getStatus(); String dBadge = "Available".equalsIgnoreCase(dStatus) ? "bg-success" : "bg-warning text-dark"; String dImg = (d.getImage() == null || d.getImage().isEmpty()) ? "assets/images/image-unavailable.jpg" : d.getImage(); %>
<div class="manage-card">
<img
src="<%= dImg %>"
class="manage-card-img"
alt="<%= d.getDressName() %>">
<div class="manage-card-body">
<h5 class="manage-card-title"><i class="bi bi-handbag"></i> <%= d.getDressName() %></h5>
<p class="manage-card-price">&#8377;<%= String.format("%,.0f", d.getPricePerDay()) %> / Day</p>
<span class="badge <%= dBadge %>"><%= dStatus %></span>
</div>
</div>
<% } %>
</div>
<% } %>
</section>
<!-- ================= MANAGE BOOKINGS ================= -->
<style>
.bookings-hero{
    position:relative;
    border-radius:20px;
    padding:35px 30px;
    color:#fff;
    margin-bottom:25px;
    background:
        linear-gradient(120deg, rgba(51,23,44,.88), rgba(74,32,64,.66)),
        url("assets/images/dress4.jpg") center/cover no-repeat;
    box-shadow:0 8px 20px rgba(74,32,64,.15);
}
</style>
<section class="container pb-5" id="bookings">
<div class="bookings-hero text-center">
<h2><i class="bi bi-calendar-check-fill"></i> Manage Bookings</h2>
<p class="mb-0">Review, approve or reject every rental request across the platform.</p>
</div>
<% if ("success".equals(bookingUpdate)) { %>
<div class="alert alert-success text-center">Booking updated successfully.</div>
<% } else if ("failed".equals(bookingUpdate)) { %>
<div class="alert alert-danger text-center">Failed to update booking. It may no longer be pending.</div>
<% } %>
<div class="table-responsive">
<table class="table table-bordered table-hover">
<thead class="table-dark">
<tr>
<th>Booking ID</th>
<th>Customer</th>
<th>Dress</th>
<th>Owner</th>
<th>Rental Dates</th>
<th>Status</th>
<th>Action</th>
</tr>
</thead>
<tbody>
<% if (adminBookings.isEmpty()) { %>
<tr><td colspan="7" class="text-center">No bookings found.</td></tr>
<% } else { for (Booking b : adminBookings) { String status = b.getStatus() == null ? "Pending" : b.getStatus(); String badge = "Pending".equalsIgnoreCase(status) ? "bg-warning text-dark" : ("Approved".equalsIgnoreCase(status) ? "bg-success" : ("Rejected".equalsIgnoreCase(status) ? "bg-danger" : "bg-secondary")); %>
<tr>
<td><%= b.getBookingId() %></td>
<td><%= b.getCustomerName() == null ? "Customer #" + b.getCustomerId() : b.getCustomerName() %></td>
<td><%= b.getDressName() == null ? "Dress #" + b.getDressId() : b.getDressName() %></td>
<td>â€”</td>
<td><%= b.getStartDate() %> - <%= b.getEndDate() %></td>
<td><span class="badge <%= badge %>"><%= status %></span></td>
<td>
<% if ("Pending".equalsIgnoreCase(status)) { %>
<form action="adminBooking" method="post" class="d-inline">
<input type="hidden" name="bookingId" value="<%= b.getBookingId() %>">
<input type="hidden" name="action" value="approve">
<button type="submit" class="btn btn-success btn-sm">Approve</button>
</form>
<form action="adminBooking" method="post" class="d-inline" onsubmit="return confirm('Reject this booking?');">
<input type="hidden" name="bookingId" value="<%= b.getBookingId() %>">
<input type="hidden" name="action" value="reject">
<button type="submit" class="btn btn-danger btn-sm">Reject</button>
</form>
<% } else { %><span class="text-muted">No action needed</span><% } %>
</td>
</tr>
<% } } %>
</tbody>
</table>
</div>
</section>
<!-- ================= REPORTS ================= -->
<section class="container pb-5" id="reports">
<h2 class="text-center mb-4">
Reports & Analytics
</h2>
<div class="row g-4">
<div class="col-md-3">
<div class="card dashboard-card text-center">
<div class="card-body">
<h2 class="text-primary"><%= adminDresses.size() %></h2>
<p>Total Dresses</p>
</div>
</div>
</div>
<div class="col-md-3">
<div class="card dashboard-card text-center">
<div class="card-body">
<h2 class="text-success"><%= adminBookings.size() %></h2>
<p>Completed Bookings</p>
</div>
</div>
</div>
<div class="col-md-3">
<div class="card dashboard-card text-center">
<div class="card-body">
<h2 class="text-warning">Rs. 8,75,000</h2>
<p>Total Revenue</p>
</div>
</div>
</div>
<div class="col-md-3">
<div class="card dashboard-card text-center">
<div class="card-body">
<h2 class="text-warning"><%= pendingBookings %></h2>
<p>Pending Requests</p>
</div>
</div>
</div>
</div>
</section>
<!-- ================= RECENT ACTIVITY ================= -->
<section class="container pb-5">
<h2 class="text-center mb-4">Recent Activity</h2>
<div class="list-group">
<% if (adminBookings.isEmpty()) { %>
<div class="list-group-item">No recent activity.</div>
<% } else { int actShown = 0; for (Booking ab : adminBookings) { if (actShown >= 5) break; actShown++; %>
<div class="list-group-item">
Booking #<%= ab.getBookingId() %> for "<%= ab.getDressName() == null ? "Dress #" + ab.getDressId() : ab.getDressName() %>" is <%= ab.getStatus() %>. Customer: <%= ab.getCustomerName() == null ? "Customer #" + ab.getCustomerId() : ab.getCustomerName() %>.
</div>
<% } } %>
</div>
</section>
<!-- ================= ADMIN PROFILE ================= -->
<section class="container pb-5" id="profile">
<h2 class="text-center mb-4">Admin Profile</h2>
<div class="row justify-content-center">
<div class="col-lg-8">
<div class="card dashboard-card">
<div class="card-body">
<div class="text-center">
<img
src="assets/images/profile.png"
class="rounded-circle mb-3"
width="120"
height="120">
<h3>System Administrator</h3>
<p class="text-muted">Lend &amp; Lace Dress Rental Management System</p>
</div>
<hr>
<div class="row">
<div class="col-md-6 mb-3">
<label class="form-label">Name</label>
<input
type="text"
class="form-control"
value="Administrator"
readonly>
</div>
<div class="col-md-6 mb-3">
<label class="form-label">Email</label>
<input
type="email"
class="form-control"
value="admin@gmail.com"
readonly>
</div>
</div>
<div class="row">
<div class="col-md-6 mb-3">
<label class="form-label">Role</label>
<input
type="text"
class="form-control"
value="Super Admin"
readonly>
</div>
<div class="col-md-6 mb-3">
<label class="form-label">
Status
</label>
<input
type="text"
class="form-control"
value="Active"
readonly>
</div>
</div>
<div class="text-center mt-4">
<button class="btn btn-primary">
Edit Profile
</button>
<a
href="login.jsp"
class="btn btn-danger ms-2">
Logout
</a>
</div>
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
<h4>Lend &amp; Lace</h4>
<p>Complete Dress Rental Management System.</p>
</div>
<div class="col-md-4">
<h4>Quick Links</h4>
<ul class="list-unstyled">
<li>Dashboard</li>
<li>Customers</li>
<li>Owners</li>
<li>Reports</li>
</ul>
</div>
<div class="col-md-4">
<h4>Admin Panel</h4>
<p>Manage the entire platform efficiently.</p>
</div>
</div>
<hr>
<p class="text-center mb-0">&copy; 2026 Lend &amp; Lace Dress Rental Management System. All Rights Reserved.
</p>
</div>
</footer>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>



