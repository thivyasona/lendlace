<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">
    <title>Register | Lend &amp; Lace Dress Rental</title>
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
            url("assets/images/register-bg.jpg");
            background-size:cover;
            background-position:center;
            background-attachment:fixed;
            display:flex;
            justify-content:center;
            align-items:center;
            padding:40px 15px;
        }
        .register-card{
            width:100%;
            max-width:750px;
            background:rgba(255,255,255,.96);
            border-radius:20px;
            padding:40px;
            color:var(--ll-ink,#2E2233);
            border:1px solid rgba(201,184,232,.5);
            box-shadow:0 10px 40px rgba(0,0,0,.40);
        }
        .logo{
            font-family:'Playfair Display',serif;
            text-align:center;
            font-size:32px;
            font-weight:bold;
            margin-bottom:10px;
            color:#4A2040;
        }
        .sub{
            text-align:center;
            color:#7A6B80;
            margin-bottom:30px;
        }
        .section-title{
            font-size:20px;
            font-weight:600;
            margin-top:25px;
            margin-bottom:20px;
            color:#6B3A5B;
            border-bottom:2px solid #EDE7F6;
            padding-bottom:8px;
        }
        .form-control,
        .form-select{
            height:50px;
            border-radius:12px;
        }
        textarea.form-control{
            height:110px;
            resize:none;
        }
        .profile-preview{
            width:130px;
            height:130px;
            border-radius:50%;
            object-fit:cover;
            border:4px solid #C9B8E8;
            display:block;
            margin:auto;
            background:#EDE7F6;
        }
        .btn-register{
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
        .btn-register:hover{
            background:#4A2040;
            transform:translateY(-2px);

        }
        .required{
            color:#A8446A;
        }
        .error{
            color:#8A5A2B;
            font-size:13px;
        }
        a{
            color:#4A2040;
            text-decoration:underline;
        }
        a:hover{
            color:#6B3A5B;
        }
        @media(max-width:576px){
            .register-card{
                padding:25px;
            }
        }
    </style>
</head>

<body>
<% String regErr = request.getParameter("error"); %>
<div class="register-card">
<div class="logo">
<i class="bi bi-bag-heart-fill"></i>
Lend &amp; Lace
</div>
<div class="sub">
Create Your Account
</div>
<% if ("email".equals(regErr)) { %>
<div class="alert alert-danger text-center py-2">This email is already registered. Please login or use another email.</div>
<% } else if ("admin".equals(regErr)) { %>
<div class="alert alert-danger text-center py-2">Admin accounts cannot be created from this page.</div>
<% } else if (regErr != null) { %>
<div class="alert alert-danger text-center py-2">Registration failed. Please try again.</div>
<% } %>
<form action="register"
      method="post"
      enctype="multipart/form-data">
<!-- ROLE -->
<div class="mb-4">
    <label class="form-label">
        Register As
    </label>
    <select class="form-select" name="role" required>
        <option value="">Select Role</option>
        <option value="CUSTOMER">Customer</option>
        <option value="OWNER">Dress Owner</option>
    </select>
</div>
<!-- PROFILE PHOTO -->
<div class="text-center mb-4">
<img
src="assets/images/default-user.png"
id="preview"
class="profile-preview">
<div class="mt-3">
<input
type="file"
class="form-control"
id="profileImage"
name="profileImage"
accept="image/*">
</div>
</div>
<!-- PERSONAL DETAILS -->
<h5 class="section-title">Personal Information</h5>
<div class="row">
<div class="col-md-6 mb-3">
<label>
Full Name
<span class="required">*</span>
</label>
<input
type="text"
class="form-control"
name="fullName"
placeholder="Enter Full Name"
required>
</div>
<div class="col-md-6 mb-3">
<label>
Email Address
<span class="required">*</span>
</label>
<input
type="email"
class="form-control"
name="email"
placeholder="Enter Email"
required>
</div>
<div class="col-md-6 mb-3">
<label>
Mobile Number
<span class="required">*</span>
</label>
<input
type="tel"
class="form-control"
name="phone"
maxlength="10"
placeholder="Enter Mobile Number"
required>
</div>
<div class="col-md-6 mb-3">
<label>
Gender
</label>
<select
class="form-select"
name="gender">
<option value="">Select Gender</option>
<option>Female</option>
<option>Male</option>
<option>Other</option>
</select>
</div>
<!-- ======================
        ADDRESS
======================= -->
<h5 class="section-title">Address Information</h5>
<div class="row">
<div class="col-12 mb-3">
<label>
Complete Address
<span class="required">*</span>
</label>
<textarea
class="form-control"
name="address"
placeholder="House No, Street, Area"
required>
</textarea>
</div>
<div class="col-md-4 mb-3">
<label>
City
<span class="required">*</span>
</label>
<input
type="text"
class="form-control"
name="city"
placeholder="Enter City"
required>
</div>
<div class="col-md-4 mb-3">
<label>
State
<span class="required">*</span>
</label>
<input
type="text"
class="form-control"
name="state"
placeholder="Enter State"
required>
</div>
<div class="col-md-4 mb-3">
<label>
Pincode
<span class="required">*</span>
</label>
<input
type="text"
class="form-control"
name="pincode"
maxlength="6"
placeholder="Enter Pincode"
required>
</div>
</div>
<!-- ======================
        PASSWORD
======================= -->
<h5 class="section-title">
Security
</h5>
<div class="row">
<div class="col-md-6 mb-3">
<label>
Password
<span class="required">*</span>
</label>
<div class="input-group">
<input
type="password"
class="form-control"
id="password"
name="password"
placeholder="Create Password"
required>
<button
type="button"
class="btn btn-light"
onclick="togglePassword()">
<i
id="eye"
class="bi bi-eye">
</i>
</button>
</div>
<div
class="progress mt-2"
style="height:8px;">
<div
id="strength"
class="progress-bar bg-danger"
style="width:0%;">
</div>
</div>
<small
id="strengthText"
class="text-muted">
Password Strength
</small>
</div>
<div class="col-md-6 mb-3">
<label>
Confirm Password
<span class="required">*</span>
</label>
<div class="input-group">
<input
type="password"
class="form-control"
id="confirmPassword"
name="confirmPassword"
placeholder="Confirm Password"
required>
<button
type="button"
class="btn btn-light"
onclick="toggleConfirmPassword()">
<i

id="eye2"
class="bi bi-eye">
</i>
</button>
</div>
<small
id="match"
class="error">
</small>
</div>
</div>
<!-- ======================
        TERMS
======================= -->
<div class="form-check mt-3 mb-4">
<input
type="checkbox"
class="form-check-input"
required>
<label class="form-check-label">
I agree to the
<a href="terms.jsp">
Terms & Conditions
</a>
and
<a href="privacy.jsp">
Privacy Policy
</a>
</label>
</div>
<button
type="submit"
class="btn-register">
<i class="bi bi-person-plus-fill"></i>
Create Account
</button>
<p class="text-center mt-4">
Already have an account?
<a href="login.jsp">Login</a>
</p>
</form>
</div>

<script>
const profileImage=document.getElementById("profileImage");
const preview=document.getElementById("preview");
profileImage.addEventListener("change",function(){
    const file=this.files[0];
    if(file){
        const reader=new FileReader();
        reader.onload=function(e){
            preview.src=e.target.result;
        }
        reader.readAsDataURL(file);
    }
});
/* =========================
      Show Password
========================= */
function togglePassword(){
    const password=document.getElementById("password");
    const eye=document.getElementById("eye");
    if(password.type==="password"){
        password.type="text";
        eye.classList.remove("bi-eye");
        eye.classList.add("bi-eye-slash");
    }
    else{
        password.type="password";
        eye.classList.remove("bi-eye-slash");
        eye.classList.add("bi-eye");
    }
}
/* =========================
      Confirm Password
========================= */
function toggleConfirmPassword(){
    const password=document.getElementById("confirmPassword");
    const eye=document.getElementById("eye2");
    if(password.type==="password"){
        password.type="text";
        eye.classList.remove("bi-eye");
        eye.classList.add("bi-eye-slash");
    }
    else{
        password.type="password";
        eye.classList.remove("bi-eye-slash");
        eye.classList.add("bi-eye");
    }
}
/* =========================
   Password Strength Meter
========================= */
const pass=document.getElementById("password");
const bar=document.getElementById("strength");
const text=document.getElementById("strengthText");
pass.addEventListener("keyup",function(){
    let value=pass.value.length;
    if(value<=4){
        bar.style.width="25%";
        bar.className="progress-bar bg-danger";
        text.innerHTML="Weak Password";
    }
    else if(value<=7){
        bar.style.width="55%";
        bar.className="progress-bar bg-warning";
        text.innerHTML="Medium Password";
    }
    else if(value<=10){
        bar.style.width="80%";
        bar.className="progress-bar bg-info";
        text.innerHTML="Strong Password";
    }
    else{
        bar.style.width="100%";
        bar.className="progress-bar bg-success";
        text.innerHTML="Very Strong Password";
    }
});
/* =========================
   Confirm Password Match
========================= */

const confirmPassword=document.getElementById("confirmPassword");
confirmPassword.addEventListener("keyup",function(){

    const message=document.getElementById("match");
    if(confirmPassword.value===pass.value){
        message.style.color="#2E7D32";
        message.innerHTML='Passwords Match';
    }
    else{
        message.style.color="#A8446A";
        message.innerHTML='Passwords Do Not Match';
    }
});
</script>
<script>
// Registration is handled server-side by /register (MySQL).
// Only client-side validation lives here.
document.querySelector("form").addEventListener("submit", function(e){
    const pass = document.getElementById("password").value;
    const confirmPass = document.getElementById("confirmPassword").value;
    if (pass !== confirmPass) {
        e.preventDefault();
        alert("Passwords do not match");
        return;
    }
});
</script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>