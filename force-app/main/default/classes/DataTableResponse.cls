public class DataTableResponse {

    @AuraEnabled
        public List<DataTableColumns> lstDataTableColumns {get;set;}
        @AuraEnabled
        public List<sObject> lstDataTableData {get;set;}
        @AuraEnabled
        public String tableTitle {get;set;} 
    
    public DataTableResponse(List<DataTableColumns> lstDataTableColumns, List<sObject> lstDataTableData, String tableTitle)
        {
            this.lstDataTableColumns     = lstDataTableColumns;
            this.lstDataTableData = lstDataTableData;
            this.tableTitle      = tableTitle;          
        }
    
     public static DataTableResponse parse(String json) {
        return (DataTableResponse) System.JSON.deserialize(json, DataTableResponse.class );
    }
}