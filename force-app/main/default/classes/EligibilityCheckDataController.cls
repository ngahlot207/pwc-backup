public class EligibilityCheckDataController {
    @AuraEnabled(cacheable=true)
    public static CombinedObjectData fetchRecords(String params) {
  		String incomeProgramAppl ='Cash Flow - Assessed income,Business income - Regular Income Program (P&L),Gross Eligible Salary with Bank Credit,Net Eligible Salary with Bank Credit,Cash Salary,Net Salary,Rental bank credit,Rental without bank credit,Pension Income,Other Income,Agriculture Income,Gross Salary';
        Map<String, Map<string, object>> resultMap = new Map<String, Map<string, object>>();
        set<id> applicantSetId = new  set<id>();
        set<String> allApplicantList = new set<string>();
        
        CombinedObjectData combinedData = new CombinedObjectData();
  
        List<BRE_Eligibility__c> records = [SELECT Id, Name, BREResponse__c, Type__c, IncomeProgram__c,  BREResponse__r.Applicant__r.FullName__c, BREResponse__r.LoanAppl__c, BREValue__c, BREValueType__c, IsLatest__c FROM BRE_Eligibility__c WHERE IsLatest__c=true AND BREResponse__r.LoanAppl__c=:params];
   
     
  
        for (BRE_Eligibility__c record : records) {
             applicantSetId.add(record.BREResponse__r.Applicant__c);
  allApplicantList.add(record.BREResponse__r.Applicant__r.FullName__c);
            String incomeProgram = record.IncomeProgram__c;
			system.debug('incomeProgram>>>'+incomeProgram);
            string applicantId = record.BREResponse__r.Applicant__c;
           // system.debug('applicantId for bre>>>>>'+applicantId);
            if (!resultMap.containsKey(incomeProgram)) {
                resultMap.put(incomeProgram, new Map<string, object>());
            }

            
            resultMap.get(incomeProgram).put(applicantId, record.BREValue__c);
        }
 
        List<Applicant__c> applicantList = [select id,LoanAppln__c, ApplType__c, FullName__c,Type_of_Borrower__c,Average_Monthly_Rental_No_Bank_Credit__c,Average_Monthly_Rental_With_Bank_Credit__c,Average_Other_Income__c,AverageMonthlyAgricultureIncome__c,Average_Monthly_Cash_Salary__c,Average_Monthly_Pension__c,Average_Monthly_Gross_Salary__c, Average_Net_Salary__c   from Applicant__c where Type_of_Borrower__c='Financial' AND ApplType__c IN('P','G','C') AND LoanAppln__c=:params];
 
        Map<Id, Object> tempMap;
        if(!applicantList.isEmpty()){
            for (Applicant__c obj : applicantList) {
                allApplicantList.add(obj.Id);
                applicantSetId.add(obj.Id);
          // system.debug('applicant id from applicant'+obj.Id);
                if(resultMap.containsKey('Cash Salary')){
                    resultMap.get('Cash Salary').put(obj.Id,obj.Average_Monthly_Cash_Salary__c);
                   // system.debug('resultMap inside if of Cash Salary>>'+resultMap);
                }else{
                    resultMap.put('Cash Salary', new Map<string, object>());
                   	resultMap.get('Cash Salary').put(obj.Id,obj.Average_Monthly_Cash_Salary__c);
                    system.debug('resultMap inside else of Cash Salary>>'+resultMap);

                }
                
                  if(resultMap.containsKey('Net Salary')){
                    resultMap.get('Net Salary').put(obj.Id,obj.Average_Net_Salary__c);
                }else{
                    resultMap.put('Net Salary', new Map<string, object>());
                   	resultMap.get('Net Salary').put(obj.Id,obj.Average_Net_Salary__c);

                }
                
                if(resultMap.containsKey('Rental bank credit')){
                    resultMap.get('Rental bank credit').put(obj.Id,obj.Average_Monthly_Rental_With_Bank_Credit__c);
                }else{
                       resultMap.put('Rental bank credit', new Map<string, object>());
                   	resultMap.get('Rental bank credit').put(obj.Id,obj.Average_Monthly_Rental_With_Bank_Credit__c);
                }
                
                if(resultMap.containsKey('Rental without bank credit')){
                    resultMap.get('Rental without bank credit').put(obj.Id,obj.Average_Monthly_Rental_No_Bank_Credit__c);
                }else{
                    resultMap.put('Rental without bank credit', new Map<string, Object>());
                    	resultMap.get('Rental without bank credit').put(obj.Id,obj.Average_Monthly_Rental_No_Bank_Credit__c);
                        
                }
                
                if(resultMap.containsKey('Pension Income')){
                    resultMap.get('Pension Income').put(obj.Id,obj.Average_Monthly_Pension__c);
                }else{
                  resultMap.put('Pension Income', new Map<string, Object>());
                    resultMap.get('Pension Income').put(obj.Id,obj.Average_Monthly_Pension__c);
                }
                
                if(resultMap.containsKey('Other Income')){
                    resultMap.get('Other Income').put(obj.Id,obj.Average_Other_Income__c);
                }else{
                   resultMap.put('Other Income', new Map<string, Object>());
                     resultMap.get('Other Income').put(obj.Id,obj.Average_Other_Income__c);
                }
                
                if(resultMap.containsKey('Agriculture Income')){
                    resultMap.get('Agriculture Income').put(obj.Id,obj.AverageMonthlyAgricultureIncome__c);
                }else{
                    resultMap.put('Agriculture Income',new Map<string, Object>());
                     resultMap.get('Agriculture Income').put(obj.Id,obj.AverageMonthlyAgricultureIncome__c);
                }
                 if(resultMap.containsKey('Gross Salary')){
                    resultMap.get('Gross Salary').put(obj.Id,obj.Average_Monthly_Gross_Salary__c);
                }else{
                    resultMap.put('Gross Salary',new Map<string, Object>());
                     resultMap.get('Gross Salary').put(obj.Id,obj.Average_Monthly_Gross_Salary__c);
                }
         
            }
            
        }
      
       system.debug('allApplicantList>>'+allApplicantList);
       for(Id appid:applicantSetId ){
            for(string incomePrograms:incomeProgramAppl.split(',')){
                if(resultMap.containsKey(incomePrograms)){
                    if(resultMap.get(incomePrograms).containsKey(appid)){
                       system.debug('applicant id is present'); 
                    }else{
                       resultMap.get(incomePrograms).put(appid,0); 
                    }   
                }
            }   
        }
        
         List<Applicant__c> actualApplicant =[select id, ApplType__c,AssessmentProgram__c, FullName__c from Applicant__c where id IN:applicantSetId];
       
        combinedData.actualApplList =JSON.serialize(actualApplicant);
   // system.debug('resultMap>>>>>'+resultMap);
  
        combinedData.serializedData = JSON.serialize(resultMap);
   system.debug('combinedData>>>>>>>>'+combinedData.serializedData);
        return combinedData;
    
        //       return resultMap;
    }
        public class CombinedObjectData{
          @AuraEnabled public String serializedData { get; set; }
        @AuraEnabled public string actualApplList { get; set; }
         
    }
}