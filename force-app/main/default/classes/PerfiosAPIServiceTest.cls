@isTest
public class PerfiosAPIServiceTest {
    @isTest
    public static void testGenerateMethod() {
        
        
    LoanAppl__c La = TestDataFactory.createLoanApplication(true);
    Applicant__c app = TestDataFactory.createSingleApplicant(true,La.id);
    Bureau__c br = TestDataFactory.BureauData(true, la.id, app.id);  
        br.BureauAPI__c = 'Consumer';
        upsert br;
    DocMstr__c dm =  TestDataFactory.DocumentMasterData(true);
    DocDtl__c doc = TestDataFactory.createDocumentDetail(true,'Test Doc',app.id,dm.id);
        
         ApplKyc__c ak=new ApplKyc__c();
        ak.Applicant__c=app.id;
        ak.kycDoc__c='Pan';
        ak.Name__c='test';
        ak.Pan__c='KIOPA1722K';
        insert ak;
        
        ApplBanking__c ab = new ApplBanking__c();
        ab.Appl__c = app.Id;
        ab.LoanAppl__c = la.Id;
        ab.TransactionId__c = 'PERFIOS1-RSA-SHA256';
        insert ab;
        
       IntgMsg__c intgMsg = new IntgMsg__c();
        intgMsg.Name='Initiate Perfios';
        intgMsg.BU__c='HL / STL';
        intgMsg.Status__c='New';
        intgMsg.MStatus__c='Blank';
        intgMsg.RefObj__c='ApplKyc__c';
        intgMsg.RefId__c = app.Id;
        intgMsg.ParentRefId__c = ab.Id;
        //intgMsg.Resp__c = '{"transaction":{"perfiosTransactionId":"XJEW1706784211330"}}';
        intgMsg.Trigger_Platform_Event__c=true;
        intgMsg.IsActive__c=true;
        intgMsg.Req__c = '{"Payload":{"payload":{"yearMonthTo":"","yearMonthFrom":"","uploadingScannedStatements":"false","txnId":"883800112","transactionCompleteCallbackUrl":"https://example.com/callback","processingType":"STATEMENT","loanType":"Home Loan","loanDuration":"24","loanAmount":"12322222","employmentType":"SALARIED","acceptancePolicy":"atLeastOneTransactionInRange"}},"Header":{"transactionID":"XJEW1706784211330","sha256Content":"58c9f3a466f9ceefbb9a41ee2884582b7969f8aaa322a529f4717eafc4de91a6","perfiosSignedHeaders":"host;x-perfios-content-sha256;x-perfios-date","perfioSignature":"8df021d20bdaba648c3809c71c806f7ee1acb633a114d160184f99bd1b27a6fa133a7e49e31c95a1761fea993ba91aa73b9fbaed141541fcd5015f19794c2b4c6afdaca18402e7058ccb4fd14b4e4c8a320074bc2580930d89605284247c8a7136c31f751163d3619ba248b1300c480ae7e6db29c8cea6c42dc91ff9217b732e7d4f0b791516ddc294f672f64d57c17db37548213f76d5d56f62b4931ca132c15325b2fc57b4f023380f21bd4849aa28ff182de69e07a3fa96736fd96dffc9bf51b88de44ed935dfe491a1db97d958291fc19fd01856353f49f33d8d2d4f491e1cf1c5c9bb0fa335ab6513e1dbec6c7aa4fb6afbbf20ac843fd34eaaee28f545d3851de6789c39e1710f41aa2c9be39c618403bea1ea83384993e8a1adcaf8f098d27e681a9669027e7170d426f323fd1bfa8708d5869a65f73f5f018b5f10ac34d1fb4813d80cff02b7cd3c7f6dfe872902abedc05664ec415592fbcf26bb2222723b1ba0f546cd912d3182fe4756b4fbca6a231bdd6d5eeaed8dc4c4b2071fdc3e28721c85a0742081139016ee7787b83fe34c7668b0007ca35414494c0366bfe9e525b604dd32cfd40749bcc434d3fa65cdc688006362806825277be14eb82b43917f9713ea3eadfca7f7524eb2560c201953b3f0b1b7c4d756fce461b8e38ee529aa351b1be1622ea33cac94638d3362b89da9e9c46b93ac77bde1cf9498","perfiosAlgorithm":"PERFIOS1-RSA-SHA256","perfioRequestDate":"20231107T154130Z","fileId":null}}';
        intgMsg.Resp__c = 'callout:PerfiosAPIGateway/XJEW1706784211330/RetrieveReports?types=json';
        intgMsg.ParentRefObj__c=intgMsg.ParentRefObj__c;
        insert intgMsg;
        	
        
        String filename = 'Response.json';
            
            ContentVersion newContentVersion = new ContentVersion();
            newContentVersion.Title = filename;
            newContentVersion.PathOnClient = filename;
            newContentVersion.VersionData = blob.valueof('{"Payload":{"payload":{"yearMonthTo":"","yearMonthFrom":"","uploadingScannedStatements":"false","txnId":"883800112","transactionCompleteCallbackUrl":"https://example.com/callback","processingType":"STATEMENT","loanType":"Home Loan","loanDuration":"24","loanAmount":"12322222","employmentType":"SALARIED","acceptancePolicy":"atLeastOneTransactionInRange"}},"Header":{"transactionID":null,"sha256Content":"58c9f3a466f9ceefbb9a41ee2884582b7969f8aaa322a529f4717eafc4de91a6","perfiosSignedHeaders":"host;x-perfios-content-sha256;x-perfios-date","perfioSignature":"8df021d20bdaba648c3809c71c806f7ee1acb633a114d160184f99bd1b27a6fa133a7e49e31c95a1761fea993ba91aa73b9fbaed141541fcd5015f19794c2b4c6afdaca18402e7058ccb4fd14b4e4c8a320074bc2580930d89605284247c8a7136c31f751163d3619ba248b1300c480ae7e6db29c8cea6c42dc91ff9217b732e7d4f0b791516ddc294f672f64d57c17db37548213f76d5d56f62b4931ca132c15325b2fc57b4f023380f21bd4849aa28ff182de69e07a3fa96736fd96dffc9bf51b88de44ed935dfe491a1db97d958291fc19fd01856353f49f33d8d2d4f491e1cf1c5c9bb0fa335ab6513e1dbec6c7aa4fb6afbbf20ac843fd34eaaee28f545d3851de6789c39e1710f41aa2c9be39c618403bea1ea83384993e8a1adcaf8f098d27e681a9669027e7170d426f323fd1bfa8708d5869a65f73f5f018b5f10ac34d1fb4813d80cff02b7cd3c7f6dfe872902abedc05664ec415592fbcf26bb2222723b1ba0f546cd912d3182fe4756b4fbca6a231bdd6d5eeaed8dc4c4b2071fdc3e28721c85a0742081139016ee7787b83fe34c7668b0007ca35414494c0366bfe9e525b604dd32cfd40749bcc434d3fa65cdc688006362806825277be14eb82b43917f9713ea3eadfca7f7524eb2560c201953b3f0b1b7c4d756fce461b8e38ee529aa351b1be1622ea33cac94638d3362b89da9e9c46b93ac77bde1cf9498","perfiosAlgorithm":"PERFIOS1-RSA-SHA256","perfioRequestDate":"20231107T154130Z","fileId":null}}');
            insert  newContentVersion; 
            
            Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:newContentVersion.Id].ContentDocumentId;
            ContentDocumentLink newContentLink = new ContentDocumentLink();
            newContentLink.ContentDocumentId = conDocId;
            newContentLink.LinkedEntityId = La.id; 
            newContentLink.ShareType = 'V';   
            insert newContentLink;     
        //
            Test.setMock(HttpCalloutMock.class, new HttpCalloutMock1());
        
        List<IntgMsg__c> responses =new List<IntgMsg__c>{intgMsg};
            List<Id> listId = new List<Id>();
        	listId.add(responses[0].id);
        	PerfiosAPIService.post(listId);
    }
    	public class HttpCalloutMock1 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
        // Create a mock response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"mockResponseKey": "mockResponseValue"}');
        res.setStatusCode(200);
        return res;
    }
    }
    
        @isTest
    public static void testGenerateMethod1() {
        
        
    LoanAppl__c La = TestDataFactory.createLoanApplication(true);
    Applicant__c app = TestDataFactory.createSingleApplicant(true,La.id);
    Bureau__c br = TestDataFactory.BureauData(true, la.id, app.id);  
        br.BureauAPI__c = 'Consumer';
        upsert br;
    DocMstr__c dm =  TestDataFactory.DocumentMasterData(true);
    DocDtl__c doc = TestDataFactory.createDocumentDetail(true,'Test Doc',app.id,dm.id);
        
         ApplKyc__c ak=new ApplKyc__c();
        ak.Applicant__c=app.id;
        ak.kycDoc__c='Pan';
        ak.Name__c='test';
        ak.Pan__c='KIOPA1722K';
        insert ak;
        
        ApplBanking__c ab = new ApplBanking__c();
        ab.Appl__c = app.Id;
        ab.LoanAppl__c = la.Id;
        ab.TransactionId__c = 'PERFIOS1-RSA-SHA256';
        insert ab;
        
       IntgMsg__c intgMsg = new IntgMsg__c();
        intgMsg.Name='Initiate Perfios';
        intgMsg.BU__c='HL / STL';
        intgMsg.Status__c='New';
        intgMsg.MStatus__c='Blank';
        intgMsg.RefObj__c='ApplKyc__c';
        intgMsg.RefId__c = app.Id;
        intgMsg.ParentRefId__c = ab.Id;
        //intgMsg.Resp__c = '{"transaction":{"perfiosTransactionId":"XJEW1706784211330"}}';
        intgMsg.Trigger_Platform_Event__c=true;
        intgMsg.IsActive__c=true;
        intgMsg.Req__c = '{"Payload":{"payload":{"yearMonthTo":"","yearMonthFrom":"","uploadingScannedStatements":"false","txnId":"883800112","transactionCompleteCallbackUrl":"https://example.com/callback","processingType":"STATEMENT","loanType":"Home Loan","loanDuration":"24","loanAmount":"12322222","employmentType":"SALARIED","acceptancePolicy":"atLeastOneTransactionInRange"}},"Header":{"transactionID":"XJEW1706784211330","sha256Content":"58c9f3a466f9ceefbb9a41ee2884582b7969f8aaa322a529f4717eafc4de91a6","perfiosSignedHeaders":"host;x-perfios-content-sha256;x-perfios-date","perfioSignature":"8df021d20bdaba648c3809c71c806f7ee1acb633a114d160184f99bd1b27a6fa133a7e49e31c95a1761fea993ba91aa73b9fbaed141541fcd5015f19794c2b4c6afdaca18402e7058ccb4fd14b4e4c8a320074bc2580930d89605284247c8a7136c31f751163d3619ba248b1300c480ae7e6db29c8cea6c42dc91ff9217b732e7d4f0b791516ddc294f672f64d57c17db37548213f76d5d56f62b4931ca132c15325b2fc57b4f023380f21bd4849aa28ff182de69e07a3fa96736fd96dffc9bf51b88de44ed935dfe491a1db97d958291fc19fd01856353f49f33d8d2d4f491e1cf1c5c9bb0fa335ab6513e1dbec6c7aa4fb6afbbf20ac843fd34eaaee28f545d3851de6789c39e1710f41aa2c9be39c618403bea1ea83384993e8a1adcaf8f098d27e681a9669027e7170d426f323fd1bfa8708d5869a65f73f5f018b5f10ac34d1fb4813d80cff02b7cd3c7f6dfe872902abedc05664ec415592fbcf26bb2222723b1ba0f546cd912d3182fe4756b4fbca6a231bdd6d5eeaed8dc4c4b2071fdc3e28721c85a0742081139016ee7787b83fe34c7668b0007ca35414494c0366bfe9e525b604dd32cfd40749bcc434d3fa65cdc688006362806825277be14eb82b43917f9713ea3eadfca7f7524eb2560c201953b3f0b1b7c4d756fce461b8e38ee529aa351b1be1622ea33cac94638d3362b89da9e9c46b93ac77bde1cf9498","perfiosAlgorithm":"PERFIOS1-RSA-SHA256","perfioRequestDate":"20231107T154130Z","fileId":null}}';
        intgMsg.Resp__c = 'callout:PerfiosAPIGateway/XJEW1706784211330/RetrieveReports?types=json';
        intgMsg.ParentRefObj__c=intgMsg.ParentRefObj__c;
        insert intgMsg;
        	
        
        String filename = 'Response.json';
            
            ContentVersion newContentVersion = new ContentVersion();
            newContentVersion.Title = filename;
            newContentVersion.PathOnClient = filename;
            newContentVersion.VersionData = blob.valueof('{"Payload":{"payload":{"yearMonthTo":"","yearMonthFrom":"","uploadingScannedStatements":"false","txnId":"883800112","transactionCompleteCallbackUrl":"https://example.com/callback","processingType":"STATEMENT","loanType":"Home Loan","loanDuration":"24","loanAmount":"12322222","employmentType":"SALARIED","acceptancePolicy":"atLeastOneTransactionInRange"}},"Header":{"transactionID":null,"sha256Content":"58c9f3a466f9ceefbb9a41ee2884582b7969f8aaa322a529f4717eafc4de91a6","perfiosSignedHeaders":"host;x-perfios-content-sha256;x-perfios-date","perfioSignature":"8df021d20bdaba648c3809c71c806f7ee1acb633a114d160184f99bd1b27a6fa133a7e49e31c95a1761fea993ba91aa73b9fbaed141541fcd5015f19794c2b4c6afdaca18402e7058ccb4fd14b4e4c8a320074bc2580930d89605284247c8a7136c31f751163d3619ba248b1300c480ae7e6db29c8cea6c42dc91ff9217b732e7d4f0b791516ddc294f672f64d57c17db37548213f76d5d56f62b4931ca132c15325b2fc57b4f023380f21bd4849aa28ff182de69e07a3fa96736fd96dffc9bf51b88de44ed935dfe491a1db97d958291fc19fd01856353f49f33d8d2d4f491e1cf1c5c9bb0fa335ab6513e1dbec6c7aa4fb6afbbf20ac843fd34eaaee28f545d3851de6789c39e1710f41aa2c9be39c618403bea1ea83384993e8a1adcaf8f098d27e681a9669027e7170d426f323fd1bfa8708d5869a65f73f5f018b5f10ac34d1fb4813d80cff02b7cd3c7f6dfe872902abedc05664ec415592fbcf26bb2222723b1ba0f546cd912d3182fe4756b4fbca6a231bdd6d5eeaed8dc4c4b2071fdc3e28721c85a0742081139016ee7787b83fe34c7668b0007ca35414494c0366bfe9e525b604dd32cfd40749bcc434d3fa65cdc688006362806825277be14eb82b43917f9713ea3eadfca7f7524eb2560c201953b3f0b1b7c4d756fce461b8e38ee529aa351b1be1622ea33cac94638d3362b89da9e9c46b93ac77bde1cf9498","perfiosAlgorithm":"PERFIOS1-RSA-SHA256","perfioRequestDate":"20231107T154130Z","fileId":null}}');
            insert  newContentVersion; 
            
            Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:newContentVersion.Id].ContentDocumentId;
            ContentDocumentLink newContentLink = new ContentDocumentLink();
            newContentLink.ContentDocumentId = conDocId;
            newContentLink.LinkedEntityId = La.id; 
            newContentLink.ShareType = 'V';   
            insert newContentLink;     
        //
            Test.setMock(HttpCalloutMock.class, new HttpCalloutMock2());
        
        List<IntgMsg__c> responses =new List<IntgMsg__c>{intgMsg};
            List<Id> listId = new List<Id>();
        	listId.add(responses[0].id);
        	PerfiosAPIService.post(listId);
    }
    	public class HttpCalloutMock2 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
        // Create a mock response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'content-disposition');
        res.setBody('{"mockResponseKey": "mockResponseValue"}');
        res.setStatusCode(200);
        return res;
    }
    }
    
}