@istest
public class CrimeCheckPdfReportTest {
    @istest
    public static Void testmethod1(){
        
        
        LoanAppl__c la = TestDataFactory.createLoanApplication(true);
        
        Applicant__c app1 = new  Applicant__c();
        app1.LoanAppln__c=la.Id;
        app1.Constitution__c='INDIVIDUAL';
        
        insert app1;
        
        Id recordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByDeveloperName().get('CrimeCheck').getRecordTypeId(); 
        
        APIVer__c apiver =new APIVer__c();
        apiver.Appl__c=app1.Id;
        apiver.LoanAplcn__c=la.Id;
        apiver.IsLatest__c=true;
        apiver.CrimeCheckId__c='2771125995998';
        apiver.RecordTypeId=recordTypeId;
        insert apiver;
        
        IntgMsg__c msg =new IntgMsg__c();
        msg.RefId__c='2771125995998';
        msg.Req__c='2771125995998';
        msg.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
        insert msg;
        
        
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.VersionData =blob.valueof('Hello, this is a test PDF content');
        contentVersion.Title = 'response.pdf';
        contentVersion.PathOnClient = 'response.pdf';
        //contentVersion.FileType='pdf';                           
        insert contentVersion;
                                                 
       Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id LIMIT 1].ContentDocumentId;
        
        ContentDocumentLink contentLink = new ContentDocumentLink();
        contentLink.ContentDocumentId = contentDocumentId;
        contentLink.LinkedEntityId=msg.id;
        contentLink.ShareType = 'V';
        insert contentLink;                                          
        
        List<IntgMsg__c> intmsglist =new List<IntgMsg__c>{msg};
        
        Test.startTest();
        CrimeCheckPdfAPIRequestGenerator request =new CrimeCheckPdfAPIRequestGenerator();
        request.generate(intmsglist,'Crime Check', 'Async');
        
        CrimeCheckPdfReportResponseProcessor.process(intmsglist);
        Test.stopTest();
        
    }
    
     @istest
    public static Void testmethod2(){
        
        
        LoanAppl__c la = TestDataFactory.createLoanApplication(true);
        
        Applicant__c app1 = new  Applicant__c();
        app1.LoanAppln__c=la.Id;
        app1.Constitution__c='INDIVIDUAL';
        
        insert app1;
        
        Id recordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByDeveloperName().get('CrimeCheck').getRecordTypeId(); 
        
        APIVer__c apiver =new APIVer__c();
        apiver.Appl__c=app1.Id;
        apiver.LoanAplcn__c=la.Id;
        apiver.IsLatest__c=true;
        apiver.CrimeCheckId__c='2771125995998';
        apiver.RecordTypeId=recordTypeId;
        insert apiver;
        
        IntgMsg__c msg =new IntgMsg__c();
        msg.RefId__c='2771125995998';
        msg.Req__c='2771125995998';
        msg.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
        insert msg;
        
        
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.VersionData =blob.valueof('{"status":"OK","message":"Invalid UniqueId"}');
        contentVersion.Title = 'response.json';
        contentVersion.PathOnClient = 'response.json';
        //contentVersion.FileType='pdf';                           
        insert contentVersion;
                                                 
       Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id LIMIT 1].ContentDocumentId;
        
        ContentDocumentLink contentLink = new ContentDocumentLink();
        contentLink.ContentDocumentId = contentDocumentId;
        contentLink.LinkedEntityId=msg.id;
        contentLink.ShareType = 'V';
        insert contentLink;                                          
        
        List<IntgMsg__c> intmsglist =new List<IntgMsg__c>{msg};
        
        Test.startTest();
        CrimeCheckPdfReportResponseProcessor.process(intmsglist);
        Test.stopTest();
        
    }

}