@isTest
public class UWApprovalValidationTest {
    
    @testSetup
    static void testValidateData() {
    }
    
    @isTest
    static void uwApprvalValnTestMethod() {
        SchMapping__c schMap = new SchMapping__c();
        schMap.SchemeDesc__c = 'BT';
        schMap.IsCostApplicable__c = true;
        insert schMap;
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        loanApp.IsSellerListDocLODAvl__c = 'N';
        loanApp.IsSellerBTLoanForeclosureAmt__c = 'N';
        loanApp.DocAsPerLegalReportMatches__c = 'N';
        loanApp.SaleDeedBetnBuyerBorr__c = 'N';
        loanApp.OwnContriPaid__c = 'N';
        loanApp.LetterFomSellerBTFinancier__c = 'N';
        loanApp.ChequeForAmtEquiBTAmt__c = 'N';
        loanApp.SellerVerificationKYCSellerTaken__c = 'N';
        loanApp.SellerVerCredTeleChk__c = 'N';
        loanApp.AllSellerBTNormMet__c = 'N';
        loanApp.Product__c = 'Home Loan';
        loanApp.ProductSubType__c = 'Commercial Property Purchase';
        loanApp.SchemeId__c = schMap.id;
        loanApp.ProductSubType__c = 'Seller BT - 100% Ready Property';
        update loanApp;
        Applicant__c app = TestDataFactory.createSingleApplicant(true,loanApp.id);
        app.Type_of_Borrower__c ='Financial';
        update app;
        BTLoan__c btLoan = new BTLoan__c();
        btLoan.LoanAppl__c = LoanApp.id;
        btLoan.BTOriginalLoanAmt__c = 74594;
        btLoan.BTLoanOutstandingValue__c = 3434;
        btLoan.BTFinancier__c = 'Other';
        insert btLoan;
        
        APICoutTrckr__c apiCounTrckr = new APICoutTrckr__c();
        apiCounTrckr.LAN__c = loanApp.id;
        apiCounTrckr.Appl__c = app.id;
        apiCounTrckr.APIName__c = 'Crif Auth Login';
        apiCounTrckr.IsInvalid__c = true;
        TriggerBase.bypass('APICoutTrckr__c');
        insert apiCounTrckr;
        TriggerBase.clearBypass('APICoutTrckr__c');
        
        List<ApplAsset__c> appAssetList = new List<ApplAsset__c>();
        appAssetList.add(new ApplAsset__c(
            Property_Carpet_area_Sq_Ft__c = 12,
            Resi_Age__c = 2,
            Property_Usage__c = 'RENTED',
            PropIdentified__c ='Yes',
            PropSubType__c = 'added',
            PropSubTypeDesc__c ='TEST',
            LoanAppln__c = loanApp.Id,
            Appl__c = app.Id,
            ValuationToBeTakenAheadForCalculation__c = 87586
        ));
        appAssetList.add(new ApplAsset__c(
            Property_Carpet_area_Sq_Ft__c = 14,
            Resi_Age__c = 4,
            PropIdentified__c ='Yes',
            PropSubType__c = 'added',
            Property_Usage__c = 'VACANT',
            LoanAppln__c = loanApp.Id,
            Appl__c = app.Id
        ));
        appAssetList.add(new ApplAsset__c(
            Property_Carpet_area_Sq_Ft__c = 15,
            Resi_Age__c = 5,
            PropIdentified__c ='Yes',
            Property_Usage__c = 'PARTLY OCCUPIED AND PARTLY RENTED',
            LoanAppln__c = loanApp.Id,
            Appl__c = app.Id
        )); 
        appAssetList.add(new ApplAsset__c(
            Property_Carpet_area_Sq_Ft__c = 15,
            Resi_Age__c = 5,
            Property_Usage__c = 'PARTLY OCCUPIED AND PARTLY RENTED',
            LoanAppln__c = loanApp.Id,
            Appl__c = app.Id
        )); 
        appAssetList.add(new ApplAsset__c(
            Property_Carpet_area_Sq_Ft__c = 15,
            Resi_Age__c = 5,
            PropIdentified__c ='Yes',
            PropSubType__c = 'added',
            PropSubTypeDesc__c ='TEST',
            //NatureofProp__c = 'Showroom',
            Property_Usage__c = 'PARTLY OCCUPIED AND PARTLY RENTED',
            LoanAppln__c = loanApp.Id,
            Appl__c = app.Id
        ));
        appAssetList.add(new ApplAsset__c(
            Property_Carpet_area_Sq_Ft__c = 15,
            Resi_Age__c = 5,
            PropIdentified__c ='Yes',
            PropSubType__c = 'added',
            PropSubTypeDesc__c ='TEST',
            // NatureofProp__c = 'Showroom',
            Property_Usage__c = 'RENTED',
            LoanAppln__c = loanApp.Id,
            Appl__c = app.Id
        ));
        appAssetList.add(new ApplAsset__c(
            Property_Carpet_area_Sq_Ft__c = 15,
            Resi_Age__c = 5,
            PropIdentified__c ='Yes',
            PropSubType__c = 'added',
            PropSubTypeDesc__c ='TEST',
            // NatureofProp__c = 'Showroom',
            Approx_Age_of_Prop__c = 9,
            Property_Usage__c = 'PARTLY OCCUPIED AND PARTLY RENTED',
            LoanAppln__c = loanApp.Id,
            Appl__c = app.Id
        ));
        TriggerBase.bypass('ApplAsset__c');
        insert appAssetList;
        TriggerBase.clearBypass('ApplAsset__c');
        
        List<PD__c> pdList = new List<PD__c>();
        
        pdList.add(new PD__c(
            PDTyp__c = 'Physical PD',
            IsCompleted__c = true,
            PDStatus__c = 'Completed',
            Result__c = 'Negative',
            LoanAppl__c = loanApp.Id,
            Appl__c = app.Id
        )); 
        pdList.add(new PD__c(
            PDTyp__c = 'Physical PD',
            IsCompleted__c = true,
            PDStatus__c = 'Completed',
            Result__c = 'Positive',
            LoanAppl__c = loanApp.Id,
            Appl__c = app.Id
        )); 
        pdList.add(new PD__c(
            PDTyp__c = 'Physical PD',
            IsCompleted__c = false,
            PDStatus__c = 'Initiated',
            Result__c = 'Average',
            LoanAppl__c = loanApp.Id,
            Appl__c = app.Id
        ));
        TriggerBase.bypass('PD__c');
        insert pdList;
        TriggerBase.clearBypass('PD__c');
        
        Account acc = new Account(name='Acme');
        TriggerBase.bypass('Account');
        insert acc;
        TriggerBase.clearBypass('Account');
        List<Case> caseList = new List<Case>();
        Id cvRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
            .get('Collateral Visit').getRecordTypeId();
        Id technicalRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
            .get('Technical').getRecordTypeId();
        Id cpvfiRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
            .get('CPVFI').getRecordTypeId();
        Id rcuRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
            .get('RCU').getRecordTypeId();
        caseList.add(new Case(
            CVStatus__c = 'In Progress',
            Status = 'Query',
            IsReinitiated__c = false,
            ApplAssetId__c = appAssetList[0].Id,
            Loan_Application__c = loanApp.Id,
            Applicant__c = app.Id,
            RecordTypeId = cvRecordTypeId
        ));
        caseList.add(new Case(
            CVStatus__c = 'In Progress',
            Status = 'Query',
            IsReinitiated__c = false,
            IsCompleted__c = true,
            Property_Visit_Final_Status__c = 'Negative',
            ApplAssetId__c = appAssetList[0].Id,
            Loan_Application__c = loanApp.Id,
            Applicant__c = app.Id,
            RecordTypeId = cvRecordTypeId
        ));
        caseList.add(new Case(
            CVStatus__c = 'In Progress',
            Status = 'Query',
            IsReinitiated__c = false,
            AccountId = acc.Id,
            ApplAssetId__c = appAssetList[0].Id,
            Loan_Application__c = loanApp.Id,
            Applicant__c = app.Id,
            RecordTypeId = technicalRecordTypeId
        ));
        caseList.add(new Case(
            CVStatus__c = 'In Progress',
            Status = 'Closed',
            WaiveCPV__c = 'Yes',
            ApplAssetId__c = appAssetList[0].Id,
            Loan_Application__c = loanApp.Id,
            Applicant__c = app.Id,
            RecordTypeId = cpvfiRecordTypeId
        ));
        /*  caseList.add(new Case(
CVStatus__c = 'In Progress',
ApplAssetId__c = appAssetList[0].Id,
Loan_Application__c = loanApp.Id,
Applicant__c = app.Id,
RecordTypeId = rcuRecordTypeId
));*/
        TriggerBase.bypass('Case');
        insert caseList;
        TriggerBase.clearBypass('Case');
        
        List<ApplBanking__c> appbankingList = new List<ApplBanking__c>();
        appbankingList.add(new ApplBanking__c(
            MICR_Code__c = '400240077',
            Repayment_bank_A_c__c = 'Yes',
            LoanAppl__c = loanApp.Id,
            Name_of_the_Primary_Account_Holder_s__c = 'TEST',
            AccountType__c = 'CURRENT',
            AC_No__c = '123456789',
            BankName__c = 'ICICI Bank',
            Appl__c = app.Id
        ));
        appbankingList.add(new ApplBanking__c(
            Name_of_the_Primary_Account_Holder_s__c = 'TEST',
            AccountType__c = 'OVERDRAFT',
            AC_No__c = '123456789',
            BankName__c = 'ICICI Bank',
            LoanAppl__c = loanApp.Id,
            Appl__c = app.Id
        ));
        TriggerBase.bypass('ApplBanking__c');
        insert appbankingList;
        TriggerBase.clearBypass('ApplBanking__c');
        
        List<ApplBankDetail__c> appbankingDtlList = new List<ApplBankDetail__c>();
        
        appbankingDtlList.add(new ApplBankDetail__c(
            AverageBankBalance__c = 1000,
            BalanceAt_10th__c = 2000.00,
            BalanceAt_15th__c = 200.90,
            BalanceAt_20th__c = 200.90,
            BalanceAt_5th__c = 2000.00,
            BalanceAt_25th__c =100.00,
            BalanceAt_1st__c =100.00,
            CountofCredit__c = 10,
            CountofDebit__c =10,
            DailyABBBalance__c = 12.00,
            InwardReturnsCount__c =10,
            MinBalanceCharges__c = 'Y',
            OutwardReturnsCount__c = 23,
            StopPaymentCount__c = 12,
            ValueSummationDebit__c = 12,
            ValueSummationCredit__c = 12,
            ApplBanking__c = appbankingList[1].Id
        ));
        
        TriggerBase.bypass('ApplBankDetail__c');
        insert appbankingDtlList;
        TriggerBase.clearBypass('ApplBankDetail__c');
        
        List<SPDD_Approval_Config__c> spddList = new List<SPDD_Approval_Config__c>();
        spddList.add(new SPDD_Approval_Config__c(
            Dev_Level__c = '5',
            Sanction_Amt__c = 500000.00,
            Product__c = 'Home Loan',
            Emp__c = UserInfo.getUserId()
        ));
        TriggerBase.bypass('SPDD_Approval_Config__c');
        insert spddList;
        TriggerBase.clearBypass('SPDD_Approval_Config__c');
        
        List<Deviation__c> deviationList = new List<Deviation__c>();
        deviationList.add(new Deviation__c(
            Dev_Type__c = 'Manual',
            Req_Apprv_Level__c = '6',
            Appr_Actn__c = 'Rejected',
            LoanAppln__c = loanApp.Id
        ));
        deviationList.add(new Deviation__c(
            Dev_Type__c = 'Manual',
            Req_Apprv_Level__c = '4',
            Appr_Actn__c = 'Approved',
            LoanAppln__c = loanApp.Id
        ));
        TriggerBase.bypass('Deviation__c');
        insert deviationList;
        TriggerBase.clearBypass('Deviation__c');
        
        ApplicantEmployment__c appEmpDetil = new ApplicantEmployment__c();
        appEmpDetil.LoanApplicant__c = app.id;
        appEmpDetil.GST_Registered__c = 'Yes';
        insert appEmpDetil;
        
        ApplGST__c appGST = new ApplGST__c();
        appGST.Main_GSTIN__c = true;
        appGST.Applicant__c = app.id;
        insert appGST;
        
        List<ApplKyc__c> appKycList = new List<ApplKyc__c>();
        appKycList.add(new ApplKyc__c(
            Applicant__c = app.Id,
            kycDoc__c = 'Aadhaar'
        ));
        appKycList.add(new ApplKyc__c(
            Applicant__c = app.Id,
            kycDoc__c = 'Driving License'
        ));
        appKycList.add(new ApplKyc__c(
            Applicant__c = app.Id,
            kycDoc__c = 'Voter Id'
        ));
        appKycList.add(new ApplKyc__c(
            Applicant__c = app.Id,
            kycDoc__c = 'Passport'
        ));
        TriggerBase.bypass('ApplKyc__c');
        insert appKycList;
        TriggerBase.clearBypass('ApplKyc__c');
        
        List<DocDtl__c> docDtlList = new List<DocDtl__c>();
        docDtlList.add(new DocDtl__c(
            DocCatgry__c = 'KYC Documents',
            DocTyp__c = 'Residence Address proof - OVD',
            Appl__c = app.id,
            Applicant_KYC__c = appKycList[0].Id,
            LAN__c = loanApp.Id,
            DocSubTyp__c = 'Aadhaar'
        ));
        docDtlList.add(new DocDtl__c(
            DocCatgry__c = 'KYC Documents',
            DocTyp__c = 'Residence Address proof - OVD',
            Appl__c = app.id,
            Applicant_KYC__c = appKycList[1].Id,
            LAN__c = loanApp.Id,
            DocSubTyp__c = 'Driving License'
        ));
        docDtlList.add(new DocDtl__c(
            DocCatgry__c = 'KYC Documents',
            DocTyp__c = 'Residence Address proof - OVD',
            Appl__c = app.id,
            Applicant_KYC__c = appKycList[2].Id,
            LAN__c = loanApp.Id,
            DocSubTyp__c = 'Voter Id'
        ));
        docDtlList.add(new DocDtl__c(
            DocCatgry__c = 'KYC Documents',
            DocTyp__c = 'Residence Address proof - OVD',
            Appl__c = app.id,
            Applicant_KYC__c = appKycList[3].Id,
            LAN__c = loanApp.Id,
            DocSubTyp__c = 'Passport'
        ));
        TriggerBase.bypass('DocDtl__c');
        insert docDtlList;
        TriggerBase.clearBypass('DocDtl__c');
        //insert docDtl;
        
        
        ApplAddr__c appAdd = new ApplAddr__c();
        appAdd.Applicant__c = app.id;
        appAdd.AddrTyp__c = 'Other Address';
        insert appAdd;
        LoanAppl__c loanApp1 = TestDataFactory.createLoanApplication(true);
        loanApp1.IsSellerListDocLODAvl__c = 'N';
        loanApp1.IsSellerBTLoanForeclosureAmt__c = 'N';
        loanApp1.DocAsPerLegalReportMatches__c = 'N';
        loanApp1.SaleDeedBetnBuyerBorr__c = 'N';
        loanApp1.OwnContriPaid__c = 'N';
        loanApp1.LetterFomSellerBTFinancier__c = 'N';
        loanApp1.ChequeForAmtEquiBTAmt__c = 'N';
        loanApp1.SellerVerificationKYCSellerTaken__c = 'N';
        loanApp1.SellerVerCredTeleChk__c = 'N';
        loanApp1.AllSellerBTNormMet__c = 'N';
        update loanApp1;
        /* List<String>erros = UWApprovalValidation.validateData('Approve', loanApp.Id);
system.debug('erros are' + erros.size());*/
        Boolean isAssert = true;
        try{
            Test.startTest();
            List<String>erross = UWApprovalValidation.validateData('Approve', loanApp.Id); 
            List<String>erross1 = UWApprovalValidation.validateData('Soft Approve', loanApp1.Id);
            
            Test.stopTest();    
        }catch(AuraHandledException ex){
            isAssert = false;
            system.assertEquals('Script-thrown exception', ex.getMessage());
        }  
        system.assertEquals(true, isAssert);
    }
    
    
    @isTest
    static void uwApprvalValnTestMethodTwo() {
        SchMapping__c schMap = new SchMapping__c();
        schMap.SchemeDesc__c = 'BT';
        schMap.IsCostApplicable__c = true;
        insert schMap;
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        loanApp.IsSellerListDocLODAvl__c = null;
        loanApp.IsSellerBTLoanForeclosureAmt__c = 'N';
        loanApp.DocAsPerLegalReportMatches__c = 'N';
        loanApp.SaleDeedBetnBuyerBorr__c = 'N';
        loanApp.OwnContriPaid__c = 'N';
        loanApp.LetterFomSellerBTFinancier__c = 'N';
        loanApp.ChequeForAmtEquiBTAmt__c = 'N';
        loanApp.SellerVerificationKYCSellerTaken__c = 'N';
        loanApp.SellerVerCredTeleChk__c = 'N';
        loanApp.AllSellerBTNormMet__c = 'N';
        loanApp.Product__c = 'Small Ticket LAP';
        loanApp.ProductSubType__c = 'Commercial Property Purchase';
        loanApp.AssesIncomeAppl__c = 'No';
        loanApp.ReqLoanAmt__c = 2550000;
        loanApp.SchemeId__c = schMap.id;
        loanApp.ProductSubType__c = 'Seller BT - 100% Ready Property';
        update loanApp;
        Applicant__c app = TestDataFactory.createSingleApplicant(true,loanApp.id);
        app.Type_of_Borrower__c ='Financial';
        update app;
        BTLoan__c btLoan = new BTLoan__c();
        btLoan.LoanAppl__c = LoanApp.id;
        btLoan.BTOriginalLoanAmt__c = null;
        btLoan.BTLoanOutstandingValue__c = 3434;
        btLoan.BTFinancier__c = 'Other';
        insert btLoan;
        
        APICoutTrckr__c apiCounTrckr = new APICoutTrckr__c();
        apiCounTrckr.LAN__c = loanApp.id;
        apiCounTrckr.Appl__c = app.id;
        apiCounTrckr.APIName__c = 'Dedupe API Token';
        apiCounTrckr.IsInvalid__c = true;
        apiCounTrckr.LtstRespCode__c = 'Failure';
        TriggerBase.bypass('APICoutTrckr__c');
        insert apiCounTrckr;
        TriggerBase.clearBypass('APICoutTrckr__c');
        
        List<ApplAsset__c> appAssetList = new List<ApplAsset__c>();
        appAssetList.add(new ApplAsset__c(
            Property_Carpet_area_Sq_Ft__c = 12,
            Resi_Age__c = 2,
            Property_Usage__c = 'RENTED',
            PropIdentified__c ='Yes',
            PropSubType__c = 'added',
            PropSubTypeDesc__c ='TEST',
            LoanAppln__c = loanApp.Id,
            Appl__c = app.Id,
            ValuationToBeTakenAheadForCalculation__c = 87586
        ));
        appAssetList.add(new ApplAsset__c(
            Property_Carpet_area_Sq_Ft__c = 14,
            Resi_Age__c = 4,
            PropIdentified__c ='Yes',
            PropSubType__c = 'added',
            Property_Usage__c = 'VACANT',
            LoanAppln__c = loanApp.Id,
            Appl__c = app.Id
        ));
        appAssetList.add(new ApplAsset__c(
            Property_Carpet_area_Sq_Ft__c = 15,
            Resi_Age__c = 5,
            PropIdentified__c ='Yes',
            Property_Usage__c = 'PARTLY OCCUPIED AND PARTLY RENTED',
            LoanAppln__c = loanApp.Id,
            Appl__c = app.Id
        )); 
        appAssetList.add(new ApplAsset__c(
            Property_Carpet_area_Sq_Ft__c = 15,
            Resi_Age__c = 5,
            Property_Usage__c = 'PARTLY OCCUPIED AND PARTLY RENTED',
            LoanAppln__c = loanApp.Id,
            Appl__c = app.Id
        )); 
        appAssetList.add(new ApplAsset__c(
            Property_Carpet_area_Sq_Ft__c = 15,
            Resi_Age__c = 5,
            PropIdentified__c ='Yes',
            PropSubType__c = 'added',
            PropSubTypeDesc__c ='TEST',
            //NatureofProp__c = 'Showroom',
            Property_Usage__c = 'PARTLY OCCUPIED AND PARTLY RENTED',
            LoanAppln__c = loanApp.Id,
            Appl__c = app.Id
        ));
        appAssetList.add(new ApplAsset__c(
            Property_Carpet_area_Sq_Ft__c = 15,
            Resi_Age__c = 5,
            PropIdentified__c ='Yes',
            PropSubType__c = 'added',
            PropSubTypeDesc__c ='TEST',
            // NatureofProp__c = 'Showroom',
            Property_Usage__c = 'RENTED',
            LoanAppln__c = loanApp.Id,
            Appl__c = app.Id
        ));
        appAssetList.add(new ApplAsset__c(
            Property_Carpet_area_Sq_Ft__c = 15,
            Resi_Age__c = 5,
            PropIdentified__c ='Yes',
            PropSubType__c = 'added',
            PropSubTypeDesc__c ='TEST',
            // NatureofProp__c = 'Showroom',
            Approx_Age_of_Prop__c = 9,
            Property_Usage__c = 'PARTLY OCCUPIED AND PARTLY RENTED',
            LoanAppln__c = loanApp.Id,
            Appl__c = app.Id
        ));
        TriggerBase.bypass('ApplAsset__c');
        insert appAssetList;
        TriggerBase.clearBypass('ApplAsset__c');
        
        List<PD__c> pdList = new List<PD__c>();
        
        pdList.add(new PD__c(
            PDTyp__c = 'Physical PD',
            IsCompleted__c = true,
            PDStatus__c = 'Completed',
            Result__c = 'Negative',
            LoanAppl__c = loanApp.Id,
            Appl__c = app.Id
        )); 
        pdList.add(new PD__c(
            PDTyp__c = 'Physical PD',
            IsCompleted__c = true,
            PDStatus__c = 'Completed',
            Result__c = 'Positive',
            LoanAppl__c = loanApp.Id,
            Appl__c = app.Id
        )); 
        pdList.add(new PD__c(
            PDTyp__c = 'Physical PD',
            IsCompleted__c = false,
            PDStatus__c = 'Initiated',
            Result__c = 'Average',
            LoanAppl__c = loanApp.Id,
            Appl__c = app.Id
        ));
        TriggerBase.bypass('PD__c');
        insert pdList;
        TriggerBase.clearBypass('PD__c');
        
        Account acc = new Account(name='Acme');
        TriggerBase.bypass('Account');
        insert acc;
        TriggerBase.clearBypass('Account');
        List<Case> caseList = new List<Case>();
        Id cvRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
            .get('Collateral Visit').getRecordTypeId();
        Id technicalRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
            .get('Technical').getRecordTypeId();
        Id cpvfiRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
            .get('CPVFI').getRecordTypeId();
        Id rcuRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
            .get('RCU').getRecordTypeId();
        
        caseList.add(new Case(
            CVStatus__c = 'In Progress',
            Status = 'Query',
            IsReinitiated__c = false,
            ApplAssetId__c = appAssetList[0].Id,
            Loan_Application__c = loanApp.Id,
            Property_Visit_Final_Status__c = 'Positive',
		    Applicant__c = app.Id,
            RecordTypeId = cvRecordTypeId,
            IsCompleted__c = false
        ));
        caseList.add(new Case(
            CVStatus__c = 'In Progress',
            Status = 'Query',
            IsReinitiated__c = false,
            IsCompleted__c = false,
            Property_Visit_Final_Status__c = 'Positive',
            ApplAssetId__c = appAssetList[0].Id,
            Loan_Application__c = loanApp.Id,
            Applicant__c = app.Id,
            RecordTypeId = cvRecordTypeId
        ));
        caseList.add(new Case(
            CVStatus__c = 'In Progress',
            Status = 'Query',
            IsReinitiated__c = false,
            AccountId = acc.Id,
            ApplAssetId__c = appAssetList[0].Id,
            Loan_Application__c = loanApp.Id,
            Applicant__c = app.Id,
            RecordTypeId = rcuRecordTypeId,
            IsCompleted__c = false,
            Property_Visit_Final_Status__c = 'Positive'
        ));
        caseList.add(new Case(
            CVStatus__c = 'In Progress',
            Status = 'Cancelled',
            WaiveCPV__c = 'Yes',
            ApplAssetId__c = appAssetList[0].Id,
            Loan_Application__c = loanApp.Id,
            Applicant__c = app.Id,
            RecordTypeId = cpvfiRecordTypeId,
            Property_Visit_Final_Status__c = 'Positive',
			IsCompleted__c = false
     ));
        /*  caseList.add(new Case(
CVStatus__c = 'In Progress',
ApplAssetId__c = appAssetList[0].Id,
Loan_Application__c = loanApp.Id,
Applicant__c = app.Id,
RecordTypeId = rcuRecordTypeId
));*/
        TriggerBase.bypass('Case');
        insert caseList;
        TriggerBase.clearBypass('Case');
        
        List<ApplBanking__c> appbankingList = new List<ApplBanking__c>();
        appbankingList.add(new ApplBanking__c(
            MICR_Code__c = '400240077',
            Repayment_bank_A_c__c = 'Yes',
            LoanAppl__c = loanApp.Id,
            Name_of_the_Primary_Account_Holder_s__c = 'TEST',
            AccountType__c = 'CURRENT',
            AC_No__c = '123456789',
            BankName__c = 'ICICI Bank',
            Appl__c = app.Id
        ));
        appbankingList.add(new ApplBanking__c(
            Name_of_the_Primary_Account_Holder_s__c = 'TEST',
            AccountType__c = 'OVERDRAFT',
            AC_No__c = '123456789',
            BankName__c = 'ICICI Bank',
            LoanAppl__c = loanApp.Id,
            Appl__c = app.Id
        ));
        TriggerBase.bypass('ApplBanking__c');
        insert appbankingList;
        TriggerBase.clearBypass('ApplBanking__c');
        
        List<ApplBankDetail__c> appbankingDtlList = new List<ApplBankDetail__c>();
        
        appbankingDtlList.add(new ApplBankDetail__c(
            AverageBankBalance__c = 1000,
            BalanceAt_10th__c = null,
            BalanceAt_15th__c = 200.90,
            BalanceAt_20th__c = 200.90,
            BalanceAt_5th__c = 2000.00,
            BalanceAt_25th__c =100.00,
            BalanceAt_1st__c =100.00,
            CountofCredit__c = 10,
            CountofDebit__c =10,
            DailyABBBalance__c = 12.00,
            InwardReturnsCount__c =10,
            MinBalanceCharges__c = 'Y',
            OutwardReturnsCount__c = 23,
            StopPaymentCount__c = 12,
            ValueSummationDebit__c = 12,
            ValueSummationCredit__c = 12,
            ApplBanking__c = appbankingList[1].Id
        ));
        
        TriggerBase.bypass('ApplBankDetail__c');
        insert appbankingDtlList;
        TriggerBase.clearBypass('ApplBankDetail__c');
        
        List<SPDD_Approval_Config__c> spddList = new List<SPDD_Approval_Config__c>();
        spddList.add(new SPDD_Approval_Config__c(
            Dev_Level__c = '5',
            Sanction_Amt__c = 500000.00,
            Product__c = 'Home Loan',
            Emp__c = UserInfo.getUserId()
        ));
        TriggerBase.bypass('SPDD_Approval_Config__c');
        insert spddList;
        TriggerBase.clearBypass('SPDD_Approval_Config__c');
        
        List<Deviation__c> deviationList = new List<Deviation__c>();
        deviationList.add(new Deviation__c(
            Dev_Type__c = 'Manual',
            Req_Apprv_Level__c = '6',
            Appr_Actn__c = 'Rejected',
            LoanAppln__c = loanApp.Id
        ));
        deviationList.add(new Deviation__c(
            Dev_Type__c = 'Manual',
            Req_Apprv_Level__c = '4',
            Appr_Actn__c = 'Approved',
            LoanAppln__c = loanApp.Id
        ));
        TriggerBase.bypass('Deviation__c');
        insert deviationList;
        TriggerBase.clearBypass('Deviation__c');
        
        ApplicantEmployment__c appEmpDetil = new ApplicantEmployment__c();
        appEmpDetil.LoanApplicant__c = app.id;
        appEmpDetil.GST_Registered__c = 'Yes';
        insert appEmpDetil;
        
        ApplGST__c appGST = new ApplGST__c();
        appGST.Main_GSTIN__c = true;
        appGST.Applicant__c = app.id;
        insert appGST;
        
        List<ApplKyc__c> appKycList = new List<ApplKyc__c>();
        appKycList.add(new ApplKyc__c(
            Applicant__c = app.Id,
            kycDoc__c = 'Aadhaar'
        ));
        appKycList.add(new ApplKyc__c(
            Applicant__c = app.Id,
            kycDoc__c = 'Driving License'
        ));
        appKycList.add(new ApplKyc__c(
            Applicant__c = app.Id,
            kycDoc__c = 'Voter Id'
        ));
        appKycList.add(new ApplKyc__c(
            Applicant__c = app.Id,
            kycDoc__c = 'Passport'
        ));
        TriggerBase.bypass('ApplKyc__c');
        insert appKycList;
        TriggerBase.clearBypass('ApplKyc__c');
        
        List<DocDtl__c> docDtlList = new List<DocDtl__c>();
        docDtlList.add(new DocDtl__c(
            DocCatgry__c = 'KYC Documents',
            DocTyp__c = 'Residence Address proof - OVD',
            Appl__c = app.id,
            Applicant_KYC__c = appKycList[0].Id,
            LAN__c = loanApp.Id,
            DocSubTyp__c = 'Aadhaar'
        ));
        docDtlList.add(new DocDtl__c(
            DocCatgry__c = 'KYC Documents',
            DocTyp__c = 'Residence Address proof - OVD',
            Appl__c = app.id,
            Applicant_KYC__c = appKycList[1].Id,
            LAN__c = loanApp.Id,
            DocSubTyp__c = 'Driving License'
        ));
        docDtlList.add(new DocDtl__c(
            DocCatgry__c = 'KYC Documents',
            DocTyp__c = 'Residence Address proof - OVD',
            Appl__c = app.id,
            Applicant_KYC__c = appKycList[2].Id,
            LAN__c = loanApp.Id,
            DocSubTyp__c = 'Voter Id'
        ));
        docDtlList.add(new DocDtl__c(
            DocCatgry__c = 'KYC Documents',
            DocTyp__c = 'Residence Address proof - OVD',
            Appl__c = app.id,
            Applicant_KYC__c = appKycList[3].Id,
            LAN__c = loanApp.Id,
            DocSubTyp__c = 'Passport'
        ));
        TriggerBase.bypass('DocDtl__c');
        insert docDtlList;
        TriggerBase.clearBypass('DocDtl__c');
        //insert docDtl;
        
        Id dedupeRecordTypeId = Schema.SObjectType.DedupeResponse__c.getRecordTypeInfosByName()
            .get('Dedupe').getRecordTypeId();
        Id enpaRecordTypeId = Schema.SObjectType.DedupeResponse__c.getRecordTypeInfosByName()
            .get('ENPA').getRecordTypeId();
        
        List<DedupeResponse__c> varDedupeListOne = New List<DedupeResponse__c>();  
        DedupeResponse__c varDedupeOne = New DedupeResponse__c();
        varDedupeOne.IntnlDeduRelevance__c = 'Accurate Match found';
        varDedupeOne.IntnalDeduperesremark__c = 'Match Found';
        //varDedupeOne.IntrnlDeduperes__c = 'Positive Dedupe';
        varDedupeOne.IsLatest__c = TRUE;
        varDedupeOne.RecordTypeId = dedupeRecordTypeId;
        varDedupeOne.Applicant__c = app.id;
        varDedupeOne.LoanAppln__c = loanApp.id;
        varDedupeListOne.add(varDedupeOne); 
        
        DedupeResponse__c varDedupeOnes = New DedupeResponse__c();
        //varDedupeOnes.IntnalDeduperesremark__c = 'Match Found';
        varDedupeOnes.IntnlDeduRelevance__c = 'Accurate Match found';
        varDedupeOnes.IntrnlDeduperes__c = 'Positive Dedupe';
        varDedupeOnes.IsLatest__c = TRUE;
        varDedupeOnes.RecordTypeId = dedupeRecordTypeId;
        varDedupeOnes.Applicant__c = app.id;
        varDedupeOnes.LoanAppln__c = loanApp.id;
        varDedupeListOne.add(varDedupeOnes);
        
        DedupeResponse__c varDedupeTwos = New DedupeResponse__c();
        varDedupeTwos.Internal_Top_up_Original_loan__c = 'Yes';
        varDedupeTwos.Loan_to_be_closed_internally__c= 'Yes';
        varDedupeTwos.IsPDDpending__c= 'Yes';
        varDedupeTwos.Loantobelinkedwithproposedloan__c = 'Yes';
        varDedupeTwos.LoantobeconsideredinLTVcal__c = 'Yes';
        varDedupeTwos.IntnlDeduRelevance__c = 'Accurate Match found';
        varDedupeTwos.IntrnlDeduperes__c = 'Positive Dedupe';
        varDedupeTwos.IsLatest__c = TRUE;
        varDedupeTwos.RecordTypeId = enpaRecordTypeId ;
        varDedupeTwos.Applicant__c = app.id;
        varDedupeTwos.LoanAppln__c = loanApp.id;
        varDedupeListOne.add(varDedupeTwos);
        
        insert varDedupeListOne;
        
		List<DedupeResponse__c> varDedupeListTwo = New List<DedupeResponse__c>();   
        DedupeResponse__c varDedupeTwo = New DedupeResponse__c();
        varDedupeTwo.IntnlDeduRelevance__c = 'Accurate Match found';
        varDedupeTwo.IntnalDeduperesremark__c = 'Match Found';
        varDedupeTwo.IsLatest__c = TRUE;
        varDedupeTwo.RecordTypeId = dedupeRecordTypeId;
        varDedupeTwo.Applicant__c = app.id;
        varDedupeTwo.Dedupe__c = varDedupeListOne[0].Id;
        varDedupeTwo.LoanAppln__c = loanApp.id;
        varDedupeListTwo.add(varDedupeTwo);
                
        DedupeResponse__c varDedupeThree = New DedupeResponse__c();
        //varDedupeThree.IntnalDeduperesremark__c = 'Match Found';
        varDedupeThree.IntnlDeduRelevance__c= 'Accurate Match found';
        varDedupeThree.IsLatest__c = TRUE;
        varDedupeThree.RecordTypeId = dedupeRecordTypeId;
        varDedupeThree.Applicant__c = app.id;
        varDedupeThree.Dedupe__c = varDedupeListOne[1].Id;
        varDedupeThree.LoanAppln__c = loanApp.id;
        varDedupeListTwo.add(varDedupeThree);
        insert varDedupeListTwo;
        
        ApplRegltry__c varAppReg = New ApplRegltry__c();  	
        varAppReg.LoanAppln__c = loanApp.Id;
        varAppReg.Appl__c = app.Id;
        varAppReg.IsBorowrOrRelFFDir__c = 'Yes';
        varAppReg.FFDirRelIntrstAsSH__c = 'No';
        varAppReg.FFDirRelIntrstAsPart__c = 'No';
		insert varAppReg;

        RegltryPrsonl__c varRegPer = New RegltryPrsonl__c();
		//varRegPer.DirName__c = 'Test Dir name';
		varRegPer.Desgntn__c = 'Engineer';
		varRegPer.Reltnshp__c = 'Test Relation';
		varRegPer.Applicant_Regulatory__c = varAppReg.Id;
		insert varRegPer;
        
        ApplAddr__c appAdd = new ApplAddr__c();
        appAdd.Applicant__c = app.id;
        appAdd.AddrTyp__c = 'Other Address';
        insert appAdd;
        LoanAppl__c loanApp1 = TestDataFactory.createLoanApplication(true);
        loanApp1.IsSellerListDocLODAvl__c = 'N';
        loanApp1.IsSellerBTLoanForeclosureAmt__c = 'N';
        loanApp1.DocAsPerLegalReportMatches__c = 'N';
        loanApp1.SaleDeedBetnBuyerBorr__c = 'N';
        loanApp1.OwnContriPaid__c = 'N';
        loanApp1.LetterFomSellerBTFinancier__c = 'N';
        loanApp1.ChequeForAmtEquiBTAmt__c = 'N';
        loanApp1.SellerVerificationKYCSellerTaken__c = 'N';
        loanApp1.SellerVerCredTeleChk__c = 'N';
        loanApp1.AllSellerBTNormMet__c = 'N';
        update loanApp1;
        /* List<String>erros = UWApprovalValidation.validateData('Approve', loanApp.Id);
system.debug('erros are' + erros.size());*/
        Boolean isAssert = true;
        try{
            Test.startTest();
            List<String>erross = UWApprovalValidation.validateData('Approve', loanApp.Id); 
            List<String>erross1 = UWApprovalValidation.validateData('Soft Approve', loanApp1.Id);
            
            Test.stopTest();    
        }catch(AuraHandledException ex){
            isAssert = false;
            system.assertEquals('Script-thrown exception', ex.getMessage());
        }  
        system.assertEquals(true, isAssert);
    }
    
    
    
    @isTest
    static void uwApprvalValnTestMethodThree() {
        SchMapping__c schMap = new SchMapping__c();
        schMap.SchemeDesc__c = 'BT';
        schMap.IsCostApplicable__c = true;
        insert schMap;
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        loanApp.IsSellerListDocLODAvl__c = null;
        loanApp.IsSellerBTLoanForeclosureAmt__c = 'N';
        loanApp.DocAsPerLegalReportMatches__c = 'N';
        loanApp.SaleDeedBetnBuyerBorr__c = 'N';
        loanApp.OwnContriPaid__c = 'N';
        loanApp.LetterFomSellerBTFinancier__c = 'N';
        loanApp.ChequeForAmtEquiBTAmt__c = 'N';
        loanApp.SellerVerificationKYCSellerTaken__c = 'N';
        loanApp.SellerVerCredTeleChk__c = 'N';
        loanApp.AllSellerBTNormMet__c = 'N';
        loanApp.Product__c = 'Small Ticket LAP';
        loanApp.ProductSubType__c = 'Commercial Property Purchase';
        loanApp.SchemeId__c = schMap.id;
        loanApp.ProductSubType__c = 'Seller BT - 100% Ready Property';
        update loanApp;
        Applicant__c app = TestDataFactory.createSingleApplicant(true,loanApp.id);
        app.Type_of_Borrower__c ='Financial';
        update app;
        BTLoan__c btLoan = new BTLoan__c();
        btLoan.LoanAppl__c = LoanApp.id;
        btLoan.BTOriginalLoanAmt__c = null;
        btLoan.BTLoanOutstandingValue__c = 3434;
        btLoan.BTFinancier__c = 'Other';
        insert btLoan;
        
        APICoutTrckr__c apiCounTrckr = new APICoutTrckr__c();
        apiCounTrckr.LAN__c = loanApp.id;
        apiCounTrckr.Appl__c = app.id;
        apiCounTrckr.APIName__c = 'Hunter Token';
        apiCounTrckr.IsInvalid__c = true;
        apiCounTrckr.LtstRespCode__c = 'Failure';
        TriggerBase.bypass('APICoutTrckr__c');
        insert apiCounTrckr;
        
        TriggerBase.clearBypass('APICoutTrckr__c');
        
        List<ApplAsset__c> appAssetList = new List<ApplAsset__c>();
        appAssetList.add(new ApplAsset__c(
            Property_Carpet_area_Sq_Ft__c = 12,
            Resi_Age__c = 2,
            Property_Usage__c = 'PARTLY OCCUPIED AND PARTLY RENTED',
            PropIdentified__c ='No',
            PropSubType__c = 'added',
            PropSubTypeDesc__c ='TEST',
            LoanAppln__c = loanApp.Id,
            PropType__c	= 'RESIDENTIAL',
            NatureofProp__c = 'Residential Flat',
            Appl__c = app.Id,
            ServiceableCity__c = false,
            ValuationToBeTakenAheadForCalculation__c = 87586
        ));
        appAssetList.add(new ApplAsset__c(
            Property_Carpet_area_Sq_Ft__c = 14,
            Resi_Age__c = 4,
           // PropIdentified__c ='Yes',
            PropSubType__c = 'added',
            Property_Usage__c = 'VACANT',
            LoanAppln__c = loanApp.Id,
            Appl__c = app.Id,
            ServiceableCity__c = false
        ));
        appAssetList.add(new ApplAsset__c(
            Property_Carpet_area_Sq_Ft__c = 15,
            Resi_Age__c = 5,
            //PropIdentified__c ='Yes',
            Property_Usage__c = 'PARTLY OCCUPIED AND PARTLY RENTED',
            LoanAppln__c = loanApp.Id,
            Appl__c = app.Id,
            ServiceableCity__c = false
        )); 
        appAssetList.add(new ApplAsset__c(
            Property_Carpet_area_Sq_Ft__c = 15,
            Resi_Age__c = 5,
            Property_Usage__c = 'PARTLY OCCUPIED AND PARTLY RENTED',
            LoanAppln__c = loanApp.Id,
            Appl__c = app.Id,
            ServiceableCity__c = false
        )); 
        appAssetList.add(new ApplAsset__c(
            Property_Carpet_area_Sq_Ft__c = 15,
            Resi_Age__c = 5,
            //PropIdentified__c ='Yes',
            PropSubType__c = 'added',
            PropSubTypeDesc__c ='TEST',
            //NatureofProp__c = 'Showroom',
            Property_Usage__c = 'PARTLY OCCUPIED AND PARTLY RENTED',
            LoanAppln__c = loanApp.Id,
            Appl__c = app.Id,
            ServiceableCity__c = false
        ));
        appAssetList.add(new ApplAsset__c(
            Property_Carpet_area_Sq_Ft__c = 15,
            Resi_Age__c = 5,
           // PropIdentified__c ='Yes',
            PropSubType__c = 'added',
            PropSubTypeDesc__c ='TEST',
            // NatureofProp__c = 'Showroom',
            Property_Usage__c = 'RENTED',
            LoanAppln__c = loanApp.Id,
            Appl__c = app.Id,
            ServiceableCity__c = false
		));
        appAssetList.add(new ApplAsset__c(
            Property_Carpet_area_Sq_Ft__c = 15,
            Resi_Age__c = 5,
           // PropIdentified__c ='Yes',
            PropSubType__c = 'added',
            PropSubTypeDesc__c ='TEST',
            // NatureofProp__c = 'Showroom',
            Approx_Age_of_Prop__c = 9,
            Property_Usage__c = 'PARTLY OCCUPIED AND PARTLY RENTED',
            LoanAppln__c = loanApp.Id,
            Appl__c = app.Id,
            ServiceableCity__c = false
		));
        TriggerBase.bypass('ApplAsset__c');
        insert appAssetList;
        TriggerBase.clearBypass('ApplAsset__c');
        
        List<PD__c> pdList = new List<PD__c>();
        
        pdList.add(new PD__c(
            PDTyp__c = 'Physical PD',
            IsCompleted__c = true,
            PDStatus__c = 'Completed',
            Result__c = 'Negative',
            LoanAppl__c = loanApp.Id,
            Appl__c = app.Id
        )); 
        pdList.add(new PD__c(
            PDTyp__c = 'Physical PD',
            IsCompleted__c = true,
            PDStatus__c = 'Completed',
            Result__c = 'Negative',
            LoanAppl__c = loanApp.Id,
            Appl__c = app.Id
        )); 
        pdList.add(new PD__c(
            PDTyp__c = 'Physical PD',
            IsCompleted__c = true,
            PDStatus__c = 'Completed',
            Result__c = 'Negative',
            LoanAppl__c = loanApp.Id,
            Appl__c = app.Id
        ));
        TriggerBase.bypass('PD__c');
        insert pdList;
        TriggerBase.clearBypass('PD__c');
        
        Account acc = new Account(name='Acme');
        TriggerBase.bypass('Account');
        insert acc;
        TriggerBase.clearBypass('Account');
        List<Case> caseList = new List<Case>();
        Id cvRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
            .get('Collateral Visit').getRecordTypeId();
        Id technicalRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
            .get('Technical').getRecordTypeId();
        Id cpvfiRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
            .get('CPVFI').getRecordTypeId();
        Id rcuRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
            .get('RCU').getRecordTypeId();
        Id legalRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
            .get('Legal').getRecordTypeId();
        caseList.add(new Case(
            CVStatus__c = 'In Progress',
            Status = 'Query',
            IsReinitiated__c = false,
            ApplAssetId__c = appAssetList[0].Id,
            Loan_Application__c = loanApp.Id,
            Applicant__c = app.Id,
            RecordTypeId = cvRecordTypeId
        ));
        caseList.add(new Case(
            CVStatus__c = 'In Progress',
            Status = 'Query',
            IsReinitiated__c = false,
            IsCompleted__c = true,
            Property_Visit_Final_Status__c = 'Negative',
            ApplAssetId__c = appAssetList[0].Id,
            Loan_Application__c = loanApp.Id,
            Applicant__c = app.Id,
            RecordTypeId = cvRecordTypeId
        ));
        caseList.add(new Case(
            CVStatus__c = 'In Progress',
            Status = 'Query',
            IsReinitiated__c = false,
            AccountId = acc.Id,
            ApplAssetId__c = appAssetList[0].Id,
            Loan_Application__c = loanApp.Id,
            Applicant__c = app.Id,
            RecordTypeId = legalRecordTypeId
        ));
        caseList.add(new Case(
            CVStatus__c = 'In Progress',
            Status = 'Closed',
            WaiveCPV__c = 'Yes',
            ApplAssetId__c = appAssetList[0].Id,
            Loan_Application__c = loanApp.Id,
            Applicant__c = app.Id,
            RecordTypeId = cpvfiRecordTypeId
        ));
        /*  caseList.add(new Case(
CVStatus__c = 'In Progress',
ApplAssetId__c = appAssetList[0].Id,
Loan_Application__c = loanApp.Id,
Applicant__c = app.Id,
RecordTypeId = rcuRecordTypeId
));*/
        TriggerBase.bypass('Case');
        insert caseList;
        TriggerBase.clearBypass('Case');
        
        List<ApplBanking__c> appbankingList = new List<ApplBanking__c>();
        appbankingList.add(new ApplBanking__c(
            MICR_Code__c = '400240077',
            Repayment_bank_A_c__c = 'Yes',
            LoanAppl__c = loanApp.Id,
            Name_of_the_Primary_Account_Holder_s__c = 'TEST',
            AccountType__c = 'CURRENT',
            AC_No__c = '123456789',
            //  BankName__c = 'ICICI Bank',
            Appl__c = app.Id
        ));
        appbankingList.add(new ApplBanking__c(
            Name_of_the_Primary_Account_Holder_s__c = 'TEST',
            AccountType__c = 'OVERDRAFT',
            AC_No__c = '123456789',
            // BankName__c = 'ICICI Bank',
            LoanAppl__c = loanApp.Id,
            Appl__c = app.Id
        ));
        TriggerBase.bypass('ApplBanking__c');
        insert appbankingList;
        TriggerBase.clearBypass('ApplBanking__c');
        
        List<ApplBankDetail__c> appbankingDtlList = new List<ApplBankDetail__c>();
        
        appbankingDtlList.add(new ApplBankDetail__c(
            AverageBankBalance__c = 1000,
            BalanceAt_10th__c = 2000.00,
            BalanceAt_15th__c = 200.90,
            BalanceAt_20th__c = 200.90,
            BalanceAt_5th__c = 2000.00,
            BalanceAt_25th__c =100.00,
            BalanceAt_1st__c =100.00,
            CountofCredit__c = 10,
            CountofDebit__c =10,
            DailyABBBalance__c = 12.00,
            InwardReturnsCount__c =10,
            MinBalanceCharges__c = 'Y',
            OutwardReturnsCount__c = 23,
            StopPaymentCount__c = 12,
            ValueSummationDebit__c = 12,
            ValueSummationCredit__c = 12,
            ApplBanking__c = appbankingList[1].Id
        ));
        
        TriggerBase.bypass('ApplBankDetail__c');
        insert appbankingDtlList;
        TriggerBase.clearBypass('ApplBankDetail__c');
        
        List<SPDD_Approval_Config__c> spddList = new List<SPDD_Approval_Config__c>();
        spddList.add(new SPDD_Approval_Config__c(
            Dev_Level__c = '5',
            Sanction_Amt__c = 500000.00,
            Product__c = 'Home Loan',
            Emp__c = UserInfo.getUserId()
        ));
        TriggerBase.bypass('SPDD_Approval_Config__c');
        insert spddList;
        TriggerBase.clearBypass('SPDD_Approval_Config__c');
        
        List<Deviation__c> deviationList = new List<Deviation__c>();
        deviationList.add(new Deviation__c(
            Dev_Type__c = 'Manual',
            Req_Apprv_Level__c = '6',
            Appr_Actn__c = 'Rejected',
            LoanAppln__c = loanApp.Id
        ));
        deviationList.add(new Deviation__c(
            Dev_Type__c = 'Manual',
            Req_Apprv_Level__c = '4',
            Appr_Actn__c = 'Approved',
            LoanAppln__c = loanApp.Id
        ));
        TriggerBase.bypass('Deviation__c');
        insert deviationList;
        TriggerBase.clearBypass('Deviation__c');
        
        ApplicantEmployment__c appEmpDetil = new ApplicantEmployment__c();
        appEmpDetil.LoanApplicant__c = app.id;
        appEmpDetil.GST_Registered__c = 'Yes';
        insert appEmpDetil;
        
        ApplGST__c appGST = new ApplGST__c();
        appGST.Main_GSTIN__c = false;
        appGST.Applicant__c = app.id;
        insert appGST;
        
        List<ApplKyc__c> appKycList = new List<ApplKyc__c>();
        appKycList.add(new ApplKyc__c(
            Applicant__c = app.Id,
            kycDoc__c = 'Aadhaar'
        ));
        appKycList.add(new ApplKyc__c(
            Applicant__c = app.Id,
            kycDoc__c = 'Driving License'
        ));
        appKycList.add(new ApplKyc__c(
            Applicant__c = app.Id,
            kycDoc__c = 'Voter Id'
        ));
        appKycList.add(new ApplKyc__c(
            Applicant__c = app.Id,
            kycDoc__c = 'Passport'
        ));
        TriggerBase.bypass('ApplKyc__c');
        insert appKycList;
        TriggerBase.clearBypass('ApplKyc__c');
        
        List<DocDtl__c> docDtlList = new List<DocDtl__c>();
        docDtlList.add(new DocDtl__c(
            DocCatgry__c = 'KYC Documents',
            DocTyp__c = 'Residence Address proof - OVD',
            Appl__c = app.id,
            Applicant_KYC__c = appKycList[0].Id,
            LAN__c = loanApp.Id,
            DocSubTyp__c = 'Aadhaar'
        ));
        docDtlList.add(new DocDtl__c(
            DocCatgry__c = 'KYC Documents',
            DocTyp__c = 'Residence Address proof - OVD',
            Appl__c = app.id,
            Applicant_KYC__c = appKycList[1].Id,
            LAN__c = loanApp.Id,
            DocSubTyp__c = 'Driving License'
        ));
        docDtlList.add(new DocDtl__c(
            DocCatgry__c = 'KYC Documents',
            DocTyp__c = 'Residence Address proof - OVD',
            Appl__c = app.id,
            Applicant_KYC__c = appKycList[2].Id,
            LAN__c = loanApp.Id,
            DocSubTyp__c = 'Voter Id'
        ));
        docDtlList.add(new DocDtl__c(
            DocCatgry__c = 'KYC Documents',
            DocTyp__c = 'Residence Address proof - OVD',
            Appl__c = app.id,
            Applicant_KYC__c = appKycList[3].Id,
            LAN__c = loanApp.Id,
            DocSubTyp__c = 'Passport'
        ));
        TriggerBase.bypass('DocDtl__c');
        insert docDtlList;
        TriggerBase.clearBypass('DocDtl__c');
        //insert docDtl;
        
        Id dedupeRecordTypeId = Schema.SObjectType.DedupeResponse__c.getRecordTypeInfosByName()
            .get('Dedupe').getRecordTypeId();
        Id enpaRecordTypeId = Schema.SObjectType.DedupeResponse__c.getRecordTypeInfosByName()
            .get('ENPA').getRecordTypeId();
        
        List<DedupeResponse__c> varDedupeListOne = New List<DedupeResponse__c>();  
        DedupeResponse__c varDedupeOne = New DedupeResponse__c();
        varDedupeOne.IntnlDeduRelevance__c = 'Accurate Match found';
        varDedupeOne.IntnalDeduperesremark__c = 'Match Found';
        varDedupeOne.IntrnlDeduperes__c = 'Positive Dedupe';
        varDedupeOne.IsLatest__c = TRUE;
        varDedupeOne.RecordTypeId = dedupeRecordTypeId;
        varDedupeOne.Applicant__c = app.id;
        varDedupeOne.LoanAppln__c = loanApp.id;
        varDedupeListOne.add(varDedupeOne);  
        insert varDedupeListOne;
        
		List<DedupeResponse__c> varDedupeListTwo = New List<DedupeResponse__c>();   
        DedupeResponse__c varDedupeTwo = New DedupeResponse__c();
        varDedupeTwo.IntnlDeduRelevance__c = 'Accurate Match found';
        varDedupeTwo.IntnalDeduperesremark__c = 'Match Found';
        varDedupeTwo.IsLatest__c = TRUE;
        varDedupeTwo.RecordTypeId = dedupeRecordTypeId;
        varDedupeTwo.Applicant__c = app.id;
        varDedupeTwo.Dedupe__c = varDedupeListOne[0].Id;
        varDedupeTwo.LoanAppln__c = loanApp.id;
        varDedupeListTwo.add(varDedupeTwo);
        
        DedupeResponse__c varDedupeTwos = New DedupeResponse__c();
        varDedupeTwos.Loan_to_be_closed_internally__c= 'Yes';
        varDedupeTwos.IsPDDpending__c= 'Yes';
        varDedupeTwos.Loantobelinkedwithproposedloan__c = 'Yes';
        varDedupeTwos.LoantobeconsideredinLTVcal__c = 'Yes';
        varDedupeTwos.IntnlDeduRelevance__c = 'Accurate Match found';
        varDedupeTwos.IntrnlDeduperes__c = 'Positive Dedupe';
        varDedupeTwos.IsLatest__c = TRUE;
        varDedupeTwos.RecordTypeId = enpaRecordTypeId ;
        varDedupeTwos.Applicant__c = app.id;
        varDedupeTwos.LoanAppln__c = loanApp.id;
        varDedupeListTwo.add(varDedupeTwos);
		insert varDedupeListTwo;
        
         
        ApplRegltry__c varAppReg = New ApplRegltry__c();  	
        varAppReg.LoanAppln__c = loanApp.Id;
        varAppReg.Appl__c = app.Id;
        varAppReg.IsBorowrOrRelFFDir__c = null;
        varAppReg.FFDirRelIntrstAsSH__c = 'No';
        varAppReg.FFDirRelIntrstAsPart__c = 'No';
		insert varAppReg;

        RegltryPrsonl__c varRegPer = New RegltryPrsonl__c();
		varRegPer.DirName__c = 'Test Dir name';
		varRegPer.Desgntn__c = 'Engineer';
		varRegPer.Reltnshp__c = 'Test Relation';
		varRegPer.Applicant_Regulatory__c = varAppReg.Id;
		insert varRegPer;
        
        
        ApplAddr__c appAdd = new ApplAddr__c();
        appAdd.Applicant__c = app.id;
        appAdd.AddrTyp__c = 'Other Address';
        insert appAdd;
        LoanAppl__c loanApp1 = TestDataFactory.createLoanApplication(true);
        loanApp1.IsSellerListDocLODAvl__c = 'N';
        loanApp1.IsSellerBTLoanForeclosureAmt__c = 'N';
        loanApp1.DocAsPerLegalReportMatches__c = 'N';
        loanApp1.SaleDeedBetnBuyerBorr__c = 'N';
        loanApp1.OwnContriPaid__c = 'N';
        loanApp1.LetterFomSellerBTFinancier__c = 'N';
        loanApp1.ChequeForAmtEquiBTAmt__c = 'N';
        loanApp1.SellerVerificationKYCSellerTaken__c = 'N';
        loanApp1.SellerVerCredTeleChk__c = 'N';
        loanApp1.AllSellerBTNormMet__c = 'N';
        update loanApp1;
        /* List<String>erros = UWApprovalValidation.validateData('Approve', loanApp.Id);
system.debug('erros are' + erros.size());*/
        Boolean isAssert = true;
        try{
            Test.startTest();
            List<String>erross = UWApprovalValidation.validateData('Approve', loanApp.Id); 
            List<String>erross1 = UWApprovalValidation.validateData('Soft Approve', loanApp1.Id);
            
            Test.stopTest();    
        }catch(AuraHandledException ex){
            isAssert = false;
            system.assertEquals('Script-thrown exception', ex.getMessage());
        }  
        system.assertEquals(true, isAssert);
        
        
    }
    
    @isTest
    static void uwApprvalValnTestMethodFour() {
        SchMapping__c schMap = new SchMapping__c();
        schMap.SchemeDesc__c = 'BT';
        schMap.IsCostApplicable__c = true;
        insert schMap;
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        loanApp.IsSellerListDocLODAvl__c = null;
        loanApp.IsSellerBTLoanForeclosureAmt__c = 'N';
        loanApp.DocAsPerLegalReportMatches__c = 'N';
        loanApp.SaleDeedBetnBuyerBorr__c = 'N';
        loanApp.OwnContriPaid__c = 'N';
        loanApp.LetterFomSellerBTFinancier__c = 'N';
        loanApp.ChequeForAmtEquiBTAmt__c = 'N';
        loanApp.SellerVerificationKYCSellerTaken__c = 'N';
        loanApp.SellerVerCredTeleChk__c = 'N';
        loanApp.AllSellerBTNormMet__c = 'N';
        loanApp.Product__c = 'Small Ticket LAP';
        loanApp.ProductSubType__c = 'Commercial Property Purchase';
        loanApp.SchemeId__c = schMap.id;
        loanApp.ProductSubType__c = 'Seller BT - 100% Ready Property';
        update loanApp;
        Applicant__c app = TestDataFactory.createSingleApplicant(true,loanApp.id);
        app.LatestyearforwhichITRisavailable__c = 'ITR Not Available';
        app.Type_of_Borrower__c ='Financial';
        app.Constitution__c = 'HUF';
        update app;
        BTLoan__c btLoan = new BTLoan__c();
        btLoan.LoanAppl__c = LoanApp.id;
        btLoan.BTOriginalLoanAmt__c = null;
        btLoan.BTLoanOutstandingValue__c = 3434;
        btLoan.BTFinancier__c = 'Other';
        insert btLoan;
        
        APICoutTrckr__c apiCounTrckr = new APICoutTrckr__c();
        apiCounTrckr.LAN__c = loanApp.id;
        apiCounTrckr.Appl__c = app.id;
        apiCounTrckr.APIName__c = 'ENPADeatils';
        apiCounTrckr.IsInvalid__c = true;
        apiCounTrckr.LtstRespCode__c = 'Failure';
        TriggerBase.bypass('APICoutTrckr__c');
        insert apiCounTrckr;
        TriggerBase.clearBypass('APICoutTrckr__c');
        
        List<ApplAsset__c> appAssetList = new List<ApplAsset__c>();
        appAssetList.add(new ApplAsset__c(
            Property_Carpet_area_Sq_Ft__c = 12,
            Resi_Age__c = 2,
            Property_Usage__c = 'RENTED',
            PropIdentified__c ='Yes',
            PropSubType__c = 'added',
            PropSubTypeDesc__c ='TEST',
            LoanAppln__c = loanApp.Id,
            Appl__c = app.Id,
            ValuationToBeTakenAheadForCalculation__c = 87586
        ));
        appAssetList.add(new ApplAsset__c(
            Property_Carpet_area_Sq_Ft__c = 14,
            Resi_Age__c = 4,
            PropIdentified__c ='Yes',
            PropSubType__c = 'added',
            Property_Usage__c = 'VACANT',
            LoanAppln__c = loanApp.Id,
            Appl__c = app.Id
        ));
        appAssetList.add(new ApplAsset__c(
            Property_Carpet_area_Sq_Ft__c = 15,
            Resi_Age__c = 5,
            PropIdentified__c ='Yes',
            Property_Usage__c = 'PARTLY OCCUPIED AND PARTLY RENTED',
            LoanAppln__c = loanApp.Id,
            Appl__c = app.Id
        )); 
        appAssetList.add(new ApplAsset__c(
            Property_Carpet_area_Sq_Ft__c = 15,
            Resi_Age__c = 5,
            Property_Usage__c = 'PARTLY OCCUPIED AND PARTLY RENTED',
            LoanAppln__c = loanApp.Id,
            Appl__c = app.Id
        )); 
        appAssetList.add(new ApplAsset__c(
            Property_Carpet_area_Sq_Ft__c = 15,
            Resi_Age__c = 5,
            PropIdentified__c ='Yes',
            PropSubType__c = 'added',
            PropSubTypeDesc__c ='TEST',
            //NatureofProp__c = 'Showroom',
            Property_Usage__c = 'PARTLY OCCUPIED AND PARTLY RENTED',
            LoanAppln__c = loanApp.Id,
            Appl__c = app.Id
        ));
        appAssetList.add(new ApplAsset__c(
            Property_Carpet_area_Sq_Ft__c = 15,
            Resi_Age__c = 5,
            PropIdentified__c ='Yes',
            PropSubType__c = 'added',
            PropSubTypeDesc__c ='TEST',
            // NatureofProp__c = 'Showroom',
            Property_Usage__c = 'RENTED',
            LoanAppln__c = loanApp.Id,
            Appl__c = app.Id
        ));
        appAssetList.add(new ApplAsset__c(
            Property_Carpet_area_Sq_Ft__c = 15,
            Resi_Age__c = 5,
            PropIdentified__c ='Yes',
            PropSubType__c = 'added',
            PropSubTypeDesc__c ='TEST',
            // NatureofProp__c = 'Showroom',
            Approx_Age_of_Prop__c = 9,
            Property_Usage__c = 'PARTLY OCCUPIED AND PARTLY RENTED',
            LoanAppln__c = loanApp.Id,
            Appl__c = app.Id
        ));
        TriggerBase.bypass('ApplAsset__c');
        insert appAssetList;
        TriggerBase.clearBypass('ApplAsset__c');
        
        List<PD__c> pdList = new List<PD__c>();
        
        pdList.add(new PD__c(
            PDTyp__c = 'Physical PD',
            IsCompleted__c = true,
            PDStatus__c = 'Completed',
            Result__c = 'Negative',
            LoanAppl__c = loanApp.Id,
            Appl__c = app.Id
        )); 
        pdList.add(new PD__c(
            PDTyp__c = 'Physical PD',
            IsCompleted__c = true,
            PDStatus__c = 'Completed',
            Result__c = 'Positive',
            LoanAppl__c = loanApp.Id,
            Appl__c = app.Id
        )); 
        pdList.add(new PD__c(
            PDTyp__c = 'Physical PD',
            IsCompleted__c = false,
            PDStatus__c = 'Initiated',
            Result__c = 'Average',
            LoanAppl__c = loanApp.Id,
            Appl__c = app.Id
        ));
        TriggerBase.bypass('PD__c');
        insert pdList;
        TriggerBase.clearBypass('PD__c');
        
        Account acc = new Account(name='Acme');
        TriggerBase.bypass('Account');
        insert acc;
        TriggerBase.clearBypass('Account');
        List<Case> caseList = new List<Case>();
        Id cvRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
            .get('Collateral Visit').getRecordTypeId();
        Id technicalRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
            .get('Technical').getRecordTypeId();
        Id cpvfiRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
            .get('CPVFI').getRecordTypeId();
        Id rcuRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
            .get('RCU').getRecordTypeId();
        Id legalRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
            .get('Legal').getRecordTypeId();
        Id vettingRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
            .get('Vetting').getRecordTypeId();
        caseList.add(new Case(
            CVStatus__c = 'In Progress',
            Status = 'Query',
            IsReinitiated__c = false,
            ApplAssetId__c = appAssetList[0].Id,
            Loan_Application__c = loanApp.Id,
            Applicant__c = app.Id,
            //RecordTypeId = cvRecordTypeId
            RecordTypeId = rcuRecordTypeId
	 ));
        caseList.add(new Case(
            CVStatus__c = 'In Progress',
            Status = 'Query',
            IsReinitiated__c = false,
            IsCompleted__c = true,
            Property_Visit_Final_Status__c = 'Negative',
            ApplAssetId__c = appAssetList[0].Id,
            Loan_Application__c = loanApp.Id,
            Applicant__c = app.Id,
            RecordTypeId = cvRecordTypeId
        ));
        caseList.add(new Case(
            CVStatus__c = 'In Progress',
            Status = 'Query',
            IsReinitiated__c = false,
            AccountId = acc.Id,
            ApplAssetId__c = appAssetList[0].Id,
            Loan_Application__c = loanApp.Id,
            Applicant__c = app.Id,
            RecordTypeId = vettingRecordTypeId
        ));
        caseList.add(new Case(
            CVStatus__c = 'In Progress',
            Status = 'Closed',
            WaiveCPV__c = 'Yes',
            ApplAssetId__c = appAssetList[0].Id,
            Loan_Application__c = loanApp.Id,
            Applicant__c = app.Id,
            RecordTypeId = cpvfiRecordTypeId
        ));
       
        TriggerBase.bypass('Case');
        insert caseList;
        TriggerBase.clearBypass('Case');
        
        List<ApplBanking__c> appbankingList = new List<ApplBanking__c>();
        appbankingList.add(new ApplBanking__c(
            MICR_Code__c = '400240077',
            Repayment_bank_A_c__c = 'Yes',
            LoanAppl__c = loanApp.Id,
            Name_of_the_Primary_Account_Holder_s__c = 'TEST',
            AccountType__c = 'CURRENT',
            AC_No__c = null,
            BankName__c = 'ICICI Bank',
            Appl__c = app.Id
        ));
        appbankingList.add(new ApplBanking__c(
            Name_of_the_Primary_Account_Holder_s__c = 'TEST',
            AccountType__c = 'OVERDRAFT',
            AC_No__c = null,
            //BankName__c = 'ICICI Bank',
            LoanAppl__c = loanApp.Id,
            Appl__c = app.Id
        ));
        TriggerBase.bypass('ApplBanking__c');
        insert appbankingList;
        TriggerBase.clearBypass('ApplBanking__c');
        
        List<ApplBankDetail__c> appbankingDtlList = new List<ApplBankDetail__c>();
        
        appbankingDtlList.add(new ApplBankDetail__c(
            AverageBankBalance__c = 1000,
            BalanceAt_10th__c = 2000.00,
            BalanceAt_15th__c = 200.90,
            BalanceAt_20th__c = 200.90,
            BalanceAt_5th__c = 2000.00,
            BalanceAt_25th__c =100.00,
            BalanceAt_1st__c =100.00,
            CountofCredit__c = 10,
            CountofDebit__c =10,
            DailyABBBalance__c = 12.00,
            InwardReturnsCount__c =10,
            MinBalanceCharges__c = 'Y',
            OutwardReturnsCount__c = 23,
            StopPaymentCount__c = 12,
            ValueSummationDebit__c = 12,
            ValueSummationCredit__c = 12,
            ApplBanking__c = appbankingList[1].Id
        ));
        
        TriggerBase.bypass('ApplBankDetail__c');
        insert appbankingDtlList;
        TriggerBase.clearBypass('ApplBankDetail__c');
        
        List<SPDD_Approval_Config__c> spddList = new List<SPDD_Approval_Config__c>();
        spddList.add(new SPDD_Approval_Config__c(
            Dev_Level__c = '5',
            Sanction_Amt__c = 500000.00,
            Product__c = 'Home Loan',
            Emp__c = UserInfo.getUserId()
        ));
        TriggerBase.bypass('SPDD_Approval_Config__c');
        insert spddList;
        TriggerBase.clearBypass('SPDD_Approval_Config__c');
        
        List<Deviation__c> deviationList = new List<Deviation__c>();
        deviationList.add(new Deviation__c(
            Dev_Type__c = 'Manual',
            Req_Apprv_Level__c = '6',
            Appr_Actn__c = 'Rejected',
            LoanAppln__c = loanApp.Id
        ));
        deviationList.add(new Deviation__c(
            Dev_Type__c = 'Manual',
            Req_Apprv_Level__c = '4',
            Appr_Actn__c = 'Approved',
            LoanAppln__c = loanApp.Id
        ));
        TriggerBase.bypass('Deviation__c');
        insert deviationList;
        TriggerBase.clearBypass('Deviation__c');
        
        ApplicantEmployment__c appEmpDetil = new ApplicantEmployment__c();
        appEmpDetil.LoanApplicant__c = app.id;
        appEmpDetil.GST_Registered__c = 'Yes';
        insert appEmpDetil;
        
        ApplGST__c appGST = new ApplGST__c();
        appGST.Main_GSTIN__c = true;
        appGST.Applicant__c = app.id;
        insert appGST;
        
        List<ApplKyc__c> appKycList = new List<ApplKyc__c>();
        appKycList.add(new ApplKyc__c(
            Applicant__c = app.Id,
            kycDoc__c = 'Aadhaar'
        ));
        appKycList.add(new ApplKyc__c(
            Applicant__c = app.Id,
            kycDoc__c = 'Driving License'
        ));
        appKycList.add(new ApplKyc__c(
            Applicant__c = app.Id,
            kycDoc__c = 'Voter Id'
        ));
        appKycList.add(new ApplKyc__c(
            Applicant__c = app.Id,
            kycDoc__c = 'Passport'
        ));
        TriggerBase.bypass('ApplKyc__c');
        insert appKycList;
        TriggerBase.clearBypass('ApplKyc__c');
        
        List<DocDtl__c> docDtlList = new List<DocDtl__c>();
        docDtlList.add(new DocDtl__c(
            DocCatgry__c = 'KYC Documents',
            DocTyp__c = 'Residence Address proof - OVD',
            Appl__c = app.id,
            Applicant_KYC__c = appKycList[0].Id,
            LAN__c = loanApp.Id,
            DocSubTyp__c = 'Aadhaar'
        ));
        docDtlList.add(new DocDtl__c(
            DocCatgry__c = 'KYC Documents',
            DocTyp__c = 'Residence Address proof - OVD',
            Appl__c = app.id,
            Applicant_KYC__c = appKycList[1].Id,
            LAN__c = loanApp.Id,
            DocSubTyp__c = 'Driving License'
        ));
        docDtlList.add(new DocDtl__c(
            DocCatgry__c = 'KYC Documents',
            DocTyp__c = 'Residence Address proof - OVD',
            Appl__c = app.id,
            Applicant_KYC__c = appKycList[2].Id,
            LAN__c = loanApp.Id,
            DocSubTyp__c = 'Voter Id'
        ));
        docDtlList.add(new DocDtl__c(
            DocCatgry__c = 'KYC Documents',
            DocTyp__c = 'Residence Address proof - OVD',
            Appl__c = app.id,
            Applicant_KYC__c = appKycList[3].Id,
            LAN__c = loanApp.Id,
            DocSubTyp__c = 'Passport'
        ));
        TriggerBase.bypass('DocDtl__c');
        insert docDtlList;
        TriggerBase.clearBypass('DocDtl__c');
        //insert docDtl;
        
        Id dedupeRecordTypeId = Schema.SObjectType.DedupeResponse__c.getRecordTypeInfosByName()
            .get('Dedupe').getRecordTypeId();
        
        List<DedupeResponse__c> varDedupeListOne = New List<DedupeResponse__c>();  
        DedupeResponse__c varDedupeOne = New DedupeResponse__c();
        varDedupeOne.IntnlDeduRelevance__c = 'Accurate Match found';
        varDedupeOne.IntnalDeduperesremark__c = 'Match Found';
        varDedupeOne.IntrnlDeduperes__c = 'Positive Dedupe';
        varDedupeOne.IsLatest__c = TRUE;
        varDedupeOne.RecordTypeId = dedupeRecordTypeId;
        varDedupeOne.Applicant__c = app.id;
        varDedupeOne.LoanAppln__c = loanApp.id;
        varDedupeListOne.add(varDedupeOne);  
        insert varDedupeListOne;
        
		List<DedupeResponse__c> varDedupeListTwo = New List<DedupeResponse__c>();   
        DedupeResponse__c varDedupeTwo = New DedupeResponse__c();
        varDedupeTwo.IntnalDeduperesremark__c = 'Match Found';
        varDedupeTwo.IsLatest__c = TRUE;
        varDedupeTwo.RecordTypeId = dedupeRecordTypeId;
        varDedupeTwo.Applicant__c = app.id;
        varDedupeTwo.Dedupe__c = varDedupeListOne[0].Id;
        varDedupeTwo.LoanAppln__c = loanApp.id;
        varDedupeListTwo.add(varDedupeTwo);
        insert varDedupeListTwo;
        
        ApplRegltry__c varAppReg = New ApplRegltry__c();  	
        varAppReg.LoanAppln__c = loanApp.Id;
        varAppReg.Appl__c = app.Id;
        varAppReg.IsBorowrOrRelFFDir__c = null;
        varAppReg.FFDirRelIntrstAsSH__c = null;
        varAppReg.FFDirRelIntrstAsPart__c = 'No';
		insert varAppReg;

        RegltryPrsonl__c varRegPer = New RegltryPrsonl__c();
		varRegPer.DirName__c = 'Test Dir name';
		varRegPer.Desgntn__c = 'Engineer';
		varRegPer.Reltnshp__c = 'Test Relation';
		varRegPer.Applicant_Regulatory__c = varAppReg.Id;
		insert varRegPer;      
        
        ApplAddr__c appAdd = new ApplAddr__c();
        appAdd.Applicant__c = app.id;
        appAdd.AddrTyp__c = 'Other Address';
        insert appAdd;
        LoanAppl__c loanApp1 = TestDataFactory.createLoanApplication(true);
        loanApp1.IsSellerListDocLODAvl__c = 'N';
        loanApp1.IsSellerBTLoanForeclosureAmt__c = 'N';
        loanApp1.DocAsPerLegalReportMatches__c = 'N';
        loanApp1.SaleDeedBetnBuyerBorr__c = 'N';
        loanApp1.OwnContriPaid__c = 'N';
        loanApp1.LetterFomSellerBTFinancier__c = 'N';
        loanApp1.ChequeForAmtEquiBTAmt__c = 'N';
        loanApp1.SellerVerificationKYCSellerTaken__c = 'N';
        loanApp1.SellerVerCredTeleChk__c = 'N';
        loanApp1.AllSellerBTNormMet__c = 'N';
        Test.startTest();
        update loanApp1;
        
        Boolean isAssert = true;
        try{
           // Test.startTest();
            List<String>erross = UWApprovalValidation.validateData('Approve', loanApp.Id); 
            List<String>erross1 = UWApprovalValidation.validateData('Soft Approve', loanApp1.Id);
            
            Test.stopTest();    
        }catch(AuraHandledException ex){
            isAssert = false;
            system.assertEquals('Script-thrown exception', ex.getMessage());
        }  
        system.assertEquals(true, isAssert);
    }
    
    @isTest
    static void uwApprvalValnTestMethodFive() {
        SchMapping__c schMap = new SchMapping__c();
        schMap.SchemeDesc__c = 'BT';
        schMap.IsCostApplicable__c = true;
        insert schMap;
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        loanApp.IsSellerListDocLODAvl__c = null;
        loanApp.IsSellerBTLoanForeclosureAmt__c = 'N';
        loanApp.DocAsPerLegalReportMatches__c = 'N';
        loanApp.SaleDeedBetnBuyerBorr__c = 'N';
        loanApp.OwnContriPaid__c = 'N';
        loanApp.LetterFomSellerBTFinancier__c = 'N';
        loanApp.ChequeForAmtEquiBTAmt__c = 'N';
        loanApp.SellerVerificationKYCSellerTaken__c = 'N';
        loanApp.SellerVerCredTeleChk__c = 'N';
        loanApp.AllSellerBTNormMet__c = 'N';
        loanApp.Product__c = 'Small Ticket LAP';
        loanApp.ProductSubType__c = 'Commercial Property Purchase';
        loanApp.SchemeId__c = schMap.id;
        loanApp.ProductSubType__c = 'Seller BT - 100% Ready Property';
        update loanApp;
        Applicant__c app = TestDataFactory.createSingleApplicant(true,loanApp.id);
        app.Type_of_Borrower__c ='Financial';
        app.Constitution__c = 'PRIVATE LIMITED COMPANY';
		update app;
        BTLoan__c btLoan = new BTLoan__c();
        btLoan.LoanAppl__c = LoanApp.id;
        btLoan.BTOriginalLoanAmt__c = null;
        btLoan.BTLoanOutstandingValue__c = 3434;
        btLoan.BTFinancier__c = 'Other';
        insert btLoan;
        
        APICoutTrckr__c apiCounTrckr = new APICoutTrckr__c();
        apiCounTrckr.LAN__c = loanApp.id;
        apiCounTrckr.Appl__c = app.id;
        apiCounTrckr.APIName__c = 'ScreeningWachout';
        apiCounTrckr.IsInvalid__c = true;
        apiCounTrckr.LtstRespCode__c = 'Failure';
        TriggerBase.bypass('APICoutTrckr__c');
        insert apiCounTrckr;
        TriggerBase.clearBypass('APICoutTrckr__c');
        
        List<ApplAsset__c> appAssetList = new List<ApplAsset__c>();
        appAssetList.add(new ApplAsset__c(
            Property_Carpet_area_Sq_Ft__c = 12,
            Resi_Age__c = 2,
            Property_Usage__c = 'RENTED',
            PropIdentified__c ='Yes',
            PropSubType__c = 'added',
            PropSubTypeDesc__c ='TEST',
            LoanAppln__c = loanApp.Id,
            Appl__c = app.Id,
            ValuationToBeTakenAheadForCalculation__c = 87586
        ));
        appAssetList.add(new ApplAsset__c(
            Property_Carpet_area_Sq_Ft__c = 14,
            Resi_Age__c = 4,
            PropIdentified__c ='Yes',
            PropSubType__c = 'added',
            Property_Usage__c = 'VACANT',
            LoanAppln__c = loanApp.Id,
            Appl__c = app.Id
        ));
        appAssetList.add(new ApplAsset__c(
            Property_Carpet_area_Sq_Ft__c = 15,
            Resi_Age__c = 5,
            PropIdentified__c ='Yes',
            Property_Usage__c = 'PARTLY OCCUPIED AND PARTLY RENTED',
            LoanAppln__c = loanApp.Id,
            Appl__c = app.Id
        )); 
        appAssetList.add(new ApplAsset__c(
            Property_Carpet_area_Sq_Ft__c = 15,
            Resi_Age__c = 5,
            Property_Usage__c = 'PARTLY OCCUPIED AND PARTLY RENTED',
            LoanAppln__c = loanApp.Id,
            Appl__c = app.Id
        )); 
        appAssetList.add(new ApplAsset__c(
            Property_Carpet_area_Sq_Ft__c = 15,
            Resi_Age__c = 5,
            PropIdentified__c ='Yes',
            PropSubType__c = 'added',
            PropSubTypeDesc__c ='TEST',
            //NatureofProp__c = 'Showroom',
            Property_Usage__c = 'PARTLY OCCUPIED AND PARTLY RENTED',
            LoanAppln__c = loanApp.Id,
            Appl__c = app.Id
        ));
        appAssetList.add(new ApplAsset__c(
            Property_Carpet_area_Sq_Ft__c = 15,
            Resi_Age__c = 5,
            PropIdentified__c ='Yes',
            PropSubType__c = 'added',
            PropSubTypeDesc__c ='TEST',
            // NatureofProp__c = 'Showroom',
            Property_Usage__c = 'RENTED',
            LoanAppln__c = loanApp.Id,
            Appl__c = app.Id
        ));
        appAssetList.add(new ApplAsset__c(
            Property_Carpet_area_Sq_Ft__c = 15,
            Resi_Age__c = 5,
            PropIdentified__c ='Yes',
            PropSubType__c = 'added',
            PropSubTypeDesc__c ='TEST',
            // NatureofProp__c = 'Showroom',
            Approx_Age_of_Prop__c = 9,
            Property_Usage__c = 'PARTLY OCCUPIED AND PARTLY RENTED',
            LoanAppln__c = loanApp.Id,
            Appl__c = app.Id
        ));
        TriggerBase.bypass('ApplAsset__c');
        insert appAssetList;
        TriggerBase.clearBypass('ApplAsset__c');
        
        List<PD__c> pdList = new List<PD__c>();
        
        pdList.add(new PD__c(
            PDTyp__c = 'Physical PD',
            IsCompleted__c = true,
            PDStatus__c = 'Completed',
            Result__c = 'Negative',
            LoanAppl__c = loanApp.Id,
            Appl__c = app.Id
        )); 
        pdList.add(new PD__c(
            PDTyp__c = 'Physical PD',
            IsCompleted__c = true,
            PDStatus__c = 'Completed',
            Result__c = 'Positive',
            LoanAppl__c = loanApp.Id,
            Appl__c = app.Id
        )); 
        pdList.add(new PD__c(
            PDTyp__c = 'Physical PD',
            IsCompleted__c = false,
            PDStatus__c = 'Initiated',
            Result__c = 'Average',
            LoanAppl__c = loanApp.Id,
            Appl__c = app.Id
        ));
        TriggerBase.bypass('PD__c');
        insert pdList;
        TriggerBase.clearBypass('PD__c');
        
        Account acc = new Account(name='Acme');
        TriggerBase.bypass('Account');
        insert acc;
        TriggerBase.clearBypass('Account');
        List<Case> caseList = new List<Case>();
        Id cvRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
            .get('Collateral Visit').getRecordTypeId();
        Id technicalRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
            .get('Technical').getRecordTypeId();
        Id cpvfiRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
            .get('CPVFI').getRecordTypeId();
        Id rcuRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
            .get('RCU').getRecordTypeId();
        Id legalRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
            .get('Legal').getRecordTypeId();
        Id tsrRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
            .get('TSR').getRecordTypeId();
        caseList.add(new Case(
            CVStatus__c = 'In Progress',
            Status = 'Query',
            IsReinitiated__c = false,
            ApplAssetId__c = appAssetList[0].Id,
            Loan_Application__c = loanApp.Id,
            Applicant__c = app.Id,
            RecordTypeId = cvRecordTypeId
        ));
        caseList.add(new Case(
            CVStatus__c = 'In Progress',
            Status = 'Query',
            IsReinitiated__c = false,
            IsCompleted__c = true,
            Property_Visit_Final_Status__c = 'Negative',
            ApplAssetId__c = appAssetList[0].Id,
            Loan_Application__c = loanApp.Id,
            Applicant__c = app.Id,
            RecordTypeId = cvRecordTypeId
        ));
        caseList.add(new Case(
            CVStatus__c = 'In Progress',
            Status = 'Query',
            IsReinitiated__c = false,
            AccountId = acc.Id,
            ApplAssetId__c = appAssetList[0].Id,
            Loan_Application__c = loanApp.Id,
            Applicant__c = app.Id,
            RecordTypeId = tsrRecordTypeId
        ));
        caseList.add(new Case(
            CVStatus__c = 'In Progress',
            Status = 'Closed',
            WaiveCPV__c = 'Yes',
            ApplAssetId__c = appAssetList[0].Id,
            Loan_Application__c = loanApp.Id,
            Applicant__c = app.Id,
            RecordTypeId = cpvfiRecordTypeId
        ));
        /*  caseList.add(new Case(
CVStatus__c = 'In Progress',
ApplAssetId__c = appAssetList[0].Id,
Loan_Application__c = loanApp.Id,
Applicant__c = app.Id,
RecordTypeId = rcuRecordTypeId
));*/
        TriggerBase.bypass('Case');
        insert caseList;
        TriggerBase.clearBypass('Case');
        
        List<ApplBanking__c> appbankingList = new List<ApplBanking__c>();
        /*     appbankingList.add(new ApplBanking__c(
MICR_Code__c = '400240077',
Repayment_bank_A_c__c = 'Yes',
LoanAppl__c = loanApp.Id,
Name_of_the_Primary_Account_Holder_s__c = 'TEST',
AccountType__c = 'CURRENT',
AC_No__c = '123456789',
BankName__c = 'ICICI Bank',
Appl__c = app.Id
)); */
        /*  appbankingList.add(new ApplBanking__c(
Name_of_the_Primary_Account_Holder_s__c = 'TEST',
AccountType__c = 'OVERDRAFT',
AC_No__c = '123456789',
BankName__c = 'ICICI Bank',
LoanAppl__c = loanApp.Id,
Appl__c = app.Id
));*/
        TriggerBase.bypass('ApplBanking__c');
        // insert appbankingList;
        TriggerBase.clearBypass('ApplBanking__c');
        
        List<ApplBankDetail__c> appbankingDtlList = new List<ApplBankDetail__c>();
        
        appbankingDtlList.add(new ApplBankDetail__c(
            AverageBankBalance__c = 1000,
            BalanceAt_10th__c = 2000.00,
            BalanceAt_15th__c = 200.90,
            BalanceAt_20th__c = 200.90,
            BalanceAt_5th__c = 2000.00,
            BalanceAt_25th__c =100.00,
            BalanceAt_1st__c =100.00,
            CountofCredit__c = 10,
            CountofDebit__c =10,
            DailyABBBalance__c = 12.00,
            InwardReturnsCount__c =10,
            MinBalanceCharges__c = 'Y',
            OutwardReturnsCount__c = 23,
            StopPaymentCount__c = 12,
            ValueSummationDebit__c = 12,
            ValueSummationCredit__c = 12,
            ApplBanking__c = null
            //ApplBanking__c = appbankingList[1].Id
        ));
        
        TriggerBase.bypass('ApplBankDetail__c');
        //    insert appbankingDtlList;
        TriggerBase.clearBypass('ApplBankDetail__c');
        
        List<SPDD_Approval_Config__c> spddList = new List<SPDD_Approval_Config__c>();
        spddList.add(new SPDD_Approval_Config__c(
            Dev_Level__c = '5',
            Sanction_Amt__c = 500000.00,
            Product__c = 'Home Loan',
            Emp__c = UserInfo.getUserId()
        ));
        TriggerBase.bypass('SPDD_Approval_Config__c');
        insert spddList;
        TriggerBase.clearBypass('SPDD_Approval_Config__c');
        
        List<Deviation__c> deviationList = new List<Deviation__c>();
        deviationList.add(new Deviation__c(
            Dev_Type__c = 'Manual',
            Req_Apprv_Level__c = '6',
            Appr_Actn__c = 'Rejected',
            LoanAppln__c = loanApp.Id
        ));
        deviationList.add(new Deviation__c(
            Dev_Type__c = 'Manual',
            Req_Apprv_Level__c = '4',
            Appr_Actn__c = 'Approved',
            LoanAppln__c = loanApp.Id
        ));
        TriggerBase.bypass('Deviation__c');
        insert deviationList;
        TriggerBase.clearBypass('Deviation__c');
        
        ApplicantEmployment__c appEmpDetil = new ApplicantEmployment__c();
        appEmpDetil.LoanApplicant__c = app.id;
        appEmpDetil.GST_Registered__c = 'Yes';
        insert appEmpDetil;
        
        ApplGST__c appGST = new ApplGST__c();
        appGST.Main_GSTIN__c = true;
        appGST.Applicant__c = app.id;
        insert appGST;
        
        List<ApplKyc__c> appKycList = new List<ApplKyc__c>();
        appKycList.add(new ApplKyc__c(
            Applicant__c = app.Id,
            kycDoc__c = 'Aadhaar'
        ));
        appKycList.add(new ApplKyc__c(
            Applicant__c = app.Id,
            kycDoc__c = 'Driving License'
        ));
        appKycList.add(new ApplKyc__c(
            Applicant__c = app.Id,
            kycDoc__c = 'Voter Id'
        ));
        appKycList.add(new ApplKyc__c(
            Applicant__c = app.Id,
            kycDoc__c = 'Passport'
        ));
        TriggerBase.bypass('ApplKyc__c');
        insert appKycList;
        TriggerBase.clearBypass('ApplKyc__c');
        
        List<DocDtl__c> docDtlList = new List<DocDtl__c>();
        docDtlList.add(new DocDtl__c(
            DocCatgry__c = 'KYC Documents',
            DocTyp__c = 'Residence Address proof - OVD',
            Appl__c = app.id,
            Applicant_KYC__c = appKycList[0].Id,
            LAN__c = loanApp.Id,
            DocSubTyp__c = 'Aadhaar'
        ));
        docDtlList.add(new DocDtl__c(
            DocCatgry__c = 'KYC Documents',
            DocTyp__c = 'Residence Address proof - OVD',
            Appl__c = app.id,
            Applicant_KYC__c = appKycList[1].Id,
            LAN__c = loanApp.Id,
            DocSubTyp__c = 'Driving License'
        ));
        docDtlList.add(new DocDtl__c(
            DocCatgry__c = 'KYC Documents',
            DocTyp__c = 'Residence Address proof - OVD',
            Appl__c = app.id,
            Applicant_KYC__c = appKycList[2].Id,
            LAN__c = loanApp.Id,
            DocSubTyp__c = 'Voter Id'
        ));
        docDtlList.add(new DocDtl__c(
            DocCatgry__c = 'KYC Documents',
            DocTyp__c = 'Residence Address proof - OVD',
            Appl__c = app.id,
            Applicant_KYC__c = appKycList[3].Id,
            LAN__c = loanApp.Id,
            DocSubTyp__c = 'Passport'
        ));
        TriggerBase.bypass('DocDtl__c');
        insert docDtlList;
        TriggerBase.clearBypass('DocDtl__c');
        //insert docDtl;
        
         Id dedupeRecordTypeId = Schema.SObjectType.DedupeResponse__c.getRecordTypeInfosByName()
            .get('Dedupe').getRecordTypeId();
        
        List<DedupeResponse__c> varDedupeListOne = New List<DedupeResponse__c>();  
        DedupeResponse__c varDedupeOne = New DedupeResponse__c();
        varDedupeOne.IntnlDeduRelevance__c = 'Accurate Match found';
        varDedupeOne.IntnalDeduperesremark__c = 'Match Found';
        varDedupeOne.IntrnlDeduperes__c = 'Positive Dedupe';
        varDedupeOne.IsLatest__c = TRUE;
        varDedupeOne.RecordTypeId = dedupeRecordTypeId;
        varDedupeOne.Applicant__c = app.id;
        varDedupeOne.LoanAppln__c = loanApp.id;
        varDedupeListOne.add(varDedupeOne);  
        insert varDedupeListOne;
        
		List<DedupeResponse__c> varDedupeListTwo = New List<DedupeResponse__c>();   
        DedupeResponse__c varDedupeTwo = New DedupeResponse__c();
        varDedupeTwo.IntnlDeduRelevance__c = 'Accurate Match found';
        varDedupeTwo.IntnalDeduperesremark__c = 'Match Found';
        varDedupeTwo.IntrnlDeduperes__c = 'Positive Dedupe';
        varDedupeTwo.IsLatest__c = TRUE;
        varDedupeTwo.RecordTypeId = dedupeRecordTypeId;
        varDedupeTwo.Applicant__c = app.id;
        varDedupeTwo.Dedupe__c = varDedupeListOne[0].Id;
        varDedupeTwo.LoanAppln__c = loanApp.id;
        varDedupeListTwo.add(varDedupeTwo);
        insert varDedupeListTwo;
        
        ApplRegltry__c varAppReg = New ApplRegltry__c();  	
        varAppReg.LoanAppln__c = loanApp.Id;
        varAppReg.Appl__c = app.Id;
        varAppReg.IsBorowrOrRelFFDir__c = null;
        varAppReg.FFDirRelIntrstAsSH__c = null;
        varAppReg.FFDirRelIntrstAsPart__c = null;
		insert varAppReg;

        RegltryPrsonl__c varRegPer = New RegltryPrsonl__c();
		varRegPer.DirName__c = 'Test Dir name';
		varRegPer.Desgntn__c = 'Engineer';
		varRegPer.Reltnshp__c = 'Test Relation';
		varRegPer.Applicant_Regulatory__c = varAppReg.Id;
		insert varRegPer;
            
        
        Id applicantFinancialRecordTypeId = Schema.SObjectType.Applicant_Financial__c.getRecordTypeInfosByName()
            .get('Profit & Loss').getRecordTypeId();
        
        Applicant_Financial__c varAppFin = New Applicant_Financial__c();
        varAppFin.Loan_Applicant__c = app.id;
        varAppFin.RecordTypeId = applicantFinancialRecordTypeId;
        insert varAppFin;  
        
        Applicant_Financial_Summary__c varAppFinSum = New Applicant_Financial_Summary__c();
        varAppFinSum.Type_of_Accounts__c = 'Audited';
		//varAppFinSum.Date_of_Filing_ITR__c = Date.parse('12/27/2024');
	    varAppFinSum.Date_of_Filing_ITR__c = Date.newInstance(2024,12,27);
        varAppFinSum.Applicant_Financial__c = varAppFin.Id;
        insert varAppFinSum;
            
        ApplAddr__c appAdd = new ApplAddr__c();
        appAdd.Applicant__c = app.id;
        appAdd.AddrTyp__c = 'Other Address';
        insert appAdd;
        LoanAppl__c loanApp1 = TestDataFactory.createLoanApplication(true);
        loanApp1.IsSellerListDocLODAvl__c = 'N';
        loanApp1.IsSellerBTLoanForeclosureAmt__c = 'N';
        loanApp1.DocAsPerLegalReportMatches__c = 'N';
        loanApp1.SaleDeedBetnBuyerBorr__c = 'N';
        loanApp1.OwnContriPaid__c = 'N';
        loanApp1.LetterFomSellerBTFinancier__c = 'N';
        loanApp1.ChequeForAmtEquiBTAmt__c = 'N';
        loanApp1.SellerVerificationKYCSellerTaken__c = 'N';
        loanApp1.SellerVerCredTeleChk__c = 'N';
        loanApp1.AllSellerBTNormMet__c = 'N';
        Test.startTest();
        update loanApp1;
     //   Test.stopTest(); 
        /* List<String>erros = UWApprovalValidation.validateData('Approve', loanApp.Id);
system.debug('erros are' + erros.size());*/
        Boolean isAssert = true;
        try{
       //     Test.startTest();
            List<String>erross = UWApprovalValidation.validateData('Approve', loanApp.Id); 
            List<String>erross1 = UWApprovalValidation.validateData('Soft Approve', loanApp1.Id);
            
            Test.stopTest();    
        }catch(AuraHandledException ex){
            isAssert = false;
            system.assertEquals('Script-thrown exception', ex.getMessage());
        }  
        system.assertEquals(true, isAssert);
    }
    
    @isTest
    static void uwApprvalValnTestMethodSix() {
        SchMapping__c schMap = new SchMapping__c();
        schMap.SchemeDesc__c = 'BT';
        schMap.IsCostApplicable__c = true;
        insert schMap;
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        loanApp.IsSellerListDocLODAvl__c = null;
        loanApp.IsSellerBTLoanForeclosureAmt__c = 'N';
        loanApp.DocAsPerLegalReportMatches__c = 'N';
        loanApp.SaleDeedBetnBuyerBorr__c = 'N';
        loanApp.OwnContriPaid__c = 'N';
        loanApp.LetterFomSellerBTFinancier__c = 'N';
        loanApp.ChequeForAmtEquiBTAmt__c = 'N';
        loanApp.SellerVerificationKYCSellerTaken__c = 'N';
        loanApp.SellerVerCredTeleChk__c = 'N';
        loanApp.AllSellerBTNormMet__c = 'N';
        loanApp.Product__c = 'Small Ticket LAP';
        loanApp.ProductSubType__c = 'Commercial Property Purchase';
        loanApp.SchemeId__c = schMap.id;
        loanApp.ProductSubType__c = 'Seller BT - 100% Ready Property';
        update loanApp;
        Applicant__c app = TestDataFactory.createSingleApplicant(true,loanApp.id);
        app.Type_of_Borrower__c ='Financial';
        app.LatestyearforwhichITRisavailable__c = 'ITR Available';
        update app;
        BTLoan__c btLoan = new BTLoan__c();
        btLoan.LoanAppl__c = LoanApp.id;
        btLoan.BTOriginalLoanAmt__c = null;
        btLoan.BTLoanOutstandingValue__c = 3434;
        btLoan.BTFinancier__c = 'Other';
        insert btLoan;
        
        APICoutTrckr__c apiCounTrckr = new APICoutTrckr__c();
        apiCounTrckr.LAN__c = loanApp.id;
        apiCounTrckr.Appl__c = app.id;
        apiCounTrckr.APIName__c = 'Screening API';
        apiCounTrckr.IsInvalid__c = true;
        apiCounTrckr.LtstRespCode__c = 'Failure';
        TriggerBase.bypass('APICoutTrckr__c');
        insert apiCounTrckr;
        TriggerBase.clearBypass('APICoutTrckr__c');
        
        List<ApplAsset__c> appAssetList = new List<ApplAsset__c>();
        appAssetList.add(new ApplAsset__c(
            Property_Carpet_area_Sq_Ft__c = 12,
            Resi_Age__c = 2,
            Property_Usage__c = 'RENTED',
            PropIdentified__c ='Yes',
            PropSubType__c = 'added',
            PropSubTypeDesc__c ='TEST',
            LoanAppln__c = loanApp.Id,
            Appl__c = app.Id,
            ValuationToBeTakenAheadForCalculation__c = 87586
        ));
        appAssetList.add(new ApplAsset__c(
            Property_Carpet_area_Sq_Ft__c = 14,
            Resi_Age__c = 4,
            PropIdentified__c ='Yes',
            PropSubType__c = 'added',
            Property_Usage__c = 'VACANT',
            LoanAppln__c = loanApp.Id,
            Appl__c = app.Id
        ));
        appAssetList.add(new ApplAsset__c(
            Property_Carpet_area_Sq_Ft__c = 15,
            Resi_Age__c = 5,
            PropIdentified__c ='Yes',
            Property_Usage__c = 'PARTLY OCCUPIED AND PARTLY RENTED',
            LoanAppln__c = loanApp.Id,
            Appl__c = app.Id
        )); 
        appAssetList.add(new ApplAsset__c(
            Property_Carpet_area_Sq_Ft__c = 15,
            Resi_Age__c = 5,
            Property_Usage__c = 'PARTLY OCCUPIED AND PARTLY RENTED',
            LoanAppln__c = loanApp.Id,
            Appl__c = app.Id
        )); 
        appAssetList.add(new ApplAsset__c(
            Property_Carpet_area_Sq_Ft__c = 15,
            Resi_Age__c = 5,
            PropIdentified__c ='Yes',
            PropSubType__c = 'added',
            PropSubTypeDesc__c ='TEST',
            //NatureofProp__c = 'Showroom',
            Property_Usage__c = 'PARTLY OCCUPIED AND PARTLY RENTED',
            LoanAppln__c = loanApp.Id,
            Appl__c = app.Id
        ));
        appAssetList.add(new ApplAsset__c(
            Property_Carpet_area_Sq_Ft__c = 15,
            Resi_Age__c = 5,
            PropIdentified__c ='Yes',
            PropSubType__c = 'added',
            PropSubTypeDesc__c ='TEST',
            // NatureofProp__c = 'Showroom',
            Property_Usage__c = 'RENTED',
            LoanAppln__c = loanApp.Id,
            Appl__c = app.Id
        ));
        appAssetList.add(new ApplAsset__c(
            Property_Carpet_area_Sq_Ft__c = 15,
            Resi_Age__c = 5,
            PropIdentified__c ='Yes',
            PropSubType__c = 'added',
            PropSubTypeDesc__c ='TEST',
            // NatureofProp__c = 'Showroom',
            Approx_Age_of_Prop__c = 9,
            Property_Usage__c = 'PARTLY OCCUPIED AND PARTLY RENTED',
            LoanAppln__c = loanApp.Id,
            Appl__c = app.Id
        ));
        TriggerBase.bypass('ApplAsset__c');
        insert appAssetList;
        TriggerBase.clearBypass('ApplAsset__c');
        
        List<PD__c> pdList = new List<PD__c>();
        
        pdList.add(new PD__c(
            PDTyp__c = 'Physical PD',
            IsCompleted__c = true,
            PDStatus__c = 'Completed',
            Result__c = 'Negative',
            LoanAppl__c = loanApp.Id,
            Appl__c = app.Id
        )); 
        pdList.add(new PD__c(
            PDTyp__c = 'Physical PD',
            IsCompleted__c = true,
            PDStatus__c = 'Completed',
            Result__c = 'Negative',
            LoanAppl__c = loanApp.Id,
            Appl__c = app.Id
        )); 
        pdList.add(new PD__c(
            PDTyp__c = 'Physical PD',
            IsCompleted__c = true,
            PDStatus__c = 'Initiated',
            Result__c = 'Average',
            LoanAppl__c = loanApp.Id,
            Appl__c = app.Id
        ));
        TriggerBase.bypass('PD__c');
        insert pdList;
        TriggerBase.clearBypass('PD__c');
        
        Account acc = new Account(name='Acme');
        TriggerBase.bypass('Account');
        insert acc;
        TriggerBase.clearBypass('Account');
        List<Case> caseList = new List<Case>();
        Id cvRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
            .get('Collateral Visit').getRecordTypeId();
        Id technicalRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
            .get('Technical').getRecordTypeId();
        Id cpvfiRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
            .get('CPVFI').getRecordTypeId();
        Id rcuRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
            .get('RCU').getRecordTypeId();
        Id legalRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
            .get('Legal').getRecordTypeId();
        Id tsrRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
            .get('TSR').getRecordTypeId();
        caseList.add(new Case(
            CVStatus__c = 'In Progress',
            Status = 'Query',
            IsReinitiated__c = false,
            ApplAssetId__c = appAssetList[0].Id,
            Loan_Application__c = loanApp.Id,
            Applicant__c = app.Id,
            RecordTypeId = cvRecordTypeId
        ));
        caseList.add(new Case(
            CVStatus__c = 'In Progress',
            Status = 'Query',
            IsReinitiated__c = false,
            IsCompleted__c = true,
            Property_Visit_Final_Status__c = 'Negative',
            ApplAssetId__c = appAssetList[0].Id,
            Loan_Application__c = loanApp.Id,
            Applicant__c = app.Id,
            RecordTypeId = cvRecordTypeId
        ));
        caseList.add(new Case(
            CVStatus__c = 'In Progress',
            Status = 'Query',
            IsReinitiated__c = false,
            AccountId = acc.Id,
            ApplAssetId__c = appAssetList[0].Id,
            Loan_Application__c = loanApp.Id,
            Applicant__c = app.Id,
            RecordTypeId = tsrRecordTypeId
        ));
        caseList.add(new Case(
            CVStatus__c = 'In Progress',
            Status = 'Closed',
            WaiveCPV__c = 'Yes',
            ApplAssetId__c = appAssetList[0].Id,
            Loan_Application__c = loanApp.Id,
            Applicant__c = app.Id,
            RecordTypeId = cpvfiRecordTypeId
        ));
        /*  caseList.add(new Case(
CVStatus__c = 'In Progress',
ApplAssetId__c = appAssetList[0].Id,
Loan_Application__c = loanApp.Id,
Applicant__c = app.Id,
RecordTypeId = rcuRecordTypeId
));*/
        TriggerBase.bypass('Case');
        insert caseList;
        TriggerBase.clearBypass('Case');
        
        List<ApplBanking__c> appbankingList = new List<ApplBanking__c>();
        appbankingList.add(new ApplBanking__c(
            MICR_Code__c = '400240077',
            Repayment_bank_A_c__c = 'Yes',
            LoanAppl__c = loanApp.Id,
            Name_of_the_Primary_Account_Holder_s__c = 'TEST',
            AccountType__c = 'CURRENT',
            AC_No__c = '123456789',
            BankName__c = 'ICICI Bank',
            Appl__c = app.Id,
            ConsideredForABBProgram__c = 'Yes'
        ));
        appbankingList.add(new ApplBanking__c(
            Name_of_the_Primary_Account_Holder_s__c = 'TEST',
            AccountType__c = 'OVERDRAFT',
            AC_No__c = '123456789',
            BankName__c = 'ICICI Bank',
            LoanAppl__c = loanApp.Id,
            Appl__c = app.Id
        ));
        TriggerBase.bypass('ApplBanking__c');
        insert appbankingList;
        TriggerBase.clearBypass('ApplBanking__c');
        
        List<ApplBankDetail__c> appbankingDtlList = new List<ApplBankDetail__c>();
        
        appbankingDtlList.add(new ApplBankDetail__c(
            AverageBankBalance__c = 1000,
            BalanceAt_10th__c = 2000.00,
            BalanceAt_15th__c = 200.90,
            BalanceAt_20th__c = 200.90,
            BalanceAt_5th__c = 2000.00,
            BalanceAt_25th__c =100.00,
            BalanceAt_1st__c =100.00,
            CountofCredit__c = 10,
            CountofDebit__c =10,
            DailyABBBalance__c = 12.00,
            InwardReturnsCount__c =10,
            MinBalanceCharges__c = 'Y',
            OutwardReturnsCount__c = 23,
            StopPaymentCount__c = 12,
            ValueSummationDebit__c = 12,
            ValueSummationCredit__c = 12,
           // ApplBanking__c = appbankingList[1].Id
            ApplBanking__c = appbankingList[0].Id
        ));
        
        TriggerBase.bypass('ApplBankDetail__c');
        insert appbankingDtlList;
        TriggerBase.clearBypass('ApplBankDetail__c');
        
        List<SPDD_Approval_Config__c> spddList = new List<SPDD_Approval_Config__c>();
        spddList.add(new SPDD_Approval_Config__c(
            Dev_Level__c = '5',
            Sanction_Amt__c = 500000.00,
            Product__c = 'Home Loan',
            Emp__c = UserInfo.getUserId()
        ));
        TriggerBase.bypass('SPDD_Approval_Config__c');
        insert spddList;
        TriggerBase.clearBypass('SPDD_Approval_Config__c');
        
        List<Deviation__c> deviationList = new List<Deviation__c>();
        deviationList.add(new Deviation__c(
            Dev_Type__c = 'Manual',
            Req_Apprv_Level__c = '6',
            Appr_Actn__c = 'Rejected',
            LoanAppln__c = loanApp.Id
        ));
        deviationList.add(new Deviation__c(
            Dev_Type__c = 'Manual',
            Req_Apprv_Level__c = '4',
            Appr_Actn__c = 'Approved',
            LoanAppln__c = loanApp.Id
        ));
        TriggerBase.bypass('Deviation__c');
        insert deviationList;
        TriggerBase.clearBypass('Deviation__c');
        
        ApplicantEmployment__c appEmpDetil = new ApplicantEmployment__c();
        appEmpDetil.LoanApplicant__c = app.id;
        appEmpDetil.GST_Registered__c = 'Yes';
        insert appEmpDetil;
        
        ApplGST__c appGST = new ApplGST__c();
        appGST.Main_GSTIN__c = true;
        appGST.Applicant__c = app.id;
        insert appGST;
        
        List<ApplKyc__c> appKycList = new List<ApplKyc__c>();
        appKycList.add(new ApplKyc__c(
            Applicant__c = app.Id,
            kycDoc__c = 'Aadhaar'
        ));
        appKycList.add(new ApplKyc__c(
            Applicant__c = app.Id,
            kycDoc__c = 'Driving License'
        ));
        appKycList.add(new ApplKyc__c(
            Applicant__c = app.Id,
            kycDoc__c = 'Voter Id'
        ));
        appKycList.add(new ApplKyc__c(
            Applicant__c = app.Id,
            kycDoc__c = 'Passport'
        ));
        TriggerBase.bypass('ApplKyc__c');
        insert appKycList;
        TriggerBase.clearBypass('ApplKyc__c');
        
        List<DocDtl__c> docDtlList = new List<DocDtl__c>();
        docDtlList.add(new DocDtl__c(
            DocCatgry__c = 'KYC Documents',
            DocTyp__c = 'Residence Address proof - OVD',
            Appl__c = app.id,
            Applicant_KYC__c = appKycList[0].Id,
            LAN__c = loanApp.Id,
            DocSubTyp__c = 'Aadhaar'
        ));
        docDtlList.add(new DocDtl__c(
            DocCatgry__c = 'KYC Documents',
            DocTyp__c = 'Residence Address proof - OVD',
            Appl__c = app.id,
            Applicant_KYC__c = appKycList[1].Id,
            LAN__c = loanApp.Id,
            DocSubTyp__c = 'Driving License'
        ));
        docDtlList.add(new DocDtl__c(
            DocCatgry__c = 'KYC Documents',
            DocTyp__c = 'Residence Address proof - OVD',
            Appl__c = app.id,
            Applicant_KYC__c = appKycList[2].Id,
            LAN__c = loanApp.Id,
            DocSubTyp__c = 'Voter Id'
        ));
        docDtlList.add(new DocDtl__c(
            DocCatgry__c = 'KYC Documents',
            DocTyp__c = 'Residence Address proof - OVD',
            Appl__c = app.id,
            Applicant_KYC__c = appKycList[3].Id,
            LAN__c = loanApp.Id,
            DocSubTyp__c = 'Passport'
        ));
        TriggerBase.bypass('DocDtl__c');
        insert docDtlList;
        TriggerBase.clearBypass('DocDtl__c');
        //insert docDtl;
        
       Id applicantFinancialRecordTypeId = Schema.SObjectType.Applicant_Financial__c.getRecordTypeInfosByName()
            .get('Profit & Loss').getRecordTypeId();
        
        Applicant_Financial__c varAppFin = New Applicant_Financial__c();
        varAppFin.Loan_Applicant__c = app.id;
        varAppFin.RecordTypeId = applicantFinancialRecordTypeId;
        insert varAppFin;  
        
        Applicant_Financial_Summary__c varAppFinSum = New Applicant_Financial_Summary__c();
        varAppFinSum.Type_of_Accounts__c = 'Audited';
      //varAppFinSum.Date_of_Filing_ITR__c = Date.parse('12/27/2024');
        varAppFinSum.Date_of_Filing_ITR__c = Date.newInstance(2024,12,27);
        varAppFinSum.Applicant_Financial__c = varAppFin.Id;
        insert varAppFinSum;        
        
        
        ApplAddr__c appAdd = new ApplAddr__c();
        appAdd.Applicant__c = app.id;
        appAdd.AddrTyp__c = 'Other Address';
        insert appAdd;
    /*    LoanAppl__c loanApp1 = TestDataFactory.createLoanApplication(true);
        loanApp1.IsSellerListDocLODAvl__c = 'N';
        loanApp1.IsSellerBTLoanForeclosureAmt__c = 'N';
        loanApp1.DocAsPerLegalReportMatches__c = 'N';
        loanApp1.SaleDeedBetnBuyerBorr__c = 'N';
        loanApp1.OwnContriPaid__c = 'N';
        loanApp1.LetterFomSellerBTFinancier__c = 'N';
        loanApp1.ChequeForAmtEquiBTAmt__c = 'N';
        loanApp1.SellerVerificationKYCSellerTaken__c = 'N';
        loanApp1.SellerVerCredTeleChk__c = 'N';
        loanApp1.AllSellerBTNormMet__c = 'N';
        update loanApp1;*/
        /* List<String>erros = UWApprovalValidation.validateData('Approve', loanApp.Id);
system.debug('erros are' + erros.size());*/
        Boolean isAssert = true;
        try{
            Test.startTest();
            List<String>erross = UWApprovalValidation.validateData('Approve', loanApp.Id); 
          /*  List<String>erross1 = UWApprovalValidation.validateData('Soft Approve', loanApp1.Id);*/
            
            Test.stopTest();    
        }catch(AuraHandledException ex){
            isAssert = false;
            system.assertEquals('Script-thrown exception', ex.getMessage());
        }  
        system.assertEquals(true, isAssert);
    }
    
    
    
}