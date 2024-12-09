public class AadharConsentController {
	transient public String recordId{get;set;}
    transient public String ApplicantName{get;set;}
    transient public Map<integer,String> mapofContent{get;set;}
    
     public AadharConsentController(){
          //recordId = 'a08C4000008MvClIAK';
        recordId=ApexPages.currentPage().getParameters().get('recordId');
        if(recordId==null)
        {
            //recordId='a08C40000083Lt0IAE';
             recordId = ApexPages.currentPage().getParameters().get('Id');
        }
        if(recordId!=null)
        {          
          getloanDetails(recordId); 
            getMetadataforContent();
            
        }
    }
    
    public void getloanDetails(string recordId){
       // Applicant__c  App=[Select id,FullName__c,ApplType__c from Applicant__c where LoanAppln__c=:recordId AND (ApplType__c='P') limit 1];
        Applicant__c  App=[Select id,FullName__c,ApplType__c from Applicant__c where id=:recordId  limit 1];
        
            ApplicantName=App.FullName__c;
        	//FinnoneNumber=App.LoanAppln__r.Finnone_Loan_Number__c;
        system.debug('ApplicantName'+ApplicantName);
    }
    public void getMetadataforContent()
    {
               mapofContent=new Map<integer,String>();
        
        
        for(PDF_Generation_Metadata__mdt pdfObj:[select id,Content_Order__c,Content__c,Page_Number__c,Region_Picklist__c,Document_Type__c,Product_Type__c from PDF_Generation_Metadata__mdt where Document_Type__c='Aadhar Consent Letter'  ORDER BY Content_Order__c DESC])
        {
            if(pdfObj.Content_Order__c>0){
                mapofContent.put(integer.valueof(pdfObj.Content_Order__c),pdfObj.Content__c);
            }
        }}
}