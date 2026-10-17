<%@ page import="com.lendlace.dao.BookingDAO" %>
<%@ page import="com.lendlace.model.Booking" %>
<%@ page import="com.lendlace.model.User" %>
<%
// This page may be opened directly (no servlet forward), so resolve the
// booking here: ?bookingId=N (own booking only) or the latest booking of the
// logged-in customer. Redirect to My Bookings when nothing can be shown.
User bsUser = (User) session.getAttribute("loggedUser");
Booking booking = (Booking) request.getAttribute("booking");
if (booking == null && bsUser != null) {
    BookingDAO bsDao = new BookingDAO();
    String bsId = request.getParameter("bookingId");
    if (bsId != null) {
        try {
            Booking bsFound = bsDao.getBookingById(Integer.parseInt(bsId));
            if (bsFound != null && bsFound.getCustomerId() == bsUser.getUserId()) {
                booking = bsFound;
            }
        } catch (NumberFormatException ignored) { }
    }
    if (booking == null) {
        booking = bsDao.getLatestBookingByCustomer(bsUser.getUserId());
    }
}
if (booking == null) {
    response.sendRedirect("my-bookings.jsp");
    return;
}
%>
<!DOCTYPE html>
<html lang="en">

<head>
<meta charset="UTF-8">
<meta name="viewport"
content="width=device-width, initial-scale=1.0">
<title>Booking Successful</title>
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
background:#f5f5f5;
}
.success-card{
max-width:900px;
margin:60px auto;
background:white;
padding:40px;
border-radius:20px;
box-shadow:0 10px 25px rgba(0,0,0,.1);
}
.success-icon{
font-size:90px;
color:#28a745;
animation:pop .8s ease;
}
@keyframes pop{
0%{
transform:scale(0);
}
100%{
transform:scale(1);
}
}
.booking-id{
font-size:24px;
font-weight:bold;
color:#6A1B9A;
}
table td{
padding:12px;
}
</style>
</head>

<body>
<div class="container">
<div class="success-card text-center">
<i class="bi bi-check-circle-fill success-icon"></i>
<h1 class="mt-3">Booking Confirmed!</h1>
<p class="text-muted">Thank you for choosing Dress Rental Management System.Your booking has been placed successfully.</p>
<div class="booking-id my-4">
Booking ID :
#DRM<%= booking.getBookingId() %>
</div>
<hr>
<h3>Booking Details</h3>
<table class="table table-bordered mt-4">
<tr>
<td>Dress Name</td>
<td><%= booking.getDressName() %></td>
</tr>
<tr>
<td>
Rental Start
</td>
<td>
<%= booking.getStartDate() %>
</td>
</tr>
<tr>
<td>
Rental End
</td>
<td>
<%= booking.getEndDate() %>
</td>
</tr>
<tr>
<td>
Rental Days
</td>
<td>
<%= booking.getRentalDays() %> Days
</td>
</tr>
<tr>
<td>
Status
</td>
<td>
<span class="badge bg-success">
<%= booking.getStatus() %>
</span>
</td>
</tr>
<tr>
<td>
Payment Status
</td>
<td>
<span class="badge bg-primary">
Paid
</span>
</td>
</tr>
</table>
<hr>
<div class="row mt-4">
<div class="col-lg-6">
<h3>Payment Summary</h3>
<table class="table table-striped">
<tr>
<td>Rental Amount</td>
<td>&#8377;<%= String.format("%,.0f", booking.getRentalCost()) %></td>
</tr>
<tr>
<td>
Security Deposit
</td>
<td>
&#8377;<%= String.format("%,.0f", booking.getSecurityDeposit()) %>
</td>
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
<tr class="table-success">
<td>
<b>Total Paid</b>
</td>
<td>
<b>&#8377;<%= String.format("%,.0f", booking.getGrandTotal()) %></b>
</td>
</tr>
</table>
</div>
<div class="col-lg-6 text-center">
<h3>Booking QR Code</h3>
<img
src="<%= booking.getImage() == null || booking.getImage().isEmpty() ? "assets/images/image-unavailable.jpg" : booking.getImage() %>"
class="img-fluid rounded" alt="Dress image">
<p class="mt-3 text-muted">Show this image while collecting or returning the dress.</p>
</div>
</div>
<hr>
<div class="alert alert-info">
<i class="bi bi-envelope-check-fill"></i>
A booking-request notification is sent to your registered email address, and the dress owner is notified of your request. When the owner approves or rejects the booking, you will receive a follow-up email with the decision.
</div>
<div class="row mt-4">
<%
// A freshly submitted booking is always PENDING: the owner has not made a
// decision yet, so the receipt must not be printable/downloadable here.
String bsStatus = booking.getStatus() == null ? "Pending" : booking.getStatus();
boolean bsReceiptAllowed = "Approved".equalsIgnoreCase(bsStatus) || "Confirmed".equalsIgnoreCase(bsStatus);
%>
<div class="col-md-6 mb-3">
<% if (bsReceiptAllowed) { %>
<button class="btn btn-primary w-100" onclick="window.print()">
    <i class="bi bi-file-earmark-pdf-fill"></i>
    Download Receipt
</button>
<% } else { %>
<div class="alert alert-warning mb-0 small">
<i class="bi bi-lock-fill"></i>
Receipt unavailable - your booking is <b><%= bsStatus %></b>.
The receipt can be downloaded after the owner approves it (see My Bookings).
</div>
<% } %>
</div>
<div class="col-md-6 mb-3">
<a href="my-bookings.jsp" class="btn btn-success w-100">
<i class="bi bi-calendar-check-fill"></i>
View My Bookings
</a>
</div>
</div>
<div class="row">
<div class="col-md-6 mb-3">
<a
href="customer-dashboard.jsp"
class="btn btn-outline-dark w-100">
<i class="bi bi-house-fill"></i>
Back to Dashboard
</a>
</div>
<div class="col-md-6 mb-3">
<a
href="${pageContext.request.contextPath}/browse-dresses.jsp"

class="btn btn-outline-primary w-100">
<i class="bi bi-bag-heart-fill"></i>
Continue Shopping
</a>
</div>
</div>
</div>
</div>
<footer class="bg-dark text-white py-4 mt-5">
<div class="container text-center">
<p>© 2026 Dress Rental Management System. All Rights Reserved.</p>
<p>Thank you for choosing our platform.</p>
</div>
</footer>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>