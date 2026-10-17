
// Tiny SMTP sink: accepts any mail on port 2525 and prints it to a file.
// Test-only helper, not part of the webapp.
import java.io.*;
import java.net.*;
import java.nio.charset.StandardCharsets;

public class SmtpSink {
    public static void main(String[] args) throws Exception {
        try (ServerSocket ss = new ServerSocket(2525)) {
            System.out.println("SMTP sink on 2525");
            while (true) {
                try (Socket s = ss.accept();
                        BufferedReader in = new BufferedReader(
                                new InputStreamReader(s.getInputStream(), StandardCharsets.UTF_8));
                        PrintWriter out = new PrintWriter(
                                new OutputStreamWriter(s.getOutputStream(), StandardCharsets.UTF_8), true)) {
                    out.println("220 test.local SMTP");
                    String line;
                    StringBuilder data = new StringBuilder();
                    boolean inData = false;
                    while ((line = in.readLine()) != null) {
                        if (!inData) {
                            String cmd = line.toUpperCase();
                            if (cmd.startsWith("DATA")) {
                                out.println("354 go");
                                inData = true;
                                continue;
                            }
                            if (cmd.startsWith("QUIT")) {
                                out.println("221 bye");
                                break;
                            }
                            out.println("250 ok");
                        } else {
                            if (line.equals(".")) {
                                inData = false;
                                try (PrintWriter f = new PrintWriter(new FileWriter(
                                        "C:\\Users\\THIVYA SONA\\Downloads\\LendAndLace_Admin_Booking_Fix\\main\\smtp-capture.txt",
                                        true))) {
                                    f.println("=== MAIL ===");
                                    f.println(data);
                                }
                                data.setLength(0);
                                out.println("250 accepted");
                            } else {
                                data.append(line).append('\n');
                            }
                        }
                    }
                } catch (Exception ignore) {
                }
            }
        }
    }
}
