public class testPdf implements IintMsgCalloutResponseProcessor{
    
    
     public static void process(List<IntgMsg__c> responses) {
        
        
        List<Id> ids = new List<Id>();
        
        for (IntgMsg__c integrationMessage : responses) {
            ids.add(integrationMessage.Id);
        }
         
         
         ContentDocumentLink cdlList = [SELECT ContentDocumentId FROM ContentDocumentLink
                                       WHERE LinkedEntityId = :ids
                                       AND ContentDocument.Title = 'response.json' LIMIT 1];//response.json
        
        
        ContentVersion contentVersion = [SELECT Id, VersionData,FileType FROM ContentVersion
                                         WHERE ContentDocumentId = :cdlList.ContentDocumentId LIMIT 1];
         
         
         
         
          try{
            if (contentVersion != null) {
                String jsonContent = contentVersion.VersionData.toString();
                
                 string jsonStr=jsonContent.replace('JSON-RESPONSE-OBJECT','JSONResponseObject').replace('ENCODED STRING','ENCODEDSTRING');
               ConsumerIssueResponseWrapper res  = (ConsumerIssueResponseWrapper) JSON.deserialize(jsonStr, ConsumerIssueResponseWrapper.class);
                
                System.debug('Id'+res.FINISHED[0].ENCODEDSTRING);
                
                ContentVersion cv = new ContentVersion();
                cv.VersionData = EncodingUtil.base64Decode(res.FINISHED[0].ENCODEDSTRING);
                cv.Title = 'BureauEncodeString';
                cv.PathOnClient = 'BureauEncodeString.pdf';
                cv.FirstPublishLocationId = responses[0].Id;
                insert cv;
                
            }
        }
        catch(Exception ex){
            GlobalUtility.logMessage('Error', 'testPdf class', 
                                     'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }	
         
         
     }

}