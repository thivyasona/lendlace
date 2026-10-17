<%@ page import="java.util.List" %>
    <%@ page import="com.lendlace.dao.DressDAO" %>
        <%@ page import="com.lendlace.dao.BookingDAO" %>
            <%@ page import="com.lendlace.dao.ReviewDAO" %>
                <%@ page import="com.lendlace.model.Dress" %>
                    <%@ page import="com.lendlace.model.Booking" %>
                        <%@ page import="com.lendlace.model.Review" %>
                            <%@ page import="com.lendlace.model.User" %>
                                <% User owner=(User) session.getAttribute("loggedUser"); if (owner==null ||
                                    !"OWNER".equalsIgnoreCase(owner.getRole())) { response.sendRedirect("login.jsp");
                                    return; } DressDAO dressDAO=new DressDAO(); BookingDAO bookingDAO=new BookingDAO();
                                    ReviewDAO reviewDAO=new ReviewDAO(); List<Dress> myDresses =
                                    dressDAO.getDressesByOwner(owner.getUserId());
                                    List<Booking> pendingBookings = bookingDAO.getPendingBookingsByOwnerFull(owner.getUserId());
                                    List<Booking> processedBookings = bookingDAO.getProcessedBookingsByOwner(owner.getUserId());
                                        List<Review> latestReviews = reviewDAO.getAllReviews();
                                            %>
                                            <!DOCTYPE html>
                                            <html lang="en">

                                            <head>
                                                <meta charset="UTF-8">
                                                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                                                <title>Owner Dashboard | Dress Rental Management System</title>
                                                <!-- Bootstrap -->
                                                <link
                                                    href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
                                                    rel="stylesheet">
                                                <!-- Bootstrap Icons -->
                                                <link rel="stylesheet"
                                                    href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
                                                <!-- Google Font -->
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
                                                        background: #f4f6f9;
                                                    }

                                                    /* Navbar */
                                                    .navbar {
                                                        background: #6A1B9A;
                                                        box-shadow: 0 5px 15px rgba(0, 0, 0, .15);
                                                    }

                                                    .navbar-brand {
                                                        font-size: 28px;
                                                        font-weight: 700;
                                                    }

                                                    .nav-link {
                                                        color: white !important;
                                                        margin-left: 15px;
                                                    }

                                                    .nav-link:hover {
                                                        color: #FFD54F !important;
                                                    }

                                                    /* Hero */
                                                    .hero {
                                                        background: linear-gradient(135deg, #6A1B9A, #8E24AA);
                                                        color: white;
                                                        padding: 60px 0;
                                                    }

                                                    .hero h1 {
                                                        font-weight: 700;
                                                        font-size: 42px;
                                                    }

                                                    .hero p {
                                                        font-size: 18px;
                                                        margin-top: 15px;
                                                    }

                                                    .hero img {
                                                        max-height: 320px;
                                                    }

                                                    /* Cards */
                                                    .dashboard-card {
                                                        border: none;
                                                        border-radius: 20px;
                                                        box-shadow: 0 8px 20px rgba(0, 0, 0, .10);
                                                        transition: .3s;
                                                    }

                                                    .dashboard-card:hover {
                                                        transform: translateY(-8px);
                                                    }

                                                    .card-body {
                                                        padding: 25px;
                                                    }

                                                    .quick-btn {
                                                        border-radius: 30px;
                                                        padding: 12px 25px;
                                                        font-weight: 600;
                                                    }
                                                </style>
                                            </head>

                                            <body>
                                            <style>
                                                body{background:#FAF6F0 !important;}
                                                .navbar{background:#33172C !important;}
                                                .hero{
                                                    position:relative;
                                                    background:
                                                        linear-gradient(120deg, rgba(51,23,44,.9), rgba(74,32,64,.7)),
                                                        url("assets/images/dress8.jpg") center/cover no-repeat;
                                                }
                                                .dashboard-card{background:#fff;}
                                                .why-title,.section-title-plum,h2{color:#4A2040 !important;}
                                            </style>
                                            <!-- ================= NAVBAR ================= -->
                                            <nav class="navbar navbar-expand-lg navbar-dark">
                                                <div class="container">
                                                    <a class="navbar-brand" href="owner-dashboard.jsp">
                                                        <i class="bi bi-bag-heart-fill"></i>
                                                        Lend &amp; Lace
                                                    </a>
                                                        <button class="navbar-toggler" data-bs-toggle="collapse"
                                                            data-bs-target="#menu">
                                                            <span class="navbar-toggler-icon"></span>
                                                        </button>
                                                        <div class="collapse navbar-collapse" id="menu">
                                                            <ul class="navbar-nav ms-auto">
                                                                <li class="nav-item">
                                                                    <a class="nav-link" href="owner-dashboard.jsp">
                                                                        <i class="bi bi-speedometer2"></i>
                                                                        Dashboard
                                                                    </a>
                                                                </li>
                                                                <li class="nav-item">
                                                                    <a class="nav-link" href="add-dress.jsp">
                                                                        <i class="bi bi-plus-circle-fill"></i>
                                                                        Add Dress
                                                                    </a>
                                                                </li>
                                                                <li class="nav-item">
                                                                    <a class="nav-link" href="manage-dresses.jsp">
                                                                        <i class="bi bi-grid-fill"></i>
                                                                        My Dresses
                                                                    </a>
                                                                </li>
                                                                <li class="nav-item">
                                                                    <a class="nav-link" href="owner-bookings.jsp">
                                                                        <i class="bi bi-calendar-check-fill"></i>
                                                                        Bookings
                                                                    </a>
                                                                </li>
                                                                <li class="nav-item dropdown">
                                                                    <a class="nav-link dropdown-toggle" href="#"
                                                                        role="button" data-bs-toggle="dropdown">

                                                                        <i class="bi bi-person-circle"></i>
                                                                        <%= owner.getFullName() %>
                                                                    </a>
                                                                    <ul class="dropdown-menu dropdown-menu-end">
                                                                        <li>
                                                                            <button class="btn btn-primary"
                                                                                onclick="window.location.href='owner-profile.jsp'">
                                                                                Edit Profile
                                                                            </button>
                                                                        </li>
                                                                        <li>
                                                                            <a class="dropdown-item"
                                                                                href="owner-profile.jsp">Settings</a>
                                                                        </li>
                                                                        <li>
                                                                            <hr class="dropdown-divider">
                                                                        </li>
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

                                                <section class="hero" id="dashboard">
                                                    <div class="container">
                                                        <div class="row align-items-center">
                                                            <div class="col-lg-6">
                                                                <h1>
                                                                Welcome, <%= owner.getFullName() %>
                                                                </h1>
                                                                <p>
                                                                    Manage your dresses, bookings, availability,
                                                                    customer reviews and earnings from one dashboard.
                                                                </p>
                                                                    <a href="add-dress.jsp"
                                                                    class="btn btn-warning btn-lg quick-btn mt-3">
                                                                    <i class="bi bi-plus-circle-fill"></i> Upload New Dress
                                                                    </a>
                                                            </div>
                                                            <div class="col-lg-6 text-center">
                                                                <img src="assets/images/owner.jpg"
                                                                    class="img-fluid">
                                                            </div>
                                                        </div>
                                                    </div>
                                                </section>
                                                <!-- ================= STATISTICS (from MySQL) ================= -->

                                                <div class="container mt-5">
                                                    <div class="row g-4">
                                                        <div class="col-lg-3 col-md-6">
                                                            <div class="card dashboard-card">
                                                                <div class="card-body text-center">
                                                                    <h1 class="text-primary">
                                                                        <%= myDresses.size() %>
                                                                    </h1>
                                                                    <h5>
                                                                        My Dresses
                                                                    </h5>
                                                                </div>
                                                            </div>
                                                        </div>
                                                        <div class="col-lg-3 col-md-6">
                                                            <div class="card dashboard-card">
                                                                <div class="card-body text-center">
                                                                    <h1 class="text-success">
                                                                        <% int active=0; for (Booking b :
                                                                            bookingDAO.getBookingsByOwner(owner.getUserId())) { if
                                                                            ("Approved".equalsIgnoreCase(b.getStatus()))
                                                                            active++; } %>
                                                                            <%= active %>
                                                                    </h1>
                                                                    <h5>Active Rentals</h5>
                                                                </div>
                                                            </div>
                                                        </div>
                                                        <div class="col-lg-3 col-md-6">
                                                            <div class="card dashboard-card">
                                                                <div class="card-body text-center">
                                                                    <h1 class="text-warning">
                                                                        <%= pendingBookings.size() %>
                                                                    </h1>
                                                                    <h5>Booking Requests</h5>
                                                                </div>
                                                            </div>
                                                        </div>
                                                        <div class="col-lg-3 col-md-6">
                                                            <div class="card dashboard-card">
                                                                <div class="card-body text-center">
                                                                    <h1 class="text-danger">
                                                                        <% double totalEarn=0; for (Booking b :
                                                                            bookingDAO.getBookingsByOwner(owner.getUserId())) { if
                                                                            (!"Rejected".equalsIgnoreCase(b.getStatus()))
                                                                            totalEarn +=b.getGrandTotal(); } %>&#8377;
                                                                            <%= String.format("%,.0f", totalEarn) %>
                                                                    </h1>
                                                                    <h5>Total Earnings</h5>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                                <!-- ================= QUICK ACTIONS ================= -->
                                                <section class="container py-5" id="add-dress">
                                                    <h2 class="text-center mb-5">Quick Actions</h2>
                                                    <div class="row g-4">
                                                        <div class="col-lg-3 col-md-6">
                                                            <div class="card dashboard-card text-center">
                                                                <div class="card-body">
                                                                    <i
                                                                        class="bi bi-plus-circle-fill display-4 text-primary"></i>
                                                                    <h5 class="mt-3">Add Dress</h5>
                                                                    <p>Upload a new dress for rent.</p>
                                                                    <button class="btn btn-primary quick-btn"
                                                                        onclick="window.location.href='add-dress.jsp'">
                                                                        Upload
                                                                    </button>
                                                                </div>
                                                            </div>
                                                        </div>
                                                        <div class="col-lg-3 col-md-6">
                                                            <div class="card dashboard-card text-center">
                                                                <div class="card-body">
                                                                    <i
                                                                        class="bi bi-pencil-square display-4 text-success"></i>
                                                                    <h5 class="mt-3">Manage Dresses</h5>
                                                                    <p>Edit or remove existing dresses.</p>
                                                                    <button class="btn btn-success quick-btn"
                                                                        onclick="window.location.href='manage-dresses.jsp'">
                                                                        Manage
                                                                    </button>
                                                                </div>
                                                            </div>
                                                        </div>
                                                        <div class="col-lg-3 col-md-6">
                                                            <div class="card dashboard-card text-center">
                                                                <div class="card-body">
                                                                    <i
                                                                        class="bi bi-calendar-check-fill display-4 text-warning"></i>
                                                                    <h5 class="mt-3">Bookings</h5>
                                                                    <p>Approve or reject requests.</p>
                                                                    <button class="btn btn-warning quick-btn"
                                                                        onclick="window.location.href='owner-bookings.jsp'">
                                                                        View
                                                                    </button>
                                                                </div>
                                                            </div>
                                                        </div>
                                                        <div class="col-lg-3 col-md-6">
                                                            <div class="card dashboard-card text-center">
                                                                <div class="card-body">
                                                                    <i
                                                                        class="bi bi-star-fill display-4 text-danger"></i>
                                                                    <h5 class="mt-3">
                                                                        Reviews
                                                                    </h5>
                                                                    <p>
                                                                        See customer ratings.
                                                                    </p>
                                                                    <button class="btn btn-danger quick-btn"
                                                                        onclick="window.location.href='reviews.jsp'">
                                                                        Open
                                                                    </button>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </section>
                                                <!-- ================= MY DRESSES (from MySQL) ================= -->
                                                <section class="container pb-5" id="my-dresses">
                                                    <h2 class="text-center mb-5">My Dresses</h2>
                                                    <% if (myDresses.isEmpty()) { %>
                                                        <p class="text-center text-muted">You have not uploaded any
                                                            dresses yet.
                                                            <a href="add-dress.jsp">Add your first dress</a>.
                                                        </p>
                                                        <% } else { %>
                                                            <div class="row g-4" id="ownerDressContainer">
<% for (Dress d : myDresses) { String dImg = (d.getImage() == null || d.getImage().isEmpty()) ? "assets/images/image-unavailable.jpg" : d.getImage(); %>
<div class="col-lg-4">
<div class="card dashboard-card">
<img src="<%= dImg %>" class="card-img-top" style="height:220px;object-fit:cover;" alt="<%= d.getDressName() %>">
<div class="card-body">
<h5><%= d.getDressName() %></h5>
<p>&#8377;<%= String.format("%,.0f", d.getPricePerDay()) %> / Day</p>
<span class="badge bg-success"><%= d.getStatus()==null ? "Available" : d.getStatus() %></span>
<div class="mt-3">
<a href="updateDress?dressId=<%= d.getDressId() %>" class="btn btn-primary btn-sm">Edit</a>
<form action="deleteDress" method="post" class="d-inline" onsubmit="return confirm('Delete this dress permanently? This cannot be undone.');">
<input type="hidden" name="dressId" value="<%= d.getDressId() %>">
<button class="btn btn-danger btn-sm">Delete</button>
</form>
</div>
</div>
</div>
</div>
</div>
<% } } %>
</div>
</section>
<!-- ================= PENDING BOOKINGS (from MySQL) ================= -->

                                                <section class="container pb-5" id="bookings">
                                                    <h2 class="text-center mb-4">Booking Requests</h2>
                                                    <% if ("success".equals(request.getParameter("bookingUpdate"))) { %>
                                                        <div class="alert alert-success text-center"><i class="bi bi-check-circle-fill"></i> Booking updated successfully. The customer will see the decision on their My Bookings page.</div>
                                                        <% } else if ("conflict".equals(request.getParameter("bookingUpdate"))) { %>
                                                            <div class="alert alert-warning text-center"><i class="bi bi-exclamation-triangle"></i> Cannot accept: another booking for this dress is already approved for overlapping dates.</div>
                                                            <% } else if ("failed".equals(request.getParameter("bookingUpdate"))) { %>
                                                                <div class="alert alert-danger text-center">Failed to update booking. It may already have been processed.</div>
                                                                <% } %>
                                                    <% if (pendingBookings.isEmpty()) { %>
                                                                            <p class="text-center text-muted">No pending booking requests.
                                                                            </p>
                                                                            <% } else { for (Booking b : pendingBookings) { %>
                                                                    <div class="card dashboard-card mb-3">
                                                                        <div class="card-body">
                                                                            <div class="d-flex align-items-center flex-wrap gap-3">
                                                                                <img src="<%= b.getImage()==null||b.getImage().isEmpty() ? "assets/images/image-unavailable.jpg" : b.getImage() %>" width="70" height="70" class="rounded" style="object-fit:cover;" alt="<%= b.getDressName() %>">
                                                                                <div class="flex-grow-1">
                                                                                    <b>#<%= b.getBookingId() %> <%= b.getDressName() %></b><br>
                                                                                    <small class="text-muted">
                                                                                        <%= b.getCustomerName()==null ? "Customer #"+b.getCustomerId() : b.getCustomerName() %>
                                                                                        &middot; <%= b.getStartDate() %> to <%= b.getEndDate() %>
                                                                                        &middot; <%= b.getRentalDays() %> day<%= b.getRentalDays()==1?"":"s" %>
                                                                                        &middot; Total &#8377;<%= String.format("%,.0f", b.getGrandTotal()) %>
                                                                                    </small>
                                                                                </div>
                                                                                <span class="badge bg-warning text-dark">PENDING</span>
                                                                                <div>
                                                                                    <form action="ownerBooking" method="post" class="d-inline">
                                                                                        <input type="hidden" name="bookingId" value="<%= b.getBookingId() %>">
                                                                                        <button class="btn btn-success btn-sm" name="action" value="approve">Accept</button>
                                                                                    </form>
                                                                                    <form action="ownerBooking" method="post" class="d-inline" onsubmit="return confirm('Reject this booking? The customer will see REJECTED.');">
                                                                                        <input type="hidden" name="bookingId" value="<%= b.getBookingId() %>">
                                                                                        <button class="btn btn-danger btn-sm" name="action" value="reject">Reject</button>
                                                                                    </form>
                                                                                </div>
                                                                            </div>
                                                                        </div>
                                                                    </div>
                                                                    <% } } %>
                                                        </section>
                                                <section class="container pb-5">
    <h2 class="text-center mb-4">Recent Decisions</h2>
    <% if (processedBookings.isEmpty()) { %>
        <p class="text-center text-muted">No processed bookings yet.</p>
        <% } else { %>
            <div class="table-responsive">
                <table class="table table-bordered table-hover bg-white">
                    <thead class="table-dark">
                        <tr><th>Booking</th><th>Dress</th><th>Customer</th><th>Dates</th><th>Total</th><th>Status</th></tr>
                    </thead>
                    <tbody>
                        <% for (Booking pb : processedBookings) { %>
                            <tr>
                                <td>#<%= pb.getBookingId() %></td>
                                <td><%= pb.getDressName() %></td>
                                <td><%= pb.getCustomerName()==null ? "Customer #"+pb.getCustomerId() : pb.getCustomerName() %></td>
                                <td><%= pb.getStartDate() %> - <%= pb.getEndDate() %></td>
                                <td>&#8377;<%= String.format("%,.0f", pb.getGrandTotal()) %></td>
                                <td><span class="badge <%= "Rejected".equalsIgnoreCase(pb.getStatus()) ? "bg-danger" : "bg-success" %>"><%= pb.getStatus().toUpperCase() %></span></td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
            <% } %>
</section>
<!-- ================= LATEST REVIEWS (from MySQL) ================= -->
                                                <section class="container pb-5">
                                                    <h2 class="text-center mb-4">Latest Customer Reviews</h2>
                                                    <% if (latestReviews.isEmpty()) { %>
                                                        <p class="text-center text-muted">No reviews yet.</p>
                                                        <% } else { %>
                                                            <div class="row g-4">
                                                                <% int shown=0; for (Review r : latestReviews) { if
                                                                    (shown>= 3) break; shown++; %>
                                                                    <div class="col-lg-4">
                                                                        <div class="card dashboard-card">
                                                                            <div class="card-body">
                                                                                <h5>
                                                                                <% for (int i = 1; i <= 5; i++) { %>
                                                                                <i class="bi <%= i <= r.getRating() ? "bi-star-fill" : "bi-star" %>" style="color:#FFC107;"></i>
                                                                                <% } %>
                                                                                </h5>
                                                                                <p>"<%= r.getReview() %>"</p>
                                                                                <hr>
                                                                                <b>â€” <%= r.getUserName()==null
                                                                                        ? "Customer #" + r.getUserId() :
                                                                                        r.getUserName() %></b>
                                                                            </div>
                                                                        </div>
                                                                    </div>
                                                                    <% } %>
                                                            </div>
                                                            <% } %>
                                                </section>
                                                <!-- ================= OWNER PROFILE (from session/MySQL) ================= -->

                                                <section class="container pb-5">
                                                    <h2 class="text-center mb-4">
                                                        Owner Profile
                                                    </h2>
                                                    <div class="row justify-content-center">
                                                        <div class="col-lg-8">
                                                            <div class="card dashboard-card">
                                                                <div class="card-body">
                                                                    <div class="text-center">
                                                                        <% String oImg = (owner.getProfileImage() == null || owner.getProfileImage().isEmpty()) ? "assets/images/default-user.png" : owner.getProfileImage(); %>
<img src="<%= oImg %>"
                                                                        class="rounded-circle mb-3"
                                                                        width="120"
                                                                        height="120">
                                                                        <h3>
                                                                            <%= owner.getFullName() %>
                                                                        </h3>
                                                                        <p class="text-muted">
                                                                            Dress Owner
                                                                        </p>
                                                                    </div>
                                                                    <hr>
                                                                    <div class="row">
                                                                        <div class="col-md-6 mb-3">
                                                                            <label class="form-label">
                                                                                Full Name

                                                                            </label>

                                                                            <input type="text" class="form-control"
                                                                                value="<%= owner.getFullName() %>"
                                                                                readonly>
                                                                        </div>
                                                                        <div class="col-md-6 mb-3">
                                                                            <label class="form-label">
                                                                                Email
                                                                            </label>
                                                                            <input type="email" class="form-control"
                                                                                value="<%= owner.getEmail() %>"
                                                                                readonly>
                                                                        </div>
                                                                    </div>
                                                                    <div class="row">
                                                                        <div class="col-md-6 mb-3">
                                                                            <label class="form-label">
                                                                                Mobile Number
                                                                            </label>
                                                                            <input type="text" class="form-control"
                                                                                value="<%= owner.getPhone() == null ? "" : owner.getPhone() %>"
                                                                                readonly>
                                                                        </div>
                                                                    </div>
                                                                    <div class="mb-3">
                                                                        <label class="form-label">
                                                                            Address
                                                                        </label>
                                                                        <textarea class="form-control" rows="3"
                                                                            readonly><%= owner.getAddress() == null ? "" : owner.getAddress() %></textarea>
                                                                    </div>
                                                                    <div class="text-center mt-4">
                                                                        <button class="btn btn-primary"
                                                                            onclick="window.location.href='owner-profile.jsp'">
                                                                            Edit Profile
                                                                        </button>
                                                                        <a href="logout" class="btn btn-danger ms-2">
                                                                            Logout
                                                                        </a>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </section>
                                                <!-- ================= FOOTER ================= -->
                                                <footer class="bg-dark text-white py-5 mt-5">
                                                    <div class="container">
                                                        <div class="row">
                                                            <div class="col-md-4">
                                                                <h4>
                                                                    Lend &amp; Lace
                                                                </h4>
                                                                <p>
                                                                    Professional Dress Rental Management Platform.
                                                                </p>
                                                            </div>
                                                            <div class="col-md-4">
                                                                <h4>
                                                                    Quick Links
                                                                </h4>
                                                                <ul class="list-unstyled">
                                                                    <li>Dashboard</li>
                                                                    <li>My Dresses</li>
                                                                    <li>Bookings</li>
                                                                    <li>Profile</li>
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
                                                <script
                                                    src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
                                            </body>

                                            </html>
