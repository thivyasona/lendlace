<%@ page import="com.lendlace.model.User" %>
    <% User user=(User) session.getAttribute("loggedUser"); if (user==null) { response.sendRedirect("login.jsp");
        return; } %>

        <head>

            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>My Profile</title>
            <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
            <link rel="stylesheet"
                href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
            <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap"
                rel="stylesheet">
            <style>
                * {
                    margin: 0;
                    padding: 0;
                    box-sizing: border-box;
                    font-family: 'Poppins', sans-serif;
                }

                body {
                    background: #FAF6F0 url('assets/images/dress7.jpg') no-repeat center center fixed;
                    background-size: cover;
                }

                body::before {
                    content: '';
                    position: fixed;
                    inset: 0;
                    background: rgba(250, 246, 240, 0.93);
                    z-index: -1;
                }

                .navbar {
                    background: #33172C;
                }

                .profile-card {
                    background: white;
                    border: none;
                    border-radius: 20px;
                    box-shadow: 0 8px 20px rgba(74, 32, 64, .1);
                    padding: 30px;
                }

                .profile-image {
                    width: 170px;
                    height: 170px;
                    border-radius: 50%;
                    object-fit: cover;
                    border: 5px solid #6B3A5B;
                }

                .info-box {
                    background: #F3EAE0;
                    border-radius: 12px;
                    padding: 15px;
                    margin-bottom: 15px;
                }

                .info-title {
                    font-weight: bold;
                    color: #6B3A5B;
                    margin-bottom: 5px;
                }

                .progress {
                    height: 10px;
                }
            </style>

        </head>

        <body>
            <nav class="navbar navbar-dark">
                <div class="container">
                    <a href="customer-dashboard.jsp" class="navbar-brand">
                        <i class="bi bi-person-circle"></i>
                        My Profile
                    </a>
                </div>
            </nav>
            <div class="container py-5">
                <% if (request.getParameter("success") !=null) { %>
                    <div class="alert alert-success text-center">Profile updated successfully.</div>
                    <% } else if (request.getParameter("error") !=null) { %>
                        <div class="alert alert-danger text-center">Failed to update profile. Please try again.</div>
                        <% } %>
                        <% if (request.getParameter("pwdSuccess") != null) { %>
                            <div class="alert alert-success text-center"><i class="bi bi-check-circle-fill"></i> Password changed successfully. Use your new password next time you log in.</div>
                        <% } else if ("current".equals(request.getParameter("pwdError"))) { %>
                            <div class="alert alert-danger text-center"><i class="bi bi-x-circle-fill"></i> Current password is incorrect.</div>
                        <% } else if ("validate".equals(request.getParameter("pwdError"))) { %>
                            <div class="alert alert-danger text-center"><i class="bi bi-x-circle-fill"></i> Passwords must be at least 8 characters and the confirmation must match.</div>
                        <% } else if ("same".equals(request.getParameter("pwdError"))) { %>
                            <div class="alert alert-danger text-center"><i class="bi bi-x-circle-fill"></i> New password must be different from your current password.</div>
                        <% } else if ("db".equals(request.getParameter("pwdError"))) { %>
                            <div class="alert alert-danger text-center"><i class="bi bi-x-circle-fill"></i> Could not change the password. Please try again.</div>
                        <% } %>
                        <% if (request.getParameter("emailSuccess") != null) { %>
                            <div class="alert alert-success text-center"><i class="bi bi-check-circle-fill"></i> Email address updated successfully.</div>
                        <% } else if ("validate".equals(request.getParameter("emailError"))) { %>
                            <div class="alert alert-danger text-center"><i class="bi bi-x-circle-fill"></i> Please enter a valid email address.</div>
                        <% } else if ("current".equals(request.getParameter("emailError"))) { %>
                            <div class="alert alert-danger text-center"><i class="bi bi-x-circle-fill"></i> Your current password was incorrect. Email not changed.</div>
                        <% } else if ("duplicate".equals(request.getParameter("emailError"))) { %>
                            <div class="alert alert-warning text-center"><i class="bi bi-exclamation-triangle"></i> That email is already registered to another account.</div>
                        <% } else if ("same".equals(request.getParameter("emailError"))) { %>
                            <div class="alert alert-info text-center">That is already your email address.</div>
                        <% } else if ("db".equals(request.getParameter("emailError"))) { %>
                            <div class="alert alert-danger text-center"><i class="bi bi-x-circle-fill"></i> Could not update the email. Please try again.</div>
                        <% } %>
                            <div class="profile-card">
                                <div class="row">
                                    <div class="col-lg-4 text-center">
                                        <% String uImg = (user.getProfileImage() == null || user.getProfileImage().isEmpty()) ? "assets/images/default-user.png" : user.getProfileImage(); %>
                                        <img
                                        src="<%= uImg %>"
                                        class="profile-image">
                                        <h3 class="mt-3">
                                            <%= user.getFullName() %>
                                        </h3>
                                        <p>
                                            <%= user.getRole() %>
                                        </p>
                                        <div class="progress mt-4">
                                            <div class="progress-bar bg-success" style="width:100%"></div>
                                        </div>
                                        <p class="mt-2">Profile Completed 100%</p>
                                    </div>
                                    <div class="col-lg-8">
                                        <h3 class="mb-4">Personal Information</h3>
                                        <div class="info-box">
                                            <div class="info-title">Full Name</div>
                                            <p id="profileName">
                                                <%= user.getFullName() %>
                                            </p>
                                        </div>
                                        <div class="info-box">
                                            <div class="info-title">Email Address</div>
                                            <p id="profileEmail">
                                                <%= user.getEmail() %>
                                            </p>
                                        </div>
                                        <div class="info-box">
                                            <div class="info-title">Mobile Number</div>
                                            <p id="profileMobile">
                                                <%= user.getPhone()==null || user.getPhone().isEmpty() ? "-" :
                                                    user.getPhone() %>
                                            </p>
                                        </div>
                                        <div class="info-box">
                                            <div class="info-title">Role</div>
                                            <p id="profileRole">
                                                <%= user.getRole() %>
                                            </p>
                                        </div>
                                        <h3 class="mt-4 mb-4">Address Information</h3>
                                        <div class="info-box">
                                            <div class="info-title">Address</div>
                                            <p id="profileAddress">
                                                <%= user.getAddress()==null || user.getAddress().isEmpty() ? "-" :
                                                    user.getAddress() %>
                                            </p>
                                        </div>
                                        <div class="d-grid gap-3 mt-4">
                                            <button class="btn btn-primary" onclick="enableEdit()">
                                                <i class="bi bi-pencil-square"></i>
                                                Edit Profile
                                            </button>
                                            <button class="btn btn-success mt-2" id="saveBtn" onclick="saveProfile()"
                                                style="display:none;">
                                                <i class="bi bi-check-circle-fill"></i>
                                                Save Changes
                                            </button>
                                            <a href="#changePassword" class="btn btn-warning mt-2">
                                                <i class="bi bi-key-fill"></i>
                                                Change Password
                                            </a>
                                            <a href="logout" class="btn btn-danger">
                                                <i class="bi bi-box-arrow-right"></i>
                                                Logout
                                            </a>
                                        </div>

                                        <!-- ================= CHANGE PASSWORD ================= -->
                                        <h3 id="changePassword" class="mt-4 mb-4"><i class="bi bi-shield-lock-fill"></i> Change Password</h3>
                                        <form action="changePassword" method="post" class="info-box">
                                            <div class="mb-3">
                                                <label class="form-label"><i class="bi bi-lock-fill"></i> Current Password</label>
                                                <input type="password" class="form-control" name="currentPassword"
                                                    placeholder="Enter your current password" required>
                                            </div>
                                            <div class="mb-3">
                                                <label class="form-label"><i class="bi bi-key-fill"></i> New Password</label>
                                                <input type="password" class="form-control" name="newPassword"
                                                    placeholder="At least 8 characters" minlength="8" required>
                                            </div>
                                            <div class="mb-3">
                                                <label class="form-label"><i class="bi bi-key-fill"></i> Confirm New Password</label>
                                                <input type="password" class="form-control" name="confirmPassword"
                                                    placeholder="Re-enter the new password" minlength="8" required>
                                            </div>
                                            <button type="submit" class="btn btn-primary">
                                                <i class="bi bi-check2-circle"></i> Update Password
                                            </button>
                                        </form>

                                        <!-- ================= CHANGE EMAIL ================= -->
                                        <h3 id="changeEmail" class="mt-4 mb-4"><i class="bi bi-envelope-fill"></i> Change Email Address</h3>
                                        <form action="changeEmail" method="post" class="info-box">
                                            <div class="mb-3">
                                                <label class="form-label"><i class="bi bi-envelope-fill"></i> New Email Address</label>
                                                <input type="email" class="form-control" name="newEmail"
                                                    placeholder="Enter the new email address" required>
                                            </div>
                                            <div class="mb-3">
                                                <label class="form-label"><i class="bi bi-lock-fill"></i> Confirm with Current Password</label>
                                                <input type="password" class="form-control" name="currentPassword"
                                                    placeholder="Enter your current password" required>
                                            </div>
                                            <button type="submit" class="btn btn-primary">
                                                <i class="bi bi-check2-circle"></i> Update Email
                                            </button>
                                        </form>
                                    </div>
                                </div>
                            </div>
            </div>

            <script>
                function enableEdit() {
                    document.getElementById("profileName").contentEditable = "true";
                    document.getElementById("profileMobile").contentEditable = "true";
                    document.getElementById("profileAddress").contentEditable = "true";
                    document.getElementById("saveBtn").style.display = "block";
                }
                // Saves profile changes to MySQL via the /updateProfile servlet
                function saveProfile() {
                    const form = document.createElement("form");
                    form.method = "post";
                    form.action = "updateProfile";

                    const f = document.createElement("input");
                    f.type = "hidden"; f.name = "fullName";
                    f.value = document.getElementById("profileName").innerText.trim();
                    form.appendChild(f);

                    const p = document.createElement("input");
                    p.type = "hidden"; p.name = "phone";
                    p.value = document.getElementById("profileMobile").innerText.trim();
                    form.appendChild(p);

                    const a = document.createElement("input");
                    a.type = "hidden"; a.name = "address";
                    a.value = document.getElementById("profileAddress").innerText.trim();
                    form.appendChild(a);

                    document.body.appendChild(form);
                    form.submit();
                }
            </script>
            <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        </body>

        </html>