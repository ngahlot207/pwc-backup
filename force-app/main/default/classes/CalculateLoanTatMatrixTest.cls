@IsTest
public class CalculateLoanTatMatrixTest {
	@testSetup
    static void testData(){
        user u=TestDataFactory.UserData(true);
        Lead testLead = TestDataFactory.LeadData(true, u.Id);
    }
     @isTest 
    static void testGetTAT(){
        user u = [SELECT Id, Name FROM User LIMIT 1];
        user sup=TestDataFactory.supervisor(true);
        Lead testLead = [ SELECT Id FROM Lead LIMIT 1];
      
        list<LoanAppl__c> newList=new list<LoanAppl__c>();
        LoanAppl__c loan =TestDataFactory.createLoanApplication(true);
        loan.Lead__c = testLead.Id;
        loan.ownerId = u.Id;
        loan.Stage__c = 'Disbursement Initiation';
        loan.FinnSubDtTime__c=system.now();
        update loan;
        newList.add(loan);
        DocDispatch__c docDis=new DocDispatch__c();
        docDis.DateofReceiptbyOps__c=system.now();
        docDis.LoanAppln__c=loan.id;
        insert docDis;
        LoanTAT__c loanTataRec =new LoanTAT__c();
        loanTataRec.LoanApplication__c=loan.id;
        loanTataRec.ApplicableTATs__c='CPA Submission to CPA Claim';
        
        insert loanTataRec;
        //set<string> tatString= new set<string>();
        //tatString.add('Lead to Login');
        /*tatString.add('Login to Disbursement TAT');
        tatString.add('Lead to Disbursement TAT');
        tatString.add('CPA Submission to CPA Claim');
        tatString.add('Underwriter to Rejection');
         tatString.add('NDC 2 to Disbursement');*/
        LoanTATMatrix__c newRec = new LoanTATMatrix__c();
        newRec.LoanApp__c=loan.id;
        insert newRec;
        Map<String,LoanTATMatrix__c> newtest=new Map<String,LoanTATMatrix__c>();
        newtest.put('test',newRec);
        
    }
}