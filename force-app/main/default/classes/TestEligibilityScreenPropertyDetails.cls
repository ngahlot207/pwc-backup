@isTest
private class TestEligibilityScreenPropertyDetails {
    
    @isTest
    static void testFetchPropRecords() {
      
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);     
        Applicant__c applicant = TestDataFactory.createSingleApplicant(false, loanApp.Id);
        insert applicant;
        ApplAsset__c appAssetDet = new ApplAsset__c();
        appAssetDet.PropIdentified__c = 'Yes';
        appAssetDet.CopyAddFrmExAdd__c = 'Yes';
        appAssetDet.PinId__c = '430005';
        appAssetDet.FlatNo__c = '123';
        appAssetDet.LoanAppln__c = loanApp.Id;
        appAssetDet.Appl__c = applicant.Id;
        appAssetDet.PropSubType__c = 'AP - DEVELOPMENT AUTHORITY';
        TriggerBase.bypass('ApplAsset__c');
        insert appAssetDet;
        BRE__c breRes =new BRE__c();
        breRes.Name='SampleBreRes';
        breRes.LoanAppl__c=loanApp.Id;
        breRes.EligibilityType__c ='Property';
        breRes.LTVApplLnWOInsurance__c = 1;
        breRes.Applicant_Asset__c = appAssetDet.id;
        insert breRes;
        BRE__c breRes1 =new BRE__c();
        breRes1.Name='SampleBreRes';
        breRes1.LoanAppl__c=loanApp.Id;
        breRes1.EligibilityType__c ='Application';
        insert breRes1;
        
        // Call the method to be tested
        //String params = 'testParams';
        //String applId = 'testApplId';
        Test.startTest();
        String result = EligibilityScreenPropertyDetails.fetchPropRecords(loanApp.Id, applicant.Id);
        Test.stopTest();
        
        // Perform assertions to validate the result
        System.assertNotEquals(null, result, 'Result should not be null');
        // Add more assertions as needed to cover different scenarios based on the expected result
        
        // Clean up test data (delete inserted records) if necessary
    }
}