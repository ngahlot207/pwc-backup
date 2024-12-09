@istest
public class MasterDataSyncAPIServiceTest {
    
    @isTest
    public static void testGenerateMethod() {
        
         IntgMsg__c intg = new IntgMsg__c();
         intg.Name='Master data Sync';
         intg.BU__c='HL / STL';
         intg.ApiVendor__c='Fedfina';
        intg.Svc__c='Master Data Sync';
        intg.Status__c='New';
        intg.Req__c='test';
        intg.Resp__c='{"identifier":"46092012","masterbody":[{"masterDataType":"RCUAGENCYEMASTER","asyncProcessing":"false","masterData":[{"record":[{"LFAM_AGENCYCODE_C":"MANDRURAJENDRA","LFAM_AGENCYNAME_C":"MANDRU RAJENDRA","LFABPMM_PRODCODE_C":"STL","BRANCHID":"382","BRANCH":"ELURU","AUTHORID":"IT018235","AUTHORDATE":"2022-04-12T10:44:03"},{"LFAM_AGENCYCODE_C":"Test","LFAM_AGENCYNAME_C":"","LFABPMM_PRODCODE_C":"HL","BRANCHID":"370","BRANCH":"JHUNJHUNU","AUTHORID":"IT012709","AUTHORDATE":"2021-09-28T11:45:40"}]}]}]}';
        insert intg;
        
        List<id> intids=new list<id>{intg.Id};
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Test.startTest();
        MasterDataSyncAPIService.postSvc(intg.Id, intg.ApiVendor__c, intg.Svc__c, intg.Resp__c);
        MasterDataSyncAPIService.post(intids);
        Test.stopTest();
    }
    
    
    @isTest
    public static void testGenerateMethod2() {
        
         IntgMsg__c intg = new IntgMsg__c();
         intg.Name='Master data Sync';
         intg.BU__c='HL / STL';
         intg.ApiVendor__c='Fedfina';
        intg.Svc__c='Master Data Sync';
        intg.Status__c='New';
        intg.Resp__c='{"identifier":"46092012","masterbody":[{"masterDataType":"RCUAGENCYEMASTER","asyncProcessing":"false","masterData":[{"record":[{"LFAM_AGENCYCODE_C":"MANDRURAJENDRA","LFAM_AGENCYNAME_C":"MANDRU RAJENDRA","LFABPMM_PRODCODE_C":"STL","BRANCHID":"382","BRANCH":"ELURU","AUTHORID":"IT018235","AUTHORDATE":"2022-04-12T10:44:03"},{"LFAM_AGENCYCODE_C":"Test","LFAM_AGENCYNAME_C":"","LFABPMM_PRODCODE_C":"HL","BRANCHID":"370","BRANCH":"JHUNJHUNU","AUTHORID":"IT012709","AUTHORDATE":"2021-09-28T11:45:40"}]}]}]}';
        insert intg;
        
        Test.startTest();
        MasterDataSyncAPIService.postSvc(intg.Id, intg.ApiVendor__c, intg.Svc__c, intg.Resp__c);
        Test.stopTest();
    }
    // Mock HTTP response generator
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status": "success"}');
            res.setStatusCode(200);
            return res;
        }
    }
}