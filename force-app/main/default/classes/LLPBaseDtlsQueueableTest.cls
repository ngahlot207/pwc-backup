@isTest
public with sharing class LLPBaseDtlsQueueableTest {

    @testSetup
    static void setupData() { 
        List<Integer> pdfValues = new List<Integer>{123456, 22345, 39876}; 
       	LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
        loan.Product__c='Home Loan';
        update loan;
        
		Applicant__c Applicant=TestDataFactory.createSingleApplicant(true,loan.id);

        List<IntgMsg__c> listIntg = TestDataFactory.createIntMsg(true,'LLP Base Details',Applicant.Id,'An Unique Identifier');

    }
   
   
    @isTest
    static void testQueueableExecution() {
        IntgMsg__c testMsg = [SELECT Id FROM IntgMsg__c LIMIT 1];
        Map<IntgMsg__c, LLPBaseDtlsResponseWrapper> successResponseMap = new Map<IntgMsg__c, LLPBaseDtlsResponseWrapper>{
            testMsg => new LLPBaseDtlsResponseWrapper()
        };
        
        LLPBaseDtlsResponseWrapper responseWrapper = new LLPBaseDtlsResponseWrapper();
        LLPBaseDtlsResponseWrapper.cls_metadata  meta= new LLPBaseDtlsResponseWrapper.cls_metadata();
        meta.last_updated = '2024-06-20';
        meta.api_version='1.3';
        responseWrapper.metadata= meta;
        
        String jsonResponse = JSON.serialize(responseWrapper);
        Test.startTest();
        LLPBaseDtlsQueueable queueable = new LLPBaseDtlsQueueable(successResponseMap, jsonResponse);
        System.enqueueJob(queueable);
        Test.stopTest();

        }

        @isTest
        static void testProcessFailure() {
            // Arrange
            IntgMsg__c testMsg = [SELECT Id FROM IntgMsg__c LIMIT 1];
            Map<IntgMsg__c, LLPBaseDtlsResponseWrapper> successResponseMap = new Map<IntgMsg__c, LLPBaseDtlsResponseWrapper>{
                testMsg => new LLPBaseDtlsResponseWrapper()
            };
            
            LLPBaseDtlsResponseWrapper responseWrapper = new LLPBaseDtlsResponseWrapper();
            responseWrapper.message = 'Some error occurred';
            
            String jsonResponse = JSON.serialize(responseWrapper);
            
            Test.startTest();
            LLPBaseDtlsQueueable queueable = new LLPBaseDtlsQueueable(successResponseMap, jsonResponse);
            System.enqueueJob(queueable);
            Test.stopTest();
        }
        
        @isTest
        static void testExceptionHandling() {
            // Arrange
            IntgMsg__c testMsg = [SELECT Id FROM IntgMsg__c LIMIT 1];
            Map<IntgMsg__c, LLPBaseDtlsResponseWrapper> successResponseMap = new Map<IntgMsg__c, LLPBaseDtlsResponseWrapper>{
                testMsg => new LLPBaseDtlsResponseWrapper()
            };
            
            String invalidJsonResponse = '{invalid_json}';
            
            Test.startTest();
            LLPBaseDtlsQueueable queueable = new LLPBaseDtlsQueueable(successResponseMap, invalidJsonResponse);
            System.enqueueJob(queueable);
            Test.stopTest();
        }
        
        @isTest
        static void testEmptyResponseMap() {
            // Arrange
            Map<IntgMsg__c, LLPBaseDtlsResponseWrapper> emptyResponseMap = new Map<IntgMsg__c, LLPBaseDtlsResponseWrapper>();
            String jsonResponse = '{}';  
    
            Test.startTest();
            LLPBaseDtlsQueueable queueable = new LLPBaseDtlsQueueable(emptyResponseMap, jsonResponse);
            System.enqueueJob(queueable);
            Test.stopTest(); 
        }

    
}