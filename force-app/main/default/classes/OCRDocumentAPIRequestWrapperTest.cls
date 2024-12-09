@istest
public class OCRDocumentAPIRequestWrapperTest {

    @testsetup
    static void DrivingLiceReqGenTestfactory(){
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        
        Applicant__c appli =  TestDataFactory.createSingleApplicant(true,loanApp.id);  
        
         string appId = appli.id;
        
        IntgMsg__c newlit = new IntgMsg__c();
        newlit.Name = 'KYC OCR';
        newlit.BU__c = 'Vehicle Loan';
        newlit.Svc__c = 'KYC OCR';
        newlit.IsActive__c = true;
        newlit.RefId__c = appId;
        newlit.Status__c = 'New';
        newlit.MStatus__c = 'Blank';
        newlit.RefObj__c = 'Applicant__c'; 
       
        TriggerBase.bypass('IntgMsg__c');
        insert newlit;
        TriggerBase.clearBypass('IntgMsg__c'); 
    }
    
    static testmethod void OCRDocumentAPIRequestWrapperTestMethod(){
        
        IntgMsg__c newlit = [SELECT Id,RefId__c,Svc__c,ApiVersion__c FROM IntgMsg__c LIMIT 1];
        
        OCRDocumentAPIRequestWrapper ocrDocApiReqWra = new OCRDocumentAPIRequestWrapper();
        
        String returnValue = ocrDocApiReqWra.getWrapper('Some Random String We Can Pass', newlit);
        
        system.assertEquals(returnValue.length() > 0 , true);
    }
}