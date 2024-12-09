@istest
public class FileUploadCoApplicantTest {
    
     @testSetup
    public static void testData(){
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);        
        Applicant__c applicant = TestDataFactory.createSingleApplicant(true, loanApp.Id);
        DocMstr__c docMstr = TestDataFactory.createDocumentMaster(true, 'Master document');
        PincodeMstr__c pincode = new PincodeMstr__c(PIN__c = '123123');
        insert pincode;

        
    }
    
  @istest
    Static void uploadFiletest(){
   LoanAppl__c loanApp = [SELECT Id,Name FROM LoanAppl__c LIMIT 1];     
        Applicant__c applicant = [SELECT Id,Name FROM Applicant__c WHERE LoanAppln__c = :loanApp.Id LIMIT 1];        
       FileUploadCoApplicant.uploadFile('test12345','testfile',loanApp.id,applicant.id);
        
        
        }
    
    @istest
    static void getRelatedFilesByRecordIdtest(){
         LoanAppl__c loanApp = [SELECT Id,Name FROM LoanAppl__c LIMIT 1];     
        Applicant__c applicant = [SELECT Id,Name FROM Applicant__c WHERE LoanAppln__c = :loanApp.Id LIMIT 1];   
        
        ApplKyc__c ak=new ApplKyc__c();
       ak.Applicant__c=applicant.id;
       ak.kycDoc__c='Aadhaar';
       ak.AadharEncripted__c='492515815873';
       insert ak;
        
        DocDtl__c dd=new DocDtl__c();
        dd.Appl__c=applicant.id;
        dd.Applicant_KYC__c=ak.id;
        insert dd;
        
       
       
       ContentVersion cv = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'test.docx',
            VersionData = Blob.valueOf('Test document content')
          
        );
        insert cv;
       
       ContentVersion cvv = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
    ContentDocumentLink cdl = new ContentDocumentLink(
            LinkedEntityId = dd.Id,
            ContentDocumentId = cvv.ContentDocumentId,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert cdl;
       
        
        FileUploadCoApplicant.getRelatedFilesByRecordId(loanApp.id,applicant.id);
     FileUploadCoApplicant.deleteFileRecord(cvv.ContentDocumentId);
       
        
    }

}