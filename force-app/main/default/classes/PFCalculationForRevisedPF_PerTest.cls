@isTest
private class PFCalculationForRevisedPF_PerTest {

    @isTest
    static void testBeforeUpdatePositiveTesting() {
        LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
        loan.SanLoanAmt__c = 100000 ;
        loan.InsAmt__c = 2000;
        upsert loan;

        // Create a test LonaApplCharges record with Revised_PF__c as null
        LonaApplCharges__c testChargeNullRevisedPF = new LonaApplCharges__c(
            LoanApplication__c = loan.Id,
            Revised_PF__c = null,
            ChargeCodeID__c = '35'
        );
        insert testChargeNullRevisedPF;

        // Ensure that the beforeUpdate logic is triggered by updating the record with null Revised_PF__c
        Test.startTest(); 
        try{
            testChargeNullRevisedPF.Revised_PF__c = 15.0;
            update testChargeNullRevisedPF;
        }catch(Exception e){
            system.debug('e----'+e.getLineNumber() +' ----' + e.getCause());
        }
        Test.stopTest(); 
         
        // Verify the updated record with null Revised_PF__c
        LonaApplCharges__c updatedChargeNullRevisedPF = [SELECT ActualAmt__c, GST_Amount__c, Amount__c FROM LonaApplCharges__c WHERE Id = :testChargeNullRevisedPF.Id LIMIT 1];
        System.assertEquals(15300, updatedChargeNullRevisedPF.ActualAmt__c, 'ActualAmt__c not updated correctly');
        System.assertEquals(2754, updatedChargeNullRevisedPF.GST_Amount__c, 'GST_Amount__c not updated correctly');
        System.assertEquals(18054.00, updatedChargeNullRevisedPF.Amount__c, 'Amount__c not updated correctly');
    }
    
    @isTest
    static void testBeforeUpdateNegativeTesting() {
        LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
        loan.SanLoanAmt__c = 100000 ; 
        loan.InsAmt__c = 2000;
        upsert loan;
        
        // Create a test LonaApplCharges record with Revised_PF__c not null
        LonaApplCharges__c testChargeNotNullRevisedPF = new LonaApplCharges__c(
            LoanApplication__c = loan.Id,
            Revised_PF__c = 10.0,
            ChargeCodeID__c = '35'
        );
        insert testChargeNotNullRevisedPF;
        
        // Ensure that the beforeUpdate logic is not triggered when updating the record with non-null Revised_PF__c	
        Test.startTest(); 
        try{
            testChargeNotNullRevisedPF.Revised_PF__c = 20.0;
            update testChargeNotNullRevisedPF;
        }catch(Exception e){
            system.debug('e----'+e.getLineNumber() +' ----' + e.getCause());
        }
        Test.stopTest(); 
        
        // Verify that the non-null Revised_PF__c record remains unchanged
        LonaApplCharges__c unchangedCharge = [SELECT ActualAmt__c, GST_Amount__c, Amount__c FROM LonaApplCharges__c WHERE Id = :testChargeNotNullRevisedPF.Id LIMIT 1];
        System.assertNotEquals(15300, unchangedCharge.ActualAmt__c, 'ActualAmt__c should not be updated');
        System.assertNotEquals(2754, unchangedCharge.GST_Amount__c, 'GST_Amount__c should not be updated');
        System.assertNotEquals(18054.00, unchangedCharge.Amount__c, 'Amount__c should not be updated');
    }
}