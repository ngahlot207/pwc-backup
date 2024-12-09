@isTest
public class AppleNotificationTest {
    
 @testSetup 
    Public static void insertData(){
       LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
    }
    
    @isTest
    Public static void testMethod1(){
        
        List<LoanAppl__c> lstLoanApp = [SELECT Id,Name,ownerId FROM LoanAppl__c LIMIT 1];
        AppleNotification.sendAppleNotification('Test', 'Test',new List<String> {lstLoanApp[0].ownerId}, lstLoanApp[0].Id);
        List<AppleNotificationInvocableClass.InputVariables> lstInputVariable = new List<AppleNotificationInvocableClass.InputVariables>();
        AppleNotificationInvocableClass.InputVariables objInput = new AppleNotificationInvocableClass.InputVariables();
        objInput.title = 'Test';
        objInput.body = 'Test';
        objInput.targetId = lstLoanApp[0].Id;
        objInput.recipientIds = new List<String> {lstLoanApp[0].ownerId};
        lstInputVariable.add(objInput);
        AppleNotificationInvocableClass.AppleNotificationInvocableClass(lstInputVariable);
    }
    
    
    
}