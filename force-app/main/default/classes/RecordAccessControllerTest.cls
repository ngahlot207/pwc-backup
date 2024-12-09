@isTest
public class RecordAccessControllerTest{
    @isTest
    static void testGetAccess(){
        user u=TestDataFactory.UserData(true);
        user sup=TestDataFactory.supervisor(true);
        LoanAppl__c loanApp=New LoanAppl__c();
        loanApp.Stage__c = 'QDE';
        loanApp.BrchCode__c = 'HYC';
        loanApp.Product__c = 'Home Loan';
        loanApp.OwnerId = u.id;
        insert loanApp;
        try{
            RecordAccessController.getAccess(loanApp.Id);
            
        }catch(exception e){
            system.debug('Script-thrown exception'+ e.getMessage());
        }
    }
    @isTest
    static void testSubStage(){
        user u=TestDataFactory.UserData(true);
        user sup=TestDataFactory.supervisor(true);
        LoanAppl__c loanApp=New LoanAppl__c();
        loanApp.Stage__c = 'QDE';
        loanApp.BrchCode__c = 'HYC';
        loanApp.Product__c = 'Home Loan';
        loanApp.OwnerId = u.id;
        insert loanApp;
        try{
            RecordAccessController.getsubStage(loanApp.Id);
            
        }catch(exception e){
            system.debug('Script-thrown exception'+ e.getMessage());
        }
    }
}