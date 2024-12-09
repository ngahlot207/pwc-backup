@isTest
public class GetDocumentDetails_Test {

	@testSetup
    static void testData(){
        Case testCase = TestDataFactory.CaseData(true);
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);     
        Applicant__c applicant = TestDataFactory.createSingleApplicant(true, loanApp.Id);
        
         // Create a test ContentVersion record (mocked file upload)
        ContentVersion testContentVersion = new ContentVersion(
            VersionData = Blob.valueOf('Sample File Content'), // Mocked file content
            Title = 'SampleFile.txt',
            PathOnClient = 'SampleFile.txt'
        );
        insert testContentVersion;      
        // Create a test DocumentMaster record
        DocMstr__c testDocumentMaster = new DocMstr__c(
            Bu__c = 'Home Loan',
            DocType__c = 'Physical Consent Proof',
            Prod__c = 'Home Loan',
            Active__c=true,
            Required__c= false
            // Add other required fields for DocMstr__c
        );
        insert testDocumentMaster;
        
        // Create a test DocumentDetail record
        DocDtl__c testDocumentDetail = new DocDtl__c(
            Appl__c = applicant.Id,
            DocCatgry__c = 'KYC Documents',
            DocSubTyp__c = 'Physical Consent Form',
            DocTyp__c = 'Address Proof',
            DocMstr__c = testDocumentMaster.Id , 
            Case__c = testCase.Id
        );
        insert testDocumentDetail;  
        
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:testContentVersion.Id].ContentDocumentId;
        ContentDocumentLink docLnk = new ContentDocumentLink(LinkedEntityId = testDocumentDetail.Id, ContentDocumentId  = conDocId);
        insert docLnk;
        
    }   
    
    @isTest
    static void getDocumentDataTest(){
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        GetDocumentDetails.getDocumentData(testCase.Id);
    }
    
    @isTest
    static void getFilePreviewDataTest(){
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        DocDtl__c docDtl = [SELECT Id, DocCatgry__c, DocSubTyp__c,DocTyp__c, File_Type__c FROM DocDtl__c where Case__c =: testCase.Id LIMIT 1];
        GetDocumentDetails.getFilePreviewData(docDtl.Id);
    }
    
    @isTest
    static void getFilePreviewDataListTest(){
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        DocDtl__c docDtl = [SELECT Id, DocCatgry__c, DocSubTyp__c,DocTyp__c, File_Type__c FROM DocDtl__c where Case__c =: testCase.Id LIMIT 1];
        GetDocumentDetails.getFilePreviewDataList(docDtl.Id);
    }
}