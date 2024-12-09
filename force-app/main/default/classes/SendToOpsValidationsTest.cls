@isTest
public class SendToOpsValidationsTest {
    @testsetup
    Public static void insertData(){
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(True);
        loanApp.Stage__c = 'Post Sanction';
        loanApp.DisbursalType__c = 'Single';
        loanApp.Stage__c = 'Post Sanction';
        loanApp.SubStage__c = 'Ops Query';
        loanApp.RemPFDeductFromDisbursementAmount__c = 'Yes';
        loanApp.SanLoanAmt__c  = 1233;
        loanApp.InsAmt__c = 122; 
        loanApp.EffectiveNextIntStartDt__c = Date.newInstance(2016, 12, 9);
        TriggerBase.bypass('LoanAppl__c');
        Update loanApp;
        TriggerBase.clearBypass('LoanAppl__c');
        system.debug('PendingDisbursalAmount:' +loanApp.PendingDisbursalAmount__c);
        
        Applicant__c appli = TestDataFactory.createSingleApplicant(True,loanApp.Id);
        Disbursement__c objDis = new  Disbursement__c();
        objDis.Loan_Appli__c = loanApp.Id;
        objDis.Total_Disb_Amt__c = 1200;
        objDis.Disbur_To__c = 'CUSTOMER';
        objDis.Princ_Rec_on__c = 'AMOUNT FINANCED';
        objDis.Princ_Start_Date__c = date.today();
        objDis.Date_of_Disbur__c = date.today();
        objDis.DisbrDiscription__c = 'TRANCHE-1';
        TriggerBase.bypass('Disbursement__c');
        Insert objDis; 
        TriggerBase.clearBypass('Disbursement__c');
        
        Split_Disbur__c splitDis = new Split_Disbur__c();
        splitDis.DisburseRela__c = objDis.Id;
        splitDis.Pay_Mode__c = 'Cheque';
        splitDis.Disbur_To__c = 'Customer';
        splitDis.Split_Cheque_Amt__c = 123;
        splitDis.Fedbank_Acc_Nm__c = 'Test';
        splitDis.Payable_At__c = 'Test';
        TriggerBase.bypass('Split_Disbur__c');
        Insert splitDis;
        TriggerBase.clearBypass('Split_Disbur__c');
        
        Repayment_Account__c repayAcc = TestDataFactory.rePayAccData(True,loanApp.Id);
        repayAcc.Repayment_Mode__c = 'NACH';
        repayAcc.Is_Active__c = True;
        TriggerBase.bypass('Repayment_Account__c');
        Update repayAcc;
        TriggerBase.clearBypass('Repayment_Account__c');
        
        PDC__c objPdc = new  PDC__c();
        objPdc.Loan_Application__c =  loanApp.Id;
        objPdc.Repayment_Account__c =  repayAcc.Id;
        objPdc.Name = 'Test';
        objPdc.PDC_Type__c = 'SPDC';
        objPdc.Cheque_Number_To__c  = '12'; 
        objPdc.Cheque_Number_From__c = '10'; 
        TriggerBase.bypass('PDC__c');
        Insert objPdc;
        TriggerBase.clearBypass('PDC__c');
        
        Id RcuRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('RCU').getRecordTypeId();   
        Case objCase = TestDataFactory.CaseData(True);
        objCase.Loan_Application__c = loanApp.Id;
        objCase.RecordTypeId = RcuRecordTypeId;
        objCase.ValidityDays__c = -12;
        objCase.ReportResult__c = 'Pending';
        TriggerBase.bypass('Case');
        
        Update objCase;
        TriggerBase.clearBypass('Case');
        Id legalRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Legal').getRecordTypeId();
        ApplAsset__c appAsset = TestDataFactory.applAssetData(True,appli.Id);
        
        Case objCase1 = TestDataFactory.CaseData(true);
        objCase1.ValidityDays__c = -3;
        objCase1.Loan_Application__c = loanApp.Id;
        objCase1.ApplAssetId__c=appAsset.Id;
        objCase1.RecordTypeId =legalRecordTypeId;
        objCase1.Date_of_Report__c = date.today();
        objCase1.Status = 'Closed';
        TriggerBase.bypass('Case');
        Update objCase1;
        TriggerBase.clearBypass('Case');
        
        DeviaMstr__c objdevMaster = new DeviaMstr__c();
        objdevMaster.Deviation_Category__c = 'Post Sanction Auto Deviation';
        TriggerBase.bypass('DeviaMstr__c');
        Insert objdevMaster;
        TriggerBase.clearBypass('DeviaMstr__c');  
        
        Deviation__c objDeviation = TestDataFactory.createDeviation(True,loanApp.Id,appli.Id,'5935');
        objDeviation.DeviationMaster__c = objdevMaster.Id;
        TriggerBase.bypass('Deviation__c');
        Update objDeviation;
        TriggerBase.clearBypass('Deviation__c'); 
        
        DocMstr__c docMast = TestDataFactory.createDocumentMaster(True,'Test');
        DocDtl__c appDocDet = TestDataFactory.createDocumentDetail(True,'Property Documents',appli.Id,docMast.Id);
        appDocDet.DocCatgry__c = 'Property Documents';
        appDocDet.DocStatus__c = 'OTC';
        appDocDet.LAN__c = loanApp.Id;
        appDocDet.Appr_Actn__c = 'Rejected';
        TriggerBase.bypass('DocDtl__c');
        Update appDocDet;
        TriggerBase.clearBypass('DocDtl__c'); 
        
        NDC__c objNdc = new NDC__c();
        objNdc.LoanAppl__c = loanApp.Id;
        objNdc.IsInvalid__c = false;
        objNdc.OpsQuery__c = true;
        objNdc.ScreenNames__c = 'RCU';
        objNdc.NDC_Section__c = 'IMD Details';
        objNdc.NDC_Type__c	= 'Scan Based Disbursement';
        TriggerBase.bypass('NDC__c');
        Insert objNdc;
        TriggerBase.clearBypass('NDC__c'); 
        
        NDC__c objNdc1 = new NDC__c();
        objNdc1.LoanAppl__c = loanApp.Id;
        objNdc1.IsInvalid__c = false;
        objNdc1.OpsQuery__c = true;
        objNdc1.NDC_Section__c = 'IMD Details';
        TriggerBase.bypass('NDC__c');
        Insert objNdc1;
        TriggerBase.clearBypass('NDC__c'); 
        
        NACH__c objNach = new NACH__c();
        objNach.LoanAppl__c = loanApp.Id;
        objNach.RepayAcc__c = repayAcc.Id;
        objNach.Mandate_Type__c = 'Enach';
        objNach.eNACH_Rejection_Reasons__c = 'Test';
        objNach.IsActive__c = true;
        TriggerBase.bypass('NACH__c');
        Insert  objNach;
        TriggerBase.clearBypass('NACH__c'); 
        
        RejectReason_eNACH__c objRejResNach = new RejectReason_eNACH__c();
        objRejResNach.ValidationMsg__c = 'Test';
        objRejResNach.RejectionReason__c = 'Test';
        TriggerBase.bypass('RejectReason_eNACH__c');
        Insert objRejResNach;    
        TriggerBase.clearBypass('RejectReason_eNACH__c');
        
         List<DocMstr__c> docMstrList = new List<DocMstr__c>();
        docMstrList.add(new DocMstr__c(
            Catgry__c = 'Mandatory Post Sanction Documents',
            DocTyp__c = 'Disbursal Documents',
            DocSubTyp__c = 'Repayment Documents SPDCs',
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
            Appl__c = appli.Id,
            ValuationToBeTakenAheadForCalculation__c = 87586
        ));
        TriggerBase.bypass('ApplAsset__c');
        insert appAssetList;
        TriggerBase.clearBypass('ApplAsset__c');
        
        List<DocDtl__c> docDtlList = new List<DocDtl__c>();
        docDtlList.add(new DocDtl__c(
            DocMstr__c = docMstrList[0].Id,
            LAN__c = loanApp.Id,
            DocStatus__c = 'OTC',
           // ApplAsset__c = Asset.Id,
            Appl__c = appli.Id,
            DocCatgry__c = 'CAM Report',
            DocTyp__c = 'CAM Report',
            DocSubTyp__c = 'CAM Report',
            IsLatest__c = TRUE
        ));
         docDtlList.add(new DocDtl__c(
            DocMstr__c = docMstrList[0].Id,
            LAN__c = loanApp.Id,
            // ApplAsset__c = Asset.Id,
            Appl__c = appli.Id,
            DocCatgry__c = 'Insurance documents',
            DocTyp__c = 'General Insurance documents',
            DocSubTyp__c = 'General Insurance documents',
            IsLatest__c = TRUE
        ));
        docDtlList.add(new DocDtl__c(
            DocMstr__c = docMstrList[0].Id,
            LAN__c = loanApp.Id,
            // ApplAsset__c = Asset.Id,
            Appl__c = appli.Id,
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
            Appl__c = appli.Id,
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
            Appl__c = appli.Id,
            DocCatgry__c = 'Application Form',
            DocTyp__c = 'Application Form',
            DocSubTyp__c = 'Application Form',
             IsLatest__c = TRUE
        ));
        docDtlList.add(new DocDtl__c(
            DocMstr__c = docMstrList[0].Id,
            LAN__c = loanApp.Id,
            DocStatus__c = 'OTC',
            ApplAsset__c = appAssetList[0].Id,
            Appl__c = appli.Id,
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
            Appl__c = appli.Id,
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
            Appl__c = appli.Id,
            InsType__c = 'Life Insurance',
            IsActive__c = TRUE
        ));
        insList.add(new Insurance__c(
            LoanAppln__c = loanApp.Id,
            Appl__c = appli.Id,
            InsType__c = 'General Insurance',
            IsActive__c = TRUE
        ));
        TriggerBase.bypass('Insurance__c');
        insert insList;
        TriggerBase.clearBypass('Insurance__c');
        
    }
    
    @isTest
    Public static void testSendToOpsValidations(){
        List<LoanAppl__c> lstLoanApp = [SELECT ID From LoanAppl__c];
        system.assert(!lstLoanApp.IsEmpty(),'Loan application list should not empty');
        Test.StartTest();
        SendToOpsValidations.validateData(lstLoanApp[0].Id);
        Test.StopTest();
    }
    
    @isTest
    Public static void testSendToOpsValidations12(){
        List<LoanAppl__c> lstLoanApp = [SELECT ID,Product__c From LoanAppl__c];
        system.assert(!lstLoanApp.IsEmpty(),'Loan application list should not empty');
        lstLoanApp[0].Product__c = 'Small Ticket LAP';
        TriggerBase.bypass('LoanAppl__c');
        Update lstLoanApp;
        TriggerBase.clearBypass('LoanAppl__c');
        
        List<DocDtl__c> lstDoctDtl = [SELECT ID,DocStatus__c FROM DocDtl__c];
        lstDoctDtl[0].DocStatus__c  = 'Received';
        TriggerBase.bypass('DocDtl__c');
        Update lstDoctDtl;
        TriggerBase.clearBypass('DocDtl__c');
        
        Test.StartTest();
        SendToOpsValidations.validateData(lstLoanApp[0].Id);
        Test.StopTest();
    }
    
    @isTest
    Public static void testSendToOpsValidations1(){
        List<applicant__c> lstLoanApp = [SELECT ID From applicant__c];
        Test.StartTest();
        try{
            SendToOpsValidations.validateData(lstLoanApp[0].Id);  
        }catch(Exception e){
            
        }
        Test.StopTest();
    }
    
}