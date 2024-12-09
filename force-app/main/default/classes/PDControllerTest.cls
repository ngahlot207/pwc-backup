@isTest
public class PDControllerTest {
    @isTest
    public static void testMethodPDCont(){
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        Applicant__c app = TestDataFactory.createSingleApplicant(true,loanApp.Id);
        ApplicantEmployment__c appEmp = TestDataFactory.createApplEmployment(true,app.id);
        BankBrchMstr__c bnk= TestDataFactory.TestDataBankBranchMaster(true);
        User u = TestDataFactory.UserData(true);
        u.FirstName = 'Sagg';
        update u;
        TeamHierarchy__c teamHir = TestDataFactory.TestDataTeamHierarchy_nonSup(true, u.id, bnk.id);
        teamHir.EmpRole__c='UW';
        update teamHir;
        DocMstr__c docMst = new DocMstr__c();
        docMst.Prod__c = loanApp.Product__c;
        docMst.DocTyp__c = 'PD Photographs';
        docMst.Catgry__c='Personal Discussion';
        docMst.Active__c =true;
        docMst.Required__c = true ;
        TriggerBase.bypass('DocMstr__c');
        insert docMst;
        TriggerBase.clearBypass('DocMstr__c');
        
        string str = '{"FileType": [".jpg",".jpeg",".pdf"], "AllowMultipleFile": true,"AllowUpload" : true,"AllowDelete" : true}';
        PDQues__c pdq = new PDQues__c();
        pdq.ProdTyp__c = loanApp.Product__c;
        pdq.PDTyp__c = 'Tele PD';
        pdq.Is_Active__c=true;
        pdq.QuesRefId__c = 'PDQ-00072';
        pdq.RespTyp__c='Video';
        pdq.QuesTtl__c='Avg. Daily Sales/ Receipts as per Applicant';
        pdq.FileConfig__c=str;
        pdq.SecTtl__c='Personal Discussion';
        pdq.Is_Active__c = true;
        pdq.CustProf__c = app.CustProfile__c;
        pdq.PDTyp__c = 'Physical PD';
        pdq.ProdTyp__c = loanApp.Product__c;
        pdq.FiltrCri__c = '{"objectName":"Applicant__c","fields":["Constitution__c"],"criteria":"Constitution__c == \'INDIVIDUAL\'"}';
        //pdq.RespTyp__c = 'Picklist Multiselect';
        pdq.OverrideConfig__c = '{"objectName":"Applicant_Income__c","field":"Constitution__c","recordId":"pdComp.recordId"}}';
        pdq.PossResp__c = '{"isFixed":true,"sourceObject":"IncomeType__c","sourceField":"","options":["Agricultural Income","Pension Income","Rental Income credit in banking","Rental Income with no bank credit","Other Income"]}';
        pdq.DefValCri__c = '{"objectName":"Applicant_Income__c","field":"Applicant__c","parentRelationObj":"Ref__c","childRelationObj":"","filterConditions":[{"field":"","value":""}]}}';
        insert pdq;
        
        PD__c pd = new PD__c();
        pd.LoanAppl__c = loanApp.Id;
        pd.Appl__c = app.Id;
        pd.PDStatus__c = 'Initiated';
        pd.AsgnTo__c = u.id;
        insert pd;
        
        id burRec = Schema.SObjectType.BureauRespDtl__c.getRecordTypeInfosByName().get('Consumer Obligation').getRecordTypeId();
        BureauRespDtl__c br = new BureauRespDtl__c();
        br.Applicant__c = app.Id;
        br.PrsnlDis__c=pd.Id;
        br.RecordTypeId = burRec;
        br.NatureOfLoan__c = 'Property Loan';
        insert br;
        
        PDPrtcpnts__c pdPct = new PDPrtcpnts__c();
        pdPct.PD__c = pd.Id;
        insert pdPct;
        
        PDResp__c pdRs =new PDResp__c();
        pdRs.PDQues__c = pdq.id;
        pdRs.PrsnlDisc__c = pd.id;
        insert pdrs;
        
        DocDtl__c doc = new DocDtl__c();
        doc.PrsnlDis__c = pd.id;
        doc.Appl__c = app.id;
        insert doc;
        
        
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
        
        PDQuesCri__c pdQueCri = new PDQuesCri__c();
        pdQueCri.IsActive__c = true;
        PDQueCri.ApcblQues__c = pdq.id;
        PDQueCri.EvalQues__c= pdq.id;
        pdQueCri.EvalCrit__c='["TRADING","MANUFACTURING"]';
        pdQueCri.DepValCnfg__c='{"sourceObject": "SubIndustry__c", "sourceField" : "Name", "dependentParent": "Industry__r","dependentField" : "Name"}';
        insert pdQueCri;
        
        PDController.PDReqestWrapper req = new PDController.PDReqestWrapper();
        req.loanAppId = loanApp.id;
        req.applicantId= app.id;
        req.pdMode= 'Physical PD';
        Test.startTest();
        System.runAs(u){
        PDController.initiatePD(req);
        PDController.retrievePD(pd.id);
        }
        Test.stopTest();
        
    }
    
        @isTest
    public static void testMethodPDCont1(){
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        loanApp.Status__c = 'Hold';
        TriggerBase.bypass('LoanAppl__c');
        update loanApp;
        TriggerBase.clearbypass('LoanAppl__c');
        Applicant__c app = TestDataFactory.createSingleApplicant(true,loanApp.Id);
        ApplicantEmployment__c appEmp = TestDataFactory.createApplEmployment(true,app.id);
        BankBrchMstr__c bnk= TestDataFactory.TestDataBankBranchMaster(true);
        User u = TestDataFactory.UserData(true);
        u.FirstName = 'Sagg';
        update u;
        TeamHierarchy__c teamHir = TestDataFactory.TestDataTeamHierarchy_nonSup(true, u.id, bnk.id);
        teamHir.EmpRole__c='UW';
        update teamHir;
        DocMstr__c docMst = new DocMstr__c();
        docMst.Prod__c = loanApp.Product__c;
        docMst.DocTyp__c = 'PD Photographs';
        docMst.Catgry__c='Personal Discussion';
        docMst.Active__c =true;
        docMst.Required__c = true ;
        TriggerBase.bypass('DocMstr__c');
        insert docMst;
        TriggerBase.clearBypass('DocMstr__c');
        
        string str = '{"FileType": [".jpg",".jpeg",".pdf"], "AllowMultipleFile": true,"AllowUpload" : true,"AllowDelete" : true}';

        
        
        
        PDQues__c pdq = new PDQues__c();
        pdq.ProdTyp__c = loanApp.Product__c;
        pdq.QuesRefId__c = 'PDQ-00101';
        pdq.Is_Active__c=true;
        pdq.FileConfig__c=str;
        pdq.SecTtl__c='Personal Discussion';
        pdq.Is_Active__c = true;
        pdq.CustProf__c = app.CustProfile__c;
        pdq.PDTyp__c = 'Tele PD';
        pdq.ProdTyp__c = loanApp.Product__c;
        pdq.FiltrCri__c = '{"objectName":"Applicant__c","fields":["Constitution__c"],"criteria":"Constitution__c == \'INDIVIDUAL\'"}';
        pdq.RespTyp__c = 'Picklist Multiselect';
        pdq.SecSeq__c = 4;
        pdq.DispSeq__c = 4;
        pdq.PossResp__c = '{"isFixed":false,"sourceObject":"IncomeType__c","sourceField":"abc","options":["Agricultural Income","Pension Income","Rental Income credit in banking","Rental Income with no bank credit","Other Income"]}';
        insert pdq;
        
        PD__c pd = new PD__c();
        pd.LoanAppl__c = loanApp.Id;
        pd.Appl__c = app.Id;
        pd.PDStatus__c = 'Initiated';
        pd.AsgnTo__c = u.id;
        insert pd;
        
        //id burRec = Schema.SObjectType.BureauRespDtl__c.getRecordTypeInfosByName().get('Consumer Obligation').getRecordTypeId();
        BureauRespDtl__c br = new BureauRespDtl__c();
        br.Applicant__c = app.Id;
        br.PrsnlDis__c=pd.Id;
        //br.RecordTypeId = burRec;
        br.Source__c = 'Manual';
        br.NatureOfLoan__c = 'Property Loan';
        insert br;
        
        PDPrtcpnts__c pdPct = new PDPrtcpnts__c();
        pdPct.PD__c = pd.Id;
        insert pdPct;
        
        PDResp__c pdRs =new PDResp__c();
        pdRs.PDQues__c = pdq.id;
        pdRs.PrsnlDisc__c = pd.id;
        insert pdrs;
        
        DocDtl__c doc = new DocDtl__c();
        doc.PrsnlDis__c = pd.id;
        doc.Appl__c = app.id;
        insert doc;
        
        
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
        
        PDQuesCri__c pdQueCri = new PDQuesCri__c();
        pdQueCri.IsActive__c = true;
        PDQueCri.ApcblQues__c = pdq.id;
        PDQueCri.EvalQues__c= pdq.id;
        pdQueCri.EvalCrit__c='["TRADING","MANUFACTURING"]';
        pdQueCri.DepValCnfg__c='{"sourceObject": "SubIndustry__c", "sourceField" : "Name","dependentField" : "Name"}';
        insert pdQueCri;
        
        PDController.PDReqestWrapper req = new PDController.PDReqestWrapper();
        req.loanAppId = loanApp.id;
        req.applicantId= app.id;
        req.pdMode= 'Physical PD';
        Test.startTest();
        System.runAs(u){
        PDController.initiatePD(req);
        PDController.retrievePD(pd.id);
        }
        Test.stopTest();
        
    }
    
            @isTest
    public static void testMethodPDCont2(){
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        Applicant__c app = TestDataFactory.createSingleApplicant(true,loanApp.Id);
        //ApplicantEmployment__c appEmp = TestDataFactory.createApplEmployment(true,app.id);
        BankBrchMstr__c bnk= TestDataFactory.TestDataBankBranchMaster(true);
        User u = TestDataFactory.UserData(true);
        u.FirstName = 'Sagg';
        update u;
        TeamHierarchy__c teamHir = TestDataFactory.TestDataTeamHierarchy_nonSup(true, u.id, bnk.id);
        teamHir.EmpRole__c='UW';
        update teamHir;
        DocMstr__c docMst = new DocMstr__c();
        docMst.Prod__c = loanApp.Product__c;
        docMst.DocTyp__c = 'PD Photographs';
        docMst.Catgry__c='Personal Discussion';
        docMst.Active__c =true;
        docMst.Required__c = true ;
        TriggerBase.bypass('DocMstr__c');
        insert docMst;
        TriggerBase.clearBypass('DocMstr__c');
        
        string str = '{"FileType": [".jpg",".jpeg",".pdf"], "AllowMultipleFile": true,"AllowUpload" : true,"AllowDelete" : true}';

        
        PDQues__c pdq = new PDQues__c();
        pdq.ProdTyp__c = loanApp.Product__c;
        pdq.QuesRefId__c = 'PDQ-00101';
        pdq.Is_Active__c=true;
        pdq.FileConfig__c=str;
        pdq.SecTtl__c='Personal Discussion';
        pdq.Is_Active__c = true;
        pdq.CustProf__c = app.CustProfile__c;
        pdq.PDTyp__c = 'Tele PD';
        pdq.ProdTyp__c = loanApp.Product__c;
        pdq.FiltrCri__c = '{"objectName":"Applicant__c","fields":["Constitution__c"],"criteria":"Constitution__c == \'INDIVIDUAL\'"}';
        pdq.RespTyp__c = 'Reference';
        //pdq.QuesConf__c = '{"objectName":"TeamHierarchy__c","selectedIconName":"standard:identifier","fieldName":"Employee__r.Name","selectrdField":"Name","filterCdn":" (EmpRole__c =\'UW\' OR  EmpRole__c=\'ACM\' OR EmpRole__c=\'RCM\' OR EmpRole__c=\'CM\' OR EmpRole__c=\'NCM\' OR EmpRole__c=\'CH\') ","keyId":"Employee__c","recConfig":{"objectName":"PDPrtcpnts__c"}}';
        pdq.QuesConf__c = '{"objectName":"Applicant_Income__c","columns":[{"label":"Type","fieldName":"IncomeType__c","type": "Picklist","required": true,"isReqMobile":true,"visibleOnMobile": true,"editable": true,"options":["Agricultural Income","Pension Income","Rental Income credit in banking","Rental Income with no bank credit","Other Income"]},{"label":"Monthly Amount","fieldName":"OtherRevenueMonthly__c","type":"Number","min":"0","required":true,"isReqMobile":true,"visibleOnMobile":true,"editable":true}]}';
        pdq.PossResp__c = '{"isFixed":false,"sourceObject":"IncomeType__c","sourceField":"","options":["Agricultural Income","Pension Income","Rental Income credit in banking","Rental Income with no bank credit","Other Income"]}';
        insert pdq;
        
                
        PDQues__c pdq1 = new PDQues__c();
        pdq1.ProdTyp__c = loanApp.Product__c;
        pdq1.QuesRefId__c = 'PDQ-00102';
        pdq1.Is_Active__c=true;
        pdq1.FileConfig__c=str;
        pdq1.SecTtl__c='Personal Discussion';
        pdq1.Is_Active__c = true;
        pdq1.CustProf__c = app.CustProfile__c;
        pdq1.PDTyp__c = 'Tele PD';
        pdq1.ProdTyp__c = loanApp.Product__c;
        pdq1.FiltrCri__c = '{"objectName":"Applicant__c","fields":["Constitution__c"],"criteria":"Constitution__c == \'INDIVIDUAL\'"}';
        pdq1.RespTyp__c = 'Table';
        pdq1.QuesConf__c = '{"objectName":"Applicant_Income__c","enableAddMore":true,"recordType":"PD Income","columns":[{"label":"Type","fieldName":"IncomeType__c","type":"Picklist","required":true,"isReqMobile":true,"visibleOnMobile":true,"editable":true,"options":["Agricultural Income","Pension Income","Rental Income credit in banking","Rental Income with no bank credit","Other Income"]},{"label":"Monthly Amount","fieldName":"OtherRevenueMonthly__c","type":"Number","min":"0","required":true,"isReqMobile":true,"visibleOnMobile":true,"editable":true},{"label":"Remarks","fieldName":"Remark__c","type":"Textarea","min":"0","required":true,"isReqMobile":true,"visibleOnMobile":true,"editable":true}]}';
        insert pdq1;
        
        PD__c pd = new PD__c();
        pd.LoanAppl__c = loanApp.Id;
        pd.Appl__c = app.Id;
        pd.PDStatus__c = 'Initiated';
        pd.AsgnTo__c = u.id;
        pd.IsCompleted__c = true;
        insert pd;
        
        id burRec = Schema.SObjectType.BureauRespDtl__c.getRecordTypeInfosByName().get('Commercial Obligation').getRecordTypeId();
        BureauRespDtl__c br = new BureauRespDtl__c();
        br.Applicant__c = app.Id;
        br.PrsnlDis__c=pd.Id;
        br.RecordTypeId = burRec;
        br.NatureOfLoan__c = 'Property Loan';
        br.CrdFacType__c = 'Current';
        insert br;
        
        PDPrtcpnts__c pdPct = new PDPrtcpnts__c();
        pdPct.PD__c = pd.Id;
        pdPct.User__c = u.id;
        insert pdPct;
        
        PDResp__c pdRs =new PDResp__c();
        pdRs.PDQues__c = pdq.id;
        pdRs.PrsnlDisc__c = pd.id;
        insert pdrs;
        
        PDResp__c pdRs1 =new PDResp__c();
        pdRs1.PDQues__c = pdq1.id;
        pdRs1.PrsnlDisc__c = pd.id;
        insert pdrs1;
        
        DocDtl__c doc = new DocDtl__c();
        doc.PrsnlDis__c = pd.id;
        doc.Appl__c = app.id;
        doc.LAN__c = loanApp.id;
        doc.DocCatgry__c = 'Bureau Report';
        insert doc;
        
        
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
        
        PDQuesCri__c pdQueCri = new PDQuesCri__c();
        pdQueCri.IsActive__c = true;
        PDQueCri.ApcblQues__c = pdq.id;
        PDQueCri.EvalQues__c= pdq.id;
        pdQueCri.EvalCrit__c='["TRADING","MANUFACTURING"]';
        pdQueCri.DepValCnfg__c='{"sourceObject": "SubIndustry__c", "sourceField" : "Name", "dependentParent": "Industry__r","dependentField" : "Name"}';
        insert pdQueCri;
        
        ApplAsset__c appAss = new ApplAsset__c();
        appAss.LoanAppln__c = loanApp.id;
        appAss.Appl__c = app.id;
        insert appAss;
        
        id appRt = Schema.SObjectType.Applicant_Income__c.getRecordTypeInfosByName().get('Cashflow Map').getRecordTypeId();
        Applicant_Income__c appInc = new Applicant_Income__c();
        appInc.Applicant__c = app.id;
        appInc.RecordTypeId = appRt;
        insert appInc;
        
        Ref__c ref = new Ref__c();
        ref.Loan_Application__c = loanApp.id;
        ref.Applicant__c = app.id;
        ref.RelationshipWthApp__c = 'M';
        insert ref;
        
        ApplExpense__c appExp = new ApplExpense__c();
        appExp.ApplInc__c = appInc.id;
        insert appExp;
        
        Industry__c ind = new Industry__c();
        ind.Status__c = 'A';
        insert ind;
        
        SubIndustry__c subInd = new SubIndustry__c();
        subInd.Industry__c = ind.id;
        insert subInd;
        
        ApplicantEmployment__c appEmp = new ApplicantEmployment__c();
        appEmp.IndustryType__c = ind.Id;
        appEmp.LoanApplicant__c = app.id;
        appEmp.SubIndustry__c = subInd.id;
        appEmp.NatureOfBusinessIndividual__c = 'M';
        appEmp.NatureOfBusinessCorporate__c = 'M';
        appEmp.TypeOfOrganisation__c = 'HU';
        insert appEmp;
        
        Repayment_Account__c repAcc = new Repayment_Account__c();
        repAcc.Loan_Application__c = loanApp.id;
        insert repAcc;
        
         ApplGST__c varObj = New ApplGST__c();
         varObj.Applicant__c = app.Id;
         varObj.ApplAsset__c = appAss.Id;
         varObj.GSTIN__c = 'Demo';
         insert varObj;
        
        /*PDC__c pdc = new PDC__c();
        pdc.Loan_Application__c = loanApp.id;
        pdc.PDC_Type__c = 'PDC';
        pdc.Repayment_Account__c = repAcc.id;
        TriggerBase.bypass('PDC__c');
        insert pdc;*/
        //TriggerBase.clearbypass('PDC__c');
        list<ApplAsset__c> appAssList = new list<ApplAsset__c>{appAss};
        list<PDPrtcpnts__c> pdPrtList = new list<PDPrtcpnts__c>{pdPct};
            
        PDController.PDReqestWrapper req = new PDController.PDReqestWrapper();
        req.loanAppId = loanApp.id;
        req.applicantId= app.id;
        req.pdMode= 'Physical PD';
        QuestionsSaveWrapper re1 = new QuestionsSaveWrapper();
        re1.objectType = 'ApplAsset__c';
        re1.records = appAssList;
        
        QuestionsSaveWrapper re2 = new QuestionsSaveWrapper();
        re2.objectType = 'PDPrtcpnts__c';
        re2.records = pdPrtList;
        
        list<Applicant_Income__c> appIncList = new list<Applicant_Income__c>{appInc};
        QuestionsSaveWrapper re3 = new QuestionsSaveWrapper();
        re3.objectType = 'Applicant_Income__c';
        re3.records = appIncList;
        
        list<PDResp__c> pdRespList = new list<PDResp__c>{pdRs1};
        QuestionsSaveWrapper re4 = new QuestionsSaveWrapper();
        re4.objectType = 'PDResp__c';
        re4.records = pdRespList;
        
        list<Ref__c> refList = new list<Ref__c>{ref};
        QuestionsSaveWrapper re5 = new QuestionsSaveWrapper();
        re5.objectType = 'Ref__c';
        re5.records = refList;
        
        list<ApplExpense__c> appExpList = new list<ApplExpense__c>{appExp};
        QuestionsSaveWrapper re6 = new QuestionsSaveWrapper();
        re6.objectType = 'ApplExpense__c';
        re6.records = appExpList;
        
        list<ApplicantEmployment__c> appEmpList = new list<ApplicantEmployment__c>{appEmp};
        QuestionsSaveWrapper re7 = new QuestionsSaveWrapper();
        re7.objectType = 'ApplicantEmployment__c';
        re7.records = appEmpList;
        
       list<Pd__c> pdList = new list<PD__c>{pd};
        QuestionsSaveWrapper re8 = new QuestionsSaveWrapper();
        re8.objectType = 'Pd__c';
        re8.records = pdList;
        
        list<Applicant__c> ApplList = new list<Applicant__c>{app};
        QuestionsSaveWrapper re9 = new QuestionsSaveWrapper();
        re9.objectType = 'Applicant__c';
        re9.records = ApplList;
        String pdId = pd.id;
        
        list<BureauRespDtl__c> brList = new list<BureauRespDtl__c>{br};
        QuestionsSaveWrapper re10 = new QuestionsSaveWrapper();
        re10.objectType = 'BureauRespDtl__c';
        re10.records = brList;
        
        //PDController.TableColumn tablCol = new PDController.TableColumn();
                    /*PDController.TableColumn recForm = (PDController.TableColumn) JSON.deserialize(
                        pdq.QuesConf__c,
                        PDController.TableColumn.class
                    );*/
        PDController.TableColumn pdTable = new PDController.TableColumn();
      	pdTable.label = 'Type';
        pdTable.fieldName = 'IncomeType__c';
        pdTable.type ='Picklist';
        pdTable.min ='0';
        pdTable.max ='0';
        pdTable.editable =true;
        pdTable.required =true;
        pdTable.isReqMobile =true;
        pdTable.visibleOnMobile =true;
        pdTable.options = new List<string>{'Agricultural Income','Pension Income','Rental Income credit in banking','Rental Income with no bank credit','Other Income'};
        pdTable.validationConfig = '{\"pattern\":\"^(?! )[a-zA-Z ]*$\"}';
        pdTable.mobileValidationConfig = '{\"pattern\":\"^(?! )[a-zA-Z ]*$\"}';
        
        PDController.PDAccompnyingUsers pdComp = new PDController.PDAccompnyingUsers();
      	pdComp.userId = u.id;
        pdComp.userName = 'IncomeType__c';
        pdComp.recordId =loanApp.id;
        
        PDController.PossibleValues pdPoss = new PDController.PossibleValues();
      	pdPoss.isFixed = true;
        pdPoss.sourceObject = 'IncomeType__c';
        pdPoss.sourceField ='';
        pdPoss.options = new List<string>{'Agricultural Income','Pension Income','Rental Income credit in banking','Rental Income with no bank credit','Other Income'};
   
        List<QuestionsSaveWrapper> req1 = new list<QuestionsSaveWrapper>{re1,re2,re3,re4,re5,re6,re7,re8,re9,re10};
        Test.startTest();
        System.runAs(u){
        PDController.initiatePD(req);
        PDController.retrievePD(pd.id);
        PDController.savePdData(pd.id,req1);
            try{PDController.savePdMultiselect(pdId,true,ApplList);}
            catch(Exception e){}
        }
        Test.stopTest();
        
    }
    
      @isTest
    public static void testMethodPDCont3(){
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        loanApp.Status__c = 'Hold';
        TriggerBase.bypass('LoanAppl__c');
        update loanApp;
        TriggerBase.clearbypass('LoanAppl__c');
        Applicant__c app = TestDataFactory.createSingleApplicant(true,loanApp.Id);
        ApplicantEmployment__c appEmp = TestDataFactory.createApplEmployment(true,app.id);
        BankBrchMstr__c bnk= TestDataFactory.TestDataBankBranchMaster(true);
        User u = TestDataFactory.UserData(true);
        u.FirstName = 'Sagg';
        update u;
        TeamHierarchy__c teamHir = TestDataFactory.TestDataTeamHierarchy_nonSup(true, u.id, bnk.id);
        teamHir.EmpRole__c='UW';
        update teamHir;
        DocMstr__c docMst = new DocMstr__c();
        docMst.Prod__c = loanApp.Product__c;
        docMst.DocTyp__c = 'PD Photographs';
        docMst.Catgry__c='Personal Discussion';
        docMst.Active__c =true;
        docMst.Required__c = true ;
        TriggerBase.bypass('DocMstr__c');
        insert docMst;
        TriggerBase.clearBypass('DocMstr__c');
        
        string str = '{"FileType": [".jpg",".jpeg",".pdf"], "AllowMultipleFile": true,"AllowUpload" : true,"AllowDelete" : true}';

        
        PDQues__c pdq = new PDQues__c();
        pdq.ProdTyp__c = loanApp.Product__c;
        pdq.QuesRefId__c = 'PDQ-00101';
        pdq.Is_Active__c=true;
        pdq.FileConfig__c=str;
        pdq.SecTtl__c='Personal Discussion';
        pdq.Is_Active__c = true;
        pdq.CustProf__c = app.CustProfile__c;
        pdq.PDTyp__c = 'Tele PD';
        pdq.ProdTyp__c = loanApp.Product__c;
        pdq.FiltrCri__c = '{"objectName":"Applicant__c","fields":["Constitution__c"],"criteria":"Constitution__c == \'INDIVIDUAL\'"}';
        pdq.RespTyp__c = 'Picklist Multiselect';
        pdq.SecSeq__c = 4;
        pdq.DispSeq__c = 4;
        insert pdq;
        
        PD__c pd = new PD__c();
        pd.LoanAppl__c = loanApp.Id;
        pd.Appl__c = app.Id;
        pd.PDStatus__c = 'Initiated';
        pd.AsgnTo__c = u.id;
        insert pd;
        
        //id burRec = Schema.SObjectType.BureauRespDtl__c.getRecordTypeInfosByName().get('Consumer Obligation').getRecordTypeId();
        BureauRespDtl__c br = new BureauRespDtl__c();
        br.Applicant__c = app.Id;
        //br.PrsnlDis__c=pd.Id;
        //br.RecordTypeId = burRec;
        br.Source__c = 'Manual';
        br.NatureOfLoan__c = 'Property Loan';
        insert br;
        
        PDPrtcpnts__c pdPct = new PDPrtcpnts__c();
        pdPct.PD__c = pd.Id;
        insert pdPct;
        
        PDResp__c pdRs =new PDResp__c();
        pdRs.PDQues__c = pdq.id;
        pdRs.PrsnlDisc__c = pd.id;
        insert pdrs;
        
        DocDtl__c doc = new DocDtl__c();
        doc.PrsnlDis__c = pd.id;
        doc.Appl__c = app.id;
        insert doc;
        
        
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
        
        PDQuesCri__c pdQueCri = new PDQuesCri__c();
        pdQueCri.IsActive__c = true;
        PDQueCri.ApcblQues__c = pdq.id;
        PDQueCri.EvalQues__c= pdq.id;
        pdQueCri.EvalCrit__c='["TRADING","MANUFACTURING"]';
        pdQueCri.DepValCnfg__c='{"sourceObject": "SubIndustry__c", "sourceField" : "Name","dependentField" : "Name"}';
        insert pdQueCri;
        
        PDController.PDReqestWrapper req = new PDController.PDReqestWrapper();
        req.loanAppId = loanApp.id;
        req.applicantId= app.id;
        req.pdMode= 'Physical PD';
        Test.startTest();
        System.runAs(u){
        PDController.initiatePD(req);
        PDController.retrievePD(pd.id);
        }
        Test.stopTest();
        
    }
    
      @isTest
    public static void testMethodPDCont4(){
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        Applicant__c app = TestDataFactory.createSingleApplicant(true,loanApp.Id);
        ApplicantEmployment__c appEmp = TestDataFactory.createApplEmployment(true,app.id);
        BankBrchMstr__c bnk= TestDataFactory.TestDataBankBranchMaster(true);
        User u = TestDataFactory.UserData(true);
        u.FirstName = 'Sagg';
        update u;
        TeamHierarchy__c teamHir = TestDataFactory.TestDataTeamHierarchy_nonSup(true, u.id, bnk.id);
        teamHir.EmpRole__c='UW';
        update teamHir;
        DocMstr__c docMst = new DocMstr__c();
        docMst.Prod__c = loanApp.Product__c;
        docMst.DocTyp__c = 'PD Photographs';
        docMst.Catgry__c='Personal Discussion';
        docMst.Active__c =true;
        docMst.Required__c = true ;
        TriggerBase.bypass('DocMstr__c');
        insert docMst;
        TriggerBase.clearBypass('DocMstr__c');
        
        string str = '{"FileType": [".jpg",".jpeg",".pdf"], "AllowMultipleFile": false,"AllowUpload" : false,"AllowDelete" : true}';
        PDQues__c pdq = new PDQues__c();
        pdq.ProdTyp__c = loanApp.Product__c;
        pdq.PDTyp__c = 'Tele PD';
        pdq.Is_Active__c=true;
        pdq.QuesRefId__c = 'PDQ-00072';
        pdq.RespTyp__c='Reference';
        pdq.QuesTtl__c='Avg. Daily Sales/ Receipts as per Applicant';
        pdq.FileConfig__c=str;
        pdq.SecTtl__c='Personal Discussion';
        pdq.Is_Active__c = true;
        pdq.CustProf__c = app.CustProfile__c;
        pdq.PDTyp__c = 'Physical PD';
        pdq.ProdTyp__c = loanApp.Product__c;
        pdq.FiltrCri__c = null ;
        insert pdq;
     
        PD__c pd = new PD__c();
        pd.LoanAppl__c = loanApp.Id;
        pd.Appl__c = app.Id;
        pd.PDStatus__c = 'Initiated';
        pd.AsgnTo__c = u.id;
        insert pd;
        
        id burRec = Schema.SObjectType.BureauRespDtl__c.getRecordTypeInfosByName().get('Consumer Obligation').getRecordTypeId();
        BureauRespDtl__c br = new BureauRespDtl__c();
        br.Applicant__c = app.Id;
        br.PrsnlDis__c=pd.Id;
        br.RecordTypeId = burRec;
        br.NatureOfLoan__c = 'Property Loan';
        insert br;
        
        PDPrtcpnts__c pdPct = new PDPrtcpnts__c();
        pdPct.PD__c = pd.Id;
        insert pdPct;
        
        PDResp__c pdRs =new PDResp__c();
        pdRs.PDQues__c = pdq.id;
        pdRs.PrsnlDisc__c = pd.id;
        insert pdrs;
        
        DocDtl__c doc = new DocDtl__c();
        doc.PrsnlDis__c = pd.id;
        doc.Appl__c = app.id;
        insert doc;
        
        
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
        
        PDQuesCri__c pdQueCri = new PDQuesCri__c();
        pdQueCri.IsActive__c = true;
        PDQueCri.ApcblQues__c = pdq.id;
        PDQueCri.EvalQues__c= pdq.id;
        pdQueCri.EvalCrit__c='["TRADING","MANUFACTURING"]';
        pdQueCri.DepValCnfg__c='{"sourceObject": "SubIndustry__c", "sourceField" : "Name", "dependentParent": "Industry__r","dependentField" : "Name"}';
        insert pdQueCri;
        
        PDController.PDReqestWrapper req = new PDController.PDReqestWrapper();
        req.loanAppId = loanApp.id;
        req.applicantId= app.id;
        req.pdMode= 'Physical PD';
        Test.startTest();
        System.runAs(u){
        PDController.initiatePD(req);
        //PDController.retrievePD(pd.id);
        }
        Test.stopTest();
        
    }
    
      @isTest
    public static void testMethodPDCont5(){
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        Applicant__c app = TestDataFactory.createSingleApplicant(true,loanApp.Id);
        ApplicantEmployment__c appEmp = TestDataFactory.createApplEmployment(true,app.id);
        BankBrchMstr__c bnk= TestDataFactory.TestDataBankBranchMaster(true);
        User u = TestDataFactory.UserData(true);
        u.FirstName = 'Sagg';
        update u;
        TeamHierarchy__c teamHir = TestDataFactory.TestDataTeamHierarchy_nonSup(true, u.id, bnk.id);
        teamHir.EmpRole__c='UW';
        update teamHir;
        DocMstr__c docMst = new DocMstr__c();
        docMst.Prod__c = loanApp.Product__c;
        docMst.DocTyp__c = 'PD Photographs';
        docMst.Catgry__c='Personal Discussion';
        docMst.Active__c =true;
        docMst.Required__c = true ;
        TriggerBase.bypass('DocMstr__c');
        insert docMst;
        TriggerBase.clearBypass('DocMstr__c');
        
        string str = '{"FileType": [".jpg",".jpeg",".pdf"], "AllowMultipleFile": true,"AllowUpload" : false,"AllowDelete" : true}';
        PDQues__c pdq = new PDQues__c();
        pdq.ProdTyp__c = loanApp.Product__c;
        pdq.PDTyp__c = 'Tele PD';
        pdq.Is_Active__c=true;
        pdq.QuesRefId__c = 'PDQ-00072';
        pdq.RespTyp__c='Video';
        pdq.QuesTtl__c='Avg. Daily Sales/ Receipts as per Applicant';
        pdq.FileConfig__c=str;
        pdq.SecTtl__c='Personal Discussion';
        pdq.Is_Active__c = true;
        pdq.CustProf__c = app.CustProfile__c;
        pdq.PDTyp__c = 'Physical PD';
        pdq.ProdTyp__c = loanApp.Product__c;
        //pdq.FiltrCri__c = '{"objectName":"Applicant__c","fields":["Constitution__c"],"criteria":"Constitution__c == \'INDIVIDUAL\'"}';
        pdq.FiltrCri__c = '{"objectName":null,"fields":["Constitution__c"],"criteria":"Constitution__c == \'INDIVIDUAL\'"}';
        //pdq.RespTyp__c = 'Picklist Multiselect';
        //pdq.PossResp__c = 'Demo PassResp';
        insert pdq;
        
        PD__c pd = new PD__c();
        pd.LoanAppl__c = loanApp.Id;
        pd.Appl__c = app.Id;
        pd.PDStatus__c = 'Initiated';
        pd.IsCompleted__c = true;
        pd.AsgnTo__c = u.id;
        insert pd;
        
        id burRec = Schema.SObjectType.BureauRespDtl__c.getRecordTypeInfosByName().get('Consumer Obligation').getRecordTypeId();
        BureauRespDtl__c br = new BureauRespDtl__c();
        br.Applicant__c = app.Id;
        br.PrsnlDis__c=pd.Id;
        br.RecordTypeId = burRec;
        br.NatureOfLoan__c = 'Property Loan';
        insert br;
        
        PDPrtcpnts__c pdPct = new PDPrtcpnts__c();
        pdPct.PD__c = pd.Id;
        insert pdPct;
        
        PDResp__c pdRs =new PDResp__c();
        pdRs.PDQues__c = pdq.id;
        pdRs.PrsnlDisc__c = pd.id;
        insert pdrs;
        
        DocDtl__c doc = new DocDtl__c();
        doc.PrsnlDis__c = pd.id;
        doc.Appl__c = app.id;
        insert doc;
        
        
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
        
        PDQuesCri__c pdQueCri = new PDQuesCri__c();
        pdQueCri.IsActive__c = true;
        PDQueCri.ApcblQues__c = pdq.id;
        PDQueCri.EvalQues__c= pdq.id;
      //pdQueCri.EvalCrit__c='["TRADING","MANUFACTURING"]';
        pdQueCri.EvalCrit__c= null;
        pdQueCri.DepValCnfg__c='{"sourceObject": "SubIndustry__c", "sourceField" : "Name", "dependentParent": "Industry__r","dependentField" : "Name"}';
        insert pdQueCri;
        
        PDController.PDReqestWrapper req = new PDController.PDReqestWrapper();
        req.loanAppId = loanApp.id;
        req.applicantId= app.id;
        req.pdMode= 'Physical PD';
        Test.startTest();
        System.runAs(u){
        PDController.initiatePD(req);
        PDController.retrievePD(pd.id);
        }
        Test.stopTest();
        
    }    
    
     @isTest
    public static void testMethodPDCont6(){
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        loanApp.Status__c= 'Hold';
        Applicant__c app = TestDataFactory.createSingleApplicant(true,loanApp.Id);
        //ApplicantEmployment__c appEmp = TestDataFactory.createApplEmployment(true,app.id);
        BankBrchMstr__c bnk= TestDataFactory.TestDataBankBranchMaster(true);
        User u = TestDataFactory.UserData(true);
        u.FirstName = 'Sagg';
        update u;
        TeamHierarchy__c teamHir = TestDataFactory.TestDataTeamHierarchy_nonSup(true, u.id, bnk.id);
        teamHir.EmpRole__c='UW';
        update teamHir;
        DocMstr__c docMst = new DocMstr__c();
        docMst.Prod__c = loanApp.Product__c;
        docMst.DocTyp__c = 'PD Photographs';
        docMst.Catgry__c='Personal Discussion';
        docMst.Active__c =true;
        docMst.Required__c = true ;
        TriggerBase.bypass('DocMstr__c');
        insert docMst;
        TriggerBase.clearBypass('DocMstr__c');
        
        string str = '{"FileType": [".jpg",".jpeg",".pdf"], "AllowMultipleFile": true,"AllowUpload" : true,"AllowDelete" : true}';

        
        PDQues__c pdq = new PDQues__c();
        pdq.ProdTyp__c = loanApp.Product__c;
        pdq.QuesRefId__c = 'PDQ-00101';
        pdq.Is_Active__c=true;
        pdq.FileConfig__c=str;
        pdq.SecTtl__c='Personal Discussion';
        pdq.Is_Active__c = true;
        pdq.CustProf__c = app.CustProfile__c;
        pdq.PDTyp__c = 'Tele PD';
        pdq.ProdTyp__c = loanApp.Product__c;
        pdq.FiltrCri__c = '{"objectName":"Applicant__c","fields":["Constitution__c"],"criteria":"Constitution__c == \'INDIVIDUAL\'"}';
        pdq.RespTyp__c = 'Reference';
        //pdq.QuesConf__c = '{"objectName":"TeamHierarchy__c","selectedIconName":"standard:identifier","fieldName":"Employee__r.Name","selectrdField":"Name","filterCdn":" (EmpRole__c =\'UW\' OR  EmpRole__c=\'ACM\' OR EmpRole__c=\'RCM\' OR EmpRole__c=\'CM\' OR EmpRole__c=\'NCM\' OR EmpRole__c=\'CH\') ","keyId":"Employee__c","recConfig":{"objectName":"PDPrtcpnts__c"}}';
        pdq.QuesConf__c ='{"objectName":"Applicant_Income__c","columns":[{"label":"Type","fieldName":"IncomeType__c","type":"Picklist","required":true,"isReqMobile":true,"visibleOnMobile":true,"editable":true,"options":["Agricultural Income","Pension Income","Rental Income credit in banking","Rental Income with no bank credit","Other Income"]},{"label":"Monthly Amount","fieldName":"OtherRevenueMonthly__c","type":"Number","min":"0","required":true,"isReqMobile":true,"visibleOnMobile":true,"editable":true}]}';
        insert pdq;
        
                
        PDQues__c pdq1 = new PDQues__c();
        pdq1.ProdTyp__c = loanApp.Product__c;
        pdq1.QuesRefId__c = 'PDQ-00102';
        pdq1.Is_Active__c=true;
        pdq1.FileConfig__c=str;
        pdq1.SecTtl__c='Personal Discussion';
        pdq1.Is_Active__c = true;
        pdq1.CustProf__c = app.CustProfile__c;
        pdq1.PDTyp__c = 'Tele PD';
        pdq1.ProdTyp__c = loanApp.Product__c;
        pdq1.FiltrCri__c = '{"objectName":"Applicant__c","fields":["Constitution__c"],"criteria":"Constitution__c == \'INDIVIDUAL\'"}';
        pdq1.RespTyp__c = 'Table';
      //pdq1.QuesConf__c = '{"objectName":"Applicant_Income__c","enableAddMore":true,"recordType":"PD Income","columns":[{"label":"Type","fieldName":"IncomeType__c","type":"Picklist","required":true,"isReqMobile":true,"visibleOnMobile":true,"editable":true,"options":["Agricultural Income","Pension Income","Rental Income credit in banking","Rental Income with no bank credit","Other Income"]},{"label":"Monthly Amount","fieldName":"OtherRevenueMonthly__c","type":"Number","min":"0","required":true,"isReqMobile":true,"visibleOnMobile":true,"editable":true},{"label":"Remarks","fieldName":"Remark__c","type":"Textarea","min":"0","required":true,"isReqMobile":true,"visibleOnMobile":true,"editable":true}]}';
        pdq1.QuesConf__c = '{"objectName":"BureauRespDtl__c","enableAddMore":true,"recordType":"PD Income","columns":[{"label":"Type","fieldName":"IncomeType__c","type":"Picklist","required":true,"isReqMobile":true,"visibleOnMobile":true,"editable":true,"options":["Agricultural Income","Pension Income","Rental Income credit in banking","Rental Income with no bank credit","Other Income"]},{"label":"Monthly Amount","fieldName":"OtherRevenueMonthly__c","type":"Number","min":"0","required":true,"isReqMobile":true,"visibleOnMobile":true,"editable":true},{"label":"Remarks","fieldName":"Remark__c","type":"Textarea","min":"0","required":true,"isReqMobile":true,"visibleOnMobile":true,"editable":true}]}';
        insert pdq1;
        
        PD__c pd = new PD__c();
        pd.LoanAppl__c = loanApp.Id;
        pd.Appl__c = app.Id;
        pd.PDStatus__c = 'Initiated';
        pd.AsgnTo__c = u.id;
        insert pd;
        
        id burRec = Schema.SObjectType.BureauRespDtl__c.getRecordTypeInfosByName().get('Commercial Obligation').getRecordTypeId();
        BureauRespDtl__c br = new BureauRespDtl__c();
        br.Applicant__c = app.Id;
        br.PrsnlDis__c=pd.Id;
        br.RecordTypeId = burRec;
        br.NatureOfLoan__c = 'Property Loan';
        br.CrdFacType__c = 'Current';
      //insert br;
        
        PDPrtcpnts__c pdPct = new PDPrtcpnts__c();
        pdPct.PD__c = pd.Id;
        pdPct.User__c = u.id;
        insert pdPct;
        
        PDResp__c pdRs =new PDResp__c();
        pdRs.PDQues__c = pdq.id;
        pdRs.PrsnlDisc__c = pd.id;
        insert pdrs;
        
        PDResp__c pdRs1 =new PDResp__c();
        pdRs1.PDQues__c = pdq1.id;
        pdRs1.PrsnlDisc__c = pd.id;
        insert pdrs1;
        
        DocDtl__c doc = new DocDtl__c();
        doc.PrsnlDis__c = pd.id;
        doc.Appl__c = app.id;
        doc.LAN__c = loanApp.id;
        doc.DocCatgry__c = 'Bureau Report';
        insert doc;
        
        
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
        
        PDQuesCri__c pdQueCri = new PDQuesCri__c();
        pdQueCri.IsActive__c = true;
        PDQueCri.ApcblQues__c = pdq.id;
        PDQueCri.EvalQues__c= pdq.id;
        pdQueCri.EvalCrit__c='["TRADING","MANUFACTURING"]';
      //pdQueCri.DepValCnfg__c='{"sourceObject": "SubIndustry__c", "sourceField" : "Name", "dependentParent": "Industry__r","dependentField" : "Name"}';
        pdQueCri.DepValCnfg__c='{"sourceObject": "SubIndustry__c", "sourceField" : "Name", "dependentParent": null,"dependentField" : "Name"}';
        insert pdQueCri;
        
        ApplAsset__c appAss = new ApplAsset__c();
        appAss.LoanAppln__c = loanApp.id;
        appAss.Appl__c = app.id;
       //insert appAss;
        
        id appRt = Schema.SObjectType.Applicant_Income__c.getRecordTypeInfosByName().get('Cashflow Map').getRecordTypeId();
        Applicant_Income__c appInc = new Applicant_Income__c();
        appInc.Applicant__c = app.id;
        appInc.RecordTypeId = appRt;
        insert appInc;
        
        Ref__c ref = new Ref__c();
        ref.Loan_Application__c = loanApp.id;
        ref.Applicant__c = app.id;
        ref.RelationshipWthApp__c = 'M';
        insert ref;
        
        ApplExpense__c appExp = new ApplExpense__c();
        appExp.ApplInc__c = appInc.id;
      //insert appExp;
        
        Industry__c ind = new Industry__c();
        ind.Status__c = 'A';
        insert ind;
        
        SubIndustry__c subInd = new SubIndustry__c();
        subInd.Industry__c = ind.id;
        insert subInd;
        
        ApplicantEmployment__c appEmp = new ApplicantEmployment__c();
        appEmp.IndustryType__c = ind.Id;
        appEmp.LoanApplicant__c = app.id;
        appEmp.SubIndustry__c = subInd.id;
        appEmp.NatureOfBusinessIndividual__c = 'M';
        appEmp.NatureOfBusinessCorporate__c = 'M';
        appEmp.TypeOfOrganisation__c = 'HU';
        insert appEmp;
        
        Repayment_Account__c repAcc = new Repayment_Account__c();
        repAcc.Loan_Application__c = loanApp.id;
        insert repAcc;
        
         ApplGST__c varObj = New ApplGST__c();
         varObj.Applicant__c = app.Id;
         varObj.ApplAsset__c = appAss.Id;
         varObj.GSTIN__c = 'Demo';
         insert varObj;
        
        /*PDC__c pdc = new PDC__c();
        pdc.Loan_Application__c = loanApp.id;
        pdc.PDC_Type__c = 'PDC';
        pdc.Repayment_Account__c = repAcc.id;
        TriggerBase.bypass('PDC__c');
        insert pdc;*/
        //TriggerBase.clearbypass('PDC__c');
        list<ApplAsset__c> appAssList = new list<ApplAsset__c>{appAss};
        list<PDPrtcpnts__c> pdPrtList = new list<PDPrtcpnts__c>{pdPct};
            
        PDController.PDReqestWrapper req = new PDController.PDReqestWrapper();
        req.loanAppId = loanApp.id;
        req.applicantId= app.id;
        req.pdMode= 'Physical PD';
        QuestionsSaveWrapper re1 = new QuestionsSaveWrapper();
        re1.objectType = 'ApplAsset__c';
        re1.records = appAssList;
        
        QuestionsSaveWrapper re2 = new QuestionsSaveWrapper();
        re2.objectType = 'PDPrtcpnts__c';
        re2.records = pdPrtList;
        
        list<Applicant_Income__c> appIncList = new list<Applicant_Income__c>{appInc};
        QuestionsSaveWrapper re3 = new QuestionsSaveWrapper();
        re3.objectType = 'Applicant_Income__c';
        re3.records = appIncList;
        
        list<PDResp__c> pdRespList = new list<PDResp__c>{pdRs1};
        QuestionsSaveWrapper re4 = new QuestionsSaveWrapper();
        re4.objectType = 'PDResp__c';
        re4.records = pdRespList;
        
        list<Ref__c> refList = new list<Ref__c>{ref};
        QuestionsSaveWrapper re5 = new QuestionsSaveWrapper();
        re5.objectType = 'Ref__c';
        re5.records = refList;
        
        list<ApplExpense__c> appExpList = new list<ApplExpense__c>{appExp};
        QuestionsSaveWrapper re6 = new QuestionsSaveWrapper();
        re6.objectType = 'ApplExpense__c';
        re6.records = appExpList;
        
        list<ApplicantEmployment__c> appEmpList = new list<ApplicantEmployment__c>{appEmp};
        QuestionsSaveWrapper re7 = new QuestionsSaveWrapper();
        re7.objectType = 'ApplicantEmployment__c';
        re7.records = appEmpList;
        
       list<Pd__c> pdList = new list<PD__c>{pd};
        QuestionsSaveWrapper re8 = new QuestionsSaveWrapper();
        re8.objectType = 'Pd__c';
        re8.records = pdList;
        
        list<PDC__c> pdLists = new list<PDC__c>{};
        QuestionsSaveWrapper re13 = new QuestionsSaveWrapper();
        re13.objectType = 'PDC__c';
        re13.records = pdLists;
        
        list<Applicant__c> ApplList = new list<Applicant__c>{app};
        QuestionsSaveWrapper re9 = new QuestionsSaveWrapper();
        re9.objectType = 'Applicant__c';
        re9.records = ApplList;
        String pdId = pd.id;
        
        list<BureauRespDtl__c> brList = new list<BureauRespDtl__c>{br};
        QuestionsSaveWrapper re10 = new QuestionsSaveWrapper();
        re10.objectType = 'BureauRespDtl__c';
        re10.records = brList;
        
 
        
        //PDController.TableColumn tablCol = new PDController.TableColumn();
                    /*PDController.TableColumn recForm = (PDController.TableColumn) JSON.deserialize(
                        pdq.QuesConf__c,
                        PDController.TableColumn.class
                    );*/
        PDController.TableColumn pdTable = new PDController.TableColumn();
      	pdTable.label = 'Type';
        pdTable.fieldName = 'IncomeType__c';
        pdTable.type ='Picklist';
        pdTable.min ='0';
        pdTable.max ='0';
        pdTable.editable =true;
        pdTable.required =true;
        pdTable.isReqMobile =true;
        pdTable.visibleOnMobile =true;
        pdTable.options = new List<string>{'Agricultural Income','Pension Income','Rental Income credit in banking','Rental Income with no bank credit','Other Income'};
        pdTable.validationConfig = '{\"pattern\":\"^(?! )[a-zA-Z ]*$\"}';
        pdTable.mobileValidationConfig = '{\"pattern\":\"^(?! )[a-zA-Z ]*$\"}';
        
        PDController.PDAccompnyingUsers pdComp = new PDController.PDAccompnyingUsers();
      	pdComp.userId = u.id;
        pdComp.userName = 'IncomeType__c';
        pdComp.recordId =loanApp.id;
        
        PDController.PossibleValues pdPoss = new PDController.PossibleValues();
      	pdPoss.isFixed = true;
        pdPoss.sourceObject = 'IncomeType__c';
        pdPoss.sourceField ='';
        pdPoss.options = new List<string>{'Agricultural Income','Pension Income','Rental Income credit in banking','Rental Income with no bank credit','Other Income'};
   
        List<QuestionsSaveWrapper> req1 = new list<QuestionsSaveWrapper>{re1,re2,re3,re4,re5,re6,re7,re8,re9,re10,re13};
        Test.startTest();
        System.runAs(u){
        PDController.initiatePD(req);
        PDController.retrievePD(pd.id);
        PDController.savePdData(pd.id,req1);
            try{PDController.savePdMultiselect(pdId,true,ApplList);}
            catch(Exception e){}
        }
        Test.stopTest();
        
    }
    
     @isTest
    public static void testMethodPDCont7(){
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        loanApp.Status__c = 'Hold';
        Applicant__c app = TestDataFactory.createSingleApplicant(true,loanApp.Id);
        //ApplicantEmployment__c appEmp = TestDataFactory.createApplEmployment(true,app.id);
        BankBrchMstr__c bnk= TestDataFactory.TestDataBankBranchMaster(true);
        User u = TestDataFactory.UserData(true);
        u.FirstName = 'Sagg';
        update u;
        TeamHierarchy__c teamHir = TestDataFactory.TestDataTeamHierarchy_nonSup(true, u.id, bnk.id);
        teamHir.EmpRole__c='UW';
        update teamHir;
        DocMstr__c docMst = new DocMstr__c();
        docMst.Prod__c = loanApp.Product__c;
        docMst.DocTyp__c = 'PD Photographs';
        docMst.Catgry__c='Personal Discussion';
        docMst.Active__c =true;
        docMst.Required__c = true ;
        TriggerBase.bypass('DocMstr__c');
        insert docMst;
        TriggerBase.clearBypass('DocMstr__c');
        
        string str = '{"FileType": [".jpg",".jpeg",".pdf"], "AllowMultipleFile": true,"AllowUpload" : true,"AllowDelete" : true}';

        
        PDQues__c pdq = new PDQues__c();
        pdq.ProdTyp__c = loanApp.Product__c;
        pdq.QuesRefId__c = 'PDQ-00101';
        pdq.Is_Active__c=true;
        pdq.FileConfig__c=str;
        pdq.SecTtl__c='Personal Discussion';
        pdq.Is_Active__c = true;
        pdq.CustProf__c = app.CustProfile__c;
        pdq.PDTyp__c = 'Tele PD';
        pdq.ProdTyp__c = loanApp.Product__c;
        pdq.FiltrCri__c = '{"objectName":"Applicant__c","fields":["Constitution__c"],"criteria":"Constitution__c == \'INDIVIDUAL\'"}';
        pdq.RespTyp__c = 'Reference';
      //pdq.RespTyp__c = 'DateTime';
       //pdq.PossResp__c = 'Demo PassResp';
        pdq.QuesConf__c = '{"objectName":"TeamHierarchy__c","selectedIconName":"standard:identifier","fieldName":"Employee__r.Name","selectrdField":"Name","filterCdn":" (EmpRole__c =\'UW\' OR  EmpRole__c=\'ACM\' OR EmpRole__c=\'RCM\' OR EmpRole__c=\'CM\' OR EmpRole__c=\'NCM\' OR EmpRole__c=\'CH\') ","keyId":"Employee__c","recConfig":{"objectName":"PDPrtcpnts__c"}}';
        insert pdq;
        
                
        PDQues__c pdq1 = new PDQues__c();
        pdq1.ProdTyp__c = loanApp.Product__c;
        pdq1.QuesRefId__c = 'PDQ-00102';
        pdq1.Is_Active__c=true;
        pdq1.FileConfig__c=str;
        pdq1.SecTtl__c='Personal Discussion';
        pdq1.Is_Active__c = true;
        pdq1.CustProf__c = app.CustProfile__c;
        pdq1.PDTyp__c = 'Tele PD';
        pdq1.ProdTyp__c = loanApp.Product__c;
        pdq1.FiltrCri__c = '{"objectName":"Applicant__c","fields":["Constitution__c"],"criteria":"Constitution__c == \'INDIVIDUAL\'"}';
        pdq1.RespTyp__c = 'Table';
      //pdq1.QuesConf__c = '{"objectName":"Applicant_Income__c","enableAddMore":true,"recordType":"PD Income","columns":[{"label":"Type","fieldName":"IncomeType__c","type":"Picklist","required":true,"isReqMobile":true,"visibleOnMobile":true,"editable":true,"options":["Agricultural Income","Pension Income","Rental Income credit in banking","Rental Income with no bank credit","Other Income"]},{"label":"Monthly Amount","fieldName":"OtherRevenueMonthly__c","type":"Number","min":"0","required":true,"isReqMobile":true,"visibleOnMobile":true,"editable":true},{"label":"Remarks","fieldName":"Remark__c","type":"Textarea","min":"0","required":true,"isReqMobile":true,"visibleOnMobile":true,"editable":true}]}';
        pdq1.QuesConf__c = '{"objectName":"BureauRespDtl__c","enableAddMore":null,"recordType":"Cashflow Map","columns":[{"label":"Type","fieldName":"IncomeType__c","type":"Picklist","required":true,"isReqMobile":true,"visibleOnMobile":true,"editable":true,"options":["Agricultural Income","Pension Income","Rental Income credit in banking","Rental Income with no bank credit","Other Income"]},{"label":"Monthly Amount","fieldName":"OtherRevenueMonthly__c","type":"Number","min":"0","required":true,"isReqMobile":true,"visibleOnMobile":true,"editable":true},{"label":"Remarks","fieldName":"Remark__c","type":"Textarea","min":"0","required":true,"isReqMobile":true,"visibleOnMobile":true,"editable":true}]}';
        insert pdq1;
        
        PD__c pd = new PD__c();
        pd.LoanAppl__c = loanApp.Id;
        pd.Appl__c = app.Id;
        pd.PDStatus__c = 'Initiated';
        pd.AsgnTo__c = u.id;
        insert pd;
        
        id burRec = Schema.SObjectType.BureauRespDtl__c.getRecordTypeInfosByName().get('Commercial Obligation').getRecordTypeId();
        BureauRespDtl__c br = new BureauRespDtl__c();
        br.Applicant__c = app.Id;
        br.PrsnlDis__c=pd.Id;
        br.RecordTypeId = burRec;
        br.NatureOfLoan__c = 'Property Loan';
        br.CrdFacType__c = 'Current';
        insert br;
        
        PDPrtcpnts__c pdPct = new PDPrtcpnts__c();
        pdPct.PD__c = pd.Id;
        //pdPct.User__c = u.id;
        pdPct.User__c = null;
        insert pdPct;
        
        PDResp__c pdRs =new PDResp__c();
        pdRs.PDQues__c = pdq.id;
        pdRs.PrsnlDisc__c = pd.id;
        insert pdrs;
        
        PDResp__c pdRs1 =new PDResp__c();
        pdRs1.PDQues__c = pdq1.id;
        pdRs1.PrsnlDisc__c = pd.id;
        insert pdrs1;
        
        DocDtl__c doc = new DocDtl__c();
        doc.PrsnlDis__c = pd.id;
        doc.Appl__c = app.id;
        doc.LAN__c = loanApp.id;
        doc.DocCatgry__c = 'Bureau Report';
        insert doc;
        
        
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
        
        PDQuesCri__c pdQueCri = new PDQuesCri__c();
        pdQueCri.IsActive__c = true;
        PDQueCri.ApcblQues__c = pdq.id;
        PDQueCri.EvalQues__c= pdq.id;
        pdQueCri.EvalCrit__c='["TRADING","MANUFACTURING"]';
      //pdQueCri.DepValCnfg__c='{"sourceObject": "SubIndustry__c", "sourceField" : "Name", "dependentParent": "Industry__r","dependentField" : "Name"}';
        pdQueCri.DepValCnfg__c='{"sourceObject": "SubIndustry__c", "sourceField" : "Name", "dependentParent": null,"dependentField" : "Name"}';
        insert pdQueCri;
        
        ApplAsset__c appAss = new ApplAsset__c();
        appAss.LoanAppln__c = loanApp.id;
        appAss.Appl__c = app.id;
        insert appAss;
        
        id appRt = Schema.SObjectType.Applicant_Income__c.getRecordTypeInfosByName().get('Cashflow Map').getRecordTypeId();
        Applicant_Income__c appInc = new Applicant_Income__c();
        appInc.Applicant__c = app.id;
        appInc.RecordTypeId = appRt;
        insert appInc;
        
        Ref__c ref = new Ref__c();
        ref.Loan_Application__c = loanApp.id;
        ref.Applicant__c = app.id;
        ref.RelationshipWthApp__c = 'M';
        insert ref;
        
        ApplExpense__c appExp = new ApplExpense__c();
        appExp.ApplInc__c = appInc.id;
        insert appExp;
        
        Industry__c ind = new Industry__c();
        ind.Status__c = 'A';
        insert ind;
        
        SubIndustry__c subInd = new SubIndustry__c();
        subInd.Industry__c = ind.id;
        insert subInd;
        
        ApplicantEmployment__c appEmp = new ApplicantEmployment__c();
        appEmp.IndustryType__c = ind.Id;
        appEmp.LoanApplicant__c = app.id;
        appEmp.SubIndustry__c = subInd.id;
        appEmp.NatureOfBusinessIndividual__c = 'M';
        appEmp.NatureOfBusinessCorporate__c = 'M';
        appEmp.TypeOfOrganisation__c = 'HU';
        insert appEmp;
        
        Repayment_Account__c repAcc = new Repayment_Account__c();
        repAcc.Loan_Application__c = loanApp.id;
        insert repAcc;
        
         ApplGST__c varObj = New ApplGST__c();
         varObj.Applicant__c = app.Id;
         varObj.ApplAsset__c = appAss.Id;
         varObj.GSTIN__c = 'Demo';
         insert varObj;
        
        /*PDC__c pdc = new PDC__c();
        pdc.Loan_Application__c = loanApp.id;
        pdc.PDC_Type__c = 'PDC';
        pdc.Repayment_Account__c = repAcc.id;
        TriggerBase.bypass('PDC__c');
        insert pdc;*/
        //TriggerBase.clearbypass('PDC__c');
        list<ApplAsset__c> appAssList = new list<ApplAsset__c>{appAss};
        list<PDPrtcpnts__c> pdPrtList = new list<PDPrtcpnts__c>{pdPct};
            
        PDController.PDReqestWrapper req = new PDController.PDReqestWrapper();
        req.loanAppId = loanApp.id;
        req.applicantId= app.id;
        req.pdMode= 'Physical PD';
        QuestionsSaveWrapper re1 = new QuestionsSaveWrapper();
        re1.objectType = 'ApplAsset__c';
        re1.records = appAssList;
        
        QuestionsSaveWrapper re2 = new QuestionsSaveWrapper();
        re2.objectType = 'PDPrtcpnts__c';
        re2.records = pdPrtList;
        
        list<Applicant_Income__c> appIncList = new list<Applicant_Income__c>{appInc};
        QuestionsSaveWrapper re3 = new QuestionsSaveWrapper();
        re3.objectType = 'Applicant_Income__c';
        re3.records = appIncList;
        
        list<PDResp__c> pdRespList = new list<PDResp__c>{pdRs1};
        QuestionsSaveWrapper re4 = new QuestionsSaveWrapper();
        re4.objectType = 'PDResp__c';
        re4.records = pdRespList;
        
        list<Ref__c> refList = new list<Ref__c>{ref};
        QuestionsSaveWrapper re5 = new QuestionsSaveWrapper();
        re5.objectType = 'Ref__c';
        re5.records = refList;
        
        list<ApplExpense__c> appExpList = new list<ApplExpense__c>{appExp};
        QuestionsSaveWrapper re6 = new QuestionsSaveWrapper();
        re6.objectType = 'ApplExpense__c';
        re6.records = appExpList;
        
        list<ApplicantEmployment__c> appEmpList = new list<ApplicantEmployment__c>{appEmp};
        QuestionsSaveWrapper re7 = new QuestionsSaveWrapper();
        re7.objectType = 'ApplicantEmployment__c';
        re7.records = appEmpList;
        
       list<Pd__c> pdList = new list<PD__c>{pd};
        QuestionsSaveWrapper re8 = new QuestionsSaveWrapper();
        re8.objectType = 'Pd__c';
        re8.records = pdList;
        
        list<Applicant__c> ApplList = new list<Applicant__c>{};
        QuestionsSaveWrapper re9 = new QuestionsSaveWrapper();
        re9.objectType = 'Applicant__c';
        re9.records = ApplList;
        String pdId = pd.id;
        
        list<BureauRespDtl__c> brList = new list<BureauRespDtl__c>{br};
        QuestionsSaveWrapper re10 = new QuestionsSaveWrapper();
        re10.objectType = 'BureauRespDtl__c';
        re10.records = brList;
        
        //PDController.TableColumn tablCol = new PDController.TableColumn();
                    /*PDController.TableColumn recForm = (PDController.TableColumn) JSON.deserialize(
                        pdq.QuesConf__c,
                        PDController.TableColumn.class
                    );*/
        PDController.TableColumn pdTable = new PDController.TableColumn();
      	pdTable.label = 'Type';
        pdTable.fieldName = 'IncomeType__c';
        pdTable.type ='Picklist';
        pdTable.min ='0';
        pdTable.max ='0';
        pdTable.editable =true;
        pdTable.required =true;
        pdTable.isReqMobile =true;
        pdTable.visibleOnMobile =true;
        pdTable.options = new List<string>{'Agricultural Income','Pension Income','Rental Income credit in banking','Rental Income with no bank credit','Other Income'};
        pdTable.validationConfig = '{\"pattern\":\"^(?! )[a-zA-Z ]*$\"}';
        pdTable.mobileValidationConfig = '{\"pattern\":\"^(?! )[a-zA-Z ]*$\"}';
        
        PDController.PDAccompnyingUsers pdComp = new PDController.PDAccompnyingUsers();
      	pdComp.userId = u.id;
        pdComp.userName = 'IncomeType__c';
        pdComp.recordId =loanApp.id;
        
        PDController.PossibleValues pdPoss = new PDController.PossibleValues();
      	pdPoss.isFixed = true;
        pdPoss.sourceObject = 'IncomeType__c';
        pdPoss.sourceField ='';
        pdPoss.options = new List<string>{'Agricultural Income','Pension Income','Rental Income credit in banking','Rental Income with no bank credit','Other Income'};
   
        List<QuestionsSaveWrapper> req1 = new list<QuestionsSaveWrapper>{re1,re2,re3,re4,re5,re6,re7,re8,re9,re10};
        Test.startTest();
        System.runAs(u){
        PDController.initiatePD(req);
        PDController.retrievePD(pd.id);
        PDController.savePdData(pd.id,req1);
            try{PDController.savePdMultiselect(pdId,true,ApplList);}
            catch(Exception e){}
        }
        Test.stopTest();
        
    }
   
   
    
}