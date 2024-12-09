@istest
public class CrifAuthLoginRequestGeneratorTest {
    @istest
    public static void testmethod1(){
        
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        Applicant__c appli =  TestDataFactory.createSingleApplicant(true,loanApp.id); 
        
        BRE__c bre =new BRE__c();
        bre.LoanAppl__c=loanApp.id;
        bre.IsLatest__c=true;
        insert bre;
        
        IntgMsg__c intgMsg4 = new IntgMsg__c();
       intgMsg4.Name='Crif Auth Login';
       intgMsg4.BU__c='HL / STL';
       intgMsg4.Status__c='New';
       intgMsg4.MStatus__c='Blank';
       intgMsg4.RefObj__c='LoanAppl__c';
       intgMsg4.RefId__c = loanApp.Id;
       intgMsg4.Trigger_Platform_Event__c=true;
       intgMsg4.Resp__c='';
        
        List<IntgMsg__c> inmsg =new List<IntgMsg__c>{intgMsg4};
        insert inmsg;
        
        test.StartTest();
        CrifAuthLoginRequestGenerator crif =new CrifAuthLoginRequestGenerator();
        crif.generate(inmsg,'','');
        Test.StopTest();
        
    }

}