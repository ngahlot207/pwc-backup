@isTest
private class ObligatoryDtlsTest {

    @isTest
    static void insertMultipleRecord_PositiveTesting() {
       // List<Applicant_Obligation_detail__c> appliObliDetails = TestDataFactory.appliObliDetails(true,5);'
       
        List<Applicant_Obligation_detail__c> appliObliDetails = new List<Applicant_Obligation_detail__c>();
        for (Integer i = 0; i < 5; i++) {
            appliObliDetails.add(
                new Applicant_Obligation_detail__c(
                    BureauRespDtl__c = TestDataFactory.breResponseDetails(true)
                        .Id
                )
            );
        }
        
        // Call the method to be tested
        Test.startTest();
        ObligatoryDtls.insertMultipleRecord(appliObliDetails);
        Test.stopTest();

        // Verify the results
        System.assertEquals(appliObliDetails.size(), [SELECT COUNT() FROM Applicant_Obligation_detail__c]);
    }
    
    @isTest
    static void insertMultipleRecord_NegativeTesting() {
         List<Applicant_Obligation_detail__c> appliObliDetails = TestDataFactory.appliObliDetails(true,5);
        
        // Call the method to be tested
        Test.startTest();
        ObligatoryDtls.insertMultipleRecord(null);
        Test.stopTest();

        // Verify the results
        System.assertNotEquals(0,[SELECT COUNT() FROM Applicant_Obligation_detail__c]);
    }
}