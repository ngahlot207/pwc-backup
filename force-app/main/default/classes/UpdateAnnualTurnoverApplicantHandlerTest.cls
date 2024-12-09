@istest
public class UpdateAnnualTurnoverApplicantHandlerTest {

    @istest
    public static void testGenerateMethod() {
        LoanAppl__c la = TestDataFactory.createLoanApplication(true);
        
        Applicant__c app = TestDataFactory.createSingleApplicant(true,la.id);
        
        Applicant_Financial__c af=new Applicant_Financial__c();
        af.Loan_Applicant__c=app.Id;
        insert af;
        
        Applicant_Financial_Summary__c afs =new Applicant_Financial_Summary__c();
        afs.Applicant_Financial__c=af.Id;
        afs.Financial_Year__c='2022-2023';
        insert afs;
        
        list<Applicant_Financial_Summary__c> afslist=new List<Applicant_Financial_Summary__c>{afs};
        list<Applicant_Financial_Summary__c> afslist1=new List<Applicant_Financial_Summary__c>();
        
        Test.StartTest();
        UpdateAnnualTurnoverOnApplicantHandler.updateAnnualTurnoverAmount(afslist);
        UpdateAnnualTurnoverOnApplicantHandler.updateAnnualTurnoverAmount(afslist,afslist1);
         Test.StopTest();
    }
}