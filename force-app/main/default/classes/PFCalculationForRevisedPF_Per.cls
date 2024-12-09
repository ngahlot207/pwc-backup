/** 
* ********************************************************
* Created By : Prasanna Kawle
* Created Date: 05-Jan-2024
* ********************************************************
*/
public class PFCalculationForRevisedPF_Per implements TriggerAction.BeforeUpdate {
    
    public static void beforeUpdate(List<LonaApplCharges__c> newList, List<LonaApplCharges__c> oldList) {
        Map<Id, LonaApplCharges__c> oldMap = new Map<Id, LonaApplCharges__c>(oldList); 
        Set<Id> loanIds = new Set<Id>();

        for (LonaApplCharges__c charge : newList) {
            LonaApplCharges__c oldCharge = oldMap.get(charge.Id);
                if (charge.Revised_PF__c != null && charge.Revised_PF__c != oldCharge.Revised_PF__c) { 
                    loanIds.add(charge.LoanApplication__c);
                }
        }

        if (!loanIds.isEmpty()) {
            Map<Id,LoanAppl__c> loans = new Map<Id,LoanAppl__c>([SELECT Id, TotalLoanAmtInclInsurance__c FROM LoanAppl__c WHERE Id IN : loanIds]);

            for (LonaApplCharges__c charge : newList) {
                LonaApplCharges__c oldCharge = oldMap.get(charge.Id);
                if (charge.Revised_PF__c != null && charge.Revised_PF__c != oldCharge.Revised_PF__c) {
                    if(charge.ChargeCodeID__c == System.Label.PFChargeCodeId){ 
                        LoanAppl__c loanAppl = loans.get(charge.LoanApplication__c);
                        decimal amount = (charge.Revised_PF__c)*(loanAppl.TotalLoanAmtInclInsurance__c)/100;
                        if(amount != null){
                            amount = roundNumberMethod(amount);
                        }
                        charge.ActualAmt__c = amount;
                        charge.GST_Amount__c = amount * (Decimal.valueOf(System.Label.GST));
                        if(charge.GST_Amount__c != null){
                            charge.GST_Amount__c = roundNumberMethod(charge.GST_Amount__c);
                        }
                        charge.Amount__c = amount + (amount * Decimal.valueOf(System.Label.GST));
                        if(charge.Amount__c != null){
                            charge.Amount__c = roundNumberMethod(charge.Amount__c);
                        }
                        system.debug('Amount__c --> '+ charge.Amount__c + ' && ' + ' ActualAmt__c --> ' + charge.ActualAmt__c + ' && ' + ' GST_Amount__c --> '+ charge.GST_Amount__c);
                    }
                }
            } 
        }
    }

    private static Decimal roundNumberMethod(decimal amount){
        Decimal roundedNumber = Math.round(amount);
        
        return roundedNumber;
    }
}