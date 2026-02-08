/**
 * EmailBuilder - Fluent builder for constructing and sending emails
 * 
 * Provides a chainable API similar to modern email services
 */
public class EmailBuilder {
    
    private String fromAddress;
    private String fromName;
    private List<String> toAddresses = new List<String>();
    private List<String> ccAddresses = new List<String>();
    private List<String> bccAddresses = new List<String>();
    private String replyToAddress;
    private String subjectLine;
    private String htmlBody;
    private String textBody;
    private String templateName;
    private Id templateId;
    private Id targetObjectId;
    private Id whatId;
    private Map<String, String> templateVariables = new Map<String, String>();
    private List<EmailAttachment> attachments = new List<EmailAttachment>();
    private Map<String, String> tags = new Map<String, String>();
    private Boolean saveAsActivity = false;
    private String staticResourceName;
    
    /**
     * Set the sender address
     * Accepts format: "Name <email@example.com>" or just "email@example.com"
     */
    public EmailBuilder sender(String senderEmail) {
        if (senderEmail.contains('<') && senderEmail.contains('>')) {
            // Parse "Name <email>" format
            Integer startBracket = senderEmail.indexOf('<');
            Integer endBracket = senderEmail.indexOf('>');
            this.fromName = senderEmail.substring(0, startBracket).trim();
            this.fromAddress = senderEmail.substring(startBracket + 1, endBracket).trim();
        } else {
            this.fromAddress = senderEmail.trim();
        }
        return this;
    }
    
    /**
     * Set single recipient
     */
    public EmailBuilder to(String recipient) {
        this.toAddresses.add(recipient.trim());
        return this;
    }
    
    /**
     * Set multiple recipients
     */
    public EmailBuilder to(List<String> recipients) {
        for (String recipient : recipients) {
            this.toAddresses.add(recipient.trim());
        }
        return this;
    }
    
    /**
     * Add CC recipient
     */
    public EmailBuilder cc(String recipient) {
        this.ccAddresses.add(recipient.trim());
        return this;
    }
    
    /**
     * Add multiple CC recipients
     */
    public EmailBuilder cc(List<String> recipients) {
        for (String recipient : recipients) {
            this.ccAddresses.add(recipient.trim());
        }
        return this;
    }
    
    /**
     * Add BCC recipient
     */
    public EmailBuilder bcc(String recipient) {
        this.bccAddresses.add(recipient.trim());
        return this;
    }
    
    /**
     * Add multiple BCC recipients
     */
    public EmailBuilder bcc(List<String> recipients) {
        for (String recipient : recipients) {
            this.bccAddresses.add(recipient.trim());
        }
        return this;
    }
    
    /**
     * Set reply-to address
     */
    public EmailBuilder replyTo(String email) {
        this.replyToAddress = email.trim();
        return this;
    }
    
    /**
     * Set email subject
     */
    public EmailBuilder subject(String subj) {
        this.subjectLine = subj;
        return this;
    }
    
    /**
     * Set HTML body content
     */
    public EmailBuilder html(String content) {
        this.htmlBody = content;
        return this;
    }
    
    /**
     * Set plain text body content
     */
    public EmailBuilder text(String content) {
        this.textBody = content;
        return this;
    }
    
    /**
     * Use an email template by developer name
     */
    public EmailBuilder template(String templateDevName) {
        this.templateName = templateDevName;
        return this;
    }
    
    /**
     * Use an email template by Id
     */
    public EmailBuilder templateId(Id tempId) {
        this.templateId = tempId;
        return this;
    }
    
    /**
     * Set target object for template merge (Contact, Lead, User)
     */
    public EmailBuilder targetObject(Id objId) {
        this.targetObjectId = objId;
        return this;
    }
    
    /**
     * Set what object for template merge (related record)
     */
    public EmailBuilder whatObject(Id objId) {
        this.whatId = objId;
        return this;
    }
    
    /**
     * Add a template variable for merge
     */
    public EmailBuilder variable(String name, String value) {
        this.templateVariables.put(name, value);
        return this;
    }
    
    /**
     * Add multiple template variables
     */
    public EmailBuilder variables(Map<String, String> vars) {
        this.templateVariables.putAll(vars);
        return this;
    }
    
    /**
     * Add an attachment
     */
    public EmailBuilder attach(EmailAttachment attachment) {
        this.attachments.add(attachment);
        return this;
    }
    
    /**
     * Add attachment from Blob
     */
    public EmailBuilder attach(String filename, Blob content) {
        this.attachments.add(new EmailAttachment().filename(filename).content(content));
        return this;
    }
    
    /**
     * Add attachment from ContentVersion Id
     */
    public EmailBuilder attachContentVersion(Id contentVersionId) {
        this.attachments.add(new EmailAttachment().contentVersionId(contentVersionId));
        return this;
    }
    
    /**
     * Add a tag for tracking
     */
    public EmailBuilder tag(String name, String value) {
        this.tags.put(name, value);
        return this;
    }
    
    /**
     * Use an HTML template from a Static Resource
     * Variables in {{variableName}} format will be replaced
     * @param resourceName The name of the Static Resource containing the HTML template
     */
    public EmailBuilder staticResource(String resourceName) {
        this.staticResourceName = resourceName;
        return this;
    }
    
    /**
     * Use an HTML template from a Static Resource with variables
     * Variables in {{variableName}} format will be replaced
     * @param resourceName The name of the Static Resource containing the HTML template
     * @param vars Map of variable names and values to replace in template
     */
    public EmailBuilder staticResource(String resourceName, Map<String, String> vars) {
        this.staticResourceName = resourceName;
        this.templateVariables.putAll(vars);
        return this;
    }
    
    @TestVisible
    private static String mockStaticResourceBody;

    /**
     * Load and process Static Resource template
     * Replaces all {{variableName}} patterns with values from templateVariables
     */
    private String processStaticResourceTemplate() {
        String htmlContent;
        
        if (Test.isRunningTest() && mockStaticResourceBody != null) {
            htmlContent = mockStaticResourceBody;
        } else {
            List<StaticResource> resources = [
                SELECT Body FROM StaticResource 
                WHERE Name = :this.staticResourceName 
                LIMIT 1
            ];
            
            if (resources.isEmpty()) {
                throw new EmailException('Static Resource not found: ' + this.staticResourceName);
            }
            
            htmlContent = resources[0].Body.toString();
        }
        
        // Replace all {{variableName}} patterns
        for (String varName : this.templateVariables.keySet()) {
            String placeholder = '{{' + varName + '}}';
            String value = this.templateVariables.get(varName);
            htmlContent = htmlContent.replace(placeholder, value != null ? value : '');
        }
        
        return htmlContent;
    }
    
    /**
     * Save email as an activity on the record
     */
    public EmailBuilder saveActivity(Boolean save) {
        this.saveAsActivity = save;
        return this;
    }
    
    /**
     * Validate required fields before sending
     */
    private void validate() {
        if (this.toAddresses.isEmpty()) {
            throw new EmailException('At least one recipient (to) is required');
        }
        
        if (String.isBlank(this.htmlBody) && String.isBlank(this.textBody) && 
            String.isBlank(this.templateName) && this.templateId == null &&
            String.isBlank(this.staticResourceName)) {
            throw new EmailException('Email body (html, text), template, or staticResource is required');
        }
    }
    
    /**
     * Build and send the email
     */
    public EmailResult send() {
        validate();
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        
        // Set recipients
        email.setToAddresses(this.toAddresses);
        
        if (!this.ccAddresses.isEmpty()) {
            email.setCcAddresses(this.ccAddresses);
        }
        
        if (!this.bccAddresses.isEmpty()) {
            email.setBccAddresses(this.bccAddresses);
        }
        
        // Set reply-to
        if (String.isNotBlank(this.replyToAddress)) {
            email.setReplyTo(this.replyToAddress);
        }
        
        // Set sender name if provided
        if (String.isNotBlank(this.fromName)) {
            email.setSenderDisplayName(this.fromName);
        }
        
        // Handle Static Resource template first
        if (String.isNotBlank(this.staticResourceName)) {
            String processedHtml = processStaticResourceTemplate();
            this.htmlBody = processedHtml;
        }
        
        // Handle Salesforce template or direct content
        if (this.templateId != null || String.isNotBlank(this.templateName)) {
            // Use Salesforce Email Template
            Id tempId = this.templateId;
            if (tempId == null && String.isNotBlank(this.templateName)) {
                List<EmailTemplate> templates = [
                    SELECT Id FROM EmailTemplate 
                    WHERE DeveloperName = :this.templateName 
                    LIMIT 1
                ];
                if (templates.isEmpty()) {
                    throw new EmailException('Template not found: ' + this.templateName);
                }
                tempId = templates[0].Id;
            }
            
            email.setTemplateId(tempId);
            
            if (this.targetObjectId != null) {
                email.setTargetObjectId(this.targetObjectId);
            }
            
            if (this.whatId != null) {
                email.setWhatId(this.whatId);
            }
        } else {
            // Use direct content (including Static Resource processed HTML)
            email.setSubject(this.subjectLine);
            
            if (String.isNotBlank(this.htmlBody)) {
                email.setHtmlBody(this.htmlBody);
            }
            
            if (String.isNotBlank(this.textBody)) {
                email.setPlainTextBody(this.textBody);
            }
        }
        
        // Handle attachments
        if (!this.attachments.isEmpty()) {
            List<Messaging.EmailFileAttachment> fileAttachments = new List<Messaging.EmailFileAttachment>();
            
            for (EmailAttachment att : this.attachments) {
                fileAttachments.add(att.toEmailFileAttachment());
            }
            
            email.setFileAttachments(fileAttachments);
        }
        
        // Save as activity
        email.setSaveAsActivity(this.saveAsActivity);
        
        // Send the email
        try {
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(
                new List<Messaging.SingleEmailMessage>{ email }
            );
            
            Messaging.SendEmailResult result = results[0];
            
            if (result.isSuccess()) {
                return new EmailResult(true, null);
            } else {
                String errorMsg = '';
                for (Messaging.SendEmailError error : result.getErrors()) {
                    errorMsg += error.getMessage() + '; ';
                }
                return new EmailResult(false, errorMsg.removeEnd('; '));
            }
        } catch (Exception e) {
            throw new EmailException('Failed to send email: ' + e.getMessage());
        }
    }
}
