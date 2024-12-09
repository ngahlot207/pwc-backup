/* ********************************************************
* Created By : Tahura Bayazid
* Created Date: 06-Feb-2024
* ********************************************************
*/

public without sharing class PDCChequeInsertion implements TriggerAction.AfterInsert,TriggerAction.AfterUpdate,TriggerAction.BeforeDelete {
    public static void afterInsert(List<PDC__c> newList) {
        if(!newList.isEmpty()){
        CreateCheque(newList);
        }
    }
    public static void afterUpdate(List<PDC__c> newList,List<PDC__c> oldList) {
        if(!newList.isEmpty()){
        UpdateCheque(newList,oldList);
        }
    }
    public static void beforeDelete(List<PDC__c> oldList) {
        if(!oldList.isEmpty()){
        DeleteCheque(oldList);
        }
    }
    
    
    public static void CreateCheque(List<PDC__c> newList) {    
        map<id,PDC__c> PDCMap = new map<id,PDC__c>(); 
        List<Cheque_Numbers__c> recordsToCreate = new List<Cheque_Numbers__c>();
        for(PDC__c p:newList){            
            PDCMap.put(p.id,p);
        }
        if(!PDCMap.isEmpty()){
        for(String Pid :PDCMap.keyset()){
            integer fromValue = Integer.valueOf(PDCMap.get(Pid).Cheque_Number_From__c);
            integer toValue = Integer.valueOf(PDCMap.get(Pid).Cheque_Number_To__c);

            for(Integer i = fromValue; i <= toValue; i++){
                Cheque_Numbers__c newRecord = new Cheque_Numbers__c();
                
                newRecord.Cheque_Number__c= formatCal(String.valueOf(i));                
                newRecord.PDC__c=Pid;
                newRecord.Loan_Application__c=PDCMap.get(Pid).Loan_Application__c;
                recordsToCreate.add(newRecord);
            }

        }
        if(!recordsToCreate.isEmpty()){
            insert recordsToCreate;
        }
        }
    }
	public static string formatCal(string i){
        string temp='000000'+i;
        string result =temp.right(6);
        system.debug('formatresult'+result);
        return result;
        
    }
    public static void UpdateCheque(list<PDC__c> newList,List<PDC__c> oldList){
        Map<Id, PDC__c> oldListMap = new Map<Id, PDC__c>(oldList);
        map<id,PDC__c> PDCMap = new map<id,PDC__c>();
        List<Cheque_Numbers__c> recordsToCreate = new List<Cheque_Numbers__c>();
        for(PDC__c p:newList ){
            if(p.Cheque_Number_From__c!=oldListMap.get(p.id).Cheque_Number_From__c ||
            p.Cheque_Number_To__c!=oldListMap.get(p.id).Cheque_Number_To__c){
                PDCMap.put(p.id,p);
                
            }
        }
		
        if(!PDCMap.isEmpty()){
        List<Cheque_Numbers__c> ChequeToDelete = [SELECT Id FROM Cheque_Numbers__c WHERE PDC__c in: PDCMap.keyset()];

        if (!ChequeToDelete.isEmpty()) {      
                delete ChequeToDelete;
        }

        for(String Pid :PDCMap.keyset()){
            integer fromValue = Integer.valueOf(PDCMap.get(Pid).Cheque_Number_From__c);
            integer toValue = Integer.valueOf(PDCMap.get(Pid).Cheque_Number_To__c);

            for(Integer i = fromValue; i <= toValue; i++){
                Cheque_Numbers__c newRecord = new Cheque_Numbers__c();
                newRecord.Cheque_Number__c=formatCal(String.valueOf(i));
                newRecord.PDC__c=Pid;
                newRecord.Loan_Application__c=PDCMap.get(Pid).Loan_Application__c;
                recordsToCreate.add(newRecord);
            }

        }
        if(!recordsToCreate.isEmpty()){
            insert recordsToCreate;
        }

    }   
    
    }
    public static void DeleteCheque(List<PDC__c> oldList) {
        Map<Id, PDC__c> oldListMap = new Map<Id, PDC__c>(oldList);
        map<id,PDC__c> PDCMap = new map<id,PDC__c>();
        List<Cheque_Numbers__c> recordsToCreate = new List<Cheque_Numbers__c>();
        for(PDC__c p:oldList ){            
                PDCMap.put(p.id,p);               
            
        }
        if(!PDCMap.isEmpty()){
        List<Cheque_Numbers__c> ChequeToDelete = [SELECT Id FROM Cheque_Numbers__c WHERE PDC__c in: PDCMap.keyset()];

        if (!ChequeToDelete.isEmpty()) {      
                delete ChequeToDelete;
        }

    }
}
}