@isTest
public class PropertyquestionController_Test {
    
    @testSetup
    public static void testData(){
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);     
        Applicant__c applicant = TestDataFactory.createSingleApplicant(true, loanApp.Id);
        ApplAsset__c testApplAsset = TestDataFactory.applAssetData(false, applicant.Id);
        testApplAsset.LoanAppln__c = loanApp.Id;
        insert testApplAsset;
        
        PropQues__c testPropQues = TestDataFactory.proQuesData(false);
        testPropQues.Category__c = 'General Norms';
        insert testPropQues;
        
    }
    
    @isTest
    public static void retrieveAllPropQuesTest(){
        ApplAsset__c testApplAsset = [SELECT Id FROM ApplAsset__c LIMIT 1];
        PropertyQuestionController.retrieveAllPropQues(testApplAsset.Id);
    }
    
    @isTest
    public static void retrieveAllPropQuesRespTest(){
        ApplAsset__c testApplAsset = [SELECT Id FROM ApplAsset__c LIMIT 1];
        PropQuesResp__c testQuesResData = TestDataFactory.propQuesRespData(true, testApplAsset.Id);
        PropQuesRespJn__c testQuesJn = TestDataFactory.propQuesResJnData(true, testQuesResData.Id);
        PropertyQuestionController.retrieveAllPropQues(testApplAsset.Id);
    }

}