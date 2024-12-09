public class RetriggerAPIsValueChangeOnPd implements TriggerAction.AfterInsert, TriggerAction.AfterUpdate, TriggerAction.AfterDelete{

      public static void afterInsert(List<PD__c> newList) {
        RetriggerUpsertHandler.InputData inputData = new RetriggerUpsertHandler.InputData();
        inputData.newList = newList;
        inputData.oldList = null;
        inputData.modificationType = 'Insert';
        inputData.objectApiName = 'PD__c';
        inputData.applFieldAPIName = 'Appl__c';
        inputData.loanFieldAPIName = 'LoanAppl__c';
        RetriggerUpsertHandler.createRetriggerRecords(inputData);
    }
    
    public static void afterUpdate(List<PD__c> newList, List<PD__c> oldList) {
        RetriggerUpsertHandler.InputData inputData = new RetriggerUpsertHandler.InputData();
        inputData.newList = newList;
        inputData.oldList = oldList;
        inputData.modificationType = 'Update';
        inputData.objectApiName = 'PD__c';
        inputData.applFieldAPIName = 'Appl__c';
        inputData.loanFieldAPIName = 'LoanAppl__c';
        RetriggerUpsertHandler.createRetriggerRecords(inputData);
    }
    
    public static void afterDelete(List<PD__c> newList) {
        RetriggerUpsertHandler.InputData inputData = new RetriggerUpsertHandler.InputData();
        inputData.newList = newList;
        inputData.oldList = null;
        inputData.modificationType = 'Delete';
        inputData.objectApiName = 'PD__c';
        inputData.applFieldAPIName = 'Appl__c';
        inputData.loanFieldAPIName = 'LoanAppl__c';
        RetriggerUpsertHandler.createRetriggerRecords(inputData);
    }
}