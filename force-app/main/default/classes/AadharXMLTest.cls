@isTest
public class AadharXMLTest {
    @isTest
    public static void testGenerateMethod() {
        LoanAppl__c la = new LoanAppl__c();
        la.ChannelName__c = 'test';
        insert la;

        Applicant__c ap = new Applicant__c();
        ap.LoanAppln__c = la.id;
        insert ap;

        ApplKyc__c ak = new ApplKyc__c();
        ak.Applicant__c = ap.id;
        ak.kycDoc__c = 'Aadhaar';
        ak.AadharEncripted__c = '492515815873';
        insert ak;

        IntgMsg__c intgMsg = new IntgMsg__c();
        intgMsg.Name = 'SFDC Aadhar XML Verification API';
        intgMsg.BU__c = 'HL / STL';
        intgMsg.Status__c = 'New';
        intgMsg.MStatus__c = 'Blank';
        intgMsg.ParentRefId__c = ak.id;
        intgmsg.Svc__c = 'SFDC Aadhar XML Verification API';
        intgmsg.Trigger_Platform_Event__c = true;
        intgMsg.Resp__c = '{"status":"success","encrypted_response":"xNQ/U6gFahptmv39BC+JekS7MVp7dUDgrkzd+MP9mwZ0UmEOiKlTGWZPstusXT6iz8iPGg7sxBjds1s/5zLDinv8JfCAPenI9jgQpUuwcdptz3irdUZ2nyrcygFDM1tM7eIV0J7JYlzEUiHvxnfYJSI0Kcfs5fOGy1AYaSpVLMq9AxqAfJR8f+7rr5Yzu2vqfwI6Y/T9WtxS5tdEZaQQyhoMnUFMfq+7Srt1c+HlzjJCMbL0TEZzeDCFUYVU8Q9p"}';
        insert intgMsg;

        IntgMsg__c intgMsg1 = new IntgMsg__c();
        intgMsg1.Name = 'SFDC Aadhar XML Verification API';
        intgMsg1.BU__c = 'HL / STL';
        intgMsg1.Status__c = 'New';
        intgMsg1.MStatus__c = 'Blank';
        intgMsg1.ParentRefId__c = ak.id;
        intgmsg.Svc__c = 'SFDC Aadhar XML Verification API';
        intgmsg1.Trigger_Platform_Event__c = true;
        intgMsg1.Resp__c = '{"status":"error","encrypted_response":"xNQ/U6gFahptmv39BC+JekS7MVp7dUDgrkzd+MP9mwZ0UmEOiKlTGWZPstusXT6iz8iPGg7sxBjds1s/5zLDinv8JfCAPenI9jgQpUuwcdptz3irdUZ2nyrcygFDM1tM7eIV0J7JYlzEUiHvxnfYJSI0Kcfs5fOGy1AYaSpVLMq9AxqAfJR8f+7rr5Yzu2vqfwI6Y/T9WtxS5tdEZaQQyhoMnUFMfq+7Srt1c+HlzjJCMbL0TEZzeDCFUYVU8Q9p"}';
        insert intgMsg1;

        //Wrapper
        String jsonrequest = '{"reference_id":"121343","source_type":"id","source":"240789858325"}';
        AadharXMLVerificationRequestWrapper wrapperrequest = AadharXMLVerificationRequestWrapper.parse(
            jsonrequest
        );

        String jsonresponse = '{"status":"success","message":"xxxxxx xxxxxx","reference_id":"xxxxxxxxx","transaction_id":"xxxxxxxxxxxx","response_time_stamp":"YYYY-MM-DDTHH:mm:ss","error":"Sample Error","error_code":"123"}';
        AadharXMLVerificationResponseWrapper wrapperresponse = AadharXMLVerificationResponseWrapper.parse(
            jsonresponse
        );

        //Request
        List<IntgMsg__c> intgMsgRecords = new List<IntgMsg__c>{ intgMsg };
        AadharXMLVerificationRequestGenerator generator = new AadharXMLVerificationRequestGenerator();
        generator.generate(
            intgMsgRecords,
            'SFDC Aadhar XML Verification API',
            'Async'
        );

        //Respose Class
        List<IntgMsg__c> responses = new List<IntgMsg__c>{ intgMsg };
        AadharXMLVerificationResponseProcessor.process(responses);

        List<IntgMsg__c> res = new List<IntgMsg__c>{ intgMsg1 };
        AadharXMLVerificationResponseProcessor.process(res);
    }
}