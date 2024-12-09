@isTest
public class CurrentStageRefreshingTest {
    @isTest
    static void currStageupd(){
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
        
        TeamHierarchy__c teamHieRec = new TeamHierarchy__c();
        teamHieRec.Product_Type__c = 'Home Loan';
        teamHieRec.EmpLevel__c = '1';
        teamHieRec.EmpRole__c = 'RM';
        teamHieRec.Employee__c = testUser.Id;
        insert teamHieRec;
        
        LoanAppl__c loanApp=New LoanAppl__c();
        loanApp.Stage__c = 'QDE';
        loanApp.SubStage__c = 'RM Data Entry';
        loanApp.Stepper__c='ApplicantDetails';
        
        insert loanApp;
            
      
        system.runAs(testUser){
          
            
            try{
             //   test.startTest();
                CurrentStageRefreshing.crntSubStagesUpdate( loanApp.SubStage__c, loanApp.Id);
                CurrentStageRefreshing.crntSubStagesUpdate( loanApp.SubStage__c, null);
                System.AssertEquals('ApplicantDetails',loanApp.Stepper__c);
             //   test.stopTest();
            }catch (Exception ex){
                system.debug('ex;;;'+ex.getMessage());
            }	      
        }
    }
    @isTest
    static void SubStageNameUpd(){
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
        
        TeamHierarchy__c teamHieRec = new TeamHierarchy__c();
        teamHieRec.Product_Type__c = 'Home Loan';
        teamHieRec.EmpLevel__c = '1';
        teamHieRec.EmpRole__c = 'RM';
        teamHieRec.Employee__c = testUser.Id;
        insert teamHieRec;
        
        LoanAppl__c loanApp=New LoanAppl__c();
        loanApp.Stage__c = 'QDE';
        loanApp.SubStage__c = 'RM Data Entry';
        loanApp.Stepper__c='ApplicantDetails';
        
        insert loanApp;
        system.runAs(testUser){
            
            
            LoanAppl__c lan = [select id, Stepper__c,SubStage__c,Stage__c from LoanAppl__c];
            try{
           //     test.startTest();
                CurrentStageRefreshing.subStageNameUpd(lan.Id);
                CurrentStageRefreshing.subStageNameUpd(null);                
                System.AssertEquals('ApplicantDetails',lan.Stage__c);
//                test.stopTest();
            }catch (Exception ex){
                system.debug('ex;;;'+ex.getMessage());
            }	  
        }
    }
  
}