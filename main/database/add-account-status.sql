-- Lend & Lace — schema change for Admin Customer Management
-- Adds a persistent account-status flag to users.
-- Values: 'ACTIVE' (default, existing behaviour) | 'SUSPENDED'
--
-- Run once:
--   mysql -u root -p lend_lace < database\add-account-status.sql

ALTER TABLE users
  ADD COLUMN status VARCHAR(10) NOT NULL DEFAULT 'ACTIVE' AFTER role;

-- existing accounts all become ACTIVE via the default above
