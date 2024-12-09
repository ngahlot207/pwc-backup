@isTest
public class CrifExecuteAPIRequestGeneratorTest {
	@isTest
    public static void testGenerate1() {
        List<IntgMsg__c> testReqList = new List<IntgMsg__c>();
        
        //Loan Application Data
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        loanApp.BrchCode__c = 'MUM';
        loanApp.BrchName__c = 'MUMBAI';
        loanApp.LeadSource__c = 'Direct';
        loanApp.ProductSubType__c = 'LAP Residential';
        loanApp.Product__c = 'Small Ticket LAP';
		loanApp.ReqLoanAmt__c = 1200000;
		loanApp.ReqTenInMonths__c = 120;
		loanApp.Stage__c = 'Post Sanction';
		loanApp.SubStage__c = 'Data Entry';
		//loanApp.ApplicantName__c = 'Test Name';
		//loanApp.City__c = 'VARANASI';
		//loanApp.CustomerName__c = 'Test Name';
		loanApp.LoanApplSubDt__c = Date.newInstance(2024, 02, 05);
		loanApp.LoginAcceptDate__c = Date.newInstance(2024, 02, 05);
		loanApp.EffectiveROI__c = 16.25;
		loanApp.LeadROI__c = 2;
		loanApp.SanLoanAmt__c = 1200000;
		loanApp.InsAmt__c = 36000;
		//loanApp.FirstEMIDate__c = '2024-03-07';
		loanApp.BranchTier__c = 'Tier 1';
		loanApp.Loan_Tenure_Months__c = 120;
		loanApp.RevisedROI__c = 16;
		loanApp.RevisedPF__c = 2;
		loanApp.Is_there_TypeA_devia__c = 'YES';
		loanApp.Is_there_TypeB_devia__c	 = 'NO';
        loanApp.Add_Another_Loan__c = 'Yes';
        UPDATE loanApp;
        
        //BT Loan Data
        BTLoan__c btVar = new BTLoan__c();
		btVar.BTFinancierStatus__c = 'P';
		btVar.BTOriginalLoanAmt__c = 2000;
		btVar.BTLoanOutstandingValue__c = 2000;
		btVar.LoanAppl__c = loanApp.Id;
		INSERT btVar;
		
        //Insurance Data
		Insurance__c ins = new Insurance__c();
		ins.InsType__c = 'Life Insurance';
		ins.IsActive__c = TRUE;
		ins.LoanAppln__c = loanApp.Id;
		INSERT ins;
		
        //Case Data
        List<Case> csList = new List<Case>();
		Case cs1 = new Case();
		//cs.RecordType.Name = 'RCU';
		cs1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('RCU').getRecordTypeId();
		cs1.ReportResult__c = 'Positive';
		cs1.Loan_Application__c = loanApp.Id;
        csList.add(cs1);
        
        //Repayment Account Data
        Repayment_Account__c ra = new Repayment_Account__c();
        ra.Loan_Application__c = loanApp.Id;
        INSERT ra;
		
        //Repayment Account Verification Data
		RepayAccVerify__c rcv = new RepayAccVerify__c();
		rcv.MatchwithAccHolderName__c = 'Yes';
		rcv.LoanAppl__c = loanApp.Id;
        rcv.RepayAcc__c = ra.Id;
		INSERT rcv;
		
        //Applicant Regulatory Data
		ApplRegltry__c ar = new ApplRegltry__c();
		ar.FundInESGPol__c = 'Fundable';
		ar.CharDiscrmtn__c = 'Yes';
		ar.LoanAppln__c = loanApp.Id;
		ar.DealngIndstry__c = 'Hazardous chemicals';
		ar.IsBorowrOrRelFFDir__c = 'Yes';
		ar.FFDirRelIntrstAsPart__c = 'Yes';
		ar.FFDirRelIntrstAsSH__c = 'No';
		INSERT ar;
		
        //Applicant IMD Data
		ApplIMD__c applyIMD = new ApplIMD__c();
		applyIMD.CheqBounceReason__c = 'test';
		applyIMD.LoanAppln__c = loanApp.Id;
		INSERT applyIMD;
		
        //Applicant Data
        Applicant__c appli =  TestDataFactory.createSingleApplicant(TRUE, loanApp.Id);
        appli.LatestyearforwhichITRisavailable__c = 'test';
        appli.Type_of_Borrower__c = 'Financial';
        UPDATE appli;
        //ApplAddr__c applyAddr =  TestDataFactory.applAddData(TRUE, loanApp.Id, appli.Id);
        
        Case cs2 = new Case();
		cs2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('CPVFI').getRecordTypeId();
		cs2.ReportResult__c = 'Positive';
		cs2.Loan_Application__c = loanApp.Id;
        cs2.Applicant__c = appli.Id;
        cs2.Negative_Area__c = 'Yes';
        cs2.Negative_Database_Result__c = 'Match Found';
        cs2.Neighbour_Reference_Check__c = 'Positive';
        //cs2.Negative_Report_reason__c = 'OGL';
        csList.add(cs2);
		INSERT csList;
        
        List<DedupeResponse__c> drList = new List<DedupeResponse__c>();
        DedupeResponse__c dr1 = new DedupeResponse__c();
        dr1.RecordTypeId = Schema.SObjectType.DedupeResponse__c.getRecordTypeInfosByName().get('DedupeMatchCr').getRecordTypeId();
        dr1.Lan__c = loanApp.Id;
        dr1.Applicant__c = appli.Id;
        drList.add(dr1);
        
        INSERT drList;
        
        //Hunter Verification Data
		HunterVer__c hv = new HunterVer__c();
		hv.HunMatchSta__c = 'No Match';
		hv.HunStaWheMatFound__c = 'test';
		hv.IsLatest__c = TRUE;
		hv.LoanAplcn__c = loanApp.Id;
        hv.Appl__c = appli.Id;
		INSERT hv;
		
        //Applicant Asset Data
        ApplAsset__c aa =  TestDataFactory.ApplAsset(TRUE, loanApp.Id, appli.Id);
		aa.Per_Sq_Ft_rate_Built_up_area__c = 0;
		aa.Appr_Cost_of_Const__c = 0;
		aa.AveNetMnthlyRentalAsPerBankCredit__c = 0;
		aa.AllPropSbtypNrmsMet__c = FALSE;
		aa.PropIdentified__c = 'Yes';
		aa.DistFrmSourceBrch__c = 10;
		aa.DistFrmNearBrch__c = 10;
		aa.PropType__c = 'RESIDENTIAL';
		aa.Pin_Code__c = '221001';
		aa.NatureofProp__c = 'Row House';
		aa.Land_Area__c = 1600;
		aa.Stamp_Duty__c = 0;
		aa.Regi_Cost__c = 0;
		aa.Approx_Age_of_Prop__c = 10;
		aa.Prop_Bui_up_ar__c = 1600;
		aa.Land_Valu__c = 1600000;
		//aa.Total_Prop_Cost__c = 2000;
		aa.Property_Usage__c = 'SELF- OCCUPIED';
		aa.No_of_Tenants__c = 5;
		aa.Per_Sq_Ft_rate_Land_area__c = 0;
		aa.Resi_Age__c = 10;
		aa.Built_up_area_Valu__c = 1200000;
		aa.Is_the_property_Multi_Tenanted__c = 'Yes';
		aa.Improvement_construction_estimate_docum__c = 'Yes';
		aa.Negative_Caution_Area__c = 'No';
		aa.Property_Carpet_area_Sq_Ft__c = 1600;
		aa.Agrem_Value__c = 0;
		aa.Total_estimate_as_per_architect_agreemen__c = 0;
		aa.RecmndByTechVal__c = 0;
		aa.Stage_of_Construction__c = 100;
		aa.Per_Sq_Ft_Approved_Cost_of_Construction__c = 0;
		aa.ChangeRequiredInValuationAsPerPolicyNorm__c = 'NO';
		aa.City__c = 'VARANASI';
		aa.PropCat__c = 'CAT A';
		aa.Prop_Owners__c = 'SATISH SINGH';
		aa.Is_the_title_clear_markateble__c = 'Yes';
		UPDATE aa;
		
        //Applicant Banking Data
        ApplBanking__c ab = new ApplBanking__c();
        ab.LoanAppl__c = loanApp.Id;
        ab.Appl__c = appli.Id;
        INSERT ab;
        
        //Applicant GST Data
        ApplGST__c ag = new ApplGST__c();
        ag.Applicant__c = appli.Id;
        ag.ApplAsset__c = aa.Id;
        INSERT ag;
        
        //Applicant Address Data
        List<ApplAddr__c> aaddList = new List<ApplAddr__c>();
        ApplAddr__c aadd1 = new ApplAddr__c();
        aadd1.Applicant__c = appli.Id;
        aadd1.LoanAppl__c = loanApp.Id;
        aadd1.AddrTyp__c = 'Permanent Address';
        aaddList.add(aadd1);
        
        ApplAddr__c aadd2 = new ApplAddr__c();
        aadd2.Applicant__c = appli.Id;
        aadd2.LoanAppl__c = loanApp.Id;
        aadd2.AddrTyp__c = 'Office Address';
        aaddList.add(aadd2);
        
        INSERT aaddList; 
        
        //Applicant Financial Data
        List<Applicant_Financial__c> afList = new List<Applicant_Financial__c>();
        
        Applicant_Financial__c af1 = new Applicant_Financial__c();
        af1.Loan_Applicant__c = appli.Id;
        
        af1.RecordTypeId = Schema.SObjectType.Applicant_Financial__c.getRecordTypeInfosByName().get('Balance Sheet').getRecordTypeId();
        afList.add(af1);
        
        Applicant_Financial__c af2 = new Applicant_Financial__c();
        af2.Loan_Applicant__c = appli.Id;
        af2.RecordTypeId = Schema.SObjectType.Applicant_Financial__c.getRecordTypeInfosByName().get('Profit & Loss').getRecordTypeId();
        afList.add(af2);
        
        INSERT afList;
        
        //Applicant Financial Summary Data
        List<Applicant_Financial_Summary__c> afsList = new List<Applicant_Financial_Summary__c>();
        for(Applicant_Financial__c af : afList) {
            Applicant_Financial_Summary__c afs = new Applicant_Financial_Summary__c();
            afs.Applicant_Financial__c = af.Id;
            afs.Financial_Year__c = '2022-2023';
            afsList.add(afs);
        }
        for(Applicant_Financial__c af : afList) {
            Applicant_Financial_Summary__c afs = new Applicant_Financial_Summary__c();
            afs.Applicant_Financial__c = af.Id;
            if(af.RecordTypeId == Schema.SObjectType.Applicant_Financial__c.getRecordTypeInfosByName().get('Profit & Loss').getRecordTypeId()) {
                afs.Financial_Year__c = '2021';
            }
            else {
                afs.Financial_Year__c = '2022';
            }
            afsList.add(afs);
        }
        INSERT afsList;
        
        //Bureau Response Data
        List<Bureau__c> buList = new List<Bureau__c>();
        
        Bureau__c bu1 = new Bureau__c();
        bu1.Applicant__c = appli.Id;
        bu1.LoanApp__c = loanApp.Id;
        bu1.IsLatest__c = TRUE;
        bu1.BureauAPI__c = 'Consumer';
        buList.add(bu1);
        
        Bureau__c bu2 = new Bureau__c();
        bu2.Applicant__c = appli.Id;
        bu2.LoanApp__c = loanApp.Id;
        bu2.IsLatest__c = TRUE;
        bu2.BureauAPI__c = 'Commercial';
        buList.add(bu2);
        
        INSERT buList;
        
        BureauEnquiry__c be = new BureauEnquiry__c();
        List<BureauRespDtl__c> brd = new List<BureauRespDtl__c>();
        BureauDemography__c bud = new BureauDemography__c();
        BureauHeader__c bh = new BureauHeader__c();
        Rank__c rnk = new Rank__c();
        for(Bureau__c bu : buList) {
            if(bu.BureauAPI__c == 'Consumer') {
                be.Bureau__c = bu.Id;
                be.Applicant__c = appli.Id;
                be.IsLatest__c = TRUE;
                INSERT be;
                
                BureauRespDtl__c brd1 = new BureauRespDtl__c();
                brd1.Applicant__c = appli.Id;
                brd1.Bureau__c = bu.Id;
                brd1.Source__c ='Manual';
                brd1.LoanApplication__c = loanApp.Id; 
                brd1.RecordTypeId = Schema.SObjectType.BureauRespDtl__c.getRecordTypeInfosByName().get('Consumer Obligation').getRecordTypeId();
                brd.add(brd1);
                
                BureauRespDtl__c brd2 = new BureauRespDtl__c();
				brd2.Applicant__c = appli.Id;
                brd2.Bureau__c = bu.Id;
                brd2.IsLatest__c = TRUE;
                brd2.LoanApplication__c = loanApp.Id;
                brd2.Source__c ='Consumer CIBIL';
                brd2.RecordTypeId = Schema.SObjectType.BureauRespDtl__c.getRecordTypeInfosByName().get('Consumer Obligation').getRecordTypeId();
                brd.add(brd2);
                
                INSERT brd;
                
                bud.Applicant__c = appli.Id;
                bud.Bureau__c = bu.Id;
                bud.IsLatest__c = TRUE;
                INSERT bud;
                
                bh.Bureau__c = bu.Id;
                INSERT bh;
            }
            if(bu.BureauAPI__c == 'Commercial') {
                rnk.BureauResponse__c = bu.Id;
                INSERT rnk;
            }
        }
        
        //Applicant Income Data
        List<Applicant_Income__c> aiList = new List<Applicant_Income__c>();
        Applicant_Income__c ai1 = new Applicant_Income__c();
		ai1.RecordTypeId = Schema.SObjectType.Applicant_Income__c.getRecordTypeInfosByName().get('Bank Credit Salary').getRecordTypeId();
		ai1.Applicant__c = appli.Id;
		ai1.LTA_Monthly__c = 1000;
		ai1.Performance_Bonus_Monthly__c = 1000;
		ai1.Net_Salary__c = 1000;
		ai1.Gross_Salary_Rs__c = 1000;
		ai1.Variable_Component__c = 1000;
		ai1.Taxes__c = 1000;
		ai1.Other_Deductions__c = 1000;
		aiList.add(ai1);
		
		Applicant_Income__c ai2 = new Applicant_Income__c();
		ai2.RecordTypeId = Schema.SObjectType.Applicant_Income__c.getRecordTypeInfosByName().get('Rental wBanking').getRecordTypeId();
		ai2.Applicant__c = appli.Id;
		ai2.Month1_Rental_Credited_Amount__c = 1000;
		aiList.add(ai2);
		
		//INSERT aiList;
        
        List<DocDtl__c> ddList = new List<DocDtl__c>();
        DocDtl__c dd1 = new DocDtl__c();
        dd1.Appl__c = appli.Id;
		dd1.ApplAsset__c = aa.Id;
		dd1.LAN__c = loanApp.Id;
		dd1.DocCatgry__c = 'Income Documents';
		dd1.DocSubTyp__c = 'Last 3 month\'s';
		ddList.add(dd1);
		
		DocDtl__c dd2 = new DocDtl__c();
        dd2.Appl__c = appli.Id;
		dd2.ApplAsset__c = aa.Id;
		dd2.LAN__c = loanApp.Id;
		dd2.DocCatgry__c = 'Income Documents';
		dd2.DocSubTyp__c = 'Latest Year Form 16';
		ddList.add(dd2);
		
		DocDtl__c dd3 = new DocDtl__c();
        dd3.Appl__c = appli.Id;
		dd3.ApplAsset__c = aa.Id;
		dd3.LAN__c = loanApp.Id;
		dd3.DocCatgry__c = 'Income Documents';
		dd3.DocSubTyp__c = 'Previous Year Audit report along with schedules';
		ddList.add(dd3);
		
		DocDtl__c dd4 = new DocDtl__c();
        dd4.Appl__c = appli.Id;
		dd4.ApplAsset__c = aa.Id;
		dd4.LAN__c = loanApp.Id;
		dd4.DocCatgry__c = 'Income Documents';
		dd4.DocSubTyp__c = 'Latest Year Audit report along with schedules';
		ddList.add(dd4);
		
		DocDtl__c dd5 = new DocDtl__c();
        dd5.Appl__c = appli.Id;
		dd5.ApplAsset__c = aa.Id;
		dd5.LAN__c = loanApp.Id;
		dd5.DocCatgry__c = 'Income Documents';
		dd5.DocSubTyp__c = 'Latest year ITR & computation';
		ddList.add(dd5);
		
		DocDtl__c dd6 = new DocDtl__c();
        dd6.Appl__c = appli.Id;
		dd6.ApplAsset__c = aa.Id;
		dd6.LAN__c = loanApp.Id;
		dd6.DocCatgry__c = 'Income Documents';
		dd6.DocSubTyp__c = 'Previous year ITR & computation';
		ddList.add(dd6);
		
		DocDtl__c dd7 = new DocDtl__c();
        dd7.Appl__c = appli.Id;
		dd7.ApplAsset__c = aa.Id;
		dd7.LAN__c = loanApp.Id;
		dd7.DocCatgry__c = 'KYC Documents';
		dd7.DocSubTyp__c = 'Udyam Registration Certificate';
		ddList.add(dd7);
		
		INSERT ddList;
        
        // Create a test response
        IntgMsg__c testReq = new IntgMsg__c();
        testReq.Name = 'Crif Execute API';
        testReq.RefId__c = loanApp.Id;
        testReq.RefObj__c = 'LoanAppl__c';
        testReq.Status__c = 'New';
        testReq.Svc__c = 'Crif Execute API';
        testReq.BU__c = 'HL / STL';
		testReqList.add(testReq);
        
        // Insert the test response list
        insert testReqList;
		
		// Call the generate method with the test response
        Test.startTest();
        CrifExecuteAPIRequestGenerator breVar = new CrifExecuteAPIRequestGenerator();
        breVar.generate(testReqList, '', '');
        Test.stopTest();
    }
}