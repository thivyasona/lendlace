# Lend & Lace — Final Change Report (Admin Customers + Booking Emails)

Date: 2026-10-14. Build: `mvn clean package` (Java 17, WAR) — BUILD OK, deployed
to Tomcat 10.1.55 at `http://localhost:8080/main/`, serving the latest build
(verified: new classes present in `webapps\main\WEB-INF\classes`).

## Files changed and why

| File | Change |
|---|---|
| `main/database/add-account-status.sql` | NEW — adds `users.status` ('ACTIVE'/'SUSPENDED') |
| `main/database/add-email-notification-log.sql` | NEW — creates `email_notification_log` audit table |
| `main/database/SMTP-CONFIG.md` | NEW — SMTP configuration + test guide |
| `main/src/com/lendlace/dao/CustomerDAO.java` | NEW — real-MySQL customer search/filter/sort with booking counts, status get/set, guarded delete, booking history |
| `main/src/com/lendlace/servlet/AdminCustomerServlet.java` | NEW — `/adminCustomer` GET (list + view details) and POST (suspend/reactivate/deactivate/delete), ADMIN-only, self-protection, session invalidation |
| `main/src/com/lendlace/util/SessionRegistry.java` | NEW — HttpSessionListener that tracks live sessions so suspended customers are logged out |
| `main/src/com/lendlace/util/BookingEmailService.java` | NEW — booking email orchestration: resolves customer/owner emails from the users table, logs every attempt in `email_notification_log`, returns true only when SMTP accepted the mail |
| `main/src/com/lendlace/util/EmailTemplates.java` | NEW — 4 branded responsive HTML templates (request received, new request to owner, approved, rejected); amounts shown only when available; app link only when APP_BASE_URL configured |
| `main/src/com/lendlace/util/EmailUtil.java` | MODIFIED — added HTML sending with plain-text fallback part, connection/read/write timeouts, configurable TLS mode (`mail.smtp.starttls` = required/true/false) |
| `main/src/com/lendlace/servlet/BookingServlet.java` | MODIFIED — after a booking row is successfully saved, sends customer + owner request emails; failure never reverses the save |
| `main/src/com/lendlace/servlet/OwnerBookingServlet.java` | MODIFIED — after a successful (row-actually-changed) approve/reject via the atomic `updateStatusIfPendingForOwner`, sends the decision email; repeated clicks (result 0) send nothing |
| `main/src/com/lendlace/servlet/LoginServlet.java` | MODIFIED — suspended accounts are refused login (`login.jsp?suspended=1`) |
| `main/WebContent/login.jsp` | MODIFIED — friendly "account suspended" alert |
| `main/WebContent/admin-dashboard.jsp` | MODIFIED — Manage Customers section now served from the fragment via `<jsp:include>` |
| `main/WebContent/WEB-INF/fragments/manage-customers-section.jsp` | NEW — full customer table (ID, name, email, phone, registered date, status badge, total/completed bookings), search/filter/sort bar with clear button, per-row View/Suspend/Deactivate/Delete/Reactivate with JS confirmations, View Details card with booking history + empty state, success/error alerts |
| `main/WebContent/WEB-INF/web.xml` | MODIFIED — registered `SessionRegistry` listener and `/adminCustomer` in the AuthFilter mapping |
| `main/test-tools/MailProbe.java` | NEW — dev-only SMTP probe used during debugging |
| `test-suite-customer.ps1`, `test-suite-emails.ps1` | NEW — automated test harnesses (live app + real MySQL) |

## Database changes (applied to live `lend_lace` DB)

1. `users.status VARCHAR(10) NOT NULL DEFAULT 'ACTIVE'` — smallest compatible
   change; existing roles/passwords/profile data untouched.
2. `email_notification_log` table (log_id, booking_id, notif_type, recipient,
   sent_ok, error_summary, created_at) — no FK to bookings so a customer/dress
   removal never breaks the audit trail. SQL scripts are in `main\database\`.

## Manage Customers features

- Table shows ID, name, email, phone, registration date, Active/Suspended badge,
  total bookings, completed bookings — all from real MySQL joins (no fabricated data).
- Search (name/email), status filter, sort by registration date or booking count,
  and a Clear button.
- View Details: profile, status, counts, and full booking history (dress, dates,
  amount, status); customers with no bookings get an explicit empty-state message.
- Suspend: persisted in MySQL, immediately blocks login and new bookings,
  invalidates the customer's live sessions; Reactivate restores access.
- Deactivate: same persistent suspension, presented as the preferred option when
  history exists (all booking records are preserved).
- Delete: hard `DELETE FROM users` only for customers with **zero** bookings and
  **zero** paid payments; blocked with an explanatory message otherwise; admin
  accounts and the acting admin's own row can never be touched (server-side check).

## Email service configuration

See `main\database\SMTP-CONFIG.md`. No credentials in source or JSPs; config is
read from env vars/system properties (`MAIL_SMTP_HOST/PORT/USER/PASS/FROM/STARTTLS`,
`APP_BASE_URL`). Timeouts: 10 s connect, 15 s read/write. STARTTLS modes:
`required` (real providers), `true` (default, opportunistic), `false` (local sink).

## Templates created

1. Booking request received (customer) — amber "Awaiting owner decision" banner,
   explicitly states the booking is **not yet approved** and no payment is due.
2. New booking request (owner) — reference, dress, dates, amount, review reminder.
3. Booking approved (customer) — green "Approved" banner, reference, dress,
   dates, total; clarifies it is a booking decision, not a payment confirmation.
4. Booking rejected (customer) — red "Rejected" banner, reference, dress, dates.

## Test results (run against the live app + real MySQL)

Customer suite (`test-suite-customer.ps1`): **21 PASS / 0 FAIL**
- List renders real records; search/filters/sort work; details show correct
  booking history; suspended user cannot log in (redirect `suspended=1`);
  reactivated user can log in; admin self-modification blocked (DB status stays
  ACTIVE); delete blocked with history (row preserved), succeeds with none;
  non-admin gets 403 on /adminCustomer.

Email suite (`test-suite-emails.ps1`): **13 PASS / 0 FAIL** (live SMTP sink)
- Booking submitted via the real form → row saved Pending + CUSTOMER_REQUEST and
  OWNER_REQUEST mails delivered to the sink, captured content contains the
  booking reference, dress name, dates, amounts, and the "awaiting decision"
  wording; approval persisted then APPROVAL mail delivered; repeated approve
  click → no duplicate email; reject → REJECTION mail; invalid bookings never
  trigger success mails; unauthorized owner approvals still blocked by the
  existing atomic owner check; status in MySQL stayed consistent throughout.

**Live delivery to a real external inbox (e.g. Gmail): NOT RUN** — no real SMTP
credentials are configured on this machine. Delivery to the local test sink was
verified end-to-end; the configuration steps above are all that is needed to go live.

## Remaining limitations

- Notification retry: failures are recorded (`sent_ok=0` + error_summary) but an
  automatic retry job is not included; re-sending requires the original workflow
  (a new decision cannot re-send because repeated clicks are deliberately ignored).
- A booking is emailed to the dress owner via the dress's current owner; if the
  dress is later deleted, historical notification logs remain but the owner
  contact for new events is naturally unavailable.
- Admin panel pagination: not previously implemented for the customer table and
  still not present (search/filter/sort work on the full result set).
