@isTest
public class ChequeOCRRequestGeneratorTest {
    
     @testsetup
    Public static void insertChequeOCRecord(){
        LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
        Applicant__c appli =  TestDataFactory.createSingleApplicant(true,loan.id);
        DocMstr__c docMast = TestDataFactory.createDocumentMaster(True,'Sanction Letter');
        DocDtl__c appDocDet =  TestDataFactory.createDocumentDetail(true,'Sanction letter',appli.Id,docMast.Id);
        
        ContentVersion testContentVersion = new ContentVersion(
            VersionData = Blob.valueOf('Test content data'),
            Title = 'Test Content',
            PathOnClient = 'test-content.txt',
            IsMajorVersion = true
        );
        TriggerBase.bypass('ContentVersion');
        insert testContentVersion;
        TriggerBase.clearBypass('ContentVersion');
        
        testContentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :testContentVersion.Id LIMIT 1];
        
       ContentDocumentLink testContentDocumentLink = new ContentDocumentLink(
            ContentDocumentId = testContentVersion.ContentDocumentId,
            LinkedEntityId = appDocDet.Id,
            ShareType = 'I', // 'I' for Inferred Permission
            Visibility = 'AllUsers' // You can set the visibility based on your requirements
        );
        TriggerBase.bypass('ContentDocumentLink');
        insert testContentDocumentLink;
        TriggerBase.clearBypass('ContentDocumentLink');
        
    }
    
    @isTest
    Public static void ChequeOCRRequestGenerator_generate(){
        List<IntgMsg__c> intMsglist1 = new List<IntgMsg__c>();
        List<LoanAppl__c> loan =[SELECT Id FROM LoanAppl__c LIMIT 1];
        List<Applicant__c> lstAplicant = [SELECT Id From Applicant__c Limit 1];  
        List<DocDtl__c> lstDocDtl = [SELECT Id From DocDtl__c Limit 1];
        List<IntgMsg__c> intMsglist =  TestDataFactory.createIntMsg(true, 'Cheque OCR', lstAplicant[0].id, null);
        system.assert(!loan.isEmpty(),'Loan list should not empty.');
        for(IntgMsg__c intMessage : intMsglist){
         intMessage.RefId__c = lstDocDtl[0].Id;
         intMessage.ParentRefObj__c = 'DocDtl__c';
         intMessage.ParentRefId__c = lstDocDtl[0].Id;
         intMsglist1.add(intMessage);
        }
        ChequeOCRRequestGenerator objCheckOcr = new ChequeOCRRequestGenerator();
        Test.StartTest();
        objCheckOcr.generate(intMsglist1, null, null);
        Test.StopTest();
    }

}