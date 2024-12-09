@isTest
public class SendSMSTest {
@isTest
    static void sendMess (){
       LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
       Applicant__c appli =  TestDataFactory.createSingleApplicant(true,loan.id); 
        List<Id> lstintId = new List<Id>();
        
        IntgMsg__c msg = new IntgMsg__c();
        msg.Name = 'SMS';
        msg.BU__c = 'HL / STL';
        msg.Svc__c = 'SMS';
        msg.IsActive__c = true;
        msg.Req__c = 'callout:IkontelSMSAPI?login=fedfeed&passwd=fed@321&version=v1.0&msisdn=919999999999&msg_type=text&msg=Dear+Customer%2C+FEDBANK+FINANCIAL+SERVICE+LIM+has+requested+payment+of+Rs.+2360+.+Click+https%3A%2F%2Ftny.fedfina.com%2FFEDFIN%2Ftest+to+pay.+Regards%2C+Fedbank&sender_id=FEDFIN';
        msg.Status__c = 'Responded';
        msg.MStatus__c = 'Blank';
        msg.Trigger_Platform_Event__c = true;
        msg.RefObj__c = 'Applicant__c';
        msg.Resp__c = '{"result": {"req_id": "mockReqId", "msisdn": "mockMsisdn", "status": {"statusCode": "200"}}}';
        
        IntgMsg__c msg1 = new IntgMsg__c();
        msg1.Name = 'SMS';
        msg1.BU__c = 'HL / STL';
        msg1.Svc__c = 'SMS';
        msg1.IsActive__c = true;
        msg1.Status__c = 'Responded';
        msg1.MStatus__c = 'Blank';
        msg1.Trigger_Platform_Event__c = true;
        msg1.RefObj__c = 'Applicant__c';
        msg1.Resp__c = '{"result": {"req_id": "mockReqId", "msisdn": "mockMsisdn", "status": {"statusCode": "200"}}}';
        
        List<IntgMsg__c> intMsglist = new List<IntgMsg__c>{msg,msg1};
        TriggerBase.bypass('IntgMsg__c');
        insert intMsglist;
        TriggerBase.clearBypass('IntgMsg__c');
        
        for(IntgMsg__c intMess : intMsglist){
          	lstintId.add(intMess.Id); 
           
        }

       Test.startTest();

        Test.setMock(HttpCalloutMock.class, new SendSMSMock());
        SendSMS.post(lstintId);
        System.enqueueJob(new SendSMS(intMsglist[0].Id,intMsglist[0].Req__c));
        Test.stopTest();
    }
    
    
    public class SendSMSMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            // Create a mock response
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"result": {"req_id": "mockReqId", "msisdn": "mockMsisdn", "status": {"statusCode": "200"}}}');
            return res;
        }
    }
     
}