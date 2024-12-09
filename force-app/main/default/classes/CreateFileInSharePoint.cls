/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-13-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class CreateFileInSharePoint {

    @future(callout=true)
    public static void createFiles(Blob fileData,String folderName,String fileName){
        try {
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
          //req.setHeader('Content-Length', String.valueOf(fileData.size()));
            Http http = new Http();
            HTTPResponse res = http.send(req);
            system.debug('####File creation response-'+res.getBody());
        }
        catch(Exception ex) {
            System.debug('error'+ex.getMessage());
            GlobalUtility.logMessage('Error', 'CreateFileInSharePoint' + ex.getLineNumber(), 'createFiles', null, null, ex.getMessage() + ' Line: ' + ex.getLineNumber(), null, ex, null);
        }
    }
}