@istest
public class DocumentDetailControllerTest {
    
    @isTest
    Public Static Void documentDetailControllerTestMethod(){
        
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        
        Applicant__c appli =  TestDataFactory.createSingleApplicant(true,loanApp.id); 
        
        ApplKyc__c appkyc = new ApplKyc__c();
        appkyc.Applicant__c = appli.id;
        appkyc.ValidationStatus__c = 'Failure';
        appkyc.OCRStatus__c = 'Success';
        appkyc.kycDoc__c = 'Driving License';
        appkyc.DLNo__c='123456';
        TriggerBase.bypass('ApplKyc__c');
        insert appkyc;
        TriggerBase.clearBypass('ApplKyc__c'); 
        
        DocDtl__c appDocDet = new DocDtl__c();
        appDocDet.DocTyp__c = 'Identity Proof';
        appDocDet.DocCatgry__c = 'KYC Documents';
        appDocDet.DocSubTyp__c = 'Driving license';
        appDocDet.LAN__c = loanApp.Id;
        appDocDet.Appl__c = appli.Id;
        
        
        TriggerBase.bypass('DocDtl__c');
        insert appDocDet;
        TriggerBase.clearBypass('DocDtl__c'); 
        Blob beforeblob=Blob.valueOf('doc');
        
        ContentVersion cv = new ContentVersion();
        cv.title = 'test content trigger';      
        cv.PathOnClient ='test.jpg';           
        cv.VersionData =beforeblob; 
        cv.IsMajorVersion = true;
        insert cv;      
        List<ContentVersion> cvList = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        //System.assertEquals(cvList.size(), 1);
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=appDocDet.id;
        contentlink.ShareType= 'I';
        contentlink.ContentDocumentId = [select contentdocumentid from contentversion where id =: cv.id].contentdocumentid;
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
        
        try{
            DocumentDetailController.findRequiredDoc(appli.id,loanApp.id,'Home Loan','QDE','RM Data Entry');
            DocumentDetailController.findRequiredDoc(null,null,null,null,null);
        }catch(AuraHandledException ex){
            system.assertEquals('Script-thrown exception', ex.getMessage());
        } 
        try{
            DocumentDetailController.createDocumentDetail(appli.id,loanApp.id, 'KYC Documents', 'Residence Address proof - OVD', 'Driving license', true);
            DocumentDetailController.createDocumentDetail(appli.id,loanApp.id, 'KYC Documents', 'Other Income Documents','Bank Statement', true);
            DocumentDetailController.createDocumentDetail(null,null, null, null, null, null);
        }catch(AuraHandledException ex){
            system.assertEquals('Script-thrown exception', ex.getMessage());
        } 
        
        
        try{
            DocumentDetailController.createApplicantKyc(appli.id, 'Driving license');
            DocumentDetailController.createApplicantKyc(null, null);
        }catch(AuraHandledException ex){
            system.assertEquals('Script-thrown exception', ex.getMessage());
        } 
        
        try{
            DocumentDetailController.createDocDetail(appli.id,loanApp.id, 'KYC Documents', 'Residence Address proof - OVD', 'Driving license', false,appkyc.id);
            DocumentDetailController.createDocDetail(appli.id,loanApp.id, 'KYC Documents', 'Residence Address proof - OVD', 'Driving license', false,null);
            DocumentDetailController.createDocDetail(null,null, null, null, null, null,null);
        }catch(AuraHandledException ex){
            system.assertEquals('Script-thrown exception', ex.getMessage());
        } 
        try{
            DocumentDetailController.createAppkycDd(appli.id,loanApp.id, 'KYC Documents', 'Residence Address proof - OVD', 'Driving license');
            DocumentDetailController.createAppkycDd(null,null, null, null, null);
        }catch(AuraHandledException ex){
            system.assertEquals('Script-thrown exception', ex.getMessage());
        } 
        
        try{
            DocumentDetailController.addAppkycDd(appli.id,loanApp.id, 'KYC Documents', 'Residence Address proof - OVD', 'Driving license',appDocDet.id);
            DocumentDetailController.addAppkycDd(null,null, null, null, null,null);
        }catch(AuraHandledException ex){
            system.assertEquals('Script-thrown exception', ex.getMessage());
        }
        
    }
    @isTest
    public static void updateTest(){
        LoanAppl__c loanApp1 = TestDataFactory.createLoanApplication(true);        
        Applicant__c applicant1 = TestDataFactory.createSingleApplicant(true, loanApp1.Id);
        DocMstr__c docMstr1 = TestDataFactory.createDocumentMaster(true, 'Master document');
        LoanAppl__c loanApp = [SELECT Id,Name FROM LoanAppl__c LIMIT 1];     
        Applicant__c applicant = [SELECT Id,Name FROM Applicant__c WHERE LoanAppln__c = :loanApp.Id LIMIT 1];  
        DocMstr__c docMstr = [SELECT Id,Name FROM DocMstr__c LIMIT 1]; 
        ApplKyc__c appKyc = [SELECT Id, Name,ValidationStatus__c FROM ApplKyc__c LIMIT 1];
        
        ApplAddr__c aplAddrs = new ApplAddr__c(Applicant__c = applicant.Id, AddrTyp__c = 'Residence Address');
        insert aplAddrs;
        
        appKyc.ValidationStatus__c = GlobalConstants.MSG_SUCCESS;
        appKyc.Pincode__c = '123123';
        update appKyc;
        
        DocDtl__c docDtl = TestDataFactory.createDocumentDetail(false, 'Test', applicant.Id, docMstr.Id);
        docDtl.DocTyp__c ='Identity Proof';
        docDtl.Applicant_KYC__c = appKyc.Id;
        
        insert docDtl;
        ContentVersion cv = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'test.docx',
            VersionData = Blob.valueOf('Test document content')
            
        );
        insert cv;
        ContentVersion cvv = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
        ContentDocumentLink cdl = new ContentDocumentLink(
            LinkedEntityId = docDtl.Id,
            ContentDocumentId = cvv.ContentDocumentId,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert cdl;
        DocumentDetailController.deleteDocDetWithCdl(docDtl.id);
        
        List<String> categoriesList= New List<String>();
        DocumentDetailController.evaluateAllRequiredRecords(applicant1.id,loanApp1.id,'productType','stage', 'subStage', categoriesList);
        
    }
    
    //Added this method to check delete operation with cdl to ndc
    @isTest    
    public static void deletewithCdlToNdcTest(){
        LoanAppl__c loanApp1 = TestDataFactory.createLoanApplication(true);        
        Applicant__c applicant1 = TestDataFactory.createSingleApplicant(true, loanApp1.Id);
        DocMstr__c docMstr1 = TestDataFactory.createDocumentMaster(true, 'Master document');
        LoanAppl__c loanApp = [SELECT Id,Name FROM LoanAppl__c LIMIT 1];     
        Applicant__c applicant = [SELECT Id,Name FROM Applicant__c WHERE LoanAppln__c = :loanApp.Id LIMIT 1];  
        DocMstr__c docMstr = [SELECT Id,Name FROM DocMstr__c LIMIT 1]; 
        ApplKyc__c appKyc = [SELECT Id, Name,ValidationStatus__c FROM ApplKyc__c LIMIT 1];
        
        ApplAddr__c aplAddrs = new ApplAddr__c(Applicant__c = applicant.Id, AddrTyp__c = 'Residence Address');
        insert aplAddrs;
        
        appKyc.ValidationStatus__c = GlobalConstants.MSG_SUCCESS;
        appKyc.Pincode__c = '123123';
        update appKyc;
        
        DocDtl__c docDtl = TestDataFactory.createDocumentDetail(false, 'Test', applicant.Id, docMstr.Id);
        docDtl.DocTyp__c ='Other Income Documents';
        docDtl.Applicant_KYC__c = appKyc.Id;
        
        insert docDtl;
        ContentVersion cv = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'test.docx',
            VersionData = Blob.valueOf('Test document content')
            
        );
        insert cv;
        ContentVersion cvv = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
        ContentDocumentLink cdl = new ContentDocumentLink(
            LinkedEntityId = docDtl.Id,
            ContentDocumentId = cvv.ContentDocumentId,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert cdl;
        DocumentDetailController.deleteDocDetWithCdlToNdc(docDtl.id);
    }
    @isTest
    public static void testCheckDuplicateDoc(){
        LoanAppl__c loanApp1 = TestDataFactory.createLoanApplication(true);        
        Applicant__c applicant1 = TestDataFactory.createSingleApplicant(true, loanApp1.Id);
        DocMstr__c docMstr1 = TestDataFactory.createDocumentMaster(true, 'Master document');
        LoanAppl__c loanApp = [SELECT Id,Name FROM LoanAppl__c LIMIT 1];     
        Applicant__c applicant = [SELECT Id,Name FROM Applicant__c WHERE LoanAppln__c = :loanApp.Id LIMIT 1];  
        DocMstr__c docMstr = [SELECT Id,Name FROM DocMstr__c LIMIT 1]; 
        ApplKyc__c appKyc = [SELECT Id, Name,ValidationStatus__c,kycDoc__c FROM ApplKyc__c LIMIT 1];
        
        ApplAddr__c aplAddrs = new ApplAddr__c(Applicant__c = applicant.Id, AddrTyp__c = 'Residence Address');
        insert aplAddrs;
        
        Applicant__c appli = TestDataFactory.createCoAppli(true, loanApp1.Id);        
        Applicant__c appli1 = TestDataFactory.createCoAppliProp(true, loanApp.Id);  
        ApplKyc__c applKyc3 = TestDataFactory.createApplKyc(true, appli.Id);
        ApplKyc__c applKyc = TestDataFactory.createApplKyc(true, appli1.Id);
        ApplKyc__c applKyc1 = TestDataFactory.createApplKyc(true, applicant1.Id);
        
        // ApplKyc__c applKyc2 = TestDataFactory.createApplKyc(true, appli1.Id);
        
        appKyc.ValidationStatus__c = GlobalConstants.MSG_SUCCESS;
        appKyc.Pincode__c = '123123';
       // appKyc.kycDoc__c='Pan';
        update appKyc;
        
        
        ApplicantEmployment__c appEmp = TestDataFactory.createApplEmplt(true,applicant1.id);
        ApplicantEmployment__c appEmp1 = TestDataFactory.createApplEmplt1(true,appli.id);
        ApplicantEmployment__c appEmp2 = TestDataFactory.createApplEmployment(true,appli1.id);
        
        DocDtl__c docDtl = TestDataFactory.createDocumentDetail(false, 'Test', applicant.Id, docMstr.Id);
        docDtl.DocTyp__c ='Identity Proof';
        docDtl.Applicant_KYC__c = appKyc.Id;
        
        insert docDtl;
        ContentVersion cv = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'test.docx',
            VersionData = Blob.valueOf('Test document content')
            
        );
        insert cv;
        ContentVersion cvv = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
        ContentDocumentLink cdl = new ContentDocumentLink(
            LinkedEntityId = docDtl.Id,
            ContentDocumentId = cvv.ContentDocumentId,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert cdl;
        DocumentDetailController.checkDuplicateDoc(loanApp1.id,applKyc1.Id,null, null,appli.id);
        DocumentDetailController.checkDuplicateDoc(loanApp.id,null,'123456789', 'panValidate',appli1.Id);
        DocumentDetailController.checkDuplicateDoc(loanApp1.id,null,'123456789', 'voterIdValidate',appli.id);
        DocumentDetailController.checkDuplicateDoc(loanApp1.id,null,'123456789', 'panValidate',appli.id);
        DocumentDetailController.checkDuplicateDoc(loanApp1.id,null,'123456789', 'voterIdValidate',appli1.id);
        
    }
    
    @isTest
    public static void testFindDuplicateDocs(){
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);        
        DocMstr__c docMstr1 = TestDataFactory.createDocumentMaster(true, 'Master document');
        //LoanAppl__c loanApp = [SELECT Id,Name FROM LoanAppl__c LIMIT 1];    
        Applicant__c applicant1 = TestDataFactory.createSingleApplicant(true, loanApp.Id);
        Applicant__c appli = TestDataFactory.createCoAppli(true, loanApp.Id);        
        Applicant__c appli1 = TestDataFactory.createCoAppliProp(true, loanApp.Id);  
        ApplicantEmployment__c appEmp = TestDataFactory.createApplEmplt(true,applicant1.id);
        ApplicantEmployment__c appEmp1 = TestDataFactory.createApplEmplt1(true,appli.id);
        
        Applicant__c applicant = [SELECT Id,Name FROM Applicant__c WHERE LoanAppln__c = :loanApp.Id LIMIT 1];  
        DocMstr__c docMstr = [SELECT Id,Name FROM DocMstr__c LIMIT 1]; 
        ApplKyc__c appKyc = [SELECT Id, Name,ValidationStatus__c FROM ApplKyc__c LIMIT 1];
        
        DocDtl__c docDtl = TestDataFactory.createDocumentDetail(false, 'Test', applicant.Id, docMstr.Id);
        docDtl.DocTyp__c ='Identity Proof';
        docDtl.Applicant_KYC__c = appKyc.Id;
        
        insert docDtl;
        ContentVersion cv = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'test.docx',
            VersionData = Blob.valueOf('Test document content')
            
        );
        insert cv;
        ContentVersion cvv = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
        ContentDocumentLink cdl = new ContentDocumentLink(
            LinkedEntityId = docDtl.Id,
            ContentDocumentId = cvv.ContentDocumentId,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert cdl;
        
        
        ApplKyc__c applKyc3 = TestDataFactory.createApplKyc(true, appli.Id);
        ApplKyc__c applKyc = TestDataFactory.createApplKyc(true, appli.Id);
        ApplKyc__c applKyc1 = TestDataFactory.createApplKyc(true, applicant1.Id);
        ApplKyc__c applKyc2 = TestDataFactory.createApplKyc(true, appli1.Id);
        
        
        DocDtl__c appDocDet = new DocDtl__c();
        appDocDet.DocTyp__c = 'Identity Proof';
        appDocDet.DocCatgry__c = 'KYC Documents';
        appDocDet.DocSubTyp__c = 'Driving license';
        appDocDet.LAN__c = loanApp.Id;
        appDocDet.Appl__c = appli.Id;
        // DocumentDetailController.findDuplicateDocs(loanApp.id);
        Test.startTest();
        List<ValidateRequiredFieldsAndDoc.Responce> responseList = DocumentDetailController.findDuplicateDocs(loanApp.Id);
        Test.stopTest();
        
        // Assert results
        System.assertEquals(1, responseList.size(), 'There should be one response object in the list');
        /* ValidateRequiredFieldsAndDoc.Responce resp = responseList[0];
System.assertEquals(false, resp.validated, 'Validation should fail');
System.assertEquals(true, resp.missingDoc, 'Missing Doc should be true');*/
        
    }
}