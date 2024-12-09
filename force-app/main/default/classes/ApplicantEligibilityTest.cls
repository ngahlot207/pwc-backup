@isTest
public class ApplicantEligibilityTest {

    @isTest
    static void testApplicantEligibilityComparable() {
         ApplicantEligibility applicanttest = new ApplicantEligibility();
          applicanttest.LTVApplLnWOInsurance = 900;
          applicanttest.LTVApplLnWtInsurance = 900;
          applicanttest.LTVBsdEliWOIns = 800;
          applicanttest.AddLTVBsdEliIns = 800;     
          applicanttest.TotlLTVBsdLnEliWIns = 800;
          applicanttest.LTVApplWDeviation = 800;
          applicanttest.MaxcoltrlLnEliWDeviation = 800;
          applicanttest.PropAddrs = 'House no 123';
          applicanttest.ApproxValue = 78988;
          applicanttest.PropType = 'Positive';
          applicanttest.PropSubType = 'Test';
          applicanttest.PropertyUsage = 'Commercial';
        // Test data setup
        ApplicantEligibility applicant1 = new ApplicantEligibility();
        // Set up other necessary fields for applicant1
        applicant1.applicantCreatedDate = DateTime.now().addDays(-1);

        ApplicantEligibility applicant2 = new ApplicantEligibility();
        // Set up other necessary fields for applicant2
        applicant2.applicantCreatedDate = DateTime.now();

        // Compare the applicants using compareTo method
        Integer result1 = applicant1.compareTo(applicant2);
        Integer result2 = applicant2.compareTo(applicant1);
        Integer result3 = applicant1.compareTo(applicant1);

        // Add assertions based on the expected behavior of your code
        System.assertNotEquals(0, result1, 'Comparison result should not be 0');
        System.assertEquals(-1, result1, 'applicant1 should be considered earlier than applicant2');
        System.assertEquals(1, result2, 'applicant2 should be considered later than applicant1');
        System.assertEquals(0, result3, 'Comparison of the same applicant should result in 0');
        // Add more assertions as needed
    }
    @isTest
    public static void fetchRecordsTest() {
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true); 
        Applicant__c applicant = TestDataFactory.createSingleApplicant(true, loanApp.Id);
        applicant.AssessmentProgram__c = 'Assessed Income Program';
        applicant.Average_Monthly_Cash_Salary__c = 30000;
        applicant.Average_Monthly_Rental_With_Bank_Credit__c = 20000;
        applicant.Average_Monthly_Rental_No_Bank_Credit__c = 10000;
        applicant.Average_Monthly_Pension__c = 3000;
        applicant.AverageMonthlyAgricultureIncome__c = 2000;
        applicant.Average_Other_Income__c = 1000;
        
        update applicant;
        
        List<BRE__c> breResp = new List<BRE__c>();
        breResp.add(new BRE__c(
            Name = 'Test BRE Resp',
            LoanAppl__c = loanApp.Id,
            Applicant__c = applicant.Id,
            EligibilityType__c = 'Applicant',
            IsLatest__c = true
        ));
        breResp.add(new BRE__c(
            Name = 'Test BRE Resp',
            LoanAppl__c = loanApp.Id,
            Applicant__c = applicant.Id,
            EligibilityType__c = 'Application',
            IsLatest__c = true
        ));
        insert breResp;
        
        Id recordTypeId = Schema.SObjectType.Applicant_Income__c.getRecordTypeInfosByName().get('Cashflow Map').getRecordTypeId();
        
        Applicant_Income__c appIncome = new Applicant_Income__c();
        appIncome.Applicant__c = applicant.Id;
        appIncome.NET_CASH_PROFIT_LOSS__c = 10000;
        appIncome.RecordTypeId = recordTypeId;
        insert appIncome;
        
        List<BRE_Eligibility__c> breEligi = new List<BRE_Eligibility__c>();
        breEligi.add(new BRE_Eligibility__c(
            BREResponse__c = breResp[0].Id,
            Type__c = 'Applicant',
            IsLatest__c = true,
            IncomeProgram__c = 'Business income - Regular Income Program (P&L)'
        ));
        breEligi.add(new BRE_Eligibility__c(
            BREResponse__c = breResp[0].Id,
            Type__c = 'Applicant',
            IsLatest__c = true,
            IncomeProgram__c = 'Gross Eligible Salary with Bank Credit'
        ));
        
        breEligi.add(new BRE_Eligibility__c(
            BREResponse__c = breResp[0].Id,
            Type__c = 'Applicant',
            IsLatest__c = true,
            IncomeProgram__c = 'Net Eligible Salary with Bank Credit'
        ));
        breEligi.add(new BRE_Eligibility__c(
            BREResponse__c = breResp[0].Id,
            Type__c = 'Application',
            IsLatest__c = true,
            IncomeProgram__c = 'Cash Flow - Assessed income',
            Consideration__c = 40.00,
            LoanApp__c = loanApp.Id,
            Applicant__c = applicant.Id
        ));
        breEligi.add(new BRE_Eligibility__c(
            BREResponse__c = breResp[0].Id,
            Type__c = 'Application',
            IsLatest__c = true,
            IncomeProgram__c = 'Business income - Regular Income Program (P&L)'
        ));
        breEligi.add(new BRE_Eligibility__c(
            BREResponse__c = breResp[0].Id,
            Type__c = 'Application',
            IsLatest__c = true,
            IncomeProgram__c = 'Gross Eligible Salary with Bank Credit'
        ));
        breEligi.add(new BRE_Eligibility__c(
            BREResponse__c = breResp[0].Id,
            Type__c = 'Application',
            IsLatest__c = true,
            IncomeProgram__c = 'Cash Salary'
        ));
        breEligi.add(new BRE_Eligibility__c(
            BREResponse__c = breResp[0].Id,
            Type__c = 'Application',
            IsLatest__c = true,
            IncomeProgram__c = 'Net Eligible Salary with Bank Credit'
        ));
        breEligi.add(new BRE_Eligibility__c(
            BREResponse__c = breResp[0].Id,
            Type__c = 'Application',
            IsLatest__c = true,
            IncomeProgram__c = 'Rental bank credit'
        ));
        breEligi.add(new BRE_Eligibility__c(
            BREResponse__c = breResp[0].Id,
            Type__c = 'Application',
            IsLatest__c = true,
            IncomeProgram__c = 'Rental without bank credit'
        ));
        breEligi.add(new BRE_Eligibility__c(
            BREResponse__c = breResp[0].Id,
            Type__c = 'Application',
            IsLatest__c = true,
            IncomeProgram__c = 'Pension Income'
        ));
        breEligi.add(new BRE_Eligibility__c(
            BREResponse__c = breResp[0].Id,
            Type__c = 'Application',
            IsLatest__c = true,
            IncomeProgram__c = 'Agriculture Income'
        ));
        breEligi.add(new BRE_Eligibility__c(
            BREResponse__c = breResp[0].Id,
            Type__c = 'Application',
            IsLatest__c = true,
            IncomeProgram__c = 'Other Income'
        ));
        
        insert breEligi;
        
        List<BRE_Eligibility__c> breList = [ SELECT Id, Name, BREResponse__c, Type__c, IncomeProgram__c, BREResponse__r.Applicant__c,
                                            BREResponse__r.Applicant__r.FullName__c, BREResponse__r.Applicant__r.AssessmentProgram__c,
                                            BREResponse__r.LoanAppl__c, BREValue__c, BREValueType__c, IsLatest__c 
                                            FROM BRE_Eligibility__c WHERE IsLatest__c = TRUE 
                                            AND BREResponse__r.LoanAppl__c =: loanApp.Id ];
        
        system.debug('bre list size'+breList.size());
        
        EligibilityScreenDataController.ResponseWrapper resp = EligibilityScreenDataController.fetchRecords(loanApp.Id);  
        system.assertEquals(true, resp.showAssesmentProgram);
        //system.assertEquals(1, resp.eligibilityList.size());
        Boolean assertsBoolNew = true;
        try{
            EligibilityScreenDataController.fetchRecords(null);          
        }catch(NullPointerException ex){
            assertsBoolNew = false;
            system.assertEquals('Attempt to de-reference a null object', ex.getMessage());
        } 
        system.assertEquals(true, assertsBoolNew);
    }
    @isTest
    static void testApplicantEligibilityComparableWithNull() {
        
        // Test data setup
        ApplicantEligibility applicant1 = new ApplicantEligibility();
        // Set up other necessary fields for applicant1
        applicant1.applicantCreatedDate = DateTime.now().addDays(-1);

        // Compare with null
        Integer result = applicant1.compareTo(null);

        // Add assertions based on the expected behavior of your code
        System.assertEquals(0, result, 'Comparison with null should result in 0');
        // Add more assertions as needed
    }

    @isTest
    static void testApplicantEligibilityComparableWithNonApplicantObject() {
        // Test data setup
        ApplicantEligibility applicant1 = new ApplicantEligibility();
        // Set up other necessary fields for applicant1
        applicant1.applicantCreatedDate = DateTime.now().addDays(-1);

        // Compare with a non-ApplicantEligibility object
        Integer result = applicant1.compareTo('Not an ApplicantEligibility');

        // Add assertions based on the expected behavior of your code
        System.assertEquals(0, result, 'Comparison with non-ApplicantEligibility object should result in 0');
        // Add more assertions as needed
    }
}