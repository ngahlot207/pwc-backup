@isTest
public class BatchToSendVendorEmailTechnicalTest {
    
    @isTest    
    Public static void testMethod1(){
        List<LoanAppl__c>  lstloanApp = new  List<LoanAppl__c>(); 
        List<LoanAppl__c>  lstloanApp2 = new  List<LoanAppl__c>(); 
        List<User> lstUser = [SELECT ID,Name, Email FROM User WHERE ID =: UserInfo.getUserId()];
        
        
        
        LoanAppl__c loanApp = new LoanAppl__c(); 
        loanApp.Stage__c = 'Disbursed';
        loanApp.SubStage__c = 'DI Check' ;
        loanApp.FinnSubDtTime__c = System.today().addDays(-10);
        loanApp.Loan_Boarding_API_Status__c = 'Success';
        loanApp.RMSMName__c = lstUser[0].Id;
        loanApp.BrchName__c = 'MUMBAI';
        loanApp.BrchCode__c = 'MUM';
        loanApp.Product__c = 'Home Loan';
        TriggerBase.bypass('LoanAppl__c');
        Insert loanApp; 
        TriggerBase.clearBypass('LoanAppl__c');  
        
        BankBrchMstr__c bankBranchMaster = new BankBrchMstr__c(); 
        bankBranchMaster.BrchCode__c = 'MUM';
        bankBranchMaster.Name = 'Mumbai';
        TriggerBase.bypass('BankBrchMstr__c');
        Insert bankBranchMaster;
        TriggerBase.clearBypass('BankBrchMstr__c'); 
        
        LocMstr__c locMaster1 = TestDataFactory.LocMaster(True);
        locMaster1.State__c = 'Maharashtra';
        Update locMaster1;
        
        LocBrchJn__c locBranchJun = TestDataFactory.locBranchJnData(True,bankBranchMaster.Id,locMaster1.Id);
        
        Applicant__c app = TestDataFactory.createSingleApplicant(True,loanApp.Id);
        DocMstr__c docMaster =  TestDataFactory.createDocumentMaster(True,'Test');
        
        
        
        DocDtl__c docDtl = TestDataFactory.createDocumentDetail(True,'OTC',app.Id,docMaster.Id);
        docDtl.DocStatus__c = 'OTC';
        docDtl.LAN__c =  loanApp.Id;   
        Update docDtl;
        
        TeamHierarchy__c teamHir = TestDataFactory.TestDataTeamHierarchy_nonSup(true,lstUser[0].Id,bankBranchMaster.Id);
        teamHir.Emprole__c = 'BBH';
        
        Update teamHir;
        
        TeamHierarchy__c teamHir1 = TestDataFactory.TestDataTeamHierarchy_nonSup(true,lstUser[0].Id,bankBranchMaster.Id);
        teamHir1.Emprole__c = 'CPA';
        Update teamHir1;
        
        TeamHierarchy__c teamHir2 = TestDataFactory.TestDataTeamHierarchy_nonSup(true,lstUser[0].Id,bankBranchMaster.Id);
        teamHir2.Emprole__c = 'NOM';
        Update teamHir2;
        
        
        Test.StartTest();  
        BatchToSendBulkOTCPDDDocToLoanApplcn objBatc = new BatchToSendBulkOTCPDDDocToLoanApplcn();
        Database.executeBatch(objBatc);
        Test.StopTest(); 
        
    }
    
    
    @isTest    
    Public static void testMethod2(){
        List<LoanAppl__c>  lstloanApp = new  List<LoanAppl__c>(); 
        List<LoanAppl__c>  lstloanApp2 = new  List<LoanAppl__c>(); 
        List<User> lstUser = [SELECT ID,Name, Email FROM User WHERE ID =: UserInfo.getUserId()];
        
        LoanAppl__c loanApp = new LoanAppl__c(); 
        loanApp.Stage__c = 'Disbursed';
        loanApp.SubStage__c = 'DI Check' ;
        loanApp.FinnSubDtTime__c = System.today().addDays(-14);
        loanApp.Loan_Boarding_API_Status__c = 'Success';
        loanApp.RMSMName__c = lstUser[0].Id;
        loanApp.BrchName__c = 'MUMBAI';
        loanApp.BrchCode__c = 'MUM';
        loanApp.Product__c = 'Home Loan';
        TriggerBase.bypass('LoanAppl__c');
        Insert loanApp; 
        TriggerBase.clearBypass('LoanAppl__c');  
        BankBrchMstr__c bankBranchMaster = new BankBrchMstr__c(); 
        bankBranchMaster.BrchCode__c = 'MUM';
        bankBranchMaster.Name = 'Mumbai';
        TriggerBase.bypass('BankBrchMstr__c');
        Insert bankBranchMaster;
        TriggerBase.clearBypass('BankBrchMstr__c'); 
        
        LocMstr__c locMaster1 = TestDataFactory.LocMaster(True);
        locMaster1.State__c = 'Maharashtra';
        Update locMaster1;
        
        LocBrchJn__c locBranchJun = TestDataFactory.locBranchJnData(True,bankBranchMaster.Id,locMaster1.Id);
        
        Applicant__c app = TestDataFactory.createSingleApplicant(True,loanApp.Id);
        DocMstr__c docMaster =  TestDataFactory.createDocumentMaster(True,'Test');
        
        
        
        DocDtl__c docDtl = TestDataFactory.createDocumentDetail(True,'OTC',app.Id,docMaster.Id);
        docDtl.DocStatus__c = 'OTC';
        docDtl.LAN__c =  loanApp.Id;   
        Update docDtl;
        
        TeamHierarchy__c teamHir = TestDataFactory.TestDataTeamHierarchy_nonSup(true,lstUser[0].Id,bankBranchMaster.Id);
        teamHir.Emprole__c = 'BBH';
        
        Update teamHir;
        
        TeamHierarchy__c teamHir1 = TestDataFactory.TestDataTeamHierarchy_nonSup(true,lstUser[0].Id,bankBranchMaster.Id);
        teamHir1.Emprole__c = 'CPA';
        Update teamHir1;
        
        TeamHierarchy__c teamHir2 = TestDataFactory.TestDataTeamHierarchy_nonSup(true,lstUser[0].Id,bankBranchMaster.Id);
        teamHir2.Emprole__c = 'NOM';
        Update teamHir2;
        
        
        Test.StartTest();  
        BatchToSendbulkOTCPDDToLANAfter14Days objBatc = new BatchToSendbulkOTCPDDToLANAfter14Days();
        Database.executeBatch(objBatc);
        Test.StopTest(); 
        
    }
    
    @isTest    
    public static void testMethod3(){
      /*  Account acc1 = new Account (
            Name = 'newAcc1'
        );  
        insert acc1;*/
        
        UserRole r = [Select id,Name from UserRole WHERE Name = 'CEO'];
        User thisUser = [SELECT ID,UserRoleId  from USER Where ID =: UserInfo.getUserId()];
        thisUser.UserRoleId =  r.id;
        Update thisUser;
        User u1;
        
         System.runAs(thisUser){
            Profile pfile = [SELECT Name, Id FROM Profile WHERE Name = 'Agency Profile'];
            Account portalAccount = new Account(name = 'portalAccount');
            insert portalAccount;
            
            Contact portalContact = new Contact(LastName = 'portalContact', AccountId = portalAccount.Id);
            insert portalContact;
            
            u1 = new User( email='test@test.com',
                          profileid = pfile.Id, 
                          UserName='portalUser@portalTestUser.com', 
                          Alias = 'a',
                          TimeZoneSidKey='Australia/Sydney',
                          EmailEncodingKey='ISO-8859-1',
                          LocaleSidKey='en_US', 
                          LanguageLocaleKey='en_US',
                          ContactId = portalContact.Id,
                          FirstName = 'Test FirstName',
                          LastName = 'LastName'
                         );
            
            insert u1;
             
              List<Case> testCases = new List<Case>();
        for (Integer i = 0; i < 2; i++) {
            testCases.add(new Case(
                ContactId = portalContact.Id,
                RecordType = new RecordType(Name = 'Technical')
            ));
        }
        insert testCases;
        }
        
        
        

      /*  Contact testContact = new Contact(
            AccountId = acc1.Id,
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'test@gmail.com'
        );
        insert testContact;
        
        User testUser = new User(
            FirstName = 'TestL',
            LastName = 'UserL',
            Email = 'testuserL@example.com',
            Alias = 'tuserL',
            Username = 'testuserL@example.com',
            CommunityNickname = 'tuserL',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id
         
        );
        insert testUser;
        
        User adminUser = [Select Id, UserRoleId from User where Profile.Name = 'System Administrator' AND IsActive = true and UserRoleId !=null LIMIT 1];
        
        User newUser1 = new User(
            profileId = [SELECT Id FROM Profile WHERE UserType = 'PowerPartner' and Name='Agency Profile' LIMIT 1].Id,
            username = 'newUser@yahoo.com'+Math.random(),
            email = 'pb@f.com',
            emailencodingkey = 'UTF-8',
            localesidkey = 'en_US',
            languagelocalekey = 'en_US',
            timezonesidkey = 'America/Los_Angeles',
            alias='nuser',
            lastname='lastname',
            contactId = testContact.id,
            UserRoleId = adminUser
        );
        insert newUser1;*/
        
      /*  List<Case> testCases = new List<Case>();
        for (Integer i = 0; i < 2; i++) {
            testCases.add(new Case(
                ContactId = testContact.Id,
                RecordType = new RecordType(Name = 'Technical')
            ));
        }
        insert testCases;*/
        
        Test.startTest();
        
        // Start the batch job
        BatchToSendVendorEmailTechnical batchJob = new BatchToSendVendorEmailTechnical();
        Database.executeBatch(batchJob);
        
        Test.stopTest();
    }
}