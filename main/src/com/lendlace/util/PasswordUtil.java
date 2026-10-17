package com.lendlace.util;

import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;

/**
 * Password hashing with PBKDF2-WithHmacSHA256.
 * Stored format: pbkdf2:<iterations>:<base64 salt>:<base64 hash>
 * Legacy plaintext passwords (existing rows) are detected and re-hashed on
 * login.
 */
public class PasswordUtil {

    private static final int ITERATIONS = 120_000;
    private static final int SALT_BYTES = 16;
    private static final int KEY_BITS = 256;
    private static final String PREFIX = "pbkdf2";

    private PasswordUtil() {
    }

    /** Hash a new plaintext password. */
    public static String hash(String plain) {
        try {
            byte[] salt = new byte[SALT_BYTES];
            new SecureRandom().nextBytes(salt);
            byte[] dk = pbkdf2(plain, salt, ITERATIONS);
            return PREFIX + ":" + ITERATIONS + ":"
                    + Base64.getEncoder().encodeToString(salt) + ":"
                    + Base64.getEncoder().encodeToString(dk);
        } catch (Exception e) {
            throw new RuntimeException("Password hashing failed", e);
        }
    }

    /**
     * Verify a candidate password against a stored value.
     * Supports hashed entries and legacy plaintext (for migration).
     */
    public static boolean verify(String plain, String stored) {
        if (plain == null || stored == null || stored.isEmpty())
            return false;

        if (!stored.startsWith(PREFIX + ":")) {
            // legacy plaintext stored password -> constant-time-ish compare
            return MessageDigest.isEqual(
                    plain.getBytes(java.nio.charset.StandardCharsets.UTF_8),
                    stored.getBytes(java.nio.charset.StandardCharsets.UTF_8));
        }

        try {
            String[] parts = stored.split(":");
            int iterations = Integer.parseInt(parts[1]);
            byte[] salt = Base64.getDecoder().decode(parts[2]);
            byte[] expected = Base64.getDecoder().decode(parts[3]);
            byte[] actual = pbkdf2(plain, salt, iterations);
            return MessageDigest.isEqual(expected, actual);
        } catch (Exception e) {
            return false;
        }
    }

    /** True when the stored value is not yet hashed and should be migrated. */
    public static boolean needsRehash(String stored) {
        return stored == null || !stored.startsWith(PREFIX + ":");
    }

    private static byte[] pbkdf2(String plain, byte[] salt, int iterations) throws Exception {
        PBEKeySpec spec = new PBEKeySpec(plain.toCharArray(), salt, iterations, KEY_BITS);
        try {
            return SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256")
                    .generateSecret(spec).getEncoded();
        } finally {
            spec.clearPassword();
        }
    }

    /**
     * Small CLI: java com.lendlace.util.PasswordUtil <plaintext> -> prints a hash
     * (for provisioning scripts).
     */
    public static void main(String[] args) {
        if (args.length < 1) {
            System.out.println("Usage: PasswordUtil <plaintext-password>");
            return;
        }
        System.out.println(hash(args[0]));
    }
}
