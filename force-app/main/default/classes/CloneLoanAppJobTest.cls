@isTest
public class CloneLoanAppJobTest {
    
    @testSetup
    static void setupTestData() {
        // Create a TeamHierarchy__c record
        TeamHierarchy__c teamHierarchy = new TeamHierarchy__c(
            Employee__c = UserInfo.getUserId(),
            EmpRole__c = 'CPA' // Adjust this role as needed for your tests
        );
        TriggerBase.bypass('TeamHierarchy__c');
        insert teamHierarchy;
        TriggerBase.clearBypass('TeamHierarchy__c');
        
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        loanApp.Stage__c = 'UnderWriting';
        loanApp.SubStage__c = 'Credit Appraisal';
        loanApp.LoginAcceptance__c = true;
        loanApp.FileAcceptance__c = true;
        loanApp.FinnoneAppid__c = 'FGYUI76567';
        TriggerBase.bypass('LoanAppl__c');
        update loanApp;
        TriggerBase.clearBypass('LoanAppl__c');
    }
    
    @isTest
    static void cloneLoanAppJobTestMethod() {
        LoanAppl__c loanApp = [SELECT Id,Stage__c,SubStage__c FROM LoanAppl__c LIMIT 1];
        
        // Set input data for the CloneLoanAppwrpr class
        CloneLoanAppController.CloneLoanAppwrpr inputData = new CloneLoanAppController.CloneLoanAppwrpr();
        inputData.recordId = loanApp.Id;
        inputData.userId = UserInfo.getUserId();
        inputData.cloneReason = 'BT + Top Up';
        
        // Instantiate the CloneLoanAppJob with input data
        CloneLoanAppController.CloneLoanDetailsWrpr job = CloneLoanAppJob.cloneLoanAppMethod(inputData);
        
        
        // Validate the cloned loan application
        LoanAppl__c clonedLoanApp = [SELECT Id, ClonedBy__c, ClonedFor__c, RMSMName__c, CloneRea__c FROM LoanAppl__c WHERE ClonedFor__c = :loanApp.Id LIMIT 1];
        System.assertNotEquals(null, clonedLoanApp, 'Cloned Loan Application should exist.');
        System.assertEquals(UserInfo.getUserId(), clonedLoanApp.ClonedBy__c, 'ClonedBy__c should match the user ID.');
        System.assertEquals(loanApp.Id, clonedLoanApp.ClonedFor__c, 'ClonedFor__c should match the original loan application ID.');
        System.assertEquals(inputData.cloneReason, clonedLoanApp.CloneRea__c, 'CloneRea__c should match the clone reason.');
        
        
        Boolean isAssert = true;
        try{
           // CloneLoanAppJob jobnew = new CloneLoanAppJob(null); new 
           CloneLoanAppJob.cloneLoanAppMethod(null);
           // System.enqueueJob(jobnew);   
        }catch(NullPointerException ex){
            isAssert = false;
            system.assertEquals('Attempt to de-reference a null object', ex.getMessage());
        }  
        //system.assertEquals(true, isAssert);
    }  
    
    @isTest
    static void cloneLoanAppJobTestMethodOne() {
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        loanApp.Stage__c = 'Post Sanction';
        loanApp.SubStage__c = 'Data Entry';
        loanApp.LoginAcceptance__c = true;
        loanApp.FileAcceptance__c = true;
        loanApp.FinnoneAppid__c = 'FGYUI76567';
        TriggerBase.bypass('LoanAppl__c');
        TriggerActionFlow.bypass('RT_After_Loan_Application_Flow'); 
        update loanApp;
        TriggerBase.clearBypass('LoanAppl__c');
        TriggerActionFlow.clearBypass('RT_After_Loan_Application_Flow');
        // Set input data for the CloneLoanAppwrpr class
        CloneLoanAppController.CloneLoanAppwrpr inputData = new CloneLoanAppController.CloneLoanAppwrpr();
        inputData.recordId = loanApp.Id;
        inputData.userId = UserInfo.getUserId();
        inputData.cloneReason = 'BT + Top Up';
        try{
            CloneLoanAppController.CloneLoanDetailsWrpr job =  CloneLoanAppJob.cloneLoanAppMethod(inputData);  
        }catch(DmlException e){
            //system.assertEquals('Attempt to de-reference a null object', e.getMessage());
        }
        
    }  
    
    @isTest
    static void cloneLoanAppJobTestMethodTwo() {
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        loanApp.Stage__c = 'QDE';
        loanApp.SubStage__c = 'Additional Data Entry';
        TriggerBase.bypass('LoanAppl__c');
        update loanApp;
        TriggerBase.clearBypass('LoanAppl__c');
        // Set input data for the CloneLoanAppwrpr class
        CloneLoanAppController.CloneLoanAppwrpr inputData = new CloneLoanAppController.CloneLoanAppwrpr();
        inputData.recordId = loanApp.Id;
        inputData.userId = UserInfo.getUserId();
        inputData.cloneReason = 'BT + Top Up';
        
        // Instantiate the CloneLoanAppJob with input data
        CloneLoanAppController.CloneLoanDetailsWrpr job =  CloneLoanAppJob.cloneLoanAppMethod(inputData);  
    
    } 
    @isTest
    static void cloneLoanAppJobTestMethodThree() {
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        loanApp.Stage__c = 'QDE';
        loanApp.SubStage__c = 'RM Data Entry';
        TriggerBase.bypass('LoanAppl__c');
        update loanApp;
        TriggerBase.clearBypass('LoanAppl__c');
        // Set input data for the CloneLoanAppwrpr class
        CloneLoanAppController.CloneLoanAppwrpr inputData = new CloneLoanAppController.CloneLoanAppwrpr();
        inputData.recordId = loanApp.Id;
        inputData.userId = UserInfo.getUserId();
        inputData.cloneReason = 'BT + Top Up';
        
       CloneLoanAppController.CloneLoanDetailsWrpr job =  CloneLoanAppJob.cloneLoanAppMethod(inputData);  
    
    } 
}