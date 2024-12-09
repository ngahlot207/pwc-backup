global class DemoDMSBatchDuplicate implements Database.Batchable<sobject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {
		List<ContentDocumentLink> cdlList =  [SELECT Id, ContentDocumentId FROM ContentDocumentLink where LinkedEntityId = 'a0GC4000000XEPBMA4'];
		String cdId = cdlList[0].ContentDocumentId;
        return Database.getQueryLocator('SELECT Id, Title, VersionData, ContentSize, FileExtension FROM ContentVersion WHERE ContentDocumentId =: cdId');
    }
	
	global void execute(Database.BatchableContext BC, List<ContentVersion> conVer) {
		ContentVersion cv = conVer[0];
		Integer contSize = cv.ContentSize;
		Integer contSizeLimit = 3500000;
		
        //List<ContentVersion> parts = new List<ContentVersion>();

		if(contSize > contSizeLimit) {
            Integer index = 0;
            System.enqueueJob(new DMSDemoQueuClass(cv.Id, index, cv.FileExtension));
            
            /*
			Integer totalParts = (contSize + contSizeLimit - 1) / contSizeLimit;

            if(totalParts > 1) {
                for(Integer i = 0; i < totalParts; i++) {
                    Integer offset = i * contSizeLimit;
                    Integer length = Math.min(contSizeLimit, contSize - offset);
                    Blob conBlob = Blob.valueOf(EncodingUtil.base64Encode(cv.VersionData).mid(offset, length));

                    //create new ContentVersion record
                    ContentVersion part = new ContentVersion();
                    part.Title = cv.Title + '_part' + (i+1);
                    part.PathOnClient = cv.Title + '_part' + (i+1);
                    part.VersionData = conBlob;
                    parts.add(part);
                }
            }
			*/
		}
		/*
        if(!parts.isEmpty()) {
            
            for(ContentVersion cvTemp : parts) {
                // Enqueue the Queueable job and pass parameters
                System.enqueueJob(new DMSDemoQueuClass(cvTemp, '.pdf'));
            }
			
            //Integer index = 0;
            //System.enqueueJob(new DMSDemoQueuClass(parts, '.pdf', index));
        }
		*/
	}
	
	global void finish(Database.BatchableContext BC) {
        // Perform any post-processing tasks if needed
    }
}