package com.lendlace.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.File;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Path;

/**
 * Serves dress/user images from the persistent upload directory (outside the
 * webapp, so they survive redeployments). URLs stay "/uploads/<filename>",
 * exactly what the database stores, so no JSP change is needed.
 *
 * Security: the requested file is resolved against the upload directory and
 * must exist as a regular file - path traversal (../) cannot escape it.
 */
@WebServlet("/uploads/*")
public class UploadFileServlet extends HttpServlet {

    private File uploadDir() {
        String override = System.getProperty("UPLOAD_DIR");
        File dir = (override != null && !override.isEmpty())
                ? new File(override)
                : new File(System.getProperty("catalina.base",
                        getServletContext().getRealPath("")), "lendlace-uploads");
        if (!dir.exists())
            dir.mkdirs();
        return dir;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String info = request.getPathInfo(); // e.g. "/dress_5_123_wall.jpg"
        if (info == null || info.length() < 2) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String requested = info.substring(1);
        // reject any path separator or traversal attempt
        if (requested.contains("/") || requested.contains("\\")
                || requested.contains("..")) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        File file = new File(uploadDir(), requested);
        if (!file.isFile()) {
            // missing image -> serve the neutral placeholder instead of a 404
            response.sendRedirect(request.getContextPath()
                    + "/assets/images/image-unavailable.jpg");
            return;
        }

        String name = file.getName().toLowerCase();
        String type = name.endsWith(".png") ? "image/png"
                : name.endsWith(".gif") ? "image/gif"
                        : name.endsWith(".webp") ? "image/webp"
                                : "image/jpeg";

        response.setContentType(type);
        response.setHeader("Cache-Control", "public, max-age=3600");
        response.setContentLengthLong(file.length());

        try (OutputStream out = response.getOutputStream()) {
            Files.copy(file.toPath(), out);
        }
    }
}
