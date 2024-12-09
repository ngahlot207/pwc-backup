@isTest
public class PerfiosUploadFilesResponseProcessorTest {
    @isTest
    public static void testGenerateMethod() {
        
        
        LoanAppl__c La = TestDataFactory.createLoanApplication(true);
        Applicant__c app = TestDataFactory.createSingleApplicant(true,La.id);
        Bureau__c br = TestDataFactory.BureauData(true, la.id, app.id);  
        br.BureauAPI__c = 'Consumer';
        upsert br;
        DocMstr__c dm =  TestDataFactory.DocumentMasterData(true);
        
        ApplBanking__c ab = new ApplBanking__c();
        ab.Appl__c = app.Id;
        ab.LoanAppl__c = la.Id;
        ab.TransactionId__c = 'PERFIOS1-RSA-SHA256';
        insert ab;
        
        // List<DocDtl__c> docDtlList = new List<DocDtl__c>();
        DocDtl__c testDocDtl = new DocDtl__c();
        testDocDtl.LAN__c = la.id;
        testDocDtl.Appl__c = app.id;
        testDocDtl.DocMstr__c = dm.id;
        testDocDtl.FileId__c =  '9b7b2a3c774137c246311d51de823457c6fa8200';
        testDocDtl.File_Type__c = 'ePDF';
        insert testDocDtl;
        //docDtlList.add(testDocDtl);
        
        
        
        ContentVersion newContentVersion = new ContentVersion();
        newContentVersion.Title = 'Response.json';
        newContentVersion.PathOnClient = 'Response.json';
        newContentVersion.VersionData = blob.valueof('{"Payload":{"payload":{"yearMonthTo":"2023-10","yearMonthFrom":"2023-05","uploadingScannedStatements":"true","txnId":"498522998","transactionCompleteCallbackUrl":"https://uat-api.fedfina.com/sandbox/uatPerfiosCallback","sisterCompanyNames":[],"sanctionLimitVariableAmounts":[],"sanctionLimitFixedAmount":"0","sanctionLimitFixed":"false","processingType":"STATEMENT","loanType":"Commercial Property Purchase","loanDuration":"180","loanAmount":"2100000","institutionId":"20","facility":"NONE","employmentType":"SelfEmployed","employerNames":[],"drawingPowerVariableAmounts":[],"companyNames":[{"namePattern":{"pattern":"Kumar Sanu"}}],"acceptancePolicy":"atLeastOneTransactionInRange"}},"Header":{"transactionID":null,"sha256Content":"00abebf336e9e1397fb65df2ec68c02d067a2e79e88705a0d19c0a94238d37ae","perfiosSignedHeaders":"host;x-perfios-content-sha256;x-perfios-date","perfioSignature":"57c11d448b3dbe5080d53b8eca3104774f77188b0574800aeb1f895eb521b33e15cd52fbdfcc917b2c94d1a28dc2327c6fbcc4c9726cbc2e8218c0668c880f769ed7b6c1ab25d7792004ed7d187c8c27067a02920c6ef7c513bae51bab4fc583de98e3d468e3429ab734cc17b24cdd8bdd645953ad5e45cc8bc0d14e83fe681781025426369b25c93105ff7a97b914c5efe780d53ef58458d2d03c5157fc3f5e742961451330c403c2893b66975cf6020439178a5554d5af694941d221797fa8c70bb40f1afc1c59798d352847bfc81f8b43b5679b246bd2d931a5e6ae51ec87c0d5bb3212301941a0669ddd37e4672e298d97df44a7983af0bc7b7c31665ecb11f43d5b6540cdb0c995fcd3678e9afeda9b7792406add8c75d093c3a7d5800776f282f9ded89dba7d06a88351158e0945fb7272415dd30a093824572e2c0e72685311188b6ac4f25d7d71ccda4453b9c0314974141fd48fc26036a52bb3b71bd7e7c63d4f30f86e57a9fd66cada8aa503cd8dbc6f4110877af8064a847353c01e8ab4f7f1a36eb6a4d1987a433520a630e32ea0dfb8fde5d278aca0d63ca6dcbf750be7b344fd5679b586eb9b6e0bf9f3e7e5917799311881e7a24c6bd75fe7aa9c0a778fd199ddfa0ae1c598238f53cd1c1f0478e889073d20d9d3f5d42302caa95f4c9c56bcdb41ab890e42a0e27264d19616223ddfc176883ce7ce953bd3","perfiosAlgorithm":"PERFIOS1-RSA-SHA256","perfioRequestDate":"20240108T185940Z","fileId":null}}');
        insert  newContentVersion; 
        
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:newContentVersion.Id].ContentDocumentId;
        ContentDocumentLink newContentLink = new ContentDocumentLink();
        newContentLink.ContentDocumentId = conDocId;
        newContentLink.LinkedEntityId = testDocDtl.id; 
        newContentLink.ShareType = 'V';   
        insert newContentLink; 
        
        ContentVersion newContentVersion1 = new ContentVersion();
        newContentVersion1.Title = 'Response.json';
        newContentVersion1.PathOnClient = 'Response.json';
        newContentVersion1.VersionData = blob.valueof('{"Payload":{"payload":{"yearMonthTo":"2023-10","yearMonthFrom":"2023-05","uploadingScannedStatements":"true","txnId":"498522998","transactionCompleteCallbackUrl":"https://uat-api.fedfina.com/sandbox/uatPerfiosCallback","sisterCompanyNames":[],"sanctionLimitVariableAmounts":[],"sanctionLimitFixedAmount":"0","sanctionLimitFixed":"false","processingType":"STATEMENT","loanType":"Commercial Property Purchase","loanDuration":"180","loanAmount":"2100000","institutionId":"20","facility":"NONE","employmentType":"SelfEmployed","employerNames":[],"drawingPowerVariableAmounts":[],"companyNames":[{"namePattern":{"pattern":"Kumar Sanu"}}],"acceptancePolicy":"atLeastOneTransactionInRange"}},"Header":{"transactionID":null,"sha256Content":"00abebf336e9e1397fb65df2ec68c02d067a2e79e88705a0d19c0a94238d37ae","perfiosSignedHeaders":"host;x-perfios-content-sha256;x-perfios-date","perfioSignature":"57c11d448b3dbe5080d53b8eca3104774f77188b0574800aeb1f895eb521b33e15cd52fbdfcc917b2c94d1a28dc2327c6fbcc4c9726cbc2e8218c0668c880f769ed7b6c1ab25d7792004ed7d187c8c27067a02920c6ef7c513bae51bab4fc583de98e3d468e3429ab734cc17b24cdd8bdd645953ad5e45cc8bc0d14e83fe681781025426369b25c93105ff7a97b914c5efe780d53ef58458d2d03c5157fc3f5e742961451330c403c2893b66975cf6020439178a5554d5af694941d221797fa8c70bb40f1afc1c59798d352847bfc81f8b43b5679b246bd2d931a5e6ae51ec87c0d5bb3212301941a0669ddd37e4672e298d97df44a7983af0bc7b7c31665ecb11f43d5b6540cdb0c995fcd3678e9afeda9b7792406add8c75d093c3a7d5800776f282f9ded89dba7d06a88351158e0945fb7272415dd30a093824572e2c0e72685311188b6ac4f25d7d71ccda4453b9c0314974141fd48fc26036a52bb3b71bd7e7c63d4f30f86e57a9fd66cada8aa503cd8dbc6f4110877af8064a847353c01e8ab4f7f1a36eb6a4d1987a433520a630e32ea0dfb8fde5d278aca0d63ca6dcbf750be7b344fd5679b586eb9b6e0bf9f3e7e5917799311881e7a24c6bd75fe7aa9c0a778fd199ddfa0ae1c598238f53cd1c1f0478e889073d20d9d3f5d42302caa95f4c9c56bcdb41ab890e42a0e27264d19616223ddfc176883ce7ce953bd3","perfiosAlgorithm":"PERFIOS1-RSA-SHA256","perfioRequestDate":"20240108T185940Z","fileId":null}}');
        insert  newContentVersion1; 
        
        Id conDocId1 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:newContentVersion1.Id].ContentDocumentId;
        ContentDocumentLink newContentLink1 = new ContentDocumentLink();
        newContentLink1.ContentDocumentId = conDocId1;
        newContentLink1.LinkedEntityId = testDocDtl.id; 
        newContentLink1.ShareType = 'V';   
        insert newContentLink1;
        
        IntgMsg__c intgMsg = new IntgMsg__c();
        intgMsg.Name='Initiate Perfios';
        intgMsg.BU__c='HL / STL';
        intgMsg.Status__c='New';
        intgMsg.MStatus__c='Blank';
        intgMsg.RefObj__c='DocDtl__c';
        intgMsg.RefId__c = testDocDtl.Id;
        intgMsg.ParentRefId__c = ab.Id;
        intgMsg.Req__c='{"Payload":"","Header":{"transactionID":"HFWM1713439511006","sha256Content":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855","reportTypes":null,"perfiosSignedHeaders":"host;x-perfios-content-sha256;x-perfios-date","perfioSignature":"8e3b17722272240c3ec20f3e0d33f2aa6a594f9be42e7b20ced18fa002e14eee821ded2110c5e60756db69a79abceb5f02acb9c68d786a8219fddebe9440b279e49a7b34fa2f077ab64fdf914fda176360271a387a1cf7628c301cf40c3b21703690f9f75cd0552628d32901d0083af8f20d65f0aba85956ea2f451e99e965fd030b0d954943ad9a6b67822dceb215a4bcbaa30c7b5b319fb785e47fe3e900bf7d6843f2e5fca7ba7e7431deef950acebe02d3b88b2f173b77b6c345f993b1a030605bed3c4772f0eb5284c5a3e20d650566ad2b3767335527bba86597cbc292a1863ea7c7933be23fa09f28ddff62640dd7d8403a5df68e9893dd6293298d4d8ca874a3fda15349f270cfa646a246f179d6e36efcf4fe63f9eaef03793c4558940acbda71cd0187be78d192a0ae4a563241e0ca0759b6767b512734a14241bc13b014675d4a42ff397ee19af03db32aca5969ac1f51dd63a464e513cd6d1fb73257ee3fb28332fd5019222010c93dfd9e65ad16e9dfbde4725b00349b185e1295e66ceae9ad1b18992f3847d679bd7288002f114af340523fc0459a208cf93a026e740636c490a437dee33ab42e9caa36a9c44da5ca3c52fd9193c3a7afa605e89f792a845ed5f1823885721596aa05d27681cf37408a92eb50131d0a4683694f7c6e3514060a046c79c6736d600f00c8b3c8f5e613b676af97e9534e5a6876","perfiosAlgorithm":"PERFIOS1-RSA-SHA256","perfioRequestDate":"20240418T165512Z","fileId":"'+newContentVersion.Id+'"}}';
        intgMsg.Resp__c = '{"file":{"fileId":"9b7b2a3c774137c246311d51de823457c6fa8200"}}';
        intgMsg.Trigger_Platform_Event__c=true;
        intgMsg.IsActive__c=true;
        intgMsg.DocApi__c = true;
        insert intgMsg;
        
        List<IntgMsg__c> msgs = new List<IntgMsg__c>{intgMsg};
            Test.startTest();
        PerfiosUploadFilesResponseProcessor.process(msgs);
        Test.StopTest();
        
        
        
    }
     @isTest
    public static void testGenerateMethod2() {
        
        
        LoanAppl__c La = TestDataFactory.createLoanApplication(true);
        Applicant__c app = TestDataFactory.createSingleApplicant(true,La.id);
        Bureau__c br = TestDataFactory.BureauData(true, la.id, app.id);  
        br.BureauAPI__c = 'Consumer';
        upsert br;
        DocMstr__c dm =  TestDataFactory.DocumentMasterData(true);
        
        ApplBanking__c ab = new ApplBanking__c();
        ab.Appl__c = app.Id;
        ab.LoanAppl__c = la.Id;
        ab.TransactionId__c = 'PERFIOS1-RSA-SHA256';
        insert ab;
        
        // List<DocDtl__c> docDtlList = new List<DocDtl__c>();
        DocDtl__c testDocDtl = new DocDtl__c();
        testDocDtl.LAN__c = la.id;
        testDocDtl.Appl__c = app.id;
        testDocDtl.DocMstr__c = dm.id;
        testDocDtl.FileId__c =  '9b7b2a3c774137c246311d51de823457c6fa8200';
        testDocDtl.File_Type__c = 'ePDF';
        insert testDocDtl;
        //docDtlList.add(testDocDtl);
        ContentVersion newContentVersion = new ContentVersion();
        newContentVersion.Title = 'Response.json';
        newContentVersion.PathOnClient = 'Response.json';
        newContentVersion.VersionData = blob.valueof('{"Payload":{"payload":{"yearMonthTo":"2023-10","yearMonthFrom":"2023-05","uploadingScannedStatements":"true","txnId":"498522998","transactionCompleteCallbackUrl":"https://uat-api.fedfina.com/sandbox/uatPerfiosCallback","sisterCompanyNames":[],"sanctionLimitVariableAmounts":[],"sanctionLimitFixedAmount":"0","sanctionLimitFixed":"false","processingType":"STATEMENT","loanType":"Commercial Property Purchase","loanDuration":"180","loanAmount":"2100000","institutionId":"20","facility":"NONE","employmentType":"SelfEmployed","employerNames":[],"drawingPowerVariableAmounts":[],"companyNames":[{"namePattern":{"pattern":"Kumar Sanu"}}],"acceptancePolicy":"atLeastOneTransactionInRange"}},"Header":{"transactionID":null,"sha256Content":"00abebf336e9e1397fb65df2ec68c02d067a2e79e88705a0d19c0a94238d37ae","perfiosSignedHeaders":"host;x-perfios-content-sha256;x-perfios-date","perfioSignature":"57c11d448b3dbe5080d53b8eca3104774f77188b0574800aeb1f895eb521b33e15cd52fbdfcc917b2c94d1a28dc2327c6fbcc4c9726cbc2e8218c0668c880f769ed7b6c1ab25d7792004ed7d187c8c27067a02920c6ef7c513bae51bab4fc583de98e3d468e3429ab734cc17b24cdd8bdd645953ad5e45cc8bc0d14e83fe681781025426369b25c93105ff7a97b914c5efe780d53ef58458d2d03c5157fc3f5e742961451330c403c2893b66975cf6020439178a5554d5af694941d221797fa8c70bb40f1afc1c59798d352847bfc81f8b43b5679b246bd2d931a5e6ae51ec87c0d5bb3212301941a0669ddd37e4672e298d97df44a7983af0bc7b7c31665ecb11f43d5b6540cdb0c995fcd3678e9afeda9b7792406add8c75d093c3a7d5800776f282f9ded89dba7d06a88351158e0945fb7272415dd30a093824572e2c0e72685311188b6ac4f25d7d71ccda4453b9c0314974141fd48fc26036a52bb3b71bd7e7c63d4f30f86e57a9fd66cada8aa503cd8dbc6f4110877af8064a847353c01e8ab4f7f1a36eb6a4d1987a433520a630e32ea0dfb8fde5d278aca0d63ca6dcbf750be7b344fd5679b586eb9b6e0bf9f3e7e5917799311881e7a24c6bd75fe7aa9c0a778fd199ddfa0ae1c598238f53cd1c1f0478e889073d20d9d3f5d42302caa95f4c9c56bcdb41ab890e42a0e27264d19616223ddfc176883ce7ce953bd3","perfiosAlgorithm":"PERFIOS1-RSA-SHA256","perfioRequestDate":"20240108T185940Z","fileId":null}}');
        insert  newContentVersion; 
        
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:newContentVersion.Id].ContentDocumentId;
        ContentDocumentLink newContentLink = new ContentDocumentLink();
        newContentLink.ContentDocumentId = conDocId;
        newContentLink.LinkedEntityId = testDocDtl.id; 
        newContentLink.ShareType = 'V';   
        insert newContentLink;
        
        IntgMsg__c intgMsg = new IntgMsg__c();
        intgMsg.Name='Initiate Perfios';
        intgMsg.BU__c='HL / STL';
        intgMsg.Status__c='New';
        intgMsg.MStatus__c='Blank';
        intgMsg.RefObj__c='DocDtl__c';
        intgMsg.RefId__c = testDocDtl.Id;
        intgMsg.ParentRefId__c = ab.Id;
        intgMsg.Req__c='{"Payload":"","Header":{"transactionID":"HFWM1713439511006","sha256Content":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855","reportTypes":null,"perfiosSignedHeaders":"host;x-perfios-content-sha256;x-perfios-date","perfioSignature":"8e3b17722272240c3ec20f3e0d33f2aa6a594f9be42e7b20ced18fa002e14eee821ded2110c5e60756db69a79abceb5f02acb9c68d786a8219fddebe9440b279e49a7b34fa2f077ab64fdf914fda176360271a387a1cf7628c301cf40c3b21703690f9f75cd0552628d32901d0083af8f20d65f0aba85956ea2f451e99e965fd030b0d954943ad9a6b67822dceb215a4bcbaa30c7b5b319fb785e47fe3e900bf7d6843f2e5fca7ba7e7431deef950acebe02d3b88b2f173b77b6c345f993b1a030605bed3c4772f0eb5284c5a3e20d650566ad2b3767335527bba86597cbc292a1863ea7c7933be23fa09f28ddff62640dd7d8403a5df68e9893dd6293298d4d8ca874a3fda15349f270cfa646a246f179d6e36efcf4fe63f9eaef03793c4558940acbda71cd0187be78d192a0ae4a563241e0ca0759b6767b512734a14241bc13b014675d4a42ff397ee19af03db32aca5969ac1f51dd63a464e513cd6d1fb73257ee3fb28332fd5019222010c93dfd9e65ad16e9dfbde4725b00349b185e1295e66ceae9ad1b18992f3847d679bd7288002f114af340523fc0459a208cf93a026e740636c490a437dee33ab42e9caa36a9c44da5ca3c52fd9193c3a7afa605e89f792a845ed5f1823885721596aa05d27681cf37408a92eb50131d0a4683694f7c6e3514060a046c79c6736d600f00c8b3c8f5e613b676af97e9534e5a6876","perfiosAlgorithm":"PERFIOS1-RSA-SHA256","perfioRequestDate":"20240418T165512Z","fileId":"'+newContentVersion.Id+'"}}'; 
        intgMsg.Resp__c='{"error":{"code":"BadParameter","message":"Request did not validate","details":[{"code":"ILLEGAL_FIELD_VALUE","field":"fileId","message":"size must be between 40 and 40","value":null},{"code":"MISSING_FIELD_VALUE","field":"fileId","message":"Cannot be blank","value":null}]}}';
        intgMsg.Trigger_Platform_Event__c=true;
        intgMsg.IsActive__c=true;
        intgMsg.DocApi__c = true;
        insert intgMsg;
        
        
        
        List<IntgMsg__c> msgs = new List<IntgMsg__c>{intgMsg};
            Test.startTest();
        PerfiosUploadFilesResponseProcessor.process(msgs);
        Test.StopTest();
        
        
        
    }
    
    @isTest
    public static void testGenerateMethod3() {
        
        
        LoanAppl__c La = TestDataFactory.createLoanApplication(true);
        Applicant__c app = TestDataFactory.createSingleApplicant(true,La.id);
        Bureau__c br = TestDataFactory.BureauData(true, la.id, app.id);  
        br.BureauAPI__c = 'Consumer';
        upsert br;
        DocMstr__c dm =  TestDataFactory.DocumentMasterData(true);
        
        ApplBanking__c ab = new ApplBanking__c();
        ab.Appl__c = app.Id;
        ab.LoanAppl__c = la.Id;
        ab.TransactionId__c = 'PERFIOS1-RSA-SHA256';
        insert ab;
        
        // List<DocDtl__c> docDtlList = new List<DocDtl__c>();
        DocDtl__c testDocDtl = new DocDtl__c();
        testDocDtl.LAN__c = la.id;
        testDocDtl.Appl__c = app.id;
        testDocDtl.DocMstr__c = dm.id;
        testDocDtl.FileId__c =  '9b7b2a3c774137c246311d51de823457c6fa8200';
        testDocDtl.File_Type__c = 'ePDF';
        insert testDocDtl;
        //docDtlList.add(testDocDtl);
        //
        ContentVersion newContentVersion = new ContentVersion();
        newContentVersion.Title = 'Response.json';
        newContentVersion.PathOnClient = 'Response.json';
        newContentVersion.VersionData = blob.valueof('{"Payload":{"payload":{"yearMonthTo":"2023-10","yearMonthFrom":"2023-05","uploadingScannedStatements":"true","txnId":"498522998","transactionCompleteCallbackUrl":"https://uat-api.fedfina.com/sandbox/uatPerfiosCallback","sisterCompanyNames":[],"sanctionLimitVariableAmounts":[],"sanctionLimitFixedAmount":"0","sanctionLimitFixed":"false","processingType":"STATEMENT","loanType":"Commercial Property Purchase","loanDuration":"180","loanAmount":"2100000","institutionId":"20","facility":"NONE","employmentType":"SelfEmployed","employerNames":[],"drawingPowerVariableAmounts":[],"companyNames":[{"namePattern":{"pattern":"Kumar Sanu"}}],"acceptancePolicy":"atLeastOneTransactionInRange"}},"Header":{"transactionID":null,"sha256Content":"00abebf336e9e1397fb65df2ec68c02d067a2e79e88705a0d19c0a94238d37ae","perfiosSignedHeaders":"host;x-perfios-content-sha256;x-perfios-date","perfioSignature":"57c11d448b3dbe5080d53b8eca3104774f77188b0574800aeb1f895eb521b33e15cd52fbdfcc917b2c94d1a28dc2327c6fbcc4c9726cbc2e8218c0668c880f769ed7b6c1ab25d7792004ed7d187c8c27067a02920c6ef7c513bae51bab4fc583de98e3d468e3429ab734cc17b24cdd8bdd645953ad5e45cc8bc0d14e83fe681781025426369b25c93105ff7a97b914c5efe780d53ef58458d2d03c5157fc3f5e742961451330c403c2893b66975cf6020439178a5554d5af694941d221797fa8c70bb40f1afc1c59798d352847bfc81f8b43b5679b246bd2d931a5e6ae51ec87c0d5bb3212301941a0669ddd37e4672e298d97df44a7983af0bc7b7c31665ecb11f43d5b6540cdb0c995fcd3678e9afeda9b7792406add8c75d093c3a7d5800776f282f9ded89dba7d06a88351158e0945fb7272415dd30a093824572e2c0e72685311188b6ac4f25d7d71ccda4453b9c0314974141fd48fc26036a52bb3b71bd7e7c63d4f30f86e57a9fd66cada8aa503cd8dbc6f4110877af8064a847353c01e8ab4f7f1a36eb6a4d1987a433520a630e32ea0dfb8fde5d278aca0d63ca6dcbf750be7b344fd5679b586eb9b6e0bf9f3e7e5917799311881e7a24c6bd75fe7aa9c0a778fd199ddfa0ae1c598238f53cd1c1f0478e889073d20d9d3f5d42302caa95f4c9c56bcdb41ab890e42a0e27264d19616223ddfc176883ce7ce953bd3","perfiosAlgorithm":"PERFIOS1-RSA-SHA256","perfioRequestDate":"20240108T185940Z","fileId":null}}');
        insert  newContentVersion; 
        
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:newContentVersion.Id].ContentDocumentId;
        ContentDocumentLink newContentLink = new ContentDocumentLink();
        newContentLink.ContentDocumentId = conDocId;
        newContentLink.LinkedEntityId = testDocDtl.id; 
        newContentLink.ShareType = 'V';   
        insert newContentLink; 
        
        IntgMsg__c intgMsg = new IntgMsg__c();
        intgMsg.Name='Initiate Perfios';
        intgMsg.BU__c='HL / STL';
        intgMsg.Status__c='New';
        intgMsg.MStatus__c='Blank';
        intgMsg.RefObj__c='DocDtl__c';
        intgMsg.RefId__c = testDocDtl.Id;
        intgMsg.ParentRefId__c = ab.Id;
        intgMsg.Req__c='{"Payload":"","Header":{"transactionID":"HFWM1713439511006","sha256Content":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855","reportTypes":null,"perfiosSignedHeaders":"host;x-perfios-content-sha256;x-perfios-date","perfioSignature":"8e3b17722272240c3ec20f3e0d33f2aa6a594f9be42e7b20ced18fa002e14eee821ded2110c5e60756db69a79abceb5f02acb9c68d786a8219fddebe9440b279e49a7b34fa2f077ab64fdf914fda176360271a387a1cf7628c301cf40c3b21703690f9f75cd0552628d32901d0083af8f20d65f0aba85956ea2f451e99e965fd030b0d954943ad9a6b67822dceb215a4bcbaa30c7b5b319fb785e47fe3e900bf7d6843f2e5fca7ba7e7431deef950acebe02d3b88b2f173b77b6c345f993b1a030605bed3c4772f0eb5284c5a3e20d650566ad2b3767335527bba86597cbc292a1863ea7c7933be23fa09f28ddff62640dd7d8403a5df68e9893dd6293298d4d8ca874a3fda15349f270cfa646a246f179d6e36efcf4fe63f9eaef03793c4558940acbda71cd0187be78d192a0ae4a563241e0ca0759b6767b512734a14241bc13b014675d4a42ff397ee19af03db32aca5969ac1f51dd63a464e513cd6d1fb73257ee3fb28332fd5019222010c93dfd9e65ad16e9dfbde4725b00349b185e1295e66ceae9ad1b18992f3847d679bd7288002f114af340523fc0459a208cf93a026e740636c490a437dee33ab42e9caa36a9c44da5ca3c52fd9193c3a7afa605e89f792a845ed5f1823885721596aa05d27681cf37408a92eb50131d0a4683694f7c6e3514060a046c79c6736d600f00c8b3c8f5e613b676af97e9534e5a6876","perfiosAlgorithm":"PERFIOS1-RSA-SHA256","perfioRequestDate":"20240418T165512Z","fileId":"'+newContentVersion.Id+'"}}'; 
        intgMsg.Resp__c = '{"file":{"fileId":"9b7b2a3c774137c246311d51de823457c6fa8200"}}';
        intgMsg.Trigger_Platform_Event__c=true;
        intgMsg.IsActive__c=true;
        intgMsg.DocApi__c = true;
        insert intgMsg;
        
        
        
        List<IntgMsg__c> msgs = new List<IntgMsg__c>{intgMsg};
            Test.startTest();
        PerfiosUploadFilesResponseProcessor.process(msgs);
        Test.StopTest();
        
        
        
    }
}