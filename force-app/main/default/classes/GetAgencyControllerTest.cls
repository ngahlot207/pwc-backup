@isTest
private class GetAgencyControllerTest {

    @isTest
    static void testGetAgency() {
        
          LocMstr__c locMaster = TestDataFactory.LocMaster(true);
        
          recordType recordTypes = [select Id,Name from RecordType where sObjectType='Account' AND Name = 'Agency'];
          Account testAccount = TestDataFactory.createAccountDetails(false);
          //testAccount.Name = 'Test';
          testAccount.RecordTypeId = recordTypes.Id;
          insert testAccount;


        AgncLocMap__c agncLocMap = new AgncLocMap__c(
            Account__c = testAccount.Id,
            IsActive__c = true,
            StartDate__c = Date.today().addDays(-1),
            EndDate__c = Date.today().addDays(1),
            AgencyType__c = 'CPVFI',
            LocationMaster__c =locMaster.Id
        );
        insert agncLocMap;
        


        Test.startTest();
        List<GetAgencyController.AgencyWrpr> result = GetAgencyController.getAgency(locMaster.Id);
        Test.stopTest();

     System.assert(result != null, 'Result should not be null');
     System.assert(result.size() > 0, 'Result should have elements');
    }

    @isTest
    static void testGetAgencyWithNoCityId() {
        Test.startTest();

        // Call the method with no cityId
        List<GetAgencyController.AgencyWrpr> result = GetAgencyController.getAgency(null);
        Test.stopTest();
        System.assert(result == null, 'Result should be null');
    }

    @isTest
    static void testGetAgencyWithInvalidCityId() {
        Test.startTest();

        // Call the method with an invalid cityId
        List<GetAgencyController.AgencyWrpr> result = GetAgencyController.getAgency('InvalidCityId');
        Test.stopTest();
        System.assert(result == null, 'Result should be null');
    }

    @isTest
    static void testGetAgencyWithNoAgncLocMap() {
        LocMstr__c locMaster = new LocMstr__c(CityId__c = 'City123');
        insert locMaster;

       
        Test.startTest();

        // Call the method with a cityId that has no AgncLocMap records
        List<GetAgencyController.AgencyWrpr> result = GetAgencyController.getAgency(locMaster.Id);

        Test.stopTest();

       //System.assert(result != null, 'Result should not be null');
       //System.assert(result.size() == 0, 'Result should be empty');
    }
}