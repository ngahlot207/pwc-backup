@isTest
public class IMDChargesCalculationTest {
	
    static testMethod void testCalculateIMD1() {
        LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
        loan.BrchCode__c = 'MUM';
        loan.ReqLoanAmt__c = 2500000;
        update loan;      
        system.debug('Test Loan Data -- '+ loan);
        
        Applicant__c applicant = TestDataFactory.createSingleApplicant(true,loan.Id);
        applicant.CustProfile__c = 'SALARIED';
        update applicant;
        
        Map<Id, LoanAppl__c> loans = new Map<Id, LoanAppl__c>();
        loans.put(loan.Id, loan);
        
        Map<Id, Applicant__c> appl = new Map<Id, Applicant__c>();
        appl.put(applicant.Id, applicant);
        
        BankBrchMstr__c brchMstr = TestDataFactory.TestDataBankBranchMaster(true);
        brchMstr.BrchCode__c = 'MUM';
        upsert brchMstr;
        LocMstr__c LocMstr = TestDatafactory.LocMaster(true);
        locMstr.State__c = 'MAHARASHTRA';
        upsert locMstr;
        LocBrchJn__c loc = TestDataFactory.locBranchJnData(true, brchMstr.Id, LocMstr.Id);
        IMDMstr__c imdMstr_PF = TestDataFactory.imdMasterData(true);
        imdMstr_PF.State__c = 'MAHARASHTRA';
        imdMstr_PF.Tax__c = 18;
        upsert imdMstr_PF;
        IMDMstr__c imdMstr_IMD = TestDataFactory.imdMasterData(true);
        imdMstr_IMD.ChargeType__c='IMD';
        imdMstr_IMD.State__c = 'MAHARASHTRA';
        imdMstr_IMD.IMDAmt__c = 2000;
        imdMstr_IMD.Tax__c = 18;
        upsert imdMstr_IMD;
        
        LonaApplCharges__c pfCharge = new LonaApplCharges__c(ChargeCodeID__c='35',LoanApplication__c=loan.Id);
        insert pfCharge;
        LonaApplCharges__c cersaiCharge = new LonaApplCharges__c(ChargeCodeID__c='600168',LoanApplication__c=loan.Id);
        insert cersaiCharge;
		
        Test.startTest();
        IMDChargesCalculation.calculateIMD(loans, appl);
        Test.stopTest();
        
        List<LoanAppl__c> loanListFinal = [select id,IMDAmount__c, PFAmount__c  from LoanAppl__c where id=:loan.Id];
        system.assertEquals(2360,loanListFinal[0].IMDAmount__c);
        system.assertEquals(29500,loanListFinal[0].PFAmount__c);
        system.debug('loanListFinal -->'+loanListFinal);
        
    }  
    
    static testMethod void testCalculateIMD3() {
        LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
        loan.BrchCode__c = 'MUM';
        loan.ReqLoanAmt__c = 2500000;
        loan.LeadSource__c = 'Direct';
        update loan;
        
        Applicant__c applicant = TestDataFactory.createSingleApplicant(true,loan.Id);
        applicant.CustProfile__c = 'SALARIED';
        update applicant;
        Map<Id, LoanAppl__c> loans = new Map<Id, LoanAppl__c>();
        loans.put(loan.Id, loan);
        
        Map<Id, Applicant__c> appl = new Map<Id, Applicant__c>();
        appl.put(applicant.Id, applicant);
        
        BankBrchMstr__c brchMstr = TestDataFactory.TestDataBankBranchMaster(true);
        brchMstr.BrchCode__c = 'MUM';
        upsert brchMstr;
        LocMstr__c LocMstr = TestDatafactory.LocMaster(true);
        locMstr.State__c = 'MAHARASHTRA';
        upsert locMstr;
        LocBrchJn__c loc = TestDataFactory.locBranchJnData(true, brchMstr.Id, LocMstr.Id);
        IMDMstr__c imdMstr_PF = TestDataFactory.imdMasterData(true);
        imdMstr_PF.State__c = 'MAHARASHTRA';
        imdMstr_PF.Tax__c = 18;
        imdMstr_PF.LeadSource__c = 'Direct';
        upsert imdMstr_PF;
        IMDMstr__c imdMstr_IMD = TestDataFactory.imdMasterData(true);
        imdMstr_IMD.ChargeType__c='IMD';
        imdMstr_IMD.State__c = 'MAHARASHTRA'; 
        imdMstr_IMD.IMDAmt__c = 2000;
        imdMstr_IMD.Tax__c = 18;
        imdMstr_IMD.LeadSource__c = 'Direct';
        upsert imdMstr_IMD;
        IMDMstr__c imdMstr_PF1 = TestDataFactory.imdMasterData(true);
        imdMstr_PF1.State__c = 'MAHARASHTRA';
        imdMstr_PF1.Tax__c = 18;
        upsert imdMstr_PF1;
        IMDMstr__c imdMstr_IMD1 = TestDataFactory.imdMasterData(true);
        imdMstr_IMD1.ChargeType__c='IMD';
        imdMstr_IMD1.State__c = 'MAHARASHTRA';
        imdMstr_IMD1.IMDAmt__c = 2000;
        imdMstr_IMD1.Tax__c = 18;
        upsert imdMstr_IMD1;  
        
		Test.startTest();
        IMDChargesCalculation.calculateIMD(loans, appl); 
        Test.stopTest();
        
        List<LoanAppl__c> loanListFinal = [select id,IMDAmount__c, PFAmount__c  from LoanAppl__c where id=:loan.Id]; 
        system.assertEquals(2360,loanListFinal[0].IMDAmount__c);
        system.assertEquals(29500,loanListFinal[0].PFAmount__c);
        system.debug('loanListFinal3 -->'+loanListFinal);
        
    }
    
    static testMethod void testCalculateIMD4() { 
        
        PromoMapping__c proData = TestDataFactory.proMapData(true);
        
        LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
        loan.BrchCode__c = 'MUM';
        loan.ReqLoanAmt__c = 2500000;
        loan.LeadSource__c = 'Direct';
        loan.PromotionId__c = proData.Id;
        update loan;
        
        Applicant__c applicant = TestDataFactory.createSingleApplicant(true,loan.Id);
        applicant.CustProfile__c = 'SALARIED';
        update applicant;
        
        Map<Id, LoanAppl__c> loans = new Map<Id, LoanAppl__c>();
        loans.put(loan.Id, loan);
        
        Map<Id, Applicant__c> appl = new Map<Id, Applicant__c>();
        appl.put(applicant.Id, applicant);
        
        BankBrchMstr__c brchMstr = TestDataFactory.TestDataBankBranchMaster(true);
        brchMstr.BrchCode__c = 'MUM';
        upsert brchMstr;
        LocMstr__c LocMstr = TestDatafactory.LocMaster(true);
        locMstr.State__c = 'MAHARASHTRA';
        upsert locMstr;
        LocBrchJn__c loc = TestDataFactory.locBranchJnData(true, brchMstr.Id, LocMstr.Id);
        IMDMstr__c imdMstr_PF = TestDataFactory.imdMasterData(true);
        imdMstr_PF.State__c = 'MAHARASHTRA';
        imdMstr_PF.Tax__c = 18;
        imdMstr_PF.LeadSource__c = 'Direct';
        upsert imdMstr_PF;
        IMDMstr__c imdMstr_IMD = TestDataFactory.imdMasterData(true);
        imdMstr_IMD.ChargeType__c='IMD';
        imdMstr_IMD.State__c = 'MAHARASHTRA'; 
        imdMstr_IMD.IMDAmt__c = 2000;
        imdMstr_IMD.Tax__c = 18;
        imdMstr_IMD.LeadSource__c = 'Direct';
        upsert imdMstr_IMD;
        IMDMstr__c imdMstr_PF1 = TestDataFactory.imdMasterData(true);
        imdMstr_PF1.State__c = 'MAHARASHTRA';
        imdMstr_PF1.Tax__c = 18;
        imdMstr_PF1.LeadSource__c = 'Direct';
        imdMstr_PF1.PromoCode__c = proData.Id;
        upsert imdMstr_PF1;
        IMDMstr__c imdMstr_IMD1 = TestDataFactory.imdMasterData(true);
        imdMstr_IMD1.ChargeType__c='IMD';
        imdMstr_IMD1.State__c = 'MAHARASHTRA';
        imdMstr_IMD1.IMDAmt__c = 2000;
        imdMstr_IMD1.Tax__c = 18;
        imdMstr_IMD1.LeadSource__c = 'Direct';
        imdMstr_IMD1.PromoCode__c = proData.Id;
        upsert imdMstr_IMD1;
        
		Test.startTest();
        IMDChargesCalculation.calculateIMD(loans, appl);
        Test.stopTest();
        
        List<LoanAppl__c> loanListFinal = [select id,IMDAmount__c, PFAmount__c  from LoanAppl__c where id=:loan.Id]; 
        system.assertEquals(2360,loanListFinal[0].IMDAmount__c);
        system.assertEquals(29500,loanListFinal[0].PFAmount__c);
        system.debug('loanListFinal4 -->'+loanListFinal);
        
    }
    
    static testMethod void testCalculateIMD5() {
        
        PromoMapping__c proData = TestDataFactory.proMapData(true);
        LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
        loan.BrchCode__c = 'MUM';
        loan.ReqLoanAmt__c = 2500000;
        loan.LeadSource__c = 'Direct';
        loan.PromotionId__c = proData.Id;
        update loan;
        
        Applicant__c applicant = TestDataFactory.createSingleApplicant(true,loan.Id);
        applicant.CustProfile__c = 'SALARIED';
        update applicant;
        
        Map<Id, LoanAppl__c> loans = new Map<Id, LoanAppl__c>();
        loans.put(loan.Id, loan);
        
        Map<Id, Applicant__c> appl = new Map<Id, Applicant__c>();
        appl.put(applicant.Id, applicant);
        
        BankBrchMstr__c brchMstr = TestDataFactory.TestDataBankBranchMaster(true);
        brchMstr.BrchCode__c = 'MUM';
        upsert brchMstr;
        LocMstr__c LocMstr = TestDatafactory.LocMaster(true);
        locMstr.State__c = 'MAHARASHTRA';
        upsert locMstr;
        LocBrchJn__c loc = TestDataFactory.locBranchJnData(true, brchMstr.Id, LocMstr.Id);
        IMDMstr__c imdMstr_PF = TestDataFactory.imdMasterData(true);
        imdMstr_PF.State__c = 'MAHARASHTRA';
        imdMstr_PF.Tax__c = 18;
        imdMstr_PF.LeadSource__c = 'Direct';
        upsert imdMstr_PF;
        IMDMstr__c imdMstr_IMD = TestDataFactory.imdMasterData(true);
        imdMstr_IMD.ChargeType__c='IMD';
        imdMstr_IMD.State__c = 'MAHARASHTRA'; 
        imdMstr_IMD.IMDAmt__c = 2000;
        imdMstr_IMD.Tax__c = 18;
        imdMstr_IMD.LeadSource__c = 'Direct';
        upsert imdMstr_IMD;
        IMDMstr__c imdMstr_PF1 = TestDataFactory.imdMasterData(true);
        imdMstr_PF1.State__c = 'MAHARASHTRA';
        imdMstr_PF1.Tax__c = 18;
        imdMstr_PF1.LeadSource__c = 'Direct';
        imdMstr_PF1.PromoCode__c = proData.Id;
        upsert imdMstr_PF1;
        IMDMstr__c imdMstr_IMD1 = TestDataFactory.imdMasterData(true);
        imdMstr_IMD1.ChargeType__c='IMD';
        imdMstr_IMD1.State__c = 'MAHARASHTRA';
        imdMstr_IMD1.IMDAmt__c = 2000;
        imdMstr_IMD1.Tax__c = 18;
        imdMstr_IMD1.LeadSource__c = 'Direct';
        imdMstr_IMD1.PromoCode__c = proData.Id;
        upsert imdMstr_IMD1;
        IMDMstr__c imdMstr_PF2 = TestDataFactory.imdMasterData(true);
        imdMstr_PF2.State__c = 'MAHARASHTRA';
        imdMstr_PF2.Tax__c = 18;
        imdMstr_PF2.LeadSource__c = 'Direct';
        imdMstr_PF2.PromoCode__c = proData.Id;
        imdMstr_PF2.MinLoanAmt__c = 50000;
        upsert imdMstr_PF2;
        IMDMstr__c imdMstr_IMD2 = TestDataFactory.imdMasterData(true);
        imdMstr_IMD2.ChargeType__c='IMD';
        imdMstr_IMD2.State__c = 'MAHARASHTRA';
        imdMstr_IMD2.IMDAmt__c = 2000;
        imdMstr_IMD2.Tax__c = 18;
        imdMstr_IMD2.LeadSource__c = 'Direct';
        imdMstr_IMD2.PromoCode__c = proData.Id;
        imdMstr_IMD2.MinLoanAmt__c = 50000;
        upsert imdMstr_IMD2;
        
		Test.startTest();
        IMDChargesCalculation.calculateIMD(loans, appl);
        Test.stopTest();
        
        List<LoanAppl__c> loanListFinal = [select id,IMDAmount__c, PFAmount__c  from LoanAppl__c where id=:loan.Id]; 
        system.assertEquals(2360,loanListFinal[0].IMDAmount__c);
        system.assertEquals(29500,loanListFinal[0].PFAmount__c);
        system.debug('loanListFinal5 -->'+loanListFinal);
        
    }
    
    static testMethod void testCalculateIMD6() {
        PromoMapping__c proData = TestDataFactory.proMapData(true);
        LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
        loan.BrchCode__c = 'MUM';
        loan.ReqLoanAmt__c = 2500000;
        loan.LeadSource__c = 'Direct';
        loan.AssessedIncAppln__c = true;
        loan.PromotionId__c = proData.Id;
        update loan;
        
        Applicant__c applicant = TestDataFactory.createSingleApplicant(true,loan.Id);
        applicant.CustProfile__c = 'SALARIED'; 
        update applicant;
        
        Map<Id, LoanAppl__c> loans = new Map<Id, LoanAppl__c>();
        loans.put(loan.Id, loan);
        
        Map<Id, Applicant__c> appl = new Map<Id, Applicant__c>();
        appl.put(applicant.Id, applicant);
        
        BankBrchMstr__c brchMstr = TestDataFactory.TestDataBankBranchMaster(true);
        brchMstr.BrchCode__c = 'MUM';
        upsert brchMstr;
        LocMstr__c LocMstr = TestDatafactory.LocMaster(true);
        locMstr.State__c = 'MAHARASHTRA';
        upsert locMstr;
        LocBrchJn__c loc = TestDataFactory.locBranchJnData(true, brchMstr.Id, LocMstr.Id);
        IMDMstr__c imdMstr_PF = TestDataFactory.imdMasterData(true);
        imdMstr_PF.State__c = 'MAHARASHTRA';
        imdMstr_PF.Tax__c = 18;
        imdMstr_PF.LeadSource__c = 'Direct';
        upsert imdMstr_PF;
        IMDMstr__c imdMstr_IMD = TestDataFactory.imdMasterData(true);
        imdMstr_IMD.ChargeType__c='IMD';
        imdMstr_IMD.State__c = 'MAHARASHTRA'; 
        imdMstr_IMD.IMDAmt__c = 2000;
        imdMstr_IMD.Tax__c = 18;
        imdMstr_IMD.LeadSource__c = 'Direct';
        upsert imdMstr_IMD;
        IMDMstr__c imdMstr_PF1 = TestDataFactory.imdMasterData(true);
        imdMstr_PF1.State__c = 'MAHARASHTRA';
        imdMstr_PF1.Tax__c = 18;
        imdMstr_PF1.LeadSource__c = 'Direct';
        imdMstr_PF1.PromoCode__c = proData.Id;
        upsert imdMstr_PF1;
        IMDMstr__c imdMstr_IMD1 = TestDataFactory.imdMasterData(true);
        imdMstr_IMD1.ChargeType__c='IMD';
        imdMstr_IMD1.State__c = 'MAHARASHTRA';
        imdMstr_IMD1.IMDAmt__c = 2000;
        imdMstr_IMD1.Tax__c = 18;
        imdMstr_IMD1.LeadSource__c = 'Direct';
        imdMstr_IMD1.PromoCode__c = proData.Id;
        upsert imdMstr_IMD1;
        IMDMstr__c imdMstr_PF2 = TestDataFactory.imdMasterData(true);
        imdMstr_PF2.State__c = 'MAHARASHTRA';
        imdMstr_PF2.Tax__c = 18;
        imdMstr_PF2.LeadSource__c = 'Direct';
        imdMstr_PF2.PromoCode__c = proData.Id;
        imdMstr_PF2.MinLoanAmt__c = 50000;
        upsert imdMstr_PF2;
        IMDMstr__c imdMstr_IMD2 = TestDataFactory.imdMasterData(true);
        imdMstr_IMD2.ChargeType__c='IMD';
        imdMstr_IMD2.State__c = 'MAHARASHTRA';
        imdMstr_IMD2.IMDAmt__c = 2000;
        imdMstr_IMD2.Tax__c = 18;
        imdMstr_IMD2.LeadSource__c = 'Direct';
        imdMstr_IMD2.PromoCode__c = proData.Id;
        imdMstr_IMD2.MinLoanAmt__c = 50000;
        upsert imdMstr_IMD2;
        IMDMstr__c imdMstr_PF3 = TestDataFactory.imdMasterData(true);
        imdMstr_PF3.State__c = 'MAHARASHTRA';
        imdMstr_PF3.Tax__c = 18;
        imdMstr_PF3.LeadSource__c = 'Direct';
        imdMstr_PF3.PromoCode__c = proData.Id;
        imdMstr_PF3.MinLoanAmt__c = 50000;
        imdMstr_PF3.Customer_Profile__c = 'SALARIED';
        upsert imdMstr_PF3;
        IMDMstr__c imdMstr_IMD3 = TestDataFactory.imdMasterData(true);
        imdMstr_IMD3.ChargeType__c='IMD';
        imdMstr_IMD3.State__c = 'MAHARASHTRA';
        imdMstr_IMD3.IMDAmt__c = 2000;
        imdMstr_IMD3.Tax__c = 18;
        imdMstr_IMD3.LeadSource__c = 'Direct';
        imdMstr_IMD3.PromoCode__c = proData.Id;
        imdMstr_IMD3.MinLoanAmt__c = 50000;
        imdMstr_IMD3.Customer_Profile__c = 'SALARIED';
        upsert imdMstr_IMD3;
        
		Test.startTest();
        IMDChargesCalculation.calculateIMD(loans, appl); 
        Test.stopTest();
        
        List<LoanAppl__c> loanListFinal = [select id,IMDAmount__c, PFAmount__c  from LoanAppl__c where id=:loan.Id]; 
        system.assertEquals(2360,loanListFinal[0].IMDAmount__c);
        system.assertEquals(29500,loanListFinal[0].PFAmount__c);
        system.debug('loanListFinal6 -->'+loanListFinal);
        
    }
}