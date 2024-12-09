public class GetFileFromSharePoint {

    public static String getFileFromSharePoint(String relativeURL){
        HttpRequest req = new HttpRequest();
        String endPointUrl = 'callout:SharePoint';
        
        //endPointUrl = endPointUrl+'/_api/web/GetFileByServerRelativeUrl(/sites/FedFinaPOC/Shared%20Documents';
        //endPointUrl = endPointUrl+'/'+folderName+'/'+fileName+')'+'/$value';
        
        endPointUrl = endPointUrl+'/_api/web/GetFileByServerRelativeUrl(\''+relativeURL+'\')/$value?binaryStringResponseBody=true';
        //endPointUrl = endPointUrl+'/_api/web/GetFileByServerRelativeUrl(\''+relativeURL+'\')/OpenBinaryStream';
        
        //endPointUrl = endPointUrl+'/Files/AddUsingPath(decodedurl=\''+fileName+'\',overwrite=true)';
        req.setEndpoint(endPointUrl);
        req.setMethod('GET');
        req.setHeader('Accept', 'application/json;odata=verbose');
        req.setHeader('Content-Type', 'application/json;odata=verbose');
       	//req.setHeader('Content-Type','application/octet-stream');
        req.setHeader('X-RequestDigest', '{form_digest_value}');
        //req.setHeader('Accept', 'application/json; odata=verbose');
        //req.setBodyAsBlob(fileData);
        //req.setHeader('Content-Length', String.valueOf(fileData.size()));
        Http http = new Http();
        HTTPResponse res = http.send(req);
        system.debug(res.getBody());
        return res.getBody();
        //system.debug(EncodingUtil.base64Decode(res.getBody()));
        //Create Document
        //ContentVersion cv = new ContentVersion();
        //cv.Title = 'Test Document';
        //cv.PathOnClient = 'TestDocument.png';
        //system.debug(res.getBodyAsBlob());
        //system.debug(res.getBodyDocument());
        //cv.VersionData = EncodingUtil.base64Decode(res.getBody();
        //cv.IsMajorVersion = true;
        //Insert cv;
         
        //Get Content Documents
        //Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
 		//system.debug(cv.id);
        //system.debug(conDocId);

        
    }
}