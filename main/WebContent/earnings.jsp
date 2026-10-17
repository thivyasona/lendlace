<%@ page import="java.util.List" %>
    <%@ page import="com.lendlace.dao.BookingDAO" %>
        <%@ page import="com.lendlace.model.Booking" %>
            <%@ page import="com.lendlace.model.User" %>
                <% User owner=(User) session.getAttribute("loggedUser"); if (owner==null ||
                    !"OWNER".equalsIgnoreCase(owner.getRole())) { response.sendRedirect("login.jsp"); return; }
                    BookingDAO dao=new BookingDAO(); List<Booking> allBookings = dao.getAllBookingsForAdmin();
                    %>
                    <!DOCTYPE html>
                    <html lang="en">

                    <head>
                        <meta charset="UTF-8">
                        <meta name="viewport" content="width=device-width, initial-scale=1.0">
                        <title>Earnings</title>
                        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
                            rel="stylesheet">
                        <link rel="stylesheet"
                            href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
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
                                background: #f5f5f5;
                            }

                            .navbar {
                                background: #6A1B9A;
                            }

                            .card {
                                border: none;
                                border-radius: 20px;
                                box-shadow: 0 8px 20px rgba(0, 0, 0, .1);
                            }
                        </style>
                    </head>

                    <body>
                        <nav class="navbar navbar-dark">
                            <div class="container">
                                <a href="owner-dashboard.jsp" class="navbar-brand">
                                    <i class="bi bi-cash-stack"></i>
                                    Earnings Dashboard
                                </a>
                            </div>
                        </nav>
                        <div class="container py-5">
                            <% double total=0; for (Booking b : allBookings) { if
                                (!"Rejected".equalsIgnoreCase(b.getStatus())) total +=b.getGrandTotal(); } %>
                                <div class="row g-4 mb-5">
                                    <div class="col-md-12">
                                        <div class="card">
                                            <div class="card-body text-center">
                                                <h2 class="text-success">&#8377;<%= String.format("%,.0f", total) %>
                                                </h2>
                                                <p>Total Earnings</p>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="card">
                                    <div class="card-body">
                                        <h3 class="mb-4">
                                            Recent Transactions
                                        </h3>
                                        <% if (allBookings.isEmpty()) { %>
                                            <p class="text-center text-muted">No transactions yet.</p>
                                            <% } else { %>
                                                <div class="table-responsive">
                                                    <table class="table table-bordered table-hover">
                                                        <thead class="table-dark">
                                                            <tr>
                                                                <th>Booking ID</th>
                                                                <th>Customer</th>
                                                                <th>Dress</th>
                                                                <th>Rental Dates</th>
                                                                <th>Amount</th>
                                                                <th>Status</th>
                                                            </tr>
                                                        </thead>
                                                        <tbody>
                                                            <% for (Booking b : allBookings) { String
                                                                st=b.getStatus()==null ? "Pending" : b.getStatus();
                                                                String badge="Approved" .equalsIgnoreCase(st)
                                                                ? "bg-success" : ("Rejected".equalsIgnoreCase(st)
                                                                ? "bg-danger" : "bg-warning text-dark" ); %>
                                                                <tr>
                                                                    <td>
                                                                        <%= b.getBookingId() %>
                                                                    </td>
                                                                    <td>
                                                                        <%= b.getCustomerName()==null ? "Customer #" +
                                                                            b.getCustomerId() : b.getCustomerName() %>
                                                                    </td>
                                                                    <td>
                                                                        <%= b.getDressName()==null ? "Dress #" +
                                                                            b.getDressId() : b.getDressName() %>
                                                                    </td>
                                                                    <td>
                                                                        <%= b.getStartDate() %> - <%= b.getEndDate() %>
                                                                    </td>
                                                                    <td>&#8377;<%= String.format("%,.0f",
                                                                            b.getGrandTotal()) %>
                                                                    </td>
                                                                    <td><span class="badge <%= badge %>">
                                                                            <%= st %>
                                                                        </span></td>
                                                                </tr>
                                                                <% } %>
                                                        </tbody>
                                                    </table>
                                                </div>
                                                <% } %>
                                    </div>
                                </div>
                                <div class="text-center mt-5">
<a href="owner-dashboard.jsp" class="btn btn-primary btn-lg">
                                    Back to Dashboard
                                    </a>
                                </div>
                        </div>
                        <script
                            src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
                    </body>

                    </html>