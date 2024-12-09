@Istest
public class Trackwizz_CKYC_A37_Test {
    
     @isTest
    public static void testGenerateMethod() {
        
        
        LoanAppl__c la = TestDataFactory.createLoanApplication(true);
        
        Applicant__c app = TestDataFactory.createSingleApplicant(true,la.id);
        app.Constitution__c='';
        update app;
        
        DocDtl__c dd=new DocDtl__c();
        dd.Appl__c=app.Id;
        dd.DocTyp__c='PAN';
        dd.DocCatgry__c='PAN Documents';
        dd.DocSubTyp__c='PAN';
        insert dd;
        
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.VersionData =blob.valueof('Hai');
        contentVersion.Title = 'response.json';
        contentVersion.PathOnClient = 'response.json';
        insert contentVersion;
        
        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id LIMIT 1].ContentDocumentId;
        
        ContentDocumentLink contentLink = new ContentDocumentLink();
        contentLink.ContentDocumentId = contentDocumentId;
        contentLink.LinkedEntityId=dd.id;
        contentLink.ShareType = 'V';
        insert contentLink;
        
        
        IntgMsg__c intgMsg =new IntgMsg__c();
        intgMsg.Name='CKYC ATTACHMENT';
        intgMsg.BU__c='HL / STL';
        intgMsg.Status__c='New';
        intgMsg.MStatus__c='Blank';
        intgMsg.RefObj__c='Applicant__c';
        intgMsg.RefId__c = app.Id;
        intgMsg.Resp__c='<?xml version="1.0" encoding="utf-8"?><A37ImageIntegrationResponse xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><RequestId>119639963</RequestId><RequestStatus>AcceptedbyTW</RequestStatus><ResponseData><CustomerResponseDetails><CustomerResponseDetail><CustomerTransactionId>358090244</CustomerTransactionId><CustomerStatus>AcceptedbyTW</CustomerStatus><ImageResponseDetails><ImageResponseDetail><ImageStatus>AcceptedbyTW</ImageStatus><ImageTransactionId>DD-43022</ImageTransactionId></ImageResponseDetail><ImageResponseDetail><ImageStatus>AcceptedbyTW</ImageStatus><ImageTransactionId>DD-43028</ImageTransactionId></ImageResponseDetail><ImageResponseDetail><ImageStatus>AcceptedbyTW</ImageStatus><ImageTransactionId>DD-43053</ImageTransactionId></ImageResponseDetail></ImageResponseDetails></CustomerResponseDetail></CustomerResponseDetails></ResponseData></A37ImageIntegrationResponse>';
        intgMsg.Svc__c='CKYC ATTACHMENT';
        insert intgMsg;
        
        IntgMsg__c intgMsg1 =new IntgMsg__c();
        intgMsg1.Name='CKYC API';
        intgMsg1.BU__c='HL / STL';
        intgMsg1.Svc__c='CKYC API';
        intgMsg1.Status__c='New';
        intgMsg1.MStatus__c='Blank';
        intgMsg1.RefObj__c='Applicant__c';
        intgMsg1.RefId__c = app.Id;
        intgMsg1.Resp__c='<Response><RequestStatus>RejectedByTW</RequestStatus><RequestRejectionDescription>Error: Invalid data</RequestRejectionDescription><Detail><CustomerIntegrationStatusCode>RejectedByTW</CustomerIntegrationStatusCode><TrackWizzInitialRejectionDescription>Error: Incomplete Information</TrackWizzInitialRejectionDescription></Detail></Response>';
        insert intgMsg1;
        
        List<IntgMsg__c> msg =new List<IntgMsg__c>{intgMsg};
        List<IntgMsg__c> msg1 =new List<IntgMsg__c>{intgMsg1};
        Trackwizz_CKYC_A37_RequestGenerator req=new Trackwizz_CKYC_A37_RequestGenerator();
        
        Test.StartTest();
        req.generate(msg,'CKYC ATTACHMENT','Async');
        Trackwizz_CKYC_A37_ResponseProcessor.process(msg);
        Trackwizz_CKYC_A37_ResponseProcessor.process(msg1);
        Test.StopTest();
        
        //Wrapper
        string resjson='{"A37ImageIntegrationRequest":{"RequestId":"119639963","RequestDataDetail":{"CustomerRequestDetails":{"CustomerRequestDetail":{"TransactionId":"358090244","SourceSystemName":"Finnone","SourceSystemCustomerCode":"SFDC","ImageRequestDetails":{"ImageRequestDetail":[{"ImageTransactionId":"DD-43022","ImageExtension":".jpeg","AttachmentCode":"DrivingLicence","AttachmentBlob":""}]},"HolderForImages":"","AppRefNumberOfImages":""}}},"ApiToken":"ffed6396-2dd1-4457-93fc-ea226ac54dbd"}}';
        Trackwizz_CKYC_A37_RequestWrapper js=Trackwizz_CKYC_A37_RequestWrapper.parse(resjson);
    }

}