@isTest
private class UWForwardValidationsTest { 
    @testSetup
    static void testValidateData() {
        SchMapping__c schemeMaping = new SchMapping__c();
        schemeMaping.ApplicableOwnContribution__c = true;
        TriggerBase.bypass('SchMapping__c');
        insert schemeMaping;
        TriggerBase.clearBypass('SchMapping__c');
        
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        loanApp.Stage__c = 'Post Sanction';
        loanApp.SubStage__c = 'Data Entry';
        loanApp.DocGenReRequired__c = true;
        loanApp.DisbursalType__c = 'MULTIPLE';
        loanApp.SchemeId__c = schemeMaping.id;
        loanApp.OwnContriCash__c = null;
        TriggerBase.bypass('LoanAppl__c');
        update loanApp;
        TriggerBase.clearBypass('LoanAppl__c');
        
        Applicant__c app = TestDataFactory.createSingleApplicant(true,loanApp.id);
        
        app.UCID__c = null;
        
        TriggerBase.bypass('Applicant__c');
        update app;
        TriggerBase.clearBypass('Applicant__c');
        
        APICoutTrckr__c apiCounTrckr = new APICoutTrckr__c();
        apiCounTrckr.LAN__c = loanApp.id;
        apiCounTrckr.Appl__c = app.id;
        apiCounTrckr.APIName__c = 'Crif Auth Login';
        apiCounTrckr.IsInvalid__c = true;
        TriggerBase.bypass('APICoutTrckr__c');
        insert apiCounTrckr;
        TriggerBase.clearBypass('APICoutTrckr__c');
        
        Repayment_Account__c repaAcc = new Repayment_Account__c();
        repaAcc.Loan_Application__c = loanApp.Id;
        repaAcc.Is_Active__c  = True;
        repaAcc.Repayment_Mode__c = 'NACH';
        TriggerBase.bypass('Repayment_Account__c');
        insert repaAcc;
        TriggerBase.clearBypass('Repayment_Account__c');
        
        List<NACH__c> lstNach = new List<NACH__c>();
        NACH__c na = new NACH__c();
        na.eNACH_Registration_Status__c = 'test';
        na.eNACH_Rejection_Reasons__c = 'test';
        na.LoanAppl__c = loanApp.Id;
        na.RepayAcc__c = repaAcc.Id;
        na.Mandate_Type__c = 'Enach';
        na.IsActive__c = TRUE;
        lstNach.add(na);
        TriggerBase.bypass('NACH__c');
        insert lstNach;
        TriggerBase.clearBypass('NACH__c');
        
        List<RejectReason_eNACH__c> lstRejResNach = new List<RejectReason_eNACH__c>();
        RejectReason_eNACH__c rejResEnach = new RejectReason_eNACH__c();
        rejResEnach.RejectionReason__c = lstNach[0].eNACH_Rejection_Reasons__c;
        rejResEnach.ValidationMsg__c = 'Test';
        lstRejResNach.add(rejResEnach);
        TriggerBase.bypass('RejectReason_eNACH__c');
        insert lstRejResNach;
        TriggerBase.clearBypass('RejectReason_eNACH__c');
        
        
        List<PDC__c> pdcList = new List<PDC__c>();    
        pdcList.add(new PDC__c(
            Cheque_Amount__c = 20000.00,
            Cheque_Number_To__c = '121',
            Cheque_Number_From__c = '120',
            PDC_Type__c = 'SPDC',
            Repayment_Account__c = repaAcc.Id,
            Loan_Application__c = loanApp.Id
        ));
        
        TriggerBase.bypass('PDC__c');
        insert pdcList;
        TriggerBase.clearBypass('PDC__c');
        
        List<ApplRegltry__c> appRegulry = new List<ApplRegltry__c>();
        
        appRegulry.add(new ApplRegltry__c(
            IsBorowrOrRelFFDir__c = 'Yes',
            FFDirRelIntrstAsSH__c = 'Yes',
            FFDirRelIntrstAsPart__c = 'Yes',
            LoanAppln__c = loanApp.Id
        ));
        
        TriggerBase.bypass('ApplRegltry__c');
        insert appRegulry;
        TriggerBase.clearBypass('ApplRegltry__c');
        
        List<RegltryPrsonl__c> regPersonl = new List<RegltryPrsonl__c>();
        
        regPersonl.add(new RegltryPrsonl__c(
            Applicant_Regulatory__c = appRegulry[0].Id,
            Desgntn__c = null,
            Reltnshp__c = null
        ));
        
        TriggerBase.bypass('RegltryPrsonl__c');
        insert regPersonl;
        TriggerBase.clearBypass('RegltryPrsonl__c');
        
        List<Bureau__c> bureauList = new List<Bureau__c>();
        
        bureauList.add(new Bureau__c(
            Applicant__c = app.Id,
            IsLatest__c = true,
            BureauAPI__c = 'Consumer',
            LoanApp__c = loanApp.Id
        ));
        
        TriggerBase.bypass('Bureau__c');
        insert bureauList;
        TriggerBase.clearBypass('Bureau__c');
        
        List<NDC__c> ndcList = new List<NDC__c>();
        
        ndcList.add(new NDC__c(
            OpsQuery__c = true,
            ScreenNames__c = 'Tranche Details',
            IsInvalid__c = false,
            LoanAppl__c = loanApp.Id
        ));
        ndcList.add(new NDC__c(
            OpsQuery__c = true,
            NDC_Section__c = 'IMD Details',
            IsInvalid__c = false,
            NDC_Type__c = 'Scan Based Disbursement',
            LoanAppl__c = loanApp.Id
        ));
        TriggerBase.bypass('NDC__c');
        insert ndcList;
        TriggerBase.clearBypass('NDC__c');
        
        List<ApplIMD__c> allIMDs = new List<ApplIMD__c> ();
        allIMDs.add(new ApplIMD__c(
            PaymentMode__c = 'Cheque',
            LoanAppln__c = loanApp.Id
        ));
        allIMDs.add(new ApplIMD__c(
            PaymentMode__c = 'DD',
            LoanAppln__c = loanApp.Id
        ));
        TriggerBase.bypass('ApplIMD__c');
        insert allIMDs;
        TriggerBase.clearBypass('ApplIMD__c');
        
        Disbursement__c disc  = new Disbursement__c();
        disc.Loan_Appli__c = loanApp.Id;
        disc.Total_Disb_Amt__c = 900.00;
        disc.Disbur_To__c = 'CUSTOMER';
        disc.Disbur_No__c = 1;
        disc.Princ_Start_Date__c = Date.newInstance(2030, 12, 7);
        disc.Princ_Rec_on__c = 'AMOUNT DISBURSED TILL DATE';
        disc.Date_of_Disbur__c = Date.newInstance(2026, 12, 9);
        disc.DisbrDiscription__c = 'TRANCHE-1';
        disc.Disbur_Status__c = 'ENTERED';
        TriggerBase.bypass('Disbursement__c');
        insert disc;
        TriggerBase.clearBypass('Disbursement__c');
        List<Split_Disbur__c> splitDisList = new List<Split_Disbur__c>();
        splitDisList.add(new Split_Disbur__c(
            DisburseRela__c = disc.Id,
            Pay_Mode__c = 'Funds Transfer',
            Disbur_To__c = 'CUSTOMER',
            Split_Cheque_Amt__c =9000.00,
            Fedbank_Acc_Nm__c = 'ICICI BANK - DISB CONTROL A/C',
            Payable_At__c = 'MUMBAI',
            Cheq_DD_Date__c = null,
            Cheq_DD_No__c = null
        ));
        /* splitDisList.add(new Split_Disbur__c(
DisburseRela__c = disc.Id,
Pay_Mode__c = 'Draft'
));*/
        TriggerBase.bypass('Split_Disbur__c');
        insert splitDisList;
        TriggerBase.clearBypass('Split_Disbur__c');
        
        Disbursement__c disc1  = new Disbursement__c();
        disc1.Loan_Appli__c = loanApp.Id;
        disc1.Total_Disb_Amt__c = 900.00;
        disc1.Disbur_To__c = 'CUSTOMER';
        disc1.Disbur_No__c = 2;
        disc1.Princ_Start_Date__c = Date.newInstance(2030, 12, 7);
        disc1.Princ_Rec_on__c = 'AMOUNT DISBURSED TILL DATE';
        disc1.Date_of_Disbur__c = Date.newInstance(2027, 08, 09);
        disc1.DisbrDiscription__c = 'TRANCHE-2';
        TriggerBase.bypass('Disbursement__c');
        insert disc1;
        TriggerBase.clearBypass('Disbursement__c');
        List<Split_Disbur__c> splitDisList1 = new List<Split_Disbur__c>();
        splitDisList.add(new Split_Disbur__c(
            DisburseRela__c = disc1.Id,
            Pay_Mode__c = 'Funds Transfer',
            Disbur_To__c = 'CUSTOMER',
            Split_Cheque_Amt__c =9000.00,
            Fedbank_Acc_Nm__c = 'ICICI BANK - DISB CONTROL A/C',
            Payable_At__c = 'MUMBAI',
            Cheq_DD_Date__c = null,
            Cheq_DD_No__c = null
        ));
        
        TriggerBase.bypass('Split_Disbur__c');
        insert splitDisList1;
        TriggerBase.clearBypass('Split_Disbur__c');
        
        Disbursement__c disc2  = new Disbursement__c();
        disc2.Loan_Appli__c = loanApp.Id;
        disc2.Total_Disb_Amt__c = 900.00;
        disc2.Disbur_To__c = 'CUSTOMER';
        disc2.Disbur_No__c = 2;
        disc2.Princ_Start_Date__c = Date.newInstance(2030, 12, 7);
        disc2.Princ_Rec_on__c = 'AMOUNT DISBURSED TILL DATE	';
        disc2.Date_of_Disbur__c = Date.newInstance(2028, 08, 09);
        disc2.DisbrDiscription__c = 'TRANCHE-3';
        TriggerBase.bypass('Disbursement__c');
        insert disc2;
        TriggerBase.clearBypass('Disbursement__c');
        
        List<Split_Disbur__c> splitDisList2 = new List<Split_Disbur__c>();
        splitDisList.add(new Split_Disbur__c(
            DisburseRela__c = disc2.Id,
            Pay_Mode__c = 'Funds Transfer',
            Disbur_To__c = 'CUSTOMER',
            Split_Cheque_Amt__c =9000.00,
            Fedbank_Acc_Nm__c = 'ICICI BANK - DISB CONTROL A/C',
            Payable_At__c = 'MUMBAI',
            Cheq_DD_Date__c = null,
            Cheq_DD_No__c = null
        ));
        
        TriggerBase.bypass('Split_Disbur__c');
        insert splitDisList2;
        TriggerBase.clearBypass('Split_Disbur__c');
        
        ApplKyc__c ap = new ApplKyc__c();
        ap.Applicant__c = app.Id;
        ap.AadharEncripted__c = '123456789098';
        ap.Address__c = 'Pune';
        ap.DLNo__c = null;
        ap.kycDoc__c = 'Driving License';
        ap.kycId__c = '12345';
        TriggerBase.bypass('ApplKyc__c');
        insert ap;
        TriggerBase.clearBypass('ApplKyc__c');
        
        List<DocMstr__c> docMstrList = new List<DocMstr__c>();
        docMstrList.add(new DocMstr__c(
            Catgry__c = 'Mandatory Post Sanction Documents',
            DocTyp__c = 'Disbursal Documents',
            DocSubTyp__c = 'Repayment Documents SPDCs',
            Active__c = TRUE
        ));
        docMstrList.add(new DocMstr__c(
            Catgry__c = 'KYC Documents',
            DocTyp__c = 'Identity Proof',
            DocSubTyp__c = 'Repayment Documents SPDCs',
            Required__c = true,
            Active__c = TRUE
        ));
        TriggerBase.bypass('DocMstr__c');
        insert docMstrList;
        TriggerBase.clearBypass('DocMstr__c');
        
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
        TriggerBase.bypass('ApplAsset__c');
        insert appAssetList;
        TriggerBase.clearBypass('ApplAsset__c');
        
        List<DocDtl__c> docDtlList = new List<DocDtl__c>();
        docDtlList.add(new DocDtl__c(
            DocMstr__c = docMstrList[0].Id,
            LAN__c = loanApp.Id,
            DocStatus__c='COMPLETED',
            Applicant_KYC__c = ap.Id,
            // ApplAsset__c = Asset.Id,
            Appl__c = app.Id,
            DocCatgry__c = 'KYC Documents',
            DocTyp__c = 'Residence Address proof - OVD',
            DocSubTyp__c = 'Aadhaar',
            IsLatest__c = TRUE
        ));
        docDtlList.add(new DocDtl__c(
            DocMstr__c = docMstrList[0].Id,
            LAN__c = loanApp.Id,
            DocStatus__c='COMPLETED',
            Applicant_KYC__c = ap.Id,
            // ApplAsset__c = Asset.Id,
            Appl__c = app.Id,
            DocCatgry__c = 'KYC Documents',
            DocTyp__c = 'Residence Address proof - OVD',
            DocSubTyp__c = 'Voter Id',
            IsLatest__c = TRUE
        ));
        docDtlList.add(new DocDtl__c(
            DocMstr__c = docMstrList[0].Id,
            LAN__c = loanApp.Id,
            DocStatus__c = 'OTC',
            // ApplAsset__c = Asset.Id,
            Appl__c = app.Id,
            DocCatgry__c = 'CAM Report',
            DocTyp__c = 'CAM Report',
            DocSubTyp__c = 'CAM Report',
            IsLatest__c = TRUE
        ));
        docDtlList.add(new DocDtl__c(
            DocMstr__c = docMstrList[0].Id,
            LAN__c = loanApp.Id,
            // ApplAsset__c = Asset.Id,
            Appl__c = app.Id,
            DocCatgry__c = 'Insurance documents',
            DocTyp__c = 'General Insurance documents',
            DocSubTyp__c = 'General Insurance documents',
            IsLatest__c = TRUE
        ));
        docDtlList.add(new DocDtl__c(
            DocMstr__c = docMstrList[0].Id,
            LAN__c = loanApp.Id,
            // ApplAsset__c = Asset.Id,
            Appl__c = app.Id,
            DocCatgry__c = 'Insurance documents',
            DocTyp__c = 'Life Insurance documents',
            DocSubTyp__c = 'Life Insurance documents',
            IsLatest__c = TRUE
        ));
        docDtlList.add(new DocDtl__c(
            DocMstr__c = docMstrList[0].Id,
            LAN__c = loanApp.Id,
            DocStatus__c = 'OTC',
            // ApplAsset__c = Asset.Id,
            Appl__c = app.Id,
            DocCatgry__c = 'Sanction Letter',
            DocTyp__c = 'Sanction Letter',
            DocSubTyp__c = 'Sanction Letter',
            IsLatest__c = TRUE
        ));
        docDtlList.add(new DocDtl__c(
            DocMstr__c = docMstrList[0].Id,
            LAN__c = loanApp.Id,
            DocStatus__c = 'OTC',
            // ApplAsset__c = Asset.Id,
            Appl__c = app.Id,
            DocCatgry__c = 'Application Form',
            DocTyp__c = 'Application Form',
            DocSubTyp__c = 'Application Form',
            IsLatest__c = TRUE
        ));
         docDtlList.add(new DocDtl__c(
            DocMstr__c = docMstrList[0].Id,
            LAN__c = loanApp.Id,
            DocStatus__c = 'OTC',
            // ApplAsset__c = Asset.Id,
            Appl__c = app.Id,
            DocCatgry__c = 'Additional Post Sanction Documents',
            DocTyp__c = 'Residence Address proof - Deemed OVD',
            DocSubTyp__c = 'Aadhaar Acknowledgment for address change',
            IsLatest__c = TRUE
        ));
        docDtlList.add(new DocDtl__c(
            DocMstr__c = docMstrList[0].Id,
            LAN__c = loanApp.Id,
            DocStatus__c='PDD',
            Applicant_KYC__c = ap.Id,
            // ApplAsset__c = Asset.Id,
            Appl__c = app.Id,
            DocCatgry__c = 'Additional Post Sanction Documents',
            DocTyp__c = 'Disbursal Documents',
            DocSubTyp__c = 'RESIDENCE ADDRESS PROOF - OVD',
            IsLatest__c = TRUE
        ));
        docDtlList.add(new DocDtl__c(
            DocMstr__c = docMstrList[0].Id,
            LAN__c = loanApp.Id,
            DocStatus__c = 'OTC',
            ApplAsset__c = appAssetList[0].Id,
            Appl__c = app.Id,
            DocCatgry__c = 'Case Documents',
            DocTyp__c = 'Technical Verification Documents',
            DocSubTyp__c = 'Technical Report',
            IsLatest__c = TRUE
        ));
        docDtlList.add(new DocDtl__c(
            DocMstr__c = docMstrList[0].Id,
            LAN__c = loanApp.Id,
            DocStatus__c = 'OTC',
            ApplAsset__c = appAssetList[0].Id,
            Appl__c = app.Id,
            DocCatgry__c = 'Property Documents',
            DocTyp__c = 'Repayment Documents',
            DocSubTyp__c = 'Repayment Documents PDCs',
            IsLatest__c = TRUE
        ));
        TriggerBase.bypass('DocDtl__c');
        insert docDtlList;
        TriggerBase.clearBypass('DocDtl__c');
        
     List<Insurance__c> insList = new List<Insurance__c>();   
        insList.add(new Insurance__c(
            LoanAppln__c = loanApp.Id,
            Appl__c = app.Id,
            InsType__c = 'Life Insurance',
            IsActive__c = TRUE
        ));
        insList.add(new Insurance__c(
            LoanAppln__c = loanApp.Id,
            Appl__c = app.Id,
            InsType__c = 'General Insurance',
            IsActive__c = TRUE
        ));
        TriggerBase.bypass('Insurance__c');
        insert insList;
        TriggerBase.clearBypass('Insurance__c');
        DocumentCheckController.DocDetailWrapper wrp = new DocumentCheckController.DocDetailWrapper();
        wrp.docCategry='KYC Documents';
        wrp.docDetName='PAN';
        wrp.docDetType='Identity Proof';
        
        DocMstr__c docMst = new DocMstr__c();
        docMst.Prod__c = loanApp.Product__c;
        docMst.DocTyp__c = wrp.docDetType;
        docMst.Catgry__c=wrp.docCategry;
        docMst.Active__c =true;
        docMst.Required__c = true ;
        TriggerBase.bypass('DocMstr__c');
        insert docMst;
        TriggerBase.clearBypass('DocMstr__c');
        
        DocDtl__c doc = new DocDtl__c();
        
        doc.DocTyp__c = wrp.docDetType;
        doc.DocCatgry__c = wrp.docCategry;
        doc.DocSubTyp__c = wrp.docDetName;
        doc.LAN__c=loanApp.Id;
        doc.Appl__c = app.Id;
        doc.DocMstr__c = docMst.Id;
        doc.DocStatus__c='COMPLETED';
        TriggerBase.bypass('DocDtl__c');
        insert doc;
        TriggerBase.clearBypass('DocDtl__c');
        
        DocDtl__c doc1 = new DocDtl__c();
        
        doc1.DocTyp__c = wrp.docDetType;
        doc1.DocCatgry__c = wrp.docCategry;
        doc1.DocSubTyp__c = wrp.docDetName;
        doc1.LAN__c=loanApp.Id;
        doc1.Appl__c = app.Id;
        doc1.DocMstr__c = docMst.Id;
        doc1.DocStatus__c='OTC';
        TriggerBase.bypass('DocDtl__c');
        insert doc1;
        TriggerBase.clearBypass('DocDtl__c');
        
        Account acc = new Account(name='Acme');
        TriggerBase.bypass('Account');
        insert acc;
        TriggerBase.clearBypass('Account');
        
        List<Case> caseList = new List<Case>();
        Id rcuRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
            .get('RCU').getRecordTypeId();
        caseList.add(new Case(
            CVStatus__c = 'In Progress',
            ApplAssetId__c = appAssetList[0].Id,
            Loan_Application__c = loanApp.Id,
            Applicant__c = app.Id,
            RecordTypeId = rcuRecordTypeId,
            ReportResult__c = 'Pending'
        ));
        TriggerBase.bypass('Case');
        insert caseList;
        TriggerBase.clearBypass('Case');
        
    }
    
    @isTest
    static void uwForwardVaTestMethod() {
        LoanAppl__c loanApp = [SELECT Id,Loan_Tenure_Months__c,Product__c,BrchCode__c,ReqLoanAmt__c FROM LoanAppl__c LIMIT 1];
        Boolean isAssertt = true;
        try{
            Test.startTest();
            List<String>erross = UWForwardValidations.validateData(loanApp.Id);   
            Test.stopTest();      
        }catch(AuraHandledException ex){
            isAssertt = false;
            system.assertEquals('Script-thrown exception', ex.getMessage());
        }  
        system.assertEquals(true, isAssertt);
    }
    @isTest
    static void uwForwardVaTestMethodOne() {
        LoanAppl__c loanApp = [SELECT Id,Loan_Tenure_Months__c,Product__c,BrchCode__c,ReqLoanAmt__c FROM LoanAppl__c LIMIT 1];
        LoanAppl__c loanAp = new LoanAppl__c();
        loanAp.Id = loanApp.Id;
        loanAp.Stage__c = 'Post Sanction';
        loanAp.SubStage__c = 'Ops Query';
        loanApp.DisbursalType__c = 'MULTIPLE';
        loanApp.Product__c = 'Small Ticket LAP';
        TriggerBase.bypass('LoanAppl__c');
        update loanAp;
        TriggerBase.clearBypass('LoanAppl__c');
        
        Boolean isAssert = true;
        try{
            Test.startTest();
            List<String>erross = UWForwardValidations.validateData(loanAp.Id);   
            Test.stopTest();
        }catch(AuraHandledException ex){
            isAssert = false;
            system.assertEquals('Script-thrown exception', ex.getMessage());
        }  
    }
    
    /*  @isTest
static void uwForwardVaTestMethod2() {
LoanAppl__c loanAppp = [SELECT Id,Loan_Tenure_Months__c,Product__c,BrchCode__c,ReqLoanAmt__c FROM LoanAppl__c LIMIT 1];
LoanAppl__c loanApp = new LoanAppl__c();
loanApp.Id = loanAppp.Id;
loanApp.Stage__c = 'DDE';
loanApp.SubStage__c = 'CPA DATA ENTRY';
loanApp.DisbursalType__c = 'SINGLE';
TriggerBase.bypass('LoanAppl__c');
Update loanApp;
TriggerBase.clearBypass('LoanAppl__c');

Repayment_Account__c repAcc = new Repayment_Account__c();
repAcc.Is_Active__c = True;
repAcc.Loan_Application__c = loanApp.id;
TriggerBase.bypass('Repayment_Account__c');        
upsert repAcc;
TriggerBase.clearBypass('Repayment_Account__c');

Applicant__c app = TestDataFactory.createSingleApplicant(true,loanApp.id);
app.UCID__c = null;

TriggerBase.bypass('Applicant__c');
update app;
TriggerBase.clearBypass('Applicant__c');

List<PDC__c> pdcList = new List<PDC__c>();
PDC__c pdc = new PDC__c();
pdc.Loan_Application__c = loanApp.id;
pdc.Cheque_Amount__c = 9000;
pdc.Cheque_Number_To__c = '876897';
pdc.Cheque_Number_From__c = '789809';
pdc.Cheque_Purpose__c = 'SPDC';
pdc.Account_No__c= '9879809800';
pdc.MICR_Code__c = '560240065';
pdc.PDC_Type__c = 'SPDC';
pdc.Repayment_Account__c = repAcc.id;
pdcList.add(pdc);
TriggerBase.bypass('PDC__c');        
upsert pdcList;
TriggerBase.clearBypass('PDC__c');

ApplKyc__c ap = new ApplKyc__c();
ap.Applicant__c = app.Id;
ap.AadharEncripted__c = '123456789098';
ap.Address__c = 'Pune';
ap.DLNo__c = null;
ap.kycDoc__c = 'Driving License';
ap.kycId__c = '12345';
TriggerBase.bypass('ApplKyc__c');
insert ap;
TriggerBase.clearBypass('ApplKyc__c');

DocMstr__c docMst = new DocMstr__c();
docMst.Prod__c = loanApp.Product__c;
docMst.DocTyp__c = 'Identity Proof';
docMst.Catgry__c='KYC Documents';
docMst.Active__c =true;
docMst.Required__c = true ;
TriggerBase.bypass('DocMstr__c');
insert docMst;
TriggerBase.clearBypass('DocMstr__c');

DocDtl__c doc = new DocDtl__c();      
doc.DocTyp__c = 'Residence Address proof - OVD';
doc.DocCatgry__c = 'KYC Documents';
doc.DocSubTyp__c = 'Aadhaar';
doc.LAN__c=loanApp.Id;
doc.Appl__c = app.Id;
doc.DocMstr__c = docMst.Id;
doc.DocStatus__c='COMPLETED';
doc.Applicant_KYC__c = ap.Id;
TriggerBase.bypass('DocDtl__c');
insert doc;
TriggerBase.clearBypass('DocDtl__c');

DocDtl__c doc1 = new DocDtl__c();
doc1.DocTyp__c = 'Residence Address proof - OVD';
doc1.DocCatgry__c = 'KYC Documents';
doc1.DocSubTyp__c = 'Voter Id';
doc1.LAN__c=loanApp.Id;
doc1.Appl__c = app.Id;
doc1.DocMstr__c = docMst.Id;
doc1.DocStatus__c='OTC';
doc.Applicant_KYC__c = ap.Id;
TriggerBase.bypass('DocDtl__c');
insert doc1;
TriggerBase.clearBypass('DocDtl__c');

Bureau__c beur = new Bureau__c();
beur.LoanApp__c = loanApp.Id;
beur.Applicant__c = app.Id;
beur.BureauAPI__c = 'Consumer';
beur.IsLatest__c = true;
beur.ErrorMess__c = null;
TriggerBase.bypass('Bureau__c');
insert beur;
TriggerBase.clearBypass('Bureau__c');

APICoutTrckr__c apiCounTrckr = new APICoutTrckr__c();
apiCounTrckr.LAN__c = loanApp.id;
apiCounTrckr.Appl__c = app.id;
apiCounTrckr.APIName__c = 'Crif Auth Login';
apiCounTrckr.IsInvalid__c = true;
TriggerBase.bypass('APICoutTrckr__c');
insert apiCounTrckr;
TriggerBase.clearBypass('APICoutTrckr__c');

Disbursement__c disc  = new Disbursement__c();
disc.Loan_Appli__c = loanApp.Id;
disc.Total_Disb_Amt__c = 10000;
disc.Disbur_To__c = 'CUSTOMER';
disc.Disbur_No__c = 1;
disc.Princ_Start_Date__c = Date.newInstance(2020, 12, 7);
disc.Princ_Rec_on__c = 'AMOUNT DISBURSED TILL DATE	';
disc.Date_of_Disbur__c = Date.newInstance(2026, 12, 9);
disc.DisbrDiscription__c = 'TRANCHE-1';
TriggerBase.bypass('Disbursement__c');
insert disc;
TriggerBase.clearBypass('Disbursement__c');

List<Split_Disbur__c> splitDisList = new List<Split_Disbur__c>();
splitDisList.add(new Split_Disbur__c(
DisburseRela__c = disc.Id,
Pay_Mode__c = 'Funds Transfer',
Disbur_To__c = 'CUSTOMER',
Split_Cheque_Amt__c =9000.00,
Fedbank_Acc_Nm__c = 'ICICI BANK - DISB CONTROL A/C',
Payable_At__c = 'MUMBAI',
Cheq_DD_Date__c = null,
Cheq_DD_No__c = null
));

TriggerBase.bypass('Split_Disbur__c');
insert splitDisList;
TriggerBase.clearBypass('Split_Disbur__c');

Disbursement__c disc1  = new Disbursement__c();
disc1.Loan_Appli__c = loanApp.Id;
disc1.Total_Disb_Amt__c = 900.00;
disc1.Disbur_To__c = 'CUSTOMER';
disc1.Disbur_No__c = 2;
disc1.Princ_Start_Date__c = Date.newInstance(2020, 12, 7);
disc1.Princ_Rec_on__c = 'AMOUNT DISBURSED TILL DATE	';
disc1.Date_of_Disbur__c = Date.newInstance(2029, 08, 09);
disc1.DisbrDiscription__c = 'TRANCHE-2';
TriggerBase.bypass('Disbursement__c');
insert disc1;
TriggerBase.clearBypass('Disbursement__c');

List<Split_Disbur__c> splitDisList1 = new List<Split_Disbur__c>();
splitDisList.add(new Split_Disbur__c(
DisburseRela__c = disc1.Id,
Pay_Mode__c = 'Funds Transfer',
Disbur_To__c = 'CUSTOMER',
Split_Cheque_Amt__c =9000.00,
Fedbank_Acc_Nm__c = 'ICICI BANK - DISB CONTROL A/C',
Payable_At__c = 'MUMBAI',
Cheq_DD_Date__c = null,
Cheq_DD_No__c = null
));

TriggerBase.bypass('Split_Disbur__c');
insert splitDisList1;
TriggerBase.clearBypass('Split_Disbur__c');

Disbursement__c disc2  = new Disbursement__c();
disc2.Loan_Appli__c = loanApp.Id;
disc2.Total_Disb_Amt__c = 900.00;
disc2.Disbur_To__c = 'CUSTOMER';
disc2.Disbur_No__c = 2;
disc2.Princ_Start_Date__c = Date.newInstance(2020, 12, 7);
disc2.Princ_Rec_on__c = 'AMOUNT DISBURSED TILL DATE	';
disc2.Date_of_Disbur__c = Date.newInstance(2029, 08, 09);
disc2.DisbrDiscription__c = 'TRANCHE-2';
TriggerBase.bypass('Disbursement__c');
insert disc2;
TriggerBase.clearBypass('Disbursement__c');

List<Split_Disbur__c> splitDisList2 = new List<Split_Disbur__c>();
splitDisList.add(new Split_Disbur__c(
DisburseRela__c = disc2.Id,
Pay_Mode__c = 'Funds Transfer',
Disbur_To__c = 'CUSTOMER',
Split_Cheque_Amt__c =9000.00,
Fedbank_Acc_Nm__c = 'ICICI BANK - DISB CONTROL A/C',
Payable_At__c = 'MUMBAI',
Cheq_DD_Date__c = null
));

TriggerBase.bypass('Split_Disbur__c');
insert splitDisList2;
TriggerBase.clearBypass('Split_Disbur__c');

Boolean isAssert = true;
try{
Test.startTest();
List<String>erross = UWForwardValidations.validateData(loanApp.Id);   
Test.stopTest();
}catch(AuraHandledException ex){
isAssert = false;
system.assertEquals('Script-thrown exception', ex.getMessage());
}  
}*/
    
}