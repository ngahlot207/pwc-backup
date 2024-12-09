public class CersaiChargesCalculationTriggerHandler {

    public static Map<Id, LoanAppl__c> loanIds {get;set;}

    CersaiChargesCalculationTriggerHandler(){
        loanIds = new Map<Id, LoanAppl__c>();
    } 

    public static void cersaiCalOnInsert(List<ApplAsset__c> newList){   
        loanIds = new Map<Id, LoanAppl__c>();
        Set<Id> loanApplIds = new Set<Id>();  
        for(ApplAsset__c asset : newList){
            if(asset.LoanAppln__c != null && asset.Appl__c != null){
                loanApplIds.add(asset.LoanAppln__c);
            }
        }

        if(!loanApplIds.isEmpty()){
            loanIds = new Map<Id, LoanAppl__c>([SELECT Id,ReqLoanAmt__c FROM LoanAppl__c WHERE Id =: loanApplIds]);
        }

        if(!loanIds.isEmpty()){
            calculateCersai(loanIds);
        }
    }
    public static void cersaiCalOnDelete(List<ApplAsset__c> oldList){
        loanIds = new Map<Id, LoanAppl__c>();
        Set<Id> loanApplIds = new Set<Id>();
        for(ApplAsset__c asset : oldList){
            if(asset.LoanAppln__c != null  && asset.Appl__c != null){
                if(asset.LoanAppln__c != null && asset.Appl__c != null){
                    loanApplIds.add(asset.LoanAppln__c);
                }
            }
        }

        if(!loanApplIds.isEmpty()){
            loanIds = new Map<Id, LoanAppl__c>([SELECT Id,ReqLoanAmt__c FROM LoanAppl__c WHERE Id =: loanApplIds]);
        }

        if(!loanIds.isEmpty()){
            calculateCersai(loanIds);
        }
    }

    public static void calculateCersai(Map<Id, LoanAppl__c> loanIds){
        List<LonaApplCharges__c> loanChargeUpdateList = new List<LonaApplCharges__c>();
        List<LonaApplCharges__c> loanCharges = new List<LonaApplCharges__c>();
        Map<String, String> chargeCodeMap = new Map<String, String>{ 
            'CersaiChargeCodeId' => System.Label.CersaiChargeCodeId
            };

        loanCharges = [SELECT Id, Name, Amount__c, ChargeCodeDesc__c, ChargeCodeID__c, LoanApplication__c ,GST_Amount__c,ActualAmt__c
                        FROM LonaApplCharges__c WHERE ChargeCodeID__c IN :chargeCodeMap.values() AND LoanApplication__c IN :loanIds.keySet()];
        
        if(!loanCharges.isEmpty() && loanCharges.size()>0){
            for (LonaApplCharges__c loanCharge : loanCharges) {
                LonaApplCharges__c updatedLoanCharge = new LonaApplCharges__c(Id = loanCharge.Id); 
                if (loanCharge.ChargeCodeID__c == chargeCodeMap.get('CersaiChargeCodeId')) { 
                    decimal amount = amountCalculation_Cersai(loanIds.get(loanCharge.LoanApplication__c));
                    if(amount != null){
                        amount = roundNumberMethod(amount);
                    }
                    updatedLoanCharge.Amount__c = amount + (amount * Decimal.valueOf(System.Label.GST));
                    updatedLoanCharge.ActualAmt__c = amount ;
                    updatedLoanCharge.GST_Amount__c = amount * Decimal.valueOf(System.Label.GST);
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

    public static Decimal amountCalculation_Cersai(LoanAppl__c loan){
        List<ApplAsset__c> assets = new List<ApplAsset__c>();
        decimal amount = 0;
        Integer aboveAmtValue = Integer.valueOf(System.Label.Above5LakhCharges);
        Integer belowAmtValue = Integer.valueOf(System.Label.Below5LakhCharges);
        Integer amtValueCheck = Integer.valueOf(System.Label.RequestedLoanAmount);
        assets = [SELECT Id,LoanAppln__c FROM ApplAsset__c WHERE LoanAppln__c =: loan.Id ];
        system.debug('Property Asset Count##74--- '+assets.size());
        if(!assets.isEmpty() && assets.size()>0){
            Integer applAssetCount = assets.size();
            if(loan.ReqLoanAmt__c > amtValueCheck){
                amount = (aboveAmtValue * applAssetCount);
            }else{
                amount = (belowAmtValue * applAssetCount); 
            }
        }
        return amount; 
    }

    private static Decimal roundNumberMethod(decimal amount){
        Decimal roundedNumber = Math.round(amount);
        return roundedNumber;
    }
}