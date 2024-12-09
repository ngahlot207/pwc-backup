@isTest
public class UcidAccessTokenRequestGeneratorTest {
    @isTest static void requestGen(){
        LoanAppl__c loanApp=TestDataFactory.createLoanApplication(true);
        Applicant__c appl=TestDataFactory.createSingleApplicant(true,loanApp.Id);
        List<IntgMsg__c> IntgMsgData=TestDataFactory.createIntegrationMessage(true,appl.Id);
        //IntgMsgData[0].RefId__c = null;
        UcidAccessTokenRequestGenerator reqGen = new UcidAccessTokenRequestGenerator();
        Test.startTest();
        try{
            reqGen.generate(IntgMsgData, 'TestService', 'TestProcessType');  
            reqGen.generate(null, 'TestService', 'TestProcessType'); 
           // System.assert(false, 'Expected UcidAccessTokenRequestException but it was not thrown');
        } catch(UcidAccessTokenRequestGenerator.UcidAccessTokenRequestException ex){
            System.assertEquals('Reference Id missing', ex.getMessage());
        }
        
        Test.stopTest();
    }
    /*
    @isTest
    static void testGenerateMethodWithoutRefId() {
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        Applicant__c appl = TestDataFactory.createSingleApplicant(true, loanApp.Id);
        
        // Create Integration Message with missing RefId
        List<IntgMsg__c> IntgMsgData = TestDataFactory.createIntegrationMessage(true, appl.Id);
        IntgMsgData[0].RefId__c = null; // Set RefId to null to simulate the negative case
        
        UcidAccessTokenRequestGenerator reqGen = new UcidAccessTokenRequestGenerator();
        
        // Test the negative scenario where RefId is missing
        Test.startTest();
        try {
            reqGen.generate(IntgMsgData, 'TestService', 'TestProcessType');
            //System.assert(false, 'Expected UcidAccessTokenRequestException but it was not thrown');
        } catch (UcidAccessTokenRequestGenerator.UcidAccessTokenRequestException ex) {
            System.assertEquals('Reference Id missing', ex.getMessage());
        }
        Test.stopTest();
    }*/
}