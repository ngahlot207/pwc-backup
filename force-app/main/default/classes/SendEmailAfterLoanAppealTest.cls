@isTest
public class SendEmailAfterLoanAppealTest {
    @testsetup
    static void AdharRequestGenTestMethod(){
        
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
        User testUser1 = new User(LastName = 'test user 2', 
                                  Username = 'test.createLoanTeam.UW@example.com', 
                                  Email = 'test.UW@example.com', 
                                  Alias = 'testu1', 
                                  TimeZoneSidKey = 'GMT', 
                                  LocaleSidKey = 'en_GB', 
                                  EmailEncodingKey = 'ISO-8859-1', 
                                  ProfileId = testProfile.Id, 
                                  LanguageLocaleKey = 'en_US'); 
        insert testUser1;
        system.runAs(testUser){
            BankBrchMstr__c bnkbranch=TestDataFactory.TestDataBankBranchMaster(true);
            BankBrchMstr__c bnkbranch1=TestDataFactory.TestDataBankBranchMaster1(true);
            TeamHierarchy__c TH= testDataFactory.TestDataTeamHierarchy_nonSup(true,testUser.id,bnkbranch.Id);// RM Role
            
            TeamHierarchy__c TH1= testDataFactory.TestDataTeamHierarchy_nonSup1(true,testUser.id,bnkbranch.Id,TH.Id);// SM Role
            TeamHierarchy__c TH3= testDataFactory.TestDataTeamHierarchy_CPA(true,testUser.id,bnkbranch.Id,TH.Id);// CPA Role
            
            TeamHierarchy__c TH2= testDataFactory.TestDataTeamHierarchy_UW(true,testUser1.id,bnkbranch.Id,TH.Id);// UW Role
            //LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
            
            TH1.Emprole__c = 'BOM';
            update TH1;
            
            LoanAppl__c loanApp = new LoanAppl__c();
            loanApp.Stage__c = 'QDE';
            loanApp.BrchCode__c = 'HYC';
            loanApp.Product__c = 'Home Loan';
            loanApp.Loan_Tenure_Months__c = 120;
            insert loanApp;
            
            LoanAppeal__c appeal = new LoanAppeal__c();
            appeal.Status__c = 'New';
            appeal.Comments__c='Relook Application';
            appeal.LoanAppl__c = loanApp.Id;
            insert appeal;
            
        }
    }
    @isTest
    Public Static Void testCreateLoanTeam(){ 
        List<LoanAppeal__c> LoanAppealList= new List<LoanAppeal__c>([select id,LoanAppl__c,LAN__c,Name from LoanAppeal__c limit 1]);
        List <TeamHierarchy__c> lstTeams = new List<TeamHierarchy__c>([select employee__c,EmpBrch__c,EmpRole__c,Employee__r.Email,BranchCode__c,Supervisor__r.EmpBrch__c,Supervisor__r.employee__c,EmployeEmail__c from TeamHierarchy__c ]);  
        system.debug('lstTeams::::'+lstTeams);
        
        // system.assert(!LoanAppealList.isEmpty(), 'LoanAppealList is not empty');
        SendEmailAfterLoanAppeal.SendEmail(LoanAppealList);
        
    }
    
    @isTest
    Public Static Void testSendEmailAfterUpdate(){
        User u = [select id, email from User where email ='test.1@example.com' limit 1];
        BankBrchMstr__c bnkbranch1=TestDataFactory.TestDataBankBranchMaster1(true);
        TeamHierarchy__c TH= testDataFactory.TestDataTeamHierarchy_nonSup(true,u.id,bnkbranch1.Id);
        TeamHierarchy__c TH2= testDataFactory.TestDataTeamHierarchy_UW(true,u.id,bnkbranch1.Id,TH.Id);
        List<LoanAppeal__c> LoanAppealList= new List<LoanAppeal__c>();
        LoanAppeal__c LoanAppeal= [select id,LoanAppl__c,LAN__c,Name,OwnerEmail__c,OwnerId from LoanAppeal__c limit 1];
        LoanAppeal.OwnerId=u.Id;	 
        LoanAppealList.add(LoanAppeal);
        update LoanAppealList;
        List <TeamHierarchy__c> lstTeams = new List<TeamHierarchy__c>([select employee__c,EmpBrch__c,EmpRole__c,Employee__r.Email,BranchCode__c,Supervisor__r.EmpBrch__c,Supervisor__r.employee__c,EmployeEmail__c from TeamHierarchy__c ]);  
        system.debug('lstTeams::::'+lstTeams);
        
        // system.assert(!LoanAppealList.isEmpty(), 'LoanAppealList is not empty');
        SendEmailAfterLoanAppeal.sendEmailAfterUpdate(LoanAppealList);
        
    }
}