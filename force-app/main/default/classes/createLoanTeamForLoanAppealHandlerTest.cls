@isTest
public class createLoanTeamForLoanAppealHandlerTest {
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
     
            TH3.Emprole__c = 'CBO';
            update TH3;
            
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
        createLoanTeamForLoanAppealHandler.createLoanTeam(LoanAppealList);
        system.assert(!LoanAppealList.isEmpty(), 'LoanAppealList is not empty'); 
        
    }

}