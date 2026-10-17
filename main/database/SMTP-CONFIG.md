# Lend & Lace — SMTP Email Configuration Guide

Booking email notifications (request received / new request / approved / rejected)
are sent by `com.lendlace.util.BookingEmailService` through `EmailUtil`.
**No credentials are hard-coded** — everything comes from environment variables
(or Java system properties). Tomcat reads them from `bin\setenv.bat`.
## Where the config lives locally
`%CATALINA_HOME%\bin\setenv.bat` — currently set for **local development only**
(`localhost:2525`, the test SMTP sink in `main\test-tools\SmtpSink.java`).

## Configure real email delivery (Gmail example)
Edit `setenv.bat`:

```bat
set "MAIL_SMTP_HOST=smtp.gmail.com"
set "MAIL_SMTP_PORT=587"
set "MAIL_SMTP_USER=youraccount@gmail.com"
set "MAIL_SMTP_PASS=your-16-char-app-password"
set "MAIL_SMTP_STARTTLS=required"
set "MAIL_FROM=youraccount@gmail.com"
set "APP_BASE_URL=https://your-production-domain/main"
```

**Important:** Gmail will reject your normal account password. You must create a
Google **App Password** (Google Account → Security → 2-Step Verification → App
passwords). Use that 16-character password in `MAIL_SMTP_PASS`.

Other providers: swap host/port (e.g. Outlook: `smtp.office365.com:587`,
SendGrid: `smtp.sendgrid.net:587` with user `apikey`). `MAIL_SMTP_STARTTLS`
supports `required` (enforce TLS — use for real providers), `true`
(opportunistic, default), or `false` (plain-text; only for the local test sink).

`APP_BASE_URL`: set it to the reachable public URL of the app. The emails only
include a "Visit Lend & Lace" button when this is configured — no fake localhost
links are ever sent to real customers.

## Apply the change

```
%CATALINA_HOME%\bin\catalina.bat stop
%CATALINA_HOME%\bin\startup.bat
```

## Test it

1. Log in as a customer and submit a booking on one of your own dresses
   (or any dress whose owner email you control).
2. Check both inboxes (customer + owner) for the two request emails.
3. As the owner, approve → customer inbox receives the approval email.
4. Check the audit trail in MySQL:
   `SELECT * FROM email_notification_log ORDER BY log_id DESC;`
   (`sent_ok=1` = accepted by the SMTP server; `error_summary` explains failures.)

## Local test sink (no external account needed)

```
cd main
javac -d test-tools test-tools\SmtpSink.java
javaw -cp test-tools SmtpSink        # listens on port 2525, appends to smtp-capture.txt
```
…then keep `setenv.bat` pointing at `localhost:2525`. Every mail the app sends is
appended to `main\smtp-capture.txt`. This is how the automated tests verified
real delivery.
