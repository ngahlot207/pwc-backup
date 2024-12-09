@isTest
public class PerfiosProcessFilesResponseProcessorTest {

    @isTest
    static void testProcess() {
         PerfiosProcessFilesResponseWrapper.BankStatement sampleBank = new PerfiosProcessFilesResponseWrapper.BankStatement();
        
        
        PerfiosProcessFilesResponseWrapper.BankAccounts sampleAccount = new PerfiosProcessFilesResponseWrapper.BankAccounts();
        sampleAccount.accountId = 'fec4b3f2fd9fec90e03de0f564a34c37417df2af';
        sampleAccount.accountNumber = 'XXXXXXXXXXXX0297';
        sampleAccount.accountType = 'Current';
        sampleAccount.complete = true;
        sampleAccount.institutionId = 30;
        List<PerfiosProcessFilesResponseWrapper.BankAccounts> bankAccounts1=new List<PerfiosProcessFilesResponseWrapper.BankAccounts>();
        bankAccounts1.add(sampleAccount);
        sampleBank.bankAccounts=bankAccounts1;
        
        
        
         LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        Applicant__c app = TestDataFactory.createSingleApplicant(true,loanApp.id);
        
         ApplBanking__c ab = new ApplBanking__c();
        ab.Appl__c = app.Id;
        ab.LoanAppl__c = loanApp.Id;
        ab.TransactionId__c = 'PERFIOS1-RSA-SHA256';
		TriggerBase.bypass('ApplBanking__c');
        insert ab;
        TriggerBase.clearbypass('ApplBanking__c');
		
         DocMstr__c dm =  TestDataFactory.DocumentMasterData(true);
        
        DocDtl__c testDocDtl = new DocDtl__c();
        testDocDtl.LAN__c = loanApp.id;
        testDocDtl.Appl__c = app.id;
        testDocDtl.DocMstr__c = dm.id;
        testDocDtl.FileId__c =  '9b7b2a3c774137c246311d51de823457c6fa8200';
        testDocDtl.File_Type__c = 'ePDF';
		TriggerBase.bypass('DocDtl__c');
        insert testDocDtl;
		TriggerBase.clearbypass('DocDtl__c');
        
        ContentVersion newContentVersion = new ContentVersion();
        newContentVersion.Title = 'Response.json';
        newContentVersion.PathOnClient = 'Response.json';
        newContentVersion.VersionData = blob.valueof('{"Payload":{"payload":{"yearMonthTo":"2023-10","yearMonthFrom":"2023-05","uploadingScannedStatements":"true","txnId":"498522998","transactionCompleteCallbackUrl":"https://uat-api.fedfina.com/sandbox/uatPerfiosCallback","sisterCompanyNames":[],"sanctionLimitVariableAmounts":[],"sanctionLimitFixedAmount":"0","sanctionLimitFixed":"false","processingType":"STATEMENT","loanType":"Commercial Property Purchase","loanDuration":"180","loanAmount":"2100000","institutionId":"20","facility":"NONE","employmentType":"SelfEmployed","employerNames":[],"drawingPowerVariableAmounts":[],"companyNames":[{"namePattern":{"pattern":"Kumar Sanu"}}],"acceptancePolicy":"atLeastOneTransactionInRange"}},"Header":{"transactionID":null,"sha256Content":"00abebf336e9e1397fb65df2ec68c02d067a2e79e88705a0d19c0a94238d37ae","perfiosSignedHeaders":"host;x-perfios-content-sha256;x-perfios-date","perfioSignature":"57c11d448b3dbe5080d53b8eca3104774f77188b0574800aeb1f895eb521b33e15cd52fbdfcc917b2c94d1a28dc2327c6fbcc4c9726cbc2e8218c0668c880f769ed7b6c1ab25d7792004ed7d187c8c27067a02920c6ef7c513bae51bab4fc583de98e3d468e3429ab734cc17b24cdd8bdd645953ad5e45cc8bc0d14e83fe681781025426369b25c93105ff7a97b914c5efe780d53ef58458d2d03c5157fc3f5e742961451330c403c2893b66975cf6020439178a5554d5af694941d221797fa8c70bb40f1afc1c59798d352847bfc81f8b43b5679b246bd2d931a5e6ae51ec87c0d5bb3212301941a0669ddd37e4672e298d97df44a7983af0bc7b7c31665ecb11f43d5b6540cdb0c995fcd3678e9afeda9b7792406add8c75d093c3a7d5800776f282f9ded89dba7d06a88351158e0945fb7272415dd30a093824572e2c0e72685311188b6ac4f25d7d71ccda4453b9c0314974141fd48fc26036a52bb3b71bd7e7c63d4f30f86e57a9fd66cada8aa503cd8dbc6f4110877af8064a847353c01e8ab4f7f1a36eb6a4d1987a433520a630e32ea0dfb8fde5d278aca0d63ca6dcbf750be7b344fd5679b586eb9b6e0bf9f3e7e5917799311881e7a24c6bd75fe7aa9c0a778fd199ddfa0ae1c598238f53cd1c1f0478e889073d20d9d3f5d42302caa95f4c9c56bcdb41ab890e42a0e27264d19616223ddfc176883ce7ce953bd3","perfiosAlgorithm":"PERFIOS1-RSA-SHA256","perfioRequestDate":"20240108T185940Z","fileId":null}}');
        TriggerBase.bypass('ContentVersion');
		insert  newContentVersion; 
        TriggerBase.clearbypass('ContentVersion');
		
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:newContentVersion.Id].ContentDocumentId;
        ContentDocumentLink newContentLink = new ContentDocumentLink();
        newContentLink.ContentDocumentId = conDocId;
        newContentLink.LinkedEntityId = testDocDtl.id; 
        newContentLink.ShareType = 'V'; 
		TriggerBase.bypass('ContentDocumentLink');
        insert newContentLink; 
        TriggerBase.clearbypass('ContentDocumentLink');
		
        // Test case 1: Correct service and BU type
        IntgMsg__c validResponse = new IntgMsg__c(
            Svc__c = 'Process Files', 
            BU__c = GlobalConstants.INT_MSG_BU_TYPE,Status__c='New',
            ParentRefId__c=ab.id,
            RefId__c=testDocDtl.id,
            Trigger_Platform_Event__c=true,
            Req__c='{"Payload":{"payload":{"password":"12211","fileId":"424ae0a7be7522c1689d98319eb52a3fdbd02fba"}},"Header":{"transactionID":"FYWQ1713440051264","sha256Content":"93e8065cf713fcdb374b4e086a4f5df4b66f22d206c71ecd71aecea7616d7ef5","reportTypes":null,"perfiosSignedHeaders":"host;x-perfios-content-sha256;x-perfios-date","perfioSignature":"54dc05af51ed4a42e47fcc4f950330c7c85e0860db66c7aa0d93c939cbee09ba79a47daaf345dc08bb47eac3eb605b754fc6d11a3a805ef76e6eb6330a628d50872bc8a2042e911080344f7b1dc282adf6725fb4c2058ad8f3475521d44b717a444ba64afd6b745487974b7a55536cc8086fe9236f92cca23320df7e3cbaae2976683b297c0eacd33d9e745ed6f02ae48c2181274cbe4bd94e222665737e2f68105f430d3bd8feaba0c71c31ae11256050cab7b1fb9fb674daea919f42c1a67c8725aadc5f3381d30be2bc5c02c20bc69b15c7756e66812f314591d7481b1c10ad014a8feabada2bde134ea245361af5f0bf53de4300e1896b5eaf6c440401474230a8f4e95f4135dbee22a408b20c1b790323cedb9047a2bb35ee350807ae62603ca217cc9e5839096fb6cbe69a3c048de4f04ed4ede10ed4d7081b4b493f6b9aef670e262ca0c2d41eb1a1b072bed17048fdd0ebbc5769f5175ac78370a2705ae02d2007df03d1250bc2ce10c706933b141e060ba7d7a98f1538ebc5033f3ae4a095cd37370f0ff181b257133cc489ea3d94e89b0d77184e710c8fbcf74f65d30d5c4ec01afaabb3bac5438ce982d06356078999cec11e1da035eee8be09fd500864946d6e16afbe18e00b21ca808d9f59b2af1827aedb0303b5e892853481e4b5bc1713734a8d2210e65140963ded232a4ebae811090cca9f8f97492b3882","perfiosAlgorithm":"PERFIOS1-RSA-SHA256","perfioRequestDate":"20240418T170455Z","fileId":"'+newContentVersion.Id+'"}}',
            Resp__c='{"bankStatement":{"bankAccounts":[{"accountId":"c186473166d3dedf5f5c4f9b1094218275ba1c71","accountNumber":"018201511496","accountType":"","complete":true,"institutionId":22,"missingMonths":["2023-06","2023-07","2023-08","2023-09","2023-10","2023-11","2023-12","2024-01","2024-02","2024-03"]}]}}'
        );
		TriggerBase.bypass('IntgMsg__c');
		insert validResponse;
		TriggerBase.clearbypass('IntgMsg__c');
		
		List<IntgMsg__c> intlist =new List<IntgMsg__c>{validResponse};
		
        PerfiosProcessFilesResponseWrapper responseWrapper = new PerfiosProcessFilesResponseWrapper();
        responseWrapper.bankStatement=sampleBank;
      
        Test.startTest();
        PerfiosProcessFilesResponseProcessor.process(intlist);
        Test.stopTest();

        
    }
 
    @isTest
    static void testProcess2() {
         PerfiosProcessFilesResponseWrapper.BankStatement sampleBank = new PerfiosProcessFilesResponseWrapper.BankStatement();
        
        
        PerfiosProcessFilesResponseWrapper.BankAccounts sampleAccount = new PerfiosProcessFilesResponseWrapper.BankAccounts();
        sampleAccount.accountId = 'fec4b3f2fd9fec90e03de0f564a34c37417df2af';
        sampleAccount.accountNumber = 'XXXXXXXXXXXX0297';
        sampleAccount.accountType = 'Current';
        sampleAccount.complete = true;
        sampleAccount.institutionId = 30;
        List<PerfiosProcessFilesResponseWrapper.BankAccounts> bankAccounts1=new List<PerfiosProcessFilesResponseWrapper.BankAccounts>();
        bankAccounts1.add(sampleAccount);
        sampleBank.bankAccounts=bankAccounts1;
        
        
        
         LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        Applicant__c app = TestDataFactory.createSingleApplicant(true,loanApp.id);
        
         ApplBanking__c ab = new ApplBanking__c();
        ab.Appl__c = app.Id;
        ab.LoanAppl__c = loanApp.Id;
        ab.TransactionId__c = 'PERFIOS1-RSA-SHA256';
       TriggerBase.bypass('ApplBanking__c');
        insert ab;
        TriggerBase.clearbypass('ApplBanking__c');
        
         DocMstr__c dm =  TestDataFactory.DocumentMasterData(true);
        
        DocDtl__c testDocDtl = new DocDtl__c();
        testDocDtl.LAN__c = loanApp.id;
        testDocDtl.Appl__c = app.id;
        testDocDtl.DocMstr__c = dm.id;
        testDocDtl.FileId__c =  '9b7b2a3c774137c246311d51de823457c6fa8200';
        testDocDtl.File_Type__c = 'ePDF';
        TriggerBase.bypass('DocDtl__c');
        insert testDocDtl;
		TriggerBase.clearbypass('DocDtl__c');
        
        
        
        IntgMsg__c validResponse = new IntgMsg__c(
            Svc__c = 'Process Files', 
            BU__c = GlobalConstants.INT_MSG_BU_TYPE,Status__c='New',
            ParentRefId__c=ab.id,
            RefId__c=testDocDtl.id,
            Trigger_Platform_Event__c=true,
            Req__c='{"Payload":{"payload":{"password":"12211","fileId":"424ae0a7be7522c1689d98319eb52a3fdbd02fba"}},"Header":{"transactionID":"FYWQ1713440051264","sha256Content":"93e8065cf713fcdb374b4e086a4f5df4b66f22d206c71ecd71aecea7616d7ef5","reportTypes":null,"perfiosSignedHeaders":"host;x-perfios-content-sha256;x-perfios-date","perfioSignature":"54dc05af51ed4a42e47fcc4f950330c7c85e0860db66c7aa0d93c939cbee09ba79a47daaf345dc08bb47eac3eb605b754fc6d11a3a805ef76e6eb6330a628d50872bc8a2042e911080344f7b1dc282adf6725fb4c2058ad8f3475521d44b717a444ba64afd6b745487974b7a55536cc8086fe9236f92cca23320df7e3cbaae2976683b297c0eacd33d9e745ed6f02ae48c2181274cbe4bd94e222665737e2f68105f430d3bd8feaba0c71c31ae11256050cab7b1fb9fb674daea919f42c1a67c8725aadc5f3381d30be2bc5c02c20bc69b15c7756e66812f314591d7481b1c10ad014a8feabada2bde134ea245361af5f0bf53de4300e1896b5eaf6c440401474230a8f4e95f4135dbee22a408b20c1b790323cedb9047a2bb35ee350807ae62603ca217cc9e5839096fb6cbe69a3c048de4f04ed4ede10ed4d7081b4b493f6b9aef670e262ca0c2d41eb1a1b072bed17048fdd0ebbc5769f5175ac78370a2705ae02d2007df03d1250bc2ce10c706933b141e060ba7d7a98f1538ebc5033f3ae4a095cd37370f0ff181b257133cc489ea3d94e89b0d77184e710c8fbcf74f65d30d5c4ec01afaabb3bac5438ce982d06356078999cec11e1da035eee8be09fd500864946d6e16afbe18e00b21ca808d9f59b2af1827aedb0303b5e892853481e4b5bc1713734a8d2210e65140963ded232a4ebae811090cca9f8f97492b3882","perfiosAlgorithm":"PERFIOS1-RSA-SHA256","perfioRequestDate":"20240418T170455Z","fileId":"068C4000002ofBhIAI"}}',
           // Resp__c='{"bankStatement":{"bankAccounts":[{"accountId":"c186473166d3dedf5f5c4f9b1094218275ba1c71","accountNumber":"018201511496","accountType":"","complete":true,"institutionId":22,"missingMonths":["2023-06","2023-07","2023-08","2023-09","2023-10","2023-11","2023-12","2024-01","2024-02","2024-03"]}]}}'
            Resp__c='{"error":{"code":"BadParameter","message":"Request did not validate","details":[{"code":"ILLEGAL_FIELD_VALUE","field":"fileId","message":"size must be between 40 and 40","value":null},{"code":"MISSING_FIELD_VALUE","field":"fileId","message":"Cannot be blank","value":null}]}}'
        );
		
		TriggerBase.bypass('IntgMsg__c');
		insert validResponse;
		TriggerBase.clearbypass('IntgMsg__c');
		
		List<IntgMsg__c> intlist =new List<IntgMsg__c>{validResponse};
		
        PerfiosProcessFilesResponseWrapper responseWrapper = new PerfiosProcessFilesResponseWrapper();
        responseWrapper.bankStatement=sampleBank;
      
        Test.startTest();
        PerfiosProcessFilesResponseProcessor.process(intlist);
        Test.stopTest();

        
    }
    
    @isTest
    static void testProcess3() {
         PerfiosProcessFilesResponseWrapper.BankStatement sampleBank = new PerfiosProcessFilesResponseWrapper.BankStatement();
        
        
        PerfiosProcessFilesResponseWrapper.BankAccounts sampleAccount = new PerfiosProcessFilesResponseWrapper.BankAccounts();
        sampleAccount.accountId = 'fec4b3f2fd9fec90e03de0f564a34c37417df2af';
        sampleAccount.accountNumber = 'XXXXXXXXXXXX0297';
        sampleAccount.accountType = 'Current';
        sampleAccount.complete = true;
        sampleAccount.institutionId = 30;
        List<PerfiosProcessFilesResponseWrapper.BankAccounts> bankAccounts1=new List<PerfiosProcessFilesResponseWrapper.BankAccounts>();
        bankAccounts1.add(sampleAccount);
        sampleBank.bankAccounts=bankAccounts1;
        
        
        
         LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        Applicant__c app = TestDataFactory.createSingleApplicant(true,loanApp.id);
        
         ApplBanking__c ab = new ApplBanking__c();
        ab.Appl__c = app.Id;
        ab.LoanAppl__c = loanApp.Id;
        ab.TransactionId__c = 'PERFIOS1-RSA-SHA256';
       TriggerBase.bypass('ApplBanking__c');
        insert ab;
        TriggerBase.clearbypass('ApplBanking__c');
        
         DocMstr__c dm =  TestDataFactory.DocumentMasterData(true);
        
        DocDtl__c testDocDtl = new DocDtl__c();
        testDocDtl.LAN__c = loanApp.id;
        testDocDtl.Appl__c = app.id;
        testDocDtl.DocMstr__c = dm.id;
        testDocDtl.FileId__c =  '9b7b2a3c774137c246311d51de823457c6fa8200';
        testDocDtl.File_Type__c = 'ePDF';
        TriggerBase.bypass('DocDtl__c');
        insert testDocDtl;
		TriggerBase.clearbypass('DocDtl__c');
        
        ContentVersion newContentVersion = new ContentVersion();
        newContentVersion.Title = 'Response.json';
        newContentVersion.PathOnClient = 'Response.json';
        newContentVersion.VersionData = blob.valueof('{"Payload":{"payload":{"yearMonthTo":"2023-10","yearMonthFrom":"2023-05","uploadingScannedStatements":"true","txnId":"498522998","transactionCompleteCallbackUrl":"https://uat-api.fedfina.com/sandbox/uatPerfiosCallback","sisterCompanyNames":[],"sanctionLimitVariableAmounts":[],"sanctionLimitFixedAmount":"0","sanctionLimitFixed":"false","processingType":"STATEMENT","loanType":"Commercial Property Purchase","loanDuration":"180","loanAmount":"2100000","institutionId":"20","facility":"NONE","employmentType":"SelfEmployed","employerNames":[],"drawingPowerVariableAmounts":[],"companyNames":[{"namePattern":{"pattern":"Kumar Sanu"}}],"acceptancePolicy":"atLeastOneTransactionInRange"}},"Header":{"transactionID":null,"sha256Content":"00abebf336e9e1397fb65df2ec68c02d067a2e79e88705a0d19c0a94238d37ae","perfiosSignedHeaders":"host;x-perfios-content-sha256;x-perfios-date","perfioSignature":"57c11d448b3dbe5080d53b8eca3104774f77188b0574800aeb1f895eb521b33e15cd52fbdfcc917b2c94d1a28dc2327c6fbcc4c9726cbc2e8218c0668c880f769ed7b6c1ab25d7792004ed7d187c8c27067a02920c6ef7c513bae51bab4fc583de98e3d468e3429ab734cc17b24cdd8bdd645953ad5e45cc8bc0d14e83fe681781025426369b25c93105ff7a97b914c5efe780d53ef58458d2d03c5157fc3f5e742961451330c403c2893b66975cf6020439178a5554d5af694941d221797fa8c70bb40f1afc1c59798d352847bfc81f8b43b5679b246bd2d931a5e6ae51ec87c0d5bb3212301941a0669ddd37e4672e298d97df44a7983af0bc7b7c31665ecb11f43d5b6540cdb0c995fcd3678e9afeda9b7792406add8c75d093c3a7d5800776f282f9ded89dba7d06a88351158e0945fb7272415dd30a093824572e2c0e72685311188b6ac4f25d7d71ccda4453b9c0314974141fd48fc26036a52bb3b71bd7e7c63d4f30f86e57a9fd66cada8aa503cd8dbc6f4110877af8064a847353c01e8ab4f7f1a36eb6a4d1987a433520a630e32ea0dfb8fde5d278aca0d63ca6dcbf750be7b344fd5679b586eb9b6e0bf9f3e7e5917799311881e7a24c6bd75fe7aa9c0a778fd199ddfa0ae1c598238f53cd1c1f0478e889073d20d9d3f5d42302caa95f4c9c56bcdb41ab890e42a0e27264d19616223ddfc176883ce7ce953bd3","perfiosAlgorithm":"PERFIOS1-RSA-SHA256","perfioRequestDate":"20240108T185940Z","fileId":null}}');
        TriggerBase.bypass('ContentVersion');
		insert  newContentVersion; 
        TriggerBase.clearbypass('ContentVersion');
		
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:newContentVersion.Id].ContentDocumentId;
        ContentDocumentLink newContentLink = new ContentDocumentLink();
        newContentLink.ContentDocumentId = conDocId;
        newContentLink.LinkedEntityId = testDocDtl.id; 
        newContentLink.ShareType = 'V'; 
		TriggerBase.bypass('ContentDocumentLink');
        insert newContentLink; 
        TriggerBase.clearbypass('ContentDocumentLink');
        
        IntgMsg__c validResponse = new IntgMsg__c(
            Svc__c = 'Process Files', 
            BU__c = GlobalConstants.INT_MSG_BU_TYPE,Status__c='New',
            ParentRefId__c=ab.id,
            RefId__c=testDocDtl.id,
            Trigger_Platform_Event__c=true,
            Req__c='{"Payload":{"payload":{"password":"12211","fileId":"424ae0a7be7522c1689d98319eb52a3fdbd02fba"}},"Header":{"transactionID":"FYWQ1713440051264","sha256Content":"93e8065cf713fcdb374b4e086a4f5df4b66f22d206c71ecd71aecea7616d7ef5","reportTypes":null,"perfiosSignedHeaders":"host;x-perfios-content-sha256;x-perfios-date","perfioSignature":"54dc05af51ed4a42e47fcc4f950330c7c85e0860db66c7aa0d93c939cbee09ba79a47daaf345dc08bb47eac3eb605b754fc6d11a3a805ef76e6eb6330a628d50872bc8a2042e911080344f7b1dc282adf6725fb4c2058ad8f3475521d44b717a444ba64afd6b745487974b7a55536cc8086fe9236f92cca23320df7e3cbaae2976683b297c0eacd33d9e745ed6f02ae48c2181274cbe4bd94e222665737e2f68105f430d3bd8feaba0c71c31ae11256050cab7b1fb9fb674daea919f42c1a67c8725aadc5f3381d30be2bc5c02c20bc69b15c7756e66812f314591d7481b1c10ad014a8feabada2bde134ea245361af5f0bf53de4300e1896b5eaf6c440401474230a8f4e95f4135dbee22a408b20c1b790323cedb9047a2bb35ee350807ae62603ca217cc9e5839096fb6cbe69a3c048de4f04ed4ede10ed4d7081b4b493f6b9aef670e262ca0c2d41eb1a1b072bed17048fdd0ebbc5769f5175ac78370a2705ae02d2007df03d1250bc2ce10c706933b141e060ba7d7a98f1538ebc5033f3ae4a095cd37370f0ff181b257133cc489ea3d94e89b0d77184e710c8fbcf74f65d30d5c4ec01afaabb3bac5438ce982d06356078999cec11e1da035eee8be09fd500864946d6e16afbe18e00b21ca808d9f59b2af1827aedb0303b5e892853481e4b5bc1713734a8d2210e65140963ded232a4ebae811090cca9f8f97492b3882","perfiosAlgorithm":"PERFIOS1-RSA-SHA256","perfioRequestDate":"20240418T170455Z","fileId":"'+newContentVersion.Id+'"}}',
            Resp__c='{"bankStatement":{"bankAccounts":[{"accountId":"c186473166d3dedf5f5c4f9b1094218275ba1c71","accountNumber":"018201511496","accountType":"","complete":true,"institutionId":22,"missingMonths":["2023-06","2023-07","2023-08","2023-09","2023-10","2023-11","2023-12","2024-01","2024-02","2024-03"]}]}}'
           // Resp__c='{"error":{"code":"BadParameter","message":"Request did not validate","details":[{"code":"ILLEGAL_FIELD_VALUE","field":"fileId","message":"size must be between 40 and 40","value":null},{"code":"MISSING_FIELD_VALUE","field":"fileId","message":"Cannot be blank","value":null}]}}'
        );
		
		TriggerBase.bypass('IntgMsg__c');
		insert validResponse;
		TriggerBase.clearbypass('IntgMsg__c');
		
		List<IntgMsg__c> intlist =new List<IntgMsg__c>{validResponse};
		
        PerfiosProcessFilesResponseWrapper responseWrapper = new PerfiosProcessFilesResponseWrapper();
        responseWrapper.bankStatement=sampleBank;
      
        Test.startTest();
        PerfiosProcessFilesResponseProcessor.process(intlist);
        Test.stopTest();

        
    }
}