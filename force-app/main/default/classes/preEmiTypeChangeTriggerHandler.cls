public class preEmiTypeChangeTriggerHandler implements TriggerAction.AfterUpdate{
    
    public static void afterUpdate(List<LoanAppl__c> newList, List<LoanAppl__c> oldList) {
        Map<Id, LoanAppl__c> oldMap = new Map<Id, LoanAppl__c>(oldList);
        emiIncludingValueChangeHandler(newList,oldMap); // added for updating amt_rupees_words__c field in active nach records by Vishnu
        Set<Id> loanAppIds = new Set<Id>();
        Set<Id> loanAppIdsNew = new Set<Id>();
        List<LonaApplCharges__c> loanAppChargRecrds = new List<LonaApplCharges__c>();
        List<LonaApplCharges__c> deleteLoanCharges = new List<LonaApplCharges__c>();
        Map<Id,List<LonaApplCharges__c>> loanAppWithChargsMap = new Map<Id,List<LonaApplCharges__c>>();
        List<LonaApplCharges__c> createLoanAppCharges = new List<LonaApplCharges__c>();
        
        for(LoanAppl__c loanApp : newList){
            if(loanApp.PreEmiType__c == 'C' && loanApp.PreEmiType__c != oldMap.get(loanApp.Id).PreEmiType__c){
                loanAppIds.add(loanApp.Id);
            }else if(loanApp.PreEmiType__c == 'R' && loanApp.PreEmiType__c != oldMap.get(loanApp.Id).PreEmiType__c){
                loanAppIdsNew.add(loanApp.Id);
            }
        }
        if(loanAppIds != null && loanAppIds.size() > 0){
            loanAppChargRecrds = [select id,ChargeCodeDesID__c,LoanApplication__c  from LonaApplCharges__c where LoanApplication__c IN:loanAppIds AND ChargeCodeDesID__c = '500131'];
        }
        if(loanAppChargRecrds != null && loanAppChargRecrds.size() > 0){
            for(LonaApplCharges__c loanAppChrge : loanAppChargRecrds){
                if(loanAppWithChargsMap.containsKey(loanAppChrge.LoanApplication__c)){
                    loanAppWithChargsMap.get(loanAppChrge.LoanApplication__c).add(loanAppChrge);
                }else{
                    loanAppWithChargsMap.put(loanAppChrge.LoanApplication__c,new List<LonaApplCharges__c>{loanAppChrge});
                }   
            }
        }
        if(loanAppIds != null && loanAppIds.size() > 0){
            for(Id loanId : loanAppIds){
                List<LonaApplCharges__c> exisChargeRecrds = loanAppWithChargsMap.get(loanId);
                system.debug('exisChargeRecrds' + exisChargeRecrds);
              if (exisChargeRecrds == null) {
                    LonaApplCharges__c loaaCharges = new LonaApplCharges__c ();
                    loaaCharges.LoanApplication__c = loanId;
                    loaaCharges.ChargeCodeDesc__c = 'Pre EMI charges';
                    loaaCharges.ChargeCodeDesID__c = '500131';
                    loaaCharges.ChargeCodeID__c = '600254';
                    loaaCharges.Remark__c = 'Pre EMI charges';
                    loaaCharges.ChargeType__c = 'Charge';
                    createLoanAppCharges.add(loaaCharges);
                }
            }         
        }
        if(createLoanAppCharges != null && createLoanAppCharges.size() > 0){
            insert createLoanAppCharges;
        }
        if(loanAppIdsNew != null && loanAppIdsNew.size() > 0){
            deleteLoanCharges = [select id,ChargeCodeDesID__c,LoanApplication__c  from LonaApplCharges__c where LoanApplication__c IN:loanAppIdsNew AND ChargeCodeDesID__c = '500131'];
        }
        if(deleteLoanCharges  != null && deleteLoanCharges.size() > 0){
            delete deleteLoanCharges ;
        }   
    }
    public static void emiIncludingValueChangeHandler(List<LoanAppl__c> newList,Map<Id, LoanAppl__c> oldMap){
        Set<Id> loanAppIds = new Set<Id>();
        List<NACH__c> updateNachRcrds = new List<NACH__c>();

        for(LoanAppl__c loanApp : newList){
           if(loanApp.EMIIcludingInsurance__c != null && loanApp.EMIIcludingInsurance__c != oldMap.get(loanApp.Id).EMIIcludingInsurance__c){
               loanAppIds.add(loanApp.Id);
           }
       }
       if(!loanAppIds.isEmpty()){
           List<NACH__c> nachList =[SELECT Id,LoanAppl__c,LoanAppl__r.EMIIcludingInsurance__c FROM NACH__c WHERE LoanAppl__c IN :loanAppIds AND IsActive__c = true];
           if(!nachList.isEmpty()){
            for(NACH__c nach : nachList){
                String amtInWords = NumberToStringConverter.convertToWords((Integer) nach.LoanAppl__r.EMIIcludingInsurance__c);
                NACH__c nachRec = new NACH__c();
                nachRec.Id = nach.Id;
                nachRec.amt_rupees_words__c = amtInWords;
                updateNachRcrds.add(nachRec);
            }
           }
          if(!updateNachRcrds.isEmpty()){
            update updateNachRcrds;
          } 
       }
   }
}