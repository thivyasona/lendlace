-- Optional: durable log of booking email notifications.
-- Lets the app record what was attempted (CUSTOMER_REQUEST / OWNER_REQUEST /
-- APPROVAL / REJECTION) and retry safely without sending duplicates.
--
-- Run once:
--   mysql -u root -p lend_lace < database\add-email-notification-log.sql

CREATE TABLE IF NOT EXISTS email_notification_log (
  log_id        INT NOT NULL AUTO_INCREMENT,
  booking_id    INT NOT NULL,
  notif_type    VARCHAR(30) NOT NULL,   -- CUSTOMER_REQUEST / OWNER_REQUEST / APPROVAL / REJECTION
  recipient     VARCHAR(100) NOT NULL,  -- email address (no other personal data)
  sent_ok       TINYINT(1)  NOT NULL DEFAULT 0,
  error_summary VARCHAR(120) DEFAULT NULL,
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (log_id),
  KEY idx_booking_type (booking_id, notif_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
