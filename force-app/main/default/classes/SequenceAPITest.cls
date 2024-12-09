@isTest
public class SequenceAPITest {
    @isTest
    public static void testGenerateMethod() {
        
    LoanAppl__c La = TestDataFactory.createLoanApplication(true);
    Applicant__c ap = TestDataFactory.createSingleApplicant(true,La.id);

        ApplKyc__c ak = new ApplKyc__c();
        ak.Applicant__c = ap.id;
        ak.kycDoc__c = 'Aadhaar';
        ak.AadharEncripted__c = '492515815873';
        insert ak;

        IntgMsg__c intgMsg = new IntgMsg__c();
        intgMsg.Name = 'Sequence API';
        intgMsg.BU__c = 'HL / STL';
        intgMsg.Status__c = 'New';
        intgMsg.MStatus__c = 'Blank';
        intgMsg.RefObj__c = 'LoanAppl__c';
        intgMsg.RefId__c = la.Id;
        intgMsg.Trigger_Platform_Event__c = true;
        intgMsg.Resp__c = '{"requestId": "123", "status": "success", "appId": "456"}';
        insert intgMsg;

        IntgMsg__c intgMsg1 = new IntgMsg__c();
        intgMsg1.Name = 'Sequence API';
        intgMsg1.BU__c = 'HL / STL';
        intgMsg1.Status__c = 'New';
        intgMsg1.MStatus__c = 'Blank';
        intgMsg1.RefObj__c = 'LoanAppl__c';
        intgMsg1.RefId__c = la.Id;
        intgMsg1.Trigger_Platform_Event__c = true;
        intgMsg1.Resp__c = '{"requestId":"909417234","status":"error","appId":"587399","applicantType":"","responseDateTime":"2023.11.22 16:22:29 IST","errorDescription":"error"}';
        insert intgMsg1;

        List<IntgMsg__c> msgs = new List<IntgMsg__c>{ intgMsg };
        SequenceAPIRequestGenerator generator = new SequenceAPIRequestGenerator();
        generator.generate(msgs, 'Sequence API', 'Async');

        List<IntgMsg__c> responses = new List<IntgMsg__c>{ intgMsg };
        SequenceAPIResponseProcessor.process(responses);

        List<IntgMsg__c> responses1 = new List<IntgMsg__c>{ intgMsg1 };
        SequenceAPIResponseProcessor.process(responses1);

        String jsonrequest = '{"requestId": "12345", "sourceId": "source123", "errorDesc": "Error description", "user": "testUser", "password": "testPassword", "applicantType": "applicantType123"}';

        String jsonresponse = '{"requestId": "12345", "status": "Success", "appId": "app123", "applicantType": "applicantType123", "responseDateTime": "2023-09-08T12:34:56Z", "errorDescription": "Error description"}';

        SequenceAPIRequestWrapper request = SequenceAPIRequestWrapper.praser(jsonrequest);
        SequenceAPIResponseWrapper response = SequenceAPIResponseWrapper.praser(jsonresponse);
    }
}