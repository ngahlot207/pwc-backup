@isTest
public class CaptureIncomeControllerTest { 
    @isTest
    static void testGetApplicantIncomeRecordTypes() {
        LoanAppl__c testLoanApp = new LoanAppl__c(AssessedIncAppln__c = true);
        insert testLoanApp;
        
        Applicant__c testApplicant=TestDataFactory.createSingleApplicant(false,testLoanApp.id);
        testApplicant.CustProfile__c = 'SELF EMPLOYED PROFESSIONAL';
        testApplicant.LatestyearforwhichITRisavailable__c ='ITR Not Available';
        insert testApplicant;
        
        List<MasterData__c> incomeTypeMasters = new List<MasterData__c>{
            new MasterData__c(FinnoneVal__c = 'Label1', FinnoneCode__c = 'Cashflow_Map', Type__c ='Income Type'),
                new MasterData__c(FinnoneVal__c = 'Label2', FinnoneCode__c = 'CashSal', Type__c ='Income Type'),
                new MasterData__c(FinnoneVal__c = 'Label3', FinnoneCode__c = 'BankCrSal', Type__c ='Income Type'),
                new MasterData__c(FinnoneVal__c = 'Label4', FinnoneCode__c = 'RentalwBank', Type__c ='Income Type'),
                 new MasterData__c(FinnoneVal__c = 'Label5', FinnoneCode__c = 'Other_Income', Type__c ='Income Type')
                };
                    insert incomeTypeMasters;
        
       Id AppIRecordTypeId1 = Schema.SObjectType.Applicant_Income__c.getRecordTypeInfosByName().get('Agricultural Income').getRecordTypeId();
        
        
        List<Applicant_Income__c> applicantIncomeRecords = new List<Applicant_Income__c>{
            new Applicant_Income__c(Applicant__c = testApplicant.Id, RecordTypeId = AppIRecordTypeId1)
                };
                    TriggerBase.bypass('Applicant_Income__c');
                    insert applicantIncomeRecords;
        			TriggerBase.clearBypass('Applicant_Income__c');
        
        	captureIncomeController.getPicklistValues(testApplicant.id);
            captureIncomeController.getApplicantIncomeRecordTypes(testApplicant.id);
            captureIncomeController.getApplicantData(testApplicant.id);
        	captureIncomeController.deleteIncomeTypeRecords(testApplicant.id,'AgriIncome');
    }
    @isTest
    static void testGetApplicantIncomeRecordTypes1() {
        LoanAppl__c testLoanApp = new LoanAppl__c(AssessedIncAppln__c = true);
        insert testLoanApp;
        Applicant__c testApplicant=TestDataFactory.createSingleApplicant(false,testLoanApp.id);
        testApplicant.CustProfile__c = 'SELF EMPLOYED PROFESSIONAL';
        testApplicant.LatestyearforwhichITRisavailable__c ='ITR Not Available';
        insert testApplicant;
        
        
        //Id AppIRecordTypeId2 = [select Id from RecordType where sobjectType='Applicant_Income__c' and name='Bank Credit Salary'].id;
        Id AppIRecordTypeId2 = Schema.SObjectType.Applicant_Income__c.getRecordTypeInfosByName().get('Bank Credit Salary').getRecordTypeId();
        
        
        List<Applicant_Income__c> applicantIncomeRecords = new List<Applicant_Income__c>{
               new Applicant_Income__c(Applicant__c = testApplicant.Id, RecordTypeId = AppIRecordTypeId2)
                };
                    TriggerBase.bypass('Applicant_Income__c');
                    insert applicantIncomeRecords;
        			TriggerBase.clearBypass('Applicant_Income__c');
        
            captureIncomeController.deleteIncomeTypeRecords(testApplicant.id,'BankCrSal');
    }
        @isTest
    static void testGetApplicantIncomeRecordTypes2() {
        LoanAppl__c testLoanApp = new LoanAppl__c(AssessedIncAppln__c = true);
        insert testLoanApp;
        Applicant__c testApplicant=TestDataFactory.createSingleApplicant(false,testLoanApp.id);
        testApplicant.CustProfile__c = 'SELF EMPLOYED PROFESSIONAL';
        testApplicant.LatestyearforwhichITRisavailable__c ='ITR Not Available';
        insert testApplicant;
        
        
        //Id AppIRecordTypeId2 = [select Id from RecordType where sobjectType='Applicant_Income__c' and name='Bank Credit Salary'].id;
        Id AppIRecordTypeId2 = Schema.SObjectType.Applicant_Income__c.getRecordTypeInfosByName().get('Cash Salary').getRecordTypeId();
        
        
        List<Applicant_Income__c> applicantIncomeRecords = new List<Applicant_Income__c>{
               new Applicant_Income__c(Applicant__c = testApplicant.Id, RecordTypeId = AppIRecordTypeId2)
                };
                    TriggerBase.bypass('Applicant_Income__c');
                    insert applicantIncomeRecords;
        			TriggerBase.clearBypass('Applicant_Income__c');
        
            captureIncomeController.deleteIncomeTypeRecords(testApplicant.id,'CashSal');
    }
            @isTest
    static void testGetApplicantIncomeRecordTypes3() {
        LoanAppl__c testLoanApp = new LoanAppl__c(AssessedIncAppln__c = true);
        insert testLoanApp;
        Applicant__c testApplicant=TestDataFactory.createSingleApplicant(false,testLoanApp.id);
        testApplicant.CustProfile__c = 'SELF EMPLOYED PROFESSIONAL';
        testApplicant.LatestyearforwhichITRisavailable__c ='ITR Not Available';
        insert testApplicant;
        
        
        //Id AppIRecordTypeId2 = [select Id from RecordType where sobjectType='Applicant_Income__c' and name='Bank Credit Salary'].id;
        Id AppIRecordTypeId2 = Schema.SObjectType.Applicant_Income__c.getRecordTypeInfosByName().get('Other Income').getRecordTypeId();
        
        
        List<Applicant_Income__c> applicantIncomeRecords = new List<Applicant_Income__c>{
               new Applicant_Income__c(Applicant__c = testApplicant.Id, RecordTypeId = AppIRecordTypeId2)
                };
                    TriggerBase.bypass('Applicant_Income__c');
                    insert applicantIncomeRecords;
        			TriggerBase.clearBypass('Applicant_Income__c');
        
            captureIncomeController.deleteIncomeTypeRecords(testApplicant.id,'Other_Income');
    }
            @isTest
    static void testGetApplicantIncomeRecordTypes4() {
        LoanAppl__c testLoanApp = new LoanAppl__c(AssessedIncAppln__c = true);
        insert testLoanApp;
        Applicant__c testApplicant=TestDataFactory.createSingleApplicant(false,testLoanApp.id);
        testApplicant.CustProfile__c = 'SELF EMPLOYED PROFESSIONAL';
        testApplicant.LatestyearforwhichITRisavailable__c ='ITR Not Available';
        insert testApplicant;
        
        
        //Id AppIRecordTypeId2 = [select Id from RecordType where sobjectType='Applicant_Income__c' and name='Bank Credit Salary'].id;
        Id AppIRecordTypeId2 = Schema.SObjectType.Applicant_Income__c.getRecordTypeInfosByName().get('Pension Income').getRecordTypeId();
        
        
        List<Applicant_Income__c> applicantIncomeRecords = new List<Applicant_Income__c>{
               new Applicant_Income__c(Applicant__c = testApplicant.Id, RecordTypeId = AppIRecordTypeId2)
                };
                    TriggerBase.bypass('Applicant_Income__c');
                    insert applicantIncomeRecords;
        			TriggerBase.clearBypass('Applicant_Income__c');
        
            captureIncomeController.deleteIncomeTypeRecords(testApplicant.id,'Pension');
    }
            @isTest
    static void testGetApplicantIncomeRecordTypes5() {
        LoanAppl__c testLoanApp = new LoanAppl__c(AssessedIncAppln__c = true);
        insert testLoanApp;
        Applicant__c testApplicant=TestDataFactory.createSingleApplicant(false,testLoanApp.id);
        testApplicant.CustProfile__c = 'SELF EMPLOYED PROFESSIONAL';
        testApplicant.LatestyearforwhichITRisavailable__c ='ITR Not Available';
        insert testApplicant;
        
        
        //Id AppIRecordTypeId2 = [select Id from RecordType where sobjectType='Applicant_Income__c' and name='Bank Credit Salary'].id;
        Id AppIRecordTypeId2 = Schema.SObjectType.Applicant_Income__c.getRecordTypeInfosByName().get('Rental wBanking').getRecordTypeId();
        
        
        List<Applicant_Income__c> applicantIncomeRecords = new List<Applicant_Income__c>{
               new Applicant_Income__c(Applicant__c = testApplicant.Id, RecordTypeId = AppIRecordTypeId2)
                };
                    TriggerBase.bypass('Applicant_Income__c');
                    insert applicantIncomeRecords;
        			TriggerBase.clearBypass('Applicant_Income__c');
        
            captureIncomeController.deleteIncomeTypeRecords(testApplicant.id,'RentalwBank');
    }
            @isTest
    static void testGetApplicantIncomeRecordTypes6() {
        LoanAppl__c testLoanApp = new LoanAppl__c(AssessedIncAppln__c = true);
        insert testLoanApp;
        Applicant__c testApplicant=TestDataFactory.createSingleApplicant(false,testLoanApp.id);
        testApplicant.CustProfile__c = 'SELF EMPLOYED PROFESSIONAL';
        testApplicant.LatestyearforwhichITRisavailable__c ='ITR Not Available';
        insert testApplicant;
        
        
        //Id AppIRecordTypeId2 = [select Id from RecordType where sobjectType='Applicant_Income__c' and name='Bank Credit Salary'].id;
       Id AppIRecordTypeId2 = Schema.SObjectType.Applicant_Income__c.getRecordTypeInfosByName().get('Rental woBanking').getRecordTypeId();
        
        
        List<Applicant_Income__c> applicantIncomeRecords = new List<Applicant_Income__c>{
               new Applicant_Income__c(Applicant__c = testApplicant.Id, RecordTypeId = AppIRecordTypeId2)
                };
                    TriggerBase.bypass('Applicant_Income__c');
                    insert applicantIncomeRecords;
        			TriggerBase.clearBypass('Applicant_Income__c');
        
            captureIncomeController.deleteIncomeTypeRecords(testApplicant.id,'Rental_woBanking');
    }
}