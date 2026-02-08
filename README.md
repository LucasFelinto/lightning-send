# ⚡ LSend - Lightning Send

> A modern, fluent Email API for Salesforce Apex

LSend provides a clean, chainable API for sending emails in Salesforce.

## 🚀 Quick Start

```apex
LSend.emails()
    .sender('Acme <noreply@acme.com>')
    .to('user@example.com')
    .subject('Hello World')
    .html('<p>It works!</p>')
    .send();
```

## 📦 Installation

Deploy the following classes to your org:
- `LSend.cls`
- `EmailBuilder.cls`
- `EmailAttachment.cls`
- `EmailResult.cls`
- `EmailException.cls`

```bash
sf project deploy start --source-dir force-app/main/default/classes
```

## 📖 Usage Examples

### Basic Email

```apex
LSend.emails()
    .sender('noreply@company.com')
    .to('customer@example.com')
    .subject('Welcome!')
    .html('<h1>Welcome to our platform</h1>')
    .send();
```

### With Sender Name

```apex
LSend.emails()
    .sender('Support Team <support@company.com>')
    .to('customer@example.com')
    .subject('Your ticket has been received')
    .html('<p>We will respond within 24 hours.</p>')
    .send();
```

### Multiple Recipients

```apex
LSend.emails()
    .sender('newsletter@company.com')
    .to(new List<String>{'user1@example.com', 'user2@example.com'})
    .cc('manager@company.com')
    .bcc('archive@company.com')
    .subject('Monthly Newsletter')
    .html('<h1>This Month\'s Updates</h1>')
    .send();
```

### With Reply-To

```apex
LSend.emails()
    .sender('noreply@company.com')
    .to('customer@example.com')
    .replyTo('support@company.com')
    .subject('Order Confirmation')
    .html('<p>Your order has been confirmed.</p>')
    .send();
```

### Plain Text Email

```apex
LSend.emails()
    .sender('alerts@company.com')
    .to('admin@company.com')
    .subject('System Alert')
    .text('CPU usage exceeded 90%')
    .send();
```

### HTML + Text (Multipart)

```apex
LSend.emails()
    .sender('noreply@company.com')
    .to('user@example.com')
    .subject('Important Update')
    .html('<h1>Update Available</h1><p>Check our website.</p>')
    .text('Update Available - Check our website.')
    .send();
```

### With Attachments

```apex
// From Blob
Blob pdfContent = Blob.valueOf('PDF content here');

LSend.emails()
    .sender('billing@company.com')
    .to('customer@example.com')
    .subject('Your Invoice')
    .html('<p>Please find your invoice attached.</p>')
    .attach('invoice.pdf', pdfContent)
    .send();

// From ContentVersion
LSend.emails()
    .sender('docs@company.com')
    .to('user@example.com')
    .subject('Document Shared')
    .html('<p>Document attached.</p>')
    .attachContentVersion(contentVersionId)
    .send();

// Using EmailAttachment class
EmailAttachment att = new EmailAttachment()
    .filename('report.xlsx')
    .content(excelBlob)
    .contentType('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');

LSend.emails()
    .sender('reports@company.com')
    .to('manager@company.com')
    .subject('Weekly Report')
    .html('<p>Report attached.</p>')
    .attach(att)
    .send();
```

### Using Salesforce Templates

```apex
// By Developer Name
LSend.emails()
    .sender('noreply@company.com')
    .to('user@example.com')
    .template('WelcomeEmail')
    .targetObject(contactId)
    .whatObject(accountId)
    .send();

// By Template Id
LSend.emails()
    .sender('noreply@company.com')
    .to('user@example.com')
    .templateId(templateId)
    .targetObject(leadId)
    .send();
```

### Using Static Resource HTML Templates

Create an HTML file as a Static Resource with `{{variableName}}` placeholders:

> [!IMPORTANT]
> **The HTML file must be encoded in UTF-8.** Otherwise, you will receive the error:
> `System.StringException: BLOB is not a valid UTF-8 string`

**Static Resource: `WelcomeEmailTemplate`**
```html
<!DOCTYPE html>
<html>
<body>
    <h1>Welcome, {{firstName}}!</h1>
    <p>Thank you for joining {{companyName}}.</p>
    <p>Your account is now active.</p>
    <a href="{{loginUrl}}">Login Now</a>
</body>
</html>
```

**Apex Usage:**
```apex
LSend.emails()
    .sender('noreply@company.com')
    .to('newuser@example.com')
    .subject('Welcome to Our Platform!')
    .staticResource('WelcomeEmailTemplate', new Map<String, String>{
        'firstName' => 'John',
        'companyName' => 'Acme Corp',
        'loginUrl' => 'https://acme.com/login'
    })
    .send();
```

**Order Confirmation Example:**
```apex
LSend.emails()
    .sender('orders@company.com')
    .to('customer@example.com')
    .subject('Order Confirmation #12345')
    .staticResource('OrderConfirmationTemplate', new Map<String, String>{
        'firstName' => 'John',
        'orderNumber' => '12345',
        'orderTotal' => '$99.99',
        'deliveryDate' => 'Feb 15, 2026'
    })
    .send();
```

### With Tags (for tracking)

```apex
LSend.emails()
    .sender('marketing@company.com')
    .to('prospect@example.com')
    .subject('Special Offer')
    .html('<p>Limited time offer!</p>')
    .tag('campaign', 'spring-sale')
    .tag('type', 'promotional')
    .send();
```

### Save as Activity

```apex
LSend.emails()
    .sender('sales@company.com')
    .to('prospect@example.com')
    .subject('Follow-up')
    .html('<p>Thank you for your interest.</p>')
    .saveActivity(true)
    .send();
```

### Handling Results

```apex
EmailResult result = LSend.emails()
    .sender('noreply@company.com')
    .to('user@example.com')
    .subject('Test')
    .html('<p>Test</p>')
    .send();

if (result.isSuccess()) {
    System.debug('Email sent! ID: ' + result.getId());
} else {
    System.debug('Error: ' + result.getError());
}
```

### Error Handling

```apex
try {
    LSend.emails()
        .sender('noreply@company.com')
        .subject('Missing recipient')
        .html('<p>This will fail</p>')
        .send();
} catch (EmailException e) {
    System.debug('Validation error: ' + e.getMessage());
}
```

## 📚 API Reference

### LSend

| Method | Description |
|--------|-------------|
| `emails()` | Returns an EmailBuilder instance |

### EmailBuilder

| Method | Parameters | Description |
|--------|------------|-------------|
| `sender()` | `String senderEmail` | Set sender (supports "Name \<email\>" format) |
| `to()` | `String recipient` | Add single recipient |
| `to()` | `List<String> recipients` | Add multiple recipients |
| `cc()` | `String/List<String>` | Add CC recipients |
| `bcc()` | `String/List<String>` | Add BCC recipients |
| `replyTo()` | `String email` | Set reply-to address |
| `subject()` | `String subject` | Set email subject |
| `html()` | `String content` | Set HTML body |
| `text()` | `String content` | Set plain text body |
| `staticResource()` | `String resourceName` | Use HTML template from Static Resource |
| `template()` | `String devName` | Use Salesforce template by developer name |
| `templateId()` | `Id templateId` | Use Salesforce template by Id |
| `targetObject()` | `Id objectId` | Set target object for template merge |
| `whatObject()` | `Id objectId` | Set what object for template merge |
| `variable()` | `String name, String value` | Add `{{variable}}` replacement |
| `variables()` | `Map<String, String>` | Add multiple variables |
| `attach()` | `String filename, Blob content` | Add attachment from Blob |
| `attach()` | `EmailAttachment attachment` | Add attachment object |
| `attachContentVersion()` | `Id contentVersionId` | Add attachment from CV |
| `tag()` | `String name, String value` | Add tracking tag |
| `saveActivity()` | `Boolean save` | Save email as activity |
| `send()` | - | Send the email |

### EmailAttachment

| Method | Description |
|--------|-------------|
| `filename()` | Set the filename |
| `content()` | Set content from Blob |
| `contentType()` | Set MIME type |
| `contentVersionId()` | Set from ContentVersion |

### EmailResult

| Property/Method | Description |
|-----------------|-------------|
| `success` | Boolean - was email sent |
| `error` | String - error message if failed |
| `id` | String - tracking ID |
| `isSuccess()` | Check if successful |
| `getError()` | Get error message |
| `getId()` | Get tracking ID |

## ⚠️ Salesforce Limits

- Daily email limit: 5,000 per org (can vary by edition)
- Single email limit: 150 recipients
- Attachment size: 25 MB total

## 📄 License

MIT License - Feel free to use in your projects!
