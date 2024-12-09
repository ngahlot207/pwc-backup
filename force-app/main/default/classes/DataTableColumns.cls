public class DataTableColumns {

    @AuraEnabled
        public String label {get;set;}
        @AuraEnabled       
        public String fieldName {get;set;}
        @AuraEnabled
        public String type {get;set;}
        
        public DataTableColumns(String label, String fieldName, String type)
        {
            this.label     = label;
            this.fieldName = fieldName;
            this.type      = type;          
        }
     public static DataTableColumns parse(String json) {
        return (DataTableColumns) System.JSON.deserialize(json, DataTableColumns.class );
    }

}