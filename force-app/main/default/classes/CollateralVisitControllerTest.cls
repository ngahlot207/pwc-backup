@isTest
public class CollateralVisitControllerTest {    
    @isTest
    static void testInitiateCollateralVisit() {
        // Create test data
        SchMapping__c schmapp = TestDataFactory.createSchemeMapping(true);
		LoanAppl__c la = TestDataFactory.createLoanApplication(true);
        Applicant__c app = TestDataFactory.createSingleApplicant(true, la.Id);
        DocMstr__c dm =  TestDataFactory.DocumentMasterData(true);
        la.SchemeId__c = schmapp.id;
        update la;
        Id caseRt = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Collateral Visit').getRecordTypeId();
        
        
        DocMstr__c docMst = new DocMstr__c();
        docMst.Prod__c = la.Product__c;
        docMst.Catgry__c = 'Collateral Visit';
        docMst.DocTyp__c = 'Collateral Visit Photographs';
        docMst.Active__c = TRUE;
        insert docMst;
        ApplAsset__c applicantasset = TestDataFactory.applAssetData(True,app.Id);
        applicantasset.Addr_of_prop_veri_as_per_Tit__c = 'Y';
        applicantasset.Bound_are_prop_dem_n_ide__c = 'Y';
        update applicantasset;
        Id stExam = Schema.SObjectType.PropQues__c.getRecordTypeInfosByName().get('Collateral Visit Questions').getRecordTypeId();
        PropQues__c propQ = new PropQues__c();
        propQ.FileConfig__c = '{"FileType":[".jpg",".jpeg",".pdf"],"AllowMultipleFile": true,"AllowUpload":true,"AllowDelete":true}';
        propQ.RespTyp__c = 'File';
        propQ.QuesRefId__c = 'PQ-707';
        propQ.IsActive__c = TRUE;
        propQ.SecTtl__c = 'Test Sect';
        propQ.SecSeq__c = 3;
        propQ.PossResp__c = '{"isFixed": true, "options": ["Relatives","Tenant","Vacant","Self"]}';
        propQ.OverrideConfig__c = '{"objectName":"ApplAsset__c","field":"Property_Usage__c","recordId":""}';
        propQ.RecordTypeId = stExam;
        propQ.DefValCri__c = '{"objectName": "Case", "childRelationObj": "Assigned_To__r", "field": "Name"}';
        propQ.ProdTyp__c = 'Home Loan';
        propQ.FiltrCri__c = '{"objectName":"ApplAsset__c","fields":["Is_it_an_APF__c"],"criteria":" Is_it_an_APF__c == \'Yes\' "}';
        insert propQ;
        
        PropQuesCrit__c propcrit = new PropQuesCrit__c();
        propcrit.EvalCrit__c = '["No"]';
        propcrit.IsActive__c =true;
        insert propcrit;
        
        // Insert necessary test data such as CVReequestWrapper, RecordType, LoanAppl__c, ApplAsset__c, SchMapping__c, PropQues__c, DocMstr__c records
         Profile testProfile = [SELECT Id FROM profile WHERE Name = 'LOS Base User' LIMIT 1];
        User testUser = new User(LastName = 'test user 1', 
                                 Username = 'test.createLoanTeam@example.com', 
                                 Email = 'test.1@example.com', 
                                 Alias = 'testu1', 
                                 TimeZoneSidKey = 'GMT', 
                                 LocaleSidKey = 'en_GB', 
                                 EmailEncodingKey = 'ISO-8859-1', 
                                 ProfileId = testProfile.Id, 
                                 LanguageLocaleKey = 'en_US'); 
        
        insert testUser;
        
        
        // Create a CVReequestWrapper instance with required data
        CollateralVisitController.CVReequestWrapper request = new CollateralVisitController.CVReequestWrapper();
        // Populate request with necessary data
        request.applicantId = applicantasset.Id;
        request.assigndTo = testUser.id;
        request.loanAppId = la.Id;
        request.schdDate = Date.today();
        
        /*ApplAsset__c appAssetDet = new ApplAsset__c();
        appAssetDet.PropIdentified__c = 'Yes';
        appAssetDet.CopyAddFrmExAdd__c = 'Yes';
        appAssetDet.PinId__c = '430005';
        appAssetDet.FlatNo__c = '123';
        appAssetDet.LoanAppln__c = la.Id;
        appAssetDet.Appl__c = app.Id;
        appAssetDet.PropSubType__c = 'AP - DEVELOPMENT AUTHORITY';
        insert appAssetDet;*/
        
        Case newCase = new Case();
            newCase.Loan_Application__c = request.loanAppId;
            newCase.ApplAssetId__c = request.applicantId;
        	//newCase.Applicant__c = applicantasset.Id;
            newCase.Assigned_To__c = request.assigndTo;
           newCase.SchDate__c = request.schdDate;
            newCase.RecordTypeId = caseRt;
        	newCase.CVStatus__c = 'Initiated';
        newCase.IsCompleted__c = true;
            insert newCase;
        String filename = 'Response.json';
        
        List<DocDtl__c> docDtlList = new List<DocDtl__c>();
        DocDtl__c testDocDtl = new DocDtl__c();
        testDocDtl.LAN__c = la.id;
        testDocDtl.Appl__c = app.id;
        testDocDtl.DocMstr__c = dm.id;
        testDocDtl.Case__c = newCase.id;
        testDocDtl.FileId__c =  '9b7b2a3c774137c246311d51de823457c6fa8200';
        testDocDtl.File_Type__c = 'ePDF';
        insert testDocDtl;
        ContentVersion newContentVersion = new ContentVersion();
            newContentVersion.Title = filename;
            newContentVersion.PathOnClient = filename;
            newContentVersion.VersionData = blob.valueof('{"Payload":{"payload":{"yearMonthTo":"2023-10","yearMonthFrom":"2023-05","uploadingScannedStatements":"true","txnId":"498522998","transactionCompleteCallbackUrl":"https://uat-api.fedfina.com/sandbox/uatPerfiosCallback","sisterCompanyNames":[],"sanctionLimitVariableAmounts":[],"sanctionLimitFixedAmount":"0","sanctionLimitFixed":"false","processingType":"STATEMENT","loanType":"Commercial Property Purchase","loanDuration":"180","loanAmount":"2100000","institutionId":"20","facility":"NONE","employmentType":"SelfEmployed","employerNames":[],"drawingPowerVariableAmounts":[],"companyNames":[{"namePattern":{"pattern":"Kumar Sanu"}}],"acceptancePolicy":"atLeastOneTransactionInRange"}},"Header":{"transactionID":null,"sha256Content":"00abebf336e9e1397fb65df2ec68c02d067a2e79e88705a0d19c0a94238d37ae","perfiosSignedHeaders":"host;x-perfios-content-sha256;x-perfios-date","perfioSignature":"57c11d448b3dbe5080d53b8eca3104774f77188b0574800aeb1f895eb521b33e15cd52fbdfcc917b2c94d1a28dc2327c6fbcc4c9726cbc2e8218c0668c880f769ed7b6c1ab25d7792004ed7d187c8c27067a02920c6ef7c513bae51bab4fc583de98e3d468e3429ab734cc17b24cdd8bdd645953ad5e45cc8bc0d14e83fe681781025426369b25c93105ff7a97b914c5efe780d53ef58458d2d03c5157fc3f5e742961451330c403c2893b66975cf6020439178a5554d5af694941d221797fa8c70bb40f1afc1c59798d352847bfc81f8b43b5679b246bd2d931a5e6ae51ec87c0d5bb3212301941a0669ddd37e4672e298d97df44a7983af0bc7b7c31665ecb11f43d5b6540cdb0c995fcd3678e9afeda9b7792406add8c75d093c3a7d5800776f282f9ded89dba7d06a88351158e0945fb7272415dd30a093824572e2c0e72685311188b6ac4f25d7d71ccda4453b9c0314974141fd48fc26036a52bb3b71bd7e7c63d4f30f86e57a9fd66cada8aa503cd8dbc6f4110877af8064a847353c01e8ab4f7f1a36eb6a4d1987a433520a630e32ea0dfb8fde5d278aca0d63ca6dcbf750be7b344fd5679b586eb9b6e0bf9f3e7e5917799311881e7a24c6bd75fe7aa9c0a778fd199ddfa0ae1c598238f53cd1c1f0478e889073d20d9d3f5d42302caa95f4c9c56bcdb41ab890e42a0e27264d19616223ddfc176883ce7ce953bd3","perfiosAlgorithm":"PERFIOS1-RSA-SHA256","perfioRequestDate":"20240108T185940Z","fileId":null}}');
            insert  newContentVersion; 
            
            Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:newContentVersion.Id].ContentDocumentId;
            ContentDocumentLink newContentLink = new ContentDocumentLink();
            newContentLink.ContentDocumentId = conDocId;
            newContentLink.LinkedEntityId = testDocDtl.id; 
            newContentLink.ShareType = 'V';   
            insert newContentLink;  
        
        
        CollateralVisitJn__c collVistJn = new CollateralVisitJn__c();
        collVistJn.PropQues__c = propQ.id;
        collVistJn.Case__c = newCase.id;
        collVistJn.DocDtl__c = testDocDtl.id;
        insert collVistJn;
        
         CollateralVisitController.CVResponseWrapper cvRespWrap = new CollateralVisitController.CVResponseWrapper();	
        cvRespWrap.recordId  = newCase.id;
            cvRespWrap.sectionTitle = propQ.SecTtl__c;
            cvRespWrap.sectionSeq = 3;
            //cvRespWrap.completedBy = ;
            //cvRespWrap.questions = ;
        
        list<ApplAsset__c> appAstList = new list<ApplAsset__c>{applicantasset};
        
        QuestionsSaveWrapper qustSavWrap = new QuestionsSaveWrapper();
        qustSavWrap.objectType = 'ApplAsset__c';
        qustSavWrap.records = appAstList;
        
        list<QuestionsSaveWrapper> qsavwrap = new list<QuestionsSaveWrapper>{qustSavWrap};
        Test.startTest();
        try{
        // Call the initiateCollateralVisit method
        CollateralVisitController.initiateCollateralVisit(request);
        CollateralVisitController.retrieveCV(newCase.id);
        CollateralVisitController.saveCV(newCase.id, qsavwrap);
        }catch(Exception e){}
        Test.stopTest();
    }
}