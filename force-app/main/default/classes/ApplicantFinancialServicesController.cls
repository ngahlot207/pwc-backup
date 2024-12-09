public with sharing class ApplicantFinancialServicesController { 
    
    @AuraEnabled(cacheable=true) 
    public static List<Applicant_Financial_Summary__c> getFinancialSummaries() {
        
        //Select Applicant_Financial__r.Loan_Applicant__r.TabName__c,Financial_Year__c FROM Applicant_Financial_Summary__c WHERE Applicant_Financial__r.Loan_Applicant__r.LoanAppln__c='a08C4000005yfVKIAY'
        //select Liabilities__c,EBITDA__c,Financial_Year__c,Profit_Before_Depreciation_and_Tax_PBDT__c,PAT__c,Profit_Before_Tax__c,Assets__c,Debtors__c,Sundry_creditors__c from Applicant_Financial_Summary__c
        List<Applicant_Financial_Summary__c> listFinancialSummary = [select Applicant_Financial__r.Loan_Applicant__r.TabName__c,ID,Liabilities__c,EBITDA__c,Financial_Year__c,Profit_Before_Depreciation_and_Tax_PBDT__c,
                                                                     PAT__c,Profit_Before_Tax__c,Assets__c,Debtors__c,Sundry_creditors__c from Applicant_Financial_Summary__c WHERE Applicant_Financial__r.Loan_Applicant__r.LoanAppln__c='a08C4000005yfVKIAY'];
        
        if(listFinancialSummary.size()>0){
            return listFinancialSummary;
        }
        else{
            return null;
        }
    }
    
    /*@AuraEnabled(cacheable=true)
public static List<GetFinancialSummariesRecordsWrapper> getFinancialSummariesRecords() {

List<GetFinancialSummariesRecordsWrapper> FyWrapperList = new List<GetFinancialSummariesRecordsWrapper>();

Integer currentFY =0;
Integer currentFYMinus1 =0;
Integer currentFYMinus2 =0;
Integer currentFYMinus3 =0;

Date dat = System.today();
currentFY = dat.year();
currentFYMinus1 = currentFY-1;
currentFYMinus2 = currentFY-2;
currentFYMinus3 = currentFY-3;
system.debug('currentFYMinus3-->'+currentFYMinus3);

Map<String,Applicant_Financial_Summary__c> mapOfCurrentFyRecords = new Map<String,Applicant_Financial_Summary__c>();
Map<String,Applicant_Financial_Summary__c> mapOfCurrentFyMinus1Records = new Map<String,Applicant_Financial_Summary__c>();
Map<String,Applicant_Financial_Summary__c> mapOfCurrentFyMinus2Records = new Map<String,Applicant_Financial_Summary__c>();
Map<String,Applicant_Financial_Summary__c> mapOfCurrentFyMinus3Records = new Map<String,Applicant_Financial_Summary__c>();

List<Applicant_Financial_Summary__c> listFinancialSummary = new List<Applicant_Financial_Summary__c>();
List<Applicant_Financial_Summary__c> lstFinancialYrs = new List<Applicant_Financial_Summary__c>();

//lstFinancialYrs = [select Financial_Year__c from Applicant_Financial_Summary__c];

listFinancialSummary = [select Applicant_Financial__r.Loan_Applicant__r.TabName__c,ID,Liabilities__c,EBITDA__c,Financial_Year__c,Profit_Before_Depreciation_and_Tax_PBDT__c,
PAT__c,Profit_Before_Tax__c,Assets__c,Debtors__c,Sundry_creditors__c from Applicant_Financial_Summary__c WHERE Applicant_Financial__r.Loan_Applicant__r.LoanAppln__c='a08C4000005yfVKIAY'];

if(!listFinancialSummary.isEmpty()){
for(Applicant_Financial_Summary__c fy: listFinancialSummary){

GetFinancialSummariesRecordsWrapper FinancialSummaryRecordsWrapper = new GetFinancialSummariesRecordsWrapper();

if(fy.Financial_Year__c == String.valueOf(currentFY)){
FinancialSummaryRecordsWrapper.mapOfCurrentFyRecordsWrapp = new Map<String,Applicant_Financial_Summary__c>();
FinancialSummaryRecordsWrapper.mapOfCurrentFyRecordsWrapp.put(fy.Financial_Year__c,fy);
}
if(fy.Financial_Year__c == String.valueOf(currentFYMinus1)){
FinancialSummaryRecordsWrapper.mapOfCurrentFyMinus1RecordsWrapp = new Map<String,Applicant_Financial_Summary__c>();
FinancialSummaryRecordsWrapper.mapOfCurrentFyMinus1RecordsWrapp.put(fy.Financial_Year__c,fy);
}
if(fy.Financial_Year__c == String.valueOf(currentFYMinus2)){
FinancialSummaryRecordsWrapper.mapOfCurrentFyMinus2RecordsWrapp.put(fy.Financial_Year__c,fy);
}
if(fy.Financial_Year__c == String.valueOf(currentFYMinus3)){
FinancialSummaryRecordsWrapper.mapOfCurrentFyMinus3RecordsWrapp = new Map<String,Applicant_Financial_Summary__c>();
FinancialSummaryRecordsWrapper.mapOfCurrentFyMinus3RecordsWrapp.put(fy.Financial_Year__c,fy);
}
FinancialSummaryRecordsWrapper.lstFinancialYearsWrapp = new List<Applicant_Financial_Summary__c>();
//FinancialSummaryRecordsWrapper.lstFinancialYearsWrapp =lstFinancialYrs;
FyWrapperList.add(FinancialSummaryRecordsWrapper);
}
}
system.debug('FyWrapperList-->'+FyWrapperList);
return FyWrapperList;

}

// wrapper class with @AuraEnabled and {get;set;} properties 
public class GetFinancialSummariesRecordsWrapper{

@AuraEnabled
public List<Applicant_Financial_Summary__c> lstFinancialYearsWrapp{get;set;}
@AuraEnabled
public Map<String,Applicant_Financial_Summary__c> mapOfCurrentFyRecordsWrapp {get;set;}
@AuraEnabled
public Map<String,Applicant_Financial_Summary__c> mapOfCurrentFyMinus1RecordsWrapp{get;set;}
@AuraEnabled
public Map<String,Applicant_Financial_Summary__c> mapOfCurrentFyMinus2RecordsWrapp{get;set;}
@AuraEnabled
public Map<String,Applicant_Financial_Summary__c> mapOfCurrentFyMinus3RecordsWrapp{get;set;}
}*/
}