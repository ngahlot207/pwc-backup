public class RetriggerAPIsValueChangeOnApplAsset implements TriggerAction.AfterInsert, TriggerAction.AfterUpdate, TriggerAction.AfterDelete{

     public static void afterInsert(List<ApplAsset__c> newList) {
        RetriggerUpsertHandler.InputData inputData = new RetriggerUpsertHandler.InputData();
        inputData.newList = newList;
        inputData.oldList = null;
        inputData.modificationType = 'Insert';
        inputData.objectApiName = 'ApplAsset__c';
        inputData.applFieldAPIName = 'Appl__c';
        inputData.loanFieldAPIName = 'LoanAppln__c';
        RetriggerUpsertHandler.createRetriggerRecords(inputData);
    }
    
    public static void afterUpdate(List<ApplAsset__c> newList, List<ApplAsset__c> oldList) {
        RetriggerUpsertHandler.InputData inputData = new RetriggerUpsertHandler.InputData();
        inputData.newList = newList;
        inputData.oldList = oldList;
        inputData.modificationType = 'Update';
        inputData.objectApiName = 'ApplAsset__c';
        inputData.applFieldAPIName = 'Appl__c';
        inputData.loanFieldAPIName = 'LoanAppln__c';
        RetriggerUpsertHandler.createRetriggerRecords(inputData);
    }
    
    public static void afterDelete(List<ApplAsset__c> newList) {
        RetriggerUpsertHandler.InputData inputData = new RetriggerUpsertHandler.InputData();
        inputData.newList = newList;
        inputData.oldList = null;
        inputData.modificationType = 'Delete';
        inputData.objectApiName = 'ApplAsset__c';
        inputData.applFieldAPIName = 'Appl__c';
        inputData.loanFieldAPIName = 'LoanAppln__c';
        RetriggerUpsertHandler.createRetriggerRecords(inputData);
    }
}