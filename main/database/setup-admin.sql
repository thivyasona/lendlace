-- ============================================================
-- Lend & Lace - Trusted ADMIN provisioning script
-- ============================================================
-- Run ONLY by a trusted administrator (never exposed to the web):
--   mysql -u root -p lend_lace < database/setup-admin.sql
--
-- You must replace <GENERATED_HASH> below with a real PBKDF2 hash.
-- Generate one with:
--   java -cp target\classes com.lendlace.util.PasswordUtil YourNewPassword
--
-- This script NEVER touches customer/owner/dress/booking rows.
-- It only creates or upgrades the single authorized ADMIN account.
-- ============================================================

-- Back up first (Windows CMD, run outside mysql):
--   mysqldump -u root -p lend_lace > lend_lace_backup_YYYYMMDD.sql

-- Option A: create the admin account fresh (idempotent via unique email)
INSERT INTO users (full_name, email, password, role, phone)
VALUES ('System Administrator', 'admin@gmail.com', '<GENERATED_HASH>', 'ADMIN', NULL)
ON DUPLICATE KEY UPDATE role = 'ADMIN', password = VALUES(password);

-- Option B (alternative): upgrade an existing row to ADMIN + hashed password
-- UPDATE users SET role='ADMIN',
--        password='<GENERATED_HASH>'
-- WHERE email='admin@gmail.com';

-- Verify
SELECT user_id, full_name, email, role, LEFT(password, 12) AS password_prefix
FROM users WHERE role = 'ADMIN';
