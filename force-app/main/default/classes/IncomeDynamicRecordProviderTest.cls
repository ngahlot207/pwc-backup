@isTest
public class IncomeDynamicRecordProviderTest {
	@isTest
    static void testGetSobjectDatawithRelatedRecords() {
        // Test data setup
        IncomeDynamicRecordProvider.SobjectQueryParams queryParams = new IncomeDynamicRecordProvider.SobjectQueryParams();
        queryParams.ParentObjectName = 'Account';
        queryParams.ChildObjectRelName = 'Opportunities';
        queryParams.parentObjFields = new List<String>{'Id', 'Name'};
        queryParams.childObjFields = new List<String>{'Id', 'Name','CloseDate','StageName'};
        queryParams.queryCriteria = ' LIMIT 1';

        // Call the method
        IncomeDynamicRecordProvider.SobjctDataWrapper result = IncomeDynamicRecordProvider.getSobjectDatawithRelatedRecords(queryParams);

        // Assert the result
        System.assertNotEquals(null, result);
        System.assertEquals(null, result.parentRecord);
        
    }

    @isTest
    static void testUpsertSobjDataWIthRelatedChilds() {
        // Test data setup
        IncomeDynamicRecordProvider.SobjectUpsertData upsertData = new IncomeDynamicRecordProvider.SobjectUpsertData();
        upsertData.parentRecord = new Account(Name = 'Test Account');
        upsertData.ChildRecords = new List<SObject>{new Opportunity(Name = 'Test Opportunity', StageName='Qualification', CloseDate=system.today())};
        upsertData.ParentFieldNameToUpdate = 'AccountId'; // Make sure this field exists in the child object

        // Call the method
        IncomeDynamicRecordProvider.SobjctDataWrapper result = IncomeDynamicRecordProvider.upsertSobjDataWIthRelatedChilds(upsertData);

        // Assert the result
        System.assertNotEquals(null, result);
        System.assertNotEquals(null, result.ChildReords);
    }

    @isTest
    static void testGetSobjectData() {
        // Test data setup
        IncomeDynamicRecordProvider.SobjectQueryParams queryParams = new IncomeDynamicRecordProvider.SobjectQueryParams();
        queryParams.ParentObjectName = 'Account';
        queryParams.parentObjFields = new List<String>{'Id', 'Name'};
        queryParams.queryCriteria = ' LIMIT 1';

        // Call the method
        IncomeDynamicRecordProvider.ParentSobjctDataWrapper result = IncomeDynamicRecordProvider.getSobjectData(queryParams);

        // Assert the result
        System.assertNotEquals(null, result);
        System.assertEquals(null, result.parentRecords);
    }

    @isTest
    static void testGetAssetPropType() {
        // Test data setup
        IncomeDynamicRecordProvider.SobjectQueryParams queryParams = new IncomeDynamicRecordProvider.SobjectQueryParams();
        queryParams.ParentObjectName = 'Account';
        queryParams.parentObjFields = new List<String>{'Id', 'Name'};
        queryParams.queryCriteria = ' LIMIT 1';
		IncomeDynamicRecordProvider.ParentSobjctDataWrapper result = IncomeDynamicRecordProvider.getAssetPropType(queryParams);
		System.assertNotEquals(null, result);
        System.assertEquals(null, result.parentRecords);
    }
}