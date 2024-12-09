public class CustomFormController {
    @AuraEnabled
    public static RecordFromData getCustomData(string recordId, string config){
        try{
        system.debug('inside recordId>>>>'+config);
      
       // List<NewAccountPOC__mdt> customFormData =[SELECT Label, Id, ScreenConfig__c FROM NewAccountPOC__mdt WHERE 
         //                                         IsActive__c=true  WITH SECURITY_ENFORCED];
        List<sObject> sobjList = new List<sObject>();
        if(recordId != null && recordId!='' && config != null ){
            system.debug('inside if condition>>>>');
            Map<String, Object> configMap = new Map<String, Object>();
            configMap = (Map<String, Object>) JSON.deserializeUntyped(config);
            
            string query = (String)configMap.get('query');
            system.debug('inside query>>>>'+query);
            Map<String,Object> parameters = new Map<String,Object>{'recordId'=>recordId};
                sobjList =database.queryWithBinds(query,parameters,AccessLevel.USER_MODE);
            system.debug('inside if sobjList>>>>'+sobjList);
        }
        
        string  josondata = JSON.serialize(config);
        system.debug('inside if josondata>>>>'+josondata);
        RecordFromData recordConfigData = new RecordFromData();
        recordConfigData.recordConfig = config;
        if(!sobjList.isEmpty()){
            system.debug('inside if SOBJECT LIST IS NOT EMPTY>>>>');
            recordConfigData.recordData =sobjList[0];  
        }
        
        system.debug('recordConfigData>>>>'+recordConfigData);
        return recordConfigData;
        }
        catch(exception e){
            system.debug('exception:::::::'+e.getMessage()+e.getLineNumber());
           throw new AuraHandledException('message' + e.getMessage()+'  line no ::'+ e.getLineNumber());
        }
    }
    
    
    @AuraEnabled
    public static String mapAndInsertData(Map<String, String> dataMap,String objname) {
        system.debug('sobject objname dynamic>>'+objname);
        //   system.debug('currentrecordId>>>'+currentrecordId);
        string t = objname;
        /* Call global describe to get the map of string to token. */
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        
        /* Get the token for the sobject based on the type. */
        Schema.SObjectType st = gd.get(t);
        system.debug('sobject objname dynamic>>st'+st);
        System.assert(st != null,'Type provided: "' + t + '" doesnt map to an sobject token in this org.');
        
        /* Instantiate the sobject from the token. */
        Sobject record = st.newSobject();
        system.debug('sobject instance dynamic>>'+record);
        
        
        try{
            //  Contact record = new Contact();
            System.debug('record>>>>>>>'+record);
            //  Schema.SObjectType objectType = Contact.sObjectType;
            Schema.DescribeSObjectResult objectDescribe = st.getDescribe();
            System.debug('objectDescribe>>>>>>>'+objectDescribe);
            Map<String, Schema.SObjectField> fieldsMap = objectDescribe.fields.getMap();
            system.debug('fieldsMap:::::::'+fieldsMap);
            for (String fieldName : dataMap.keySet()) {
                String fieldValue = dataMap.get(fieldName);
                
                if (fieldsMap.containsKey(fieldName)) {
                    SObjectField field = fieldsMap.get(fieldName);
                    
                    system.debug('field.getDescribe().getType()'+field.getDescribe().getType());
                    //record.put(field, fieldValue);
                    if (field.getDescribe().getType() == Schema.DisplayType.String) {
                        system.debug('field.getDescribe().getType()'+fieldValue);
                        record.put(field, fieldValue);
                    }   
                    
                    // For checking valid email
                    else if (field.getDescribe().getType() == Schema.DisplayType.email) {
                        
                        record.put(field, fieldValue);
                    }
                    
                    //For checking Picklist value 
                    else if (field.getDescribe().getType() == Schema.DisplayType.Picklist) {
                        
                        Schema.PicklistEntry[] picklistValues = field.getDescribe().getPicklistValues();
                        for (Schema.PicklistEntry picklistValue : picklistValues) {
                            if (picklistValue.getValue().equalsIgnoreCase(fieldValue)) {
                                record.put(field, fieldValue);
                                break;
                            }
                        }
                    }
                    //For checking boolean value       
                    else if (fieldValue.equalsIgnoreCase('true') || fieldValue.equalsIgnoreCase('false')) {
                        Boolean fieldBooleanValue = Boolean.valueOf(fieldValue);
                        record.put(field, fieldBooleanValue);
                    }
                    //For checking date
                    else if (field.getDescribe().getType() == Schema.DisplayType.date) {
                        system.debug('date::::::'+field.getDescribe().getType()+':::::::::'+Schema.DisplayType.date);
                        Date fieldDateValue = Date.valueOf(fieldValue);
                        record.put(field, fieldDateValue);
                        
                    }
                    else if (field.getDescribe().getType() == Schema.DisplayType.Id) {
                        
                        record.put(field, fieldValue);
                    }else if (field.getDescribe().getType() == Schema.DisplayType.datetime) {
                        
                        Datetime fieldDateValue = Date.valueOf(fieldValue);
                        record.put(field, fieldDateValue);
                        
                    }else if (field.getDescribe().getType() == Schema.DisplayType.url) {
                        system.debug('URL::::::'+field.getDescribe().getType()+':::::::::'+Schema.DisplayType.url);
                        record.put(field, fieldValue);
                        
                    }else if (field.getDescribe().getType() == Schema.DisplayType.time) {
                        system.debug('TIME::::::'+field.getDescribe().getType()+':::::::::'+Schema.DisplayType.time);
                       
                        String[] strTimeSplit = fieldValue.split(':');
                        Time timeChange = Time.newInstance( Integer.valueOf(strTimeSplit[0]) //hour
                                                           ,Integer.valueOf(strTimeSplit[1]) //min
                                                           ,0                                //sec
                                                           ,0); 
                      
                        record.put(field, timeChange);
                        
                    }else if (field.getDescribe().getType() == Schema.DisplayType.phone) {
                        system.debug('URL::::::'+field.getDescribe().getType()+':::::::::'+Schema.DisplayType.url);
                        record.put(field, fieldValue);
                        
                    }else if (field.getDescribe().getType() == Schema.DisplayType.reference) {
                        
                        record.put(field, fieldValue);
                    }
                }
                
            }
            
            upsert record;
            
            system.debug('inserted record id>>'+record.id);
            return record.id;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
            
        }
    }
    
    public class RecordFromData{
        @AuraEnabled 
        public string recordConfig{get;set;}
        @AuraEnabled 
        public sObject recordData{get;set;}
    }
}