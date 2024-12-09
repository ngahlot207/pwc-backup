@isTest
public class TestApplicantTotalIncomeDeletion {
    // Create test data
    static void createTestData() {
        // Create test Applicant_Income__c records
        List<Applicant_Income__c> applicantIncomeList = new List<Applicant_Income__c>();
        
        // Add your test data here
        // Example:
        // Applicant_Income__c appIncome = new Applicant_Income__c(/* Populate required fields */);
        // applicantIncomeList.add(appIncome);
        
        insert applicantIncomeList;
    }

    @isTest
    static void testAfterDelete() {
        // Create test data
        createTestData();
       
        List<Applicant_Income__c> applicantIncomeList = [SELECT Id FROM Applicant_Income__c];
        ApplicantTotalIncomeDeletion.afterDelete(applicantIncomeList);
     
    }
}



/*   

@isTest
public class TestApplicantTotalIncomeDeletion {
    @testSetup
    static void setupTestData() {
        // Create test Applicant_Income__c records
        List<Applicant_Income__c> applicantIncomeList = new List<Applicant_Income__c>();

        // Add your test data here
        // Example:
        // applicantIncomeList.add(new Applicant_Income__c(Name = 'Test Income 1', Amount__c = 100));
        // applicantIncomeList.add(new Applicant_Income__c(Name = 'Test Income 2', Amount__c = 200));

        insert applicantIncomeList;
    }

    @isTest
    static void testAfterDelete() {
        // Call the afterDelete trigger action method
        Test.startTest();
        List<Applicant_Income__c> applicantIncomeList = [SELECT Id FROM Applicant_Income__c];
        ApplicantTotalIncomeDeletion.afterDelete(applicantIncomeList);
        Test.stopTest();

        // Add assertions to verify the expected results
        // Example:
        // System.assertEquals(expectedResult, actualResult);
    }
}


*/