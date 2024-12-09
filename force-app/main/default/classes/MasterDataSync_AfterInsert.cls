public class MasterDataSync_AfterInsert implements TriggerAction.AfterInsert{
    public static void AfterInsert(List<MasterDataSync__c> newList){
        List<MasterDataSync__c> masterDataSyncList = new List<MasterDataSync__c>();
        for (MasterDataSync__c masterData : newList) {
            if(!masterData.Async__c){
                masterDataSyncList.add(masterData);
            }
        }
        if(!masterDataSyncList.isEmpty()){
            MasterDataSync.processMasterData(masterDataSyncList);
        }
    }
}