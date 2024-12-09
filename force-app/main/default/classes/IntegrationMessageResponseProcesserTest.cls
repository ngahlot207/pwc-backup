@isTest
public class IntegrationMessageResponseProcesserTest {
@isTest
    static void intRespProcessor(){
         LoanAppl__c loanApp=TestDataFactory.createLoanApplication(true);
        Applicant__c appl=TestDataFactory.createSingleApplicant(true,loanApp.Id);
        List<IntgMsg__c> IntgMsgData=TestDataFactory.createIntegrationMessage(true,appl.Id);
        
        Map<Id,IntgMsg__c> integrationListToMap = new Map<Id,IntgMsg__c>();
        for(IntgMsg__c intega : IntgMsgData){
            integrationListToMap.put(intega.Id,intega);
        }
        system.debug('integrationListToMap:'+integrationListToMap);      
 
        List<String> testServiceList = new List<String>{'SFDC Aadhar Masking', 'Cheque OCR'};
        List<String> testBuList = new List<String>{'HL / STL', 'HL / STL'};
 
        Test.startTest();
        IntegrationMessageResponseProcesser.responseProcesser(integrationListToMap, testServiceList, testBuList);
       // IntegrationMessageResponseProcesser.responseProcesser(integrationListToMap, null, null);
        Test.stopTest();
    }
    
    @isTest
    Public static void negativeintRespProcessor(){
       LoanAppl__c loanApp=TestDataFactory.createLoanApplication(true);
        Applicant__c appl=TestDataFactory.createSingleApplicant(true,loanApp.Id);
        List<IntgMsg__c> IntgMsgData=TestDataFactory.createIntegrationMessage(true,appl.Id);
        
        Map<Id,IntgMsg__c> integrationListToMap = new Map<Id,IntgMsg__c>();
        for(IntgMsg__c intega : IntgMsgData){
            integrationListToMap.put(intega.Id,intega);
        }  
         Test.startTest();
         IntegrationMessageResponseProcesser.responseProcesser(integrationListToMap, null, null);
        Test.stopTest();
        
    }
    
    
}