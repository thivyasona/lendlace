package com.lendlace.servlet;

import com.lendlace.dao.DressDAO;
import com.lendlace.model.Dress;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/browse-dresses")
public class BrowseDressServlet extends HttpServlet {   
@Override
protected void doGet(HttpServletRequest request,
                     HttpServletResponse response)
        throws ServletException, IOException {

    DressDAO dao = new DressDAO();

    String search = request.getParameter("search");
    String category = request.getParameter("category");
    String size = request.getParameter("size");
    String color = request.getParameter("color");
    String brand = request.getParameter("brand");
    String occasion = request.getParameter("occasion");
    String status = request.getParameter("status");
    Double maxPrice = null;
    try {
        String mp = request.getParameter("maxPrice");
        if (mp != null && !mp.isEmpty()) maxPrice = Double.parseDouble(mp);
    } catch (NumberFormatException ignored) { }

    List<Dress> dresses;

    boolean hasSearch = search != null && !search.trim().isEmpty();
    boolean hasFilters = (size != null && !size.isEmpty() && !size.equals("All Sizes"))
            || (color != null && !color.isEmpty() && !color.equals("All Colors"))
            || (brand != null && !brand.isEmpty() && !brand.equals("All Brands"))
            || (occasion != null && !occasion.isEmpty() && !occasion.equals("All Occasions"))
            || maxPrice != null
            || (status != null && !status.isEmpty() && !status.equals("All"));

    if (hasSearch || hasFilters) {
        dresses = dao.filterDresses(category, size, color, brand, occasion, maxPrice, status);
        if (hasSearch && dresses != null && !dresses.isEmpty()) {
            // keep only dresses whose name/brand/occasion match the keyword
            String kw = search.trim().toLowerCase();
            dresses.removeIf(d -> !(String.valueOf(d.getDressName()).toLowerCase().contains(kw)
                    || String.valueOf(d.getBrand()).toLowerCase().contains(kw)
                    || String.valueOf(d.getOccasion()).toLowerCase().contains(kw)));
        }
    } else if (category != null && !category.equals("All Categories")) {
        dresses = dao.getDressByCategory(category);
    } else {
        dresses = dao.getAllDresses();
    }

    request.setAttribute("dressList", dresses);

    request.getRequestDispatcher("browse-dresses.jsp")
           .forward(request, response);
}
}