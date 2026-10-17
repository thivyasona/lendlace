<%@ page import="com.lendlace.model.Dress" %>
<% // The forwarded "dress" attribute comes from DressServlet doGet.
    Dress dress = (Dress) request.getAttribute("dress"); if (dress == null) { response.sendRedirect("manage-dresses.jsp");
    return; } %>
        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Edit Dress</title>
            <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
            <link rel="stylesheet"
                href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
            <style>
                body {
                    background: #f5f5f5;
                    font-family: Poppins, sans-serif;
                }

                .navbar {
                    background: #6A1B9A;
                }

                .card {
                    border: none;
                    border-radius: 20px;
                    box-shadow: 0 5px 15px rgba(0, 0, 0, .1);
                }
            </style>
        </head>

        <body>
            <nav class="navbar navbar-dark">
                <div class="container">
                    <a class="navbar-brand" href="manage-dresses.jsp">
                        <i class="bi bi-arrow-left-circle"></i> Back to Manage Dresses
                    </a>
                </div>
            </nav>
            <div class="container py-5" style="max-width:760px;">
                <% if (request.getParameter("error") !=null) { %>
                    <div class="alert alert-danger">Update failed. Please check the values and try again.</div>
                    <% } %>
                        <div class="card p-4">
                            <h3 class="mb-4"><i class="bi bi-pencil-square"></i> Edit Dress #<%= dress.getDressId() %>
                            </h3>
                            <form action="updateDress" method="post" enctype="multipart/form-data">
                                <input type="hidden" name="dressId" value="<%= dress.getDressId() %>">
                                <div class="mb-3">
                                    <label class="form-label">Dress Name *</label>
                                    <input type="text" class="form-control" name="dressName" required
                                        value="<%= dress.getDressName() == null ? "" : dress.getDressName() %>">
                                </div>
                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label">Category</label>
                                        <input type="text" class="form-control" name="category"
                                            value="<%= dress.getCategory() == null ? "" : dress.getCategory() %>">
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label">Brand</label>
                                        <input type="text" class="form-control" name="brand"
                                            value="<%= dress.getBrand() == null ? "" : dress.getBrand() %>">
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label">Color</label>
                                        <input type="text" class="form-control" name="color"
                                            value="<%= dress.getColor() == null ? "" : dress.getColor() %>">
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label">Size</label>
                                        <input type="text" class="form-control" name="size"
                                            value="<%= dress.getSize() == null ? "" : dress.getSize() %>">
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label">Occasion</label>
                                        <input type="text" class="form-control" name="occasion"
                                            value="<%= dress.getOccasion() == null ? "" : dress.getOccasion() %>">
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label">Price Per Day *</label>
                                        <input type="number" step="0.01" min="0" class="form-control" name="dressPrice"
                                            required value="<%= dress.getPricePerDay() %>">
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label">Security Deposit</label>
                                        <input type="number" step="0.01" min="0" class="form-control" name="deposit"
                                            value="<%= dress.getSecurityDeposit() %>">
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label">Available From</label>
                                        <input type="date" class="form-control" name="availableFrom"
                                            value="<%= dress.getAvailableFrom() == null ? "" : dress.getAvailableFrom() %>">
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label">Available To</label>
                                        <input type="date" class="form-control" name="availableTo"
                                            value="<%= dress.getAvailableTo() == null ? "" : dress.getAvailableTo() %>">
                                    </div>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Description</label>
                                    <textarea class="form-control" name="description"
                                        rows="3"><%= dress.getDescription() == null ? "" : dress.getDescription() %></textarea>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Availability Status *</label>
                                    <select class="form-select" name="status">
                                        <option <%= "Available".equalsIgnoreCase(dress.getStatus()) ? "selected" : "" %>>Available</option>
                                        <option <%= "Not Available".equalsIgnoreCase(dress.getStatus()) ? "selected" : "" %>>Not Available</option>
                                    </select>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Replace Image (optional)</label>
                                    <input type="file" class="form-control" name="dressImage"
                                        accept="image/jpeg,image/png,image/gif,image/webp">
                                    <small class="text-muted">Leave empty to keep the current image.</small>
                                </div>
                                <div class="text-center">
                                    <button type="submit" class="btn btn-success px-4">Save Changes</button>
                                    <a href="manage-dresses.jsp" class="btn btn-secondary">Cancel</a>
                                </div>
                            </form>
                        </div>
            </div>
        </body>

        </html>