@isTest
public class ShowMultipleComponentEnhancementTest {

    @isTest
    static void testGetDiplayConfigAsRoleNStatus(){
        
        LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
        loan.id = loan.id;
        loan.Product__c = 'Home Loan';	
        loan.Stepper__c = 'Applicant Details';
        loan.Stage__c = 'QDE';
        loan.SubStage__c = 'RM Data Entry';
        update loan;
        
        Applicant__c appli =  TestDataFactory.createSingleApplicant(true,loan.id);
        user u=TestDataFactory.UserData(true);
       
        user sup=TestDataFactory.supervisor(true);
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
        
        system.runAs(testUser){
           // test.startTest();
            try{
                //system.debug( loan.Id +'  ====  ' + listofMeta[0].Stage_Name__c + ' ====  ' +app.Id);
                ShowMultipleComponentEnhancement.getDiplayConfigAsRoleNStatus(loan.Id,'ApplicantDetails','ApplicantDetails', appli.id);
                ShowMultipleComponentEnhancement.getDiplayConfigAsRoleNStatus(loan.Id,'ApplicantDetails',null, null);
               
                
            }
            catch(Exception e){
                system.assertEquals('Script-thrown exception', e.getMessage());
            }
          //  test.stopTest();
        }
    }
}