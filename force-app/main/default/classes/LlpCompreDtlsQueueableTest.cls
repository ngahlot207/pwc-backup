@isTest
public with sharing class LlpCompreDtlsQueueableTest {

    @testSetup
    static void setupData() {  
       	LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
        loan.Product__c='Home Loan';
        update loan;
        
		Applicant__c Applicant=TestDataFactory.createSingleApplicant(true,loan.id);

        List<IntgMsg__c> listIntg = TestDataFactory.createIntMsg(true,'LLP Comprehensive Details',Applicant.Id,'An Unique Identifier');

    }
   
   
    @isTest
    static void testQueueableExecution() {
        IntgMsg__c testMsg = [SELECT Id FROM IntgMsg__c LIMIT 1];
        Map<IntgMsg__c, LlpCompreDtlsResponseWrapper> successResponseMap = new Map<IntgMsg__c, LlpCompreDtlsResponseWrapper>{
            testMsg => new LlpCompreDtlsResponseWrapper()
        };
        
        LlpCompreDtlsResponseWrapper responseWrapper = new LlpCompreDtlsResponseWrapper();
        LlpCompreDtlsResponseWrapper.Metadata  meta= new LlpCompreDtlsResponseWrapper.Metadata();
        meta.last_updated = '2024-06-20';
        meta.api_version='1.3';
        responseWrapper.metadata= meta;
        
        String jsonResponse = JSON.serialize(responseWrapper);
        Test.startTest();
        LlpCompreDtlsQueueable queueable = new LlpCompreDtlsQueueable(successResponseMap, jsonResponse);
        System.enqueueJob(queueable);
        Test.stopTest();

        }

        @isTest
        static void testProcessFailure() {
            // Arrange
            IntgMsg__c testMsg = [SELECT Id FROM IntgMsg__c LIMIT 1];
            Map<IntgMsg__c, LlpCompreDtlsResponseWrapper> successResponseMap = new Map<IntgMsg__c, LlpCompreDtlsResponseWrapper>{
                testMsg => new LlpCompreDtlsResponseWrapper()
            };
            
            LlpCompreDtlsResponseWrapper responseWrapper = new LlpCompreDtlsResponseWrapper();
            responseWrapper.message = 'Some error occurred';
            
            String jsonResponse = JSON.serialize(responseWrapper);
            
            Test.startTest();
            LlpCompreDtlsQueueable queueable = new LlpCompreDtlsQueueable(successResponseMap, jsonResponse);
            System.enqueueJob(queueable);
            Test.stopTest();
        }
        
        @isTest
        static void testExceptionHandling() {
            // Arrange
            IntgMsg__c testMsg = [SELECT Id FROM IntgMsg__c LIMIT 1];
            Map<IntgMsg__c, LlpCompreDtlsResponseWrapper> successResponseMap = new Map<IntgMsg__c, LlpCompreDtlsResponseWrapper>{
                testMsg => new LlpCompreDtlsResponseWrapper()
            };
            
            String invalidJsonResponse = '{invalid_json}';
            
            Test.startTest();
            LlpCompreDtlsQueueable queueable = new LlpCompreDtlsQueueable(successResponseMap, invalidJsonResponse);
            System.enqueueJob(queueable);
            Test.stopTest();
        }
        
        @isTest
        static void testEmptyResponseMap() {
            // Arrange
            Map<IntgMsg__c, LlpCompreDtlsResponseWrapper> emptyResponseMap = new Map<IntgMsg__c, LlpCompreDtlsResponseWrapper>();
            String jsonResponse = '{}';  
    
            Test.startTest();
            LlpCompreDtlsQueueable queueable = new LlpCompreDtlsQueueable(emptyResponseMap, jsonResponse);
            System.enqueueJob(queueable);
            Test.stopTest(); 
        }

    
}