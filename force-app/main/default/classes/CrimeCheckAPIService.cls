public class CrimeCheckAPIService implements ExternalService{
    
    @future(callout=true)
    public static void postSvc( String recordId, String apiVendor,String svcName, String payload ){
        
        try{
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            Http http = new Http();
            
            Map<String,APIConfiguration__c> APICrdMap = APIConfiguration__c.getAll();
            //req.setEndpoint('https://api.probe42.in/probe_reports_sandbox/companies/AAACG3995M/reports?type=pdf&client_name=probe&unit=INR&identifier_type=PAN');
            //req.setMethod('GET');
            //req.setHeader('Content-Type','application/json');
            //req.setHeader('accept','application/pdf');
            //req.setHeader('x-api-version','1.3');
           // req.setHeader('x-api-key','VZhVAcO7Yn20HUcBit81F3Jbg1J8TwUF6XqwAUuE');
            //GET https://api.probe42.in/probe_reports_sandbox/companies/AAACG3995M/reports?type=pdf&client_name=probe&unit=INR&identifier_type=PAN
            
            req.setEndpoint('callout:APIGateway');
            req.setMethod('POST');
           // req.setHeader('x-client-id','BDJHZhBnMHMWHcZeLKQCPdQCZhKAFYZRCbEf');
           // req.setHeader('x-client-secret','LIGTiBlCBXQMSAhIaVmQWZZQBSFRSnVdfKYeDbkIIkPYOimdOQ');
           // req.setHeader('x-application-id','fac7bd67-c7ca-4b38-81a2-c851827f6d6c');
            req.setHeader('Content-Type',+APICrdMap.get('Crime Check API Service').RequestType__c);//application/x-www-form-urlencoded
            req.setHeader('APIVendor',+apiVendor);
            req.setHeader('APIname',+svcName);
            req.setHeader('RecordID',+recordId);
            req.setHeader('transactionId',+payload);
            req.setHeader('apikey',+APICrdMap.get('Crime Check API Service').APIKey__c);//FedFinaDev-sandbox-T9HBC
            req.setTimeout(30000);
            
            res = http.send(req);
            
            System.debug('::::::StatusCode::::::'+res.getStatusCode());
            System.debug('::::::Response::::::' + res.getBody());  
            
            if(res.getStatusCode()==200){
                
                ContentVersion contentVersion = new ContentVersion();
                contentVersion.VersionData = res.getBodyAsBlob();
                contentVersion.Title = 'response';
                contentVersion.PathOnClient = 'response.pdf';
                contentVersion.FirstPublishLocationId = recordId;
                insert contentVersion;
                
            }
            else{
                
                ContentVersion contentVersion = new ContentVersion();
                contentVersion.VersionData = res.getBodyAsBlob();
                contentVersion.Title = 'response';
                contentVersion.PathOnClient = 'response.json';
                contentVersion.FirstPublishLocationId = recordId;
                insert contentVersion;
            }
            
            IntgMsg__c intg = new IntgMsg__c();
            intg.Id = recordId;
            intg.Status__c = GlobalConstants.INT_MSG_Status_Responded;
            intg.MStatus__c= GlobalConstants.INT_MSG_MStatus_ACKNOWLEDGED;
            update intg;
            
        }catch(Exception ex){
            
            IntgMsg__c intg = new IntgMsg__c();
            intg.Id = recordId;
            intg.Status__c = GlobalConstants.INT_MSG_Status_EXCEPTION;
            update intg;
            
            GlobalUtility.logMessage('Error', 'CrimeCheckAPIService' + ex.getLineNumber(), 'postSvc', recordId, null, ex.getMessage() + ' Line: ' + ex.getLineNumber() , null, ex, null);
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