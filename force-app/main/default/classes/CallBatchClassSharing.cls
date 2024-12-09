public class CallBatchClassSharing {
    @AuraEnabled
    public static void callBatch(Id loanId, string branchName){
        List<LoanAppl__c>loanList = [select id,BrchCode__c,
                                     Stage__c,SubStage__c,Product__c,OwnerId,
                                     RMSMName__c from LoanAppl__c 
                                     where Id =:loanId];
        system.debug('loanList:::::8'+loanList);
        system.debug('loanList::SIZE:: IS ::::'+loanList.size());
        Set<Id>loanIds = new Set<Id>();
        Set<String>bankIds = new Set<String>();
        for(LoanAppl__c loanApp : loanList){
            loanIds.add(loanApp.id);
        }
        system.debug('loanIds:::::15'+loanIds);
        system.debug('loanIds SIZE:::::IS::::'+loanIds.size());        
        BatchClassForLoanSharing reassign = new BatchClassForLoanSharing(loanIds,bankIds);
        ID batchprocessid = Database.executeBatch(reassign);
    }
}