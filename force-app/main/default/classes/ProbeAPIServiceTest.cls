@isTest
public class ProbeAPIServiceTest {

    @istest
    public static Void testmethod1(){
        
        
        IntgMsg__c intgMsg1 =new IntgMsg__c();
        intgMsg1.Name='LLP Base Details';
        intgMsg1.BU__c='HL / STL';
        intgMsg1.Status__c='New';
        intgMsg1.MStatus__c='Blank';
        intgMsg1.RefObj__c='APIVer__c';
        intgMsg1.Svc__c ='LLP Base Details';
        intgMsg1.ApiVendor__c ='Probe';
        intgMsg1.RefId__c = '2771125995998';
        intgMsg1.Req__c='2771125995998';
        intgMsg1.ApiVersion__c='1.3';
        Insert intgMsg1;
        
        APIConfiguration__c apiconfig =new APIConfiguration__c();
        apiconfig.Name='Probe';
        apiconfig.RequestType__c='test';
        apiconfig.APIKey__c='test';
        Insert apiconfig;
        
        // Mock HTTP response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        List<Id> intMsg =new List<Id>{intgMsg1.Id};
            
        Test.startTest();
        ProbeAPIService.post(intMsg);
        Test.Stoptest();
        
    }
    
     @istest
    public static Void testmethod2(){
        
        
        IntgMsg__c intgMsg1 =new IntgMsg__c();
        intgMsg1.Name='LLP Base Details';
        intgMsg1.BU__c='HL / STL';
        intgMsg1.ApiVendor__c ='Probe';
        intgMsg1.Svc__c='LLP Base Details';
        intgMsg1.Status__c='New';
        intgMsg1.MStatus__c='Blank';
        intgMsg1.RefObj__c='Applicant__c';
        intgMsg1.RefId__c = '2771125995900';
        intgMsg1.ParentRefId__c = '2771125995998';
        intgMsg1.Trigger_Platform_Event__c=true;
        intgMsg1.IsActive__c=true;
        intgMsg1.Req__c = 'callout:APIGateway?identifier_type=PAN&CinOrPan=AAAFQ4251B';
        intgMsg1.Resp__c = 'An Unique Identifier';
        intgMsg1.ParentRefObj__c='LoanAppl__c';
        intgMsg1.ApiVersion__c='1.3';
        Insert intgMsg1;
        
        APIConfiguration__c apiconfig =new APIConfiguration__c();
        apiconfig.Name='Probe';
        apiconfig.RequestType__c='test';
        apiconfig.APIKey__c='test';
        Insert apiconfig;
        
        
        // Mock HTTP response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator1());
        
        List<Id> intMsg =new List<Id>{intgMsg1.Id};
            
        Test.startTest();
        ProbeAPIService.post(intMsg);
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
    
    public class MockHttpResponseGenerator1 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(201);
            res.setBody('Mock response body Error');
            return res;
        }
    }
    
}