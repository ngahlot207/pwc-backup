public class CalculateBorrowerWiseIncome {
    
    public static void calculateForApplicant(List<Applicant__c> newList,Map<Id,Applicant__c> oldMap)
    {
        Set<Id> applicantIds= new Set<Id>();
        for(Applicant__c appObj:newList)
        {
            if(appObj.CustProfile__c!=oldMap.get(appObj.id).CustProfile__c || appObj.LatestyearforwhichITRisavailable__c!=oldMap.get(appObj.id).LatestyearforwhichITRisavailable__c)
            {
                applicantIds.add(appObj.id);
            }
        }
        if(!applicantIds.isEmpty())
        {
            updateBorrowerWiseAssessmentProcessor(applicantIds);
        }
    }
    
    public static void calculateForApplicantIncome(List<Applicant_Income__c> appIncomeList)
    {
        Set<Id> applicantIds = new Set<Id>();
        for(Applicant_Income__c incomeObj : appIncomeList)
        {
            if(incomeObj.Applicant__c !=null){
                applicantIds.add(incomeObj.Applicant__c);
            }
        }
        updateBorrowerWiseAssessmentProcessor(applicantIds);
    }
    
    public static void calculateForApplicantFinancial(List<Applicant_Financial__c> financialList)
    {
        Set<Id> applicantIds = new Set<Id>();
        for(Applicant_Financial__c finObj : financialList)
        {
            if(finObj.Loan_Applicant__c !=null){
                applicantIds.add(finObj.Loan_Applicant__c);
            }
        }
        updateBorrowerWiseAssessmentProcessor(applicantIds);
    }
    
    public static void updateBorrowerWiseAssessmentProcessor(Set<Id> applicantIds)
    {
        if(!HandleRecursionForApplicant.mapExecutedRecord.containsKey('afterUpdate')){
            HandleRecursionForApplicant.mapExecutedRecord.put('afterUpdate',new Set<ID>()); 
        }
        
        
        List<Applicant__c> updatedApplicantList=new List<Applicant__c>();
        Map<Id,Set<String>> coreIncomeRecordTypes=new Map<Id,set<String>>();  
        
        populateRecordTypes(coreIncomeRecordTypes, 'Income', [SELECT Id, RecordType.DeveloperName, Applicant__c
                                                    FROM Applicant_Income__c
                                                    WHERE Applicant__c IN :applicantIds AND
                                                    RecordType.DeveloperName IN ('Cashflow_Map', 'CashSal', 'BankCrSal')], null);
        
       populateRecordTypes(coreIncomeRecordTypes, 'Financial', null, [SELECT Id, RecordType.DeveloperName, Loan_Applicant__c
                                                    FROM Applicant_Financial__c
                                                    WHERE Loan_Applicant__c IN :applicantIds AND
                                                    RecordType.DeveloperName IN ('Profit_Loss', 'Balance_Sheet')]);
        
        
        for(Applicant__c applObj:[Select id,CustProfile__c,LatestyearforwhichITRisavailable__c,AssessmentProgram__c from Applicant__c where id IN: applicantIds])
        {
            if(!HandleRecursionForApplicant.mapExecutedRecord.get('afterUpdate').contains(applObj.id))
            {
                applObj.AssessmentProgram__c='';
                if(!String.isBlank(applObj.CustProfile__c) )
                {
                    if((applObj.CustProfile__c=='SELF EMPLOYED NON PROFESSIONAL' || applObj.CustProfile__c=='SELF EMPLOYED PROFESSIONAL')  )
                    {
                        if(applObj.LatestyearforwhichITRisavailable__c=='ITR Not Available')
                        {
                            if(coreIncomeRecordTypes.containsKey(applObj.Id) && coreIncomeRecordTypes.get(applObj.Id).contains('Cashflow_Map'))
                            {
                                applObj.AssessmentProgram__c='Assessed Income Program';
                                updatedApplicantList.add(applObj);
                            }
                            else{
                                applObj.AssessmentProgram__c='Assessed Income Program';
                                updatedApplicantList.add(applObj);
                            }
                        }
                        else if(String.isBlank(applObj.LatestyearforwhichITRisavailable__c) || applObj.LatestyearforwhichITRisavailable__c != 'ITR Not Available')
                        {
                            if(coreIncomeRecordTypes.containsKey(applObj.Id) && 
                               (coreIncomeRecordTypes.get(applObj.Id).contains('Profit_Loss') || coreIncomeRecordTypes.get(applObj.Id).contains('Balance_Sheet'))
                              )
                            {
                                applObj.AssessmentProgram__c='Regular Income Program';
                                updatedApplicantList.add(applObj);
                            }
                        }
                    }
                    else if(applObj.CustProfile__c=='SALARIED' )
                    {
                        system.debug('coreIncomeRecordTypes------------------>'+coreIncomeRecordTypes);
                        if(coreIncomeRecordTypes.containsKey(applObj.Id))
                        {
                            if(coreIncomeRecordTypes.get(applObj.id).contains('CashSal'))
                            {
                                applObj.AssessmentProgram__c='Assessed Income Program'; 
                                updatedApplicantList.add(applObj);
                            }
                            else if(coreIncomeRecordTypes.get(applObj.id).contains('BankCrSal'))
                            {
                                applObj.AssessmentProgram__c='Regular Income Program';
                                updatedApplicantList.add(applObj);
                            }
                        }
                        else
                        {
                            applObj.AssessmentProgram__c='Assessed Income Program'; 
                            updatedApplicantList.add(applObj);
                        }
                    }
                }
                if(applObj.AssessmentProgram__c=='')
                {
                    updatedApplicantList.add(applObj);
                }
                HandleRecursionForApplicant.mapExecutedRecord.get('afterUpdate').add(applObj.id);
            } 
        }
        system.debug('updatedApplicantList-------------------->'+updatedApplicantList);
        if(!updatedApplicantList.isEmpty())
        {
            update updatedApplicantList;
        }
    }
    
    private static void populateRecordTypes(Map<Id, Set<String>> recordTypesMap, String objectType, List<Applicant_Income__c> incomeRecords, List<Applicant_Financial__c> financialRecords) {
        String parentIdField = (objectType == 'Financial') ? 'Loan_Applicant__c' : 'Applicant__c';
        if(objectType == 'Financial'){
            for (Applicant_Financial__c record : financialRecords) {
                Id parentId = (Id) record.get(parentIdField);
                
                if (!recordTypesMap.containsKey(parentId)) {
                    recordTypesMap.put(parentId, new Set<String>{record.RecordType.DeveloperName});
                }else{
                    recordTypesMap.get(parentId).add(record.RecordType.DeveloperName);
                }
            }
        }else if(objectType == 'Income'){
            for (Applicant_Income__c record : incomeRecords) {
                Id parentId = (Id) record.get(parentIdField);
                
                if (!recordTypesMap.containsKey(parentId)) {
                    recordTypesMap.put(parentId, new Set<String>{record.RecordType.DeveloperName});
                }else{
                    recordTypesMap.get(parentId).add(record.RecordType.DeveloperName);
                }
            }
        }
    }
}