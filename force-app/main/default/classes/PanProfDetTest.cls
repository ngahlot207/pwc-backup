@isTest
public class PanProfDetTest {
    
     
    @isTest
    public static void testGenerateMethod() {
        LoanAppl__c la=new LoanAppl__c();
       la.ChannelName__c='test';
       insert la;
       
       Applicant__c ap=new Applicant__c();
       ap.LoanAppln__c=la.id;
       insert ap;
       
       ApplKyc__c ak=new ApplKyc__c();
       ak.Applicant__c=ap.id;
       ak.kycDoc__c='Pan';
       ak.Pan__c='ABCDE1234F';
       insert ak;
        
         IntgMsg__c intgMsg = new IntgMsg__c();
        intgMsg.Name='Pan Validation';
        intgMsg.BU__c='HL / STL';
        intgMsg.Status__c='New';
        intgMsg.MStatus__c='Blank';
        intgMsg.ParentRefId__c=ak.id;
        intgMsg.Svc__c='Pan Validation';
        intgmsg.Trigger_Platform_Event__c=true;
        intgMsg.Resp__c='{"status-code": 101, "request_id": "73cdbde2-80f7-11e7-8f0c-e7e769f70bd1", "result": {"name": "OMKAR MILIND SHIRHATTI"}, "clientData": {"caseId": "123456"}}';
        insert intgMsg;
        
        IntgMsg__c intgMsg1 = new IntgMsg__c();
        intgMsg1.Name='Pan Validation';
        intgMsg1.BU__c='HL / STL';
        intgMsg1.Status__c='New';
        intgMsg1.MStatus__c='Blank';
        intgMsg1.ParentRefId__c=ak.id;
        intgMsg1.Svc__c='Pan Validation';
        intgmsg1.Trigger_Platform_Event__c=true;
        intgMsg1.Resp__c='{"status":402,"error":"Insufficient Credits","request_id":"38a7b8a2-dbfd-4b5c-90dc-959cc7384801","clientData":{"caseId":"610194869"}}';
        insert intgMsg1;
           
           
           
            //Wrapper
        String jsonrequest = '{"consent": "Sample Consent", "pan": "ABCDE1234F", "clientData": {"caseId": "CASE-123"}}';
        PanWrapper wrapperrequest = PanWrapper.parse(jsonrequest);
        
        String jsonresponse = '{"status-code": 101, "request_id": "73cdbde2-80f7-11e7-8f0c-e7e769f70bd1", "result": {"name": "OMKAR MILIND SHIRHATTI"}, "clientData": {"caseId": "123456"}}';
        PanProfDetResponseWrapper wrapperresponse = PanProfDetResponseWrapper.parse(jsonresponse);
        
        //Request
        List<IntgMsg__c> intgMsgRecords = new List<IntgMsg__c>{intgMsg};
        PanProfDetRequestGenerator generator = new PanProfDetRequestGenerator();
        generator.generate(intgMsgRecords, 'Pan Validation', 'Async');
        
        //Respose Class
        List<IntgMsg__c> responses = new List<IntgMsg__c>{intgMsg};
            PanProfDetResponseProcessor.process(responses);
        
           List<IntgMsg__c> res = new List<IntgMsg__c>{intgMsg1};
            PanProfDetResponseProcessor.process(res);
        
    }

}