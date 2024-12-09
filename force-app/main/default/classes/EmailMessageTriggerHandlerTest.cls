@isTest
private class EmailMessageTriggerHandlerTest {
	
    @TestSetup
    private static void createTestData(){
       	EmailMessage em = new Emailmessage();
		em.FromAddress='testfrom@yopmail.com';
		em.FromName='Test Test';
		em.HtmlBody='<p>This is Test Body for Email Message Trigger!</p>';
		em.Priority__c='Instant';
		em.Subject='EmailMessage Trigger Testing!';
		em.ToAddress='testto@yopmail.com';
        em.BulkEmail__c=false;
        TriggerBase.bypass('EmailMessage');
       	insert em;
        TriggerBase.clearBypass('EmailMessage');
    }
    
    @isTest
    private static void testAfterInsert(){
        Test.StartTest();
        EmailMessage msg = [Select Id, BulkEmail__c From EmailMessage Where Subject='EmailMessage Trigger Testing!'];
        List<EmailMessage> msglist = new list<EmailMessage>();
        msglist.add(msg);
        EmailMessageTriggerHandler.AfterInsert(msglist);
        Test.StopTest();
    }
    
}