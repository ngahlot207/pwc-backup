@isTest
public class AadharMaskingResponseProcessorTest {
    
    @isTest
    public static void testProcessMethod() {
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
        
        
        
        IntgMsg__c intgMsg = new IntgMsg__c();
        intgMsg.Name='Aadhar Masking';
        intgMsg.BU__c='HL / STL';
        intgMsg.Status__c='New';
        intgMsg.MStatus__c='Blank';
        intgMsg.RefObj__c='DocDtl__c';
        intgMsg.ParentRefId__c=ak.id;
        intgMsg.ParentRefObj__c='ApplKyc__c';
        intgMsg.RefId__c = dd.Id;
        intgMsg.Resp__c ='An Unique Identifier';
        intgMsg.Trigger_Platform_Event__c = true;
        insert intgMsg;
        
        String jsonresponse1 = '{"respcode":"200","respdesc":"Success","txnid":"testTxnid","rrn":"testRrn","refr":"testRefr","file":"testFile","txnmode":"testTxnmode","timespan":"testTimespan","aadhaars":"testAadhaars"}';
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'response.json',
            PathOnClient = 'test.docx',
            VersionData = Blob.valueOf(jsonresponse1)
            
        );
        insert contentVersion;
        
        ContentDocumentLink cdl = new ContentDocumentLink(
            LinkedEntityId = intgMsg.Id,
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id LIMIT 1].ContentDocumentId,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert cdl;  
        
        
        
       ContentVersion cv = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'test.pdf',
            VersionData = Blob.valueOf('Test document content')
            
        );
        insert cv;
        
        ContentVersion cvv = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
        ContentDocumentLink cd = new ContentDocumentLink(
            LinkedEntityId = dd.Id,
            ContentDocumentId = cvv.ContentDocumentId,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert cd;
        
        
        ContentDocumentLink doclist = [SELECT ContentDocumentId FROM ContentDocumentLink
                                       WHERE LinkedEntityId = :intgMsg.id LIMIT 1];
        
        ContentVersion docVersion = [SELECT Id, VersionData,FileType FROM ContentVersion
                                     WHERE ContentDocumentId = :doclist.ContentDocumentId LIMIT 1];
        
        
        List<IntgMsg__c> responses = new List<IntgMsg__c>{intgMsg};
            
            AadharMaskingResponseProcessor.process(responses);
        
        
        ContentDocumentLink doc = [SELECT ContentDocumentId FROM ContentDocumentLink
                                       WHERE LinkedEntityId = :dd.id LIMIT 1];
        
        ContentVersion docVer = [SELECT Id, VersionData,FileType FROM ContentVersion
                                     WHERE ContentDocumentId = :doc.ContentDocumentId LIMIT 1];

        string FileType=docVer.FileType;
        
        if(docVer!=null){
            delete doc;
        }
        
        
        
       IntgMsg__c intgMsg1 = new IntgMsg__c();
        intgMsg1.Name='Aadhar Masking';
        intgMsg1.BU__c='HL / STL';
        intgMsg1.Status__c='New';
        intgMsg1.MStatus__c='Blank';
        intgMsg1.RefObj__c='DocDtl__c';
        intgMsg1.ParentRefId__c=ak.id;
        intgMsg1.ParentRefObj__c='ApplKyc__c';
        intgMsg1.RefId__c = dd.Id;
        intgMsg1.Resp__c ='An Unique Identifier';
        intgMsg1.Trigger_Platform_Event__c = true;
        insert intgMsg1;
        
        //Wrapper class
        String jsonres = '{"respcode":"SYN10","respdesc":"Account Expired, Please Contact Adiministrator.","txnid":"","rrn":"47","refr":"","file":"","txnmode":"0","timespan":"","aadhaars":""}';
         AadharMaskingResponseWrapper wrapperresponse = AadharMaskingResponseWrapper.praser(jsonres);
        
        ContentVersion cont = new ContentVersion(
            Title = 'response.json',
            PathOnClient = 'test.docx',
            VersionData = Blob.valueOf(jsonres)
            
        );
        insert cont;
        
        ContentDocumentLink cdd = new ContentDocumentLink(
            LinkedEntityId = intgMsg1.Id,
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cont.Id LIMIT 1].ContentDocumentId,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert cdd;   
        
        
        List<IntgMsg__c> respon = new List<IntgMsg__c>{intgMsg1};
            
            AadharMaskingResponseProcessor.process(respon);
        
          
    }
}