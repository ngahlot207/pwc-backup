@isTest
private class UpdateTotalAmountConstitutionTest {

    @isTest
    static void testAfterUpdate() {
        LoanAppl__c testLoan = TestDataFactory.createLoanApplication(true);
        Applicant__c testApplicant = new Applicant__c(
            LoanAppln__c = testLoan.Id,
            TotalIncome__c = 1000000,
            Constitution__c = 'INDIVIDUAL',
            ApplType__c = 'P',
            Type_of_Borrower__c = 'Financial',
            CustProfile__c = 'SELF EMPLOYED NON PROFESSIONAL'
        );
        insert testApplicant;
        ApplicantEmployment__c applEmployment = TestDataFactory.createApplEmployment(true,testApplicant.Id);
        applEmployment.MainRBIIndustry__c='Test Main';
        update applEmployment;
        List<Applicant__c> oldApplicants = new List<Applicant__c>{testApplicant};
        Applicant__c newtestApplicant = new Applicant__c(
            Id = testApplicant.Id,
            LoanAppln__c = testLoan.Id,
            TotalIncome__c = 2000000,
            Constitution__c = 'INDIVIDUAL',
            ApplType__c = 'P',
            Type_of_Borrower__c='Financial'
        );
        List<Applicant__c> newApplicants = new List<Applicant__c>{newtestApplicant};

        Test.startTest();
        UpdateTotalAmountConstitution.afterUpdate(newApplicants, oldApplicants);
        Test.stopTest();
        
        LoanAppl__c loan = [SELECT Id,Final_Industry_for_RBI__c FROM LoanAppl__c where id =: newtestApplicant.LoanAppln__c];
        system.assertEquals('Test Main',loan.Final_Industry_for_RBI__c);
    }
    
    @isTest
    static void testAfterUpdate1() {
        LoanAppl__c testLoan = TestDataFactory.createLoanApplication(true);
        Applicant__c testApplicant = new Applicant__c(
            LoanAppln__c = testLoan.Id,
            TotalIncome__c = 1000000,
            Constitution__c = 'HUF',
            ApplType__c = 'P',
            Type_of_Borrower__c = 'Financial',
            CustProfile__c = 'SELF EMPLOYED NON PROFESSIONAL'
        );
        insert testApplicant;
        ApplicantEmployment__c applEmployment = TestDataFactory.createApplEmployment(true,testApplicant.Id);
        applEmployment.MainRBIIndustry__c='Test Main';
        update applEmployment;
        List<Applicant__c> oldApplicants = new List<Applicant__c>{testApplicant};
        Applicant__c newtestApplicant = new Applicant__c(
            Id = testApplicant.Id,
            LoanAppln__c = testLoan.Id,
            TotalIncome__c = 2000000,
            Constitution__c = 'HUF',
            ApplType__c = 'P',
            Type_of_Borrower__c='Financial' 
        );
        List<Applicant__c> newApplicants = new List<Applicant__c>{newtestApplicant};

        Test.startTest();
        UpdateTotalAmountConstitution.afterUpdate(newApplicants, oldApplicants);
        Test.stopTest();
        
        LoanAppl__c loan = [SELECT Id,Final_Industry_for_RBI__c FROM LoanAppl__c where id =: newtestApplicant.LoanAppln__c];
        system.assertEquals('Test Main',loan.Final_Industry_for_RBI__c);
    }
    
    @isTest
    static void testAfterUpdate2() {
        LoanAppl__c testLoan = TestDataFactory.createLoanApplication(true);
        Applicant__c testApplicant = new Applicant__c(
            LoanAppln__c = testLoan.Id,
            TotalIncome__c = 1000000,
            Constitution__c = 'INDIVIDUAL',
            ApplType__c = 'P',
            Type_of_Borrower__c = 'Financial'
        );
        insert testApplicant;
        ApplicantEmployment__c applEmployment = TestDataFactory.createApplEmployment(true,testApplicant.Id);
        applEmployment.MainRBIIndustry__c='Test Main';
        update applEmployment;
        List<Applicant__c> oldApplicants = new List<Applicant__c>{testApplicant};
        Applicant__c newtestApplicant = new Applicant__c(
            Id = testApplicant.Id,
            LoanAppln__c = testLoan.Id,
            TotalIncome__c = 2000000,
            Constitution__c = 'INDIVIDUAL',
            ApplType__c = 'P',
            Type_of_Borrower__c='Financial' 
        );
        List<Applicant__c> newApplicants = new List<Applicant__c>{newtestApplicant};

        Test.startTest();
        UpdateTotalAmountConstitution.afterUpdate(newApplicants, oldApplicants);
        Test.stopTest();
        
        LoanAppl__c loan = [SELECT Id,Final_Industry_for_RBI__c FROM LoanAppl__c where id =: newtestApplicant.LoanAppln__c];
        system.assertEquals('Test Main',loan.Final_Industry_for_RBI__c);
    }
}