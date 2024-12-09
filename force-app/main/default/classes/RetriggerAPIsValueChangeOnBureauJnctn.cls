public class RetriggerAPIsValueChangeOnBureauJnctn implements TriggerAction.AfterInsert, TriggerAction.AfterUpdate, TriggerAction.AfterDelete{

     public static void afterInsert(List<BureauRespDtl__c> newList) {
        RetriggerUpsertHandler.InputData inputData = new RetriggerUpsertHandler.InputData();
        inputData.newList = newList;
        inputData.oldList = null;
        inputData.modificationType = 'Insert';
        inputData.objectApiName = 'BureauRespDtl__c';
        inputData.applFieldAPIName = 'Applicant__c';
        inputData.loanFieldAPIName = 'LoanApplication__c';
        RetriggerUpsertHandler.createRetriggerRecords(inputData);
    }
    
    public static void afterUpdate(List<BureauRespDtl__c> newList, List<BureauRespDtl__c> oldList) {
        RetriggerUpsertHandler.InputData inputData = new RetriggerUpsertHandler.InputData();
        inputData.newList = newList;
        inputData.oldList = oldList;
        inputData.modificationType = 'Update';
        inputData.objectApiName = 'BureauRespDtl__c';
        inputData.applFieldAPIName = 'Applicant__c';
        inputData.loanFieldAPIName = 'LoanApplication__c';
        RetriggerUpsertHandler.createRetriggerRecords(inputData);
    }
    
    public static void afterDelete(List<BureauRespDtl__c> newList) {
        RetriggerUpsertHandler.InputData inputData = new RetriggerUpsertHandler.InputData();
        inputData.newList = newList;
        inputData.oldList = null;
        inputData.modificationType = 'Delete';
        inputData.objectApiName = 'BureauRespDtl__c';
        inputData.applFieldAPIName = 'Applicant__c';
        inputData.loanFieldAPIName = 'LoanApplication__c';
        RetriggerUpsertHandler.createRetriggerRecords(inputData);
    }
}