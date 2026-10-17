<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">
    <title>Forgot Password | Lend &amp; Lace Dress Rental</title>
    <!-- Bootstrap -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
          rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link rel="stylesheet"
          href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <!-- Google Font -->
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
            min-height:100vh;
            background:
            linear-gradient(120deg, rgba(51,23,44,.72), rgba(74,32,64,.55)),
            url("assets/images/login-bg.jpg");
            background-size:cover;
            background-position:center;
            display:flex;
            justify-content:center;
            align-items:center;
            padding:20px;
        }
        .forgot-card{
            width:100%;
            max-width:480px;
            background:rgba(58,26,50,.55);
            backdrop-filter:blur(20px);
            border-radius:20px;
            padding:40px;
            color:white;
            border:1px solid rgba(237,231,246,.25);
            box-shadow:0 10px 40px rgba(0,0,0,.45);
        }
        .logo{
            text-align:center;
            font-family:'Playfair Display',serif;
            font-size:32px;
            font-weight:700;
            margin-bottom:10px;
        }
        .sub{
            text-align:center;
            color:#eee;
            margin-bottom:30px;
        }
        .icon{
            width:90px;
            height:90px;
            border-radius:50%;
            background:rgba(255,255,255,.2);
            display:flex;
            justify-content:center;
            align-items:center;
            margin:0 auto 25px;
            font-size:42px;
        }
        .form-control{
            height:52px;
            border-radius:12px;
        }
        .btn-reset{
            width:100%;
            height:52px;
            border:none;
            border-radius:12px;
            background:#6B3A5B;
            color:white;
            font-size:18px;
            font-weight:600;
            transition:.3s;
        }
        .btn-reset:hover{
            background:#4A2040;
            transform:translateY(-2px);
        }
        a{
            color:#F4EEF6;
            text-decoration:none;
        }
        a:hover{
            color:#C9B8E8;
        }
        @media(max-width:576px){
            .forgot-card{
                padding:30px 20px;
            }
        }
    </style>
</head>
<body>
<div class="forgot-card">
<div class="logo">
<i class="bi bi-bag-heart-fill"></i>
Lend &amp; Lace
</div>
<div class="sub">
Reset Your Password
</div>
<div class="icon">
<i class="bi bi-envelope-lock-fill"></i>
</div>
<form action="forgotPassword" method="post">
<input type="hidden" name="step" value="request">
<% if (request.getParameter("error") != null && !request.getParameter("error").equals("1") && !request.getParameter("error").equals("db")) { %>
<div class="alert alert-danger text-center py-2">This reset link is invalid, expired or already used. Please request a new one.</div>
<% } %>
<% if (request.getParameter("sent") != null) { %>
<% if (request.getParameter("sent").equals("0")) { %>
<div class="alert alert-warning text-center py-2">
<strong>Email delivery is not configured.</strong> The reset link could not be sent.<br>
To enable it, configure SMTP for the server (host, port, username and app password), e.g.:<br>
<code>-Dmail.smtp.host=smtp.gmail.com -Dmail.smtp.port=587 -Dmail.smtp.user=you@example.com -Dmail.smtp.pass=APP_PASSWORD</code>
</div>
<% } else { %>
<div class="alert alert-success text-center py-2">If that email is registered, a password-reset link has been sent. It expires in 30 minutes and can be used once.</div>
<% } %>
<% } %>
<% String resetToken = request.getParameter("token"); %>
<% if (resetToken != null && !resetToken.isEmpty()) { %>
<!-- STEP 2: set a new password using the emailed single-use token -->
<input type="hidden" name="step" value="reset">
<input type="hidden" name="token" value="<%= resetToken %>">
<% if (request.getParameter("error") != null && request.getParameter("error").equals("1")) { %>
<div class="alert alert-danger text-center py-2">Passwords must be at least 8 characters and must match.</div>
<% } else if (request.getParameter("error") != null && request.getParameter("error").equals("db")) { %>
<div class="alert alert-danger text-center py-2">Could not update the password. Please try again.</div>
<% } %>
<div class="mb-4">
<label class="form-label">New Password</label>
<input type="password" class="form-control" id="newPassword" name="newPassword" placeholder="At least 8 characters" minlength="8" required>
</div>
<div class="mb-4">
<label class="form-label">Confirm New Password</label>
<input type="password" class="form-control" id="confirmPassword" name="confirmPassword" placeholder="Re-enter new password" minlength="8" required>
</div>
<button type="submit" id="resetBtn" class="btn-reset">
<i class="bi bi-key-fill"></i> Set New Password
</button>
<% } else { %>
<!-- STEP 1: identify the account by email -->
<% if (request.getParameter("error") != null && request.getParameter("error").equals("1")) { %>
<div class="alert alert-danger text-center py-2">Please enter your registered email address.</div>
<% } %>
<div class="mb-4">
<label class="form-label">
Email Address
</label>
<input
type="email"
class="form-control"
id="email"
name="email"
placeholder="Enter your registered email"
required>
</div>
<div class="mb-4">
<p class="text-light small">Enter the email address associated with your account to set a new password.</p>
</div>
<button
type="submit"
id="resetBtn"
class="btn-reset">
<i class="bi bi-send-fill"></i>
Continue
</button>
<% } %>
<div class="text-center mt-4">
<a href="login.jsp">
<i class="bi bi-arrow-left-circle"></i>
Back to Login
</a>
</div>
</form>
</div>

<script>
const form=document.querySelector("form");
const btn=document.getElementById("resetBtn");
form.addEventListener("submit",function(){
    btn.disabled=true;
    btn.innerHTML='<span class="spinner-border spinner-border-sm"></span> Sending...';
});
const email=document.getElementById("email");
if (email) email.addEventListener("blur",function(){
    const pattern=/^[^ ]+@[^ ]+\.[a-z]{2,3}$/;
    if(email.value!="" && !pattern.test(email.value)){
        email.classList.add("is-invalid");
    }
    else{
        email.classList.remove("is-invalid");
        email.classList.add("is-valid");
    }
});
</script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>