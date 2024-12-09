@isTest
public class CrifAuthLoginResponseProcessorTest {
    
    @isTest
   Public static void testProcessMethod() {
        
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        Applicant__c appli =  TestDataFactory.createSingleApplicant(true,loanApp.id); 
        
       BRE__c bre =new BRE__c();
       bre.LoanAppl__c=loanApp.id;
       bre.IsLatest__c=true;
       insert bre;
       
       
       List<IntgMsg__c> intList=new List<IntgMsg__c>();
       
       IntgMsg__c intgMsg1 = new IntgMsg__c();
       intgMsg1.Name='Crif Auth Login';
       intgMsg1.BU__c='HL / STL';
       intgMsg1.Status__c='New';
       intgMsg1.MStatus__c='Blank';
       intgMsg1.RefObj__c='LoanAppl__c';
       intgMsg1.RefId__c = loanApp.Id;
       intgMsg1.Trigger_Platform_Event__c=true;
       intgMsg1.Resp__c='{"access_token":"eyJhbGciOiJIUzM4NCJ9.eyJpc3MiOiJDUklGIiwic3ViIjoiSldUVVNFUiIsImlhdCI6MTcxMDc2Mzc3NSwiZXhwIjoxNzEwNzkyNTc1LCJpZCI6MTg4LCJyb2xlIjoiUk9MRV9BUFBMSUNBVElPTiIsInBvd2VyTWFuYWdlciI6ZmFsc2UsImNsaWVudFZlcnNpb24iOiI3LjEuMjguMjMwNyIsImFjdGl2ZVNlc3Npb25JZCI6MzUyNzJ9.Hs8RWmAyfOTF4abKcfgu1w6tQhFs_oeBEVRXsFfjAQeaYS6E9VAYaiB9hb1sCpSl","token_type":"Bearer","expires_in":28800}';
       intList.add(intgMsg1);
       
       IntgMsg__c intgMsg2 = new IntgMsg__c();
       intgMsg2.Name='Crif Auth Login';
       intgMsg2.BU__c='HL / STL';
       intgMsg2.Status__c='New';
       intgMsg2.MStatus__c='Blank';
       intgMsg2.RefObj__c='LoanAppl__c';
       intgMsg2.RefId__c = loanApp.Id;
       intgMsg2.Trigger_Platform_Event__c=true;
       intgMsg2.Resp__c='{"timestamp":"2024-02-13T20:13:16.227+01:00","status":400,"error":"Bad Request","exception":"Unable to acquire JDBC Connection","message":"No message available","path":"/api/auth/login","reason":"DATABASE","code":"DB_ERROR"}';
       intList.add(intgMsg2);
       
       IntgMsg__c intgMsg3 = new IntgMsg__c();
       intgMsg3.Name='Crif Auth Login';
       intgMsg3.BU__c='HL / STL';
       intgMsg3.Status__c='New';
       intgMsg3.MStatus__c='Blank';
       intgMsg3.RefObj__c='LoanAppl__c';
       intgMsg3.RefId__c = loanApp.Id;
       intgMsg3.Trigger_Platform_Event__c=true;
       intgMsg3.Resp__c='{"timestamp":"2024-02-13T20:13:16.227+01:00","status":400,"error":"","exception":"Unable to acquire JDBC Connection","message":"No message available","path":"/api/auth/login","reason":"DATABASE","code":"DB_ERROR"}';
       intList.add(intgMsg3);
       
       IntgMsg__c intgMsg4 = new IntgMsg__c();
       intgMsg4.Name='Crif Auth Login';
       intgMsg4.BU__c='HL / STL';
       intgMsg4.Status__c='New';
       intgMsg4.MStatus__c='Blank';
       intgMsg4.RefObj__c='LoanAppl__c';
       intgMsg4.RefId__c = loanApp.Id;
       intgMsg4.Trigger_Platform_Event__c=true;
       intgMsg4.Resp__c='';
       intList.add(intgMsg4);
       
       //List<IntgMsg__c> intList=new List<IntgMsg__c>{intgMsg1};
           insert intList;
       Test.StartTest();
       CrifAuthLoginResponseProcessor.process(intList);
       Test.StopTest();
    }
    
}