﻿<%@ page import="java.util.List" %>
<%@ page import="com.lendlace.dao.CustomerDAO" %>
<%@ page import="com.lendlace.model.Booking" %>
<%@ page import="com.lendlace.model.User" %>
<%
    String custQ = (String) request.getAttribute("custQ");
    String custStatus = (String) request.getAttribute("custStatus");
    String custSort = (String) request.getAttribute("custSort");
    String custMsg = request.getParameter("custMsg");
    java.util.List<CustomerDAO.CustomerRow> customerRows =
            (java.util.List<CustomerDAO.CustomerRow>) request.getAttribute("customerRows");
    User viewCustomer = (User) request.getAttribute("viewCustomer");
    List<Booking> viewHistory = (List<Booking>) request.getAttribute("viewHistory");
    String viewStatus = (String) request.getAttribute("viewStatus");
    CustomerDAO.BookingCounts viewCounts =
            (CustomerDAO.BookingCounts) request.getAttribute("viewCounts");
    CustomerDAO custDAO = new CustomerDAO();

    String stateQ = (custQ != null && !custQ.isEmpty()
            ? "&q=" + java.net.URLEncoder.encode(custQ, "UTF-8") : "")
            + (custStatus != null && !custStatus.isEmpty() ? "&status=" + custStatus : "")
            + (custSort != null ? "&sort=" + custSort : "");
    String dash = "&#8212;";
%>
<style>
.cust-searchbar .form-control, .cust-searchbar .form-select { border-color:#D8C4D2; }
.badge-act { background:#2E7D32; }
.badge-susp { background:#C62828; }
.cust-actions .btn { margin-right:4px; margin-bottom:4px; }
.view-detail-card { background:#fff; border-radius:14px; box-shadow:0 4px 12px rgba(74,32,64,.10); }
</style>
<%
    if (custMsg != null) {
        String m;
        String cls = "alert-success";
        switch (custMsg) {
            case "suspended": m = "Customer account suspended. Their session was ended and new logins are blocked."; break;
            case "reactivated": m = "Customer account reactivated. They can log in and book again."; break;
            case "deleted": m = "Customer account deleted (no booking history existed)."; break;
            case "deleteblocked": cls = "alert-warning"; m = "Deletion blocked: this customer has booking or payment history. Use Deactivate Account instead to preserve the records."; break;
            case "self": cls = "alert-warning"; m = "You cannot modify your own administrator account here."; break;
            case "failed": cls = "alert-danger"; m = "Action failed. Please try again."; break;
            default: cls = "alert-danger"; m = "Invalid request.";
        }
%>
<div class="alert <%= cls %> text-center"><%= m %></div>
<% } %>
<form method="get" action="adminCustomer" class="cust-searchbar row g-2 align-items-end mb-3">
<div class="col-md-4">
<label class="form-label mb-1 small">Search name or email</label>
<input type="text" name="q" class="form-control" value="<%= custQ == null ? "" : custQ %>" placeholder="e.g. Thivya or @gmail.com">
</div>
<div class="col-md-3">
<label class="form-label mb-1 small">Status</label>
<select name="status" class="form-select">
<option value="" <%= custStatus == null || custStatus.isEmpty() ? "selected" : "" %>>All</option>
<option value="ACTIVE" <%= "ACTIVE".equalsIgnoreCase(custStatus) ? "selected" : "" %>>Active</option>
<option value="SUSPENDED" <%= "SUSPENDED".equalsIgnoreCase(custStatus) ? "selected" : "" %>>Suspended</option>
</select>
</div>
<div class="col-md-3">
<label class="form-label mb-1 small">Sort by</label>
<select name="sort" class="form-select">
<option value="registered" <%= custSort == null || "registered".equals(custSort) ? "selected" : "" %>>Registration date</option>
<option value="bookings" <%= "bookings".equals(custSort) ? "selected" : "" %>>Booking count</option>
</select>
</div>
<div class="col-md-2 d-flex gap-2">
<button type="submit" class="btn btn-primary btn-sm px-3" style="background:#4A2040;border-color:#4A2040;"><i class="bi bi-search"></i></button>
<a href="adminCustomer" class="btn btn-outline-secondary btn-sm px-3" title="Clear search and filters"><i class="bi bi-x-circle"></i></a>
</div>
</form>
<% if (customerRows == null || customerRows.isEmpty()) { %>
<p class="text-center text-muted"><i class="bi bi-inbox"></i> No customers match the current search or filters.</p>
<% } else { %>
<div class="table-responsive">
<table class="table table-bordered table-hover align-middle">
<thead class="table-dark">
<tr><th>ID</th><th>Name</th><th>Email</th><th>Phone</th><th>Registered</th><th>Status</th><th>Bookings</th><th>Actions</th></tr>
</thead>
<tbody>
<% for (CustomerDAO.CustomerRow row : customerRows) {
       User c = row.user;
       boolean suspended = "SUSPENDED".equalsIgnoreCase(custDAO.getStatus(c.getUserId()));
       String stBadge = suspended ? "badge-susp" : "badge-act";
       String stText = suspended ? "Suspended" : "Active"; %>
<tr>
<td><%= c.getUserId() %></td>
<td><%= c.getFullName() %></td>
<td><%= c.getEmail() %></td>
<td><%= (c.getPhone() == null || c.getPhone().isEmpty()) ? dash : c.getPhone() %></td>
<td><%= c.getCreatedAt() == null ? dash : c.getCreatedAt() %></td>
<td><span class="badge <%= stBadge %>"><%= stText %></span></td>
<td><%= row.totalBookings %> total / <%= row.completedBookings %> completed</td>
<td class="cust-actions">
<a class="btn btn-outline-primary btn-sm" href="adminCustomer?action=view&customerId=<%= c.getUserId() %><%= stateQ %>#cust-detail"><i class="bi bi-eye"></i> View</a>
<% if (!suspended) { %>
<form action="adminCustomer" method="post" class="d-inline" onsubmit="return confirm('Suspend this customer account? They will be logged out and unable to log in or make new bookings.');">
<input type="hidden" name="customerId" value="<%= c.getUserId() %>">
<input type="hidden" name="action" value="suspend">
<button type="submit" class="btn btn-warning btn-sm"><i class="bi bi-pause-circle"></i> Suspend</button>
</form>
<form action="adminCustomer" method="post" class="d-inline" onsubmit="return confirm('Deactivate this account instead of deleting? Their booking history is preserved and the account can be reactivated later. Continue?');">
<input type="hidden" name="customerId" value="<%= c.getUserId() %>">
<input type="hidden" name="action" value="deactivate">
<button type="submit" class="btn btn-outline-warning btn-sm" title="Preferred when booking history exists"><i class="bi bi-slash-circle"></i> Deactivate</button>
</form>
<% if (row.totalBookings == 0) { %>
<form action="adminCustomer" method="post" class="d-inline" onsubmit="return confirm('PERMANENTLY delete this customer account? This cannot be undone and only works for customers with no booking history. Continue?');">
<input type="hidden" name="customerId" value="<%= c.getUserId() %>">
<input type="hidden" name="action" value="delete">
<button type="submit" class="btn btn-danger btn-sm" title="Only available when no booking history exists"><i class="bi bi-trash"></i> Delete</button>
</form>
<% } %>
<% } else { %>
<form action="adminCustomer" method="post" class="d-inline">
<input type="hidden" name="customerId" value="<%= c.getUserId() %>">
<input type="hidden" name="action" value="reactivate">
<button type="submit" class="btn btn-success btn-sm"><i class="bi bi-play-circle"></i> Reactivate</button>
</form>
<% } %>
</td>
</tr>
<% } %>
</tbody>
</table>
</div>
<% } %>
<div id="cust-detail">
<% if (viewCustomer != null) { %>
<div class="view-detail-card p-4 mt-3">
<div class="d-flex justify-content-between align-items-center mb-3">
<h3 class="mb-0" style="font-family:'Playfair Display',serif;color:#4A2040;">
<i class="bi bi-person-vcard"></i> Customer #<%= viewCustomer.getUserId() %> &#8212; <%= viewCustomer.getFullName() %>
</h3>
<a href="adminCustomer?action=list#customers" class="btn btn-outline-secondary btn-sm">Close</a>
</div>
<div class="row">
<div class="col-md-6">
<p><b>Email:</b> <%= viewCustomer.getEmail() %></p>
<p><b>Phone:</b> <%= (viewCustomer.getPhone() == null || viewCustomer.getPhone().isEmpty()) ? dash : viewCustomer.getPhone() %></p>
<p><b>Address:</b> <%= (viewCustomer.getAddress() == null || viewCustomer.getAddress().isEmpty()) ? dash : viewCustomer.getAddress() %></p>
</div>
<div class="col-md-6">
<p><b>Registered:</b> <%= viewCustomer.getCreatedAt() == null ? dash : viewCustomer.getCreatedAt() %></p>
<p><b>Account status:</b> <span class="badge <%= "SUSPENDED".equalsIgnoreCase(viewStatus) ? "badge-susp" : "badge-act" %>"><%= "SUSPENDED".equalsIgnoreCase(viewStatus) ? "Suspended" : "Active" %></span></p>
<p><b>Bookings:</b> <%= viewCounts.total %> total, <%= viewCounts.approved %> completed</p>
</div>
</div>
<hr>
<h5 style="color:#4A2040;"><i class="bi bi-clock-history"></i> Booking History</h5>
<% if (viewHistory == null || viewHistory.isEmpty()) { %>
<p class="text-muted"><i class="bi bi-inbox"></i> This customer has never made a booking.</p>
<% } else { %>
<div class="table-responsive">
<table class="table table-sm table-bordered align-middle">
<thead class="table-dark">
<tr><th>Booking</th><th>Dress</th><th>Dates</th><th>Days</th><th>Total</th><th>Status</th></tr>
</thead>
<tbody>
<% for (Booking hb : viewHistory) {
       String hst = hb.getStatus() == null ? "Pending" : hb.getStatus();
       String hBadge = "Pending".equalsIgnoreCase(hst) ? "bg-warning text-dark"
               : (("Approved".equalsIgnoreCase(hst) || "Confirmed".equalsIgnoreCase(hst)) ? "bg-success"
               : ("Rejected".equalsIgnoreCase(hst) ? "bg-danger" : "bg-secondary")); %>
<tr>
<td>#<%= hb.getBookingId() %></td>
<td><%= hb.getDressName() == null ? "Dress #" + hb.getDressId() : hb.getDressName() %></td>
<td><%= hb.getStartDate() %> to <%= hb.getEndDate() %></td>
<td><%= hb.getRentalDays() %></td>
<td>&#8377;<%= String.format("%,.2f", hb.getGrandTotal()) %></td>
<td><span class="badge <%= hBadge %>"><%= hst %></span></td>
</tr>
<% } %>
</tbody>
</table>
</div>
<% } %>
</div>
<% } %>
</div>

