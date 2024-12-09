@isTest
public class VoterIdTest {
    
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
       ak.kycDoc__c='Voter Id';
       ak.VotIdEpicNo__c='492515815873';
       insert ak;
       
        IntgMsg__c intgMsg = new IntgMsg__c();
        intgMsg.Name='Voterid Verification';
        intgMsg.BU__c='HL / STL';
        intgMsg.Status__c='New';
        intgMsg.MStatus__c='Blank';
        intgMsg.ParentRefId__c=ak.id;
        intgmsg.Trigger_Platform_Event__c=true;
        intgmsg.Svc__c='Voterid Verification';
        intgMsg.Resp__c='{"requestId":"ff6f5c68-b700-4b65-a5d3-2ff51a686834","result":{"acNo":"200","rlnName":"shrichndra porval","partNo":"219","nameV3":"","psLatLong":"26.78418410436519-79.01518162339926","stCode":"S24","id":"","pin":"","district":"Etawah","rlnNameV1":"श्रीचन्‍द्र पोरवाल","epicNo":"XQC3321486","state":"Uttar Pradesh","slNoInPart":"832","sectionNo":"1","lastUpdate":"","rlnNameV2":"","rlnNameV3":"","acName":"Etawah","psName":"ISLAMIA INTER COLLEGE ETAWAH","houseNo":"","rlnType":"F","pcName":"Etawah","name":"manish porval","dob":"","gender":"M","age":30,"nameV2":"","nameV1":"मनीष पोरवाल","partName":"ISLAMIA INTER COLLEGE ROOM-2"},"statusCode":101,"clientData":{"caseId":"057979684"}}';
       insert intgMsg;
        
       
        
        
        //Wrapper
        String jsonrequest = '{"consent": "Sample Consent", "epicNo": "ABCDE1234F", "clientData": {"caseId": "CASE-123"}}';
        OCRVoterIdWrapperClass wrapperrequest = OCRVoterIdWrapperClass.parse(jsonrequest);
        
        String jsonresponse = '{"requestId": "R1234", "result": {"name": "John Doe", "rlnName": "Jane Doe", "gender": "Male" }, "statusCode": 101, "clientData": {"caseId": "CASE-123"}}';
        voterIdResponseWrapper wrapperresponse = voterIdResponseWrapper.parse(jsonresponse);
        
        //Request
        List<IntgMsg__c> intgMsgRecords = new List<IntgMsg__c>{intgMsg};
        VoterIdRequestGenerator generator = new VoterIdRequestGenerator();
        generator.generate(intgMsgRecords, 'Voterid Verification', 'Async');
        
        //Respose Class
        List<IntgMsg__c> responses = new List<IntgMsg__c>{intgMsg};
            VoterIdResponseProcessor.process(responses);
        
       
    }

}