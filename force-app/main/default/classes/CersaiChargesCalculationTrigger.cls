public class CersaiChargesCalculationTrigger implements TriggerAction.AfterInsert,TriggerAction.AfterDelete {
    public static void afterInsert(List<ApplAsset__c> newList) {
        if(!newList.isEmpty()){
            CersaiChargesCalculationTriggerHandler.cersaiCalOnInsert(newList);
        }
    }
    public static void afterDelete(List<ApplAsset__c> oldList) {
        if(!oldList.isEmpty()){
            CersaiChargesCalculationTriggerHandler.cersaiCalOnDelete(oldList);
        }
    }
}