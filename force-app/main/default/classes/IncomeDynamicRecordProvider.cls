public without sharing class IncomeDynamicRecordProvider {
    
    @AuraEnabled
    public static SobjctDataWrapper getSobjectDatawithRelatedRecords(SobjectQueryParams params){
        
        SobjctDataWrapper sobjWrp = new SobjctDataWrapper();
        system.debug('params'+params);
        system.debug('childRelationshipName'+params.ChildObjectRelName);
        try {
            if(params != null ){
                
                // Building the dynamic SOQL query
                String query = 'SELECT ';
                
                // Add parent object fields to the query
                query += String.join(params.parentObjFields, ',');
                
                if(String.isNotBlank(params.ChildObjectRelName)){
                    
                    query += ', (SELECT ' ;
                    
                    // Add child object fields to the query
                    query += String.join(params.childObjFields, ',');    
                    
                    // Remove the trailing comma
                    query = query.removeEnd(',');
                    
                    query += ' FROM ' + params.ChildObjectRelName;
                    query += ')';
                }else{      
                    // Remove the trailing comma
                    query = query.removeEnd(','); 
                }
                
                
                query += '  FROM '+ params.ParentObjectName ;
                
                if(String.isNotBlank(params.queryCriteria)){
                    
                    query += params.queryCriteria;
                    
                }
                
                // + ' WHERE Id IN (SELECT AccountId FROM Opportunity)'
                system.debug('query finally is '+ query);
                
                
                
                // Execute the query
                List<SObject> sobj =  Database.query(query);
                // system.debug('sobj ===> '  + sobj[0].getSObjects(params.ChildObjectRelName));
                List<SObject> childRecordsList = new List<SObject>(); 
                if(sobj!= null && !sobj.isEmpty()){     
                    sobjWrp.parentRecord = sobj[0];
                    if(params.ChildObjectRelName !=null){
                        sobjWrp.ChildReords = sobj[0].getSObjects(params.ChildObjectRelName);
                    }
                    
                }
                
            }
        } catch (Exception e) {
            // Handle any exceptions here
            system.debug('error message is' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }  
        if(sobjWrp != null){
            return sobjWrp;
        }else{
            return null;
        }
    }
    
    @AuraEnabled
    public static SobjctDataWrapper upsertSobjDataWIthRelatedChilds(SobjectUpsertData upsertData){
        system.debug('upsertData' + upsertData);
        SobjctDataWrapper sobjWrp = new SobjctDataWrapper();
        try{
            system.debug('upsertData' + upsertData);
            
            String ParentFieldApiNameToUpdate = upsertData.ParentFieldNameToUpdate != null ? upsertData.ParentFieldNameToUpdate : null;   
            
            if(upsertData != null ){
                
                SObject parentRecordDetails = upsertData.parentRecord != null ? upsertData.parentRecord : null ;
                
                // system.debug('parent record id' + (Id)parentRecordDetails.get('Id')); 
                if(parentRecordDetails != null ){
                    
                    upsert parentRecordDetails;
                    sobjWrp.parentRecord = parentRecordDetails;
                }
                
                if(upsertData.ChildRecords != null  ){
                    
                    for(SObject record : upsertData.ChildRecords)  {          
                        //record.ParentFieldApiNameToUpdate = (Id)parentRecordDetails.get('Id');
                        system.debug('parent record id' + (Id)parentRecordDetails.get('Id'));
                        Object childRecordId = record.get('Id');
                        system.debug('childRecordId' +childRecordId);
                        if(childRecordId == null){  
                            record.put(ParentFieldApiNameToUpdate, (Id)parentRecordDetails.get('Id'));
                        }     
                    }
                    
                    List<SObject> childRecordDetails = upsertData.ChildRecords;
                    system.debug('childRecordDetails'+childRecordDetails);
                    
                    if(!childRecordDetails.isEmpty()){
                        
                        upsert childRecordDetails;
                        sobjWrp.ChildReords = childRecordDetails;
                    }
                    
                }  
            }
        }catch(exception e){
            system.debug('error message is'+ e.getMessage() + 'Line Number ' + e.getLineNumber() + 'get trace' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }  
        system.debug('parentRecord'+sobjWrp);
        return sobjWrp;
    }
    
    @AuraEnabled
    public static ParentSobjctDataWrapper getSobjectData(SobjectQueryParams params){  
        ParentSobjctDataWrapper sobjWrp = new ParentSobjctDataWrapper();
        system.debug('params'+params);
        try {
            if(params != null ){
                
                // Building the dynamic SOQL query
                String query = 'SELECT ';
                
                // Add parent object fields to the query
                query += String.join(params.parentObjFields, ',');
                query = query.removeEnd(','); 
                
                query += '  FROM '+ params.ParentObjectName ;
                
                if(String.isNotBlank(params.queryCriteria)){    
                    query += params.queryCriteria; 
                }
                system.debug('query finally is '+ query);
                // Execute the query
                List<SObject> sobj =  Database.query(query);
                
                if(sobj!= null && !sobj.isEmpty()){     
                    sobjWrp.parentRecords = sobj;   
                }   
            }
        } catch (Exception e) {
            // Handle any exceptions here
            system.debug('error message is' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }  
        if(sobjWrp != null){
            return sobjWrp;
        }else{
            return null;
        }
    }
    
    @AuraEnabled
    public static ParentSobjctDataWrapper getAssetPropType(SobjectQueryParams params){  
        ParentSobjctDataWrapper sobjWrp = new ParentSobjctDataWrapper();
        system.debug('params'+params);
        try {
            if(params != null ){
                // Building the dynamic SOQL query
                String query = 'SELECT ';
                // Add parent object fields to the query
                query += String.join(params.parentObjFields, ',');
                query = query.removeEnd(',');
                query += '  FROM '+ params.ParentObjectName ;
                if(String.isNotBlank(params.queryCriteria)){    
                    query += params.queryCriteria;
                }
                system.debug('query finally is '+ query);
                // Execute the query
                List<SObject> sobj =  Database.query(query);
                if(sobj!= null && !sobj.isEmpty()){    
                    sobjWrp.parentRecords = sobj;  
                }  
            }
        } catch (Exception e) {
            // Handle any exceptions here
            system.debug('error message is' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }  
        
        if(sobjWrp != null){
            return sobjWrp;
        }else{
            return null;
        }
    }
    
    
    public class SobjectQueryParams {
        @AuraEnabled
        public String ParentObjectName { get; set; }
        @AuraEnabled
        public String ChildObjectRelName { get; set; }
        @AuraEnabled
        public List<String> parentObjFields { get; set; }
        @AuraEnabled
        public List<String> childObjFields { get; set; }
        @AuraEnabled
        public String queryCriteria { get; set; }    
    }
    
    public class SobjctDataWrapper {
        @AuraEnabled
        public SObject parentRecord { get; set; }
        @AuraEnabled
        public List<SObject> ChildReords { get; set; }     
    }
    
    public class ParentSobjctDataWrapper {
        @AuraEnabled
        public List<SObject> parentRecords { get; set; }    
    }
    public class SobjectUpsertData {
        @AuraEnabled
        public SObject parentRecord { get; set; }
        @AuraEnabled
        public List<SObject> ChildRecords { get; set; }  
        @AuraEnabled
        public String ParentFieldNameToUpdate { get; set; }
    }
    
    
}