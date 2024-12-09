@isTest
public class GeneratePDFandAttachToLoanAppTest {
    @isTest
	 static void testGenerateDocument_Success() {

        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);   
        Applicant__c appli =  TestDataFactory.createSingleApplicant(true,loanApp.id); 
         
        DocMstr__c docMast =  new DocMstr__c(); 
        docMast.BU__c = 'Vehicle Loan';
        docMast.DocType__c = 'Aadhaar';
        docMast.Active__c =true;
        docMast.Required__c = true ;
        TriggerBase.bypass('DocMstr__c');
        insert docMast;
        TriggerBase.clearBypass('DocMstr__c'); 
         
        DocDtl__c appDocDet1 = new DocDtl__c();
        appDocDet1.DocTyp__c = 'Identity Proof';
        appDocDet1.DocCatgry__c = 'KYC Documents';
        appDocDet1.DocSubTyp__c = 'Passport';
        appDocDet1.ShopAndEstablishmentDate__c = system.today();
        appDocDet1.UtilityBillDate__c = system.today();
        appDocDet1.LAN__c = loanApp.Id;
        appDocDet1.Appl__c = appli.Id;
        appDocDet1.DocMstr__c = docMast.id ;
          TriggerBase.bypass('DocDtl__c');
        insert appDocDet1;
        TriggerBase.clearBypass('DocDtl__c'); 
         
         ContentVersion CV = new ContentVersion();
         CV.Title = 'TestFile.pdf';
         CV.PathOnClient = 'TestFile.pdf';
         CV.VersionData =  Blob.valueOf('Sample file data');
         CV.FirstPublishLocationId = appDocDet1.Id;
         TriggerBase.bypass('ContentVersion');
         insert CV;
         TriggerBase.clearBypass('ContentVersion'); 
         
        GeneratePDFandAttachToLoanApplication.DocGenWrapper wrapper = new GeneratePDFandAttachToLoanApplication.DocGenWrapper();
        wrapper.pageUrl = '/apex/YourPageName?id=TestContactId';
        wrapper.fileName = 'TestFile.pdf';
        wrapper.docDetailId = appDocDet1.Id; 
        
        PageReference mockPageRef = new PageReference('https://yourdomain.visualforce.com/apex/YourPageName?id=TestContactId');
        Test.setCurrentPage(mockPageRef);
  
        Test.startTest();
        String result = GeneratePDFandAttachToLoanApplication.generateDocument(wrapper);
        Test.stopTest();
        
    }
}