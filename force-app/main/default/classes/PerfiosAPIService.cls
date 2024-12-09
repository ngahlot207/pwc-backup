public class PerfiosAPIService implements ExternalService {
    
    @future(callout=true)
    public static void postSvc( String recordId, String apiVendor,String svcName, String payload ){
        try{
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            Http http = new Http();
            
            if(svcname=='Analysed Report'){
                APIConfiguration__c config = APIConfiguration__c.getInstance('Perfios AA');
                
                req.setMethod('POST');
                req.setEndpoint('callout:Perfios_AA_APIGateway');
                req.setHeader('api_key',config.APIKey__c);
                req.setHeader('org_id',config.SourceName__c);
                req.setBody(payload);
            }
            else{
                Map<String,Object> requestMap = (Map<String,Object>) JSON.deserializeUntyped (payload);
                String transactionID = (String)((Map<String, Object>)requestMap.get('Header')).get('transactionID');
                String reportTypes = (String)((Map<String, Object>)requestMap.get('Header')).get('reportTypes');
                //req.setEndpoint('callout:PerfiosAPI/'+transactionID+'/reports?types=json,xlsx');
                req.setEndpoint('callout:PerfiosAPIGateway/'+transactionID+'/RetrieveReports?types='+reportTypes);
                //req.setEndpoint('https://demo.perfios.com/KuberaVault/api/v3/organisations/fedfina/transactions/'+transactionID+'/reports?types=json,xlsx');
                //req.setHeader('host','demo.perfios.com');
                //req.setHeader('Accept','application/json');
                req.setMethod('GET');
                req.setHeader('X-Perfios-Algorithm',(String)((Map<String, Object>)requestMap.get('Header')).get('perfiosAlgorithm'));
                req.setHeader('X-Perfios-Content-Sha256',(String)((Map<String, Object>)requestMap.get('Header')).get('sha256Content'));
                req.setHeader('X-Perfios-Date',(String)((Map<String, Object>)requestMap.get('Header')).get('perfioRequestDate'));
                req.setHeader('X-Perfios-Signature',(String)((Map<String, Object>)requestMap.get('Header')).get('perfioSignature'));
                req.setHeader('X-Perfios-Signed-Headers',(String)((Map<String, Object>)requestMap.get('Header')).get('perfiosSignedHeaders'));   
            }
            
            
            req.setTimeout(30000);
            res = http.send(req);
            System.debug('::::::StatusCode::::::'+res.getStatusCode());
            System.debug('::::::Response::::::' + res.getBody());  
            //if(res.getStatusCode()==200 || res.getStatusCode()==201){
            String filename;// = res.getHeader('Content-Type')=='application/zip'? 'Response.zip' : 'Response.json';
            if(res.getHeader('Content-Type')=='application/json'){
                filename='Response.json';
            }
            else{
                String contentdisposition = res.getHeader('content-disposition');
                if(contentdisposition!=null && String.isNotBlank(contentdisposition)){
                    List<String>data =contentdisposition.split('[;=]');
                    filename=data[2];
                }
                /*else{
                    filename='Response.xlsx';
                }*/
			}
            ContentVersion newContentVersion = new ContentVersion();
            newContentVersion.Title = filename!=null ? filename : 'Response.json';
            newContentVersion.PathOnClient = filename!=null ? filename : 'Response.json';
            newContentVersion.VersionData = res.getBodyAsBlob();
            insert  newContentVersion; 
            
            Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:newContentVersion.Id].ContentDocumentId;
            ContentDocumentLink newContentLink = new ContentDocumentLink();
            newContentLink.ContentDocumentId = conDocId;
            newContentLink.LinkedEntityId = recordId; 
            newContentLink.ShareType = 'V';   
            insert newContentLink;          
            
            
            IntgMsg__c intg = new IntgMsg__c();
            intg.Id = recordId;
            intg.Status__c = GlobalConstants.INT_MSG_Status_Responded;
            intg.ExecType__c = 'Async';
            update intg;
            
            //}
        }
        catch(Exception ex){
            
            IntgMsg__c intg = new IntgMsg__c();
            intg.Id = recordId;
            intg.Status__c = GlobalConstants.INT_MSG_Status_EXCEPTION;
            update intg;
            GlobalUtility.logMessage('Error', 'PerfiosAPIService' + ex.getLineNumber(), 'postSvc', recordId, null, ex.getMessage() + ' Line: ' + ex.getLineNumber() , null, ex, null);
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