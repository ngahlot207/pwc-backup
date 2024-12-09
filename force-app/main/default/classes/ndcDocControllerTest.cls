@isTest
public class ndcDocControllerTest {

    @isTest
    public static void testGetNdcRequiredDoc() {
        // Test data setup
        // Create DocMstr__c records based on your requirements
        DocMstr__c docMstrRecord = new DocMstr__c(
            Catgry__c = 'PAN Documents',
            DocTyp__c = 'Registered office - Address Proof	',
            DocSubTyp__c = 'TestDocSubType'
        );
        insert docMstrRecord;
        DocMstr__c docMstrRecord1 = new DocMstr__c(
            Catgry__c = 'IMD Documents',
            DocTyp__c = 'Registered office - Address Proof	',
            DocSubTyp__c = 'TestDocSubType'
        );

        // Call the method
        Map<String, Map<String, List<String>>> result = ndcDocController.getNdcRequiredDoc('PAN Documents');
        Map<String, Map<String, List<String>>> result1 = ndcDocController.getNdcRequiredDoc('IMD Documents');

        // Add assertions based on expected results
        //System.assert(result != null, 'Result should not be null');
        // Add more assertions based on your requirements
    }

    @isTest
    public static void testCreateDocDetailwithApplicantAsset() {
        // Test data setup
        // Create necessary records such as ApplAsset__c, DocMstr__c, etc.
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        Applicant__c appli =  TestDataFactory.createSingleApplicant(true,loanApp.id);
        ApplAsset__c applAssetRecord = new ApplAsset__c(
            // Set required fields
            State__c = 'TestState',
           	Appl__c=appli.id
        );
        insert applAssetRecord;

        DocMstr__c docMstrRecord = new DocMstr__c(
            Catgry__c = 'PAN Documents',
            DocTyp__c = 'Registered office - Address Proof',
            DocSubTyp__c = 'TestDocSubType'
        );
        insert docMstrRecord;

        // Call the method
        String documentId = ndcDocController.createDocDetailwithApplicantAsset(
            appli.id, loanApp.id, 'PAN Documents', 'Registered office - Address Proof', 'TestDocSubType', applAssetRecord.Id
        );

        // Add assertions based on expected results
       // System.assertNotEquals(null, documentId, 'Document Id should not be null');
        // Add more assertions based on your requirements
    }
}