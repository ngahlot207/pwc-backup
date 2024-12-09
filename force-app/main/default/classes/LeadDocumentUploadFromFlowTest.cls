@isTest
public class LeadDocumentUploadFromFlowTest {
    @isTest
    static void testCollectAllContentDataFromLead() {
        // Test data setup
               Profile testProfile = [SELECT Id FROM profile WHERE Name = 'LOS Base User' LIMIT 1];
        User testUser = new User(LastName = 'test user 1', 
                                 Username = 'test.createLoanTeam@example.com', 
                                 Email = 'test.1@example.com', 
                                 Alias = 'testu1', 
                                 TimeZoneSidKey = 'GMT', 
                                 LocaleSidKey = 'en_GB', 
                                 EmailEncodingKey = 'ISO-8859-1', 
                                 ProfileId = testProfile.Id, 
                                 LanguageLocaleKey = 'en_US'); 
        
        insert testUser;
        system.runAs(testUser){
            BankBrchMstr__c bnkbranch=TestDataFactory.TestDataBankBranchMaster(true);
            BankBrchMstr__c bnkbranch1=TestDataFactory.TestDataBankBranchMaster1(true);
            TeamHierarchy__c ownerId= testDataFactory.TestDataTeamHierarchy_nonSup(true,testUser.id,bnkbranch.Id);// RM Role
             
               
       	Lead leadrec = new Lead();
        leadrec.Lastname = 'Test';
        leadrec.ownerId = ownerId.Employee__c;
        insert leadrec;
        
        LoanAppl__c loanApp = new LoanAppl__c();
        //loanApp.BU__c='Vehicle Loan';
        loanApp.Stage__c = 'QDE';
        loanApp.BrchCode__c = 'HYC';
        loanApp.Product__c = 'Home Loan';
        loanApp.Loan_Tenure_Months__c = 120;
        loanApp.ReqLoanAmt__c=1000000;
        loanApp.Lead__c =leadrec.Id;
        insert loanApp;
        
        Applicant__c appli = new Applicant__c();

        appli.FName__c = 'test';
        appli.MobNumber__c = '9876567899';
        appli.LName__c = 'method';
        appli.ApplType__c = 'P';        
        appli.Constitution__c = 'INDIVIDUAL';
        appli.CustProfile__c = 'SELF EMPLOYED NON PROFESSIONAL';
        appli.Type_of_Borrower__c = 'Financial';
        appli.LoanAppln__c =loanApp.id;
        insert appli;
       
        String applicantId = appli.Id;
        String loanAppId = loanApp.Id;
        String leadId = leadrec.Id;
         system.debug('listOfParameters from flow tab3'+loanAppId);
        system.debug('listOfParameters from flow tab4'+applicantId);
        system.debug('listOfParameters from flow tab5'+leadId);
        List<List<String>> listOfParameters = new List<List<String>>();
        listOfParameters.add(new List<String>{applicantId, loanAppId, leadId, 'ContentDocumentId1'});
        
        // Call the method under test
        Test.startTest();
        LeadDocumentUploadFromFlow.collectAllContentDataFromLead(listOfParameters);
        Test.stopTest();
        
        // Add assertions here
        // Example assertions:
        // 1. Verify that document details and attachments are created
        // 2. Verify the correctness of inserted records
        // 3. Verify the expected behavior for various scenarios
        }}
    
    @isTest
    static void testCreateAndAttachDocumentDetail() {
        // Test data setup
         // Test data setup
               Profile testProfile = [SELECT Id FROM profile WHERE Name = 'LOS Base User' LIMIT 1];
        User testUser = new User(LastName = 'test user 1', 
                                 Username = 'test.createLoanTeam@example.com', 
                                 Email = 'test.1@example.com', 
                                 Alias = 'testu1', 
                                 TimeZoneSidKey = 'GMT', 
                                 LocaleSidKey = 'en_GB', 
                                 EmailEncodingKey = 'ISO-8859-1', 
                                 ProfileId = testProfile.Id, 
                                 LanguageLocaleKey = 'en_US'); 
        
        insert testUser;
        system.runAs(testUser){
            BankBrchMstr__c bnkbranch=TestDataFactory.TestDataBankBranchMaster(true);
            BankBrchMstr__c bnkbranch1=TestDataFactory.TestDataBankBranchMaster1(true);
            TeamHierarchy__c ownerId= testDataFactory.TestDataTeamHierarchy_nonSup(true,testUser.id,bnkbranch.Id);// RM Role
             
               
       	Lead leadrec = new Lead();
        leadrec.Lastname = 'Test';
        leadrec.ownerId = ownerId.Employee__c;
        insert leadrec;
        
        LoanAppl__c loanApp = new LoanAppl__c();
        //loanApp.BU__c='Vehicle Loan';
        loanApp.Stage__c = 'QDE';
        loanApp.BrchCode__c = 'HYC';
        loanApp.Product__c = 'Home Loan';
        loanApp.Loan_Tenure_Months__c = 120;
        loanApp.ReqLoanAmt__c=1000000;
        loanApp.Lead__c =leadrec.Id;
        insert loanApp;
        
        Applicant__c appli = new Applicant__c();

        appli.FName__c = 'test';
        appli.MobNumber__c = '9876567899';
        appli.LName__c = 'method';
        appli.ApplType__c = 'P';        
        appli.Constitution__c = 'INDIVIDUAL';
        appli.CustProfile__c = 'SELF EMPLOYED NON PROFESSIONAL';
        appli.Type_of_Borrower__c = 'Financial';
        appli.LoanAppln__c =loanApp.id;
        insert appli;
         
        Blob beforeblob=Blob.valueOf('doc');    
        ContentVersion cv = new ContentVersion();
        cv.title = 'test content trigger';      
        cv.PathOnClient ='test.jpg';           
        cv.VersionData =beforeblob; 
        cv.IsMajorVersion = true;
            cv.Document_Category__c='KYC Documents';
            cv.Document_Name__c='Passport';
            cv.Document_Type__c='Sign Proof';
            cv.FirstPublishLocationId=leadrec.id;
        insert cv;  
            
            ContentDocument cd=new ContentDocument();
            //cd.LatestPublishedVersionId=[select id from ContentVersion where FirstPublishLocationId =:leadrec.Id];
               // cd.LatestPublishedVersionId=cv.Id;
            
        List<ContentVersion> cvList = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];    
       
        String applicantId = appli.Id;
        String loanAppId = loanApp.Id;
        String leadId = leadrec.Id;       
        String docCategory = 'KYC Documents';
        String docType = 'DOB Proof';
        String docSubType = 'Voter ID';
       // String appKycId = 'a0C4K00000P3RxKUAV';
        String cdId = [select contentdocumentid from contentversion where id =: cv.id].contentdocumentid;
        
        // Call the method under test
        Test.startTest();
        LeadDocumentUploadFromFlow.createAndAttachDocumentDetail(applicantId, loanAppId, leadId, true);
        Test.stopTest();
        
        // Add assertions here
        // Example assertions:
        // 1. Verify the correctness of inserted records
        // 2. Verify the expected behavior for various scenarios
        }}
    
    // Add more test methods to cover other scenarios and edge cases
}