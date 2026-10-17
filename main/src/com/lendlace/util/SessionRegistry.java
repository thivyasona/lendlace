package com.lendlace.util;

import com.lendlace.model.User;

import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.HttpSessionEvent;
import jakarta.servlet.http.HttpSessionListener;

import java.util.Collections;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Tracks live sessions so the admin can invalidate a suspended customer's
 * session. Registered in web.xml as a listener.
 */
public class SessionRegistry implements HttpSessionListener {

    private static final Set<HttpSession> SESSIONS = Collections.newSetFromMap(new ConcurrentHashMap<>());

    @Override
    public void sessionCreated(HttpSessionEvent se) {
        SESSIONS.add(se.getSession());
    }

    @Override
    public void sessionDestroyed(HttpSessionEvent se) {
        SESSIONS.remove(se.getSession());
    }

    /** Live sessions only; invalid ones are pruned automatically. */
    public static Set<HttpSession> all() {
        SESSIONS.removeIf(s -> {
            try {
                s.getAttribute("loggedUser");
                return false;
            } catch (IllegalStateException e) {
                return true;
            }
        });
        return SESSIONS;
    }

    /** Helper for suspension: is this user currently logged in anywhere? */
    public static boolean isOnline(int userId) {
        for (HttpSession s : all()) {
            Object a = s.getAttribute("loggedUser");
            if (a instanceof User && ((User) a).getUserId() == userId)
                return true;
        }
        return false;
    }
}
