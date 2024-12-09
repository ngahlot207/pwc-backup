@isTest
public class PDCChequeInsertionTest {
	
    @isTest
    static void testAfterInsert() {
        LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
        Repayment_Account__c repyRec=TestDataFactory.rePayAccData(true, loan.Id);
        List<PDC__c> testRecords = new List<PDC__c>();
        for(Integer i = 0; i < 5; i++) {
            PDC__c pdc = new PDC__c(
                Cheque_Number_From__c = '1000',
                Cheque_Number_To__c = '1004',
                Loan_Application__c = loan.Id,
                Repayment_Account__c=repyRec.Id
            );
            testRecords.add(pdc);
        }
        insert testRecords;
		Test.startTest();
        PDCChequeInsertion.afterInsert(testRecords);
        Test.stopTest();
		List<Cheque_Numbers__c> insertedCheques = [SELECT Id FROM Cheque_Numbers__c];
        //System.assertEquals(25, insertedCheques.size(), 'Incorrect number of Cheque_Numbers__c records inserted');
    }

    @isTest
    static void testAfterUpdate() {
        LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
        Repayment_Account__c repyRec=TestDataFactory.rePayAccData(true, loan.Id);
        PDC__c oldPDC = new PDC__c(
            Cheque_Number_From__c = '1000',
            Cheque_Number_To__c = '1004',
            Loan_Application__c = loan.Id,
            Repayment_Account__c=repyRec.Id
        );
        insert oldPDC;

        List<PDC__c> testRecordsNew = new List<PDC__c>();
        List<PDC__c> testRecordsOld = new List<PDC__c>();
        PDC__c newPDC = new PDC__c(
            Id = oldPDC.Id,
            Cheque_Number_From__c = '2000',
            Cheque_Number_To__c = '2004',
            Loan_Application__c = loan.Id
        );
        testRecordsNew.add(newPDC);
        testRecordsOld.add(oldPDC);

        // Call the afterUpdate method
        Test.startTest();
        PDCChequeInsertion.afterUpdate(testRecordsNew, testRecordsOld);
        Test.stopTest();

        // Add assertions
        List<Cheque_Numbers__c> insertedCheques = [SELECT Id FROM Cheque_Numbers__c];
        //System.assertEquals(5, insertedCheques.size(), 'Incorrect number of Cheque_Numbers__c records inserted');

        List<Cheque_Numbers__c> existingCheques = [SELECT Id FROM Cheque_Numbers__c WHERE PDC__c = :oldPDC.Id];
        //System.assertEquals(0, existingCheques.size(), 'Existing Cheque_Numbers__c records not deleted');
    }
    @isTest
    static void testForDelete(){
        List<PDC__c> RecForDel = new List<PDC__c>();
        LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
        Repayment_Account__c repyRec=TestDataFactory.rePayAccData(true, loan.Id);
        PDC__c oldPDC = new PDC__c(
            Cheque_Number_From__c = '1000',
            Cheque_Number_To__c = '1004',
            Loan_Application__c = loan.Id,
            Repayment_Account__c=repyRec.Id
        );
        insert oldPDC;
        RecForDel.add(oldPDC);
        Test.startTest();
        PDCChequeInsertion.beforeDelete(RecForDel);
        Test.stopTest();

    }

}