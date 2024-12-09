@isTest
private class EmploymentDetailsControllerTest {

    @isTest
    static void testGetEmployers() {
        Employer__c testEmployer=TestDataFactory.createEmployer(true);
        // Call the method to test
        Test.startTest();
        List<Employer__c> result = EmploymentDetailsController.getEmployers();
        Test.stopTest();
    }

    @isTest
    static void testGetIndustries() {
        Industry__c testIndustry=TestDataFactory.createIndustry(true);
        Test.startTest();
        List<Industry__c> result = EmploymentDetailsController.getIndustries();
        Test.stopTest();
    }

    @isTest
    static void testGetSubIndustries() {
        Industry__c testIndustry=TestDataFactory.createIndustry(true);
       SubIndustry__c testSubIndustry=TestDataFactory.createSubIndustry(true,testIndustry.Id);
      
        // Call the method to test
        Test.startTest();
        List<SubIndustry__c> result = EmploymentDetailsController.getSubIndustries(testIndustry.Id);
        Test.stopTest();
    }

    @isTest
    static void testGetApplicant() {
        LoanAppl__c loanApp= TestDataFactory.createLoanApplication(true);
        Applicant__c app=TestDataFactory.createSingleApplicant(false,loanApp.Id);
        app.CustProfile__c = 'SELF EMPLOYED PROFESSIONAL';
        insert app;
        Test.startTest();
        Applicant__c result = EmploymentDetailsController.getApplicant(app.Id);
        Test.stopTest();
    }
   
    @isTest
    static void testGetRBIReportingIndustry() {
        Industry__c testIndustry=TestDataFactory.createIndustry(true);
        SubIndustry__c testSubIndustry=TestDataFactory.createSubIndustry(true,testIndustry.Id);
        RBI_ReportingIndustry__c RbiIndustry= TestDataFactory.createRbiIndustry(true,testIndustry.Id,testSubIndustry.Id);
      		 
        // Call the method to test
        Test.startTest();
        List<RBI_ReportingIndustry__c> result = EmploymentDetailsController.getRBIReportingIndustry(testIndustry.Id, testSubIndustry.Id);
        Test.stopTest();
    }
}