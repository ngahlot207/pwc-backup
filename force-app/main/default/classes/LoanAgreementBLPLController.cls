public class LoanAgreementBLPLController {
	transient public String recordId{get;set;}
    transient public String StaticContent{get;set;}
    transient public String StaticContent1{get;set;}
    transient public String ApplicantName{get;set;}
    transient public String CoApplicantName{get;set;}
     transient public String ApplicationFormNo{get;set;}
     transient public String AddressOfTheProperty{get;set;}
     transient public Decimal LoanAmount{get;set;}
    transient public Decimal InusraceAmount{get;set;}
     transient public Decimal LoanAmount1{get;set;} 
    transient public Decimal EffectiveROI{get;set;}
    transient public Decimal PFAmount{get;set;}
    transient public String DueDate{get;set;}
    transient public Decimal Cersai{get;set;}
    transient public Decimal MoratPeriod{get;set;}
    public String LoanAmountInWord{get;set;}
    public String LoanAmountInWord1{get;set;}
    transient public String LoanPurpose{get;set;}
    transient public String rateTypeFloatingFlag{get;set;}
     transient public String LoanAccountNo{get;set;}
     transient public String CurrentDate{get;set;}
    transient public String CurrentDateTime{get;set;}
    transient public String CurrentMonthNumber{get;set;}
    
    
    transient public Integer CurrentDay{get;set;}
    transient public String CurrentMonth{get;set;}
    transient public Integer CurrentYear{get;set;}
    transient public string loanApplicationId{get;set;}
    transient public string fatherName{get;set;}
     transient public Decimal TenureOfLoan{get;set;}
     transient public string TypeOfLoan{get;set;}
    transient public string Place{get;set;}
    transient public string ModeOfRepayment{get;set;}
    transient public String FirstEMIDate{get;set;}
    transient public Decimal EMI{get;set;}
    transient public Decimal RevisedROI{get;set;}
    transient public Decimal RAACROI{get;set;}
    transient public Decimal resultRAACRevisedROI{get;set;}
     transient public Decimal FRR{get;set;}
    
        transient public string ApplicantTitle{get;set;}
    transient public string moratApplicable{get;set;}
     transient public string officeAddress{get;set;}
    transient public string ResidenceAddress{get;set;}
    transient public string DisbursalType{get;set;}
     transient public string LoanCity{get;set;}
    transient public string LoanBranch{get;set;}
    transient public Map<integer,String> mapofContent{get;set;}
     transient public List<getBorrowerDetailsWrapper> borrowerDetailsWrapper{get;set;}
     transient public List<getPropertyAddressWrapper> PropertyAddressWrapper{get;set;}
    transient public List<getMultiTrancheWrapper> MultiTrancheWrapper{get;set;}
    transient public List<getDeedsWrapper> DeedsWrapper{get;set;}
    transient public list<ChargeWrapper> ChargeWrapperList { get; set; }
    public List<Applicant__c> applicantList { get; set; }
    
     public LoanAgreementBLPLController(){
          recordId = 'a08C4000006afh7IAA';
        recordId=ApexPages.currentPage().getParameters().get('recordId');
        if(recordId==null)
        {
            //recordId='a08C40000083Lt0IAE';
             recordId = ApexPages.currentPage().getParameters().get('Id');
        }
        if(recordId!=null)
        {          
          	getStaticData(); 
            setDateTime();
            getloanDetails(recordId);
            getMetadataforContent();
            
            borrowerDetailsWrapper=getBorrowerDetails(recordId);
            PropertyAddressWrapper=getproperty(recordId);
            MultiTrancheWrapper=getMultiTranche(recordId);
            DeedsWrapper=getdeedDetails(recordId);
             toGetDescCharges();
            applicantList = [SELECT id, FullName__c, tolabel(ApplType__c) FROM Applicant__c
            WHERE LoanAppln__c = :recordId AND (ApplType__c = 'C' OR ApplType__c = 'p')];
        }
    }
    public void setDateTime()
    {
        DateTime dt = Datetime.now();
        CurrentDateTime=system.Now().format('dd-MMM-yyyy')+', '+system.Now().format('h:mm a');
        CurrentDate=system.Now().format('dd-MMM-yyyy');
        CurrentDay=dt.day();
        CurrentMonth=dt.format('MMM');
        CurrentMonthNumber=dt.format('MM');
        CurrentYear=dt.year();
        system.debug('CurrentDate'+CurrentDate);
    }
     public void  getStaticData(){
        // String StaticContent = '';
        try {
            // Fetch the static resource content
            StaticResource myHtmlResource = [SELECT Body FROM StaticResource WHERE Name = 'LoanAgreementBL1'];
            Blob htmlBlob = myHtmlResource.Body;
            StaticContent = htmlBlob.toString();
             StaticResource myHtmlResource1 = [SELECT Body FROM StaticResource WHERE Name = 'LoanAgreementATTORNEY'];
            Blob htmlBlob1 = myHtmlResource1.Body;
            StaticContent1 = htmlBlob1.toString();
            
           
        } catch (Exception e) {
            System.debug('Error fetching HTML content: ' + e.getMessage());
        }
        //return html;
    }
     public void getloanDetails(string recordId){
         list<Applicant__c>  CoApp=[Select id,Father_Name__c,Name,FullName__c,ApplType__c,LoanAppln__r.MoratGraceApplicable__c,LoanAppln__r.MoratGracePeriodMonths__c,LoanAppln__r.EMIIcludingInsurance__c,LoanAppln__r.DueDay__c,LoanAppln__r.FirstEMIDate__c,LoanAppln__r.ReqTenInMonths__c,LoanAppln__r.PFAmount__c,LoanAppln__r.EffectiveROI__c,LoanAppln__r.BrchName__c,LoanAppln__r.Name,LoanAppln__r.ReqLoanAmt__c,LoanAppln__r.Loan_Tenure_Months__c , LoanAppln__r.ExistngFedFinaLoanAccNo__c,LoanAppln__r.Product__c, LoanAppln__r.TotalLoanAmtInclInsurance__c from Applicant__c where LoanAppln__c=:recordId AND (ApplType__c='C') limit 1];
         if(!CoApp.isEmpty()){
             CoApplicantName=CoApp[0].FullName__c!=NULL?String.valueOf(CoApp[0].FullName__c):'';
         }
        Applicant__c  App=[Select id,Father_Name__c,Name,Constitution__c,Title__c,FullName__c,ApplType__c,LoanAppln__r.City__c,LoanAppln__r.Branch__r.Name,LoanAppln__r.DisbursalType__c,LoanAppln__r.RevisedROI__c,LoanAppln__r.InsAmt__c,LoanAppln__r.LoanPLRRate__c,LoanAppln__r.SpreadID__c,LoanAppln__r.Rate_Type_Floating_Flag__c,LoanAppln__r.LoanPurpose__c,LoanAppln__r.MoratGraceApplicable__c,LoanAppln__r.MoratGracePeriodMonths__c,LoanAppln__r.EMIIcludingInsurance__c,LoanAppln__r.DueDay__c,LoanAppln__r.FirstEMIDate__c,LoanAppln__r.ReqTenInMonths__c,LoanAppln__r.PFAmount__c,LoanAppln__r.EffectiveROI__c,LoanAppln__r.BrchName__c,LoanAppln__r.Name,LoanAppln__r.ReqLoanAmt__c,LoanAppln__r.Loan_Tenure_Months__c , LoanAppln__r.ExistngFedFinaLoanAccNo__c,LoanAppln__r.Product__c, LoanAppln__r.TotalLoanAmtInclInsurance__c from Applicant__c where LoanAppln__c=:recordId AND (ApplType__c='P') limit 1];
         if(App!=null){
         ApplicantName=App.FullName__c!=NULL?String.valueOf(App.FullName__c):'';
             fatherName=App.Father_Name__c!=NULL?String.valueOf(App.Father_Name__c):'';
             ApplicantTitle=App.Title__c!=NULL?String.valueOf(App.Title__c):'';
         	ApplicationFormNo=App.LoanAppln__r.Name!=NULL?String.valueOf(App.LoanAppln__r.Name):''; 
         AddressOfTheProperty='';
         LoanAmount=App.LoanAppln__r.ReqLoanAmt__c;
             InusraceAmount=App.LoanAppln__r.InsAmt__c;
             LoanCity=App.LoanAppln__r.City__c!=NULL?String.valueOf(App.LoanAppln__r.City__c):'';
             
             LoanBranch=App.LoanAppln__r.Branch__r.Name!=NULL?String.valueOf(App.LoanAppln__r.Branch__r.Name):'';
             DisbursalType=App.LoanAppln__r.DisbursalType__c!=NULL?String.valueOf(App.LoanAppln__r.DisbursalType__c):'';
         if(LoanAmount!=null){
             LoanAmountInWord=NumberToStringConverter.convertToWords(Integer.valueOf(LoanAmount));
         }
         LoanAmount1=App.LoanAppln__r.TotalLoanAmtInclInsurance__c; //LAK-9345
             if(LoanAmount1!=null){
             LoanAmountInWord1=NumberToStringConverter.convertToWords(Integer.valueOf(LoanAmount1));
         }
         EffectiveROI=App.LoanAppln__r.EffectiveROI__c;
         PFAmount=App.LoanAppln__r.PFAmount__c;
         DueDate=App.LoanAppln__r.DueDay__c;
         EMI=App.LoanAppln__r.EMIIcludingInsurance__c;
         LoanAccountNo=App.LoanAppln__r.ExistngFedFinaLoanAccNo__c!=NULL?String.valueOf(App.LoanAppln__r.ExistngFedFinaLoanAccNo__c):'';
         TypeOfLoan=App.LoanAppln__r.Product__c!=NULL?String.valueOf(App.LoanAppln__r.Product__c):'';
         TenureOfLoan=App.LoanAppln__r.ReqTenInMonths__c;
         Place=App.LoanAppln__r.BrchName__c!=NULL?String.valueOf(App.LoanAppln__r.BrchName__c):'';
         LoanPurpose=App.LoanAppln__r.LoanPurpose__c!=NULL?String.valueOf(App.LoanAppln__r.LoanPurpose__c):'';
         if(App.LoanAppln__r.FirstEMIDate__c!=null) {
                datetime mydatetime=App.LoanAppln__r.FirstEMIDate__c;
                FirstEMIDate=mydatetime.format('dd-MMM-yyyy');
            }
         if(App.LoanAppln__r.MoratGraceApplicable__c!=null && App.LoanAppln__r.MoratGraceApplicable__c=='Y') {
               MoratPeriod=App.LoanAppln__r.MoratGracePeriodMonths__c;                
            }
         else{
             moratApplicable='NOT Applicable';
         }
         if(App.LoanAppln__r.Rate_Type_Floating_Flag__c!=null && App.LoanAppln__r.Rate_Type_Floating_Flag__c=='N') {
               //MoratPeriod=App.LoanAppln__r.MoratGracePeriodMonths__c;   
				rateTypeFloatingFlag= 'Fixed' +' '+App.LoanAppln__r.EffectiveROI__c+ ' '+' p.a.' ;       
            }
         else{
             rateTypeFloatingFlag='Floating FEDFINA FRR'+' '+App.LoanAppln__r.LoanPLRRate__c +'% (+/-) margin'+App.LoanAppln__r.SpreadID__c+'% ='+App.LoanAppln__r.EffectiveROI__c;
         }   
             if(App.LoanAppln__r.RevisedROI__c!=null ) {
               //MoratPeriod=App.LoanAppln__r.MoratGracePeriodMonths__c;   
				RevisedROI= App.LoanAppln__r.RevisedROI__c;       
            }
         list<ApplAddr__c> appAdd=[select id,AddrLine1__c, AddrLine2__c, City__c,State__c, Country__c,HouseNo__c,Pincode__c,AddrTyp__c from ApplAddr__c where Applicant__c =:App.id  and AddrTyp__c='Office Address' limit 1];
         if(!appAdd.isEmpty()){
         officeAddress=appAdd[0].HouseNo__c+' '+appAdd[0].AddrLine1__c+' '+appAdd[0].AddrLine2__c+' '+appAdd[0].City__c+' '+appAdd[0].State__c+' '+appAdd[0].Country__c+ ''+appAdd[0].Pincode__c!=NULL?String.valueOf(appAdd[0].HouseNo__c+' '+appAdd[0].AddrLine1__c+' '+appAdd[0].AddrLine2__c+' '+appAdd[0].City__c+' '+appAdd[0].State__c+' '+appAdd[0].Country__c+ ''+appAdd[0].Pincode__c):'';
           }
             if(App.Constitution__c=='INDIVIDUAL'){
                 list<ApplAddr__c> ResAdd=[select id,AddrLine1__c, AddrLine2__c, City__c,State__c, Country__c,HouseNo__c,Pincode__c,AddrTyp__c from ApplAddr__c where Applicant__c =:App.id  and AddrTyp__c='Residence Address' limit 1];
         if(!ResAdd.isEmpty()){
         ResidenceAddress=ResAdd[0].HouseNo__c+' '+ResAdd[0].AddrLine1__c+' '+ResAdd[0].AddrLine2__c+' '+ResAdd[0].City__c+' '+ResAdd[0].State__c+' '+ResAdd[0].Country__c+ ''+ResAdd[0].Pincode__c!=NULL?String.valueOf(ResAdd[0].HouseNo__c+' '+ResAdd[0].AddrLine1__c+' '+ResAdd[0].AddrLine2__c+' '+ResAdd[0].City__c+' '+ResAdd[0].State__c+' '+ResAdd[0].Country__c+ ''+ResAdd[0].Pincode__c):'';
           }
             }
             else{
                 list<ApplAddr__c> ResAdd=[select id,AddrLine1__c, AddrLine2__c, City__c,State__c, Country__c,HouseNo__c,Pincode__c,AddrTyp__c from ApplAddr__c where Applicant__c =:App.id  and AddrTyp__c='Registered place for business' limit 1];
         if(!ResAdd.isEmpty()){
         ResidenceAddress=ResAdd[0].HouseNo__c+' '+ResAdd[0].AddrLine1__c+' '+ResAdd[0].AddrLine2__c+' '+ResAdd[0].City__c+' '+ResAdd[0].State__c+' '+ResAdd[0].Country__c+ ''+ResAdd[0].Pincode__c!=NULL?String.valueOf(ResAdd[0].HouseNo__c+' '+ResAdd[0].AddrLine1__c+' '+ResAdd[0].AddrLine2__c+' '+ResAdd[0].City__c+' '+ResAdd[0].State__c+' '+ResAdd[0].Country__c+ ''+ResAdd[0].Pincode__c):'';
           }
             }
         
         
         list<LonaApplCharges__c > LoanCharge=[select id,ChargeCodeDesc__c, Amount__c from LonaApplCharges__c where ChargeCodeDesc__c ='CERSAI CHARGES' and LoanApplication__c =:recordId ];
     	if(!LoanCharge.isEmpty()){
         Cersai=LoanCharge[0].Amount__c;
        }
         /*list<BRE__c> BRErecord=[select id,RAACROI__c,EligibilityType__c from BRE__c where LoanAppl__c =:recordId and EligibilityType__c ='Application' limit 1] ;
     	if(!BRErecord.isEmpty()){
         RAACROI=BRErecord[0].RAACROI__c;
        }*/
             
                 if(App.LoanAppln__r.EffectiveROI__c!=null ) {
               //MoratPeriod=App.LoanAppln__r.MoratGracePeriodMonths__c;   
				RAACROI= App.LoanAppln__r.EffectiveROI__c;       
            }
             if(App.LoanAppln__r.LoanPLRRate__c!=null ) {
               //MoratPeriod=App.LoanAppln__r.MoratGracePeriodMonths__c;   
				FRR= App.LoanAppln__r.LoanPLRRate__c;       
            }
             
     		if(RAACROI!=null && RevisedROI!=null) {
         resultRAACRevisedROI=RAACROI-RevisedROI;
            }
         list<Repayment_Account__c> RepayAcc=[select Id,Repayment_Mode__c,Is_Active__c from Repayment_Account__c where Loan_Application__c =:recordId and Is_Active__c =true];
     	if(!RepayAcc.isEmpty()){
         ModeOfRepayment=RepayAcc[0].Repayment_Mode__c!=NULL?String.valueOf(RepayAcc[0].Repayment_Mode__c):'';
        }}
     }
    
    
    public list<getPropertyAddressWrapper> getproperty(String recordId){
        /* list<ApplAddr__c> PropAdd=[select id,AddrLine1__c, AddrLine2__c, City__c,State__c, Country__c,HouseNo__c,Pincode__c,AddrTyp__c from ApplAddr__c where LoanAppl__c= :recordId ];
        list<getPropertyAddressWrapper> propList = new list<getPropertyAddressWrapper>();
        if(!PropAdd.isEmpty()){
              for(ApplAddr__c ad: PropAdd){
                  getPropertyAddressWrapper getWrapperData = new getPropertyAddressWrapper();
                  getWrapperData.AllPropertyAddress = ad.HouseNo__c+' '+ad.AddrLine1__c+' '+ad.AddrLine2__c+' '+ad.City__c+' '+ad.State__c+' '+ad.Country__c+ ''+ad.Pincode__c;
                   propList.add(getWrapperData)  ;                         
                    }
            return propList;
                }
        else{
            return null;
        }*/
        list<ApplAsset__c> PropAdd=[select id,PropAddrs__c,PropType__c,AddrType__c, Pin_Code__c, ValuationToBeTakenAheadForCalculation__c from ApplAsset__c where LoanAppln__c= :recordId ];
        list<getPropertyAddressWrapper> propList = new list<getPropertyAddressWrapper>();
        if(!PropAdd.isEmpty()){
              for(ApplAsset__c ad: PropAdd){
                  getPropertyAddressWrapper getWrapperData = new getPropertyAddressWrapper();
                 // getWrapperData.AllPropertyAddress = ad.HouseNo__c+' '+ad.AddrLine1__c+' '+ad.AddrLine2__c+' '+ad.City__c+' '+ad.State__c+' '+ad.Country__c+ ''+ad.Pincode__c;
                  getWrapperData.AllPropertyAddress=ad.PropType__c+','+ad.PropAddrs__c+','+ad.ValuationToBeTakenAheadForCalculation__c;
                   getWrapperData.AllPropertyAddresswithoutAmount=ad.PropType__c+','+ad.PropAddrs__c;
                  propList.add(getWrapperData)  ;                         
                    }
            return propList;
                }
        else{
            return null;
        }
        // officeAddress=PropAdd[0].HouseNo__c+' '+PropAdd[0].AddrLine1__c+' '+PropAdd[0].AddrLine2__c+' '+PropAdd[0].City__c+' '+PropAdd[0].State__c+' '+PropAdd[0].Country__c+ ''+PropAdd[0].Pincode__c!=NULL?String.valueOf(PropAdd[0].HouseNo__c+' '+PropAdd[0].AddrLine1__c+' '+PropAdd[0].AddrLine2__c+' '+PropAdd[0].City__c+' '+PropAdd[0].State__c+' '+PropAdd[0].Country__c+ ''+PropAdd[0].Pincode__c):'';
           }
    
     public void getMetadataforContent()
    {
               mapofContent=new Map<integer,String>();
        
        
        for(PDF_Generation_Metadata__mdt pdfObj:[select id,Content_Order__c,Content__c,Page_Number__c,Region_Picklist__c,Document_Type__c,Product_Type__c from PDF_Generation_Metadata__mdt where Document_Type__c='Loan Agreement for BL/PL'  ORDER BY Content_Order__c DESC])
        {
            if(pdfObj.Content_Order__c>0){
                mapofContent.put(integer.valueof(pdfObj.Content_Order__c),pdfObj.Content__c);
            }
        }}
    
     // Borrower details
    public List<getBorrowerDetailsWrapper> getBorrowerDetails(String recordId){
        try{
            List<getBorrowerDetailsWrapper> borrowerwrapperData = new List<getBorrowerDetailsWrapper>();
			string addType;
            set<Id> setOfApplicantId = new set<Id>();
            Map<Id,String> mapOfDPD = new map<Id,String>();
           // List<Applicant__c>  listOfApplicantDetails = [Select id, FullName__c, TabName__c, ApplType__c, CustProfile__c, Constitution__c, Gender__c,Residential_Status__c, Relationship__c, Age__c, UCID__c, Type_of_Borrower__c,LoanAppln__r.Loan_Tenure_Months__c,(SELECT Id from ApplAssetJn__r), (select Id, Prop_Owners__c from Applicant_Assets__r), (Select Id,Score__c from Bureau_Responses__r order by Score__c,createddate desc ) from Applicant__c where LoanAppln__c=:recordId and ApplType__c in ('P','C','G') ORDER BY CreatedDate ASC];
            List<Applicant__c>  listOfApplicantDetails = [Select id, FullName__c, TabName__c,DOI__c, ApplType__c, CustProfile__c, Constitution__c, Gender__c,Residential_Status__c, Relationship__c, Age__c, UCID__c, Type_of_Borrower__c,LoanAppln__r.Loan_Tenure_Months__c,(SELECT Id from ApplAssetJn__r),(select id,AddrLine1__c, AddrLine2__c, City__c,State__c, Country__c,HouseNo__c,Pincode__c,   AddrTyp__c from Applicant_Addresses__r), (select Id, Prop_Owners__c from Applicant_Assets__r), (Select Id,Score__c from Bureau_Responses__r order by Score__c,createddate desc ) from Applicant__c where LoanAppln__c=:recordId and ApplType__c in ('P','C','G') ORDER BY CreatedDate ASC];
           
             
            if(listOfApplicantDetails.size()>0){
                
                system.debug('listOfApplicantDetails-->'+listOfApplicantDetails);


                for(Applicant__c applns: listOfApplicantDetails){

                    setOfApplicantId.add(applns.Id);
                }

               // List<Applicant__c>
               List<AggregateResult>  listOfDedupeResponse    = [select MAX(DPD__c)max,Applicant__c from DedupeResponse__c where LoanAppln__c =:recordId and   RecordType.Name = 'ENPA' and IsLatest__c = True AND Applicant__c in:setOfApplicantId Group BY Applicant__c]; 

               if(listOfDedupeResponse.size()>0){


                for (AggregateResult dedupResp: listOfDedupeResponse) {
                    if(dedupResp!=null){
                    String ApplicantId = (string)dedupResp.get('Applicant__c');
                    //decimal max = (decimal)dedupResp.get('max');
                    string max = (string)dedupResp.get('max');
                    mapOfDPD.put(ApplicantId,max);
                }
                }
                system.debug('mapOfDPD-->'+mapOfDPD);
                
        }
                
                for(Applicant__c appln: listOfApplicantDetails){
                    
                    getBorrowerDetailsWrapper getWrapperData = new getBorrowerDetailsWrapper();
                    getWrapperData.applicantListForBorrowerWrapper = appln;
					getWrapperData.RelationShip=appln.Relationship__c;
                    getWrapperData.ResidentStatus=appln.Residential_Status__c;
                    
                    
                    if(appln.DOI__c!=null) {
                    datetime mydatetime1=appln.DOI__c;
                getWrapperData.DOI=mydatetime1.format('dd-MMM-yyyy');
                    }
                    
                    if(mapOfDPD.containsKey(appln.Id)){
                        getWrapperData.maxDPD = mapOfDPD.get(appln.Id);
                    }
                    
                    
                     if(appln.Residential_Status__c != null && appln.Residential_Status__c =='C'){
                getWrapperData.ResidenceType = 'CITIZEN';
            }else if(appln.Residential_Status__c != null && appln.Residential_Status__c =='NR'){
                getWrapperData.ResidenceType = 'NON RESIDENT';
            }
            else if(appln.Residential_Status__c != null && appln.Residential_Status__c =='PR'){
                getWrapperData.ResidenceType = 'PERMANENT RESIDENT';
                addType='Permanent Address';
            }
            else if(appln.Residential_Status__c != null && appln.Residential_Status__c =='R'){
                getWrapperData.ResidenceType = 'RESIDENT';
                addType='Residence Address';
            }
                    
                    if(appln.ApplType__c != null && appln.ApplType__c =='P'){
                getWrapperData.borrowerType = 'PRIMARY';
            }else if(appln.ApplType__c != null && appln.ApplType__c =='C'){
                getWrapperData.borrowerType = 'CO-APPLICANT';
            }
            else if(appln.ApplType__c != null && appln.ApplType__c =='G'){
                getWrapperData.borrowerType = 'GUARANTOR';
            }
            else if(appln.ApplType__c != null && appln.ApplType__c =='N'){
                getWrapperData.borrowerType = 'NOMINEE';
            }
            else if(appln.ApplType__c != null && appln.ApplType__c =='A'){
                getWrapperData.borrowerType = 'APPOINTEE';
            }
            
            if(appln.Gender__c != null && appln.Gender__c =='F'){
                getWrapperData.gender = 'Female';
            }
            else if(appln.Gender__c != null && appln.Gender__c =='M'){
                getWrapperData.gender = 'Male';
            }

            if(appln.Type_of_Borrower__c != null && appln.Type_of_Borrower__c =='Financial'){
                getWrapperData.financialBorrowerWrapper = 'Yes';
            }
                    
                    if(appln.Type_of_Borrower__c != null && appln.Type_of_Borrower__c =='Financial'){
                        getWrapperData.financialBorrowerWrapper = 'Yes';
                    }
                    
                    if(appln.Age__c != null && appln.LoanAppln__r.Loan_Tenure_Months__c !=null){
                        
                        system.debug('Age-->'+appln.Age__c);
                        system.debug('Loan Tenure Months-->'+appln.LoanAppln__r.Loan_Tenure_Months__c);
                        
                        Decimal ageMaturity =0;
                        Integer ageAtMaturity;
                        ageMaturity = appln.Age__c + appln.LoanAppln__r.Loan_Tenure_Months__c/12;
                        ageAtMaturity = ageMaturity.intValue();
                        getWrapperData.ageAtLonaMaturityWrapper = ageAtMaturity;
                        system.debug('getWrapperData.ageAtLonaMaturityWrapper-->'+getWrapperData.ageAtLonaMaturityWrapper);
                    }
                    
                    List<ApplAsset__c> applAsstList = appln.Applicant_Assets__r;
                    List<ApplAssetJn__c> applAsstJnList = appln.ApplAssetJn__r;
                    List<Bureau__c> bureauList = appln.Bureau_Responses__r;
                     List<ApplAddr__c> AppAddList = appln.Applicant_Addresses__r;
                    system.debug('applAsstList-->'+applAsstList);
                    system.debug('bureauList-->'+bureauList);
                    
                     /*for(ApplAddr__c ad: AppAddList){
                            getWrapperData.AddressOfBorrowers = ad.HouseNo__c+' '+ad.AddrLine1__c+' '+ad.AddrLine2__c+' '+ad.City__c+' '+ad.State__c+' '+ad.Country__c+ ''+ad.Pincode__c;
                                              
                    }*/
                    
                    for(ApplAddr__c ad: AppAddList){
                           // getWrapperData.AddressOfBorrowers = ad.HouseNo__c+' '+ad.AddrLine1__c+' '+ad.AddrLine2__c+' '+ad.City__c+' '+ad.State__c+' '+ad.Country__c+ ''+ad.Pincode__c;
                             if(addType!=null){
                        system.debug('addType'+addType);
                                 //removed  and AddrTyp__c=:addType from below query
          list<ApplAddr__c> adty=[select id,AddrLine1__c, AddrLine2__c, City__c,State__c, Country__c,HouseNo__c,Pincode__c,AddrTyp__c from ApplAddr__c where Applicant__c =:appln.id   limit 1];
         if(!adty.isEmpty()){
         getWrapperData.AddressOfBorrowers = adty[0].HouseNo__c+' '+adty[0].AddrLine1__c+' '+adty[0].AddrLine2__c+' '+adty[0].City__c+' '+adty[0].State__c+' '+adty[0].Pincode__c;
                              
         
                        }
                          
                    }
                               }
                    /*for(ApplAsset__c applAss: applAsstList){
                        
                        if(applAss.Prop_Owners__c !=null){
                            getWrapperData.propertyOwnerWrapper = 'Yes';
                        }
                        else{
                            getWrapperData.propertyOwnerWrapper = 'No';
                        }                        
                        
                    }*/

                    if(applAsstJnList.size()>0){
                        getWrapperData.propertyOwnerWrapper = 'Yes';
                    }else{
                        getWrapperData.propertyOwnerWrapper = 'No';
                    }
                    

                    
                    for(Bureau__c bu: bureauList){
                        
                        if(bu.Score__c !=null){
                            getWrapperData.scoreWrapper = bu.Score__c;
                            break;
                        } 
                    }
                    
                    borrowerwrapperData.add(getWrapperData);
                }
                system.debug('borrowerwrapperData-->'+borrowerwrapperData);
                return borrowerwrapperData;
            }
            else{ 
                return null;
            }
            
        }
        Catch (exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    
     public list<getDeedsWrapper> getdeedDetails(string recordId){
        
         list<DocDtl__c>  listDoc = [select id,DocDes__c, DocSubTyp__c, OriDoc__c,Originals__c,DocCatgry__c, DocStatus__c from DocDtl__c where LAN__c=:recordId and DocCatgry__c='Property Documents'];
             list<getDeedsWrapper> DeedList = new list<getDeedsWrapper>();
        if(!listDoc.isEmpty()){
         
                 for(DocDtl__c Docdtl: listDoc){
                      getDeedsWrapper DOCWpr=new getDeedsWrapper();
                     
                     DOCWpr.DetailsforTitleDeeds=Docdtl.DocSubTyp__c;                   
                   
                    DeedList.add(DOCWpr);
                   
                 }
            return DeedList;
            }
         else {
             return null;
         }
    }
    public void toGetDescCharges(){
        List<MasterData__c> masRecForCharges = [
            SELECT
                Id,
                DescriptionOfChargeAsPerFedfinaKFS__c,
                ValuesOfChargeKFS__c,
                Product__c
            FROM MasterData__c
            WHERE
                Product__c =: TypeOfLoan
                AND Type__c = 'KFS Contingent Charges' order by Sequence__c
        ];
        system.debug('masRecForCharges' + masRecForCharges);
        Integer sequence = 1;
        ChargeWrapperList = new List<ChargeWrapper>();
        for (MasterData__c record : masRecForCharges) {
            ChargeWrapper charRec = new ChargeWrapper();
            charRec.Index = sequence;
            charRec.valueOfCharge = record.ValuesOfChargeKFS__c;
            charRec.DecsOfCharge = record.DescriptionOfChargeAsPerFedfinaKFS__c;
            ChargeWrapperList.add(charRec);
            sequence++;
        }
    }
    
    //multiTranche
    public list<getMultiTrancheWrapper> getMultiTranche(String recordId){
        
        list<Disbursement__c> DisMultiTranche=[select id,DisbrDiscription__c,Total_Disb_Amt__c from Disbursement__c where Loan_Appli__c =:recordId ];
        list<getMultiTrancheWrapper> propList = new list<getMultiTrancheWrapper>();
        if(!DisMultiTranche.isEmpty()){
              for(Disbursement__c ad: DisMultiTranche){
                  getMultiTrancheWrapper getWrapperData = new getMultiTrancheWrapper();
                 // getWrapperData.AllPropertyAddress = ad.HouseNo__c+' '+ad.AddrLine1__c+' '+ad.AddrLine2__c+' '+ad.City__c+' '+ad.State__c+' '+ad.Country__c+ ''+ad.Pincode__c;
                  getWrapperData.MTDescription=ad.DisbrDiscription__c;
                   getWrapperData.MTAmount=ad.Total_Disb_Amt__c;
                  propList.add(getWrapperData)  ;                         
                    }
            return propList;
                }
        else{
            return null;
        }
        // officeAddress=PropAdd[0].HouseNo__c+' '+PropAdd[0].AddrLine1__c+' '+PropAdd[0].AddrLine2__c+' '+PropAdd[0].City__c+' '+PropAdd[0].State__c+' '+PropAdd[0].Country__c+ ''+PropAdd[0].Pincode__c!=NULL?String.valueOf(PropAdd[0].HouseNo__c+' '+PropAdd[0].AddrLine1__c+' '+PropAdd[0].AddrLine2__c+' '+PropAdd[0].City__c+' '+PropAdd[0].State__c+' '+PropAdd[0].Country__c+ ''+PropAdd[0].Pincode__c):'';
           }
       public class getMultiTrancheWrapper{
@AuraEnabled
public String MTDescription {get;set;}   
public Decimal MTAmount {get;set;}
}
    class ChargeWrapper {
        public Integer Index { get; set; }
        public String valueOfCharge { get; set; }
        public String DecsOfCharge { get; set; }
    }
    public class getPropertyAddressWrapper{
@AuraEnabled
public String AllPropertyAddress {get;set;}   
public String AllPropertyAddresswithoutAmount {get;set;}
}
    public class getBorrowerDetailsWrapper{
@AuraEnabled
public Applicant__c applicantListForBorrowerWrapper {get;set;}
@AuraEnabled
public String propertyOwnerWrapper {get;set;}
@AuraEnabled
public String scoreWrapper {get;set;}
@AuraEnabled
public Integer ageAtLonaMaturityWrapper {get;set;}
@AuraEnabled
public String financialBorrowerWrapper {get;set;}
@AuraEnabled
public String borrowerType {get;set;}
        @AuraEnabled
public String ResidenceType {get;set;}
@AuraEnabled
public String gender {get;set;}
@AuraEnabled
public String maxDPD {get;set;}
        @AuraEnabled
public String RelationShip {get;set;}
        @AuraEnabled
public String ResidentStatus {get;set;}
         @AuraEnabled
public String AddressOfBorrowers {get;set;}
        @AuraEnabled
public String DOI {get;set;}
       

}
 public class getDeedsWrapper{
@AuraEnabled
public String DetailsforTitleDeeds {get;set;}   
}
    class ApplicantWrapper {
    public String custProfile { get; set; }
    public String companyName { get; set; }
    public String phoneNo { get; set; }
    public String fullName { get; set; }   
    public String spName { get; set; }
    public String fatherName { get; set; }
    public String mthrMdnName { get; set; }
    public string dob { get; set; }
    public String emailId { get; set; }
    public String comunicationAddress { get; set; }
    public String appType { get; set; }
    }
}