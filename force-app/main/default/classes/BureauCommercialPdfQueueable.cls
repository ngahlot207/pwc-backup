public class BureauCommercialPdfQueueable implements Queueable {
    
    private List<integer> pdfvalues;
    private string applicantid;
    
    public BureauCommercialPdfQueueable(List<integer> values,string refid){
        this.pdfvalues=values;
        this.applicantid=refid;
    }
    
    public void execute(QueueableContext context){
        
        try{
            
            if(!string.isblank(applicantid) && pdfvalues!=null){
                
                Bureau__c Bureau = [SELECT Id,LoanApp__c,Applicant__c,LoanApp__r.Product__c,IsLatest__c,BureauAPI__c FROM Bureau__c WHERE Applicant__c =:applicantid AND IsLatest__c = true AND BureauAPI__c='Commercial'];
                
                DocMstr__c docmap =[Select id,DocTyp__c,Prod__c,Catgry__c from DocMstr__c Where DocTyp__c='Bureau Report' 
                                    AND Catgry__c='Bureau Report' AND Prod__c=:Bureau.LoanApp__r.Product__c];
               	system.debug('docmap'+docmap);
                string DocDtlId;
                //Creating Bureau PDF
                system.debug('pdfvalue'+pdfvalues);
                if(pdfvalues!=null){ 
                    
                    DocDtl__c doc = new DocDtl__c();
                    doc.Appl__c=applicantid;
                    doc.LAN__c=Bureau.LoanApp__c;
                    doc.DocMstr__c=docmap.Id;
                    doc.DocCatgry__c='Bureau Report';
                    doc.DocTyp__c='Bureau Report';
                    doc.DocSubTyp__c='Bureau Report';
                    Insert doc;
                    
                    DocDtlId=doc.Id;
                    
                    
                    List<Integer> values = pdfvalues;
                    
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
                    
                    string hexval=String.join(hexValues,'');
                    Blob result = EncodingUtil.convertFromHex(hexval);
                    
                    
                    ContentVersion contentVersion = new ContentVersion();
                    contentVersion.VersionData = result;//fileData;
                    contentVersion.Title = 'Report';
                    contentVersion.PathOnClient = 'Report.pdf';
                    contentVersion.FirstPublishLocationId = doc.Id;
                    insert contentVersion;
                    
                    /*Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id LIMIT 1].ContentDocumentId;
                    
                    ContentDocumentLink contentLink = new ContentDocumentLink();
                    contentLink.ContentDocumentId = contentDocumentId;
                    contentLink.LinkedEntityId=DocDtlId;
                    contentLink.ShareType = 'V';
                    insert contentLink;*/
                    
                    Bureau.DocDetail__c=DocDtlId!=null?DocDtlId:'';
                    update Bureau;
                    
                }
                
                if(Bureau.LoanApp__c!=null){
                    
                    IntgMsg__c intmsg =new IntgMsg__c();
                    intmsg.Name='Crif Auth Login';
                    intmsg.BU__c='HL / STL';
                    intmsg.RefId__c=Bureau.LoanApp__c;
                    intmsg.Status__c='New';
                    intmsg.MStatus__c='Blank';
                    intmsg.RefObj__c='LoanAppl__c';
                    intmsg.Svc__c='Crif Auth Login';
                    intmsg.IsActive__c=true;
                    
                    insert intmsg;
                }                
            }
            
        }catch(Exception ex){
            system.debug('ex'+ex);
            GlobalUtility.logMessage('Error', 'BureauCommercialPdfQueueable class', 
                                     'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        
        
    }
    
}