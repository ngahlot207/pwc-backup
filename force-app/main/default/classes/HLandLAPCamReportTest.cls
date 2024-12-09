@isTest
public class HLandLAPCamReportTest {
    
    @testSetup
    
    public static void insertTestData() {
        List<Applicant__c> lstApplicant = new List<Applicant__c>();
        List<Case> lstCase = new List<Case>();
        List<ApplAsset__c> lstAppAsset = new List<ApplAsset__c>();
      
        
        TriggerActionFlow.bypass('RT_After_Update_Loan_Application_For_Stage_Change');
        SchMapping__c schme = TestDataFactory.createSchemeMapping(True);
        
        LoanAppl__c ln = new LoanAppl__c();
        ln.Stage__c = 'QDE';
        ln.BrchCode__c = 'HYC';
        ln.Product__c = 'Home Loan';
        ln.Loan_Tenure_Months__c = 120;
        ln.ReqLoanAmt__c=1000000;
        ln.SchemeId__c = schme.Id;
        ln.LoginAcceptDate__c = date.today();
        
        TriggerBase.bypass('LoanAppl__c');
        Test.startTest();
        Insert ln;   
        Test.stopTest();
        TriggerBase.clearBypass('LoanAppl__c');
        
        Applicant__c appl = new  Applicant__c();
        appl.LoanAppln__c = ln.Id;
        appl.MSME__c = 'Test';
        appl.ApplType__c = 'p';
        appl.Constitution__c = 'INDIVIDUAL';
        lstApplicant.add(appl);
        
        Applicant__c appl1 = new Applicant__c();
        appl1.LoanAppln__c = ln.Id;
        appl1.MSME__c = 'Test';
        appl1.ApplType__c = 'C';
        appl1.Constitution__c = 'INDIVIDUAL';
        lstApplicant.add(appl1);
        
        Applicant__c appl2 = new Applicant__c();
        appl2.LoanAppln__c = ln.Id;
        appl2.MSME__c = 'Test';
        appl2.ApplType__c = 'G';
        appl2.Constitution__c = 'INDIVIDUAL';
        lstApplicant.add(appl2);
        
        TriggerBase.bypass('Applicant__c');
        insert lstApplicant;
        TriggerBase.clearBypass('Applicant__c'); 
        
        
        List<APIVer__c> apiList = new List<APIVer__c>();
        
        APIVer__c apiVer1 = new APIVer__c();
        apiVer1.IsLatest__c = true;
        apiVer1.Result_Relevance__c  = 'Accurate Match found';
        apiVer1.LoanAplcn__c = ln.Id;
        apiVer1.Appl__c = appl1.Id;
        apiVer1.RecordTypeId = Schema.getGlobalDescribe()
            .get('APIVer__c')
            .getDescribe()
            .getRecordTypeInfosByName()
            .get('Watchout')
            .getRecordTypeId();
        apiList.add(apiVer1);
        
       
        APIVer__c apiVer2 = new APIVer__c();
        apiVer2.LoanAplcn__c = ln.Id;
        apiVer2.Appl__c = appl1.Id;
        apiVer2.IsLatest__c = true;
        apiVer2.ScrRes__c = 'Match';
        apiVer1.RecordTypeId = Schema.getGlobalDescribe()
            .get('APIVer__c')
            .getDescribe()
            .getRecordTypeInfosByName()
            .get('Screening')
            .getRecordTypeId();
        apiList.add(apiVer2);
        
        TriggerBase.bypass('APIVer__c');
        Insert apiList;
        TriggerBase.clearBypass('APIVer__c'); 
        
        PD__c objPd = new PD__c();
        objPd.Appl__c = appl.Id;
        objPd.CmpltDt__c = system.today();
        objPd.PdTyp__c = 'Physical PD';
        TriggerBase.bypass('PD__c');
        Insert objPd;
        TriggerBase.clearBypass('PD__c');   
        
        Insurance__c Ins = TestDataFactory.InsuranceData(True,ln.Id,appl.Id);
        List<ApplicantEmployment__c> lstAppEmploy =new List<ApplicantEmployment__c>();
        ApplicantEmployment__c appEmploymenent = new ApplicantEmployment__c();
        appEmploymenent.LoanApplicant__c = appl.Id;
        appEmploymenent.Name = 'test';
        appEmploymenent.NatureOfBusinessIndividual__c = 'M';
        appEmploymenent.Is_URC_UAC_available__c = 'YES';
        appEmploymenent.Select_applicability_for_URC_UAC__c = 'UDYAM ASSIST CERTIFICATE (UAC)';
        lstAppEmploy.add(appEmploymenent);
    
        ApplicantEmployment__c appEmploymenent1 = new ApplicantEmployment__c();
        appEmploymenent1.LoanApplicant__c = appl.Id;
        appEmploymenent1.Name = 'test';
        appEmploymenent1.NatureOfBusinessIndividual__c = 'M';
        appEmploymenent1.Is_URC_UAC_available__c = 'YES';
        lstAppEmploy.add(appEmploymenent1);
        TriggerBase.bypass('ApplicantEmployment__c');
        Insert lstAppEmploy;
        TriggerBase.clearBypass('ApplicantEmployment__c');
        
        
        List<BRE__c> breList = new List<BRE__c>();
        BRE__c objBre = new BRE__c();
        objBre.Name = 'Test';
        objBre.isLatest__c = true;
        objBre.LoanAppl__c = ln.Id;
        objBre.EligibilityType__c = 'Application';
        objBre.Applicant__c = appl.id;
        TriggerBase.bypass('BRE__c');
        breList.add(objBre); 
        TriggerBase.clearBypass('BRE__c'); 
        
        BRE__c objBre1 = new BRE__c();
        objBre1.Name = 'Test';
        objBre1.isLatest__c = true;
        objBre1.LoanAppl__c = ln.Id;
        objBre1.EligibilityType__c = 'Applicant';
        objBre1.Applicant__c = appl.id;
        breList.add(objBre1);
        TriggerBase.bypass('BRE__c');
        insert breList;
        TriggerBase.clearBypass('BRE__c');  
        
        btloan__c objBtLoan = new btloan__c();
        objBtLoan.LoanAppl__c = ln.Id;
        objBtLoan.BTFinancier__c = 'Other';
        objBtLoan.SpecifyOtherBTFinancier__c = 'Test';
        TriggerBase.bypass('btloan__c');
        Insert objBtLoan;
        TriggerBase.clearBypass('btloan__c');  
        Id ENPARecordTypeId = Schema.SObjectType.DedupeResponse__c.getRecordTypeInfosByName().get('ENPA').getRecordTypeId();
        
        DedupeResponse__c objDedupe = new DedupeResponse__c();
        objDedupe.LoanAppln__c = ln.Id;
        objDedupe.Applicant__c = appl.Id;
        objDedupe.Lan__c = ln.Id;
        objDedupe.Loantobelinkedwithproposedloan__c = 'Yes';
        objDedupe.SecuritisationStatus__c = 'Y';
        objDedupe.IsLatest__c = true;
        objDedupe.RecordTypeId = ENPARecordTypeId;
        TriggerBase.bypass('DedupeResponse__c');
        Insert objDedupe;
        TriggerBase.clearBypass('DedupeResponse__c');
        
        ApplAsset__c testApplAsset = new ApplAsset__c();
        testApplAsset.Appl__c = appl.Id;
        testApplAsset.PropSubType__c = 'Test';
        testApplAsset.ValuationToBeTakenAheadForCalculation__c = 1233;
        lstAppAsset.add(testApplAsset);
        
        ApplRegltry__c ApplRegltry = TestDataFactory.createApplRegltry(TRUE,appl.Id,ln.Id);
        
        List<BureauRespDtl__c> lstBureu = new List<BureauRespDtl__c>();
        BureauRespDtl__c buresponseDtl = new BureauRespDtl__c();
        buresponseDtl.Applicant__c = appl.Id;
        buresponseDtl.Treatment__c = 'To continue - Obligate';
        buresponseDtl.LoanApplication__c = ln.Id;
        lstBureu.add(buresponseDtl);
        
        
        BureauRespDtl__c objBueru = new BureauRespDtl__c();
        objBueru.EMI__c = 1233;
        objBueru.Treatment__c = 'To continue - Obligate';
        objBueru.Applicant__c = appl.Id;
        objBueru.LoanApplication__c = ln.Id; 
        lstBureu.add(objBueru);
        
        
        TriggerBase.bypass('BureauRespDtl__c');
        Insert lstBureu;
        TriggerBase.clearBypass('BureauRespDtl__c'); 
        
        Bureau__c bure =  new Bureau__c(); 
        bure.IsLatest__c = true;
        bure.LoanApp__c = ln.Id;
        bure.Applicant__c = appl.Id;
        bure.BureauAPI__c = 'Commercial';
        TriggerBase.bypass('Bureau__c');
        Insert bure;
        TriggerBase.clearBypass('Bureau__c'); 
        
        BankBrchMstr__c bankMaster =  TestDataFactory.TestDataBankBranchMaster(TRUE);
        SFDCBANKMaster__c sfdcBnkMstr = TestDataFactory.sfdcBankMasterDetails(TRUE);
        List<ApplBanking__c> lstAppBank = new List<ApplBanking__c>();
        ApplBanking__c applBank = new ApplBanking__c();
        applBank.Appl__c = appl.Id;
        applBank.LoanAppl__c = ln.Id;
        applBank.Type__c = 'Banking Summary';
        applBank.Summary_Type__c = 'Combined Banking (CASA)';
        applBank.SFDCBankMaster__c = sfdcBnkMstr.Id;
        lstAppBank.add(applBank);
        
        
        ApplBanking__c applBank1 = new ApplBanking__c();
        applBank1.Appl__c = appl.Id;
        applBank1.LoanAppl__c = ln.Id;
        applBank1.Type__c = 'Banking Summary';
        applBank1.Summary_Type__c = 'Combined Banking (OD/CC)';
        applBank1.SFDCBankMaster__c = sfdcBnkMstr.Id;
        
        lstAppBank.add(applBank1);
        TriggerBase.bypass('ApplBanking__c');
        Insert lstAppBank; 
        TriggerBase.clearBypass('ApplBanking__c');
        
        List<ApplBankDetail__c> lstAppBankDtl = new List<ApplBankDetail__c>();
        ApplBankDetail__c appBankDtl = new ApplBankDetail__c();
        appBankDtl.ApplBanking__c = applBank.Id;
        appBankDtl.MinBalanceCharges__c = 'Y';
        lstAppBankDtl.add(appBankDtl);
        
        ApplBankDetail__c appBankDtl1 = new ApplBankDetail__c();
        appBankDtl1.ApplBanking__c = applBank1.Id;
        appBankDtl1.MinBalanceCharges__c = 'Y';
        lstAppBankDtl.add(appBankDtl1);
        TriggerBase.bypass('ApplBankDetail__c');
        Insert lstAppBankDtl;
        TriggerBase.clearBypass('ApplBankDetail__c');
        
        List<BRE_Eligibility__c> lstBreElig = new List<BRE_Eligibility__c>();
        
        BRE_Eligibility__c breEligiblity = new BRE_Eligibility__c();
        breEligiblity.BREResponse__c = objBre1.Id;
        breEligiblity.IsLatest__c = true;
        breEligiblity.Type__c = 'Applicant';
        lstBreElig.add(breEligiblity);
      
        
        BRE_Eligibility__c breEligiblity1 = new BRE_Eligibility__c();
        breEligiblity1.BREResponse__c = objBre1.Id;
        breEligiblity1.IsLatest__c = true;
        breEligiblity1.Type__c = 'Applicant';
        breEligiblity1.IncomeProgram__c = 'Business income - Regular Income Program (P&L)';
        lstBreElig.add(breEligiblity1);
      
        
        BRE_Eligibility__c breEligiblity2 = new BRE_Eligibility__c();
        breEligiblity2.BREResponse__c = objBre1.Id;
        breEligiblity2.IsLatest__c = true;
        breEligiblity2.IncomeProgram__c = 'Gross Eligible Salary with Bank Credit';
        breEligiblity2.Type__c = 'Applicant';
        lstBreElig.add(breEligiblity2);
     
        
        BRE_Eligibility__c breEligiblity3 = new BRE_Eligibility__c();
        breEligiblity3.BREResponse__c = objBre1.Id;
        breEligiblity3.IsLatest__c = true;
        breEligiblity3.IncomeProgram__c = 'Net Eligible Salary with Bank Credit';
        breEligiblity3.Type__c = 'Applicant';
        lstBreElig.add(breEligiblity3);
        TriggerBase.bypass('BRE_Eligibility__c');
        Insert lstBreElig;
        TriggerBase.clearBypass('BRE_Eligibility__c'); 
        List<Applicant_Financial__c> lstAppFin = new List<Applicant_Financial__c>();
        //Test.StartTest();
        Id balanceSheetRecordTypeId = Schema.SObjectType.Applicant_Financial__c.getRecordTypeInfosByName().get('Balance Sheet').getRecordTypeId();
        Applicant_Financial__c objApplicantFinacial = new Applicant_Financial__c();
        objApplicantFinacial.RecordTypeId = balanceSheetRecordTypeId;
        objApplicantFinacial.Loan_Applicant__c = appl.id;
        lstAppFin.add(objApplicantFinacial);
      
        
        
        Id profitAndLossRecordTypeId = Schema.SObjectType.Applicant_Financial__c.getRecordTypeInfosByName().get('Profit & Loss').getRecordTypeId();
        Applicant_Financial__c objApplicantFinacial1 = new Applicant_Financial__c();
        objApplicantFinacial1.RecordTypeId = profitAndLossRecordTypeId;
        objApplicantFinacial1.Loan_Applicant__c = appl.id;
        lstAppFin.add(objApplicantFinacial1);
        TriggerBase.bypass('Applicant_Financial__c');
        Insert lstAppFin;
        TriggerBase.clearBypass('Applicant_Financial__c'); 
        
        List<Applicant_Financial_Summary__c> lstAppFinciasummary = new List<Applicant_Financial_Summary__c>();
        
        Applicant_Financial_Summary__c appFinicialSummaryData = new Applicant_Financial_Summary__c();
        appFinicialSummaryData.Adjustable_Remarks__c = 'Test';
        appFinicialSummaryData.Applicant_Financial__c = objApplicantFinacial.Id;
        appFinicialSummaryData.Adjusted_tangible_Netwroth__c = 1233;
        appFinicialSummaryData.LessSix_months__c = 1233;
        appFinicialSummaryData.Greaterthan6__c = 123;
        appFinicialSummaryData.Sundry_creditors__c = 1233;
        appFinicialSummaryData.EBITDA__c = 1233;
        lstAppFinciasummary.add(appFinicialSummaryData);
        
        
        Applicant_Financial_Summary__c appFinicialSummaryData1 = new Applicant_Financial_Summary__c();
        appFinicialSummaryData1.Adjustable_Remarks__c = 'Test';
        appFinicialSummaryData1.Applicant_Financial__c = objApplicantFinacial1.Id;
        lstAppFinciasummary.add(appFinicialSummaryData1);
        TriggerBase.bypass('Applicant_Financial_Summary__c');
        Insert lstAppFinciasummary;
        TriggerBase.clearBypass('Applicant_Financial_Summary__c');  
     
        ApplAsset__c appAsst = new ApplAsset__c();
        appAsst.Prop_Owners__c = 'Test';
        appAsst.Appl__c = appl.Id;
        appAsst.LoanAppln__c = ln.id;
        lstAppAsset.add(appAsst);
     
        Id TechanicalRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Technical').getRecordTypeId();
        Case objCase6 = new Case();
        objCase6.CityId__c = '957';
        objCase6.RecordTypeId = TechanicalRecordTypeId;
        objCase6.IsReinitiatedExpired__c = false;
        objCase6.Loan_Application__c = ln.Id;
        objCase6.ApplAssetId__c = appAsst.Id;
        objCase6.Date_of_Report__c = date.today() + 1;
        objCase6.Status = 'Closed';
        lstCase.add(objCase6);
       
        ApplAsset__c appAsst1 = new ApplAsset__c();
        appAsst1.Appl__c = appl.Id;
        appAsst1.Prop_Owners__c = 'Test';
        appAsst1.LoanAppln__c = ln.id;
        TriggerBase.bypass('ApplAsset__c');
        lstAppAsset.add(appAsst1);
  
        TriggerBase.bypass('ApplAsset__c');
        Insert lstAppAsset;
        TriggerBase.clearBypass('ApplAsset__c');
        
        Id cpvRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('CPVFI').getRecordTypeId();
        Case objCase7 = new Case();
        objCase7.RecordTypeId = cpvRecordTypeId;
        objCase7.IsReinitiatedExpired__c = false;
        objCase7.Loan_Application__c = ln.Id;
        objCase7.ApplAssetId__c = appAsst.Id;
        objCase7.Applicant__c = appl.Id; 
        objCase7.Date_of_Report__c = date.today() + 1;
        objCase7.Status = 'Closed';
        objCase7.ReportResult__c = 'Positive'; 
        objCase7.Address_Type__c = 'Residence Address';
        lstCase.add(objCase7);
        TriggerBase.bypass('Case');
        insert lstCase;
        TriggerBase.clearBypass('Case');
        
        Sanction_Conditions__c  objSanctionCondtion = new Sanction_Conditions__c();
        objSanctionCondtion.Loan_Application__c = ln.Id;
        TriggerBase.bypass('Sanction_Conditions__c');
        Insert objSanctionCondtion; 
        TriggerBase.clearBypass('Sanction_Conditions__c'); 
        TriggerActionFlow.clearBypass('RT_After_Update_Loan_Application_For_Stage_Change');
       
        
        
        
    }
    
    
    
    
    
    @isTest
    Public static void testMethod1(){
        List<LoanAppl__c> lstLoanApp = [SELECT ID FROM LoanAppl__c LIMIT 1];
        
        Test.startTest();
        Test.setCurrentPageReference(Page.HLandLAPCamReport_AppForm); // Replace YourPageName with the actual name of your Visualforce page
        ApexPages.currentPage().getParameters().put('recordId', lstLoanApp[0].Id);
        HLandLAPCamReport obj = new HLandLAPCamReport();
        obj.getBorrowerDetail(lstLoanApp[0].Id);
        obj.TotalVSD = 12.00;
        obj.TotalVSC =  12.00;
        obj.TotalCD = 12.00;
        obj.TotalCC = 12.00;
        obj.TotalIRC = 12.00;
        obj.TotalORC = 12.00;
        obj.TotalSPC = 12.00;
        obj.TotalAverage = 12.00;
        obj.VSDAvg = 12.00;
        obj.VSCAvg =12.00;
        obj.CCAvg = 12.00;
        obj.CDAvg = 12.00;
        obj.IRCAvg = 12.00;
        obj.ORCAvg = 12.00;
        obj.SPCAvg = 12.00;
        obj.TotalVSD1 = 12.00;
        obj.TotalVSC1 = 12.00;
        obj.TotalCD1 = 12.00;
        obj.TotalCC1 = 12.00;
        obj.TotalIRC1 = 12.00;
        obj.TotalORC1 = 12.00;
        obj.TotalSPC1 = 12.00;
        obj.VSDAvg1 = 12.00;
        obj.VSCAvg1 = 12.00;
        obj.CDAvg1 = 12.00;
        obj.IRCAvg1 = 12.00;
        obj.ORCAvg1 = 12.00;
        obj.SPCAvg1 = 12.00;
        obj.TotalAvgAverage = 12.00;
        obj.borrowerName = 'Test';
        obj.CCAvg1 = 12.00;
        obj.ESGNegative = 'Test';
        obj.hunterStatus = 'Test';
        
        HLandLAPCamReport.FinancialRecordWrapper objReport = new HLandLAPCamReport.FinancialRecordWrapper();
        objReport.Id = lstLoanApp[0].Id;
        objReport.turnOverGrowthRate = 12.00;
        objReport.turnOverGrowthRatePercent = '12%';
        objReport.EBIDTA_PBDIT = 12;
        objReport.cashProfit = 123;
        objReport.grossProfitMargin = 123;
        objReport.totalCurrentLiabilities =123;
        objReport.totalDebt =1233;
        objReport.adjustedNetworth = 1233;
        objReport.debtorsCollectionPeriod = 1233;
        objReport.creditorsPayementPeriod = 1234;
        objReport.stockReplenishnentPeriod = 1233;
        objReport.inventryTorunOver = 1233;
        objReport.networkingCapital = 123;
        objReport.currentRatio = 123;
        objReport.quickRatio = 123;
        objReport.interestCoverageRatio = 1233;
        objReport.debtEquityRatio = 123;
        objReport.laverageRatio = 123;
        objReport.closingStock = 123;
        objReport.directExpense = 123;
        
        HLandLAPCamReport.ConsoilidateFinancialWrapper objconsolidate = new HLandLAPCamReport.ConsoilidateFinancialWrapper();
        objconsolidate.currentFinancialYear = objReport;
        objconsolidate.provisionalFinancialYear = objReport;
        objconsolidate.currentFinancialRecord = TRUE;
        objconsolidate.provisionFinancialRecord = TRUE;
        objconsolidate.finacialYear2 = 'Test';
        objconsolidate.finacialYear3 = 'Test';
        objconsolidate.Id = lstLoanApp[0].Id;
        //objReport.
        //
        HLandLAPCamReport.getBankingDetailsSummaryForCASAWrapper  objBank = new HLandLAPCamReport.getBankingDetailsSummaryForCASAWrapper();
        objBank.totalMinBalanceCharges = 1233;
        objBank.averageMinBalanceCharges = 1234;
        
        HLandLAPCamReport.ApplicantEligibility objApplicantElig = new HLandLAPCamReport.ApplicantEligibility();
        objApplicantElig.cashFlowAssedIncome = 1200; 
        objApplicantElig.businessIncome = 1233;
        objApplicantElig.grossSalaryBankCredit = 1200;
        objApplicantElig.netSalaryBankCredit = 1200;
        objApplicantElig.LoanEliOtherCashSalary = 1200;
        objApplicantElig.FinLoanEliCashSalary  = 1200;
        objApplicantElig.MaxFinLoanElideviation = 1233;
        objApplicantElig.LTVApplLnWOInsurance = 1233;
        objApplicantElig.LTVApplLnWtInsurance = 1234;
        objApplicantElig.LTVBsdEliWOIns = 123;
        objApplicantElig.AddLTVBsdEliIns = 1233;
        objApplicantElig.TotlLTVBsdLnEliWIns = 1234;
        objApplicantElig.MaxcoltrlLnEliWDeviation = 1233;
        objApplicantElig.PropAddrs = 'Test';
        objApplicantElig.PropType = '123';
        objApplicantElig.PropSubType = '123';
        objApplicantElig.PropertyUsage = 'Test';
        objApplicantElig.ApproxValue = 123;
        objApplicantElig.LTVApplWDeviation = 123;
        HLandLAPCamReport.ResponseWrapper objResponse = new HLandLAPCamReport.ResponseWrapper();
        objResponse.showcashFlowAssessedIncome = TRUE;
        objResponse.showBusinessIncome = TRUE;
        objResponse.showGrossWithBankCredit = TRUE;
        objResponse.showNetWithBankCredit = TRUE;
        HLandLAPCamReport.getBorrowerVerificationDetailWrapper objVerif = new  HLandLAPCamReport.getBorrowerVerificationDetailWrapper();
        objVerif.watchOutInvestor = 'Test';
        objVerif.trackwizzRecordTypeCheck = 'Test';
        objVerif.gstinStatus = 'Test';
        objVerif.PanStatus = 'Test';
        objVerif.passportStatus = 'Test';
        objVerif.drivingLicence = 'Test';
        
        HLandLAPCamReport.DecisionWrapper objDescsion = new HLandLAPCamReport.DecisionWrapper();
        objDescsion.ApproverComment = 'Test';
        objDescsion.Decision = 'Test';
        objDescsion.DecisionDate = date.today();
        objDescsion.formattedDecisionDate = 'test';
        objDescsion.UserName = 'Test';
        
        HLandLAPCamReport.getCollateralVerificationDetailsWrapper OBJHl = new HLandLAPCamReport.getCollateralVerificationDetailsWrapper();
        OBJHl.totalValuation2 = 1230.00;
        OBJHl.totalValuation3 = 1230.00;
        test.stopTest();
    }
    
    
    
}