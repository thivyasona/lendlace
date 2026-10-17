<%@ page import="java.util.List" %>
    <%@ page import="com.lendlace.dao.ReviewDAO" %>
        <%@ page import="com.lendlace.dao.DressDAO" %>
            <%@ page import="com.lendlace.model.Review" %>
                <%@ page import="com.lendlace.model.Dress" %>
                    <%@ page import="com.lendlace.model.User" %>
                        <% User user=(User) session.getAttribute("loggedUser"); if (user==null) {
                            response.sendRedirect("login.jsp"); return; } ReviewDAO reviewDAO=new ReviewDAO(); DressDAO
                            dressDAO=new DressDAO(); List<Review> myReviews =
                            reviewDAO.getReviewsByUser(user.getUserId());
                            %>
                            <!DOCTYPE html>
                            <html lang="en">

                            <head>
                                <meta charset="UTF-8">
                                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                                <title>My Reviews</title>
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

                                    textarea {
                                        resize: none;
                                    }
                                </style>
                            </head>

                            <body>
                                <nav class="navbar navbar-dark">
                                    <div class="container">
                                        <a href="customer-dashboard.jsp" class="navbar-brand">
                                            <i class="bi bi-star-fill"></i>
                                            My Reviews
                                        </a>
                                    </div>
                                </nav>
                                <div class="container py-5">
                                    <% if ("1".equals(request.getParameter("deleted"))) { %>
                                        <div class="alert alert-success">Review deleted.</div>
                                        <% } else if ("1".equals(request.getParameter("updated"))) { %>
                                            <div class="alert alert-success">Review updated.</div>
                                            <% } %>
                                                <div class="card">
                                                    <div class="card-body">
                                                        <h3 class="mb-4">Add Review</h3>
                                                        <form action="review" method="post">
                                                            <% List<Dress> dresses = dressDAO.getAllDresses(); %>
                                                                <label class="form-label">Dress</label>
                                                                <select name="dressId" class="form-select mb-3"
                                                                    required>
                                                                    <% for (Dress d : dresses) { %>
                                                                        <option value="<%= d.getDressId() %>">
                                                                            <%= d.getDressName() %>
                                                                        </option>
                                                                        <% } %>
                                                                </select>
                                                                <label class="form-label">Rating</label>
                                                                <select name="rating" class="form-select mb-3" required>
                                                                    <option value="5">
                                                                        &#11088;&#11088;&#11088;&#11088;&#11088;
                                                                    </option>
                                                                    <option value="4">&#11088;&#11088;&#11088;&#11088;
                                                                    </option>
                                                                    <option value="3">&#11088;&#11088;&#11088;</option>
                                                                    <option value="2">&#11088;&#11088;</option>
                                                                    <option value="1">&#11088;</option>
                                                                </select>
                                                                <textarea name="review" class="form-control mb-3"
                                                                    rows="4" placeholder="Write your review..."
                                                                    required></textarea>
                                                                <button type="submit" class="btn btn-success">
                                                                    Submit Review
                                                                </button>
                                                        </form>
                                                    </div>
                                                </div>
                                                <h3 class="mb-4">My Reviews</h3>
                                                <% if (myReviews.isEmpty()) { %>
                                                    <p class="text-muted">No reviews yet.</p>
                                                    <% } else { %>
                                                        <% for (Review r : myReviews) { Dress
                                                            d=dressDAO.getDressById(r.getDressId()); %>
                                                            <div class="card">
                                                                <div class="card-body">
                                                                    <h4>
                                                                        <% for (int i=0; i < 5; i++) { %>
                                                                            <%= i < r.getRating() ? "&#11088;"
                                                                                : "&#9734;" %>
                                                                                <% } %>
                                                                    </h4>
                                                                    <p><b>Dress:</b>
                                                                        <%= d==null ? "Dress #" + r.getDressId() :
                                                                            d.getDressName() %>
                                                                    </p>
                                                                    <p>
                                                                        <%= r.getReview() %>
                                                                    </p>
                                                                    <form action="deleteReview" method="post"
                                                                        onsubmit="return confirm('Delete Review?');">
                                                                        <input type="hidden" name="reviewId"
                                                                            value="<%= r.getReviewId() %>">
                                                                        <button
                                                                            class="btn btn-danger btn-sm">Delete</button>
                                                                    </form>
                                                                </div>
                                                            </div>
                                                            <% } %>
                                                                <% } %>
                                </div>
                                <script
                                    src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
                            </body>

                            </html>