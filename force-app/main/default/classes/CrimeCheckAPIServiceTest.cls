@istest
public class CrimeCheckAPIServiceTest {
    
    @istest
    public static Void testmethod1(){
        
        
        IntgMsg__c intgMsg1 =new IntgMsg__c();
        intgMsg1.Name='Crime Download Report';
        intgMsg1.BU__c='HL / STL';
        intgMsg1.Status__c='New';
        intgMsg1.MStatus__c='Blank';
        intgMsg1.RefObj__c='APIVer__c';
        intgMsg1.Svc__c ='Crime Download Report';
        intgMsg1.ApiVendor__c ='CrimeCheck';
        intgMsg1.RefId__c = '2771125995998';
        intgMsg1.Req__c='2771125995998';
        Insert intgMsg1;
        
        APIConfiguration__c apiconfig =new APIConfiguration__c();
        apiconfig.Name='Crime Check API Service';
        apiconfig.RequestType__c='test';
        apiconfig.APIKey__c='test';
        Insert apiconfig;
        
        // Mock HTTP response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        List<Id> intMsg =new List<Id>{intgMsg1.Id};
            
        Test.startTest();
        CrimeCheckAPIService.post(intMsg);
        Test.Stoptest();
        
    }
    
     @istest
    public static Void testmethod2(){
        
        
        IntgMsg__c intgMsg1 =new IntgMsg__c();
        intgMsg1.Name='Crime Download Report';
        intgMsg1.BU__c='HL / STL';
        intgMsg1.Status__c='New';
        intgMsg1.MStatus__c='Blank';
        intgMsg1.RefObj__c='APIVer__c';
        intgMsg1.Svc__c ='Crime Download Report';
        intgMsg1.ApiVendor__c ='CrimeCheck';
        intgMsg1.RefId__c = '2771125995998';
        intgMsg1.Req__c='2771125995998';
        Insert intgMsg1;
        
        APIConfiguration__c apiconfig =new APIConfiguration__c();
        apiconfig.Name='Crime Check API Service';
        apiconfig.RequestType__c='test';
        apiconfig.APIKey__c='test';
        Insert apiconfig;
        
        List<Id> intMsg =new List<Id>{intgMsg1.Id};
            
        Test.startTest();
        CrimeCheckAPIService.post(intMsg);
        Test.Stoptest();
        
    }
    
    //************************************************************************************************************************************** 
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('Mock response body');
            return res;
        }
    }
}