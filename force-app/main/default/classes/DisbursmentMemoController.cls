public class DisbursmentMemoController {
    transient public String recordId{get;set;}
    transient public String todaysDate{get;set;}
    transient public String currentUserName{get;set;}
    transient public String accountType{get;set;}
    transient public Boolean ProductType{get;set;}
    transient public Boolean isFloating{get;set;}
    transient public AddressWrapper mailingAddress{get;set;}
    transient public Map<String,String> loanApplicationValues{get;set;}
    transient public Map<String,String> chargeDetailsValues{get;set;}
    transient public List<CustomerWrapper> customerList{get;set;}
    transient public List<Disbursement__c> disbursementList{get;set;}
    transient public List<Repayment_Account__c> repaymentList{get;set;}
    transient public List<NACHtWrapper> NACHList{get;set;}
    transient public List<ChequeWrapper> PDCList{get;set;}
    transient public List<ApplAsset__c> propertyList{get;set;}
    transient public List<ChargeWrapper> loanApplistforCERSAI{get;set;}
    transient public List<DisbursmentWrapper> disbursmentWrapperList{get;set;}
    transient public List<PropertyWrapper> propertyWrapperList{get;set;}
    transient public List<caseWrapper> caseWrapperList{get;set;}
    transient public List<DOCWrapper> DocList{get;set;}
    
    public DisbursmentMemoController()
    {
        setUserAndDateTime();
        mailingAddress=new AddressWrapper();
        recordId=ApexPages.currentPage().getParameters().get('recordId');
        if(recordId==null){
            recordId='a03C4000007yHtCIAU'; 
            
        }
        if(recordId!=null)
        {
            
            getLoanDetails(recordId);
            getCustomerDetailsandMailingAddress(recordId);
            getChargesDetails(recordId);
            getDisbursmentDetails(recordId);
            getRepaymentDetails(recordId);
            getNACHDetails(recordId);
            getPDCDetails(recordId);
            getPropertyDetails(recordId);
            getFIPVdetails(recordId);
            getBREData(recordId);
            getDisbursmentAmount(recordId);
            getlodDetails(recordId);
        }
        
    }
    public void setUserAndDateTime()
    {
        Id userId =UserInfo.getUserId(); 
        User currentUser = [SELECT FirstName, LastName FROM User WHERE Id =: userId];
        currentUserName=' '+(currentUser.FirstName!=null?currentUser.FirstName:'')+' '+(currentUser.LastName!=null?currentUser.LastName:'');
        DateTime myDateTime = DateTime.now();
        String formattedDate = myDateTime.format('dd-MMM-yyyy');
        String formattedTime = myDateTime.format('hh:mm a');
        todaysDate=formattedDate + ' ' + formattedTime;
        //system.debug('Actual Time as String ' + dt.format()); 
    }
    
    public void getDisbursmentAmount(string recordId)
    {
        List<Disbursement__c> listDisburs=[Select Total_Disb_Amt__c,Loan_Appli__c , Loan_Appli__r.Final_Loan_Disbursal_Amount__c, DisbrDiscription__c from Disbursement__c where Loan_Appli__c=:recordId AND DisbrDiscription__c='TRANCHE-1'];
        loanApplicationValues.put('Disbursement Amount','');
        if(listDisburs.size()>0)
        {
            loanApplicationValues.put('Disbursement Amount',(listDisburs[0].Loan_Appli__c!=null && listDisburs[0].Loan_Appli__r.Final_Loan_Disbursal_Amount__c!=null) ?formatIndianCurrency(listDisburs[0].Loan_Appli__r.Final_Loan_Disbursal_Amount__c):'');
        }
    }
    public void getLoanDetails(string recordId)
    {
        loanApplicationValues =new Map<String,String>();
        LoanAppl__c loanApp=[Select id,Product__c,Final_MSME__c,Name,Rate_Type_Floating_Flag__c,FinnoneAppid__c,Final_Industry_for_RBI__c,currentDateorFinnOneDate__c,(select id,Date_of_Disbur__c from Disbursements__r),ChanelNme__r.Name,toLabel(Installment_Plan__c),SchmCode__c,SpreadID__c,ProductSubType__c,LoanPLRRate__c,FirstEMIDate__c,TotalLoanAmtInclInsurance__c,Loan_Tenure_Months__c,BrchName__c,BrchCode__c,EMIIcludingInsurance__c,Total_PF_Amount__c,TotalIMDAmount__c,EffectiveROI__c from LoanAppl__c where id=:recordId];
        system.debug('loanApp------------->'+loanApp);
        if(loanApp!=null)
        {
            loanApplicationValues.put('Name',loanApp.FinnoneAppid__c!=null?loanApp.FinnoneAppid__c+' - '+loanApp.Name:'');
            loanApplicationValues.put('MSME',loanApp.Final_MSME__c!=null?loanApp.Final_MSME__c:'');
            if(loanApp.Rate_Type_Floating_Flag__c!=null && loanApp.Rate_Type_Floating_Flag__c=='Y'){
                isFloating=true;
            }
            //loanApplicationValues.put('Disbursal Date',loanApp.Disbursements__r.size() >0 && loanApp.Disbursements__r[0].Date_of_Disbur__c!=null?string.valueof(loanApp.Disbursements__r[0].Date_of_Disbur__c.day()+'/'+loanApp.Disbursements__r[0].Date_of_Disbur__c.month()+'/'+loanApp.Disbursements__r[0].Date_of_Disbur__c.year()):'');
            loanApplicationValues.put(
                'Disbursal Date',
                loanApp.Disbursements__r.size() > 0 && loanApp.Disbursements__r[0].Date_of_Disbur__c != null ?
                Datetime.newInstance(
                    loanApp.Disbursements__r[0].Date_of_Disbur__c.year(),
                    loanApp.Disbursements__r[0].Date_of_Disbur__c.month(),
                    loanApp.Disbursements__r[0].Date_of_Disbur__c.day()
                ).format('dd-MMM-yyyy') :
                ''
            );
            loanApplicationValues.put('Channel Name',loanApp.ChanelNme__r.Name!=null?loanApp.ChanelNme__r.Name:'');
            loanApplicationValues.put('PSL','');
            loanApplicationValues.put('Category',loanApp.ProductSubType__c!=null?loanApp.ProductSubType__c:'');
            loanApplicationValues.put('Line of Business',loanApp.Final_Industry_for_RBI__c!=null?loanApp.Final_Industry_for_RBI__c:'');
            loanApplicationValues.put('Spread',loanApp.SpreadID__c!=null?string.valueof(loanApp.SpreadID__c):'');
            loanApplicationValues.put('PLR',loanApp.LoanPLRRate__c!=null?string.valueof(loanApp.LoanPLRRate__c):'');
            loanApplicationValues.put('ROI',loanApp.EffectiveROI__c!=null?string.valueof(loanApp.EffectiveROI__c):'');
            //loanApplicationValues.put('EMI Start Date',loanApp.FirstEMIDate__c!=null?string.valueof(loanApp.FirstEMIDate__c.day()+'/'+loanApp.FirstEMIDate__c.month()+'/'+loanApp.FirstEMIDate__c.year()):'');
            
            loanApplicationValues.put(
                'EMI Start Date',
                loanApp.FirstEMIDate__c!=null ?
                Datetime.newInstance(
                    loanApp.FirstEMIDate__c.year(),
                    loanApp.FirstEMIDate__c.month(),
                    loanApp.FirstEMIDate__c.day()
                ).format('dd-MMM-yyyy') :
                ''
            );
            
            
            
            loanApplicationValues.put(
                'Date',
                Datetime.now().format('dd-MMM-yyyy')
            );
            loanApplicationValues.put('Product',loanApp.Product__c!=null?loanApp.Product__c:'');
           // ProductType=loanApp.Product__c!=null?loanApp.Product__c:'';
            if(loanApp.Product__c!=null){
                if(loanApp.Product__c=='Business Loan' || loanApp.Product__c=='Personal Loan'){
                    ProductType=false;
                }
                else{
                    ProductType=true;
                }
            }
            loanApplicationValues.put('Scheme Code',loanApp.SchmCode__c!=null?loanApp.SchmCode__c:'');
            loanApplicationValues.put('Linked Loans','');
            loanApplicationValues.put('Installment Type',loanApp.Installment_Plan__c!=null?loanApp.Installment_Plan__c:'');
            loanApplicationValues.put('EMI',loanApp.EMIIcludingInsurance__c!=null?formatIndianCurrency(loanApp.EMIIcludingInsurance__c):'');
            loanApplicationValues.put('Loan Amount',loanApp.TotalLoanAmtInclInsurance__c!=null?formatIndianCurrency(loanApp.TotalLoanAmtInclInsurance__c):'');
            //loanApplicationValues.put('Interest Date',loanApp.Disbursements__r.size() > 0  && loanApp.Disbursements__r[0].Date_of_Disbur__c!=null?string.valueof(loanApp.Disbursements__r[0].Date_of_Disbur__c.day()+'/'+loanApp.Disbursements__r[0].Date_of_Disbur__c.month()+'/'+loanApp.Disbursements__r[0].Date_of_Disbur__c.year()):'');
            loanApplicationValues.put(
                'Interest Date',
                loanApp.currentDateorFinnOneDate__c != null ?
                Datetime.newInstance(
                    loanApp.currentDateorFinnOneDate__c.year(),
                    loanApp.currentDateorFinnOneDate__c.month(),
                    loanApp.currentDateorFinnOneDate__c.day()
                ).format('dd-MMM-yyyy') :
                ''
            );
            
            loanApplicationValues.put('Tenor', loanApp.Loan_Tenure_Months__c!=null?string.valueof(loanApp.Loan_Tenure_Months__c):'');
            //loanApplicationValues.put('Disbursement Amount',loanApp.TotalLoanAmtInclInsurance__c!=null?formatIndianCurrency(loanApp.TotalLoanAmtInclInsurance__c):'');
            loanApplicationValues.put('Branch Name',loanApp.BrchName__c);
            
            
            //charge details
            loanApplicationValues.put('Processing Fees',loanApp.Total_PF_Amount__c!=null?string.valueof(loanApp.Total_PF_Amount__c):'');
            loanApplicationValues.put('Total Initial Pay',loanApp.TotalIMDAmount__c!=null?formatIndianCurrency(loanApp.TotalIMDAmount__c):'');
            String temp='';
            integer count=1;
            List<DedupeResponse__c> dedupeList=[Select id,Lan__c from DedupeResponse__c where LoanAppln__c=:recordId AND RecordType.name = 'ENPA' and IsLatest__c = True AND Loantobelinkedwithproposedloan__c='Yes'];
            if(dedupeList.size()>0)
            {
                for(DedupeResponse__c dedObj:dedupeList)
                {
                    if(count==dedupeList.size())
                    {
                        temp=loanApplicationValues.get('Linked Loans')+(dedObj.Lan__c!=null?dedObj.Lan__c:'');
                    }
                    else
                    {
                        temp=loanApplicationValues.get('Linked Loans')+(dedObj.Lan__c!=null?dedObj.Lan__c+', ':'');
                    }
                    count++;
                    loanApplicationValues.put('Linked Loans',temp);              
                }
            }
            
            
            
        }
        system.debug('loanApplicationValues-------------->'+JSON.serializepretty(loanApplicationValues));
    }
    
    public void getCustomerDetailsandMailingAddress(string recordId)
    {
        customerList=new List<CustomerWrapper>();
        List<String> applicantIds=new List<String>();
        integer count=1;
        for(Applicant__c appObj:[Select id,(SELECT Id from ApplAssetJn__r),FullName__c,ApplType__c,Age__c,Constitution__c from Applicant__c where LoanAppln__c=:recordId AND (ApplType__c='P' OR ApplType__c='G' OR ApplType__c='C')])
        {
            applicantIds.add(appObj.id);            
            CustomerWrapper cw=new CustomerWrapper();
            cw.Name=appObj.FullName__c!=null?appObj.FullName__c:'';
            cw.type=appObj.ApplType__c!=null?appObj.ApplType__c:'';
            if(appObj.ApplType__c=='P')
            {
                cw.type='Applicant';
            }
            else if(appObj.ApplType__c=='C')
            {
                cw.type='Co-Applicant '+count;
                count++;
            }
            else if(appObj.ApplType__c=='G')
            {
                cw.type='Guarantor';
            }
            cw.age=string.valueof(appObj.Age__c);
            cw.Constitution=appObj.Constitution__c!=null?appObj.Constitution__c:'';
            if(appObj.ApplAssetJn__r.size()>0)
            {
                cw.propertyowner='Yes';
            }
            else
            {
                cw.propertyowner='No';
            }
            customerList.add(cw);
        }
        
        if(applicantIds.size()>0)
        {
            for(ApplAddr__c addObj:[Select id,MailAddr__c,AddrLine1__c,AddrLine2__c,City__c,Pincode__c,State__c,Applicant__r.MobNumber__c,HouseNo__c from ApplAddr__c where Applicant__c IN:applicantIds])
            {
                if(addObj.MailAddr__c==true)
                {
                    System.debug('insideif ===> '+addObj);
                    //mailingAddress.MailAdd=addObj.MailAddr__c;
                    mailingAddress.AddrLine1=addObj.AddrLine1__c;
                    mailingAddress.AddrLine2=addObj.AddrLine2__c;
                    mailingAddress.City=addObj.City__c;
                    mailingAddress.Pincode=addObj.Pincode__c;
                    mailingAddress.State=addObj.State__c; 
                    mailingAddress.MobNumber=addObj.Applicant__r.MobNumber__c; 
                    mailingAddress.HouseNo=addObj.HouseNo__c;
                    break;
                    
                }
                system.debug('mailingAddress------------>'+mailingAddress);
            }
        }
    }
    
    public void getChargesDetails(string recordId)
    {
        chargeDetailsValues=new Map<String,String>();
        loanApplistforCERSAI=new List<ChargeWrapper>();
        for(LonaApplCharges__c loanObj:[select id, ChargeCodeDesc__c,ChargeCodeID__c,Amount__c,EffeChrgeAmt__c from LonaApplCharges__c where LoanApplication__c =:recordId])
        {
            ChargeWrapper chargObj=new ChargeWrapper();
            chargObj.ChargeCodeDesc=loanObj.ChargeCodeDesc__c!=null?loanObj.ChargeCodeDesc__c:'';
            chargObj.EffectiveChargeAmount=loanObj.EffeChrgeAmt__c!=null?loanObj.EffeChrgeAmt__c:0;
            loanApplistforCERSAI.add(chargObj);
        }
        LoanAppl__c loanApp=[Select InsAmt__c,TotalIMDAmount__c,InsPremimtobededfromdisamt__c from LoanAppl__c where id=:recordId];
        if(loanApp!=null)
        {
            chargeDetailsValues.put('Total Initial Pay',loanApp.TotalIMDAmount__c!=null?string.valueof(loanApp.TotalIMDAmount__c):'');
            chargeDetailsValues.put('Insurance Funded','0');
            chargeDetailsValues.put('Insurance Funded by Customer','0');
            if(loanApp.InsPremimtobededfromdisamt__c=='Y')
            {
                chargeDetailsValues.put('Insurance Funded',loanApp.InsAmt__c!=null?formatIndianCurrency(loanApp.InsAmt__c):'0');
                chargeDetailsValues.put('Insurance Funded by Customer','0');
            }
            else if(loanApp.InsPremimtobededfromdisamt__c=='N')
            {
                chargeDetailsValues.put('Insurance Funded by Customer',loanApp.InsAmt__c!=null?formatIndianCurrency(loanApp.InsAmt__c):'0');
                chargeDetailsValues.put('Insurance Funded','0');
            }
        }
        //Insurance__c insObj=[Select id,InsProvider__c from Insurance__c where LoanAppln__c=:recordId]
        // if(insObj!=null)
        // {
        //  chargeDetailsValues.put('Insurance Funded by Customer',)
        // }
        
    }
    
    public void getDisbursmentDetails(string recordId){
        disbursementList=new List<Disbursement__c>();
        disbursmentWrapperList=new List<DisbursmentWrapper>();
        //system.debug('disbursementList----------->'+disbursementList);
        //disbursementList=[Select Date_of_Disbur__c,(Select id,Cheq_Favor_Dets__c,Split_Cheque_Amt__c,Cheq_Favor_Acc_No__c,Payable_At__c,Pay_Mode__c,Cheq_DD_No__c,Cheq_DD_Date__c from Split_Disbursements__r) from Disbursement__c where Loan_Appli__c=:recordId];
        for(Disbursement__c dcObj:[Select Date_of_Disbur__c,DisbrDiscription__c,(Select id,Cheq_Favor_Dets__c,Split_Cheque_Amt__c,Cheq_Favor_Acc_No__c,Payable_At__c,Pay_Mode__c,Cheq_DD_No__c,Cheq_DD_Date__c from Split_Disbursements__r) from Disbursement__c where Loan_Appli__c=:recordId])
        {
            //system.debug('dcObj--Split_Disbursements__r------------->'+dcObj.Split_Disbursements__r);
            if(dcObj.Split_Disbursements__r !=null && dcObj.Split_Disbursements__r.size()>0 ){
                for(Split_Disbur__c splitObj:dcObj.Split_Disbursements__r)
                {
                    DisbursmentWrapper dp=new DisbursmentWrapper();
                    dp.TrancheDetails=dcObj.DisbrDiscription__c!=null?dcObj.DisbrDiscription__c:'';
                    dp.Favouring=splitObj.Cheq_Favor_Dets__c!=null?splitObj.Cheq_Favor_Dets__c:'';
                    dp.ChequeTransferAmount=splitObj.Split_Cheque_Amt__c!=null?formatIndianCurrency(splitObj.Split_Cheque_Amt__c):'';
                    dp.DisbursementDate=Datetime.newInstance(
                        dcObj.Date_of_Disbur__c.year(),
                        dcObj.Date_of_Disbur__c.month(),
                        dcObj.Date_of_Disbur__c.day()).format('dd-MMM-yyyy');
                    dp.BankAccount=splitObj.Cheq_Favor_Acc_No__c!=null?splitObj.Cheq_Favor_Acc_No__c:'';
                    dp.PayableAt=splitObj.Payable_At__c!=null?splitObj.Payable_At__c:'';
                    dp.PaymentMode=splitObj.Pay_Mode__c!=null?splitObj.Pay_Mode__c:'';
                    dp.ChequeNo=splitObj.Cheq_DD_No__c!=null?splitObj.Cheq_DD_No__c:'';
                    dp.ChequeDate=splitObj.Cheq_DD_Date__c!=null?Datetime.newInstance(
                        splitObj.Cheq_DD_Date__c.year(),
                        splitObj.Cheq_DD_Date__c.month(),
                        splitObj.Cheq_DD_Date__c.day()).format('dd-MMM-yyyy'):'';
                    disbursmentWrapperList.add(dp);
                }
                
            }
            
        }
        system.debug('disbursmentWrapperList----------->'+disbursmentWrapperList);
    }
    
    private String formatIndianCurrency(Decimal amount) {
        
        String formattedAmount = amount.setScale(1).format();
        
        return formattedAmount;
        
    }
    
    public void getRepaymentDetails(string recordId){
        accountType='';
        repaymentList=new List<Repayment_Account__c>();
        repaymentList=[Select Repayment_Mode__c,AccHolderName__c,Applicant_Banking__r.AccountType__c,Bank_Name__c,Bank_Branch__c,Account_Number__c from Repayment_Account__c where Loan_Application__c=:recordId AND Is_Active__c=true];
        //= [Select AccountType__c from ApplBanking__c where LoanAppl__c=:recordId Limit 1];
        if(!repaymentList.isEmpty()){
            accountType = repaymentList[0].Applicant_Banking__r.AccountType__c!=null?repaymentList[0].Applicant_Banking__r.AccountType__c:'';
        }
        //accountType=[Select AccountType__c from ApplBanking__c where LoanAppl__c=:recordId Limit 1].AccountType__c;
    }
    
    public void getNACHDetails(string recordId){
        NACHList=new List<NACHtWrapper>();
        
        for(NACH__c nachObj:[Select UMRN__c,Debit_Type__c,MICR_Code__c,amount_numbers__c,Frequency__c,Account_Type__c,From_Date__c from NACH__c where LoanAppl__c=:recordId AND IsActive__c=true])
        {
            NACHtWrapper nachWrp=new NACHtWrapper();
            nachWrp.UMRN=nachObj.UMRN__c!=null?nachObj.UMRN__c:'';
            nachWrp.DebitType=nachObj.Debit_Type__c!=null?nachObj.Debit_Type__c:'';
            nachWrp.MICRCode=nachObj.MICR_Code__c!=null?nachObj.MICR_Code__c:'';
            nachWrp.AmountNumbers=nachObj.amount_numbers__c!=null?nachObj.amount_numbers__c:0;
            nachWrp.Frequency=nachObj.Frequency__c!=null?nachObj.Frequency__c:'';
            nachWrp.AccountType=nachObj.Account_Type__c!=null?nachObj.Account_Type__c:'';
            nachWrp.FromDate=nachObj.From_Date__c!=null?Datetime.newInstance(
                nachObj.From_Date__c.year(),
                nachObj.From_Date__c.month(),
                nachObj.From_Date__c.day()).format('dd-MMM-yyyy'):'';
            nachWrp.ToDate=nachObj.From_Date__c!=null?Datetime.newInstance(
                nachObj.From_Date__c.year(),
                nachObj.From_Date__c.month(),
                nachObj.From_Date__c.day()).addyears(30).format('dd-MMM-yyyy'):'';
            NACHList.add(nachWrp);
        }
    }
    public void getPDCDetails(string recordId){
        PDCList=new List<ChequeWrapper>();
        for(PDC__c pdObj:[Select Cheque_Purpose__c,Cheque_Number_From__c,Cheque_Number_To__c,Cheque_Amount__c,Name,Account_No__c,No_of_Cheques__c,Repayment_Account__r.Applicant_Banking__r.Appl__r.FullName__c,Repayment_Account__r.Account_Number__c,PDC_Type__c from PDC__c where Loan_Application__c=:recordId AND Repayment_Account__r.Is_Active__c=true])
        {
            ChequeWrapper cheqObj=new ChequeWrapper();
            cheqObj.ChequePurpose=pdObj.Cheque_Purpose__c!=null?pdObj.Cheque_Purpose__c:'';
            cheqObj.ChequeNumberFrom=pdObj.Cheque_Number_From__c!=null?pdObj.Cheque_Number_From__c:'';
            cheqObj.ChequeNumberTo=pdObj.Cheque_Number_To__c!=null?pdObj.Cheque_Number_To__c:'';
            cheqObj.ChequeAmount=pdObj.Cheque_Amount__c!=null?pdObj.Cheque_Amount__c:0;
            if(pdObj.PDC_Type__c=='PDC')
            {
                cheqObj.AccountNo=pdObj.Repayment_Account__r.Account_Number__c!=null?pdObj.Repayment_Account__r.Account_Number__c:'';
            }
            else if(pdObj.PDC_Type__c=='SPDC')
            {
                cheqObj.AccountNo=pdObj.Account_No__c!=null?pdObj.Account_No__c:'';            
            }
            
            cheqObj.NoOfCheques=pdObj.No_of_Cheques__c!=null?pdObj.No_of_Cheques__c:0;
            cheqObj.ApplicantFullName=pdObj.Repayment_Account__r.Applicant_Banking__r.Appl__r.FullName__c;
            PDCList.add(cheqObj);
            
        }
    }
    
    public void getPropertyDetails(string recordId)
    {
        decimal LTVwithoutInsurance=0;
        propertyList=new List<ApplAsset__c>();
        propertyWrapperList=new List<PropertyWrapper>();
        //propertyList=[Select PropAddrs__c,Land_Valu__c,ApproxValue__c,Agrem_Value__c,Stamp_Duty__c,Amenities__c,Total_Valua__c,(select id,LTVApplWDeviation__c,IsLatest__c from BRE_Responses__r where IsLatest__c=true) from ApplAsset__c where LoanAppln__c=:recordId];
        for(ApplAsset__c assObj:[Select PropAddrs__c,Land_Valu__c,Total_estimate_as_per_architect_agreemen__c,Total_Prop_Cost__c,Agrem_Value__c,Stamp_Duty__c,Amenities__c,Total_Valua__c,ValuationToBeTakenAheadForCalculation__c,(select id,LTVApplWDeviation__c,LTVApplLnWOInsurance__c,IsLatest__c,Actual_LTV__c,LTVApplLnWtInsurance__c from BRE_Responses__r where EligibilityType__c = 'Property' and IsLatest__c = true),(select Id,DateofVisit__c,Date_of_Report__c,ExpiryDate__c,Total_Valuation_Land_Valuation_B__c,Status,RecordTypeId,recordtype.name,IsCompleted__c,ReportResult__c,Property_Visit_Final_Status__c,Assigned_To__r.name from cases__r ) from ApplAsset__c where LoanAppln__c=:recordId])
        {
            PropertyWrapper wrapObj=new PropertyWrapper();
            wrapObj.PropAddr=string.valueof(assObj.PropAddrs__c);
            wrapObj.LandValue=assObj.Land_Valu__c!=null?formatIndianCurrency(assObj.Land_Valu__c):'';
            wrapObj.ApproxValue=assObj.Total_estimate_as_per_architect_agreemen__c!=null?formatIndianCurrency(assObj.Total_estimate_as_per_architect_agreemen__c):'';
            wrapObj.AgremValue=assObj.Total_Prop_Cost__c!=null?formatIndianCurrency(assObj.Total_Prop_Cost__c):'';
            wrapObj.StampDuty=assObj.Stamp_Duty__c!=null?formatIndianCurrency(assObj.Stamp_Duty__c):'';
            wrapObj.Amenities=assObj.Amenities__c!=null?formatIndianCurrency(assObj.Amenities__c):'';
            wrapObj.TotalValue=assObj.Total_Valua__c!=null?formatIndianCurrency(assObj.Total_Valua__c):'';
            if(assObj.cases__r.size()>0)
            {
                list<case> casesRecord = assObj.cases__r;
                Integer i=0;
                for (case c: casesRecord) {
                    
                    if(c.recordType.name =='Technical' && c.status=='Closed' && c.ExpiryDate__c > Date.Today()){
                        if(i==0){
                            wrapObj.technical1 =c.Total_Valuation_Land_Valuation_B__c!=null?formatIndianCurrency(c.Total_Valuation_Land_Valuation_B__c):'';
                        }else if(i == 1){
                            wrapObj.technical2 =c.Total_Valuation_Land_Valuation_B__c!=null?formatIndianCurrency(c.Total_Valuation_Land_Valuation_B__c):'';
                        }else if(i==2){
                            wrapObj.technical3 =c.Total_Valuation_Land_Valuation_B__c!=null?formatIndianCurrency(c.Total_Valuation_Land_Valuation_B__c):'';
                        }
                        i++;
                    }
                }
            }
            wrapObj.ValuetoBetaken=assObj.ValuationToBeTakenAheadForCalculation__c!=null?formatIndianCurrency(assObj.ValuationToBeTakenAheadForCalculation__c):'';
            if(assObj.BRE_Responses__r.size()>0)
            {
                //LAk-8267 Nagarjuna
                wrapObj.LTV=assObj.BRE_Responses__r[0].LTVApplLnWtInsurance__c!=null?string.valueof(assObj.BRE_Responses__r[0].LTVApplLnWtInsurance__c):'0';
               // wrapObj.LTV=assObj.BRE_Responses__r[0].LTVApplLnWOInsurance__c!=null?string.valueof(assObj.BRE_Responses__r[0].LTVApplLnWOInsurance__c):'0';

                //LTVwithoutInsurance=LTVwithoutInsurance+(assObj.BRE_Responses__r[0].LTVApplLnWOInsurance__c!=null?assObj.BRE_Responses__r[0].LTVApplLnWOInsurance__c:0);
            }
            propertyWrapperList.add(wrapObj);
        }
        
        
    }
    public void getFIPVdetails(string recordId){
        caseWrapperList=new List<caseWrapper>();
        for(ApplAsset__c assObj:[Select PropAddrs__c,(select id,Property_Visit_Final_Status__c,NameofCredOfficer__c from Cases__r where recordtype.developername='CollateralVisit' Order by createddate ASC Limit 1) from ApplAsset__c where LoanAppln__c=:recordId])
        {
            caseWrapper caObj=new caseWrapper();
            if(assObj.Cases__r.size()>0)
            {
                caObj.Property_Visit_Final_Status=assObj.Cases__r[0].Property_Visit_Final_Status__c!=null?assObj.Cases__r[0].Property_Visit_Final_Status__c:'';
                caObj.NameofCredOfficer=assObj.Cases__r[0].NameofCredOfficer__c!=null?assObj.Cases__r[0].NameofCredOfficer__c:'';
                caObj.PropAddrs=assObj.PropAddrs__c!=null?assObj.PropAddrs__c:'';
                caseWrapperList.add(caObj);
            }
        }
    }
    public void getBREData(string recordId){
        //List<BRE__c> breObjList=[Select id,LoanAppl__c,LTVApplLnWOInsurance__c,ActualLTVWithoutInsur__c from BRE__c where EligibilityType__c='Property' AND LoanAppl__c=:recordId and IsLatest__c=true];
        //LAK-8267
        List<BRE__c> breObjList=[SELECT Id, LoanAppl__c, Actual_FOIR__c, Actual_LTV__c FROM BRE__c where LoanAppl__c=:recordId AND IsLatest__c=true AND EligibilityType__c = 'Application'];
 
        string ltvIns='';
        if(breObjList.size()>0)
        {
           // ltvIns=breObjList[0].ActualLTVWithoutInsur__c!=null?string.valueof(breObjList[0].ActualLTVWithoutInsur__c.setScale(2)):'';
           //LAK-8267
           ltvIns=breObjList[0].Actual_LTV__c!=null?string.valueof(breObjList[0].Actual_LTV__c.setScale(2)):'';
        }
        loanApplicationValues.put('LTV without Insurance',ltvIns);
        
    }
     public void getlodDetails(string recordId){
        DocList=new List<DOCWrapper>();
         list<DocDtl__c>  listLOD = [select id,DevLvl__c,DocDes__c, Rmrk__c,DocSubTyp__c, OriDoc__c,Originals__c,DocCatgry__c, DocStatus__c from DocDtl__c where LAN__c=:recordId and DocStatus__c in ('OTC','PDD') and DocTyp__c='Disbursal Documents'];
            if (listLOD.size()>0) {
                 for(DocDtl__c Docdtl: listLOD){
                      DOCWrapper DOCWpr=new DOCWrapper();
                     
                    // DOCWpr.Description=Docdtl.DocSubTyp__c;
                    /* if(Docdtl.Rmrk__c !=null){
                        DOCWpr.Description=Docdtl.Rmrk__c;
                    }else{
                        DOCWpr.Description=Docdtl.DocSubTyp__c; 
                    }   */
                   /* if(Docdtl.Originals__c ==true){
                        DOCWpr.OriginalPhoto = 'Original';
                    }else{
                        DOCWpr.OriginalPhoto = 'Photocopy'; 
                    }  */
                     DOCWpr.DOCName=Docdtl.DocSubTyp__c; 
                     DOCWpr.Description=Docdtl.Rmrk__c;
                     DOCWpr.OriginalPhoto =Docdtl.OriDoc__c;
                     DOCWpr.Status=Docdtl.DocStatus__c;
                     DOCWpr.ApprovalLevel=Docdtl.DevLvl__c;
                    DocList.add(DOCWpr);
                     system.debug('DocList'+DocList);
                 }
            }
    }
    
    class DOCWrapper
    {
        transient public string DOCName{get;set;}
        transient public string Description{get;set;}
        transient public string OriginalPhoto{get;set;}
        transient public string Status{get;set;}
        transient public string ApprovalLevel{get;set;}
        
        
    }
    public class CustomerWrapper {
        public String Name {get; set;}
        public String type {get; set;}
        public String age {get; set;}
        public String Constitution {get; set;}
        public String propertyowner {get; set;}
    }
    
    public class DisbursmentWrapper {
        public String TrancheDetails  {get; set;}
        public String Favouring {get; set;}
        public String ChequeTransferAmount {get; set;}
        public string DisbursementDate{get; set;}
        public String BankAccount {get; set;}
        public String PayableAt {get; set;}
        public String PaymentMode {get; set;}
        public String ChequeNo {get; set;}
        public String ChequeDate {get; set;}
    }
    public class PropertyWrapper
    {
        public String LTV {get; set;}
        public String PropAddr {get; set;}
        public String LandValue {get; set;}
        public String ApproxValue {get; set;}
        public String AgremValue {get; set;}
        public String StampDuty {get; set;}
        public String Amenities {get; set;}
        public String TotalValue {get; set;}
        public String ValuetoBetaken {get; set;}
        public String technical1 {get; set;}
        public String technical2 {get; set;}
        public String technical3 {get; set;}
        
    }
    
    public class caseWrapper
    {
        public String Property_Visit_Final_Status {get; set;}
        public String NameofCredOfficer {get; set;}
        public String PropAddrs {get; set;}
    }
    
    public class NACHtWrapper {
        
        public String UMRN { get; set; }
        public String DebitType { get; set; }
        public String MICRCode { get; set; }
        public Decimal AmountNumbers { get; set; }
        public String Frequency { get; set; }
        public String AccountType { get; set; }
        public string FromDate { get; set; }
        public string ToDate { get; set; }
    }
    
    public class ChargeWrapper {
        
        public String ChargeCodeDesc { get; set; }
        public String ChargeCodeID { get; set; }
        public Decimal Amount { get; set; }
        public Decimal EffectiveChargeAmount { get; set; }
    }
    
    public class ChequeWrapper {
        
        public String ChequePurpose { get; set; }
        public String ChequeNumberFrom { get; set; }
        public String ChequeNumberTo { get; set; }
        public Decimal ChequeAmount { get; set; }
        public String Name { get; set; }
        public String AccountNo { get; set; }
        public Decimal NoOfCheques { get; set; }
        public String ApplicantFullName { get; set; }
    }
    
    public class AddressWrapper {
        public String MailAdd { get; set; }
        public String AddrLine1 { get; set; }
        public String AddrLine2 { get; set; }
        public String City { get; set; }
        public String Pincode { get; set; }
        public String State { get; set; }
        public String MobNumber { get; set; }
        public String HouseNo { get; set; }
    }
    
}