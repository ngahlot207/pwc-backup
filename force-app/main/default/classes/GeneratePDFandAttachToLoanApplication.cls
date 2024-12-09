public class GeneratePDFandAttachToLoanApplication {

    @auraEnabled
    public static string generateDocument(DocGenWrapper wrapObj){
        try {
            
            //URL Format /apex/ContactDataPDF?id='+contactId
            PageReference pdf = new pagereference(wrapObj.pageUrl);
            
         
            Blob body;
            
            // returns page as a PDF
            if(!Test.IsRunningTest()){
            body = pdf.getContent();
            }
 
            //insert content version
            ContentVersion CV = new ContentVersion();
            CV.Title = wrapObj.fileName;
            CV.PathOnClient = wrapObj.fileName;
            CV.VersionData = body;
            CV.FirstPublishLocationId = wrapObj.docDetailId;
            insert CV;
            return 'success';
        }catch (Exception ex) {
            
            return ex.getMessage();
        }
    }
    
    public class DocGenWrapper{
        
        
        @auraEnabled public String pageUrl{get;set;}
        @auraEnabled public String fileName{get;set;}
        @auraEnabled public String docDetailId{get;set;}
    }
}