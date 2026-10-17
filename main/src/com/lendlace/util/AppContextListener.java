package com.lendlace.util;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

import java.sql.Driver;
import java.sql.DriverManager;
import java.util.Enumeration;

/**
 * Cleanly stops MySQL Connector/J background threads when the webapp stops,
 * preventing the "web application started a thread but failed to stop it"
 * memory-leak warnings and classloader leaks on redeploy/shutdown.
 */
@WebListener
public class AppContextListener implements ServletContextListener {

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        // abort the Connector/J cleanup thread (reflection: method name differs across driver versions)
        try {
            Class<?> cls = Class.forName("com.mysql.cj.jdbc.AbandonedConnectionCleanupThread");
            try {
                cls.getMethod("shutdownNow").invoke(null);
            } catch (NoSuchMethodException e) {
                cls.getMethod("shutdown").invoke(null);
            }
        } catch (Exception ignored) { }

        Enumeration<Driver> drivers = DriverManager.getDrivers();
        while (drivers.hasMoreElements()) {
            Driver driver = drivers.nextElement();
            if (driver.getClass().getClassLoader() == getClass().getClassLoader()) {
                try {
                    DriverManager.deregisterDriver(driver);
                } catch (Exception ignored) {
                }
            }
        }
    }
}
