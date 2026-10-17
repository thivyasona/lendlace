package com.lendlace.servlet;

import com.lendlace.dao.ReviewDAO;
import com.lendlace.model.Review;
import com.lendlace.model.User;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet({"/review","/deleteReview"})
public class ReviewServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("loggedUser") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // DELETE dispatch
        if ("/deleteReview".equals(request.getServletPath())) {
            com.lendlace.model.User u = (com.lendlace.model.User) session.getAttribute("loggedUser");
            try {
                int reviewId = Integer.parseInt(request.getParameter("reviewId"));
                ReviewDAO d = new ReviewDAO();
                Review existing = d.getReviewById(reviewId);
                // only the author can delete their own review
                if (existing == null || existing.getUserId() != u.getUserId()) {
                    response.sendRedirect("my-reviews.jsp");
                    return;
                }
                d.deleteReview(reviewId);
            } catch (NumberFormatException ignored) { }
            response.sendRedirect("my-reviews.jsp?deleted=1");
            return;
        }

        Review review = new Review();

    User user = (User) session.getAttribute("loggedUser");

    review.setUserId(user.getUserId());
        review.setDressId(Integer.parseInt(request.getParameter("dressId")));
        review.setRating(Integer.parseInt(request.getParameter("rating")));
        review.setReview(request.getParameter("review"));

        ReviewDAO dao = new ReviewDAO();

        if (dao.addReview(review)) {

            response.sendRedirect("dress-details.jsp?success=1");

        } else {

            response.sendRedirect("dress-details.jsp?error=1");

        }
    }
}