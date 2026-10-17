<%@ page import="java.util.*"%>
<%@ page import="com.lendlace.dao.BookingDAO"%>
<%@ page import="com.lendlace.dao.DressDAO"%>
<%@ page import="com.lendlace.model.Booking"%>
<%@ page import="com.lendlace.model.User"%>

<%
User owner=(User)session.getAttribute("loggedUser");
if(owner==null || !"OWNER".equalsIgnoreCase(owner.getRole())){
response.sendRedirect("login.jsp");
return;
}
BookingDAO dao=new BookingDAO();
// SERVER-SIDE OWNERSHIP: only booking requests for THIS owner's dresses
List<Booking> bookings=dao.getPendingBookingsByOwner(owner.getUserId());
String bookingUpdate=request.getParameter("bookingUpdate");
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Owner Bookings | Lend &amp; Lace</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
<style>
body{background:#FAF6F0;font-family:Poppins,sans-serif;}
.navbar{background:#33172C;}
.card{border:none;border-radius:15px;box-shadow:0 5px 15px rgba(74,32,64,.1);}
h2{color:#4A2040;}
.table thead{background:#33172C;color:#fff;}
</style>
</head>

<body>

<nav class="navbar navbar-dark py-3">
<div class="container">
<a class="navbar-brand" href="owner-dashboard.jsp">
<i class="bi bi-arrow-left-circle"></i> Back to Dashboard
</a>
</div>
</nav>

<div class="container mt-4">

<h2 class="mb-4"><i class="bi bi-calendar-check-fill"></i> Booking Requests</h2>

<% if ("success".equals(bookingUpdate)) { %>
<div class="alert alert-success"><i class="bi bi-check-circle-fill"></i> Booking updated successfully. The customer will see the decision on their My Bookings page.</div>
<% } else if ("conflict".equals(bookingUpdate)) { %>
<div class="alert alert-warning"><i class="bi bi-exclamation-triangle"></i> Cannot accept: another booking for this dress is already approved for overlapping dates. Please reject this request or ask the customer to pick different dates.</div>
<% } else if ("failed".equals(bookingUpdate)) { %>
<div class="alert alert-danger">Failed to update booking. It may already have been processed.</div>
<% } %>

<div class="card p-4">
<table class="table table-bordered table-hover align-middle">

<thead>
<tr>
<th>Image</th>
<th>Dress</th>
<th>Customer</th>
<th>Start</th>
<th>End</th>
<th>Duration</th>
<th>Rental</th>
<th>Deposit</th>
<th>Total</th>
<th>Status</th>
<th>Action</th>
</tr>
</thead>
<tbody>
<% if (bookings.isEmpty()) { %>
<tr><td colspan="11" class="text-center text-muted">No pending booking requests.</td></tr>
<% } %>
<% for(Booking b:bookings){ %>

<tr>

<td>
<img src="<%= b.getImage() == null || b.getImage().isEmpty() ? "assets/images/image-unavailable.jpg" : b.getImage() %>" width="80" class="rounded" alt="<%= b.getDressName() %>">
</td>

<td><%= b.getDressName() %></td>

<td><%= b.getCustomerName() == null ? "Customer #" + b.getCustomerId() : b.getCustomerName() %></td>

<td><%= b.getStartDate() %></td>

<td><%= b.getEndDate() %></td>

<td><%= b.getRentalDays() %> day<%= b.getRentalDays() == 1 ? "" : "s" %></td>

<td>&#8377;<%= String.format("%,.0f", b.getRentalCost()) %></td>

<td>&#8377;<%= String.format("%,.0f", b.getSecurityDeposit()) %></td>

<td><b>&#8377;<%= String.format("%,.0f", b.getGrandTotal()) %></b></td>

<td><span class="badge bg-warning text-dark">PENDING</span></td>

<td>

<form action="ownerBooking" method="post" class="d-inline">

<input type="hidden" name="bookingId" value="<%= b.getBookingId() %>">

<button
class="btn btn-success btn-sm"
name="action"
value="approve">
Accept
</button>

</form>

<form action="ownerBooking" method="post" class="d-inline"
      onsubmit="return confirm('Reject this booking? The customer will see REJECTED.');">

<input type="hidden" name="bookingId" value="<%= b.getBookingId() %>">

<button
class="btn btn-danger btn-sm"
name="action"
value="reject">
Reject
</button>

</form>

</td>

</tr>

<%
}
%>

</tbody>
</table>
</div>

</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>