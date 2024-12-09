@isTest
private class IMDRequestGeneratorTest {

    @isTest
    static void testGeneratePositive() {
        
        LoanAppl__c testLoanAppl = TestDataFactory.createLoanApplication(true);
        ApplIMD__c testApplIMD = TestDataFactory.applIMDData(true,testLoanAppl.Id);
		Applicant__c appl = TestDataFactory.createSingleApplicant(true, testLoanAppl.Id);
        ApplAddr__c applAdd = TestDataFactory.applAddData(true, testLoanAppl.Id, appl.id);
        applAdd.AddrTyp__c = 'Residence Address';
        upsert applAdd;

        IntgMsg__c testIntgMsg = new IntgMsg__c(
            RefId__c = testApplIMD.Id,
            ParentRefId__c = testLoanAppl.Id,RefObj__c='ApplIMD__c',
            Status__c = 'New'
        );
        insert testIntgMsg;

        IMDRequestGenerator testGenerator = new IMDRequestGenerator();
        
        // Call the generate method
        Test.startTest();
        testGenerator.generate(new List<IntgMsg__c>{ testIntgMsg }, 'TestService', 'TestProcessType');
        Test.stopTest();

    }
    
    @isTest
    static void testGeneratePositive1() {
        
        LoanAppl__c testLoanAppl = TestDataFactory.createLoanApplication(true);
        Applicant__c appl = TestDataFactory.createSingleApplicant(true, testLoanAppl.Id);
        ApplAddr__c applAdd = TestDataFactory.applAddData(true, testLoanAppl.Id, appl.id);
        applAdd.AddrTyp__c = 'Residence Address';
        upsert applAdd;
		
        Payment__c payment = new Payment__c();
        payment.LoanAppl__c=testLoanAppl.Id;
        insert payment;
        
        IntgMsg__c testIntgMsg = new IntgMsg__c(
            RefId__c = payment.Id,
            ParentRefId__c = testLoanAppl.Id,RefObj__c='Payment__c',
            Status__c = 'New'
        );
        insert testIntgMsg;

        IMDRequestGenerator testGenerator = new IMDRequestGenerator();
        
        // Call the generate method
        Test.startTest();
        testGenerator.generate(new List<IntgMsg__c>{ testIntgMsg }, 'TestService', 'TestProcessType');
        Test.stopTest();

    }

    @isTest
    static void testGenerateNegative() {
        LoanAppl__c testLoanAppl = TestDataFactory.createLoanApplication(true);
        ApplIMD__c testApplIMD = TestDataFactory.applIMDData(true,testLoanAppl.Id); 

        IntgMsg__c testIntgMsg = new IntgMsg__c(
            RefId__c = testLoanAppl.Id,
            ParentRefId__c = testLoanAppl.Id,
            Status__c = 'New'            
        );
        insert testIntgMsg;

        IMDRequestGenerator testGenerator = new IMDRequestGenerator();

        // Call the generate method, expecting an exception
        Test.startTest();
        try {
            testGenerator.generate(new List<IntgMsg__c>{ testIntgMsg }, 'TestService', 'TestProcessType');
        } catch (IMDRequestGenerator.IMDRequestGeneratorException e) {
             }
        Test.stopTest();

    }
}