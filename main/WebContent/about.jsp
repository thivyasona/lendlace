<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>About Us | Lend &amp; Lace Dress Rental</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@500;600;700&family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root{
            --ll-cream:#FAF6F0; --ll-lavender:#C9B8E8; --ll-lavender-soft:#EDE7F6;
            --ll-plum:#4A2040; --ll-plum-deep:#33172C; --ll-plum-mid:#6B3A5B;
            --ll-ink:#2E2233; --ll-muted:#7A6B80; --ll-gold:#C6A664;
        }
        *{margin:0;padding:0;box-sizing:border-box;}
        body{font-family:'Poppins',sans-serif;background:var(--ll-cream);color:var(--ll-ink);}
        h1,h2,h3{font-family:'Playfair Display',serif;color:var(--ll-plum);}
        .navbar{background:var(--ll-plum-deep) !important;padding:15px 0;}
        .navbar-brand{font-family:'Playfair Display',serif;font-size:26px;font-weight:700;letter-spacing:1px;}
        .nav-link{color:#F4EEF6 !important;margin-left:18px;font-weight:500;}
        .nav-link:hover{color:var(--ll-lavender) !important;}
        .page-hero{
            position:relative;color:#fff;padding:80px 0;text-align:center;
            background:linear-gradient(120deg, rgba(51,23,44,.88), rgba(74,32,64,.7)),
                       url("assets/images/dress8.jpg") center/cover no-repeat;
        }
        .page-hero h1{color:#fff;}
        .story-img{border-radius:20px;box-shadow:0 14px 30px rgba(74,32,64,.18);width:100%;height:100%;max-height:420px;object-fit:cover;}
        .step-card,.why-card{background:#fff;border:none;border-radius:18px;padding:32px 22px;height:100%;
            box-shadow:0 6px 18px rgba(74,32,64,.08);transition:transform .25s ease, box-shadow .25s ease;}
        .step-card:hover,.why-card:hover{transform:translateY(-6px);box-shadow:0 14px 28px rgba(74,32,64,.16);}
        .step-icon,.why-icon{width:60px;height:60px;margin:0 auto 16px;border-radius:50%;
            background:linear-gradient(135deg,var(--ll-plum),var(--ll-plum-mid));color:#fff;
            display:flex;align-items:center;justify-content:center;font-size:24px;
            box-shadow:0 6px 14px rgba(74,32,64,.35);}
        .why-icon{width:64px;}
        .muted{color:var(--ll-muted);}
        footer{background:var(--ll-plum-deep);}
        footer h4{font-family:'Playfair Display',serif;}
        footer p{color:#D9CFE0;}
        footer a{color:#F4EEF6;text-decoration:none;}
        footer a:hover{color:var(--ll-lavender);}
        footer i{cursor:pointer;transition:.3s;}
        footer i:hover{color:var(--ll-lavender);transform:scale(1.15);}
        @media(max-width:768px){ .page-hero{padding:60px 0;} .story-img{max-height:300px;} }
    </style>
</head>
<body>

<!-- ================= NAVBAR ================= -->
<nav class="navbar navbar-expand-lg navbar-dark sticky-top">
    <div class="container">
        <a class="navbar-brand fw-bold" href="index.jsp">
            <i class="bi bi-bag-heart-fill"></i>
            Lend &amp; Lace
        </a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#menu">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="menu">
            <ul class="navbar-nav ms-auto">
                <li class="nav-item"><a class="nav-link" href="index.jsp">Home</a></li>
                <li class="nav-item"><a class="nav-link" href="browse-dresses">Browse Dresses</a></li>
                <li class="nav-item"><a class="nav-link active" href="about.jsp">About</a></li>
                <li class="nav-item"><a class="nav-link" href="contact.jsp">Contact</a></li>
                <li class="nav-item">
                    <a class="btn btn-outline-light ms-2" href="login.jsp">Login</a>
                </li>
                <li class="nav-item">
                    <a class="btn btn-warning ms-2" href="register.jsp">Register</a>
                </li>
            </ul>
        </div>
    </div>
</nav>

<!-- ================= PAGE HERO ================= -->
<section class="page-hero">
    <div class="container">
        <h1 class="mb-2">About Lend &amp; Lace</h1>
        <p class="mb-0">Premium dress rental for weddings, receptions, festivals and every special occasion.</p>
    </div>
</section>

<!-- ================= OUR STORY ================= -->
<section class="container py-5" id="story">
    <div class="row align-items-center g-5">
        <div class="col-lg-6">
            <img src="assets/images/dress3.jpg" class="story-img" alt="Elegant rented gown on a mannequin in a boutique">
        </div>
        <div class="col-lg-6">
            <h2 class="mb-3">Our Story</h2>
            <p class="muted">
                Lend &amp; Lace began with a simple observation: most people own beautiful
                special-occasion outfits they wear only once or twice, while others need
                exactly that kind of outfit for a single wedding, reception or festival.
            </p>
            <p class="muted">
                We built Lend &amp; Lace to connect the two. Dress owners list their gowns,
                sarees, lehengas and bridal wear on the platform; customers browse real
                photos, check availability on a live calendar, and reserve the dress for
                the exact dates they need it - at a fraction of the retail price.
            </p>
        </div>
    </div>
</section>

<!-- ================= OUR MISSION ================= -->
<section class="container pb-5" id="mission">
    <div class="row align-items-center g-5">
        <div class="col-lg-6 order-lg-2">
            <img src="assets/images/dress1.jpg" class="story-img" alt="Traditional saree and bridal wear collection ready for rental">
        </div>
        <div class="col-lg-6 order-lg-1">
            <h2 class="mb-3">Our Mission</h2>
            <p class="muted">
                Our mission is to make special-occasion fashion accessible and sustainable.
                Renting keeps premium outfits in circulation instead of sitting in a cupboard,
                lets customers wear designer-quality clothing for a single event, and gives
                dress owners a way to earn income from the collections they already own.
            </p>
            <ul class="muted mt-3">
                <li class="mb-2"><i class="bi bi-check2-circle text-success me-2"></i>Transparent per-day pricing with a clearly shown refundable deposit.</li>
                <li class="mb-2"><i class="bi bi-check2-circle text-success me-2"></i>Server-verified availability so a dress can never be double-booked.</li>
                <li class="mb-2"><i class="bi bi-check2-circle text-success me-2"></i>Secure accounts with hashed passwords and protected role-based dashboards.</li>
            </ul>
        </div>
    </div>
</section>

<!-- ================= HOW IT WORKS ================= -->
<section class="container pb-5" id="how-it-works">
    <h2 class="text-center mb-5">How It Works</h2>
    <div class="row g-4 text-center">
        <div class="col-lg-3 col-md-6">
            <div class="step-card">
                <div class="step-icon"><i class="bi bi-search"></i></div>
                <h5 class="mb-2">1. Browse</h5>
                <p class="muted small mb-0">Filter dresses by category, size, colour, occasion and price on the Browse Dresses page.</p>
            </div>
        </div>
        <div class="col-lg-3 col-md-6">
            <div class="step-card">
                <div class="step-icon"><i class="bi bi-calendar-check"></i></div>
                <h5 class="mb-2">2. Pick Your Dates</h5>
                <p class="muted small mb-0">Check the availability calendar and choose a rental window that is free for that dress.</p>
            </div>
        </div>
        <div class="col-lg-3 col-md-6">
            <div class="step-card">
                <div class="step-icon"><i class="bi bi-hourglass-split"></i></div>
                <h5 class="mb-2">3. Owner Confirms</h5>
                <p class="muted small mb-0">Your request is sent to the dress owner, who approves or declines it from their dashboard.</p>
            </div>
        </div>
        <div class="col-lg-3 col-md-6">
            <div class="step-card">
                <div class="step-icon"><i class="bi bi-handbag"></i></div>
                <h5 class="mb-2">4. Wear &amp; Return</h5>
                <p class="muted small mb-0">Wear the dress for your occasion, then return it. The refundable deposit is released after a successful return.</p>
            </div>
        </div>
    </div>
</section>

<!-- ================= WHY CHOOSE US ================= -->
<section class="pb-5" id="why">
    <div class="container">
        <h2 class="text-center mb-5">Why Choose Lend &amp; Lace</h2>
        <div class="row g-4 text-center">
            <div class="col-md-3">
                <div class="why-card">
                    <div class="why-icon"><i class="bi bi-patch-check-fill"></i></div>
                    <h5>Verified Owners</h5>
                    <p class="muted small mb-0">Dress owners manage their own listings through a dedicated owner dashboard with server-side ownership checks.</p>
                </div>
            </div>
            <div class="col-md-3">
                <div class="why-card">
                    <div class="why-icon"><i class="bi bi-cash-coin"></i></div>
                    <h5>Affordable Prices</h5>
                    <p class="muted small mb-0">Designer wear for a fraction of the retail price, with transparent per-day pricing.</p>
                </div>
            </div>
            <div class="col-md-3">
                <div class="why-card">
                    <div class="why-icon"><i class="bi bi-shield-lock-fill"></i></div>
                    <h5>Secure Booking</h5>
                    <p class="muted small mb-0">Hashed passwords, role-based access control, and every charge recalculated on the server.</p>
                </div>
            </div>
            <div class="col-md-3">
                <div class="why-card">
                    <div class="why-icon"><i class="bi bi-arrow-repeat"></i></div>
                    <h5>Easy Returns</h5>
                    <p class="muted small mb-0">Flexible rental windows and a simple return process with a refundable deposit.</p>
                </div>
            </div>
        </div>
        <div class="text-center mt-5">
            <a href="browse-dresses" class="btn btn-primary btn-lg"><i class="bi bi-bag-heart-fill"></i> Browse Dresses</a>
            <a href="register.jsp" class="btn btn-outline-primary btn-lg ms-2">Become a Dress Owner</a>
        </div>
    </div>
</section>

<!-- ================= FOOTER ================= -->
<footer class="text-white py-5">
    <div class="container">
        <div class="row">
            <div class="col-md-4">
                <h4>Lend &amp; Lace</h4>
                <p>Find premium dresses for rent at affordable prices.</p>
            </div>
            <div class="col-md-4">
                <h4>Quick Links</h4>
                <ul class="list-unstyled">
                    <li><a href="about.jsp">About</a></li>
                    <li><a href="contact.jsp">Contact</a></li>
                    <li><a href="privacy.jsp">Privacy</a></li>
                    <li><a href="terms.jsp">Terms</a></li>
                </ul>
            </div>
            <div class="col-md-4">
                <h4>Follow Us</h4>
                <i class="bi bi-facebook fs-2"></i>
                <i class="bi bi-instagram fs-2 ms-3"></i>
                <i class="bi bi-twitter-x fs-2 ms-3"></i>
            </div>
        </div>
        <hr>
        <p class="text-center mb-0">&copy; 2026 Lend &amp; Lace Dress Rental Management System</p>
    </div>
</footer>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
