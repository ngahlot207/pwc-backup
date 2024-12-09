@isTest
private class EmailNotificationResponseProcessorTest {
	
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
            Status__c='In Progress',
           	RefId__c=email.Id,
           	RefObj__c='EmailMessage',
           	Svc__c='Email Notification',
           	ApiVendor__c='Fedfina',
            Resp__c='{"Data": [{"ReferenceID": 189338}],"Status": 1,"Message": "Success"}',
           	IsActive__c=true
        );
        TriggerBase.bypass('IntgMsg__c');
        insert intMsg;
        TriggerBase.clearBypass('IntgMsg__c');
    }
    
    @isTest
    private static void testProcessMethod(){
        List<IntgMsg__c> msgsList = new List<IntgMsg__c>();
        IntgMsg__c msg = [Select Id,Name,BU__c,RefId__c,RefObj__c,Svc__c,ApiVendor__c,Resp__c,IsActive__c From IntgMsg__c Where Name='Test Integration Message'];
        msgsList.add(msg);
        Test.startTest();
        EmailNotificationResponseProcessor.process(msgsList);
        Test.stopTest();
    }
    
    @isTest
    private static void testResponseWrapperClass(){
        String responseJson = '{"Data":[{"ReferenceID":194}],"status":1,"message":"Success"}';
        EmailNotificationResponseWrapper response = EmailNotificationResponseWrapper.parse(responseJson);
        Assert.isNotNull(response, 'response should not be null');
    }
    
}