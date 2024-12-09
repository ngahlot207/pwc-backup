public with sharing class SaveDataController {
    
    @AuraEnabled(cacheable=true)
    public static void saveData(String jsonData){
        
        List<DataWrapper> responseWrapper = new List<DataWrapper>();
        
        if(jsonData != null){ 
            responseWrapper = (List<DataWrapper>) JSON.deserialize(jsonData, List<DataWrapper>.class);
            system.debug('responseWrapper'+ responseWrapper[0]);
        }
        
       // SObject sobj = new SObject(); 
        
        for(DataWrapper res : responseWrapper){
            
            sObject up = (sObject) Type.forName(res.objApiName).newInstance();
            
            if(res.recordId == null){
                
            }
        }
    }  
}