@istest
public class CloneInProgPdTechCVDataControllerTest {
    
    @testSetup
    static void testValidateData() {
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        Applicant__c app = TestDataFactory.createSingleApplicant(true,loanApp.id);
        List<Case> caseList = new List<Case>();
        Id cvRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
            .get('Collateral Visit').getRecordTypeId();
        Id technicalRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
            .get('Technical').getRecordTypeId();
        caseList.add(new Case(
            CVStatus__c = 'In Progress',
            Status = 'Closed',
            IsReinitiated__c = false,
            Loan_Application__c = loanApp.Id,
            Applicant__c = app.Id,
            RecordTypeId = cvRecordTypeId
        ));
        caseList.add(new Case(
            CVStatus__c = 'In Progress',
            Status = 'Closed',
            IsReinitiated__c = false,
            IsCompleted__c = true,
            Property_Visit_Final_Status__c = 'Negative',
            Loan_Application__c = loanApp.Id,
            Applicant__c = app.Id,
            RecordTypeId = technicalRecordTypeId
        ));
        TriggerBase.bypass('Case');
        insert caseList;
        TriggerBase.clearBypass('Case');
        
        List<PD__c> pdList = new List<PD__c>();
        pdList.add(new PD__c(
            PDTyp__c = 'Physical PD',
            IsCompleted__c = true,
            PDStatus__c = 'Completed',
            Result__c = 'Negative',
            LoanAppl__c = loanApp.Id,
            Appl__c = app.Id
        )); 
        pdList.add(new PD__c(
            PDTyp__c = 'Physical PD',
            IsCompleted__c = true,
            PDStatus__c = 'Completed',
            Result__c = 'Positive',
            LoanAppl__c = loanApp.Id,
            Appl__c = app.Id
        )); 
        TriggerBase.bypass('PD__c');
        insert pdList;
        TriggerBase.clearBypass('PD__c'); 
        
        List<Ref__c> refList = new List<Ref__c>();
        refList.add(new Ref__c(
            PrsnlDis__c = pdList[1].Id,
            Loan_Application__c = loanApp.Id,
            Applicant__c = app.Id
        )); 
        TriggerBase.bypass('Ref__c');
        insert refList;
        TriggerBase.clearBypass('Ref__c'); 

        List<ApplAsset__c> appAssetList = new List<ApplAsset__c>();
        appAssetList.add(new ApplAsset__c(
            Property_Carpet_area_Sq_Ft__c = 12,
            LoanAppln__c = loanApp.Id,
            Appl__c = app.Id
        ));
        TriggerBase.bypass('ApplAsset__c');
        insert appAssetList;
        TriggerBase.clearBypass('ApplAsset__c'); 
        
        List<ApplKyc__c> appKycList = new List<ApplKyc__c>();
        appKycList.add(new ApplKyc__c(
            Applicant__c = app.Id,
            kycDoc__c = 'Aadhaar'
        ));
        appKycList.add(new ApplKyc__c(
            Applicant__c = app.Id,
            kycDoc__c = 'Driving License'
        ));
        TriggerBase.bypass('ApplKyc__c');
        insert appKycList;
        TriggerBase.clearBypass('ApplKyc__c');
        
        List<DocDtl__c> docDtlList = new List<DocDtl__c>();
        docDtlList.add(new DocDtl__c(
            DocCatgry__c = 'KYC Documents',
            DocTyp__c = 'Residence Address proof - OVD',
            Appl__c = app.id,
            LAN__c = loanApp.Id,
            Applicant_KYC__c = appKycList[0].Id,
            Case__c = caseList[0].Id,
            ApplAsset__c = appAssetList[0].Id,
            DocSubTyp__c = 'Voter Id'
        ));
        docDtlList.add(new DocDtl__c(
            DocCatgry__c = 'Application Form',
            DocTyp__c = 'Application Form',
            Appl__c = app.id,
            PrsnlDis__c = pdList[0].Id,
            Applicant_KYC__c = appKycList[0].Id,
            Case__c = caseList[0].Id,
            LAN__c = loanApp.Id,
            ApplAsset__c = appAssetList[0].Id,
            DocSubTyp__c = 'Application Form'
        ));
        TriggerBase.bypass('DocDtl__c');
        insert docDtlList;
        TriggerBase.clearBypass('DocDtl__c');
        
        List<PDResp__c> pdRespList = new List<PDResp__c>();
        pdRespList.add(new PDResp__c(
            PrsnlDisc__c = pdList[1].Id,
            DocDtl__c = docDtlList[0].Id
        )); 
        TriggerBase.bypass('PDResp__c');
        insert pdRespList;
        TriggerBase.clearBypass('PDResp__c'); 
        
        List<PDPrtcpnts__c> pdPartList = new List<PDPrtcpnts__c>();
        pdPartList.add(new PDPrtcpnts__c(
            PD__c = pdList[1].Id
        )); 
        TriggerBase.bypass('PDPrtcpnts__c');
        insert pdPartList;
        TriggerBase.clearBypass('PDPrtcpnts__c'); 
        
        Id AppIRecordTypeId1 = Schema.SObjectType.Applicant_Income__c.getRecordTypeInfosByName().get('Agricultural Income').getRecordTypeId();
        
        
        List<Applicant_Income__c> applicantIncomeRecords = new List<Applicant_Income__c>{
            new Applicant_Income__c(Applicant__c = app.Id, RecordTypeId = AppIRecordTypeId1)
                };
                    TriggerBase.bypass('Applicant_Income__c');
        insert applicantIncomeRecords;
        TriggerBase.clearBypass('Applicant_Income__c');
        
        List<ApplExpense__c> appExpensesList = new List<ApplExpense__c>();
        appExpensesList.add(new ApplExpense__c(
            PrsnlDis__c = pdList[1].Id,
            ApplInc__c = applicantIncomeRecords[0].Id
        )); 
        TriggerBase.bypass('ApplExpense__c');
        insert appExpensesList;
        TriggerBase.clearBypass('ApplExpense__c');
        
        List<CollateralVisitJn__c> cvList = new List<CollateralVisitJn__c>();
        cvList.add(new CollateralVisitJn__c(
            Case__c = caseList[0].Id,
            DocDtl__c = docDtlList[0].Id
        )); 
        cvList.add(new CollateralVisitJn__c(
             Case__c = caseList[1].Id,
            DocDtl__c = docDtlList[0].Id
        )); 
        TriggerBase.bypass('CollateralVisitJn__c');
        insert cvList;
        TriggerBase.clearBypass('CollateralVisitJn__c');
        
    }
    
    @isTest
    static void cloneInProgPdTechCVDataMethod() {
        
        LoanAppl__c loanApp = [SELECT Id,Stage__c,SubStage__c,Product__c,ClonedFor__c FROM LoanAppl__c LIMIT 1];
        loanApp.ClonedFor__c = loanApp.Id;
        update loanApp;
        Applicant__c app = [SELECT Id,ClonedFor__c FROM Applicant__c LIMIT 1];
        app.ClonedFor__c = app.Id;
        update app;
        
        LoanAppl__c loanAppp = [SELECT Id, Product__c FROM LoanAppl__c LIMIT 1];
        Id clonedLoanAppId = loanAppp.Id; // Simulate cloned loan application ID
        
        PD__c pdsRecrd = [SELECT Id,ClonedSource__c FROM PD__c WHERE Appl__c = :app.Id AND PDStatus__c = 'Completed' LIMIT 1];
        pdsRecrd.ClonedSource__c =pdsRecrd.Id; 
        TriggerBase.bypass('PD__c');
        update pdsRecrd;
        TriggerBase.clearBypass('PD__c');
        
        Case CaseRec = [SELECT Id,ClonedSource__c FROM Case WHERE Loan_Application__c = :clonedLoanAppId LIMIT 1];
        CaseRec.ClonedSource__c =CaseRec.Id; 
        TriggerBase.bypass('Case');
        update CaseRec;
        TriggerBase.clearBypass('Case');
        
        ApplAsset__c appAsset = [SELECT Id,ClonedSource__c FROM ApplAsset__c WHERE Appl__c = :app.Id LIMIT 1];
        appAsset.ClonedSource__c =appAsset.Id; 
        TriggerBase.bypass('ApplAsset__c');
        update appAsset;
        TriggerBase.clearBypass('ApplAsset__c');
        
        ApplKyc__c appKycRec = [SELECT Id,ClonedSource__c FROM ApplKyc__c WHERE Applicant__c = :app.Id LIMIT 1];
        appKycRec.ClonedSource__c =appKycRec.Id; 
        TriggerBase.bypass('ApplKyc__c');
        update appKycRec;
        TriggerBase.clearBypass('ApplKyc__c');
        
        
        // Set input data for the CloneLoanAppwrpr class
        CloneInProgPdTechCVDataController.CloneInProWrpr inputData = new CloneInProgPdTechCVDataController.CloneInProWrpr();
        inputData.loanAppId = loanApp.Id;
        inputData.appAssetId = '';
        inputData.cloneFor = 'PD';
        
        // CloneInProgPdTechCVDataController cloneJob = new CloneInProgPdTechCVDataController(inputData);
        CloneInProgPdTechCVDataController.cloneInProgPdTechCVDataMethod(inputData);
        // Test.startTest();
        // Enqueue job
        // System.enqueueJob(cloneJob);
        //Test.stopTest();        
       /* Boolean isAssert = true;
        try{
            CloneInProgPdTechCVDataController.cloneInProgPdTechCVDataMethod(null);
        }catch(AuraHandledException ex){
            isAssert = false;
            system.assertEquals('Script-thrown exception', ex.getMessage());
        }  */
        //system.assertEquals(true, isAssert);
    } 
    
    
      
    @isTest
    static void cloneInProgPdTechCVDataMethodOne() {
        
        LoanAppl__c loanApp = [SELECT Id,Stage__c,SubStage__c,Product__c,ClonedFor__c FROM LoanAppl__c LIMIT 1];
        loanApp.ClonedFor__c = loanApp.Id;
        update loanApp;
        Applicant__c app = [SELECT Id,ClonedFor__c FROM Applicant__c LIMIT 1];
        app.ClonedFor__c = app.Id;
        update app;
        
        LoanAppl__c loanAppp = [SELECT Id, Product__c FROM LoanAppl__c LIMIT 1];
        Id clonedLoanAppId = loanAppp.Id; // Simulate cloned loan application ID
        
      /*  PD__c pdsRecrd = [SELECT Id,ClonedSource__c FROM PD__c WHERE Appl__c = :app.Id AND PDStatus__c = 'Completed' LIMIT 1];
        pdsRecrd.ClonedSource__c =pdsRecrd.Id; 
        TriggerBase.bypass('PD__c');
        update pdsRecrd;
        TriggerBase.clearBypass('PD__c');*/
        
        Case CaseRec = [SELECT Id,ClonedSource__c FROM Case WHERE Loan_Application__c = :clonedLoanAppId LIMIT 1];
        CaseRec.ClonedSource__c =CaseRec.Id; 
        TriggerBase.bypass('Case');
        update CaseRec;
        TriggerBase.clearBypass('Case');
        
      /*  ApplAsset__c appAsset = [SELECT Id,ClonedSource__c FROM ApplAsset__c WHERE Appl__c = :app.Id LIMIT 1];
        appAsset.ClonedSource__c =appAsset.Id; 
        TriggerBase.bypass('ApplAsset__c');
        update appAsset;
        TriggerBase.clearBypass('ApplAsset__c');
        
        ApplKyc__c appKycRec = [SELECT Id,ClonedSource__c FROM ApplKyc__c WHERE Applicant__c = :app.Id LIMIT 1];
        appKycRec.ClonedSource__c =appKycRec.Id; 
        TriggerBase.bypass('ApplKyc__c');
        update appKycRec;
        TriggerBase.clearBypass('ApplKyc__c');*/
  
         CloneInProgPdTechCVDataController.CloneInProWrpr cvInputData = new CloneInProgPdTechCVDataController.CloneInProWrpr();
        cvInputData.loanAppId = loanApp.Id;
        cvInputData.appAssetId = '';
        cvInputData.cloneFor = 'CV';
        
        // CloneInProgPdTechCVDataController cloneJob = new CloneInProgPdTechCVDataController(inputData);
        CloneInProgPdTechCVDataController.cloneInProgPdTechCVDataMethod(cvInputData);
        
        Boolean isAssert = true;
        try{
            CloneInProgPdTechCVDataController.cloneInProgPdTechCVDataMethod(null);
        }catch(AuraHandledException ex){
            isAssert = false;
            system.assertEquals('Script-thrown exception', ex.getMessage());
        }  
       // system.assertEquals(true, isAssert);
    } 
    
      
    @isTest
    static void cloneInProgPdTechCVDataMethodTwo() {
        
        LoanAppl__c loanApp = [SELECT Id,Stage__c,SubStage__c,Product__c,ClonedFor__c FROM LoanAppl__c LIMIT 1];
        loanApp.ClonedFor__c = loanApp.Id;
        update loanApp;
        Applicant__c app = [SELECT Id,ClonedFor__c FROM Applicant__c LIMIT 1];
        app.ClonedFor__c = app.Id;
        update app;
        
        LoanAppl__c loanAppp = [SELECT Id, Product__c FROM LoanAppl__c LIMIT 1];
        Id clonedLoanAppId = loanAppp.Id; // Simulate cloned loan application ID
        
        /*PD__c pdsRecrd = [SELECT Id,ClonedSource__c FROM PD__c WHERE Appl__c = :app.Id AND PDStatus__c = 'Completed' LIMIT 1];
        pdsRecrd.ClonedSource__c =pdsRecrd.Id; 
        TriggerBase.bypass('PD__c');
        update pdsRecrd;
        TriggerBase.clearBypass('PD__c');*/
        
        Case CaseRec = [SELECT Id,ClonedSource__c FROM Case WHERE Loan_Application__c = :clonedLoanAppId LIMIT 1];
        CaseRec.ClonedSource__c =CaseRec.Id; 
        TriggerBase.bypass('Case');
        update CaseRec;
        TriggerBase.clearBypass('Case');
        
      /*  ApplAsset__c appAsset = [SELECT Id,ClonedSource__c FROM ApplAsset__c WHERE Appl__c = :app.Id LIMIT 1];
        appAsset.ClonedSource__c =appAsset.Id; 
        TriggerBase.bypass('ApplAsset__c');
        update appAsset;
        TriggerBase.clearBypass('ApplAsset__c');
        
        ApplKyc__c appKycRec = [SELECT Id,ClonedSource__c FROM ApplKyc__c WHERE Applicant__c = :app.Id LIMIT 1];
        appKycRec.ClonedSource__c =appKycRec.Id; 
        TriggerBase.bypass('ApplKyc__c');
        update appKycRec;
        TriggerBase.clearBypass('ApplKyc__c');*/
        
         CloneInProgPdTechCVDataController.CloneInProWrpr TechInputData = new CloneInProgPdTechCVDataController.CloneInProWrpr();
        TechInputData.loanAppId = loanApp.Id;
        TechInputData.appAssetId = '';
        TechInputData.cloneFor = 'Technical';
        
        // CloneInProgPdTechCVDataController cloneJob = new CloneInProgPdTechCVDataController(inputData);
        CloneInProgPdTechCVDataController.cloneInProgPdTechCVDataMethod(TechInputData);
        
        Boolean isAssert = true;
        try{
            CloneInProgPdTechCVDataController.cloneInProgPdTechCVDataMethod(null);
        }catch(AuraHandledException ex){
            isAssert = false;
            system.assertEquals('Script-thrown exception', ex.getMessage());
        }  
       // system.assertEquals(true, isAssert);
    } 
}