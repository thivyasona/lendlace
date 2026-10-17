-- ============================================================
-- Lend & Lace - Forgot Password token storage
-- Safe migration: adds ONE new table, touches NO existing data.
-- Existing tables (users, dresses, bookings, reviews, payments,
-- wishlist) are not modified in any way.
--
-- Run with:
--   "C:\Program Files\MySQL\MySQL Server 9.7\bin\mysql.exe" -u root -p lend_lace < database\add-password-reset-tokens.sql
-- ============================================================

USE lend_lace;

CREATE TABLE IF NOT EXISTS password_reset_tokens (
    token_id      INT           NOT NULL AUTO_INCREMENT,
    user_id       INT           NOT NULL,
    token_hash    CHAR(64)      NOT NULL,          -- SHA-256 hex of the emailed token (token itself is NEVER stored)
    expires_at    TIMESTAMP     NOT NULL,          -- 30 minutes after issue
    used_at       TIMESTAMP     NULL     DEFAULT NULL,  -- set when consumed; single use
    created_at    TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (token_id),
    UNIQUE KEY uq_token_hash (token_hash),
    KEY idx_user_id (user_id),
    CONSTRAINT fk_prt_user FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT 'password_reset_tokens table ready' AS status;
