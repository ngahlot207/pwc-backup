@isTest
public class PFCalculationForSanAmountTest {   
    @isTest
    static void testAfterUpdate(){
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        loanApp.SanLoanAmt__c=800000;
        loanApp.InsAmt__c=15000;
        update loanApp;
        list<LoanAppl__c> oldList = new list<LoanAppl__c>();
        oldList.add(loanApp);
        LoanAppl__c loan = new LoanAppl__c(Id=loanApp.Id);
        loan.SanLoanAmt__c=900000;
        loan.InsAmt__c=10000;
        update loan;
        Applicant__c appli =  TestDataFactory.createSingleApplicant(true,loan.id); 
        ApplAsset__c asset = TestDataFactory.createApplAsset(true,appli.Id,loan.Id);
        MasterData__c mst = TestDataFactory.mstrData(true);
        LonaApplCharges__c charge=TestDataFactory.chargeData(true, loan.Id, mst.Id);
        LonaApplCharges__c charge1=TestDataFactory.chargeData(true, loan.Id, mst.Id);
        charge1.ChargeCodeID__c='35';
        update charge1;
        system.debug('loan --'+loan);
        system.debug('charge --'+charge);
        system.debug('charge1 --'+charge1);
        list<LoanAppl__c> newList = new list<LoanAppl__c>{loan};
        Test.startTest();
        PFCalculationForSanAmount.afterUpdate(newList,oldList);
        Test.stopTest();
    }
}