public class AllowedFileTypeToUploadOnCV implements TriggerAction.BeforeInsert{
    
    public static void BeforeInsert(List<ContentVersion> newList){       
        try{           
            // Define a list of file types where you want to throw an error           
            List<String> allowedFileTypes = system.label.AllowedDocumentTypes.split(',');         
            //  Set<String> allowedFileTypes = ststem.parse system.label.AllowedDocumentTypes;
            List<ContentVersion> invalidContentVersions = new List<ContentVersion>();           
            // Iterate through the ContentVersions being inserted
            for (ContentVersion cv : newList) {
                // Check if the file type is in the restricted list                
                List<String> parts = cv.PathOnClient.split('\\.');
                String docType = parts[1];
                System.debug('File extension name : ' +docType);              
                if (!allowedFileTypes.contains(docType)) {
                    // Add invalid ContentVersion to list
                    invalidContentVersions.add(cv);
                }
            }            
            // If there are invalid ContentVersions, throw an error
            if (!invalidContentVersions.isEmpty()) {
                for (ContentVersion invalidCV : invalidContentVersions) {
                    List<String> part = invalidCV.PathOnClient.split('\\.');
               		 String docTypeIS = part[1];
                    System.debug('File type ' + docTypeIS + ' is not allowed.' );
                    invalidCV.addError('File type ' + docTypeIS + ' is not allowed.');
                }
            }
            
            
        }catch (Exception e){
            System.debug('An exception occurred: ' + e.getMessage() + ' \n' + 'line number==>'+ e.getLineNumber()
                         +'\nstack tracke '+ e.getStackTraceString() +'\n'+e.getCause() );
        }
    }
}