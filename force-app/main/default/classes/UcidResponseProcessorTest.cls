@isTest
public class UcidResponseProcessorTest {

    @isTest
    static void testProcess() {
        // Create a test Applicant
        LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
        Applicant__c testApplicant = TestDataFactory.createSingleApplicant(true, loan.Id);

        // Create a test IntgMsg__c related to the Applicant
        IntgMsg__c testIntMsg = new IntgMsg__c(
            RefId__c = testApplicant.Id,
            ParentRefId__c = 'SomeParentRefId',
            Svc__c = 'KYC OCR',
            Status__c = 'New',
            MStatus__c = 'Blank',
            RefObj__c = 'Applicant__c',
            IsActive__c = true,
            Trigger_Platform_Event__c = true
            // Add other required fields as needed
        );
        insert testIntMsg;

        // Create a test UcidResponseWrapper
        UcidResponseWrapper testResponseWrapper = new UcidResponseWrapper();
        testResponseWrapper.success = 'true';
        testResponseWrapper.ucid = 'TestUCID';

        // Serialize the UcidResponseWrapper to simulate the JSON response in the IntgMsg__c record
        String serializedResponse = JSON.serialize(testResponseWrapper);

        // Update the IntgMsg__c record with the simulated JSON response
        testIntMsg.Resp__c = serializedResponse;
        update testIntMsg;
        
        IntgMsg__c testIntMsg1 = new IntgMsg__c(
            RefId__c = testApplicant.Id,
            ParentRefId__c = 'SomeParentRefId',
            Svc__c = 'KYC OCR',
            Status__c = 'New',
            MStatus__c = 'Blank',
            RefObj__c = 'Applicant__c',
            IsActive__c = true,
            Trigger_Platform_Event__c = true
            // Add other required fields as needed
        );
        insert testIntMsg1;

        // Create a test UcidResponseWrapper
        UcidResponseWrapper testResponseWrapper1 = new UcidResponseWrapper();
       // testResponseWrapper1.success = '';
        testResponseWrapper1.ucid = 'TestUCID';

        // Serialize the UcidResponseWrapper to simulate the JSON response in the IntgMsg__c record
        String serializedResponse1 = JSON.serialize(testResponseWrapper1);

        // Update the IntgMsg__c record with the simulated JSON response
        testIntMsg1.Resp__c = serializedResponse1;
        //update testIntMsg1;
		list<IntgMsg__c> intMessList= new list<IntgMsg__c>();
        intMessList.add(testIntMsg);
        intMessList.add(testIntMsg1);
        // Trigger the process method
        Test.startTest();
        UcidResponseProcessor.process(intMessList);
        Test.stopTest();

        // Verify the updated Applicant__c record
        
        Applicant__c updatedApplicant = [SELECT UCID__c, IntegrationStatus__c, IntegrationErrorMessage__c FROM Applicant__c WHERE Id = :testApplicant.Id LIMIT 1];
        system.debug('71>>>'+updatedApplicant.IntegrationErrorMessage__c);
        system.debug('72>>>'+updatedApplicant.IntegrationStatus__c);
        System.assertEquals('TestUCID', updatedApplicant.UCID__c, 'UCID should be updated');
       System.assertEquals('UCID API: Failure', updatedApplicant.IntegrationStatus__c, 'IntegrationStatus__c should be updated');
       System.assertEquals('UCID API:', updatedApplicant.IntegrationErrorMessage__c, 'IntegrationErrorMessage__c should be not empty');
    }
}