<%@ page import="java.util.List" %>
<%@ page import="com.lendlace.dao.UserDAO" %>
<%@ page import="com.lendlace.model.User" %>
<%
User adminUser = (User) session.getAttribute("loggedUser");
if (adminUser == null || !"ADMIN".equalsIgnoreCase(adminUser.getRole())) {
    response.sendRedirect("login.jsp");
    return;
}
UserDAO userDAO = new UserDAO();
List<User> allAccounts = new java.util.ArrayList<>();
allAccounts.addAll(userDAO.getUsersByRole("ADMIN"));
allAccounts.addAll(userDAO.getUsersByRole("OWNER"));
allAccounts.addAll(userDAO.getUsersByRole("CUSTOMER"));
String resetResult = request.getParameter("resetResult");
String resetError  = request.getParameter("resetError");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Manage Accounts | Lend &amp; Lace Admin</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
<style>
body{background:#FAF6F0;font-family:Poppins,sans-serif;}
.navbar{background:#33172C;}
h2{color:#4A2040;font-family:'Playfair Display',serif;}
.table thead{background:#33172C;color:#fff;}
.card{border:none;border-radius:15px;box-shadow:0 5px 15px rgba(74,32,64,.1);background:#fff;}
.reset-form{background:#F3EAE0;border-radius:12px;padding:16px;margin-top:10px;}
details summary{cursor:pointer;font-weight:600;color:#6B3A5B;}
</style>
</head>
<body>
<nav class="navbar navbar-dark py-3"><div class="container">
<a class="navbar-brand" href="admin-dashboard.jsp"><i class="bi bi-arrow-left-circle"></i> Back to Dashboard</a>
</div></nav>
<div class="container py-4">
<h2 class="mb-2"><i class="bi bi-people-fill"></i> Manage Accounts</h2>
<p class="text-muted mb-4">Reset an account password or email. Every reset requires your own admin password and is written to the audit log. Roles are never changed here and accounts are never deleted.</p>
<% if ("success".equals(resetResult)) { %>
<div class="alert alert-success"><i class="bi bi-check-circle-fill"></i> Credential updated and logged in the audit trail.</div>
<% } else if ("db".equals(resetResult)) { %>
<div class="alert alert-danger"><i class="bi bi-x-circle-fill"></i> Database update failed. Please try again.</div>
<% } %>
<% if ("auth".equals(resetError)) { %>
<div class="alert alert-danger"><i class="bi bi-shield-exclamation"></i> Your admin password was incorrect. No change was made.</div>
<% } else if ("validate".equals(resetError)) { %>
<div class="alert alert-warning">Invalid input: passwords must be 8+ characters and match; emails must be valid.</div>
<% } else if ("duplicate".equals(resetError)) { %>
<div class="alert alert-warning"><i class="bi bi-exclamation-triangle"></i> That email is already used by another account.</div>
<% } else if ("same".equals(resetError)) { %>
<div class="alert alert-info">The new email is the same as the current one.</div>
<% } else if ("notfound".equals(resetError)) { %>
<div class="alert alert-danger">Target account not found.</div>
<% } %>
<div class="card p-4">
<div class="table-responsive">
<table class="table table-bordered table-hover align-middle">
<thead><tr><th>ID</th><th>Name</th><th>Email</th><th>Role</th><th>Status</th><th>Credential Reset</th></tr></thead>
<tbody>
<%
for (User u : allAccounts) {
    String role = u.getRole() == null ? "" : u.getRole().toUpperCase();
    String badge = "ADMIN".equals(role) ? "bg-dark" : ("OWNER".equals(role) ? "bg-secondary" : "bg-light text-dark");
%>
<tr>
<td><%= u.getUserId() %></td>
<td><%= u.getFullName() %></td>
<td><%= u.getEmail() %></td>
<td><span class="badge <%= badge %>"><%= u.getRole() %></span></td>
<td><span class="badge bg-success">Active</span></td>
<td>
<details>
<summary><i class="bi bi-key-fill"></i> Reset credentials</summary>
<div class="reset-form">
<form action="adminCredentialReset" method="post">
<input type="hidden" name="targetUserId" value="<%= u.getUserId() %>">
<div class="row g-2">
<div class="col-md-3">
<label class="form-label small">Action</label>
<select class="form-select" name="resetAction" id="act<%= u.getUserId() %>">
<option value="password">Reset Password</option>
<option value="email">Change Email</option>
</select>
</div>
<div class="col-md-4">
<label class="form-label small">Your admin password</label>
<input type="password" class="form-control" name="adminPassword" required>
</div>
<div class="col-md-5">
<div id="pw<%= u.getUserId() %>">
<label class="form-label small">New password</label>
<input type="password" class="form-control mb-1" name="newPassword" placeholder="Min 8 chars" minlength="8">
<input type="password" class="form-control" name="confirmPassword" placeholder="Confirm password" minlength="8">
</div>
<div id="em<%= u.getUserId() %>" style="display:none;">
<label class="form-label small">New email</label>
<input type="email" class="form-control" name="newEmail" placeholder="new@email.com">
</div>
</div>
</div>
<button type="submit" class="btn btn-primary btn-sm mt-2"><i class="bi bi-check2-circle"></i> Apply Reset</button>
</form>
<small class="text-muted d-block mt-2">This action is recorded in the credential audit log.</small>
</div>
</details>
</td>
</tr>
<% } %>
</tbody>
</table>
</div>
</div>
<div class="card p-4 mt-4">
<h5><i class="bi bi-clock-history"></i> Recent Credential Changes</h5>
<div class="table-responsive">
<table class="table table-sm table-striped mb-0">
<thead><tr><th>When</th><th>User</th><th>Actor</th><th>Action</th><th>Detail</th></tr></thead>
<tbody>
<%
java.util.List<String[]> auditRows = new java.util.ArrayList<>();
java.sql.Connection con = null;
java.sql.PreparedStatement ps = null;
java.sql.ResultSet rs = null;
try {
    con = com.lendlace.util.DBConnection.getConnection();
    String sql = "SELECT created_at, target_user, actor, action, detail";
    sql += " FROM credential_audit_log ORDER BY audit_id DESC LIMIT 10";
    ps = con.prepareStatement(sql);
    rs = ps.executeQuery();
    while (rs.next()) {
        String[] row = new String[5];
        row[0] = String.valueOf(rs.getTimestamp("created_at"));
        row[1] = "#" + rs.getInt("target_user");
        row[2] = rs.getString("actor");
        row[3] = rs.getString("action");
        String d = rs.getString("detail");
        row[4] = d == null ? "" : d;
        auditRows.add(row);
    }
} catch (Exception e) {
    e.printStackTrace();
} finally {
    try { if (rs != null) rs.close(); } catch (Exception x) {}
    try { if (ps != null) ps.close(); } catch (Exception x) {}
    try { if (con != null) con.close(); } catch (Exception x) {}
}
if (auditRows.isEmpty()) {
%>
<tr><td colspan="5" class="text-center text-muted">No credential changes recorded yet.</td></tr>
<% } %>
<% for (String[] r : auditRows) { %>
<tr><td><%= r[0] %></td><td><%= r[1] %></td><td><%= r[2] %></td><td><span class="badge bg-secondary"><%= r[3] %></span></td><td><%= r[4] %></td></tr>
<% } %>
</tbody>
</table>
</div>
</div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
document.querySelectorAll("select[name='resetAction']").forEach(function(sel){
    var uid = sel.id.replace("act","");
    var pw = document.getElementById("pw"+uid);
    var em = document.getElementById("em"+uid);
    function sync(){
        var isPwd = sel.value === "password";
        pw.style.display = isPwd ? "" : "none";
        em.style.display = isPwd ? "none" : "";
        pw.querySelectorAll("input").forEach(function(i){ i.required = isPwd; });
        em.querySelector("input").required = !isPwd;
    }
    sel.addEventListener("change", sync);
    sync();
});
</script>
</body>
</html>
