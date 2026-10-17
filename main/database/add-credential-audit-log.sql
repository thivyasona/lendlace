-- ============================================================
-- Lend & Lace - Credential audit log table
-- Safe migration: adds ONE new table, touches NO existing data.
-- Every email/password change (self-service or admin reset) is
-- recorded here so the final-year demo can show real audit logs.
--
-- Run with:
--   mysql -u root -p lend_lace < database/add-credential-audit-log.sql
-- ============================================================

USE lend_lace;

CREATE TABLE IF NOT EXISTS credential_audit_log (
    audit_id    INT           NOT NULL AUTO_INCREMENT,
    target_user INT           NOT NULL,               -- user whose credentials changed
    actor       VARCHAR(255)  NOT NULL,               -- 'self' or the admin's email
    action      VARCHAR(32)   NOT NULL,               -- 'PASSWORD_CHANGE' / 'EMAIL_CHANGE' / 'ADMIN_PASSWORD_RESET' / 'ADMIN_EMAIL_RESET'
    detail      VARCHAR(255)  NULL,                   -- e.g. 'email changed to ...' (never contains passwords)
    created_at  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (audit_id),
    KEY idx_target_user (target_user)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT 'credential_audit_log table ready' AS status;
