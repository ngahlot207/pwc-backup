@isTest
public class GlobalServiceClassTest {

    @isTest
    static void testCreateIntegrationRequest() {
       LoanAppl__c loanApp=TestDataFactory.createLoanApplication(True);
        
        // Create test data for applicant
        Applicant__c testApplicant = new Applicant__c(LoanAppln__c=loanApp.Id,FName__c = 'John', LName__c = 'Doe', DOB__c = Date.today(), MobNumber__c = '9876543210');
        insert testApplicant;
        // Create test data for applicant KYC
        ApplKyc__c testApplKyc = new ApplKyc__c(Applicant__c = testApplicant.Id, kycDoc__c ='Pan', Pan__c = 'ABCDE1234F');
        insert testApplKyc;
        // Call the method to be tested
     	GlobalServiceClass.CreateIntegrationRequest(testApplicant.Id);
    }
    
      @isTest
    static void testCreateIntegrationRequest1() {
       LoanAppl__c loanApp=TestDataFactory.createLoanApplication(True);
        
        // Create test data for applicant
        Applicant__c testApplicant = new Applicant__c(LoanAppln__c=loanApp.Id);
        insert testApplicant;
        // Create test data for applicant KYC
        ApplKyc__c testApplKyc = new ApplKyc__c(Applicant__c = testApplicant.Id, kycDoc__c ='Pan');
        insert testApplKyc;
        // Call the method to be tested
     	GlobalServiceClass.CreateIntegrationRequest(testApplicant.Id);
    }

}