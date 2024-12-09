public class CloneAppIncomeGStJob implements Queueable, Database.AllowsCallouts {
    private CloneLoanAppController.CloneLoanAppwrpr inputData;
    private String loanProduct;
    private Id clonedLoanAppId;
    
    public CloneAppIncomeGStJob(
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
            Map<Id, Id> appAddrsWithOldIdMap = new Map<Id, Id>();
            Map<Id, Id> appAssetWithOldIdMap = new Map<Id, Id>();
            Map<Id, Id> pdOldIdMap = new Map<Id, Id>();
            
            List<SObject> recordsToClone = new List<SObject>();
             LoanAppl__c loanApp = [SELECT Id, Product__c, Stage__c, SubStage__c,LoginAcceptDate__c FROM LoanAppl__c WHERE Id = :inputdata.recordId LIMIT 1];
        Date todayDate = Date.today();
        Boolean loginAccData = true;
        Date comparisonDate = todayDate.addDays(-30);
        if (loanApp.LoginAcceptDate__c != null && loanApp.LoginAcceptDate__c <= comparisonDate) {
          loginAccData = false;
        }
            List<Applicant__c> applicants = [
                SELECT
                Id,
                ClonedFor__c,
                (SELECT Id, ClonedSource__c FROM Applicant_Addresses__r),
                (SELECT Id, ClonedSource__c FROM Applicant_Assets__r),(SELECT Id,ClonedSource__c FROM Personal_Discussions__r WHERE PDStatus__c ='Completed')
                FROM Applicant__c
                WHERE LoanAppln__c = :clonedLoanAppId AND ApplType__c IN ('P', 'C', 'G')
            ];
            
            if (!applicants.isEmpty()) {
                for (Applicant__c applicant : applicants) {
                    appWithOldIdMap.put(applicant.ClonedFor__c, applicant.Id);
                    if (!applicant.Applicant_Assets__r.isEmpty()) {
                        for (ApplAsset__c appAsset : applicant.Applicant_Assets__r) {
                            appAssetWithOldIdMap.put(appAsset.ClonedSource__c, appAsset.Id);
                        }
                    }
                    if (!applicant.Personal_Discussions__r.isEmpty()) {
                        for (PD__c pd : applicant.Personal_Discussions__r) {
                            pdOldIdMap.put(pd.ClonedSource__c, pd.Id);
                        }
                    }
                    if (!applicant.Applicant_Addresses__r.isEmpty()) {
                        for (ApplAddr__c appAddrss : applicant.Applicant_Addresses__r) {
                            appAddrsWithOldIdMap.put(appAddrss.ClonedSource__c, appAddrss.Id);
                        }
                    }
                }
            }
            if (inputData.cloneReason != null) {
                CloneMetadataUtility.CloneMtdUtilityWrpr returnDat = CloneMetadataUtility.getCloneStatus('ApplicantFinancial', inputData.cloneReason);
                List<String> products = returnDat.productType.split(':');
                if ((loginAccData == true && returnDat.cloneStatus != null && returnDat.cloneStatus == 'Yes' && products.contains(loanProduct)) || (inputData.income == true && loginAccData == false)) {
                    if (!appWithOldIdMap.keySet().isEmpty()) {
                        List<ApplGST__c> appGstRecrds = [
                            SELECT
                            Id,
                            Applicant__c,
                            ApplAsset__c,
                            GSTIN__c,
                            GSTIN_Status__c,
                            LegalNameOfBusiness_GST_Certificate__c,
                            Main_GSTIN__c,
                            RegisteredAddress_GST__c,
                            TradeName_GST_Certificate__c,
                            Income_Documents__c,
                            AddrLine1__c,
                            AddrLine2__c,
                            Applicant_Address__c,
                            CityId__c,
                            City__c,
                            Index__c,
                            LastSelectedAddrType__c,
                            PinId__c,
                            Pincode__c,
                            StateId__c,
                            State__c,
                            HouseNo__c,
                            Locality__c,
                            Landmark__c,
                            Email__c,
                            MobNo__c,
                            ApplStatus__c,
                            GSTIN_RefId__c,
                            Pan__c,
                            Reg_Type__c,
                            RegistName__c,
                            TinNo__c,
                            RegDate__c,
                            ConstBuisnessGST__c,
                            NaturBuisnessReg__c,
                            Invalid__c,
                            ClonedSource__c
                            FROM ApplGST__c
                            WHERE Applicant__c IN :appWithOldIdMap.keySet()
                        ];
                        
                        if (!appGstRecrds.isEmpty()) {
                            for (ApplGST__c appGst : appGstRecrds) {
                                ApplGST__c clonedAppGst = appGst.clone(
                                    false,
                                    true,
                                    false,
                                    false
                                );
                                clonedAppGst.Applicant__c = appGst.Applicant__c != null
                                    ? appWithOldIdMap.get(appGst.Applicant__c)
                                    : null;
                                clonedAppGst.Applicant_Address__c = appGst.Applicant_Address__c !=
                                    null
                                    ? appAddrsWithOldIdMap.get(appGst.Applicant_Address__c)
                                    : null;
                                clonedAppGst.ApplAsset__c = appGst.ApplAsset__c != null
                                    ? appAssetWithOldIdMap.get(appGst.ApplAsset__c)
                                    : null;
                                clonedAppGst.ClonedSource__c = appGst.Id;
                                recordsToClone.add(clonedAppGst);
                            }
                        }
                        
                        insert recordsToClone;
                        recordsToClone.clear();
                        //added RecordTypeId FROM LAK-9309
                        List<Applicant_Income__c> appIncomeDtls = [
                            SELECT Id, RecordTypeId,Rental_Credit_Bank_Name__c, Address__c, TOTAL_MONTHLY_RENTAL_CREDIT_AMT__c, 
                            Address_Type__c, Total_Monthly_Rental_Amount__c, Rental_Month_1__c, Rental_Month_2__c, Rental_Month_3__c, 
                            Other_Address__c, Multi_Tenanted__c, No_of_Tenants__c, ClonedSource__c, Rent_agreement_documented__c, Property_ownership_proof_documented__c,
                            Annual_Net_Rental_Previous_Year_ITR__c, Annual_Net_Rental_Current_Year_ITR__c, Average_Monthly_Rental__c, 
                            APPROXIMATE_MARGIN_IN_THE_BUSINESS__c, Monthly_Rental_AMT_Rs__c, Monthly_Rental_Credit_AMT_Rs__c, Agricultural_Yearly_Income__c, 
                            NET_CASH_PROFIT_LOSS__c, Agricultural_Income_Year__c, IncomeType__c, PrsnlDis__c, Name_Of_Pensioner__c, Bank_Name_Of_Pensioner__c,
                            Nature_Of_Business_of_Applicant__c, Applicant__c, Salary__c, Gross_Salary_Rs__c, Variable_Component__c, LTA_Monthly__c, 
                            Performance_Bonus_Monthly__c, Taxes__c, Other_Deductions__c, Net_Salary__c, Bank_Credit_Date__c, Other_Salary_Component__c,
                            ReceiptsPerDayDaily__c, Monthly_Other_Income__c, Income_Head__c, Monthly_Pension_Credited__c, Month1_Rental_Credit_Bank_Name__c, 
                            Month2_Rental_Credit_Bank_Name__c, Month__c, Salary_Months__c, Month3_Rental_Credit_Bank_Name__c, Month1_Rental_Credited_Amount__c,
                            Month2_Rental_Credited_Amount__c, Month3_Rental_Credited_Amount__c, Rental_Verification_done__c, ReceiptsPerDayDaysWorking__c,
                            ReceiptsPerDayMonthly__c, ServicesRevenueMonthly__c, OtherRevenueMonthly__c, Total_Inflow_From_Operations__c, 
                            Monthly_Purchases_Cost_Of_Materials__c, Total_Expense_of_operations_Or_Business__c, Operating_Activity_Receipts__c, 
                            OthersDaysWorking__c, OthersDayMonthly__c, Normal_Days_sales_Receipts_Daily__c, Normal_Days_sales_Days_Working__c, 
                            Normal_Days_sales_Receipts_Monthly__c, Peak_Days_sales_Receipts_Daily__c, Peak_Days_sales_Receipts_Days_Working__c, 
                            Peak_Days_sales_Receipts_Receipts_Monthl__c, Index__c, Property_Name__c, Total_Agriculture_Income__c, Total_Other_Income__c,
                            Total_Pension_Income__c, Total_Net_Salary__c, Total_Other_Salary_Component__c, Remark__c, OtherDayDaily__c, Cash_Flow_Remarks__c
                            FROM Applicant_Income__c
                            WHERE
                            Applicant__c IN :appWithOldIdMap.keySet()
                        ];
                        
                        if (!appIncomeDtls.isEmpty()) {
                            for (
                                Applicant_Income__c appIncome : appIncomeDtls
                            ) {
                                Applicant_Income__c clonedAppIncome = appIncome.clone(
                                    false,
                                    true,
                                    false,
                                    false
                                );
                                clonedAppIncome.Address__c = appIncome.Address__c !=
                                    null
                                    ? appAddrsWithOldIdMap.get(
                                        appIncome.Address__c
                                    )
                                    : null;
                                clonedAppIncome.Applicant__c = appIncome.Applicant__c !=
                                    null
                                    ? appWithOldIdMap.get(
                                        appIncome.Applicant__c
                                    )
                                    : null;
                                clonedAppIncome.PrsnlDis__c = appIncome.PrsnlDis__c !=
                                    null
                                    ? pdOldIdMap.get(
                                        appIncome.PrsnlDis__c
                                    )
                                    : null;
                                clonedAppIncome.ClonedSource__c = appIncome.Id;
                                recordsToClone.add(clonedAppIncome);
                            }
                        }
                        if (!recordsToClone.isEmpty()) {
                            insert recordsToClone;
                        }
                    }
                }
            }
            if(!Test.isRunningTest()){
                System.enqueueJob(
                    new CloneDocDtlsJob(inputData, loanProduct, clonedLoanAppId)
                );
            }
        } catch (Exception e) {
            if (clonedLoanAppId != null) {
                CloneRollbackHanlder.rollbackClonedloanApp(clonedLoanAppId);
              }
            GlobalUtility.logMessage(
                'Error',
                'CloneAppIncomeGStJob',
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