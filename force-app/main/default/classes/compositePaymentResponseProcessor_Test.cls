@isTest
public class compositePaymentResponseProcessor_Test {

    @testSetup 
    Public static void insertData(){
           LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
           Applicant__c appli =  TestDataFactory.createSingleApplicant(true,loan.id); 
           Repayment_Account__c repayAccount = TestDataFactory.rePayAccData(True,loan.Id);
         
           RepayAccVerify__c objRepymentVerifi = new RepayAccVerify__c();
           objRepymentVerifi.RepayAcc__c = repayAccount.Id;
           TriggerBase.bypass('RepayAccVerify__c');
           Insert objRepymentVerifi;
           TriggerBase.clearBypass('RepayAccVerify__c');
        
           Disbursement__c objDisb = new Disbursement__c();
           objDisb.Loan_Appli__c = loan.Id;
           TriggerBase.bypass('Disbursement__c');
           Insert objDisb;
           TriggerBase.clearBypass('Disbursement__c');  
        
           Split_Disbur__c objSplit = new Split_Disbur__c();
           objSplit.DisburseRela__c = objDisb.id;
           TriggerBase.bypass('Split_Disbur__c');
           Insert objSplit;
           TriggerBase.clearBypass('Split_Disbur__c');
    }
    
    @isTest
    Public static void testMethod1(){
         String json = '{"ActCode": "123", "Response": "Success", "BankRRN": "456", "BeneName": "John Doe", "success": "true", "TransRefNo": "789", "errorCode": "E001", "description": "Error occurred"}';

        List<LoanAppl__c> lstLoanApp = [SELECT ID FROM LoanAppl__c LIMIT 1];
        List<RepayAccVerify__c> lstRepaymentVerification = [SELECT Id FROM RepayAccVerify__c Limit 1];
        List<IntgMsg__c> intMsglist =  new List<IntgMsg__c>();
        
        for(IntgMsg__c intMess : TestDataFactory.createIntMsg(true, 'ICICI PennyDrop', lstRepaymentVerification[0].id, json)){
            intMess.RefObj__c = 'RepayAccVerify__c';
            intMess.RefId__c = lstRepaymentVerification[0].id;
            intMsglist.add(intMess);
        }
        
        system.assert(!intMsglist.isEmpty(),'Integration message List Should not empty');
        Test.StartTest();
        CompositePaymentResponseProcessor.process(intMsglist);
        Test.StopTest();
     }
    
      @isTest
    Public static void testMethod2(){
         String json = '{"ActCode": "123", "Response": "Success", "BankRRN": "456", "BeneName": "John Doe", "success": "true", "TransRefNo": "789", "errorCode": "E001", "description": "Error occurred"}';

        List<LoanAppl__c> lstLoanApp = [SELECT ID FROM LoanAppl__c LIMIT 1];
        List<Split_Disbur__c> lstRepaymentVerification = [SELECT Id FROM Split_Disbur__c Limit 1];
        List<IntgMsg__c> intMsglist =  new List<IntgMsg__c>();
        
        for(IntgMsg__c intMess : TestDataFactory.createIntMsg(true, 'ICICI PennyDrop', lstRepaymentVerification[0].id, json)){
            intMess.RefObj__c = 'Split_Disbur__c';
            intMess.RefId__c = lstRepaymentVerification[0].id;
            intMsglist.add(intMess);
        }
          system.assert(!intMsglist.isEmpty(),'Integration message List Should not empty');
        Test.StartTest();
        CompositePaymentResponseProcessor.process(intMsglist);
        Test.StopTest();
     }
    
    
      @isTest
    Public static void testMethod3(){
         String json = '{"ActCode": "0", "Response": "Success", "BankRRN": "456", "BeneName": "John Doe", "success": "true", "TransRefNo": "789", "errorCode": "E001", "description": "Error occurred"}';

        List<LoanAppl__c> lstLoanApp = [SELECT ID FROM LoanAppl__c LIMIT 1];
        List<Split_Disbur__c> lstRepaymentVerification = [SELECT Id FROM Split_Disbur__c Limit 1];
        List<IntgMsg__c> intMsglist =  new List<IntgMsg__c>();
        
        for(IntgMsg__c intMess : TestDataFactory.createIntMsg(true, 'ICICI PennyDrop', lstRepaymentVerification[0].id, json)){
            intMess.RefObj__c = 'Split_Disbur__c';
            intMess.RefId__c = lstRepaymentVerification[0].id;
            intMsglist.add(intMess);
        }
          system.assert(!intMsglist.isEmpty(),'Integration message List Should not empty');
        Test.StartTest();
        CompositePaymentResponseProcessor.process(intMsglist);
        Test.StopTest();
     }
    
    
      @isTest
    Public static void testMethod4(){
          String json = '{"ActCode": "0", "Response": "Success", "BankRRN": "456", "BeneName": "John Doe", "success": "true", "TransRefNo": "789", "errorCode": "E001", "description": "Error occurred"}';

        List<LoanAppl__c> lstLoanApp = [SELECT ID FROM LoanAppl__c LIMIT 1];
        List<RepayAccVerify__c> lstRepaymentVerification = [SELECT Id FROM RepayAccVerify__c Limit 1];
        List<IntgMsg__c> intMsglist =  new List<IntgMsg__c>();
        
        for(IntgMsg__c intMess : TestDataFactory.createIntMsg(true, 'ICICI PennyDrop', lstRepaymentVerification[0].id, json)){
            intMess.RefObj__c = 'RepayAccVerify__c';
            intMess.RefId__c = lstRepaymentVerification[0].id;
            intMsglist.add(intMess);
        }
          system.assert(!intMsglist.isEmpty(),'Integration message List Should not empty');
        Test.StartTest();
        CompositePaymentResponseProcessor.process(intMsglist);
        Test.StopTest();
     }
    
}