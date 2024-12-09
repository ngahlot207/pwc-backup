public class APIGatewayService  implements ExternalService {
    
    @future(callout=true)
    public static void postSvc( String recordId){//String recordId, String apiVendor,String svcName, String payload
        
        //performAPICallout(recordId, apiVendor, svcName, payload);
        
		List<IntgMsg__c> intgList = [Select Id, ApiVendor__c, Svc__c, Req__c from IntgMsg__c Where Id =:recordId];
        if(intgList!=null && !intgList.isEmpty()){
            performAPICallout(intgList[0].Id, intgList[0].ApiVendor__c,intgList[0].Svc__c,intgList[0].Req__c);
        }
		
    }
    
    public static void post(List<Id> Ids){
        if(!Ids.isEmpty()){
            for(Id recordId: Ids){
                if(!System.isFuture() && !System.isQueueable()){
                    System.enqueueJob(new APIGatewayServiceQueueable(recordId));
                }
                else{
                    postSvc(recordId);
                }
            }
        }
    }
    
    public static string getAuthorizationToken(String recordId,String svcName){
        String token;
        if(recordId!=null){
            List<IntgMsg__c> intgList = [Select Id, ParentRefId__c from IntgMsg__c Where Id =: recordId];
            List<IntgMsg__c> intgRefList = [Select Id,Resp__c from IntgMsg__c Where Id =: intgList[0].ParentRefId__c];
            if(!intgRefList.isEmpty()){
                if(svcName=='Dedupe' || svcName=='UCIC'){
                    DedupeAccessTokenWrapper responseWrapper = (DedupeAccessTokenWrapper) JSON.deserialize(intgRefList[0].Resp__c, DedupeAccessTokenWrapper.class);
                    if(responseWrapper != null){
                        if(!String.isBlank(responseWrapper.access_token)){
                            token= responseWrapper.access_token;
                        }
                    }
                }
                if(svcName=='Hunter API'){
                    HunterTokenResponseParser responseWrapper = (HunterTokenResponseParser) JSON.deserialize(intgRefList[0].Resp__c, HunterTokenResponseParser.class);
                    if(responseWrapper != null){
                        if(!String.isBlank(responseWrapper.access_token)){
                            token= 'Bearer ' + responseWrapper.access_token;
                        }
                    }
                }
                if(svcName=='Crif Execute API'){
                    CrifAuthLoginResponseWrapper responseWrapper = (CrifAuthLoginResponseWrapper) JSON.deserialize(intgRefList[0].Resp__c, CrifAuthLoginResponseWrapper.class);
                    if(responseWrapper != null){
                        if(!String.isBlank(responseWrapper.access_token)){
                            token= 'Bearer ' + responseWrapper.access_token;
                        }
                    }
                }
                
                if(svcName=='Create Order - GST' || svcName=='Create Order - ITR'){
                    
                    FinfortAccesstokenAPIResponseWrapper  res =(FinfortAccesstokenAPIResponseWrapper) JSON.deserialize(intgRefList[0].Resp__c,FinfortAccesstokenAPIResponseWrapper.class);
                    
                    if(res!=null && res.data!=null && String.isNotblank(res.data.api_auth_token)){
                        
                        token=res.data.api_auth_token;
                    }
                
                }
            }    
        }
        return token;
    }
    
    public static void performAPICallout(String recordId,String apiVendor,String svcName,String payload){
        
        try{
            ContentVersion verData;
            Attachment att;
            if(payload==Null && svcname!='Dedupe API Token')
            {
                att=   [Select Id,ParentId, Name,body,ContentType From Attachment a where ParentId=:Recordid limit 1];
                
                /* List<DocDtl__c> appDocDetails= [SELECT Id,DocTyp__c,Appl__c,DocMstr__r.DocSubTyp__c FROM DocDtl__c Where id in : ids AND DocTyp__c ='Identity Proof'];

                ContentDocumentLink cdlList =  [SELECT Id, LinkedEntityId,ContentDocumentId,ContentDocument.FileType FROM
                ContentDocumentLink where LinkedEntityId =:recordId];

                verData= [SELECT VersionData,ContentDocumentId,FileType,FileExtension FROM ContentVersion 
                where ContentDocumentId = :cdlList.ContentDocumentId];*/
            }
            
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            Http http = new Http();
            
            
            if(svcname=='ICICI PennyDrop'){
                req.setEndpoint('callout:ICICI_API_Gateway'); 
                req.setBody(payload);
            }
            else if(svcname!='SFDC Aadhar Vault' && apiVendor!='Probe')
            {
                req.setEndpoint('callout:APIGateway');
                if(svcname=='Consumer ACK Request' || svcname=='Cusomer Issue Request'){
                    /*req.setHeader('x-client-id','BDJHZhBnMHMWHcZeLKQCPdQCZhKAFYZRCbEf');
                    req.setHeader('x-client-secret','LIGTiBlCBXQMSAhIaVmQWZZQBSFRSnVdfKYeDbkIIkPYOimdOQ');
                    req.setHeader('x-application-id','fac7bd67-c7ca-4b38-81a2-c851827f6d6c');
                    //  req.setHeader('Content-Type', 'application/json');
                    req.setHeader('APIVendor','Lentra');
                    
                    if(svcname=='Consumer ACK Request'){
                       req.setHeader('APIname','Consumer ACK Request'); 
                    }
                    if(svcname=='Commercial ACK Request'){
                       req.setHeader('APIname','Commercial ACK Request'); 
                    }
                    if(svcname=='Cusomer Issue Request'){
                        req.setHeader('APIname','Cusomer Issue Request'); 
                    }
                    if(svcname=='Commercial Issue Request'){
                        req.setHeader('APIname','Commercial Issue Request'); 
                    }*/
                   /*
                    req.setHeader('RecordID',recordId);
                    req.setheader('Content-Type','multipart/form-data; boundary=--------------------------466421723705540664751601');
                    
                    string body='---------------------------466421723705540664751601\r\nContent-Disposition: form-data; name="X-Forwarded-For"\r\n\r\n14.142.131.226\r\n----------------------------466421723705540664751601\r\nContent-Disposition: form-data; name="INSTITUTION_ID"\r\n\r\n4145\r\n----------------------------466421723705540664751601\r\nContent-Disposition: form-data; name="AGGREGATOR_ID"\r\n\r\n676\r\n----------------------------466421723705540664751601\r\nContent-Disposition: form-data; name="MEMBER_ID"\r\n\r\ncpu_user@fedfina.com\r\n----------------------------466421723705540664751601\r\nContent-Disposition: form-data; name="PASSWORD"\r\n\r\nJDFhd0l6ZFE=\r\n----------------------------466421723705540664751601\r\nContent-Disposition: form-data; name="inputJson_"\r\n\r\n'+payload+'\r\n----------------------------466421723705540664751601--\r\n';
                    req.setbody(body);
                    System.debug(':::'+body);
                   */ 
					/*
					String BOUNDARY ='--------------------------466421723705540664751601';
					String EXTRABOUNDARY = '--' + BOUNDARY;
					String ENDBOUNDARY = '\r\n--' + BOUNDARY+'--\r\n';
					req.setHeader('RecordID',recordId);
					req.setheader('Content-Type',BOUNDARY);
					String body = '-' + BOUNDARY + '\r\nContent-Disposition: form-data; name="X-Forwarded-For"\r\n\r\n'+ '14.142.131.226' +'\r\n'+ EXTRABOUNDARY + '\r\nContent-Disposition: form-data; name="INSTITUTION_ID"\r\n\r\n'+ '4145' +'\r\n'+EXTRABOUNDARY + '\r\nContent-Disposition: form-data; name="AGGREGATOR_ID"\r\n\r\n' + '676' +'\r\n'+EXTRABOUNDARY + '\r\nContent-Disposition: form-data; name="MEMBER_ID"\r\n\r\n' + 'cpu_user@fedfina.com' +'\r\n'+EXTRABOUNDARY + '\r\nContent-Disposition: form-data; name="PASSWORD"\r\n\r\n' + 'JDFhd0l6ZFE=' +'\r\n'+EXTRABOUNDARY + '\r\nContent-Disposition: form-data; name="inputJson_"\r\n\r\n'+payload+ ENDBOUNDARY;
					String reqBody=body;
                    System.debug(':::'+reqBody);
                    req.setbody(reqBody);
					*/
                    IntgSvcMgmt__mdt svc = svcname=='Consumer ACK Request'? IntgSvcMgmt__mdt.getInstance('Consumer_ACK_Request'):IntgSvcMgmt__mdt.getInstance('Consumer_Issue_Request');
                    req.setheader('Content-Type','multipart/form-data; boundary=--------------------------466421723705540664751601');
                    string body='---------------------------466421723705540664751601\r\nContent-Disposition: form-data; name="X-Forwarded-For"\r\n\r\n'+svc.X_Forwarded_For__c+'\r\n----------------------------466421723705540664751601\r\nContent-Disposition: form-data; name="INSTITUTION_ID"\r\n\r\n'+svc.InstitutionId__c+'\r\n----------------------------466421723705540664751601\r\nContent-Disposition: form-data; name="AGGREGATOR_ID"\r\n\r\n'+svc.AggregatorID__c+'\r\n----------------------------466421723705540664751601\r\nContent-Disposition: form-data; name="MEMBER_ID"\r\n\r\n'+svc.Username__c+'\r\n----------------------------466421723705540664751601\r\nContent-Disposition: form-data; name="PASSWORD"\r\n\r\n'+svc.Password__c+'\r\n----------------------------466421723705540664751601\r\nContent-Disposition: form-data; name="inputJson_"\r\n\r\n'+payload+'\r\n----------------------------466421723705540664751601--\r\n';
                    req.setbody(body);
                    
                    
                } 
                else if(svcname=='Commercial ACK Request' || svcname=='Commercial Issue Request'){
                    IntgSvcMgmt__mdt svc = svcname=='Commercial ACK Request'? IntgSvcMgmt__mdt.getInstance('Commercial_ACK_Request'):IntgSvcMgmt__mdt.getInstance('Commercial_Issue_Request');
                    req.setheader('Content-Type','multipart/form-data; boundary=--------------------------466421723705540664751601');
                    //string body='---------------------------466421723705540664751601\r\nContent-Disposition: form-data; name="X-Forwarded-For"\r\n\r\n14.142.131.226\r\n----------------------------466421723705540664751601\r\nContent-Disposition: form-data; name="INSTITUTION_ID"\r\n\r\n4145\r\n----------------------------466421723705540664751601\r\nContent-Disposition: form-data; name="AGGREGATOR_ID"\r\n\r\n676\r\n----------------------------466421723705540664751601\r\nContent-Disposition: form-data; name="MEMBER_ID"\r\n\r\ncpu_comm_user@fedfina.com\r\n----------------------------466421723705540664751601\r\nContent-Disposition: form-data; name="PASSWORD"\r\n\r\nT3gmYjFTQDE=\r\n----------------------------466421723705540664751601\r\nContent-Disposition: form-data; name="inputJson_"\r\n\r\n'+payload+'\r\n----------------------------466421723705540664751601--\r\n';
                    string body='---------------------------466421723705540664751601\r\nContent-Disposition: form-data; name="X-Forwarded-For"\r\n\r\n'+svc.X_Forwarded_For__c+'\r\n----------------------------466421723705540664751601\r\nContent-Disposition: form-data; name="INSTITUTION_ID"\r\n\r\n'+svc.InstitutionId__c+'\r\n----------------------------466421723705540664751601\r\nContent-Disposition: form-data; name="AGGREGATOR_ID"\r\n\r\n'+svc.AggregatorID__c+'\r\n----------------------------466421723705540664751601\r\nContent-Disposition: form-data; name="MEMBER_ID"\r\n\r\n'+svc.Username__c+'\r\n----------------------------466421723705540664751601\r\nContent-Disposition: form-data; name="PASSWORD"\r\n\r\n'+svc.Password__c+'\r\n----------------------------466421723705540664751601\r\nContent-Disposition: form-data; name="inputJson_"\r\n\r\n'+payload+'\r\n----------------------------466421723705540664751601--\r\n';
                    req.setbody(body);
                }
                else{
                    if(payload==null && svcname!='Dedupe API Token'){
                        req.setBody(att.body.tostring());
                    }
                    else if(svcname!='Dedupe API Token' && svcname!='ScreeningWachout' && apiVendor!='Perfios' && apiVendor !='BillDesk' && apiVendor !='WorkApps')
                    {
                        req.setBody(payload);
                    }   
                }
                
            }
            else 
            {
                req.setEndpoint(payload);
                //req.setHeader('x-client-id','BDJHZhBnMHMWHcZeLKQCPdQCZhKAFYZRCbEf');
                //req.setHeader('x-client-secret','LIGTiBlCBXQMSAhIaVmQWZZQBSFRSnVdfKYeDbkIIkPYOimdOQ');
                //req.setHeader('x-application-id','fac7bd67-c7ca-4b38-81a2-c851827f6d6c');
                //req.setHeader('Content-Type', 'application/json');
                //req.setHeader('APIVendor','Syntizen');
                //req.setHeader('APIname','SFDC Aadhar Vault');
                //req.setHeader('RecordID',recordId); 
            }
            
            req.setMethod('POST');
            if(apiVendor=='Karza'){
                req.setHeader('x-karza-key',System.label.Karza_API_Key);
            }
            if(apiVendor=='Signdesk'){
                IntgSvcMgmt__mdt svc = IntgSvcMgmt__mdt.getInstance('SFDC_Aadhar_XML_Verification_API');
                req.setHeader('x-parse-application-id',svc.ApplicationId__c);//'fedbankfinancialservicesltd_kyc_uat'
                req.setHeader('x-parse-rest-api-key',svc.APIKey__c);//'81855ad8681d0d86d1e91e00167939cb'
            }
            if(apiVendor=='FedENPA'){
                IntgSvcMgmt__mdt svc = IntgSvcMgmt__mdt.getInstance('ENPA_Details');
                req.setHeader('StaticKey',svc.StaticKey__c);
            }
            if(svcname=='Dedupe API Token'){
                IntgSvcMgmt__mdt svc = IntgSvcMgmt__mdt.getInstance('Dedupe_API_Token');
                req.setHeader('username',svc.Username__c);
                req.setHeader('password',svc.Password__c);
                req.setHeader('grant_type','password');
                req.setHeader('Authorization','Basic ' + svc.APIToken__c);
            }
            if(svcname=='Hunter Token'){
                IntgSvcMgmt__mdt svc = IntgSvcMgmt__mdt.getInstance('Hunter_Token');
                //req.setHeader('xCorrelationId',svc.CorrelationId__c);//'7d590538-250a-4e01-bb17-80c207c9c70a'
                req.setHeader('x-user-domain',svc.Domain__c);//'fedfina.com'
            }
            if(svcname=='Dedupe' || svcname=='UCIC'){
                string token=getAuthorizationToken(recordId,svcName);
                req.setHeader('Authorization',token);
            }
            if(svcname=='Hunter API'){
                IntgSvcMgmt__mdt svc = IntgSvcMgmt__mdt.getInstance('Hunter_API');
                string token=getAuthorizationToken(recordId,svcName);
                req.setHeader('Authorization',token);
                //req.setHeader('xCorrelationId',svc.CorrelationId__c);//'a34727f1-b872-46c8-b905-151356d13034'
                req.setHeader('x-user-domain',svc.Domain__c);//'crosscore-in-sit.com'
                req.setHeader('ID',svc.ApplicationId__c);//'3'
                
            }
            if(svcname=='Crif Execute API'){
                string token=getAuthorizationToken(recordId,svcName);
                req.setHeader('Authorization',token);
            }
            if(svcname=='ScreeningWachout'){
                IntgSvcMgmt__mdt svc = IntgSvcMgmt__mdt.getInstance('ScreeningWachout');
                req.setHeader('InputParams',payload);
                req.setHeader('USERID',svc.Username__c);//'abeKldFjg345i9eklDflkfoasd'                
            }
            if(apiVendor=='Perfios'){
                if(svcname=='Initiate Consent' || svcname=='Transaction Status'){
                    APIConfiguration__c config = APIConfiguration__c.getInstance('Perfios AA');
                    req.setHeader('api_key',config.APIKey__c);
                    req.setHeader('org_id',config.SourceName__c);
                    req.setBody(payload);
                }
                else{
                    Map<String,Object> requestMap = (Map<String,Object>) JSON.deserializeUntyped (payload);
                    Map<String,APIGatewayHeaders__c> APIGatewayHeadersMap = APIGatewayHeaders__c.getAll();
                    
                    req.setHeader(APIGatewayHeadersMap.get('PerfiosAlgorithm').Name__c,(String)((Map<String, Object>)requestMap.get('Header')).get('perfiosAlgorithm'));
                    req.setHeader(APIGatewayHeadersMap.get('PerfiosContentSha256').Name__c,(String)((Map<String, Object>)requestMap.get('Header')).get('sha256Content'));
                    req.setHeader(APIGatewayHeadersMap.get('PerfiosDate').Name__c,(String)((Map<String, Object>)requestMap.get('Header')).get('perfioRequestDate'));
                    req.setHeader(APIGatewayHeadersMap.get('PerfiosSignature').Name__c,(String)((Map<String, Object>)requestMap.get('Header')).get('perfioSignature'));
                    req.setHeader(APIGatewayHeadersMap.get('PerfiosSignedHeaders').Name__c,(String)((Map<String, Object>)requestMap.get('Header')).get('perfiosSignedHeaders'));
                    req.setHeader(APIGatewayHeadersMap.get('PerfiosAccept').Name__c,APIGatewayHeadersMap.get('PerfiosAccept').Value__c);
                    req.setHeader(APIGatewayHeadersMap.get('PerfiosContentType').Name__c,APIGatewayHeadersMap.get('PerfiosContentType').Value__c);
                    
                    if(svcname =='Initiate Transaction'){
                        PerfiosInitiateRequestWrapper requestPayload = (PerfiosInitiateRequestWrapper) JSON.deserialize(JSON.serializePretty(requestMap.get('Payload')) , PerfiosInitiateRequestWrapper.class);
                        req.setBody(JSON.serialize(requestPayload));
                    }
                    else if(svcname =='Generate Link'){
                        PerfiosGenerateLinkRequestWrapper requestPayload = (PerfiosGenerateLinkRequestWrapper) JSON.deserialize(JSON.serializePretty(requestMap.get('Payload')) , PerfiosGenerateLinkRequestWrapper.class);
                        req.setBody(JSON.serialize(requestPayload));
                    }
                    else if(svcname=='Upload Files'){
                        
                        req.setHeader(APIGatewayHeadersMap.get('PerfiosTransactionId').Name__c, (String)((Map<String, Object>)requestMap.get('Header')).get('transactionID'));
                        system.debug(':::::'+PerfiosAPIController.GetContentType());
                        req.setHeader('Content-Type', PerfiosAPIController.GetContentType());
                        req.setHeader(APIGatewayHeadersMap.get('PerfiosContentType').Name__c, PerfiosAPIController.GetContentType());
                        req.setHeader(APIGatewayHeadersMap.get('PerfiosCacheControl').Name__c, APIGatewayHeadersMap.get('PerfiosCacheControl').Value__c);
                        req.setHeader(APIGatewayHeadersMap.get('PerfiosConnection').Name__c, APIGatewayHeadersMap.get('PerfiosConnection').Value__c);
                        
                        String docDetialId = (String)((Map<String, Object>)requestMap.get('Header')).get('fileId');
                        /*ContentDocumentLink cdlList =  [SELECT Id, LinkedEntityId,ContentDocumentId,ContentDocument.FileType FROM
						ContentDocumentLink where LinkedEntityId =:docDetialId];*/
                        
                        verData = [SELECT Title,VersionData,ContentDocumentId,FileType,FileExtension FROM ContentVersion 
                                   where ID = :docDetialId];
                        
                        String fileName= verData.Title +'.'+verData.FileExtension;
                        Map<String,String> metadataMap = new Map<String,String>();
                        
                        req.setBodyAsBlob(PerfiosAPIController.multiPartFormDataBody(verData.VersionData, 'application/pdf', fileName, metadataMap));
                        
                    }
                    else if(svcname=='Process Files'){
                        req.setHeader(APIGatewayHeadersMap.get('PerfiosTransactionId').Name__c, (String)((Map<String, Object>)requestMap.get('Header')).get('transactionID'));
                        PerfiosProcessFilesRequestWrapper requestPayload = (PerfiosProcessFilesRequestWrapper) JSON.deserialize(JSON.serializePretty(requestMap.get('Payload')) , PerfiosProcessFilesRequestWrapper.class);
                        req.setBody(JSON.serialize(requestPayload));
                    }
                    else if(svcname=='Report generation'){
                        req.setHeader(APIGatewayHeadersMap.get('PerfiosTransactionId').Name__c, (String)((Map<String, Object>)requestMap.get('Header')).get('transactionID'));
                        //req.setBody();
                    }
                    /*else if(svcname=='Retrieve Report'){
                    req.setEndpoint('callout:APIGateway/?types=json,xlsx');
                    req.setHeader('transactionID', (String)((Map<String, Object>)requestMap.get('Header')).get('transactionID'));
                    
                    }*/
                }
            }
            if(apiVendor=='Enach'){
                IntgSvcMgmt__mdt svc = IntgSvcMgmt__mdt.getInstance('Enach');
                req.setHeader('Authorization','Basic ' + svc.APIToken__c);
                //req.setHeader('Authorization','Basic QUlTNk5RRVQ2WThJMTNZNEdXNFZXRjlGRVM4WUNSVFU6WVk2S0tWQkZHRFFFWjVNQUxXSVY3NUJTM0VRMk9TNTE=');//QUlRSjVBTU1IUjhTN1dCUlU4Q081RkRBSkdYQTVGRkU6MkQzUEFZQURFTzcxS0pJVFVTNDM0NEM1Rkc2SExHWlE=
            }
            if(svcname=='Get Multi Tranch'){
                IntgSvcMgmt__mdt svc = IntgSvcMgmt__mdt.getInstance('Get_Multi_Tranch');
                req.setHeader('StaticKey',svc.StaticKey__c);
                req.setHeader('operation-flag',svc.OperationFlag__c);
            }
            if(apiVendor=='HRMS'){
                IntgSvcMgmt__mdt svc = IntgSvcMgmt__mdt.getInstance('Get_HRMS_Details');
                req.setHeader('StaticKey',svc.StaticKey__c);
            }
            if(apiVendor=='Probe'){
                APIConfiguration__c ProbeConfig = APIConfiguration__c.getInstance('Probe');
                req.setHeader('apikey',ProbeConfig.APIKey__c);
            }
            if(apiVendor=='BillDesk'){
                Map<String,Object> requestMap = (Map<String,Object>) JSON.deserializeUntyped (payload);
                if(requestMap.containsKey('Header')){
                    Map<String,Object> headerMap = (Map<String,Object>) requestMap.get('Header');
                    req.setHeader('BDTraceid',headerMap.containsKey('BD-Traceid') ? String.valueOf(headerMap.get('BD-Traceid')) : '');
                    req.setHeader('BDTimestamp',headerMap.containsKey('BD-Timestamp') ? String.valueOf(headerMap.get('BD-Timestamp')) : '');
                    req.setHeader('Accept','application/jose');
                    req.setHeader('Content-Type','application/jose');
                }
                
                req.setBody(requestMap.containsKey('encrypted_Payload') ? String.valueOf(requestMap.get('encrypted_Payload')) : ''); 
            }
            if(apiVendor == 'WorkApps'){
                Map<String,Object> requestMap = (Map<String,Object>) JSON.deserializeUntyped (payload);
                IntgSvcMgmt__mdt svc = IntgSvcMgmt__mdt.getInstance('Guest_Call');
                req.setHeader('clientId','101');
                req.setHeader('apikey','cb8fedb939fe11ef9b7b0267c6221b81');
                
                if(requestMap.containsKey('Header')){
                    Map<String,Object> headerMap = (Map<String,Object>) requestMap.get('Header');
                    req.setHeader('xRequestId',headerMap.containsKey('RequestId') ? String.valueOf(headerMap.get('RequestId')) : '');
                    req.setHeader('Signature',headerMap.containsKey('Signature') ? String.valueOf(headerMap.get('Signature')) : '');
                    req.setHeader('Timestamp',headerMap.containsKey('Timestamp') ? String.valueOf(headerMap.get('Timestamp')) : '');
                    if(svcname == 'Guest Call Details'){
                        req.setHeader('groupId',headerMap.containsKey('GroupId') ? String.valueOf(headerMap.get('GroupId')) : '');
                    }
                }
                if(svcname == 'Guest Call'){
                    req.setBody(requestMap.containsKey('Payload') ? JSON.serialize(requestMap.get('Payload')) : ''); 
                }
                
            }
            
            if(apiVendor=='FinFort' && (svcname=='Create Order - GST' || svcname=='Create Order - ITR')){
                req.setHeader('client-security-token',getAuthorizationToken(recordId,svcName));
            }
            
            if(apiVendor=='CrimeCheck' && (svcname=='Crime Add Report API - Individual' || svcname=='Crime Add Report API - Company')){
                req.setHeader('Content-Type','application/x-www-form-urlencoded');
            }
            
            req.setHeader('APIVendor',apiVendor);
            
            if(apiVendor=='FinFort' && (svcname=='FinFort Auth Token - GST' || svcname=='FinFort Auth Token - ITR')){
                req.setHeader('APIname','FinFort Auth Token');
            }
            
            else if(apiVendor=='FinFort' && (svcname=='Create Order - GST' || svcname=='Create Order - ITR')){
                req.setHeader('APIname','Create Order');
            }
            
            else{
                req.setHeader('APIname',svcName);
            }
            
            req.setHeader('RecordID',recordId);
            req.setTimeout(30000);
            
            res = http.send(req);
            
            IntgMsg__c intg = new IntgMsg__c();
            intg.Id = recordId;
            intg.MStatus__c= GlobalConstants.INT_MSG_MStatus_ACKNOWLEDGED;
            intg.Mresp__c = res.getBody();
            update intg;
            if(String.isNotBlank(System.label.APISuccessStatusCodes)){
                Set<String> statusCodes = new Set<String>(System.label.APISuccessStatusCodes.split(','));
                Map<String, Object> responseJsonMap; 
                if(String.isNotBlank(res.getBody())){
                    responseJsonMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                }
                if((!statusCodes.contains(String.ValueOf(res.getStatusCode()))) && (responseJsonMap!=null && responseJsonMap.containsKey('message') && String.isNotBlank(String.valueOf(responseJsonMap.get('message'))) && !statusCodes.contains(String.valueOf(responseJsonMap.get('message'))))){
                    List<IntgMsg__c> intgList = [Select Id, ApiVendor__c,Svc__c,RefId__c from IntgMsg__c Where Id =:recordId];
                    if(intgList!=null && !intgList.isEmpty()){
                        APICalloutTracker.update_ApiTrackerWithIntMsg(intgList[0].Id,intgList[0].Svc__c, intgList[0].RefId__c, 'Failure');
                    }
                }
            }
        }
        catch(Exception ex){
            
            IntgMsg__c intg = new IntgMsg__c();
            intg.Id = recordId;
            intg.Status__c = GlobalConstants.INT_MSG_Status_EXCEPTION;
            update intg;
            GlobalUtility.logMessage('Error', 'APIGatewayService' + ex.getLineNumber(), 'performAPICallout', recordId, null, ex.getMessage() + ' Line: ' + ex.getLineNumber() , null, ex, null);
            List<IntgMsg__c> intgList = [Select Id, ApiVendor__c,Svc__c,RefId__c from IntgMsg__c Where Id =:recordId];
            if(intgList!=null && !intgList.isEmpty()){
                APICalloutTracker.update_ApiTrackerWithIntMsg(intgList[0].Id,intgList[0].Svc__c, intgList[0].RefId__c, 'Failure');
            }
        }
               
    }
}