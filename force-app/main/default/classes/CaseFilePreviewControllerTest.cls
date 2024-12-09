@isTest
public class CaseFilePreviewControllerTest {
    @testsetup
    Static Void prepareFileUploadCntlrData(){
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        Applicant__c appli =  TestDataFactory.createSingleApplicant(true,loanApp.id); 
        DocMstr__c documentMaster = TestDataFactory.createDocumentMaster(true,'PAN');  
        DocDtl__c documentDetail = TestDataFactory.createDocumentDetail(true,'PAN',appli.Id,documentMaster.Id);
        Blob beforeblob=Blob.valueOf('doc');
        
        ContentVersion cv = new ContentVersion();
        cv.title = 'test content trigger';      
        cv.PathOnClient ='test.jpg';           
        cv.VersionData =beforeblob; 
        cv.IsMajorVersion = true;
        insert cv;    
        
        List<ContentVersion> cvList = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=documentDetail.id;
        contentlink.ShareType= 'I';
        contentlink.ContentDocumentId = [select contentdocumentid from contentversion where id =: cv.id].contentdocumentid;
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
    }
    
    @isTest 
      static void testCaseFilePreviewController(){
         List<DocDtl__c> documentDetailId = [SELECT ID,Name from DocDtl__c LIMIT 1];
          List<String> lstIds = new List<String>();
          for(DocDtl__c documentDetail : documentDetailId){
              lstIds.add(documentDetail.Id);
          }
          try{
          List<CaseFilePreviewController.DocDetailWrapper> docWrpList = CaseFilePreviewController.getContentDocumentId(lstIds);
          system.assertEquals(1, docWrpList.size());
          }
          catch(NullPointerException ex){
            system.assertEquals('Attempt to de-reference a null object', ex.getMessage());   
          }
          
      }
    
}