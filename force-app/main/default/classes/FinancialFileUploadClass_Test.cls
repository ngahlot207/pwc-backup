@isTest
public class FinancialFileUploadClass_Test {
    
    @testSetup
    static void testData(){ 
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);     
        Applicant__c applicant = TestDataFactory.createSingleApplicant(true, loanApp.Id);
        ApplGST__c appGst = new ApplGST__c(Applicant__c = applicant.Id);
        insert appGst;
        DocMstr__c docMast = TestDataFactory.createDocumentMaster(true, 'ITR');
        Applicant_Financial__c appFinan = new Applicant_Financial__c(Loan_Applicant__c = applicant.Id, Income_Documents__c='Previous year ITR & computation');
        insert appFinan;
        DocDtl__c appDocDet = new DocDtl__c();
        appDocDet.DocTyp__c = 'Financials - P&L and BL';
        appDocDet.DocCatgry__c = 'Income Documents';
        appDocDet.IsLatest__c = true;
        appDocDet.Appl__c = applicant.Id;
        appDocDet.DocMstr__c = docMast.Id;
        appDocDet.DocSubTyp__c='Latest year Financials - P&L and BS';
        appDocDet.Appl__c = applicant.Id;
        appDocDet.LAN__c = loanApp.Id;
        insert appDocDet;
        
        
        DocDtl__c appDocDet1 = new DocDtl__c();
        appDocDet1.DocTyp__c = 'Income Tax Returns';
        appDocDet1.DocCatgry__c = 'Income Documents';
        appDocDet1.IsLatest__c = true;
        appDocDet1.Appl__c = applicant.Id;
        appDocDet1.DocMstr__c = docMast.Id;
        appDocDet1.DocSubTyp__c='Latest year Financials - P&L and BS';
        appDocDet1.Appl__c = applicant.Id;
        appDocDet1.LAN__c = loanApp.Id;
        insert appDocDet1;
        
        
        DocDtl__c appDocDet2 = new DocDtl__c();
        appDocDet2.DocTyp__c = 'Form 16';
        appDocDet2.DocCatgry__c = 'Income Documents';
        appDocDet2.IsLatest__c = true;
        appDocDet2.Appl__c = applicant.Id;
        appDocDet2.DocMstr__c = docMast.Id;
        appDocDet2.DocSubTyp__c='Latest year Financials - P&L and BS';
        appDocDet2.Appl__c = applicant.Id;
        appDocDet2.LAN__c = loanApp.Id;
        insert appDocDet2;
        
        
    }
    
    @isTest
    static void getGSTINValueTest(){
        LoanAppl__c loanApp = [SELECT Id,Name FROM LoanAppl__c LIMIT 1];  
        Applicant__c applicant = [SELECT Id,Name FROM Applicant__c WHERE LoanAppln__c = :loanApp.Id LIMIT 1];  
        
        FinancialFileUploadClass.getGSTINValue(applicant.Id);
    }
    
    @IsTest
    static void getRecordTypeValueTest(){
        FinancialFileUploadClass.getRecordTypeValue('Balance Sheet');
    }
    
    @IsTest
    static void documentTest(){
        LoanAppl__c loanApp = [SELECT Id,Name FROM LoanAppl__c LIMIT 1];  
        Applicant__c applicant = [SELECT Id,Name FROM Applicant__c WHERE LoanAppln__c = :loanApp.Id LIMIT 1];
        ApplGST__c parentRecord = [SELECT Id FROM ApplGST__c WHERE Applicant__c = :applicant.Id LIMIT 1];
        
        ContentVersion contVersion = new ContentVersion(Title = 'Test Document', PathOnClient = 'TestDocument.pdf',VersionData = Blob.valueOf('Test Content'));
        insert contVersion;
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contVersion.Id].ContentDocumentId;
        
        
        DocDtl__c docDtl = [SELECT Id, DocCatgry__c, DocSubTyp__c,DocTyp__c, File_Type__c FROM DocDtl__c  LIMIT 1];
        ContentDocumentLink docLnk = new ContentDocumentLink(LinkedEntityId = docDtl.Id, ContentDocumentId  = conDocId);
        insert docLnk;
        
        FinancialFileUploadClass.getRelatedFilesByRecordIdWire(loanApp.Id,applicant.Id , false, docDtl.Id);
        
        FinancialFileUploadClass.getRelatedFilesByRecordId(loanApp.Id,applicant.Id , false);
        
        FinancialFileUploadClass.deleteFileRecord(conDocId);
    }
    
    @IsTest
    static void financialDocTest(){
        LoanAppl__c loanApp = [SELECT Id,Name FROM LoanAppl__c LIMIT 1];  
        Applicant__c applicant = [SELECT Id,Name FROM Applicant__c WHERE LoanAppln__c = :loanApp.Id LIMIT 1];
        Applicant_Financial__c appFinan = [SELECT Id FROM Applicant_Financial__c WHERE Loan_Applicant__c = :applicant.Id LIMIT 1];
        
        ContentVersion contVersion = new ContentVersion(Title = 'Test Document', PathOnClient = 'TestDocument.pdf',VersionData = Blob.valueOf('Test Content'));
        insert contVersion;
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contVersion.Id].ContentDocumentId;
        
        DocDtl__c docDtl = [SELECT Id, DocCatgry__c, DocSubTyp__c,DocTyp__c, File_Type__c FROM DocDtl__c  LIMIT 1];
        ContentDocumentLink docLnk = new ContentDocumentLink(LinkedEntityId = docDtl.Id, ContentDocumentId  = conDocId);
        insert docLnk;
        FinancialFileUploadClass.getRelatedFilesFinancialByRecordIdWire(loanApp.Id, applicant.Id, docDtl.Id);
    }
    
    
    @IsTest
    static void getPicklistValuesTest(){
        LoanAppl__c loanApp = [SELECT Id,Name FROM LoanAppl__c LIMIT 1];  
        loanApp.AssesIncomeAppl__c = 'No';
        update loanApp;
        Applicant__c applicant = [SELECT Id,Name FROM Applicant__c WHERE LoanAppln__c = :loanApp.Id LIMIT 1];
        applicant.CustProfile__c = 'SELF EMPLOYED PROFESSIONAL';
        applicant.Constitution__c = 'INDIVIDUAL';
        applicant.Type_of_Borrower__c = 'Non Financial';
        
        update applicant;
        
        FinancialFileUploadClass.getPicklistValues(applicant.Id, loanApp.Id);
        
        applicant.CustProfile__c = 'SELF EMPLOYED NON PROFESSIONAL';
        applicant.Constitution__c = 'HUF';
        applicant.Type_of_Borrower__c = 'Financial';
        
        update applicant;
        
        FinancialFileUploadClass.getPicklistValues(applicant.Id, loanApp.Id);
        
    }
    
    @isTest
    static void testDeleteFileRecord() {
        LoanAppl__c loanApp = [SELECT Id,Name FROM LoanAppl__c LIMIT 1];  
        Applicant__c applicant = [SELECT Id,Name FROM Applicant__c WHERE LoanAppln__c = :loanApp.Id LIMIT 1];
        DocMstr__c docMst = TestDataFactory.createDocumentMaster(true,'PAN');
        DocDtl__c docDet = TestDataFactory.createDocumentDetail(true, 'PAN', applicant.Id, docMst.Id);
        ContentVersion testContentVersion = new ContentVersion(
            VersionData = Blob.valueOf('Test Content'),
            PathOnClient = 'TestDocument.pdf',
            Title = 'Test Document'
        );
        insert testContentVersion;
        docDet.Content_Document_Id__c=testContentVersion.Id;
        update docDet;
        
      //  FinancialFileUploadClass.deleteFileRecord(docDet.Id);
        
        // Verify that DocDtl__c records are deleted
        // System.assertEquals(null, [SELECT Id FROM DocDtl__c WHERE Id = :docDet.Id], 'DocDtl__c should be deleted');
        
        // Verify that ContentDocument is deleted
        // System.assertEquals(null, [SELECT Id FROM ContentDocument WHERE Id = :testContentVersion.ContentDocumentId], 'ContentDocument should be deleted');
    }
    
    @isTest
    static void testDeleteFileRecordWithInvalidInput() {
        // Test with invalid input
        String result = FinancialFileUploadClass.deleteFileRecord(null);
        System.assertEquals('FAILURE', result, 'Expected result is FAILURE for invalid input');
    }
    
    @isTest
    static void testDeleteFileRecordWithInvalidInput1() {
        // Test with invalid input
        LoanAppl__c loanApp = [SELECT Id,Name FROM LoanAppl__c LIMIT 1];  
        Applicant__c applicant = [SELECT Id,Name FROM Applicant__c WHERE LoanAppln__c = :loanApp.Id LIMIT 1];
        DocDtl__c docDtl = [SELECT Id, DocCatgry__c, DocSubTyp__c,DocTyp__c, File_Type__c FROM DocDtl__c  LIMIT 1];
        FinancialFileUploadClass.getRelatedFilesByRecordIdWire(loanApp.Id,applicant.Id , true, docDtl.Id);
    }
    
      @isTest 
    static void testDeleteFileRecordWithInvalidInput2() {
        // Test with invalid input
        LoanAppl__c loanApp = [SELECT Id,Name FROM LoanAppl__c LIMIT 1];  
        Applicant__c applicant = [SELECT Id,Name,CustProfile__c FROM Applicant__c WHERE LoanAppln__c = :loanApp.Id LIMIT 1];
        applicant.CustProfile__c = 'SALARIED';
        Update applicant; 
        DocDtl__c docDtl = [SELECT Id, DocCatgry__c, DocSubTyp__c,DocTyp__c, File_Type__c FROM DocDtl__c  LIMIT 1];
        FinancialFileUploadClass.getRelatedFilesByRecordIdWire(loanApp.Id,applicant.Id , true, docDtl.Id);
    }

    
    
}