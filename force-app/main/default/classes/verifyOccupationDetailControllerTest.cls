@isTest
public class verifyOccupationDetailControllerTest {
    @testSetup
    static void setupTestData() {
        Test.startTest();
        LoanAppl__c loanApp= TestDataFactory.createLoanApplication(true);
        Applicant__c app=TestDataFactory.createSingleApplicant(false,loanApp.Id);
        app.CustProfile__c = 'SELF EMPLOYED PROFESSIONAL';
        insert app;
        APIVer__c apiRecord=  TestDataFactory.createAPIVerification(true,loanApp.Id,app.id,'Qualification Check');
        Test.stopTest();
    }
    public testMethod static void testGetAllApplicants(){
        LoanAppl__c loanApp=[select id from LoanAppl__c limit 1];
        verifyOccupationDetailController.allApplicantsData(loanApp.id);
        verifyOccupationDetailController.getVerificationData(loanApp.id);
    }  
}