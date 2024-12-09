/** 
* ********************************************************
* Created By : Prasanna Kawle
* Created Date: 13-Dec-2023
* ******************************************************** 
*/
public class PFCalculationForSanAmount implements TriggerAction.AfterUpdate{
    public static void afterUpdate(List<LoanAppl__c> newList, List<LoanAppl__c> oldList) {
        Map<Id, LoanAppl__c> oldMap = new Map<Id, LoanAppl__c>(oldList);
        List<LonaApplCharges__c> loanChargeUpdateList = new List<LonaApplCharges__c>();
        
        Map<Id,LoanAppl__c> loanIds = new Map<Id,LoanAppl__c>();
        for (LoanAppl__c loan : newList) {
            LoanAppl__c oldLoan = oldMap.get(loan.Id);
            if ((loan.SanLoanAmt__c != null && loan.SanLoanAmt__c != oldLoan.SanLoanAmt__c) || (loan.InsAmt__c != null && loan.InsAmt__c != oldLoan.InsAmt__c)) {
                loanIds.put(loan.Id,loan);
            }
        }
        
        if (!loanIds.isEmpty()) {
            Map<String, String> chargeCodeMap = new Map<String, String>{
                'PFChargeCodeId' => System.Label.PFChargeCodeId, 
                'CersaiChargeCodeId' => System.Label.CersaiChargeCodeId
            };

            List<LonaApplCharges__c> loanCharges = [SELECT Id, Name, Amount__c, ActualAmt__c, Processing_Fees__c, ChargeCodeDesc__c, ChargeCodeID__c, LoanApplication__c,PF__c 
                                                    FROM LonaApplCharges__c WHERE ChargeCodeID__c IN :chargeCodeMap.values() AND LoanApplication__c IN :loanIds.keySet()];
            
            if(!loanCharges.isEmpty() && loanCharges.size()>0){
                for (LonaApplCharges__c loanCharge : loanCharges) {
                    LonaApplCharges__c updatedLoanCharge = new LonaApplCharges__c(Id = loanCharge.Id);
                    if (loanCharge.ChargeCodeID__c == chargeCodeMap.get('PFChargeCodeId')) {
                        system.debug('loanCharge'+loanIds.get(loanCharge.LoanApplication__c));
                        system.debug('Total Amount'+loanIds.get(loanCharge.LoanApplication__c).TotalLoanAmtInclInsurance__c);
                        decimal amount = calculatePF(loanCharge, loanIds.get(loanCharge.LoanApplication__c))*loanIds.get(loanCharge.LoanApplication__c).TotalLoanAmtInclInsurance__c;
                        if(amount != null) {
                            amount = roundNumberMethod(amount);
                        }
                        updatedLoanCharge.PF__c = calculatePF(loanCharge, loanIds.get(loanCharge.LoanApplication__c))*100 ;
                        updatedLoanCharge.ActualAmt__c = amount;
                        updatedLoanCharge.GST_Amount__c = amount * (Decimal.valueOf(System.Label.GST));
                        if(updatedLoanCharge.GST_Amount__c != null) {
                            updatedLoanCharge.GST_Amount__c = roundNumberMethod(updatedLoanCharge.GST_Amount__c);
                        }
                        updatedLoanCharge.Amount__c = amount + (amount * Decimal.valueOf(System.Label.GST));
                        if(updatedLoanCharge.Amount__c != null){
                            updatedLoanCharge.Amount__c = roundNumberMethod(updatedLoanCharge.Amount__c);
                        }
                    } 
                    if (loanCharge.ChargeCodeID__c == chargeCodeMap.get('CersaiChargeCodeId')) { 
                        decimal amount = amountCalculation_Cersai(loanIds.get(loanCharge.LoanApplication__c));
                        if(amount != null){
                            amount = roundNumberMethod(amount);
                        }
                        updatedLoanCharge.ActualAmt__c = amount;
                        updatedLoanCharge.GST_Amount__c = amount * (Decimal.valueOf(System.Label.GST));
                        if(updatedLoanCharge.GST_Amount__c != null){
                            updatedLoanCharge.GST_Amount__c = roundNumberMethod(updatedLoanCharge.GST_Amount__c);
                        }
                        updatedLoanCharge.Amount__c = amount + (amount * Decimal.valueOf(System.Label.GST));
                        if(updatedLoanCharge.Amount__c != null){
                            updatedLoanCharge.Amount__c = roundNumberMethod(updatedLoanCharge.Amount__c);
                        }
                    }
                    
                    loanChargeUpdateList.add(updatedLoanCharge);
                }
            }
            
            if (!loanChargeUpdateList.isEmpty()) {
                update loanChargeUpdateList;
            }
        }
    }
    
    public static Decimal calculatePF(LonaApplCharges__c charge,LoanAppl__c loan){
        decimal proFees = 0;
        if(charge.PF__c != null){
            proFees = charge.PF__c/100;
        }else{
            proFees = charge.ActualAmt__c != null && loan.ReqLoanAmt__c != null?charge.ActualAmt__c/loan.ReqLoanAmt__c:0;
        }
        system.debug('PF Cal ##27---'+proFees*100);
        return proFees;         
    }
    
    public static Decimal amountCalculation_Cersai(LoanAppl__c loan){
        List<ApplAsset__c> assets = new List<ApplAsset__c>();
        decimal amount = 0;
        Integer aboveAmtValue = Integer.valueOf(System.Label.Above5LakhCharges);
        Integer belowAmtValue = Integer.valueOf(System.Label.Below5LakhCharges);
        Integer amtValueCheck = Integer.valueOf(System.Label.RequestedLoanAmount);
        assets = [SELECT Id,LoanAppln__c FROM ApplAsset__c WHERE LoanAppln__c =: loan.Id ];
        system.debug('Property Asset Count##92--- '+assets.size());
        if(!assets.isEmpty() && assets.size()>0){
            Integer applAssetCount = assets.size();
            if(loan.ReqLoanAmt__c > amtValueCheck){
                amount = (aboveAmtValue * applAssetCount);
            }else{
                amount = (belowAmtValue * applAssetCount); 
            }
            system.debug('Amount Cal for Cersai ##100--- '+amount); 
        }
        system.debug('Amount Cal for Cersai ##102--- '+amount); 
        return amount;  
    }

    private static Decimal roundNumberMethod(decimal amount){
        Decimal roundedNumber = Math.round(amount);
        return roundedNumber;
    }
}