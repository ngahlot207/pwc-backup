public class SanctionLetterForBLAndPLController {
	transient public String recordId{get;set;}
    transient public String header{get;set;}
    transient public String todaysDate{get;set;}
    transient public String allApplicantsNames{get;set;}
    transient public String addressLine1{get;set;}
    transient public String addressLine2{get;set;}
    transient public String houseNo{get;set;}
    transient public String landMark{get;set;}
    transient public String state{get;set;}
    transient public String cityPincode{get;set;}
    transient public String mobileNumber{get;set;}
    transient public String loanNumber{get;set;}
    transient public String typeofFacility{get;set;}
    transient public String loanAmountSanctioned{get;set;}
    transient public String LoanAmount{get;set;}
    transient public String termofFacility{get;set;}
    transient public String roi{get;set;}
    transient public String security{get;set;}
    transient public Decimal amountofEachEMI{get;set;}
    transient public String dueDiligence{get;set;}
    transient public String processingFeeforDescription{get;set;}
    transient public String processingFee{get;set;}
    transient public String descriptionContent{get;set;}
    transient public String floatingReferenceRate{get;set;}
    transient public boolean showFloatingRate{get;set;}
    transient public Decimal insurancePremium{get;set;}
    transient public Decimal feesChargesToBeCollected{get;set;}
    transient public Decimal feesChargesToBeRecieved{get;set;}
    transient public String typeofInterest{get;set;}
    transient public List<String> coApplicantIds{get;set;}
    transient public List<customerWrapper> oddList{get;set;}
    transient public List<customerWrapper> evenList{get;set;}
    transient public Map<integer,String> mapofContent{get;set;}
    transient public List<sanctionWrapper> conditionList{get;set;}
    public List<String> args{get;set;}
    transient public String CurrentDateTime{get;set;}
    transient public String CurrentDate{get;set;}
    transient public String branchName{get;set;}
    transient public String borrowerName{get;set;}
    transient public String modifiedContent{get;set;}
    transient public String product{get;set;}
    transient public String RmName{get;set;}
    transient public String contactRM{get;set;}
    transient public list<ChargeWrapper> ChargeWrapperList { get; set; }
    public List<Applicant__c> applicantList { get; set; }
    
    public SanctionLetterForBLAndPLController(){
        recordId=ApexPages.currentPage().getParameters().get('recordId');
        if(recordId==null)
        {
            recordId='a08C40000083Lt0IAE';
        }
        if(recordId!=null)
        {
            setDateTime();
            initializeAllVariable();
            getloanApplicationFeilds(recordId);
            setDueDiligenceandProcessingFee(recordId);
            getMetadataforContent(recordId);
            getSanctionConditions(recordId);
            //getInsurancePremium(recordId);
            getFeesDetails(recordId);
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
    }
    public void initializeAllVariable()
    {
        args= new String[]{'0','number','⌗⌗⌗,⌗⌗⌗,⌗⌗⌗,⌗⌗⌗'};
            todaysDate = '';
        allApplicantsNames = '';
        addressLine1 = '';
        addressLine2 = '';
        cityPincode = '';
        mobileNumber = '';
        loanNumber = '';
        product='';
        typeofFacility = '';
        loanAmountSanctioned = '0';
        termofFacility = '';
        roi = '';
        security = '';
        amountofEachEMI = 0;
        dueDiligence = '';
        processingFee = '';
        insurancePremium=0;
        feesChargesToBeCollected=0;
        feesChargesToBeRecieved=0;
        typeofInterest='';
        descriptionContent='';
        floatingReferenceRate='';
        showFloatingRate=false;
        processingFeeforDescription='';
        header='';
        borrowerName='';
        
    }
    public void getloanApplicationFeilds(string recordId) {
        try{
            DateTime dt = Datetime.now();
            header='Sanction Letter';
            string schemeId='';
            List<String> applicantIds=new List<String>();
            coApplicantIds=new List<String>();
            oddList=new List<customerWrapper>();
            evenList=new List<customerWrapper>();
            decimal loanAmount=0;
            //todaysDate=string.valueof(System.now().date().day()+'/'+System.now().date().month()+'/'+System.now().date().year());//dt.format('MMMM')+' '+dt.format('dd')+', '+dt.format('YYYY');
            System.debug('todaysDate ===> '+todaysDate);
            integer count=0;
            integer propertyNumber=1;
            
            for(Applicant__c appObj:[Select id,LoanAppln__r.RM__c, LoanAppln__r.DSACONTACT__c,Title__c,FullName__c,MobNumber__c,ApplType__c,LoanAppln__r.Name,LoanAppln__r.SchemeId__c,LoanAppln__r.Product__c,LoanAppln__r.SanLoanAmt__c,LoanAppln__r.Loan_Tenure_Months__c,LoanAppln__r.EffectiveROI__c,LoanAppln__r.EMIIcludingInsurance__c,LoanAppln__r.Stage__c,LoanAppln__r.LatestSanctionDate__c,LoanAppln__r.TotalLoanAmtInclInsurance__c,LoanAppln__r.InsAmt__c,LoanAppln__r.LoanPurpose__c,LoanAppln__r.BrchName__c from Applicant__c where LoanAppln__c=:recordId AND (ApplType__c='P' OR ApplType__c='G' OR ApplType__c='C' ) order by CreatedDate Asc])
            {
                if(appObj.LoanAppln__r.LatestSanctionDate__c!=null)
                {
                    DateTime date1 = DateTime.newInstance(appObj.LoanAppln__r.LatestSanctionDate__c.year(), appObj.LoanAppln__r.LatestSanctionDate__c.month(), appObj.LoanAppln__r.LatestSanctionDate__c.day());
                    todaysDate=date1.format('dd-MMM-yyyy');
                }
                if(appObj.LoanAppln__r.Stage__c!=null && appObj.LoanAppln__r.Stage__c=='Soft Sanction')
                {
                    header='Sanction Letter';
                }
                if(appObj.LoanAppln__r.Product__c!=null && typeofFacility=='')
                {
                    typeofFacility=appObj.LoanAppln__r.Product__c;
                }
                if(appObj.LoanAppln__r.BrchName__c!=null)
                {
                    branchName=appObj.LoanAppln__r.BrchName__c;
                }
                count++;
                system.debug(count);
                if(math.mod(count,2)==0)
                {
                    customerWrapper cv=new customerWrapper();
                    cv.serialNumber=count;
                    cv.name=appObj.FullName__c;
                    evenList.add(cv);
                }
                else{
                    customerWrapper cv=new customerWrapper();
                    cv.serialNumber=count;
                    cv.name=appObj.FullName__c;
                    oddList.add(cv);
                }
                applicantIds.add(appObj.id);
                
                loanNumber=!string.isBlank(appObj.LoanAppln__r.Name)?appObj.LoanAppln__r.Name:'';
                RmName=!string.isBlank(appObj.LoanAppln__r.RM__c)?appObj.LoanAppln__r.RM__c:'';
                contactRM=!string.isBlank(appObj.LoanAppln__r.DSACONTACT__c)?appObj.LoanAppln__r.DSACONTACT__c:'';
                product=!string.isBlank(appObj.LoanAppln__r.product__c)?appObj.LoanAppln__r.product__c:'';
                schemeId=!string.isBlank(appObj.LoanAppln__r.SchemeId__c)?appObj.LoanAppln__r.SchemeId__c:'';
                loanAmountSanctioned=formatIndianCurrency(appObj.LoanAppln__r.TotalLoanAmtInclInsurance__c);
                loanAmount=appObj.LoanAppln__r.TotalLoanAmtInclInsurance__c;
                insurancePremium = appObj.LoanAppln__r.InsAmt__c;
                termofFacility=string.valueof(appObj.LoanAppln__r.Loan_Tenure_Months__c);
                roi=string.valueof(appObj.LoanAppln__r.EffectiveROI__c);
                amountofEachEMI=appObj.LoanAppln__r.EMIIcludingInsurance__c;
                system.debug('appObj.FullName__c---------------->'+appObj.FullName__c);
                system.debug('appObj.Title__c---------------->'+appObj.Title__c);
                if(appObj.Title__c!=null)
                {
                    allApplicantsNames=(!string.isBlank(allApplicantsNames)?allApplicantsNames+', ':'')+appObj.Title__c+' '+appObj.FullName__c;
                }
                else
                {
                    allApplicantsNames=(!string.isBlank(allApplicantsNames)?allApplicantsNames+', ':'')+appObj.FullName__c;
                }
                system.debug('appObj.ApplType__c----------->'+appObj.ApplType__c);
                if(appObj.ApplType__c=='P')
                {
                    mobileNumber=appObj.MobNumber__c;
                    borrowerName=appObj.FullName__c;
                }
                else
                {
                    coApplicantIds.add(appObj.FullName__c);
                }
                //coApplicantIds.add('qwertyui');
                //coApplicantIds.add('qwertyui');
                
            }
            //oddList.add(9);
            //oddList.add(10);
            //evenList.add(8);
            //evenList.add(0);
            //if(loanAmount!=null && loanAmount>0)
            //{
                //setLoanAmout(recordId);
          //  }
            system.debug('80'+schemeId);
            if(!string.isBlank(schemeId))
            {
                system.debug('83'+schemeId);
                SchMapping__c schObj=[select id,SchemeDesc__c from SchMapping__c where id=:schemeId];
                if(typeofFacility!=null && schObj.SchemeDesc__c !='')
                {
                    typeofFacility=typeofFacility+'+'+schObj.SchemeDesc__c;
                }
                
            }
            System.debug('typeofFacility ===> '+typeofFacility);
            System.debug('oddList ===> '+oddList);
            System.debug('evenList ===> '+evenList);
            System.debug('allApplicantsNames ===> '+allApplicantsNames);
            System.debug('applicantIds ===> '+applicantIds);
            if(applicantIds.size()>0)
            {
                for(ApplAddr__c addObj:[Select id,MailAddr__c,AddrLine1__c,AddrLine2__c,City__c,Pincode__c,Landmark__c,HouseNo__c,State__c from ApplAddr__c where Applicant__c IN:applicantIds])
                {
                    if(addObj.MailAddr__c==true)
                    {
                        System.debug('insideif ===> '+addObj);
                        addressLine1=addObj.AddrLine1__c!=''?addObj.AddrLine1__c+'':'';
                        addressLine2=addObj.AddrLine2__c!=''?addObj.AddrLine2__c+'':'';
                        cityPincode=addObj.City__c+' - '+addObj.Pincode__c;
                        state=addObj.State__c;
                        landMark=addObj.Landmark__c!=null?addObj.Landmark__c+'':'';
                        houseNo=addObj.HouseNo__c!=null?addObj.HouseNo__c+'':'';
                        break;
                    }
                }
                System.debug('addressLine1 ===> '+addressLine1);
                System.debug('addressLine2 ===> '+addressLine2);
                System.debug('cityPincode ===> '+cityPincode);
                List<ApplAsset__c> assetList=[SELECT Id, Name, LoanAppln__c,PropAddrs__c,FlatNo__c ,AddrLn1__c,AddrLn2__c,City__c,State__c,Pin_Code__c,Landmark__c  FROM ApplAsset__c where LoanAppln__c =:recordId];
                system.debug('assetList---------------->'+assetList);
                if(assetList.size()>0)
                {
                    if(assetList.size()==1)
                    {
                        for(ApplAsset__c  assetObj:assetList)
                        {
                            if(!string.isBlank(security))
                            {
                                security=security+(assetObj.FlatNo__c!=null ?(assetObj.FlatNo__c!=''?assetObj.FlatNo__c:''):'')+
                                    (assetObj.AddrLn1__c!=null ?(assetObj.AddrLn1__c!=''?', '+assetObj.AddrLn1__c:''):'')+
                                    (assetObj.AddrLn2__c!=null ?(assetObj.AddrLn2__c!=''?', '+assetObj.AddrLn2__c:''):'')+
                                    (assetObj.Landmark__c!=null ?(assetObj.Landmark__c!=''?', '+assetObj.Landmark__c:''):'')+
                                    (assetObj.City__c!=null ?(assetObj.City__c!=''?', '+assetObj.City__c:''):'')+
                                    (assetObj.State__c!=null ?(assetObj.State__c!=''?', '+assetObj.State__c:''):'')+
                                    (assetObj.Pin_Code__c!=null ?(assetObj.Pin_Code__c!=''?', '+assetObj.Pin_Code__c:''):'');
                                
                            }
                            else
                            {
                                security=(assetObj.FlatNo__c!=null ?(assetObj.FlatNo__c!=''?assetObj.FlatNo__c:''):'')+
                                    (assetObj.AddrLn1__c!=null ?(assetObj.AddrLn1__c!=''?', '+assetObj.AddrLn1__c:''):'')+
                                    (assetObj.AddrLn2__c!=null ?(assetObj.AddrLn2__c!=''?', '+assetObj.AddrLn2__c:''):'')+
                                    (assetObj.Landmark__c!=null ?(assetObj.Landmark__c!=''?', '+assetObj.Landmark__c:''):'')+
                                    (assetObj.City__c!=null ?(assetObj.City__c!=''?', '+assetObj.City__c:''):'')+
                                    (assetObj.State__c!=null ?(assetObj.State__c!=''?', '+assetObj.State__c:''):'')+
                                    (assetObj.Pin_Code__c!=null ?(assetObj.Pin_Code__c!=''?', '+assetObj.Pin_Code__c:''):'')+security+'<br/>';
                            }
                        }
                    }
                    else
                    {
                        for(ApplAsset__c  assetObj:assetList)
                        {
                            if(!string.isBlank(security))
                            {
                                security=security+'<br/>'+propertyNumber+'. '+(assetObj.FlatNo__c!=null ?(assetObj.FlatNo__c!=''?assetObj.FlatNo__c:''):'')+
                                    (assetObj.AddrLn1__c!=null ?(assetObj.AddrLn1__c!=''?', '+assetObj.AddrLn1__c:''):'')+
                                    (assetObj.AddrLn2__c!=null ?(assetObj.AddrLn2__c!=''?', '+assetObj.AddrLn2__c:''):'')+
                                    (assetObj.Landmark__c!=null ?(assetObj.Landmark__c!=''?', '+assetObj.Landmark__c:''):'')+
                                    (assetObj.City__c!=null ?(assetObj.City__c!=''?', '+assetObj.City__c:''):'')+
                                    (assetObj.State__c!=null ?(assetObj.State__c!=''?', '+assetObj.State__c:''):'')+
                                    (assetObj.Pin_Code__c!=null ?(assetObj.Pin_Code__c!=''?', '+assetObj.Pin_Code__c:''):'');
                                
                                
                                propertyNumber++;
                            }
                            else
                            {
                                security=propertyNumber+'. '+(assetObj.FlatNo__c!=null ?(assetObj.FlatNo__c!=''?assetObj.FlatNo__c:''):'')+
                                    (assetObj.AddrLn1__c!=null ?(assetObj.AddrLn1__c!=''?', '+assetObj.AddrLn1__c:''):'')+
                                    (assetObj.AddrLn2__c!=null ?(assetObj.AddrLn2__c!=''?', '+assetObj.AddrLn2__c:''):'')+
                                    (assetObj.Landmark__c!=null ?(assetObj.Landmark__c!=''?', '+assetObj.Landmark__c:''):'')+
                                    (assetObj.City__c!=null ?(assetObj.City__c!=''?', '+assetObj.City__c:''):'')+
                                    (assetObj.State__c!=null ?(assetObj.State__c!=''?', '+assetObj.State__c:''):'')+
                                    (assetObj.Pin_Code__c!=null ?(assetObj.Pin_Code__c!=''?', '+assetObj.Pin_Code__c:''):'')+security;
                                propertyNumber++;
                            }
                        }
                    }
                    
                }
                
                
            }
            
            
        }catch (exception e) {
            system.debug(e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public void setLoanAmout(string recordId){
        List<Payment__c> paymentList=[Select id,TransAmt__c,TransStatus__c,PaytmAPIStatus__c,IntegrationStatus__c,PaymentRefNo__c,LoanAppl__r.SanLoanAmt__c from Payment__c where TransStatus__c='Success' and LoanAppl__c=:recordId and Type__c='Insurance'];
        if(paymentList.size()>0)
        {
            loanAmountSanctioned=formatIndianCurrency(paymentList[0].LoanAppl__r.SanLoanAmt__c);
            insurancePremium = 0;
        }
        
    }
    
    private String formatIndianCurrency(Decimal amount) {
        String formattedAmount = amount.setScale(1).format();
        return formattedAmount;
        
    }
    
    public void setDueDiligenceandProcessingFee(string recordId)
    {
        System.debug('RecordIddddddddddd:'+recordId);
        List<LonaApplCharges__c> loanApplistforDiligence=[select id, ChargeCodeID__c,Amount__c from LonaApplCharges__c where ChargeCodeID__c ='600234' Limit 1];
        LoanAppl__c loanObjDueDili=[Select id,(SELECT ID ,PF__C,Amount__c FROM Loan_Application_Charges__r WHERE ChargeCodeID__c='600234' LIMIT 1)  from LoanAppl__c where id=:recordId];
        dueDiligence='Rs.0/- (inclusive of GST) Rs.0/- collected and Rs.0/- to be collected on Disbursement.';
        if(loanObjDueDili.Loan_Application_Charges__r.size()>0)
        {
            if(loanObjDueDili.Loan_Application_Charges__r[0].Amount__c>0)
            {
                dueDiligence='Rs.'+loanObjDueDili.Loan_Application_Charges__r[0].Amount__c+'/- (inclusive of GST) Rs.0/- collected and '+'Rs.'+loanObjDueDili.Loan_Application_Charges__r[0].Amount__c+'/- to be collected on Disbursement.';
            }            
        }
        
        //List<LonaApplCharges__c> loanApplistforProcessingFee=[select id, ChargeCodeID__c,Amount__c from LonaApplCharges__c where ChargeCodeID__c ='600168' Limit 1];
        LoanAppl__c loanObjCERSAI=[Select id,(SELECT ID ,PF__C,Amount__c FROM Loan_Application_Charges__r WHERE ChargeCodeID__c='600168' LIMIT 1)  from LoanAppl__c where id=:recordId];
        processingFee='Rs.0/- (inclusive of CERSAI charges of Rs.0/-) Rs.0/- collected and Rs.0/- to be collected on Disbursement.';
        LoanAppl__c loanObj=[Select id,TotalCharges__c,Total_PF_Amount__c,TotalIMDAmount__c,(SELECT ID ,PF__C,Amount__c FROM Loan_Application_Charges__r WHERE ChargeCodeID__c=:System.Label.PFChargeCodeId LIMIT 1)  from LoanAppl__c where id=:recordId];
        List<ApplIMD__c> imdList=[select id,InstrumentAmt__c from ApplIMD__c where LoanAppln__c =:recordId Order By createddate ASC Limit 1];
        
        Decimal ImdAmount=0;
        if(imdList.size()>0)
        {
            ImdAmount=imdList[0].InstrumentAmt__c!=null?imdList[0].InstrumentAmt__c:0;
        }
        
        System.debug('LoanObject:'+loanObj);
        string cersaiCharges='0';
        if(loanObjCERSAI.Loan_Application_Charges__r.size()>0)
        {
            if(loanObjCERSAI.Loan_Application_Charges__r[0].Amount__c>0)
            {
                cersaiCharges=string.valueof(loanObjCERSAI.Loan_Application_Charges__r[0].Amount__c);
            }            
        }
        if(loanObj!=null)
        {
            Decimal prosFees=(loanObj.Loan_Application_Charges__r.size()>0?(loanObj.Loan_Application_Charges__r[0].Amount__c!=null?loanObj.Loan_Application_Charges__r[0].Amount__c:0):0)+(loanObjCERSAI.Loan_Application_Charges__r.size()>0?(loanObjCERSAI.Loan_Application_Charges__r[0].Amount__c!=null?loanObjCERSAI.Loan_Application_Charges__r[0].Amount__c:0):0);
            processingFee='Rs. '+string.valueof(prosFees!=null?formatIndianCurrency(prosFees):'0')+'/- (inclusive of CERSAI charges of Rs. '+cersaiCharges+'/-) Rs. '+String.valueof(loanObj.TotalIMDAmount__c >0?formatIndianCurrency(loanObj.TotalIMDAmount__c) :'0')+'/- collected and Rs. '+string.valueof(loanObj.Total_PF_Amount__c >0?formatIndianCurrency(loanObj.Total_PF_Amount__c) :'0')+'/- to be collected on Disbursement.';
        }
    }
    public void getMetadataforContent(string recordId)
    {
        String productType=[Select id,Product__c from LoanAppl__c where id=:recordId].Product__c;
        mapofContent=new Map<integer,String>();
        LoanAppl__c loanApp=[Select id,BrchCode__c,TotalIMDAmount__c,Total_PF_Amount__c,Rate_Type_Floating_Flag__c,LoanPLRRate__c,ProductSubType__c,LoanPurpose__c,RevisedPF__c,PFInPercentage__c,(SELECT ID ,PF__C,Revised_PF__c FROM Loan_Application_Charges__r WHERE ChargeCodeID__c=:System.Label.PFChargeCodeId LIMIT 1) from LoanAppl__c where id=:recordId];
        
        for(PDF_Generation_Metadata__mdt pdfObj:[select id,Content_Order__c,Content__c,Page_Number__c,Region_Picklist__c,Document_Type__c,Product_Type__c from PDF_Generation_Metadata__mdt where Document_Type__c='Sanction Letter' and Product_Type__c ='Home Loan' ORDER BY Content_Order__c DESC])
        {
            if(pdfObj.Content_Order__c>0){
                mapofContent.put(integer.valueof(pdfObj.Content_Order__c),pdfObj.Content__c);
            }
        }
        
        if(loanApp!=null)
        {
            feesChargesToBeRecieved=loanApp.TotalIMDAmount__c!=null?loanApp.TotalIMDAmount__c:0;
            feesChargesToBeCollected=loanApp.Total_PF_Amount__c!=null?loanApp.Total_PF_Amount__c:0;
            if(feesChargesToBeCollected!=null && feesChargesToBeCollected>0)
            {
                getPaymentDetails(recordId,feesChargesToBeCollected,feesChargesToBeRecieved);
            }
            //typeofFacility=(loanApp.ProductSubType__c!=null?loanApp.ProductSubType__c:'')+'+'+(loanApp.LoanPurpose__c!=null?loanApp.LoanPurpose__c:'');
            if(loanApp.Rate_Type_Floating_Flag__c!=null)
            {
                if(loanApp.Rate_Type_Floating_Flag__c=='Y')
                {
                    typeofInterest='Floating Rate of Interest';
                    //descriptionContent=mapofContent.get(6);
                    showFloatingRate=true;
                    floatingReferenceRate=loanApp.LoanPLRRate__c!=null?string.valueof(loanApp.LoanPLRRate__c):'';
                }
                else if(loanApp.Rate_Type_Floating_Flag__c=='N')
                {
                    typeofInterest='Fixed Rate of Interest';
                    //descriptionContent=mapofContent.get(7);
                }
                descriptionContent=mapofContent.get(7);
            }
            if(loanApp!=null && loanApp.Loan_Application_Charges__r.size()>0 )
            {
                if(loanApp.Loan_Application_Charges__r[0].Revised_PF__c==null)
                {
                    processingFeeforDescription=(loanApp.Loan_Application_Charges__r[0].PF__c!=null?String.format(loanApp.Loan_Application_Charges__r[0].PF__c.format(), args):'0');
                }
                else
                {
                    processingFeeforDescription=(loanApp.Loan_Application_Charges__r[0].Revised_PF__c!=null?String.format(loanApp.Loan_Application_Charges__r[0].Revised_PF__c.format(), args):'0');
                }
            }
            if(loanApp.BrchCode__c != null){
                BankBrchMstr__c branch = [SELECT Id,BrchCode__c,Address__c FROM BankBrchMstr__c WHERE BrchCode__c =: loanApp.BrchCode__c LIMIT 1];

                String newContent = branch != null && String.isNotBlank(branch.Address__c) ? 'Branch Address: ' + branch.Address__c : 'Branch Address: ' ;

                String htmlContent = mapofContent.get(4);

                modifiedContent = htmlContent.replace('<p>Branch Address: ', '<p>' + newContent + '</p>');

            }
        }
        system.debug('mapofContent------------------>'+JSON.serializepretty(mapofContent));
    }
    public void getPaymentDetails(string recordId,decimal pfAmount,decimal ImdAmount)
    {
        List<Payment__c> paymentList=[Select id,TransAmt__c,TransStatus__c,PaytmAPIStatus__c,IntegrationStatus__c,PaymentRefNo__c from Payment__c where TransStatus__c='Success' and LoanAppl__c=:recordId and Type__c='Charges'];
        if(paymentList.size()>0)
        {
            for(Payment__c payObj:paymentList)
            {
                if(payObj.TransAmt__c!=null && payObj.TransAmt__c>0){
                    pfAmount=pfAmount-payObj.TransAmt__c;
                    ImdAmount=ImdAmount+payObj.TransAmt__c;
                }
            }
            feesChargesToBeRecieved=ImdAmount;
            feesChargesToBeCollected=pfAmount;
        }
    }
    public void getSanctionConditions(string recordId)
    {
        conditionList=new List<sanctionWrapper>();
        
        for(Sanction_Conditions__c sanObj:[SELECT Remarks__c, Condition__c, Id, Loan_Application__c FROM Sanction_Conditions__c where Loan_Application__c =:recordId])
        {
            if(sanObj.Condition__c!=null)
            {
                if(!string.isBlank(sanObj.Condition__c))
                {
                    sanctionWrapper sc=new sanctionWrapper();
                    sc.condition=sanObj.Condition__c;
                    sc.remark=sanObj.Remarks__c!=null?sanObj.Remarks__c:'';
                    conditionList.add(sc);
                }
            }
        }
    }
    public void getInsurancePremium(string recordId)
    {
        String applId=[Select Id from Applicant__c where LoanAppln__c=:recordId AND ApplType__c='P' Limit 1].Id;
        decimal sum=0;
        if(!string.isBlank(applId))
        {
            for(Insurance__c insObj:[select Id,IsActive__c,InsType__c,PremiumAmount__c,Appl__c from Insurance__c where IsActive__c = True and Appl__c=:applId and (InsType__c='Life Insurance' OR InsType__c='General Insurance')])
            {
                if(insObj.PremiumAmount__c!=null)
                {
                    if(insObj.InsType__c=='General Insurance')
                    {
                        sum=sum+insObj.PremiumAmount__c;
                    }
                    if(insObj.InsType__c=='Life Insurance')
                    {
                        sum=sum+insObj.PremiumAmount__c;
                    }
                }
            }
        }
        insurancePremium=sum;
    }
    
    Public void getFeesDetails(string recordId){
        /*LoanAppl__c loanApp=[Select id,TotalIMDAmount__c,Total_PF_Amount__c,Rate_Type_Floating_Flag__c from LoanAppl__c where id=:recordId];
if(loanApp!=null)
{
feesChargesToBeRecieved=loanApp.TotalIMDAmount__c!=null?loanApp.TotalIMDAmount__c:0;
feesChargesToBeCollected=loanApp.Total_PF_Amount__c!=null?loanApp.Total_PF_Amount__c:0;
if(loanApp.Rate_Type_Floating_Flag__c!=null)
{
if(loanApp.Rate_Type_Floating_Flag__c=='Y')
{
typeofInterest='Floating Rate of Interest';
}
else if(loanApp.Rate_Type_Floating_Flag__c=='N')
{
typeofInterest='Fixed Rate of Interest';
}
}
}*/
        
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
                Product__c = :product
                AND Type__c = 'KFS Contingent Charges' order by Sequence__c
        ];
        system.debug('masRecForCharges' + masRecForCharges);
        Integer sequence = 2;
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
    class ChargeWrapper {
        public Integer Index { get; set; }
        public String valueOfCharge { get; set; }
        public String DecsOfCharge { get; set; }
    }
    class customerWrapper
    {
        transient public integer serialNumber{get;set;}
        transient public string name{get;set;}
        
    }
    
    class sanctionWrapper
    {
        transient public string condition{get;set;}
        transient public string remark{get;set;}
        
    }
}