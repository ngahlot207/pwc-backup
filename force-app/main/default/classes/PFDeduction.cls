public class PFDeduction {
	transient public String recordId{get;set;}
    transient public String CurrentDate{get;set;}
    transient public string Place{get;set;}
     transient public Decimal LoanAmount{get;set;}
     transient public Decimal LoanAmount1{get;set;}
    public String rupeeInWord{get;set;}
    transient public String ApplicantName{get;set;}
    transient public String COApplicantName{get;set;}
    transient public Decimal processingFess{get;set;}
	public String processingFessrupeeInWord{get;set;}    
    transient public String CurrentDateTime{get;set;}
    transient public String heading{get;set;}
     public PFDeduction(){
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
            setDateTime();
        }
    }
    
     public void setDateTime()
    {
        DateTime dt = Datetime.now(); 
        CurrentDate=system.Now().format('dd-MMM-yyyy');
        CurrentDateTime=system.Now().format('dd-MMM-yyyy')+', '+system.Now().format('h:mm a');
       
    }
     public void getloanDetails(string recordId){
        list<Applicant__c>  App=[Select id,LoanAppln__r.Product__c,FullName__c,Age__c,ApplType__c,LoanAppln__r.ReqLoanAmt__c, LoanAppln__r.IMD_GSTAmt__c,LoanAppln__r.BrchName__c, LoanAppln__r.TotalLoanAmtInclInsurance__c from Applicant__c where LoanAppln__c=:recordId AND (ApplType__c='P') limit 1];
           if(!App.isEmpty()){
         ApplicantName=App[0].FullName__c!=NULL?String.valueOf(App[0].FullName__c):'';
        LoanAmount=App[0].LoanAppln__r.ReqLoanAmt__c;
        LoanAmount1=App[0].LoanAppln__r.TotalLoanAmtInclInsurance__c; //LAK-9343
        Place=App[0].LoanAppln__r.BrchName__c!=NULL?String.valueOf(App[0].LoanAppln__r.BrchName__c):'';
        //        if(LoanAmount!=null){
        //  rupeeInWord = NumberToStringConverter.convertToWords(Integer.valueOf(LoanAmount));
        //        }
               if(LoanAmount1!=null){
                rupeeInWord = NumberToStringConverter.convertToWords(Integer.valueOf(LoanAmount1));
                      }
               
                list<LonaApplCharges__c > LoanCharge=[select id,ChargeCodeDesc__c, Amount__c from LonaApplCharges__c where ChargeCodeDesc__c ='PF RECD FRM CUST-IRR-NDED' and LoanApplication__c =:recordId ];
     	if(!LoanCharge.isEmpty()){
          decimal  processingFess1=LoanCharge[0].Amount__c !=null ?  LoanCharge[0].Amount__c : 0;
            decimal  processingFess2=App[0].LoanAppln__r.IMD_GSTAmt__c !=null ?  App[0].LoanAppln__r.IMD_GSTAmt__c : 0;
            system.debug('processingFessprocessingFess1'+processingFess1);
			system.debug('processingFessprocessingFess2'+processingFess2);

            if(App[0].LoanAppln__r.Product__c=='Loan Against Property' || App[0].LoanAppln__r.Product__c=='Home Loan' || App[0].LoanAppln__r.Product__c=='Small Ticket LAP'){
            	processingFess=LoanCharge[0].Amount__c;
                
            }else{
               processingFess=processingFess1+processingFess2;
                heading='Processing Fee(PF) Deduction Letter';
            }
            system.debug('processingFessprocessingFess'+processingFess);
        //processingFess=LoanCharge[0].Amount__c;
              if(processingFess!=null){
         processingFessrupeeInWord = NumberToStringConverter.convertToWords(Integer.valueOf(processingFess));
               }
        }
            
         list<Applicant__c>  CoApp=[Select id,FullName__c,Age__c,ApplType__c,LoanAppln__r.ReqLoanAmt__c,LoanAppln__r.BrchName__c from Applicant__c where LoanAppln__c=:recordId AND (ApplType__c='C') limit 1];
          if(!CoApp.isEmpty()){
               COApplicantName=CoApp[0].FullName__c!=NULL?String.valueOf(CoApp[0].FullName__c):'';
          }
           }}
}