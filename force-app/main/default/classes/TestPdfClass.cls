public class TestPdfClass implements Queueable {
    private String jsonString;
    
    public TestPdfClass(String jsonString) {
        
        this.jsonString = jsonString;
    }
    
  /*  public void execute(QueueableContext context) {
        
        try {
            List<Integer> pdfData = extractPdfDataFromJson(jsonString);
            
            String encodedString = String.fromCharArray(pdfData);
            Blob htmlBlob = EncodingUtil.base64Decode(encodedString);
            
            
            
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.VersionData = htmlBlob;
            contentVersion.Title = 'HTML Report';
            contentVersion.PathOnClient = 'HTML_Report.pdf';
            insert contentVersion;
            
            system.debug('contentVersion'+contentVersion);
            
            Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id LIMIT 1].ContentDocumentId;
            
            ContentDocumentLink contentLink = new ContentDocumentLink();
            contentLink.ContentDocumentId = contentDocumentId;
            contentLink.LinkedEntityId='a0nC400000047J3IAI';
            contentLink.ShareType = 'V';
            insert contentLink;
            
            system.debug('contentLink'+contentLink);
            
            
        } catch (Exception e) {
            System.debug('Exception in PdfGenerationQueueable: ' + e.getMessage()+ ' line ' + e.getLineNumber());
        }
    }*/
    
    public void execute(QueueableContext context){
        ContentDocumentLink cdlList =  [SELECT Id, LinkedEntityId,ContentDocumentId,ContentDocument.FileType FROM
                                        ContentDocumentLink where LinkedEntityId ='a0GC4000000VsTxMAK' ORDER BY SystemModstamp DESC  LIMIT 1 ];
        
        ContentVersion verData = [SELECT VersionData,ContentDocumentId,FileType,FileExtension FROM ContentVersion 
                                  where ContentDocumentId = :cdlList.ContentDocumentId];
        
        String jsonResponse= verData.VersionData.toString().replace('PDF REPORT','PDF_REPORT');
        system.debug(jsonResponse); 
        
        TestingAPI.response res =  (TestingAPI.response) JSON.deserialize(jsonResponse,TestingAPI.response.class);           
        system.debug(res); 
        
        List<Integer> values = res.PDF_REPORT;
		String encodedString = String.fromCharArray(values);
        system.debug(encodedString);
		Blob fileData = Blob.valueOf(encodedString);//EncodingUtil.base64Decode(encodedString);//
        System.debug('fileData'+fileData);
        /*Attachment att = new Attachment();
        att.ParentId = 'a0GC4000000PtNtMAK';
        att.Body = fileData;
        att.Name = 'Response.Pdf';
        insert att;*/
        
        
		//Integer[] values = new Integer[]{-33, 103, -48, -46, 113, ...};
        // Buffer
        String[] hexValues = new String[0];
        // Hex lookup
        String[] hex = '0123456789abcdef'.split('');
        for(Integer byteValue: values) {
            // Isolate bits 4-7: (240) 0xF0 is the mask
            // Divide by 16 (shift right 4 bits)
            Integer highNybble = (byteValue & 240) >> 4;
            // Isolate bits 0-3 (15) 0x0F is the mask
            Integer lowNybble = byteValue & 15;
            // Write high and low 
            hexValues.add(hex[highNybble]);
            hexValues.add(hex[lowNybble]);
        }
        Blob result = EncodingUtil.convertFromHex(String.join(hexValues,''));
        System.debug(result);

		
        
        ContentVersion contentVersion = new ContentVersion();
            contentVersion.VersionData = result;//fileData;
            contentVersion.Title = 'Report';
            contentVersion.PathOnClient = 'Report.pdf';
            insert contentVersion;
            
            system.debug('contentVersion'+contentVersion);
            
            Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id LIMIT 1].ContentDocumentId;
            
            ContentDocumentLink contentLink = new ContentDocumentLink();
            contentLink.ContentDocumentId = contentDocumentId;
            contentLink.LinkedEntityId='a0GC4000000PtNtMAK';
            contentLink.ShareType = 'V';
            insert contentLink;
            
            system.debug('contentLink'+contentLink);
    }
    
   /* public void execute(QueueableContext context){
        ContentDocumentLink cdlList =  [SELECT Id, LinkedEntityId,ContentDocumentId,ContentDocument.FileType FROM
                                        ContentDocumentLink where LinkedEntityId ='a0GC4000000WtFtMAK' ORDER BY SystemModstamp DESC  LIMIT 1 ];
        
        ContentVersion verData = [SELECT VersionData,ContentDocumentId,FileType,FileExtension FROM ContentVersion 
                                  where ContentDocumentId = :cdlList.ContentDocumentId];
        
        string jsonString=verData.VersionData.toString();
        
        Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
            
            string htmlResponse;
            
           // if (jsonMap.containsKey('FINISHED')) {
               // List<object> finishedList =(List<object>) jsonMap.get('FINISHED');
                
                // if (!finishedList.isEmpty()) {
                    //Map<String, Object> finishedMap = (Map<String, Object>)finishedList[0];
                     if (jsonMap.containsKey('HTML REPORT')) {
                         htmlResponse=string.valueof(jsonMap.get('HTML REPORT')).unescapejava();
                     }
                 //}
            //}
            
       //// system.debug('html:::'+htmlResponse);
             Blob htmlBlob = Blob.valueOf(htmlResponse);//.unescapejava());
            
                ContentVersion contentVersion = new ContentVersion();
                contentVersion.VersionData = htmlBlob;
                contentVersion.Title = 'HTML Report';
                contentVersion.PathOnClient = 'HTML_Report.pdf';
                insert contentVersion;
            
             Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id LIMIT 1].ContentDocumentId;
            
               ContentDocumentLink contentLink = new ContentDocumentLink();
               contentLink.ContentDocumentId = contentDocumentId;
               contentLink.LinkedEntityId='a0nC400000047J3IAI';
               contentLink.ShareType = 'V';
               insert contentLink;
    }*/
    
    private List<Integer> extractPdfDataFromJson(String jsonString) {
        List<Integer> values = new List<Integer>();
        
        try {
            Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
            
            if (jsonMap.containsKey('FINISHED')) {
                List<Object> finishedList = (List<Object>) jsonMap.get('FINISHED');
                
                if (!finishedList.isEmpty()) {
                    Map<String, Object> finishedMap = (Map<String, Object>) finishedList[0];
                    
                    if (finishedMap.containsKey('PDF REPORT')) {
                        Object pdfReportValue = finishedMap.get('PDF REPORT');
                        
                        if (pdfReportValue instanceof List<Object>) {
                            
                            for (Object item : (List<Object>) pdfReportValue) {
                                if (item instanceof Integer) {
                                    values.add((Integer)item);
                                }
                               
                            }
                        } else if (pdfReportValue instanceof Integer) {
                            
                            values.add((Integer)pdfReportValue);
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.debug('Exception in extractPdfDataFromJson: ' + e.getMessage() + ' line ' + e.getLineNumber());
        }
        
        return values;
    }
    
}