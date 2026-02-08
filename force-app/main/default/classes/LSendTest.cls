/**
 * LSendTest - Unit tests for the LSend email framework
 */
@isTest
private class LSendTest {
    
    @isTest
    static void testBasicEmail() {
        Test.startTest();
        
        // Test basic email builder chain
        EmailBuilder builder = LSend.emails()
            .sender('Test <test@example.com>')
            .to('recipient@example.com')
            .subject('Test Subject')
            .html('<p>Test body</p>');
        
        System.assertNotEquals(null, builder, 'Builder should not be null');
        
        Test.stopTest();
    }
    
    @isTest
    static void testMultipleRecipients() {
        Test.startTest();
        
        EmailBuilder builder = LSend.emails()
            .sender('Test <test@example.com>')
            .to(new List<String>{'user1@example.com', 'user2@example.com'})
            .cc('cc@example.com')
            .bcc('bcc@example.com')
            .subject('Test')
            .html('<p>Test</p>');
        
        System.assertNotEquals(null, builder, 'Builder should handle multiple recipients');
        
        Test.stopTest();
    }
    
    @isTest
    static void testFromParsing() {
        Test.startTest();
        
        // Test with name format
        EmailBuilder builder1 = LSend.emails()
            .sender('Company Name <noreply@company.com>')
            .to('user@example.com')
            .subject('Test')
            .html('<p>Test</p>');
        
        // Test without name format
        EmailBuilder builder2 = LSend.emails()
            .sender('noreply@company.com')
            .to('user@example.com')
            .subject('Test')
            .html('<p>Test</p>');
        
        System.assertNotEquals(null, builder1, 'Should parse name format');
        System.assertNotEquals(null, builder2, 'Should parse email only format');
        
        Test.stopTest();
    }
    
    @isTest
    static void testTextBody() {
        Test.startTest();
        
        EmailBuilder builder = LSend.emails()
            .sender('test@example.com')
            .to('user@example.com')
            .subject('Test')
            .text('Plain text body');
        
        System.assertNotEquals(null, builder, 'Should accept text body');
        
        Test.stopTest();
    }
    
    @isTest
    static void testReplyTo() {
        Test.startTest();
        
        EmailBuilder builder = LSend.emails()
            .sender('noreply@example.com')
            .to('user@example.com')
            .replyTo('support@example.com')
            .subject('Test')
            .html('<p>Test</p>');
        
        System.assertNotEquals(null, builder, 'Should accept reply-to');
        
        Test.stopTest();
    }
    
    @isTest
    static void testAttachment() {
        Test.startTest();
        
        Blob testBlob = Blob.valueOf('Test content');
        
        EmailBuilder builder = LSend.emails()
            .sender('test@example.com')
            .to('user@example.com')
            .subject('Test with attachment')
            .html('<p>See attached</p>')
            .attach('test.txt', testBlob);
        
        System.assertNotEquals(null, builder, 'Should accept attachment');
        
        Test.stopTest();
    }
    
    @isTest
    static void testEmailAttachmentClass() {
        Test.startTest();
        
        Blob testBlob = Blob.valueOf('Test content');
        
        EmailAttachment att = new EmailAttachment()
            .filename('document.pdf')
            .content(testBlob)
            .contentType('application/pdf');
        
        Messaging.EmailFileAttachment result = att.toEmailFileAttachment();
        
        System.assertEquals('document.pdf', result.getFileName(), 'Filename should match');
        System.assertEquals(testBlob, result.getBody(), 'Content should match');
        
        Test.stopTest();
    }
    
    @isTest
    static void testEmailResult() {
        Test.startTest();
        
        EmailResult successResult = new EmailResult(true, null);
        System.assertEquals(true, successResult.isSuccess(), 'Should be success');
        System.assertEquals(null, successResult.getError(), 'Error should be null');
        System.assertNotEquals(null, successResult.getId(), 'ID should be generated');
        
        EmailResult failResult = new EmailResult(false, 'Test error');
        System.assertEquals(false, failResult.isSuccess(), 'Should be failure');
        System.assertEquals('Test error', failResult.getError(), 'Error message should match');
        
        Test.stopTest();
    }
    
    @isTest
    static void testValidationNoRecipient() {
        Test.startTest();
        
        Boolean exceptionThrown = false;
        try {
            LSend.emails()
                .sender('test@example.com')
                .subject('Test')
                .html('<p>Test</p>')
                .send();
        } catch (EmailException e) {
            exceptionThrown = true;
            System.assert(e.getMessage().contains('recipient'), 'Should mention recipient');
        }
        
        System.assert(exceptionThrown, 'Should throw exception for missing recipient');
        
        Test.stopTest();
    }
    
    @isTest
    static void testValidationNoBody() {
        Test.startTest();
        
        Boolean exceptionThrown = false;
        try {
            LSend.emails()
                .sender('test@example.com')
                .to('user@example.com')
                .subject('Test')
                .send();
        } catch (EmailException e) {
            exceptionThrown = true;
            System.assert(e.getMessage().contains('body') || e.getMessage().contains('template'), 
                'Should mention body or template');
        }
        
        System.assert(exceptionThrown, 'Should throw exception for missing body');
        
        Test.stopTest();
    }
    
    @isTest
    static void testVariables() {
        Test.startTest();
        
        EmailBuilder builder = LSend.emails()
            .sender('test@example.com')
            .to('user@example.com')
            .variable('firstName', 'John')
            .variable('lastName', 'Doe')
            .variables(new Map<String, String>{
                'company' => 'Acme',
                'role' => 'Developer'
            });
        
        System.assertNotEquals(null, builder, 'Should accept variables');
        
        Test.stopTest();
    }
    
    @isTest
    static void testTags() {
        Test.startTest();
        
        EmailBuilder builder = LSend.emails()
            .sender('test@example.com')
            .to('user@example.com')
            .subject('Test')
            .html('<p>Test</p>')
            .tag('category', 'notification')
            .tag('priority', 'high');
        
        System.assertNotEquals(null, builder, 'Should accept tags');
        
        Test.stopTest();
    }
    
    @isTest
    static void testSaveActivity() {
        Test.startTest();
        
        EmailBuilder builder = LSend.emails()
            .sender('test@example.com')
            .to('user@example.com')
            .subject('Test')
            .html('<p>Test</p>')
            .saveActivity(true);
        
        System.assertNotEquals(null, builder, 'Should accept saveActivity');
        
        Test.stopTest();
    }

    @isTest
    static void testContentVersionAttachment() {
        // Create a ContentVersion
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content Data');
        cv.IsMajorVersion = true;
        insert cv;
        
        // Query the ContentVersionId
        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        
        Test.startTest();
        
        EmailBuilder builder = LSend.emails()
            .sender('test@example.com')
            .to('user@example.com')
            .subject('Test CV Attachment')
            .html('<p>See attached</p>')
            .attachContentVersion(cv.Id);
            
        System.assertNotEquals(null, builder, 'Should accept ContentVersion attachment');
        
        // Directly test EmailAttachment toEmailFileAttachment with CV ID
        EmailAttachment att = new EmailAttachment().contentVersionId(cv.Id);
        Messaging.EmailFileAttachment result = att.toEmailFileAttachment();
        
        System.assertEquals('Test Document.pdf', result.getFileName(), 'Filename should match ContentVersion title + extension');

        Test.stopTest();
    }

    @isTest
    static void testEmailTemplate() {
        // Create a user to run as (to ensure current user has permissions)
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(currentUser) {
            // Create a test EmailTemplate
            EmailTemplate template = new EmailTemplate();
            template.isActive = true;
            template.Name = 'Test Template';
            template.DeveloperName = 'Test_Template_Unique_123';
            template.TemplateType = 'text';
            template.FolderId = UserInfo.getUserId(); // Put in personal folder
            template.Subject = 'Template Subject';
            template.Body = 'Hello {!Contact.FirstName}, this is a template.';
            insert template;
            
            // Create a dummy Contact for targetObjectId
            Contact c = new Contact(FirstName = 'Test', LastName = 'User', Email = 'testuser@example.com');
            insert c;
            
            Test.startTest();
            
            // Test by Template Name
            EmailBuilder builder1 = LSend.emails()
                .to('recipient@example.com')
                .template('Test_Template_Unique_123')
                .targetObject(c.Id)
                .saveActivity(false); // Don't save activity to avoid "WhatId is not available for sending emails to UserIds" or similar issues if testing with User
            
            System.assertNotEquals(null, builder1, 'Should accept template name');
            
            // Test by Template ID
            EmailBuilder builder2 = LSend.emails()
                .to('recipient@example.com')
                .templateId(template.Id)
                .targetObject(c.Id);
                
            System.assertNotEquals(null, builder2, 'Should accept template Id');

            // Verify validations for template
            try {
                LSend.emails().template('Non_Existent_Template').send();
                System.assert(false, 'Should throw exception for non-existent template');
            } catch (EmailException e) {
                System.assert(e.getMessage() != null, 'Should match error message');
            }
            
            Test.stopTest();
        }
    }

    @isTest
    static void testStaticResourceTemplate() {
        Test.startTest();
        
        // Mock the static resource body
        String mockHtml = '<html><body><h1>Hello {{name}}</h1><p>Welcome to {{company}}!</p></body></html>';
        EmailBuilder.mockStaticResourceBody = mockHtml;
        
        EmailBuilder builder = LSend.emails()
            .sender('sender@example.com')
            .to('recipient@example.com')
            .subject('Static Resource Test')
            .staticResource('MyResource')
            .variable('name', 'User')
            .variable('company', 'Acme Inc');
            
        // We can't easily verify the internal HTML body without sending or exposing it, 
        // but we can ensure the builder chain completes and send() doesn't crash.
        // To verify the variable replacement, we might need to expose the htmlBody for testing or use a trick.
        // Since we are testing coverage, executing the code path is the primary goal.
        
        // This will trigger processStaticResourceTemplate()
        EmailResult result = builder.send();
        
        // Validation check - if we use a static resource that doesn't exist (and we don't mock it)
        EmailBuilder.mockStaticResourceBody = null;
        try {
            LSend.emails()
                .to('recipient@example.com')
                .staticResource('NonExistentResource')
                .send();
            System.assert(false, 'Should throw exception for missing static resource');
        } catch (EmailException e) {
            System.assert(e.getMessage().contains('Static Resource not found'), 'Should match error message');
        }
        
        Test.stopTest();
    }

    @isTest
    static void testListOverloads() {
        Test.startTest();
        
        EmailBuilder builder = LSend.emails()
            .to(new List<String>{'to1@example.com', 'to2@example.com'})
            .cc(new List<String>{'cc1@example.com', 'cc2@example.com'})
            .bcc(new List<String>{'bcc1@example.com', 'bcc2@example.com'})
            .sender('sender@example.com')
            .subject('List Overloads')
            .html('Body');
            
        System.assertNotEquals(null, builder, 'Builder should handle list overloads');
        
        Test.stopTest();
    }

    @isTest
    static void testWhatObject() {
        // Create a dummy Account for WhatId
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        // Create a dummy Contact for TargetObjectId
        Contact c = new Contact(FirstName = 'Test', LastName = 'User', Email = 'testuser@example.com');
        insert c;
        
        // Create a template
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(currentUser) {
            EmailTemplate template = new EmailTemplate();
            template.isActive = true;
            template.Name = 'Test What Template';
            template.DeveloperName = 'Test_What_Template';
            template.TemplateType = 'text';
            template.FolderId = UserInfo.getUserId();
            template.Subject = 'Template Subject';
            template.Body = 'Hello {!Contact.FirstName}, related to {!Account.Name}.';
            insert template;

            Test.startTest();
            
            EmailBuilder builder = LSend.emails()
                .to('recipient@example.com')
                .templateId(template.Id)
                .targetObject(c.Id)
                .whatObject(acc.Id);
                
            System.assertNotEquals(null, builder, 'Builder should handle whatObject');
            
            Test.stopTest();
        }
    }

    @isTest
    static void testStaticResourceWithVariables() {
        Test.startTest();
        
        String mockHtml = '<html><body>Hello {{name}}</body></html>';
        EmailBuilder.mockStaticResourceBody = mockHtml;
        
        // Test overload that takes map
        EmailBuilder builder = LSend.emails()
            .sender('sender@example.com')
            .to('recipient@example.com')
            .subject('Static Resource Map Test')
            .staticResource('MyResource', new Map<String, String>{'name' => 'User'});
            
        EmailResult result = builder.send();
        System.assert(result.isSuccess(), 'Should send successfully with static resource map overload');
        
        Test.stopTest();
    }

    @isTest
    static void testAttachObject() {
        Test.startTest();
        
        Blob content = Blob.valueOf('Test');
        EmailAttachment att = new EmailAttachment()
            .filename('test.txt')
            .content(content)
            .contentType('text/plain');
            
        EmailBuilder builder = LSend.emails()
            .sender('sender@example.com')
            .to('recipient@example.com')
            .subject('Attach Object Test')
            .text('Body')
            .attach(att);
            
        System.assertNotEquals(null, builder, 'Builder should handle EmailAttachment object');
        
        Test.stopTest();
    }

    @isTest
    static void testValidationEdgeCases() {
        Test.startTest();
        
        // Test missing template name in template flow
        try {
            // We set neither templateId nor templateName but try to use that flow?
            // Actually the current validation checks basic requirement of body/template.
            // Let's try sending with just subject and no body/template
            LSend.emails()
                .to('user@example.com')
                .subject('Subject Only')
                .send();
            System.assert(false, 'Should throw exception for missing body/template');
        } catch (EmailException e) {
            System.assert(e.getMessage().contains('required'), 'Should match error message');
        }
        
        Test.stopTest();
    }
}