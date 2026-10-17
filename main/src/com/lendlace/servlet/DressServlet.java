package com.lendlace.servlet;

import com.lendlace.dao.DressDAO;
import com.lendlace.model.Dress;
import com.lendlace.model.User;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@MultipartConfig(maxFileSize = 5 * 1024 * 1024)
@WebServlet({"/addDress","/DressServlet","/deleteDress","/updateDress"})
public class DressServlet extends HttpServlet {

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

        // SERVER-SIDE ROLE ENFORCEMENT: owners manage their own dresses.
        // ADMIN may manage any dress (platform administration).
        // Customers can never upload, edit or delete, even by direct POST.
        boolean isAdmin = "ADMIN".equalsIgnoreCase(user.getRole());
        if (!"OWNER".equalsIgnoreCase(user.getRole()) && !isAdmin) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Access denied: dress management is restricted to owners and admins.");
            return;
        }

        String path = request.getServletPath();

        if ("/deleteDress".equals(path)) {
            handleDelete(request, response, user);
            return;
        }
        if ("/updateDress".equals(path)) {
            handleUpdate(request, response, user);
            return;
        }

        // the add form must be multipart (it carries the image file)
        if (request.getContentType() == null
                || !request.getContentType().toLowerCase().startsWith("multipart/")) {
            response.sendRedirect("add-dress.jsp?error=1");
            return;
        }

        // ---- ADD new dress (owner only) ----
        Dress dress = new Dress();

        dress.setOwnerId(user.getUserId()); // ownership fixed server-side, never from the form
        if (!parseDress(request, dress)) {
            response.sendRedirect("add-dress.jsp?error=1");
            return;
        }
        Part imagePart = request.getPart("dressImage");
        String fileName = (imagePart == null || imagePart.getSubmittedFileName() == null
                || imagePart.getSubmittedFileName().isEmpty())
                ? null : imagePart.getSubmittedFileName();
        if (fileName != null
                && RegisterServlet.isAllowedImage(imagePart.getContentType(), fileName)) {
            // unique, server-generated safe filename (no path traversal, no overwrites)
            String safeName = "dress_" + user.getUserId() + "_"
                    + System.currentTimeMillis() + "_"
                    + RegisterServlet.safeName(fileName);
            File dest = new File(getUploadDir(), safeName);
            imagePart.write(dest.getAbsolutePath());
            dress.setImage("uploads/" + dest.getName());
        } else {
            dress.setImage("assets/images/dress1.jpg");
        }
        dress.setVideo(request.getParameter("video"));
        String statusParam = request.getParameter("status");
        dress.setStatus("Not Available".equalsIgnoreCase(statusParam)
                ? "Not Available" : "Available");

        DressDAO dao = new DressDAO();

        if (dao.addDress(dress)) {
            response.sendRedirect("owner-dashboard.jsp?success=1");
        } else {
            response.sendRedirect("add-dress.jsp?error=1");
        }
    }
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)throws ServletException, IOException {
        String action = request.getParameter("action");

        // public "view dress details" used by browse/customer pages
        if ("view".equals(action)) {
            try {
                int dressId = Integer.parseInt(request.getParameter("dressId"));
                DressDAO dao = new DressDAO();
                Dress dress = dao.getDressById(dressId);
                if (dress == null) {
                    response.sendRedirect("browse-dresses.jsp");
                    return;
                }
                request.setAttribute("dress", dress);
                request.getRequestDispatcher("dress-details.jsp")
                       .forward(request, response);
            } catch (NumberFormatException e) {
                response.sendRedirect("browse-dresses.jsp");
            }
            return;
        }

        // edit-dress page needs the dress loaded. Owners may edit their own
        // dresses; admins may edit any dress (the edit form updates the same
        // rows the admin sees in Manage Dresses).
        HttpSession session = request.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("loggedUser");
        boolean isAdmin = user != null && "ADMIN".equalsIgnoreCase(user.getRole());
        if (user == null || (!"OWNER".equalsIgnoreCase(user.getRole()) && !isAdmin)) {
            response.sendRedirect("login.jsp");
            return;
        }
        try {
            int dressId = Integer.parseInt(request.getParameter("dressId"));
            DressDAO dao = new DressDAO();
            Dress dress = dao.getDressById(dressId);
            if (dress == null || (!isAdmin && dress.getOwnerId() != user.getUserId())) {
                // owners cannot open another owner's dress
                response.sendRedirect("manage-dresses.jsp?deleteError=1");
                return;
            }
            request.setAttribute("dress", dress);
            request.getRequestDispatcher("edit-dress.jsp")
                   .forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect("manage-dresses.jsp?deleteError=1");
        }
    }

    /** Parses and validates the numeric dress fields. */
    private boolean parseDress(HttpServletRequest request, Dress dress) {
        try {
            dress.setDressName(request.getParameter("dressName"));
            dress.setCategory(request.getParameter("category"));
            dress.setBrand(request.getParameter("brand"));
            dress.setColor(request.getParameter("color"));
            dress.setSize(request.getParameter("size"));
            dress.setOccasion(request.getParameter("occasion"));
            dress.setPricePerDay(Double.parseDouble(request.getParameter("dressPrice")));
            dress.setSecurityDeposit(Double.parseDouble(
                    request.getParameter("deposit") == null
                            || request.getParameter("deposit").isEmpty()
                            ? "0" : request.getParameter("deposit")));
            dress.setDescription(request.getParameter("description"));
            dress.setAvailableFrom(request.getParameter("availableFrom"));
            dress.setAvailableTo(request.getParameter("availableTo"));
            if (dress.getDressName() == null || dress.getDressName().trim().isEmpty()
                    || dress.getPricePerDay() < 0) {
                return false;
            }
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    /*
     * Persistent upload directory OUTSIDE the webapp. Files written inside
     * the exploded WAR (getRealPath) are wiped by Tomcat on every redeploy,
     * which made owner-uploaded images disappear. An external directory
     * survives redeploys. Override with the UPLOAD_DIR system property.
     */
    private File getUploadDir() {
        String override = System.getProperty("UPLOAD_DIR");
        File dir = (override != null && !override.isEmpty())
                ? new File(override)
                : new File(System.getProperty("catalina.base",
                        getServletContext().getRealPath("")), "lendlace-uploads");
        if (!dir.exists()) dir.mkdirs();
        return dir;
    }

    /** UPDATE a dress in MySQL (owner edits own dresses; admin edits any). */
    private void handleUpdate(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {
        try {
            int dressId = Integer.parseInt(request.getParameter("dressId"));
            DressDAO dao = new DressDAO();
            Dress existing = dao.getDressById(dressId);
            boolean isAdmin = "ADMIN".equalsIgnoreCase(user.getRole());

            // OWNERSHIP CHECK: an owner can only update their own dress.
            // An admin can update any dress (platform administration).
            if (existing == null || (!isAdmin && existing.getOwnerId() != user.getUserId())) {
                response.sendRedirect("manage-dresses.jsp?deleteError=1");
                return;
            }

            Dress dress = new Dress();
            dress.setDressId(dressId);
            dress.setOwnerId(existing.getOwnerId()); // never transferred by a form
            dress.setStatus(existing.getStatus());   // default: keep current status
            if (!parseDress(request, dress)) {
                response.sendRedirect("edit-dress.jsp?dressId=" + dressId + "&error=1");
                return;
            }
            // admins may change the availability status; owners cannot bypass
            // booking-derived availability by editing the form
            if (isAdmin) {
                String statusParam = request.getParameter("status");
                if ("Available".equalsIgnoreCase(statusParam)
                        || "Not Available".equalsIgnoreCase(statusParam)) {
                    dress.setStatus(statusParam.substring(0, 1).toUpperCase()
                            + statusParam.substring(1).toLowerCase());
                }
            }
            // preserve availability window when the form omits it
            dress.setAvailableFrom(request.getParameter("availableFrom") == null
                    || request.getParameter("availableFrom").isEmpty()
                    ? existing.getAvailableFrom() : request.getParameter("availableFrom"));
            dress.setAvailableTo(request.getParameter("availableTo") == null
                    || request.getParameter("availableTo").isEmpty()
                    ? existing.getAvailableTo() : request.getParameter("availableTo"));

            // replace the image only when a new valid one was uploaded
            Part imagePart = null;
            if (request.getContentType() != null
                    && request.getContentType().toLowerCase().startsWith("multipart/")) {
                imagePart = request.getPart("dressImage");
            }
            String fileName = (imagePart == null || imagePart.getSubmittedFileName() == null
                    || imagePart.getSubmittedFileName().isEmpty())
                    ? null : imagePart.getSubmittedFileName();
            if (fileName != null
                    && RegisterServlet.isAllowedImage(imagePart.getContentType(), fileName)) {
                String safeName = "dress_" + user.getUserId() + "_"
                        + System.currentTimeMillis() + "_"
                        + RegisterServlet.safeName(fileName);
                File dest = new File(getUploadDir(), safeName);
                imagePart.write(dest.getAbsolutePath());
                dress.setImage("uploads/" + dest.getName());
            } else {
                dress.setImage(existing.getImage()); // keep current image
            }
            dress.setVideo(request.getParameter("video") == null
                    ? existing.getVideo() : request.getParameter("video"));

            boolean ok = dao.updateDress(dress);
            response.sendRedirect("manage-dresses.jsp?updated=" + (ok ? "1" : "0"));
        } catch (NumberFormatException e) {
            response.sendRedirect("manage-dresses.jsp?deleteError=1");
        }
    }

    // DELETE a dress from MySQL (owner only, own dresses only)
    private void handleDelete(HttpServletRequest request, HttpServletResponse response,
                              com.lendlace.model.User user)
            throws ServletException, IOException {
        if (user == null || !"OWNER".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect("login.jsp");
            return;
        }
        try {
            int dressId = Integer.parseInt(request.getParameter("dressId"));
            DressDAO dao = new DressDAO();
            Dress dress = dao.getDressById(dressId);
            // only the owner of the dress may delete it
            if (dress == null || dress.getOwnerId() != user.getUserId()) {
                response.sendRedirect("manage-dresses.jsp?deleteError=1");
                return;
            }
            // booking rule: a dress with active bookings cannot be removed
            boolean hasActiveBookings = false;
            for (com.lendlace.model.Booking ab : new com.lendlace.dao.BookingDAO().getAllBookings()) {
                if (ab.getDressId() == dressId
                        && ("Pending".equalsIgnoreCase(ab.getStatus())
                            || "Approved".equalsIgnoreCase(ab.getStatus())
                            || "Confirmed".equalsIgnoreCase(ab.getStatus()))) {
                    hasActiveBookings = true;
                    break;
                }
            }
            if (hasActiveBookings) {
                response.sendRedirect("manage-dresses.jsp?deleteError=2");
                return;
            }
            boolean ok = dao.deleteDress(dressId);
            if (ok) {
                // remove the uploaded image file from the persistent folder,
                // but ONLY when no other dress still references the same path
                String img = dress.getImage();
                if (img != null && img.startsWith("uploads/") && !img.isEmpty()) {
                    boolean stillUsed = false;
                    for (Dress other : dao.getAllDresses()) {
                        if (img.equals(other.getImage())) { stillUsed = true; break; }
                    }
                    if (!stillUsed) {
                        String fname = img.substring("uploads/".length());
                        if (!fname.contains("/") && !fname.contains("\\") && !fname.contains("..")) {
                            File f = new File(getUploadDir(), fname);
                            if (f.isFile()) f.delete();
                        }
                    }
                }
                response.sendRedirect("manage-dresses.jsp?deleted=1");
            } else {
                response.sendRedirect("manage-dresses.jsp?deleted=0");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect("manage-dresses.jsp?deleteError=1");
        }
    }
}