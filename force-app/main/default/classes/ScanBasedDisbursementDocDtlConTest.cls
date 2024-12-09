@isTest
public class ScanBasedDisbursementDocDtlConTest {
    
    @testsetup 
    Public static void insertData(){
        LoanAppl__c loanApp =  TestDataFactory.createLoanApplication(True);
        Applicant__c applicant = TestDataFactory.createSingleApplicant(true,loanApp.Id);
        DocMstr__c docData = TestDataFactory.DocumentMasterData(True);
        DocDtl__c docDtl = TestDataFactory.createDocumentDetail(True,'Test',applicant.Id,docData.Id);
        docDtl.PhyFileRec__c = 'Query';   
        docDtl.LAN__c = loanApp.Id;
        TriggerBase.bypass('DocDtl__c');
        Update docDtl;
        TriggerBase.clearBypass('DocDtl__c');   
        
    }
    
    @isTest
    Public static void testmethod1(){
        List<DocDtl__c> lstDocDtl = [SELECT ID, LAN__c,PhyFileRec__c FROM DocDtl__c ];
        system.assert(!lstDocDtl.isEmpty(),' lstDocDtl list should not empty');
        ScanBasedDisbursementDocDtlController.allDocumentRealtedInfor(lstDocDtl[0].LAN__c , 'Test');
    }
    
}