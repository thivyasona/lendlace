<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login | Lend &amp; Lace Dress Rental</title>
    <!-- Bootstrap -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
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
        }
        .login-card{
            width:100%;
            max-width:470px;
            background:rgba(58,26,50,.55);
            backdrop-filter:blur(20px);
            border-radius:20px;
            padding:40px;
            color:white;
            border:1px solid rgba(237,231,246,.25);
            box-shadow:0 10px 40px rgba(0,0,0,.4);
        }
        .logo{
            font-family:'Playfair Display',serif;
            font-size:32px;
            font-weight:bold;
            text-align:center;
            margin-bottom:10px;
        }
        .sub{
            text-align:center;
            margin-bottom:30px;
            color:#eee;
        }
        .form-control,
        .form-select{
            border-radius:12px;
            height:50px;
        }
        .input-group-text{
            border-radius:12px 0 0 12px;
        }
        .btn-login{
            width:100%;
            height:50px;
            background:#6B3A5B;
            color:white;
            border:none;
            border-radius:12px;
            font-size:18px;
            font-weight:600;
            transition:.3s;
        }
        .btn-login:hover{
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
        .divider::before,
        .divider::after{
            content:"";
            flex:1;
            height:1px;
            background:rgba(244,238,246,.4);
        }
        .divider span{
            margin:0 10px;
        }
    .social{
        gap:12px;
    }
        @media(max-width:576px){
            .login-card{
                margin:20px;
                padding:30px 20px;
            }
        }
    </style>
</head>
<body>
<div class="login-card">
    <div class="logo">
        <i class="bi bi-bag-heart-fill"></i>
        Lend &amp; Lace
    </div>
    <div class="sub">
        Welcome Back
    </div>
    <% if (request.getParameter("success") != null) { %>
    <div class="alert alert-success text-center py-2">Account created! Please login.</div>
    <% } else if (request.getParameter("reset") != null) { %>
    <div class="alert alert-success text-center py-2">Password updated! Please login with your new password.</div>
    <% } else if (request.getParameter("role") != null) { %>
    <div class="alert alert-danger text-center py-2">The selected account role does not match your account. Please choose the correct role.</div>
    <% } else if (request.getParameter("suspended") != null) { %>
    <div class="alert alert-warning text-center py-2">This account has been suspended by the administrator. Please contact support if you believe this is an error.</div>
    <% } else if (request.getParameter("error") != null) { %>
    <div class="alert alert-danger text-center py-2">Invalid email or password.</div>
    <% } %>
    <form action="login" method="post">
        <!-- Role selection -->
        <div class="mb-3">
            <label class="form-label">Login As</label>
            <select class="form-select" name="role" required>
                <option value="CUSTOMER" selected>Login as Customer</option>
                <option value="OWNER">Login as Owner</option>
                <option value="ADMIN">Login as Admin</option>
            </select>
        </div>
        <!-- Email -->
        <div class="mb-3">
            <label class="form-label">
                Email Address
            </label>
            <input
             type="email"
             id="email"
             class="form-control"
            name="email"
             placeholder="Enter Email"
             required>
        </div>
        <!-- Password -->
        <div class="mb-3">
            <label class="form-label">
                Password
            </label>
            <div class="input-group">
                <input
                        type="password"
                        id="password"
                        class="form-control"
                        name="password"
                        placeholder="Enter Password"
                        required>
                <button
                        class="btn btn-light"
                        type="button"
                        onclick="togglePassword()">
                    <i id="eye"
                       class="bi bi-eye"></i>
                </button>
            </div>
        </div>
        <div class="d-flex justify-content-between mb-3">
            <div>
                <input
                        type="checkbox"
                        class="form-check-input">
                Remember Me
            </div>
            <a href="password.jsp">
                Forgot Password?
            </a>
        </div>
        <button
         type="submit"
        class="btn-login">
        Login
        </button>
        <div class="divider">
            <span>
                OR
            </span>
        </div>
        <div class="social d-flex justify-content-between">
            <a class="btn btn-outline-danger w-100"
               href="register.jsp">
                <i class="bi bi-person-plus"></i>
                Create a New Account
            </a>
        </div>
        <p class="text-center mt-4">
            Don't have an account?
            <a href="register.jsp">
                Register
            </a>
        </p>
    </form>
</div>
<script>
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
</script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>