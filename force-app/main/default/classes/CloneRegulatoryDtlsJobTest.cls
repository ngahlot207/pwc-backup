@istest
public class CloneRegulatoryDtlsJobTest {
    
    @testSetup
    static void testValidateData() {
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        Applicant__c app = TestDataFactory.createSingleApplicant(true,loanApp.id);
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
        
        List<DocDtl__c> docDtlList = new List<DocDtl__c>();
        docDtlList.add(new DocDtl__c(
            DocCatgry__c = 'KYC Documents',
            DocTyp__c = 'Residence Address proof - OVD',
            Appl__c = app.id,
            LAN__c = loanApp.Id,
            DocSubTyp__c = 'Voter Id'
        ));
        docDtlList.add(new DocDtl__c(
            DocCatgry__c = 'Application Form',
            DocTyp__c = 'Application Form',
            Appl__c = app.id,
            LAN__c = loanApp.Id,
            DocSubTyp__c = 'Application Form'
        ));
        TriggerBase.bypass('DocDtl__c');
        insert docDtlList;
        TriggerBase.clearBypass('DocDtl__c');
        
        ApplRegltry__c varAppReg = New ApplRegltry__c();  	
        varAppReg.LoanAppln__c = loanApp.Id;
        varAppReg.Appl__c = app.Id;
        varAppReg.IsBorowrOrRelFFDir__c = null;
        varAppReg.FFDirRelIntrstAsSH__c = 'No';
        varAppReg.FFDirRelIntrstAsPart__c = 'No';
        TriggerBase.bypass('ApplRegltry__c');
        insert varAppReg;
        TriggerBase.clearBypass('ApplRegltry__c');
        
        
        RegltryPrsonl__c varRegPer = New RegltryPrsonl__c();
        varRegPer.DirName__c = 'Test Dir name';
        varRegPer.Desgntn__c = 'Engineer';
        varRegPer.Reltnshp__c = 'Test Relation';
        varRegPer.Applicant_Regulatory__c = varAppReg.Id;
        TriggerBase.bypass('RegltryPrsonl__c');
        insert varRegPer;
        TriggerBase.clearBypass('RegltryPrsonl__c');
        
        CaseDoc__c casDoc = new CaseDoc__c();
        casDoc.Case__c = caseList[0].Id;
        casDoc.DocDetail__c = docDtlList[0].Id;
        TriggerBase.bypass('CaseDoc__c');
        insert casDoc;
        TriggerBase.clearBypass('CaseDoc__c');
    }
    
    @isTest
    static void cloneCaseJobTestMethod() {
        
        LoanAppl__c loanApp = [SELECT Id,Stage__c,SubStage__c,Product__c FROM LoanAppl__c LIMIT 1];
        Applicant__c app = [SELECT Id,ClonedFor__c FROM Applicant__c LIMIT 1];
        app.ClonedFor__c = app.Id;
        update app;
        
        LoanAppl__c loanAppp = [SELECT Id, Product__c FROM LoanAppl__c LIMIT 1];
        Id clonedLoanAppId = loanAppp.Id; // Simulate cloned loan application ID
        
        DocDtl__c appDocDtls = [SELECT Id,ClonedSource__c FROM DocDtl__c WHERE Appl__c = :app.Id LIMIT 1];
        appDocDtls.ClonedSource__c =appDocDtls.Id; 
        TriggerBase.bypass('DocDtl__c');
        update appDocDtls;
        TriggerBase.clearBypass('DocDtl__c');
        
        Case CaseRec = [SELECT Id,ClonedSource__c FROM Case WHERE Loan_Application__c = :clonedLoanAppId LIMIT 1];
        CaseRec.ClonedSource__c =CaseRec.Id; 
        TriggerBase.bypass('Case');
        update CaseRec;
        TriggerBase.clearBypass('Case');
        // Set input data for the CloneLoanAppwrpr class
        CloneLoanAppController.CloneLoanAppwrpr inputData = new CloneLoanAppController.CloneLoanAppwrpr();
        inputData.recordId = loanApp.Id;
        inputData.userId = UserInfo.getUserId();
        inputData.cloneReason = 'BT + Top Up';
        
        
        CloneRegulatoryDtlsJob cloneJob = new CloneRegulatoryDtlsJob(inputData, loanApp.Product__c, clonedLoanAppId);
        
        Test.startTest();
        // Enqueue job
        System.enqueueJob(cloneJob);
        Test.stopTest();
        
        List<ApplRegltry__c> clonedApplRegulatories = [SELECT Id, LoanAppln__c FROM ApplRegltry__c WHERE LoanAppln__c = :loanApp.Id];
        System.assertEquals(2, clonedApplRegulatories.size(), 'Applicant Regulatories should be cloned.');
        
        List<RegltryPrsonl__c> clonedReglaryPersonel = [SELECT Id, Applicant_Regulatory__c FROM RegltryPrsonl__c WHERE Applicant_Regulatory__c = :clonedApplRegulatories[0].Id];
        System.assertEquals(1, clonedReglaryPersonel.size(), 'Regulatory personnel should be cloned.');
        
        Boolean isAssert = true;
        try{
            CloneRegulatoryDtlsJob jobnew = new CloneRegulatoryDtlsJob(null,null,null);
            System.enqueueJob(jobnew);   
        }catch(AuraHandledException ex){
            isAssert = false;
            system.assertEquals('Script-thrown exception', ex.getMessage());
        }  
        system.assertEquals(true, isAssert);
    } 
}