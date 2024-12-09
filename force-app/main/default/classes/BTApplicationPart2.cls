public class BTApplicationPart2 {
	transient public String recordId{get;set;}
    transient public String ApplicantName{get;set;}
    transient public Map<integer,String> mapofContent{get;set;}
    transient public String CurrentDate{get;set;}
    transient public String DisbursementDate{get;set;}
    
         transient public String DOI{get;set;}
     transient public Decimal age{get;set;}
     transient public string Place{get;set;}
    transient public string ResidenceAddress{get;set;}
    transient public string RentedProperty{get;set;}
    transient public string SelfOccupiedProperty{get;set;}
     transient public string BTFinancier{get;set;}
    transient public string AllPropertyAddress{get;set;}
    
        transient public Decimal OutStandingAmount{get;set;}
     transient public Decimal LoanAmount{get;set;}
     public String rupeeInWord{get;set;}
    transient public Integer CurrentDay{get;set;}
    transient public String CurrentMonth{get;set;}
    transient public Integer CurrentYear{get;set;}
    transient public boolean IsDocForPLAndPL{get;set;}
    
     public BTApplicationPart2(){
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
            setDateTime();
        }
    }
    
    
     public void setDateTime()
    {
        DateTime dt = Datetime.now();
         CurrentDay=dt.day();
        CurrentMonth=dt.format('MMM');
        CurrentYear=dt.year();
       // CurrentDateTime=system.Now().format('dd-MMM-yyyy')+', '+system.Now().format('h:mm a');
        CurrentDate=system.Now().format('dd-MMM-yyyy');
       
    }
    public void getloanDetails(string recordId){
        Applicant__c  App=[Select id,FullName__c,DOI__c,Age__c,ApplType__c,LoanAppln__r.Product__c,LoanAppln__r.DisbursementDate__c,LoanAppln__r.BTLoanOutstndVal__c,LoanAppln__r.ReqLoanAmt__c,LoanAppln__r.TotalLoanAmtInclInsurance__c,LoanAppln__r.BrchName__c from Applicant__c where LoanAppln__c=:recordId AND (ApplType__c='P') limit 1];
            ApplicantName=App.FullName__c;
        	age=App.Age__c;
        Place=App.LoanAppln__r.BrchName__c!=NULL?String.valueOf(App.LoanAppln__r.BrchName__c):'';
        if(App.LoanAppln__r.Product__c=='Loan Against Property' || App.LoanAppln__r.Product__c=='Home Loan' || App.LoanAppln__r.Product__c=='Small Ticket LAP'){
            IsDocForPLAndPL=false;
        }else{
            IsDocForPLAndPL=true;
        }
        if(App.LoanAppln__r.TotalLoanAmtInclInsurance__c!=null){
        LoanAmount=App.LoanAppln__r.TotalLoanAmtInclInsurance__c;        
        rupeeInWord = NumberToStringConverter.convertToWords(Integer.valueOf(LoanAmount));
    }
        if(App.LoanAppln__r.BTLoanOutstndVal__c!=null){
        OutStandingAmount=App.LoanAppln__r.BTLoanOutstndVal__c;        
        //rupeeInWord = NumberToStringConverter.convertToWords(Integer.valueOf(LoanAmount));
    }
        if(App.DOI__c!=null) {
                    datetime mydatetimeDOI=App.DOI__c;
                DOI=mydatetimeDOI.format('dd-MMM-yyyy');
                    }
        /* list<ApplAddr__c> appAdd=[select id,AddrLine1__c, AddrLine2__c, City__c,State__c, Country__c,HouseNo__c,Pincode__c,AddrTyp__c from ApplAddr__c where Applicant__c =:App.id  and AddrTyp__c='Office Address' limit 1];
         if(!appAdd.isEmpty()){
         officeAddress=appAdd[0].HouseNo__c+' '+appAdd[0].AddrLine1__c+' '+appAdd[0].AddrLine2__c+' '+appAdd[0].City__c+' '+appAdd[0].State__c+' '+appAdd[0].Country__c+ ''+appAdd[0].Pincode__c!=NULL?String.valueOf(appAdd[0].HouseNo__c+' '+appAdd[0].AddrLine1__c+' '+appAdd[0].AddrLine2__c+' '+appAdd[0].City__c+' '+appAdd[0].State__c+' '+appAdd[0].Country__c+ ''+appAdd[0].Pincode__c):'';
           }*/
        list<ApplAsset__c> PropAdd=[select id,PropAddrs__c,PropType__c,AddrType__c, Pin_Code__c, ValuationToBeTakenAheadForCalculation__c from ApplAsset__c where LoanAppln__c= :recordId and AddrType__c ='Residence Address'];
       
        if(!PropAdd.isEmpty()){
              ResidenceAddress=PropAdd[0].PropAddrs__c!=NULL?String.valueOf(PropAdd[0].PropAddrs__c):'';
                   
   		 }
        
         list<ApplAsset__c> PropRentedAdd=[select id,LoanAppln__r.Name,Property_Usage__c ,PropType__c,AddrType__c, PropAddrs__c,Pin_Code__c, ValuationToBeTakenAheadForCalculation__c from ApplAsset__c  where LoanAppln__c= :recordId and Property_Usage__c ='RENTED'];
        if(!PropRentedAdd.isEmpty()){
              RentedProperty=PropRentedAdd[0].PropAddrs__c!=NULL?String.valueOf(PropRentedAdd[0].PropAddrs__c):'';
                   
   		 }
        list<ApplAsset__c> PropSelfOccupiedAdd=[select id,LoanAppln__r.Name,Property_Usage__c ,PropAddrs__c,PropType__c,AddrType__c, Pin_Code__c, ValuationToBeTakenAheadForCalculation__c from ApplAsset__c  where  LoanAppln__c= :recordId and Property_Usage__c ='RENTED'];
        if(!PropSelfOccupiedAdd.isEmpty()){
              SelfOccupiedProperty=PropSelfOccupiedAdd[0].PropAddrs__c!=NULL?String.valueOf(PropSelfOccupiedAdd[0].PropAddrs__c):'';
                   
   		 }
		if( App.LoanAppln__r.DisbursementDate__c != null) {
                datetime mydatetimeDis=App.LoanAppln__r.DisbursementDate__c;
                DisbursementDate=mydatetimeDis.format('dd-MMM-yyyy');
            }
        list<ApplAsset__c> AllProdAddr = [select id,LoanAppln__r.Name,Property_Usage__c ,PropType__c,AddrType__c, PropAddrs__c,Pin_Code__c, ValuationToBeTakenAheadForCalculation__c from ApplAsset__c  where LoanAppln__c= :recordId];
            set<string> AddrSet = new set<string>();
            if (AllProdAddr.size()>0) {
                for (ApplAsset__c bt: AllProdAddr) {
                    
                        AddrSet.add(bt.PropAddrs__c);
                    
                }
                AllPropertyAddress = string.join(AddrSet, ', ');
            }else{
                AllPropertyAddress='NA';
            }
        
        list<btloan__c> btFinancierlist = [select id, BTFinancier__c, SpecifyOtherBTFinancier__c from BTLoan__c where LoanAppl__c =:recordId];
            set<string> btFinancierSet = new set<string>();
            if (btFinancierlist.size()>0) {
                for (btloan__c bt: btFinancierlist) {
                    if (bt.BTFinancier__c == 'OTHER NBFC' && bt.SpecifyOtherBTFinancier__c != null) {
                        btFinancierSet.add(bt.SpecifyOtherBTFinancier__c);
                    }else {
                        btFinancierSet.add(bt.BTFinancier__c);
                    }
                }
                BTFinancier = string.join(btFinancierSet, ', ');
            }else{
                BTFinancier='NA';
            }
        
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