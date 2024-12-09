@isTest
public class EmpSearchRequestGeneratorTest {

    @testSetup
    static void setup() {
        // Create test data for Applicant
         LoanAppl__c   loanApplicant = TestDataFactory.createLoanApplication(true);
        //insert loanApplicant;

        Applicant__c appli = TestDataFactory.createSingleApplicant(true,loanApplicant.Id);
        // Create test data for Employer
        Employer__c employer =  TestDataFactory.createEmployer(true);
            
           // TestDataFactory.createApplEmployment(true,loanApplicant.Id);

        // Create test data for ApplicantEmployment
        ApplicantEmployment__c applicantEmployment = TestDataFactory.createApplEmployment(true,appli.Id);
        //applicantEmployment.LoanApplicant__c=appli.Id;
        applicantEmployment.EmployerName__c=employer.Id;
        applicantEmployment.OfficialEmail__c ='john.doe@techcorp.com';   
        
        update applicantEmployment;

        // Create test data for IntgMsg
        IntgMsg__c intgMsg = new IntgMsg__c(
            RefId__c = applicantEmployment.Id,
            ParentRefId__c = appli.Id,
            ParentRefObj__c = 'Applicant__c',
            RefObj__c= 'ApplicantEmployment__c',
            Status__c='In Progress'
        );
        insert intgMsg;
    }

    @isTest
    static void testGenerate() {
        // Fetch the test data
        List<IntgMsg__c> msgs = [SELECT Id, RefId__c, ParentRefId__c, Integration_Message_Number__c FROM IntgMsg__c];
        
        // Instantiate the class
        EmpSearchRequestGenerator generator = new EmpSearchRequestGenerator();
        
        // Call the generate method
        Test.startTest();
        generator.generate(msgs, 'service', 'processType');
        Test.stopTest();
        
        // Verify that the fields are updated as expected
        IntgMsg__c updatedMsg = [SELECT Id, Req__c, Status__c FROM IntgMsg__c LIMIT 1];
        System.assertNotEquals(null, updatedMsg.Req__c, 'Req__c should not be null');
        System.assertEquals(GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS, updatedMsg.Status__c, 'Status__c should be IN_PROGRESS');
    }
}