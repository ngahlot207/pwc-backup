@isTest
private class PerfiosExtractZipFilesQueueableTest {

   /* @isTest
    static void testExecuteWithEmptyMaps() {
        // Test data setup
        Map<Id,IntgMsg__c> intgMsgMap = new Map<Id,IntgMsg__c>();
        Map<Id,Blob> responseZipFileMap = new Map<Id,Blob>();

        // Call the method
        Test.startTest();
        PerfiosExtractZipFilesQueueable queueable = new PerfiosExtractZipFilesQueueable(intgMsgMap, responseZipFileMap);
        System.enqueueJob(queueable);
        Test.stopTest();
	}*/

    @isTest
    static void testExecuteWithPopulatedMaps() {
        // Test data setup
        Map<Id,IntgMsg__c> intgMsgMap = new Map<Id,IntgMsg__c>();
        Map<Id,Blob> responseZipFileMap = new Map<Id,Blob>();
		IntgMsg__c intgMsg = new IntgMsg__c(
        Status__c = 'New'
            // Populate with required fields as needed
        );
        insert intgMsg;
        intgMsgMap.put(intgMsg.Id, intgMsg);
       

          
        responseZipFileMap.put(intgMsg.Id, Blob.valueOf('Test Blob Data'));

		Test.startTest();
        PerfiosExtractZipFilesQueueable queueable = new PerfiosExtractZipFilesQueueable(intgMsgMap, responseZipFileMap);
        System.enqueueJob(queueable);
        Test.stopTest();

    }

    // Add more test methods to cover other scenarios
}