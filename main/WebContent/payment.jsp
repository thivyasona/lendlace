<%@ page import="com.lendlace.dao.BookingDAO" %>
    <%@ page import="com.lendlace.model.Booking" %>
        <%@ page import="com.lendlace.model.User" %>
            <% User payUser=(User) session.getAttribute("loggedUser"); if (payUser==null) {
                response.sendRedirect("login.jsp"); return; } int payBookingId; try {
                payBookingId=Integer.parseInt(request.getParameter("bookingId")); } catch (Exception e) {
                response.sendRedirect("my-bookings.jsp"); return; } Booking payBooking=new
                BookingDAO().getBookingById(payBookingId); if (payBooking==null || payBooking.getCustomerId()
                !=payUser.getUserId()) { response.sendRedirect("my-bookings.jsp"); return; } %>
                <!DOCTYPE html>
                <html lang="en">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1">
                    <title>Payment</title>
                    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
                        rel="stylesheet">
                </head>

                <body class="bg-light">
                    <div class="container py-5" style="max-width:520px;">
                        <div class="card shadow p-4">
                            <h2 class="mb-2">Payment</h2>
                            <p class="text-muted mb-4">Booking #<%= payBooking.getBookingId() %>
                                    <%= payBooking.getDressName()==null ? "" : "- " + payBooking.getDressName() %>
                            </p>
                            <h5>Amount to Pay</h5>
                            <p class="fs-3 fw-bold">&#8377;<%= String.format("%,.0f", payBooking.getGrandTotal()) %>
                            </p>
                            <hr>
                            <h5 class="mt-3">Choose Payment Method</h5>
                            <form action="payment" method="post">
                                <input type="hidden" name="bookingId" value="<%= payBooking.getBookingId() %>">
                                <input type="hidden" id="paymentMethod" name="paymentMethod" value="UPI">
                                <div class="form-check">
                                    <input class="form-check-input" type="radio" name="pay" id="payUpi" checked>
                                    <label class="form-check-label" for="payUpi">UPI</label>
                                </div>
                                <div class="form-check">
                                    <input class="form-check-input" type="radio" name="pay" id="payCard">
                                    <label class="form-check-label" for="payCard">Credit / Debit Card</label>
                                </div>
                                <div class="form-check">
                                    <input class="form-check-input" type="radio" name="pay" id="payNet">
                                    <label class="form-check-label" for="payNet">Net Banking</label>
                                </div>
                                <div class="form-check mb-4">
                                    <input class="form-check-input" type="radio" name="pay" id="payCod">
                                    <label class="form-check-label" for="payCod">Cash on Delivery</label>
                                </div>
                                <button type="submit" class="btn btn-success w-100">Pay Now</button>
                            </form>
                        </div>
                    </div>
                    <script>
                        document.querySelectorAll("input[name='pay']").forEach(function (radio) {
                            radio.addEventListener("change", function () {
                                document.getElementById("paymentMethod").value =
                                    this.parentElement.innerText.trim();
                            });
                        });
                    </script>
                </body>

                </html>