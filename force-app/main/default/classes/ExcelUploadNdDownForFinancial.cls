public class ExcelUploadNdDownForFinancial {
	@AuraEnabled(cacheable=true)
    public static List<FinancialSheetMapping__c> getMetadataForProfit(){
        List<FinancialSheetMapping__c> jsonMetaDataList=[select FieldName__c,Remark_for_field__c,Sheet_Name__c,TableColumnName__c  from FinancialSheetMapping__c where Sheet_Name__c='Profit and loss' ORDER BY Sequence__c];
        system.debug('jsonMetaDataList'+jsonMetaDataList);
        return jsonMetaDataList;
    }
    @AuraEnabled(cacheable=true)
    public static Map<string, List<FinancialSheetMapping__c>> getMetadataForProfitTab2(){
        Map<string, List<FinancialSheetMapping__c>> mapToReturn=new Map<string, List<FinancialSheetMapping__c>>();
        List<FinancialSheetMapping__c> cusSetListForTab2=[select FieldName__c,Remark_for_field__c,Sheet_Name__c,TableColumnName__c  from FinancialSheetMapping__c where Sheet_Name__c='Profit and loss 2 table' ORDER BY Sequence__c];
        List<FinancialSheetMapping__c> cusSetListForTab5=[select FieldName__c,Remark_for_field__c,Sheet_Name__c,TableColumnName__c  from FinancialSheetMapping__c where Sheet_Name__c='Profit and loss 3 table' ORDER BY Sequence__c];
        system.debug('cusSetListForTab2'+cusSetListForTab2);
        List<FinancialSheetMapping__c> cusSetListForTab3=[select FieldName__c,Remark_for_field__c,Sheet_Name__c,TableColumnName__c  from FinancialSheetMapping__c where Sheet_Name__c='Balance Sheet' ORDER BY Sequence__c];
        system.debug('cusSetListForTab3'+cusSetListForTab3);
        List<FinancialSheetMapping__c> cusSetListForTab4=[select FieldName__c,Remark_for_field__c,Sheet_Name__c,TableColumnName__c  from FinancialSheetMapping__c where Sheet_Name__c='Asset Sheet' ORDER BY Sequence__c];
        system.debug('cusSetListForTab4'+cusSetListForTab4);
        
        mapToReturn.put('Profit and loss 2 table', cusSetListForTab2);
        mapToReturn.put('Profit and loss 3 table', cusSetListForTab5);
        mapToReturn.put('Balance Sheet', cusSetListForTab3);
        mapToReturn.put('Asset Sheet', cusSetListForTab4);
        return mapToReturn;
    }
}