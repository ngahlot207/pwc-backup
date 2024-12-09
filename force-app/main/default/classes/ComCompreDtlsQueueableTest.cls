@isTest
public with sharing class ComCompreDtlsQueueableTest {

    @testSetup
    static void setupData() {  
       	LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
        loan.Product__c='Home Loan';
        update loan;
        
		Applicant__c Applicant=TestDataFactory.createSingleApplicant(true,loan.id);

        List<IntgMsg__c> listIntg = TestDataFactory.createIntMsg(true,'Company Comprehensive Details',Applicant.Id,'An Unique Identifier');

    }
   
   
    @isTest
    static void testQueueableExecution() {
        IntgMsg__c testMsg = [SELECT Id FROM IntgMsg__c LIMIT 1];
        Map<IntgMsg__c, ComCompreDtlsResponseWrapper> successResponseMap = new Map<IntgMsg__c, ComCompreDtlsResponseWrapper>{
            testMsg => new ComCompreDtlsResponseWrapper()
        };
        
        ComCompreDtlsResponseWrapper responseWrapper = new ComCompreDtlsResponseWrapper();
        ComCompreDtlsResponseWrapper.Metadata  meta= new ComCompreDtlsResponseWrapper.Metadata();
        meta.last_updated = '2024-06-20';
        meta.api_version='1.3';
        responseWrapper.metadata= meta;
        
        String jsonResponse = JSON.serialize(responseWrapper);
        Test.startTest();
        ComCompreDtlsQueueable queueable = new ComCompreDtlsQueueable(successResponseMap, jsonResponse);
        System.enqueueJob(queueable);
        Test.stopTest();

        }

        @isTest
        static void testProcessFailure() {
            // Arrange
            IntgMsg__c testMsg = [SELECT Id FROM IntgMsg__c LIMIT 1];
            Map<IntgMsg__c, ComCompreDtlsResponseWrapper> successResponseMap = new Map<IntgMsg__c, ComCompreDtlsResponseWrapper>{
                testMsg => new ComCompreDtlsResponseWrapper()
            };
            
            ComCompreDtlsResponseWrapper responseWrapper = new ComCompreDtlsResponseWrapper();
            responseWrapper.message = 'Some error occurred';
            
            String jsonResponse = JSON.serialize(responseWrapper);
            
            Test.startTest();
            ComCompreDtlsQueueable queueable = new ComCompreDtlsQueueable(successResponseMap, jsonResponse);
            System.enqueueJob(queueable);
            Test.stopTest();
        }
        
        @isTest
        static void testExceptionHandling() {
            // Arrange
            IntgMsg__c testMsg = [SELECT Id FROM IntgMsg__c LIMIT 1];
            Map<IntgMsg__c, ComCompreDtlsResponseWrapper> successResponseMap = new Map<IntgMsg__c, ComCompreDtlsResponseWrapper>{
                testMsg => new ComCompreDtlsResponseWrapper()
            };
            
            String invalidJsonResponse = '{invalid_json}';
            
            Test.startTest();
            ComCompreDtlsQueueable queueable = new ComCompreDtlsQueueable(successResponseMap, invalidJsonResponse);
            System.enqueueJob(queueable);
            Test.stopTest();
        }
        
        @isTest
        static void testEmptyResponseMap() {
            // Arrange
            Map<IntgMsg__c, ComCompreDtlsResponseWrapper> emptyResponseMap = new Map<IntgMsg__c, ComCompreDtlsResponseWrapper>();
            String jsonResponse = '{}';  
    
            Test.startTest();
            ComCompreDtlsQueueable queueable = new ComCompreDtlsQueueable(emptyResponseMap, jsonResponse);
            System.enqueueJob(queueable);
            Test.stopTest(); 
        }

    
}