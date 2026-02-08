/**
 * EmailResult - Result wrapper for email send operations
 */
public class EmailResult {
    
    @AuraEnabled public Boolean success { get; private set; }
    @AuraEnabled public String error { get; private set; }
    @AuraEnabled public String id { get; private set; }
    
    public EmailResult(Boolean isSuccess, String errorMessage) {
        this.success = isSuccess;
        this.error = errorMessage;
        this.id = generateId();
    }
    
    private String generateId() {
        // Generate a UUID-like string for tracking
        Blob b = Crypto.generateAesKey(128);
        String h = EncodingUtil.convertToHex(b);
        return h.substring(0, 8) + '-' + 
               h.substring(8, 12) + '-' + 
               h.substring(12, 16) + '-' + 
               h.substring(16, 20) + '-' + 
               h.substring(20);
    }
    
    /**
     * Check if email was sent successfully
     */
    public Boolean isSuccess() {
        return this.success;
    }
    
    /**
     * Get the error message if failed
     */
    public String getError() {
        return this.error;
    }
    
    /**
     * Get the email ID for tracking
     */
    public String getId() {
        return this.id;
    }
}
