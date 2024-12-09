public with sharing class CSVController {

    @AuraEnabled(cacheable=false)
    public static String insertRecords(String recordsJson) {
        System.debug('Start');
        try {
            List<Account> accountsToInsert = new List<Account>();
            List<Object> records = (List<Object>) JSON.deserializeUntyped(recordsJson);
            
            for (Object record : records) {
                Map<String, Object> recordMap = (Map<String, Object>) record;
                Account acc = new Account();
                acc.Name = String.valueOf(recordMap.get('Name'));
                acc.Rating = String.valueOf(recordMap.get('Rating'));
                acc.Industry = String.valueOf(recordMap.get('Industry'));
                accountsToInsert.add(acc);
            }
            
            if (!accountsToInsert.isEmpty()) {
                insert accountsToInsert;
            }
            
            return 'Records inserted successfully';
        } catch (Exception e) {
            return 'Error inserting records: ' + e.getMessage();
        }
    }
}