public class IMDChargesCalculationApplTriggerHandler implements TriggerAction.AfterInsert,TriggerAction.AfterUpdate{
    public static void afterInsert(List<Applicant__c> newList) {
        IMDChargesCalculationApplTriggerHandler.wrapperClass wrap = new IMDChargesCalculationApplTriggerHandler.wrapperClass();
        for (Applicant__c appl : newList) {
            if(appl.ApplType__c == 'P'){
                wrap.applIds.put(appl.Id, appl);
                wrap.applWithLoanIds.add(appl.LoanAppln__c); 
            }
        }
        
       /* wrap.loanIds = new Map<Id,LoanAppl__c>([SELECT Id,BrchCode__c,Product__c,AssessedIncAppln__c,LeadSource__c,PromotionId__c,ReqLoanAmt__c,Applicant__r.CustProfile__c,
                                                IMDAmount__c,PFAmount__c FROM LoanAppl__c WHERE Id =: wrap.applWithLoanIds ]);*/
         wrap.loanIds = new Map<Id,LoanAppl__c>([SELECT Id,SanLoanAmt__c,InsAmt__c,TotalLoanAmtInclInsurance__c,BrchCode__c,Product__c,AssessedIncAppln__c,LeadSource__c,PromotionId__c,ReqLoanAmt__c,Applicant__r.CustProfile__c,
                                                IMDAmount__c,PFAmount__c,PFInPercentage__c,RevisedPF__c,(SELECT ID FROM Applicant_Assets__r) FROM LoanAppl__c WHERE Id =: wrap.applWithLoanIds ]);
        
        if (!wrap.applIds.isEmpty() && !wrap.loanIds.isEmpty()) {
            IMDChargesCalculation.calculateIMD(wrap.loanIds,wrap.applIds);  
        }
    }
    public static void afterUpdate(List<Applicant__c> newList, List<Applicant__c> oldList) {
        Map<Id, Applicant__c> oldMap = new Map<Id, Applicant__c>(oldList);
        IMDChargesCalculationApplTriggerHandler.wrapperClass wrap = new IMDChargesCalculationApplTriggerHandler.wrapperClass();
        
        for (Applicant__c appl : newList) {
            Applicant__c oldappl = oldMap.get(appl.Id); 
            if (appl.CustProfile__c != oldappl.CustProfile__c && appl.ApplType__c == 'P' && appl.CustProfile__c != NULL ) {
                    wrap.applIds.put(appl.Id, appl);
                    wrap.applWithLoanIds.add(appl.LoanAppln__c); 
            }
        }

        wrap.loanIds = new Map<Id,LoanAppl__c>([SELECT Id,SanLoanAmt__c,InsAmt__c,TotalLoanAmtInclInsurance__c,BrchCode__c,Product__c,AssessedIncAppln__c,LeadSource__c,PromotionId__c,ReqLoanAmt__c,Applicant__r.CustProfile__c,
                                                IMDAmount__c,PFAmount__c,PFInPercentage__c,RevisedPF__c,(SELECT ID FROM Applicant_Assets__r) FROM LoanAppl__c WHERE Id =: wrap.applWithLoanIds ]);

        if (!wrap.applIds.isEmpty() && !wrap.loanIds.isEmpty()) {
            IMDChargesCalculation.calculateIMD(wrap.loanIds,wrap.applIds); 
        }
    }

    public class wrapperClass{
        public Map<Id, Applicant__c> applIds = new Map<Id, Applicant__c>();
        public Map<Id, LoanAppl__c> loanIds = new Map<Id, LoanAppl__c>();
        public Set<Id> applWithLoanIds = new Set<Id>();

    }
}