@isTest
public class VerificationExpiryTest {
    @testsetup
    Public static void insertVerficationData(){
       LoanAppl__c loanApp = TestDataFactory.createLoanApplication(True); 
       loanApp.ApprovedValidTill__c = date.today() -1;
       Update loanApp;
       Applicant__c applicant = TestDataFactory.createSingleApplicant(True,loanApp.Id);
       ApplAsset__c appAsset = TestDataFactory.applAssetData(True,applicant.Id);
       ApplAddr__c appAddress = TestDataFactory.applAddData(True,loanApp.Id,applicant.Id);

       Id dedupeRecordTypeId = Schema.SObjectType.DedupeResponse__c.getRecordTypeInfosByName().get('Dedupe').getRecordTypeId();
       DocMstr__c docMaster = TestDataFactory.DocumentMasterData(True);
       DocDtl__c docDtl = TestDataFactory.createDocumentDetail(True,'Test',applicant.Id,docMaster.Id);
       docDtl.DocTyp__c = 'Sanction Letter';
       docDtl.IsLatest__c = true;
       docDtl.ValidityDays__c = -5;
       docDtl.LAN__c = loanApp.Id; 
       Update docDtl;
        
       Id TSRRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('TSR').getRecordTypeId();
       Id legalRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Legal').getRecordTypeId();
       Id TechanicalRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Technical').getRecordTypeId();
       Id CollatralVisitRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Collateral Visit').getRecordTypeId();
       Id CpvRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('CPVFI').getRecordTypeId();
       Id deduberecordTypeId = Schema.SObjectType.DedupeResponse__c.getRecordTypeInfosByName().get('Dedupe').getRecordTypeId();

       Test.startTest();
        
       Deviation__c devtionObj = TestDataFactory.createDeviation(True,loanApp.Id,applicant.Id,'5716');
       Deviation__c devtionObj1 = TestDataFactory.createDeviation(True,loanApp.Id,applicant.Id,'5716');
       Deviation__c devtionObj2 = TestDataFactory.createDeviation(True,loanApp.Id,applicant.Id,'5716');
       Deviation__c devtionObj3 = TestDataFactory.createDeviation(True,loanApp.Id,applicant.Id,'5716');
       Deviation__c devtionObj4 = TestDataFactory.createDeviation(True,loanApp.Id,applicant.Id,'5716');
       Deviation__c devtionObj5 = TestDataFactory.createDeviation(True,loanApp.Id,applicant.Id,'5716');
       Deviation__c devtionObj6 = TestDataFactory.createDeviation(True,loanApp.Id,applicant.Id,'5716');
       Deviation__c devtionObj7 = TestDataFactory.createDeviation(True,loanApp.Id,applicant.Id,'5716');
       Deviation__c devtionObj8 = TestDataFactory.createDeviation(True,loanApp.Id,applicant.Id,'5716');
        

       Case objCase = TestDataFactory.CaseData(true);
       objCase.ValidityDays__c = -3;
       objCase.Loan_Application__c = loanApp.Id;
       objCase.ApplAssetId__c=appAsset.Id;
       objCase.RecordTypeId =legalRecordTypeId;
       objCase.Date_of_Report__c = date.today();
       objCase.Status = 'Closed';
       TriggerBase.bypass('Case');
       Update objCase;
       TriggerBase.clearBypass('Case');
        
       Case objCase1 = TestDataFactory.CaseData(true);
       objCase1.ValidityDays__c = -3;
       objCase1.Loan_Application__c = loanApp.Id;
       objCase1.ApplAssetId__c=appAsset.Id;
       objCase1.RecordTypeId =TSRRecordTypeId;
       objCase1.Date_of_Report__c = date.today();
       objCase1.Status = 'Closed';
       TriggerBase.bypass('Case');
       Update objCase1;
       TriggerBase.clearBypass('Case');
        
       Case objCase2 = TestDataFactory.CaseData(true);
       objCase2.ValidityDays__c = -3;
       objCase2.Loan_Application__c = loanApp.Id;
       objCase2.ApplAssetId__c = appAsset.Id;
       objCase2.RecordTypeId =CollatralVisitRecordTypeId;
       objCase2.DateofVisit__c = date.today();
       objCase2.Date_of_Report__c = date.today();
       objCase2.ReportResult__c = 'Positive';
       objCase2.Status = 'Closed';
        
       TriggerBase.bypass('Case');
       Update objCase2;
       TriggerBase.clearBypass('Case');
        
       Case objCase5 = TestDataFactory.CaseData(true);
       objCase5.ValidityDays__c = -3;
       objCase5.Loan_Application__c = loanApp.Id;
       objCase5.ApplAddr__c = appAddress.Id;
       objCase5.RecordTypeId =CpvRecordTypeId;
       objCase5.DateofVisit__c = date.today();
       objCase5.Applicant__c =applicant.Id;
       objCase5.IsMandatory__c = true;
       objCase5.Status = 'Closed';
       objCase5.ReportResult__c = 'Positive';
       TriggerBase.bypass('Case');
       Update objCase5;
       TriggerBase.clearBypass('Case');
        
       Case objCase6 = TestDataFactory.CaseData(true);
       objCase6.RecordTypeId = TechanicalRecordTypeId;
       objCase6.IsReinitiatedExpired__c = false;
       objCase6.ValidityDays__c = -10; 
       objCase6.Loan_Application__c = loanapp.Id;
       objCase6.ApplAssetId__c = appAsset.Id;
       objCase6.Date_of_Report__c = date.today();
       objCase6.Status = 'Closed'; 
       
       TriggerBase.bypass('Case');
       Update objCase6;
       TriggerBase.clearBypass('Case');
     
       APIVer__c apiVer = TestDataFactory.createAPIVerification(True,loanApp.Id,applicant.Id,'Watchout');
       apiVer.IsLatest__c = True;
       apiVer.ValidityDays__c = -5;
       TriggerBase.bypass('APIVer__c');
       Update apiVer;
       TriggerBase.clearBypass('APIVer__c'); 
       
       DedupeResponse__c objDedupe = new DedupeResponse__c();
       objDedupe.Applicant__c = applicant.Id;
       objDedupe.RecordTypeId= deduberecordTypeId;
       objDedupe.IsLatest__c = true; 
       objDedupe.LoanAppln__c = loanApp.Id;
       TriggerBase.bypass('DedupeResponse__c');
       Insert objDedupe;
       TriggerBase.clearBypass('DedupeResponse__c'); 
        
       objDedupe.ValidityDays__c = -10;
       Update objDedupe;
       
        
       HunterVer__c objHunter = new  HunterVer__c();
       objHunter.Appl__c = applicant.Id;
       objHunter.LoanAplcn__c = loanApp.Id;
       objHunter.IsLatest__c = true;
       TriggerBase.bypass('HunterVer__c');
       Insert objHunter;
       TriggerBase.clearBypass('HunterVer__c'); 
       objHunter.ValidityDays__c = -10;
       TriggerBase.bypass('HunterVer__c');
       Update objHunter;
       TriggerBase.clearBypass('HunterVer__c'); 
        
       TriggerBase.bypass('Applicant__c');
       applicant.CustProfile__c = 'OTHERS';
       Update applicant;
       TriggerBase.clearBypass('Applicant__c');
        
       PD__c pd = new PD__c();
       pd.LoanAppl__c = loanApp.Id;
       pd.Appl__c = applicant.Id;
       pd.PDStatus__c = 'Initiated';
       pd.CmpltDt__c =date.today();
       pd.PdTyp__c = 'Physical PD';
       TriggerBase.bypass('PD__c');
       insert pd;
       TriggerBase.clearBypass('PD__c');
       pd.ValidityDays__c = -5;
       TriggerBase.bypass('PD__c');
       Update pd;
       TriggerBase.clearBypass('PD__c');
       Test.stopTest();   
    }
    
    @isTest
    Public static void testMethodVerificationExpiry_1(){
      List<LoanAppl__c> loanApp = [Select Id From LoanAppl__c Limit 1];
      system.assert(!loanApp.isEmpty(),'loanApp List Should not empty');
      List<Applicant__c> Applicantlst = [Select Id From Applicant__c Limit 1];
        try{
      VerificationExpiry.expiryDetail(loanApp[0].Id); 
        }catch(Exception e){
            
        }
     
    }
    
}