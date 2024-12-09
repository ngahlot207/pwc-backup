@istest
public class FileUploadControllerTest {
    
    @testsetup
    Static Void prepareFileUploadCntlrData(){
        
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        
        Applicant__c appli =  TestDataFactory.createSingleApplicant(true,loanApp.id); 
        
        BankBrchMstr__c objBandMaster = new BankBrchMstr__c();
        objBandMaster.Name = 'Test';
        Insert objBandMaster;
        TeamHierarchy__c teamh=TestDataFactory.TestDataTeamHierarchy_nonSup(True,UserInfo.getUserId(),objBandMaster.Id);
        DocMstr__c docMast =  new DocMstr__c();
        
        docMast.BU__c = 'Vehicle Loan';
        docMast.DocType__c = 'Aadhaar';
        docMast.Active__c =true;
        docMast.Required__c = true ;
        TriggerBase.bypass('DocMstr__c');
        insert docMast;
        TriggerBase.clearBypass('DocMstr__c'); 
        
        ApplKyc__c appkyc = new ApplKyc__c();
        appkyc.Applicant__c = appli.id;
        appkyc.ValidationStatus__c = 'Failure';
        appkyc.OCRStatus__c = 'Success';
        appkyc.kycDoc__c = 'Driving License	';
        appkyc.AadharNo__c = '1234567890';
        appkyc.PassNo__c = 'CFDVD654';
        appkyc.VotIdEpicNo__c='Test';
        appkyc.DLNo__c = 'Test';
        appkyc.Pan__c ='CFRDG5573P';
        appkyc.NPRNumber__c ='HGSDY';
        
            
        appkyc.NameInPan__c = 'Test';
        appkyc.NameInAdhr__c = 'test';
        appkyc.DtOfBirth__c=system.today();
        appkyc.Name__c='test';
        TriggerBase.bypass('ApplKyc__c');
        insert appkyc;
        TriggerBase.clearBypass('ApplKyc__c'); 
        
        
        List<DocDtl__c> docDetList = new List<DocDtl__c>(); 
        DocDtl__c appDocDet = new DocDtl__c();
        appDocDet.DocTyp__c = 'Identity Proof';
        appDocDet.DocCatgry__c = 'KYC Documents';
        appDocDet.DocSubTyp__c = 'Aadhaar';
        appDocDet.ShopAndEstablishmentDate__c = system.today();
        appDocDet.UtilityBillDate__c = system.today();
        appDocDet.LAN__c = loanApp.Id;
        appDocDet.Appl__c = appli.Id;
        appDocDet.Applicant_KYC__c = appkyc.id;
        appDocDet.DocMstr__c = docMast.id ;
        docDetList.add(appDocDet);
        
        DocDtl__c appDocDet1 = new DocDtl__c();
        appDocDet1.DocTyp__c = 'Identity Proof';
        appDocDet1.DocCatgry__c = 'KYC Documents';
        appDocDet1.DocSubTyp__c = 'Passport';
        appDocDet1.ShopAndEstablishmentDate__c = system.today();
        appDocDet1.UtilityBillDate__c = system.today();
        appDocDet1.LAN__c = loanApp.Id;
        appDocDet1.Appl__c = appli.Id;
        appDocDet1.Applicant_KYC__c = appkyc.id;
        appDocDet1.DocMstr__c = docMast.id ;
        docDetList.add(appDocDet1);
        
        DocDtl__c appDocDet2 = new DocDtl__c();
        appDocDet2.DocTyp__c = 'Identity Proof';
        appDocDet2.DocCatgry__c = 'KYC Documents';
        appDocDet2.DocSubTyp__c = 'PAN';
        appDocDet2.ShopAndEstablishmentDate__c = system.today();
        appDocDet2.UtilityBillDate__c = system.today();
        appDocDet2.LAN__c = loanApp.Id;
        appDocDet2.Appl__c = appli.Id;
        appDocDet2.Applicant_KYC__c = appkyc.id;
        appDocDet2.DocMstr__c = docMast.id ;
        docDetList.add(appDocDet2);
        
		DocDtl__c appDocDet3 = new DocDtl__c();
        appDocDet3.DocTyp__c = 'Identity Proof';
        appDocDet3.DocCatgry__c = 'KYC Documents';
        appDocDet3.DocSubTyp__c = 'Driving license';
        appDocDet3.ShopAndEstablishmentDate__c = system.today();
        appDocDet3.UtilityBillDate__c = system.today();
        appDocDet3.LAN__c = loanApp.Id;
        appDocDet3.Appl__c = appli.Id;
        appDocDet3.Applicant_KYC__c = appkyc.id;
        appDocDet3.DocMstr__c = docMast.id ;
        docDetList.add(appDocDet3);
        
        DocDtl__c appDocDet4 = new DocDtl__c();
        appDocDet4.DocTyp__c = 'Identity Proof';
        appDocDet4.DocCatgry__c = 'KYC Documents';
        appDocDet4.DocSubTyp__c = 'Voter ID';
        appDocDet4.ShopAndEstablishmentDate__c = system.today();
        appDocDet4.UtilityBillDate__c = system.today();
        appDocDet4.LAN__c = loanApp.Id;
        appDocDet4.Appl__c = appli.Id;
        appDocDet4.Applicant_KYC__c = appkyc.id;
        appDocDet4.DocMstr__c = docMast.id ;
        docDetList.add(appDocDet4);
        
        DocDtl__c appDocDet5 = new DocDtl__c();
        appDocDet5.DocTyp__c = 'Identity Proof';
        appDocDet5.DocCatgry__c = 'KYC Documents';
        appDocDet5.DocSubTyp__c = 'Letter issued by the National Population Register';
        appDocDet5.ShopAndEstablishmentDate__c = system.today();
        appDocDet5.UtilityBillDate__c = system.today();
        appDocDet5.LAN__c = loanApp.Id;
        appDocDet5.Appl__c = appli.Id;
        appDocDet5.Applicant_KYC__c = appkyc.id;
        appDocDet5.DocMstr__c = docMast.id ;
        docDetList.add(appDocDet5);
               
        TriggerBase.bypass('DocDtl__c');
        insert docDetList;
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
        
        DocDtl__c appDocDetTwo = new DocDtl__c();
        appDocDetTwo.DocTyp__c = 'Residence Address proof - OVD';
        appDocDetTwo.DocCatgry__c = 'KYC Documents';
        appDocDetTwo.DocSubTyp__c = 'Test';
        appDocDetTwo.LAN__c = loanApp.Id;
        appDocDetTwo.Appl__c = appli.Id;
        appDocDetTwo.DocMstr__c = docMast.id ;
        appDocDetTwo.FileAvalbl__c = true;
        
        TriggerBase.bypass('DocDtl__c');
        insert appDocDetTwo;
        TriggerBase.clearBypass('DocDtl__c');  
        Case objCase = TestDataFactory.CaseData(true);
        ApplAsset__c applicantasset = TestDataFactory.applAssetData(True,appli.Id);
    }
    
    @isTest
    Public Static Void testFileUploadCntrle(){
        List<Applicant__c> appList = [SELECT Id FROM Applicant__c];
        List<DocDtl__c> docDetlistWithLid = [SELECT Id,Applicant_KYC__c FROM DocDtl__c];
        List<DocDtl__c> docDetlistWithOutLid = [SELECT Id,Applicant_KYC__c FROM DocDtl__c WHERE DocSubTyp__c = 'Test'];
         List<Case> objCaseList = [SELECT Id FROM Case];
         List<ApplAsset__c> ApplAssetList = [SELECT Id FROM ApplAsset__c];
        List<String> categories = new List<String>{'KYC Documents'};
            List<String> types = new List<String>{'Residence Address proof - OVD','Identity Proof'};
                List<String> subTypes = new List<String>{'Driving license','Aadhaar','Passport','PAN','Voter ID','Letter issued by the National Population Register',''};  
                    try{
                        List<FileUploadController.DocDetailWrapper> docWrpList = FileUploadController.fetchId(appList[0].id,categories,types,subTypes); 
                        system.assertEquals(6, docWrpList.size());
                        List<FileUploadController.DocDetailWrapper> docWrpList1 = FileUploadController.fetchId(objCaseList[0].id,categories,types,subTypes); 
                        system.assertEquals(0, docWrpList1.size());
                        List<FileUploadController.DocDetailWrapper> docWrpList2 = FileUploadController.fetchId(ApplAssetList[0].id,categories,types,subTypes); 
                        system.assertEquals(0, docWrpList2.size());
                        FileUploadController.deleteDocDetail(docDetlistWithLid[0].id); 
                         FileUploadController.deleteDocDetail(docDetlistWithOutLid[0].id); 
                        FileUploadController.fetchId(null,null,null,null); 
                         
                    }catch(NullPointerException ex){
                        system.assertEquals('Attempt to de-reference a null object', ex.getMessage());
                    }  
        
    }
}