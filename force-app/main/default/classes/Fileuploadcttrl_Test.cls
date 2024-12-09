@isTest
public class Fileuploadcttrl_Test {
    
 @testsetup
    Public static void insertDocumentDeatil(){
       LoanAppl__c loanApp = TestDataFactory.createLoanApplication(True); 
       Applicant__c applicant = TestDataFactory.createSingleApplicant(True,loanApp.Id);
       DocMstr__c docMaster = TestDataFactory.DocumentMasterData(True);
       DocDtl__c docDtl = TestDataFactory.createDocumentDetail(True,'Test',applicant.Id,docMaster.Id);
       docDtl.DocTyp__c = 'Sanction Letter';
       docDtl.IsLatest__c = true;
       docDtl.ValidityDays__c = -5;
       docDtl.LAN__c = loanApp.Id; 
       TriggerBase.bypass('Case');
       Update docDtl;
       TriggerBase.clearBypass('Case');        
    }
    
    @isTest
    Public static void test_fetchFiles(){
      List<DocDtl__c> lstDocdtl = [SELECT ID,DocTyp__c,IsLatest__c,ValidityDays__c FROM DocDtl__c WHERE  DocTyp__c = 'Sanction Letter' ]; 
      system.assert(!lstDocdtl.isEmpty(),'document detail list should not empty');
      Fileuploadcttrl.fetchFiles(lstDocdtl[0].Id);
    }

}