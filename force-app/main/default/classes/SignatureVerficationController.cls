public without sharing class SignatureVerficationController {
	transient public String CurrentDateTime1{get;set;}
    transient public String CurrentDate{get;set;}
    public LoanAppl__c loanApplRec { get; set; }
    transient public String recordId{get;set;}
    transient public List<string> oneCoName{get;set;}
    transient public List<string> moreCoName{get;set;}
    transient public String appliName{get;set;}
    transient public String coappliName{get;set;}
    transient public list<NameWrapper> nameWrapperList { get; set; }
    
    
    public SignatureVerficationController(){
        DateTime dt = Datetime.now();
        DateTime currentDateTimePlus30Days = dt.addDays(30);
        CurrentDateTime1=system.Now().format('dd-MMM-yyyy')+', '+system.Now().format('h:mm a');
        CurrentDate = system.Now().format('dd-MMM-yyyy');
        recordId=ApexPages.currentPage().getParameters().get('recordId');
        if(recordId==null){
            recordId = 'a08C40000082ahBIAQ'; 
        }
      	loanApplRec= [select id,city__c,TotalOwnContri__c,IsConstruction__c,SchmCode__c,Rate_Type_Floating_Flag__c,ProductSubType__c,EMIIcludingInsurance__c, Name,ReqLoanAmt__c,Loan_Tenure_Months__c,PropertyIdentified__c, Formatted_Login_Acceptance_Date__c, Product__c, BrchCode__c, BrchName__c, RMSMName__r.Name, RMSMEmployeeID__c, ChannelName__c, ChannelCode__c,ChanelNme__r.name, LoanPurpose__c  from LoanAppl__c where id=:recordId LIMIT 1];
      	List<Applicant__c> coApplicantList = [SELECT id, FullName__c, ApplType__c FROM Applicant__c WHERE LoanAppln__c = :recordId AND (ApplType__c = 'C' OR ApplType__c = 'G')];
        List<Applicant__c> ApplicantList = [SELECT id, FullName__c, ApplType__c FROM Applicant__c WHERE LoanAppln__c = :recordId AND ApplType__c = 'P'];
        appliName=ApplicantList[0].FullName__c;
        list<NameWrapper> namewrapperList1=new list<NameWrapper>();
        if(coApplicantList.size()>0){
            for (Applicant__c applicant : coApplicantList) {
                if(applicant.FullName__c !=null && applicant.FullName__c != ''){
                    if(coappliName ==null || coappliName == ''){
                        coappliName=applicant.FullName__c;
                    }else{
                        NameWrapper newrec=new NameWrapper();
                       newrec.name=applicant.FullName__c;
                       namewrapperList1.add(newrec);
                    }
                    
                }
        		
            }
            nameWrapperList=namewrapperList1;
            system.debug('nameWrapperList'+nameWrapperList);
        }
        
   }
    class NameWrapper {
        public string name { get; set; }
    }
}