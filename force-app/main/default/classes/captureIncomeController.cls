public class captureIncomeController {
    @AuraEnabled(cacheable=true) 
    public static Map<String, String> getPicklistValues(String applcntId) {
        Map<String, String> picklistValues = new Map<String, String>();   
        
        if (String.isNotBlank(applcntId)) { 
            // Retrieve Loan Application record
            // LoanAppl__c loanApp = [SELECT AssessedIncAppln__c FROM LoanAppl__c WHERE Id = :loanAppId];
            Applicant__c applObj = [SELECT Id, LatestyearforwhichITRisavailable__c, CustProfile__c, LoanAppln__r.AssessedIncAppln__c, LoanAppln__r.AssesIncomeAppl__c,LoanAppln__r.Product__c From Applicant__c WHERE Id =: applcntId];
            
            // Retrieve Income Type Master records
            List<MasterData__c> incomeMasterRecs = new List<MasterData__c>();
            incomeMasterRecs = [SELECT Id, Name, FinnoneVal__c, FinnoneCode__c, Type__c FROM MasterData__c where Type__c ='Income Type'];
            
            if(applObj != null && incomeMasterRecs.size() > 0 && !string.isBlank(applObj.CustProfile__c)){
                
                for (MasterData__c masterRec : incomeMasterRecs) { 
                    if (masterRec.FinnoneCode__c == 'Cashflow_Map' && 
                        (applObj.CustProfile__c=='SELF EMPLOYED PROFESSIONAL' 
                         || applObj.CustProfile__c=='SELF EMPLOYED NON PROFESSIONAL'
                        ) && !string.isBlank(applObj.LatestyearforwhichITRisavailable__c) && applObj.LatestyearforwhichITRisavailable__c=='ITR Not Available')
                    {
                     	picklistValues.put(masterRec.FinnoneVal__c, masterRec.FinnoneCode__c);
                    }
                    if (masterRec.FinnoneCode__c == 'CashSal' && applObj.CustProfile__c=='SALARIED')//&& (applObj.LoanAppln__r.Product__c != 'Business Loan' && applObj.LoanAppln__r.Product__c != 'Personal Loan')
                    {
                        picklistValues.put(masterRec.FinnoneVal__c, masterRec.FinnoneCode__c);
                    }
                    if (masterRec.FinnoneCode__c == 'BankCrSal' && applObj.CustProfile__c=='SALARIED')
                    {
                        picklistValues.put(masterRec.FinnoneVal__c, masterRec.FinnoneCode__c);
                    }
                    if ((masterRec.FinnoneCode__c == 'Rental_woBanking' || masterRec.FinnoneCode__c == 'AgriIncome') && (applObj.CustProfile__c=='SALARIED' || (applObj.CustProfile__c=='SELF EMPLOYED PROFESSIONAL' || applObj.CustProfile__c=='SELF EMPLOYED NON PROFESSIONAL')))// && (applObj.LoanAppln__r.Product__c != 'Business Loan' && applObj.LoanAppln__r.Product__c != 'Personal Loan'))
                    {
                        picklistValues.put(masterRec.FinnoneVal__c, masterRec.FinnoneCode__c);
                    }
                    if ((masterRec.FinnoneCode__c == 'RentalwBank'  || masterRec.FinnoneCode__c == 'Pension' || masterRec.FinnoneCode__c == 'Other_Income' ) && (applObj.CustProfile__c=='SALARIED' || (applObj.CustProfile__c=='SELF EMPLOYED PROFESSIONAL' || applObj.CustProfile__c=='SELF EMPLOYED NON PROFESSIONAL')))
                    {
                        picklistValues.put(masterRec.FinnoneVal__c, masterRec.FinnoneCode__c);
                    }
                    if ((masterRec.FinnoneCode__c == 'Consulting_Income' || masterRec.FinnoneCode__c == 'Other_Income_Annual') && (applObj.LoanAppln__r.Product__c == 'Business Loan' || applObj.LoanAppln__r.Product__c == 'Personal Loan'))
                    {
                        picklistValues.put(masterRec.FinnoneVal__c, masterRec.FinnoneCode__c);
                    }
                }
            }
        }
        system.debug('picklistValues----------------->'+picklistValues);
        return picklistValues;
    }
    
    
    @AuraEnabled(cacheable=true)
    public static List<String> getApplicantIncomeRecordTypes(String appId) {
        system.debug('applicantId-------------->'+appId);
        Set<String> recordTypeNames = new Set<String>();
        
        if (String.isNotBlank(appId)) {
            for (Applicant_Income__c appIncome : [SELECT RecordType.DeveloperName FROM Applicant_Income__c WHERE Applicant__c = :appId ORDER BY CreatedDate ASC]) {
                recordTypeNames.add(appIncome.RecordType.DeveloperName);
            }
        }
        return new List<String>(recordTypeNames);
    }
    
    @AuraEnabled(cacheable=true)
    public static Applicant__c getApplicantData(String applicantId) {
        
        
        return [Select Id, Income_Type_Selected__c, CustProfile__c, ApplType__c, Type_of_Borrower__c,AverageMonthlyAgricultureIncome__c,
                Average_Monthly_Gross_Salary__c,Average_Net_Salary__c,Average_Monthly_Cash_Salary__c, Average_Other_Income__c,
                Average_Monthly_Pension__c,Average_Monthly_Rental_With_Bank_Credit__c,Average_Monthly_Rental_No_Bank_Credit__c  from Applicant__c where Id =:applicantId];
    }
    
    @AuraEnabled
    public static Boolean deleteIncomeTypeRecords(String applicantId, String incomeType) {
        List<Applicant_Income__c> appIncomeRecords = new List<Applicant_Income__c>();
        List<Applicant_Income__c> appIncomeRecordsLatest = new List<Applicant_Income__c>();
        system.debug('applicantId----------->'+applicantId);
        system.debug('incomeType----------->'+incomeType);
        if(!String.isBlank(applicantId)){
            appIncomeRecords = [Select Id from Applicant_Income__c where RecordType.DeveloperName =:incomeType AND Applicant__c =:applicantId];
            if(!appIncomeRecords.isEmpty()){
                try{
                    delete appIncomeRecords;
                    Applicant__c appL = new Applicant__c();
                    appL = [Select Id, Income_Type_Selected__c ,AverageMonthlyAgricultureIncome__c, Average_Monthly_Gross_Salary__c, Average_Net_Salary__c, 
                             Average_Monthly_Cash_Salary__c, Average_Other_Income__c, Average_Monthly_Pension__c, Average_Monthly_Rental_With_Bank_Credit__c,
                             Average_Monthly_Rental_No_Bank_Credit__c from Applicant__c where Id =:applicantId];
                    //appL.Id = applicantId;
                    if(incomeType == 'AgriIncome'){
                        appL.AverageMonthlyAgricultureIncome__c = 0;
                    }else if(incomeType == 'BankCrSal'){
                        appL.Average_Monthly_Gross_Salary__c = 0;
                        appL.Average_Net_Salary__c = 0;
                    }else if(incomeType == 'CashSal'){
                        appL.Average_Monthly_Cash_Salary__c = 0;
                    }else if(incomeType == 'Other_Income'){
                        appL.Average_Other_Income__c = 0;
                    }else if(incomeType == 'Pension'){
                        appL.Average_Monthly_Pension__c = 0;
                    }else if(incomeType == 'RentalwBank'){
                        appL.Average_Monthly_Rental_With_Bank_Credit__c = 0;
                    }else if(incomeType == 'Rental_woBanking'){
                        appL.Average_Monthly_Rental_No_Bank_Credit__c = 0;
                    }
                    
                    if(appL.Income_Type_Selected__c!=null && appL.Income_Type_Selected__c == incomeType){
                        appL.Income_Type_Selected__c = '';
                    }
                    update appL;
                    return true;
                }catch(Exception ex){
                    return false;
                }
            }else{
                return true;
            }
        }else{
            return false;
        }
    }
}