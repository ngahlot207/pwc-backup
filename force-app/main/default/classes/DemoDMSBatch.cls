global class DemoDMSBatch implements Database.Batchable<sobject>,  Database.AllowsCallouts {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        try {
            List<ContentDocumentLink> cdlList =  [SELECT Id, ContentDocumentId FROM ContentDocumentLink where LinkedEntityId = 'a0GC4000000XEPBMA4'];
   		    /*
            Set<Id> cdIds = new Set<Id>();  
            for(ContentDocumentLink cd : cdlList) {
                cdIds.add(cd.ContentDocumentId);
            }
			
            System.debug('cdIds-'+cdIds);
			*/
            String cdId = cdlList[0].ContentDocumentId;
            //System.debug('Content Document Id - '+ cdId);
            return Database.getQueryLocator('SELECT Id, Title, VersionData, FileExtension FROM ContentVersion WHERE ContentDocumentId =: cdId');
        }
        catch(exception e) {
            System.debug(e);
            return null;
        }
    }
	
	global void execute(Database.BatchableContext BC, List<ContentVersion> conVer) {
        
        try {
            String folderName = 'FedFolderNew';
            String fileName = EncodingUtil.urlEncode(conVer[0].title+'.'+conVer[0].FileExtension, 'UTF-8');
            //String strData = EncodingUtil.base64Encode(conVer[0].VersionData);
            //Blob finalData = Blob.valueOf(strData);
            System.debug('fileName-'+fileName);
            //String fileName = 'demo10.pdf';
            //System.debug('Blob Data - ' +conVer[0].VersionData);
            //System.debug('Data in String -'+EncodingUtil.base64Encode(conVer[0].VersionData));
            //System.debug('Actual Blob Data -'+Blob.valueOf(EncodingUtil.base64Encode(conVer[0].VersionData)));
            HttpRequest req = new HttpRequest();
            String endPointUrl = 'callout:SharePoint';
            endPointUrl = endPointUrl+'/_api/web/GetFolderByServerRelativeUrl(';
            endPointUrl = endPointUrl+'\'/sites/FedSaleForce_UAT/Shared%20Documents/'+folderName+'\')';
            endPointUrl = endPointUrl+'/Files/AddUsingPath(decodedurl=\''+fileName+'\',overwrite=true)';
            System.debug('endPointUrl-'+endPointUrl);
            req.setEndpoint(endPointUrl);
            req.setMethod('POST');
            req.setHeader('Content-Type','application/octet-stream');
            req.setHeader('X-RequestDigest', '{form_digest_value}');
            req.setBody(EncodingUtil.base64Encode(conVer[0].VersionData));
            //req.setBodyAsBlob(finalData);
            Http http = new Http();
            HTTPResponse res = http.send(req);
            system.debug('####File creation response-'+res.getBody());
        }
        catch(exception e) {
            System.debug(e);
        }
		
        System.debug('execute method');
	}
	
	global void finish(Database.BatchableContext BC) {
        // Perform any post-processing tasks if needed
    }
}