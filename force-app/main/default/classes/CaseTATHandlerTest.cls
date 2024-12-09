@isTest
public class CaseTATHandlerTest {
    @testsetup
    Public static void InsertCaseRecord(){
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        Case objCase = new Case();
        objCase.Status = 'Query';
        objCase.Origin = 'Email';
        objCase.Loan_Application__c = loanApp.Id;
        Insert objCase;
        
        Case objCaseUpdate = new Case();
        objCaseUpdate.Id = objCase.Id;
        objCaseUpdate.Status = 'Cancelled';
        objCaseUpdate.Origin = 'Phone';
        objCaseUpdate.Loan_Application__c = loanApp.Id;
        Update objCaseUpdate;
        
    }
    
    @isTest
    Public static void callCaseTatHandlerMethod(){
        List<Case> newCaseList = [SELECT Id,ownerId,Loan_Application__c,Status FROM Case WHERE Status ='Query'];
        List<Case> oldCaseList = [SELECT Id,ownerId,Loan_Application__c,Status FROM Case WHERE Origin ='Phone'];

        CaseTATHandler.afterInsert(newCaseList);
        CaseTATHandler.afterUpdate(newCaseList,oldCaseList);
    }

}