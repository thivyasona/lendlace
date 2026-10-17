﻿<%@ page import="java.util.List" %>
    <%@ page import="com.lendlace.dao.ReviewDAO" %>
        <%@ page import="com.lendlace.dao.DressDAO" %>
            <%@ page import="com.lendlace.model.Review" %>
                <%@ page import="com.lendlace.model.Dress" %>
                    <%@ page import="com.lendlace.model.User" %>
                        <% User user=(User) session.getAttribute("loggedUser"); if (user==null ||
                            !"OWNER".equalsIgnoreCase(user.getRole())) { response.sendRedirect("login.jsp"); return; }
                            ReviewDAO reviewDAO=new ReviewDAO(); DressDAO dressDAO=new DressDAO(); List<Review>
                            allReviews = reviewDAO.getAllReviews();
                            %>
                            <!DOCTYPE html>
                            <html lang="en">

                            <head>
                                <meta charset="UTF-8">
                                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                                <title>Customer Reviews</title>
                                <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
                                    rel="stylesheet">
                                <link rel="stylesheet"
                                    href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
                                <link
                                    href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap"
                                    rel="stylesheet">

                                <style>
                                    * {
                                        margin: 0;
                                        padding: 0;
                                        box-sizing: border-box;
                                        font-family: 'Poppins', sans-serif;
                                    }

                                    body {
                                        background: #f5f5f5;
                                    }

                                    .navbar {
                                        background: #6A1B9A;
                                    }

                                    .card {
                                        border: none;
                                        border-radius: 20px;
                                        box-shadow: 0 8px 20px rgba(0, 0, 0, .1);
                                        margin-bottom: 25px;
                                    }

                                    .review-img {
                                        width: 70px;
                                        height: 70px;
                                        border-radius: 12px;
                                        object-fit: cover;
                                    }
                                </style>
                            </head>

                            <body>
                                <nav class="navbar navbar-dark">
                                    <div class="container">
                                        <a href="owner-dashboard.jsp" class="navbar-brand">
                                            Customer Reviews
                                        </a>
                                    </div>
                                </nav>
                                <div class="container py-5">
                                    <h2 class="text-center mb-5">Customer Reviews &amp; Ratings</h2>
                                    <% if (allReviews.isEmpty()) { %>
                                        <p class="text-center text-muted">No reviews yet.</p>
                                        <% } else { %>
                                            <% for (Review r : allReviews) { Dress d = dressDAO.getDressById(r.getDressId()); String rImg = (d == null || d.getImage() == null || d.getImage().isEmpty()) ? "assets/images/dress1.jpg" : d.getImage(); %>
                                                <div class="card">
                                                    <div class="card-body">
                                                        <div class="d-flex">
                                                            <img src="<%= rImg %>"
                                                            class="review-img">
                                                            <div class="ms-3">
                                                                <h5>
                                                                    <%= r.getUserName()==null ? "Customer #" +
                                                                        r.getUserId() : r.getUserName() %>
                                                                </h5>
                                                                <div class="rating">
                                                                <% for (int i = 1; i <= 5; i++) { %><i class="bi <%= i <= r.getRating() ? "bi-star-fill" : "bi-star" %>" style="color:#FFC107;"></i><% } %>
                                                                </div>
                                                                <p class="mt-2">
                                                                    <%= r.getReview() %>
                                                                </p>
                                                                <small class="text-muted">
                                                                    <%= d==null ? "Dress #" + r.getDressId() :
                                                                        d.getDressName() %>
                                                                </small>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                                <% } %>
                                                    <% } %>
                                                        <div class="text-center mt-4">
                                                            <a href="owner-dashboard.jsp"
                                                                class="btn btn-primary btn-lg">
                                                                Back to Dashboard
                                                            </a>
                                                        </div>
                                </div>
                                <script
                                    src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
                            </body>

                            </html>
