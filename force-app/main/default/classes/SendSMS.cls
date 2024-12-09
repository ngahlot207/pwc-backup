public class SendSMS implements ExternalService,Queueable,Database.AllowsCallouts{
    
    /*public static void sendMsg(String mobileNumber,String message){
        
        String loginId = 'fedfeed';
        String password = 'fed@321';
        String version = 'v1.0';
        String countrycode = '91';
        String msgtype = 'text';
        String senderId = 'FEDFIN';
        String encodedMsg = EncodingUtil.urlEncode(message, 'UTF-8');
        String endpoint= 'https://www.msg2all.com/TRANSAPI/sendsms.jsp?login=' + loginId + '&passwd=' + password + '&version=' + version + '&msisdn='+ countrycode + mobileNumber + '&msg_type=' + msgtype + '&msg=' + encodedMsg + '&sender_id=' + senderId;
        SMSResponse result= new SMSResponse(); 
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(endpoint);
        //req.setEndpoint('callout:IkontelSMSAPI?login=' + EncodingUtil.urlEncode('{!$Credential.IkontelSMSCredential.loginId}','UTF-8') + '&passwd=' + EncodingUtil.urlEncode('{!$Credential.IkontelSMSCredential.password}','UTF-8') + '&version=' + EncodingUtil.urlEncode('{!$Credential.IkontelSMSCredential.version}','UTF-8') + '&msisdn='+ EncodingUtil.urlEncode('{!$Credential.IkontelSMSCredential.countrycode}','UTF-8') + mobileNumber + '&msg_type=' + EncodingUtil.urlEncode('{!$Credential.IkontelSMSCredential.msgtype}','UTF-8') + '&msg=' + encodedMsg + '&sender_id=' + EncodingUtil.urlEncode('{!$Credential.IkontelSMSCredential.senderId}','UTF-8'));
        System.Debug('::::::Request::::::'+req);
        
        HttpResponse res = http.send(req);
        System.debug('::::::StatusCode::::::'+res.getStatusCode());
        System.debug('::::::Response::::::' + res.getBody());
        
        if(res.getStatusCode() == 200 || res.getStatusCode() == 201){
            result= (SMSResponse)JSON.deserialize(res.getBody(),SMSResponse.class);
        }
        System.debug('::::::Result::::::'+result);
    }*/
    public SendSMS(){}
    public class SMSResponse{
        public Result result;
    }
    public class Result {
        public String req_id;
        public String msisdn;
        public Status status;
    }
    public class Status {
        public String statusCode;
    }
    
    @future(callout=true)
    public static void sendMessage(String recordId, String request){
        performAPICallout(recordId,request);        
    }
    
    private String recordId;
    private String request;
    public SendSMS(String recordId,String request){
        this.recordId = recordId;
        this.request = request;
    }
    public void execute(QueueableContext context){
        performAPICallout(recordId,request);
    }
    
    public static void performAPICallout(String recordId, String request){
        try{
            
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setEndpoint(request);
            System.Debug('::::::Request::::::'+req);
            
            HttpResponse res = http.send(req);
            System.debug('::::::StatusCode::::::'+res.getStatusCode());
            System.debug('::::::Response::::::' + res.getBody());
            IntgMsg__c intg = new IntgMsg__c();
            intg.Id = recordId;
            intg.Resp__c = res.getBody();
            intg.Status__c = GlobalConstants.INT_MSG_Status_Responded;
            intg.ExecType__c = 'Async';
            update intg;
            
        }
        catch(Exception ex){
            
            IntgMsg__c intg = new IntgMsg__c();
            intg.Id = recordId;
            intg.Status__c = GlobalConstants.INT_MSG_Status_EXCEPTION;
            update intg;
            
            GlobalUtility.logMessage('Error', 'SendSMS' + ex.getLineNumber(), 
                                     'performAPICallout', intg.Id, null, ex.getMessage() + ' Line: ' + ex.getLineNumber(), null, ex, null);
        }
    }
    public static void post(List<Id> Ids){
        
        List<IntgMsg__c> intgList = [Select Id, ApiVendor__c, ApiVersion__c, Svc__c, Req__c from IntgMsg__c Where Id IN: Ids];
        if(!intgList.isEmpty()){
            for(IntgMsg__c intg: intgList){
                if(!System.isFuture()){
                      SendSMS.sendMessage(intg.Id,intg.Req__c);
                }
                else{
                  
                    System.enqueueJob(new SendSMS(intg.Id,intg.Req__c));
                }
            }
        }
        
    }
}