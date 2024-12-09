@isTest
public class DocDispFormatedDateOfRecieptHandlerTest {
    @isTest
    Public static void insertData(){
       LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
       DocDispatch__c docDisp = new DocDispatch__c();
       docDisp.LoanAppln__c = loan.Id;
       docDisp.CPARemarks__c = 'Test1';
       docDisp.DateofReceiptbyOps__c = system.now(); 
       Insert docDisp;
        
       DocDispatch__c docDisp1 = new DocDispatch__c();
       docDisp1.Id = docDisp.Id; 
       docDisp1.DateofReceiptbyOps__c = loan.CreatedDate;
       docDisp1.CPARemarks__c = 'Test';
       docDisp1.DateofReceiptbyOps__c = system.now(); 
       Update docDisp1;
        
        Test.StartTest();
        DocDispFormatedDateOfRecieptHandler.beforeUpdate(new List<DocDispatch__c>{docDisp},new List<DocDispatch__c>{docDisp1});  
        Test.StopTest();
        
    }
    
   

}