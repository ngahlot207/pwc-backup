@isTest
public class Test_CaseUpdationTriggerHandlerUpdated {
    @isTest
    static void testTriggerLogic() {
        // Prepare a RecordType for testing
        RecordType testRecordType = new RecordType(
            Name = 'CPVFI RT',
            SObjectType = 'Case' // Adjust the SObjectType as needed
            // Add any other required fields
        );
       // insert testRecordType;

        // Prepare test data
      //  Case testCase = new Case(
           // RecordTypeId = testRecordType.Id,
            // Add other necessary fields
       // );
        //insert testCase;

        // Simulate the trigger event (inserting records)
       // Test.startTest();
       // List<Case> testCases = new List<Case>{ testCase };
       // CaseUpdationTriggerHandlerUpdated.BeforeInsert(testCases);
        //Test.stopTest();

        // Assert the expected results
        // Add assertions to check if the owner and related records were updated as expected
        // Example: Retrieve and assert the updated Case and related records
        // Case updatedCase = [SELECT Id, OwnerId, ... FROM Case WHERE Id = :testCase.Id];
        // System.assertEquals(expectedOwnerId, updatedCase.OwnerId);
        // Assert other related records' updates as well
    }
}