package com.lendlace.dao;

import com.lendlace.model.Dress;
import com.lendlace.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class DressDAO {
    // Add Dress
    public boolean addDress(Dress dress) {
        String sql = "INSERT INTO dresses(owner_id,dress_name,category,brand,color,size,occasion,price_per_day,security_deposit,description,available_from,available_to,image,video,status) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
        try {

            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql);

            ps.setInt(1, dress.getOwnerId());
            ps.setString(2, dress.getDressName());
            ps.setString(3, dress.getCategory());
            ps.setString(4, dress.getBrand());
            ps.setString(5, dress.getColor());
            ps.setString(6, dress.getSize());
            ps.setString(7, dress.getOccasion());
            ps.setDouble(8, dress.getPricePerDay());
            ps.setDouble(9, dress.getSecurityDeposit());
            ps.setString(10, dress.getDescription());
            ps.setString(11, dress.getAvailableFrom());
            ps.setString(12, dress.getAvailableTo());
            ps.setString(13, dress.getImage());
            ps.setString(14, dress.getVideo());
            ps.setString(15, dress.getStatus());

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
    // Get All Dresses
    public List<Dress> getAllDresses() {
        List<Dress> list = new ArrayList<>();
        String sql = "SELECT * FROM dresses";
        try {
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Dress dress = new Dress();

                dress.setDressId(rs.getInt("dress_id"));
                dress.setOwnerId(rs.getInt("owner_id"));
                dress.setDressName(rs.getString("dress_name"));
                dress.setCategory(rs.getString("category"));
                dress.setBrand(rs.getString("brand"));
                dress.setColor(rs.getString("color"));
                dress.setSize(rs.getString("size"));
                dress.setOccasion(rs.getString("occasion"));
                dress.setPricePerDay(rs.getDouble("price_per_day"));
                dress.setSecurityDeposit(rs.getDouble("security_deposit"));
                dress.setDescription(rs.getString("description"));
                dress.setAvailableFrom(rs.getString("available_from"));
                dress.setAvailableTo(rs.getString("available_to"));
                dress.setImage(rs.getString("image"));
                dress.setVideo(rs.getString("video"));
                dress.setStatus(rs.getString("status"));

                list.add(dress);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
    // Get Dress By ID
public Dress getDressById(int dressId) {
    String sql = "SELECT * FROM dresses WHERE dress_id=?";
    try {
        Connection con = DBConnection.getConnection();
        PreparedStatement ps = con.prepareStatement(sql);
        ps.setInt(1, dressId);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {

            Dress dress = new Dress();

            dress.setDressId(rs.getInt("dress_id"));
            dress.setOwnerId(rs.getInt("owner_id"));
            dress.setDressName(rs.getString("dress_name"));
            dress.setCategory(rs.getString("category"));
            dress.setBrand(rs.getString("brand"));
            dress.setColor(rs.getString("color"));
            dress.setSize(rs.getString("size"));
            dress.setOccasion(rs.getString("occasion"));
            dress.setPricePerDay(rs.getDouble("price_per_day"));
            dress.setSecurityDeposit(rs.getDouble("security_deposit"));
            dress.setDescription(rs.getString("description"));
            dress.setAvailableFrom(rs.getString("available_from"));
            dress.setAvailableTo(rs.getString("available_to"));
            dress.setImage(rs.getString("image"));
            dress.setVideo(rs.getString("video"));
            dress.setStatus(rs.getString("status"));
            return dress;
        }
    } catch (Exception e) {

        e.printStackTrace();
    }
    return null;
}
// Update Dress
public boolean updateDress(Dress dress) {
    String sql = "UPDATE dresses SET dress_name=?, category=?, brand=?, color=?, size=?, occasion=?, price_per_day=?, security_deposit=?, description=?, image=?, video=?, status=?, available_from=?, available_to=? WHERE dress_id=?";
    try {
        Connection con = DBConnection.getConnection();

        PreparedStatement ps = con.prepareStatement(sql);

        ps.setString(1, dress.getDressName());
        ps.setString(2, dress.getCategory());
        ps.setString(3, dress.getBrand());
        ps.setString(4, dress.getColor());
        ps.setString(5, dress.getSize());
        ps.setString(6, dress.getOccasion());
        ps.setDouble(7, dress.getPricePerDay());
        ps.setDouble(8, dress.getSecurityDeposit());
        ps.setString(9, dress.getDescription());
        ps.setString(10, dress.getImage());
        ps.setString(11, dress.getVideo());
        ps.setString(12, dress.getStatus());
        ps.setString(13, dress.getAvailableFrom());
        ps.setString(14, dress.getAvailableTo());
        ps.setInt(15, dress.getDressId());
        return ps.executeUpdate() > 0;
    } catch (Exception e) {
        e.printStackTrace();
    }
    return false;
}
// Delete Dress
public boolean deleteDress(int dressId) {
    String sql = "DELETE FROM dresses WHERE dress_id=?";
    try {
        Connection con = DBConnection.getConnection();
        PreparedStatement ps = con.prepareStatement(sql);
        ps.setInt(1, dressId);
        return ps.executeUpdate() > 0;
    } catch (Exception e) {
        e.printStackTrace();
    }
    return false;
}
// Get Dresses By Owner
public List<Dress> getDressesByOwner(int ownerId) {
    List<Dress> list = new ArrayList<>();
    String sql = "SELECT * FROM dresses WHERE owner_id=?";
    try {
        Connection con = DBConnection.getConnection();
        PreparedStatement ps = con.prepareStatement(sql);
        ps.setInt(1, ownerId);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            Dress dress = new Dress();

            dress.setDressId(rs.getInt("dress_id"));
            dress.setOwnerId(rs.getInt("owner_id"));
            dress.setDressName(rs.getString("dress_name"));
            dress.setCategory(rs.getString("category"));
            dress.setBrand(rs.getString("brand"));
            dress.setColor(rs.getString("color"));
            dress.setSize(rs.getString("size"));
            dress.setOccasion(rs.getString("occasion"));
            dress.setPricePerDay(rs.getDouble("price_per_day"));
            dress.setSecurityDeposit(rs.getDouble("security_deposit"));
            dress.setDescription(rs.getString("description"));
            dress.setImage(rs.getString("image"));
            dress.setVideo(rs.getString("video"));
            dress.setStatus(rs.getString("status"));
            list.add(dress);
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
    return list;
}
// Search Dress
public List<Dress> searchDress(String keyword) {
    List<Dress> list = new ArrayList<>();
    String sql = "SELECT * FROM dresses WHERE dress_name LIKE ? OR category LIKE ? OR occasion LIKE ?";
    try {
        Connection con = DBConnection.getConnection();
        PreparedStatement ps = con.prepareStatement(sql);
        String search = "%" + keyword + "%";
        ps.setString(1, search);
        ps.setString(2, search);
        ps.setString(3, search);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            Dress dress = new Dress();

            dress.setDressId(rs.getInt("dress_id"));
            dress.setOwnerId(rs.getInt("owner_id"));
            dress.setDressName(rs.getString("dress_name"));
            dress.setCategory(rs.getString("category"));
            dress.setBrand(rs.getString("brand"));
            dress.setColor(rs.getString("color"));
            dress.setSize(rs.getString("size"));
            dress.setOccasion(rs.getString("occasion"));
            dress.setPricePerDay(rs.getDouble("price_per_day"));
            dress.setSecurityDeposit(rs.getDouble("security_deposit"));
            dress.setDescription(rs.getString("description"));
            dress.setImage(rs.getString("image"));
            dress.setVideo(rs.getString("video"));
            dress.setStatus(rs.getString("status"));
            list.add(dress);
        }
    } catch (Exception e) {
    e.printStackTrace();
    throw new RuntimeException(e);
}
    return list;
}
    // Filter dresses by multiple criteria
    public List<Dress> filterDresses(String category, String size, String color,
                                     String brand, String occasion,
                                     Double maxPrice, String status) {
        List<Dress> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM dresses WHERE 1=1");
        List<Object> params = new ArrayList<>();
        if (category != null && !category.isEmpty() && !"All Categories".equals(category)) {
            sql.append(" AND category = ?"); params.add(category);
        }
        if (size != null && !size.isEmpty() && !"All Sizes".equals(size)) {
            sql.append(" AND size LIKE ?"); params.add("%" + size + "%");
        }
        if (color != null && !color.isEmpty() && !"All Colors".equals(color)) {
            sql.append(" AND color LIKE ?"); params.add("%" + color + "%");
        }
        if (brand != null && !brand.isEmpty() && !"All Brands".equals(brand)) {
            sql.append(" AND brand LIKE ?"); params.add("%" + brand + "%");
        }
        if (occasion != null && !occasion.isEmpty() && !"All Occasions".equals(occasion)) {
            sql.append(" AND occasion LIKE ?"); params.add("%" + occasion + "%");
        }
        if (maxPrice != null) {
            sql.append(" AND price_per_day <= ?"); params.add(maxPrice);
        }
        if (status != null && !status.isEmpty() && !"All".equals(status)) {
            sql.append(" AND status = ?"); params.add(status);
        }
        sql.append(" ORDER BY dress_id DESC");
        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql.toString());
        ) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Dress d = new Dress();
                d.setDressId(rs.getInt("dress_id"));
                d.setOwnerId(rs.getInt("owner_id"));
                d.setDressName(rs.getString("dress_name"));
                d.setCategory(rs.getString("category"));
                d.setBrand(rs.getString("brand"));
                d.setColor(rs.getString("color"));
                d.setSize(rs.getString("size"));
                d.setOccasion(rs.getString("occasion"));
                d.setPricePerDay(rs.getDouble("price_per_day"));
                d.setSecurityDeposit(rs.getDouble("security_deposit"));
                d.setDescription(rs.getString("description"));
                d.setImage(rs.getString("image"));
                d.setStatus(rs.getString("status"));
                list.add(d);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Dress> getDressByCategory(String category) {

    List<Dress> list = new ArrayList<>();

    String sql = "SELECT * FROM dresses WHERE category = ?";

    try (
        Connection con = DBConnection.getConnection();
        PreparedStatement ps = con.prepareStatement(sql);
    ) {

        ps.setString(1, category);

        ResultSet rs = ps.executeQuery();

        while (rs.next()) {

            Dress d = new Dress();

            d.setDressId(rs.getInt("dress_id"));
            d.setDressName(rs.getString("dress_name"));
            d.setCategory(rs.getString("category"));
            d.setBrand(rs.getString("brand"));
            d.setColor(rs.getString("color"));
            d.setSize(rs.getString("size"));
            d.setOccasion(rs.getString("occasion"));
            d.setPricePerDay(rs.getDouble("price_per_day"));
            d.setSecurityDeposit(rs.getDouble("security_deposit"));
            d.setStatus(rs.getString("status"));
            d.setImage(rs.getString("image"));

            list.add(d);
        }

    } catch (Exception e) {
        e.printStackTrace();
    }

    return list;
}
}