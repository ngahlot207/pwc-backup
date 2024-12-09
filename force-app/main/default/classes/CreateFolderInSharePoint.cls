/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-13-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class CreateFolderInSharePoint {

    @future(callout=true)
    public static void createFolder(String folderName){
        try {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:SharePoint'+'/_api/web/folders');
            req.setMethod('POST');
            /*
            req.setHeader('Accept', 'application/json;odata=verbose');
            req.setHeader('Content-Type', 'application/json;odata=verbose');
            req.setHeader('X-RequestDigest', '{form_digest_value}');
			*/
            
            FolderCreateWrapper requestBody = new FolderCreateWrapper();  
            FolderCreateWrapper.MetadataClass metadataObj= new FolderCreateWrapper.MetadataClass();
            metadataObj.type = 'SP.Folder';
            requestBody.metadata = metadataObj;
            requestBody.ServerRelativeUrl = '/sites/FedSaleForce_UAT/Shared%20Documents/'+folderName;
            //Shared%20Documents/
            
            String jsonBody= JSON.serialize(requestBody);
            jsonBody = jsonBody.replace('metadata', '__metadata');
            req.setBody(jsonBody);
            System.debug('###FolderCreationJSONBody-'+jsonBody);
          //req.setHeader('Content-Length', String.valueOf(jsonBody.length()));
            Http http = new Http();
            HTTPResponse res = http.send(req);
            System.debug('###FolderCreationJSONResponse-'+res.getBody());
        }
        catch(Exception ex) {
            System.debug('error'+ex.getMessage());
            GlobalUtility.logMessage('Error', 'CreateFolderInSharePoint' + ex.getLineNumber(), 'createFolder', null, null, ex.getMessage() + ' Line: ' + ex.getLineNumber(), null, ex, null);
        }
    }
}