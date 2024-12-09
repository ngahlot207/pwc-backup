@isTest
public class SanctionLetterBTPlusTopUpControllerTest {
     @testsetup
    Public static void insertData(){
        LoanAppl__c loanApplication = TestDataFactory.createLoanApplication(true);
        Applicant__c applicant1 =  TestDataFactory.createSingleApplicant(true,loanApplication.id); 
    }
    @isTest
    static void testConstructorWithRecordId() {
        LoanAppl__c loanApplication = [SELECT ID,Name FROM LoanAppl__c LIMIT 1];
        Applicant__c applicant1 = [SELECT ID FROM Applicant__c LIMIT 1];
        
        Test.setCurrentPageReference(new PageReference('/apex/YourPageName?recordId=' + loanApplication.Id));
        SanctionLetterBTPlusTopUpController controller = new SanctionLetterBTPlusTopUpController();
        System.assertEquals(loanApplication.Id, controller.recordId);
    }

    @isTest
    static void testGetloanApplicationFeilds() {
        LoanAppl__c loanApplication = [SELECT ID,Name FROM LoanAppl__c LIMIT 1];
        Applicant__c applicant1 = [SELECT ID FROM Applicant__c LIMIT 1];
        Test.setCurrentPageReference(new PageReference('/apex/YourPageName?recordId=' + loanApplication.Id));
        SanctionLetterBTPlusTopUpController controller = new SanctionLetterBTPlusTopUpController();
        Test.startTest();
        controller.getloanApplicationFeilds(loanApplication.Id);
        Test.stopTest();
    }

    @isTest
    static void testSetDueDiligenceandProcessingFee() {
        LoanAppl__c loanApplication = [SELECT ID,Name FROM LoanAppl__c LIMIT 1];
        Test.setCurrentPageReference(new PageReference('/apex/YourPageName?recordId=' + loanApplication.Id));
        SanctionLetterBTPlusTopUpController controller = new SanctionLetterBTPlusTopUpController();
        Test.startTest();
        controller.setDueDiligenceandProcessingFee(loanApplication.Id);
        Test.stopTest();    }

    @isTest
    static void testGetMetadataforContent() {
        LoanAppl__c loanApplication = [SELECT ID,Name FROM LoanAppl__c LIMIT 1];
         Test.setCurrentPageReference(new PageReference('/apex/YourPageName?recordId=' + loanApplication.Id));
        SanctionLetterBTPlusTopUpController controller = new SanctionLetterBTPlusTopUpController();
         Test.startTest();
        controller.getMetadataforContent(loanApplication.Id);
        Test.stopTest();
    }

    @isTest
    static void testGetSanctionConditions() {
       LoanAppl__c loanApplication = [SELECT ID,Name FROM LoanAppl__c LIMIT 1];
        Test.setCurrentPageReference(new PageReference('/apex/YourPageName?recordId=' + loanApplication.Id));
        SanctionLetterBTPlusTopUpController controller = new SanctionLetterBTPlusTopUpController();
        Test.startTest();
        controller.getSanctionConditions(loanApplication.Id);
        Test.stopTest();
    }

}