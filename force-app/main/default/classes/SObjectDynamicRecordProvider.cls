public without sharing class SObjectDynamicRecordProvider {
    
    @AuraEnabled(cacheable=true)
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
                system.debug('query finally is getSobjectDatawithRelatedRecords'+ query);
                
                
                
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
            system.debug('error message is' + e.getMessage()+'stack'+e.getStackTraceString());
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
                        //system.debug('parent record id' + (Id)parentRecordDetails.get('Id'));
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
    
    @AuraEnabled (cacheable=true)
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
    public static ParentSobjctDataWrapper getSobjectDataNonCacheable(SobjectQueryParams params){  
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
    
    @AuraEnabled(cacheable=true)
    public static List<SobjctDataWrapper> getAllSobjectDatawithRelatedRecords(SobjectQueryParams params){
        
        List<SobjctDataWrapper> sobjWrpList = new List<SobjctDataWrapper>();
        SobjctDataWrapper wrapObj;
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
                List<SObject> sobjList =  Database.query(query);
                for(SObject record: sobjList){
                    wrapObj = new SobjctDataWrapper();
                    wrapObj.parentRecord = record;
                    if(params.ChildObjectRelName !=null){
                        wrapObj.ChildReords = record.getSObjects(params.ChildObjectRelName);
                    }
                    sobjWrpList.add(wrapObj);
                    
                }
                // system.debug('sobj ===> '  + sobj[0].getSObjects(params.ChildObjectRelName));
                /*List<SObject> childRecordsList = new List<SObject>(); 
if(sobj!= null && !sobj.isEmpty()){     
sobjWrp.parentRecord = sobj[0];
if(params.ChildObjectRelName !=null){
sobjWrp.ChildReords = sobj[0].getSObjects(params.ChildObjectRelName);
}

}*/
                
            }
        } catch (Exception e) {
            // Handle any exceptions here
            system.debug('error message is' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }  
        if(sobjWrpList != null){
            return sobjWrpList;
        }else{
            return null;
        }
    }
    
    @AuraEnabled
    Public static List<SobjctDataWrapper> getSobjectDataWithoutCacheable(SobjectQueryParams params){
        
        
        List<SobjctDataWrapper> sobjWrpList = new List<SobjctDataWrapper>();
        SobjctDataWrapper wrapObj;
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
                List<SObject> sobjList =  Database.query(query);
                for(SObject record: sobjList){
                    wrapObj = new SobjctDataWrapper();
                    wrapObj.parentRecord = record;
                    if(params.ChildObjectRelName !=null){
                        wrapObj.ChildReords = record.getSObjects(params.ChildObjectRelName);
                    }
                    sobjWrpList.add(wrapObj);
                    
                }
                // system.debug('sobj ===> '  + sobj[0].getSObjects(params.ChildObjectRelName));
                /*List<SObject> childRecordsList = new List<SObject>(); 
if(sobj!= null && !sobj.isEmpty()){     
sobjWrp.parentRecord = sobj[0];
if(params.ChildObjectRelName !=null){
sobjWrp.ChildReords = sobj[0].getSObjects(params.ChildObjectRelName);
}

}*/
                
            }
        } catch (Exception e) {
            // Handle any exceptions here
            system.debug('error message is' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }  
        if(sobjWrpList != null){
            return sobjWrpList;
        }else{
            return null;
        }
        
    }
    @AuraEnabled
    public static void deleteRecord(List<SObject> rcrds){
        try {
            if(rcrds != null && rcrds.size() > 0 ){
                delete rcrds;
            }
        }catch (Exception e) {
            system.debug('error message is' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        } 
    }
    
    @AuraEnabled
    public static List<SObject> upsertMultipleRecord(List<SObject> params){
        system.debug('params'+params);
        if(params != null && params.size() > 0 ){
            system.debug('params'+params);
            upsert params;
        }  
        if(params != null && params.size() > 0 ){
            return params;
        }else{
            return null;
        }
    }
    
    
    /*@AuraEnabled
public static void insertMultipleRecord(List<Applicant_Obligation_detail__c> params){
system.debug('params'+params);
if(params != null && params.size() > 0 ){
system.debug('params'+params);
insert params;
}  
} */
    // public static Void upsertMultipleParentsWithMultipleChilds(List<SobjectUpsertMultiData> upsertData){
    @AuraEnabled
    public static Void upsertMultipleParentsWithMultipleChilds(List<SobjectUpsertData> upsertData){
        system.debug('upsertData' + upsertData);
        SobjctDataWrapper sobjWrp = new SobjctDataWrapper();
        List<Sobject> parentObjList = new List<Sobject>();
        List<Sobject> childObjectlist = new List<Sobject>();
        try{
            system.debug('upsertData' + upsertData);
            
            
            
            if(upsertData != null ){
                
                for(SobjectUpsertData wrapObj : upsertData){
                    parentObjList.add(wrapObj.parentRecord);
                }
                if(!parentObjList.isEmpty()){
                    system.debug('parent list' +parentObjList);
                    upsert parentObjList;
                    
                    Integer i=0;
                    
                    for(SobjectUpsertData wrapObj : upsertData){
                        if(!wrapObj.ChildRecords.isEmpty()){
                            for(Sobject childObj : wrapObj.ChildRecords){
                                if(childObj.Id == null){  
                                    childObj.put(wrapObj.ParentFieldNameToUpdate, (Id)parentObjList[i].get('Id'));
                                }  
                                childObjectlist.add(childObj);
                            }
                        }
                        i++;
                    }
                    if(!childObjectlist.isEmpty()){
                        upsert childObjectlist;
                    }
                }
            }
        }catch(exception e){
            system.debug('error message is'+ e.getMessage() + 'Line Number ' + e.getLineNumber() + 'get trace' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }  
        
        
    }
    
    @AuraEnabled(cacheable=true)
    public static SobjctDataWrapper getSobjectDatawithFilterRelatedRecords(SobjectQueryParams params){
        
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
                    if (String.isNotBlank(params.queryCriteriaForChild)) {
                        
                        query += params.queryCriteriaForChild;
                    }
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
    public static List<SobjctDataWrapper> getSobjDtwithFltrRelatedRecordsWithoutCache(SobjectQueryParams params){
        
        List<SobjctDataWrapper> sobjWrpList = new List<SobjctDataWrapper>();
        SobjctDataWrapper wrapObj;
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
                    if (String.isNotBlank(params.queryCriteriaForChild)) {
                        
                        query += params.queryCriteriaForChild;
                    }
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
                for (SObject record : sobj) {
                    wrapObj = new SobjctDataWrapper();
                    wrapObj.parentRecord = record;
                    if (params.ChildObjectRelName != null) {
                        wrapObj.ChildReords = record.getSObjects(params.ChildObjectRelName);
                    }
                    sobjWrpList.add(wrapObj);
                }
                // system.debug('sobj ===> '  + sobj[0].getSObjects(params.ChildObjectRelName));
               /* List<SObject> childRecordsList = new List<SObject>(); 
                if(sobj!= null && !sobj.isEmpty()){     
                    sobjWrp.parentRecord = sobj[0];
                    if(params.ChildObjectRelName !=null){
                        sobjWrp.ChildReords = sobj[0].getSObjects(params.ChildObjectRelName);
                    }
                    
                }*/
                
            }
        } catch (Exception e) {
            // Handle any exceptions here
            system.debug('error message is' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }  
        if(sobjWrpList != null){
            return sobjWrpList;
        }else{
            return null;
        }
    }
    @AuraEnabled
    public static SobjctDataWrapper getFilterRelRecordsWithOutCache(SobjectQueryParams params){
        
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
                    if (String.isNotBlank(params.queryCriteriaForChild)) {
                        
                        query += params.queryCriteriaForChild;
                    }
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
        @AuraEnabled
        public String queryCriteriaForChild { get; set; } 
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
    /* public class SobjectUpsertMultiData {
@AuraEnabled
public list<SObject> parentRecord { get; set; }
@AuraEnabled
public List<SObject> ChildRecords { get; set; }  
@AuraEnabled
public String ParentFieldNameToUpdate { get; set; }
}*/
    
    public class SobjectUpsertData {
        @AuraEnabled
        public SObject parentRecord { get; set; }
        @AuraEnabled
        public List<SObject> ChildRecords { get; set; }  
        @AuraEnabled
        public String ParentFieldNameToUpdate { get; set; }
    }
}