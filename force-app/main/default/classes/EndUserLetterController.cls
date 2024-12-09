public class EndUserLetterController {
	transient public String recordId{get;set;}
    transient public String header{get;set;}
    transient public String todaysDate{get;set;}
     transient public String CurrentDate{get;set;}
    transient public String ApplicantName{get;set;}
    transient public String LoanNumber{get;set;}
    transient public String loginAcceptance{get;set;}
    transient public String LoanPurpose{get;set;}
    transient public Map<integer,String> mapofContent{get;set;}
    transient public String CurrentDateTime{get;set;}
    transient public boolean showTable{get;set;}
    public List<Applicant__c> applicantList { get; set; }
    transient public String Subject{get;set;}
    
    public EndUserLetterController(){
         // recordId = loanApplicationId;
        recordId=ApexPages.currentPage().getParameters().get('recordId');
        if(recordId==null)
        {
            //recordId='a08C40000083Lt0IAE';
             recordId = ApexPages.currentPage().getParameters().get('Id');
        }
        if(recordId!=null)
        {
         setDateTime(); 
          getloanDetails(recordId);  
            getMetadataforContent();
            applicantList = [SELECT id, FullName__c, tolabel(ApplType__c) FROM Applicant__c
            WHERE LoanAppln__c = :recordId AND (ApplType__c = 'C' OR ApplType__c = 'P' OR ApplType__c = 'G')];
             system.debug('applicantListapplicantList'+applicantList);
            
             
        }
    }
    
     public void setDateTime()
    {
        DateTime dt = Datetime.now();
        CurrentDateTime=system.Now().format('dd-MMM-yyyy')+', '+system.Now().format('h:mm a');
        CurrentDate=system.Now().format('dd-MMM-yyyy');
        system.debug('CurrentDate'+CurrentDate);
    }
    public void getloanDetails(string recordId){
        Applicant__c  App=[Select id,FullName__c,ApplType__c,LoanAppln__r.Name,LoanAppln__r.LoanPurpose__c,LoanAppln__r.LoginAcceptDate__c, LoanAppln__r.Product__c from Applicant__c where LoanAppln__c=:recordId AND (ApplType__c='P') limit 1];
        if(App.LoanAppln__r.Product__c=='Loan Against Property' || App.LoanAppln__r.Product__c=='Home Loan' || App.LoanAppln__r.Product__c=='Small Ticket LAP'){
            showTable=false;
            Subject='Application for loan facility for ancillary purpose';
        }else{
            showTable=true;
            Subject='Application for '+App.LoanAppln__r.Product__c;
        }
        ApplicantName=App.FullName__c;
        	LoanNumber=App.LoanAppln__r.Name;
       // loginAcceptance=String.valueof(App.LoanAppln__r.LoginAcceptDate__c.format('dd-MMM-yyyy'));
         if(App.LoanAppln__r.LoginAcceptDate__c!=null){
        loginAcceptance=DateTime.newInstance(App.LoanAppln__r.LoginAcceptDate__c.year(),App.LoanAppln__r.LoginAcceptDate__c.month(), App.LoanAppln__r.LoginAcceptDate__c.day()).format('dd-MMM-yyyy');
         
    }
        
        LoanPurpose=App.LoanAppln__r.LoanPurpose__c;
        system.debug('LoanNumber'+LoanNumber);
    }
    public void getMetadataforContent()
    {
               mapofContent=new Map<integer,String>();
        
        
        for(PDF_Generation_Metadata__mdt pdfObj:[select id,Content_Order__c,Content__c,Page_Number__c,Region_Picklist__c,Document_Type__c,Product_Type__c from PDF_Generation_Metadata__mdt where Document_Type__c='End User Letter'  ORDER BY Content_Order__c DESC])
        {
            if(pdfObj.Content_Order__c>0){
                mapofContent.put(integer.valueof(pdfObj.Content_Order__c),pdfObj.Content__c);
            }
        }}
}