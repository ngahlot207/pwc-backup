@istest
public class GenerateShortUrlAPIServiceTest {
    
    @istest
    public static Void testmethod1(){
        
        LoanAppl__c La = TestDataFactory.createLoanApplication(true);
        
        ApplIMD__c imd =new ApplIMD__c();
        imd.LoanAppln__c=La.id;
        imd.PaytmLinkURL__c='https://tny.fedfina.com/urlutil/health';
        Insert imd;
        
        
        IntgMsg__c intgMsg1 =new IntgMsg__c();
        intgMsg1.Name='Generate Short URL';
        intgMsg1.BU__c='HL / STL';
        intgMsg1.Status__c='New';
        intgMsg1.MStatus__c='Blank';
        intgMsg1.RefObj__c='ApplIMD__c';
        intgMsg1.Svc__c ='Generate Short URL';
        intgMsg1.ApiVendor__c ='Fedfina';
        intgMsg1.RefId__c = imd.id;
        intgMsg1.Req__c='{"templateId":"45474558","sourceSystem":"SFDC","senderId":"fedFina","actualUrl":"https://securegw-stage.paytm.in/link/onlinePayment?linkName=IMDPayment&linkId=LL_536054"}';
        Insert intgMsg1;
        
        
        // Mock HTTP response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        List<Id> intMsg =new List<Id>{intgMsg1.Id};
            
            Test.startTest();
        GenerateShortUrlAPIService.post(intMsg);
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