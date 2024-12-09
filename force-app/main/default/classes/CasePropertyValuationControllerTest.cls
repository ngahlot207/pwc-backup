@isTest
public class CasePropertyValuationControllerTest {
    
@testsetup
    Public static void insertData(){
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        loanApp.ReqLoanAmt__c= 2600000000.00;
        Update loanApp; 

        Id recordTypeId1 = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Technical').getRecordTypeId();
        Applicant__c applicantId = TestDataFactory.createSingleApplicant(true,loanApp.Id);
        
        ApplAsset__c applicantasset = TestDataFactory.applAssetData(True,applicantId.Id);

        
       Case objCase = TestDataFactory.CaseData(true);
       objCase.ValidityDays__c = 60;
       objCase.Loan_Application__c = loanApp.Id;
       objCase.ApplAssetId__c=applicantasset.Id;
       objCase.RecordTypeId =recordTypeId1;
       objCase.Date_of_Report__c = date.today();
       objCase.Status = 'Closed';
       objCase.Land_Valuation_in_Rs__c = 8000;
       objCase.Built_up_area_Valuation_In_Rs__c = 8000; 
       objCase.IsReinitiatedExpired__c = true;
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
       objCase1.IsReinitiatedExpired__c = true;
       Update objCase1;
        
       
    }
    
    @isTest
    Public static void propertyValuationMethod(){
        List<ApplAsset__c> lstApplicantAsset = [Select id from ApplAsset__c LIMIT 1];
        CasePropertyValuationController.calculatePropertyValuation(lstApplicantAsset[0].Id);
		
    }

}