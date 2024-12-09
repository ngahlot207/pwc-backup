@isTest
private class FileUploadControllerPOCTest {
    
    @testSetup
    public static void testData(){
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);        
        Applicant__c applicant = TestDataFactory.createSingleApplicant(true, loanApp.Id);
        DocMstr__c docMstr = TestDataFactory.createDocumentMaster(true, 'Master document');
        
        
    }

        @isTest
    public static void updateApplicantAddressTest(){
        LoanAppl__c loanApp = [SELECT Id,Name FROM LoanAppl__c LIMIT 1];     
        Applicant__c applicant = [SELECT Id,Name FROM Applicant__c WHERE LoanAppln__c = :loanApp.Id LIMIT 1];  
        DocMstr__c docMstr = [SELECT Id,Name FROM DocMstr__c LIMIT 1]; 
        ApplKyc__c appKyc = [SELECT Id, Name,ValidationStatus__c FROM ApplKyc__c LIMIT 1];

        ApplAddr__c aplAddrs = new ApplAddr__c(Applicant__c = applicant.Id, AddrTyp__c = 'Residence Address');
        insert aplAddrs;

        appKyc.ValidationStatus__c = GlobalConstants.MSG_SUCCESS;
        appKyc.Pincode__c = '123123';
        update appKyc;
        
        DocDtl__c docDtl = TestDataFactory.createDocumentDetail(false, 'Test', applicant.Id, docMstr.Id);
        docDtl.DocTyp__c ='Residence Address proof - OVD';
        docDtl.Applicant_KYC__c = appKyc.Id;

        insert docDtl;
          Test.startTest();
        List<ContentVersion> uploadedFiles = FileUploadControllerPOC.getUploadedFiles(applicant.Id);
        Test.stopTest();


    }


    // Add additional test methods to cover other functionalities if needed
}