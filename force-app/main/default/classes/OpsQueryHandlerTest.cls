@isTest
public class OpsQueryHandlerTest {
    
    @TestSetup
    Public static void insertData(){
        
       LoanAppl__c loanApp =  TestDataFactory.createLoanApplication(True);
       Applicant__c appli =  TestDataFactory.createSingleApplicant(True,loanApp.Id);
       NDC__c NDC = TestDataFactory.NDCData(True,loanApp.Id,appli.Id);
     
       Application_Query__c appQuery = new  Application_Query__c();
       appQuery.NDC__c =  NDC.Id;
       appQuery.QryTyp__c = 'NDC Query';
       appQuery.Remarks__c = 'Test';
       TriggerBase.bypass('Application_Query__c');
       Insert appQuery;
       TriggerBase.clearBypass('Application_Query__c');
        
       Application_Query__c appQuery1 = new  Application_Query__c();
       appQuery1.NDC__c =  NDC.Id;
       appQuery1.QryTyp__c = 'Response';
       appQuery1.Remarks__c = 'Test';
       TriggerBase.bypass('Application_Query__c');
       Insert appQuery1;
       TriggerBase.clearBypass('Application_Query__c');
        
    }
    
    @isTest
    Public static void test_getOpsqueryRema(){
        
        List<LoanAppl__c> lstLoanApp = [SELECT ID FROM LoanAppl__c];
        Test.StartTest();
         OpsQueryHandler.getOpsqueryRema(lstLoanApp[0].Id);
         Test.StopTest();
    }

}