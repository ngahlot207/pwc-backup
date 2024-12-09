public class SanctionLetterBTPlusTopUpController {
    transient public String recordId{get;set;}
    transient public String todaysDate{get;set;}
    transient public String allApplicantsNames{get;set;}
    transient public String addressLine1{get;set;}
    transient public String addressLine2{get;set;}
    transient public String cityPincode{get;set;}
    transient public String mobileNumber{get;set;}
    transient public String loanNumber{get;set;}
    transient public String typeofFacility{get;set;}
    transient public String loanAmountSanctioned{get;set;}
    transient public String termofFacility{get;set;}
    transient public String roi{get;set;}
    transient public String security{get;set;}
    transient public String amountofEachEMI{get;set;}
    transient public String dueDiligence{get;set;}
    transient public String processingFee{get;set;}
    transient public List<String> coApplicantIds{get;set;}
    transient public List<integer> oddList{get;set;}
    transient public List<integer> evenList{get;set;}
    transient public Map<Decimal,String> mapofContent{get;set;}
    transient public List<Sanction_Conditions__c> conditionList{get;set;}
    
    public SanctionLetterBTPlusTopUpController(){
        recordId=ApexPages.currentPage().getParameters().get('recordId');
        //recordId='a08C4000007hddDIAQ';
        if(recordId!=null)
        {
            initializeAllVariable();
            getloanApplicationFeilds(recordId);
            setDueDiligenceandProcessingFee(recordId);
            getMetadataforContent(recordId);
            getSanctionConditions(recordId);
        }
    }
    public void initializeAllVariable()
    {
        todaysDate = '';
        allApplicantsNames = '';
        addressLine1 = '';
        addressLine2 = '';
        cityPincode = '';
        mobileNumber = '';
        loanNumber = '';
        typeofFacility = '';
        loanAmountSanctioned = '';
        termofFacility = '';
        roi = '';
        security = '';
        amountofEachEMI = '';
        dueDiligence = '';
        processingFee = '';
        
    }
    public void getloanApplicationFeilds(string recordId) {
        try{
            DateTime dt = Datetime.now();
            string schemeId='';
            List<String> applicantIds=new List<String>();
            coApplicantIds=new List<String>();
            oddList=new List<integer>();
            evenList=new List<integer>();
            todaysDate=dt.format('MMMM')+' '+dt.format('dd')+', '+dt.format('YYYY');
            System.debug('todaysDate ===> '+todaysDate);
            integer count=0;
            for(Applicant__c appObj:[Select id,Title__c,FullName__c,MobNumber__c,ApplType__c,LoanAppln__r.Name,LoanAppln__r.SchemeId__c,LoanAppln__r.SanLoanAmt__c,LoanAppln__r.Loan_Tenure_Months__c,LoanAppln__r.EffectiveROI__c,LoanAppln__r.EMIIcludingInsurance__c from Applicant__c where LoanAppln__c=:recordId AND (ApplType__c='P' OR ApplType__c='G' OR ApplType__c='C')])
            {
                count++;
                system.debug(count);
                if(math.mod(count,2)==0)
                {
                    evenList.add(count);
                }
                else{
                   oddList.add(count);
                }
                applicantIds.add(appObj.id);
                
                loanNumber=!string.isBlank(appObj.LoanAppln__r.Name)?appObj.LoanAppln__r.Name:'';
                schemeId=!string.isBlank(appObj.LoanAppln__r.SchemeId__c)?appObj.LoanAppln__r.SchemeId__c:'';
                loanAmountSanctioned=string.valueof(appObj.LoanAppln__r.SanLoanAmt__c);
                termofFacility=string.valueof(appObj.LoanAppln__r.Loan_Tenure_Months__c);
                roi=string.valueof(appObj.LoanAppln__r.EffectiveROI__c);
                amountofEachEMI=string.valueof(appObj.LoanAppln__r.EMIIcludingInsurance__c);
                if(appObj.Title__c!=null)
                {
                    allApplicantsNames=allApplicantsNames+', '+appObj.Title__c+appObj.FullName__c;
                }
                else
                {
                    allApplicantsNames=allApplicantsNames+', '+appObj.FullName__c;
                }
                system.debug('appObj.ApplType__c----------->'+appObj.ApplType__c);
                if(appObj.ApplType__c=='P')
                {
                    mobileNumber=appObj.MobNumber__c;
                }
                else
                {
                    coApplicantIds.add(appObj.Id);
                }
                //coApplicantIds.add('qwertyui');
                //coApplicantIds.add('qwertyui');
                
            }
            //oddList.add(9);
            //oddList.add(10);
            //evenList.add(8);
            //evenList.add(0);
            system.debug('80'+schemeId);
            if(!string.isBlank(schemeId))
            {
                system.debug('83'+schemeId);
                SchMapping__c schObj=[select id,SchemeDesc__c from SchMapping__c where id=:schemeId];
                typeofFacility=schObj.SchemeDesc__c;
                
            }
            System.debug('typeofFacility ===> '+typeofFacility);
            System.debug('oddList ===> '+oddList);
            System.debug('evenList ===> '+evenList);
            System.debug('allApplicantsNames ===> '+allApplicantsNames);
            System.debug('applicantIds ===> '+applicantIds);
            if(applicantIds.size()>0)
            {
                for(ApplAddr__c addObj:[Select id,MailAddr__c,AddrLine1__c,AddrLine2__c,City__c,Pincode__c from ApplAddr__c where Applicant__c IN:applicantIds])
                {
                    if(addObj.MailAddr__c==true)
                    {
                        System.debug('insideif ===> '+addObj);
                        addressLine1=addObj.AddrLine1__c;
                        addressLine2=addObj.AddrLine2__c;
                        cityPincode=addObj.City__c+' - '+addObj.Pincode__c;
                        break;
                    }
                }
                System.debug('addressLine1 ===> '+addressLine1);
                System.debug('addressLine2 ===> '+addressLine2);
                System.debug('cityPincode ===> '+cityPincode);
                for(ApplAsset__c  assetObj:[SELECT Id, Name, LoanAppln__c,PropAddrs__c FROM ApplAsset__c where LoanAppln__c =:recordId])
                {
                    if(assetObj.PropAddrs__c!=null)
                    {
                        security=security+'<br/>'+assetObj.PropAddrs__c;
                    }
                }
                
                
            }
            
            
        }catch (exception e) {
            system.debug(e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
    public void setDueDiligenceandProcessingFee(string recordId)
    {
        List<LonaApplCharges__c> loanApplistforDiligence=[select id, ChargeCodeID__c,Amount__c from LonaApplCharges__c where ChargeCodeID__c ='600234' Limit 1];
        dueDiligence='Rs.0/- (inclusive of GST) Rs.0/- collected and Rs.0/- to be collected on Disbursement.';
        if(loanApplistforDiligence.size()>0)
        {
            if(loanApplistforDiligence[0].Amount__c>0)
            {
                dueDiligence='Rs.'+loanApplistforDiligence[0].Amount__c+'/- (inclusive of GST) Rs.0/- collected and '+'Rs.'+loanApplistforDiligence[0].Amount__c+'/- to be collected on Disbursement.';
            }            
        }
        
        List<LonaApplCharges__c> loanApplistforProcessingFee=[select id, ChargeCodeID__c,Amount__c from LonaApplCharges__c where ChargeCodeID__c ='600168' Limit 1];
        processingFee='Rs.0/- (inclusive of CERSAI charges of Rs.0/-) Rs.0/- collected and Rs.0/- to be collected on Disbursement.';
        LoanAppl__c loanObj=[Select id,TotalCharges__c,Total_PF_Amount__c,TotalIMDAmount__c  from LoanAppl__c where id=:recordId];
        string cersaiCharges='0';
        if(loanApplistforProcessingFee.size()>0)
        {
            if(loanApplistforProcessingFee[0].Amount__c>0)
            {
                cersaiCharges=string.valueof(loanApplistforProcessingFee[0].Amount__c);
            }            
        }
        if(loanObj!=null)
        {
                processingFee='Rs.'+string.valueof(loanObj.TotalCharges__c>0?loanObj.TotalCharges__c:0)+'/- (inclusive of CERSAI charges of Rs.'+cersaiCharges+'/-) Rs.'+string.valueof(loanObj.TotalIMDAmount__c>0?loanObj.TotalIMDAmount__c:0)+'/- collected and Rs.'+string.valueof(loanObj.Total_PF_Amount__c >0?loanObj.Total_PF_Amount__c :0)+'/- to be collected on Disbursement.';
        }
    }
    public void getMetadataforContent(string recordId)
    {
        String productType=[Select id,Product__c from LoanAppl__c where id=:recordId].Product__c;
        mapofContent=new Map<Decimal,String>();
        for(PDF_Generation_Metadata__mdt pdfObj:[select id,Content_Order__c,Content__c,Page_Number__c,Region_Picklist__c,Document_Type__c,Product_Type__c from PDF_Generation_Metadata__mdt where Document_Type__c='Sanction Letter' and Product_Type__c =:productType ORDER BY Content_Order__c DESC])
        {
            if(pdfObj.Content_Order__c>0){
                mapofContent.put(pdfObj.Content_Order__c,pdfObj.Content__c);
            }
        }
        system.debug('mapofContent------------------>'+JSON.serializepretty(mapofContent));
    }
    public void getSanctionConditions(string recordId)
    {
        conditionList=new List<Sanction_Conditions__c>();
        conditionList=[SELECT Remarks__c, Condition__c, Id, Loan_Application__c FROM Sanction_Conditions__c where Loan_Application__c =:recordId];
         
    }
    
    
}