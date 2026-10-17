package com.lendlace.servlet;

import com.lendlace.dao.WishlistDAO;
import com.lendlace.model.Wishlist;
import com.lendlace.model.User;
import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/wishlist")
public class WishlistServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {
    HttpSession session = request.getSession(false);
    if (session == null || session.getAttribute("loggedUser") == null) {
    response.sendRedirect("login.jsp");
    return;
}
User user = (User) session.getAttribute("loggedUser");
System.out.println("Logged User ID = " + user.getUserId());
int userId = user.getUserId();
        int dressId = Integer.parseInt(request.getParameter("dressId"));
        Wishlist wishlist = new Wishlist();
        wishlist.setUserId(userId);
        wishlist.setDressId(dressId);
        WishlistDAO dao = new WishlistDAO();
        if (dao.addToWishlist(wishlist)) {
            response.sendRedirect("wishlist.jsp?success=1");
        } else {
            response.sendRedirect("browse-dresses.jsp?error=1");
        }
    }
    @Override
protected void doGet(HttpServletRequest request,
                     HttpServletResponse response)
        throws ServletException, IOException {

    HttpSession session = request.getSession(false);

    if (session == null || session.getAttribute("loggedUser") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    User user = (User) session.getAttribute("loggedUser");
    int userId = user.getUserId();

    String action = request.getParameter("action");

    WishlistDAO dao = new WishlistDAO();

    if ("remove".equals(action)) {

        int dressId = Integer.parseInt(request.getParameter("dressId"));

        dao.removeFromWishlist(userId, dressId);

    }

    response.sendRedirect("wishlist.jsp");
}
}
