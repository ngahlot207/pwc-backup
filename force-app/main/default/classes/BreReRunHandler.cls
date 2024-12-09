public class BreReRunHandler implements TriggerAction.BeforeUpdate {
    public static void beforeUpdate(
        List<LoanAppl__c> newList,
        List<LoanAppl__c> oldList
    ) {
        Map<Id, LoanAppl__c> oldListMap = new Map<Id, LoanAppl__c>(oldList);
        List<LoanAppl__c> updateLoanAppList = new List<LoanAppl__c>();
        
        for (LoanAppl__c loanApp : newList) {
            // if(loanApp.Stage__c == 'Post Sanction'){
            if (
                loanApp.EffectiveROI__c != oldListMap.get(loanApp.Id).EffectiveROI__c ||
                loanApp.SanLoanAmt__c != oldListMap.get(loanApp.Id).SanLoanAmt__c ||
                loanApp.InsAmt__c != oldListMap.get(loanApp.Id).InsAmt__c ||
                loanApp.EMIIcludingInsurance__c !=
                oldListMap.get(loanApp.Id).EMIIcludingInsurance__c ||
                loanApp.Loan_Tenure_Months__c !=
                oldListMap.get(loanApp.Id).Loan_Tenure_Months__c ||
                loanApp.RevisedPF__c != oldListMap.get(loanApp.Id).RevisedPF__c ||
                loanApp.Rate_Type_Floating_Flag__c !=
                oldListMap.get(loanApp.Id).Rate_Type_Floating_Flag__c ||
                loanApp.PricingApprovalApplicable__c !=
                oldListMap.get(loanApp.Id).PricingApprovalApplicable__c || 
                loanApp.TotalIMDAmount__c !=   //LAK-7701
                oldListMap.get(loanApp.Id).TotalIMDAmount__c ||  //LAK-7701
                loanApp.TotalCharges__c !=  
                oldListMap.get(loanApp.Id).TotalCharges__c ||
                loanApp.SchemeId__c !=  
                oldListMap.get(loanApp.Id).SchemeId__c ||
                (loanApp.Stage__c != oldListMap.get(loanApp.Id).Stage__c &&
                 loanApp.Stage__c == 'Post Sanction' &&
                 oldListMap.get(loanApp.Id).Stage__c == 'Soft Sanction') ||
                (loanApp.Stage__c != oldListMap.get(loanApp.Id).Stage__c &&
                 (loanApp.Stage__c == 'DDE' || loanApp.Stage__c == 'UnderWriting') &&
                 (oldListMap.get(loanApp.Id).Stage__c == 'Post Sanction' || oldListMap.get(loanApp.Id).Stage__c == 'Soft Sanction'))
            ) {
                loanApp.DocGenReRequired__c = true;
                loanApp.Disbursal_Document_Required__c=true;
                loanApp.App_Form_End_Use_Letter_Doc_Required__c=true;
                 loanApp.SignatureVerificationDocReq__c=true;
            }
            //Start Changes for LAK-166
            if(loanApp.Stage__c == 'Disbursement Initiation' && loanApp.SubStage__c == 'DI Pool' && oldListMap.get(loanApp.Id).Stage__c == 'Post Sanction' && oldListMap.get(loanApp.Id).SubStage__c == 'UW Approval' && loanApp.OpsStatus__c != 'FTNR'){
                loanApp.OpsStatus__c = 'FTR';
            }else if(loanApp.Stage__c == 'Post Sanction' && loanApp.SubStage__c == 'Ops Query Pool' && oldListMap.get(loanApp.Id).Stage__c == 'Disbursement Initiation' && oldListMap.get(loanApp.Id).SubStage__c == 'DI Check' && loanApp.OpsStatus__c != 'FTNR'){
                loanApp.OpsStatus__c = 'FTNR';
            }
            //End changes for LAK-166
        }
    }
}