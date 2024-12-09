public class LoanAgreementDynamicController {
	transient public String recordId{get;set;}
    transient public String ApplicantName{get;set;}
    transient public string loanApplicationId{get;set;}
    
     public LoanAgreementDynamicController(){         
        recordId=ApexPages.currentPage().getParameters().get('recordId');
        if(recordId==null)
        {
            //recordId='a08C40000083Lt0IAE';
             recordId = ApexPages.currentPage().getParameters().get('Id');
        }
        if(recordId!=null)
        {
         
          getloanDetails(recordId);  
            
        }
    }
    
     public void getloanDetails(string recordId){
        Applicant__c  App=[Select id,FullName__c,ApplType__c,LoanAppln__r.Name from Applicant__c where LoanAppln__c=:recordId AND (ApplType__c='P') limit 1];
            ApplicantName=App.FullName__c;
         	//ApplicationFormNo=App.LoanAppln__r.Name;
        	
       
    }
}