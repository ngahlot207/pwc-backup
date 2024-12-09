public with sharing class DynamicLWCDataTableController {
    
    @AuraEnabled
    public static DataTableResponse getWrapperOfSObjectFieldColumnActionValues(RequiredParams params)
    {
        system.debug('param  :::' + params);
        system.debug('param  :::' + params.query);
        List<QueryParamWrapp> mapData = params.queryParams;
        List<DataTableColumns> lstDataColumns = params.columnsData;
        String qry = params.query;
        Map<String,Object> paramValues = new Map<String,Object>();
        if(mapData != null && mapData.size() > 0){
            for(QueryParamWrapp que : mapData){
                paramValues.put(que.key,que.value);
            }
        }
        system.debug('paramValues'+paramValues);
        List<SObject> lstDataTableData                   = new List<SObject>();
        List<string> columnList                          = new List<string>();
        List<string> fieldAPINameList                    = new List<string>();
        system.debug('col::' + lstDataColumns); 
        List<sObject> results = new  List<sObject>();
        if(paramValues.size() > 0 ){
            results = 
                Database.queryWithBinds(params.query,
                                        paramValues, 
                                        AccessLevel.USER_MODE);
            
        }else{
            results = Database.query(params.query);
        }
        
        system.debug('lstDataTableData :::' + results);
        DataTableResponse finalWrapper   = new DataTableResponse();
        finalWrapper.tableTitle          = params.tableTitle;
        finalWrapper.lstDataTableColumns = lstDataColumns;
        finalWrapper.lstDataTableData    = results;
        system.debug('finalWrapper:::::::' + finalWrapper);
        return finalWrapper;
    }
    
    public class RequiredParams {
        @AuraEnabled
        public List<DataTableColumns> columnsData {get;set;}
        @AuraEnabled
        public List<QueryParamWrapp> queryParams {get;set;}
        @AuraEnabled
        public String query {get;set;}
        @AuraEnabled
        public String tableTitle {get;set;}
    }
    public class DataTableColumns {
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled       
        public String fieldName {get;set;}
        @AuraEnabled
        public String type {get;set;}
        @AuraEnabled
        public boolean editable {get;set;}
    }
    public class  QueryParamWrapp {
        @AuraEnabled
        public String key {get;set;}
        @AuraEnabled
        public Object value {get;set;}
    }
    public class DataTableResponse {
        @AuraEnabled
        public List<DataTableColumns> lstDataTableColumns {get;set;}
        @AuraEnabled
        public List<sObject> lstDataTableData {get;set;}
        @AuraEnabled
        public String tableTitle {get;set;}       
    }  
}