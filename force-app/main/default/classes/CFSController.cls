public class CFSController {
	transient public String recordId{get;set;}
     transient public String CurrentDateTime{get;set;}
    transient public String ApplicantName{get;set;}
    transient public list<String> CoApplicantName{get;set;}
    transient public String ApplicationFormNo{get;set;}
    transient public Decimal LoanAmount{get;set;}
    transient public String LoanAccountNo{get;set;}
    transient public string ModeOfRepayment{get;set;}
     transient public Decimal EMI{get;set;}
    transient public List<getRepaymentWrapper> RepaymentWrapper{get;set;}
    
    public CFSController(){
          //recordId = 'a08C4000008MvClIAK';
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
            RepaymentWrapper=RepaymentDetails(recordId);
        }
    }
    
     public void setDateTime()
    {
        DateTime dt = Datetime.now();
        CurrentDateTime=system.Now().format('dd-MMM-yyyy');
       // CurrentDateTime=system.Now().format('dd-MMM-yyyy')+', '+system.Now().format('h:mm a');
      /*  CurrentDate=system.Now().format('dd-MMM-yyyy');
        CurrentDay=dt.day();
        CurrentMonth=dt.format('MMM');
        CurrentYear=dt.year();
        system.debug('CurrentDate'+CurrentDate);*/
    }
     public void getloanDetails(string recordId){
         list<Applicant__c>  CoApp=[Select id,Name,FullName__c,ApplType__c,LoanAppln__r.MoratGraceApplicable__c,LoanAppln__r.MoratGracePeriodMonths__c,LoanAppln__r.EMIIcludingInsurance__c,LoanAppln__r.DueDay__c,LoanAppln__r.FirstEMIDate__c,LoanAppln__r.ReqTenInMonths__c,LoanAppln__r.PFAmount__c,LoanAppln__r.EffectiveROI__c,LoanAppln__r.BrchName__c,LoanAppln__r.Name,LoanAppln__r.ReqLoanAmt__c,LoanAppln__r.Loan_Tenure_Months__c , LoanAppln__r.ExistngFedFinaLoanAccNo__c,LoanAppln__r.Product__c, LoanAppln__r.TotalLoanAmtInclInsurance__c from Applicant__c where LoanAppln__c=:recordId AND (ApplType__c='C') ];
         list<String> CoApplicantName1=new list<String>();
         if(!CoApp.isEmpty()){
              for(Applicant__c CoA: CoApp){
             CoApplicantName1.add(CoA.FullName__c);
              }
         system.debug('CoApplicantName'+CoApplicantName);
         }
         CoApplicantName=CoApplicantName1;
        Applicant__c  App=[Select id,Name,Constitution__c,FullName__c,ApplType__c,LoanAppln__r.RevisedROI__c,LoanAppln__r.LoanPLRRate__c,LoanAppln__r.SpreadID__c,LoanAppln__r.Rate_Type_Floating_Flag__c,LoanAppln__r.LoanPurpose__c,LoanAppln__r.MoratGraceApplicable__c,LoanAppln__r.MoratGracePeriodMonths__c,LoanAppln__r.EMIIcludingInsurance__c,LoanAppln__r.DueDay__c,LoanAppln__r.FirstEMIDate__c,LoanAppln__r.ReqTenInMonths__c,LoanAppln__r.PFAmount__c,LoanAppln__r.EffectiveROI__c,LoanAppln__r.BrchName__c,LoanAppln__r.Name,LoanAppln__r.ReqLoanAmt__c,LoanAppln__r.Loan_Tenure_Months__c , LoanAppln__r.ExistngFedFinaLoanAccNo__c,LoanAppln__r.Product__c, LoanAppln__r.TotalLoanAmtInclInsurance__c from Applicant__c where LoanAppln__c=:recordId AND (ApplType__c='P') limit 1];
         if(App!=null){
         ApplicantName=App.FullName__c!=NULL?String.valueOf(App.FullName__c):'';
         	ApplicationFormNo=App.LoanAppln__r.Name!=NULL?String.valueOf(App.LoanAppln__r.Name):''; 
       
         LoanAmount=App.LoanAppln__r.ReqLoanAmt__c;
       /*  if(LoanAmount!=null){
             LoanAmountInWord=NumberToStringConverter.convertToWords(Integer.valueOf(LoanAmount));
         }
         LoanAmount1=App.LoanAppln__r.TotalLoanAmtInclInsurance__c; //LAK-9345
             if(LoanAmount1!=null){
             LoanAmountInWord1=NumberToStringConverter.convertToWords(Integer.valueOf(LoanAmount1));
         }*/
         
         LoanAccountNo=App.LoanAppln__r.ExistngFedFinaLoanAccNo__c!=NULL?String.valueOf(App.LoanAppln__r.ExistngFedFinaLoanAccNo__c):'';
         EMI=App.LoanAppln__r.EMIIcludingInsurance__c;
         list<Repayment_Account__c> RepayAcc=[select Id,Repayment_Mode__c,Is_Active__c from Repayment_Account__c where Loan_Application__c =:recordId and Is_Active__c =true];
     	if(!RepayAcc.isEmpty()){
         ModeOfRepayment=RepayAcc[0].Repayment_Mode__c!=NULL?String.valueOf(RepayAcc[0].Repayment_Mode__c):'';
        }}
     }
    
     public list<getRepaymentWrapper> RepaymentDetails(String recordId){
       
        list<Repayment_Account__c > repayMode=[select id,Repayment_Mode__c  from Repayment_Account__c  where Loan_Application__c = :recordId and Is_Active__c=true];
        
         list<getRepaymentWrapper> resultList = new list<getRepaymentWrapper>();
         list<PDC__c> rec=new list<PDC__c>();
        if(!repayMode.isEmpty()){
            if(repayMode[0].Repayment_Mode__c=='NACH'){
                  rec=[select id,PDC_Type__c,Cheque_Number_From__c, Cheque_Number_To__c, No_of_Cheques__c, Bank_Name__c, Bank_Branch__c, Cheque_Purpose__c, Cheque_Amount__c   from PDC__c   where Loan_Application__c  = :recordId and PDC_Type__c ='SPDC' ];
        
            }
            if(repayMode[0].Repayment_Mode__c=='PDC'){
                 rec=[select id,PDC_Type__c,Cheque_Number_From__c, Cheque_Number_To__c, No_of_Cheques__c, Bank_Name__c, Bank_Branch__c, Cheque_Purpose__c, Cheque_Amount__c   from PDC__c   where Loan_Application__c  = :recordId ];
            }
            if(!rec.isEmpty()){
                integer forIndex = 0;
              for(PDC__c r: rec){
                  forIndex++;
                  getRepaymentWrapper getWrapperData = new getRepaymentWrapper();
                	getWrapperData.SNo=forIndex;
                   getWrapperData.ChequeFrom=r.Cheque_Number_From__c;
                  getWrapperData.ChequeTo=r.Cheque_Number_To__c;
                  getWrapperData.NoofCheque=r.No_of_Cheques__c;
                  getWrapperData.BankandBranch=r.Bank_Name__c +' '+ r.Bank_Branch__c;
                  getWrapperData.Purpose=r.Cheque_Purpose__c;
                  getWrapperData.AmountofEachCheque=r.Cheque_Amount__c;
                  
                  resultList.add(getWrapperData)  ;                         
                    }}
            return resultList;
                }
        else{
            return null;
        }
        // officeAddress=PropAdd[0].HouseNo__c+' '+PropAdd[0].AddrLine1__c+' '+PropAdd[0].AddrLine2__c+' '+PropAdd[0].City__c+' '+PropAdd[0].State__c+' '+PropAdd[0].Country__c+ ''+PropAdd[0].Pincode__c!=NULL?String.valueOf(PropAdd[0].HouseNo__c+' '+PropAdd[0].AddrLine1__c+' '+PropAdd[0].AddrLine2__c+' '+PropAdd[0].City__c+' '+PropAdd[0].State__c+' '+PropAdd[0].Country__c+ ''+PropAdd[0].Pincode__c):'';
           }
 
    public class getRepaymentWrapper{

        @AuraEnabled
public Integer SNo {get;set;}
@AuraEnabled
public String ChequeFrom {get;set;}
@AuraEnabled
public String ChequeTo {get;set;}
@AuraEnabled
public Decimal NoofCheque {get;set;}
@AuraEnabled
public String BankandBranch {get;set;}
@AuraEnabled
public String Purpose {get;set;}
        @AuraEnabled
public Decimal AmountofEachCheque {get;set;}


}
}