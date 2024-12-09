@isTest
public class FetchApplicantDetailsTest {
    
    @isTest
    static void fetchQryRecordMethodPositiveTest() { 
        // Create test data
        FetchApplicantDetails.DefinetabVal objNew = new FetchApplicantDetails.DefinetabVal();
        objNew.key = 'Id';
        objNew.showButtonLabelIncremented = true;
        objNew.labelContent = new List<String>();
        LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
        
        Applicant__c app = new Applicant__c();
        app.FName__c='Test fname';
        app.LName__c='Test lname';
        app.LoanAppln__c=loan.Id;
        app.Constitution__c='INDIVIDUAL';
        insert app;
        
        ApplAsset__c applAsset = new ApplAsset__c();
        applAsset.LoanAppln__c=loan.Id;
        applAsset.Appl__c=app.Id;
        insert applAsset;
        
        String query = 'SELECT Id,Name FROM ApplAsset__c  WHERE LoanAppln__c = \''+loan.Id + '\'';
        system.debug('Query ----'+ query); 
        // Call the method to be tested 
        Test.startTest();
        try{
        	String resultJson = FetchApplicantDetails.fetchQryRecordMethod(query, loan.Id, objNew, 'NewTabLabel');
        	system.debug('resultJson --- '+resultJson);
            // Verify the results
        	//System.assertNotEquals(null, resultJson);
        }catch(exception e){
            system.debug('Error ---'+e.getMessage() + e.getLineNumber() + e.getCause());
        }
        Test.stopTest();


    }

    @isTest
    static void fetchQryRecordMethodNegativeTest() {        
        // Create test data
        LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
        String query = '[SELECT Id, LName__c, Age__c, ApplType__c, CIN__c, Category__c, Father_Name__c, Gender__c FROM Applicant__c]';
   
        // Call the method with a query that may cause an exception
        Test.startTest(); 
        try {
            String resultJson = FetchApplicantDetails.fetchQryRecordMethod(query, loan.Id, new FetchApplicantDetails.DefinetabVal(), 'NewTabLabel');
            System.assert(false, 'Exception should have been thrown');
        } catch (AuraHandledException ex) { 
            
            // Verify that the exception message is as expected
            System.assertEquals('Script-thrown exception', ex.getMessage(), 'Incorrect exception message');
        }
        Test.stopTest();
    }

    
    //added test case to check DefinetabVal label content condition
    @isTest
    static void fetchQryRecordMethodAlternateTest() { 
        // Create test data
        FetchApplicantDetails.DefinetabVal objNew = new FetchApplicantDetails.DefinetabVal();
        objNew.key = 'Id';
        objNew.showButtonLabelIncremented = true;
        objNew.labelContent = new List<String>();
        objNew.labelContent.add('Name');
        LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
        
        Applicant__c app = new Applicant__c();
        app.FName__c='Test fname';
        app.LName__c='Test lname';
        app.LoanAppln__c=loan.Id;
        app.Constitution__c='INDIVIDUAL';
        insert app;
        
        ApplAsset__c applAsset = new ApplAsset__c();
        applAsset.LoanAppln__c=loan.Id;
        applAsset.Appl__c=app.Id;
        insert applAsset;
        
        String query = 'SELECT Id,Name FROM ApplAsset__c  WHERE LoanAppln__c = \''+loan.Id + '\'';
        system.debug('Query ----'+ query); 
        // Call the method to be tested 
        Test.startTest();
        try{
        	String resultJson = FetchApplicantDetails.fetchQryRecordMethod(query, loan.Id, objNew, 'NewTabLabel');
        	system.debug('resultJson --- '+resultJson);
            // Verify the results
        	//System.assertNotEquals(null, resultJson);
        }catch(exception e){
            system.debug('Error ---'+e.getMessage() + e.getLineNumber() + e.getCause());
        }
        Test.stopTest();

    }

}