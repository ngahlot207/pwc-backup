@istest
public class ProgIndicConfigControllerTest {
    @isTest
    static void testIntProgIndiConfigDetails(){
        
        LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
        Applicant__c appli =  TestDataFactory.createSingleApplicant(true,loan.id);
        profile prof = [select id from profile where Name = 'System Administrator'];
        user u=new user();
        u.ProfileId = prof.id;
        u.LastName = 'Test Code';
        u.Email = 'test@test.com';
        u.Alias = 'Tcode';
        u.Username = 'test123tring@test.com';
        u.TimeZoneSidKey = 'GMT';
        u.LocaleSidKey = 'en_US';
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        insert u;
        
        loan.OwnerId = u.id;
        loan.Stage__c = 'Disbursed';
        loan.SubStage__c = 'Additional processing';
        loan.Product__c = 'Home Loan';
        update loan;
        TeamHierarchy__c teamHieRec = new TeamHierarchy__c();
        teamHieRec.Product_Type__c = 'Home Loan';
        teamHieRec.EmpLevel__c = '1';
        teamHieRec.EmpRole__c = 'CPA';
        teamHieRec.Employee__c = u.Id;
        insert teamHieRec;
        
        
       // Test.startTest();
            system.debug('loan id' + loan.id);
            try{
                System.runAs(u) {
                ProgIndicConfigController.progIndConfHanlde(loan.id, 'ApplicantDetails');
                ProgIndicConfigController.progIndConfHanlde(loan.id, null);
                ProgIndicConfigController.stepperStagesAvailable(loan.id);
                ProgIndicConfigController.subStepperQueryConfi(loan.id, 'ApplicantDetails');
                }
            } catch(NullPointerException ex){
                system.assertEquals('Attempt to de-reference a null object', ex.getMessage());
            }
            
            try{
                ProgIndicConfigController.stepperStagesAvailable(loan.id);
                ProgIndicConfigController.stepperStagesAvailable(null);
            } catch(NullPointerException ex){
                system.assertEquals('Attempt to de-reference a null object', ex.getMessage());
            }
        }
}