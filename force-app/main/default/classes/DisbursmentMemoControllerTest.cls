@isTest
public class DisbursmentMemoControllerTest {
    
    @testSetUp
    static void testSetupDataForValidation(){
        
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);  
        loanApp.SanLoanAmt__c  = 1000000;
        loanApp.InsPremimtobededfromdisamt__c = 'Y';
        loanApp.EffectiveNextIntStartDt__c = Date.today();
        loanApp.DueDay__c = '12';
        update loanApp;

        Applicant__c applicant = new Applicant__c();
        applicant.LoanAppln__c = loanApp.id;
        applicant.MobNumber__c = '1234567890';
        applicant.CustProfile__c = 'SALARIED';
        applicant.Constitution__c = 'ASSOCIATION OF PERSONS';
        applicant.Type_of_Borrower__c = 'Financial';
        applicant.ApplType__c = 'P';
        insert applicant;
        
        ApplAddr__c applAddr = new ApplAddr__c();
        applAddr.State__c = 'Maharashtra';
        applAddr.Pincode__c = '431110';
        applAddr.City__c = 'Pune';
        applAddr.HouseNo__c = '45';
        applAddr.MailAddr__c = True;
        applAddr.Landmark__c = 'Near ZP School';
        applAddr.Applicant__c = applicant.id;
        insert applAddr;
        
        ApplBanking__c appBank =new ApplBanking__c();
        appBank.AC_No__c= '6583467';
        appBank.AccountType__c= 'CURRENT';
        appBank.Bank_Branch__c= 'MARUTI KUNJ ROAD;NEAR KIIT COLLEGE;VILLAGE BHONDS';
        appBank.BankName__c= 'STATE BANK OF INDIA';
        appBank.Bank_City__c= 'GREATER NOIDA';
        appBank.Appl__c= applicant.ID;
        appBank.LoanAppl__c=loanApp.Id;
        insert appBank;
        
        Repayment_Account__c repayData = new Repayment_Account__c();
        repayData.Loan_Application__c = loanApp.Id;
        repayData.Applicant_Banking__c = appBank.Id;
        repayData.Is_Active__c = true;
        insert repayData;
        
        PDC__c pdcData = new PDC__c();
        pdcData.Loan_Application__c = loanApp.Id;
        pdcData.Repayment_Account__c = repayData.Id;
        TriggerBase.bypass('PDC__c');
        insert pdcData;
        TriggerBase.clearbypass('PDC__c');
        ApplAsset__c asser = new ApplAsset__c(
            LoanAppln__c = loanApp.Id,
            Land_Valu__c = 100000,
            Appl__c = applicant.id
        );
        insert asser;
        
        BRE__c bre = new BRE__c(
            LoanAppl__c = loanApp.Id,
            LTVApplWDeviation__c = 80,
            LTVApplLnWOInsurance__c = 75,
            IsLatest__c = true,
            Applicant__c=applicant.id,
            Applicant_Asset__c=asser.id
        );
        insert bre;
        
        Nach__c nachRecord = new Nach__c();
        nachRecord.IsActive__c = true;
        nachRecord.LoanAppl__c = loanApp.Id;
        insert nachRecord;
        
        Disbursement__c disbRecord = new Disbursement__c();
        disbRecord.Total_Disb_Amt__c = 100000;
        //disbRecord.Total_Disbur_Amt__c = 100000;
        disbRecord.Loan_Appli__c = loanApp.Id;
        disbRecord.Date_of_Disbur__c = Date.today();
        disbRecord.DisbrDiscription__c = 'TRANCHE-1';
        insert disbRecord;
        
        Split_Disbur__c splitRecord = new Split_Disbur__c();
        splitRecord.DisburseAmt__c = 100000;
        splitRecord.Split_Cheque_Amt__c = 100000;
        splitRecord.DisburseRela__c = disbRecord.Id;
        splitRecord.Date_of_Disbur__c = Date.today();
        splitRecord.Cheq_DD_Date__c = Date.today();
        insert splitRecord;
        
        DisbursmentMemoController.AddressWrapper wrapper = new DisbursmentMemoController.AddressWrapper();
        wrapper.MailAdd = 'test@example.com';
        wrapper.AddrLine1 = '123 Main St';
        wrapper.AddrLine2 = 'Apt 101';
        wrapper.City = 'Pune';
        wrapper.Pincode = '431110';
        wrapper.State = 'MH';
        wrapper.MobNumber = '9887986988';
        wrapper.HouseNo = '456';
        
        DisbursmentMemoController.caseWrapper caseWrapper = new DisbursmentMemoController.caseWrapper();
        caseWrapper.Property_Visit_Final_Status = 'Test';
        caseWrapper.NameofCredOfficer = 'Manan';
        caseWrapper.PropAddrs = 'Pune';
        
        DisbursmentMemoController.chargeWrapper chargeWrapper = new DisbursmentMemoController.chargeWrapper();
        chargeWrapper.ChargeCodeDesc = 'Test';
        chargeWrapper.ChargeCodeID = '123456';
        chargeWrapper.Amount = 900000;
        chargeWrapper.EffectiveChargeAmount = 90000;
  
        
    }
    
    @isTest
    static void testDisbursmentMemoController(){
        LoanAppl__c loanAppRecord = [Select Id from LoanAppl__c];
        Test.startTest();
        PageReference pageRef = Page.NACHFormFedFina;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('recordId', loanAppRecord.Id);
        DisbursmentMemoController controller = new DisbursmentMemoController();
        Test.stopTest();
        
    }

}