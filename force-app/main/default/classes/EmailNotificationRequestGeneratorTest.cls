@isTest
private class EmailNotificationRequestGeneratorTest {
	
    @TestSetup
    private static void createTestData(){
        
        EmailMessage email = new EmailMessage(
            BccAddress='bcc@yopmail.com',
            CcAddress='ccaddress@yopmail.com',
            FromAddress='from@yopmail.com',
            HtmlBody='<p>This is a sample html body!</p>',
            Priority__c='Instant',
            Subject='Sample Email Notification!',
            ToAddress='john@yopmail.com'
        );
        TriggerBase.bypass('EmailMessage');
       	insert email;
        TriggerBase.clearBypass('EmailMessage');
        
        IntgMsg__c intMsg = new IntgMsg__c(
           	Name='Test Integration Message',
           	BU__c='HL / STL',
           	Status__c='New',
           	RefId__c=email.Id,
           	RefObj__c='EmailMessage',
           	Svc__c='Email Notification',
           	ApiVendor__c='Fedfina',
           	IsActive__c=true
        );
        TriggerBase.bypass('IntgMsg__c');
        insert intMsg;
        TriggerBase.clearBypass('IntgMsg__c');
    }
    
    @isTest
    private static void testGenerateMethod(){
        List<IntgMsg__c> msgsList = new List<IntgMsg__c>();
        IntgMsg__c msg = [Select Id,Name,BU__c,Status__c,RefId__c,RefObj__c,Svc__c,ApiVendor__c,IsActive__c From IntgMsg__c Where Name='Test Integration Message'];
        msgsList.add(msg);
        Test.startTest();
        EmailNotificationRequestGenerator.generate(msgsList,'Email Notification','HL / STL');
        Test.stopTest();
    }
    
    @isTest
    private static void testRequestWrapperClass(){
        String requestJson = '{"saveToSentItems":"true","priority":1,"parentType":"SFDC","parentID":"02sC4000001q2RnIAI","message":{"toRecipients":[{"emailAddress":{"address":"spruthi.basavaraj@pwc.com"}},{"emailAddress":{"address":"spruthi@yopmail.com"}}],"subject":"Test Email for Email Notification API","ccRecipients":[{"emailAddress":{"address":"spruthi.cc@yopmail.com"}}],"body":{"contentType":"html","content":"<p>This is a sample email body!</p>"},"bccRecipients":[{"emailAddress":{"address":"spruthi.bcc@yopmail.com"}}],"attachments":[]},"isAttachment":0,"alertType":"EMAIL"}';
        EmailNotificationRequestWrapper request = EmailNotificationRequestWrapper.parse(requestJson);
        Assert.isNotNull(request, 'request should not be null');
    }
    
}