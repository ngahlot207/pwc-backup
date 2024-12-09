public class DMSDemoQueuClass implements Queueable, Database.AllowsCallouts {
    private Id cvId;
    //private List<ContentVersion> cvList;
    Private String fileExt;
    Private Integer index;

    // Constructor to accept parameters
    public DMSDemoQueuClass(Id cvId, Integer index, String fileExt) {
        //this.cvList = cvList;
        this.fileExt = fileExt;
        this.index = index;
        this.cvId = cvId;
    }

    public void execute(QueueableContext context) {
        
        if(cvId != NULL) {
            Integer contSizeLimit = 3500000;
            List<ContentVersion> cvList = [SELECT Id, Title, VersionData, ContentSize, FileExtension FROM ContentVersion WHERE Id =: cvId];
            
			Integer contSize = cvList[0].ContentSize;
            Integer totalParts = (contSize + contSizeLimit - 1) / contSizeLimit;
            if(index < totalParts) {
                String folderName = 'FedFolder';
                Integer offset = index * contSizeLimit;
                Integer length = Math.min(contSizeLimit, contSize - offset);
                System.debug('offset - '+offset);
                System.debug('length - '+length);
                
                //part.Title = cv.Title + '_part' + (i+1);
                String fileName = EncodingUtil.urlEncode(cvList[0].title +'_part' + (index + 1) + '.' + fileExt, 'UTF-8');
                System.debug('File Part Name - '+ fileName);
                
                HttpRequest req = new HttpRequest();
                String endPointUrl = 'callout:SharePoint';
                endPointUrl = endPointUrl+'/_api/web/GetFolderByServerRelativeUrl(';
                endPointUrl = endPointUrl+'\'/sites/FedSaleForce_UAT/Shared%20Documents/'+folderName+'\')';
                endPointUrl = endPointUrl+'/Files/AddUsingPath(decodedurl=\''+fileName+'\',overwrite=true)';
                req.setEndpoint(endPointUrl);
                req.setMethod('POST');
                req.setHeader('Content-Type','application/octet-stream');
                req.setHeader('X-RequestDigest', '{form_digest_value}');
                req.setBodyAsBlob(Blob.valueOf(EncodingUtil.base64Encode(cvList[0].VersionData).mid(offset, length)));
                Http http = new Http();
                HTTPResponse res = http.send(req);
                index++;
                
                System.enqueueJob(new DMSDemoQueuClass(cvId, index, fileExt));
            }
        }
        /*
        if(index < cvList.size()) {
            String folderName = 'DummyFolder';
        	String fileName = EncodingUtil.urlEncode(cvList[index].title+'.'+fileExt, 'UTF-8');
            
            HttpRequest req = new HttpRequest();
            String endPointUrl = 'callout:SharePoint';
            endPointUrl = endPointUrl+'/_api/web/GetFolderByServerRelativeUrl(';
            endPointUrl = endPointUrl+'\'/sites/FedSaleForce_UAT/Shared%20Documents/'+folderName+'\')';
            endPointUrl = endPointUrl+'/Files/AddUsingPath(decodedurl=\''+fileName+'\',overwrite=true)';
            req.setEndpoint(endPointUrl);
            req.setMethod('POST');
            req.setHeader('Content-Type','application/octet-stream');
            req.setHeader('X-RequestDigest', '{form_digest_value}');
            req.setBodyAsBlob(Blob.valueOf(EncodingUtil.base64Encode(cvList[index].VersionData)));
            Http http = new Http();
            HTTPResponse res = http.send(req);
            index++;
            
            System.enqueueJob(new DMSDemoQueuClass(cvList, '.pdf', index));
        }
        */
    }
}