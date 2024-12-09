@isTest
public class PassPortTest {
    @isTest
    public static void testGenerateMethod() {
        LoanAppl__c la=new LoanAppl__c();
        la.ChannelName__c='test';
        insert la;
        
        Applicant__c ap=new Applicant__c();
        ap.LoanAppln__c=la.id;
        ap.DOB__c=System.today();
        insert ap;
        
        ApplKyc__c ak=new ApplKyc__c();
        ak.Applicant__c=ap.id;
        ak.kycDoc__c='Passport';
        ak.FileNo__c='123';
        insert ak;
        
        IntgMsg__c intgMsg = new IntgMsg__c();
        intgMsg.Name='Passport Verification';
        intgMsg.BU__c='HL / STL';
        intgMsg.Status__c='New';
        intgMsg.MStatus__c='Blank';
        intgMsg.ParentRefId__c=ak.id;
        intgmsg.Trigger_Platform_Event__c=true;
        intgmsg.Svc__c='Passport Verification';
        intgMsg.Resp__c='{"requestId":"8eb39778-4d34-4a75-83a3-d986ddae3aee","result":{"name":{"nameFromPassport":"SRIDEVI","surnameFromPassport":"GUNTUPALLI","nameMatch":true,"nameScore":1},"passportNumber":{"passportNumberFromSource":"S9265723","passportNumberMatch":true},"dateOfIssue":{"dispatchedOnFromSource":"30/01/2019","dateOfIssueMatch":null},"typeOfApplication":"Normal","applicationDate":"28/01/2019"},"statusCode":101,"clientData":{"caseId":"746650859"}}';
        insert intgMsg;
        
        IntgMsg__c intgMsg1 = new IntgMsg__c();
        intgMsg1.Name='Passport Verification';
        intgMsg1.BU__c='HL / STL';
        intgMsg1.Status__c='New';
        intgMsg1.MStatus__c='Blank';
        intgMsg1.ParentRefId__c=ak.id;
        intgmsg1.Trigger_Platform_Event__c=true;
        intgmsg1.Svc__c='Passport Verification';
        intgMsg1.Resp__c='{"requestId":"506a3232-2311-4f46-a7b7-7bcbdb71c780","result":{},"statusCode":103,"clientData":{"caseId":"854546851"}}';
        insert intgMsg1;
        
        
        //wrapper
        String jsonrequest = '{"consent": "Sample Consent", "fileNo": "12345", "dob": "2000-01-01", "passportNo": "AB1234567", "doi": "2022-01-01", "name": "John Doe", "clientData": {"caseId": "CASE-123"}}';
        passportWrapper wrapperrequest = passportWrapper.parse(jsonrequest);
        
        String jsonresponse = '{"requestId":"8eb39778-4d34-4a75-83a3-d986ddae3aee","result":{"name":{"nameFromPassport":"SRIDEVI","surnameFromPassport":"GUNTUPALLI","nameMatch":true,"nameScore":1},"passportNumber":{"passportNumberFromSource":"S9265723","passportNumberMatch":true},"dateOfIssue":{"dispatchedOnFromSource":"30/01/2019","dateOfIssueMatch":null},"typeOfApplication":"Normal","applicationDate":"28/01/2019"},"statusCode":101,"clientData":{"caseId":"746650859"}}';
        passportResponseWrapper wrapperresponse = passportResponseWrapper.parse(jsonresponse);
        
        //Request
        List<IntgMsg__c> intgMsgRecords = new List<IntgMsg__c>{intgMsg};
            passportRequestGenerator generator = new passportRequestGenerator();
        generator.generate(intgMsgRecords, 'Passport Verification', 'Async');
        
        //Respose Class
        List<IntgMsg__c> responses = new List<IntgMsg__c>{intgMsg};
            passportResponseProcessor.process(responses);
        
        List<IntgMsg__c> response = new List<IntgMsg__c>{intgMsg1};
            passportResponseProcessor.process(response);
    }
    
}