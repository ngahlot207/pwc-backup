public class CustomFileUploadController {
     @AuraEnabled(cacheable=false)
    public static Id createAccountWithFile(ContentVersion file) {
        try {
          //  Contact newAccount = new Contact(LastName = 'New  test contact',AccountId='001C4000008VFXHIA4'); // You can customize the account fields
			//insert newAccount;

            // Attach the file as Note and Attachment to the Account
            ContentNote note = new ContentNote();
            note.Title = 'Uploaded File';
            insert note;

            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :file.Id].ContentDocumentId;
            cdl.LinkedEntityId = '003C4000007bVvFIAU';
            cdl.ShareType = 'I';
            insert cdl;

            return null;
        } catch (Exception e) {
            return null;
        }
    }
    /*
@AuraEnabled
    public static List<Account> saveFiles(List<WrapperClassForFileUpd> uploadFl) {
        List<Account> docList = new List<Account>();
      
            for (WrapperClassForFileUpd fileUpd : uploadFl) {
                List<String> fileNames = fileUpd.fileNames;
                List<String> fileContents = fileUpd.fileContents;
                List<String> fileID = fileUpd.fileID;
                List<String> fileType = fileUpd.fileType;
               try { for (Integer i = 0; i < fileNames.size(); i++) {
                    Account file = new Account();
                    file.Name = fileNames[i];
                    file.Content__c = EncodingUtil.base64Encode(Blob.valueOf(fileContents[i]));
                    file.URL__c = '/sfc/servlet.shepherd/document/download/' +fileID[i];
                    file.File_Type__c = fileType[i];
                    file.File_Id__c = fileID[i];
                    file.Document_Id__c = fileID[i];
                    docList.add(file);
                }
            }
                catch (Exception e) {
            System.debug('An error occurred while saving files: ' + e.getMessage());
            throw e;
        }
            if (!docList.isEmpty()) {
                insert docList;
            }
          system.debug('docList'+docList);
        } 
         return docList; 
    }

    public class WrapperClassForFileUpd {
        @AuraEnabled
        public List<String> fileNames { get; set; }

        @AuraEnabled
        public List<String> fileContents { get; set; }
        
        @AuraEnabled
        public List<String> fileID { get; set; }
        
        @AuraEnabled
        public List<String> fileType { get; set; }
    }
*/
}