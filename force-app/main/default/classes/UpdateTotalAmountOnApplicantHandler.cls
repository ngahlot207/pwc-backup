public class UpdateTotalAmountOnApplicantHandler {
    
    public static void updateTotalAmountDelete(List<Applicant_Income__c> oldList){
        updateTotalAmountProcessor(oldList);   
    }
    
    public static void updateTotalAmountInsert(list<Applicant_Income__c> newList){
        updateTotalAmountProcessor(newList);
    }
    
    public static void updateTotalAmountUpdate(list<Applicant_Income__c> newList,List<Applicant_Income__c> oldList){
        Map<Id, Applicant_Income__c> oldApplicantIncomesMap = new Map<Id, Applicant_Income__c> (oldList);
        List<Applicant_Income__c> newApplicantList = new List<Applicant_Income__c>();
        for (Applicant_Income__c newRecord : newList) {
            Applicant_Income__c oldRecord = oldApplicantIncomesMap.get(newRecord.Id);
            if (hasFieldChanged(newRecord, oldRecord, 'RecordTypeId') ||
                hasFieldChanged(newRecord, oldRecord, 'Applicant__c') ||
                hasFieldChanged(newRecord, oldRecord, 'Month1_Rental_Credited_Amount__c') ||
                hasFieldChanged(newRecord, oldRecord, 'Month2_Rental_Credited_Amount__c') ||
                hasFieldChanged(newRecord, oldRecord, 'Month3_Rental_Credited_Amount__c') ||
                hasFieldChanged(newRecord, oldRecord, 'Salary__c') ||
                hasFieldChanged(newRecord, oldRecord, 'Total_Inflow_From_Operations__c') ||
                hasFieldChanged(newRecord, oldRecord, 'Monthly_Purchases_Cost_Of_Materials__c') ||
                hasFieldChanged(newRecord, oldRecord, 'Total_Expense_of_operations_Or_Business__c') ||
                hasFieldChanged(newRecord, oldRecord, 'Agricultural_Yearly_Income__c') ||
                hasFieldChanged(newRecord, oldRecord, 'Net_Salary__c') ||
                hasFieldChanged(newRecord, oldRecord, 'Other_Salary_Component__c') ||
                hasFieldChanged(newRecord, oldRecord, 'Monthly_Pension_Credited__c') ||
                hasFieldChanged(newRecord, oldRecord, 'Monthly_Other_Income__c')){
                    newApplicantList.add(newRecord);
                }
        }
        if(!newApplicantList.isEmpty()){
            updateTotalAmountProcessor(newList);
        }
    }
    
    public static void updateTotalAmountProcessor(list<Applicant_Income__c> appListRecords){
        Map<Id,Decimal> applicantTotalIncomeMap = new Map<Id,Decimal>();
        Set<Id> applicantIds = new Set<Id>();
        List<Applicant_Income__c> applIncList = new List<Applicant_Income__c>();
        List<Applicant__c> updateList = new List<Applicant__c>();
        
        for(Applicant_Income__c appInc : appListRecords){
            if(appInc.Applicant__c!=null){
                applicantIds.add(appInc.Applicant__c);
            }
        }
        
        if(!applicantIds.isEmpty()){
            applIncList = [Select Id, RecordTypeId, RecordType.DeveloperName, Applicant__c, Month1_Rental_Credited_Amount__c, Month2_Rental_Credited_Amount__c, Month3_Rental_Credited_Amount__c,
                           Salary__c, Total_Inflow_From_Operations__c, Monthly_Purchases_Cost_Of_Materials__c, Total_Expense_of_operations_Or_Business__c,
                           Agricultural_Yearly_Income__c, Net_Salary__c, Other_Salary_Component__c, Monthly_Pension_Credited__c, Monthly_Other_Income__c from Applicant_Income__c where
                           Applicant__c IN:applicantIds];
        }
        
        for(Applicant_Income__c appInc : applIncList){  
            if (appInc.Applicant__c != null) {
                Decimal totalIncome = 0;
                
                if (appInc.RecordTypeId != null) {
                    if (appInc.RecordType.DeveloperName == 'Rental_woBanking' || appInc.RecordType.DeveloperName == 'RentalwBank') {
                        totalIncome = calculateTotalRentalIncome(appInc);
                    } else if (appInc.RecordType.DeveloperName == 'CashSal') {
                        totalIncome = appInc.Salary__c;
                    } else if (appInc.RecordType.DeveloperName == 'AgriIncome') {
                        totalIncome = appInc.Agricultural_Yearly_Income__c;
                    } else if (appInc.RecordType.DeveloperName == 'BankCrSal') {
                        totalIncome = calculateTotalBankCreditSalaryIncome(appInc); 
                    } else if (appInc.RecordType.DeveloperName == 'Pension') {
                        totalIncome = appInc.Monthly_Pension_Credited__c;
                    } else if (appInc.RecordType.DeveloperName == 'Other_Income') {
                        totalIncome = appInc.Monthly_Other_Income__c;
                    } else if (appInc.RecordType.DeveloperName == 'Cashflow_Map') {
                        totalIncome = calculateTotalCashFlowIncome(appInc);
                    }
                    if(totalIncome == null){
                        totalIncome = 0;
                    }
                    
                    if (applicantTotalIncomeMap.containsKey(appInc.Applicant__c)) {
                        totalIncome = totalIncome + applicantTotalIncomeMap.get(appInc.Applicant__c);
                        applicantTotalIncomeMap.put(appInc.Applicant__c, totalIncome);
                    }else{
                        applicantTotalIncomeMap.put(appInc.Applicant__c, totalIncome);
                    }
                    
                }
            }
        }        
        if(!applicantTotalIncomeMap.keySet().isEmpty()){
            for(Id appL : applicantTotalIncomeMap.keySet()){
                Applicant__c applicant = new Applicant__c();
                applicant.Id = appL;
                applicant.TotalIncome__c = applicantTotalIncomeMap.get(appL);
                updateList.add(applicant);
            }
            update updateList;
        }
    }
    
    @TestVisible
    private static Decimal calculateTotalRentalIncome(Applicant_Income__c appInc) {
        Decimal totalIncome = 0;
        totalIncome += (appInc.Month1_Rental_Credited_Amount__c != null) ? appInc.Month1_Rental_Credited_Amount__c : 0;
        totalIncome += (appInc.Month2_Rental_Credited_Amount__c != null) ? appInc.Month2_Rental_Credited_Amount__c : 0;
        totalIncome += (appInc.Month3_Rental_Credited_Amount__c != null) ? appInc.Month3_Rental_Credited_Amount__c : 0;
        return totalIncome;
    }
    @TestVisible
    private static Decimal calculateTotalBankCreditSalaryIncome(Applicant_Income__c appInc) {
        Decimal totalIncome = 0;
        totalIncome += (appInc.Net_Salary__c != null) ? appInc.Net_Salary__c : 0;
        totalIncome += (appInc.Other_Salary_Component__c != null) ? appInc.Other_Salary_Component__c : 0;
        return totalIncome;
    }
    
    @TestVisible
    private static Decimal calculateTotalCashFlowIncome(Applicant_Income__c appInc) {
        Decimal totalIncome = 0;
        totalIncome += (appInc.Total_Inflow_From_Operations__c != null) ? appInc.Total_Inflow_From_Operations__c : 0;
        Decimal expenses = 0;
        expenses += (appInc.Monthly_Purchases_Cost_Of_Materials__c != null) ? appInc.Monthly_Purchases_Cost_Of_Materials__c : 0;
        expenses += (appInc.Total_Expense_of_operations_Or_Business__c != null) ? appInc.Total_Expense_of_operations_Or_Business__c : 0;
        totalIncome = totalIncome - expenses;
        return totalIncome;
    }
    
    @TestVisible
    private static Boolean hasFieldChanged(Applicant_Income__c newRecord, Applicant_Income__c oldRecord, String fieldName) {
        return newRecord.get(fieldName) != oldRecord.get(fieldName);
    }
}