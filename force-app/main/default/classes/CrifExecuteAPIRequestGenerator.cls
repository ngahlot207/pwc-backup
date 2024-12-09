public class CrifExecuteAPIRequestGenerator implements ICalloutRequestGenerator {
    
    Private static Set<Id> loanIDs = new Set<Id>(); 
    Private static List<IntgMsg__c> updateIntrecods = new List<IntgMsg__c>(); 
    Private static Map<Id,LoanAppl__c> loanmap = new map<Id,LoanAppl__c>();
    
    Private static Set<String> btFin = new Set<String>();
    Private static Map<String, String> balTranFinMap = new Map<String, String>();
    
    Private static Set<String> crifValSet = new Set<String>();
    Private static Map<Id, Boolean> fin44ADMap = new Map<Id, Boolean>();
    
    Private static Map<Id, List<Applicant__c>> applyMap = new Map<Id, List<Applicant__c>>();
    Private static Set<Id> applyIdList = new Set<Id>();
    Private static Map<Id, Decimal> totOblig = new Map<Id, Decimal>();
    Private static List<Map<string,object>> Categorieslist = new List<Map<string,object>>();
    Private static List<Map<string,object>> custCategorieslist = new List<Map<string,object>>();
    Private static Map<Id, List<Map<string,object>>> custCatMap = new Map<Id, List<Map<string,object>>>();
    Private static Set<Id> schemeIds = new Set<Id>();
    Private static Set<String> branchCds = new Set<String>();
    Private static Map<Id, String> schemeMap = new Map<Id, String>();
    Private static Map<Id, Boolean> btLoanMap = new Map<Id, Boolean>();
    Private static Map<String, List<Map<String, String>>> masterDataMap = new Map<String, List<Map<String, String>>>();
    Private static Set<String> masterDataKey = new Set<String>();
    Private static Set<String> custProfSel = new Set<String>();
    Private static Map<String, LocMstr__c> locatMasterMap = new Map<String, LocMstr__c>();
    Private static Set<String> cityIds = new Set<String>();
    Private static Set<Id> conBureauResIds = new Set<Id>();
    Private static Set<Id> commBureauResIds = new Set<Id>();
    Private static Set<String> loanPur = new Set<String>();
    Private static Set<Id> applyAsstIds = new Set<Id>();
    Private static Set<String> promCode = new Set<String>();
    Private static Map<Id, List<Case>> appAssCaseMap = new Map<Id, List<Case>>();
    Private static Set<String> properSub = new Set<String>();
    Private static Map<String, String> promCodeMap = new Map<String, String>();
    Private static Map<String, String> properSubMap = new Map<String, String>();
    Private static Map<String, String> loanPurMap = new Map<String, String>();
    Private static Map<String, BankBrchMstr__c> bankBranchMstrMap = new Map<String, BankBrchMstr__c>();
    Private static Map<Id, List<DedupeResponse__c>> dedupeResMap = new Map<Id, List<DedupeResponse__c>>();
    Private static Map<Id, List<DedupeResponse__c>> dedupeResLAMap = new Map<Id, List<DedupeResponse__c>>();
    Private static Map<Id, List<DocDtl__c>> applyDocMap = new Map<Id, List<DocDtl__c>>();
    Private static String btFinStat = '';
    Private static String propDocVar = 'No';
    Private Map<Id,ApplBankDetail__c> applBankDetailMap =new Map<Id,ApplBankDetail__c>();
    
    public void generate(List<IntgMsg__c> msgs, String service, String processType) {
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> { IntgMsg__c.SObjectType });
        
        for(IntgMsg__c intms : msgs) {
            if(intms.RefObj__c != NULL && intms.RefObj__c == 'LoanAppl__c') {
                loanIDs.add(intms.RefId__c);
            }
        }
        
        try {
            if(!loanIDs.isEmpty()) { 
                
                loanmap=CrifExecuteAPIRequestGeneratorHelper.loanMapDeatils(loanIDs);
                
                
                if(!loanmap.isEmpty()) {
                    
                    for(LoanAppl__c laRec : loanmap.values()) {
                        if(String.isNotBlank(laRec.SchemeId__c)) {
                            schemeIds.add(laRec.SchemeId__c);
                        }
                        
                        if(String.isNotBlank(laRec.BrchCode__c)) {
                            branchCds.add(laRec.BrchCode__c);
                        }
                        
                        if(String.isNotBlank(laRec.OthrBTFinancr__c)) {
                            btFin.add(laRec.OthrBTFinancr__c);
                        }
                        
                        if(String.isNotBlank(laRec.ProductSubType__c)) {
                            crifValSet.add(laRec.ProductSubType__c);
                        }
                        
                        if(String.isNotBlank(laRec.BranchTier__c)) {
                            crifValSet.add(laRec.BranchTier__c);
                        }
                        
                        if(String.isNotBlank(laRec.Product__c)) {
                            masterDataKey.add(laRec.Product__c);
                        }
                        
                        if(!laRec.Applicant_Assets__r.isEmpty()) {
                            for(ApplAsset__c aa : laRec.Applicant_Assets__r) {
                                
                                applyAsstIds.add(aa.Id);
                                
                                if(String.isNotBlank(aa.City__c)) {
                                    cityIds.add(aa.City__c);
                                }
                                
                                if(String.isNotBlank(aa.PropSubType__c)) {
                                    properSub.add(aa.PropSubType__c);
                                }
                                
                                if(String.isNotBlank(aa.Property_Usage__c)) {
                                    masterDataKey.add(aa.Property_Usage__c);
                                }
                                
                                if(String.isNotBlank(aa.PropType__c)) {
                                    masterDataKey.add(aa.PropType__c);
                                }
                                
                                if(String.isNotBlank(aa.PropCat__c)) {
                                    crifValSet.add(aa.PropCat__c);
                                }
                            }
                        }
                        
                        if(!laRec.Cases__r.isEmpty()) {
                            for(Case cs : laRec.Cases__r) {
                                if(String.isNotBlank(cs.Final_RCU_status_Reason__c)) {
                                    crifValSet.add(cs.Final_RCU_status_Reason__c);
                                }
                                if(String.isNotBlank(cs.ReportResult__c)) {
                                    crifValSet.add(cs.ReportResult__c);
                                }
                            }
                        }
                        
                        if(!laRec.Hunter_Verifications__r.isEmpty()) {
                            for(HunterVer__c hv : laRec.Hunter_Verifications__r) {
                                if(String.isNotBlank(hv.HunterStatWhereMatchFound__c)) {
                                    crifValSet.add(hv.HunterStatWhereMatchFound__c);
                                }
                                if(String.isNotBlank(hv.HunMatchSta__c)) {
                                    crifValSet.add(hv.HunMatchSta__c);
                                }
                            }
                        }
                        
                        if(!laRec.Applicant_Regulatory__r.isEmpty()) {
                            for(ApplRegltry__c ar : laRec.Applicant_Regulatory__r) {
                                if(String.isNotBlank(ar.FundInESGPol__c)) {
                                    crifValSet.add(ar.FundInESGPol__c);
                                }
                            }
                        }
                        
                        if(!laRec.Repayment_Account__r.isEmpty()) {
                            for(Repayment_Account__c ra : laRec.Repayment_Account__r) {
                                if(String.isNotBlank(ra.Repayment_Mode__c)) {
                                    masterDataKey.add(ra.Repayment_Mode__c);
                                }
                            }
                        }
                        
                        if(!laRec.Applicant_Document_Details__r.isEmpty()) {
                            propDocVar = 'Yes';
                        }
                        
                        if(String.isNotBlank(laRec.LoanPurposeId__c)) {
                            loanPur.add(laRec.LoanPurposeId__c);
                        }
                        
                        if(String.isNotBlank(laRec.LeadSource__c)) {
                            masterDataKey.add(laRec.LeadSource__c);
                        }
                        
                        if(String.isNotBlank(laRec.PromCode__c)) {
                            promCode.add(laRec.PromCode__c);
                        }
                        
                        if(!laRec.BT_Loans__r.isEmpty()) {
                            Boolean btPos = FALSE, btNeg = FALSE, btRef = FALSE;
                            for(BTLoan__c bt : laRec.BT_Loans__r) {
                                
                                if(String.isNotBlank(bt.BTFinancierStatus__c)) {
                                    
                                    if(bt.BTFinancierStatus__c.equalsIgnoreCase('N')) {
                                        btNeg = TRUE;
                                    }
                                    
                                    else if(bt.BTFinancierStatus__c.equalsIgnoreCase('R')) {
                                        btRef = TRUE;
                                    }
                                    
                                    else {
                                        btPos = TRUE;
                                    }
                                }
                            }
                            
                            if(btNeg == TRUE) {
                                btFinStat = 'Negative';
                            }
                            
                            else if(btRef == TRUE) {
                                btFinStat = 'Refer';
                            }
                            
                            else if(btPos == TRUE) {
                                btFinStat = 'Positive';
                            }
                        }
                    }
                }
                
                
                dedupeResLAMap=CrifExecuteAPIRequestGeneratorHelper.dedupeResLAMap(loanIDs);
                
                List<BureauRespDtl__c> brdetList = [SELECT Id, NoEMIPaid__c FROM BureauRespDtl__c WHERE RecordType.Name IN ('Consumer Obligation', 'Commercial Obligation') AND NoEMIPaid__c != NULL AND NoEMIPaid__c > 0 AND Treatment__c = 'BT loan' AND LoanApplication__c IN : loanIDs];
                
                if(!btFin.isEmpty()) {
                    balTranFinMap=CrifExecuteAPIRequestGeneratorHelper.balTranFin(btFin);
                }
                
                if(!promCode.isEmpty()) {
                    promCodeMap=CrifExecuteAPIRequestGeneratorHelper.promCodes(promCode);
                }
                
                if(!applyAsstIds.isEmpty()) {
                    appAssCaseMap=CrifExecuteAPIRequestGeneratorHelper.appAssCase(applyAsstIds);
                }
                
                if(!appAssCaseMap.isEmpty()) {
                    List<Case> tempCaseList = new List<Case>();
                    for(Id temp : appAssCaseMap.keySet()) {
                        if(!appAssCaseMap.get(temp).isEmpty()) {
                            tempCaseList.addAll(appAssCaseMap.get(temp));
                        }
                    }
                    if(!tempCaseList.isEmpty()) {
                        for(Case cs : tempCaseList) {
                            if(String.isNotBlank(cs.ReportResult__c)) {
                                crifValSet.add(cs.ReportResult__c);
                            }
                        }
                    }
                }
                
                if(!properSub.isEmpty()) {
                    properSubMap=CrifExecuteAPIRequestGeneratorHelper.properSub(properSub);
                }
                
                if(!loanPur.isEmpty()) {
                    loanPurMap=CrifExecuteAPIRequestGeneratorHelper.loanPur(loanPur);
                }
                
                //Financial Summary Data
                Map<Id, List<Map<String, Applicant_Financial_Summary__c>>> mapBS = new Map<Id, List<Map<String, Applicant_Financial_Summary__c>>>();
                Map<Id, List<Map<String, Applicant_Financial_Summary__c>>> mapPNL = new Map<Id, List<Map<String, Applicant_Financial_Summary__c>>>();
                for(Applicant_Financial_Summary__c afs : [SELECT Id, Debtors__c, ITR_Filing_Gap_Days__c, Taxes__c, Financial_Year__c, Director_Partners_remuneration_Interest__c, Adjusted_tangible_Netwroth__c, Advances_from_customers__c, Adavces_to_group_co_friends__c, Advances_to_Suppliers__c, Bank_Borrowing_Working_Capital_OD_CC__c, Cash_Bank_Balances__c, Deffered_Tax_Liability_Assets__c, Direct_Expenses__c, EBITDA__c, Closing_Stock__c, Depreciation__c, Investments__c, Opening_Stock__c, PAT__c, Purchases__c, Total_Loan_funds__c, Greaterthan6__c, Gross_Profit__c, Interest_on_CC_OD_limits__c, Interest_on_Partner_Capital__c, Interest_on_Term_Loans__c, LessSix_months__c, Misc_Exp_Not_written_off__c, Net_Income_Considered_for_Eligibility__c, Net_Intangible_Fixed_Assets__c, Net_Tangible_Fixed_Assets_Including_Cap__c, Net_worth__c, Non_Business_Income__c, Non_Operating_Expenses_FxLoss_AssetLoss__c, Non_Operating_Income__c, Office_Administrative_Expenses__c, Other_current_assets__c, Other_current_liabilities__c, Other_Indirect_Expenses__c, Other_loans_advances__c, Other_Loans_From_private_parties__c, Other_Non_Current_assets_Security_Depos__c, Other_Operating_Income_IncomeIncidental__c, Prepaid_expenses__c, Profit_Before_Tax__c, Profit_Before_Depreciation_and_Tax_PBDT__c, Provisions_for_exps_tax_etc__c, Revaluation_Reserves_Notional_Reserves__c, Salary_to_Partner_Directors__c, Secured_debts_Banks_Ndfc__c, Share_capital_Partner_s_Capital__c, Stock__c, Sundry_creditors__c, Tax_on_Above_Income__c, Total_Sales__c, Type_of_Accounts__c, Unsecured_debts_Banks_Ndfc__c, unsecured_Loan_from_promoters_family_m__c, Applicant_Financial__r.RecordType.Name, Applicant_Financial__r.Loan_Applicant__c FROM Applicant_Financial_Summary__c WHERE Applicant_Financial__r.RecordType.Name IN ('Balance Sheet', 'Profit & Loss') AND Financial_Year__c != NULL AND Applicant_Financial__r.Loan_Applicant__c != NULL AND Applicant_Financial__r.Loan_Applicant__r.LatestyearforwhichITRisavailable__c != NULL AND Applicant_Financial__r.Loan_Applicant__r.LatestyearforwhichITRisavailable__c != 'ITR Not Available' AND Applicant_Financial__r.Loan_Applicant__r.LoanAppln__c IN : loanIDs ORDER BY LastModifiedDate DESC]) {
                    
                    //Balance Sheet Data
                    if(afs.Applicant_Financial__r.RecordType.Name != NULL && afs.Applicant_Financial__r.RecordType.Name.equalsIgnoreCase('Balance Sheet')) {
                        if((!mapBS.containsKey(afs.Applicant_Financial__r.Loan_Applicant__c))) {
                            Map<String, Applicant_Financial_Summary__c> tempMap = new Map<String, Applicant_Financial_Summary__c>{afs.Financial_Year__c=>afs};
                                List<Map<String, Applicant_Financial_Summary__c>> tempList = new List<Map<String, Applicant_Financial_Summary__c>>();
                            tempList.add(tempMap);
                            mapBS.put(afs.Applicant_Financial__r.Loan_Applicant__c, tempList);
                        }
                        else {
                            Map<String, Applicant_Financial_Summary__c> tempMap = new Map<String, Applicant_Financial_Summary__c>();
                            
                            Set<String> finYearSet = new Set<String>();
                            for(Map<String, Applicant_Financial_Summary__c> mapTemp : mapBS.get(afs.Applicant_Financial__r.Loan_Applicant__c)) {
                                finYearSet.addAll(mapTemp.keySet());
                            }
                            if(!finYearSet.isEmpty()) {
                                if(!finYearSet.contains(afs.Financial_Year__c)) {
                                    tempMap.put(afs.Financial_Year__c, afs);
                                }
                            }
                            if(!tempMap.isEmpty()) {
                                mapBS.get(afs.Applicant_Financial__r.Loan_Applicant__c).add(tempMap);
                            }
                        }
                    }
                    
                    //Profit & Loss Data
                    if(afs.Applicant_Financial__r.RecordType.Name != NULL && afs.Applicant_Financial__r.RecordType.Name.equalsIgnoreCase('Profit & Loss')) {
                        if((!mapPNL.containsKey(afs.Applicant_Financial__r.Loan_Applicant__c))) {
                            Map<String, Applicant_Financial_Summary__c> tempMap = new Map<String, Applicant_Financial_Summary__c>{afs.Financial_Year__c=>afs};
                                List<Map<String, Applicant_Financial_Summary__c>> tempList = new List<Map<String, Applicant_Financial_Summary__c>>();
                            tempList.add(tempMap);
                            mapPNL.put(afs.Applicant_Financial__r.Loan_Applicant__c, tempList);
                        }
                        else {
                            Map<String, Applicant_Financial_Summary__c> tempMap = new Map<String, Applicant_Financial_Summary__c>();
                            
                            Set<String> finYearSet = new Set<String>();
                            for(Map<String, Applicant_Financial_Summary__c> mapTemp : mapPNL.get(afs.Applicant_Financial__r.Loan_Applicant__c)) {
                                finYearSet.addAll(mapTemp.keySet());
                            }
                            if(!finYearSet.isEmpty()) {
                                if(!finYearSet.contains(afs.Financial_Year__c)) {
                                    tempMap.put(afs.Financial_Year__c, afs);
                                }
                            }
                            if(!tempMap.isEmpty()) {
                                mapPNL.get(afs.Applicant_Financial__r.Loan_Applicant__c).add(tempMap);
                            }
                        }
                    } 
                    
                    if(String.isNotBlank(afs.Type_of_Accounts__c)) {
                        crifValSet.add(afs.Type_of_Accounts__c);
                    }
                }
                
                if(!schemeIds.isEmpty()) {
                    for(SchMapping__c scMap : [SELECT Id, SchmId__c, IsBT__c FROM SchMapping__c WHERE Id IN : schemeIds]) {
                        
                        if(String.isNotBlank(scMap.SchmId__c)) {
                            schemeMap.put(scMap.Id, scMap.SchmId__c);
                        }
                        
                        btLoanMap.put(scMap.Id, scMap.IsBT__c);
                    } 
                }
                
                if(!branchCds.isEmpty()) {
                    bankBranchMstrMap=CrifExecuteAPIRequestGeneratorHelper.bankBranchMstr(branchCds);
                }
                
                //Applicant Employment Type
                Map<Id,String> applicantMap =new Map<Id,String>();
                
                for(Applicant__c appl : [SELECT Id, UCID__c, Businessproofavailable__c, toLabel(Residential_Status__c),
                                         LatestyearforwhichITRisavailable__c, AverageMonthlyAgricultureIncome__c, Salary_Credit_Count__c, 
                                         Average_Monthly_Pension__c, Average_Other_Income__c, Customer_Profile_Selection_Id__c,
                                         LoanAppln__r.Lead__r.UnservicableCityCheck__c, LoanAppln__r.Product__c, FullName__c,
                                         toLabel(EduQual__c), AssessmentProgram__c, YearOfRegistration__c, Gender__c,
                                         Average_Monthly_Rental_No_Bank_Credit__c, Average_Monthly_Rental_With_Bank_Credit__c,
                                         LoanAppln__c, ApplType__c, DOB__c, DOI__c, Constitution__c, Type_of_Borrower__c, FName__c, 
                                         LName__c,LEI_Number__c, Category__c, CompanyName__c, Customer_Profile_Categorisation__c, 
                                         Listed_Unlisted__c,CustProfile__c, LoanAppln__r.Status__c, toLabel(MariStatus__c), 
                                         MediCouncl__c, toLabel(Religion__c),Relationship__c, toLabel(ProfQual__c), 
                                         Politically_Exposed_Person__c,Whether_partnership_is_registered__c, 
                                         Average_Monthly_Cash_Salary__c, Average_Monthly_Gross_Salary__c,
                                         (SELECT Id, InsType__c, SumAmount__c FROM Insurances__r WHERE InsType__c != NULL AND IsActive__c = TRUE),
                                         (SELECT Id, LTA_Monthly__c, Performance_Bonus_Monthly__c, Rental_Month_1__c, Gross_Salary_Rs__c,
                                          Rental_Month_2__c, Rental_Month_3__c, Month1_Rental_Credited_Amount__c, 
                                          Net_Salary__c,Variable_Component__c, Taxes__c, Multi_Tenanted__c, 
                                          No_of_Tenants__c,Property_ownership_proof_documented__c, 
                                          Other_Deductions__c,Rent_agreement_documented__c, 
                                          Rental_Verification_done__c, APPROXIMATE_MARGIN_IN_THE_BUSINESS__c,
                                          Monthly_Purchases_Cost_Of_Materials__c, Total_Expense_of_operations_Or_Business__c,
                                          Operating_Activity_Receipts__c, NET_CASH_PROFIT_LOSS__c, 
                                          RecordType.Name FROM Applicant_Income__r ORDER BY LastModifiedDate DESC), 
                                         (SELECT Id, ScrRes__c, Result_Relevance__c, RecordType.Name, WatchoutInvestor__c, 
                                          Risk_Rating_Final__c,acceptAll__c,Email__c,QualificationYear__c,Qualification__c 
                                          FROM API_Verifications__r WHERE IsLatest__c = TRUE AND 
                                          RecordType.Name != NULL ORDER BY CreatedDate DESC),
                                         (SELECT Id, Name, GSTIN__c, GSTIN_Status__c, Income_Documents__c, 
                                          LegalNameOfBusiness_GST_Certificate__c,Main_GSTIN__c, RegisteredAddress_GST__c, 
                                          TradeName_GST_Certificate__c,RegDate__c FROM Applicant_GST__r),
                                         (SELECT Id, AccountOpenDate__c, TotalStopPaymentCounts__c, TotalOutwardReturnCount__c,
                                          TotalMinimumBalanceChangesCount__c, TotalInwardReturnCount__c, TotalDebitValueSummation__c,
                                          TotalDebitTransactionCount__c, TotalCreditValueSummation__c, TotalCreditTransactionCount__c,
                                          SumofMonthlyAverageBalance__c, AverageBankBalance__c, LimitUtilisation__c, 
                                          AvgEODBalanceofLatest6Months__c,AvgEODBalanceofLatest3Months__c, Avg_EOD_Balance_of_latest_12_months__c,
                                          AverageMonthlyDebitValueSummation__c, AverageMonthlyStopPaymentCounts__c,
                                          AverageMonthlyOutwardReturnCount__c, Average_Monthly_Inward_return_count__c,
                                          AverageMonthlyDebitTransactionCount__c, AverageMonthlyCreditValueSummation__c,Name__c,
                                          Average_Monthly_Credit_transaction_count__c, I_W_Return_Ratio__c,Appl__r.LoanAppln__r.SchemeId__c
                                          FROM Applicant_Banking1__r),
                                         (SELECT Id, Score__c, IsLatest__c, BureauAPI__c FROM Bureau_Responses__r ORDER BY CreatedDate DESC),
                                         (SELECT Id, Dedupe_for_Negative_Database__c, 
                                         Details_of_the_borrowers_have_been_confi__c, Distance_from_Fedfina_Branch__c, 
                                         Martial_Status__c, Negative_Area__c, Negative_Database_Result__c,ReportResult__c, 
                                         Negative_Report_reason__c, Neighbour_Reference_Check__c, Address_Type__c,FI_report_result__c,
                                         Date_of_Report__c,RecordType.Name,Assessed_Turnover_Annual_In_Lacs__c,
                                         Assessed_PAT_Annual_In_Lacs__c,Status FROM Cases__r 
                                         WHERE RecordType.Name IN ('CPVFI','LIP Vendor case') ORDER BY CreatedDate DESC), 
                                         (SELECT Id, DateOfUdyamRegistration__c,GST_Registered__c,GSTIN_Status__c,EntityName__c,
                                          IndustryType__r.Name,Proprietorship_firm_part_of_the_proposal__c,Is_URC_UAC_available__c,
                                          UdyamAssistCertificate__c,UdyamRegistrationNumber__c,NatureOfBusinessCorporate__c,
                                          NatureOfBusinessIndividual__c,DesignationValues__c,DesignationText__c,OfficialEmail__c,
                                          ShareholdingInTheEntity__c,SubIndustry__r.Name,TotalWorkExperience_Months__c,TypeOfEnterprise_URC__c,
                                          TypeOfOrganisation__c,WorkingWithCurrentEmployer_Months__c,WorkingWithCurrentEmployer_Years__c,
                                          CurrentBusinessVintage_Months__c, TotalWorkExperience_Years__c, CurrentBusinessVintage_Years__c, 
                                          RetirementAge__c, EmployerName__r.EmployerId__c, Select_applicability_for_URC_UAC__c,
                                          LoanApplicant__c FROM Applicant_Employments__r ORDER BY CreatedDate DESC), 
                                         (SELECT Id, AddrTyp__c, DisFrmSrcBrnh__c, toLabel(OwnType__c), DisFrmFFBrnh__c, 
                                          Nearest_Fedfina_Branch__c, Negative_Caution_Area__c, AddrStability__c, CityId__c, Pincode__c, 
                                          City__c, StabAtAddressMnth__c, StabAtAddressYr__c FROM Applicant_Addresses__r 
                                          ORDER BY CreatedDate DESC), (SELECT Id, kycDoc__c,ElectAmtPayable__c,ElectBillAmt__c,ElectTotAmt__c, 
                                         DLExpDt__c, Pan__c,Name_Match_Score__c FROM Applicant_KYC__r) 
                                         FROM Applicant__c WHERE LoanAppln__c IN : loanIDs]){
                                                                                          
                    if(applyMap.containskey(appl.LoanAppln__c)) {
                        applyMap.get(appl.LoanAppln__c).add(appl);
                    }
                    
                    else {
                        List<Applicant__c> tempApplyList = new List<Applicant__c>();
                        tempApplyList.add(appl);
                        applyMap.put(appl.LoanAppln__c, tempApplyList);
                    }
                    
                    //Adding Applicant Ids
                    applyIdList.add(appl.Id);
                    
                    //Applicant Address
                    if(!appl.Applicant_Addresses__r.isEmpty()) {
                        for(ApplAddr__c addrVar : appl.Applicant_Addresses__r) {
                            
                            if(String.isNotBlank(addrVar.City__c)) {
                                cityIds.add(addrVar.City__c);
                            }
                            
                            if(String.isNotBlank(addrVar.OwnType__c)) {
                                masterDataKey.add(addrVar.OwnType__c);
                            }
                            
                            if(String.isNotBlank(addrVar.AddrTyp__c)) {
                                
                                //LAK 8475 Start(Commentting this code )
                                /* if(addrVar.AddrTyp__c.equalsIgnoreCase('Office Address')) {
crifValSet.add('Other Address');
}
else {
crifValSet.add(addrVar.AddrTyp__c);
}*/
                                //LAK 8475 End(Commentting this code )
                                crifValSet.add(addrVar.AddrTyp__c);
                            }
                        }
                    }
                    
                    //Bureau Response --> Consumer Bureau Ids
                    if(!appl.Bureau_Responses__r.isEmpty()) {
                        for(Bureau__c bureauVar : appl.Bureau_Responses__r) {
                            if(bureauVar.IsLatest__c == TRUE && bureauVar.BureauAPI__c != NULL && bureauVar.BureauAPI__c.equalsIgnoreCase('Consumer')) {
                                conBureauResIds.add(bureauVar.Id);
                            }
                            
                            if(bureauVar.IsLatest__c == TRUE && bureauVar.BureauAPI__c != NULL && bureauVar.BureauAPI__c.equalsIgnoreCase('Commercial')) {
                                commBureauResIds.add(bureauVar.Id);
                            }
                        } 
                    }
                    
                    if(!appl.Cases__r.isEmpty()) {
                        for(Case cs : appl.Cases__r) {
                            
                            if(String.isNotBlank(cs.Neighbour_Reference_Check__c)) {
                                crifValSet.add(cs.Neighbour_Reference_Check__c);
                            }
                            
                            if(String.isNotBlank(cs.Negative_Report_reason__c)) {
                                crifValSet.add(cs.Negative_Report_reason__c);
                            }
                            
                            if(String.isNotBlank(cs.ReportResult__c)) {
                                crifValSet.add(cs.ReportResult__c);
                            }
                            
                        }
                    }
                    
                    if(!appl.Applicant_Employments__r.isEmpty()) {
                        for(ApplicantEmployment__c ae : appl.Applicant_Employments__r) {
                            if(String.isNotBlank(ae.UdyamAssistCertificate__c)) {
                                crifValSet.add(ae.UdyamAssistCertificate__c);
                            }
                            if(String.isNotBlank(ae.UdyamRegistrationNumber__c)) {
                                crifValSet.add(ae.UdyamRegistrationNumber__c);
                            }
                            
                            if(!applicantMap.containsKey(ae.LoanApplicant__c)){
                                applicantMap.put(ae.LoanApplicant__c,ae.Proprietorship_firm_part_of_the_proposal__c);
                            }
                        }
                    }
                    
                    if(String.isNotBlank(appl.Constitution__c)) {
                        masterDataKey.add(appl.Constitution__c);
                    }
                    
                    if(String.isNotBlank(appl.CustProfile__c)) {
                        masterDataKey.add(appl.CustProfile__c);
                    }
                    
                    if(String.isNotBlank(appl.EduQual__c)) {
                        masterDataKey.add(appl.EduQual__c);
                    }
                    
                    if(String.isNotBlank(appl.Customer_Profile_Selection_Id__c)) {
                        custProfSel.add(appl.Customer_Profile_Selection_Id__c);
                    }
                    
                    if(String.isNotBlank(appl.MariStatus__c)) {
                        masterDataKey.add(appl.MariStatus__c);
                    }
                    
                    if(String.isNotBlank(appl.ProfQual__c)) {
                        masterDataKey.add(appl.ProfQual__c);
                    }
                    
                    if(String.isNotBlank(appl.Religion__c)) {
                        masterDataKey.add(appl.Religion__c);
                    }
                    
                    if(String.isNotBlank(appl.CustProfile__c)) {
                        masterDataKey.add(appl.CustProfile__c);
                    }
                    
                    if(String.isNotBlank(appl.LoanAppln__r.Product__c) && String.isNotBlank(appl.AssessmentProgram__c)) {
                        String prod;
                        if(appl.LoanAppln__r.Product__c.equalsIgnoreCase('Home Loan')) {
                            prod = 'HL';
                        }
                        else if(appl.LoanAppln__r.Product__c.equalsIgnoreCase('Small Ticket LAP')) {
                            prod = 'STL';
                        }
                        else if(appl.LoanAppln__r.Product__c.equalsIgnoreCase('Loan Against Property')) {
                            prod = 'STL';//LAP
                        }
                        
                        if(prod != NULL) {
                            String tempVar = appl.AssessmentProgram__c.replaceAll(' ', '_') + '_' +  prod;
                            crifValSet.add(tempVar);
                        }
                    }
                }
                
                Map<Id,Boolean> propertyOwnerMap =new Map<Id,Boolean>();
                
                //Obligation Data
                if(!applyIdList.isEmpty()) {
                    /*Date:2024-05-30 
Author:Ripul Rawat 
Bug:LAK-7554
*/
                    totOblig=CrifExecuteAPIRequestGeneratorHelper.totOblig(applyIdList);
                    
                    for(Applicant_Financial_Summary__c afs : [SELECT Id, Type_of_Accounts__c, Applicant_Financial__r.Loan_Applicant__c FROM Applicant_Financial_Summary__c WHERE Applicant_Financial__c != NULL AND Applicant_Financial__r.RecordType.Name = 'Profit & Loss' AND Type_of_Accounts__c NOT IN('44ADA', '44AD') AND Applicant_Financial__r.Loan_Applicant__c IN : applyIdList]) {
                        fin44ADMap.put(afs.Applicant_Financial__r.Loan_Applicant__c, TRUE);
                    }
                    
                    //Dedupe Responses
                    dedupeResMap=CrifExecuteAPIRequestGeneratorHelper.dedupeRes(applyIdList);
                    
                    applyDocMap=CrifExecuteAPIRequestGeneratorHelper.applyDoc(applyIdList);
                    
                    //ApplAssetJn__c
                    propertyOwnerMap=CrifExecuteAPIRequestGeneratorHelper.propertyOwner(applyIdList);
                    
                    //ApplBankDetail__c
                    applBankDetailMap=CrifExecuteAPIRequestGeneratorHelper.applBankDetail(applyIdList);
                }
                
                //Applicant Id and List of BureauEnquiry__c records map
                Map<Id, List<BureauEnquiry__c>> consBurEnqMap = new Map<Id, List<BureauEnquiry__c>>();
                
                //Applicant Id and List of BureauRespDtl__c records map
                Map<Id, List<BureauRespDtl__c>> consBurResDetMap = new Map<Id, List<BureauRespDtl__c>>();
                
                //Applicant Id and List of BureauDemography__c records map
                Map<Id, List<BureauDemography__c>> consBurDemogMap = new Map<Id, List<BureauDemography__c>>();
                
                //Applicant Id and List of BureauHeader__c records map
                Map<Id, List<BureauHeader__c>> consBurHeadMap = new Map<Id, List<BureauHeader__c>>();
                
                //Applicant Id and List of Rank__c records map
                Map<Id, List<Rank__c>> rankMap = new Map<Id, List<Rank__c>>();
                
                Map<String, String> multBureResMast = new Map<String, String>();
                
                if(!conBureauResIds.isEmpty()) {
                    consBurEnqMap=CrifExecuteAPIRequestGeneratorHelper.consBurEnq(conBureauResIds);
                    
                    consBurResDetMap=CrifExecuteAPIRequestGeneratorHelper.consBurResDet(conBureauResIds,applyIdList);
                    
                    for(MultiBureau_Response_Master__mdt temp : [SELECT Label, Loan_Type__c FROM MultiBureau_Response_Master__mdt]) {
                        multBureResMast.put(temp.Loan_Type__c, temp.Label);
                    }
                    
                    consBurDemogMap=CrifExecuteAPIRequestGeneratorHelper.consBurDemog(conBureauResIds);
                    
                    consBurHeadMap=CrifExecuteAPIRequestGeneratorHelper.consBurHead(conBureauResIds);
                }
                
                if(!commBureauResIds.isEmpty()) {
                    rankMap=CrifExecuteAPIRequestGeneratorHelper.rank(commBureauResIds);
                }
                
                //Location Master
                if(!cityIds.isEmpty()) {
                    locatMasterMap=CrifExecuteAPIRequestGeneratorHelper.locatMaster(cityIds);
                }
                
                
                //Master Data Map
                masterDataMap=CrifExecuteAPIRequestGeneratorHelper.masterData(masterDataKey,custProfSel,crifValSet);
                
                
                //LAK-6471 Start
                Map<Id,HunterVer__c> hunterMap =new Map<Id,HunterVer__c>();
                hunterMap=CrifExecuteAPIRequestGeneratorHelper.hunter(loanIDs);
                
                Map<Id,Case> caseMap =new Map<Id,Case>();
                caseMap=CrifExecuteAPIRequestGeneratorHelper.caseVal(loanIDs);
                
                //LAK-8570
                List<DedupeResponse__c> dedupeResp = [SELECT ID, Lan__c, Applicant__c, UCID__c FROM DedupeResponse__c WHERE RecordType.Name = 'DedupeMatchCr' AND IntnlDeduRelevance__c = 'Accurate Match found' AND LoanAppln__c IN :loanIDs];
                
                List<Id> appIdsMatchFound = new List<Id>();
                for(DedupeResponse__c dedupe : dedupeResp){
                    appIdsMatchFound.add(dedupe.Applicant__c);
                }
                
                
                
                Map<Id,List<DedupeResponse__c>> dedupeMap =new Map<Id,List<DedupeResponse__c>>();
                Set<String> pastLans = new Set<String>();
                Set<String> ucidSet = new Set<String>();
                for(DedupeResponse__c dedu:[Select id,LoanAppln__c,AUM__c,IsLatest__c,RecordType.DeveloperName,LoanType__c,AUF__c, UCID__c, Lan__c,Loan_to_be_closed_internally__c from DedupeResponse__c 
                                            Where LoanAppln__c IN:loanIDs AND RecordType.DeveloperName='ENPA' AND Applicant__c IN :appIdsMatchFound]){
                                                
                                                if(!pastLans.contains(dedu.Lan__c) && !ucidSet.contains(dedu.UCID__c) && dedu.Loan_to_be_closed_internally__c == 'No'){
                                                    if(dedupeMap.containsKey(dedu.LoanAppln__c)){
                                                        dedupeMap.get(dedu.LoanAppln__c).add(dedu);
                                                    }else{
                                                        dedupeMap.put(dedu.LoanAppln__c,new List<DedupeResponse__c>{dedu});
                                                    }
                                                    pastLans.add(dedu.Lan__c);
                                                    ucidSet.add(dedu.UCID__c);
                                                }
                                                
                                            }
                
                Map<Id,UWDecision__c> UWDecisionMap=new Map<Id,UWDecision__c>();
                UWDecisionMap=CrifExecuteAPIRequestGeneratorHelper.UWDecision(loanIDs);
                //LAK-6471 End
                
                //LAK-9870 Start
                Map<Id,String> applVerificationMap =new Map<Id,String>();
                
                if(!applyIdList.isEmpty()){
                    
                    applVerificationMap=CrifExecuteAPIRequestGeneratorHelper.applVerification(applyIdList);
                }
                
                Map<Id,Date> caseAddressMap =new Map<Id,Date>();
                if(!loanIDs.isEmpty()){
                    
                    for(case cs:[Select id,ApplAddr__c,RecordType.DeveloperName,Date_of_Report__c,Status from Case 
                                 Where Loan_Application__c IN:loanIDs AND Status='Closed' order by CreatedDate DESC]){
                                  
                                     if(!caseAddressMap.containsKey(cs.ApplAddr__c) && cs.ApplAddr__c!=null && 
                                        cs.RecordType.DeveloperName=='CPVFI' && cs.Date_of_Report__c!=null){
                                            
                                            caseAddressMap.put(cs.ApplAddr__c,cs.Date_of_Report__c);
                                        }
                                 }
                }
                
                //LAK-9870 End
                
                for(IntgMsg__c intmsg : msgs) {
                    
                    //Create Application Variable
                    CrifExecuteAPIRequestWrapper.ApplicationVariables appvar = new CrifExecuteAPIRequestWrapper.ApplicationVariables();
                    
                    
                    
                    Decimal dedupeLoanAmt = 0;
                    Decimal maxDPD = 0;
                    String appSubDate = '';
                    if(loanmap.containskey(intmsg.RefId__c)) {
                        LoanAppl__c La = loanmap.get(intmsg.RefId__c);
                        
                        
                        if(!dedupeResLAMap.isEmpty() && dedupeResLAMap.containsKey(La.Id) && dedupeResLAMap.get(La.Id) != NULL) {
                            for(DedupeResponse__c drVar : dedupeResLAMap.get(La.Id)) {
                                if(drVar.IntnlDeduRelevance__c != NULL && drVar.IntnlDeduRelevance__c.equalsIgnoreCase('Accurate Match found') && drVar.LoanAmount__c != NULL) {
                                    dedupeLoanAmt += drVar.LoanAmount__c;
                                }
                                
                                if(drVar.DPD__c != NULL && drVar.DPD__c.isNumeric()) {
                                    Decimal tempVar = Decimal.valueOf(drVar.DPD__c);
                                    if(tempVar > maxDPD) {
                                        maxDPD = tempVar.setScale(2);
                                    }
                                } 
                            }
                        }
                        
                        appSubDate = La.LoanApplSubDt__c != NULL ? String.valueOf(La.LoanApplSubDt__c) : '';
                        
                        appvar = applicantVariable(La, schemeMap, btFinStat, balTranFinMap, loanPurMap, promCodeMap, masterDataMap, bankBranchMstrMap, btLoanMap, brdetList);
                        
                        //LAK-6471 Start
                        appvar.hunter_status_match_or_not_match=(!hunterMap.isEmpty() && hunterMap.containsKey(La.Id) && String.isNotblank(hunterMap.get(La.Id).HunMatchSta__c))?masterDataMapUtility(masterDataMap, 'Hunter Status',hunterMap.get(La.Id).HunMatchSta__c):'';
                        appvar.date_of_rcu_report = (!caseMap.isEmpty() && caseMap.containsKey(La.Id) && caseMap.get(La.Id).Date_of_Report__c != null)? DateTime.newInstance(caseMap.get(La.Id).Date_of_Report__c, Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd'): '';
                        appvar.first_sanction_date = (!UWDecisionMap.isEmpty() && UWDecisionMap.containsKey(La.Id) && UWDecisionMap.get(La.Id).DecisionDt__c != null)? DateTime.newInstance(UWDecisionMap.get(La.Id).DecisionDt__c, Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd'): '';
                        
                        Decimal ExposureTotal=0;
                        Decimal ExposureSameProduct=0;
                        
                        if(!dedupeMap.isEmpty() && dedupeMap.containsKey(La.Id)){
                            
                            List<DedupeResponse__c> dedRespList =dedupeMap.get(La.Id);
                            
                            if(!dedRespList.isEmpty()){
                                
                                for(DedupeResponse__c dedResp:dedRespList){
                                    
                                    //dedupeLoanTypeMap.containsKey(La.Product__c) this Logic is used as per LAK-9882
                                    if(dedupeLoanTypeMap.containsKey(La.Product__c) && dedResp.LoanType__c==dedupeLoanTypeMap.get(La.Product__c) && dedResp.AUF__c!=null){
                                        ExposureSameProduct+=dedResp.AUF__c;
                                    }
                                    if(dedResp.AUF__c!=null){
                                        ExposureTotal+=dedResp.AUF__c;
                                    }
                                }
                            }
                        }
                        
                        appvar.Existing_Fedfina_Loan_Exposure_Total=ExposureTotal;
                        appvar.Existing_Fedfina_Loan_Exposure_Same_Product=ExposureSameProduct;
                        
                        appvar.Is_Top_Up_being_processed_parallelly_along_with_HL_BT='';
                        appvar.Status_of_Proposed_Top_up_loan='';
                        appvar.HL_Top_up_loan_has_been_added_in_obligation='';
                        appvar.Status_of_Parallel_HL_BT_loan_application='';
                        appvar.HL_BT_loan_has_been_added_in_obligation='';
                        appvar.Income_ownership_norms_met_as_per_policy=''; 
                        appvar.HL_Top_up_loan_amount=0;
                        appvar.HL_Top_up_EMI=0;
                        appvar.HL_BT_loan_amount=0;
                        appvar.HL_BT_loan_EMI=0;
                        appvar.Cumulative_HL_BT_plus_Top_Up_loan_amount=0;
                        appvar.Total_of_Existing_continuing_Fedfina_Loan_amount=0;
                        appvar.Total_of_Existing_continuing_Fedfina_Loan_Principal_outstanding=0;
                        appvar.Total_of_Existing_continuing_Fedfina_EMI=0;
                        //LAK-6471 END
                        
                        if(!La.Applicant_Assets__r.isEmpty()) {
                            for(ApplAsset__c aa : La.Applicant_Assets__r) {
                                CrifExecuteAPIRequestWrapper.Property pty = new CrifExecuteAPIRequestWrapper.Property();
                                CrifExecuteAPIRequestWrapper.PropertyVariables provariable = new CrifExecuteAPIRequestWrapper.PropertyVariables();
                                provariable = propertyVariable(aa, locatMasterMap, properSubMap, appAssCaseMap, masterDataMap, propDocVar);
                                
                                pty.Variables=provariable;
                                Categorieslist.add(new Map<String,object>{'PROPERTY'=>pty});
                            }
                        }
                        
                    }
                    // Applicants Data
                    if(!applyMap.isEmpty() && applyMap.containskey(intmsg.RefId__c)) {
                        
                        for(Applicant__c app : applyMap.get(intmsg.RefId__c)) {
                            
                            CrifExecuteAPIRequestWrapper.Customer apptag = new CrifExecuteAPIRequestWrapper.Customer();
                            CrifExecuteAPIRequestWrapper.Variables aplvar = new CrifExecuteAPIRequestWrapper.Variables();
                            
                            String custTag, uniqId;
                            if(app.ApplType__c != NULL) {
                                if(app.ApplType__c.equalsIgnoreCase('P')) {
                                    custTag = 'APP';
                                    uniqId = '';
                                }
                                else if(app.ApplType__c.equalsIgnoreCase('C')) {
                                    uniqId = app.Id;
                                    custTag = 'COAPP';
                                }
                                else if(app.ApplType__c.equalsIgnoreCase('G')) {
                                    uniqId = app.Id;
                                    custTag = 'GR';
                                }
                            }
                            
                            Datetime dob = app.DOB__c != NULL ? Datetime.newInstance(app.DOB__c.year(), app.DOB__c.month(), app.DOB__c.day()) : NULL;
                            String birth = dob != NULL ? dob.format('yyyy-MM-dd') : '';
                            
                            Datetime doi = app.DOI__c != NULL ? (Datetime.newInstance(app.DOI__c.year(), app.DOI__c.month(), app.DOI__c.day())) : NULL;
                            String incorp = doi != NULL ? doi.format('yyyy-MM-dd') : '';
                            
                            aplvar.cust_applicant_type = app.ApplType__c != NULL ? app.ApplType__c : '';
                            aplvar.cust_date_of_birth_date_of_incorporation = app.Constitution__c != NULL ? app.Constitution__c == 'INDIVIDUAL' ? birth : incorp : ''; 
                            aplvar.unique_id = uniqId != NULL ? uniqId : '';
                            String tempCustInc = '';
                            if(app.ApplType__c != NULL && (app.ApplType__c.equalsIgnoreCase('P') || ((app.ApplType__c.equalsIgnoreCase('C') || app.ApplType__c.equalsIgnoreCase('G'))) && app.Type_of_Borrower__c != NULL && app.Type_of_Borrower__c.equalsIgnoreCase('Financial'))) {
                                tempCustInc = 'Yes';
                            }
                            else {
                                tempCustInc = 'No';
                            }
                            aplvar.cust_consider_income = tempCustInc;
                            aplvar.cust_category = app.Category__c != NULL ? app.Category__c : '';
                            aplvar.cust_company_name = app.CompanyName__c != NULL ? app.CompanyName__c : '';
                            aplvar.cust_customer_profile_categorisation = app.Customer_Profile_Categorisation__c != NULL ? app.Customer_Profile_Categorisation__c : '';
                            aplvar.cust_education_qualification = app.EduQual__c != NULL ? masterDataMapUtility(masterDataMap, 'Education Qualification', app.EduQual__c) : '';
                            aplvar.cust_first_name = app.FName__c != NULL ? app.FName__c : '';
                            aplvar.cust_last_name = app.LName__c != NULL ? app.LName__c : '';
                            aplvar.cust_lei_no = app.LEI_Number__c != NULL ? app.LEI_Number__c:'';
                            aplvar.cust_listed_unlisted = app.Listed_Unlisted__c != NULL ? app.Listed_Unlisted__c : '';
                            aplvar.cust_marital_status = app.MariStatus__c != NULL ? masterDataMapUtility(masterDataMap, 'Marital Status', app.MariStatus__c) : '';
                            aplvar.cust_medical_council = app.MediCouncl__c != NULL ? app.MediCouncl__c : '';
                            aplvar.cust_occ_customer_profile = app.CustProfile__c != NULL ? masterDataMapUtility(masterDataMap, 'Customer Profile', app.CustProfile__c) : '';
                            aplvar.cust_politically_exposed_person = app.Politically_Exposed_Person__c != NULL ? app.Politically_Exposed_Person__c : '';
                            aplvar.cust_professional_qualification = app.ProfQual__c != NULL ? masterDataMapUtility(masterDataMap, 'Professional Qualification', app.ProfQual__c) : '';
                            aplvar.cust_relationship = app.Relationship__c != NULL ? app.Relationship__c : '';
                            aplvar.cust_religion = app.Religion__c != NULL ? masterDataMapUtility(masterDataMap, 'Religion', app.Religion__c) : '';
                            aplvar.cust_whether_partnership_is_registered = app.Whether_partnership_is_registered__c != NULL ? app.Whether_partnership_is_registered__c : '';
                            aplvar.cust_whether_politically_exposed_person = app.Politically_Exposed_Person__c != NULL ? app.Politically_Exposed_Person__c : '';
                            aplvar.cust_year_of_registration = app.YearOfRegistration__c != NULL ? app.YearOfRegistration__c.setScale(2) : 0;
                            aplvar.average_monthly_cash_salary = app.Average_Monthly_Cash_Salary__c != NULL ? app.Average_Monthly_Cash_Salary__c.setScale(2) : 0;
                            aplvar.average_monthly_gross_salary = app.Average_Monthly_Gross_Salary__c != NULL ? app.Average_Monthly_Gross_Salary__c.setScale(2) : 0;
                            aplvar.gender = app.Gender__c != NULL ? app.Gender__c : '';
                            aplvar.cust_loanstatus = app.LoanAppln__r.Status__c != NULL ? app.LoanAppln__r.Status__c : '';
                            //
                            aplvar.Is_proprietorship_firm_part_of_proposal=(!applicantMap.isEmpty() && applicantMap.containskey(app.Id) && String.isNotBlank(applicantMap.get(app.Id)))?(applicantMap.get(app.Id) == 'YES' ? 'Yes' : 'No'):'';
                            //bureau
                            Double cibilScore = 0;
                            if(!app.Bureau_Responses__r.isEmpty()) {
                                for(Bureau__c bu : app.Bureau_Responses__r) {
                                    if(bu.IsLatest__c == TRUE && String.isNotBlank(bu.Score__c) && bu.Score__c.isNumeric()) {
                                        cibilScore = Double.valueOf(bu.Score__c);
                                        break;
                                    }
                                }
                            }
                            aplvar.CIBIL_Score = cibilScore;
                            
                            //ENPA 
                            DedupeResponse__c enVar, dedVar;
                            Decimal ucidDPD = 0;
                            String internalDedRes, securtStat = 'No', intDedupRelvnc = '', intDedupRes = '', pddPen = 'No', negListDedupe = 'No';
                            if(!dedupeResMap.isEmpty() && dedupeResMap.containsKey(app.Id) && dedupeResMap.get(app.Id) != NULL) {
                                for(DedupeResponse__c en : dedupeResMap.get(app.Id)) {
                                    if(en.recordtype.name != NULL && en.recordtype.name.equalsIgnoreCase('ENPA') && en.IsLatest__c == TRUE) {
                                        enVar = en;
                                        break;
                                    }
                                }
                                for(DedupeResponse__c en : dedupeResMap.get(app.Id)) {
                                    if(en.recordtype.name != NULL && en.recordtype.name.equalsIgnoreCase('Dedupe')) {
                                        dedVar = en;
                                        break;
                                    }
                                }
                                String intDedRelAccMat, intDedRelInacAccMat;
                                Boolean negDedVar = FALSE, posDedVar = FALSE;
                                for(DedupeResponse__c en : dedupeResMap.get(app.Id)) {
                                    if(en.recordtype.name != NULL && (en.recordtype.name.equalsIgnoreCase('DedupeMatchCr') || en.recordtype.name.equalsIgnoreCase('Dedupe'))) {
                                        if(en.SecuritisationStatus__c != NULL && en.SecuritisationStatus__c.equalsIgnoreCase('Y') && en.IntnlDeduRelevance__c != NULL && en.IntnlDeduRelevance__c.equalsIgnoreCase('Accurate Match found')) {
                                            securtStat = 'Yes';
                                        }
                                        if(en.IntnlDeduRelevance__c != NULL) {
                                            if(en.IntnlDeduRelevance__c.equalsIgnoreCase('Accurate Match found')) {
                                                intDedRelAccMat = 'Accurate Match Found';
                                                
                                                if(en.IntrnlDeduperes__c != NULL) {
                                                    if(!en.IntrnlDeduperes__c.equalsIgnoreCase('Positive Dedupe')) {
                                                        negDedVar = TRUE;
                                                    }
                                                    else if(en.IntrnlDeduperes__c.equalsIgnoreCase('Positive Dedupe')) {
                                                        posDedVar = TRUE;
                                                    }
                                                }
                                            }
                                            else if(en.IntnlDeduRelevance__c.equalsIgnoreCase('Inaccurate match found')) {
                                                intDedRelInacAccMat = 'Inaccurate Match Found';
                                            }
                                        }
                                        if(en.recordtype.name.equalsIgnoreCase('Dedupe') && en.MatchSource__c != NULL && en.MatchSource__c.equalsIgnoreCase('NegativeList') && en.IsLatest__c == TRUE) {
                                            negListDedupe = 'Yes';
                                        }
                                    }
                                }
                                
                                if(String.isNotBlank(intDedRelAccMat)) {
                                    intDedupRelvnc = intDedRelAccMat;
                                    for(DedupeResponse__c en : dedupeResMap.get(app.Id)) {
                                        if(en.recordtype.name != NULL && en.recordtype.name.equalsIgnoreCase('ENPA') && en.IsLatest__c == TRUE) {
                                            if(en.DPD__c != NULL && en.DPD__c.isNumeric()) {
                                                Decimal tempVar = Decimal.valueOf(en.DPD__c);
                                                if(tempVar > ucidDPD) {
                                                    ucidDPD = tempVar;
                                                }
                                            }
                                            if(en.IsPDDpending__c != NULL && en.IsPDDpending__c.equalsIgnoreCase('Yes')) {
                                                pddPen = 'Yes';
                                            }
                                        }
                                    }
                                }
                                else if(String.isNotBlank(intDedRelInacAccMat) && String.isBlank(intDedupRelvnc)) {
                                    intDedupRelvnc = intDedRelInacAccMat;
                                }
                                
                                if(negDedVar) {
                                    intDedupRes = 'Negative';
                                }
                                else if(negDedVar == FALSE && posDedVar == TRUE) {
                                    intDedupRes = 'Positive';
                                }
                            }
                            aplvar.Is_PDD_Pending = pddPen;
                            aplvar.Negative_list_dedupe = negListDedupe;
                            aplvar.Securitisation_Status = securtStat;
                            aplvar.Internal_Dedupe_Relevance = intDedupRelvnc;
                            aplvar.Internal_Dedupe_Result = intDedupRes;
                            aplvar.UCID_level_DPD = ucidDPD;
                            aplvar.cust_asset_classification = (enVar != NULL && enVar.FinalAssetClass__c != NULL) ? enVar.FinalAssetClass__c : '';
                            aplvar.cust_auf = (enVar != NULL && enVar.AUF__c != NULL) ? enVar.AUF__c.setScale(2) : 0;
                            aplvar.cust_aum = (enVar != NULL && enVar.AUM__c != NULL) ? enVar.AUM__c.setScale(2) : 0;
                            aplvar.cust_enpa_rejection_reason = ''; //will be blank
                            aplvar.cust_finalassetclass =  (enVar != NULL && enVar.FinalAssetClass__c != NULL) ? enVar.FinalAssetClass__c : '';
                            aplvar.cust_linked_ucic = (enVar != NULL && enVar.LinkedUCIC__c != NULL) ? enVar.LinkedUCIC__c : '';
                            aplvar.cust_ucic = (enVar != NULL && enVar.UCID__c != NULL) ? enVar.UCID__c : '';
                            aplvar.cust_npa_date = (enVar != NULL && enVar.NPADate__c != NULL) ? String.valueOf(Datetime.newInstance(enVar.NPADate__c.year(), enVar.NPADate__c.month(), enVar.NPADate__c.day()).format('yyyy-MM-dd')) : ''; 
                            aplvar.cust_internal_dedupe_result = intDedupRes;
                            aplvar.cust_loantype = (dedVar != NULL && dedVar.LoanType__c != NULL) ? dedVar.LoanType__c : '';
                            aplvar.cust_securitisation_status = securtStat;
                            aplvar.cust_securitizationflag = securtStat;
                            
                            //Case data mapping
                            Case cs,cpfviCase,lipVendorCase;
                            String reportResCPVFIRes, reportResCPVFIResCumOf, reportResCPVFIOff, reportResCPVFIPrinPlcBs;
                            if(!app.Cases__r.isEmpty() && String.isNotBlank(app.Constitution__c)) {
                                Case resCase, resCumOfCase, prinCase;
                                
                                //LAK--8121 Start
                                //cust_fi_report_result mapping
                                Integer custFiReportValue =0;
                                
                                for(Case temp : app.Cases__r) {
                                    
                                    if(temp.RecordType.Name!=null && temp.RecordType.Name=='CPVFI' && 
                                       cpfviCase==null && temp.Date_of_Report__c!=null){
                                           cpfviCase=temp;
                                       }
                                    if(String.isNotBlank(temp.Address_Type__c)) {
                                        if(temp.Address_Type__c.equalsIgnoreCase('Residence Address')) {
                                            
                                            //cust_fi_report_result mapping
                                            if(temp.ReportResult__c != NULL && temp.Negative_Report_reason__c != NUll &&
                                               custFiReportResult.containsKey(temp.ReportResult__c) && custFiReportResult.get(temp.ReportResult__c)>custFiReportValue){
                                                   
                                                   reportResCPVFIRes =temp.Negative_Report_reason__c;
                                                   cs = temp;
                                               }
                                            //Previous Code by ripul
                                            //reportResCPVFIRes = reportResCPVFIRes == NULL && temp.ReportResult__c != NULL && temp.Negative_Report_reason__c != NULL && temp.ReportResult__c.equalsIgnoreCase('Negative') ? temp.Negative_Report_reason__c : NULL;
                                            // resCase = temp;
                                        }
                                        else if(temp.Address_Type__c.equalsIgnoreCase('Residence Cum office')) {
                                            
                                            //cust_fi_report_result mapping
                                            if(temp.ReportResult__c != NULL && temp.Negative_Report_reason__c != NULL &&
                                               custFiReportResult.containsKey(temp.ReportResult__c) && custFiReportResult.get(temp.ReportResult__c)>custFiReportValue){
                                                   
                                                   reportResCPVFIResCumOf =temp.Negative_Report_reason__c;
                                                   cs = temp;
                                               }
                                            
                                            //Previous Code by ripul
                                            // reportResCPVFIResCumOf = reportResCPVFIResCumOf == NULL && temp.ReportResult__c != NULL && temp.Negative_Report_reason__c != NULL && temp.ReportResult__c.equalsIgnoreCase('Negative') ? temp.Negative_Report_reason__c : NULL;
                                            // resCumOfCase = temp;
                                        }
                                        else if(temp.Address_Type__c.equalsIgnoreCase('Office Address')) {
                                            
                                            //cust_fi_report_result mapping
                                            if(temp.ReportResult__c != NULL && temp.Negative_Report_reason__c != NULL &&
                                               custFiReportResult.containsKey(temp.ReportResult__c) && custFiReportResult.get(temp.ReportResult__c)>custFiReportValue){
                                                   reportResCPVFIOff =temp.Negative_Report_reason__c;
                                               }
                                            
                                            //Previous Code by ripul
                                            //reportResCPVFIOff = temp.ReportResult__c != NULL && temp.Negative_Report_reason__c != NULL && temp.ReportResult__c.equalsIgnoreCase('Negative') ? temp.Negative_Report_reason__c : NULL;
                                        }
                                        /*Date:2024-06-05 
Author:Ripul Rawat 
Bug:LAK-7806
*/
                                        else if(temp.Address_Type__c.equalsIgnoreCase('Principal place for business')) {
                                            
                                            
                                            
                                            //cust_fi_report_result mapping
                                            if(temp.ReportResult__c != NULL && temp.Negative_Report_reason__c != NULL &&
                                               custFiReportResult.containsKey(temp.ReportResult__c) && custFiReportResult.get(temp.ReportResult__c)>custFiReportValue){
                                                   reportResCPVFIPrinPlcBs =temp.Negative_Report_reason__c;
                                               }
                                            
                                            if(custFiReportResult.containsKey(temp.ReportResult__c) && custFiReportResult.get(temp.ReportResult__c)>custFiReportValue) {
                                                cs = temp;
                                            }
                                            
                                            //Previous Code by ripul
                                            // reportResCPVFIPrinPlcBs = temp.ReportResult__c != NULL && temp.Negative_Report_reason__c != NULL && temp.ReportResult__c.equalsIgnoreCase('Negative') ? temp.Negative_Report_reason__c : NULL;
                                        }
                                        
                                        /*  else if(temp.Address_Type__c.equalsIgnoreCase('Principal place for business') && prinCase == NULL &&
custFiReportResult.containsKey(temp.ReportResult__c) && custFiReportResult.get(temp.ReportResult__c)>custFiReportValue) {
prinCase = temp;
}*/
                                        
                                        //incriminating custFiReportValue
                                        custFiReportValue=custFiReportResult.containsKey(temp.ReportResult__c)?custFiReportResult.get(temp.ReportResult__c):0;
                                    }
                                    //LAK--8121 Stop
                                    //LAK -9282 start
                                    if(lipVendorCase==Null && temp.RecordType.Name=='LIP Vendor case' && temp.Status=='Closed'){
                                        lipVendorCase=temp;
                                    }
                                    //LAK -9282 stop
                                }
                                //cs = resCase != NULL ? resCase : (resCumOfCase != NULL ? resCumOfCase : (prinCase != NULL ? prinCase : NULL));
                            }
                            aplvar.cust_cpvfi_dedupe_for_negative_database = (cs != NULL && cs.Dedupe_for_Negative_Database__c != NULL) ? cs.Dedupe_for_Negative_Database__c : '';  
                            aplvar.cust_cpvfi_details_of_the_borrowers_have_been_confirmed = (cs != NULL && cs.Details_of_the_borrowers_have_been_confi__c != NULL) ? cs.Details_of_the_borrowers_have_been_confi__c : '';        
                            aplvar.cust_cpvfi_distance_from_fedfina_fi_initiated_branch = (cs != NULL && cs.Distance_from_Fedfina_Branch__c != NULL) ? cs.Distance_from_Fedfina_Branch__c.setScale(2) : 0;
                            aplvar.cust_cpvfi_marital_status = (cs != NULL && cs.Martial_Status__c != NULL) ? cs.Martial_Status__c : '';
                            aplvar.cust_cpvfi_negative_area = (cs != NULL && cs.Negative_Area__c != NULL) ? cs.Negative_Area__c : '';
                            aplvar.cust_cpvfi_negative_database_result = (cs != NULL && cs.Negative_Database_Result__c != NULL) ? (cs.Negative_Database_Result__c == 'Match Found' ? 'CPVND_MATCH' : 'CPVND_NOMATCH') : '';
                            aplvar.cust_cpvfi_negative_report_reason = (cs != NULL && cs.Negative_Report_reason__c != NULL) ? masterDataMapUtility(masterDataMap, 'Negative Report reason', cs.Negative_Report_reason__c) : '';
                            aplvar.cust_details_of_the_borrowers_have_been_confirmed = (cs != NULL && cs.Details_of_the_borrowers_have_been_confi__c != NULL) ? cs.Details_of_the_borrowers_have_been_confi__c : '';
                            aplvar.cust_fi_report_result = (cs != NULL && cs.ReportResult__c != NULL) ? masterDataMapUtility(masterDataMap, 'FI Report Result', cs.ReportResult__c) : ''; 
                            aplvar.cust_negative_area = (cs != NULL && cs.Negative_Area__c != NULL) ? cs.Negative_Area__c : ''; 
                            aplvar.cust_negative_database_result = (cs != NULL && cs.Negative_Database_Result__c != NULL) ? (cs.Negative_Database_Result__c == 'Match Not Found' ? 'ND_NOMATCH' : 'ND_MATCH') : '';
                            aplvar.cust_neighbour_reference_check = (cs != NULL && cs.Neighbour_Reference_Check__c != NULL) ? masterDataMapUtility(masterDataMap, 'Neighbour Reference Check', cs.Neighbour_Reference_Check__c) : '';
                            aplvar.cust_cpvfi_resi_negative_report_reason = reportResCPVFIRes != NULL ? masterDataMapUtility(masterDataMap, 'Negative Report reason', reportResCPVFIRes) : '';
                            aplvar.cust_cpvfi_resicumoffice_negative_report_reason = reportResCPVFIResCumOf != NULL ? masterDataMapUtility(masterDataMap, 'Negative Report reason', reportResCPVFIResCumOf) : '';
                            aplvar.cust_cpvfi_office_negative_report_reason = reportResCPVFIOff != NULL ? masterDataMapUtility(masterDataMap, 'Negative Report reason', reportResCPVFIOff) : (reportResCPVFIPrinPlcBs != NULL ? (masterDataMapUtility(masterDataMap, 'Negative Report reason', reportResCPVFIPrinPlcBs)) : '');
                                
                                //LAK-6471 Start
                                aplvar.date_of_FI_report=(cpfviCase!=null && cpfviCase.Date_of_Report__c!=null)?DateTime.newInstance(cpfviCase.Date_of_Report__c, Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd'):'';  
                            //LAK-6471 End
                            
                            //LAK -9282 start
                            aplvar.assPatAn=(lipVendorCase!=null && lipVendorCase.Assessed_PAT_Annual_In_Lacs__c!=null)?lipVendorCase.Assessed_PAT_Annual_In_Lacs__c:0;
                            aplvar.assessed_turnover_annual_in_lacs=(lipVendorCase!=null && lipVendorCase.Assessed_Turnover_Annual_In_Lacs__c!=null)?lipVendorCase.Assessed_Turnover_Annual_In_Lacs__c:0;
                            //LAK -9282 stop
                            
                            //Applicant employment  
                            ApplicantEmployment__c ae;
                            if(!app.Applicant_Employments__r.isEmpty()) {
                                ae = app.Applicant_Employments__r[0];   
                            }
                            
                            aplvar.cust_current_business_vintage_year = (ae != NULL && ae.CurrentBusinessVintage_Years__c != NULL) ? ae.CurrentBusinessVintage_Years__c.setScale(2) : 0;
                            aplvar.cust_date_of_udyam_registration = (ae != NULL && ae.DateOfUdyamRegistration__c != NULL) ? String.valueOf(Datetime.newInstance(ae.DateOfUdyamRegistration__c.year(), ae.DateOfUdyamRegistration__c.month(), ae.DateOfUdyamRegistration__c.day()).format('yyyy-MM-dd')) : '';  
                            aplvar.cust_entity_name = (ae != NULL && ae.EntityName__c != NULL) ? ae.EntityName__c : '';
                            aplvar.cust_current_business_vintage_month = (ae != NULL && ae.CurrentBusinessVintage_Months__c != NULL) ? ae.CurrentBusinessVintage_Months__c.setScale(2) : 0;
                            aplvar.cust_tot_work_experience_year = (ae != NULL && ae.TotalWorkExperience_Years__c != NULL) ? ae.TotalWorkExperience_Years__c.setScale(2) : 0;
                            aplvar.cust_working_with_current_employer_year = (ae != NULL && ae.WorkingWithCurrentEmployer_Years__c != NULL) ? ae.WorkingWithCurrentEmployer_Years__c.setScale(2) : 0;
                            aplvar.cust_working_with_current_employer_month = (ae != NULL && ae.WorkingWithCurrentEmployer_Months__c != NULL) ? ae.WorkingWithCurrentEmployer_Months__c.setScale(2) : 0;
                            aplvar.cust_type_of_organisation = (ae != NULL && ae.TypeOfOrganisation__c != NULL) ? ae.TypeOfOrganisation__c : '';
                            aplvar.cust_type_of_enterprise_as_per_urc = (ae != NULL && ae.TypeOfEnterprise_URC__c != NULL) ? ae.TypeOfEnterprise_URC__c : '';
                            aplvar.cust_tot_work_experience_month = (ae != NULL && ae.TotalWorkExperience_Months__c != NULL) ? ae.TotalWorkExperience_Months__c.setScale(2) : 0;
                            aplvar.cust_sub_industry = (ae != NULL && ae.SubIndustry__r.Name != NULL) ? ae.SubIndustry__r.Name : '';
                            aplvar.cust_percent_shareholding_in_the_entity = (ae != NULL && ae.ShareholdingInTheEntity__c != NULL) ? ae.ShareholdingInTheEntity__c.setScale(2) : 0;
                            aplvar.cust_official_email_id = (ae != NULL && ae.OfficialEmail__c != NULL) ? ae.OfficialEmail__c : '';
                            aplvar.cust_occ_designation = (ae != NULL && app.CustProfile__c != NULL && app.CustProfile__c != 'SALARIED') ? ((ae != NULL && ae.DesignationValues__c != NULL) ? ae.DesignationValues__c : '') : ((ae != NULL && ae.DesignationText__c != NULL) ? ae.DesignationText__c : '');
                                aplvar.cust_nature_of_business = (ae != NULL && app.Constitution__c == 'INDIVIDUAL') ? ((ae != NULL && ae.NatureOfBusinessIndividual__c != NULL) ? ae.NatureOfBusinessIndividual__c : '') : ((ae != NULL && ae.NatureOfBusinessCorporate__c != NULL) ? ae.NatureOfBusinessCorporate__c : '');
                                    aplvar.cust_is_urc_uac_available = (ae != NULL && ae.Is_URC_UAC_available__c != NULL) ? ae.Is_URC_UAC_available__c == 'YES' ? 'Yes' : 'No' : '';
                            aplvar.cust_is_the_prorietorship_firm_part_of_the_proposal = (ae != NULL && ae.Proprietorship_firm_part_of_the_proposal__c != NULL) ? ae.Proprietorship_firm_part_of_the_proposal__c : '';
                            aplvar.cust_industry_type = (ae != NULL && ae.IndustryType__r.Name != NULL) ? ae.IndustryType__r.Name : '';
                            aplvar.cust_gstin_status = (ae != NULL && ae.GSTIN_Status__c != NULL) ? ae.GSTIN_Status__c : '';
                            aplvar.cust_gst_registered = (ae != NULL && ae.GST_Registered__c != NULL) ? ae.GST_Registered__c == 'YES' ? 'Yes' : 'No' : '';
                            String custUdyam;
                            if(ae != NULL && ae.Select_applicability_for_URC_UAC__c != NULL) {
                                if(ae.Select_applicability_for_URC_UAC__c.equalsIgnoreCase('UDYAM ASSIST CERTIFICATE (UAC)') && ae.UdyamAssistCertificate__c != NULL) {
                                    custUdyam = masterDataMapUtility(masterDataMap, 'KYC Udyam Reg Cert', ae.UdyamAssistCertificate__c);
                                }
                                else if(ae.Select_applicability_for_URC_UAC__c.equalsIgnoreCase('UDYAM REGISTRATION NUMBER (URC)') && ae.UdyamRegistrationNumber__c != NULL) {
                                    custUdyam = masterDataMapUtility(masterDataMap, 'KYC Udyam Reg Cert', ae.UdyamRegistrationNumber__c);
                                }
                            }
                            aplvar.cust_kyc_udyam_registration_cert_or_udyam_assist_cert = custUdyam != NULL ? custUdyam : '';
                            
                            //Applicant Address 
                            ApplAddr__c applAddr;
                            if(!app.Applicant_Addresses__r.isEmpty()) { 
                                Boolean resAdd = FALSE, resCuAdd = FALSE, princPlBus = FALSE;
                                ApplAddr__c resAddVar, resCuAddVar, princPlBusVar;
                                for(ApplAddr__c adr : app.Applicant_Addresses__r) {
                                    
                                    if(adr.AddrTyp__c != NULL && adr.AddrTyp__c.equalsIgnoreCase('Residence Address')) {
                                        resAdd = TRUE;
                                        resAddVar = adr;
                                    }
                                    
                                    else if(adr.AddrTyp__c != NULL && adr.AddrTyp__c.equalsIgnoreCase('Residence Cum office')) {
                                        resCuAdd = TRUE;
                                        resCuAddVar = adr;
                                    }
                                    
                                    else if(adr.AddrTyp__c != NULL && adr.AddrTyp__c.equalsIgnoreCase('Principal place for business')) {
                                        princPlBus = TRUE;
                                        princPlBusVar = adr;
                                    }
                                }
                                
                                if(resAdd == TRUE) {
                                    applAddr = resAddVar;
                                }
                                
                                else if(resCuAdd == TRUE) {
                                    applAddr = resCuAddVar;
                                }
                                
                                else if(princPlBus == TRUE) {
                                    applAddr = princPlBusVar;
                                }
                                
                                for(ApplAddr__c adr : app.Applicant_Addresses__r) {
                                    CrifExecuteAPIRequestWrapper.AppAddress appAddr = new CrifExecuteAPIRequestWrapper.AppAddress();
                                    CrifExecuteAPIRequestWrapper.AppAddressVariables appAddrVar = new CrifExecuteAPIRequestWrapper.AppAddressVariables();
                                    
                                    appAddrVar = applyAddrVariables(adr, locatMasterMap, masterDataMap,caseAddressMap);
                                    appAddr.Variables = appAddrVar;
                                    if(custCatMap.containsKey(app.Id)) {  
                                        custCatMap.get(app.Id).add(new MAP<String,Object>{custTag + '_ADDRESS'=>appAddr});
                                    }
                                    else {
                                        List<Map<string,object>> tempList = new List<Map<string,object>>();
                                        tempList.add(new MAP<String,Object>{custTag + '_ADDRESS'=>appAddr});
                                        custCatMap.put(app.Id, tempList);
                                    }
                                }
                            }
                            
                            //Applicant GST
                            if(app.ApplType__c != 'G') {
                                if(!app.Applicant_GST__r.isEmpty()) {
                                    for(ApplGST__c applyGST : app.Applicant_GST__r) {
                                        CrifExecuteAPIRequestWrapper.GstData gstData = new CrifExecuteAPIRequestWrapper.GstData();
                                        CrifExecuteAPIRequestWrapper.GstDataVariables gstVar = new CrifExecuteAPIRequestWrapper.GstDataVariables();
                                        
                                        gstVar = gstVariables(applyGST);
                                        gstData.Variables = gstVar;
                                        
                                        if(custCatMap.containsKey(app.Id)) {
                                            custCatMap.get(app.Id).add(new MAP<String,Object>{custTag + '_GST_DATA'=>gstData});
                                        }
                                        else {
                                            List<Map<string,object>> tempList = new List<Map<string,object>>();
                                            tempList.add(new MAP<String,Object>{custTag + '_GST_DATA'=>gstData});
                                            custCatMap.put(app.Id, tempList);
                                        }
                                    }
                                } 
                            }
                            
                            
                            //Applicant Banking
                            if(app.ApplType__c != 'G') {
                                if(!app.Applicant_Banking1__r.isEmpty()) {
                                    for(ApplBanking__c applyBank : app.Applicant_Banking1__r) {
                                        
                                        CrifExecuteAPIRequestWrapper.BankingData bankData = new CrifExecuteAPIRequestWrapper.BankingData();
                                        CrifExecuteAPIRequestWrapper.BankingDataVariables bankDataVar = new CrifExecuteAPIRequestWrapper.BankingDataVariables();
                                        
                                        bankDataVar = applyBankingVariable(applyBank,btLoanMap,applBankDetailMap);
                                        
                                        bankData.Variables = bankDataVar;
                                        if(custCatMap.containsKey(app.Id)) {  
                                            custCatMap.get(app.Id).add(new MAP<String,Object>{custTag + '_BANKING_DATA'=>bankData});
                                        }
                                        else {
                                            List<Map<string,object>> tempList = new List<Map<string,object>>();
                                            tempList.add(new MAP<String,Object>{custTag + '_BANKING_DATA'=>bankData});
                                            custCatMap.put(app.Id, tempList);
                                        }
                                    }
                                }
                            }//
                            
                            
                            //Consumer Bureau Enqury Data
                            if(consBurEnqMap.containsKey(app.Id)) {
                                for(BureauEnquiry__c tempVar : consBurEnqMap.get(app.Id)) {
                                    CrifExecuteAPIRequestWrapper.EnquiryCons enqCons = new CrifExecuteAPIRequestWrapper.EnquiryCons();
                                    CrifExecuteAPIRequestWrapper.EnquiryConsVariables enqConsVar = new CrifExecuteAPIRequestWrapper.EnquiryConsVariables();
                                    
                                    enqConsVar = burEnqVariables(tempVar);
                                    enqCons.Variables =   enqConsVar;
                                    if(custCatMap.containsKey(app.Id)) { 
                                        custCatMap.get(app.Id).add(new MAP<String,Object>{custTag + '_ENQUIRY_CONS'=>enqCons});
                                    }
                                    else {
                                        List<Map<string,object>> tempList = new List<Map<string,object>>();
                                        tempList.add(new MAP<String,Object>{custTag + '_ENQUIRY_CONS'=>enqCons});
                                        custCatMap.put(app.Id, tempList);
                                    }                             
                                }
                            }
                            
                            //Consumer Bureau Response Detail Data
                            if(consBurResDetMap.containsKey(app.Id)) {
                                for(BureauRespDtl__c tempVar : consBurResDetMap.get(app.Id)) {
                                    CrifExecuteAPIRequestWrapper.ConsBuAccount burResDetCons = new CrifExecuteAPIRequestWrapper.ConsBuAccount();
                                    CrifExecuteAPIRequestWrapper.ConsBUAccountVariables burResDetConsVar = new CrifExecuteAPIRequestWrapper.ConsBUAccountVariables();
                                    
                                    burResDetConsVar = consBurVariables(tempVar, multBureResMast);
                                    burResDetCons.Variables = burResDetConsVar;
                                    
                                    if(custCatMap.containsKey(app.Id)) { 
                                        custCatMap.get(app.Id).add(new MAP<String,Object>{custTag + '_CONS_BU_ACCOUNT'=>burResDetCons});
                                    }
                                    else {
                                        List<Map<string,object>> tempList = new List<Map<string,object>>();
                                        tempList.add(new MAP<String,Object>{custTag + '_CONS_BU_ACCOUNT'=>burResDetCons});
                                        custCatMap.put(app.Id, tempList);
                                    }
                                }
                            }
                            
                            //Consumer Bureau Demography Data
                            if(consBurDemogMap.containsKey(app.Id)) {
                                for(BureauDemography__c tempVar : consBurDemogMap.get(app.Id)) {
                                    
                                    CrifExecuteAPIRequestWrapper.AppBurCons burDemogCons = new CrifExecuteAPIRequestWrapper.AppBurCons();
                                    CrifExecuteAPIRequestWrapper.AppBurConsVariables burDemogConsVar = new CrifExecuteAPIRequestWrapper.AppBurConsVariables();
                                    
                                    BureauHeader__c buRec = !consBurHeadMap.isEmpty() && consBurHeadMap.containsKey(app.Id) && !consBurHeadMap.get(app.Id).isEmpty() ? consBurHeadMap.get(app.Id)[0] : NULL;
                                    burDemogConsVar = burSummVarables(tempVar, buRec);
                                    burDemogCons.Variables = burDemogConsVar;
                                    
                                    if(custCatMap.containsKey(app.Id)) { 
                                        custCatMap.get(app.Id).add(new MAP<String,Object>{custTag + '_BUREAU_SUMMARY_CONS'=>burDemogCons});
                                    }
                                    else {
                                        List<Map<string,object>> tempList = new List<Map<string,object>>();
                                        tempList.add(new MAP<String,Object>{custTag + '_BUREAU_SUMMARY_CONS'=>burDemogCons});
                                        custCatMap.put(app.Id, tempList);
                                    }
                                }
                            } 
                            
                            //Commercial Rank Data
                            if(rankMap.containsKey(app.Id)) {
                                for(Rank__c tempVar : rankMap.get(app.Id)) {
                                    
                                    CrifExecuteAPIRequestWrapper.AppBurSummComm appBurSum = new CrifExecuteAPIRequestWrapper.AppBurSummComm();
                                    CrifExecuteAPIRequestWrapper.AppBurSummCommVariables appBurSumVar = new CrifExecuteAPIRequestWrapper.AppBurSummCommVariables();
                                    
                                    appBurSumVar = commBurSumVar(tempVar);
                                    appBurSum.Variables = appBurSumVar;
                                    
                                    if(custCatMap.containsKey(app.Id)) { 
                                        custCatMap.get(app.Id).add(new MAP<String,Object>{custTag + '_BUREAU_SUMMARY_COMM'=>appBurSum});
                                    }
                                    else {
                                        List<Map<string,object>> tempList = new List<Map<string,object>>();
                                        tempList.add(new MAP<String,Object>{custTag + '_BUREAU_SUMMARY_COMM'=>appBurSum});
                                        custCatMap.put(app.Id, tempList);
                                    }
                                }
                            } 
                            
                            //Financial Data Mapping 
                            Map<String, Applicant_Financial_Summary__c> mapBSVar = new Map<String, Applicant_Financial_Summary__c>();
                            Map<String, Applicant_Financial_Summary__c> mapPNLVar = new Map<String, Applicant_Financial_Summary__c>();
                            if(!mapBS.isEmpty()) {
                                if(mapBS.containsKey(app.Id) && !mapBS.get(app.Id).isEmpty()) {
                                    for(Map<String, Applicant_Financial_Summary__c> tempVar : mapBS.get(app.Id)) {
                                        mapBSVar.putAll(tempVar);
                                    }
                                }
                            }
                            
                            if(!mapPNL.isEmpty()) {
                                if(mapPNL.containsKey(app.Id) && !mapPNL.get(app.Id).isEmpty()) {
                                    for(Map<String, Applicant_Financial_Summary__c> tempVar : mapPNL.get(app.Id)) {
                                        mapPNLVar.putAll(tempVar);
                                    }
                                }
                            }
                            
                            Set<String> FY = new Set<String>();
                            if(!mapBSVar.isEmpty()) {
                                FY.addAll(mapBSVar.keySet());
                            }
                            if(!mapPNLVar.isEmpty()){
                                FY.addAll(mapPNLVar.keySet());
                            }
                            
                            if(app.ApplType__c != 'G') {
                                if(!FY.isEmpty()) {
                                    for(String tempVar : FY) {
                                        CrifExecuteAPIRequestWrapper.FinancialData finDataTag = new CrifExecuteAPIRequestWrapper.FinancialData();
                                        CrifExecuteAPIRequestWrapper.FinancialDataVariables finDataVar = new CrifExecuteAPIRequestWrapper.FinancialDataVariables();
                                        
                                        finDataVar = financVariables(tempVar, mapBSVar, mapPNLVar, masterDataMap, app);
                                        finDataTag.Variables = finDataVar;
                                        
                                        if(custCatMap.containsKey(app.Id)) { 
                                            custCatMap.get(app.Id).add(new MAP<String,Object>{custTag + '_FINANCIAL_DATA'=>finDataTag});
                                        }
                                        else {
                                            List<Map<string,object>> tempList = new List<Map<string,object>>();
                                            tempList.add(new MAP<String,Object>{custTag + '_FINANCIAL_DATA'=>finDataTag});
                                            custCatMap.put(app.Id, tempList);
                                        }
                                    }
                                }
                            }
                            
                            String custAddrType = '';
                            String custAddrTypeVar = '';
                            if(applAddr != NULL && String.isNotBlank(applAddr.AddrTyp__c)) {
                                //LAK 8475 Start(Commentting this code )
                                // if(applAddr.AddrTyp__c.equalsIgnoreCase('Other Address') || applAddr.AddrTyp__c.equalsIgnoreCase('Office Address')) {
                                //   custAddrType = 'Other Address';
                                //  }
                                // else {
                                custAddrType = applAddr.AddrTyp__c;
                                // }
                                //LAK 8475 End(Commentting this code )
                                custAddrTypeVar = String.isNotBlank(custAddrType) ? masterDataMapUtility(masterDataMap, 'Address Type', custAddrType) : '';
                            }
                            //aplvar.cust_negative_caution_area = (applAddr != NULL && applAddr.Negative_Caution_Area__c != NULL) ? applAddr.Negative_Caution_Area__c : '';
                            aplvar.cust_type_of_address = custAddrTypeVar;
                            
                            
                            String dlDate, panVar;
                            Map<String,String> kycMappingMap =new Map<String,String>();
                            //applkyc
                            if(!app.Applicant_KYC__r.isEmpty()) {
                                for(ApplKyc__c applyKYC : app.Applicant_KYC__r) {
                                    if(applyKYC.kycDoc__c != NULL && applyKYC.DLExpDt__c != NULL && applyKYC.kycDoc__c.equalsIgnoreCase('Driving License')) {
                                        dlDate = String.valueOf(applyKYC.DLExpDt__c);
                                    }
                                    if(applyKYC.kycDoc__c != NULL && applyKYC.kycDoc__c.equalsIgnoreCase('Pan') && applyKYC.Pan__c != NULL) {
                                        panVar = applyKYC.Pan__c;
                                    }
                                    
                                }
                                
                                //LAK-9870 Start
                                kycMappingMap=CrifExecuteAPIRequestGeneratorHelper.applyKyc(app.Applicant_KYC__r);
                                //LAK-9870 END
                            }
                            
                            aplvar.cust_driver_license_authentication = dlDate != NULL ? dlDate : '';
                            String constiVar, custProf;
                            constiVar = app.Constitution__c != NULL ? masterDataMapUtility(masterDataMap, 'Constitution', app.Constitution__c) : '';
                            custProf = app.CustProfile__c != NULL ? masterDataMapUtility(masterDataMap, 'Customer Profile', app.CustProfile__c) : '';
                            aplvar.cust_constitution = String.isNotBlank(constiVar) && constiVar.isNumeric() ? Double.valueOf(constiVar) : 0;
                            aplvar.cust_customer_profile = String.isNotBlank(custProf) && custProf.isNumeric() ? Double.valueOf(custProf) : 0;
                            aplvar.cust_customer_profile_selection = app.Customer_Profile_Selection_Id__c != NULL ? masterDataMapUtility(masterDataMap, 'Customer Profile Selection', app.Customer_Profile_Selection_Id__c) : '';
                            aplvar.cust_ageyear = app.DOB__c != NULL ? Double.valueOf(app.DOB__c.year()) : 0;
                            aplvar.cust_applicantname = app.FullName__c != NULL ? app.FullName__c : '';
                            aplvar.cust_applicationdate = appSubDate;
                            aplvar.cust_dateofincorporation = app.DOI__c != NULL ? String.valueOf(app.DOI__c) : '';
                            aplvar.cust_dedupe_loanamt = dedupeLoanAmt != NULL ? dedupeLoanAmt.setScale(2) : 0;
                            aplvar.cust_dpd_datalake_dedupe_enpa = maxDPD;
                            aplvar.rental_in_bank_credit = app.Average_Monthly_Rental_With_Bank_Credit__c != NULL ? app.Average_Monthly_Rental_With_Bank_Credit__c.setScale(2) : 0;  
                            aplvar.rental_with_no_bank_credit = app.Average_Monthly_Rental_No_Bank_Credit__c != NULL ? app.Average_Monthly_Rental_No_Bank_Credit__c.setScale(2) : 0;  
                            
                            String assPgm = '';
                            if(!masterDataMap.isEmpty() && masterDataMap.containsKey('Selected Eligibility Program') && String.isNotBlank(app.LoanAppln__r.Product__c) && String.isNotBlank(app.AssessmentProgram__c)) {
                                for(Map<String, String> temp : masterDataMap.get('Selected Eligibility Program')) {
                                    String prod;
                                    if(app.LoanAppln__r.Product__c.equalsIgnoreCase('Home Loan')) {
                                        prod = 'HL';
                                    }
                                    else if(app.LoanAppln__r.Product__c.equalsIgnoreCase('Small Ticket LAP')) {
                                        prod = 'STL';
                                    }
                                    else if(app.LoanAppln__r.Product__c.equalsIgnoreCase(System.Label.Loan_Against_Property)) {
                                        prod = 'STL';//LAP
                                    }
                                    if(prod != NULL) {
                                        String tempVar = app.AssessmentProgram__c.replaceAll(' ', '_') + '_' +  prod;
                                        tempVar = tempVar.toUpperCase();
                                        if(temp.containsKey(tempVar) && temp.get(tempVar) != NULL) {
                                            assPgm = temp.get(tempVar);
                                        }
                                    }
                                }
                            }
                            aplvar.selected_eligibility_program = app.Type_of_Borrower__c == 'Financial' ? assPgm : '';//LAK-9138
                            
                            //LAK-9870 Start
                            aplvar.cust_amt_payable=(!kycMappingMap.isEmpty() && kycMappingMap.containsKey('ElectAmtPayable'))?Decimal.valueOf(kycMappingMap.get('ElectAmtPayable')):0; //drop 2
                            aplvar.cust_bill_amt=(!kycMappingMap.isEmpty() && kycMappingMap.containsKey('ElectBillAmt'))?Decimal.valueOf(kycMappingMap.get('ElectBillAmt')):0;
                            aplvar.cust_tot_amt=(!kycMappingMap.isEmpty() && kycMappingMap.containsKey('ElectTotAmt'))?Decimal.valueOf(kycMappingMap.get('ElectTotAmt')):0;
                            aplvar.name_match_DL=(!kycMappingMap.isEmpty() && kycMappingMap.containsKey('DL'))?Decimal.valueOf(kycMappingMap.get('DL')):0;
                            aplvar.name_match_passport=(!kycMappingMap.isEmpty() && kycMappingMap.containsKey('Passport'))?Decimal.valueOf(kycMappingMap.get('Passport')):0;
                            aplvar.name_match_Aadhaar=(!kycMappingMap.isEmpty() && kycMappingMap.containsKey('Aadhaar'))?Decimal.valueOf(kycMappingMap.get('Aadhaar')):0;
                            aplvar.name_match_Voter_id=(!kycMappingMap.isEmpty() && kycMappingMap.containsKey('VoterId'))?Decimal.valueOf(kycMappingMap.get('VoterId')):0;
                            //LAK-9870 END
                            
                            
                            //No Mapping
                            
                            aplvar.cust_activitydescription=''; //drop 2
                            aplvar.cust_address_match=''; //drop 2
                            aplvar.cust_address_match_score=0; //drop 2
                            aplvar.cust_alertcount=0;
                            aplvar.cust_amt_namaste_credit_itr=0; //drop 2
                            aplvar.cust_asset_classification_date=''; //Blank
                            aplvar.cust_associateyear=0;  //drop 2
                            aplvar.cust_balancesheetcheck_amt=0; //drop 2
                            aplvar.cust_balancesheetcheck_inc_decrease_over_prev_yr=0; //drop 2
                            aplvar.cust_beneficial_owner_related_details=''; //Blank
                            aplvar.cust_beneficial_owner=''; //Blank
                            aplvar.cust_bounce=0; //Blank
                            aplvar.cust_ca_membership_authentication_name=''; //drop 2
                            aplvar.cust_closing_stock_amt=0; //drop 2
                            aplvar.cust_closing_stock_growth_perc=0; //drop 2
                            aplvar.cust_commencedate='';    //drop 2
                            aplvar.cust_controlling_ownership_interest_perc=0; //drop 2
                            aplvar.cust_copstatus=''; //drop 2
                            aplvar.cust_cpvfi_neighbour_reference_check=''; //Did not find in mapping sheet
                            aplvar.cust_cpvfi_property_type=''; //Did not find in mapping sheet
                            aplvar.cust_dateofcommencement='';  // drop 2
                            aplvar.cust_dateofregistration='';  //drop 2
                            aplvar.cust_debtors_period_in_days=0; //drop 2
                            aplvar.cust_deferred_tax_liability_assets_amt = 0; //drop 2
                            aplvar.cust_deferred_tax_liability_assets_inc_decrease_over_prev_yr = 0; //drop 2
                            aplvar.cust_depreciation_amt=0; //drop 2
                            aplvar.cust_depreciation_growth_perc=0; //drop 2
                            aplvar.cust_disciplinaryaction=''; //drop 2
                            aplvar.cust_dobmatch=''; //drop 2
                            aplvar.cust_duplicate_pan=''; //drop 2
                            aplvar.cust_email_authentication_disposable=''; //drop 2
                            
                            aplvar.cust_email_authentication_regexp=''; //drop 2 
                            aplvar.cust_email_authentication_result=''; //drop 2 
                            aplvar.cust_email_authentication_webmail=''; //drop 2
                            aplvar.cust_employer_emplrscore=0; //drop 2
                            aplvar.cust_enterprisetype=''; //drop 2
                            aplvar.cust_entityname=''; //drop 2
                            aplvar.cust_estinfo_confidence=0; //drop 2
                            aplvar.cust_estinfo_epfhistory=''; //drop 2
                            aplvar.cust_estinfo_isemployed=''; //drop 2
                            aplvar.cust_estinfo_isnameexact=''; //drop 2
                            aplvar.cust_existingFedfinaTenure=0; //Need to map
                            aplvar.cust_finance_cost_amt=0; //drop 2 
                            aplvar.cust_finance_cost_growth_perc=0; //drop 2
                            aplvar.cust_for_how_many_years_user_want_to_enter_itr_values=0; //drop 2
                            aplvar.cust_gstnstatus=''; //drop 2
                            aplvar.cust_income_details_amt=0; //drop 2 
                            aplvar.cust_income_details_growth_perc=0; //drop 2
                            aplvar.cust_individualmatch=''; //drop 2
                            aplvar.cust_individualmatch_name=''; //drop 2
                            aplvar.cust_individualmatch_score=0; //drop 2
                            aplvar.cust_individualmatchmatch=''; //drop 2
                            aplvar.cust_industrycode=''; //drop 2
                            aplvar.cust_inerest_paid_cash_credit_or_over_draft_amt=0; //drop 2
                            aplvar.cust_inerest_paid_cash_credit_or_over_draft_growth_perc=0; //drop 2
                            aplvar.cust_interest_paid_on_term_loan_amt=0; //drop 2
                            aplvar.cust_interest_paid_on_term_loan_growth_perc=0; //drop 2
                            aplvar.cust_interest_paid_to_partners_or_directors_growth_perc=0; //drop 2
                            aplvar.cust_intersest_paid_on_term_loan_amt=0; //drop 2 
                            aplvar.cust_intersest_paid_on_term_loan_growth_perc=0; //drop 2
                            String isAct = 'No', watchoutResRel = '', screeningRes = '', riskRating = '';
                            
                            //LAK-9870 Start
                            Boolean acceptAll=false;
                            Map<String,String> apiVerificationMap =new Map<String,String>();
                            //LAK-9870 End
                            
                            if(!app.API_Verifications__r.isEmpty()) {
                                String accMatchFnd, inAccMatchFnd;
                                for(APIVer__c aiVar : app.API_Verifications__r) {
                                    
                                    if(aiVar.RecordType.Name.equalsIgnoreCase('Screening') && aiVar.ScrRes__c != NULL) {
                                        isAct = aiVar.ScrRes__c.equalsIgnoreCase('Match') ? 'Yes' : 'No';
                                        screeningRes = aiVar.ScrRes__c.equalsIgnoreCase('Match') ? 'Match' : aiVar.ScrRes__c.equalsIgnoreCase('NotMatch') ? 'Not Match' : '';
                                    }
                                    if(aiVar.RecordType.Name.equalsIgnoreCase('Watchout') && aiVar.WatchoutInvestor__c == TRUE && aiVar.Result_Relevance__c != NULL) {
                                        if(aiVar.Result_Relevance__c.equalsIgnoreCase('Accurate Match Found')) {
                                            accMatchFnd = 'Accurate Match Found';
                                        }
                                        else if(aiVar.Result_Relevance__c.equalsIgnoreCase('Inaccurate Match Found')) {
                                            inAccMatchFnd = 'Inaccurate Match Found';
                                        }
                                    }
                                    if(aiVar.RecordType.Name.equalsIgnoreCase('Risk Rating') && aiVar.Risk_Rating_Final__c != NULL) {
                                        riskRating = aiVar.Risk_Rating_Final__c;
                                    }
                                    
                                    //LAK-9870 Start
                                    if(aiVar.RecordType.Name.equalsIgnoreCase('Email Authentication Advance')){
                                        
                                        if(aiVar.acceptAll__c){
                                            acceptAll=aiVar.acceptAll__c;
                                        }
                                        
                                        if(String.isNotblank(aiVar.Email__c)){
                                            apiVerificationMap.put('email',aiVar.Email__c);
                                        }
                                    }
                                    if(aiVar.RecordType.Name.equalsIgnoreCase('Qualification Check')){
                                        
                                        if(string.isNotblank(aiVar.Qualification__c)){
                                            apiVerificationMap.put('Qualification',aiVar.Qualification__c);
                                        }
                                        if(string.isNotblank(aiVar.QualificationYear__c)){
                                            apiVerificationMap.put('QualificationYear',aiVar.QualificationYear__c);
                                        }
                                    }
                                    //LAK-9870 End
                                }
                                
                                if(String.isNotBlank(accMatchFnd)) {
                                    watchoutResRel = accMatchFnd;
                                }
                                else if(String.isNotBlank(inAccMatchFnd) && String.isBlank(watchoutResRel)) {
                                    watchoutResRel = inAccMatchFnd;
                                }
                            }
                            
                            //LAK-9870 Start
                            aplvar.cust_accept_all=acceptAll?'Yes':'No';
                            aplvar.cust_email_authentication_email=(!apiVerificationMap.isEmpty() && apiVerificationMap.containsKey('email'))?apiVerificationMap.get('email'):'';
                            aplvar.cust_nmc_membership_qualification=(!apiVerificationMap.isEmpty() && apiVerificationMap.containsKey('Qualification'))?apiVerificationMap.get('Qualification'):'';
                            aplvar.cust_qualificationyear=(!apiVerificationMap.isEmpty() && apiVerificationMap.containsKey('QualificationYear'))?integer.valueof(apiVerificationMap.get('QualificationYear').replaceAll('[^0-9]', '')):0;
                            //LAK-9870 End
                            
                            aplvar.cust_isactive = isAct;  
                            aplvar.Screening_Results_Trackwizz = screeningRes;
                            aplvar.Risk_Rating_Final = riskRating;
                            aplvar.Result_Relevance_Watchout = watchoutResRel; 
                            aplvar.cust_kyc_details=''; //Blank
                            aplvar.cust_latest_year_for_which_itr_is_available=0; //drop 2
                            aplvar.custLigitgCrimeChk = '';  //aplvar.cust_litigation_crime_check__individual_status=''; //drop 2
                            aplvar.cust_majoractivity=''; //drop 2
                            aplvar.cust_memberstatus=''; //drop 2
                            aplvar.cust_mob=0;  //drop 2
                            aplvar.cust_month1_epfo_data=0;   //drop 2
                            aplvar.cust_month2_epfo_data=0;   //drop 2
                            aplvar.cust_month3_epfo_data=0;   //drop 2
                            aplvar.cust_mx_records='';        //drop 2
                            aplvar.cust_name_namastecredit_itr='';  //drop 2
                            aplvar.cust_name_of_employer=''; //Blank
                            aplvar.cust_name_similarity_result=''; //drop 2
                            aplvar.cust_name_similarity_score=0; //drop 2
                            aplvar.cust_namelookup_formatted_wage_month=''; //drop 2
                            aplvar.cust_namelookup_totamt=0;  //drop 2
                            aplvar.cust_namelookup_totmembers=0;  //drop 2
                            aplvar.cust_namelookup_wagemonth='';  //drop 2
                            aplvar.cust_namematch=0;  //drop 2
                            aplvar.cust_natureofbusiness=''; //drop 2
                            aplvar.cust_negative_list='';  //Blank
                            String unSerCity = 'No';
                            if(app.LoanAppln__r.Lead__r.UnservicableCityCheck__c == True) {
                                unSerCity = 'Yes';
                            }
                            aplvar.cust_negative_unservicable_city_check = unSerCity;
                            aplvar.cust_niccode='';  //drop 2
                            aplvar.cust_numberofcases=0; //drop 2
                            aplvar.cust_numberoffaces_imgae1=0; //Blank
                            aplvar.cust_numberoffaces_imgae2=0; //Blank
                            aplvar.cust_opening_stock_amt=0;  //drop 2
                            aplvar.cust_opening_stock_growth_perc=0; //drop 2
                            aplvar.cust_org_domain_match_domain='';  //drop 2
                            aplvar.cust_org_domain_match_match='';   //drop 2
                            aplvar.cust_org_domain_match_orgname=''; //drop 2
                            aplvar.cust_org_domain_match_source='';  //drop 2
                            aplvar.cust_org_email_match='';          //drop 2
                            aplvar.cust_org_email_match_companyemail=''; //drop 2
                            aplvar.cust_org_email_match_match='';  //drop 2
                            aplvar.cust_org_email_match_orgname=''; //drop 2
                            aplvar.cust_org_email_match_source='';  //drop 2
                            aplvar.cust_organization='';  //drop 2
                            aplvar.cust_organizationname=''; //drop 2
                            aplvar.cust_organizationtype=''; //drop 2
                            aplvar.cust_ownername='';  //drop 2
                            aplvar.cust_pan_authentication_status_code=0; //need to map
                            aplvar.cust_pan_check_result='';   //drop 2
                            aplvar.cust_pan_check_status='';   //drop 2
                            aplvar.cust_pan_check_status_code='';  //drop 2
                            aplvar.cust_pbdit_excluding_other_income_amt=0; //drop 2
                            aplvar.cust_pbdit_excluding_other_income_growth_perc=0; //drop 2
                            aplvar.cust_purchases_amt=0;  //drop 2
                            aplvar.cust_purchases_growth_perc=0;  //drop 2
                            aplvar.cust_qualification_proof='';  //Blank
                            aplvar.cust_ratios=0;  //drop 2
                            aplvar.cust_registrationdate='';    //drop 2  
                            aplvar.cust_restorationdate='';   //drop 2
                            aplvar.cust_retirement_age = (ae != NULL && ae.RetirementAge__c != NULL) ? ae.RetirementAge__c : 0;
                            aplvar.cust_risktype=''; //drop 2
                            aplvar.cust_udyam_registration_check_activity=''; //drop 2
                            aplvar.cust_udyam_registration_check_industry=''; //drop 2
                            aplvar.cust_udyam_registration_check_name='';     //drop 2
                            aplvar.cust_udyam_registration_checkpan='';       //drop 2                   
                            aplvar.cust_validfrom='';   //drop 2 
                            aplvar.cust_validto='';     //drop 2 
                            aplvar.cust_validupto='';   //drop 2  
                            aplvar.cust_watchlistname=''; //need to map
                            aplvar.cust_whoisinfo_creationdate='';  //drop 2
                            aplvar.cust_whoisinfo_expirationdate='';  //drop 2 
                            aplvar.cust_whoisinfo_expired='';  //drop 2
                            aplvar.cust_whoisinfo_updatedate='';   //drop 2 
                            aplvar.cust_whoisorgname_epfhistory=''; //drop 2
                            aplvar.cust_whoisorgname_namelookup=''; //drop 2
                            
                            aplvar.obligation = (!totOblig.isEmpty() && totOblig.containsKey(app.Id)) ? totOblig.get(app.Id) : 0;
                            aplvar.bounce_in_last_12_months=0;
                            aplvar.bounce_in_last_18_months=0;
                            aplvar.cust_status_datalake_dedupe_enpa='';
                            aplvar.cust_rule='';
                            aplvar.cust_rulename='';
                            aplvar.cust_rulescore=0;
                            aplvar.cust_ruletext='';
                            aplvar.cust_shop_category='';  //drop 2
                            aplvar.cust_shop_ownername=''; //drop 2
                            aplvar.cust_shop_status='';    //drop 2
                            aplvar.cust_smtp_check='';     //drop 2
                            aplvar.cust_spamemail='';      //drop 2
                            aplvar.cust_spamrecord_ipblacklist='';  //drop 2
                            aplvar.cust_spamrecord_reportcount=0;   //drop 2
                            aplvar.cust_loandisbdate=''; 
                            aplvar.cust_matched='';  
                            aplvar.cust_matchingperc=0; 
                            aplvar.cust_subindustry='';  //drop 2
                            aplvar.cust_subsector='';    //drop 2
                            aplvar.cust_subsectorcode=''; //drop 2
                            aplvar.cust_suspensiondate='';  //drop 2 
                            aplvar.cust_tot_loan_funds_amt=0; //drop 2
                            aplvar.cust_tot_loan_funds_inc_decrease_over_prev_year=0; //drop 2
                            aplvar.cust_tot_unsecured_loans_amt=0;  //drop 2
                            aplvar.cust_tot_unsecured_loans_inc_decrease_over_prev_yr=0;  //drop 2
                            aplvar.cust_totworkers=0;  //drop 2
                            aplvar.cust_trackwizzscreeningalertcreate_source='';
                            aplvar.cust_transactionstatus='';
                            aplvar.cust_internal_top_up_original_loan='';
                            aplvar.ownership_relation='';  //Blank  
                            aplvar.average_salary=0; //Blank
                            
                            Decimal benLTA = 0, perBon = 0, gorsSal = 0, totMonCred = 0, netSalAmt = 0, varCom = 0, totTax = 0, totOD = 0;
                            
                            //LAK-9870 Start
                            Set<String> multiTen =new Set<String>();
                            Set<String> ownershipproofdoc=new Set<String>();
                            Set<String> rentAgreement=new Set<String>();
                            Set<String> rentalVerification=new Set<String>();
                            Decimal noOfTenants=0;
                            //LAK-9870 END
                            
                            Applicant_Income__c cashFlowAppInc;
                            if(!app.Applicant_Income__r.isEmpty()) {
                                Integer noBenLTA = 0, noPerfBon = 0, noGrosSal = 0, noNetSal = 0, noVarComp = 0, noTax = 0, noOD = 0, noMonCred = 0;
                                Decimal monCredVar = 0, odVar = 0, taxVar = 0, varCompVar = 0, noNetSalVar = 0, grosSalVar = 0, perBonVar = 0, benLTATemp = 0;
                                
                                for(Applicant_Income__c temp : app.Applicant_Income__r) {
                                    if(temp.RecordType.Name != NULL && temp.RecordType.Name.equalsIgnoreCase('Bank Credit Salary')) {
                                        if(temp.LTA_Monthly__c != NULL) {
                                            benLTATemp += temp.LTA_Monthly__c;
                                            noBenLTA++;
                                        }
                                        if(temp.Performance_Bonus_Monthly__c != NULL) {
                                            perBonVar += temp.Performance_Bonus_Monthly__c;
                                            noPerfBon++;
                                        }
                                        if(temp.Gross_Salary_Rs__c != NULL) {
                                            grosSalVar += temp.Gross_Salary_Rs__c;
                                            noGrosSal++;
                                        }
                                        if(temp.Net_Salary__c != NULL) {
                                            noNetSalVar += temp.Net_Salary__c;
                                            noNetSal++;
                                        }
                                        if(temp.Variable_Component__c != NULL) {
                                            varCompVar += temp.Variable_Component__c;
                                            noVarComp++;
                                        }
                                        if(temp.Taxes__c != NULL) {
                                            taxVar += temp.Taxes__c;
                                            noTax++;
                                        }
                                        if(temp.Other_Deductions__c != NULL) {
                                            odVar += temp.Other_Deductions__c;
                                            noOD++;
                                        }
                                    }
                                    if(temp.RecordType.Name != NULL && temp.RecordType.Name.equalsIgnoreCase('Rental wBanking')) {
                                        if(temp.Month1_Rental_Credited_Amount__c != NULL) {
                                            monCredVar += temp.Month1_Rental_Credited_Amount__c;
                                            noMonCred++;
                                        }
                                        
                                        //LAK-9870 Start
                                        if(temp.Multi_Tenanted__c!=null && (temp.Multi_Tenanted__c=='Yes' || temp.Multi_Tenanted__c=='No')){
                                            multiTen.add(temp.Multi_Tenanted__c);
                                        }
                                        
                                        if(temp.No_of_Tenants__c!=null && temp.No_of_Tenants__c>noOfTenants){
                                            noOfTenants=temp.No_of_Tenants__c;
                                        }
                                        
                                        if(temp.Property_ownership_proof_documented__c!=null && (temp.Property_ownership_proof_documented__c=='Yes' || temp.Property_ownership_proof_documented__c=='No')){
                                            ownershipproofdoc.add(temp.Property_ownership_proof_documented__c);
                                        }
                                        
                                        if(temp.Rent_agreement_documented__c!=null && (temp.Rent_agreement_documented__c=='Yes' || temp.Rent_agreement_documented__c=='No')){
                                            rentAgreement.add(temp.Rent_agreement_documented__c);
                                            }
                                        
                                        if(temp.Rental_Verification_done__c!=null && (temp.Rental_Verification_done__c=='Yes' || temp.Rental_Verification_done__c=='No')){
                                            rentalVerification.add(temp.Rental_Verification_done__c);
                                        }
                                        //LAK-9870 END
                                    }
                                    
                                }
                                for(Applicant_Income__c temp : app.Applicant_Income__r) {
                                    if(temp.RecordType.Name != NULL && temp.RecordType.Name.equalsIgnoreCase('Cashflow Map') && app.LatestyearforwhichITRisavailable__c != NULL && app.LatestyearforwhichITRisavailable__c.equalsIgnoreCase('ITR Not Available')) {
                                        cashFlowAppInc = temp;
                                        break;
                                    }
                                }
                                if(noBenLTA != 0) {
                                    benLTA = (benLTATemp/noBenLTA).setScale(2);
                                }
                                if(noPerfBon != 0) {
                                    perBon = (perBonVar/noPerfBon).setScale(2);
                                }
                                if(noGrosSal != 0) {
                                    gorsSal = (grosSalVar/noGrosSal).setScale(2);
                                }
                                if(noNetSal != 0) {
                                    netSalAmt = (noNetSalVar/noNetSal).setScale(2);
                                }
                                if(noVarComp != 0) {
                                    varCom = (varCompVar/noVarComp).setScale(2);
                                }
                                if(noTax != 0) {
                                    totTax = (taxVar/noTax).setScale(2);
                                }
                                if(noOD != 0) {
                                    totOD = (odVar/noOD).setScale(2);
                                }
                                if(noMonCred != 0) {
                                    totMonCred = (monCredVar/noMonCred).setScale(2);
                                }
                            }
                            Map<string,String> docTypeMap =new Map<string,String>();
                            //Doc Detail
                            if(!applyDocMap.isEmpty() && applyDocMap.containsKey(app.Id) && !applyDocMap.get(app.Id).isEmpty()) {
                                
                                docTypeMap=CrifExecuteAPIRequestGeneratorHelper.docDetailsValue(applyDocMap.get(app.Id),fin44ADMap,app.Id);
                            }
                            aplvar.annual_benefits_like_lta = benLTA;
                            aplvar.average_monthly_pension = app.Average_Monthly_Pension__c != NULL ? app.Average_Monthly_Pension__c.setScale(2) : 0;
                            aplvar.performance_bonus = perBon;
                            aplvar.bank_rental_credit_month = 0; //Blank
                            aplvar.gross_salary_rs = gorsSal;
                            aplvar.LIC_Agent_Commisssion_RenewalBusiness = 0; //Blank
                            aplvar.inc_total_monthly_rental_credit_per_month_rs = totMonCred;
                            aplvar.LIC_Agent_Commisssion_NewBusiness_Bonus = 0; //Blank
                            aplvar.Constitution_wise_Mandatory_documents=''; //Blank
                            aplvar.net_salary_rs = netSalAmt;
                            aplvar.avg_variable_component_last_4_months = varCom;
                            aplvar.last_3_month_payslip = (!docTypeMap.isEmpty() && docTypeMap.containsKey('payslp3'))?docTypeMap.get('payslp3'):'No';
                            aplvar.final_status_of_lip='';
                            aplvar.inc_taxes = totTax;
                            aplvar.inform_applicantcoapp_is_dealing_in_any_mentioned_industry='';
                            aplvar.latest_year_audit_report_along_with_schedules = (!docTypeMap.isEmpty() && docTypeMap.containsKey('ltsYrAud'))?docTypeMap.get('ltsYrAud'):'No';
                            aplvar.latest_year_financials_pl_bs_except_44_ad_ae_ada_cases = (!docTypeMap.isEmpty() && docTypeMap.containsKey('ltsYrFin'))?docTypeMap.get('ltsYrFin'):'No';
                            aplvar.latest_year_form_16 = (!docTypeMap.isEmpty() && docTypeMap.containsKey('form16'))?docTypeMap.get('form16'):'No';
                            
                            
                            //LAK-9870 Start
                            aplvar.multi_tenanted = !multiTen.isEmpty() ? (multiTen.contains('Yes') ? 'Yes' : (multiTen.contains('No') ? 'No' : '')) : '';
                            aplvar.no_of_tenants=noOfTenants;
                            aplvar.property_ownership_proof_documented = !ownershipproofdoc.isEmpty() ? (ownershipproofdoc.contains('No') ? 'No' : (ownershipproofdoc.contains('Yes') ? 'Yes' : '')) : '';
                            aplvar.rent_agreement_documented = !rentAgreement.isEmpty() ? (rentAgreement.contains('No') ? 'No' : (rentAgreement.contains('Yes') ? 'Yes' : '')) :'';
                            aplvar.rental_verification_done = !rentalVerification.isEmpty() ? (rentalVerification.contains('No') ? 'No' : (rentalVerification.contains('Yes') ? 'Yes' : '')) :'';
                            
                            aplvar.document_aoa=(!docTypeMap.isEmpty() && docTypeMap.containsKey('aoa'))?docTypeMap.get('aoa'):'No';
                            aplvar.document_certificate_of_incorporation=(!docTypeMap.isEmpty() && docTypeMap.containsKey('certifiIncorp'))?docTypeMap.get('certifiIncorp'):'No';
                            aplvar.document_cert_regist_doc_issued_by_competent_authorities=(!docTypeMap.isEmpty() && docTypeMap.containsKey('certifiRegistrDoc'))?docTypeMap.get('certifiRegistrDoc'):'No';
                            aplvar.document_electricity_bill=(!docTypeMap.isEmpty() && docTypeMap.containsKey('electricityBill'))?docTypeMap.get('electricityBill'):'No';
                            aplvar.document_gst_certificate=(!docTypeMap.isEmpty() && docTypeMap.containsKey('GSTcertificate'))?docTypeMap.get('GSTcertificate'):'No';
                            aplvar.document_moa=(!docTypeMap.isEmpty() && docTypeMap.containsKey('moa'))?docTypeMap.get('moa'):'No';
                            aplvar.document_patnership_deed=(!docTypeMap.isEmpty() && docTypeMap.containsKey('patnershipDeed'))?docTypeMap.get('patnershipDeed'):'No';
                            aplvar.document_piped_gas_bill=(!docTypeMap.isEmpty() && docTypeMap.containsKey('pipedGasBill'))?docTypeMap.get('pipedGasBill'):'No';
                            aplvar.document_post_paid_mobile_phone_bill=(!docTypeMap.isEmpty() && docTypeMap.containsKey('PostPaidMobBill'))?docTypeMap.get('PostPaidMobBill'):'No';
                            aplvar.document_shop_and_establishment=(!docTypeMap.isEmpty() && docTypeMap.containsKey('ShopEstablish'))?docTypeMap.get('ShopEstablish'):'No';
                            aplvar.document_telephone_bill=(!docTypeMap.isEmpty() && docTypeMap.containsKey('telephoneBill'))?docTypeMap.get('telephoneBill'):'No';
                            aplvar.document_trust_society_deed=(!docTypeMap.isEmpty() && docTypeMap.containsKey('trustSocietyDeed'))?docTypeMap.get('trustSocietyDeed'):'No';
                            aplvar.document_udyam_registration_certificate=(!docTypeMap.isEmpty() && docTypeMap.containsKey('docUdy'))?docTypeMap.get('docUdy'):'No';
                            aplvar.document_water_bill=(!docTypeMap.isEmpty() && docTypeMap.containsKey('waterBill'))?docTypeMap.get('waterBill'):'No';
                            //LAK-9870 END 
                            
                            
                            aplvar.other_deductions = totOD; 
                            aplvar.previous_year_audit_report_along_with_schedules = (!docTypeMap.isEmpty() && docTypeMap.containsKey('prvYrAud'))?docTypeMap.get('prvYrAud'):'No';
                            aplvar.previous_year_financials_pl_bs_except_44_ad_ae_ada_cases = (!docTypeMap.isEmpty() && docTypeMap.containsKey('prvYrFin'))?docTypeMap.get('prvYrFin'):'No';
                            aplvar.previous_year_itr_computation = (!docTypeMap.isEmpty() && docTypeMap.containsKey('prvYrITR'))?docTypeMap.get('prvYrITR'):'No';
                            aplvar.latest_year_itr_computation = (!docTypeMap.isEmpty() && docTypeMap.containsKey('lstYrITR'))?docTypeMap.get('lstYrITR'):'No';
                            aplvar.total_bounces_in_rtr=0;
                            aplvar.approximate_margin_in_the_business = cashFlowAppInc != NULL && cashFlowAppInc.APPROXIMATE_MARGIN_IN_THE_BUSINESS__c != NULL ? cashFlowAppInc.APPROXIMATE_MARGIN_IN_THE_BUSINESS__c.setScale(2) : 0;
                            aplvar.average_yearly_income=0;
                            aplvar.cost_of_materials = cashFlowAppInc != NULL && cashFlowAppInc.Monthly_Purchases_Cost_Of_Materials__c != NULL ? cashFlowAppInc.Monthly_Purchases_Cost_Of_Materials__c.setScale(2) : 0;
                            aplvar.details_of_expenses_total_expenses = cashFlowAppInc != NULL && cashFlowAppInc.Total_Expense_of_operations_Or_Business__c != NULL ? cashFlowAppInc.Total_Expense_of_operations_Or_Business__c.setScale(2) : 0;
                            aplvar.Cash_Flow_Assessd_Income = cashFlowAppInc != NULL && cashFlowAppInc.NET_CASH_PROFIT_LOSS__c != NULL ? cashFlowAppInc.NET_CASH_PROFIT_LOSS__c.setScale(2) : 0;
                            aplvar.docu_chk_udyam_registration_cert_urc_or_udyam_assist_cert = (!docTypeMap.isEmpty() && docTypeMap.containsKey('docUdy'))?docTypeMap.get('docUdy'):'No';
                            
                            //LAK-6471 Start
                            aplvar.Form_26AS=(!docTypeMap.isEmpty() && docTypeMap.containsKey('form26AS'))?docTypeMap.get('form26AS'):'No';//form26AS;
                            //LAK-6471 Start
                            
                            Decimal avgMonRen = 0;
                            if(app.Average_Monthly_Rental_With_Bank_Credit__c != NULL && app.Average_Monthly_Rental_No_Bank_Credit__c != NULL) {
                                avgMonRen = app.Average_Monthly_Rental_With_Bank_Credit__c + app.Average_Monthly_Rental_No_Bank_Credit__c;
                            }
                            else if(app.Average_Monthly_Rental_With_Bank_Credit__c != NULL && app.Average_Monthly_Rental_No_Bank_Credit__c == NULL) {
                                avgMonRen = app.Average_Monthly_Rental_With_Bank_Credit__c;
                            }
                            else if(app.Average_Monthly_Rental_With_Bank_Credit__c == NULL && app.Average_Monthly_Rental_No_Bank_Credit__c != NULL) {
                                avgMonRen = app.Average_Monthly_Rental_No_Bank_Credit__c;
                            }
                            aplvar.inc_average_monthly_rental = avgMonRen != 0 ? avgMonRen.setScale(2) : 0;
                            aplvar.monthly_rental_credit_amt_rs=0;
                            aplvar.monthly_rental_credit_amt=0;
                            aplvar.net_cash_profitloss=0;
                            aplvar.operating_activity_receipts = cashFlowAppInc != NULL && cashFlowAppInc.Operating_Activity_Receipts__c != NULL ? cashFlowAppInc.Operating_Activity_Receipts__c.setScale(2) : 0;
                            aplvar.PD_Authority = '';
                            aplvar.lip_vendor_status_of_report = '';
                            aplvar.salary_credit_count = app.Salary_Credit_Count__c != NULL ? app.Salary_Credit_Count__c.setScale(2) : 0;
                            aplvar.other_income = app.Average_Other_Income__c != NULL ? app.Average_Other_Income__c.setScale(2) : 0;
                            aplvar.cust_employer_name= (ae != NULL && ae.EmployerName__r.EmployerId__c != NULL) ? ae.EmployerName__r.EmployerId__c : '';
                            aplvar.UCID = app != NULL && app.UCID__c != NULL && app.UCID__c.isNumeric() ? Integer.valueOf(app.UCID__c) : 0;
                            aplvar.cust_residential_status = app != NULL && app.Residential_Status__c != NULL ? app.Residential_Status__c : '';
                            aplvar.Average_Agriculture_Income = app != NULL && app.AverageMonthlyAgricultureIncome__c != NULL ? app.AverageMonthlyAgricultureIncome__c.setScale(2) : 0;
                            aplvar.PAN = panVar != NULL ? panVar : '';
                            
                            String genIns = 'No', lifIns = 'No';
                            Decimal insAmt;
                            if(!app.Insurances__r.isEmpty()) {
                                for(Insurance__c ins : app.Insurances__r) {
                                    if(String.isNotBlank(ins.InsType__c)) {
                                        if(ins.InsType__c.equalsIgnoreCase('General Insurance')) {
                                            genIns = 'Yes';
                                        }
                                        else if(ins.InsType__c.equalsIgnoreCase('Life Insurance')){
                                            lifIns = 'Yes'; 
                                            if(ins.SumAmount__c != NULL) {
                                                insAmt = ins.SumAmount__c.setScale(2);
                                            }
                                        }
                                    }  
                                }
                            }
                            aplvar.Insurance_coverage_amount = insAmt != NULL ? insAmt : 0;
                            aplvar.life_insurance = lifIns;
                            aplvar.general_insurance = genIns;
                            aplvar.Business_Proof_Available = app != NULL && app.Businessproofavailable__c != NULL ? (app.Businessproofavailable__c.equalsIgnoreCase('YES') ? 'Yes' : 'No') : '';
                            
                            //Need to be blank for now
                            aplvar.cust_dedupe_customername = '';
                            aplvar.cust_dedupe_lan = '';
                            aplvar.cust_dedupe_source = '';
                            aplvar.cust_dpdstring = '';
                            aplvar.cust_nationality = 1;
                            
                            //LAK-9870 start
                            aplvar.cust_litigation_crime_check_individual_status=(applVerificationMap.containsKey(app.Id) && String.isNotblank(applVerificationMap.get(app.Id)) )?applVerificationMap.get(app.Id):'';
                            aplvar.cust_crimewatch=(applVerificationMap.containsKey(app.Id) && String.isNotblank(applVerificationMap.get(app.Id)) )?applVerificationMap.get(app.Id):'';
                            aplvar.cust_litigation_crimecheck_company_status=(applVerificationMap.containsKey(app.Id) && String.isNotblank(applVerificationMap.get(app.Id)) )?applVerificationMap.get(app.Id):'';
                            // LAK-9870 End
                            
                            aplvar.property_ownership=(!propertyOwnerMap.isEmpty() && propertyOwnerMap.containsKey(app.Id) && propertyOwnerMap.get(app.Id))?'yes':'no';
                            //assign values to customer wrapper class variable
                            apptag.Variables=aplvar;
                            
                            if(custCatMap.containsKey(app.Id)) {
                                apptag.Categories = custCatMap.get(app.Id);
                            }
                            else {
                                apptag.Categories = custCategorieslist;
                            }
                            
                            if(app.ApplType__c=='P'){
                                Categorieslist.add(new MAP<String,Object>{'APPLICANT'=>apptag});
                            }
                            
                            else if(app.ApplType__c=='C'){
                                Categorieslist.add(new MAP<String,Object>{'COAPPLICANT'=>apptag});
                            }
                            else if(app.ApplType__c=='G'){
                                Categorieslist.add(new MAP<String,Object>{'GUARANTOR'=>apptag});
                            }
                        }
                    }
                    
                    //create the Application 
                    CrifExecuteAPIRequestWrapper.Application app =new CrifExecuteAPIRequestWrapper.Application();
                    app.Variables=appvar;
                    app.Categories=Categorieslist;
                    
                    //create the body
                    CrifExecuteAPIRequestWrapper.Body body = new CrifExecuteAPIRequestWrapper.Body();
                    body.APPLICATION=app;
                    
                    // Create StrategyOneRequest
                    CrifExecuteAPIRequestWrapper.StrategyOneRequest OneRequest =new CrifExecuteAPIRequestWrapper.StrategyOneRequest();
                    IntgSvcMgmt__mdt breMD = IntgSvcMgmt__mdt.getInstance('BRE_Data');
                    String InqCode = (breMD != NULL && breMD.InquiryCode__c != NULL && breMD.IsActive__c == TRUE) ? breMD.InquiryCode__c : '';
                    String ProcCode = (breMD != NULL && breMD.ProcessCode__c != NULL && breMD.IsActive__c == TRUE) ? breMD.ProcessCode__c : '';
                    String OrgCode = (breMD != NULL && breMD.Organization__c != NULL && breMD.IsActive__c == TRUE) ? breMD.Organization__c : '';
                    
                    String hd = '{';
                    hd += '"' + 'InquiryCode' + '"' + ':' + '"' + InqCode + '"' + ',';
                    hd += '"' + 'ProcessCode' + '"' + ':' + '"' + ProcCode + '"' + ',';
                    hd += '"' + 'OrganizationCode' + '"' + ':' + '"' + OrgCode + '"';
                    hd += '}';
                    OneRequest.Body = body;
                    OneRequest.Header = hd;
                    
                    // Create the main request object
                    CrifExecuteAPIRequestWrapper request = new CrifExecuteAPIRequestWrapper();
                    request.StrategyOneRequest = OneRequest;
                    
                    
                    String req = JSON.serialize(request).replace('hunterStaRepl' , 'hunter_status__match_or_not_match').replace('residAge', 'technical_residual_age__in_years').replace('marketables', 'tsr_is_the_title_clear__marketable').replace('assPatAn' , 'assessed_pat__annual_in_lacs').replace('finSalToPartDirect', 'fin_salary_to_partnersdirectors_').replace('finTotDebt', 'fin_total_debtors_').replace('gstPercGrowth', 'gst_percentage__of_growth_in_to_for_current_fy').replace('cust_litigation_crime_check_individual_status','cust_litigation_crime_check__individual_status');
                    String req1 = req.unescapeJava();
                    String req2 = req1.replace('"{', '{').replace('}"', '}');
                    
                    Blob reqData = Blob.valueOf(req2);
                    
                    //Creating attachment for json request
                    Attachment att = new Attachment();
                    att.ParentId = intmsg.Id;
                    att.Body = reqData;
                    att.Name = 'request.txt';
                    Insert att;
                    
                    //Updating Integration Message Record
                    IntgMsg__c intg = New IntgMsg__c();
                    intg.Id = intmsg.Id;
                    intg.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                    updateIntrecods.add(intg);
                }
            }
            if(!updateIntrecods.isEmpty()) {
                String sObjectName = 'IntgMsg__c';
                List<String> fieldNamesList = new List<String>{ 'Req__c','Status__c' };
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                uow.registerDirty(updateIntrecods);
                uow.commitWork();
            }
        }
        
        catch(Exception ex){
            GlobalUtility.logMessage('Error', 'CrifExecuteAPIRequestGenerator', 'generate', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
    }
    
    //Applicaion variables tags mapping
    public static CrifExecuteAPIRequestWrapper.ApplicationVariables applicantVariable(LoanAppl__c La, Map<Id, String> schemeMap, String btFinStat, Map<String, String> balTranFinMap, Map<String, String> loanPurMap, Map<String, String> promCodeMap, Map<String, List<Map<String, String>>> masterDataMap, Map<String, BankBrchMstr__c> bankBranchMstrMap, Map<Id, Boolean> btLoanMap, List<BureauRespDtl__c> brdetList) {
        CrifExecuteAPIRequestWrapper.ApplicationVariables appvar = new CrifExecuteAPIRequestWrapper.ApplicationVariables();
        try {
            Double schVar = 0, noEmiPaidBTLoan = 0;
            String btLn = 'No';
            if(!schemeMap.isEmpty() && La.SchemeId__c != NULL) {
                if(schemeMap.containskey(La.SchemeId__c) && schemeMap.get(La.SchemeId__c) != NULL && schemeMap.get(La.SchemeId__c).isNumeric()) {
                    schVar = Double.valueOf(schemeMap.get(La.SchemeId__c));
                }
            }
            
            if(!btLoanMap.isEmpty() && La.SchemeId__c != NULL) {
                btLn = (btLoanMap.containskey(La.SchemeId__c) && btLoanMap.get(La.SchemeId__c) == TRUE) ? 'Yes' : 'No';
            }
            
            if(btLn == 'Yes' && !brdetList.isEmpty()) {
                Double temp = 0;
                for(BureauRespDtl__c brd : brdetList) {
                    temp = brd.NoEMIPaid__c > temp ? brd.NoEMIPaid__c : temp;
                }
                noEmiPaidBTLoan = temp;
            }
            appvar.scheme = schVar;
            appvar.status_of_reportrcu = '';
            appvar.revised_roi_perc = La.RevisedROI__c != NULL ? La.RevisedROI__c.setScale(2) : 0;
            appvar.own_contribution_bank = La.OwnContriBank__c != NULL ? La.OwnContriBank__c.setScale(2) : 0;  
            appvar.is_there_a_TypeA_deviation = La.Is_there_TypeA_devia__c != NULL ? (La.Is_there_TypeA_devia__c.equalsIgnoreCase('Yes') ? 'Yes' : 'No') : '';
            appvar.is_there_a_TypeB_deviation = La.Is_there_TypeB_devia__c != NULL ? (La.Is_there_TypeB_devia__c.equalsIgnoreCase('Yes') ? 'Yes' : 'No') : '';
            appvar.final_rcu_sampling_status = '';   //drop 2
            Case rcuCase;
            if(!La.Cases__r.isEmpty()) {
                Case negCase, refCase, fraudCase, posCase;
                for(Case cs : La.Cases__r) {
                    //LAK-10453 Start
                    negCase = String.isNotBlank(cs.ReportResult__c) && cs.ReportResult__c.equalsIgnoreCase('Negative') ? cs : negCase;
                    refCase = String.isNotBlank(cs.ReportResult__c) && cs.ReportResult__c.equalsIgnoreCase('Refer') ? cs : refCase;
                    fraudCase = String.isNotBlank(cs.ReportResult__c) && cs.ReportResult__c.equalsIgnoreCase('Fraud') ? cs : fraudCase;
                    posCase = String.isNotBlank(cs.ReportResult__c) && cs.ReportResult__c.equalsIgnoreCase('Positive') ? cs : posCase;
                //LAK-10453 End
                }
                rcuCase = fraudCase != NULL ? fraudCase : (negCase != NULL ? negCase : (refCase != NULL ? refCase : (posCase != NULL ? posCase : rcuCase)));
                    }
            Repayment_Account__c repayAcc = !La.Repayment_Account__r.isEmpty() ? La.Repayment_Account__r[0] : NULL;
            appvar.final_rcu_status = (rcuCase != NULL && String.isNotBlank(rcuCase.ReportResult__c)) ? masterDataMapUtility(masterDataMap, 'Final RCU Status', rcuCase.ReportResult__c) : ''; 
            appvar.final_rcu_status_reason = (rcuCase != NULL && String.isNotBlank(rcuCase.Final_RCU_status_Reason__c))? masterDataMapUtility(masterDataMap, 'Final RCU Status Reason', rcuCase.Final_RCU_status_Reason__c) : ''; 
            appvar.product_sub_field = '';   //Blank 
            appvar.Repayment_Mode = repayAcc != NULL && repayAcc.Repayment_Mode__c != NULL ? masterDataMapUtility(masterDataMap, 'Instrument Type', repayAcc.Repayment_Mode__c) : '';  
            appvar.cust_hunter_type = '';  //Blank
            appvar.Previous_Exposure_with_Fedfina = 0; //Field to be created
            appvar.no_of_emi_bounce_for_bt_loan = 0; //Mrunal will confirm
            appvar.no_of_emi_paid_for_bt_loan = noEmiPaidBTLoan; 
            appvar.bt_loan = btLn != NULL ? btLn : '';
            appvar.location = '';
            appvar.authstatus = '';     //drop 2
            appvar.biil_desk_txnamount = 0; //drop 2
            appvar.other_salary_component_outside_payslip = 0; //Blank
            appvar.revised_pf_perc = La.RevisedPF__c != NULL ? La.RevisedPF__c.setScale(2) : 0;
            String brinSPDC = 'No';
            if(!La.Applicants__r.isEmpty()) {
                for(Applicant__c apply : La.Applicants__r) {
                    if(apply.Guarantor_is_bringing_in_SPDC__c != NULL && apply.Guarantor_is_bringing_in_SPDC__c.equalsIgnoreCase('Yes')) {
                        brinSPDC = 'Yes';
                    }
                }
            }
            appvar.guarantor_is_bringing_in_spdc = brinSPDC;
            appvar.loan_tenure_months = La.Loan_Tenure_Months__c != NULL ? La.Loan_Tenure_Months__c.setScale(2) : 0;
            appvar.summary_emi_loan_amount_including_insurance = La.TotalLoanAmtInclInsurance__c != NULL ? La.TotalLoanAmtInclInsurance__c.setScale(2) : 0;
            appvar.pdt_requested_loan_amount = La.ReqLoanAmt__c != NULL ? La.ReqLoanAmt__c.setScale(2) : 0;
            appvar.pdt_all_seller_bt_norms_met = La.AllSellerBTNormMet__c != NULL ? (La.AllSellerBTNormMet__c == 'Y' ? 'Yes' : 'No') : '';
            appvar.pdt_balance_transfer_financier_status = btFinStat;
            appvar.pdt_is_it_a_refinance_transaction = La.IsItRefinanceTransaction__c != NULL ? (La.IsItRefinanceTransaction__c == 'Y' ? 'Yes' : 'No') : '';
            appvar.pdt_is_it_a_seller_balance_transfer_transaction = La.IsitSellerBalTransferTransaction__c != NULL ? (La.IsitSellerBalTransferTransaction__c == 'Y' ? 'Yes' : 'No') : '';  
            appvar.pdt_period_since_sale_agreement_is_executed_month = La.PeriodSinceSaleAgreementExecuted__c != NULL && La.PeriodSinceSaleAgreementExecuted__c.isNumeric() ? Double.valueOf(La.PeriodSinceSaleAgreementExecuted__c) : 0;    
            appvar.pdt_refinance_sale_agreement_amount = La.RefinanceSaleAgreementAmt__c != NULL ? La.RefinanceSaleAgreementAmt__c.setScale(2) : 0;
            appvar.pdt_refinance_sale_agreement_date = La.RefinanceSaleAgreementDate__c != NULL ? String.valueOf(La.RefinanceSaleAgreementDate__c) : '';
            appvar.application_id = La.Name != NULL ? La.Name : '';
            appvar.pdt_product = La.Product__c != NULL ? masterDataMapUtility(masterDataMap, 'Product', La.Product__c) : '';
            appvar.product_sub_type = La.ProductSubType__c != NULL ? masterDataMapUtility(masterDataMap, 'Product Sub Type', La.ProductSubType__c) : '';
            
            //Commenting Due to LAK-9870
            //appvar.balance_transfer_financier = La.OthrBTFinancr__c != NULL && balTranFinMap != NULL && balTranFinMap.containsKey(La.OthrBTFinancr__c) && balTranFinMap.get(La.OthrBTFinancr__c) != NULL ? balTranFinMap.get(La.OthrBTFinancr__c) : '';
            
            Decimal btOutsVal = 0, btOrigAmt = 0,balanceTransferfin=0;
            string balanceTransferFinancier='',otherBalanceTransferFinancier='';
            if(!La.BT_Loans__r.isEmpty()) {
                for(BTLoan__c bt : La.BT_Loans__r) {
                    if(bt.BTLoanOutstandingValue__c != NULL) {
                        btOutsVal += bt.BTLoanOutstandingValue__c;
                    }
                    if(bt.BTOriginalLoanAmt__c != NULL) {
                        btOrigAmt += bt.BTOriginalLoanAmt__c;
                    }
                    //LAK-9870 Start
                    if(bt.BTLoanOutstandingValue__c!=null &&  bt.BTLoanOutstandingValue__c>balanceTransferfin){
                        balanceTransferFinancier=bt.BTFinancier__c;
                        otherBalanceTransferFinancier=bt.SpecifyOtherBTFinancier__c;
                        balanceTransferfin=bt.BTLoanOutstandingValue__c;
                    }
                    //LAK-9870 End
                }
            }
           
            //LAK-9870 Start
            appvar.balance_transfer_financier =(string.isNotblank(La.SchemeId__c) && btLoanMap.containsKey(La.SchemeId__c) && btLoanMap.get(La.SchemeId__c))?balanceTransferFinancier:'';
            appvar.specify_other_balance_transfer_financier =(string.isNotblank(La.SchemeId__c) && btLoanMap.containsKey(La.SchemeId__c) && btLoanMap.get(La.SchemeId__c) && balanceTransferFinancier.tolowerCase().contains('other'))?otherBalanceTransferFinancier:'';
            appvar.Stage=string.isNotblank(La.Stage__c)?La.Stage__c:'';
            appvar.Sub_Stage=string.isNotblank(La.SubStage__c)?La.SubStage__c:'';
            //LAK-9870 End
            
            appvar.balance_transfer_loan_outstanding_value = btOutsVal.setScale(2);
            appvar.balance_transfer_original_loan_amount = btOrigAmt.setScale(2);
            appvar.existing_fedfina_loan_account_number = La.ExistngFedFinaLoanAccNo__c != NULL ? La.ExistngFedFinaLoanAccNo__c : '';
            appvar.is_this_assesed_income_program = La.AssessedIncAppln__c != NULL ? (La.AssessedIncAppln__c == TRUE ? 'Yes' : 'No') : '';
            appvar.loan_purpose = (!loanPurMap.isEmpty() && La.LoanPurposeId__c != NULL && loanPurMap.containsKey(La.LoanPurposeId__c) && loanPurMap.get(La.LoanPurposeId__c) != NULL) ? loanPurMap.get(La.LoanPurposeId__c) : '';
            Integer channelCode = 0;
            String channelName = '';
            if(String.isNotBlank(La.LeadSource__c)) {
                if(La.LeadSource__c != NULL && La.LeadSource__c.equalsIgnoreCase('Connector')) {
                    if(String.isNotBlank(La.ChanelNme__r.VCReferralId__c) && La.ChanelNme__r.VCReferralId__c.isNumeric()) {
                        channelCode = Integer.valueOf(La.ChanelNme__r.VCReferralId__c);
                    }
                }
                else if(La.LeadSource__c != NULL && La.LeadSource__c.equalsIgnoreCase('DSA')) {
                    if(String.isNotBlank(La.ChanelNme__r.DSAConnId__c) && La.ChanelNme__r.DSAConnId__c.isNumeric()) {
                        channelCode = Integer.valueOf(La.ChanelNme__r.DSAConnId__c);
                    }
                }
            }
            if(String.isNotBlank(La.ChanelNme__r.Name)) {
                channelName = La.ChanelNme__r.Name;
            }
            appvar.pdt_channel_code = channelCode;   
            appvar.pdt_channel_name = channelName;
            appvar.promotion = (!promCodeMap.isEmpty() && La.PromCode__c != NULL && promCodeMap.containsKey(La.PromCode__c) && promCodeMap.get(La.PromCode__c) != NULL) ? promCodeMap.get(La.PromCode__c) : '';
            appvar.eligibility_insurance_amount = La.InsAmt__c != NULL ? La.InsAmt__c.setScale(2) : 0;
            appvar.Loan_Amount = La.SanLoanAmt__c != NULL ? La.SanLoanAmt__c.setScale(2) : 0;
            appvar.pdt_lead_source = La.LeadSource__c != NULL ? masterDataMapUtility(masterDataMap, 'Channel', La.LeadSource__c) : '';
            appvar.pdt_branch_name = La.BrchName__c != NULL ? La.BrchName__c : '';
            appvar.pdt_payment_done_in_last_12_months_bank = La.PaymentDoneInLast12MonthsBank__c != NULL ? La.PaymentDoneInLast12MonthsBank__c.setScale(2) : 0; 
            appvar.pdt_payment_done_in_last_12_months_cash = La.PaymentDoneInLast12MonthsCash__c != NULL? La.PaymentDoneInLast12MonthsCash__c.setScale(2) : 0;   
            appvar.pdt_payment_done_in_last_6_months_bank = La.PaymentDoneInLast6MonthsBank__c != NULL ? La.PaymentDoneInLast6MonthsBank__c.setScale(2) : 0; 
            appvar.pdt_payment_done_in_last_6_months_cash = La.PaymentDoneInLast6MonthsCash__c != NULL ? La.PaymentDoneInLast6MonthsCash__c.setScale(2) : 0;
            appvar.requested_tenure_in_months = La.ReqTenInMonths__c != NULL ? La.ReqTenInMonths__c.setScale(2) : 0;
            appvar.summary_total_loan_amount_including_insurance = La.TotalLoanAmtInclInsurance__c != NULL ? La.TotalLoanAmtInclInsurance__c.setScale(2) : 0;
            appvar.summary_rate_type_floating_flag = La.Rate_Type_Floating_Flag__c != NULL ? (La.Rate_Type_Floating_Flag__c == 'Y' ? 'Yes' : 'No') : '';
            appvar.login_acceptance_date = La.LoginAcceptDate__c != null ? String.valueOf(La.LoginAcceptDate__c) : '';
            
            ApplRegltry__c ar = new ApplRegltry__c();
            if(!La.Applicant_Regulatory__r.isEmpty()) {
                ar = La.Applicant_Regulatory__r[0];
            }
            
            Integer callId = 0;
            
            if(String.isNotBlank(La.Stage__c)) {
                if(La.Stage__c.equalsIgnoreCase('QDE') && String.isNotBlank(La.SubStage__c) && 
                   (La.SubStage__c.equalsIgnoreCase('RM Data Entry') || 
                    La.SubStage__c.equalsIgnoreCase('Additional Data Entry') || 
                    La.SubStage__c.equalsIgnoreCase('Pre login Query'))) {//LAK -10412 start
                        
                    if(La.SubStage__c.equalsIgnoreCase('RM Data Entry') || La.SubStage__c.equalsIgnoreCase('Pre login Query')) {//LAK -10412 End
                        callId = 1;
                    }
                    else if(La.SubStage__c.equalsIgnoreCase('Additional Data Entry')) {
                        callId = 2;
                    }
                }
                else if(La.Stage__c.equalsIgnoreCase('DDE')) {
                    callId = 3;
                }
                else if(La.Stage__c.equalsIgnoreCase('UnderWriting') || La.Stage__c.equalsIgnoreCase('Soft Sanction') || 
                        (La.Stage__c.equalsIgnoreCase('Post Sanction') && (La.SubStage__c.equalsIgnoreCase('Data Entry') || La.SubStage__c.equalsIgnoreCase('Data Entry Pool') ))) {
                    callId = 4;
                }
               else if(La.Stage__c.equalsIgnoreCase('Post Sanction') && La.SubStage__c != NULL && (La.SubStage__c.equalsIgnoreCase('UW Approval') || La.SubStage__c.equalsIgnoreCase('Ops Query'))) {
                    callId = 5;
                }
            }
            appvar.call_id = callId;
            String rePay = 'No';
            if(!La.Repayment_Acct_Verifications__r.isEmpty()) {
                rePay = 'Yes';
            }
            appvar.pdt_branch_tier = La.BranchTier__c != NULL ? masterDataMapUtility(masterDataMap, 'Branch Tier', La.BranchTier__c) : ''; 
            appvar.is_it_matching_with_the_repayment_account_holder_name = rePay;
            appvar.lead_roi = La.EffectiveROI__c != NULL ? La.EffectiveROI__c.setScale(2) : 0;
            appvar.psl_tagging = '';  //Blank  
            appvar.pdt_branch_code = ((!bankBranchMstrMap.isEmpty()) && La.BrchCode__c != NULL && bankBranchMstrMap.containsKey(La.BrchCode__c) && bankBranchMstrMap.get(La.BrchCode__c).OffcCode__c != NULL && bankBranchMstrMap.get(La.BrchCode__c).OffcCode__c.isNumeric()) ? Double.valueOf(bankBranchMstrMap.get(La.BrchCode__c).OffcCode__c) : 0;
            appvar.eligible_for_funding_under_esg_policy_norms_or_not = ar != NULL && ar.FundInESGPol__c != NULL ? masterDataMapUtility(masterDataMap, 'Funding Under ESG Policy', ar.FundInESGPol__c) : '';
            appvar.is_there_any_discrimination_basis_gender_caste_religion_race = (ar != NULL && ar.CharDiscrmtn__c != NULL) ? ar.CharDiscrmtn__c : ''; 
            appvar.borrower_is_director_relative_or_senior_officer_at_fedfina = (ar != NULL && ar.IsBorowrOrRelFFDir__c != NULL) ? ar.IsBorowrOrRelFFDir__c : '';
            appvar.fedfina_director_relative_interested_as_a_partner = (ar != NULL && ar.FFDirRelIntrstAsPart__c != NULL) ? ar.FFDirRelIntrstAsPart__c : '';    
            appvar.fedfina_director_relative_interested_as_major_shareholder = (ar != NULL && ar.FFDirRelIntrstAsSH__c != NULL) ? ar.FFDirRelIntrstAsSH__c : '';
            
            String chqkBounceRes, chqkBounceRes1, chqkBounceRes2, imdstat1, imdstat2;
            Decimal imdAmt;
            if(!La.Applicant_IMD__r.isEmpty()) {
                
                for(ApplIMD__c ai : La.Applicant_IMD__r) {
                    if(ai.IMDStatus__c != NULL && ai.IMDStatus__c == 'Bounced' && ai.CheqBounceReason__c != NULL && ai.BounceReasonID__c != NULL) {
                        if(chqkBounceRes1 == NULL && chqkBounceRes2 == NULL) {
                            chqkBounceRes1 = ai.BounceReasonID__c;
                        }
                        else if(chqkBounceRes1 != NULL && chqkBounceRes2 == NULL) {
                            chqkBounceRes2 = ai.BounceReasonID__c;
                        }
                    }
                }
                
                for(ApplIMD__c ai : La.Applicant_IMD__r) {
                    if(ai.IMDStatus__c != NULL) {
                        if(imdstat1 == NULL && imdstat2 == NULL) {
                            imdstat1 = ai.IMDStatus__c;
                        }
                        else if(imdstat1 != NULL && imdstat2 == NULL) {
                            imdstat2 = ai.IMDStatus__c;
                        }
                    }
                }
                Integer size = La.Applicant_IMD__r.size();
                ApplIMD__c aiVar = La.Applicant_IMD__r[size-1];
                imdAmt = aiVar != NULL && aiVar.InstrumentAmt__c != NULL ? aiVar.InstrumentAmt__c : 0; 
            }
            appvar.cheque_bounce_reason = chqkBounceRes1 != NULL ? chqkBounceRes1 : '';
            appvar.imd_amount = imdAmt != NULL && imdAmt != 0 ? imdAmt.setScale(2) : 0;
            appvar.Cheque_bounce_reason_1 = chqkBounceRes1 != NULL ? chqkBounceRes1 : '';
            appvar.Cheque_bounce_reason_2 = chqkBounceRes2 != NULL ? chqkBounceRes2 : '';
            appvar.IMD_CLEARANCE_STATUS1 = imdstat1 != NULL ? imdstat1 : '';
            appvar.IMD_CLEARANCE_STATUS2 = imdstat2 != NULL ? imdstat2 : '';
            appvar.own_contribution_in_cash = La.OwnContriCash__c != NULL ? La.OwnContriCash__c.setScale(2) : 0;
            
            HunterVer__c hvVar;
            Double hunScore;
            if(!La.Hunter_Verifications__r.isEmpty()) {
                for(HunterVer__c hv : La.Hunter_Verifications__r) {
                    if(hv.HunMatchSta__c != NULL && hv.HunMatchSta__c.equalsIgnoreCase('Match')) {
                        hunScore = 1;
                        hvVar = hv;
                        break;
                    }
                }
                if(hvVar == NULL) {
                    hvVar = La.Hunter_Verifications__r[0];
                    hunScore = 0;
                }
            }   
            appvar.cust_hunter_decision = (hvVar != NULL && hvVar.HunMatchSta__c != NULL) ? masterDataMapUtility(masterDataMap, 'Hunter Status', hvVar.HunMatchSta__c) : '';
            //appvar.hunterStaRepl = (hvVar != NULL && hvVar.HunMatchSta__c != NULL) ? masterDataMapUtility(masterDataMap, 'Hunter Status', hvVar.HunMatchSta__c) : '';  
            appvar.cust_hunter_decisiontext = (hvVar != NULL && hvVar.HunMatchSta__c != NULL) ? masterDataMapUtility(masterDataMap, 'Hunter Status', hvVar.HunMatchSta__c) : '';
            appvar.cust_hunter_decisionreasons = (hvVar != NULL && hvVar.HunterStatWhereMatchFound__c != NULL) ? masterDataMapUtility(masterDataMap, 'Final RCU Hunter Status', hvVar.HunterStatWhereMatchFound__c) : '';
            appvar.cust_hunter_name = (hvVar != NULL && hvVar.Name != NULL) ? hvVar.Name : '';
            appvar.cust_hunter_score = hunScore != NULL ? hunScore : 0;
            appvar.final_rcu_hunter_status = (hvVar != NULL && hvVar.HunterStatWhereMatchFound__c != NULL) ? masterDataMapUtility(masterDataMap, 'Final RCU Hunter Status', hvVar.HunterStatWhereMatchFound__c) : '';    
            appvar.Bounce_in_BT_Loan_with_Seasoning_less_than_12_Months = La.BonceBTloanSesingless12mths__c != NULL ? La.BonceBTloanSesingless12mths__c.setScale(2) : 0;
            appvar.Bounce_in_BT_Loan_with_Seasoning_greater_than_equal_to_12_Months = La.BonceBTloanSesingtreql12mths__c != NULL ? La.BonceBTloanSesingtreql12mths__c.setScale(2) : 0;
            appvar.Bounce_in_BT_Loan_with_Seasoning_greater_than_equal_to_18_Months = La.BonceBTloanSesingtreql18mths__c != NULL ? La.BonceBTloanSesingtreql18mths__c.setScale(2) : 0;
            
        }
        catch(Exception ex){
            GlobalUtility.logMessage('Error', 'CrifExecuteAPIRequestGenerator', 'applicantVariable', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            return NULL;
        }
        return appvar;
    }
    
    //Property variables tags mapping
    public static CrifExecuteAPIRequestWrapper.PropertyVariables propertyVariable(ApplAsset__c aa, Map<String, LocMstr__c> locatMasterMap, Map<String, String> properSubMap, Map<Id, List<Case>> appAssCaseMap, Map<String, List<Map<String, String>>> masterDataMap, String propDocVar) {
        CrifExecuteAPIRequestWrapper.PropertyVariables provariable = new CrifExecuteAPIRequestWrapper.PropertyVariables();
        Double cityVar = 0, stateVar = 0;
        String inServ = '';
        try {
            if(String.isNotBlank(aa.City__c) && (!locatMasterMap.isEmpty())) {
                if(locatMasterMap.containsKey(aa.City__c)) {
                    LocMstr__c lm = locatMasterMap.get(aa.City__c);
                    cityVar = lm.CityId__c != NULL && lm.CityId__c.isNumeric() ? Double.valueOf(lm.CityId__c) : 0;  
                    stateVar = lm.StateId__c != NULL && lm.StateId__c.isNumeric() ? Double.valueOf(lm.StateId__c) : 0;
                    inServ = lm.IsServiceable__c != NULL ? (lm.IsServiceable__c == TRUE ? 'Yes' : 'No') : '';
                }
            }
            Decimal totVal1, totVal2, totVal3;
            Decimal recommendedTechValue=0;
            
            Case techCase, legalCase, tsrCase, vetCase;
            string visitDate='';
            
            if(!appAssCaseMap.isEmpty() && appAssCaseMap.containsKey(aa.Id)) {
                for(Case cs : appAssCaseMap.get(aa.Id)) {
                    if(cs.RecordType.Name != NULL && cs.RecordType.Name.equalsIgnoreCase('Technical')) {
                        if(cs.Status != NULL && (cs.Status.equalsIgnoreCase('Closed') || cs.Status.equalsIgnoreCase('Query Resolved') || cs.Status.equalsIgnoreCase('Review'))) {
                            if(totVal1 == NULL) {
                                totVal1 = cs.Total_Valuation_Land_Valuation_B__c;
                            }
                            else if(totVal1 != NULL && totVal2 == NULL) {
                                totVal2 = cs.Total_Valuation_Land_Valuation_B__c;
                            }
                            else if(totVal1 != NULL && totVal2 != NULL && totVal3 == NULL) {
                                totVal3 = cs.Total_Valuation_Land_Valuation_B__c;
                            }
                        }
                        
                        //LAK-9870 Start
                        if(cs.Status != NULL && cs.Status=='Closed' && cs.Total_Valuation_Land_Valuation_B__c!=null){
                            
                            if(recommendedTechValue==0){
                                recommendedTechValue=cs.Total_Valuation_Land_Valuation_B__c;
                            }
                            else if(recommendedTechValue!=0 && cs.Total_Valuation_Land_Valuation_B__c<recommendedTechValue){
                                recommendedTechValue=cs.Total_Valuation_Land_Valuation_B__c;
                            }
                            
                        }
                        //LAK-9870 END
                        //if(aa.ValuationToBeTakenAheadForCalculation__c != NULL && cs.Total_Valuation_Land_Valuation_B__c != NULL && aa.ValuationToBeTakenAheadForCalculation__c == cs.Total_Valuation_Land_Valuation_B__c) {
                        if(cs.Total_Valuation_Land_Valuation_B__c != NULL && aa.ChangeRequiredInValuationAsPerPolicyNorm__c != NULL) {
                            if(aa.Total_Valua__c != NULL && aa.ChangeRequiredInValuationAsPerPolicyNorm__c.equalsIgnoreCase('NO') && cs.Total_Valuation_Land_Valuation_B__c.round(RoundingMode.HALF_UP) == aa.Total_Valua__c.round(RoundingMode.HALF_UP)) { //LAK-8501 //LAK-10242
                                techCase = cs;
                            }
                            else if(aa.ValuationToBeTakenAheadForCalculation__c != NULL && aa.ChangeRequiredInValuationAsPerPolicyNorm__c.equalsIgnoreCase('YES') &&  aa.ValuationToBeTakenAheadForCalculation__c.round(RoundingMode.HALF_UP) ==  cs.Total_Valuation_Land_Valuation_B__c.round(RoundingMode.HALF_UP)) {
                                techCase = cs;
                            }
                        }
                    }
                    if(cs.RecordType.Name != NULL && cs.RecordType.Name.equalsIgnoreCase('Legal') && cs.WaiveCPV__c != NULL && cs.WaiveCPV__c.equalsIgnoreCase('No')) {
                        legalCase = cs;
                    }
                    if(cs.RecordType.Name != NULL && cs.RecordType.Name.equalsIgnoreCase('TSR') && cs.IsTSRwaived__c != NULL && cs.IsTSRwaived__c.equalsIgnoreCase('No')) {
                        tsrCase = cs;
                    }
                    if(cs.RecordType.Name != NULL && cs.RecordType.Name.equalsIgnoreCase('Vetting') && cs.Is_Vetting_waived__c != NULL && cs.Is_Vetting_waived__c.equalsIgnoreCase('No')) {
                        vetCase = cs;
                    }
                    
                    if(cs.RecordType.Name != NULL && cs.RecordType.Name.equalsIgnoreCase('Collateral Visit') 
                       && cs.DateofVisit__c!=null && string.isblank(visitDate) && cs.Status =='Closed'){
                           
                           visitDate=cs.DateofVisit__c!=null?DateTime.newInstance(cs.DateofVisit__c, Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd'): '';
                       }
                    
                }
            }
            provariable.unique_id = aa.Id;
            provariable.property_city = cityVar;
            provariable.property_nature_of_property = aa.NatureofProp__c != NULL ? aa.NatureofProp__c : '';
            provariable.property_pin_code = aa.Pin_Code__c != NULL ? aa.Pin_Code__c : '';
            provariable.prop_property_type = aa.PropType__c != NULL ? masterDataMapUtility(masterDataMap, 'Property Type', aa.PropType__c) : '';
            provariable.prop_state_ut = stateVar;
            provariable.property_address_distance_from_nearest_fedfina_branch = aa.DistFrmNearBrch__c != NULL ? aa.DistFrmNearBrch__c.setScale(2) : 0;  
            provariable.property_address_distance_from_the_sourcing_branch = aa.DistFrmSourceBrch__c != NULL ? aa.DistFrmSourceBrch__c.setScale(2) : 0;
            provariable.property_category = aa.PropCat__c != NULL ? masterDataMapUtility(masterDataMap, 'Property Category', aa.PropCat__c) : '';
            provariable.property_identified = aa.PropIdentified__c != NULL ? aa.PropIdentified__c : ''; 
            provariable.property_in_serviceable_city = inServ;  
            provariable.property_sub_type_description = (!properSubMap.isEmpty() && aa.PropSubType__c != NULL && properSubMap.containsKey(aa.PropSubType__c) && properSubMap.get(aa.PropSubType__c) != NULL) ? properSubMap.get(aa.PropSubType__c) : ''; 
            provariable.property_subtype = (!properSubMap.isEmpty() && aa.PropSubType__c != NULL && properSubMap.containsKey(aa.PropSubType__c) && properSubMap.get(aa.PropSubType__c) != NULL) ? properSubMap.get(aa.PropSubType__c) : '';
            //provariable.property_ownership_proof_documented = '';Commenting Due to LAK -9870
            provariable.property_all_property_general_norms_met = aa.AllPropGnrlNrmsMet__c != NULL ?  (aa.AllPropGnrlNrmsMet__c == TRUE ? 'Yes' : 'No') : '';    
            provariable.property_all_property_subtype_norms_met = aa.AllPropSbtypNrmsMet__c != NULL ? (aa.AllPropSbtypNrmsMet__c == TRUE ? 'Yes' : 'No') : '';   
            provariable.property_average_net_monthly_rental_as_per_banking_credit = aa.AveNetMnthlyRentalAsPerBankCredit__c != NULL ? aa.AveNetMnthlyRentalAsPerBankCredit__c.setScale(2) : 0;
            provariable.property_carpet_area = aa.Property_Carpet_area_Sq_Ft__c != NULL ? aa.Property_Carpet_area_Sq_Ft__c.setScale(2) : 0; 
            provariable.property_details_negative_caution_area = aa.Negative_Caution_Area__c != NULL ? aa.Negative_Caution_Area__c : '';    
            provariable.property_improvement_construction_estimate_documented = aa.Improvement_construction_estimate_docum__c != NULL ? (aa.Improvement_construction_estimate_docum__c == 'Yes' ? 1 : 0) : 0; 
            provariable.property_is_the_property_multi_tenanted = aa.Is_the_property_Multi_Tenanted__c != NULL ? aa.Is_the_property_Multi_Tenanted__c : '';
            provariable.property_per_sq_ft_approved_cost_of_construction = aa.Per_Sq_Ft_Approved_Cost_of_Const__c != NULL ? aa.Per_Sq_Ft_Approved_Cost_of_Const__c.setScale(2) : 0; 
            provariable.property_per_sq_ft_rate_built_up_area = aa.Per_Sq_Ft_rate_Built_up_area__c != NULL ?aa.Per_Sq_Ft_rate_Built_up_area__c.setScale(2) : 0;
            provariable.property_per_sq_ft_rate_land_area = aa.Per_Sq_Ft_rate_Land_area__c != NULL ? aa.Per_Sq_Ft_rate_Land_area__c.setScale(2) : 0;    
            provariable.property_prop_no_of_tenants = aa.No_of_Tenants__c != NULL ? aa.No_of_Tenants__c.setScale(2) : 0;
            provariable.property_stage_of_construction_percentage = aa.Stage_of_Construction__c != NULL ? aa.Stage_of_Construction__c.setScale(2) : 0;
            provariable.property_usage = aa.Property_Usage__c != NULL ? masterDataMapUtility(masterDataMap, 'Property Usage', aa.Property_Usage__c) : '';
            provariable.technical_total_valuation_land_valuation_built_up_area_valuation = techCase != NULL && techCase.Total_Valuation_Land_Valuation_B__c != NULL ? techCase.Total_Valuation_Land_Valuation_B__c.setScale(2) : 0; 
            provariable.total_property_cost = aa.Total_Prop_Cost__c != NULL ? aa.Total_Prop_Cost__c.setScale(2) : 0;
            provariable.technical_built_up_area_valuation_in_rs = techCase != NULL && techCase.Built_up_area_Valuation_In_Rs__c != NULL ? techCase.Built_up_area_Valuation_In_Rs__c.setScale(2) : 0;
            provariable.technical_land_valuation_in_rs = techCase != NULL && techCase.Land_Valuation_in_Rs__c != NULL ? techCase.Land_Valuation_in_Rs__c.setScale(2) : 0; 
            provariable.technical_property_built_up_area_sq_ft = techCase != NULL && techCase.Property_Built_up_area_Sq_Ft__c != NULL ? techCase.Property_Built_up_area_Sq_Ft__c.setScale(2) : 0;   
            provariable.technical_approx_age_of_property_in_years = techCase != NULL && techCase.Approx_Age_of_Property_in_Years__c != NULL ? techCase.Approx_Age_of_Property_in_Years__c.setScale(2) : 0; 
            provariable.Registration_Charges = aa.Regi_Cost__c != NULL ? aa.Regi_Cost__c.setScale(2) : 0;   
            provariable.Stamp_Duty = aa.Stamp_Duty__c != NULL ? aa.Stamp_Duty__c.setScale(2) : 0;
            provariable.technical_status_of_technical_report = techCase != NULL && techCase.ReportResult__c != NULL ? masterDataMapUtility(masterDataMap, 'Technical Report Result', techCase.ReportResult__c) : '';   
            provariable.residAge = techCase != NULL && techCase.Residual_Age_in_Years__c != NULL ? techCase.Residual_Age_in_Years__c.setScale(2) : 0;
            provariable.technical_property_reconstruction_cost = techCase != NULL && techCase.Property_Reconstruction_Cost__c != NULL ? techCase.Property_Reconstruction_Cost__c.setScale(2) : 0;  
            provariable.technical_land_area_sq_ft = techCase != NULL && techCase.Land_Area_Sq_Ft__c != NULL ? techCase.Land_Area_Sq_Ft__c.setScale(2) : 0;
            provariable.technical_approved_plan_oc_available = techCase != NULL && techCase.Approved_Plan_OC_available__c != NULL ? techCase.Approved_Plan_OC_available__c : '';
            provariable.stage_of_construction = aa.Stage_of_Construction__c != NULL ? aa.Stage_of_Construction__c.setScale(2) : 0;  
            
            //LAK-9870 Start
            provariable.perc_recommended_by_technical_valuer =recommendedTechValue ;
            provariable.Collateral_visit_report_date=visitDate;
            //LAK-9870 END
            
            provariable.distance_captured_by_technical_agency_from_fedfina_branch = techCase != NULL && techCase.Distance_from_Fedfina_Branch__c != NULL ? techCase.Distance_from_Fedfina_Branch__c.setScale(2) : 0;     
            provariable.marketables = tsrCase != NULL && tsrCase.IsTheTitleClearNdMarketable__c != NULL ? tsrCase.IsTheTitleClearNdMarketable__c : '';
            provariable.final_technical_status = tsrCase != NULL && tsrCase.ReportResult__c != NULL ? masterDataMapUtility(masterDataMap, 'TSR Report Result', tsrCase.ReportResult__c) : '';
            //provariable.assPatAn = 0;Commenting for LAK 9248
            //provariable.status_of_reporttsr = ''; //Due To LAK-6471
            provariable.TSR_report_status = tsrCase != NULL && tsrCase.ReportResult__c != NULL ? masterDataMapUtility(masterDataMap, 'TSR Report Result', tsrCase.ReportResult__c) : '';
            //provariable.assessed_turnover_annual_in_lacs = 0; Commenting for LAK 9248
            provariable.final_status_of_vetting = vetCase != NULL && vetCase.ReportResult__c != NULL ? masterDataMapUtility(masterDataMap, 'Vetting Report Result', vetCase.ReportResult__c) : '';  
            //commeting due to LAK-6471 Start
            // provariable.vetting_is_the_title_clear_marketable = vetCase != NULL && vetCase.IsTheTitleClearNdMarketable__c != NULL ? vetCase.IsTheTitleClearNdMarketable__c : '';  
            //commeting due to LAK-6471 Stop
            provariable.legal_is_the_title_clear_marketable = String.isNotblank(aa.Is_the_title_clear_markateble__c)? aa.Is_the_title_clear_markateble__c : ''; 
            provariable.legal_final_status_of_legal_report = legalCase != NULL && legalCase.ReportResult__c != NULL ? masterDataMapUtility(masterDataMap, 'Legal Report Result', legalCase.ReportResult__c) : '';  
            provariable.technical_plot_is_non_agricultural = techCase != NULL && techCase.Plot_is_non_agricultural__c != NULL ? techCase.Plot_is_non_agricultural__c : '';  
            provariable.final_status_of_technical_report_from_internal_technical_manager = ''; 
            provariable.Total_construction_estimate_as_per_architect_agreement = aa.Appr_Cost_of_Const__c != NULL ? aa.Appr_Cost_of_Const__c.setScale(2) : 0;
            provariable.Registered_Agreement_Value = aa.Agrem_Value__c != NULL ? aa.Agrem_Value__c.setScale(2) : 0;
            provariable.property_owner = aa.Prop_Owners__c != NULL ? aa.Prop_Owners__c : '';
            provariable.final_status_of_legal_report_from_internal_legal = '';
            provariable.Property_Document = propDocVar;
            provariable.Document_Type = '';
            provariable.Change_required_in_Valuation_as_per_policy_norms = aa.ChangeRequiredInValuationAsPerPolicyNorm__c != NULL ? aa.ChangeRequiredInValuationAsPerPolicyNorm__c : '';
            provariable.Total_Valuation_1 = totVal1 != NULL ? totVal1.setScale(2) : 0;
            provariable.Total_Valuation_2 = totVal2 != NULL ? totVal2.setScale(2) : 0;
            provariable.Total_Valuation_3 = totVal3 != NULL ? totVal3.setScale(2) : 0;
            
            //LAK-6471 Start
            provariable.date_of_technical_report=(techCase!=null && techCase.Date_of_Report__c!=null)?DateTime.newInstance(techCase.Date_of_Report__c, Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd'):'';
            provariable.date_of_legal_report=(legalCase!=null && legalCase.Date_of_Report__c!=null)?DateTime.newInstance(legalCase.Date_of_Report__c, Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd'):'';
            provariable.copy_existing_address=(aa!=null && String.isNotBlank(aa.CopyAddFrmExAdd__c) && aa.CopyAddFrmExAdd__c=='Yes')?'yes':'no';
            provariable.Recent_title_document_Gift_deed='';
            
            
            
            //LAK-6471 End
        }
        catch(Exception ex){
            GlobalUtility.logMessage('Error', 'CrifExecuteAPIRequestGenerator', 'propertyVariable', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            return NULL;
        }
        return provariable;
    }
    
    //Applicant level banking data tags mapping
    public static CrifExecuteAPIRequestWrapper.BankingDataVariables applyBankingVariable(ApplBanking__c applyBank,Map<Id, Boolean> btLoanMap,Map<Id,ApplBankDetail__c> applBankDetailMap) {//btLoanMap becsuse of LAK-8560
        CrifExecuteAPIRequestWrapper.BankingDataVariables bankDataVar = new CrifExecuteAPIRequestWrapper.BankingDataVariables();
        try {
            bankDataVar.bnk_abb_of_bankings_considered_for_12_months = 0; //No mapping
            bankDataVar.bnk_abb_of_bankings_considered_for_6_months = 0; //No mapping
            bankDataVar.bnk_abb_programnumber_of_bankings_considered = 0; //No mapping
            bankDataVar.bnk_average_monthly_credit_transaction_count = applyBank.Average_Monthly_Credit_transaction_count__c != NULL ? applyBank.Average_Monthly_Credit_transaction_count__c.setScale(2) : 0;
            bankDataVar.bnk_average_monthly_credit_value_summation = applyBank.AverageMonthlyCreditValueSummation__c != NULL ? applyBank.AverageMonthlyCreditValueSummation__c.setScale(2) : 0;
            bankDataVar.bnk_average_monthly_debit_transaction_count = applyBank.AverageMonthlyDebitTransactionCount__c != NULL ? applyBank.AverageMonthlyDebitTransactionCount__c.setScale(2) : 0;
            bankDataVar.bnk_average_monthly_inward_return_count = applyBank.Average_Monthly_Inward_return_count__c != NULL ? applyBank.Average_Monthly_Inward_return_count__c.setScale(2) : 0;
            bankDataVar.bnk_average_monthly_outward_return_count = applyBank.AverageMonthlyOutwardReturnCount__c != NULL ? applyBank.AverageMonthlyOutwardReturnCount__c.setScale(2) : 0;
            bankDataVar.bnk_average_monthly_stop_payment_counts = applyBank.AverageMonthlyStopPaymentCounts__c != NULL ? applyBank.AverageMonthlyStopPaymentCounts__c.setScale(2) : 0;
            bankDataVar.bnk_average_monthy_debit_value_summation = applyBank.AverageMonthlyDebitValueSummation__c != NULL ? applyBank.AverageMonthlyDebitValueSummation__c.setScale(2) : 0;
            bankDataVar.bnk_avg_eod_balance_of_latest_12_months = applyBank.Avg_EOD_Balance_of_latest_12_months__c != NULL ? applyBank.Avg_EOD_Balance_of_latest_12_months__c.setScale(2) : 0;
            bankDataVar.bnk_avg_eod_balance_of_latest_3_months = applyBank.AvgEODBalanceofLatest3Months__c != NULL ? applyBank.AvgEODBalanceofLatest3Months__c.setScale(2) : 0;
            bankDataVar.bnk_avg_eod_balance_of_latest_6_months = applyBank.AvgEODBalanceofLatest6Months__c != NULL ? applyBank.AvgEODBalanceofLatest6Months__c.setScale(2) : 0;
            bankDataVar.bnk_emi_bounce_in_last_12_months = 0; //No mapping
            bankDataVar.bnk_emi_bounce_in_last_18_months = 0; //No mapping
            bankDataVar.bnk_emi_bounce_in_last_6_months = 0; //No mapping
            //LAK-8560 Start
            if(!btLoanMap.isEmpty() && applyBank.Appl__r.LoanAppln__r.SchemeId__c!=null){
                bankDataVar.bt_loan =(btLoanMap.containskey(applyBank.Appl__r.LoanAppln__r.SchemeId__c) && btLoanMap.get(applyBank.Appl__r.LoanAppln__r.SchemeId__c) == TRUE) ? 'Yes' : 'No';
            }
            //LAK-8560 End
            bankDataVar.iw_return_ratio = applyBank.I_W_Return_Ratio__c != NULL ? applyBank.I_W_Return_Ratio__c.setScale(2) : 0;
            bankDataVar.bnk_limit_utilisation = applyBank.LimitUtilisation__c != NULL ? applyBank.LimitUtilisation__c.setScale(2) : 0;
            bankDataVar.bnk_monthly_average_balance = applyBank.AverageBankBalance__c != NULL ? applyBank.AverageBankBalance__c.setScale(2) : 0;
            bankDataVar.bnk_sum_of_monthly_average_balance = applyBank.SumofMonthlyAverageBalance__c != NULL ? applyBank.SumofMonthlyAverageBalance__c.setScale(2) : 0;
            bankDataVar.bnk_total_credit_transaction_count = applyBank.TotalCreditTransactionCount__c != NULL ? applyBank.TotalCreditTransactionCount__c.setScale(2) : 0;
            bankDataVar.bnk_total_credit_value_summation = applyBank.TotalCreditValueSummation__c != NULL ? applyBank.TotalCreditValueSummation__c.setScale(2) : 0;
            bankDataVar.bnk_total_debit_transaction_count = applyBank.TotalDebitTransactionCount__c != NULL ? applyBank.TotalDebitTransactionCount__c.setScale(2) : 0;
            bankDataVar.bnk_total_debit_value_summation = applyBank.TotalDebitValueSummation__c != NULL ? applyBank.TotalDebitValueSummation__c.setScale(2) : 0;
            bankDataVar.bnk_total_inward_return_count = applyBank.TotalInwardReturnCount__c != NULL ? applyBank.TotalInwardReturnCount__c.setScale(2) : 0;
            bankDataVar.bnk_total_minimum_balance_changes_count = applyBank.TotalMinimumBalanceChangesCount__c != NULL ? applyBank.TotalMinimumBalanceChangesCount__c.setScale(2) : 0;
            bankDataVar.bnk_total_outward_return_count = applyBank.TotalOutwardReturnCount__c != NULL ? applyBank.TotalOutwardReturnCount__c.setScale(2) : 0;
            bankDataVar.bnk_total_stop_payment_counts = applyBank.TotalStopPaymentCounts__c != NULL ? applyBank.TotalStopPaymentCounts__c.setScale(2) : 0;
            bankDataVar.bnk_account_open_date = applyBank.AccountOpenDate__c != NULL ? String.valueOf(applyBank.AccountOpenDate__c) : '';
            
            //LAK-9870 Start
            bankDataVar.cust_perfios_name=string.isNotblank(applyBank.Name__c)?applyBank.Name__c:'';
            
            if(!applBankDetailMap.isEmpty() && applBankDetailMap.containsKey(applyBank.Id) && applBankDetailMap.get(applyBank.Id)!=null){
                
                ApplBankDetail__c abd=applBankDetailMap.get(applyBank.Id);
                
                bankDataVar.cust_perfios_statementstatus=string.isNotblank(abd.StatementStatus__c)?abd.StatementStatus__c:'';
                bankDataVar.cust_perfios_xnsenddate=abd.TransactionEndDate__c!=null?DateTime.newInstance(abd.TransactionEndDate__c, Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd'):'';
                bankDataVar.cust_perfios_xnsstartdate=abd.TransactionStartDate__c!=null?DateTime.newInstance(abd.TransactionStartDate__c, Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd'):'';
                
            }else{
                bankDataVar.cust_perfios_statementstatus='';
                bankDataVar.cust_perfios_xnsenddate='';
                bankDataVar.cust_perfios_xnsstartdate='';
            }
            
            //LAK-9870 End
        }
        catch(Exception ex){
            GlobalUtility.logMessage('Error', 'CrifExecuteAPIRequestGenerator', 'applyBankingVariable', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            return NULL;
        }
        return bankDataVar;
    }
    
    //Applicant level - APP_ENQUIRY_CONS tags mapping
    public static CrifExecuteAPIRequestWrapper.EnquiryConsVariables burEnqVariables(BureauEnquiry__c tempVar) {
        CrifExecuteAPIRequestWrapper.EnquiryConsVariables enqConsVar = new CrifExecuteAPIRequestWrapper.EnquiryConsVariables();
        try {
            enqConsVar.candidate_id = Double.valueOf(GlobalUtility.getUniqueNumber());
            enqConsVar.cons_datereportedenquirylist = tempVar.DateReported__c != NULL ? String.valueOf(tempVar.DateReported__c) : '';
            enqConsVar.cons_enquiryamount = tempVar.EnqAmount__c != NULL ? tempVar.EnqAmount__c.setScale(2) : 0;
            enqConsVar.cons_enquirypurposeenquirylist = tempVar.EnquiryPurpose__c != NULL ? tempVar.EnquiryPurpose__c : '';
            enqConsVar.cons_reportingmembershortnameenquirylist = tempVar.ReportingName__c != NULL ? tempVar.ReportingName__c : '';
        }
        catch(Exception ex){
            GlobalUtility.logMessage('Error', 'CrifExecuteAPIRequestGenerator', 'burEnqVariables', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            return NULL;
        }
        return enqConsVar;
    }
    
    //Applicant level - APP_CONS_BU_ACCOUNT tags mapping
    public static CrifExecuteAPIRequestWrapper.ConsBUAccountVariables consBurVariables(BureauRespDtl__c tempVar, Map<String, String> multBureResMast) {
        CrifExecuteAPIRequestWrapper.ConsBUAccountVariables burResDetConsVar = new CrifExecuteAPIRequestWrapper.ConsBUAccountVariables();
        try {
            burResDetConsVar.candidate_id = Double.valueOf(GlobalUtility.getUniqueNumber()); //tempVar.Name != NULL ? Double.valueOf(tempVar.Name) : 0;
            burResDetConsVar.bureau_name = tempVar.Source__c != NULL ? tempVar.Source__c : '';
            burResDetConsVar.cons_accountnumber_accountlist = '';
            burResDetConsVar.cons_accounttypeaccountlist = tempVar.NatureOfLoan__c != NULL && !multBureResMast.isEmpty() && multBureResMast.containsKey(tempVar.NatureOfLoan__c) ? multBureResMast.get(tempVar.NatureOfLoan__c) : '';
            burResDetConsVar.cons_dateopenedordisbursed = tempVar.DisbursalDate__c != NULL ? String.valueOf(tempVar.DisbursalDate__c) : '';
            burResDetConsVar.cons_dateclosed = tempVar.CloseDate__c != NULL ? String.valueOf(tempVar.CloseDate__c) : '';
            burResDetConsVar.cons_currentbalance = tempVar.CurrentOs__c != NULL ? tempVar.CurrentOs__c.setScale(2) : 0; 
            burResDetConsVar.cons_highcreditorsanctionedamount = tempVar.LoanAmount__c != NULL ? tempVar.LoanAmount__c.setScale(2) : 0;
            burResDetConsVar.cons_paymenthistory1 = tempVar.PayHis1__c != NULL ? tempVar.PayHis1__c : '';
            burResDetConsVar.cons_paymenthistory2 = tempVar.PayHis2__c != NULL ? tempVar.PayHis2__c : '';
            burResDetConsVar.cons_actualpaymentamount = tempVar.ActPayAmt__c != NULL ? tempVar.ActPayAmt__c.setScale(2) : 0; 
            burResDetConsVar.cons_cashlimit = tempVar.Cashlmt__c != NULL ? tempVar.Cashlmt__c.setScale(2) : 0; 
            burResDetConsVar.cons_creditlimit = tempVar.CreditLmt__c != NULL ? tempVar.CreditLmt__c.setScale(2) : 0; 
            burResDetConsVar.cons_dateoflastpayment = tempVar.LastPayment__c != NULL ? String.valueOf(tempVar.LastPayment__c) : '';
            burResDetConsVar.cons_datereportedandcertified = tempVar.DateReportedCert__c != NULL ? String.valueOf(tempVar.DateReportedCert__c) : '';
            burResDetConsVar.cons_emiamount = tempVar.EMI__c != NULL ? tempVar.EMI__c.setScale(2) : 0; 
            burResDetConsVar.cons_overdueamount = tempVar.Overdues__c != NULL ? tempVar.Overdues__c.setScale(2) : 0; 
            burResDetConsVar.cons_paymenthistoryenddate = tempVar.PaymentEndDate__c != NULL ? String.valueOf(tempVar.PaymentEndDate__c) : '';
            burResDetConsVar.cons_paymenthistorystartdate = tempVar.PaymentStartDate__c != NULL ? String.valueOf(tempVar.PaymentStartDate__c) : '';
            burResDetConsVar.cons_rateofinterest = tempVar.ROI__c != NULL ? tempVar.ROI__c.setScale(2) : 0; 
            burResDetConsVar.cons_repaymentTenure = tempVar.Tenure__c != NULL ? tempVar.Tenure__c.setScale(2) : 0;
            burResDetConsVar.cons_settlementamount = tempVar.SettlementAmt__c != NULL ? tempVar.SettlementAmt__c.setScale(2) : 0;
            burResDetConsVar.cons_valueofcollateral = (tempVar.Value_of_col__c != NULL && tempVar.Value_of_col__c.isNumeric()) ? Decimal.valueOf(tempVar.Value_of_col__c).setScale(2) : 0;
            burResDetConsVar.cons_writtenoffamountprincipal = tempVar.WrittenOffAmtPrincipal__c != NULL ? tempVar.WrittenOffAmtPrincipal__c.setScale(2) : 0;
            burResDetConsVar.cons_writtenoffamounttotal = tempVar.WrittenOffAmtTotal__c != NULL ? tempVar.WrittenOffAmtTotal__c.setScale(2) : 0;
            burResDetConsVar.cons_credit_faccility_status = '';
            burResDetConsVar.cons_ownershipindicator = tempVar.LoanCapacity__c != NULL ? (tempVar.LoanCapacity__c == 'Guarantor' ? 3 : (tempVar.LoanCapacity__c == 'Individual' ? 1 : (tempVar.LoanCapacity__c == 'Joint') ? 4 : 0)) : 0;
            burResDetConsVar.cons_suitfiledorwilfuldefault = String.isNotblank(tempVar.SuitFiledWillfulDft__c)? tempVar.SuitFiledWillfulDft__c:'';
            burResDetConsVar.cons_writtenoffsettledstatus = String.isNotblank(tempVar.WrittenOffSettledStatus__c)? tempVar.WrittenOffSettledStatus__c:'';
        }
        catch(Exception ex){
            GlobalUtility.logMessage('Error', 'CrifExecuteAPIRequestGenerator', 'consBurVariables', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            return NULL;
        }
        return burResDetConsVar;
    }
    
    //Applicant level - APP_BUREAU_SUMMARY_CONS tags mapping
    public static CrifExecuteAPIRequestWrapper.AppBurConsVariables burSummVarables(BureauDemography__c tempVar, BureauHeader__c buRec) {
        CrifExecuteAPIRequestWrapper.AppBurConsVariables burDemogConsVar = new CrifExecuteAPIRequestWrapper.AppBurConsVariables();
        try {
            burDemogConsVar.cons_addressline5addresslist = '';
            burDemogConsVar.cons_addressline4addresslist = tempVar.Address4__c != NULL ? tempVar.Address4__c : '';
            burDemogConsVar.cons_addressline3addresslist = tempVar.Address3__c != NULL ? tempVar.Address3__c : '';
            burDemogConsVar.cons_addressline2addresslist = tempVar.Address2__c != NULL ? tempVar.Address2__c : '';
            burDemogConsVar.cons_addressline1addresslist = tempVar.Address1__c != NULL ? tempVar.Address1__c : '';
            burDemogConsVar.cons_addresscategory_bureau = tempVar.AddressCategory__c != NULL ? tempVar.AddressCategory__c : '';
            burDemogConsVar.cons_actualpaymentamount = 0;
            burDemogConsVar.cons_accounttypecibil_guide = '';
            burDemogConsVar.cons_accountnumberenqactnolist = '';
            burDemogConsVar.bureau_name = tempVar.Bureau__r.Name != NULL ? tempVar.Bureau__r.Name : '';
            burDemogConsVar.cons_exclusioncode2 = '';
            burDemogConsVar.cons_exclusioncode10 = '';
            burDemogConsVar.cons_exclusioncode1 = '';
            burDemogConsVar.cons_disputeremarksline1 = '';
            burDemogConsVar.cons_datereported_consumer = '';
            burDemogConsVar.cons_datereported_addresslist = '';
            burDemogConsVar.cons_dateoflastpayment = '';
            burDemogConsVar.cons_dateofentry = '';
            burDemogConsVar.cons_cibilremarkcode_consumer = '';
            burDemogConsVar.cons_idvaluephonelist = tempVar.IdValue__c != NULL ? tempVar.IdValue__c : '';
            burDemogConsVar.cons_idtypephonelist = tempVar.IdType__c != NULL ? tempVar.IdType__c : '';
            burDemogConsVar.cons_expirydatephonelist = tempVar.ExpiryDate__c != NULL ? String.valueOf(tempVar.ExpiryDate__c) : '';
            burDemogConsVar.cons_exclusioncode9 = '';
            burDemogConsVar.cons_exclusioncode8 = '';
            burDemogConsVar.cons_exclusioncode7 = '';
            burDemogConsVar.cons_exclusioncode6 = '';
            burDemogConsVar.cons_exclusioncode5 = '';
            burDemogConsVar.cons_exclusioncode4 = '';
            burDemogConsVar.cons_exclusioncode3 = '';
            burDemogConsVar.cons_reasoncode2 = '';
            burDemogConsVar.cons_reasoncode1 = '';
            burDemogConsVar.cons_pincodeaddresslist = tempVar.Pincode__c != NULL ? String.valueOf(tempVar.Pincode__c) : '';
            burDemogConsVar.cons_paymentfrequence = '';
            burDemogConsVar.cons_occupationcode = '';
            burDemogConsVar.cons_netgrossindicator = '';
            String nameVar = '';
            if(tempVar.FirstName__c != NULL && tempVar.LastName__c != NULL) {
                nameVar = tempVar.FirstName__c + ' ' + tempVar.LastName__c;
            }
            else if(tempVar.FirstName__c != NULL && tempVar.LastName__c == NULL) {
                nameVar = tempVar.FirstName__c;
            }
            else if(tempVar.FirstName__c == NULL && tempVar.LastName__c != NULL) {
                nameVar = tempVar.LastName__c;
            }
            burDemogConsVar.cons_name1secname = nameVar;
            burDemogConsVar.cons_monthlyannuallyindicator = '';
            burDemogConsVar.cons_issuedatephonelist = '';
            burDemogConsVar.cons_income = '';
            burDemogConsVar.cons_secaddresslist = '';
            burDemogConsVar.cons_scorename = '';
            burDemogConsVar.cons_scorelist_score = '';
            burDemogConsVar.cons_scoredate = '';
            burDemogConsVar.cons_scorecardversion = '';
            burDemogConsVar.cons_scorecardname = '';
            burDemogConsVar.cons_residencecode_bureau = '';
            burDemogConsVar.cons_reasoncode5 = '';
            burDemogConsVar.cons_reasoncode4 = '';
            burDemogConsVar.cons_reasoncode3 = '';
            burDemogConsVar.cons_dateproceed = buRec != NULL && buRec.DateProceed__c != NULL ? String.valueOf(buRec.DateProceed__c) : '';
            burDemogConsVar.cons_writtenoffandsettledstatus = '';
            burDemogConsVar.cons_typeofcollateral = '';
            burDemogConsVar.cons_statecodeaddresslist = '';
            burDemogConsVar.cons_secphonelist = '';
            burDemogConsVar.cons_secname = '';
            burDemogConsVar.cons_secidlist = '';
        }
        catch(Exception ex){
            GlobalUtility.logMessage('Error', 'CrifExecuteAPIRequestGenerator', 'burSummVarables', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            return NULL;
        }
        return burDemogConsVar;
    }
    
    //Applicant level - APP_FINANCIAL_DATA tags mapping
    public static CrifExecuteAPIRequestWrapper.FinancialDataVariables financVariables(String tempVar, Map<String, Applicant_Financial_Summary__c> mapBSVar, Map<String, Applicant_Financial_Summary__c> mapPNLVar, Map<String, List<Map<String, String>>> masterDataMap, Applicant__c app) {
        CrifExecuteAPIRequestWrapper.FinancialDataVariables finDataVar = new CrifExecuteAPIRequestWrapper.FinancialDataVariables();
        try {
            
            //Mapping Balance Sheet Data
            if((!mapBSVar.isEmpty()) && mapBSVar.containsKey(tempVar)) {
                Integer lakh = 100000;
                Applicant_Financial_Summary__c tempAFS = mapBSVar.get(tempVar);
                Decimal totalCurrentAssets = (tempAFS.Stock__c != NULL ? tempAFS.Stock__c : 0) + (tempAFS.LessSix_months__c != NULL ? tempAFS.LessSix_months__c : 0) + (tempAFS.Greaterthan6__c != NULL ? tempAFS.Greaterthan6__c : 0) + (tempAFS.Advances_to_Suppliers__c != NULL ? tempAFS.Advances_to_Suppliers__c : 0) + (tempAFS.Investments__c != NULL ? tempAFS.Investments__c : 0) + (tempAFS.Prepaid_expenses__c != NULL ? tempAFS.Prepaid_expenses__c : 0) + (tempAFS.Other_current_assets__c != NULL ? tempAFS.Other_current_assets__c : 0) + (tempAFS.Cash_Bank_Balances__c != NULL ? tempAFS.Cash_Bank_Balances__c : 0);
                Decimal totalCurrentLiabilities = (tempAFS.Sundry_creditors__c != NULL ? tempAFS.Sundry_creditors__c : 0) + (tempAFS.Advances_from_customers__c != NULL ? tempAFS.Advances_from_customers__c : 0) + (tempAFS.Other_current_liabilities__c != NULL ? tempAFS.Other_current_liabilities__c : 0) + (tempAFS.Provisions_for_exps_tax_etc__c != NULL ? tempAFS.Provisions_for_exps_tax_etc__c : 0) + (tempAFS.Bank_Borrowing_Working_Capital_OD_CC__c != NULL ? tempAFS.Bank_Borrowing_Working_Capital_OD_CC__c : 0);
                if(totalCurrentLiabilities != 0) {
                    Decimal currentRatio = (totalCurrentAssets/totalCurrentLiabilities).setScale(2);
                    finDataVar.fin_current_ratio = currentRatio;
                    finDataVar.fin_quick_ratio = ((totalCurrentAssets - (tempAFS.Stock__c != NULL ? (tempAFS.Stock__c / lakh) : 0)) / totalCurrentLiabilities).setScale(2);
                }
                else {
                    finDataVar.fin_current_ratio = 0;
                    finDataVar.fin_quick_ratio = 0;
                }
                
                Decimal totalDebt = (((tempAFS.Total_Loan_funds__c != NULL ? tempAFS.Total_Loan_funds__c : 0) - (tempAFS.Bank_Borrowing_Working_Capital_OD_CC__c != NULL ? tempAFS.Bank_Borrowing_Working_Capital_OD_CC__c : 0))/lakh);
                Decimal adjNetWorth = tempAFS.Adjusted_tangible_Netwroth__c != NULL ? (tempAFS.Adjusted_tangible_Netwroth__c / lakh) : 0;
                if(adjNetWorth != 0) {
                    finDataVar.fin_debt_equity_ratio = (totalDebt / adjNetWorth).setScale(2);
                    finDataVar.fin_leverage_ratio_total = ((totalDebt + totalCurrentLiabilities) / adjNetWorth).setScale(2);
                }
                else {
                    finDataVar.fin_debt_equity_ratio = 0;
                    finDataVar.fin_leverage_ratio_total = 0;
                }
                finDataVar.fin_adjusted_net_worth = adjNetWorth.setScale(2);
                finDataVar.fin_adjusted_tangible_networth = tempAFS.Adjusted_tangible_Netwroth__c != NULL ? tempAFS.Adjusted_tangible_Netwroth__c.setScale(2) : 0;
                finDataVar.fin_advances_from_customers = tempAFS.Advances_from_customers__c != NULL ? tempAFS.Advances_from_customers__c.setScale(2)  : 0;
                finDataVar.fin_advances_to_group_cofriends = tempAFS.Adavces_to_group_co_friends__c != NULL ? tempAFS.Adavces_to_group_co_friends__c.setScale(2)  : 0;
                finDataVar.fin_advances_to_suppliers = tempAFS.Advances_to_Suppliers__c != NULL ? tempAFS.Advances_to_Suppliers__c.setScale(2)  : 0;
                finDataVar.fin_bank_borrowing_working_capital_odcc = tempAFS.Bank_Borrowing_Working_Capital_OD_CC__c != NULL ? tempAFS.Bank_Borrowing_Working_Capital_OD_CC__c.setScale(2)  : 0;
                finDataVar.fin_cash_bank_balances = tempAFS.Cash_Bank_Balances__c != NULL ? tempAFS.Cash_Bank_Balances__c.setScale(2)  : 0;
                finDataVar.fin_deffered_tax_liabilityassets = tempAFS.Deffered_Tax_Liability_Assets__c != NULL ? tempAFS.Deffered_Tax_Liability_Assets__c.setScale(2)  : 0;
                finDataVar.fin_fd_investments = tempAFS.Investments__c != NULL ? tempAFS.Investments__c.setScale(2)  : 0;
                finDataVar.fin_fd_total_loan_funds = tempAFS.Total_Loan_funds__c != NULL ? tempAFS.Total_Loan_funds__c.setScale(2)  : 0;
                finDataVar.fin_greaterthan_6_months_debtors = tempAFS.Greaterthan6__c != NULL ? tempAFS.Greaterthan6__c.setScale(2)  : 0;
                finDataVar.fin_lessthan_6_months_debtors = tempAFS.LessSix_months__c != NULL ? tempAFS.LessSix_months__c.setScale(2)  : 0;
                finDataVar.fin_misc_exp_not_written_off = tempAFS.Misc_Exp_Not_written_off__c != NULL ? tempAFS.Misc_Exp_Not_written_off__c.setScale(2)  : 0;
                finDataVar.fin_net_intangible_fixed_assets = tempAFS.Net_Intangible_Fixed_Assets__c != NULL ? tempAFS.Net_Intangible_Fixed_Assets__c.setScale(2)  : 0;
                finDataVar.fin_net_tangible_fixed_assets_including_capital_wip = tempAFS.Net_Tangible_Fixed_Assets_Including_Cap__c != NULL ? tempAFS.Net_Tangible_Fixed_Assets_Including_Cap__c.setScale(2)  : 0;
                finDataVar.fin_net_worth = tempAFS.Net_worth__c != NULL ? tempAFS.Net_worth__c.setScale(2)  : 0;
                finDataVar.fin_other_current_assets = tempAFS.Other_current_assets__c != NULL ? tempAFS.Other_current_assets__c.setScale(2)  : 0;
                finDataVar.fin_other_current_liabilities = tempAFS.Other_current_liabilities__c != NULL ? tempAFS.Other_current_liabilities__c.setScale(2)  : 0;
                finDataVar.fin_other_loans_advances = tempAFS.Other_loans_advances__c != NULL ? tempAFS.Other_loans_advances__c.setScale(2)  : 0;
                finDataVar.fin_other_loans_from_private_parties = tempAFS.Other_Loans_From_private_parties__c != NULL ? tempAFS.Other_Loans_From_private_parties__c.setScale(2)  : 0;
                finDataVar.fin_other_non_current_assets_security_deposits = tempAFS.Other_Non_Current_assets_Security_Depos__c != NULL ? tempAFS.Other_Non_Current_assets_Security_Depos__c.setScale(2)  : 0;
                finDataVar.fin_prepaid_expenses = tempAFS.Prepaid_expenses__c != NULL ? tempAFS.Prepaid_expenses__c.setScale(2)  : 0;
                finDataVar.fin_provisions_for_exps_tax_etc = tempAFS.Provisions_for_exps_tax_etc__c != NULL ? tempAFS.Provisions_for_exps_tax_etc__c.setScale(2)  : 0;
                finDataVar.fin_revaluation_reserves_notional_reserves = tempAFS.Revaluation_Reserves_Notional_Reserves__c != NULL ? tempAFS.Revaluation_Reserves_Notional_Reserves__c.setScale(2)  : 0;
                finDataVar.fin_secured_debts_banks_nbfc = tempAFS.Secured_debts_Banks_Ndfc__c != NULL ? tempAFS.Secured_debts_Banks_Ndfc__c.setScale(2)  : 0;
                finDataVar.fin_share_capital_partners_capital = tempAFS.Share_capital_Partner_s_Capital__c != NULL ? tempAFS.Share_capital_Partner_s_Capital__c.setScale(2)  : 0;
                finDataVar.fin_stock = tempAFS.Stock__c != NULL ? tempAFS.Stock__c.setScale(2)  : 0;
                finDataVar.fin_sundry_creditors = tempAFS.Sundry_creditors__c != NULL ? tempAFS.Sundry_creditors__c.setScale(2)  : 0;
                finDataVar.fin_unsecured_debt_banks_nbfc = tempAFS.Unsecured_debts_Banks_Ndfc__c != NULL ? tempAFS.Unsecured_debts_Banks_Ndfc__c.setScale(2)  : 0;
                finDataVar.fin_unsecured_loans_from_promoters_family_members = tempAFS.unsecured_Loan_from_promoters_family_m__c != NULL ? tempAFS.unsecured_Loan_from_promoters_family_m__c.setScale(2)  : 0;
                finDataVar.fin_net_working_capital = totalCurrentAssets.setScale(2) - totalCurrentLiabilities.setScale(2);
                finDataVar.fin_total_current_assets = totalCurrentAssets.setScale(2);
                finDataVar.fin_total_current_liabilities = totalCurrentLiabilities.setScale(2);
                finDataVar.fin_total_liabilities = totalCurrentLiabilities.setScale(2);
                finDataVar.fin_total_debt = totalDebt.setScale(2);  
            }
            else {
                finDataVar.fin_current_ratio = 0;
                finDataVar.fin_quick_ratio = 0;
                finDataVar.fin_debt_equity_ratio = 0;
                finDataVar.fin_leverage_ratio_total = 0;
                finDataVar.fin_adjusted_net_worth = 0;
                finDataVar.fin_adjusted_tangible_networth = 0;
                finDataVar.fin_advances_from_customers = 0;
                finDataVar.fin_advances_to_group_cofriends = 0;
                finDataVar.fin_advances_to_suppliers = 0;
                finDataVar.fin_bank_borrowing_working_capital_odcc = 0;
                finDataVar.fin_cash_bank_balances = 0;
                finDataVar.fin_deffered_tax_liabilityassets = 0;
                finDataVar.fin_fd_investments = 0;
                finDataVar.fin_fd_total_loan_funds = 0;
                finDataVar.fin_greaterthan_6_months_debtors = 0;
                finDataVar.fin_lessthan_6_months_debtors = 0;
                finDataVar.fin_misc_exp_not_written_off = 0;
                finDataVar.fin_net_intangible_fixed_assets = 0;
                finDataVar.fin_net_tangible_fixed_assets_including_capital_wip = 0;
                finDataVar.fin_net_worth = 0;
                finDataVar.fin_other_current_assets = 0;
                finDataVar.fin_other_current_liabilities = 0;
                finDataVar.fin_other_loans_advances = 0;
                finDataVar.fin_other_loans_from_private_parties = 0;
                finDataVar.fin_other_non_current_assets_security_deposits = 0;
                finDataVar.fin_prepaid_expenses = 0;
                finDataVar.fin_provisions_for_exps_tax_etc = 0; 
                finDataVar.fin_revaluation_reserves_notional_reserves = 0;
                finDataVar.fin_secured_debts_banks_nbfc = 0;
                finDataVar.fin_share_capital_partners_capital = 0;
                finDataVar.fin_stock = 0;
                finDataVar.fin_sundry_creditors = 0;
                finDataVar.fin_unsecured_debt_banks_nbfc = 0;
                finDataVar.fin_unsecured_loans_from_promoters_family_members = 0;
                finDataVar.fin_net_working_capital = 0;
                finDataVar.fin_total_current_assets = 0;
                finDataVar.fin_total_current_liabilities = 0;
                finDataVar.fin_total_liabilities = 0;
                finDataVar.fin_total_debt = 0;
                finDataVar.fin_stock_replenishment_period_days = 0;
            }
            
            //Mapping Profit & Loss Data 
            if((!mapPNLVar.isEmpty()) && mapPNLVar.containsKey(tempVar)) {
                Applicant_Financial_Summary__c tempAFS = mapPNLVar.get(tempVar);
                Integer lakh = 100000;
                Decimal salToParDir = tempAFS.Salary_to_Partner_Directors__c != NULL ? tempAFS.Salary_to_Partner_Directors__c : 0; 
                Decimal nonOpEx = tempAFS.Non_Operating_Expenses_FxLoss_AssetLoss__c != NULL ? tempAFS.Non_Operating_Expenses_FxLoss_AssetLoss__c : 0; 
                Decimal intPartCap = tempAFS.Interest_on_Partner_Capital__c != NULL ? tempAFS.Interest_on_Partner_Capital__c : 0; 
                Decimal deprec = tempAFS.Depreciation__c != NULL ? tempAFS.Depreciation__c : 0; 
                Decimal pat = tempAFS.PAT__c != NULL ? tempAFS.PAT__c : 0; 
                Decimal cashProfit = ((salToParDir + nonOpEx + intPartCap + deprec + pat)/lakh).setScale(2);
                finDataVar.fin_cash_profit = cashProfit.setScale(2); 
                finDataVar.fin_direct_expenses = tempAFS.Direct_Expenses__c != NULL ? tempAFS.Direct_Expenses__c.setScale(2)  : 0;
                finDataVar.fin_ebitda = tempAFS.EBITDA__c != NULL ? tempAFS.EBITDA__c.setScale(2)  : 0;
                finDataVar.fin_fd_closing_stock = tempAFS.Closing_Stock__c != NULL ? tempAFS.Closing_Stock__c.setScale(2)  : 0;
                finDataVar.fin_fd_depreciation = tempAFS.Depreciation__c != NULL ? tempAFS.Depreciation__c.setScale(2)  : 0;
                finDataVar.fin_fd_financial_year = tempAFS.Financial_Year__c != NULL ? tempAFS.Financial_Year__c  : '';
                finDataVar.fin_fd_opening_stock = tempAFS.Opening_Stock__c != NULL ? tempAFS.Opening_Stock__c.setScale(2)  : 0;
                finDataVar.fin_fd_pat = tempAFS.PAT__c != NULL ? tempAFS.PAT__c.setScale(2)  : 0;
                finDataVar.Net_Profit_After_Tax = tempAFS.PAT__c != NULL ? tempAFS.PAT__c.setScale(2)  : 0;
                finDataVar.fin_fd_purchases = tempAFS.Purchases__c != NULL ? tempAFS.Purchases__c.setScale(2)  : 0;
                finDataVar.fin_gross_profit = tempAFS.Gross_Profit__c != NULL ? tempAFS.Gross_Profit__c.setScale(2)  : 0;
                finDataVar.fin_interest_on_cc_od_limits = tempAFS.Interest_on_CC_OD_limits__c != NULL ? tempAFS.Interest_on_CC_OD_limits__c.setScale(2)  : 0;
                finDataVar.fin_interest_on_partners_capital = tempAFS.Interest_on_Partner_Capital__c != NULL ? tempAFS.Interest_on_Partner_Capital__c.setScale(2)  : 0;
                finDataVar.fin_interest_on_term_loans = tempAFS.Interest_on_Term_Loans__c != NULL ? tempAFS.Interest_on_Term_Loans__c.setScale(2)  : 0;
                finDataVar.fin_net_income_considered_for_eligibility = tempAFS.Net_Income_Considered_for_Eligibility__c != NULL ? tempAFS.Net_Income_Considered_for_Eligibility__c.setScale(2)  : 0;
                finDataVar.fin_non_business_income = tempAFS.Non_Business_Income__c != NULL ? tempAFS.Non_Business_Income__c.setScale(2)  : 0;
                finDataVar.fin_non_operating_expenses_fx_loss_loss_on_sale_of_assets = tempAFS.Non_Operating_Expenses_FxLoss_AssetLoss__c != NULL ? tempAFS.Non_Operating_Expenses_FxLoss_AssetLoss__c.setScale(2)  : 0;
                finDataVar.fin_non_operating_income = tempAFS.Non_Operating_Income__c != NULL ? tempAFS.Non_Operating_Income__c.setScale(2)  : 0;
                finDataVar.fin_office_administrative_expenses = tempAFS.Office_Administrative_Expenses__c != NULL ? tempAFS.Office_Administrative_Expenses__c.setScale(2)  : 0;
                finDataVar.fin_other_indirect_expenses = tempAFS.Other_Indirect_Expenses__c != NULL ? tempAFS.Other_Indirect_Expenses__c.setScale(2)  : 0;
                finDataVar.fin_other_operating_income_which_is_incidental_to_business = tempAFS.Other_Operating_Income_IncomeIncidental__c != NULL ? tempAFS.Other_Operating_Income_IncomeIncidental__c.setScale(2)  : 0;
                finDataVar.fin_profit_before_depreciation_tax_pbdt = tempAFS.Profit_Before_Depreciation_and_Tax_PBDT__c != NULL ? tempAFS.Profit_Before_Depreciation_and_Tax_PBDT__c.setScale(2)  : 0;
                finDataVar.fin_profit_before_tax_pbt = tempAFS.Profit_Before_Tax__c != NULL ? tempAFS.Profit_Before_Tax__c.setScale(2)  : 0;
                finDataVar.finSalToPartDirect = tempAFS.Salary_to_Partner_Directors__c != NULL ? tempAFS.Salary_to_Partner_Directors__c.setScale(2)  : 0;
                finDataVar.fin_tax_on_the_above_income = tempAFS.Tax_on_Above_Income__c != NULL ? tempAFS.Tax_on_Above_Income__c.setScale(2)  : 0;
                finDataVar.fin_total_sales = tempAFS.Total_Sales__c != NULL ? tempAFS.Total_Sales__c.setScale(2)  : 0;
                finDataVar.fin_type_of_accounts = tempAFS.Type_of_Accounts__c != NULL ? masterDataMapUtility(masterDataMap, 'Type of Accounts', tempAFS.Type_of_Accounts__c) : '';
                finDataVar.fin_directororpartners_interest_on_partners_capital_for_clubbing = tempAFS.Director_Partners_remuneration_Interest__c != NULL ? tempAFS.Director_Partners_remuneration_Interest__c.setScale(2)  : 0;
                if((tempAFS.Interest_on_Term_Loans__c != NULL && tempAFS.Interest_on_Term_Loans__c != 0) && (tempAFS.Interest_on_CC_OD_limits__c != NULL && tempAFS.Interest_on_CC_OD_limits__c !=0)) {
                    finDataVar.fin_interest_coverage_ratio = ((tempAFS.EBITDA__c != NULL ? tempAFS.EBITDA__c : 0) / (tempAFS.Interest_on_Term_Loans__c + tempAFS.Interest_on_CC_OD_limits__c)).setScale(2);
                }
                else {
                    finDataVar.fin_interest_coverage_ratio = 0;
                }
                if((tempAFS.Total_Sales__c != NULL && tempAFS.Total_Sales__c !=0) && (tempAFS.Other_Operating_Income_IncomeIncidental__c != NULL && tempAFS.Other_Operating_Income_IncomeIncidental__c != 0)) {
                    finDataVar.fin_gross_profit_margin = (((tempAFS.Gross_Profit__c != NULL ? tempAFS.Gross_Profit__c : 0) / (tempAFS.Total_Sales__c + tempAFS.Other_Operating_Income_IncomeIncidental__c)) * 100).setScale(2);
                }
                else {
                    finDataVar.fin_gross_profit_margin = 0;
                }
                if((tempAFS.Opening_Stock__c != NULL && tempAFS.Opening_Stock__c != 0) && (tempAFS.Closing_Stock__c != NULL && tempAFS.Closing_Stock__c != 0)) {
                    finDataVar.fin_inventory_turnover = ((tempAFS.Opening_Stock__c + (tempAFS.Purchases__c != NULL ? tempAFS.Purchases__c : 0) + (tempAFS.Direct_Expenses__c != NULL ? tempAFS.Direct_Expenses__c : 0) + tempAFS.Closing_Stock__c) / ((tempAFS.Opening_Stock__c + tempAFS.Closing_Stock__c) / 2)).setScale(2);
                }
                else {
                    finDataVar.fin_inventory_turnover = 0;
                }
                Decimal netProfMarg = 0;
                Decimal totSal = tempAFS.Total_Sales__c != NULL ? (tempAFS.Total_Sales__c/lakh).setScale(2) : 0;
                if(tempAFS.Total_Sales__c != NULL && tempAFS.Profit_Before_Tax__c != NULL && tempAFS.Total_Sales__c != 0 && totSal != 0) {
                    netProfMarg = ((tempAFS.Profit_Before_Tax__c / totSal) * 100).setScale(2);
                }
                finDataVar.fin_net_profit_margin = netProfMarg.setScale(2);
                finDataVar.finTotDebt = tempAFS.Debtors__c != NULL ? (tempAFS.Debtors__c/lakh).setScale(2) : 0;
                finDataVar.Depreciation_Unaudited_Financials = (tempAFS.Type_of_Accounts__c != NULL && tempAFS.Type_of_Accounts__c != 'Audited' && tempAFS.Depreciation__c != NULL) ? tempAFS.Depreciation__c.setScale(2) : 0;
                finDataVar.Depreciation_Audited_Financials = (tempAFS.Type_of_Accounts__c != NULL && tempAFS.Type_of_Accounts__c == 'Audited' && tempAFS.Depreciation__c != NULL) ? tempAFS.Depreciation__c.setScale(2) : 0;
                finDataVar.fin_taxes = tempAFS.Taxes__c != NULL ? tempAFS.Taxes__c.setScale(2) : 0;
                Decimal stockVal = tempAFS.Stock__c != NULL ? (tempAFS.Stock__c/lakh).setScale(2) : 0;
                Decimal openingStock = tempAFS.Opening_Stock__c != NULL ? tempAFS.Opening_Stock__c/lakh : 0;
                Decimal closingStock = tempAFS.Closing_Stock__c != NULL ? tempAFS.Closing_Stock__c/lakh : 0;
                Decimal directExpense = tempAFS.Direct_Expenses__c != NULL ? tempAFS.Direct_Expenses__c/lakh : 0;
                Decimal purchases = tempAFS.Purchases__c != NULL ? (tempAFS.Purchases__c/lakh).setScale(2) : 0;
                Decimal stockReplDenom = openingStock + directExpense + purchases - closingStock;
                finDataVar.fin_stock_replenishment_period_days = stockReplDenom != 0 ? ((stockVal / stockReplDenom) * 365).setScale(2) : 0;
                finDataVar.fin_creditors_payment_period_days = tempAFS.Purchases__c != NULL && tempAFS.Sundry_creditors__c != NULL && tempAFS.Purchases__c != 0 ? ((tempAFS.Sundry_creditors__c / tempAFS.Purchases__c) * 365).setScale(2) : 0;
                finDataVar.fin_debtors_collection_period_days = tempAFS.Total_Sales__c != NULL && tempAFS.Total_Sales__c != 0 ? ((((tempAFS.LessSix_months__c != NULL ? tempAFS.LessSix_months__c : 0) + (tempAFS.Greaterthan6__c != NULL ? tempAFS.Greaterthan6__c : 0)) / tempAFS.Total_Sales__c) * 365).setScale(2) : 0;
                finDataVar.fin_itr_filing_gap_days = tempAFS.ITR_Filing_Gap_Days__c != NULL && tempAFS.ITR_Filing_Gap_Days__c.isNumeric() ? Decimal.valueOf(tempAFS.ITR_Filing_Gap_Days__c).setScale(2) : 0;
            }
            else {
                finDataVar.fin_cash_profit = 0;
                finDataVar.fin_direct_expenses = 0;
                finDataVar.fin_ebitda = 0;
                finDataVar.fin_fd_closing_stock = 0;
                finDataVar.fin_fd_depreciation = 0;
                finDataVar.fin_fd_financial_year = '';
                finDataVar.fin_fd_opening_stock = 0;
                finDataVar.fin_fd_pat = 0;
                finDataVar.Net_Profit_After_Tax = 0;
                finDataVar.fin_fd_purchases = 0;
                finDataVar.fin_gross_profit = 0;
                finDataVar.fin_interest_on_cc_od_limits = 0;
                finDataVar.fin_interest_on_partners_capital = 0;
                finDataVar.fin_interest_on_term_loans = 0;
                finDataVar.fin_net_income_considered_for_eligibility = 0;
                finDataVar.fin_non_business_income = 0;
                finDataVar.fin_non_operating_expenses_fx_loss_loss_on_sale_of_assets = 0;
                finDataVar.fin_non_operating_income = 0;
                finDataVar.fin_office_administrative_expenses = 0;
                finDataVar.fin_other_indirect_expenses = 0;
                finDataVar.fin_other_operating_income_which_is_incidental_to_business = 0;
                finDataVar.fin_profit_before_depreciation_tax_pbdt = 0;
                finDataVar.fin_profit_before_tax_pbt = 0;
                finDataVar.finSalToPartDirect = 0;
                finDataVar.fin_tax_on_the_above_income = 0;
                finDataVar.fin_total_sales = 0;
                finDataVar.fin_type_of_accounts = '';
                finDataVar.fin_directororpartners_interest_on_partners_capital_for_clubbing = 0;
                finDataVar.fin_interest_coverage_ratio = 0;
                finDataVar.fin_gross_profit_margin = 0;
                finDataVar.fin_inventory_turnover = 0;
                finDataVar.fin_net_profit_margin = 0;
                finDataVar.finTotDebt = 0;
                finDataVar.Depreciation_Unaudited_Financials = 0;
                finDataVar.Depreciation_Audited_Financials = 0;
                finDataVar.fin_taxes = 0;
                finDataVar.fin_stock_replenishment_period_days = 0;
                finDataVar.fin_creditors_payment_period_days = 0;
                finDataVar.fin_debtors_collection_period_days = 0;
                finDataVar.fin_itr_filing_gap_days = 0;
            }
            
            //Blank
            finDataVar.fin_balance_sheet_source = ''; //drop 2
            finDataVar.fin_profit_n_loss_account_source = ''; // drop 2
            finDataVar.fin_transferred_value_from_p_n_l_ac = 0; //will be blank
            finDataVar.cust_interest_paid_to_partners_or_directors_amt = 0; //drop 2 
            finDataVar.variable_component = 0; //will be blank
            finDataVar.Reimbursements = 0; //will be blank 
            
            //Need to map
            finDataVar.fin_turnover_growth_rate = 0; //Need to map 
            finDataVar.Interest_Dividend_Income = 0; //Need to map 
            finDataVar.annual_net_rental_income_bank_credit = 0; //Need to map    
            finDataVar.fin_total_asset = 0; //Mrunal to confirm  
        }
        catch(Exception ex){
            GlobalUtility.logMessage('Error', 'CrifExecuteAPIRequestGenerator', 'financVariables', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            return NULL;
        }
        return finDataVar;
    }
    
    //Applicant level - APP_GST_DATA tags mapping
    public static CrifExecuteAPIRequestWrapper.GstDataVariables gstVariables(ApplGST__c applyGST) {
        CrifExecuteAPIRequestWrapper.GstDataVariables gstVar = new CrifExecuteAPIRequestWrapper.GstDataVariables();
        try {
            gstVar.gst_annualised_to = 0;
            gstVar.gst_gdes = '';
            gstVar.gst_hsncd = '';
            gstVar.gst_industry = '';
            gstVar.gst_lastupdateddate = '';
            gstVar.gst_name = '';
            gstVar.gst_ntr = '';
            //gstVar.gst_percentage__of_growth_in_to_for_current_fy = 0;
            gstVar.gstPercGrowth = 0;
            gstVar.gst_returns_for_last_12_months = '';
            gstVar.gst_saccd = '';
            gstVar.gst_sdes = '';
            gstVar.gst_total_turnover_for_current_financial_year_fy = 0;
            gstVar.gst_turnover_profit_growth = 0;
            
            //LAK-9870 Start
            gstVar.gstgspapi_GST_status=string.isNotblank(applyGST.GSTIN_Status__c)?applyGST.GSTIN_Status__c:'';
            gstVar.gstgspapi_GST_registration_rgdt = applyGST.RegDate__c != null ? DateTime.newInstance(applyGST.RegDate__c, Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd') : '';
            //LAK-9870 END
        }
        catch(Exception ex){
            GlobalUtility.logMessage('Error', 'CrifExecuteAPIRequestGenerator', 'gstVariables', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            return NULL;
        }
        return gstVar;
    }
    
    //Applicant level - APP_ADDRESS tags mapping
    public static CrifExecuteAPIRequestWrapper.AppAddressVariables applyAddrVariables(ApplAddr__c adr, Map<String, LocMstr__c> locatMasterMap, Map<String, List<Map<String, String>>> masterDataMap,Map<Id,Date> caseAddressMap) {
        CrifExecuteAPIRequestWrapper.AppAddressVariables appAddrVar = new CrifExecuteAPIRequestWrapper.AppAddressVariables();
        try {
            Double stateId, cityId;
            if(locatMasterMap.containsKey(adr.City__c) && locatMasterMap.get(adr.City__c) != NULL) {
                cityId = locatMasterMap.get(adr.City__c).CityId__c != NULL && locatMasterMap.get(adr.City__c).CityId__c.isNumeric() ? Double.valueOf(locatMasterMap.get(adr.City__c).CityId__c) : 0;
                stateId = locatMasterMap.get(adr.City__c).StateId__c != NULL && locatMasterMap.get(adr.City__c).StateId__c.isNumeric() ? Double.valueOf(locatMasterMap.get(adr.City__c).StateId__c) : 0; 
            }
            
            String addrTypVar = '';
            if(String.isNotBlank(adr.AddrTyp__c)) {
                String addrType = '';
                //LAK 8475 Start(Commentting this code )
                // if(adr.AddrTyp__c.equalsIgnoreCase('Other Address') || adr.AddrTyp__c.equalsIgnoreCase('Office Address')) {
                //  addrType = 'Other Address';
                //}
                //else {
                addrType = adr.AddrTyp__c;
                //}
                ////LAK 8475 End(Commentting this code )
                addrTypVar = String.isNotBlank(addrType) ? masterDataMapUtility(masterDataMap, 'Address Type', addrType) : '';
            }
            
            appAddrVar.cust_type_of_address = addrTypVar;
            appAddrVar.cust_state_ut = stateId != NULL ? stateId : 0; 
            appAddrVar.cust_stability_at_given_address_month = adr.StabAtAddressMnth__c != NULL ? adr.StabAtAddressMnth__c.setScale(2)  : 0;  
            appAddrVar.cust_stability_at_given_address_year = adr.StabAtAddressYr__c != NULL ? adr.StabAtAddressYr__c.setScale(2)  : 0;   
            appAddrVar.cust_pin_code = adr.Pincode__c != NULL && adr.Pincode__c.isNumeric() ? Double.valueOf(adr.Pincode__c) : 0;
            appAddrVar.cust_ownership_type = adr.OwnType__c != NULL ? masterDataMapUtility(masterDataMap, 'Ownership Type', adr.OwnType__c) : '';
            String nearFedBranch;
            if(String.isNotBlank(adr.AddrTyp__c) && adr.AddrTyp__c.equalsIgnoreCase('Residence Address') && String.isNotBlank(adr.Nearest_Fedfina_Branch__c)) {
                nearFedBranch = adr.Nearest_Fedfina_Branch__c;
            }
            appAddrVar.cust_nearest_fedfina_branch = nearFedBranch != NULL ? nearFedBranch : '';
            appAddrVar.cust_dist_from_nearest_fedfina = adr.DisFrmFFBrnh__c != NULL ? adr.DisFrmFFBrnh__c.setScale(2) : 0;
            appAddrVar.cust_dist_from_sourcing_branch = adr.DisFrmSrcBrnh__c != NULL ? adr.DisFrmSrcBrnh__c.setScale(2) : 0;
            appAddrVar.cust_city = cityId != NULL ? cityId : 0;
            appAddrVar.cust_negative_caution_area = (adr != NULL && adr.Negative_Caution_Area__c != NULL) ? adr.Negative_Caution_Area__c : '';
            
            //LAK-9870 Start
            appAddrVar.CPVFI_report_date=(!caseAddressMap.isEmpty() && caseAddressMap.containsKey(adr.id))?DateTime.newInstance(caseAddressMap.get(adr.id), Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd'):'';
            //LAK-9870 End
        }
        catch(Exception ex){
            GlobalUtility.logMessage('Error', 'CrifExecuteAPIRequestGenerator', 'applyAddrVariables', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            return NULL;
        }
        return appAddrVar;
    }
    
    //Applicant level - APP_ENQUIRY_COMM tags mapping 
    /*
public static CrifExecuteAPIRequestWrapper.EnquiryCommVariables burEnqCommVariables() {
CrifExecuteAPIRequestWrapper.EnquiryCommVariables enqCommVar = new CrifExecuteAPIRequestWrapper.EnquiryCommVariables();
try {
enqCommVar.candidate_id = 0;
enqCommVar.m_enqamtenqdetailsinlast24month = '';
enqCommVar.m_enqdetailsinlast24monthenqdetailsinlast24monthvec = '';
enqCommVar.m_enq_date_enqdetailsinlast24month = '';
enqCommVar.m_enqoutside_insti_enqsummarysec = 0;
enqCommVar.m_enqpurposeenqdetailsinlast24month = '';
enqCommVar.m_enqsummarysec_productsec = '';
enqCommVar.m_enqtotalenqsummarysec = 0;
enqCommVar.m_enquiriesdispute_enqdetailsinlast24monthvec = '';
}
catch(Exception ex){
GlobalUtility.logMessage('Error', 'CrifExecuteAPIRequestGenerator', 'burEnqCommVariables', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
return NULL;
}
return enqCommVar;
}
*/
    
    //Applicant level - APP_COMM_BU_ACCOUNT tags mapping 
    /*
public static CrifExecuteAPIRequestWrapper.CommBuAccountVariables commBurAccVar() {
CrifExecuteAPIRequestWrapper.CommBuAccountVariables commBuAccVar = new CrifExecuteAPIRequestWrapper.CommBuAccountVariables();
try {
commBuAccVar.candidate_id = 0;
commBuAccVar.bureau_name = '';
commBuAccVar.m_accountnumber_creditfacilitycurrentdetails = '';
commBuAccVar.m_acordpdcfhistory_upto24M = '';
commBuAccVar.m_amount_creditfacilitycurrentdetails = '';
commBuAccVar.m_amtsettled_writtenoff_invoked_suitfilled_overduecf = '';
commBuAccVar.m_assetclassificationdpddpdcreditfacilitycurrentdetails = '';
commBuAccVar.m_cfhistoryforacordpdupt_24M_vec = '';
commBuAccVar.m_cfhistoryforacordpdupto24M_vec_brwsec = '';
commBuAccVar.m_cfmemberdatescreditfacilitycurrentdetails = '';
commBuAccVar.m_cfserialnumbercreditfacilitycurrentdetails = '';
commBuAccVar.m_cftypecreditfacilitycurrentdetails = '';
commBuAccVar.m_chequedishounoured_duetoinsufficientfunds_brwsec = '';
commBuAccVar.m_creditfacilitycurrentdetailsvec = '';
commBuAccVar.m_creditfacilitycurrentdetailsvec_brwsec = '';
commBuAccVar.m_creditfacilitydetailsas_brwsec = '';
commBuAccVar.m_creditfacilitydetailsas_brwsecproductsecproductsec = '';
commBuAccVar.m_creditfacilitydetailsasguarantorvecproductsec = '';
commBuAccVar.m_creditfacilitydisputecreditfacilitycurrentdetails = '';
commBuAccVar.m_creditfacilityoverduedetailsvec = 0;
commBuAccVar.m_creditfacilityoverduedetailsvec_brwsec = '';
commBuAccVar.m_currencyamountamount = '';
commBuAccVar.m_derivativecreditfacilitycurrentdetails = '';
commBuAccVar.m_disputeremark_creditfacilitydispute = '';
commBuAccVar.m_dpd1to30amtcreditfacilityoverduedetails = 0;
commBuAccVar.m_drawingpoweramount = '';
commBuAccVar.m_loanexpirydtotherdetails = '';
commBuAccVar.m_message_creditfacilitydetailsas_brwsec = '';
commBuAccVar.m_message_creditfacilityguarantordetailsvec = '';
commBuAccVar.m_message_creditfacilitysecuritydetailsvec = '';
commBuAccVar.m_messagecreditfacilitydetailsas_brwsec = '';
commBuAccVar.m_num_ofsuitfiledsettled_writoff_suitfilled_overduecf = '';
commBuAccVar.m_osbalanceamount = '';
commBuAccVar.m_otherdetailscreditfacilitycurrentdetails = '';
commBuAccVar.m_sanctionedamtamount = '';
commBuAccVar.m_sanctioneddtotherdetails = '';
commBuAccVar.m_lastreporteddate_creditfacilitycurrentdetails = '';
commBuAccVar.m_osamountcfhistory_upto24M = '';
commBuAccVar.m_overdueamount = '';
commBuAccVar.m_status_creditfacilitycurrentdetails = '';
}
catch(Exception ex){
GlobalUtility.logMessage('Error', 'CrifExecuteAPIRequestGenerator', 'commBurAccVar', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
return NULL;
}
return commBuAccVar;
}
*/
    
    //Applicant level - APP_BUREAU_SUMMARY_COMM tags mapping 
    public static CrifExecuteAPIRequestWrapper.AppBurSummCommVariables commBurSumVar(Rank__c tempVar) {
        CrifExecuteAPIRequestWrapper.AppBurSummCommVariables commBuSumVar = new CrifExecuteAPIRequestWrapper.AppBurSummCommVariables();
        try {
            commBuSumVar.m_brwdelinquencyreportedon_brw_brwprofilesec = '';
            commBuSumVar.m_brwdelinquencyreported_brwprofilesec = '';
            commBuSumVar.m_borrweriddetailsvec_brwprofilesec = '';
            commBuSumVar.m_borrweriddetailsborrweriddetailsvec = '';
            commBuSumVar.m_borrwerdetails_brwprofilesec = '';
            commBuSumVar.m_borrweraddresscontactdetails_brwprofilesec = '';
            commBuSumVar.m_banknoofcreditgrantors_noofcreditfacilities = '';
            commBuSumVar.m_applicationreferencenumberreportheaderrec = '';
            commBuSumVar.m_addressvec_enqinfo_rec = '';
            commBuSumVar.m_addresscount_enqinfo_rec = '';
            commBuSumVar.m_cin_borrweriddetailsborrweriddetails = '';
            commBuSumVar.m_businessindustrytypeborrwerdetails = '';
            commBuSumVar.m_businesscategoryborrwerdetails = '';
            commBuSumVar.m_brwtotal_os_totalcf_delinquent_os_delinquentcf = '';
            commBuSumVar.m_brwslegalconstitutionborrwerdetails = '';
            commBuSumVar.m_brwprofilesecproductsec = '';
            commBuSumVar.m_brwperc_total_os_totalcf_delinquent_os_delinquentcf = '';
            //commBuSumVar.m_brwoffice_locationtypelocationinfo_ = '';
            commBuSumVar.m_brwname_enqinfo_rec = '';
            commBuSumVar.m_brwdispute_brwprofilesec = '';
            commBuSumVar.m_countofcreditfacilitiessummary = '';
            commBuSumVar.m_com_dpd61to90 = '';
            commBuSumVar.m_com_dpd31to60 = '';
            commBuSumVar.m_com_dpd1to30 = '';
            commBuSumVar.m_com_dpd0 = '';
            commBuSumVar.m_com_count = '';
            commBuSumVar.m_classofactivityvecborrwerdetails = '';
            commBuSumVar.m_classofactivityclassofactivityvec = '';
            commBuSumVar.m_cityaddressvecaddressvec = '';
            commBuSumVar.m_cin_enqinfo_recenqinfo_rec = '';
            commBuSumVar.m_creditvisionnamecreditvision = '';
            commBuSumVar.m_creditvisiondesccreditvision = '';
            commBuSumVar.m_creditvisioncreditvisionsec = '';
            commBuSumVar.m_creditratingsummaryvec_productsec = '';
            commBuSumVar.m_creditprofilesummarysecproductsec = '';
            commBuSumVar.m_creditlenderenqdetailsinlast24month = '';
            commBuSumVar.m_creditfacilitysecuritydetailsvec_brwsec = '';
            commBuSumVar.m_creditfacilityguarantordetailsvec_brwsec = '';
            commBuSumVar.m_creditfacilitiessummary_productsec = '';
            commBuSumVar.m_countsub_loss_dpd_total = '';
            commBuSumVar.m_derogatoryinfo_onderogatoryinfo_sec = '';
            commBuSumVar.m_derogatoryinfo_brwderogatoryinfo_sec = '';
            commBuSumVar.m_delinquency_PSB_otherprivateforeignbanks_nbfcothers = '';
            commBuSumVar.m_dbtnonstdvec = '';
            commBuSumVar.m_dateofregistrationenqinfo_recenqinfo_rec = '';
            commBuSumVar.m_dateofincorporationborrwerdetailsborrwerdetails = '';
            //commBuSumVar.m_currentinsti_outside_insti_ = '';
            commBuSumVar.m_crn_enqinfo_rec = '';
            commBuSumVar.m_creditvisionvaluecreditvision = '';
            commBuSumVar.m_creditvisionsec_productsec = '';
            commBuSumVar.m_enq_date_enqdetailsinlast24month = '';
            commBuSumVar.m_dpd91to180nonstdvec = '';
            commBuSumVar.m_dpd61to90stdvec = '';
            commBuSumVar.m_dpd31to60_stdvec = '';
            commBuSumVar.m_dpd1to30stdvec = '';
            commBuSumVar.m_dpd0stdvec = '';
            commBuSumVar.m_dpd_otherinsti_outside_total_PSB_privateforeignbanks = '';
            commBuSumVar.m_disputeremarksdate_creditfacilitydispute = '';
            //commBuSumVar.m_dishonoredchequetotal_insti_outside_insti_ = '';
            commBuSumVar.m_derogatoryinfo_secproductsec = '';
            commBuSumVar.m_greaterthan24monthnoofenquiries = '';
            //commBuSumVar.m_forexinsti_outside_insti_ = '';
            //mmBuSumVar.m_exclusionreasonrankvec = tempVar != NULL && tempVar.ExclusionRes__c != NULL ? tempVar.ExclusionRes__c : '';
            //mmBuSumVar.m_exclusionreasonrankvec = '';
            commBuSumVar.m_enquiriesdispute_enqdetailsinlast24monthvec = '';
            commBuSumVar.m_enqtotalenqsummarysec = '';
            commBuSumVar.m_enqsummarysec_productsec = '';
            commBuSumVar.m_enqpurposeenqdetailsinlast24month = '';
            commBuSumVar.m_enqoutside_insti_enqsummarysec = '';
            commBuSumVar.m_enqdetailsinlast24monthenqdetailsinlast24monthvec = '';
            commBuSumVar.m_enqamtenqdetailsinlast24month = '';
            //commBuSumVar.m_last24M_insti_outside_insti_ = '';
            commBuSumVar.m_last_rep_date_brwrid_detailsvecborrweriddetailsvec = '';
            //commBuSumVar.m_invoked_total_insti_outside_insti_ = '';
            commBuSumVar.m_insti_oustandingbalancebycfandassetclasificationsec = '';
            commBuSumVar.m_insti_derogatoryinfo_brw = '';
            commBuSumVar.m_insti_brwdelinquencyreportedon_brw = '';
            commBuSumVar.m_inquirypurpose_reportheaderrec = '';
            commBuSumVar.m_guarantortotal_os_totalcf_delinquent_os_delinquentcf = '';
            commBuSumVar.m_guarantorperc_total_os_totalcf_delinquent_os_dpdcf = '';
            commBuSumVar.m_insti_derogatoryinfo_secderogatoryinfo_sec = '';
            commBuSumVar.m_message_enqsummarysecenqsummarysec = '';
            commBuSumVar.m_message_creditratingsummaryvec = '';
            commBuSumVar.m_message_creditfacilityoverduedetailsvec = '';
            commBuSumVar.m_message_creditfacilitydetailsasguarantorvec = '';
            commBuSumVar.m_message_chequedishounouredduetoinsufficientfunds = '';
            commBuSumVar.m_message_brw_dpd_reported_on_brwin24M = '';
            commBuSumVar.m_locationdetailssec_productsec = '';
            commBuSumVar.m_latestcfopeneddatetotaltotal = '';
            commBuSumVar.m_latestcfopeneddateInstitute_publicsector_foreignbank = '';
            commBuSumVar.m_messageofrelatedparties_derogatoryinfo_sec = '';
            commBuSumVar.m_messageenqdetailsinlast24month = '';
            commBuSumVar.m_messagederogatoryinfo_sec = '';
            commBuSumVar.m_message_relationshipdetailsvec = '';
            commBuSumVar.m_message_oustandingbalancebycfandassetclasificationsec = '';
            commBuSumVar.m_message_ofguarantedpartiesderogatoryinfo_sec = '';
            commBuSumVar.m_message_of_brwoutside_insti_derogatoryinfo_sec = '';
            commBuSumVar.m_message_of_brwinsti_derogatoryinfo_sec = '';
            commBuSumVar.m_message_of_brwderogatoryinfo_sec = '';
            commBuSumVar.m_message_insti_PSB_privateforeignbanks = '';
            //commBuSumVar.m_nbfcothers_outside_insti_ = '';
            commBuSumVar.m_nameborrwerdetails_brwdelinquencyreportedon_brw = '';
            commBuSumVar.m_mostrecentdatenoofenquiries = '';
            commBuSumVar.m_month7to12_noofenquiries = '';
            commBuSumVar.m_month4to6noofenquiries = '';
            commBuSumVar.m_month2to3noofenquiries = '';
            commBuSumVar.m_month1noofenquiries = '';
            commBuSumVar.m_month12to24noofenquiries = '';
            commBuSumVar.m_month_cfhistoryforacordpdupto24month = '';
            commBuSumVar.m_messagesuitfiledvecsuitfiledvec = '';
            commBuSumVar.m_others_noofcreditgrantors_noofcreditfacilities = '';
            //commBuSumVar.m_otherprivateforeignbanksoutside_insti_ = '';
            commBuSumVar.m_opencf_PSB_otherprivateforeignbanks_nbfcothers = '';
            commBuSumVar.m_numberofemployeesborrwerdetails = '';
            commBuSumVar.m_noofenquiriesenqoutside_insti_enqinsti_enqtotal = '';
            commBuSumVar.m_noofcreditgrantorscountofcreditfacilities = '';
            commBuSumVar.m_noofcreditfacilitiescountofcreditfacilities = '';
            commBuSumVar.m_nonstdvectotaltotal = '';
            commBuSumVar.m_nonstdvectermloan_workingcapital_forex_nonfunded = '';
            //commBuSumVar.m_nonfundedinsti_outside_insti_ = '';
            commBuSumVar.m_pan_borrweriddetailsborrwerdetails = '';
            commBuSumVar.m_pan_borrweriddetails = '';
            //commBuSumVar.m_overduecftotal_insti_outside_insti_ = '';
            //commBuSumVar.m_outside_totaloutside_insti_ = '';
            commBuSumVar.m_outside_insti_derogatoryinfo_secderogatoryinfo_sec = '';
            commBuSumVar.m_outside_insti_derogatoryinfo_brw = '';
            commBuSumVar.m_outside_insti_creditprofilesummarysec = '';
            commBuSumVar.m_outside_insti_brwdelinquencyreportedon_brw_24M_vec = '';
            commBuSumVar.m_oustandingbal_bycfandassetclasificationsecproductsec = '';
            commBuSumVar.m_oustanding_bal_cf_assetclasificationsec_outside_insti = '';
            commBuSumVar.m_relationshipdisputerelationshipdetailsvec = '';
            commBuSumVar.m_relationshipdetailsvec_productsec = '';
            commBuSumVar.m_relatedpartiesorguarantorsof_brwsecderogatoryinfo_sec = '';
            commBuSumVar.m_rankvecranksec = '';
            commBuSumVar.m_rankValue = tempVar != NULL && tempVar.RankVal__c != NULL ? tempVar.RankVal__c : '';
            commBuSumVar.m_ranksec_productsec = '';
            commBuSumVar.m_rankName = tempVar != NULL && tempVar.RankName__c != NULL ? tempVar.RankName__c : '';
            //commBuSumVar.m_PSBoutside_insti_ = '';
            commBuSumVar.m_pincodeaddressvecaddressvec = '';
            commBuSumVar.m_pan_enqinfo_recenqinfo_rec = '';
            //commBuSumVar.m_suitfilledtotal_insti_outside_insti_ = '';
            commBuSumVar.m_suitfiledvecproductsec = '';
            commBuSumVar.m_subnonstdvec = '';
            commBuSumVar.m_stdvectotaltotal = '';
            commBuSumVar.m_stdvectermloan_workingcapital_forex_nonfunded = '';
            commBuSumVar.m_stateaddressvecaddressvec = '';
            //commBuSumVar.m_settled_total_insti_outside_insti_ = '';
            commBuSumVar.m_salesfigureborrwerdetails = '';
            commBuSumVar.m_reportorderdate_reportheaderrec = '';
            commBuSumVar.m_repaymentfrequencyotherdetails = '';
            commBuSumVar.m_total_termloan_workingcapital_forex_nonfundedTL = '';
            commBuSumVar.m_total_ostotaltotal = '';
            commBuSumVar.m_total_os_PSB_otherprivateforeignbanks_nbfcothers = '';
            commBuSumVar.m_total_noofenquiriesnoofenquiries = '';
            commBuSumVar.m_total_noofcreditgrantors_noofcreditfacilities = '';
            commBuSumVar.m_total_derogatoryinfo_brw_derogatoryinfo_brw = '';
            commBuSumVar.m_total_delinquentcftotal = '';
            commBuSumVar.m_total_delinquent_ostotal = '';
            commBuSumVar.m_tin_enqinfo_rec = '';
            //commBuSumVar.m_termloaninsti_outside_insti_ = '';
            //commBuSumVar.m_workingcapitalinsti_outside_insti_ = '';
            //commBuSumVar.m_wilfuldefaulttotal_insti_outside_insti_ = '';
            commBuSumVar.m_value_sub_loss_tot_dpd = '';
            commBuSumVar.m_totaltotallenderstotal = '';
            commBuSumVar.m_totalopencftotal = '';
            //commBuSumVar.m_totalmessageoutside_insti_ = '';
            commBuSumVar.m_totallenders_PSB_otherprivateforeignbanks_nbfcothers = '';
            //commBuSumVar.m_totalinsti_outside_insti_insti_outside_insti_ = '';
            commBuSumVar.m_totalcf_insti_PSB_otherprivateforeignbanks_nbfcothers = '';
            commBuSumVar.m_total_totalcftotal = '';
            //commBuSumVar.m_writtenofftotal_insti_outside_insti_ = '';
            commBuSumVar.m_yearborrwerDetails = '';
        }
        catch(Exception ex){
            GlobalUtility.logMessage('Error', 'CrifExecuteAPIRequestGenerator', 'commBurSumVar', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            return NULL;
        }
        return commBuSumVar;
    }
    
    //Master Data utility to fetch master values
    public static String masterDataMapUtility(Map<String, List<Map<String, String>>> masterDataMap, String outsideMapKey, String internalMapKey) {
        String emptyStr = '';
        String returnMapValue;
        try {
            if(!masterDataMap.isEmpty() && String.isNotBlank(outsideMapKey) && String.isNotBlank(internalMapKey)) {
                internalMapKey = internalMapKey.toUpperCase();
                if(masterDataMap.containsKey(outsideMapKey) && !masterDataMap.get(outsideMapKey).isEmpty()) {
                    for(Map<String, String> temp : masterDataMap.get(outsideMapKey)) {
                        if(temp.containsKey(internalMapKey) && temp.get(internalMapKey) != NULL) {
                            returnMapValue = temp.get(internalMapKey);
                        }
                    }
                }
            }
            return returnMapValue != NULL ? returnMapValue : emptyStr;
        }
        catch(Exception ex){
            GlobalUtility.logMessage('Error', 'CrifExecuteAPIRequestGenerator', 'masterDataMapUtility', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            return emptyStr;
        }
    }
    
    //cust_fi_report_result result tag
    private static Map<String,Integer> custFiReportResult=new Map<String,Integer>{
        'Negative'=>4,
            'Refer'=>3,
            'Positive'=>2,
            ''=>1
            };
                
                private static Map<String,String> dedupeLoanTypeMap=new Map<String,String>{
                    'Home Loan'=>'HL',
                        'Small Ticket LAP'=>'STL'
                        };            
                            }