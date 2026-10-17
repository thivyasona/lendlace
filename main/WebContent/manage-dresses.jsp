<%@ page import="java.util.List" %>
    <%@ page import="com.lendlace.dao.DressDAO" %>
        <%@ page import="com.lendlace.model.Dress" %>
            <%@ page import="com.lendlace.model.User" %>
                <% User owner=(User) session.getAttribute("loggedUser"); boolean isOwnerRole = owner != null && "OWNER".equalsIgnoreCase(owner.getRole()); boolean isAdminRole = owner != null && "ADMIN".equalsIgnoreCase(owner.getRole()); if (owner==null || (!isOwnerRole && !isAdminRole)) { response.sendRedirect("login.jsp"); return; } DressDAO
                    dao=new DressDAO(); List<Dress> myDresses = isOwnerRole ? dao.getDressesByOwner(owner.getUserId()) : dao.getAllDresses();
                    String deleted = request.getParameter("deleted");
                    String deleteError = request.getParameter("deleteError");
                    String updatedParam = request.getParameter("updated");
                    %>
                    <!DOCTYPE html>
                    <html lang="en">

                    <head>
                        <meta charset="UTF-8">
                        <meta name="viewport" content="width=device-width, initial-scale=1.0">
                        <title>Manage Dresses</title>
                        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
                            rel="stylesheet">
                        <link rel="stylesheet"
                            href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
                        <style>
                            body {
                                background: #FAF6F0;
                                font-family: Poppins, sans-serif;
                            }

                            .navbar {
                                background: #33172C;
                            }

                            .card {
                                border: none;
                                border-radius: 15px;
                                box-shadow: 0 5px 15px rgba(74, 32, 64, .1);
                            }

                            .card img {
                                height: 260px;
                                width: 100%;
                                object-fit: cover;
                                display: block;
                            }

                            /* Consistent dress grid: equal card heights, side-by-side
                               columns on desktop, fewer columns on smaller screens. */
                            .dress-grid {
                                display: grid;
                                grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
                                gap: 1.5rem;
                                align-items: stretch;
                            }
                            .dress-grid .card { height: 100%; }
                            .dress-grid .card-body { display: flex; flex-direction: column; }
                            .dress-grid .card-body form { margin-top: auto; }
                            @media (max-width: 576px) {
                                .dress-grid { grid-template-columns: 1fr; }
                            }
                        </style>
                    </head>

                    <body>
                        <nav class="navbar navbar-dark">
                            <div class="container">
                                <a class="navbar-brand" href="owner-dashboard.jsp">
                                    <i class="bi bi-arrow-left-circle"></i>
                                    Manage Dresses
                                </a>
                            </div>
                        </nav>
                        <div class="container py-5">
                            <% if ("1".equals(updatedParam)) { %>
                                <div class="alert alert-success"><i class="bi bi-check-circle-fill"></i> Dress updated successfully.</div>
                                <% } else if ("0".equals(updatedParam)) { %>
                                    <div class="alert alert-danger">Update failed. Please check the values and try again.</div>
                            <% } %>
                            <% if ("1".equals(deleted)) { %>
                                <div class="alert alert-success"><i class="bi bi-check-circle-fill"></i> Dress deleted successfully. It no longer appears on the Browse Dresses page.</div>
                                <% } else if ("0".equals(deleted)) { %>
                                    <div class="alert alert-danger">Delete failed in the database. The dress was not removed.</div>
                                <% } else if ("1".equals(deleteError)) { %>
                                    <div class="alert alert-danger">Delete failed: the dress does not exist or you are not authorised to delete it.</div>
                                    <% } else if ("2".equals(deleteError)) { %>
                                        <div class="alert alert-warning"><i class="bi bi-exclamation-triangle"></i> <b>Cannot delete:</b> this dress has Pending, Approved or Confirmed bookings. Wait until they are completed or rejected, or edit the dress and set it to <b>Not Available</b> so customers cannot book it.</div>
                                        <% } %>
                                        <% if (myDresses.isEmpty()) { %>
                                            <p class="text-center text-muted mt-4">You have not uploaded any dresses
                                                yet.
                                                <a href="add-dress.jsp">Add your first dress</a>.
                                            </p>
                                            <% } else { %>
                                                <div class="dress-grid">
                                                    <% for (Dress d : myDresses) { String dImg = (d.getImage() == null || d.getImage().isEmpty()) ? "assets/images/image-unavailable.jpg" : d.getImage(); %>
                                                        <div>
                                                            <div class="card">
                                                                <img src="<%= dImg %>" class="card-img-top">
                                                                <div class="card-body">
                                                                    <h4>
                                                                        <%= d.getDressName() %>
                                                                    </h4>
                                                                    <p>&#8377;<%= String.format("%,.0f", d.getPricePerDay()) %> / Day</p>
                                                                    <p><b>Size:</b>
                                                                        <%= d.getSize()==null ? "-" : d.getSize() %>
                                                                    </p>
                                                                    <p><b>Status:</b>
                                                                        <%= d.getStatus()==null ? "Available" :
                                                                            d.getStatus() %>
                                                                    </p>
                                                                    <form action="updateDress" method="get"
                                                                        class="d-inline">
                                                                        <input type="hidden" name="dressId"
                                                                            value="<%= d.getDressId() %>">
                                                                        <button
                                                                            class="btn btn-primary btn-sm">Edit</button>
                                                                    </form>
                                                                    <% if (isOwnerRole) { %>
                                                                    <form action="deleteDress" method="post"
                                                                        class="d-inline"
                                                                        onsubmit="return confirm('Delete \'<%= d.getDressName().replace("'", "\\'") %>\' permanently? This cannot be undone.');">
                                                                        <input type="hidden" name="dressId"
                                                                            value="<%= d.getDressId() %>">
                                                                        <button
                                                                            class="btn btn-danger btn-sm">Delete</button>
                                                                    </form>
                                                                    <% } else { %>
                                                                        <span class="text-muted small ms-1"><i class="bi bi-shield-lock"></i> Admin view (delete is owner-only)</span>
                                                                    <% } %>
                                                                </div>
                                                            </div>
                                                        </div>
                                                        <% } %>
                                                </div>
                                                <% } %>
                        </div>
                        <script
                            src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
                    </body>

                    </html>