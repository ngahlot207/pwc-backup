public class ProbeAPIService implements ExternalService{

    @future(callout=true)
    public static void postSvc( String recordId, String apiVendor,String apiVersion,String svcName, String payload ){
        try{
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            Http http = new Http();

            //Get metadata value


            APIConfiguration__c ProbeConfig = APIConfiguration__c.getInstance('Probe');
            req.setEndpoint(payload);
            req.setMethod('GET');
            req.setHeader('x-api-key',ProbeConfig.APIKey__c);
            req.setHeader('x-api-version',apiVersion);
		
            System.debug('key:::'+ProbeConfig.APIKey__c);
                System.debug('api-version:::'+apiVersion);
            req.setTimeout(30000);
            res = http.send(req);
            
            System.debug('::::::StatusCode::::::'+res.getStatusCode());
            //System.debug('::::::Response::::::' + res.getBody());  
            String responseStr ;

            String contentType = res!=null ? res.getHeader('Content-Type') :'';
            System.debug('Content Type: ' + contentType);

            if(res.getStatusCode()==200){
                
                ContentVersion contentVersion = new ContentVersion();
                contentVersion.VersionData = res.getBodyAsBlob();
                contentVersion.Title = 'response';
                contentVersion.PathOnClient = 'response.pdf';
                contentVersion.FirstPublishLocationId = recordId;
                insert contentVersion;
                
            }
            //else if (contentType == 'application/json; charset=utf-8' && res.getStatusCode() != 200){
            else if (res.getStatusCode() != 200){
                
                responseStr = res!=null && res.getBody()!=null ? res.getBody() :'';

            }
            
            IntgMsg__c intg = new IntgMsg__c();
            intg.Id = recordId;
            intg.Status__c = GlobalConstants.INT_MSG_Status_Responded;
            intg.MStatus__c= GlobalConstants.INT_MSG_MStatus_ACKNOWLEDGED;
            intg.Resp__c= responseStr;
            update intg;

            
        }
        catch(Exception ex){
            
            IntgMsg__c intg = new IntgMsg__c();
            intg.Id = recordId;
            intg.Status__c = GlobalConstants.INT_MSG_Status_EXCEPTION;
            update intg;
            GlobalUtility.logMessage('Error', 'ProbeAPIService' + ex.getLineNumber(), 'postSvc', recordId, null, ex.getMessage() + ' Line: ' + ex.getLineNumber() , null, ex, null);
        }
    }
    

    public static void post(List<Id> Ids){
        
        List<IntgMsg__c> intgList = [Select Id, ApiVendor__c, Svc__c, Req__c,ApiVersion__c from IntgMsg__c Where Id IN: Ids];
        if(!intgList.isEmpty()){
            for(IntgMsg__c intg: intgList){
                postSvc(intg.Id, intg.ApiVendor__c,intg.ApiVersion__c,intg.Svc__c,intg.Req__c);
                
            }
        }
    }
    
}