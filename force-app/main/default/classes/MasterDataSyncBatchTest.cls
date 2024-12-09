@isTest
public class MasterDataSyncBatchTest {
    
    @isTest
    Public static void testGenerateMethod(){
        
        MasterDataSync__c mds=new MasterDataSync__c();
        mds.Identifier__c='47012275';
        mds.MasterDataType__c='DSAMASTER';
        mds.Record__c='{"PRODUCT_CODE":"LAP","DSA_NAME":"VALUE LINE FINANCIAL SERVICES","BROKERID":"4","BRANCH":"DELHI","AUTHID":"FEDM","ACTIVE_STATUS":"I"}';
        mds.SequenceNumber__c=1;
        mds.SyncStatus__c='Failed';
        mds.Async__c=true;
        mds.ProcessImmediately__c=false;
        mds.IsProcessed__c=False;
        insert mds;
        
        
        List<MasterDataSync__c> masterdatalist = new List<MasterDataSync__c>{mds};
        
        Test.Starttest();
        MasterDataSyncBatch batch = new MasterDataSyncBatch();
        batch.execute(null);
       // Database.executeBatch(batch);
        Test.Stoptest();
            
        
        
    }

}