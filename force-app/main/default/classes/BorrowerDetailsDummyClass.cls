public with sharing class BorrowerDetailsDummyClass {
    //dummy class and method for testing
   
   /* @AuraEnabled(Cacheable=true)
public Static List<ConsoilidateFinancialWrapper> getfinancialSatement() {
    Map<string, Map<string, Map<string, decimal>>> outerfinancialSummaryMap = new Map<string, Map<string, Map<string, decimal>>>();
    
    Map<string, Map<string, decimal>> financialSummaryMap = new map<string, Map<string, decimal>>();
    Map<string, String> innerfinancialMap = new map<string, String>();
   long lakh = 100000;
    Decimal Turnover;
    Decimal totalCurrentLiabilities;
    Decimal totalCurrentAssets;
    Decimal totalDebt;
    Decimal AdjustedNetWorth;
    Decimal stockValue;
    Decimal debtors;
    Decimal creditors;
    List<Applicant_Financial_Summary__c> financialStatementDate = [Select Id,Applicant_Financial__r.Loan_Applicant__c,Applicant_Financial__r.Loan_Applicant__r.TabName__c, Total_Sales__c , EBITDA__c , Profit_Before_Depreciation_and_Tax_PBDT__c, Profit_Before_Tax__c, PAT__c, Depreciation__c, 
                                                                   Interest_on_Partner_Capital__c, Salary_to_Partner_Directors__c, Non_Operating_Expenses_FxLoss_AssetLoss__c,
                                                                   Gross_Profit__c, Other_Operating_Income_IncomeIncidental__c, Sundry_creditors__c, Advances_from_customers__c,
                                                                   Other_current_liabilities__c, Provisions_for_exps_tax_etc__c, Bank_Borrowing_Working_Capital_OD_CC__c,
                                                                   Stock__c, Debtors__c, Advances_to_Suppliers__c, Investments__c, Prepaid_expenses__c, Other_current_assets__c,
                                                                   Cash_Bank_Balances__c, Total_Loan_funds__c, Adjusted_tangible_Netwroth__c, Opening_Stock__c, Purchases__c,
                                                                   Direct_Expenses__c, Closing_Stock__c, Interest_on_Term_Loans__c, Interest_on_CC_OD_limits__c,
                                                                   Applicant_Financial__r.Loan_Applicant__r.id, FinancialYearFor__c from Applicant_Financial_Summary__c
                                                                   where Applicant_Financial__r.Loan_Applicant__r.LoanAppln__r.id = 'a08C40000063xjHIAQ' Order BY FinancialYearFor__c ASC];
    
    FinancialRecordWrapper recordWrapper = new financialRecordWrapper();//assign the values;
    List<ConsoilidateFinancialWrapper> returnWrapper = new List<ConsoilidateFinancialWrapper>();
    Integer index = 0;
    For(Applicant_Financial_Summary__c finance: financialStatementDate){
        
        if (finance.Applicant_Financial__r.Loan_Applicant__r.TabName__c != null) {
            recordWrapper = new financialRecordWrapper();
            
            recordWrapper.Id = finance.Applicant_Financial__r.Loan_Applicant__c;//finance.Id;
            recordWrapper.Year =finance.FinancialYearFor__c;
            recordWrapper.borrowerName = finance.Applicant_Financial__r.Loan_Applicant__r.TabName__c;
           if(!innerfinancialMap.containsKey(recordWrapper.borrowerName)){
                index =0;
               innerfinancialMap.put(recordWrapper.borrowerName, '');
            }
                
            
            recordWrapper.turnOver = finance.Total_Sales__c != null ? finance.Total_Sales__c/lakh : 0;
            
           // innerfinancialMap.put('Turnover', Turnover);
            
            if (finance.EBITDA__c != null) {
                 recordWrapper.EBIDTA_PBDIT = (finance.EBITDA__c/lakh);
                if (finance.Interest_on_Term_Loans__c != null && finance.Interest_on_CC_OD_limits__c != null){
                   recordWrapper.interestCoverageRatio = (finance.EBITDA__c/(finance.Interest_on_Term_Loans__c+finance.Interest_on_CC_OD_limits__c)).setScale(2);
                } 
            }
            
            recordWrapper.PBDT = finance.Profit_Before_Depreciation_and_Tax_PBDT__c != null ? finance.Profit_Before_Depreciation_and_Tax_PBDT__c/lakh : 0;
            recordWrapper.PBT = finance.Profit_Before_Tax__c != null ? finance.Profit_Before_Tax__c/lakh : 0;
            recordWrapper.PAT = finance.PAT__c != null ? finance.PAT__c/lakh : 0;
           // System.debug('Ebidta');
            if (finance.PAT__c != null && finance.Depreciation__c != null && finance.Interest_on_Partner_Capital__c != null && finance.Non_Operating_Expenses_FxLoss_AssetLoss__c != null && finance.Salary_to_Partner_Directors__c != null) {
              recordWrapper.cashProfit = (finance.PAT__c+finance.Depreciation__c+finance.Interest_on_Partner_Capital__c+finance.Non_Operating_Expenses_FxLoss_AssetLoss__c+finance.Salary_to_Partner_Directors__c)/lakh;
            }
            //System.debug('Ebidta');
            if (finance.Gross_Profit__c != null && finance.Total_Sales__c !=null && finance.Other_Operating_Income_IncomeIncidental__c != null) {
                recordWrapper.grossProfitMargin = ((finance.Gross_Profit__c/(finance.Total_Sales__c+finance.Other_Operating_Income_IncomeIncidental__c))*100).setScale(2);
            } 
           // System.debug('Ebidta');
            if (finance.Profit_Before_Tax__c != null && finance.Total_Sales__c != null){
                recordWrapper.netProfitMargin = ((finance.Profit_Before_Tax__c/finance.Total_Sales__c)*100).setScale(2);
            }
           // System.debug('Ebidta');
            if (finance.Sundry_creditors__c != null && finance.Advances_from_customers__c != null && finance.Other_current_liabilities__c !=null && finance.Provisions_for_exps_tax_etc__c != null && finance.Bank_Borrowing_Working_Capital_OD_CC__c != null) {
                recordWrapper.totalCurrentLiabilities = finance.Sundry_creditors__c + finance.Advances_from_customers__c + finance.Other_current_liabilities__c + finance.Provisions_for_exps_tax_etc__c + finance.Bank_Borrowing_Working_Capital_OD_CC__c;
                //innerfinancialMap.put('totalCurrentLiabilities', totalCurrentLiabilities);
            }
           // System.debug('Ebidta');
            if (finance.Stock__c != null && finance.Debtors__c != null && finance.Advances_to_Suppliers__c != null && finance.Investments__c != null && finance.Prepaid_expenses__c != null && finance.Other_current_assets__c != null && finance.Cash_Bank_Balances__c != null) {
                recordWrapper.totalCurrentAssets = finance.Stock__c + finance.Debtors__c + finance.Advances_to_Suppliers__c + finance.Investments__c + finance.Prepaid_expenses__c + finance.Other_current_assets__c + finance.Cash_Bank_Balances__c;
               // innerfinancialMap.put('totalCurrentAssets', totalCurrentAssets);
            }
            if (finance.Total_Loan_funds__c != null && finance.Bank_Borrowing_Working_Capital_OD_CC__c != null) {
                recordWrapper.totalDebt = ((finance.Total_Loan_funds__c - finance.Bank_Borrowing_Working_Capital_OD_CC__c)/lakh).setScale(2);
               // innerfinancialMap.put('totalDebt', (totalDebt).setScale(2));
            }
            if (finance.Adjusted_tangible_Netwroth__c != null) {
                recordWrapper.adjustedNetworth = (finance.Adjusted_tangible_Netwroth__c/lakh).setScale(2);
               // innerfinancialMap.put('AdjustedNetWorth', (finance.Adjusted_tangible_Netwroth__c/lakh).setScale(2));
                if (recordWrapper.totalDebt != null) {
                    recordWrapper.debtEquityRatio = (recordWrapper.totalDebt/recordWrapper.adjustedNetworth).setScale(2);
                    if (recordWrapper.totalCurrentLiabilities != null) {
                        recordWrapper.laverageRatio = ((recordWrapper.totalDebt+recordWrapper.totalCurrentLiabilities)/recordWrapper.adjustedNetworth).setScale(2);
                    }
                }
            }
            if(finance.Stock__c != null){
            recordWrapper.stockValue = (finance.Stock__c/lakh != null ? finance.Stock__c/lakh : 0).setScale(2);
        }
           // innerfinancialMap.put('stockValue', (stockValue).setScale(2));
            if (recordWrapper.totalCurrentAssets!=null && recordWrapper.totalCurrentLiabilities != null) {
                recordWrapper.networkingCapital = recordWrapper.totalCurrentAssets-recordWrapper.totalCurrentLiabilities;
                recordWrapper.currentRatio = (recordWrapper.totalCurrentAssets/recordWrapper.totalCurrentLiabilities).setScale(2);
                if (recordWrapper.stockValue != null) {
                     recordWrapper.quickRatio =((recordWrapper.totalCurrentAssets-recordWrapper.stockValue)/recordWrapper.totalCurrentLiabilities).setScale(2);
                } 
            }
            if (finance.Debtors__c != null) {
                recordWrapper.debtors = finance.Debtors__c/lakh;
               // innerfinancialMap.put('debtors', debtors);
               recordWrapper.debtorsCollectionPeriod =  finance.Total_Sales__c != null ? ((recordWrapper.debtors*lakh)/(finance.Total_Sales__c*365)).setScale(2): 0;
            }
            if (finance.Sundry_creditors__c != null) {
                recordWrapper.creditors = finance.Sundry_creditors__c/lakh;
                //innerfinancialMap.put('creditors',creditors);
               recordWrapper.creditorsPayementPeriod = finance.Purchases__c != null ? ((recordWrapper.creditors*lakh)/finance.Purchases__c).setScale(2) : 0;
            }
            if (finance.Opening_Stock__c != null && finance.Purchases__c != null && finance.Direct_Expenses__c != null && finance.Closing_Stock__c != null) {
                recordWrapper.inventryTorunOver = ((finance.Opening_Stock__c+finance.Purchases__c+finance.Direct_Expenses__c-finance.Closing_Stock__c)/((finance.Opening_Stock__c+finance.Closing_Stock__c)/2)).setScale(2);
                recordWrapper.stockReplenishnentPeriod = finance.Stock__c != null ? ((finance.Stock__c/(finance.Opening_Stock__c+finance.Purchases__c+finance.Direct_Expenses__c-finance.Closing_Stock__c))*365).setScale(2) : 0;
                //innerfinancialMap.put('Stock replenishment period (days)', finance.Stock__c != null ? ((finance.Stock__c/(finance.Opening_Stock__c+finance.Purchases__c+finance.Direct_Expenses__c-finance.Closing_Stock__c))*365).setScale(2) : 0);
            }
           // financialSummaryMap.put(finance.FinancialYearFor__c, innerfinancialMap);
           // outerfinancialSummaryMap.put(borrowername, financialSummaryMap);
         }
       //  returnWrapper = new ConsoilidateFinancialWrapper();
        if(recordWrapper.borrowerName != finance.Applicant_Financial__r.Loan_Applicant__r.TabName__c){
            index = 0;
        }
       ConsoilidateFinancialWrapper lstWrapperData = new ConsoilidateFinancialWrapper();
        if(index == 0){
            
           // returnWrapper = new ConsoilidateFinancialWrapper();
            lstWrapperData.lastFinancialYear =recordWrapper;
            lstWrapperData.previousFinancialRecord = true;
            lstWrapperData.finacialYear1 = finance.FinancialYearFor__c;
            lstWrapperData.Id = recordWrapper.Id;
            
        }else if(index==1){
           // ConsoilidateFinancialWrapper lstWrapperData = new ConsoilidateFinancialWrapper();
          //  returnWrapper = new ConsoilidateFinancialWrapper();
            lstWrapperData.currentFinancialYear = recordWrapper;
            lstWrapperData.currentFinancialRecord = true;
            lstWrapperData.finacialYear2 = finance.FinancialYearFor__c;
            lstWrapperData.Id = recordWrapper.Id;
          //  returnWrapper.add(lstWrapperData);
        }else if (index==2){
            //ConsoilidateFinancialWrapper lstWrapperData = new ConsoilidateFinancialWrapper();
           // returnWrapper = new ConsoilidateFinancialWrapper();
            lstWrapperData.provisionalFinancialYear = recordWrapper;
            lstWrapperData.provisionFinancialRecord = true;
            lstWrapperData.finacialYear3 = finance.FinancialYearFor__c;
            lstWrapperData.Id = recordWrapper.Id;
           // returnWrapper.add(lstWrapperData);
        }
        index++;
        returnWrapper.add(lstWrapperData);
 }
    
    //keylist = outerfinancialSummaryMap.keySet();
 //   System.debug('outerfinancialSummaryMap '+ outerfinancialSummaryMap);
      System.debug('returnWrapper-->'+ returnWrapper);
    return returnWrapper;
}*/

@AuraEnabled(Cacheable=true)
public Static Map<Id,ConsoilidateFinancialWrapper> getfinancialSatement(String recordId) {
    Map<string, Map<string, Map<string, decimal>>> outerfinancialSummaryMap = new Map<string, Map<string, Map<string, decimal>>>();
    
    Map<string, Map<string, decimal>> financialSummaryMap = new map<string, Map<string, decimal>>();
    Map<string, String> innerfinancialMap = new map<string, String>();
   long lakh = 100000;
    Decimal Turnover;
    Decimal totalCurrentLiabilities;
    Decimal totalCurrentAssets;
    Decimal totalDebt;
    Decimal AdjustedNetWorth;
    Decimal stockValue;
    Decimal debtors;
    Decimal creditors;
    List<Applicant_Financial_Summary__c> financialStatementDate = [Select Id,Applicant_Financial__r.Loan_Applicant__c,Applicant_Financial__r.Loan_Applicant__r.TabName__c, Total_Sales__c , EBITDA__c , Profit_Before_Depreciation_and_Tax_PBDT__c, Profit_Before_Tax__c, PAT__c, Depreciation__c, 
                                                                   Interest_on_Partner_Capital__c, Salary_to_Partner_Directors__c, Non_Operating_Expenses_FxLoss_AssetLoss__c,
                                                                   Gross_Profit__c, Other_Operating_Income_IncomeIncidental__c, Sundry_creditors__c, Advances_from_customers__c,
                                                                   Other_current_liabilities__c, Provisions_for_exps_tax_etc__c, Bank_Borrowing_Working_Capital_OD_CC__c,
                                                                   Stock__c, Debtors__c, Advances_to_Suppliers__c, Investments__c, Prepaid_expenses__c, Other_current_assets__c,
                                                                   Cash_Bank_Balances__c, Total_Loan_funds__c, Adjusted_tangible_Netwroth__c, Opening_Stock__c, Purchases__c,
                                                                   Direct_Expenses__c, Closing_Stock__c, Interest_on_Term_Loans__c, Interest_on_CC_OD_limits__c,
                                                                   Applicant_Financial__r.Loan_Applicant__r.id, FinancialYearFor__c from Applicant_Financial_Summary__c
                                                                   where Applicant_Financial__r.Loan_Applicant__r.LoanAppln__r.id = 'a08C4000007x0uSIAQ' Order BY FinancialYearFor__c ASC]; // old id a08C40000063xjHIAQ
    
    FinancialRecordWrapper recordWrapper = new financialRecordWrapper();//assign the values;
    //ConsoilidateFinancialWrapper returnWrapper = new ConsoilidateFinancialWrapper();
    List<ConsoilidateFinancialWrapper> returnWrapper = new List<ConsoilidateFinancialWrapper>();
    Map<Id,ConsoilidateFinancialWrapper> applicantToFinancialWrap = new Map<Id,ConsoilidateFinancialWrapper>();
    Integer index = 0;
    For(Applicant_Financial_Summary__c finance: financialStatementDate){
        
        if (finance.Applicant_Financial__r.Loan_Applicant__r.TabName__c != null) {
            recordWrapper = new financialRecordWrapper();
           	
            
            recordWrapper.Id = finance.Applicant_Financial__r.Loan_Applicant__c;//finance.Id;
            recordWrapper.Year =finance.FinancialYearFor__c;
             
            recordWrapper.borrowerName = finance.Applicant_Financial__r.Loan_Applicant__r.TabName__c;
            // if(recordWrapper.borrowerName !=null && recordWrapper.borrowerName != finance.Applicant_Financial__r.Loan_Applicant__r.TabName__c){
            //     index =0;
            // }
            /*if(innerfinancialMap.containsKey(recordWrapper.borrowerName)==false){
                index =0;
                innerfinancialMap.put(recordWrapper.borrowerName, '');
            }*/
                
            if(finance.Total_Sales__c !=null){
            recordWrapper.turnOver = finance.Total_Sales__c != null ? finance.Total_Sales__c/lakh : 0;
        }
           // innerfinancialMap.put('Turnover', Turnover);
            /*if (financialSummaryMap.get(string.valueof(Integer.valueof(finance.FinancialYearFor__c)-1))!=null) {
                Decimal TurnoverGrowthRatio=(Turnover-financialSummaryMap.get(string.valueof(Integer.valueof(finance.FinancialYearFor__c)-1)).get('Turnover'))*100;
            }*/
            if (finance.EBITDA__c != null) {
                 recordWrapper.EBIDTA_PBDIT = (finance.EBITDA__c/lakh);
                if (finance.Interest_on_Term_Loans__c != null && finance.Interest_on_CC_OD_limits__c != null){
                   recordWrapper.interestCoverageRatio = (finance.EBITDA__c/(finance.Interest_on_Term_Loans__c+finance.Interest_on_CC_OD_limits__c)).setScale(2);
                } 
            }
            
            recordWrapper.PBDT = finance.Profit_Before_Depreciation_and_Tax_PBDT__c != null ? finance.Profit_Before_Depreciation_and_Tax_PBDT__c/lakh : 0;
            recordWrapper.PBT = finance.Profit_Before_Tax__c != null ? finance.Profit_Before_Tax__c/lakh : 0;
            recordWrapper.PAT = finance.PAT__c != null ? finance.PAT__c/lakh : 0;
           // System.debug('Ebidta');
            if (finance.PAT__c != null && finance.Depreciation__c != null && finance.Interest_on_Partner_Capital__c != null && finance.Non_Operating_Expenses_FxLoss_AssetLoss__c != null && finance.Salary_to_Partner_Directors__c != null) {
              recordWrapper.cashProfit = (finance.PAT__c+finance.Depreciation__c+finance.Interest_on_Partner_Capital__c+finance.Non_Operating_Expenses_FxLoss_AssetLoss__c+finance.Salary_to_Partner_Directors__c)/lakh;
            }
            //System.debug('Ebidta');
            if (finance.Gross_Profit__c != null && finance.Total_Sales__c !=null && finance.Other_Operating_Income_IncomeIncidental__c != null) {
                recordWrapper.grossProfitMargin = ((finance.Gross_Profit__c/(finance.Total_Sales__c+finance.Other_Operating_Income_IncomeIncidental__c))*100).setScale(2);
            } 
           // System.debug('Ebidta');
            if (finance.Profit_Before_Tax__c != null && finance.Total_Sales__c != null){
                recordWrapper.netProfitMargin = ((finance.Profit_Before_Tax__c/finance.Total_Sales__c)*100).setScale(2);
            }
           // System.debug('Ebidta');
            if (finance.Sundry_creditors__c != null && finance.Advances_from_customers__c != null && finance.Other_current_liabilities__c !=null && finance.Provisions_for_exps_tax_etc__c != null && finance.Bank_Borrowing_Working_Capital_OD_CC__c != null) {
                recordWrapper.totalCurrentLiabilities = finance.Sundry_creditors__c + finance.Advances_from_customers__c + finance.Other_current_liabilities__c + finance.Provisions_for_exps_tax_etc__c + finance.Bank_Borrowing_Working_Capital_OD_CC__c;
                //innerfinancialMap.put('totalCurrentLiabilities', totalCurrentLiabilities);
            }
           // System.debug('Ebidta');
            if (finance.Stock__c != null && finance.Debtors__c != null && finance.Advances_to_Suppliers__c != null && finance.Investments__c != null && finance.Prepaid_expenses__c != null && finance.Other_current_assets__c != null && finance.Cash_Bank_Balances__c != null) {
                recordWrapper.totalCurrentAssets = finance.Stock__c + finance.Debtors__c + finance.Advances_to_Suppliers__c + finance.Investments__c + finance.Prepaid_expenses__c + finance.Other_current_assets__c + finance.Cash_Bank_Balances__c;
               // innerfinancialMap.put('totalCurrentAssets', totalCurrentAssets);
            }
            if (finance.Total_Loan_funds__c != null && finance.Bank_Borrowing_Working_Capital_OD_CC__c != null) {
                recordWrapper.totalDebt = ((finance.Total_Loan_funds__c - finance.Bank_Borrowing_Working_Capital_OD_CC__c)/lakh).setScale(2);
               // innerfinancialMap.put('totalDebt', (totalDebt).setScale(2));
            }
            if (finance.Adjusted_tangible_Netwroth__c != null) {
                recordWrapper.adjustedNetworth = (finance.Adjusted_tangible_Netwroth__c/lakh).setScale(2);
               // innerfinancialMap.put('AdjustedNetWorth', (finance.Adjusted_tangible_Netwroth__c/lakh).setScale(2));
                if (recordWrapper.totalDebt != null) {
                    recordWrapper.debtEquityRatio = (recordWrapper.totalDebt/recordWrapper.adjustedNetworth).setScale(2);
                    if (recordWrapper.totalCurrentLiabilities != null) {
                        recordWrapper.laverageRatio = ((recordWrapper.totalDebt+recordWrapper.totalCurrentLiabilities)/recordWrapper.adjustedNetworth).setScale(2);
                    }
                }
            }
            if(finance.Stock__c != null){
            recordWrapper.stockValue = (finance.Stock__c/lakh != null ? finance.Stock__c/lakh : 0).setScale(2);
        }
           // innerfinancialMap.put('stockValue', (stockValue).setScale(2));
            if (recordWrapper.totalCurrentAssets!=null && recordWrapper.totalCurrentLiabilities != null) {
                recordWrapper.networkingCapital = recordWrapper.totalCurrentAssets-recordWrapper.totalCurrentLiabilities;
                recordWrapper.currentRatio = (recordWrapper.totalCurrentAssets/recordWrapper.totalCurrentLiabilities).setScale(2);
                if (recordWrapper.stockValue != null) {
                     recordWrapper.quickRatio =((recordWrapper.totalCurrentAssets-recordWrapper.stockValue)/recordWrapper.totalCurrentLiabilities).setScale(2);
                } 
            }
            if (finance.Debtors__c != null) {
                recordWrapper.debtors = finance.Debtors__c/lakh;
               // innerfinancialMap.put('debtors', debtors);
               recordWrapper.debtorsCollectionPeriod =  finance.Total_Sales__c != null ? ((recordWrapper.debtors*lakh)/(finance.Total_Sales__c*365)).setScale(2): 0;
            }
            if (finance.Sundry_creditors__c != null) {
                recordWrapper.creditors = finance.Sundry_creditors__c/lakh;
                //innerfinancialMap.put('creditors',creditors);
               recordWrapper.creditorsPayementPeriod = finance.Purchases__c != null ? ((recordWrapper.creditors*lakh)/finance.Purchases__c).setScale(2) : 0;
            }
            if (finance.Opening_Stock__c != null && finance.Purchases__c != null && finance.Direct_Expenses__c != null && finance.Closing_Stock__c != null) {
                recordWrapper.inventryTorunOver = ((finance.Opening_Stock__c+finance.Purchases__c+finance.Direct_Expenses__c-finance.Closing_Stock__c)/((finance.Opening_Stock__c+finance.Closing_Stock__c)/2)).setScale(2);
                recordWrapper.stockReplenishnentPeriod = finance.Stock__c != null ? ((finance.Stock__c/(finance.Opening_Stock__c+finance.Purchases__c+finance.Direct_Expenses__c-finance.Closing_Stock__c))*365).setScale(2) : 0;
                //innerfinancialMap.put('Stock replenishment period (days)', finance.Stock__c != null ? ((finance.Stock__c/(finance.Opening_Stock__c+finance.Purchases__c+finance.Direct_Expenses__c-finance.Closing_Stock__c))*365).setScale(2) : 0);
            }
           // financialSummaryMap.put(finance.FinancialYearFor__c, innerfinancialMap);
           // outerfinancialSummaryMap.put(borrowername, financialSummaryMap);
           	ConsoilidateFinancialWrapper wrapObj;
            if(applicantToFinancialWrap.containsKey(finance.Applicant_Financial__r.Loan_Applicant__c)){
                wrapObj = applicantToFinancialWrap.get(finance.Applicant_Financial__r.Loan_Applicant__c);
                if(wrapObj.currentFinancialYear == null){
                    wrapObj.currentFinancialYear = recordWrapper;
                    wrapObj.currentFinancialRecord = true;
                    wrapObj.finacialYear2 = finance.FinancialYearFor__c;
                    //wrapObj.Id = recordWrapper.Id;
                }else{
                   	wrapObj.provisionalFinancialYear = recordWrapper;
                    wrapObj.provisionFinancialRecord = true;
                    wrapObj.finacialYear3 = finance.FinancialYearFor__c;
                    //wrapObj.Id = recordWrapper.Id;
                }
                applicantToFinancialWrap.put(finance.Applicant_Financial__r.Loan_Applicant__c,wrapObj);
            }else{
               	wrapObj = new ConsoilidateFinancialWrapper();
                wrapObj.lastFinancialYear = recordWrapper;
                wrapObj.previousFinancialRecord = true;
                wrapObj.finacialYear1 = finance.FinancialYearFor__c;
            	//wrapObj.Id = recordWrapper.Id;
                applicantToFinancialWrap.put(finance.Applicant_Financial__r.Loan_Applicant__c,wrapObj);
            }
         }
        
        
        // returnWrapper = new ConsoilidateFinancialWrapper();
        /*ConsoilidateFinancialWrapper lstWrapperData = new ConsoilidateFinancialWrapper();
        if(index == 0){
           // ConsoilidateFinancialWrapper lstWrapperData = new ConsoilidateFinancialWrapper();
           // returnWrapper = new ConsoilidateFinancialWrapper();
            lstWrapperData.lastFinancialYear =recordWrapper;
            lstWrapperData.previousFinancialRecord = true;
            lstWrapperData.finacialYear1 = finance.FinancialYearFor__c;
            lstWrapperData.Id = recordWrapper.Id;
          //  returnWrapper.add(lstWrapperData);
        }else if(index==1){
          //  ConsoilidateFinancialWrapper lstWrapperData = new ConsoilidateFinancialWrapper();
          //  returnWrapper = new ConsoilidateFinancialWrapper();
            lstWrapperData.currentFinancialYear = recordWrapper;
            lstWrapperData.currentFinancialRecord = true;
            lstWrapperData.finacialYear2 = finance.FinancialYearFor__c;
            lstWrapperData.Id = recordWrapper.Id;
           // returnWrapper.add(lstWrapperData);
        }else if (index==2){
          //  ConsoilidateFinancialWrapper lstWrapperData = new ConsoilidateFinancialWrapper();
           // returnWrapper = new ConsoilidateFinancialWrapper();
            lstWrapperData.provisionalFinancialYear = recordWrapper;
            lstWrapperData.provisionFinancialRecord = true;
            lstWrapperData.finacialYear3 = finance.FinancialYearFor__c;
            lstWrapperData.Id = recordWrapper.Id;
            //returnWrapper.add(lstWrapperData);
        }
        index++;
        returnWrapper.add(lstWrapperData);*/
 }
    //keylist = outerfinancialSummaryMap.keySet();
 //   System.debug('outerfinancialSummaryMap '+ outerfinancialSummaryMap);
      System.debug('returnWrapper-->'+ returnWrapper);
    //return Map<Id,ConsoilidateFinancialWrapper>
    system.debug(applicantToFinancialWrap);
    return applicantToFinancialWrap;
}

public class FinancialRecordWrapper{
    @AuraEnabled
    public String Year{get;set;}
    @AuraEnabled
    public String Id{get;set;}
    @AuraEnabled
    public String borrowerName{get;set;}
    @AuraEnabled
    public decimal turnOver{get;set;}
    @AuraEnabled
    public decimal turnOverGrowthRate{get;set;}
    @AuraEnabled
    public decimal EBIDTA_PBDIT{get;set;}
    @AuraEnabled
    public decimal PBDT{get;set;}
    @AuraEnabled
    public decimal PBT{get;set;}
    @AuraEnabled
    public decimal PAT{get;set;}
    @AuraEnabled
    public decimal cashProfit{get;set;}
    @AuraEnabled
    public decimal grossProfitMargin{get;set;}
    @AuraEnabled
    public decimal netProfitMargin{get;set;}
    @AuraEnabled
    public decimal totalCurrentLiabilities{get;set;}
    @AuraEnabled
    public decimal totalCurrentAssets{get;set;}
    @AuraEnabled
    public decimal totalDebt{get;set;}
    @AuraEnabled
    public decimal adjustedNetworth{get;set;}
    @AuraEnabled
    public decimal debtors{get;set;}
    @AuraEnabled
    public decimal creditors{get;set;}
    @AuraEnabled
    public decimal stockValue{get;set;}
    @AuraEnabled
    public decimal debtorsCollectionPeriod{get;set;}
    @AuraEnabled
    public decimal creditorsPayementPeriod{get;set;}
    @AuraEnabled
    public decimal stockReplenishnentPeriod{get;set;} 
    @AuraEnabled
    public decimal inventryTorunOver{get;set;}
    @AuraEnabled
    public decimal networkingCapital{get;set;}
    @AuraEnabled
    public decimal currentRatio{get;set;}
    @AuraEnabled
    public decimal quickRatio{get;set;}
    @AuraEnabled
    public decimal interestCoverageRatio{get;set;}
    @AuraEnabled
    public decimal debtEquityRatio{get;set;}
    @AuraEnabled
    public decimal laverageRatio{get;set;}
       
      
  }
  
  Public class ConsoilidateFinancialWrapper{
      @AuraEnabled
      Public FinancialRecordWrapper lastFinancialYear{get;set;}
      @AuraEnabled
      Public FinancialRecordWrapper currentFinancialYear{get;set;}
      @AuraEnabled
      Public FinancialRecordWrapper provisionalFinancialYear{get;set;}
      @AuraEnabled
      public Boolean currentFinancialRecord{get;set;}
      @AuraEnabled
         public Boolean previousFinancialRecord{get;set;}
      @AuraEnabled
      public Boolean provisionFinancialRecord{get;set;}
      @AuraEnabled
      Public String finacialYear1{get;set;}
      @AuraEnabled
      Public String finacialYear2{get;set;}
      @AuraEnabled
      Public String finacialYear3{get;set;}
      @AuraEnabled
      Public String Id{get;set;}
      
  }
    
    @AuraEnabled(cacheable=true)
    public static List<getBoroowerDetailsWrapper> getBorrowerDetails(){
        try{
            List<getBoroowerDetailsWrapper> borrowerwrapperData = new List<getBoroowerDetailsWrapper>();
            List<Applicant__c>  listOfApplicantDetails = [Select id, FullName__c, TabName__c, ApplType__c, CustProfile__c, Constitution__c, Gender__c, Relationship__c, Age__c, UCID__c, Type_of_Borrower__c,LoanAppln__r.Loan_Tenure_Months__c, (select Id, Prop_Owners__c from Applicant_Assets__r), (Select Id,Score__c from Bureau_Responses__r order by Score__c,createddate desc ) from Applicant__c where LoanAppln__c='a08C4000006Ayh2IAC'];
            if(listOfApplicantDetails.size()>0){
                
                system.debug('listOfApplicantDetails-->'+listOfApplicantDetails);
                
                for(Applicant__c appln: listOfApplicantDetails){
                    
                    getBoroowerDetailsWrapper getWrapperData = new getBoroowerDetailsWrapper();
                    getWrapperData.applicantListForBorrowerWrapper = appln;
                    
                    if(appln.Type_of_Borrower__c != null && appln.Type_of_Borrower__c =='Financial'){
                        getWrapperData.financialBorrowerWrapper = 'Yes';
                    }
                    
                    if(appln.Age__c != null && appln.LoanAppln__r.Loan_Tenure_Months__c !=null){
                        
                        system.debug('Age-->'+appln.Age__c);
                        system.debug('Loan Tenure Months-->'+appln.LoanAppln__r.Loan_Tenure_Months__c);
                        
                        Decimal ageMaturity =0;
                        Integer ageAtMaturity;
                        ageMaturity = appln.Age__c + appln.LoanAppln__r.Loan_Tenure_Months__c/12;
                        ageAtMaturity = ageMaturity.intValue();
                        getWrapperData.ageAtLonaMaturityWrapper = ageAtMaturity;
                        system.debug('getWrapperData.ageAtLonaMaturityWrapper-->'+getWrapperData.ageAtLonaMaturityWrapper);
                    }
                    
                    List<ApplAsset__c> applAsstList = appln.Applicant_Assets__r;
                    List<Bureau__c> bureauList = appln.Bureau_Responses__r;
                    system.debug('applAsstList-->'+applAsstList);
                    system.debug('bureauList-->'+bureauList);
                    
                    for(ApplAsset__c applAss: applAsstList){
                        
                        if(applAss.Prop_Owners__c !=null){
                            getWrapperData.propertyOwnerWrapper = 'Yes';
                        }
                        else{
                            getWrapperData.propertyOwnerWrapper = 'No';
                        }                        
                        
                    }
                    
                    for(Bureau__c bu: bureauList){
                        
                        if(bu.Score__c !=null){
                            getWrapperData.scoreWrapper = bu.Score__c;
                            break;
                        } 
                    }
                    
                    borrowerwrapperData.add(getWrapperData);
                }
                system.debug('borrowerwrapperData-->'+borrowerwrapperData);
            }
            return null;
        }
        Catch (exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static list<getDecisionSummaryWrapper> getDecisionSummary(){
        try{
            //
            List<getDecisionSummaryWrapper> decisionWrapperData = new List<getDecisionSummaryWrapper>();
            list<UWDecision__c>  listDecisionSummary = [select Id,name,LoanAppl__c,User__c,User__r.Name,Decision__c,DecisionRmrks__c,PrsnldetailsofPromotrs__c,BDApplicantCoapp__c,IncomerelateComm__c,AddationalComm__c,DecisionDt__c from UWDecision__c where LoanAppl__c='a08C4000006Ayh2IAC'];
            if(listDecisionSummary.size()>0){
                
                system.debug('listDecisionSummary-->'+listDecisionSummary);
                
                for(UWDecision__c decision: listDecisionSummary){
                    
                    getDecisionSummaryWrapper getDecisionWrapperData = new getDecisionSummaryWrapper();
                    getDecisionWrapperData.listDecisionSummaryWrapper = decision;
                    
                    if(decision.Decision__c != null && decision.Decision__c =='Forward'){
                        getDecisionWrapperData.fedfinaUnderwriterWrapp = decision.User__r.Name;
                        system.debug('fedfinaUnderwriterWrapp-->'+getDecisionWrapperData.fedfinaUnderwriterWrapp);
                        
                    }
                    if(decision.Decision__c != null && decision.Decision__c =='Approved'){
                        getDecisionWrapperData.fedfinaApproverWrap = decision.User__r.Name;
                        system.debug('fedfinaApproverWrap-->'+getDecisionWrapperData.fedfinaUnderwriterWrapp);
                    }
                    
                    decisionWrapperData.add(getDecisionWrapperData);
                }
                system.debug('decisionWrapperData-->'+decisionWrapperData);
                system.debug('decisionWrapperData-->'+decisionWrapperData.size());
                
            }
            return decisionWrapperData;
        }
        Catch (exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<getBankingDetailsSummaryForCASAWrapper> getBankingDetailsSummaryForCASA(){
        try {
            
            List<getBankingDetailsSummaryForCASAWrapper> listBankingDetailsSummaryWrapper = new List<getBankingDetailsSummaryForCASAWrapper>(); 
            
            List<ApplBanking__c> listBankingDetailsSummaryCASA = [Select Id, name,Appl__r.Id,Type__c , 
                                                                  Appl__r.LoanAppln__r.id,Summary_Type__c,Appl__r.TabName__c,Appl__c ,
                                                                  (Select id,Month__c,Year__c,ValueSummationDebit__c,ValueSummationCredit__c,CountofDebit__c,
                                                                   CountofCredit__c,InwardReturnsCount__c,OutwardReturnsCount__c,StopPaymentCount__c,MinBalanceCharges__c,
                                                                   AverageBankBalance__c from Applicant_Banking_Detail__r) 
                                                                  from ApplBanking__c where Type__c ='Banking Summary'
                                                                  and Appl__c IN (Select id from Applicant__c where LoanAppln__c ='a08C40000063xjHIAQ') 
                                                                  and Summary_Type__c ='Combined Banking (CASA)'];
            /*   [select Id,ApplBanking__r.Appl__r.TabName__c,Month__c,Year__c,ValueSummationDebit__c,
ValueSummationCredit__c,CountofDebit__c,CountofCredit__c,InwardReturnsCount__c,
OutwardReturnsCount__c,StopPaymentCount__c,MinBalanceCharges__c,AverageBankBalance__c,
ApplBanking__r.Limit__c from ApplBankDetail__c where ApplBanking__r.LoanAppl__c='a08C40000063xjHIAQ' 
AND ApplBanking__r.AccountType__c IN('JOINT','CURRENT','SAVINGS') ];  //a08C40000063xjHIAQ//used other component loan application id is a08C4000005yfVKIAY
*/        
            decimal TotalVSD=0.0;
            decimal TotalVSC=0.0;
            decimal TotalCD=0.0;
            decimal TotalCC=0.0;
            decimal TotalIRC=0.0;
            decimal TotalORC=0.0;
            decimal TotalSPC=0.0;
            decimal TotalABB=0.0;
            
            decimal AverageVSD=0.0;
            decimal AverageVSC=0.0;
            decimal AverageCD=0.0;
            decimal AverageCC=0.0;
            decimal AverageIRC=0.0;
            decimal AverageORC=0.0;
            decimal AverageSPC=0.0;
            decimal AverageABB=0.0;
            
            
            if(listBankingDetailsSummaryCASA.size()>0){
                system.debug('listBankingDetailsSummaryCASA-->'+listBankingDetailsSummaryCASA);
                
                for(ApplBanking__c lstAppBank : listBankingDetailsSummaryCASA){
                    
                    getBankingDetailsSummaryForCASAWrapper wrapperData = new getBankingDetailsSummaryForCASAWrapper();
                    
                    if(lstAppBank!=null){
                    wrapperData.listApplicantBankingWrapper = lstAppBank;
                        }
                  /*  if(lstAppBank.Applicant_Banking_Detail__r !=null){
                    wrapperData.listApplicantBankingDetailWrapper = lstAppBank.Applicant_Banking_Detail__r;
                        }*/
                    
                    List<ApplBankDetail__c> listAppBank = lstAppBank.Applicant_Banking_Detail__r;
                    System.debug('listAppBankDetails-->'+listAppBank);
                     System.debug('listAppBankDetails-->'+listAppBank.size());
                    
                     
                    
                    for(ApplBankDetail__c appBankDetails : listAppBank){
                        
                          wrapperData.listApplicantBankingDetailWrapper = appBankDetails;
                            system.debug('wrapperData.listApplicantBankingDetailWrapper-->'+wrapperData.listApplicantBankingDetailWrapper);
                        
                        System.debug('appBankDetails-->'+appBankDetails);
                        TotalVSD += appBankDetails.ValueSummationDebit__c == null ? 0 : appBankDetails.ValueSummationDebit__c;
                        TotalVSC += appBankDetails.ValueSummationCredit__c == null ? 0 : appBankDetails.ValueSummationCredit__c;
                        TotalCD +=  appBankDetails.CountofDebit__c == null ? 0 : appBankDetails.CountofDebit__c;
                        TotalCC +=  appBankDetails.CountofCredit__c == null ? 0 : appBankDetails.CountofCredit__c;
                        TotalIRC += appBankDetails.InwardReturnsCount__c == null ? 0 : appBankDetails.InwardReturnsCount__c;
                        TotalORC += appBankDetails.OutwardReturnsCount__c == null ? 0 : appBankDetails.OutwardReturnsCount__c;
                        TotalSPC += appBankDetails.StopPaymentCount__c == null ? 0 : appBankDetails.StopPaymentCount__c;
                        TotalABB += appBankDetails.AverageBankBalance__c == null ? 0 : appBankDetails.AverageBankBalance__c; 
                        
                    }
                    system.debug('wrapperData.listApplicantBankingDetailWrapper-->'+wrapperData.listApplicantBankingDetailWrapper);
                   // system.debug('wrapperData.listApplicantBankingDetailWrapper-->'+wrapperData.listApplicantBankingDetailWrapper);
                    
                    wrapperData.totalValueSummationDebit = TotalVSD;
                    wrapperData.totalValueSummationCredit = TotalVSC;
                    wrapperData.totalCountDebit = TotalCD;
                    wrapperData.totalCountCredit = TotalCC;
                    wrapperData.totalInwardReturns = TotalIRC;
                    wrapperData.totalOutwardReturns = TotalORC;
                    wrapperData.totalStopPayment = TotalSPC;
                    wrapperData.totalAverageBankBalance = TotalABB;
                    
                    if (listAppBank.size()!=0) {
                        
                        AverageVSD = (TotalVSD/listAppBank.size()).setScale(2);
                        AverageVSC = (TotalVSC/listAppBank.size()).setScale(2);
                        AverageCD = (TotalCD/listAppBank.size()).setScale(2);
                        AverageCC = (TotalCC/listAppBank.size()).setScale(2);
                        AverageIRC = (TotalIRC/listAppBank.size()).setScale(2);
                        AverageORC = (TotalORC/listAppBank.size()).setScale(2);
                        AverageSPC = (TotalSPC/listAppBank.size()).setScale(2);
                        AverageABB = (TotalABB/listAppBank.size()).setScale(2);
                        
                        wrapperData.averageValueSummationDebit = AverageVSD;
                        wrapperData.averageValueSummationCredit = AverageVSC;
                        wrapperData.averageCountDebit = AverageCD;
                        wrapperData.averageCountCredit = AverageCC;
                        wrapperData.averageInwardReturns = AverageIRC;
                        wrapperData.averageOutwardReturns = AverageORC;
                        wrapperData.averageStopPayment = AverageSPC;
                        wrapperData.averageAverageBankBalance = AverageABB;
                        
                    }
                    
                    listBankingDetailsSummaryWrapper.add(wrapperData)  ;                 
                    
                }
                system.debug('listBankingDetailsSummaryWrapper-->'+listBankingDetailsSummaryWrapper);
                system.debug('listBankingDetailsSummaryWrapper-->'+listBankingDetailsSummaryWrapper.size());
                return listBankingDetailsSummaryWrapper;
            }
            else{
                return null;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    public class getBankingDetailsSummaryForCASAWrapper{
        
        @AuraEnabled
        public ApplBanking__c listApplicantBankingWrapper {get;set;}
        @AuraEnabled
        public ApplBankDetail__c listApplicantBankingDetailWrapper {get;set;}
        @AuraEnabled
        public Decimal totalValueSummationDebit {get;set;}
        @AuraEnabled
        public Decimal totalValueSummationCredit {get;set;}
        @AuraEnabled
        public Decimal totalCountDebit {get;set;}
        @AuraEnabled
        public Decimal totalCountCredit {get;set;}
        @AuraEnabled
        public Decimal totalInwardReturns {get;set;}
        @AuraEnabled
        public Decimal totalOutwardReturns {get;set;}
        @AuraEnabled
        public Decimal totalStopPayment {get;set;}
        @AuraEnabled
        public Decimal totalMinBalanceCharges {get;set;}
        @AuraEnabled
        public Decimal totalAverageBankBalance {get;set;}
        
        
        @AuraEnabled
        public Decimal averageValueSummationDebit {get;set;}
        @AuraEnabled
        public Decimal averageValueSummationCredit {get;set;}
        @AuraEnabled
        public Decimal averageCountDebit {get;set;}
        @AuraEnabled
        public Decimal averageCountCredit {get;set;}
        @AuraEnabled
        public Decimal averageInwardReturns {get;set;}
        @AuraEnabled
        public Decimal averageOutwardReturns {get;set;}
        @AuraEnabled
        public Decimal averageStopPayment {get;set;}
        @AuraEnabled
        public Decimal averageMinBalanceCharges {get;set;}
        @AuraEnabled
        public Decimal averageAverageBankBalance {get;set;}
        
    }
    
    public class getBoroowerDetailsWrapper{
        @AuraEnabled
        public Applicant__c applicantListForBorrowerWrapper {get;set;}
        @AuraEnabled
        public String propertyOwnerWrapper {get;set;}
        @AuraEnabled
        public String scoreWrapper {get;set;}
        @AuraEnabled
        public Integer ageAtLonaMaturityWrapper {get;set;}
        @AuraEnabled
        public String financialBorrowerWrapper {get;set;}
        
    }
    
    
    public class getDecisionSummaryWrapper{
        @AuraEnabled
        public UWDecision__c listDecisionSummaryWrapper {get;set;}
        @AuraEnabled
        public String fedfinaUnderwriterWrapp {get;set;}
        @AuraEnabled
        public String fedfinaApproverWrap {get;set;} 
    }
  public static BorrowerDetailsDummyClass parse(String json){
        return (BorrowerDetailsDummyClass) System.JSON.deserialize(json, BorrowerDetailsDummyClass.class);
    }
}