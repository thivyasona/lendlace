<%@ page import="com.lendlace.dao.DressDAO" %>
<%@ page import="com.lendlace.dao.ReviewDAO" %>
<%@ page import="com.lendlace.dao.UserDAO" %>
<%@ page import="com.lendlace.dao.BookingDAO" %>
<%@ page import="com.lendlace.dao.WishlistDAO" %>
<%@ page import="com.lendlace.model.Dress" %>
<%@ page import="com.lendlace.model.Review" %>
<%@ page import="com.lendlace.model.User" %>
<%@ page import="com.lendlace.model.Booking" %>
<%@ page import="java.util.List" %>
<%
    String id = request.getParameter("dressId");
    if (id == null) { response.sendRedirect("browse-dresses"); return; }

    DressDAO dao = new DressDAO();
    Dress dress;
    try {
        dress = dao.getDressById(Integer.parseInt(id));
    } catch (NumberFormatException e) {
        response.sendRedirect("browse-dresses"); return;
    }
    if (dress == null) { response.sendRedirect("browse-dresses"); return; }

    // ---- real data from MySQL ----
    ReviewDAO reviewDAO = new ReviewDAO();
    List<Review> dressReviews = reviewDAO.getReviewsByDress(dress.getDressId());
    double avgRating = 0;
    for (Review r : dressReviews) avgRating += r.getRating();
    avgRating = dressReviews.isEmpty() ? 0 : avgRating / dressReviews.size();

    User dressOwner = new UserDAO().getUserById(dress.getOwnerId());

    // similar dresses: same category first, then others (max 3, exclude this one)
    List<Dress> similar = new java.util.ArrayList<>();
    for (Dress sd : dao.getAllDresses()) {
        if (sd.getDressId() != dress.getDressId()
                && dress.getCategory() != null
                && dress.getCategory().equalsIgnoreCase(sd.getCategory())) {
            similar.add(sd);
            if (similar.size() >= 3) break;
        }
    }
    if (similar.isEmpty()) {
        for (Dress sd : dao.getAllDresses()) {
            if (sd.getDressId() != dress.getDressId()) {
                similar.add(sd);
                if (similar.size() >= 3) break;
            }
        }
    }

    // real booked dates (approved/confirmed/pending bookings) for the availability calendar
    java.util.Set<java.time.LocalDate> bookedDates = new java.util.HashSet<>();
    for (Booking bb : new BookingDAO().getAllBookings()) {
        if (bb.getDressId() == dress.getDressId()
                && ("Approved".equalsIgnoreCase(bb.getStatus())
                    || "Confirmed".equalsIgnoreCase(bb.getStatus())
                    || "Pending".equalsIgnoreCase(bb.getStatus()))) {
            try {
                java.time.LocalDate s = java.time.LocalDate.parse(bb.getStartDate());
                java.time.LocalDate e = java.time.LocalDate.parse(bb.getEndDate());
                while (!s.isAfter(e)) { bookedDates.add(s); s = s.plusDays(1); }
            } catch (Exception ignored) { }
        }
    }

    boolean isInWishlist = false;
    User sessionUser = (User) session.getAttribute("loggedUser");
    if (sessionUser != null) {
        isInWishlist = new WishlistDAO().isInWishlist(sessionUser.getUserId(), dress.getDressId());
    }

    String mainImg = (dress.getImage() == null || dress.getImage().isEmpty())
            ? "assets/images/image-unavailable.jpg" : dress.getImage();
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><%= dress.getDressName() %> | Lend &amp; Lace</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
<style>
    body{background:#FAF6F0;font-family:Poppins,sans-serif;}
    .navbar{background:#33172C;}
    .details-card{border:none;border-radius:20px;box-shadow:0 5px 15px rgba(74,32,64,.08);background:#fff;}
    .gallery-img{height:480px;object-fit:cover;border-radius:15px;width:100%;}
    .thumbnail{width:80px;height:80px;object-fit:cover;border-radius:10px;cursor:pointer;border:2px solid transparent;}
    .thumbnail:hover{border-color:#6A1B9A;}
    .price{font-size:26px;font-weight:700;color:#6B3A5B;}
    .info-table td{padding:10px;}
    .book-box{position:sticky;top:90px;}
    .dress-card img{height:260px;object-fit:cover;}
    .calendar td.booked{background:#f8d7da;color:#842029;font-weight:600;}
</style>
</head>
<body>
<nav class="navbar navbar-expand-lg navbar-dark">
    <div class="container">
        <a class="navbar-brand" href="index.jsp"><i class="bi bi-bag-heart-fill"></i> Dress Rental</a>
        <button class="navbar-toggler" data-bs-toggle="collapse" data-bs-target="#menu"><span class="navbar-toggler-icon"></span></button>
        <div class="collapse navbar-collapse" id="menu">
            <ul class="navbar-nav ms-auto">
                <li class="nav-item"><a class="nav-link" href="index.jsp">Home</a></li>
                <li class="nav-item"><a class="nav-link" href="browse-dresses">Browse Dresses</a></li>
                <% if (sessionUser != null && "CUSTOMER".equalsIgnoreCase(sessionUser.getRole())) { %>
                    <li class="nav-item"><a class="nav-link" href="customer-dashboard.jsp">Dashboard</a></li>
                    <li class="nav-item"><a class="nav-link" href="wishlist.jsp">Wishlist</a></li>
                    <li class="nav-item"><a class="nav-link" href="my-bookings.jsp">My Bookings</a></li>
                <% } else if (sessionUser == null) { %>
                    <li class="nav-item"><a class="nav-link" href="login.jsp">Login</a></li>
                <% } %>
            </ul>
        </div>
    </div>
</nav>

<!-- DRESS DETAILS -->
<div class="container py-5">
    <div class="row">
        <div class="col-lg-7">
            <div class="card details-card p-3">
                <img src="<%= mainImg %>" class="img-fluid gallery-img" id="mainImage" alt="<%= dress.getDressName() %>">
                <div class="d-flex justify-content-center gap-3 mt-3">
                    <img src="<%= mainImg %>" class="thumbnail" onclick="changeImage(this)">
                </div>
            </div>
        </div>
        <div class="col-lg-5">
            <div class="card details-card p-4 book-box">
                <h2><%= dress.getDressName() %></h2>
                <p class="text-muted">Brand : <%= dress.getBrand() == null ? "-" : dress.getBrand() %></p>
                <div class="rating">
                    <% if (dressReviews.isEmpty()) { %>
                        <span class="text-muted">No reviews yet</span>
                    <% } else { for (int i = 1; i <= 5; i++) { %><i class="bi <%= i <= Math.round(avgRating) ? "bi-star-fill" : "bi-star" %>" style="color:#FFC107;"></i><% } %>
                        <span class="ms-1"><%= String.format("%.1f", avgRating) %> (<%= dressReviews.size() %> Review<%= dressReviews.size() == 1 ? "" : "s" %>)</span>
                    <% } %>
                </div>
                <div class="price mt-3">&#8377;<%= String.format("%,.0f", dress.getPricePerDay()) %> / Day</div>
                <div class="mt-3">
                    <p><b>Available From:</b> <%= dress.getAvailableFrom() == null ? "-" : dress.getAvailableFrom() %></p>
                    <p><b>Available Until:</b> <%= dress.getAvailableTo() == null ? "-" : dress.getAvailableTo() %></p>
                </div>
                <p>Security Deposit : <b>&#8377;<%= String.format("%,.0f", dress.getSecurityDeposit()) %></b></p>
                <span class="badge bg-success"><%= dress.getStatus() %></span>
                <hr>
                <table class="table info-table">
                    <tr><td><b>Category</b></td><td><%= dress.getCategory() == null ? "-" : dress.getCategory() %></td></tr>
                    <tr><td><b>Size</b></td><td><%= dress.getSize() == null ? "-" : dress.getSize() %></td></tr>
                    <tr><td><b>Color</b></td><td><%= dress.getColor() == null ? "-" : dress.getColor() %></td></tr>
                    <tr><td><b>Occasion</b></td><td><%= dress.getOccasion() == null ? "-" : dress.getOccasion() %></td></tr>
                    <tr><td><b>Rental Price</b></td><td>&#8377;<%= String.format("%,.0f", dress.getPricePerDay()) %> / Day</td></tr>
                    <tr><td><b>Security Deposit</b></td><td>&#8377;<%= String.format("%,.0f", dress.getSecurityDeposit()) %></td></tr>
                </table>
                <h5 class="mt-4">Description</h5>
                <p class="text-muted"><%= dress.getDescription() == null ? "-" : dress.getDescription() %></p>

                <!-- OWNER DETAILS (real, from MySQL) -->
                <div class="owner-card mt-4">
                    <div class="d-flex align-items-center">
                        <img src="<%= (dressOwner != null && dressOwner.getProfileImage() != null && !dressOwner.getProfileImage().isEmpty()) ? dressOwner.getProfileImage() : "assets/images/default-user.png" %>"
                             width="70" height="70" class="rounded-circle me-3" alt="Owner">
                        <div>
                            <h5 class="mb-1"><%= dressOwner != null ? dressOwner.getFullName() : "Verified Dress Owner" %></h5>
                            <p class="text-muted mb-0">Dress owner verified by the platform</p>
                        </div>
                    </div>
                    <hr>
                    <% if (dressOwner != null && dressOwner.getAddress() != null && !dressOwner.getAddress().isEmpty()) { %>
                        <p><i class="bi bi-geo-alt-fill"></i> <%= dressOwner.getAddress() %></p>
                    <% } %>
                    <% if (dressOwner != null && dressOwner.getPhone() != null && !dressOwner.getPhone().isEmpty()) { %>
                        <p><i class="bi bi-telephone-fill"></i> <%= dressOwner.getPhone() %></p>
                    <% } %>
                    <p><i class="bi bi-envelope-fill"></i> <%= dressOwner != null ? dressOwner.getEmail() : "-" %></p>
                </div>

                <div class="d-grid gap-2 mt-4">
                    <button class="btn btn-danger" onclick="addToWishlist()">
                        <i class="bi bi-heart-fill"></i>
                        <%= isInWishlist ? "In Wishlist" : "Add to Wishlist" %>
                    </button>
                    <button class="btn btn-outline-primary" onclick="shareDress()">
                        <i class="bi bi-share-fill"></i> Share Dress
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- BOOKING SECTION -->
    <div class="row mt-5">
        <div class="col-lg-8">
            <div class="card details-card p-4">
                <h3 class="mb-4"><i class="bi bi-calendar-check-fill text-primary"></i> Book This Dress</h3>
                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label">Rental Start Date</label>
                        <input type="date" class="form-control" id="startDate">
                    </div>
                    <div class="col-md-6 mb-3">
                        <label class="form-label">Rental End Date</label>
                        <input type="date" class="form-control" id="endDate">
                    </div>
                </div>
                <div class="mb-4">
                    <label class="form-label">Select Size</label>
                    <select class="form-select" id="sizeSelect">
                        <option value="">Any / As available</option>
                        <option value="XS">XS</option>
                        <option value="S">S</option>
                        <option value="M">M</option>
                        <option value="L">L</option>
                        <option value="XL">XL</option>
                        <option value="Free">Free Size</option>
                    </select>
                </div>
                <div class="card bg-light border-0 p-3">
                    <h5 class="mb-3">Price Summary</h5>
                    <div class="d-flex justify-content-between mb-2">
                        <span>Rental Price Per Day</span>
                        <span>&#8377;<%= String.format("%,.0f", dress.getPricePerDay()) %></span>
                    </div>
                    <div class="d-flex justify-content-between mb-2">
                        <span>Number of Rental Days</span>
                        <span id="daysCount">0</span>
                    </div>
                    <div class="d-flex justify-content-between mb-2">
                        <span>Rental Cost</span>
                        <span id="rentalCost">&#8377;0</span>
                    </div>
                    <div class="d-flex justify-content-between mb-2">
                        <span>Security Deposit</span>
                        <span>&#8377;<%= String.format("%,.0f", dress.getSecurityDeposit()) %></span>
                    </div>
                    <hr>
                    <div class="d-flex justify-content-between fw-bold fs-5">
                        <span>Grand Total</span>
                        <span id="grandTotal">&#8377;0</span>
                    </div>
                </div>
                <div class="d-grid gap-3 mt-4">
                    <a id="bookNowBtn"
                       href="booking.jsp?dressId=<%= dress.getDressId() %>"
                       class="btn btn-success btn-lg">
                        <i class="bi bi-cart-check-fill"></i> Book Now
                    </a>
                    <button type="button" class="btn btn-outline-primary" onclick="printReceipt()">
                        <i class="bi bi-file-earmark-pdf-fill"></i> Download Receipt Preview
                    </button>
                </div>
            </div>
        </div>

        <!-- AVAILABILITY CALENDAR (real booked dates from MySQL) -->
        <div class="col-lg-4">
            <div class="card details-card p-4">
                <h4 class="mb-3"><i class="bi bi-calendar3 text-primary"></i> Availability</h4>
                <div class="mb-3">
                    <span class="badge bg-success"><%= dress.getStatus() %></span>
                </div>
                <table class="table table-bordered text-center calendar">
                    <thead class="table-light">
                    <tr><th>Su</th><th>Mo</th><th>Tu</th><th>We</th><th>Th</th><th>Fr</th><th>Sa</th></tr>
                    </thead>
                    <tbody>
                    <%
                        java.time.YearMonth month = java.time.YearMonth.now();
                        int firstDow = month.atDay(1).getDayOfWeek().getValue() % 7; // Sun=0
                        int len = month.lengthOfMonth();
                        outer:
                        for (int w = 0; w < 6; w++) {
                    %>
                    <tr>
                        <%
                        for (int d = 0; d < 7; d++) {
                            int dayNum = w * 7 + d - firstDow + 1;
                            if (dayNum < 1 || dayNum > len) {
                        %>
                        <td></td>
                        <%
                            } else {
                                java.time.LocalDate date = month.atDay(dayNum);
                                boolean booked = bookedDates.contains(date);
                        %>
                        <td class="<%= booked ? "booked" : "" %>"><%= dayNum %></td>
                        <%
                            }
                        }
                        %>
                    </tr>
                    <%
                        if (w * 7 + firstDow >= len) break outer;
                        }
                    %>
                    </tbody>
                </table>
                <p class="text-muted small mb-0">Red dates are already booked and unavailable for new rentals.</p>
            </div>
            <% if (dress.getVideo() != null && !dress.getVideo().isEmpty() && dress.getVideo().startsWith("http")) { %>
            <div class="card details-card p-4 mt-4">
                <h4><i class="bi bi-play-circle-fill text-danger"></i> Dress Video</h4>
                <div class="ratio ratio-16x9">
                    <iframe src="<%= dress.getVideo() %>" allowfullscreen></iframe>
                </div>
            </div>
            <% } %>
        </div>
    </div>

    <!-- CUSTOMER REVIEWS (from MySQL) -->
    <section class="py-5">
        <h2 class="text-center mb-5">Customer Reviews</h2>
        <% if (dressReviews.isEmpty()) { %>
            <p class="text-center text-muted">No reviews yet. Be the first to review this dress.</p>
        <% } else { %>
        <div class="row g-4">
            <% for (Review r : dressReviews) { %>
            <div class="col-lg-6">
                <div class="card details-card p-4">
                    <h5><% for (int i = 1; i <= 5; i++) { %><i class="bi <%= i <= r.getRating() ? "bi-star-fill" : "bi-star" %>" style="color:#FFC107;"></i><% } %></h5>
                    <p><%= r.getReview() %></p>
                </div>
            </div>
            <% } %>
        </div>
        <% } %>
    </section>

    <!-- SIMILAR DRESSES (from MySQL, same category first) -->
    <section class="pb-5">
        <h2 class="text-center mb-5">Similar Dresses</h2>
        <div class="row g-4">
            <% if (similar.isEmpty()) { %>
                <p class="text-center text-muted">No similar dresses available yet.</p>
            <% } %>
            <% for (Dress sd : similar) { String sdImg = (sd.getImage() == null || sd.getImage().isEmpty()) ? "assets/images/image-unavailable.jpg" : sd.getImage(); %>
            <div class="col-lg-4">
                <div class="card dress-card">
                    <img src="<%= sdImg %>" class="card-img-top">
                    <div class="card-body">
                        <h5><%= sd.getDressName() %></h5>
                        <p class="price">&#8377;<%= String.format("%,.0f", sd.getPricePerDay()) %> / Day</p>
                        <a href="DressServlet?action=view&dressId=<%= sd.getDressId() %>" class="btn btn-primary w-100">View Dress</a>
                    </div>
                </div>
            </div>
            <% } %>
        </div>
    </section>
</div>

<footer class="bg-dark text-white py-5">
    <div class="container">
        <div class="row">
            <div class="col-md-4">
                <h4>Dress Rental</h4>
                <p>Rent premium dresses for weddings, receptions, festivals and parties at affordable prices.</p>
            </div>
            <div class="col-md-4">
                <h4>Quick Links</h4>
                <ul class="list-unstyled">
                    <li><a href="about.jsp" class="text-white text-decoration-none">About Us</a></li>
                    <li><a href="contact.jsp" class="text-white text-decoration-none">Contact Us</a></li>
                    <li><a href="terms.jsp" class="text-white text-decoration-none">FAQ / Terms</a></li>
                    <li><a href="privacy.jsp" class="text-white text-decoration-none">Privacy Policy</a></li>
                    <li><a href="terms.jsp" class="text-white text-decoration-none">Terms &amp; Conditions</a></li>
                </ul>
            </div>
            <div class="col-md-4">
                <h4>Follow Us</h4>
                <i class="bi bi-facebook fs-2 me-3"></i>
                <i class="bi bi-instagram fs-2 me-3"></i>
                <i class="bi bi-twitter-x fs-2 me-3"></i>
                <i class="bi bi-youtube fs-2"></i>
            </div>
        </div>
        <hr>
        <p class="text-center mb-0">&copy; 2026 Dress Rental Management System. All Rights Reserved.</p>
    </div>
</footer>

<script>
function changeImage(img){ document.getElementById("mainImage").src = img.src; }
function calculatePrice() {
    let pricePerDay = <%= dress.getPricePerDay() %>;
    let deposit = <%= dress.getSecurityDeposit() %>;
    let startVal = document.getElementById("startDate").value;
    let endVal = document.getElementById("endDate").value;
    if (!startVal || !endVal) return;
    let start = new Date(startVal), end = new Date(endVal);
    if (end >= start) {
        let days = Math.round((end - start) / (1000 * 60 * 60 * 24)) + 1;
        let rent = days * pricePerDay;
        document.getElementById("daysCount").innerHTML = days;
        document.getElementById("rentalCost").innerHTML = "&#8377;" + rent.toLocaleString();
        document.getElementById("grandTotal").innerHTML = "&#8377;" + (rent + deposit).toLocaleString();
    }
}
document.getElementById("startDate").addEventListener("change", calculatePrice);
document.getElementById("endDate").addEventListener("change", calculatePrice);

function addToWishlist() {
    const form = document.createElement("form");
    form.method = "POST";
    form.action = "wishlist";
    const input = document.createElement("input");
    input.type = "hidden"; input.name = "dressId";
    input.value = "<%= dress.getDressId() %>";
    form.appendChild(input);
    document.body.appendChild(form);
    form.submit();
}
function shareDress() {
    const url = window.location.href;
    if (navigator.share) { navigator.share({ title: document.title, url: url }).catch(function(){}); }
    else if (navigator.clipboard) { navigator.clipboard.writeText(url); alert("Link copied to clipboard!"); }
    else { prompt("Copy this link:", url); }
}
function printReceipt() {
    const startVal = document.getElementById("startDate").value;
    const endVal = document.getElementById("endDate").value;
    if (!startVal || !endVal) { alert("Please select rental dates first to preview your receipt."); return; }
    window.print();
}
</script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
