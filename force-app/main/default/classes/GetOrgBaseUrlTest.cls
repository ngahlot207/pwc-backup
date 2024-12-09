@isTest
public class GetOrgBaseUrlTest {
    @isTest
    static void testGetBaseUrl() {
        // Create test data for Loan Application 
        LoanAppl__c loanApp=New LoanAppl__c();
        loanApp.Stage__c = 'QDE';
        loanApp.BrchCode__c = 'HYC';
        loanApp.Product__c = 'Home Loan';
        insert loanApp;
        
        List<Id> loanIds = new List<Id>();
        loanIds.add(loanApp.Id);
        
        // Call the method being tested
        List<GetOrgBaseUrl.Results> resultsList = GetOrgBaseUrl.getBaseUrl(loanIds);
    }
}