public class SharePointUploader {

    private final String sharepointSiteUrl = 'https://yourtenant.sharepoint.com/sites/yoursite';
    private final String accessToken = 'your_access_token'; // You need to get this using OAuth 2.0

    @future(callout=true)
    public static void uploadLargeFile(Id contentDocumentId) {
        // Get the file from Salesforce
        ContentVersion contentVersion = [SELECT VersionData, Title, PathOnClient FROM ContentVersion WHERE ContentDocumentId = :contentDocumentId LIMIT 1];
        
        // Convert the file to a Blob
        //Blob fileBlob = contentVersion.VersionData;
        String fileBlob = contentVersion.VersionData.toString();
        String fileName = contentVersion.Title;

        // Split the file into chunks
        Integer chunkSize = 5 * 1024 * 1024; // 5 MB chunk size
        Integer fileSize = fileBlob.length();
        Integer totalChunks = (Integer)Math.ceil(fileSize / chunkSize);
        
        for (Integer i = 0; i < totalChunks; i++) {
            Integer startPosition = i * chunkSize;
            Integer endPosition = (i + 1) * chunkSize;
            if (endPosition > fileSize) {
                endPosition = fileSize;
            }

            ///Blob fileChunk = fileBlob.substring(startPosition, endPosition);
			Blob fileChunk = Blob.valueOf(fileBlob.substring(startPosition, endPosition));
            // Upload the chunk
            uploadChunk(fileChunk, fileName, i, totalChunks);
        }
    }

    //@future(callout=true)
    private static void uploadChunk(Blob fileChunk, String fileName, Integer chunkIndex, Integer totalChunks) {
        // Construct the SharePoint REST API endpoint
        //String uploadUrl = 'https://yourtenant.sharepoint.com/sites/yoursite/_api/web/getfolderbyserverrelativeurl(\'/Shared Documents\')/Files/Add(url=\'' + fileName + '\',overwrite=true)';
		String uploadUrl = 'callout:SharePoint' + '/_api/web/getfolderbyserverrelativeurl(\'/sites/FedSaleForce_UAT/Shared%20Documents/'+'Test_Folder_July_2024'+'\'))/Files/Add(url=\'' + 'testSplitFile.pdf' + '\',overwrite=true)';	
        HttpRequest req = new HttpRequest();
        req.setEndpoint(uploadUrl);
        req.setMethod('POST');
        //req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Accept', 'application/json;odata=verbose');
        req.setHeader('Content-Type', 'application/octet-stream');
        req.setBodyAsBlob(fileChunk);

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() != 201) {
            System.debug('Error uploading chunk ' + chunkIndex + ' of ' + totalChunks + ': ' + res.getBody());
        }
    }
}