public class SharePointAPI {
    
    public static SObject createFolder(String folderName, SObject record){
        try {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:SharePoint'+'/_api/web/folders');
            req.setMethod('POST');
            
            CreateFolderWrapper requestBody = new CreateFolderWrapper();  
            Metadata metadataObj= new Metadata();
            metadataObj.type = 'SP.Folder';
            requestBody.metadata = metadataObj;
            requestBody.ServerRelativeUrl = '/sites/FedSaleForce_UAT/Shared%20Documents/'+folderName;
            String jsonBody= JSON.serialize(requestBody);
            jsonBody = jsonBody.replace('metadata', '__metadata');
            req.setBody(jsonBody);
            System.debug('###FolderCreationJSONBody-'+jsonBody);
            Http http = new Http();
            HTTPResponse res = http.send(req);
            System.debug('Status Code: ' + res.getStatusCode() + ':' +  res.getStatus());
            System.debug('###FolderCreationJSONResponse-'+res.getBody());
            
            if(record!=null){
                if(res.getStatusCode() == 201){
                    Map<String, Object> responseJsonMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());  
                    if(responseJsonMap.containsKey('d')){
                        Map<String,Object> innerJsonMap = (Map<String, Object>) (responseJsonMap.get('d'));
                        if(innerJsonMap.containsKey('ServerRelativeUrl')){
                            system.debug((String) innerJsonMap.get('ServerRelativeUrl'));
                            record.put('SharePointRelativeUrl__c', (String) innerJsonMap.get('ServerRelativeUrl'));
                            record.put('SharePointFolderStatus__c', 'Success');
                            record.put('SharePointFolderErrorMessage__c', '');
                        }
                        else{
                            record.put('SharePointFolderStatus__c', 'Failure');
                            record.put('SharePointFolderErrorMessage__c','ServerRelativeUrl Not Found');
                        }
                    }
                    else{
                        record.put('SharePointFolderStatus__c', 'Failure');
                        record.put('SharePointFolderErrorMessage__c','ServerRelativeUrl Not Found');
                    }
                }
                else{
                    record.put('SharePointFolderStatus__c', 'Failure');
                    Map<String, Object> responseJsonMap; 
                    Map<String, Object> innerJsonMap;
                    Map<String, Object> innerChildJsonMap;
                    if(res.getBody()!=null){
                        responseJsonMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                        if(responseJsonMap.containsKey('error')){
                            innerJsonMap =  (Map<String, Object>) responseJsonMap.get('error');  
                            if(innerJsonMap.containsKey('message')){
                                innerChildJsonMap =  (Map<String, Object>) innerJsonMap.get('message'); 
                            }
                        }
                    }    
                    
                    record.put('SharePointFolderErrorMessage__c',(innerChildJsonMap!=null && innerChildJsonMap.containsKey('value')) ? innerChildJsonMap.get('value') : 'No folder was created');
                }
            }
            
        }
        catch(Exception ex) {
            System.debug('error'+ex.getMessage());
            //GlobalUtility.logMessage('Error', 'SharePointAPI' + ex.getLineNumber(), 'createFolder', null, null, ex.getMessage() + ' Line: ' + ex.getLineNumber(), null, ex, null);
            record.put('SharePointFolderStatus__c', 'Failure');
            record.put('SharePointFolderErrorMessage__c', 'An unexpected error has occurred');
        }
        
        return record;
    }
    
    /*@future(callout=true)
    public static void createFile(Blob fileData,String folderName,String fileName, Id docDtlId, Id contentVersionId){
        try {
            
            if(String.isNotBlank(folderName) && String.isNotBlank(fileName)){
                
                HttpRequest req = new HttpRequest();
                String endPointUrl = 'callout:SharePoint';
                endPointUrl = endPointUrl+'/_api/web/GetFolderByServerRelativeUrl(';
                endPointUrl = endPointUrl+'\'/sites/FedSaleForce_UAT/Shared%20Documents/'+folderName+'\')';
                endPointUrl = endPointUrl+'/Files/AddUsingPath(decodedurl=\''+fileName+'\',overwrite=true)';
                req.setEndpoint(endPointUrl);
                req.setMethod('POST');
                req.setHeader('Content-Type','application/octet-stream');
                req.setHeader('X-RequestDigest', '{form_digest_value}');
                req.setBodyAsBlob(fileData);
                
                Http http = new Http();
                HTTPResponse res = http.send(req);
                system.debug('####File creation response-'+res.getBody());
                if(docDtlId!=null && contentVersionId!=null){
                    if(res.getStatusCode() == 200){
                        ContentVersion ver = new ContentVersion();
                        ver.Id = contentVersionId;
                        ver.SharePointFileSyncStatus__c ='Success';
                        ver.SharePointFileSyncErrorMessage__c='';
                        update ver;
                        Map<String, Object> responseJsonMap;
                        Map<String,Object> innerJsonMap;
                        if(res.getBody()!=null){
                            responseJsonMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());  
                        }
                        if(responseJsonMap.containsKey('d')){
                            innerJsonMap = (Map<String, Object>) (responseJsonMap.get('d'));
                        }    
                        DocDtlItem__c docDtlItem = new DocDtlItem__c();
                        docDtlItem.DocumentDetail__c = docDtlId;
                        docDtlItem.Type__c = 'SharePoint';
                        docDtlItem.FileName__c = fileName;
                        docDtlItem.SharePointFileSyncStatus__c = 'Success';
                        docDtlItem.SharePointFileSyncErrorMessage__c = '';  
                        docDtlItem.FileRelativeUrl__c = (innerJsonMap!=null && innerJsonMap.containsKey('ServerRelativeUrl')) ? (String) innerJsonMap.get('ServerRelativeUrl') : '';
                        insert docDtlItem;
                    }
                    else{
                        Map<String, Object> responseJsonMap;
                        Map<String, Object> innerJsonMap;
                        Map<String, Object> innerChildJsonMap;
                        if(res.getBody()!=null){
                            responseJsonMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody()); 
                            if(responseJsonMap.containsKey('error')){
                                innerJsonMap =  (Map<String, Object>) responseJsonMap.get('error');
                                if(innerJsonMap.containsKey('message')){
                                    innerChildJsonMap =  (Map<String, Object>) innerJsonMap.get('message');   
                                }
                            }
                        }
                        
                        ContentVersion ver = new ContentVersion();
                        ver.Id = contentVersionId;
                        ver.SharePointFileSyncStatus__c ='Failure';
                        ver.SharePointFileSyncErrorMessage__c= innerChildJsonMap!=null && innerChildJsonMap.containsKey('value') ? (String) innerChildJsonMap.get('value') : 'No file was created';
                        update ver;
                    }
                }
            }
        }
        catch(Exception ex) {
            System.debug('error'+ex.getMessage());
            GlobalUtility.logMessage('Error', 'CreateFileInSharePoint' + ex.getLineNumber(), 'createFiles', null, null, ex.getMessage() + ' Line: ' + ex.getLineNumber(), null, ex, null);
            if(contentVersionId!=null){
                ContentVersion ver = new ContentVersion();
                ver.Id = contentVersionId;
                ver.SharePointFileSyncStatus__c ='Failure';
                ver.SharePointFileSyncErrorMessage__c= 'An unexpected error has occurred';
                update ver;
            }
        }
    }*/
    
    public static List<SObject> createFiles(Id loanAppId){
        
        List<SObject> recordToInsertList = new List<SObject>();
        if(loanAppId!=null){
            
            Map<Id,DocDtl__c> docDtlMap = new Map<Id,DocDtl__c>([SELECT Id,DocCatgry__c, DocTyp__c, DocSubTyp__c, LAN__c,LAN__r.Name  FROM DocDtl__c WHERE LAN__c=:loanAppId]);
            Map<Id,Id> contentDocLinkMap = new Map<Id,Id>();
            Map<Id,ContentDocumentLink> contentDocumentLinkMap = new Map<Id,ContentDocumentLink>();
            Map<Id,contentVersion> contentVersionMap = new Map<Id,contentVersion>();
            Set<Id> contentDocIds = new Set<Id>();
            APIConfiguration__c SharePointConfig = APIConfiguration__c.getInstance('SharePoint');
            for(ContentDocumentLink contentDocLink : [SELECT Id,ContentDocumentId,LinkedEntityId  FROM ContentDocumentLink WHERE LinkedEntityId  IN:docDtlMap.keySet()]){
                contentDocIds.add(contentDocLink.ContentDocumentId);
                contentDocumentLinkMap.put(contentDocLink.Id,contentDocLink);
            }
            
            for(ContentVersion ver : [SELECT Id,VersionData,ContentDocumentId,CreatedDate,Title,FileExtension,ContentSize FROM ContentVersion WHERE ContentDocumentId IN:contentDocIds]){
                Decimal fileSize = ver.ContentSize/(1024 *1024);
                if(fileSize.setScale(2, RoundingMode.HALF_UP)  <= SharePointConfig.MaxSize__c){
                    contentVersionMap.put(ver.ContentDocumentId,ver);
                }
                
            }
            
            if(contentDocumentLinkMap!=null && !contentDocumentLinkMap.isEmpty()){
                //List<ContentVersion> contentVersionList = new List<ContentVersion>();
                //List<DocDtlItem__c> docDtlItemList = new List<DocDtlItem__c>();
                
                for(ContentDocumentLink contentDocLink : contentDocumentLinkMap.values()){
                    if(contentVersionMap.containsKey(contentDocLink.ContentDocumentId) && docDtlMap.containsKey(contentDocLink.LinkedEntityId)){
                        ContentVersion ver = contentVersionMap.get(contentDocLink.ContentDocumentId);
                        String fileName = (docDtlMap.get(contentDocLink.LinkedEntityId).DocTyp__c + '_' + ver.Title.substringBefore('.') + '_' + String.valueOf(DateTime.newInstance(ver.CreatedDate.year(), ver.CreatedDate.month(), ver.CreatedDate.day(),ver.CreatedDate.hour(),ver.CreatedDate.minute(),ver.CreatedDate.second()).format('YYYY-MM-dd_HH-mm-ss')) + '.' + ver.FileExtension.toLowerCase()).replaceAll(' ','_');
                        String folderName = docDtlMap.get(contentDocLink.LinkedEntityId).LAN__r.Name;
                        SObject record = createFile(ver.VersionData, folderName, fileName, new DocDtlItem__c(DocumentDetail__c = contentDocLink.LinkedEntityId, DocumentId__c = contentDocLink.ContentDocumentId,Type__c = 'SharePoint',FileName__c = fileName));
                        recordToInsertList.add(record);
                        /*DocDtlItem__c docDtlItem = new DocDtlItem__c();
                        docDtlItem.DocumentDetail__c = contentDocLink.LinkedEntityId;
                        docDtlItem.DocumentId__c = contentDocLink.ContentDocumentId;
                        docDtlItem.Type__c = 'SharePoint';
                        docDtlItem.FileName__c = fileName;
                        
                        try {
                            
                            if(String.isNotBlank(folderName) && String.isNotBlank(fileName)){
                                DateTime startDateTime = System.now();
                                HttpRequest req = new HttpRequest();
                                String endPointUrl = 'callout:SharePoint';
                                endPointUrl = endPointUrl+'/_api/web/GetFolderByServerRelativeUrl(';
                                endPointUrl = endPointUrl+'\'/sites/FedSaleForce_UAT/Shared%20Documents/'+folderName+'\')';
                                endPointUrl = endPointUrl+'/Files/AddUsingPath(decodedurl=\''+fileName+'\',overwrite=true)';
                                req.setEndpoint(endPointUrl);
                                req.setMethod('POST');
                                req.setHeader('Content-Type','application/octet-stream');
                                req.setHeader('X-RequestDigest', '{form_digest_value}');
                                req.setBodyAsBlob(ver.VersionData);
                                
                                Http http = new Http();
                                HTTPResponse res = http.send(req);
                                system.debug('####File creation response-'+res.getBody());
                                
                                
                                    
                                DateTime endDateTime = System.now();
                                if(res.getStatusCode() == 200){
                                   Map<String, Object> responseJsonMap;
                                    Map<String,Object> innerJsonMap;
                                    if(res.getBody()!=null){
                                        responseJsonMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());  
                                    }
                                    if(responseJsonMap.containsKey('d')){
                                        innerJsonMap = (Map<String, Object>) (responseJsonMap.get('d'));
                                    }    
                                    docDtlItem.SharePointFileSyncStatus__c = 'Success';
                                    docDtlItem.SharePointFileSyncErrorMessage__c = '';  
                                    docDtlItem.FileRelativeUrl__c = (innerJsonMap!=null && innerJsonMap.containsKey('ServerRelativeUrl')) ? (String) innerJsonMap.get('ServerRelativeUrl') : '';
                                    docDtlItem.SharePointFileUploadStartDate__c = startDateTime;
                                    docDtlItem.SharePointFileUploadEndDate__c = endDateTime;
                                    
                                }
                                else{
                                    Map<String, Object> responseJsonMap;
                                    Map<String, Object> innerJsonMap;
                                    Map<String, Object> innerChildJsonMap;
                                    if(res.getBody()!=null){
                                        responseJsonMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody()); 
                                        if(responseJsonMap.containsKey('error')){
                                            innerJsonMap =  (Map<String, Object>) responseJsonMap.get('error');
                                            if(innerJsonMap.containsKey('message')){
                                                innerChildJsonMap =  (Map<String, Object>) innerJsonMap.get('message');   
                                            }
                                        }
                                    }
                                    
                                    docDtlItem.SharePointFileSyncStatus__c = 'Failure';
                                    docDtlItem.SharePointFileSyncErrorMessage__c = innerChildJsonMap!=null && innerChildJsonMap.containsKey('value') ? (String) innerChildJsonMap.get('value') : 'No file was created';
                                }
                                
                            }
                        }
                        catch(Exception ex) {
                            System.debug('error'+ex.getMessage());
                            GlobalUtility.logMessage('Error', 'CreateFileInSharePoint' + ex.getLineNumber(), 'createFiles', null, null, ex.getMessage() + ' Line: ' + ex.getLineNumber(), null, ex, null);
                            
                            docDtlItem.SharePointFileSyncStatus__c = 'Failure';
                            docDtlItem.SharePointFileSyncErrorMessage__c = 'An unexpected error has occurred';
                        }
                        
                        docDtlItemList.add(docDtlItem);*/
                    }
                }
                
                //if(!recordToInsertList.isEmpty()){
                //    insert recordToInsertList;
                //}
            }	            
        }
        
        return recordToInsertList;
    }
    
    public static SObject createFile(Blob fileData,String folderName,String fileName, SObject record){
        //List<Exception> exceptionList = new List<Exception>();
        try {
            
            if(String.isNotBlank(folderName) && String.isNotBlank(fileName) && fileData!=null){
                DateTime startDateTime = System.now();
                HttpRequest req = new HttpRequest();
                String endPointUrl = 'callout:SharePoint';
                endPointUrl = endPointUrl+'/_api/web/GetFolderByServerRelativeUrl(';
                endPointUrl = endPointUrl+'\'/sites/FedSaleForce_UAT/Shared%20Documents/'+folderName+'\')';
                endPointUrl = endPointUrl+'/Files/AddUsingPath(decodedurl=\''+fileName+'\',overwrite=true)';
                req.setEndpoint(endPointUrl);
                req.setMethod('POST');
                req.setHeader('Content-Type','application/octet-stream');
                req.setHeader('X-RequestDigest', '{form_digest_value}');
                req.setBodyAsBlob(fileData);
                
                Http http = new Http();
                HTTPResponse res = http.send(req);
                system.debug('####File creation response-'+res.getBody());
                DateTime endDateTime = System.now();
                if(record!=null){
                    if(res.getStatusCode() == 200){
                        Map<String, Object> responseJsonMap;
                        Map<String,Object> innerJsonMap;
                        if(res.getBody()!=null){
                            responseJsonMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());  
                        }
                        if(responseJsonMap.containsKey('d')){
                            innerJsonMap = (Map<String, Object>) (responseJsonMap.get('d'));
                        }    
                        record.put('SharePointFileSyncStatus__c','Success');
                        record.put('SharePointFileSyncErrorMessage__c', '');  
                        record.put('FileRelativeUrl__c', (innerJsonMap!=null && innerJsonMap.containsKey('ServerRelativeUrl')) ? (String) innerJsonMap.get('ServerRelativeUrl') : '');
                        record.put('SharePointFileUploadStartDate__c',startDateTime);
                        record.put('SharePointFileUploadEndDate__c',endDateTime);
                        
                    }
                    else{
                        Map<String, Object> responseJsonMap;
                        Map<String, Object> innerJsonMap;
                        Map<String, Object> innerChildJsonMap;
                        if(res.getBody()!=null){
                            responseJsonMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody()); 
                            if(responseJsonMap.containsKey('error')){
                                innerJsonMap =  (Map<String, Object>) responseJsonMap.get('error');
                                if(innerJsonMap.containsKey('message')){
                                    innerChildJsonMap =  (Map<String, Object>) innerJsonMap.get('message');   
                                }
                            }
                        }
                        
                        record.put('SharePointFileSyncStatus__c', 'Failure');
                        record.put('SharePointFileSyncErrorMessage__c', innerChildJsonMap!=null && innerChildJsonMap.containsKey('value') ? (String) innerChildJsonMap.get('value') : 'No file was created');
                    }
                }
            }
        }
        catch(Exception ex) {
            System.debug('error'+ex.getMessage());
            //exceptionList.add(ex);
            if(record!=null){
                record.put('SharePointFileSyncStatus__c','Failure');
                record.put('SharePointFileSyncErrorMessage__c', 'An unexpected error has occurred' + '\n'+ 'Error Message:' + ex.getMessage() + ' Line: ' + ex.getLineNumber());
            }
        }
        
        /*if(!exceptionList.isEmpty()){
            for(Exception ex : exceptionList){
               GlobalUtility.logMessage('Error', 'SharePointAPI' + ex.getLineNumber(), 'createFile', null, null, ex.getMessage() + ' Line: ' + ex.getLineNumber(), null, ex, null); 
            }
        }*/
        return record;
    }
    
    public class CreateFolderWrapper {
        public String ServerRelativeUrl;
        public Metadata metadata;
    }
    public class Metadata{
        public String type;
    }
}