public class SharePointAPIIntegrationBatch implements Database.Batchable<sObject>,Database.AllowsCallouts, Schedulable {

    public Database.QueryLocator start(Database.BatchableContext BC) {
        
        return Database.getQueryLocator([SELECT Id,Name,Finnone_Loan_Number__c FROM LoanAppl__c WHERE Stage__c = 'Disbursed' OR SharePointFolderStatus__c <> 'Success']); // Id = 'a08C4000008YsEKIA0'
    
    }
    
    public void execute(Database.BatchableContext BC, List<LoanAppl__c> scope) {
        
        try{
            if(!scope.isEmpty()){
                List<Sobject> updateSObjectList =new List<Sobject>();
                //List<Sobject> insertSObjectList = new List<Sobject>();
                for(LoanAppl__c loanApp : scope){
                    SObject recordToUpdate = SharePointAPI.createFolder(loanApp.Name, new LoanAppl__c(Id = loanApp.Id));
                    /*if(recordToUpdate.get('SharePointFolderStatus__c') == 'Success'){
                        //SharePointAPI.createFiles(loanApp.Id);
                        List<Sobject> createFiles = SharePointAPI.createFiles(loanApp.Id);
                        if(createFiles!=null && !createFiles.isEmpty()){
                            insertSObjectList.addAll(createFiles);
                        }
                    }*/
                    updateSObjectList.add(recordToUpdate);
                }
                    
                system.debug('updateSObjectList:' + updateSObjectList.size());    
                //system.debug('insertSObjectList:' + insertSObjectList.size());    
                if(!updateSObjectList.isEmpty()){
                    update updateSObjectList;
                }
                /*if(!insertSObjectList.isEmpty()){
                    insert insertSObjectList;
                }*/
                
            }            
        }
        catch(Exception ex){
            GlobalUtility.logMessage('Error', 'SharePointAPIIntegrationBatch', 'execute', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        
    }
    
    public void execute(SchedulableContext sc) {
        SharePointAPIIntegrationBatch batch = new SharePointAPIIntegrationBatch();
        Database.executeBatch(batch,50);
    }
    public void finish(Database.BatchableContext BC) {
    }
}