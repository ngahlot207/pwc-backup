@isTest
public class BatchClassForLoanSharingTest {
    @isTest
    static void testBatch(){
        set<Id> loanApps = new set<Id>();
        set<string> branchCodes = new set<string>();
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        loanApps.add(loanApp.Id);        
        map<Id,LoanAppl__c> loanIds = new map<Id,LoanAppl__c>([select id,BrchCode__c,Stage__c,SubStage__c,Product__c,OwnerId,RMSMName__c from LoanAppl__c where id in :loanApps]);
        BatchClassForLoanSharing bt = new BatchClassForLoanSharing(loanIds.keySet(),branchCodes);
        Database.executeBatch(bt,10);
        
    }
    @isTest
    static void testBatch1(){
        set<Id> loanApps = new set<Id>();
        set<Id> loanApps1 = new set<Id>();
        set<string> branchCodes = new set<string>();
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        loanApps.add(loanApp.Id);     
        system.debug('loanApp:::::' + loanApp);
        map<Id,LoanAppl__c> loanIds = new map<Id,LoanAppl__c>([select id,BrchCode__c,Stage__c,SubStage__c,Product__c,OwnerId,RMSMName__c from LoanAppl__c where id in :loanApps AND BrchCode__c != null]);
        for(LoanAppl__c ln : loanIds.values()){
            branchCodes.add(ln.BrchCode__c);
        }
        //branchCodes.add(loanApp.BrchCode__c);
        system.debug('branchCodes:::::' + branchCodes+'Size::::'+branchCodes.size()+ 'loanApps1 Size'+loanApps1.size());
        BatchClassForLoanSharing bt1 = new BatchClassForLoanSharing(loanApps1,branchCodes);
        Database.executeBatch(bt1,10);
        
    }
}