@isTest
public class ScanBasedDisbursementCommTest {
    
@TestSetup
    Public static void testData(){
        LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
        DocDispatch__c docDisp = new DocDispatch__c();
        docDisp.LoanAppln__c = loan.Id;
        TriggerBase.bypass('DocDispatch__c');
        Insert docDisp;
        TriggerBase.clearBypass('DocDispatch__c');
    }
    
    @isTest
    Public static void testmethod1(){
        List<DocDispatch__c> lstDocment = [SELECT ID FROM DocDispatch__c];
        ScanBasedDisbursementCommunication scanBased = new ScanBasedDisbursementCommunication();
        scanBased.DocDisPatchId = lstDocment[0].Id;
        scanBased.getDocumentDispatchDtl();
        
    }


}