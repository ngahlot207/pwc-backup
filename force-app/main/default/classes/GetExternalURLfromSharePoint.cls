public class GetExternalURLfromSharePoint {

    public static String getURL(String folderName,String fileName){
        try {
        HttpRequest req = new HttpRequest();
        
        String endPointUrl = 'callout:SharePoint';
        endPointUrl = endPointUrl+'/_api/SP.Web.CreateAnonymousLink';
        //endPointUrl = endPointUrl+'\'/sites/FedFinaPOC/Shared%20Documents/'+folderName+'\')';
        //endPointUrl = endPointUrl+'/Files/AddUsingPath(decodedurl=\''+fileName+'\',overwrite=true)';
        req.setEndpoint(endPointUrl);
        req.setMethod('POST');
       	req.setHeader('Content-Type','application/json;odata=verbose');
        req.setHeader('Accept','application/json;odata=verbose');
        req.setHeader('X-RequestDigest', '{form_digest_value}');
        //req.setBodyAsBlob(fileData);
        //req.setHeader('Content-Length', String.valueOf(fileData.size()));
        GenerateExternalURLJSON body = new GenerateExternalURLJSON('https://fedfina1.sharepoint.com/sites/FedSaleForce_UAT/Shared%20Documents/'+folderName+'/'+fileName,'false');
        system.debug('Body Url-'+body.url);
        req.setBody(JSON.serialize(body));
        //req.setHeader('Content-Length', String.valueOf(JSON.serialize(body).length()));
        System.debug('Content Length-'+String.valueOf(JSON.serialize(body).length()));
        Http http = new Http();
        HTTPResponse res = http.send(req);
        system.debug(res.getBody());
        Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        if(res.getStatusCode() == 200){
            Map<String,Object> externalURLMap= (Map<String,Object>)jsonMap.get('d');
            String strExternalUrl = String.valueOf(externalURLMap.get('CreateAnonymousLink'));
            system.debug(strExternalUrl);
            return strExternalUrl;
        }else{
            return '';
        }
        }
        catch(exception e) {
            System.debug(e.getMessage());
            System.debug(e);
            return null;
        }
    }
}