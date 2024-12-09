@isTest
public class FetchFileToMergeTest {
	@TestSetup
    static void setupTestData() {
        LoanAppl__c loanApp = new LoanAppl__c(Product__c = 'Small Ticket LAP');
        if (true) {
            TriggerBase.bypass('LoanAppl__c');
            insert loanApp;
            TriggerBase.clearBypass('LoanAppl__c');
        }
        Applicant__c app = TestDataFactory.createSingleApplicant(true,loanApp.id);
        SchMapping__c schemeMapping = new SchMapping__c();
        insert schemeMapping;
		DocDtl__c doc1 = new DocDtl__c(Appl__c = app.Id,LAN__c = loanApp.Id, DocSubTyp__c = 'Stamped Loan Agreement', IsLatest__c = true);
        DocDtl__c doc2 = new DocDtl__c(Appl__c = app.Id,LAN__c = loanApp.Id, DocSubTyp__c = 'Physical-Signed Loan Agreement & Related Annexures', IsLatest__c = true);
        insert new List<DocDtl__c>{doc1, doc2};
		ContentVersion contentVersion = new ContentVersion(Title = 'Test PDF',  VersionData = Blob.valueOf('Test PDF Data'), FirstPublishLocationId = loanApp.Id);
        insert contentVersion;
        ContentDocumentLink docLink = new ContentDocumentLink(LinkedEntityId = loanApp.Id, ContentDocumentId = contentVersion.ContentDocumentId);
        insert docLink;
    }

    @IsTest
    static void testGetContentDocumentId() {
        ContentVersion contentVersion = [SELECT Id FROM ContentVersion LIMIT 1];
		Test.startTest();
        String result = FetchFileToMerge.getContentDocumentId(contentVersion.Id);
        Test.stopTest();
		System.assertNotEquals(null, result, 'ContentDocumentId should not be null');
    }

    @IsTest
    static void testGetDocPdfData() {
        LoanAppl__c loanApp = [SELECT Id FROM LoanAppl__c LIMIT 1];
        List<String> docIds = new List<String>{loanApp.Id};
		Test.startTest();
        List<String> pdfData = FetchFileToMerge.getDocPdfData(docIds);
        Test.stopTest();
		System.assert(pdfData.size() > 0, 'PDF data should be returned');
    }

    @IsTest
    static void testFetchAllDocs() {
        LoanAppl__c loanApp = [SELECT Id FROM LoanAppl__c LIMIT 1];
		Test.startTest();
        Map<String, List<String>> documentMap = FetchFileToMerge.fetchAllDocs(loanApp.Id);
        Test.stopTest();
		System.assert(documentMap.containsKey('Sanction Letter & KFS Document'), 'Map should contain Sanction Letter & KFS Document');
        System.assert(documentMap.containsKey('BT Draft Part 1'), 'Map should contain BT Draft Part 1 for IsBT=true');
    }

    @IsTest
    static void testCheckAllESignStampDoc() {
        LoanAppl__c loanApp = [SELECT Id FROM LoanAppl__c LIMIT 1];
		Test.startTest();
        List<String> errors = FetchFileToMerge.checkAllESignStampDoc(loanApp.Id);
        Test.stopTest();
		System.assertEquals(0, errors.size(), 'There should be no missing documents');
    }
}