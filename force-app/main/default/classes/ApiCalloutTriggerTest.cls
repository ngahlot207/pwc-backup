@isTest
public class ApiCalloutTriggerTest {

    @isTest
    static void testBeforeInsert() {
        // Create test data
        APICoutTrckr__c record = new APICoutTrckr__c(APIName__c = 'PAN-PROFILE');
        
        // Perform a DML operation (insert)
        Test.startTest();
        insert record;
        Test.stopTest();

        // Add assertions as needed for before insert behavior
        System.assertEquals('PAN-PROFILE', record.APIName__c);
    }
}