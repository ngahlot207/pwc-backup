@isTest
private class EmailMessageBatchHandlerTest {

    @TestSetup
    private static void createTestData(){
        EmailMessage email = new EmailMessage(
            BccAddress='bcc@yopmail.com',
            CcAddress='ccaddress@yopmail.com',
            FromAddress='from@yopmail.com',
            HtmlBody='<p>This is a sample html body!</p>',
            Priority__c='Instant',
            Subject='Sample Email Notification!',
            ToAddress='john@yopmail.com',
            BulkEmail__c=true
        );
        TriggerBase.bypass('EmailMessage');
       	insert email;
        TriggerBase.clearBypass('EmailMessage');
    }
    
    @isTest
    private static void testHandleEmailMessage(){
        List<EmailMessage> msgsList = new List<EmailMessage>();
        EmailMessage msg = [Select Id,ToAddress,HtmlBody,Subject,Status,RelatedToId,BulkEmail__c From EmailMessage Where Subject='Sample Email Notification!'];
        msgsList.add(msg);
        Test.startTest();
        EmailMessageBatchHandler.handleEmailMessage(msgsList);
        Test.stopTest();
    }
}