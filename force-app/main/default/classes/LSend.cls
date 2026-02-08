/**
 * LSend - Lightning Send: Fluent Email API for Salesforce
 * 
 * A modern, developer-friendly email framework for Apex
 * 
 * Usage:
 *   LSend.emails()
 *       .sender('Acme <noreply@acme.com>')
 *       .to('user@example.com')
 *       .subject('Hello World')
 *       .html('<p>It works!</p>')
 *       .send();
 */
public class LSend {
    
    /**
     * Start building an email
     * @return EmailBuilder instance for fluent chaining
     */
    public static EmailBuilder emails() {
        return new EmailBuilder();
    }
}
