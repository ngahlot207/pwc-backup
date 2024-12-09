public without sharing class FinancialRecordProcessor {
    
    @AuraEnabled
    public static String processDefunctRecordsFinancial(String previousFinYear, String currentFinYear, String provisionalAvailable, String provisionalYear, String applicantId) {
        Set<String> financialYearSet = new Set<String>();
        String status;
        List<Applicant_Financial_Summary__c> appFinSumRecords = new List<Applicant_Financial_Summary__c>();
        if(!String.isBlank(provisionalAvailable) && (provisionalAvailable == 'Yes') && !String.isBlank(provisionalYear)){
            financialYearSet.add(provisionalYear);
        }
        if(!String.isBlank(currentFinYear)){
            financialYearSet.add(currentFinYear);
        }
        
        if(!String.isBlank(previousFinYear)){
            financialYearSet.add(previousFinYear);
        }
        
        if(!financialYearSet.isEmpty()){
            appFinSumRecords = [Select Id, Financial_Year__c,Applicant_ID__c, Applicant_Financial__c, Applicant_Financial__r.RecordType.DeveloperName from Applicant_Financial_Summary__c 
                                where Financial_Year__c NOT IN:financialYearSet
                                AND Applicant_ID__c =:applicantId];
        }
        
        
        if(!appFinSumRecords.isempty()){
            try{
                delete appFinSumRecords;
                status = 'Success';
            }catch(Exception ex){
                status = 'Failure';
            }
        }else{
            status = 'Success';
        }
        return status;
    }
}