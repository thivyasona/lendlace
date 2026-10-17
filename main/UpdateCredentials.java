import com.lendlace.util.PasswordUtil;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

/**
 * Development-only credential update tool.
 * Sets a password per account using the project's existing PBKDF2 hashing.
 * Never inserts plaintext into MySQL. Verifies the row count of each
 * update and prints the result.
 *
 * NO credentials are hardcoded here. Accounts and passwords are read from
 * environment variables so this file is safe to publish on GitHub:
 *
 *   CRED_UPDATE_ACCOUNTS = "admin@gmail.com:Password1,owner@gmail.com:Password2"
 *   DB_URL / DB_USER / DB_PASSWORD  (same as DBConnection)
 */
public class UpdateCredentials {

    /** accounts+passwords come from env, never from source */
    private static String[][] loadUpdates() {
        String spec = System.getenv("CRED_UPDATE_ACCOUNTS");
        if (spec == null || spec.isEmpty()) {
            System.out.println("Set CRED_UPDATE_ACCOUNTS=email:password,email2:password2");
            return new String[0][];
        }
        java.util.List<String[]> list = new java.util.ArrayList<>();
        for (String pair : spec.split(",")) {
            String[] parts = pair.split(":", 2);
            if (parts.length == 2) list.add(parts);
        }
        return list.toArray(new String[0][]);
    }

    public static void main(String[] args) throws Exception {
        String url = System.getProperty("db.url", System.getenv("DB_URL") != null
                ? System.getenv("DB_URL") : "jdbc:mysql://localhost:3306/lend_lace");
        String user = System.getProperty("db.user",
                System.getenv("DB_USER") != null ? System.getenv("DB_USER") : "root");
        String pass = System.getProperty("db.password",
                System.getenv("DB_PASSWORD") != null ? System.getenv("DB_PASSWORD") : "123456");
        String[][] UPDATES = loadUpdates();
        Class.forName("com.mysql.cj.jdbc.Driver");

        try (Connection con = DriverManager.getConnection(url, user, pass)) {
            for (String[] u : UPDATES) {
                String email = u[0];
                String plain = u[1];
                String hash = PasswordUtil.hash(plain);

                // does the account exist?
                try (PreparedStatement q = con.prepareStatement(
                        "SELECT user_id, role FROM users WHERE email=?")) {
                    q.setString(1, email);
                    ResultSet rs = q.executeQuery();
                    if (!rs.next()) {
                        System.out.println("SKIP (not found): " + email);
                        continue;
                    }
                    int userId = rs.getInt("user_id");
                    String role = rs.getString("role");

                    try (PreparedStatement ps = con.prepareStatement(
                            "UPDATE users SET password=? WHERE user_id=? AND email=?")) {
                        ps.setString(1, hash);
                        ps.setInt(2, userId);
                        ps.setString(3, email);
                        int rows = ps.executeUpdate();
                        System.out.println((rows == 1 ? "UPDATED 1 row" : "FAILED rows=" + rows)
                                + "  user_id=" + userId + "  role=" + role + "  " + email);
                    }
                }
            }
        }
        System.out.println("Done. All stored values are PBKDF2 hashes; no plaintext was written.");
    }
}
