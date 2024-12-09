@istest
public class KycOcrRequestGeneratorTest {
    
    @testsetup
    static void AdharRequestGenTestMethod(){
        
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
            
            ContentVersion contentVersion = new ContentVersion(Title = 'Penguins',PathOnClient = 'Penguins.jpg',VersionData = Blob.valueOf('Test Content'),IsMajorVersion = true);
            insert contentVersion;
            List<ContentDocument>documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            //create ContentDocumentLink record
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = docDetail.id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.shareType = 'V';
            insert cdl;            

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
        

     
        
        //List<IntgMsg__c> intMsglist =  TestDataFactory.createIntMsgnew(true, 'KYC AADHAR', appli.id, null);
        List<IntgMsg__c> intMsglist = new List<IntgMsg__c>();
        IntgMsg__c newlit = new IntgMsg__c();
        newlit.BU__c = 'Vehicle Loan';
        newlit.Svc__c = 'KYC AADHAR';
        newlit.IsActive__c = true;
        newlit.RefId__c = docDtl.id;
        newlit.ParentRefId__c= docDtl.id;
        intMsglist.add(newlit);
        
        
        Test.startTest();
        TriggerBase.bypass('IntgMsg__c');
        KycOcrRequestGenerator kycreqgen = new KycOcrRequestGenerator();
        kycreqgen.generate(intMsglist, '', '');
        Test.stopTest();
        TriggerBase.clearBypass('IntgMsg__c');
        
        Set <Id> strList = new Set<Id>();
        strList.add(docDtl.id);
        KycOcrRequestGenerator kycreqgenn = new KycOcrRequestGenerator();
        

        KycOcrResponseProcessor.process(intMsglist);
        //system.assertEquals(intMsglist[0].Svc__c, 'KYC OCR');
      //  system.assertEquals(intMsglist.size(), 2);
        
        
        
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