@isTest
public class IntMsgAfterUpdateTriggerHandlerTest {
@isTest
     static void intMsgUpdHandler(){
         LoanAppl__c loanApp=TestDataFactory.createLoanApplication(true);
        Applicant__c appl=TestDataFactory.createSingleApplicant(true,loanApp.Id);
        List<IntgMsg__c> oldIntgMsgData=TestDataFactory.createIntegrationMessage(true,appl.Id);
         List<IntgMsg__c> newIntgMsgData=TestDataFactory.createIntegrationMessage(true,appl.Id);
         
         List<IntgMsg__c> updNewIntgMsgData  = new List<IntgMsg__c>();
         for(IntgMsg__c intemes : newIntgMsgData){
             intemes.Status__c = 'Responded';
             updNewIntgMsgData.add(intemes);
         }
         
         oldIntgMsgData[0].Id =  updNewIntgMsgData[0].Id;
         Update oldIntgMsgData;
         
         IntMsgAfterUpdateTriggerHandler.afterUpdate(updNewIntgMsgData, oldIntgMsgData);
    }
}