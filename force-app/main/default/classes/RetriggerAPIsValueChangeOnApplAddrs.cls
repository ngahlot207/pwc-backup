public class RetriggerAPIsValueChangeOnApplAddrs implements TriggerAction.AfterInsert, TriggerAction.AfterUpdate, TriggerAction.AfterDelete{
    
    public static void afterInsert(List<ApplAddr__c> newList) {
        RetriggerUpsertHandler.InputData inputData = new RetriggerUpsertHandler.InputData();
        inputData.newList = newList;
        inputData.oldList = null;
        inputData.modificationType = 'Insert';
        inputData.objectApiName = 'ApplAddr__c';
        inputData.applFieldAPIName = 'Applicant__c';
        inputData.loanFieldAPIName = 'LoanAppl__c';
        RetriggerUpsertHandler.createRetriggerRecords(inputData);
    }
    
    public static void afterUpdate(List<ApplAddr__c> newList, List<ApplAddr__c> oldList) {
        List<ApplAddr__c> newListData = new List<ApplAddr__c>();
        for(ApplAddr__c apAddrs : newList){
            if(apAddrs.AddrTyp__c == 'Residence Address' || apAddrs.AddrTyp__c == 'Office Address' || apAddrs.AddrTyp__c == 'Principal place for business' || apAddrs.AddrTyp__c == 'Residence Cum office'){
                newListData.add(apAddrs);
            }
        }
        
        if(newListData != null && newListData.size() > 0){
            RetriggerUpsertHandler.InputData inputData = new RetriggerUpsertHandler.InputData();
            inputData.newList = newListData;
            inputData.oldList = oldList;
            inputData.modificationType = 'Update';
            inputData.objectApiName = 'ApplAddr__c';
            inputData.applFieldAPIName = 'Applicant__c';
            inputData.loanFieldAPIName = 'LoanAppl__c';
            RetriggerUpsertHandler.createRetriggerRecords(inputData);
        }   
    }
    
    public static void afterDelete(List<ApplAddr__c> newList) {
        RetriggerUpsertHandler.InputData inputData = new RetriggerUpsertHandler.InputData();
        inputData.newList = newList;
        inputData.oldList = null;
        inputData.modificationType = 'Delete';
        inputData.objectApiName = 'ApplAddr__c';
        inputData.applFieldAPIName = 'Applicant__c';
        inputData.loanFieldAPIName = 'LoanAppl__c';
        RetriggerUpsertHandler.createRetriggerRecords(inputData);
    }
}