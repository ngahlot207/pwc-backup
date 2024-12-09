@isTest
public class VerificationExpiryControllerTest {
    
    @isTest
    Public static void testVerificationExpiryController(){
       LoanAppl__c loanApp = TestDataFactory.createLoanApplication(True);
       Applicant__c applicant = TestDataFactory.createSingleApplicant(True,loanApp.Id);
       Deviation__c devtionObj = TestDataFactory.createDeviation(True,loanApp.Id,applicant.Id,'5820');
       ApplAsset__c appAsset = TestDataFactory.applAssetData(True,applicant.Id);
       Id legalRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Legal').getRecordTypeId();
        
       Case objCase = TestDataFactory.CaseData(true);
       objCase.ValidityDays__c = -3;
       objCase.Loan_Application__c = loanApp.Id;
       objCase.ApplAssetId__c=appAsset.Id;
       objCase.RecordTypeId =legalRecordTypeId;
       objCase.Date_of_Report__c = date.today();
       objCase.Status = 'Closed';
       Update objCase;
       
        
        PD__c pd= new PD__c();
        pd.LoanAppl__c = loanApp.id;
        pd.Appl__c = applicant.id;
        pd.PDStatus__c = 'Initiated';
        pd.CmpltDt__c = Date.newInstance(2022,09,04);
        pd.ValidityDays__c = 0;
        pd.PdTyp__c = 'Physical PD';
        insert pd;
        
         Test.setCreatedDate(pd.id, Date.newInstance(2021,09,08));
         Test.startTest();
        try{
        VerificationExpiryController.checkExpiry(loanApp.Id);
        VerificationExpiryController.checkExpiry(null);
        VerificationExpiryController.checkExpiry('invalidId');
        }
        catch(Exception e){
            
        }
         Test.stopTest();  
     }
	
}