@isTest
public class CloneDocDtlAttachmentsTest {
    @TestSetup
    static void setup() {
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        Applicant__c app = TestDataFactory.createSingleApplicant(true,loanApp.id);
        
        List<DocDtl__c> docDtlList = new List<DocDtl__c>();
        docDtlList.add(new DocDtl__c(
            DocCatgry__c = 'KYC Documents',
            DocTyp__c = 'Residence Address proof - OVD',
            Appl__c = app.id,
            LAN__c = loanApp.Id,
            DocSubTyp__c = 'Voter Id'
        ));
        docDtlList.add(new DocDtl__c(
            DocCatgry__c = 'Application Form',
            DocTyp__c = 'Application Form',
            Appl__c = app.id,
            LAN__c = loanApp.Id,
            DocSubTyp__c = 'Application Form'
        ));
        TriggerBase.bypass('DocDtl__c');
        insert docDtlList;
        TriggerBase.clearBypass('DocDtl__c');
        
        
        // Insert ContentVersion and link it to the DocDtl__c records
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'Test Document Path',
            VersionData = Blob.valueOf('Test content'),
            IsMajorVersion = true
        );
        insert contentVersion;
        
        // Query the ContentDocumentId
        LIST<ContentVersion >contentVers = [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id LIMIT 1];
        
        ContentDocumentLink cdl1 = new ContentDocumentLink(
            ContentDocumentId = contentVers[0].ContentDocumentId,
            LinkedEntityId = docDtlList[0].Id
        );
        insert cdl1;
        
        ContentDocumentLink cdl2 = new ContentDocumentLink(
            ContentDocumentId = contentVers[0].ContentDocumentId,
            LinkedEntityId = docDtlList[1].Id
        );
        insert cdl2;
    }
    
    @IsTest
    static void testCloneDocDtlAttachments() {
        // Retrieve data for the test
        LoanAppl__c originalLoanApp = [SELECT Id FROM LoanAppl__c LIMIT 1];
        LoanAppl__c clonedLoanApp = [SELECT Id FROM LoanAppl__c LIMIT 1];
        Map<Id, Id> appWithOldIdMap = new Map<Id, Id>();
        for (Applicant__c app : [SELECT Id FROM Applicant__c WHERE LoanAppln__c = :originalLoanApp.Id]) {
            appWithOldIdMap.put(app.Id, app.Id);
        }
        
        // Create inputData for CloneLoanAppwrpr
        CloneLoanAppController.CloneLoanAppwrpr inputData = new CloneLoanAppController.CloneLoanAppwrpr();
        inputData.recordId = originalLoanApp.Id;
        inputData.userId = UserInfo.getUserId();
        inputData.cloneReason = 'Test Clone';
        
        // Instantiate the batch class
        CloneDocDtlAttachments batch = new CloneDocDtlAttachments(inputData, originalLoanApp.Id, clonedLoanApp.Id, appWithOldIdMap);
        
        Test.startTest();
        // Execute the batch
        Database.executeBatch(batch);
        Test.stopTest();
        
        // Verify ContentDocumentLink records are cloned correctly
        List<ContentDocumentLink> newContentDocLinks = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :appWithOldIdMap.values()];
        System.assertEquals(0, newContentDocLinks.size(), 'ContentDocumentLinks should be cloned.');
        
        // Verify the CloneStatus__c field on the cloned Loan Application
        LoanAppl__c updatedClonedLoanApp = [SELECT CloneStatus__c FROM LoanAppl__c WHERE Id = :clonedLoanApp.Id];
        System.assertEquals('Success', updatedClonedLoanApp.CloneStatus__c, 'CloneStatus__c should be updated to "Success".');
    } 
}