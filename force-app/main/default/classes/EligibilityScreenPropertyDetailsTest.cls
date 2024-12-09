@isTest
private class EligibilityScreenPropertyDetailsTest {

    @isTest
    static void testFetchPropRecords() {
        // Test data setup
        LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
        Applicant__c applicant = TestDataFactory.createSingleApplicant(true, loan.Id);
        ApplAsset__c testAsset = new ApplAsset__c(
           // PropAddrs__c = 'Test Property Address',
            PropType__c = 'Residential',
            Property_Usage__c = 'Primary Residence',
            ChangeRequiredInValuationAsPerPolicyNorm__c = 'NO',
           // Total_Valua__c = 500000,
            LoanAppln__c = loan.Id,
            Appl__c=applicant.Id
        );
        insert testAsset;

        BRE__c testBre = new BRE__c(
            Applicant_Asset__c = testAsset.Id,
            LoanAppl__c = loan.Id,
            EligibilityType__c = 'Property',
            LTVApplLnWOInsurance__c = 80,
            LTVApplLnWtInsurance__c = 75,
            LTVBsdEliWOIns__c = 70,
            AddLTVBsdEliIns__c = 5,
            TotlLTVBsdLnEliWIns__c = 75,
            LTVApplWDeviation__c = 2,
            MaxcoltrlLnEliWDeviation__c = 3
        );
        insert testBre;

        // Test the fetchPropRecords method
        Test.startTest();
        String params = loan.Id;
        String applId = applicant.Id;

        String result = EligibilityScreenPropertyDetails.fetchPropRecords(params, applId);
		String resulttest = EligibilityScreenPropertyDetails.fetchPropRecordsNonCacheable(params, applId);

        // Perform assertions based on the expected result
        System.assertNotEquals(null, result);

        // Add more assertions based on the expected structure of the response
        // Example: System.assertEquals('ExpectedValue', result.someProperty);

        Test.stopTest();
    }

    
}