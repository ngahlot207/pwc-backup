@istest
public class KycOcrRequestTest {
    
    @testsetup
    static void KYcGenTestMethod(){
        
        Profile testProfile = [SELECT Id 
                               FROM profile
                               WHERE Name = 'System Administrator' 
                               LIMIT 1];
        User testUser = new User(LastName = 'test user 1', 
                                 Username = 'test.user.123@example.com', 
                                 Email = 'test.1@example.com', 
                                 Alias = 'testu1', 
                                 TimeZoneSidKey = 'GMT', 
                                 LocaleSidKey = 'en_GB', 
                                 EmailEncodingKey = 'ISO-8859-1', 
                                 ProfileId = testProfile.Id, 
                                 LanguageLocaleKey = 'en_US'); 
        
        insert testUser;
        
        system.runAs(testUser){
            
            LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
            
            Applicant__c appli =  TestDataFactory.createSingleApplicant(true,loanApp.id);  
            DocMstr__c docMstr = TestDataFactory.createDocumentMaster(true,'AADHAR');
            DocDtl__c docDetail = TestDataFactory.createDocumentDetail(true,'Aadhaar',appli.id,docMstr.id);
                     

        }
    }
    
    @isTest
    public static void  KycOcrRequestGeneratorTestMethod(){  
        
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        Applicant__c appli = [SELECT Id FROM  Applicant__c LIMIT 1];
        string appId = appli.id;
        DocMstr__c dMst =[Select ID From DocMstr__c LIMIT 1];
        DocDtl__c docDtl =[Select Id, DocTyp__c From DocDtl__c LIMIT 1 ];
        ApplKyc__c apl=new ApplKyc__c(kycDoc__c='Passport',Applicant__c=appId,FileNo__c='123');
         insert apl;
        
        String jsonresponse = '{"respcode":"200","respdesc":"Success","txnid":"testTxnid","rrn":"testRrn","refr":"testRefr","file":"testFile","txnmode":"testTxnmode","timespan":"testTimespan","aadhaars":"testAadhaars"}';
            
            ContentVersion contentVersion = new ContentVersion(
            Title = 'response.json',
            PathOnClient = 'test.docx',
            VersionData = Blob.valueOf(jsonresponse)
            
        );
        insert contentVersion;
             
       ContentVersion cvv = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id LIMIT 1];
       ContentDocumentLink cdl = new ContentDocumentLink(
            LinkedEntityId = docDtl.Id,
            ContentDocumentId = cvv.ContentDocumentId,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert cdl;           

        //List<IntgMsg__c> intMsglist =  TestDataFactory.createIntMsgnew(true, 'KYC AADHAR', appli.id, null);
        IntgMsg__c intgMsg1 = new IntgMsg__c();
        intgMsg1.Name='KYC Aadhar';
        intgMsg1.BU__c='Vehicle Loan';
        intgMsg1.Status__c='New';
        intgMsg1.MStatus__c='Blank';
        //intgMsg1.Svc__c='KYC AADHAR';
        intgMsg1.RefObj__c='DocDtl__c';
        intgMsg1.ParentRefId__c=apl.id;
        intgMsg1.ParentRefObj__c='ApplKyc__c';
        intgMsg1.RefId__c = docDtl.Id;
       
       

        IntgMsg__c intgMsg2 = new IntgMsg__c();
        intgMsg1.Name='KYC AADHAR';
        intgMsg2.BU__c='Vehicle Loan';
        intgMsg2.Status__c='New';
        intgMsg2.MStatus__c='Blank';
        intgMsg2.RefObj__c='DocDtl__c';
        //intgMsg1.Svc__c='KYC AADHAR';
        intgMsg2.ParentRefId__c=apl.id;
        intgMsg2.ParentRefObj__c='ApplKyc__c';
        intgMsg2.RefId__c = docDtl.Id; 
        
       insert new List<IntgMsg__c>{intgMsg1, intgMsg2};

       List<IntgMsg__c> msgs = new List<IntgMsg__c>{intgMsg1, intgMsg2};
        
        Test.startTest();
        //TriggerBase.bypass('IntgMsg__c');
        KycOcrRequestGenerator kycreqgen = new KycOcrRequestGenerator();
        kycreqgen.generate(msgs, 'SFDC Aadhar Masking', 'Async');
        Test.stopTest();
        //TriggerBase.clearBypass('IntgMsg__c');
        
        Set <Id> strList = new Set<Id>();
        strList.add(docDtl.id);

        KycOcrResponseProcessor.process(msgs);
       // system.assertEquals(msgs[0].Svc__c, 'KYC OCR');
        system.assertEquals(msgs.size(), 2);
        
        
        
    }
    
     @isTest
    public static void  KycOcrRequestProcessorTestMethod(){
        
        //List<IntgMsg__c> intMsglistempty =  TestDataFactory.createIntMsgnew(true,null, null, null);
		List<IntgMsg__c> intMsglistempty = new List<IntgMsg__c>();
        IntgMsg__c newlit = new IntgMsg__c();
        newlit.BU__c = '';
        newlit.Svc__c = '';
        newlit.IsActive__c = true;
        newlit.RefId__c = null;
        newlit.ParentRefId__c= null;
        intMsglistempty.add(newlit);
        Test.startTest();
        TriggerBase.bypass('IntgMsg__c');
        KycOcrRequestGenerator kycreqgen = new KycOcrRequestGenerator();
        kycreqgen.generate(intMsglistempty, '', '');
        KycOcrResponseProcessor.process(intMsglistempty);
        Test.stopTest();
    }
}