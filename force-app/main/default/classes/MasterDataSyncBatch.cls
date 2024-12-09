global class MasterDataSyncBatch implements Database.Batchable<sobject>, Schedulable{
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
      	System.debug('start');
        
        return Database.getQueryLocator([Select Id,Identifier__c, SequenceNumber__c, SyncStatus__c, MasterDataType__c, Record__c,Async__c, ProcessImmediately__c, IsProcessed__c from MasterDataSync__c WHERE Async__c=True AND IsProcessed__c =False AND MasterDataType__c!=null]);
    }
    
    global void execute(Database.BatchableContext BC, List<MasterDataSync__c> masterDataSyncList) {
        try{
            if(!masterDataSyncList.isEmpty()){
                MasterDataSync.processMasterData(masterDataSyncList);
            }
        }
        catch(Exception ex){
            System.debug(ex.getMessage() + ' line ' + ex.getLineNumber());
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
     global void execute(SchedulableContext sc) {
        MasterDataSyncBatch batch = new MasterDataSyncBatch();
        Database.executeBatch(batch);
    }
    
    
}