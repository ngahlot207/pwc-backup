public class UpdateAnnualTurnoverOnApplicantHandler { 
    
    public static String profitLossRecordTypeName = 'Profit_Loss';
    
         
    public static void updateAnnualTurnoverAmount(List<Applicant_Financial_Summary__c> oldList){
        updateAnnualTurnoverAmountProcessor(oldList);   
    }
    
    
    public static void updateAnnualTurnoverAmount(list<Applicant_Financial_Summary__c> newList,List<Applicant_Financial_Summary__c> oldList){
       updateAnnualTurnoverAmountProcessor(newList);
    }
    
    public static void updateAnnualTurnoverAmountProcessor(list<Applicant_Financial_Summary__c> appListRecords){
        Map<Id,Decimal> applicantAnnualTurnoverMap = new Map<Id,Decimal>();
        Set<Id> applicantIds = new Set<Id>();
        Set<Id> applicantFinancialIds = new Set<Id>();
        List<Applicant_Financial_Summary__c> applFinSumList = new List<Applicant_Financial_Summary__c>();
        List<Applicant__c> updateList = new List<Applicant__c>();
        
        Integer currentYear = Date.today().year();
        Integer financialYearStartMonth = 4;
        if(Date.today().month() < financialYearStartMonth) {
            currentYear--;
        }
        String finalCurrentFinYear = (currentYear-1)+'-'+currentYear;
        finalCurrentFinYear = String.valueOf(finalCurrentFinYear);
        
        
        for(Applicant_Financial_Summary__c appFinSum : appListRecords){
            
            if(appFinSum.Applicant_Financial__c!=null && appFinSum.Financial_Year__c!=null && appFinSum.Financial_Year__c == finalCurrentFinYear){
                applicantFinancialIds.add(appFinSum.Applicant_Financial__c);
            }
        }
        
        if(!applicantFinancialIds.isEmpty()){
            for(Applicant_Financial__c appFin : [Select Id, Loan_Applicant__c from Applicant_Financial__c where Loan_Applicant__c !=null AND ID IN:applicantFinancialIds]){
                applicantIds.add(appFin.Loan_Applicant__c);
            }
        }
        
        if(!applicantIds.isEmpty()){
            
            
            system.debug('Pratap 1111 '+finalCurrentFinYear);
            
            applFinSumList = [Select Id, Total_Sales__c, Applicant_Financial__c, Applicant_Financial__r.Loan_Applicant__c, Financial_Year__c, 
                              Applicant_Financial__r.RecordTypeId, Applicant_Financial__r.RecordType.DeveloperName
                              from Applicant_Financial_Summary__c where Applicant_Financial__r.Loan_Applicant__c !=null AND Applicant_Financial__r.RecordTypeId !=null
                              AND Applicant_Financial__r.RecordType.DeveloperName =:profitLossRecordTypeName AND Applicant_Financial__r.Loan_Applicant__c IN:applicantIds
                              AND Financial_Year__c =:finalCurrentFinYear];
        }
        
        for(Applicant_Financial_Summary__c appInc : applFinSumList){  
            if (appInc.Applicant_Financial__c != null && appInc.Applicant_Financial__r.Loan_Applicant__c !=null) {
                Decimal annualTurOver = 0;
                annualTurOver = (appInc.Total_Sales__c != null) ? appInc.Total_Sales__c : 0;
                
                
                if (applicantAnnualTurnoverMap.containsKey(appInc.Applicant_Financial__r.Loan_Applicant__c)) {
                    annualTurOver = annualTurOver + applicantAnnualTurnoverMap.get(appInc.Applicant_Financial__r.Loan_Applicant__c);
                    applicantAnnualTurnoverMap.put(appInc.Applicant_Financial__r.Loan_Applicant__c, annualTurOver);
                }else{
                    applicantAnnualTurnoverMap.put(appInc.Applicant_Financial__r.Loan_Applicant__c, annualTurOver);
                }
                
            }
        }  
        
        system.debug('Pratap 1 '+applFinSumList);
        system.debug('Pratap 11 '+applicantAnnualTurnoverMap);
        if(!applicantAnnualTurnoverMap.keySet().isEmpty()){
            for(Id appL : applicantAnnualTurnoverMap.keySet()){
                Applicant__c applicant = new Applicant__c();
                applicant.Id = appL;
                applicant.Annual_Turnover__c = applicantAnnualTurnoverMap.get(appL);
                updateList.add(applicant);
            }
            update updateList;
        }
        system.debug('Pratap 111 '+updateList);
    }
}