import com.lendlace.util.EmailUtil;

public class MailProbe {
    public static void main(String[] a) {
        System.setProperty("mail.smtp.host", "localhost");
        System.setProperty("mail.smtp.port", "2525");
        System.setProperty("mail.smtp.user", "dev@localhost");
        System.setProperty("mail.smtp.pass", "devpassword");
        System.out.println("configured=" + EmailUtil.isConfigured());
        boolean ok = EmailUtil.send("probe@example.com", "probe test", "hello");
        System.out.println("send=" + ok);
        try {
            java.util.Properties p = new java.util.Properties();
            p.put("mail.smtp.auth", "true");
            p.put("mail.smtp.host", "localhost");
            p.put("mail.smtp.port", "2525");
            jakarta.mail.Session s = jakarta.mail.Session.getInstance(p);
            s.setDebug(true);
            jakarta.mail.Transport t = s.getTransport("smtp");
            t.connect("dev@localhost", "devpassword");
            t.close();
            System.out.println("raw connect OK");
        } catch (Exception e) {
            System.out.println("RAW ERR: " + e);
        }
    }
}
