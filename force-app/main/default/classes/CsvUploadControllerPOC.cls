public class CsvUploadControllerPOC {
    @AuraEnabled
    public static List<POCObject__c> saveFile(String base64Data)  
    {
        String data    = JSON.deserializeUntyped(base64Data).toString();
        list<POCObject__c> lstCCToInsert = new list<POCObject__c>();
        list<String> lstCSVLines = data.split('\n');
        
        
        for(Integer i = 1; i < lstCSVLines.size(); i++){
            POCObject__c pocObj = new POCObject__c();
            String csvLine = lstCSVLines[i];
            String prevLine = csvLine;
            List<String> csvRowData = new List<String>();
            
            for(String column : csvLine.split(',')){
                column = column.replaceAll(':quotes:', '"').replaceAll(':comma:', ',');
                csvRowData.add(column);
            }
            pocObj.Field1__c = csvRowData[0];
            pocObj.Field2__c = csvRowData[1];
            pocObj.Field3__c = csvRowData[2];
            pocObj.Field4__c = csvRowData[3];
            lstCCToInsert.add(pocObj);
        }
        
        if (lstCCToInsert != null)
        {
            insert lstCCToInsert;
        }
        return lstCCToInsert;
    }
}