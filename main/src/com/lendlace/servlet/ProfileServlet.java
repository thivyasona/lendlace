package com.lendlace.servlet;

import com.lendlace.dao.UserDAO;
import com.lendlace.model.User;

import java.io.File;
import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

@MultipartConfig
@WebServlet("/updateProfile")
public class ProfileServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        User user = (User) session.getAttribute("loggedUser");

        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String back = "OWNER".equalsIgnoreCase(user.getRole())
                ? "owner-profile.jsp" : "profile.jsp";

        user.setFullName(request.getParameter("fullName"));
        user.setPhone(request.getParameter("phone"));
        user.setAddress(request.getParameter("address"));

        // optional new profile photo
        try {
            Part imagePart = request.getPart("profileImage");
            if (imagePart != null && imagePart.getSubmittedFileName() != null
                    && !imagePart.getSubmittedFileName().isEmpty()) {
                String fileName = imagePart.getSubmittedFileName();
                String uploadPath = getServletContext().getRealPath("") + "uploads";
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) uploadDir.mkdirs();
                File dest = new File(uploadPath + File.separator + fileName);
                if (dest.exists()) {
                    String base = fileName.contains(".")
                            ? fileName.substring(0, fileName.lastIndexOf('.')) : fileName;
                    String ext = fileName.contains(".")
                            ? fileName.substring(fileName.lastIndexOf('.')) : "";
                    dest = new File(uploadPath + File.separator + base
                            + "_" + System.currentTimeMillis() + ext);
                }
                imagePart.write(dest.getAbsolutePath());
                user.setProfileImage("uploads/" + dest.getName());
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        UserDAO dao = new UserDAO();

        if (dao.updateUser(user)) {

            session.setAttribute("loggedUser", user);

            response.sendRedirect(back + "?success=1");

        } else {

            response.sendRedirect(back + "?error=1");

        }
    }
}