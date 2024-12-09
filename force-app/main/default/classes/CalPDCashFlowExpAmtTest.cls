@isTest
public class CalPDCashFlowExpAmtTest {

    @isTest
    static void testAfterInsert() {
        // Create test data
        // 
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
		Applicant__c applicant = TestDataFactory.createSingleApplicant(true, loanApp.Id);
        
        RecordType rt = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'ApplExpense__c' AND Name = 'Fedfina Officer Validation' LIMIT 1];

        List<Applicant_Income__c> testApplicantIncomes = new List<Applicant_Income__c>();
        for (Integer i = 0; i < 10; i++) {
            testApplicantIncomes.add(new Applicant_Income__c(Applicant__c = applicant.id));
        }
        insert testApplicantIncomes;
        PD__c pd = new PD__c();
        pd.Appl__c = applicant.id;
        insert pd;

        List<ApplExpense__c> testExpenses = new List<ApplExpense__c>();
        for (Integer i = 0; i < 10; i++) {
            testExpenses.add(new ApplExpense__c(
                PrsnlDis__c = pd.Id,
                RecordTypeId = rt.Id,
                ApplInc__c = testApplicantIncomes[i].Id,
                ExpAmt__c = 100.0
            ));
        }
        insert testExpenses;

        Test.startTest();

        // Perform the insert operation
        CalPDCashFlowExpAmt.afterInsert(testExpenses);

        Test.stopTest();

        // Perform assertions if necessary
        // Add your assertions here
    }

    @isTest
    static void testAfterUpdate() {
        // Create test data
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
		Applicant__c applicant = TestDataFactory.createSingleApplicant(true, loanApp.Id);
        
        RecordType rt = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'ApplExpense__c' AND Name = 'Fedfina Officer Validation' LIMIT 1];

        List<Applicant_Income__c> testApplicantIncomes = new List<Applicant_Income__c>();
        for (Integer i = 0; i < 10; i++) {
            testApplicantIncomes.add(new Applicant_Income__c(Applicant__c = applicant.id));
        }
        insert testApplicantIncomes;
        PD__c pd = new PD__c();
        pd.Appl__c = applicant.id;
        insert pd;

        List<ApplExpense__c> testExpenses = new List<ApplExpense__c>();
        for (Integer i = 0; i < 10; i++) {
            testExpenses.add(new ApplExpense__c(
                PrsnlDis__c = pd.Id,
                RecordTypeId = rt.Id,
                ApplInc__c = testApplicantIncomes[i].Id,
                ExpAmt__c = 100.0
            ));
        }
        insert testExpenses;

        Test.startTest();

        // Perform the update operation
        for (ApplExpense__c expense : testExpenses) {
            expense.ExpAmt__c = 200.0;
        }
        CalPDCashFlowExpAmt.afterUpdate(testExpenses, testExpenses);

        Test.stopTest();

        // Perform assertions if necessary
        // Add your assertions here
    }

    @isTest
    static void testAfterDelete() {
        // Create test data
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
		Applicant__c applicant = TestDataFactory.createSingleApplicant(true, loanApp.Id);
        
        RecordType rt = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'ApplExpense__c' AND Name = 'Fedfina Officer Validation' LIMIT 1];

        List<Applicant_Income__c> testApplicantIncomes = new List<Applicant_Income__c>();
        for (Integer i = 0; i < 10; i++) {
            testApplicantIncomes.add(new Applicant_Income__c(Applicant__c = applicant.id));
        }
        insert testApplicantIncomes;
        PD__c pd = new PD__c();
        pd.Appl__c = applicant.id;
        insert pd;

        List<ApplExpense__c> testExpenses = new List<ApplExpense__c>();
        for (Integer i = 0; i < 10; i++) {
            testExpenses.add(new ApplExpense__c(
                PrsnlDis__c = pd.Id,
                RecordTypeId = rt.Id,
                ApplInc__c = testApplicantIncomes[i].Id,
                ExpAmt__c = 100.0
            ));
        }
        insert testExpenses;

        Test.startTest();

        // Perform the delete operation
        CalPDCashFlowExpAmt.afterDelete(testExpenses);

        Test.stopTest();

        // Perform assertions if necessary
        // Add your assertions here
    }
}