@isTest
public class QuestionConfigMobileAPITest {
    @testSetup
    Public static void inserTestData(){
        LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
        Applicant__c appli =  TestDataFactory.createSingleApplicant(true,loan.id); 
        PD__c pdObj = new PD__c();
        pdObj.Appl__c = appli.Id;
        TriggerBase.bypass('PD__c');
        Insert pdObj;
        TriggerBase.clearBypass('PD__c');
        
        Id collectrailVisitRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('Collateral Visit').getRecordTypeId();
        
        Case objCase = TestDataFactory.CaseData(True);
        objCase.RecordTypeId = collectrailVisitRecordTypeId;
        objCase.Address_Line_1__c = 'Test';
        Update objCase;
    }
    
    @isTest
    static void positiveTestGetQuestionConfig() {
        List<PD__c> lstPd = [SELECT ID From PD__c Limit 1];
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/reterieveQuestions';
        request.httpMethod = 'GET';
        request.addParameter('recordId', lstPd[0].Id);
        request.addParameter('category', 'PersonalDiscussion');
        RestContext.request = request;
        MobileResponseData responseData = QuestionConfigMobileAPI.getQuestionConfig();
        system.assert(!lstPd.isEmpty(),'Pd List Should not empty');
    }
   @isTest 
    static void negativeTestGetQuestionConfig() {
        List<PD__c> lstPd = [SELECT ID From PD__c Limit 1];
        List<Case> lstOfCase = [SELECT ID,casetype__c From Case WHERE Address_Line_1__c = 'Test'];
        system.debug('lstOfCase:'+lstOfCase);
        
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/reterieveQuestions';
        request.httpMethod = 'GET';
        request.addParameter('recordId', lstOfCase[0].Id);
        request.addParameter('category', 'CollateralVisit');
        RestContext.request = request;
        MobileResponseData responseData = QuestionConfigMobileAPI.getQuestionConfig();
        system.assert(!lstOfCase.isEmpty(),'Case List Should not empty');
    }
    
    
    @isTest
    static void positivetestSaveQuestionData() {
   List<PD__c> lstPd = [SELECT ID From PD__c Limit 1];
   String serializedRecords = JSON.serialize(lstPd);
   String sampleQuestionData = '[{"objectType": "PD__c", "records": ' + serializedRecords + '}]';
       
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/saveQuestionData';
        request.httpMethod = 'POST';
        request.addParameter('recordId', lstPd[0].Id);
        request.addParameter('category', 'PersonalDiscussion');
        request.requestBody = Blob.valueOf(sampleQuestionData);
        RestContext.request = request;
        MobileResponseData responseData = QuestionConfigMobileAPI.saveQuestionData(sampleQuestionData);
         system.assert(!lstPd.isEmpty(),'Pd List Should not empty');
    }
    
    
    @isTest
    static void negativetestSaveQuestionData() {
        List<Case> lstOfCase = [SELECT ID,casetype__c From Case WHERE Address_Line_1__c = 'Test'];
        String serializedRecords = JSON.serialize(lstOfCase);
        String sampleQuestionData = '[{"objectType": "PD__c", "records": ' + serializedRecords + '}]';
        
       
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/saveQuestionData';
        request.httpMethod = 'POST';
        request.addParameter('recordId', lstOfCase[0].Id);
        request.addParameter('category', 'CollateralVisit');
        request.requestBody = Blob.valueOf(sampleQuestionData);
        RestContext.request = request;
        MobileResponseData responseData = QuestionConfigMobileAPI.saveQuestionData(sampleQuestionData);
         system.assert(!lstOfCase.isEmpty(),'Case List Should not empty');
    }
}