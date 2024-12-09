@isTest
public class preEmiTypeChangeTriggerHandlerTest {
    
    @isTest
    static void preEmiChngaeTestMethd() {
        LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
        List<LoanAppl__c> oldList = new List<LoanAppl__c> {loan};
            
        LoanAppl__c loanAPp = new LoanAppl__c();
        loanAPp.Id = loan.Id;
        loanAPp.PreEmiType__c = 'C';
        
        TriggerBase.bypass('LoanAppl__c');
        update loanAPp;
        TriggerBase.clearBypass('LoanAppl__c');
        List<LoanAppl__c> newList = new List<LoanAppl__c> {loanAPp};
         preEmiTypeChangeTriggerHandler.afterUpdate(newList, oldList);
        
        List<LonaApplCharges__c> loanAppChargRecrds = new List<LonaApplCharges__c>();
        loanAppChargRecrds = [select id,ChargeCodeDesID__c,LoanApplication__c  from LonaApplCharges__c where LoanApplication__c =: newList[0].Id AND ChargeCodeDesID__c = '500131'];
        system.assertEquals(1, loanAppChargRecrds.size());
        
        LoanAppl__c loanAppr = new LoanAppl__c();
        loanAppr.Id = loan.Id;
        loanAppr.PreEmiType__c = 'R';
        
        TriggerBase.bypass('LoanAppl__c');
        update loanAppr;
        TriggerBase.clearBypass('LoanAppl__c');
        List<LoanAppl__c> newListNew = new List<LoanAppl__c> {loanAppr};
        preEmiTypeChangeTriggerHandler.afterUpdate(newListNew, newList);
        List<LonaApplCharges__c> loanAppChargRecrdNew = new List<LonaApplCharges__c>();
        loanAppChargRecrdNew = [select id,ChargeCodeDesID__c,LoanApplication__c  from LonaApplCharges__c where LoanApplication__c =: newListNew[0].Id AND ChargeCodeDesID__c = '500131'];
        system.assertEquals(0, loanAppChargRecrdNew.size());
       	
        LoanAppl__c loanNew = TestDataFactory.createLoanApplication(true);
        LonaApplCharges__c loaaCharges = new LonaApplCharges__c ();
        loaaCharges.LoanApplication__c = loanNew.Id;
        loaaCharges.ChargeCodeDesc__c = 'Pre EMI charges';
        loaaCharges.ChargeCodeDesID__c = '500131';
        loaaCharges.ChargeCodeID__c = '600254';
        loaaCharges.Remark__c = 'Pre EMI charges';
        loaaCharges.ChargeType__c = 'Charge';
        TriggerBase.bypass('LonaApplCharges__c');
        Insert loaaCharges;
        TriggerBase.clearBypass('LonaApplCharges__c');
        
        LoanAppl__c loanApprr = new LoanAppl__c();
        loanApprr.Id = loanNew.Id;
        loanApprr.PreEmiType__c = 'R';
        
        TriggerBase.bypass('LoanAppl__c');
        update loanApprr;
        TriggerBase.clearBypass('LoanAppl__c');
        List<LoanAppl__c> newListNeww = new List<LoanAppl__c> {loanApprr};
        preEmiTypeChangeTriggerHandler.afterUpdate(newListNeww, new List<LoanAppl__c> {loanNew});
        List<LonaApplCharges__c> loanAppChargRecr = [select id,ChargeCodeDesID__c,LoanApplication__c  from LonaApplCharges__c where LoanApplication__c =: loanNew.Id AND ChargeCodeDesID__c = '500131'];
        system.assertEquals(0, loanAppChargRecr.size());        
    }
}