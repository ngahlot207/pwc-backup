@isTest
public class MultiTrancheRequestGeneratorTest {

     @isTest
    public static void testGenerateMethod() {
        Test.startTest();
        
        User us = TestDataFactory.UserData(true);
        
        System.runas(us){    
            
            LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
            loanApp.Finnone_Loan_Number__c='FEDMUM0HL0503111';
            update loanApp;
            
            IntgMsg__c intgMsg1 = new IntgMsg__c();
            intgMsg1.Name='Get Multi Tranch';
            intgMsg1.BU__c='HL / STL';
            intgMsg1.Status__c='New';
            intgMsg1.MStatus__c='Blank';
            intgMsg1.RefObj__c='LoanAppl__c';
            intgMsg1.RefId__c = loanApp.Id;
            intgMsg1.Svc__c='Get Multi Tranch';
            
            insert intgMsg1;
            
            
            List<IntgMsg__c> msgs = new List<IntgMsg__c>{intgMsg1};
            MultiTrancheRequestGenerator generator = new MultiTrancheRequestGenerator();
            generator.generate(msgs, 'Get Multi Tranch', 'Async');
            
     }   
     
    }   
}