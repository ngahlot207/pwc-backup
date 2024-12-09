@isTest
public class LoanTATHandlerTest {
    @isTest
    static void testAfterUpdate(){
       
        List<LoanAppl__c> oldLoanList= new List<LoanAppl__c>();
        List<LoanAppl__c> newLoanList= new List<LoanAppl__c>();
        LoanAppl__c oldLoanApp=TestDataFactory.createLoanApplication(true);
        id userId=UserInfo.getUserId();
        Lead leadRec=TestDataFactory.LeadData(true,userId);
        oldLoanList.add(oldLoanApp);
        system.debug('oldLoanApp.Id '+oldLoanApp.stage__c);
        LoanAppl__c updateOldRec=new LoanAppl__c(
        	id=oldLoanApp.Id,
        	stage__c = 'DDE',
            Status__c='In Progress',
            SubStage__c='CPA DATA ENTRY',
            Hold_Reason__c='Customer out of station/ not contactable',
            OwnerId=UserInfo.getUserId(),
            Lead__c=leadRec.Id
        );
        TriggerBase.bypass('LoanAppl__c');
        update updateOldRec;
        TriggerBase.clearBypass('LoanAppl__c');
        
        system.debug('oldLoanApp.Id'+updateOldRec.stage__c);
        newLoanList.add(updateOldRec);
        LoanTat__c loanTatRec = new LoanTat__c(
        	LoanApplication__c= oldLoanApp.Id,
            EntryTime__c =system.now()
        );
        insert loanTatRec;
        LoanTATHandler.afterUpdate(newLoanList,oldLoanList);
        
    }
}