@isTest
private class UpdateTotalAmountOnApplicantHandlerTest {
    
    @isTest
    static void testUpdateTotalAmount() {      
        LoanAppl__c loanRecord = new LoanAppl__c(Stage__c = 'QDE');
        insert loanRecord;
        
        Applicant__c applicant = new Applicant__c(FName__c = 'Test Applicant', LoanAppln__c = loanRecord.Id);
        insert applicant;
        
        Applicant_Income__c incomeRecord = new Applicant_Income__c( 
            Applicant__c = applicant.Id,
            RecordTypeId = Schema.sObjectType.Applicant_Income__c.getRecordTypeInfosByDeveloperName().get('CashSal').getRecordTypeId(),
            Month1_Rental_Credited_Amount__c = 2000,
            Month2_Rental_Credited_Amount__c = 3000,
            Month3_Rental_Credited_Amount__c = 2500,
            Salary__c = 5000, 
            Net_Salary__c = 3500, 
            Other_Salary_Component__c = 1000, 
            Monthly_Pension_Credited__c = 1200, 
            Monthly_Other_Income__c = 500 
        );
        insert incomeRecord;
        
        List<Applicant_Income__c> incomeList = new List<Applicant_Income__c>{incomeRecord};
        UpdateTotalAmountOnApplicantHandler.updateTotalAmountInsert(incomeList);
        
    }
    
    @isTest
    static void testUpdateTotalAmount2() {
        LoanAppl__c loanRecord = new LoanAppl__c(Stage__C = 'QDE');
        insert loanRecord;
        
        Applicant__c applicant = new Applicant__c(FNAME__c = 'Test Applicant');
        applicant.LoanAppln__c = loanRecord.Id;
        insert applicant;
        
        String cashSalaryRecordType = Schema.SObjectType.Applicant_Income__c.getRecordTypeInfosByName().get('Cash Salary').getRecordTypeId();
        
        Applicant_Income__c income1 = new Applicant_Income__c(
            Applicant__c = applicant.Id,
            RecordTypeId = cashSalaryRecordType,
            Salary__c = 5000
        );
        
        Applicant_Income__c income2 = new Applicant_Income__c(
            Applicant__c = applicant.Id,
            RecordTypeId = cashSalaryRecordType,
            Month1_Rental_Credited_Amount__c = 2000,
            Month2_Rental_Credited_Amount__c = 3000,
            Month3_Rental_Credited_Amount__c = 2500
        );
        insert new List<Applicant_Income__c> {income1, income2};
            
        UpdateTotalAmountOnApplicantHandler.updateTotalAmountInsert(new List<Applicant_Income__c> {income1, income2}); 
    } 
    
    @isTest
    static void testCalculateTotalRentalIncome() {        
        LoanAppl__c loanRecord = new LoanAppl__c(Stage__c = 'QDE');
        insert loanRecord;
        
        Applicant__c applicant = new Applicant__c(FName__c = 'Test Applicant', LoanAppln__c = loanRecord.Id);
        insert applicant;
        
        Applicant_Income__c incomeRecord2 = new Applicant_Income__c(
            Applicant__c = applicant.Id,
            RecordTypeId = Schema.sObjectType.Applicant_Income__c.getRecordTypeInfosByDeveloperName().get('Rental_woBanking').getRecordTypeId(),
            Month1_Rental_Credited_Amount__c=0,
            Month2_Rental_Credited_Amount__c=0,
            Month3_Rental_Credited_Amount__c=0,
            Salary__c = 0, 
            Net_Salary__c = 0, 
            Other_Salary_Component__c = 000, 
            Monthly_Pension_Credited__c = 00, 
            Monthly_Other_Income__c = 00 
            
        );
        insert incomeRecord2;
       // Decimal totalRentalIncome = UpdateTotalAmountOnApplicantHandler.calculateTotalRentalIncome(incomeRecord2);   
        
        Decimal expectedTotalRentalIncome;
        
        Applicant_Income__c incomeRecord3 = new Applicant_Income__c(
            Applicant__c = applicant.Id,
            RecordTypeId = Schema.sObjectType.Applicant_Income__c.getRecordTypeInfosByDeveloperName().get('AgriIncome').getRecordTypeId(),
            
            Month1_Rental_Credited_Amount__c=600,
            Month2_Rental_Credited_Amount__c=700,
            Month3_Rental_Credited_Amount__c=800,
            Salary__c = 100,
            Net_Salary__c = 200, 
            Other_Salary_Component__c = 300, 
            Monthly_Pension_Credited__c = 400, 
            Monthly_Other_Income__c = 500 
        );
        insert incomeRecord3;
    }  
    
    @isTest
    static void testCalculateTotalCashFlowIncome() {
        LoanAppl__c loanRecord = new LoanAppl__c(Stage__C = 'QDE');
        insert loanRecord;
        
        Applicant__c applicant = new Applicant__c(FNAME__c = 'Test Applicant');
        applicant.LoanAppln__c = loanRecord.Id;
        insert applicant;
        
        Applicant_Income__c testIncome = new Applicant_Income__c(
            Applicant__c = applicant.Id,
            Total_Inflow_From_Operations__c = 000,
            Monthly_Purchases_Cost_Of_Materials__c = 00, 
            Total_Expense_of_operations_Or_Business__c = 000
        );
        insert testIncome;
        Decimal totalCashFlowIncome;
       // totalCashFlowIncome = UpdateTotalAmountOnApplicantHandler.calculateTotalCashFlowIncome(testIncome);        
    }
    
    @isTest
    static void processBankCreditSalaryTest() {      
        LoanAppl__c loanRecord = new LoanAppl__c(Stage__c = 'QDE');
        insert loanRecord;
        
        Applicant__c applicant = new Applicant__c(FName__c = 'Test Applicant', LoanAppln__c = loanRecord.Id);
        insert applicant;
        
        Applicant_Income__c incomeRecord = new Applicant_Income__c( 
            Applicant__c = applicant.Id,
            RecordTypeId = Schema.sObjectType.Applicant_Income__c.getRecordTypeInfosByDeveloperName().get('BankCrSal').getRecordTypeId(),
            Net_Salary__c = 2000,
            Other_Salary_Component__c = 3000
        );
        insert incomeRecord;
        
        List<Applicant_Income__c> incomeList = new List<Applicant_Income__c>{incomeRecord};
            UpdateTotalAmountOnApplicantHandler.updateTotalAmountInsert(incomeList);
    }
    
    @isTest
    static void processPensionTest() {      
        LoanAppl__c loanRecord = new LoanAppl__c(Stage__c = 'QDE');
        insert loanRecord;
        
        Applicant__c applicant = new Applicant__c(FName__c = 'Test Applicant', LoanAppln__c = loanRecord.Id);
        insert applicant;
        
        Applicant_Income__c incomeRecord = new Applicant_Income__c( 
            Applicant__c = applicant.Id,
            RecordTypeId = Schema.sObjectType.Applicant_Income__c.getRecordTypeInfosByDeveloperName().get('Pension').getRecordTypeId(),
            Monthly_Pension_Credited__c = 2000
        );
        insert incomeRecord;
        
        List<Applicant_Income__c> incomeList = new List<Applicant_Income__c>{incomeRecord};
            UpdateTotalAmountOnApplicantHandler.updateTotalAmountInsert(incomeList);
    }
    
    @isTest
    static void processOtherIncomeTest() {      
        LoanAppl__c loanRecord = new LoanAppl__c(Stage__c = 'QDE');
        insert loanRecord;
        
        Applicant__c applicant = new Applicant__c(FName__c = 'Test Applicant', LoanAppln__c = loanRecord.Id);
        insert applicant;
        
        Applicant_Income__c incomeRecord = new Applicant_Income__c( 
            Applicant__c = applicant.Id,
            RecordTypeId = Schema.sObjectType.Applicant_Income__c.getRecordTypeInfosByDeveloperName().get('Other_Income').getRecordTypeId(),
            Monthly_Other_Income__c = 2000
        );
        insert incomeRecord;
        
        List<Applicant_Income__c> incomeList = new List<Applicant_Income__c>{incomeRecord};
            UpdateTotalAmountOnApplicantHandler.updateTotalAmountInsert(incomeList);
    }
    
    @isTest
    static void processCashFlowIncomeTest() {      
        LoanAppl__c loanRecord = new LoanAppl__c(Stage__c = 'QDE');
        insert loanRecord;
        
        Applicant__c applicant = new Applicant__c(FName__c = 'Test Applicant', LoanAppln__c = loanRecord.Id);
        insert applicant;
        
        Applicant_Income__c incomeRecord = new Applicant_Income__c( 
            Applicant__c = applicant.Id,
            RecordTypeId = Schema.sObjectType.Applicant_Income__c.getRecordTypeInfosByDeveloperName().get('Cashflow_Map').getRecordTypeId(),
            Total_Inflow_From_Operations__c = 2000,
            Monthly_Purchases_Cost_Of_Materials__c = 100,
            Total_Expense_of_operations_Or_Business__c = 200
            
        );
        insert incomeRecord;
        
        List<Applicant_Income__c> incomeList = new List<Applicant_Income__c>{incomeRecord};
            UpdateTotalAmountOnApplicantHandler.updateTotalAmountInsert(incomeList);
    }
    
    @isTest
    static void processCashFlowIncomeUpdateTest() {  
        Test.startTest();
        LoanAppl__c loanRecord = new LoanAppl__c(Stage__c = 'QDE');
        insert loanRecord;
        
        Applicant__c applicant = new Applicant__c(FName__c = 'Test Applicant', LoanAppln__c = loanRecord.Id);
        insert applicant;
        
        Applicant_Income__c incomeRecord = new Applicant_Income__c( 
            Applicant__c = applicant.Id,
            RecordTypeId = Schema.sObjectType.Applicant_Income__c.getRecordTypeInfosByDeveloperName().get('Cashflow_Map').getRecordTypeId(),
            Total_Inflow_From_Operations__c = 2000,
            Monthly_Purchases_Cost_Of_Materials__c = 100,
            Total_Expense_of_operations_Or_Business__c = 200,
            Agricultural_Yearly_Income__c = 0,
            Net_Salary__c = 0,
            Other_Salary_Component__c = 0,
            Monthly_Pension_Credited__c = 0,
            Monthly_Other_Income__c = 1
            
        );
        insert incomeRecord;
        
        incomeRecord.Monthly_Purchases_Cost_Of_Materials__c = 50;
        update incomeRecord;
        Test.stopTest();
    }
    
    @isTest
    static void processCashFlowIncomeDeleteTest() {  
        Test.startTest();
        LoanAppl__c loanRecord = new LoanAppl__c(Stage__c = 'QDE');
        insert loanRecord;
        
        Applicant__c applicant = new Applicant__c(FName__c = 'Test Applicant', LoanAppln__c = loanRecord.Id);
        insert applicant;
        
        Applicant_Income__c incomeRecord = new Applicant_Income__c( 
            Applicant__c = applicant.Id,
            RecordTypeId = Schema.sObjectType.Applicant_Income__c.getRecordTypeInfosByDeveloperName().get('Cashflow_Map').getRecordTypeId(),
            Total_Inflow_From_Operations__c = 2000,
            Monthly_Purchases_Cost_Of_Materials__c = 100,
            Total_Expense_of_operations_Or_Business__c = 200,
            Agricultural_Yearly_Income__c = 0,
            Net_Salary__c = 0,
            Other_Salary_Component__c = 0,
            Monthly_Pension_Credited__c = 0,
            Monthly_Other_Income__c = 1
            
        );
        insert incomeRecord;
        
        delete incomeRecord;
        Test.stopTest();
    }
}