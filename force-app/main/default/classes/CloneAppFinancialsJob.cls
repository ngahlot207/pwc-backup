public class CloneAppFinancialsJob implements Queueable, Database.AllowsCallouts {
    private CloneLoanAppController.CloneLoanAppwrpr inputData;
    private String loanProduct;
    private Id clonedLoanAppId;
    
    public CloneAppFinancialsJob(
        CloneLoanAppController.CloneLoanAppwrpr inputData,
        String loanProduct,
        Id clonedLoanAppId
    ) {
        this.inputData = inputData;
        this.loanProduct = loanProduct;
        this.clonedLoanAppId = clonedLoanAppId;
    }
    
    public void execute(QueueableContext context) {
        try {
            Map<Id, Id> appWithOldIdMap = new Map<Id, Id>();
            List<SObject> recordsToClone = new List<SObject>();
            Map<Id, Id> appFinanceWithOldIdMap = new Map<Id, Id>();
          LoanAppl__c loanApp = [SELECT Id, Product__c, Stage__c, SubStage__c,LoginAcceptDate__c FROM LoanAppl__c WHERE Id = :inputdata.recordId LIMIT 1];
        Date todayDate = Date.today();
        Boolean loginAccData = true;
        Date comparisonDate = todayDate.addDays(-30);
        if (loanApp.LoginAcceptDate__c != null && loanApp.LoginAcceptDate__c <= comparisonDate) {
          loginAccData = false;
        }
            
            if (inputData.cloneReason != null) {
                List<Applicant__c> applicants = [
                    SELECT Id, ClonedFor__c
                    FROM Applicant__c
                    WHERE
                    LoanAppln__c = :clonedLoanAppId
                    AND ApplType__c IN ('P', 'C', 'G')
                ];
                
                if (!applicants.isEmpty()) {
                    for (Applicant__c applicant : applicants) {
                        appWithOldIdMap.put(applicant.ClonedFor__c, applicant.Id);
                    }
                }
                
                CloneMetadataUtility.CloneMtdUtilityWrpr returnDat = CloneMetadataUtility.getCloneStatus(
                    'ApplicantFinancial',
                    inputData.cloneReason
                );
                List<String> products = returnDat.productType.split(':');
                if (
                    (loginAccData==true && returnDat.cloneStatus != null &&
                    returnDat.cloneStatus == 'Yes' &&
                    products.contains(loanProduct) ) || (inputData.financial == true && loginAccData == false)
                ) {
                    Set<Id> applicantIds = appWithOldIdMap.keyset();
                    String applicantIdsString =
                        '(\'' +
                        String.join(new List<Id>(applicantIds), '\',\'') +
                        '\')';
                    String appFinQuery =
                        'SELECT ' +
                        returnDat.fields +
                        ' FROM Applicant_Financial__c WHERE Loan_Applicant__c IN ' +
                        applicantIdsString +
                        ' AND RecordType.Name IN (\'Balance Sheet\', \'GST\', \'Profit & Loss\')';
                    
                    System.debug('appFinQuery ==>> ' + appFinQuery);
                    
                    List<Applicant_Financial__c> applFinancials = Database.query(
                        appFinQuery
                    );
                    system.debug('applFinancials' + applFinancials);
                    if (!applFinancials.isEmpty()) {
                        for (Applicant_Financial__c appFinancial : applFinancials) {
                            Applicant_Financial__c clonedAppFinancial = appFinancial.clone(
                                false,
                                true,
                                false,
                                false
                            );
                            clonedAppFinancial.Loan_Applicant__c = appFinancial.Loan_Applicant__c !=
                                null
                                ? appWithOldIdMap.get(appFinancial.Loan_Applicant__c)
                                : null;
                            clonedAppFinancial.ClonedSource__c = appFinancial.Id;
                            recordsToClone.add(clonedAppFinancial);
                        }
                    }
                    // Insert cloned applicant Financial and update map with new IDs
                    insert recordsToClone;
                    
                    for (Integer i = 0; i < recordsToClone.size(); i++) {
                        appFinanceWithOldIdMap.put(
                            applFinancials[i].Id,
                            recordsToClone[i].Id
                        );
                    }
                    recordsToClone.clear();
                    
                    if (!appWithOldIdMap.keySet().isEmpty()) {
                        if (!appFinanceWithOldIdMap.keySet().isEmpty()) {
                            List<Applicant_Financial_Summary__c> appFinanSummaries = [
                                SELECT
                                Id,
                                Applicant_Financial__c,
                                Financial_Category__c,
                                Amount__c,
                                Financial_Year__c,
                                Liabilities__c,
                                Share_capital_Partner_s_Capital__c,
                                P_L_A_capital__c,
                                Revaluation_Reserves_Notional_Reserves__c,
                                Net_worth__c,
                                Adavces_to_group_co_friends__c,
                                unsecured_Loan_from_promoters_family_m__c,
                                Misc_Exp_Not_written_off__c,
                                Adjusted_tangible_Netwroth__c,
                                Bank_Borrowing_Working_Capital_OD_CC__c,
                                Secured_debts_Banks_Ndfc__c,
                                Unsecured_debts_Banks_Ndfc__c,
                                Other_Loans_From_private_parties__c,
                                Total_Loan_funds__c,
                                Sundry_creditors__c,
                                Advances_from_customers__c,
                                Other_current_liabilities__c,
                                Provisions_for_exps_tax_etc__c,
                                Deffered_Tax_Liability_Assets__c,
                                Total__c,
                                Assets__c,
                                Net_Tangible_Fixed_Assets_Including_Cap__c,
                                Net_Intangible_Fixed_Assets__c,
                                Stock__c,
                                Debtors__c,
                                LessSix_months__c,
                                Greaterthan6__c,
                                Advances_to_Suppliers__c,
                                Investments__c,
                                Other_loans_advances__c,
                                Prepaid_expenses__c,
                                Other_current_assets__c,
                                Other_Non_Current_assets_Security_Depos__c,
                                Cash_Bank_Balances__c,
                                Difference__c,
                                Date_of_Filing_ITR__c,
                                FinancialYearFor__c,
                                Total_Sales__c,
                                Other_Operating_Income_IncomeIncidental__c,
                                Non_Operating_Income__c,
                                Non_Business_Income__c,
                                Opening_Stock__c,
                                Closing_Stock__c,
                                Purchases__c,
                                Direct_Expenses__c,
                                Gross_Profit__c,
                                Office_Administrative_Expenses__c,
                                Other_Indirect_Expenses__c,
                                Non_Operating_Expenses_FxLoss_AssetLoss__c,
                                Salary_to_Partner_Directors__c,
                                EBITDA__c,
                                Interest_on_Term_Loans__c,
                                Interest_on_CC_OD_limits__c,
                                Interest_on_Partner_Capital__c,
                                Profit_Before_Depreciation_and_Tax_PBDT__c,
                                Depreciation__c,
                                Profit_Before_Tax__c,
                                Taxes__c,
                                PAT__c,
                                Tax_on_Above_Income__c,
                                Net_Income_Considered_for_Eligibility__c,
                                Director_Partners_remuneration_Interest__c,
                                Total_Sales_Remark__c,
                                Type_of_Accounts__c,
                                Other_Operating_Income_Remark__c,
                                Non_Operating_Income_Remark__c,
                                Non_Business_Income_Remark__c,
                                Opening_Stock_Remark__c,
                                Closing_Stock_Remark__c,
                                Purchases_Remark__c,
                                Direct_Expenses_Remark__c,
                                Gross_Profit_Remark__c,
                                Office_Administrative_Expenses_Remark__c,
                                Other_Indirect_Expenses_Remark__c,
                                Non_Operating_Expenses_Remark__c,
                                Salary_to_Partner_Directors_Remark__c,
                                EBITDA_Remark__c,
                                Interest_on_Term_Loans_Remark__c,
                                Interest_on_CC_OD_limits_Remark__c,
                                Interest_on_Partner_Capital_Remark__c,
                                Profit_Before_Depreciation_PBDT_Remark__c,
                                Depreciation_Remark__c,
                                Profit_Before_Tax_Remark__c,
                                Taxes_Remark__c,
                                PAT_Remark__c,
                                Liabilities_Remarks__c,
                                Share_capital_Remarks__c,
                                Reevaluation_Remark__c,
                                Advances_Remarks__c,
                                Unsecured_Loan_Remarks__c,
                                Adjustable_Remarks__c,
                                Borrowing_Remarks__c,
                                Secured_Remarks__c,
                                Unsecured_Remarks__c,
                                Total_Loan_Remarks__c,
                                Sundry_Remarks__c,
                                Deferred_Tax_Liability_Remark__c,
                                Assets_Remarks__c,
                                Less_Six_Months_Remarks__c,
                                Greater_Six_Months_Remarks__c,
                                Comments_on_Balance_sheet__c,
                                Comments_on_Profit_Loss__c,
                                ITR_Filing_Gap_Days__c,
                                Previous_Financial_Year__c,
                                Current_Financial_Year__c,
                                Provisional_Financial_Year__c,
                                Applicant_ID__c,
                                GST_Month_Year__c,
                                Gross_Turnover_as_per_GST_excl_taxes__c,
                                Index__c,
                                ExportSalesOutOfAboveSales__c,
                                ExportSalesOutOfAboveSalesRemark__c,
                                Income_addition_u_s_40_a_2_b__c,
                                Tax_on_the_above_inc_for_Addition__c,
                                Net_inc_con_for_Eligibility_for_add_Inc__c,
                                ClonedSource__c
                                FROM Applicant_Financial_Summary__c
                                WHERE Applicant_Financial__c IN :appFinanceWithOldIdMap.keySet()
                            ];
                            
                            if (!appFinanSummaries.isEmpty()) {
                                for (
                                    Applicant_Financial_Summary__c appFinancialSummary : appFinanSummaries
                                ) {
                                    Applicant_Financial_Summary__c clonedAppFinancialSummary = appFinancialSummary.clone(
                                        false,
                                        true,
                                        false,
                                        false
                                    );
                                    clonedAppFinancialSummary.Applicant_Financial__c = appFinancialSummary.Applicant_Financial__c !=
                                        null
                                        ? appFinanceWithOldIdMap.get(
                                            appFinancialSummary.Applicant_Financial__c
                                        )
                                        : null;
                                    clonedAppFinancialSummary.ClonedSource__c = appFinancialSummary.Id;
                                    recordsToClone.add(clonedAppFinancialSummary);
                                }
                            }
                            if (!recordsToClone.isEmpty()) {
                                insert recordsToClone;
                            }
                        }
                    }
                }
            }
            if (!Test.isRunningTest()) {
                System.enqueueJob(
                    new ClonePdDocDtlsJob(inputData, loanProduct, clonedLoanAppId)
                );
            }
        } catch (Exception e) {
            if (clonedLoanAppId != null) {
                CloneRollbackHanlder.rollbackClonedloanApp(clonedLoanAppId);
            }
            GlobalUtility.logMessage(
                'Error',
                'CloneAppFinancialsJob',
                'Process',
                null,
                null,
                e.getMessage() + ' line ' + e.getLineNumber(),
                null,
                e,
                null
            );
        }
    }
}