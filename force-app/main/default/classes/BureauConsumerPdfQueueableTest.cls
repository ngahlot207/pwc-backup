@isTest
public class BureauConsumerPdfQueueableTest {
    @isTest
    static void testQueueableExecution() {
        // Set up test data
        String jsonResponse ='{"PDF REPORT": [0,0,0,0] }';
            LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
        loan.Product__c='Home Loan';
        update loan;
        
        Applicant__c Applicant=TestDataFactory.createSingleApplicant(true,loan.id);
        Bureau__c Bureau=TestDataFactory.BureauData(true,loan.id,Applicant.Id);
        Bureau.BureauAPI__c = 'Consumer';
        Update Bureau;
        
        DocMstr__c docMstr=TestDataFactory.DocumentMasterData(true);
        docMstr.Prod__c='Home Loan';
        docMstr.Catgry__c='Bureau Report';
        docMstr.DocTyp__c='Bureau Report';
        update docMstr;
        
        DocDtl__c doc = new DocDtl__c();
        doc.Appl__c=Applicant.Id;
        doc.LAN__c=Bureau.LoanApp__c;
        doc.DocMstr__c=docMstr.Id;
        doc.DocCatgry__c='Bureau Report';
        doc.DocTyp__c='Bureau Report';
        doc.DocSubTyp__c='Bureau Report';
        Insert doc;
        // Enqueue the queueable job
        Test.startTest();
        System.enqueueJob(new BureauConsumerPdfQueueable(jsonResponse, Applicant.Id));
        Test.stopTest();
        
    }
}