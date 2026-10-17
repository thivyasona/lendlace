<%@ page import="com.lendlace.model.User" %>
    <% User owner=(User) session.getAttribute("loggedUser"); if (owner==null ||
        !"OWNER".equalsIgnoreCase(owner.getRole())) { response.sendRedirect("login.jsp"); return; } %>
        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Owner Profile</title>
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
                    background: #FAF6F0 url('assets/images/dress6.jpg') no-repeat center center fixed;
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
                    border-radius: 20px;
                    box-shadow: 0 8px 20px rgba(74, 32, 64, .1);
                    padding: 40px;
                }

                .profile-img {
                    width: 140px;
                    height: 140px;
                    border-radius: 50%;
                    object-fit: cover;
                    border: 5px solid #6B3A5B;
                }
            </style>
        </head>

        <body>
            <nav class="navbar navbar-dark">
                <div class="container">
                    <a href="owner-dashboard.jsp" class="navbar-brand">
                        <i class="bi bi-person-circle"></i>
                        Owner Profile
                    </a>
                </div>
            </nav>
            <div class="container py-5">
                <% if (request.getParameter("success") !=null) { %>
                    <div class="alert alert-success text-center">Profile updated successfully.</div>
                    <% } else if (request.getParameter("error") !=null) { %>
                        <div class="alert alert-danger text-center">Failed to update profile.</div>
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
                            <div class="row justify-content-center">
                                <div class="col-lg-8">
                                    <div class="profile-card">
                                        <div class="text-center mb-4">
                                            <% String oImg = (owner.getProfileImage() == null || owner.getProfileImage().isEmpty()) ? "assets/images/default-user.png" : owner.getProfileImage(); %>
                                            <img
                                            id="profileImage"
                                            src="<%= oImg %>"
                                            class="profile-img">
                                            <h2 class="mt-3">
                                                <%= owner.getFullName() %>
                                            </h2>
                                            <p class="text-muted">Dress Owner</p>
                                        </div>
                                        <form action="updateProfile" method="post" enctype="multipart/form-data">
                                            <div class="row">
                                                <div class="col-md-6 mb-3">
                                                    <label class="form-label">Full Name</label>
                                                    <input type="text" class="form-control" name="fullName"
                                                        value="<%= owner.getFullName() %>" required>
                                                </div>
                                                <div class="col-md-6 mb-3">
                                                    <label class="form-label">Email (read-only)</label>
                                                    <input type="email" class="form-control"
                                                        value="<%= owner.getEmail() %>" readonly>
                                                </div>
                                                <div class="col-md-6 mb-3">
                                                    <label class="form-label">Phone</label>
                                                    <input type="text" class="form-control" name="phone"
                                                        value="<%= owner.getPhone() == null ? "" : owner.getPhone() %>">
                                                </div>
                                                <div class="col-md-6 mb-3">
                                                    <label class="form-label">Profile Photo</label>
                                                    <input type="file" class="form-control" id="photo"
                                                        name="profileImage" accept="image/*">
                                                </div>
                                                <div class="col-12 mb-3">
                                                    <label class="form-label">
                                                        Address
                                                    </label>
                                                    <textarea class="form-control" rows="3"
                                                        name="address"><%= owner.getAddress() == null ? "" : owner.getAddress() %></textarea>
                                                </div>
                                            </div>
                                            <div class="text-center">
                                                <button type="submit" class="btn btn-success">
                                                    Save Changes
                                                </button>
                                                <a href="owner-dashboard.jsp" class="btn btn-primary ms-2">
                                                    Back
                                                </a>
                                            </div>
                                        </form>

                                        <!-- ================= CHANGE PASSWORD ================= -->
                                        <h3 id="changePassword" class="mt-4 mb-4"><i class="bi bi-shield-lock-fill"></i> Change Password</h3>
                                        <form action="changePassword" method="post" class="profile-card p-0 border-0 bg-transparent shadow-none">
                                            <div class="row">
                                                <div class="col-md-4 mb-3">
                                                    <label class="form-label"><i class="bi bi-lock-fill"></i> Current Password</label>
                                                    <input type="password" class="form-control" name="currentPassword"
                                                        placeholder="Enter your current password" required>
                                                </div>
                                                <div class="col-md-4 mb-3">
                                                    <label class="form-label"><i class="bi bi-key-fill"></i> New Password</label>
                                                    <input type="password" class="form-control" name="newPassword"
                                                        placeholder="At least 8 characters" minlength="8" required>
                                                </div>
                                                <div class="col-md-4 mb-3">
                                                    <label class="form-label"><i class="bi bi-key-fill"></i> Confirm New Password</label>
                                                    <input type="password" class="form-control" name="confirmPassword"
                                                        placeholder="Re-enter the new password" minlength="8" required>
                                                </div>
                                            </div>
                                            <div class="text-center">
                                                <button type="submit" class="btn btn-success">
                                                    <i class="bi bi-check2-circle"></i> Update Password
                                                </button>
                                            </div>
                                        </form>

                                        <!-- ================= CHANGE EMAIL ================= -->
                                        <h3 id="changeEmail" class="mt-4 mb-4"><i class="bi bi-envelope-fill"></i> Change Email Address</h3>
                                        <form action="changeEmail" method="post">
                                            <div class="row">
                                                <div class="col-md-6 mb-3">
                                                    <label class="form-label"><i class="bi bi-envelope-fill"></i> New Email Address</label>
                                                    <input type="email" class="form-control" name="newEmail"
                                                        placeholder="Enter the new email address" required>
                                                </div>
                                                <div class="col-md-6 mb-3">
                                                    <label class="form-label"><i class="bi bi-lock-fill"></i> Confirm with Current Password</label>
                                                    <input type="password" class="form-control" name="currentPassword"
                                                        placeholder="Enter your current password" required>
                                                </div>
                                            </div>
                                            <div class="text-center">
                                                <button type="submit" class="btn btn-success">
                                                    <i class="bi bi-check2-circle"></i> Update Email
                                                </button>
                                            </div>
                                        </form>
                                    </div>
                                </div>
                            </div>
            </div>
            <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3/dist/js/bootstrap.bundle.min.js"></script>
        </body>

        </html>