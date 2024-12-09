@isTest
public class CaseUpdateApplicantAsset_Test {
    @testsetup
    Public static void InsertCaseRecord(){
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        loanApp.ReqLoanAmt__c = 2700000000000.00;
        Update loanApp;
        Id recordTypeId1 = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Technical').getRecordTypeId();
        Applicant__c applicantId = TestDataFactory.createSingleApplicant(true,loanApp.Id);
        ApplAsset__c applicantasset = new ApplAsset__c();
        applicantasset.Appl__c = applicantId.Id;
        Insert applicantasset;
        
        Test.StartTest(); 
        Case objCase = TestDataFactory.CaseData(true);
        objCase.ValidityDays__c = 60;
        objCase.Loan_Application__c = loanApp.Id;
        objCase.ApplAssetId__c=applicantasset.Id;
        objCase.RecordTypeId =recordTypeId1;
        objCase.Date_of_Report__c = date.today();
        objCase.Status = 'Closed';
        objCase.Land_Valuation_in_Rs__c = 8000;
        objCase.Built_up_area_Valuation_In_Rs__c = 8000; 
        objCase.Approx_Age_of_Property_in_Years__c = 12;
        objCase.Land_Area_Sq_Ft__c = 1200;
        objCase.Residual_Age_in_Years__c = 12;
        objCase.Property_Built_up_area_Sq_Ft__c = 12;
        Update objCase;
     
        
        Case objCase1 = TestDataFactory.CaseData(true);
        objCase1.ValidityDays__c = 60;
        objCase1.Loan_Application__c = loanApp.Id;
        objCase1.ApplAssetId__c=applicantasset.Id;
        objCase1.RecordTypeId =recordTypeId1;
        objCase1.Date_of_Report__c = date.today();
        objCase1.Status = 'Closed';
        objCase1.Land_Valuation_in_Rs__c = 8000;
        objCase1.Built_up_area_Valuation_In_Rs__c = 8000; 
        Update objCase1;
        
        
        Case updatecaseObj3 = new Case();
        updatecaseObj3.Id = objCase.Id;
        updatecaseObj3.Status = 'query';
        updatecaseObj3.Origin = 'Email';
        updatecaseObj3.Loan_Application__c = loanApp.Id;
        updatecaseObj3.ReportResult__c = 'Positive';
        updatecaseObj3.Date_of_Report__c = date.today();
        updatecaseObj3.ValidityDays__c = 60;
        updatecaseObj3.RecordTypeId = recordTypeId1;
        Update updatecaseObj3;
    
        
        Case updatecaseObj4 = new Case();
        updatecaseObj4.Id = objCase1.Id;
        updatecaseObj4.Status = 'query';
        updatecaseObj4.Origin = 'Email';
        updatecaseObj4.Loan_Application__c = loanApp.Id;
        updatecaseObj4.ReportResult__c = 'Positive';
        updatecaseObj4.Date_of_Report__c = date.today();
        updatecaseObj4.ValidityDays__c = 60;
        updatecaseObj4.RecordTypeId = recordTypeId1;
        Update updatecaseObj4;
        Test.StopTest(); 
    }
    
    
    @isTest
    Public static void callCaseUpdateApplicantAsset(){
        List<Case> newCaseList = [SELECT Id,ownerId,Loan_Application__c,Total_Valuation_Land_Valuation_B__c,Status,Approx_Age_of_Property_in_Years__c,RecordTypeId FROM Case ];
        List<Case> oldCaseList = [SELECT Id,ownerId,Loan_Application__c,Status,RecordTypeId FROM Case WHERE Status ='query'];
        system.assert(!newCaseList.isEmpty(),'New caseList  should not empty');
        Test.StartTest();
        CaseUpdateApplicantAsset.afterUpdate(newCaseList,oldCaseList);
        Test.StopTest();
    }
    
    @isTest
    Public static void CaseUpdateApplicantAsset_test(){
        List<Case> newCaseList = [SELECT Id,ownerId,Loan_Application__c,Total_Valuation_Land_Valuation_B__c,Status,Approx_Age_of_Property_in_Years__c,RecordTypeId FROM Case ];
        List<Case> oldCaseList = [SELECT Id,ownerId,Loan_Application__c,Status,RecordTypeId FROM Case WHERE Status ='query'];
        
        List<ApplAsset__c> appAssetList = [SELECT ID,Approx_Age_of_Prop__c,Resi_Age__c,Prop_Bui_up_ar__c FROM ApplAsset__c];
        appAssetList[0].Approx_Age_of_Prop__c = 10;
        appAssetList[0].Land_Area__c = 1400;
        appAssetList[0].Resi_Age__c = 14;
        
        Update appAssetList;
         Test.StartTest();
        CaseUpdateApplicantAsset.afterUpdate(newCaseList,oldCaseList);
         Test.StopTest();
    }
    
}