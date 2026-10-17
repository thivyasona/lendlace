<%@ page import="java.util.*" %>
<%@ page import="com.lendlace.dao.BookingDAO" %>
<%@ page import="com.lendlace.model.Booking" %>
<%@ page import="com.lendlace.model.User" %>
<%
User user=(User)session.getAttribute("loggedUser");

if(user==null){
response.sendRedirect("login.jsp");
return;
}
BookingDAO dao=new BookingDAO();
ArrayList<Booking> bookings = new ArrayList<>(dao.getBookingsByCustomer(user.getUserId()));
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>My Bookings</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
<style>
body{
    background:#FAF6F0;
    font-family:Poppins,sans-serif;
    /* professional fashion backdrop, consistent with the dashboard heroes */
    background-image:
        linear-gradient(120deg, rgba(51,23,44,.82), rgba(74,32,64,.62)),
        url("assets/images/dress3.jpg");
    background-size:cover;
    background-position:center;
    background-attachment:fixed;
}
.navbar{
    background:#33172C;
}
.card{
    border:none;
    border-radius:15px;
    box-shadow:0 5px 15px rgba(74,32,64,.1);
    background:#fff;
}
.card img{
    height:320px;
    object-fit:cover;
}
.price{
    color:#6B3A5B;
    font-size:22px;
    font-weight:bold;
}
</style>
<style>
@media print {
    .btn,
    footer {
        display: none;
    }
    body {
        background: white;
    }
    .success-card {
        box-shadow: none;
        margin: 0;
    }
}
</style>
</head>

<body>
<nav class="navbar navbar-dark">
<div class="container">
<a class="navbar-brand" href="customer-dashboard.jsp">
<i class="bi bi-calendar-check-fill"></i>
My Bookings
</a>
</div>
</nav>
<div class="container py-5">
<% if ("1".equals(request.getParameter("success"))) { %>
<div class="alert alert-success text-center"><i class="bi bi-check-circle-fill"></i> Booking request submitted! The dress owner will accept or reject it soon - this page shows the decision once made.</div>
<% } %>
<h2 class="mb-4 text-white">My Bookings</h2>
<div class="row">

<%
for(Booking b : bookings){
%>

<div class="col-lg-4">

    <div class="card">

        <img src="<%= b.getImage() == null || b.getImage().isEmpty() ? "assets/images/image-unavailable.jpg" : b.getImage() %>" class="card-img-top" alt="<%= b.getDressName() %>">

        <div class="card-body">

            <h4><%= b.getDressName() %></h4>

            <p class="price">
                &#8377;<%= String.format("%,.0f", b.getPricePerDay()) %> / Day
            </p>

            <p>
                Booking ID :
                <b><%= b.getBookingId() %></b>
            </p>

            <p>
                Rental Start :
                <b><%= b.getStartDate() %></b>
            </p>

            <p>
                Rental End :
                <b><%= b.getEndDate() %></b>
            </p>

            <p>
                Status :
                <b><span class="badge <%= "Approved".equalsIgnoreCase(b.getStatus()) || "Confirmed".equalsIgnoreCase(b.getStatus()) ? "bg-success" : ("Rejected".equalsIgnoreCase(b.getStatus()) ? "bg-danger" : "bg-warning text-dark") %>"><%= b.getStatus() == null ? "PENDING" : b.getStatus().toUpperCase() %></span></b>
            </p>

            <p>
                Rental Cost :
                <b>&#8377;<%= String.format("%,.0f", b.getRentalCost()) %></b>
            </p>

            <p>
                Security Deposit :
                <b>&#8377;<%= String.format("%,.0f", b.getSecurityDeposit()) %></b>
            </p>

            <p>
                Total :
                <b>&#8377;<%= String.format("%,.0f", b.getGrandTotal()) %></b>
            </p>

            <div class="d-grid gap-2">

                <%
                // Receipt is only available once the owner has approved the booking.
                String bStatus = b.getStatus() == null ? "Pending" : b.getStatus();
                boolean receiptAllowed = "Approved".equalsIgnoreCase(bStatus) || "Confirmed".equalsIgnoreCase(bStatus);
                if (receiptAllowed) { %>
                <button class="btn btn-primary w-100" onclick="window.print()">
                    <i class="bi bi-file-earmark-pdf-fill"></i>
                    Download Receipt
                </button>
                <% } else { %>
                <div class="alert alert-warning mb-0 text-center small">
                    <i class="bi bi-lock-fill"></i>
                    Receipt unavailable - your booking is <b><%= bStatus %></b>.
                    The receipt can be downloaded after the owner approves it.
                </div>
                <% } %>

                <a href="browse-dresses" class="btn btn-outline-primary">
                    Continue Shopping
                </a>

                <a href="customer-dashboard.jsp" class="btn btn-outline-dark">
                    Back to Dashboard
                </a>

            </div>

        </div>

    </div>

</div>

<%
}
%>

</div>
</div>
</div>
</div>
</div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>