package com.lendlace.util;

import java.sql.Connection;
import java.sql.DriverManager;

/**
 * MySQL connection factory.
 *
 * Configuration comes from the environment so credentials are never baked
 * into the WAR for a public deployment (system properties win, then env vars,
 * then safe local-development defaults):
 *
 *   -Ddb.url=jdbc:mysql://host:3306/lend_lace   (or DB_URL)
 *   -Ddb.user=app_user                          (or DB_USER)
 *   -Ddb.password=...                           (or DB_PASSWORD)
 *
 * Defaults keep the existing local setup working: localhost / root / 123456.
 * For hosting, set DB_URL/DB_USER/DB_PASSWORD in the Tomcat service
 * environment (setenv.bat or systemd unit) - see database/DEPLOY-AND-TEST.md.
 */
public class DBConnection {

    private static final String URL = envOr("db.url", "DB_URL",
            "jdbc:mysql://localhost:3306/lend_lace");

    private static final String USER = envOr("db.user", "DB_USER", "root");

    private static final String PASSWORD = envOr("db.password", "DB_PASSWORD", "123456");

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

    private static String envOr(String sysProp, String envVar, String fallback) {
        String v = System.getProperty(sysProp);
        if (v == null || v.isEmpty()) {
            v = System.getenv(envVar);
        }
        return (v == null || v.isEmpty()) ? fallback : v;
    }

    public static Connection getConnection() {

        try {

            return DriverManager.getConnection(URL, USER, PASSWORD);

        } catch (Exception e) {

            e.printStackTrace();
            return null;
        }
    }
}