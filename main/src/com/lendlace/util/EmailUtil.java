package com.lendlace.util;

import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeBodyPart;
import jakarta.mail.internet.MimeMessage;
import jakarta.mail.internet.MimeMultipart;

import java.util.Properties;

/**
 * Minimal SMTP sender for password-reset emails.
 *
 * Configuration (system properties or environment variables):
 * -Dmail.smtp.host=smtp.gmail.com (or MAIL_SMTP_HOST)
 * -Dmail.smtp.port=587 (or MAIL_SMTP_PORT)
 * -Dmail.smtp.user=you@gmail.com (or MAIL_SMTP_USER)
 * -Dmail.smtp.pass=app-password (or MAIL_SMTP_PASS)
 * -Dmail.from=you@gmail.com (or MAIL_FROM, optional; defaults to
 * mail.smtp.user)
 *
 * If host/user/pass are not configured, isConfigured() returns false and the
 * caller must tell the user how to configure SMTP rather than pretending a
 * mail was sent.
 */
public class EmailUtil {

    private EmailUtil() {
    }

    public static boolean isConfigured() {
        return prop("mail.smtp.host") != null && !prop("mail.smtp.host").isEmpty()
                && prop("mail.smtp.user") != null && !prop("mail.smtp.user").isEmpty();
    }

    /** True reason of the most recent send failure ("not configured" when SMTP settings are missing). */
    private static String lastError = null;
    public static String getLastError() {
        if (!isConfigured())
            return "SMTP not configured (set MAIL_SMTP_HOST / MAIL_SMTP_USER / MAIL_SMTP_PASS)";
        return lastError == null ? "unknown" : lastError;
    }

    /** Sends an email; returns true only when the mail server accepted it. */
    public static boolean send(String to, String subject, String body) {
        return sendInternal(to, null, subject, body, false);
    }

    /**
     * Sends a branded HTML email; returns true only when the mail server
     * accepted it. Used by BookingEmailService for booking notifications.
     */
    public static boolean sendHtml(String to, String toName, String subject, String html) {
        return sendInternal(to, toName, subject, html, true);
    }

    private static boolean sendInternal(String to, String toName, String subject,
                                        String body, boolean html) {
        if (!isConfigured()) {
            return false;
        }
        Properties p = new Properties();
        p.put("mail.smtp.auth", "true");
        p.put("mail.smtp.starttls.enable", "true");
        p.put("mail.smtp.host", prop("mail.smtp.host"));
        p.put("mail.smtp.port", prop("mail.smtp.port") == null ? "587" : prop("mail.smtp.port"));
        // timeouts so an unresponsive SMTP server can never hang a booking request
        p.put("mail.smtp.connectiontimeout", "10000");
        p.put("mail.smtp.timeout", "15000");
        p.put("mail.smtp.writetimeout", "15000");
        // TLS mode: 'required' | 'true' (opportunistic, default) | 'false' (plain-text test sinks)
        String tlsMode = prop("mail.smtp.starttls");
        if (tlsMode == null || tlsMode.isEmpty()) tlsMode = "true";
        if ("required".equalsIgnoreCase(tlsMode)) {
            p.put("mail.smtp.starttls.enable", "true");
            p.put("mail.smtp.starttls.required", "true");
        } else if ("false".equalsIgnoreCase(tlsMode)) {
            p.put("mail.smtp.starttls.enable", "false");
        } else {
            p.put("mail.smtp.starttls.enable", "true");
        }

        String user = prop("mail.smtp.user");
        String pass = prop("mail.smtp.pass");
        String from = prop("mail.from") != null ? prop("mail.from") : user;

        try {
            Session session = Session.getInstance(p, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(user, pass);
                }
            });
            MimeMessage msg = new MimeMessage(session);
            msg.setFrom(new InternetAddress(from));
            msg.setRecipients(Message.RecipientType.TO,
                    InternetAddress.parse(to, false));
            if (toName != null && !toName.isEmpty()) {
                try {
                    msg.addRecipient(Message.RecipientType.TO,
                            new InternetAddress(to, toName, "UTF-8"));
                } catch (Exception ignore) {
                    // plain address was already set above
                }
            }
            msg.setSubject(subject, "UTF-8");
            if (html) {
                MimeBodyPart part = new MimeBodyPart();
                part.setContent(body, "text/html; charset=UTF-8");
                MimeMultipart multi = new MimeMultipart("alternative");
                MimeBodyPart plain = new MimeBodyPart();
                plain.setText(stripHtml(body), "UTF-8");
                multi.addBodyPart(plain);
                multi.addBodyPart(part);
                msg.setContent(multi);
            } else {
                msg.setText(body, "UTF-8");
            }
            Transport.send(msg);
            return true;
        } catch (Exception e) {
            // Log the real failure (class + message) so "email not received"
            // reports are diagnosable - but never credentials or message content.
            String why = e.getMessage() == null ? "" : e.getMessage();
            System.err.println("Email send failed: " + e.getClass().getSimpleName()
                    + (why.isEmpty() ? "" : " - " + why.split("\n")[0]));
            lastError = e.getClass().getSimpleName() + (why.isEmpty() ? "" : ": " + why.split("\n")[0]);
            return false;
        }
    }

    /** Plain-text fallback for the alternative part of HTML mails. */
    private static String stripHtml(String html) {
        return html == null ? ""
                : html.replaceAll("<style[\\s\\S]*?</style>", "")
                      .replaceAll("<[^>]+>", " ")
                      .replaceAll("&amp;", "&").replaceAll("&lt;", "<")
                      .replaceAll("&gt;", ">").replaceAll("&quot;", "\"")
                      .replaceAll("\\s+", " ").trim();
    }

    private static String prop(String key) {
        String v = System.getProperty(key);
        if (v == null || v.isEmpty()) {
            v = System.getenv(key.toUpperCase().replace('.', '_'));
        }
        return v;
    }
}
