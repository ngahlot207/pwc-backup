@isTest
private class FinancialRecordProcessorTest {
    
    public static String previousFinYear = '2020-2021';
    public static String currentFinYear = '2021-2022';
    public static String provisionalAvailable = 'Yes';
    public static String provisionalYear = '2022-2023';
    public static String applicantId;
    
    @testSetup
    public static void testFinancialSummaries(){

        LoanAppl__c loanAppl =TestDataFactory.createLoanApplication(true);
        
        Applicant__c applicant =TestDataFactory.createSingleApplicant(true,loanAppl.id);  
        applicant.Provisional_Financials_Available__c = 'Yes';
        applicant.Provisional_Financials_Year__c = provisionalYear;
        update applicant;
        applicantId = applicant.id;
        
        Applicant_Financial__c applicantFinancial = new Applicant_Financial__c(Loan_Applicant__c = applicant.Id);
        insert applicantFinancial;
        

        List<Applicant_Financial_Summary__c> appFinSumLst = new List<Applicant_Financial_Summary__c>();
        // Creating and inserting Applicant_Financial_Summary__c record
        Applicant_Financial_Summary__c financialSummary1 = new Applicant_Financial_Summary__c(
            Applicant_Financial__c = applicantFinancial.Id,
            Liabilities__c = 1000.00,
            EBITDA__c = 5000.00,
            Financial_Year__c = previousFinYear
        );
        appFinSumLst.add(financialSummary1);
        //insert financialSummary1; 
        
        Applicant_Financial_Summary__c financialSummary2 = new Applicant_Financial_Summary__c(
            Applicant_Financial__c = applicantFinancial.Id,
            Liabilities__c = 1000.00,
            EBITDA__c = 5000.00,
            Financial_Year__c = currentFinYear
        );
         appFinSumLst.add(financialSummary2);
        //insert financialSummary2; 
        
        Applicant_Financial_Summary__c financialSummary3 = new Applicant_Financial_Summary__c(
            Applicant_Financial__c = applicantFinancial.Id,
            Liabilities__c = 1000.00,
            EBITDA__c = 5000.00,
            Financial_Year__c = provisionalYear
        );
         appFinSumLst.add(financialSummary3);
        //insert financialSummary3;
        
           Applicant_Financial_Summary__c financialSummary4 = new Applicant_Financial_Summary__c(
            Applicant_Financial__c = applicantFinancial.Id,
            Liabilities__c = 1000.00,
            EBITDA__c = 5000.00,
            Financial_Year__c = '2018-2019'
        );
         appFinSumLst.add(financialSummary4);
        
          insert appFinSumLst;
        
    }

    
    @isTest
    static void testProcessDefunctRecordsFinancial() {
        Test.startTest();
        Applicant__c appl = [Select Id From Applicant__c Limit 1];
        // Call the method under test
        String result = FinancialRecordProcessor.processDefunctRecordsFinancial(
            previousFinYear, 
            currentFinYear, 
            provisionalAvailable, 
            provisionalYear, 
            appl.Id);
        
        Test.stopTest();
        
        // Verify the result
        System.assertEquals('Success', result, 'Status should be Success');
        
        // Verify that the Applicant Financial Summary records are deleted
        List<Applicant_Financial_Summary__c> remainingRecords = [
            SELECT Id FROM Applicant_Financial_Summary__c 
            WHERE Applicant_ID__c = :applicantId
        ];
        System.assertEquals(0, remainingRecords.size(), 'All Applicant Financial Summary records should be deleted');
    }
}