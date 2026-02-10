/**
 * EmailAttachment - Fluent wrapper for email attachments
 */
public with sharing class EmailAttachment {
    
    private String name;
    private Blob body;
    private String contentType;
    private Id cvId;
    
    /**
     * Set the filename
     */
    public EmailAttachment filename(String fileName) {
        this.name = fileName;
        return this;
    }
    
    /**
     * Set the content from a Blob
     */
    public EmailAttachment content(Blob blobContent) {
        this.body = blobContent;
        return this;
    }
    
    /**
     * Set the content type (MIME type)
     */
    public EmailAttachment contentType(String mimeType) {
        this.contentType = mimeType;
        return this;
    }
    
    /**
     * Set from ContentVersion Id
     */
    public EmailAttachment contentVersionId(Id contentVersionId) {
        this.cvId = contentVersionId;
        return this;
    }
    
    private ContentVersion cvRecord;

    /**
     * Get the ContentVersion Id
     */
    public Id getContentVersionId() {
        return this.cvId;
    }

    /**
     * Set the ContentVersion record directly (for bulkification)
     */
    public void setContentVersionSObject(ContentVersion cv) {
        this.cvRecord = cv;
    }
    
    /**
     * Convert to Salesforce EmailFileAttachment
     */
    public Messaging.EmailFileAttachment toEmailFileAttachment() {
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        
        if (this.cvRecord != null) {
            // Use pre-loaded record
            attachment.setFileName(this.cvRecord.Title + '.' + this.cvRecord.FileExtension);
            attachment.setBody(this.cvRecord.VersionData);
        } else if (this.cvId != null) {
            if (!Schema.sObjectType.ContentVersion.isAccessible()) {
                throw new EmailException('ContentVersion object is not accessible in this context');
            }

            // Load from ContentVersion
            ContentVersion cv = [
                SELECT VersionData, Title, FileExtension, ContentSize 
                FROM ContentVersion 
                WHERE Id = :this.cvId 
                LIMIT 1
            ];
            attachment.setFileName(cv.Title + '.' + cv.FileExtension);
            attachment.setBody(cv.VersionData);
        } else {
            attachment.setFileName(this.name);
            attachment.setBody(this.body);
            
            if (String.isNotBlank(this.contentType)) {
                attachment.setContentType(this.contentType);
            }
        }
        
        return attachment;
    }
}
