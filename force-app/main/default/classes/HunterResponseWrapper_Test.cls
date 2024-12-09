@isTest
public class HunterResponseWrapper_Test {

    @isTest
    static void testParseMethod() {
        //  response
        String sampleJson = '{"responseHeader": {"requestType": "HunterOnly", "clientReferenceId": "XXXX", "expRequestId": "RB000000286330", "messageTime": "2022-12-30T15:48:55Z", "overallResponse": {"decision": "NODECISION", "decisionText": "No Decision", "decisionReasons": [], "recommendedNextActions": [], "spareObjects": []}, "responseCode": "R0201", "responseType": "INFO", "responseMessage": "Workflow Complete.", "tenantID": "XXXX"}, "clientResponsePayload": {"orchestrationDecisions": [], "decisionElements": []}, "originalRequestData": {"source": "WEB", "contacts": [], "application": {"originalRequestTime": "2022-12-30T15:48:55Z", "type": "CREDIT", "status": "UNKNOWN", "productDetails": {"productType": "LOAN", "purposeOfLoan": "", "productCode": "PL_FNT", "loanReference": ""}, "applicants": [], "messageTime": "2022-12-30T15:48:55Z"}}}';
        
       
        HunterResponseWrapper result = HunterResponseWrapper.parse(sampleJson);
        
      
    }
    
    

    @isTest
    static void testParseMethod2() {
        String sampleJson = '{"header":{"tenantId":"IN24CEZZ","requestType":"HunterOnly","clientReferenceId":"FEDFINA_14092023_001","expRequestId":"","messageTime":"2023-04-27T05:01:36Z","options":{}},"payload":{"source":"", "contacts":[], "application":{"originalRequestTime":"2023-04-27T05:01:36Z","productDetails":{"productType":"","productCode":"IND_LAP"},"applicants":[]}}}';
        
        HunterRequestWrapper result = HunterRequestWrapper.parse(sampleJson);

       
    }

    
    
   
}