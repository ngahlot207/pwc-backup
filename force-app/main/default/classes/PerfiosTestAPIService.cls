public class PerfiosTestAPIService implements ExternalService {

    @future(callout=true)
    public static void postSvc( String recordId, String apiVendor,String svcName, String payload ){
        try{
            
            Map<String,Object> requestMap = (Map<String,Object>) JSON.deserializeUntyped (payload);
            
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setEndpoint('https://demo.perfios.com/KuberaVault/api/v3/organisations/fedfina/transaction-links');
            req.setHeader('host','demo.perfios.com');
            //req.setEndpoint('https://uat-api.fedfina.com/sandbox/test/workflow/singleendpoint');
            req.setHeader('Accept','application/json');
            req.setHeader('Content-Type','application/json');
            req.setHeader('X-Perfios-Algorithm',(String)((Map<String, Object>)requestMap.get('Header')).get('perfiosAlgorithm'));
            req.setHeader('X-Perfios-Content-Sha256',(String)((Map<String, Object>)requestMap.get('Header')).get('sha256Content'));
            req.setHeader('X-Perfios-Date',(String)((Map<String, Object>)requestMap.get('Header')).get('perfioRequestDate'));
            req.setHeader('X-Perfios-Signature',(String)((Map<String, Object>)requestMap.get('Header')).get('perfioSignature'));
            req.setHeader('X-Perfios-Signed-Headers',(String)((Map<String, Object>)requestMap.get('Header')).get('perfiosSignedHeaders'));
               
            PerfiosGenerateLinkRequestWrapper requestPayload = (PerfiosGenerateLinkRequestWrapper) JSON.deserialize(JSON.serializePretty(requestMap.get('Payload')) , PerfiosGenerateLinkRequestWrapper.class);
            req.setBody(JSON.serialize(requestPayload));
            
            HttpResponse res = http.send(req);
            
            
            
            
            IntgMsg__c intg = new IntgMsg__c();
            intg.Id = recordId;
            intg.Status__c = GlobalConstants.INT_MSG_Status_Responded;
            intg.ExecType__c = 'Async';
            intg.Resp__c = res.getBody();
            update intg;
        }
        catch(Exception ex){
            
            IntgMsg__c intg = new IntgMsg__c();
            intg.Id = recordId;
            intg.Status__c = GlobalConstants.INT_MSG_Status_EXCEPTION;
            update intg;
            GlobalUtility.logMessage('Error', 'TestAPIService' + ex.getLineNumber(), 'postSvc', recordId, null, ex.getMessage() + ' Line: ' + ex.getLineNumber() , null, ex, null);
        }
        
    }
    public static void post(List<Id> Ids){
        
        List<IntgMsg__c> intgList = [Select Id, ApiVendor__c, Svc__c, Req__c from IntgMsg__c Where Id IN: Ids];
        if(!intgList.isEmpty()){
            for(IntgMsg__c intg: intgList){
                postSvc(intg.Id, intg.ApiVendor__c,intg.Svc__c,intg.Req__c);
                
            }
        }
    }
}