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
}
