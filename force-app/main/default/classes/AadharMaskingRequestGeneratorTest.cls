@isTest
public class AadharMaskingRequestGeneratorTest {

    @isTest
   public static void testGenerateMethod() {
        LoanAppl__c la=new LoanAppl__c();
       la.ChannelName__c='test';
       TriggerBase.bypass('LoanAppl__c');
       insert la;
       TriggerBase.clearBypass('LoanAppl__c');
       
       Applicant__c ap=new Applicant__c();
       ap.LoanAppln__c=la.id;
       TriggerBase.bypass('Applicant__c');
       insert ap;
       TriggerBase.clearBypass('Applicant__c');
       
       ApplKyc__c ak=new ApplKyc__c();
       ak.Applicant__c=ap.id;
       ak.kycDoc__c='Aadhaar';
       ak.AadharEncripted__c='492515815873';
       insert ak;
        
        DocDtl__c dd=new DocDtl__c();
        dd.Appl__c=ap.id;
        dd.Applicant_KYC__c=ak.id;
        insert dd;
        
       
       
       ContentVersion cv = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'test.docx',
            VersionData = Blob.valueOf('Test document content')
          
        );
        insert cv;
       
       ContentVersion cvv = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
    ContentDocumentLink cdl = new ContentDocumentLink(
            LinkedEntityId = dd.Id,
            ContentDocumentId = cvv.ContentDocumentId,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert cdl;
       
       String base64Data = AadharMaskingRequestGenerator.getFileBase64EncodeData(dd.id);
       
        IntgMsg__c intgMsg1 = new IntgMsg__c();
        intgMsg1.Name='Aadhar Masking';
        intgMsg1.BU__c='HL / STL';
        intgMsg1.Status__c='New';
        intgMsg1.MStatus__c='Blank';
        intgMsg1.RefObj__c='DocDtl__c';
        intgMsg1.ParentRefId__c=ak.id;
        intgMsg1.ParentRefObj__c='ApplKyc__c';
        intgMsg1.RefId__c = dd.Id;
       
       

        IntgMsg__c intgMsg2 = new IntgMsg__c();
        intgMsg2.Name='Aadhar Masking';
        intgMsg2.BU__c='HL / STL';
        intgMsg2.Status__c='New';
        intgMsg2.MStatus__c='Blank';
        intgMsg2.RefObj__c='DocDtl__c';
        intgMsg2.ParentRefId__c=ak.id;
        intgMsg2.ParentRefObj__c='ApplKyc__c';
        intgMsg2.RefId__c = dd.Id; 
        
       insert new List<IntgMsg__c>{intgMsg1, intgMsg2};
           
         
        List<IntgMsg__c> msgs = new List<IntgMsg__c>{intgMsg1, intgMsg2};
        AadharMaskingRequestGenerator generator = new AadharMaskingRequestGenerator();
        generator.generate(msgs, 'SFDC Aadhar Masking', 'Async');
       
       
       //Wrapper class
       string requestjson='{"ver":"2.0","uid":"47","txnmode":"0","slk":"KVOTO-FAZQE-QSJGL-IEATF","sertype":"02","rrn":"123","refr":"","lon":"0.0","lat":"0.0","file":"","env":"2","devid":""}';
    
       AadharMaskingRequestWrapper req=AadharMaskingRequestWrapper.parser(requestjson);
   
   
   }
}