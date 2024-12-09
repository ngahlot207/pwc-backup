@isTest
public class PerfiosProcessFilesRequestGeneratorTest {
    @isTest
    public static void testGenerateMethod() {
        
        
    LoanAppl__c La = TestDataFactory.createLoanApplication(true);
    Applicant__c app = TestDataFactory.createSingleApplicant(true,La.id);
    DocMstr__c dm =  TestDataFactory.DocumentMasterData(true);
    DocDtl__c doc = TestDataFactory.createDocumentDetail(true,'Test Doc',app.id,dm.id);

        
        
        ApplBanking__c ab = new ApplBanking__c();
        ab.Appl__c = app.Id;
        ab.LoanAppl__c = la.Id;
        ab.TransactionId__c = 'PERFIOS1-RSA-SHA256';
        ab.DocumentDetail__c = doc.id;
        ab.Is_Statement_password_protected__c = 'No';
        ab.FileType__c = 'ePDF';
        ab.TransactionId__c = 'B39N1704447512961';
        insert ab;
        
       IntgMsg__c intgMsg = new IntgMsg__c();
        intgMsg.Name='Initiate Perfios';
        intgMsg.BU__c='HL / STL';
        intgMsg.Status__c='New';
        intgMsg.MStatus__c='Blank';
        intgMsg.RefObj__c='ApplKyc__c';
        intgMsg.RefId__c = doc.Id;
        intgMsg.ParentRefId__c = ab.Id;
        intgMsg.Resp__c = '{"transaction":{"perfiosTransactionId":"B39N1704447512961"}}';
        intgMsg.Trigger_Platform_Event__c=true;
        insert intgMsg;
       
        String filename = 'Response.json';
            
            ContentVersion newContentVersion = new ContentVersion();
            newContentVersion.Title = filename;
            newContentVersion.PathOnClient = filename;
            newContentVersion.VersionData = blob.valueof('{"Payload":{"payload":{"yearMonthTo":"2023-10","yearMonthFrom":"2023-05","uploadingScannedStatements":"true","txnId":"498522998","transactionCompleteCallbackUrl":"https://uat-api.fedfina.com/sandbox/uatPerfiosCallback","sisterCompanyNames":[],"sanctionLimitVariableAmounts":[],"sanctionLimitFixedAmount":"0","sanctionLimitFixed":"false","processingType":"STATEMENT","loanType":"Commercial Property Purchase","loanDuration":"180","loanAmount":"2100000","institutionId":"20","facility":"NONE","employmentType":"SelfEmployed","employerNames":[],"drawingPowerVariableAmounts":[],"companyNames":[{"namePattern":{"pattern":"Kumar Sanu"}}],"acceptancePolicy":"atLeastOneTransactionInRange"}},"Header":{"transactionID":null,"sha256Content":"00abebf336e9e1397fb65df2ec68c02d067a2e79e88705a0d19c0a94238d37ae","perfiosSignedHeaders":"host;x-perfios-content-sha256;x-perfios-date","perfioSignature":"57c11d448b3dbe5080d53b8eca3104774f77188b0574800aeb1f895eb521b33e15cd52fbdfcc917b2c94d1a28dc2327c6fbcc4c9726cbc2e8218c0668c880f769ed7b6c1ab25d7792004ed7d187c8c27067a02920c6ef7c513bae51bab4fc583de98e3d468e3429ab734cc17b24cdd8bdd645953ad5e45cc8bc0d14e83fe681781025426369b25c93105ff7a97b914c5efe780d53ef58458d2d03c5157fc3f5e742961451330c403c2893b66975cf6020439178a5554d5af694941d221797fa8c70bb40f1afc1c59798d352847bfc81f8b43b5679b246bd2d931a5e6ae51ec87c0d5bb3212301941a0669ddd37e4672e298d97df44a7983af0bc7b7c31665ecb11f43d5b6540cdb0c995fcd3678e9afeda9b7792406add8c75d093c3a7d5800776f282f9ded89dba7d06a88351158e0945fb7272415dd30a093824572e2c0e72685311188b6ac4f25d7d71ccda4453b9c0314974141fd48fc26036a52bb3b71bd7e7c63d4f30f86e57a9fd66cada8aa503cd8dbc6f4110877af8064a847353c01e8ab4f7f1a36eb6a4d1987a433520a630e32ea0dfb8fde5d278aca0d63ca6dcbf750be7b344fd5679b586eb9b6e0bf9f3e7e5917799311881e7a24c6bd75fe7aa9c0a778fd199ddfa0ae1c598238f53cd1c1f0478e889073d20d9d3f5d42302caa95f4c9c56bcdb41ab890e42a0e27264d19616223ddfc176883ce7ce953bd3","perfiosAlgorithm":"PERFIOS1-RSA-SHA256","perfioRequestDate":"20240108T185940Z","fileId":null}}');
            insert  newContentVersion; 
            
            Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:newContentVersion.Id].ContentDocumentId;
            ContentDocumentLink newContentLink = new ContentDocumentLink();
            newContentLink.ContentDocumentId = conDocId;
            newContentLink.LinkedEntityId = doc.id; 
            newContentLink.ShareType = 'V';   
            insert newContentLink;          
            
            
            IntgMsg__c intg = new IntgMsg__c();
            intg.Id = intgMsg.id;
            intg.Status__c = 'In Progress';
        	intg.Req__c = '{"transaction":{"perfiosTransactionId":"B39N1704447512921"}}';
            update intg;
        
        Test.startTest();
        List<IntgMsg__c> msgs = new List<IntgMsg__c>{intgMsg};
        	PerfiosProcessFilesRequestGenerator fileReqGenerate = new PerfiosProcessFilesRequestGenerator();
        	fileReqGenerate.generate(msgs, 'PerfiosProcessFilesRequestGenerator', 'Async');
        Test.stopTest();
        
    }
}