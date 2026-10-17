<%@ page import="java.util.List" %>
<%@ page import="com.lendlace.dao.WishlistDAO" %>
<%@ page import="com.lendlace.dao.DressDAO" %>
<%@ page import="com.lendlace.model.Wishlist" %>
<%@ page import="com.lendlace.model.Dress" %>
<%@ page import="com.lendlace.model.User" %>

<%
User user = (User) session.getAttribute("loggedUser");

if(user == null){
    response.sendRedirect("login.jsp");
    return;
}

WishlistDAO wishlistDAO = new WishlistDAO();
DressDAO dressDAO = new DressDAO();

List<Wishlist> wishlist = wishlistDAO.getWishlistByUser(user.getUserId());
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Wishlist</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
<style>
body{
    background:#f5f5f5;
    background-image:
        linear-gradient(120deg, rgba(51,23,44,.85), rgba(74,32,64,.65)),
        url("assets/images/dress5.jpg");
    background-size:cover;
    background-position:center;
    background-attachment:fixed;
}
.navbar{
    background:#6A1B9A;
}
.card{
    border:none;
    border-radius:15px;
    box-shadow:0 5px 15px rgba(0,0,0,.1);
    background:#fff;
}
.card img{
    height:300px;
    object-fit:cover;
}
.price{
    color:#6A1B9A;
    font-size:22px;
    font-weight:bold;
}
</style>
</head>

<body>
<nav class="navbar navbar-dark">
<div class="container">
<a class="navbar-brand" href="customer-dashboard.jsp">
<i class="bi bi-heart-fill"></i>
My Wishlist
</a>
</div>
</nav>
<div class="container py-5">
<h2 class="mb-4 text-white">My Wishlist</h2>

<div class="row g-4">

<%
for(Wishlist w : wishlist){

    Dress dress = dressDAO.getDressById(w.getDressId());
%>

<%
    if(dress == null) continue;
%>

<div class="col-md-4">
<div class="card">

<img src="<%= dress.getImage() == null || dress.getImage().isEmpty() ? "assets/images/image-unavailable.jpg" : dress.getImage() %>" class="card-img-top">

<div class="card-body">

<h5><%= dress.getDressName() %></h5>

<p><%= dress.getBrand() %></p>

<p class="price">
&#8377;<%= String.format("%,.0f", dress.getPricePerDay()) %> / Day
</p>

<div class="d-grid gap-2">

<a href="dress-details.jsp?dressId=<%= dress.getDressId() %>" class="btn btn-primary">
View Details
</a>

<a href="booking.jsp?dressId=<%= dress.getDressId() %>" class="btn btn-success">
Book Now
</a>

<a href="wishlist?action=remove&dressId=<%= dress.getDressId() %>" class="btn btn-danger">
Remove
</a>

</div>

</div>

</div>
</div>
<%
}
%>
<% if (wishlist.isEmpty()) { %>
<p class="text-muted text-center py-4">Your wishlist is empty. Browse dresses to add some!</p>
<% } %>
</div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>