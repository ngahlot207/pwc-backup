public class BatchClassForLoanSharing implements Database.Batchable<sObject> {
    public set<Id> loanAppIds = new Set<Id>();
    public set<string> branchCodes = new Set<String>();
    public BatchClassForLoanSharing(set<Id> loanIds,set<string> branchCodes) {
        
        this.loanAppIds.addall(loanIds);
        this.branchCodes.addall(branchCodes);        
    }
    public Database.QueryLocator start(Database.BatchableContext BC) {        
        if (loanAppIds.size() > 0) {
            return Database.getQueryLocator(
                'select id,BrchCode__c,Stage__c,SubStage__c,Product__c,OwnerId,RMSMName__c,CPA_User__c,NDCType__c from LoanAppl__c where Id IN:loanAppIds'
            );
        }else if(branchCodes.size()>0){
            return Database.getQueryLocator(
                'select id,BrchCode__c,Stage__c,SubStage__c,Product__c,OwnerId,RMSMName__c,CPA_User__c,NDCType__c from LoanAppl__c where BrchCode__c IN:branchCodes'
            );
        } else {
            return Database.getQueryLocator(
                'select id,BrchCode__c,Stage__c,SubStage__c,Product__c,OwnerId,RMSMName__c,CPA_User__c,NDCType__c from LoanAppl__c'
            );
        }
        
    }
    
    public void execute(Database.BatchableContext BC, List<LoanAppl__c> scope) {
        system.debug('scope:::::' + scope);
        CreateLoanTeamHandler.createLoanTeam(scope);
    }
    public void finish(Database.BatchableContext BC) {
    }
}