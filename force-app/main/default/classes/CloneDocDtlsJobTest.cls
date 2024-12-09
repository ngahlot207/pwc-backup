@istest
public class CloneDocDtlsJobTest {
    
    @testSetup
    static void testValidateData() {
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        Applicant__c app = TestDataFactory.createSingleApplicant(true,loanApp.id);
        
        List<ApplBanking__c> appbankingList = new List<ApplBanking__c>();
        appbankingList.add(new ApplBanking__c(
            MICR_Code__c = '400240077',
            Repayment_bank_A_c__c = 'Yes',
            LoanAppl__c = loanApp.Id,
            Name_of_the_Primary_Account_Holder_s__c = 'TEST',
            AccountType__c = 'CURRENT',
            AC_No__c = '123456789',
            BankName__c = 'ICICI Bank',
            Appl__c = app.Id
        ));
        TriggerBase.bypass('ApplBanking__c');
        insert appbankingList;
        TriggerBase.clearBypass('ApplBanking__c');
        
        List<ApplAsset__c> appAssetList = new List<ApplAsset__c>();
        appAssetList.add(new ApplAsset__c(
            Property_Carpet_area_Sq_Ft__c = 12,
            LoanAppln__c = loanApp.Id,
            Appl__c = app.Id
        ));
        TriggerBase.bypass('ApplAsset__c');
        insert appAssetList;
        TriggerBase.clearBypass('ApplAsset__c');   
        
        ApplGST__c appGST = new ApplGST__c();
        appGST.Main_GSTIN__c = true;
        appGST.Applicant__c = app.id;
        TriggerBase.bypass('ApplGST__c');
        insert appGST;
        TriggerBase.clearBypass('ApplGST__c');
        List<Case> caseList = new List<Case>();
        Id cvRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
            .get('Collateral Visit').getRecordTypeId();
        Id technicalRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
            .get('Technical').getRecordTypeId();
        Id cpvfiRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
            .get('CPVFI').getRecordTypeId();
        Id legalRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
            .get('Legal').getRecordTypeId();
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
        caseList.add(new Case(
            CVStatus__c = 'In Progress',
            Status = 'Closed',
            WaiveCPV__c = 'Yes',
            Loan_Application__c = loanApp.Id,
            Applicant__c = app.Id,
            RecordTypeId = cpvfiRecordTypeId
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
        
        Id applicantFinancialRecordTypeId = Schema.SObjectType.Applicant_Financial__c.getRecordTypeInfosByName()
            .get('Profit & Loss').getRecordTypeId();
        
        Id applicantFinancialGSTRecordTypeId = Schema.SObjectType.Applicant_Financial__c.getRecordTypeInfosByName()
            .get('GST').getRecordTypeId();
        Id applicantFinancialBSRecordTypeId = Schema.SObjectType.Applicant_Financial__c.getRecordTypeInfosByName()
            .get('Balance Sheet').getRecordTypeId();
        List<Applicant_Financial__c> appFinList = new List<Applicant_Financial__c>();
        appFinList.add(new Applicant_Financial__c(
            Loan_Applicant__c = app.id,
            RecordTypeId = applicantFinancialRecordTypeId
        ));
        appFinList.add(new Applicant_Financial__c(
            Loan_Applicant__c = app.id,
            RecordTypeId = applicantFinancialGSTRecordTypeId
        ));
        appFinList.add(new Applicant_Financial__c(
            Loan_Applicant__c = app.id,
            RecordTypeId = applicantFinancialBSRecordTypeId
        ));
        TriggerBase.bypass('Applicant_Financial__c');
        insert appFinList;
        TriggerBase.clearBypass('Applicant_Financial__c');
        
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
            ApplBanking__c = appbankingList[0].Id,
            Applicant_Financial__c = appFinList[0].Id,
            ApplAsset__c = appAssetList[0].Id,
            Applicant_GST__c = appGST.Id,
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
            ApplBanking__c = appbankingList[0].Id,
            Applicant_Financial__c = appFinList[0].Id,
            ApplAsset__c = appAssetList[0].Id,
            Applicant_GST__c = appGST.Id,
            DocSubTyp__c = 'Application Form'
        ));
        TriggerBase.bypass('DocDtl__c');
        insert docDtlList;
        TriggerBase.clearBypass('DocDtl__c');
        
    }
    
    
    @isTest
    static void cloneDocDtlsJobTestMethod() {
        
        LoanAppl__c loanApp = [SELECT Id,Stage__c,SubStage__c,Product__c FROM LoanAppl__c LIMIT 1];
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
        
        ApplBanking__c appbankingRec = [SELECT Id,ClonedSource__c FROM ApplBanking__c WHERE Appl__c = :app.Id LIMIT 1];
        appbankingRec.ClonedSource__c =appbankingRec.Id; 
        TriggerBase.bypass('ApplBanking__c');
        update appbankingRec;
        TriggerBase.clearBypass('ApplBanking__c');
        
        ApplGST__c appGstRec = [SELECT Id,ClonedSource__c FROM ApplGST__c WHERE Applicant__c = :app.Id LIMIT 1];
        appGstRec.ClonedSource__c =appGstRec.Id; 
        TriggerBase.bypass('ApplGST__c');
        update appGstRec;
        TriggerBase.clearBypass('ApplGST__c');
        
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
        
        Applicant_Financial__c appFinancilRec = [SELECT Id,ClonedSource__c FROM Applicant_Financial__c WHERE Loan_Applicant__c = :app.Id LIMIT 1];
        appFinancilRec.ClonedSource__c =appFinancilRec.Id; 
        TriggerBase.bypass('Applicant_Financial__c');
        update appFinancilRec;
        TriggerBase.clearBypass('Applicant_Financial__c');
        
        ApplKyc__c appKycRec = [SELECT Id,ClonedSource__c FROM ApplKyc__c WHERE Applicant__c = :app.Id LIMIT 1];
        appKycRec.ClonedSource__c =appKycRec.Id; 
        TriggerBase.bypass('ApplKyc__c');
        update appKycRec;
        TriggerBase.clearBypass('ApplKyc__c');
        
        // Set input data for the CloneLoanAppwrpr class
        CloneLoanAppController.CloneLoanAppwrpr inputData = new CloneLoanAppController.CloneLoanAppwrpr();
        inputData.recordId = loanApp.Id;
        inputData.userId = UserInfo.getUserId();
        inputData.cloneReason = 'BT + Top Up';
        
        CloneDocDtlsJob cloneJob = new CloneDocDtlsJob(inputData, loanApp.Product__c, clonedLoanAppId);
        
        Test.startTest();
        // Enqueue job
        System.enqueueJob(cloneJob);
        Test.stopTest();
        
        List<DocDtl__c> clonedDocDtls = [SELECT Id,Appl__c FROM DocDtl__c WHERE Appl__c = :app.Id];
        System.assertEquals(4, clonedDocDtls.size(), 'Document Detail Records should be cloned.');
        
        Boolean isAssert = true;
        try{
            CloneDocDtlsJob jobnew = new CloneDocDtlsJob(null,null,null);
            System.enqueueJob(jobnew);   
        }catch(AuraHandledException ex){
            isAssert = false;
            system.assertEquals('Script-thrown exception', ex.getMessage());
        }  
        system.assertEquals(true, isAssert);
    } 
}