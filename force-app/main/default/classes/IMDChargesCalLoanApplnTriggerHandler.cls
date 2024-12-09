public class IMDChargesCalLoanApplnTriggerHandler implements TriggerAction.AfterInsert,TriggerAction.AfterUpdate{
    
    public static void afterInsert(List<LoanAppl__c> newList) {
        /*
        IMDChargesCalLoanApplnTriggerHandler.wrapperClass wrap = new IMDChargesCalLoanApplnTriggerHandler.wrapperClass();

        for (LoanAppl__c loan : newList) {
            wrap.loanIds.put(loan.Id, loan);   
        }

        if (!wrap.loanIds.isEmpty()) {
            IMDChargesCalculation.calculateIMD(wrap.loanIds,wrap.applIds);   
        } */
    }
    
    public static void afterUpdate(List<LoanAppl__c> newList, List<LoanAppl__c> oldList) {
        IMDChargesCalLoanApplnTriggerHandler.wrapperClass wrap = new IMDChargesCalLoanApplnTriggerHandler.wrapperClass();
        Map<Id, LoanAppl__c> oldMap = new Map<Id, LoanAppl__c>(oldList);
        Map<Id,LoanAppl__c> changedValuesLoans = new Map<Id,LoanAppl__c>();
        for (LoanAppl__c loan : newList) {
            LoanAppl__c oldLoan = oldMap.get(loan.Id);
            if (loan.Product__c != oldLoan.Product__c || loan.LeadSource__c != oldLoan.LeadSource__c || loan.PromotionId__c != oldLoan.PromotionId__c
            || loan.ReqLoanAmt__c != oldLoan.ReqLoanAmt__c || loan.AssessedIncAppln__c != oldLoan.AssessedIncAppln__c  || loan.SanLoanAmt__c != oldLoan.SanLoanAmt__c 
            || loan.InsAmt__c != oldLoan.InsAmt__c || loan.RevisedPF__c != oldLoan.RevisedPF__c) {
                changedValuesLoans.put(loan.Id, loan); 
                
            }
        }
        
        if(!changedValuesLoans.isEmpty()){
            wrap.applIds = new Map<Id,Applicant__c>([SELECT Id FROM Applicant__c WHERE ApplType__c = 'P' AND LoanAppln__c =: changedValuesLoans.keySet()]);
            wrap.loanIds = new Map<Id,LoanAppl__c>([SELECT Id,SanLoanAmt__c,InsAmt__c,TotalLoanAmtInclInsurance__c,BrchCode__c,Product__c,AssessedIncAppln__c,LeadSource__c,PromotionId__c,ReqLoanAmt__c,Applicant__r.CustProfile__c,
                                                IMDAmount__c,PFAmount__c,RevisedPF__c,PFInPercentage__c,(SELECT ID FROM Applicant_Assets__r) FROM LoanAppl__c WHERE Id =: changedValuesLoans.keySet() ]);
        }
        
        if (!wrap.applIds.isEmpty() && !wrap.loanIds.isEmpty()) {
            IMDChargesCalculation.calculateIMD(wrap.loanIds,wrap.applIds); 
        }
    }

    public class wrapperClass{
        public Map<Id, Applicant__c> applIds = new Map<Id, Applicant__c>();
        public Map<Id, LoanAppl__c> loanIds = new Map<Id, LoanAppl__c>();
    }

}