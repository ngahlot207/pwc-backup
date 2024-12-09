@isTest
public class DisbursementComparatorTest {
    @isTest
    public static void CompareTest(){
       LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        
        //Equal Condition
       	Disbursement__c a1 = TestDataFactory.createDisbursement(true,100,loanApp.id);
        Disbursement__c b1 = TestDataFactory.createDisbursement(true,100,loanApp.id);
        
        //a>b
        Disbursement__c a2 = TestDataFactory.createDisbursement(true,200,loanApp.id);
        Disbursement__c b2 = TestDataFactory.createDisbursement(true,100,loanApp.id);
        
        //a<b
        Disbursement__c a3 = TestDataFactory.createDisbursement(true,100,loanApp.id);
        Disbursement__c b3 = TestDataFactory.createDisbursement(true,200,loanApp.id);
          
        
        test.startTest();
        DisbursementComparator a = new DisbursementComparator();
       	Integer test1 = a.compare(a1, b1);
        Integer test2 = a.compare(a2, b2);
        Integer test3 = a.compare(a3, b3);
        test.stopTest();
    }
    
}