public without sharing class HLandLAPCamReport {
    transient public String recordId{get;set;}
    transient public list<loanAppl__c> loanApplData{get;set;}
    transient public list<AggregateResult> applicantBankingDetailData{get;set;}
    transient public list<AggregateResult> applicantBankingDetailDataODCC{get;set;}
    transient public Map<string, string> minBalanceChargeMap{get;set;}
    transient public Map<string, decimal> AvgBalanceMap{get;set;}
    transient public list<BureauRespDtl__c> lstObligationDetails{get;set;}
    transient public list<Bureau__c> lstObligationDetailsBureau{get;set;}
    transient public list<Applicant__c> BorrowerDetails{get;set;}
    transient public list<Applicant__c> GstDetails{get;set;}
    transient public list<ApplAsset__c> listCollateralVisitDetails{get;set;}
    transient public list<Sanction_Conditions__c> SanctionConditionDetail{get;set;}
    transient public list<ApplicantEmployment__c> ApplicantEmploymentDetail{get;set;}
    transient public list<Deviation__c> DeviationDetail{get;set;}
    transient public String maxValueSubProperty{get;set;}
    transient public String PropertyType{get;set;}
    transient public String PropertyUsage{get;set;}
    transient public String loanToRelativeCheck{get;set;}
    transient public List<ApplAsset__c> propType{get;set;}
    transient public List<SchMapping__c> schemeName{get;set;}
    transient public List<TeamHierarchy__c> EmpName{get;set;}
    transient public List<BankBrchMstr__c> BranchCity{get;set;}
    transient public List<DedupeResponse__c> pastLan{get;set;}
    transient public List<DedupeResponse__c> lstLinkedLoan{get;set;}
    transient public List<LoanAppeal__c> BusinessPricing{get;set;}
    transient public String SecurityStatusCheck{get;set;}
    transient public String Userdetail{get;set;}
    transient public String CurrentDate{get;set;}
    transient public string formattedDate{get;set;}
    transient public Decimal TotalLoanAmount{get;set;}
    transient public String natureOfBusinessIndv{get;set;}
    transient public String ESGNegative{get;set;}
    transient public String imdStatuss{get;set;}
    transient public String MSMEcategorisation{get;set;}
    transient public String urcUACNumber{get;set;}
    transient public list<String> Linkedloans{get;set;}
    transient public string pastLanStr{get;set;}
    transient public string BTFinancier{get;set;}
    transient public String uw{get;set;}
    transient public String approver{get;set;}
    transient public String applicantName{get;set;}

  //  transient public list<UWDecision__c> listDecisionSummary{get;set;}
    transient public List<getCollateralVerificationDetailsWrapper> colWrapper{get;set;}
    transient public List<getBorrowerVerificationDetailWrapper> borrowWrapper{get;set;}
    transient public List<getBorrowerFinalCPVSummaryDetailsWrapper> finalCPVWrapper{get;set;}
    transient public List<getBorrowerDetailsWrapper> borrowerDetailsWrapper{get;set;}
    transient public List<HLRelatedDetailsWrapper> HLRelatedDetailsWrapperData{get;set;}
    transient public List<ConstructionRelatedDetailsWrapper> ConstructionRelatedDetailsWrapperData{get;set;}

    transient public decimal TotalVSD{get;set;}
    transient public decimal TotalVSC{get;set;}
    transient public decimal TotalCD{get;set;}
    transient public decimal TotalCC{get;set;}
    transient public decimal TotalIRC{get;set;}
    transient public decimal TotalORC{get;set;}
    transient public decimal TotalSPC{get;set;}
    transient public decimal TotalAverage{get;set;}
    transient public decimal VSDAvg{get;set;}
    transient public decimal VSCAvg{get;set;}
    transient public decimal CCAvg{get;set;}
    transient public decimal CDAvg{get;set;}
    transient public decimal IRCAvg{get;set;}
    transient public decimal ORCAvg{get;set;}
    transient public decimal SPCAvg{get;set;}
    transient public decimal TotalVSD1{get;set;}
    transient public decimal TotalVSC1{get;set;}
    transient public decimal TotalCD1{get;set;}
    transient public decimal TotalCC1{get;set;}
    transient public decimal TotalIRC1{get;set;}
    transient public decimal TotalORC1{get;set;}
    transient public decimal TotalSPC1{get;set;}
    transient public decimal VSDAvg1{get;set;}
    transient public decimal VSCAvg1{get;set;}
    transient public decimal CCAvg1{get;set;}
    transient public decimal CDAvg1{get;set;}
    transient public decimal IRCAvg1{get;set;}
    transient public decimal ORCAvg1{get;set;}
    transient public decimal SPCAvg1{get;set;}
    transient public decimal TotalAvgAverage{get;set;}
    transient public string borrowerName{get;set;}
    transient public List<InsuranceWrapper> insList {get;set;}
    transient public list<LoanApplRelationship__c> boDetails{get;set;}
    //transient public Map<string, string> innerfinancialMap{get;set;}
    transient public Map<string, Map<string, Map<string, decimal>>> outerfinancialSummaryMap{get;set;}
    transient public Map<Id,ConsoilidateFinancialWrapper> applicantToFinancialWrap1{get;set;}
    transient public List<getBankingDetailsSummaryForCASAWrapper> BankingDetailsSummaryWrapper{get;set;}
    transient public List<getBankingDetailsSummaryForCASAWrapper> BankingDetailsSummaryWrapperODCC{get;set;}
    transient public ResponseWrapper respWrapper{get;set;}
    transient public ResponseWrapper2 respWrapper2{get;set;}
    transient public Map<Id,ApplicantEligibility> applicantEliMap{get;set;}
    
    transient public  ConsoilidateFinancialWrapper returnWrapper{get;set;}
    transient public boolean isHomeLoan{get;set;}
    transient public boolean isHLSTLAP{get;set;}
    transient public boolean isConstruction{get;set;}
    transient public BRE__c breObj{get;set;}
    transient public String hunterStatus{get;set;}
    transient public Case rcuCase{get;set;}
    transient public list<SanctionWrapper> sanctionList{get;set;}
    transient public list<DecisionWrapper> listDecisionSummary{get;set;}
    public HLandLAPCamReport(){
        recordId=ApexPages.currentPage().getParameters().get('recordId');
        
        if(recordId==null){
            recordId = 'a08C4000007x0uSIAQ'; //a08C4000007P6asIAC//a08C4000007x0uSIAQ
            System.debug('recordId '+recordId);
        }
        if(recordId!=null)
        {
            getFIORandLTV(recordId);
            getloanApplicationFeilds(recordId);
            //getApplicantBankingDetailFeildsCASA(recordId);
            //getMinBalanceCharges(recordId);
            //getAverageBalance(recordId);
           // getApplicantBankingDetailFeildsODCC(recordId);
            getObligationDetailsSummary(recordId);
            getObligationDetailsSummaryBureau(recordId);
            getCollateralVisitDetails(recordId);
            getSancionCondition(recordId);
            getApplicantEmploymentDetail(recordId);
            //getSancionCondition(recordId);
            getDeviationDetail(recordId);
            getApplicantEmploymentDetail(recordId);
            getDecisionSummary(recordId);
            getHunterAndRCUStatus(recordId);
          //  HLandLAPCamReport wrapMethods = new HLandLAPCamReport();
            colWrapper=getCollateralVerificationDetails(recordid);
            borrowWrapper=getBorrowerVerificationDetail(recordId);
            finalCPVWrapper=getBorrowerFinalCPVSummaryDetails(recordId);
            borrowerDetailsWrapper=getBorrowerDetails(recordId);
            applicantToFinancialWrap1=getfinancialSatement(recordId);
            BankingDetailsSummaryWrapper=getBankingDetailsSummaryForCASA(recordId);
            System.debug('BankingDetailsSummaryWrapper'+BankingDetailsSummaryWrapper);
            BankingDetailsSummaryWrapperODCC = getBankingDetailsSummaryForODCC(recordId);
            respWrapper = fetchRecords(recordId);
            respWrapper2 = propdetails(recordId);
            HLRelatedDetailsWrapperData = getHLRelatedDetailsData(recordId);
            ConstructionRelatedDetailsWrapperData = getConstructionRelatedDetailData(recordId);
            getBODetails(recordId);
            getGstDetails(recordId);
            getBusinessPricing(recordId);

        } 
    }

    public list<LoanApplRelationship__c> getBODetails(string recordId){
        try{
            // boDetails = [Select Id,Loan_Applicant__c,BeneficialOwner__c,Relationship_Type__c,Shareholding__c,ToLabel(Loan_Applicant__r.Gender__c),Loan_Applicant__r.Age__c,Loan_Applicant__r.FName__c,Loan_Applicant__r.LName__c from LoanApplRelationship__c where Loan_Applicant__r.LoanAppln__r.id=:recordId];
            boDetails = [Select Id,Related_Person__c, Related_Person__r.FullName__c,ToLabel(Related_Person__r.Gender__c),Related_Person__r.Age__c, Related_Person__r.Relationship__c, Loan_Applicant__c,BeneficialOwner__c,Relationship_Type__c,Shareholding__c,ToLabel(Loan_Applicant__r.Gender__c),Loan_Applicant__r.Age__c,Loan_Applicant__r.FName__c,Loan_Applicant__r.LName__c from LoanApplRelationship__c where Loan_Applicant__r.LoanAppln__r.id=:recordId and BeneficialOwner__c='Yes' AND Relationship_Type__c IN ('Beneficial Owner','ShareHolder')];
            if(boDetails.size()>0){
                return boDetails;
            }
            else{
                return null;
            }
        }
        catch(exception e){
            system.debug(e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    public list<Applicant__c> getGstDetails(string recordId){
        try{
            
            GstDetails = [Select Id, Total_Turnover_as_per_GST__c, FullName__c from Applicant__c where LoanAppln__r.id=:recordId];
            if(GstDetails.size()>0){
                return GstDetails;
            }
            else{
                return null;
            }
        }
        catch(exception e){
            system.debug(e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public void getHunterAndRCUStatus(String recordId){
        //HunMatchSta__c
        List<HunterVer__c> hunterList = new List<HunterVer__c>();
        hunterList = [SELECT Id,HunMatchSta__c FROM HunterVer__c WHERE IsLatest__c = true and LoanAplcn__c =:recordId Limit 1];
        if(!hunterList.isEmpty()){
            hunterStatus = hunterList[0].HunMatchSta__c;
        }
        List<Case> rcuList = new List<Case>();
        rcuList = [SELECT Id,ReportResult__c,Final_RCU_status_Reason__c FROM Case WHERE RecordType.Name= 'RCU' and Loan_Application__c =:recordId ORDER BY Date_of_Report__c DESC Limit 1 ];
        if(!rcuList.isEMpty()){
            rcuCase = rcuList[0];
        }
       

    }
    public list<loanAppl__c> getloanApplicationFeilds(string recordId) {
        try{
            userdetail = userinfo.getname();
            isHomeLoan=false;
            isHLSTLAP=false;
            isConstruction=false;
            CurrentDate = system.Now().format('dd-MMM-yyyy')+', '+system.Now().format('h:mm a');
            loanApplData = [select id,PrsnldetailsofPromotrs__c,BDApplicantCoapp__c,IncomerelateComm__c,AddationalComm__c, ChanelNme__r.Name,name, Status__c, BrchName__c, BrchCode__c, Product__c, RMSMName__r.Name, ChannelCode__c, SanLoanAmt__c,
                            Loan_Tenure_Months__c, LoginAcceptDate__c, City__c, SchemeId__c, ChannelName__c, BTFinancierId__c, InsAmt__c, TotalLoanAmtInclInsurance__c,
                            Insurance_Amount__c, EMIIcludingInsurance__c, EffectiveROI__c, Final_MSME__c, LoanPurpose__c, stage__c, Applicant__r.MSME__c, Applicant__r.ApplType__c, AssesIncomeAppl__c
                            ,(Select id,LoanAppln__c,Appl__r.FullName__c,InsProvider__r.Name, Appl__r.name,Appl__r.ApplType__c,PolicyTenute__c,PremiumAmount__c,InsType__c,SumAmount__c from Insurances__r) from LoanAppl__c
                            where id =:recordId];
            SchMapping__c schObj = new SchMapping__c();
            List<SchMapping__c> schObjectList = new List<SchMapping__c>();
            schObjectList=[select id,SchemeDesc__c,IsConstruction__c from SchMapping__c where id=:loanApplData[0].SchemeId__c];
            if(schObjectList.size()>0){
                schObj = schObjectList[0];
            }
            if(schObj!=null && schObj.IsConstruction__c!=null)
            {
                if(schObj.IsConstruction__c=='Yes')
                {
                   isConstruction=true; 
                }
                
            }

            List<LoanAppl__c> applicantNameList = [Select Id,Applicant__c, Applicant__r.ApplType__c, Applicant__r.FullName__c from LoanAppl__c where id =:recordId and Applicant__r.ApplType__c='P'];
            if(!applicantNameList.isEmpty()){
                applicantName = applicantNameList[0].Applicant__r.FullName__c != null ? applicantNameList[0].Applicant__r.FullName__c:'';
            }

            insList = new List<InsuranceWrapper>();
            InsuranceWrapper insWrap;
            for(Insurance__c ins: loanApplData[0].Insurances__r){
                insWrap = new InsuranceWrapper();
                insWrap.borrowerName = ins.Appl__r.FullName__c;
                insWrap.insuranceCompany = ins.InsProvider__r.Name;
                insWrap.typeOfInsurance = ins.InsType__c;
                insWrap.sumAssured = ins.SumAmount__c !=NULL?Integer.valueOf(ins.SumAmount__c):0;
                insWrap.periodOfInsurance = ins.PolicyTenute__c !=NULL?String.valueOf(ins.PolicyTenute__c):'';
                insWrap.policyPremium = ins.PremiumAmount__c !=NULL?Integer.valueOf(ins.PremiumAmount__c):0;
                insList.add(insWrap);
            }
            //insList = loanApplData[0].Insurances__r;
            
            
            
            system.debug('recordId '+recordId);
            system.debug('loanApplData--'+loanApplData);
            list<ApplIMD__c> imdStatus = new list<ApplIMD__c>();
            if(!loanApplData.isEmpty() && loanApplData[0].LoginAcceptDate__c != null) {
                datetime mydatetime=loanApplData[0].LoginAcceptDate__c;
                formattedDate=mydatetime.format('dd-MMM-yyyy');
            }
            For (loanAppl__c MSME: loanApplData) {
                if (MSME.Applicant__r.MSME__c!=Null && MSME.Applicant__r.ApplType__c == 'P') {
                    MSMEcategorisation = MSME.Applicant__r.MSME__c;
                }
                /*if(MSME.Applicant__r.ApplType__c == 'P' MSME.Applicant__r.CustProfile__c== 'SELF EMPLOYED NON PROFESSIONAL')
                    urcUACNumber = */
            }
            if (!loanApplData.isEmpty() && loanApplData[0].TotalLoanAmtInclInsurance__c != Null) {
                TotalLoanAmount = loanApplData[0].TotalLoanAmtInclInsurance__c;
            }
            List<ApplicantEmployment__c> NatureOfBusiness = new List<ApplicantEmployment__c>();
            if(!loanApplData.isEmpty()){
                if(loanApplData[0].Product__c=='Home Loan')
                {
                    isHomeLoan=true;
                }
                if(loanApplData[0].Product__c=='Home Loan' || loanApplData[0].Product__c=='Small Ticket LAP')
                {
                    isHLSTLAP=true;
                }
                NatureOfBusiness = [Select id, NatureOfBusinessIndividual__c,NatureOfBusinessCorporate__c,LoanApplicant__r.Constitution__c
                                                                 from ApplicantEmployment__c where LoanApplicant__r.ApplType__c = 'P' and LoanApplicant__r.LoanAppln__r.id=:loanApplData[0].Id];
                System.debug('Natureofbusiness '+NatureOfBusiness);
            }
            
            if (!NatureOfBusiness.isEmpty()) {

                    Schema.DescribeFieldResult fieldResult1 = ApplicantEmployment__c.NatureOfBusinessIndividual__c.getDescribe(); 
                    Schema.DescribeFieldResult fieldResult2 = ApplicantEmployment__c.NatureOfBusinessCorporate__c.getDescribe(); 

                    List<Schema.PicklistEntry> natureOfBusinessIndividual = fieldResult1.getPicklistValues();
                    
                    List<Schema.PicklistEntry> natureOfBusinessCorporate = fieldResult2.getPicklistValues();
                    
                    Map<String,String> natureOfBusinessIndividualMap = new map<String,String>();
                    for( Schema.PicklistEntry v : natureOfBusinessIndividual) {
                    
                        natureOfBusinessIndividualMap.put(v.getValue(),v.getLabel());
                    System.debug('Picklist Value Label:' + v.getLabel());
                    
                    System.debug('Picklist API Name:' + v.getValue());
                    
                    }

                    Map<String,String> natureOfBusinessCorporateMap = new map<String,String>();
                    for( Schema.PicklistEntry v : natureOfBusinessCorporate) {
                    
                    natureOfBusinessCorporateMap.put(v.getValue(),v.getLabel());
                    System.debug('Picklist Value Label:' + v.getLabel());
                    
                    System.debug('Picklist API Name:' + v.getValue());
                    }
                    
                if (NatureOfBusiness[0].LoanApplicant__r.Constitution__c!=null){
                    if(NatureOfBusiness[0].LoanApplicant__r.Constitution__c == 'INDIVIDUAL'){
                        if (NatureOfBusiness[0].NatureOfBusinessIndividual__c!=null){
                        natureOfBusinessIndv = natureOfBusinessIndividualMap.get(NatureOfBusiness[0].NatureOfBusinessIndividual__c);
                        }
                    }
                else{
                    if (NatureOfBusiness[0].NatureOfBusinessCorporate__c!=null) {
                        natureOfBusinessIndv = natureOfBusinessCorporateMap.get(NatureOfBusiness[0].NatureOfBusinessCorporate__c);
                    }
                    }
                }
            }
            System.debug('Natureofbusiness '+  NatureOfBusiness);
            list<btloan__c> btFinancierlist = [select id, BTFinancier__c, SpecifyOtherBTFinancier__c from BTLoan__c where LoanAppl__c =:recordId];
            set<string> btFinancierSet = new set<string>();
            if (btFinancierlist.size()>0) {
                for (btloan__c bt: btFinancierlist) {
                    if (bt.BTFinancier__c == 'other' && bt.SpecifyOtherBTFinancier__c != null) {
                        btFinancierSet.add(bt.SpecifyOtherBTFinancier__c);
                    }else {
                        btFinancierSet.add(bt.BTFinancier__c);
                    }
                }
                BTFinancier = string.join(btFinancierSet, ', ');
            }else{
                BTFinancier='NA';
            }
            if(!loanApplData.isEmpty()){
                schemeName = [Select SchemeDesc__c from SchMapping__c where id=: loanApplData[0].SchemeId__c];
                system.debug('loanApplData[0].SchemeId__c'+loanApplData[0].SchemeId__c);
                System.debug('schemeName '+schemeName);
                imdStatus = [SELECT Id,IMDStatus__c FROM ApplIMD__c where LoanAppln__c =:loanApplData[0].id Order by createdDate Desc limit 1];
                System.debug('Test '+imdStatus);
            }
            
            if(!imdStatus.isEmpty() && imdStatus[0].IMDStatus__c !=null) {
                
                   imdStatuss = imdStatus[0].IMDStatus__c;
             /*    if(imdStatus[0].IMDReceived__c == 'Yes'){
                     imdStatuss = 'Success';
                }
                else if(imdStatus[0].IMDReceived__c == 'No'){
                     imdStatuss = 'Pending';
                 }*/
               }
                 else{
                     imdStatuss = 'Pending';
                 }
            System.debug('Test123 '+loanApplData);
        if (loanApplData.size()>0){
           // EmpName = [Select id, Employee__r.Name, EmpRole__c, EmpBrch__r.BrchCode__c, Product_Type__c 
                       //from TeamHierarchy__c where EmpRole__c = 'BBH' AND EmpBrch__r.BrchCode__c =:loanApplData[0].BrchCode__c AND Product_Type__c =:loanApplData[0].Product__c];
            String productTypeValue= loanApplData[0].Product__c;           
            EmpName = [Select id, Employee__r.Name, EmpRole__c, EmpBrch__r.BrchCode__c, Product_Type__c 
                       from TeamHierarchy__c where EmpRole__c = 'BBH' AND EmpBrch__r.BrchCode__c =:loanApplData[0].BrchCode__c AND Product_Type__c Includes (:productTypeValue) AND IsActive__c =true];
          //  BranchCity = [Select id, Location__r.City__c, Location__r.State__c from LocBrchJn__c where Branch__r.BrchCode__c=:loanApplData[0].BrchCode__c];
            BranchCity = [Select id, LocationMaster__r.City__c, LocationMaster__r.State__c from BankBrchMstr__c  where BrchCode__c =:loanApplData[0].BrchCode__c];
        
        }
            System.debug('pBranchCity'+ BranchCity);
            pastLan = [Select id, lan__c, Loantobelinkedwithproposedloan__c, SecuritisationStatus__c from DedupeResponse__c where LoanAppln__r.id=:recordId]; 

            lstLinkedLoan = [Select id, lan__c, SecuritisationStatus__c,Loantobelinkedwithproposedloan__c from DedupeResponse__c where LoanAppln__r.id=:recordId AND RecordType.name = 'ENPA' and IsLatest__c = True]; 
            LinkedLoans = new list<String>();
            if (!lstLinkedLoan.isEmpty()){
                For (DedupeResponse__c Lan: lstLinkedLoan){
                    System.debug('Lan.lan__c '+Lan.lan__c);
                    if (Lan.lan__c!=Null && Lan.Loantobelinkedwithproposedloan__c == 'Yes') {
                        Linkedloans.add(String.valueOf(lan.lan__c));
                    }
                }
            pastLanStr = String.join(Linkedloans, ', ');
            }
            
            System.debug(' Linkedloans' +  Linkedloans);
            System.debug('pastLan'+pastLan);
            propType = [Select id, PropType__c,Property_Usage__c, PropSubType__c,ValuationToBeTakenAheadForCalculation__c, Total_Valua__c from ApplAsset__c where Appl__r.LoanAppln__r.Id =:recordId and ValuationToBeTakenAheadForCalculation__c!=null order by ValuationToBeTakenAheadForCalculation__c desc];
            System.debug(' propType'+ propType);
            if (propType.size()>0){
                 maxValueSubProperty = propType[0].PropSubType__c != null ? propType[0].PropSubType__c: '';
                PropertyType = propType[0].PropType__c != null ? propType[0].PropType__c: '';
                PropertyUsage = propType[0].Property_Usage__c != null ? propType[0].Property_Usage__c: '';
            }
            List<ApplRegltry__c> ApplRegulatory = [Select DealngIndstry__c, IsBorowrOrRelFFDir__c, FFDirRelIntrstAsPart__c, FFDirRelIntrstAsSH__c from ApplRegltry__c where LoanAppln__r.Id=:recordId];
            for(ApplRegltry__c Appl: ApplRegulatory) {
                if (Appl.DealngIndstry__c!=null) {
                    ESGNegative=Appl.DealngIndstry__c;
                    Break;
                }
            }
            for (ApplRegltry__c Appl: ApplRegulatory) {
                if (Appl.IsBorowrOrRelFFDir__c == 'Yes' || Appl.FFDirRelIntrstAsPart__c == 'Yes' || Appl.FFDirRelIntrstAsSH__c == 'Yes') {
                    loanToRelativeCheck = 'Yes';
                    Break;
                }
                else {
                    loanToRelativeCheck = 'No';
                }
            }
            for (DedupeResponse__c Dedupe: pastLan) {
                if (Dedupe.SecuritisationStatus__c == 'Y' && Dedupe.SecuritisationStatus__c!=Null) {
                    SecurityStatusCheck = 'Y';
                    Break;
                }
                else{
                    SecurityStatusCheck = 'N';
                }
            }
            system.debug('loanApplData '+loanApplData);
            return loanApplData;
        }
        catch (exception e) {
            system.debug(e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    // Banking table CASA
    public static List<getBankingDetailsSummaryForCASAWrapper> getBankingDetailsSummaryForCASA(string recordId){
        try {
            
            List<getBankingDetailsSummaryForCASAWrapper> listBankingDetailsSummaryWrapper = new List<getBankingDetailsSummaryForCASAWrapper>(); 
            
            List<ApplBanking__c> listBankingDetailsSummaryCASA = [Select Id, 
                                                                  Summary_Type__c,Appl__r.FullName__c,Appl__c ,
                                                                  (Select id,Month__c,Year__c,ValueSummationDebit__c,ValueSummationCredit__c,CountofDebit__c,
                                                                   CountofCredit__c,InwardReturnsCount__c,OutwardReturnsCount__c,StopPaymentCount__c,MinBalanceCharges__c,
                                                                   AverageBankBalance__c from Applicant_Banking_Detail__r) 
                                                                  from ApplBanking__c where Type__c ='Banking Summary'
                                                                  and Appl__c IN (Select id from Applicant__c where LoanAppln__c =:recordId) 
                                                                  and Summary_Type__c ='Combined Banking (CASA)'];
            /*   [select Id,ApplBanking__r.Appl__r.TabName__c,Month__c,Year__c,ValueSummationDebit__c,
ValueSummationCredit__c,CountofDebit__c,CountofCredit__c,InwardReturnsCount__c,
OutwardReturnsCount__c,StopPaymentCount__c,MinBalanceCharges__c,AverageBankBalance__c,
ApplBanking__r.Limit__c from ApplBankDetail__c where ApplBanking__r.LoanAppl__c='a08C40000063xjHIAQ' 
AND ApplBanking__r.AccountType__c IN('JOINT','CURRENT','SAVINGS') ];  //a08C40000063xjHIAQ//used other component loan application id is a08C4000005yfVKIAY
*/        
            decimal TotalVSD=0.0;
            decimal TotalVSC=0.0;
            decimal TotalCD=0.0;
            decimal TotalCC=0.0;
            decimal TotalIRC=0.0;
            decimal TotalORC=0.0;
            decimal TotalSPC=0.0;
            decimal TotalABB=0.0;
            String TotalsumcheckMiniChan='N';
            
            decimal AverageVSD=0.0;
            decimal AverageVSC=0.0;
            decimal AverageCD=0.0;
            decimal AverageCC=0.0;
            decimal AverageIRC=0.0;
            decimal AverageORC=0.0;
            decimal AverageSPC=0.0;
            decimal AverageABB=0.0;
            
            
            if(listBankingDetailsSummaryCASA.size()>0){
                system.debug('listBankingDetailsSummaryCASA-->'+listBankingDetailsSummaryCASA);
                
                for(ApplBanking__c lstAppBank : listBankingDetailsSummaryCASA){
                    
                    getBankingDetailsSummaryForCASAWrapper wrapperData = new getBankingDetailsSummaryForCASAWrapper();
                    
                    if(lstAppBank!=null){
                    wrapperData.listApplicantBankingWrapper = lstAppBank;
                        }
                  /*  if(lstAppBank.Applicant_Banking_Detail__r !=null){
                    wrapperData.listApplicantBankingDetailWrapper = lstAppBank.Applicant_Banking_Detail__r;
                        }*/
                    
                    List<ApplBankDetail__c> listAppBank = lstAppBank.Applicant_Banking_Detail__r;
                    System.debug('listAppBankDetails-->'+listAppBank);
                     System.debug('listAppBankDetails-->'+listAppBank.size());
                    
                     
                    
                    for(ApplBankDetail__c appBankDetails : listAppBank){
                         wrapperData.listApplicantBankingDetailWrapper=appBankDetails;
                          
                            system.debug('wrapperData.listApplicantBankingDetailWrapper-->'+wrapperData.listApplicantBankingDetailWrapper);
                        
                        System.debug('appBankDetails-->'+appBankDetails);
                        if(appBankDetails.MinBalanceCharges__c =='Y'){
                            TotalsumcheckMiniChan = 'Y';
                            }
                        TotalVSD += appBankDetails.ValueSummationDebit__c == null ? 0 : appBankDetails.ValueSummationDebit__c;
                        TotalVSC += appBankDetails.ValueSummationCredit__c == null ? 0 : appBankDetails.ValueSummationCredit__c;
                        TotalCD +=  appBankDetails.CountofDebit__c == null ? 0 : appBankDetails.CountofDebit__c;
                        TotalCC +=  appBankDetails.CountofCredit__c == null ? 0 : appBankDetails.CountofCredit__c;
                        TotalIRC += appBankDetails.InwardReturnsCount__c == null ? 0 : appBankDetails.InwardReturnsCount__c;
                        TotalORC += appBankDetails.OutwardReturnsCount__c == null ? 0 : appBankDetails.OutwardReturnsCount__c;
                        TotalSPC += appBankDetails.StopPaymentCount__c == null ? 0 : appBankDetails.StopPaymentCount__c;
                        TotalABB += appBankDetails.AverageBankBalance__c == null ? 0 : appBankDetails.AverageBankBalance__c; 
                        
                    }
                    system.debug('wrapperData.listApplicantBankingDetailWrapper-->'+wrapperData.listApplicantBankingDetailWrapper);
                   // system.debug('wrapperData.listApplicantBankingDetailWrapper-->'+wrapperData.listApplicantBankingDetailWrapper);
                    
                    wrapperData.totalValueSummationDebit = TotalVSD;
                    wrapperData.totalValueSummationCredit = TotalVSC;
                    wrapperData.totalCountDebit = TotalCD;
                    wrapperData.totalCountCredit = TotalCC;
                    wrapperData.totalInwardReturns = TotalIRC;
                    wrapperData.totalOutwardReturns = TotalORC;
                    wrapperData.totalStopPayment = TotalSPC;
                    wrapperData.totalAverageBankBalance = TotalABB;
                    
                    if (listAppBank.size()!=0) {
                        
                        AverageVSD = (TotalVSD/listAppBank.size()).setScale(2);
                        AverageVSC = (TotalVSC/listAppBank.size()).setScale(2);
                        AverageCD = (TotalCD/listAppBank.size()).setScale(2);
                        AverageCC = (TotalCC/listAppBank.size()).setScale(2);
                        AverageIRC = (TotalIRC/listAppBank.size()).setScale(2);
                        AverageORC = (TotalORC/listAppBank.size()).setScale(2);
                        AverageSPC = (TotalSPC/listAppBank.size()).setScale(2);
                        AverageABB = (TotalABB/listAppBank.size()).setScale(2);
                        
                        wrapperData.averageValueSummationDebit = AverageVSD;
                        wrapperData.averageValueSummationCredit = AverageVSC;
                        wrapperData.averageCountDebit = AverageCD;
                        wrapperData.averageCountCredit = AverageCC;
                        wrapperData.averageInwardReturns = AverageIRC;
                        wrapperData.averageOutwardReturns = AverageORC;
                        wrapperData.averageStopPayment = AverageSPC;
                        wrapperData.averageAverageBankBalance = AverageABB;
                        
                    }
                    wrapperData.minBalanceSumCheck=TotalsumcheckMiniChan;
                    listBankingDetailsSummaryWrapper.add(wrapperData)  ;                 
                    
                }
                system.debug('listBankingDetailsSummaryWrapper-->'+listBankingDetailsSummaryWrapper);
                system.debug('listBankingDetailsSummaryWrapper-->'+listBankingDetailsSummaryWrapper.size());
                return listBankingDetailsSummaryWrapper;
            }
            else{
                return null;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
   

    
    public List<getBankingDetailsSummaryForCASAWrapper> getBankingDetailsSummaryForODCC(String recordId){
        try {
            
            List<getBankingDetailsSummaryForCASAWrapper> listBankingDetailsSummaryWrapper = new List<getBankingDetailsSummaryForCASAWrapper>(); 
            
            List<ApplBanking__c> listBankingDetailsSummaryCASA = [Select Id, 
                                                                  Summary_Type__c,Appl__r.FullName__c,Appl__c ,
                                                                  (Select id,Month__c,Year__c,ValueSummationDebit__c,ValueSummationCredit__c,CountofDebit__c,
                                                                   CountofCredit__c,InwardReturnsCount__c,OutwardReturnsCount__c,StopPaymentCount__c,MinBalanceCharges__c,
                                                                   AverageBankBalance__c, MonthlyLimit__c, Utilization__c from Applicant_Banking_Detail__r) 
                                                                  from ApplBanking__c where Type__c ='Banking Summary'
                                                                  and Appl__c IN (Select id from Applicant__c where LoanAppln__c =:recordId) 
                                                                  and Summary_Type__c ='Combined Banking (OD/CC)'];
            /*   [select Id,ApplBanking__r.Appl__r.TabName__c,Month__c,Year__c,ValueSummationDebit__c,
ValueSummationCredit__c,CountofDebit__c,CountofCredit__c,InwardReturnsCount__c,
OutwardReturnsCount__c,StopPaymentCount__c,MinBalanceCharges__c,AverageBankBalance__c,
ApplBanking__r.Limit__c from ApplBankDetail__c where ApplBanking__r.LoanAppl__c='a08C40000063xjHIAQ' 
AND ApplBanking__r.AccountType__c IN('JOINT','CURRENT','SAVINGS') ];  //a08C40000063xjHIAQ//used other component loan application id is a08C4000005yfVKIAY
*/        
            decimal TotalVSD=0.0;
            decimal TotalVSC=0.0;
            decimal TotalCD=0.0;
            decimal TotalCC=0.0;
            decimal TotalIRC=0.0;
            decimal TotalORC=0.0;
            decimal TotalSPC=0.0;
            decimal TotalABB=0.0;
            decimal TotalLimit=0;
            decimal TotalUtilisation=0;
            
            decimal AverageVSD=0.0;
            decimal AverageVSC=0.0;
            decimal AverageCD=0.0;
            decimal AverageCC=0.0;
            decimal AverageIRC=0.0;
            decimal AverageORC=0.0;
            decimal AverageSPC=0.0;
            decimal AverageABB=0.0;
            decimal averageMonthlyUtilisation = 0;
            decimal averageMonthlyLimit = 0;
            
            
            if(listBankingDetailsSummaryCASA.size()>0){
                system.debug('listBankingDetailsSummaryCASA-->'+listBankingDetailsSummaryCASA);
                
                for(ApplBanking__c lstAppBank : listBankingDetailsSummaryCASA){
                    
                    getBankingDetailsSummaryForCASAWrapper wrapperData = new getBankingDetailsSummaryForCASAWrapper();
                    
                    if(lstAppBank!=null){
                    wrapperData.listApplicantBankingWrapper = lstAppBank;
                        }
                  /*  if(lstAppBank.Applicant_Banking_Detail__r !=null){
                    wrapperData.listApplicantBankingDetailWrapper = lstAppBank.Applicant_Banking_Detail__r;
                        }*/
                    
                    List<ApplBankDetail__c> listAppBank = lstAppBank.Applicant_Banking_Detail__r;
                    System.debug('listAppBankDetails-->'+listAppBank);
                     System.debug('listAppBankDetails-->'+listAppBank.size());
                    
                     
                    
                    for(ApplBankDetail__c appBankDetails : listAppBank){
                        
                          wrapperData.listApplicantBankingDetailWrapper=appBankDetails;
                            system.debug('wrapperData.listApplicantBankingDetailWrapper-->'+wrapperData.listApplicantBankingDetailWrapper);
                        
                        System.debug('appBankDetails-->'+appBankDetails);
                        TotalVSD += appBankDetails.ValueSummationDebit__c == null ? 0 : appBankDetails.ValueSummationDebit__c;
                        TotalVSC += appBankDetails.ValueSummationCredit__c == null ? 0 : appBankDetails.ValueSummationCredit__c;
                        TotalCD +=  appBankDetails.CountofDebit__c == null ? 0 : appBankDetails.CountofDebit__c;
                        TotalCC +=  appBankDetails.CountofCredit__c == null ? 0 : appBankDetails.CountofCredit__c;
                        TotalIRC += appBankDetails.InwardReturnsCount__c == null ? 0 : appBankDetails.InwardReturnsCount__c;
                        TotalORC += appBankDetails.OutwardReturnsCount__c == null ? 0 : appBankDetails.OutwardReturnsCount__c;
                        TotalSPC += appBankDetails.StopPaymentCount__c == null ? 0 : appBankDetails.StopPaymentCount__c;
                        TotalABB += appBankDetails.AverageBankBalance__c == null ? 0 : appBankDetails.AverageBankBalance__c; 
                        TotalLimit += appBankDetails.MonthlyLimit__c == null ? 0 : appBankDetails.MonthlyLimit__c;
                        TotalUtilisation += appBankDetails.Utilization__c == null ? 0 : appBankDetails.Utilization__c;
                    }
                    system.debug('wrapperData.listApplicantBankingDetailWrapper-->'+wrapperData.listApplicantBankingDetailWrapper);
                   // system.debug('wrapperData.listApplicantBankingDetailWrapper-->'+wrapperData.listApplicantBankingDetailWrapper);
                    
                    wrapperData.totalValueSummationDebit = TotalVSD;
                    wrapperData.totalValueSummationCredit = TotalVSC;
                    wrapperData.totalCountDebit = TotalCD;
                    wrapperData.totalCountCredit = TotalCC;
                    wrapperData.totalInwardReturns = TotalIRC;
                    wrapperData.totalOutwardReturns = TotalORC;
                    wrapperData.totalStopPayment = TotalSPC;
                    wrapperData.totalAverageBankBalance = TotalABB;
                    wrapperData.totalLimit = TotalLimit;
                    wrapperData.totalUtilisation = TotalUtilisation;
                    
                    if (listAppBank.size()!=0) {
                        
                        AverageVSD = (TotalVSD/listAppBank.size()).setScale(2);
                        AverageVSC = (TotalVSC/listAppBank.size()).setScale(2);
                        AverageCD = (TotalCD/listAppBank.size()).setScale(2);
                        AverageCC = (TotalCC/listAppBank.size()).setScale(2);
                        AverageIRC = (TotalIRC/listAppBank.size()).setScale(2);
                        AverageORC = (TotalORC/listAppBank.size()).setScale(2);
                        AverageSPC = (TotalSPC/listAppBank.size()).setScale(2);
                        AverageABB = (TotalABB/listAppBank.size()).setScale(2);
                        AverageMonthlyLimit = (TotalLimit/listAppBank.size()).setScale(2);
                        AverageMonthlyUtilisation = (TotalUtilisation/listAppBank.size()).setScale(2);
                        
                        wrapperData.averageValueSummationDebit = AverageVSD;
                        wrapperData.averageValueSummationCredit = AverageVSC;
                        wrapperData.averageCountDebit = AverageCD;
                        wrapperData.averageCountCredit = AverageCC;
                        wrapperData.averageInwardReturns = AverageIRC;
                        wrapperData.averageOutwardReturns = AverageORC;
                        wrapperData.averageStopPayment = AverageSPC;
                        wrapperData.averageAverageBankBalance = AverageABB;
                        wrapperData.averageLimit = AverageMonthlyLimit;
                        wrapperData.averageUtilisation = AverageMonthlyUtilisation;
                    }
                    
                    listBankingDetailsSummaryWrapper.add(wrapperData)  ;                 
                    
                }
                system.debug('listBankingDetailsSummaryWrapper-->'+listBankingDetailsSummaryWrapper);
                system.debug('listBankingDetailsSummaryWrapper-->'+listBankingDetailsSummaryWrapper.size());
                return listBankingDetailsSummaryWrapper;
            }
            else{
                return null;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    //ODCC Table
   /* public list<AggregateResult> getApplicantBankingDetailFeildsODCC(string recordId) {
        applicantBankingDetailDataODCC = [Select month__c, Year__c, sum(CountofCredit__c) Coc, sum(ValueSummationCredit__c) VSC, sum(CountofDebit__c) COD, sum(ValueSummationDebit__c) VSD,
                                          sum(InwardReturnsCount__c) IRC, sum(OutwardReturnsCount__c) ORC, sum(StopPaymentCount__c) SPC
                                          from ApplBankDetail__c where ApplBanking__r.LoanAppl__r.Id =:recordId AND ApplBanking__r.AccountType__c IN('CC','OVERDRAFT')
                                          group by month__c,year__c];
        TotalVSD1 = 0;
        TotalVSC1 =0;
        TotalCD1 =0;
        TotalCC1 = 0;
        TotalIRC1 = 0;
        TotalORC1 = 0;
        TotalSPC1 = 0;
        For(AggregateResult item: applicantBankingDetailDataODCC) {
            System.debug('item '+item);
            TotalVSD1 += (Decimal)item.get('VSD') == null ? 0 : (Decimal)item.get('VSD');
            TotalVSC1 += (Decimal)item.get('VSC') == null ? 0 : (Decimal)item.get('VSC');
            TotalCD1 += (Decimal)item.get('COD') == null ? 0 : (Decimal)item.get('COD');
            TotalCC1 += (Decimal)item.get('COC') == null ? 0 : (Decimal)item.get('COC');
            TotalIRC1 += (Decimal)item.get('IRC') == null ? 0 : (Decimal)item.get('IRC');
            TotalORC1 += (Decimal)item.get('ORC') == null ? 0 : (Decimal)item.get('ORC');
            TotalSPC1 += (Decimal)item.get('SPC') == null ? 0 : (Decimal)item.get('SPC');
        }
        /*if (applicantBankingDetailData.size()!=0) {
            VSDAvg1 = (TotalVSD/applicantBankingDetailData.size()).setScale(2);
            VSCAvg1 = (TotalVSC/applicantBankingDetailData.size()).setScale(2);
            CDAVG1 = (TotalCD/applicantBankingDetailData.size()).setScale(2);
            CCAVG1 = (TotalCC/applicantBankingDetailData.size()).setScale(2);
            IRCAVG1 = (TotalIRC/applicantBankingDetailData.size()).setScale(2);
            ORCAVG1 = (TotalORC/applicantBankingDetailData.size()).setScale(2);
            SPCAVG1 = (TotalSPC/applicantBankingDetailData.size()).setScale(2);
        }*/
       // system.debug(applicantBankingDetailDataODCC);
       // return applicantBankingDetailDataODCC;
   // }
    
    //Obligation Details
    public List<BureauRespDtl__c> getObligationDetailsSummary(string recordid){
        try {
            
            lstObligationDetails = [select Id,BounceInLast12Months__c,Applicant__r.FullName__c,Treatment__c,FinancierName__c,
                                    NatureOfLoan__c,LoanAmount__c,Tenure__c,NoEMIPaid__c,EMI__c,
                                    CurrentOs__c,EMISource__c,ConsiderObligation__c,
                                    MaxDPDLst12month__c,Remarks__c from BureauRespDtl__c 
                                    where LoanApplication__c=:recordId AND Treatment__c='To continue - Obligate'];  //used other component loan application id is a08C4000005yfVKIAY
            System.debug('lstObligationDetails '+lstObligationDetails);
            if(lstObligationDetails.size()>0){
                system.debug('obligationDetails'+ lstObligationDetails);
                return lstObligationDetails;
            }
            else{
                return null;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    //Bureau Summary
    public List<Bureau__c> getObligationDetailsSummaryBureau(String recordid){
        try {
            
            lstObligationDetailsBureau = [select Id,Applicant__r.FullName__c,Totalliveloan__c,
                                          Totalloanexposure__c,Totalsecuredloan__c, Totalunsecuredloan__c,
                                          Totalcreditcardoutstanding__c,Totaloanoverdue__c,
                                          Totalcreditcardoverdue__c,MaxcurrentDPDLiveFacilities__c,
                                          MaxDPDlast12months__c,TotalEnquiries__c,TotalEnquirieslast30day__c,TotalMortgageEnqlst30days__c,TotalMortgageloan__c  from Bureau__c 
                                          where LoanApp__c=:recordId AND IsLatest__c=true  order by Applicant__r.CreatedDate Asc];  //used other component loan application id is a08C4000005yfVKIAY
            if(lstObligationDetailsBureau.size()>0){
                System.debug('Bureau'+lstObligationDetailsBureau);
                return lstObligationDetailsBureau;
            }
            else{
                return null;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    // Collateral details
    public List<ApplAsset__c> getCollateralVisitDetails(String recordId){
        try {
            
            listCollateralVisitDetails = [SELECT Id,PropAddrs__c,Prop_Owners__c,NatureofProp__c,PropType__c,PropSubType__c,
                                          Property_Usage__c,Approx_Age_of_Prop__c,Resi_Age__c,Land_Area__c,
                                          Prop_Bui_up_ar__c,Negative_Caution_Area__c,Comments_on_Collateral__c
                                          //Comments_on_Collateral__c
                                           FROM ApplAsset__c 
                                          where LoanAppln__c =:recordId];//where Case__r.Loan_Application__c='a08C40000063xjHIAQ'  //used other component loan application id is a08C4000005yfVKIAY
            if(listCollateralVisitDetails.size()>0){
                system.debug('listCollateralVisitDetails.size()-->'+listCollateralVisitDetails.size());
                system.debug('listCollateralVisitDetails-->'+listCollateralVisitDetails);
                return listCollateralVisitDetails;
            }
            else{
                return null;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    // Sanction Condition
    public void getSancionCondition(String recordId) {
        try {

            sanctionList = new  List<SanctionWrapper>();
            SanctionWrapper sanctionWrap;
            
            for(Sanction_Conditions__c conditions: [SELECT Name, Remarks__c, Condition__c FROM Sanction_Conditions__c WHERE Loan_Application__c = :recordId]){
                sanctionWrap = new SanctionWrapper();
                sanctionWrap.conditionName = conditions.Condition__c;
                sanctionWrap.remarks = conditions.Remarks__c;
                sanctionList.add(sanctionWrap);
            }
            
        }
        Catch (exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    //Financial Borrower Employment and PD Details
    transient public list<EmploymentWrapper> EmploymentList{get;set;}
    public list<ApplicantEmployment__c> getApplicantEmploymentDetail(String recordId) {
        try {
            ApplicantEmploymentDetail = [Select LoanApplicant__r.CustProfile__c,LoanApplicant__c,LoanApplicant__r.ApplType__c,Is_URC_UAC_available__c,Select_applicability_for_URC_UAC__c,UdyamAssistCertificate__c,UdyamRegistrationNumber__c,MainRBIIndustry__c, SubIndustry__r.Name, toLabel(TypeOfOrganisation__c),
                                         LoanApplicant__r.TabName__c,LoanApplicant__r.FullName__c
                                         from ApplicantEmployment__c where LoanApplicant__r.LoanAppln__r.id =:recordId order by CreatedDate Asc];
            Set<id> applicantId=new Set<id>();
            Map<Id,PD__c> applPD=new Map<Id,PD__c>();
            EmploymentList=new list<EmploymentWrapper>();
            urcUacNumber = 'NA';
            if (ApplicantEmploymentDetail.size()>0) {
                System.debug('ApplicantEmploymentDetail' + ApplicantEmploymentDetail);
                for(ApplicantEmployment__c appObj:ApplicantEmploymentDetail)
                {
                    applicantId.add(appObj.LoanApplicant__c);
                    if(appObj.LoanApplicant__r.ApplType__c == 'P' && appObj.Is_URC_UAC_available__c == 'YES' && appObj.LoanApplicant__r.CustProfile__c!='SALARIED'){
                        
                        if(appObj.Select_applicability_for_URC_UAC__c =='UDYAM ASSIST CERTIFICATE (UAC)'){
                            urcUacNumber = appObj.UdyamAssistCertificate__c;
                        }else{
                            urcUacNumber = appObj.UdyamRegistrationNumber__c;
                        }
                    }
                }
                system.debug('applicantId---------------->'+applicantId);
                for(PD__c pdObj:[Select id,PDStatus__c,PDRmrks__c,Appl__c,PdTyp__c,Appl__r.CustProfile__c,CmpltDt__c,AsgnTo__r.name from PD__c where Appl__c IN:applicantId and CmpltDt__c != NULL ORDER BY CmpltDt__c DESC])  // CmpltDt__c!=null 
                {
                    applPD.put(pdObj.Appl__c,pdObj);
                    
                    if(!applPD.containsKey(pdObj.Appl__c) && pdObj.Appl__r.CustProfile__c != 'SALARIED' && pdObj.PdTyp__c.contains('Physical PD')){
                        applPD.put(pdObj.Appl__c,pdObj);     
                        system.debug('applPD:'+applPD.values());
                        
                    }
                    if(!applPD.containsKey(pdObj.Appl__c) && pdObj.Appl__r.CustProfile__c == 'SALARIED'){
                        applPD.put(pdObj.Appl__c,pdObj);                   
                    }
                }
                system.debug('pdList----------->'+[Select id,PDStatus__c,PDRmrks__c,Appl__c from PD__c where Appl__c IN:applicantId and CmpltDt__c != NULL ORDER BY CmpltDt__c DESC]);
                system.debug('applPD------------------>'+applPD);
                for(ApplicantEmployment__c appObj:ApplicantEmploymentDetail)
                {
                    EmploymentWrapper empObj=new EmploymentWrapper();
                    empObj.borrowerName=appObj.LoanApplicant__r.FullName__c;
                    empObj.typeOfEmployment=appObj.TypeOfOrganisation__c;
                    empObj.industryOfMainEstablishment=appObj.MainRBIIndustry__c;
                    empObj.subIndustryOfMainEstablishment=appObj.SubIndustry__r.Name;
                    
                    empObj.pdStatus=applPD.size()>0?(applPD.get(appObj.LoanApplicant__c)!=null?applPD.get(appObj.LoanApplicant__c).PDStatus__c:''):'';
                    empObj.pdRemarksSummary=applPD.size()>0?(applPD.get(appObj.LoanApplicant__c)!=null?applPD.get(appObj.LoanApplicant__c).PDRmrks__c:''):'';
                    empObj.pdAuthorityName=applPD.size()>0?(applPD.get(appObj.LoanApplicant__c)!=null?applPD.get(appObj.LoanApplicant__c).AsgnTo__r.name:''):'';
                    empObj.pdDate=applPD.size()>0?(applPD.get(appObj.LoanApplicant__c)!=null?String.valueof(applPD.get(appObj.LoanApplicant__c).CmpltDt__c.format('dd-MMM-yyyy'))+ ','+ String.valueof(applPD.get(appObj.LoanApplicant__c).CmpltDt__c.format('h:mm a')):''):'';
                    
                    EmploymentList.add(empObj);
                    
                }
                
                
                
                return ApplicantEmploymentDetail;
            }
            else {
                return null;
            }
        }
        Catch (exception e) {
            system.debug('Line number'+e.getLinenumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
    Public class SanctionWrapper{
        @AuraEnabled
        public String conditionName { get; set; }
        @AuraEnabled
        public String remarks { get; set; }
    }
    
    Public class DecisionWrapper{
        @AuraEnabled
        public String UserName { get; set; }
        @AuraEnabled
        public String Decision { get; set; }
         @AuraEnabled
        public String ApproverComment { get; set; }
        @AuraEnabled
        public Date DecisionDate { get; set; }
        @AuraEnabled
        public String formattedDecisionDate { get; set; }
    }

    Public class InsuranceWrapper{
        @AuraEnabled
        public String borrowerName { get; set; }
        @AuraEnabled
        public String insuranceCompany { get; set; }
        @AuraEnabled
        public Integer sumAssured { get; set; }
        @AuraEnabled
        public Integer policyPremium{ get; set; }
        @AuraEnabled
        public String periodOfInsurance{ get; set; }
        @AuraEnabled
        public String typeOfInsurance{ get; set; }
    }

    public class EmploymentWrapper {

    @AuraEnabled
    public String borrowerName { get; set; }

    @AuraEnabled
    public String typeOfEmployment { get; set; }

    @AuraEnabled
    public String industryOfMainEstablishment { get; set; }

    @AuraEnabled
    public String subIndustryOfMainEstablishment { get; set; }

    @AuraEnabled
    public String pdStatus { get; set; }

    @AuraEnabled
    public String pdRemarksSummary { get; set; }

    @AuraEnabled
    public String pdAuthorityName { get; set; }

    @AuraEnabled
    public String pdDate { get; set; }
    
}
    
    
    // Deviation Details
    public list<Deviation__c> getDeviationDetail(String recordId) {
        try {
            DeviationDetail = [Select Deviation__c, Req_Apprv_Level__c, Devia_Desrp__c, Mitigation__c, Appr_Remarks__c, Apprv_By__r.Name
                               from Deviation__c where LoanAppln__r.Id =:recordId AND (Dev_Type__c ='Manual' OR (Dev_Type__c ='System' AND BRE__r.IsLatest__c=TRUE))];
            System.debug('DeviationDetail'+DeviationDetail);
            if (ApplicantEmploymentDetail.size()>0) {
                System.debug('DeviationDetail'+DeviationDetail);
                return DeviationDetail;
            }
            else {
                return null;
            }
        }
        Catch (exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public list<LoanAppeal__c> getBusinessPricing(String recordId) {
        try {
            BusinessPricing = [select Id, Status__c, LoanAppl__c, Comments__c, LAN__c, Recommender__c, Approver__c, Approver__r.Name, RevisedRoi__c, RevisedPF__c, AppName__c, Decision__c, ApproverLevel__c, RecordType__c,RecordType.Name from LoanAppeal__c where RecordType.Name ='Roi Pf Correction' and LoanAppl__r.Id =:recordId];
            
            if (BusinessPricing.size()>0) {
                
                return BusinessPricing;
            }
            else {
                return null;
            }
        }
        Catch (exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    
    //Borrower Verification details
    
    public list<Applicant__c> getBorrowerDetail(String recordId) {
        try {
            BorrowerDetails = [Select FullName__c, PAN__c, DLNo__c, VotIdEpicNo__c, PassNo__c from Applicant__c
                               where LoanAppln__r.id=:recordId];
            if (BorrowerDetails.size()>0) {
                System.debug('DeviationDetail'+BorrowerDetails);
                return BorrowerDetails;
            }
            else {
                return null;
            }
        }
        Catch (exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public List<getCollateralVerificationDetailsWrapper> getCollateralVerificationDetails(String recordId){
        try {
            List<getCollateralVerificationDetailsWrapper> WrapperList = new List<getCollateralVerificationDetailsWrapper>();
            
            List<ApplAsset__c> listCollateralVerificationDetails = [SELECT Id,Valuation_as_per_policy_norms__c,ValuationToBeTakenAheadForCalculation__c,DistFrmNearBrch__c,DistFrmSourceBrch__c,Negative_Caution_Area__c,PropAddrs__c,(select Id,DateofVisit__c,Date_of_Report__c,ExpiryDate__c,Total_Valuation_Land_Valuation_B__c,Status,RecordTypeId,recordtype.name,IsCompleted__c,ReportResult__c,Property_Visit_Final_Status__c,Assigned_To__r.name from cases__r ) FROM ApplAsset__c where LoanAppln__c =:recordId];//where Case__r.Loan_Application__c='a08C40000063xjHIAQ'  //used other component loan application id is a08C4000005yfVKIAY
            if(listCollateralVerificationDetails.size()>0){
                // system.debug('listCollateralVerificationDetails.size()-->'+listCollateralVerificationDetails.size());
                //  system.debug('listCollateralVerificationDetails-->'+listCollateralVerificationDetails);
                Map<Id,Case> cvCase = new Map<Id,Case>();
                Map<Id,Case> legalCase = new Map<Id,Case>();
                Map<Id,Case> tsrCase = new Map<Id,Case>();
                For(ApplAsset__c appAssetList: listCollateralVerificationDetails){
                    
                    getCollateralVerificationDetailsWrapper CollaterVerDetailsWrapp = new getCollateralVerificationDetailsWrapper();
                    
                    CollaterVerDetailsWrapp.lstOfApplicantAssetsWrapp = appAssetList;
                    //  system.debug('CollaterVerDetailsWrapp-->'+CollaterVerDetailsWrapp.lstOfApplicantAssetsWrapp);
                    list<case> casesRecord = appAssetList.cases__r;
                    //  system.debug('appAssetList.cases__r.size()-->'+appAssetList.cases__r.size());
                    Integer i=0;
                    for (case c: casesRecord) {
                        
                        if(c.recordType.name =='Technical' && c.status=='Closed' && c.ExpiryDate__c > Date.Today()){
                            if(i==0){
                                CollaterVerDetailsWrapp.totalValuation1 = c.Total_Valuation_Land_Valuation_B__c;
                            }else if(i == 1){
                                    CollaterVerDetailsWrapp.totalValuation2 = c.Total_Valuation_Land_Valuation_B__c;
                            }else if(i==2){
                                CollaterVerDetailsWrapp.totalValuation3 = c.Total_Valuation_Land_Valuation_B__c;
                            }
                            i++;
                        }else if(c.recordType.name =='Collateral Visit' && c.IsCompleted__c){

                            if(cvCase.containsKey(appAssetList.Id) && c.DateofVisit__c > cvCase.get(appAssetList.Id).DateofVisit__c){
                                cvCase.put(appAssetList.Id,c);
                            }else{
                                cvCase.put(appAssetList.Id,c);
                            }
                            
                        }else if(c.recordType.name =='Legal' && c.status=='Closed' ){
                            if(legalCase.containsKey(appAssetList.Id) && c.Date_of_Report__c > legalCase.get(appAssetList.Id).DateofVisit__c ){
                                legalCase.put(appAssetList.Id,c);
                            }else{
                                legalCase.put(appAssetList.Id,c);
                            }
                        }else if(c.recordType.name =='TSR' && c.status=='Closed'){
                            if(tsrCase.containsKey(appAssetList.Id) && c.Date_of_Report__c > tsrCase.get(appAssetList.Id).DateofVisit__c){
                                tsrCase.put(appAssetList.Id,c);
                            }else{
                                tsrCase.put(appAssetList.Id,c);
                            }
                        }
                    }   
                        
                       
                        
                        
                    
                    CollaterVerDetailsWrapp.legalCase = legalCase.get(appAssetList.Id);
                    CollaterVerDetailsWrapp.tsrCase = tsrCase.get(appAssetList.Id);
                    CollaterVerDetailsWrapp.visitCase = cvCase.get(appAssetList.Id);
                    WrapperList.add(CollaterVerDetailsWrapp);
                    system.debug('WrapperList-->'+WrapperList);
                }
                return WrapperList;
            }
            else{
                return null;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    public List<getBorrowerVerificationDetailWrapper> getBorrowerVerificationDetail(String recordId) {
        try {
            
            List<getBorrowerVerificationDetailWrapper> WrapperBorrowerList = new List<getBorrowerVerificationDetailWrapper>();
            
            list<Applicant__c> lstApplicantDetails = [Select Id,CAVerStatus__c, DoctorApiVerStatus__c, ArchVerStatus__c,LoanAppln__c,name,TabName__c,FullName__c, PAN__c, DLNo__c, VotIdEpicNo__c, PassNo__c,(Select id,Applicant__c,IntnlDeduRelevance__c,LoanAppln__c,IsLatest__c,RecordType.name  from Dedupe_Responses__r where IsLatest__c =true),(select Id, WatchoutInvestor__c,ScrRes__c,Result_Relevance__c,RecordTypeId,RecordType.name,IsLatest__c from API_Verifications__r where IsLatest__c=true),(Select id,kycDoc__c,ValidationStatus__c,OCRStatus__c,Applicant__c   from Applicant_KYC__r  where kycDoc__c  IN  ('Passport','PAN','Voter Id','Driving License')),(Select id, GSTIN__c,Applicant__c,Main_GSTIN__c,GSTIN_Status__c  from Applicant_GST__r  where Main_GSTIN__c = True) from Applicant__c where LoanAppln__c =:recordId and ApplType__c in ('P','C','G') order by createdDate ASC ];
            
            // List<Applicant__c> profVer = [Select Id, ProfQual__c, CAVerStatus__c, DoctorApiVerStatus__c, ArchVerStatus__c from Applicant__c where LoanAppln__r.Id =:recordId];
            // if(profVer.size()>0){
            //     getBorrowerVerificationDetailWrapper borrowerVerDetailsWrapp1 = new getBorrowerVerificationDetailWrapper();
            //     borrowerVerDetailsWrapp1.ca = profVer[0].CAVerStatus__c != null ? profVer[0].CAVerStatus__c:'';
            //     borrowerVerDetailsWrapp1.doctor = profVer[0].DoctorApiVerStatus__c != null ? profVer[0].DoctorApiVerStatus__c:'';
            //     borrowerVerDetailsWrapp1.architect = profVer[0]. ArchVerStatus__c != null ? profVer[0]. ArchVerStatus__c:'';
            //     WrapperBorrowerList.add(borrowerVerDetailsWrapp1);
            //     return WrapperBorrowerList;

            // }
            

            if (lstApplicantDetails.size()>0) {
                //System.debug('lstApplicantDetails-->'+lstApplicantDetails);
                //System.debug('lstApplicantDetails-->'+lstApplicantDetails.size());
                
                for(Applicant__c appList: lstApplicantDetails){
                    getBorrowerVerificationDetailWrapper borrowerVerDetailsWrapp = new getBorrowerVerificationDetailWrapper();
                    
                    borrowerVerDetailsWrapp.lstOfApplicantDetailsWrapp = appList;
                    
                    system.debug('WrapperBorrowerList-->'+borrowerVerDetailsWrapp.lstOfApplicantDetailsWrapp);
                   List<DedupeResponse__c> dedupResp = appList.Dedupe_Responses__r;
                    List<APIVer__c> apiVerList = appList.API_Verifications__r;
                    List<ApplKyc__c> applKycList = appList.Applicant_KYC__r;
                    List<ApplGST__c> applGSTList = appList.Applicant_GST__r;
                    
                    System.debug('applKycList-->'+applKycList);
                    System.debug('applKycList-->'+applKycList.size());

                    borrowerVerDetailsWrapp.ca = appList.CAVerStatus__c != null ? appList.CAVerStatus__c:'';
                    borrowerVerDetailsWrapp.doctor = appList.DoctorApiVerStatus__c != null ? appList.DoctorApiVerStatus__c:'';
                    borrowerVerDetailsWrapp.architect = appList.ArchVerStatus__c != null ? appList.ArchVerStatus__c:'';
                    
                     for(ApplKyc__c kyc:applKycList){
                       
                   // applicantKYCWrapper wrap = applicantKYCMap.containsKey(kyc.Applicant__c)?applicantKYCMap.get(kyc.Applicant__c):new applicantKYCWrapper();
                        if(kyc.kycDoc__c == 'PAN'){
                            borrowerVerDetailsWrapp.PanStatus  = kyc.validationStatus__c != NULL ? kyc.validationStatus__c:'Pending';
                        }else if(kyc.kycDoc__c == 'Voter Id'){
                            borrowerVerDetailsWrapp.voterIdStatus = kyc.validationStatus__c != NULL ? kyc.validationStatus__c:'Pending';
                        }
                        else if(kyc.kycDoc__c == 'Passport'){
                            borrowerVerDetailsWrapp.passportStatus = kyc.validationStatus__c != NULL ? kyc.validationStatus__c:'Pending';
                        }
                        else if(kyc.kycDoc__c == 'Driving License'){
                            borrowerVerDetailsWrapp.drivingLicence = kyc.validationStatus__c != NULL ? kyc.validationStatus__c:'Pending';
                        }
                        
                   }

                   for(ApplGST__c gst: applGSTList){
                   
                    if(gst.GSTIN_Status__c != null){
                        borrowerVerDetailsWrapp.gstinStatus = gst.GSTIN_Status__c != NULL ? gst.GSTIN_Status__c:'';
                    }
                }
                    
                  //  for(ApplicantEmployment__c apEmp : applnEmp){
                  //      borrowerVerDetailsWrapp.gstinStatus = apEmp.GSTIN_Status__c;
                  //  }
                    
                    // borrowerVerDetailsWrapp.deDupe = 'No Match Found';
                    // for(DedupeResponse__c dedup : dedupResp){
                    //     if((dedup.IsLatest__c || dedup.IsLatest__c == true)){
                    //         borrowerVerDetailsWrapp.deDupe = 'Match found';
                    //     }
                        
                    // }
                    // borrowerVerDetailsWrapp.watchOutInvestor = 'No Match Found';
                    // borrowerVerDetailsWrapp.trackwizzRecordTypeCheck = 'No Match Found';
                    // for(APIVer__c apiVer : apiVerList){
                    //     //    system.debug('apiVer.RecordType.name-->'+apiVer.RecordType.name);
                    //     //    system.debug('apiVer.WatchoutInvestor__c-->'+apiVer.WatchoutInvestor__c);
                    //     if((apiVer.WatchoutInvestor__c || apiVer.WatchoutInvestor__c == true) && (apiVer.RecordType.name =='Watchout')){
                    //         borrowerVerDetailsWrapp.watchOutInvestor = 'Match found';
                    //     }
                    //     if(apiVer.RecordType.name =='Risk Rating'){
                    //         borrowerVerDetailsWrapp.trackwizzRecordTypeCheck = 'Match found';
                    //     }    
                    // }

                    for(DedupeResponse__c dedup : dedupResp){
                        if(dedup.RecordType.name == 'Dedupe' && dedup.IntnlDeduRelevance__c == 'Accurate Match found'){
                            borrowerVerDetailsWrapp.deDupe = dedup.IntnlDeduRelevance__c;
                        }
                        else{
                            borrowerVerDetailsWrapp.deDupe = 'Inaccurate match found';
                        }
                        
                    }
               // }
                  //  if(apiVerList.size()>0){
                  //  borrowerVerDetailsWrapp.watchOutInvestor = 'Inaccurate match found';
                  //  borrowerVerDetailsWrapp.trackwizzRecordTypeCheck = 'NotMatch';
                    for(APIVer__c apiVer : apiVerList){
                        //    system.debug('apiVer.RecordType.name-->'+apiVer.RecordType.name);
                        //    system.debug('apiVer.WatchoutInvestor__c-->'+apiVer.WatchoutInvestor__c);
                        // if((apiVer.WatchoutInvestor__c || apiVer.WatchoutInvestor__c == true) && (apiVer.RecordType.name =='Watchout')){
                        //     borrowerVerDetailsWrapp.watchOutInvestor = 'Yes';
                        // }
                        // if(apiVer.RecordType.name =='Screening'){
                        //     borrowerVerDetailsWrapp.trackwizzRecordTypeCheck = 'Yes';
                        // }

                        if(apiVer.RecordType.name =='Watchout'){
                            
                            if(apiVer.Result_Relevance__c == 'Accurate Match found'){
                                borrowerVerDetailsWrapp.watchOutInvestor = apiVer.Result_Relevance__c;
                            }
                            else{
                                borrowerVerDetailsWrapp.watchOutInvestor = 'Inaccurate match found';
                            }
                        }
                        else if(apiVer.RecordType.name =='Screening'){
    
                            if(apiVer.ScrRes__c == 'Match'){
                                borrowerVerDetailsWrapp.trackwizzRecordTypeCheck = apiVer.ScrRes__c;
                            }
                            else{
    
                                borrowerVerDetailsWrapp.trackwizzRecordTypeCheck = 'NotMatch';
    
                            }
    
                        }
                        
                        
                        
                    }

                    // for(Applicant__c app: profVer){
                    //     borrowerVerDetailsWrapp.ca = app.CAVerStatus__c != null ? app.CAVerStatus__c:'';
                    //     borrowerVerDetailsWrapp.doctor = app.DoctorApiVerStatus__c != null ? app.DoctorApiVerStatus__c:'';
                    //     borrowerVerDetailsWrapp.architect = app.ArchVerStatus__c != null ? app.ArchVerStatus__c:'';
                    // }
                    
                    WrapperBorrowerList.add(borrowerVerDetailsWrapp);
                }
                system.debug('WrapperBorrowerList-->'+WrapperBorrowerList);
                system.debug('WrapperBorrowerList-->'+WrapperBorrowerList.size());
                return WrapperBorrowerList;
            }
            else {
                return null;
            }
        }
        Catch (exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public List<getBorrowerFinalCPVSummaryDetailsWrapper> getBorrowerFinalCPVSummaryDetails(String recordId){
        try {
            
            List<getBorrowerFinalCPVSummaryDetailsWrapper> borrowerFinalCPVWrapperList = new List<getBorrowerFinalCPVSummaryDetailsWrapper>();
            
            //  List<case> listBorrowerFinalCPVSummaryDetails = [SELECT Id,ApplAssetId__c,Loan_Application__c,Applicant__c,Applicant__r.tabname__c,RecordTypeId,RecordType.name,Address_Type__c,ReportResult__c FROM case where Loan_Application__c='a08C4000007Kw2EIAS'];//where Case__r.Loan_Application__c='a08C40000063xjHIAQ'  //used other component loan application id is a08C4000005yfVKIAY
            
            List<Applicant__c> listBorrowerFinalCPVSummaryDetails = [Select Id, LoanAppln__c, name,FullName__c, TabName__c, (select Id,WaiveCPV__c, RecordTypeId, RecordType.name, Address_Type__c, ReportResult__c from cases__r where RecordType.name = 'CPVFI') from Applicant__c where LoanAppln__c =:recordId and ApplType__c in ('P','C','G') order by createdDate ASC];
            if(listBorrowerFinalCPVSummaryDetails.size()>0){
                system.debug('listBorrowerFinalCPVSummaryDetails.size()-->'+listBorrowerFinalCPVSummaryDetails.size());
                system.debug('listBorrowerFinalCPVSummaryDetails-->'+listBorrowerFinalCPVSummaryDetails);
                
                for(Applicant__c applcnList: listBorrowerFinalCPVSummaryDetails){
                    
                    getBorrowerFinalCPVSummaryDetailsWrapper borrowerFinalCPVWrapper = new getBorrowerFinalCPVSummaryDetailsWrapper();
                    
                    borrowerFinalCPVWrapper.lstOfCaseApplicantDetailsWrapp = applcnList;
                    system.debug('borrowerFinalCPVWrapper.lstOfCaseApplicantDetailsWrapp-->'+borrowerFinalCPVWrapper.lstOfCaseApplicantDetailsWrapp);
                    
                    List<case> caseChildList = applcnList.cases__r;
                    system.debug('caseChildList-->'+caseChildList);
                    system.debug('caseChildList size()-->'+caseChildList.size());
                    
                    /*Integer countOfResultReport =0;

for(case ca: caseChildList){
if(ca.ReportResult__c != null && ca.ReportResult__c =='Positive'){
countOfResultReport = countOfResultReport+1;
}
}*/
                    
                    //borrowerFinalCPVWrapper.residenceCPV ='Negative';
                    //borrowerFinalCPVWrapper.resiCumOfficeCPV ='Negative';
                    //borrowerFinalCPVWrapper.permanentAddressCPV ='Negative';
                    //borrowerFinalCPVWrapper.officeCPV ='Negative';
                    
                    for(case c: caseChildList){
                  if(c.ReportResult__c !=null){

                  if(c.Address_Type__c != null && c.Address_Type__c == 'Residence Address' ){  //&& c.ReportResult__c != null && c.ReportResult__c =='Positive'
                    
                      if(borrowerFinalCPVWrapper.residenceCPV != 'Negative'){
                          borrowerFinalCPVWrapper.residenceCPV = c.ReportResult__c;
                      }
                    
  
                  }
                
                  if(c.Address_Type__c != null && c.Address_Type__c == 'Residence Cum office'){

                    if(borrowerFinalCPVWrapper.resiCumOfficeCPV != 'Negative'){
                    borrowerFinalCPVWrapper.resiCumOfficeCPV = c.ReportResult__c;
                    }

                  }
                  if(c.Address_Type__c != null && c.Address_Type__c == 'Permanent Address'){
                    if(borrowerFinalCPVWrapper.permanentAddressCPV != 'Negative'){
                    borrowerFinalCPVWrapper.permanentAddressCPV = c.ReportResult__c;
                    }
  
                  }
                  if(c.Address_Type__c != null && (c.Address_Type__c == 'Office Address' || c.Address_Type__c == 'Principal place for business')){
                    if(borrowerFinalCPVWrapper.officeCPV != 'Negative'){
                    borrowerFinalCPVWrapper.officeCPV = c.ReportResult__c;
                    }
  
                  }
                  if(c.Address_Type__c != null && c.Address_Type__c == 'Other Address'){
                    if(borrowerFinalCPVWrapper.otherAddressCPV != 'Negative'){
                    borrowerFinalCPVWrapper.otherAddressCPV = c.ReportResult__c;
                    }
  
                  }
                }
                   else if(c.WaiveCPV__c  == 'Yes'){
                       if(c.Address_Type__c != null && c.Address_Type__c == 'Residence Address' && String.IsBlank(borrowerFinalCPVWrapper.residenceCPV )){  //&& c.ReportResult__c != null && c.ReportResult__c =='Positive'
                    
                      
                          borrowerFinalCPVWrapper.residenceCPV = 'Waived';
                      
                    
  
                  }
                
                  if(c.Address_Type__c != null && c.Address_Type__c == 'Residence Cum office' && String.IsBlank(borrowerFinalCPVWrapper.resiCumOfficeCPV)){

                    borrowerFinalCPVWrapper.resiCumOfficeCPV = 'Waived';
                    

                  }
                  if(c.Address_Type__c != null && c.Address_Type__c == 'Permanent Address' && String.IsBlank(borrowerFinalCPVWrapper.permanentAddressCPV )){
                   
                    borrowerFinalCPVWrapper.permanentAddressCPV = 'Waived';
                    
  
                  }
                  if(c.Address_Type__c != null && (c.Address_Type__c == 'Office Address' || c.Address_Type__c == 'Principal place for business') && String.IsBlank(borrowerFinalCPVWrapper.officeCPV )){
                    
                    borrowerFinalCPVWrapper.officeCPV = 'Waived';
                    
  
                  }
                  if(c.Address_Type__c != null && c.Address_Type__c == 'Other Address' && String.IsBlank(borrowerFinalCPVWrapper.otherAddressCPV )){
                   
                    borrowerFinalCPVWrapper.otherAddressCPV = 'Waived';
                    
  
                  }
                   }
                }
                    borrowerFinalCPVWrapperList.add(borrowerFinalCPVWrapper);
                    
                }
                
                system.debug('borrowerFinalCPVWrapperList-->'+borrowerFinalCPVWrapperList);
                system.debug('borrowerFinalCPVWrapperList-->'+borrowerFinalCPVWrapperList.size());
                
                return borrowerFinalCPVWrapperList;
            }
            else{
                return null;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    // Decision list
   /* public list<UWDecision__c> getDecisionSummary(String recordId) {
        try {
           // 
            listDecisionSummary = [select Id,name,LoanAppl__c,LoanAppl__r.BDApplicantCoapp__c,LoanAppl__r.IncomerelateComm__c,LoanAppl__r.AddationalComm__c,LoanAppl__r.PrsnldetailsofPromotrs__c,User__c,User__r.name,Decision__c,
                                                        DecisionRmrks__c,
                                                        DecisionDt__c,createddate,IncomerelateComm__c,AddationalComm__c,PrsnldetailsofPromotrs__c,BDApplicantCoapp__c
                                                        from UWDecision__c where LoanAppl__c=:recordId AND Decision_Type__c = 'UW Decision'];
            if (listDecisionSummary.size()>0) {
                system.debug('listDecisionSummary' + listDecisionSummary);
                return listDecisionSummary;
            }
            else {
                return null;
            }
        }
        Catch (exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    } */ 
    public void getDecisionSummary(String recordId) {
        try {
           listDecisionSummary = new  List<DecisionWrapper>();
            DecisionWrapper DecisionWrap;
            List<UWDecision__c> decisionList = [select Id,name,LoanAppl__c,LoanAppl__r.BDApplicantCoapp__c,LoanAppl__r.IncomerelateComm__c,LoanAppl__r.AddationalComm__c,LoanAppl__r.PrsnldetailsofPromotrs__c,User__c,User__r.name,Decision__c,DecisionRmrks__c,
            DecisionDt__c,createddate,IncomerelateComm__c,AddationalComm__c,PrsnldetailsofPromotrs__c,BDApplicantCoapp__c from UWDecision__c where LoanAppl__c=:recordId AND Decision_Type__c = 'UW Decision'];
            
            for(UWDecision__c Decision: decisionList){
            DecisionWrap = new DecisionWrapper();
            DecisionWrap.UserName= Decision.User__r.name != null? Decision.User__r.name:'';
            DecisionWrap.Decision= Decision.Decision__c != null? Decision.Decision__c:'';                                                                                                                   
            DecisionWrap.ApproverComment= Decision.DecisionRmrks__c !=null? Decision.DecisionRmrks__c:'';                                                                                                                  
            DecisionWrap.DecisionDate= Decision.DecisionDt__c != null? Decision.DecisionDt__c:null; 
            //DecisionWrap.formattedDecisionDate = String.valueof(Decision.DecisionDt__c.format('dd-MMM-yyyy'));
            if(Decision.DecisionDt__c!=null){
            DecisionWrap.formattedDecisionDate=DateTime.newInstance(Decision.DecisionDt__c.year(), Decision.DecisionDt__c.month(), Decision.DecisionDt__c.day()).format('dd-MMM-yyyy');
            }
             listDecisionSummary.add(DecisionWrap);
            
        }
            
            List<UWDecision__c> firstForwardDecision = [
                SELECT Id, Name, User__c, User__r.Name, Decision__c, DecisionRmrks__c, DecisionDt__c, CreatedDate
                FROM UWDecision__c
                WHERE LoanAppl__c = :recordId 
                AND Decision__c = 'Forward'
                ORDER BY CreatedDate ASC
                LIMIT 1
            ];

            if(firstForwardDecision.size()>0){
                uw = firstForwardDecision[0].User__r.Name!=null ? firstForwardDecision[0].User__r.Name:'';
            }
            List<UWDecision__c> approvedDecisions = [SELECT Id, User__r.Name, Decision__c, DecisionDt__c
                                                     FROM UWDecision__c
                                                     WHERE LoanAppl__c = :recordId AND Decision__c = 'Approve'
                                                     ORDER BY DecisionDt__c DESC LIMIT 1];
    
            if (approvedDecisions.size() > 0) {
                UWDecision__c approvedDecision = approvedDecisions[0];
                
                approver = approvedDecision.User__r.Name!=null? approvedDecision.User__r.Name:'';
                
            }

                                                                                                                              
        }
        Catch (exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }  
          
    public class getCollateralVerificationDetailsWrapper{
        
        public ApplAsset__c lstOfApplicantAssetsWrapp{get;set;}
        public Decimal totalValuation1 {get;set;}
        
        public Decimal totalValuation2 {get;set;}
        public Decimal totalValuation3 {get;set;}
        public Case legalCase{get;set;}
        public Case tsrCase{get;set;}
        public Case visitCase{get;set;}
        
    }  
  /*  public class getBorrowerVerificationDetailWrapper{
        
        @AuraEnabled
        public Applicant__c lstOfApplicantDetailsWrapp{get;set;}
        @AuraEnabled
        public String gstinStatus {get;set;}
        @AuraEnabled
        public String deDupe {get;set;}
        @AuraEnabled
        public String watchOutInvestor {get;set;}
        @AuraEnabled
        public String trackwizzRecordTypeCheck {get;set;}
        
    }*/
    
    public class getBorrowerVerificationDetailWrapper{
        
        @AuraEnabled
        public Applicant__c lstOfApplicantDetailsWrapp{get;set;}
        @AuraEnabled
        public String deDupe {get;set;}
        @AuraEnabled
        public String watchOutInvestor {get;set;}
        @AuraEnabled
        public String trackwizzRecordTypeCheck {get;set;}
        @AuraEnabled
        public String gstinStatus {get;set;}
        @AuraEnabled
        public String PanStatus {get;set;}
        @AuraEnabled
        public String voterIdStatus {get;set;}
        @AuraEnabled
        public String passportStatus {get;set;}
        @AuraEnabled
        public String drivingLicence {get;set;}
        @AuraEnabled
        public String ca {get;set;}
        @AuraEnabled
        public String doctor {get;set;}
        @AuraEnabled
        public String architect {get;set;}
        
    }
    
    public class getBorrowerFinalCPVSummaryDetailsWrapper{
        
        @AuraEnabled
        public Applicant__c lstOfCaseApplicantDetailsWrapp{get;set;}
        @AuraEnabled
        public String residenceCPV {get;set;}
        @AuraEnabled
        public String resiCumOfficeCPV {get;set;}
        @AuraEnabled
        public String permanentAddressCPV {get;set;}
        @AuraEnabled
        public String officeCPV {get;set;}
        @AuraEnabled
        public String otherAddressCPV {get;set;}
    }
    
    // Borrower details
    public List<getBorrowerDetailsWrapper> getBorrowerDetails(String recordId){
        try{
            List<getBorrowerDetailsWrapper> borrowerwrapperData = new List<getBorrowerDetailsWrapper>();

            set<Id> setOfApplicantId = new set<Id>();
            Map<Id,String> mapOfDPD = new map<Id,String>();
            List<Applicant__c>  listOfApplicantDetails = [Select id, FullName__c, TabName__c, ApplType__c, CustProfile__c, Constitution__c, Gender__c, Relationship__c, Age__c, UCID__c, Type_of_Borrower__c,LoanAppln__r.Loan_Tenure_Months__c,(SELECT Id from ApplAssetJn__r), (select Id, Prop_Owners__c from Applicant_Assets__r), (Select Id,Score__c from Bureau_Responses__r order by Score__c,createddate desc ) from Applicant__c where LoanAppln__c=:recordId and ApplType__c in ('P','C','G') ORDER BY CreatedDate ASC];
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

                    if(mapOfDPD.containsKey(appln.Id)){
                        getWrapperData.maxDPD = mapOfDPD.get(appln.Id);
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
                    system.debug('applAsstList-->'+applAsstList);
                    system.debug('bureauList-->'+bureauList);
                    
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
    
    // Financial Statement
    transient public string profitLossComment{get;set;}
    transient public string BalanceSheetComment{get;set;}
    
   public Map<Id,ConsoilidateFinancialWrapper> getfinancialSatement(String recordId) {
// Map<string, Map<string, Map<string, decimal>>> outerfinancialSummaryMap = new Map<string, Map<string, Map<string, decimal>>>();
FinancialRecordWrapper recordWrapper = new financialRecordWrapper();
Map<Id,Map<String,FinancialRecordWrapper>> finalMapOfFinancialDetails = new Map<Id,Map<String,FinancialRecordWrapper>>();
//Map<string, Map<string, decimal>> financialSummaryMap = new map<string, Map<string, decimal>>();
//Map<string, String> innerfinancialMap = new map<string, String>();

long lakh = 100000;
Decimal Turnover;
Decimal totalCurrentLiabilities;
Decimal totalCurrentAssets;
Decimal totalDebt;
Decimal AdjustedNetWorth;
Decimal stockValue;
Decimal debtors;
Decimal creditors;
List<Applicant_Financial_Summary__c> financialStatementDate = [Select Id,Applicant_Financial__r.Loan_Applicant__c,Applicant_Financial__r.Loan_Applicant__r.TabName__c,Applicant_Financial__r.Loan_Applicant__r.FullName__c, Total_Sales__c , EBITDA__c , Profit_Before_Depreciation_and_Tax_PBDT__c, Profit_Before_Tax__c, PAT__c, Depreciation__c, 
                                                                Interest_on_Partner_Capital__c, Salary_to_Partner_Directors__c, Non_Operating_Expenses_FxLoss_AssetLoss__c,
                                                                Gross_Profit__c, Other_Operating_Income_IncomeIncidental__c, Sundry_creditors__c, Advances_from_customers__c,
                                                                Other_current_liabilities__c, Provisions_for_exps_tax_etc__c, Bank_Borrowing_Working_Capital_OD_CC__c,
                                                                Stock__c, Debtors__c, LessSix_months__c,Greaterthan6__c,Other_loans_advances__c,Advances_to_Suppliers__c, Investments__c, Prepaid_expenses__c, Other_current_assets__c,
                                                                Cash_Bank_Balances__c, Total_Loan_funds__c, Adjusted_tangible_Netwroth__c, Opening_Stock__c, Purchases__c,
                                                                Direct_Expenses__c, Closing_Stock__c, Interest_on_Term_Loans__c, Interest_on_CC_OD_limits__c,Comments_on_Balance_sheet__c,Comments_on_Profit_Loss__c,
                                                                Applicant_Financial__r.Loan_Applicant__r.id, FinancialYearFor__c,Applicant_Financial__r.RecordType.Name, Applicant_Financial__r.Loan_Applicant__r.LoanAppln__r.EMI_Proposed_Loan__c from Applicant_Financial_Summary__c
                                                                where Applicant_Financial__r.recordtype.name IN('Balance Sheet','Profit & Loss') AND Applicant_Financial__r.Loan_Applicant__r.LoanAppln__r.id =:recordId ORDER BY FinancialYearFor__c,Applicant_Financial__r.RecordType.Name ASC]; //a08C4000007x0uSIAQ old id a08C40000063xjHIAQ

//assign the values;
//Map<String,RecordWrapper> tempMap = new Map<String,RecordWrapper>();
list<id> applicantIds = new list<id>();
Map<id, decimal> monthlyIncMap = new Map<id, decimal>();
Map<id, decimal> monthlyObligationMap = new Map<id, decimal>();
For(Applicant_Financial_Summary__c finance: financialStatementDate) {
         applicantIds.add(finance.Applicant_Financial__r.Loan_Applicant__c);
       }
Map<Id,ConsoilidateFinancialWrapper> applicantToFinancialWrap = new Map<Id,ConsoilidateFinancialWrapper>();
Integer index = 0;
list<Bre__c> MonthlyIncome = new List<Bre__c>();
MonthlyIncome = [Select id,Mnthlyapprincome__c, Applicant__c from Bre__c where Applicant__C  in:(applicantIds) and EligibilityType__c = 'Applicant' and isLatest__c=true]; //:finance.Applicant_Financial__r.Loan_Applicant__c
list<AggregateResult> MonthlyObligation = new List<AggregateResult>();
MonthlyObligation = [SELECT Applicant__c, sum(EMI__c)sum FROM BureauRespDtl__c where Applicant__c in:(applicantIds) and Treatment__c='To continue - Obligate' group by Applicant__c]; //.size()>0 ? (Decimal) [SELECT sum(EMI__c)sum FROM BureauRespDtl__c where Applicant__c in:(applicantIds) and Treatment__c='To continue - Obligate' group by Applicant__c][0].get('sum') :0;
system.debug('MonthlyIncome-->'+ MonthlyIncome);
system.debug('MonthlyObligation-->'+MonthlyObligation);
System.debug('ApplicantIds-->'+applicantIds);
       for (Bre__c monthlyInc: MonthlyIncome) {
           monthlyIncMap.put(monthlyInc.Applicant__c, monthlyInc.Mnthlyapprincome__c);
       }
       for (AggregateResult monthObligation: MonthlyObligation) {
           String ApplicantId = (string)monthObligation.get('Applicant__c');
           decimal sum = (decimal)monthObligation.get('sum');
           monthlyObligationMap.put(ApplicantId, sum);
       }


For(Applicant_Financial_Summary__c finance: financialStatementDate){
    
    if(finance.Applicant_Financial__r.recordtype.name=='Balance Sheet')
    {
        if(string.isEmpty(BalanceSheetComment)){
        BalanceSheetComment=!string.isEmpty(finance.Comments_on_Balance_sheet__c)?finance.Comments_on_Balance_sheet__c:'';
        system.debug('finance.Comments_on_Balance_sheet__c------------>'+finance.Comments_on_Balance_sheet__c);
        }
    }
    if(finance.Applicant_Financial__r.recordtype.name=='Profit & Loss')
    {
        if(string.isEmpty(profitLossComment)){
        profitLossComment=!string.isEmpty(finance.Comments_on_Profit_Loss__c)?finance.Comments_on_Profit_Loss__c:'';
        system.debug('finance.Comments_on_Profit_Loss__c------------>'+finance.Comments_on_Profit_Loss__c);
        }
    }
    
    recordWrapper  = new FinancialRecordWrapper();
    if(finalMapOfFinancialDetails.containskey(finance.Applicant_Financial__r.Loan_Applicant__c)){
        //tempMap = new Map<String,RecordWrapper>();
        Map<String,FinancialRecordWrapper> tempMap =  finalMapOfFinancialDetails.get(finance.Applicant_Financial__r.Loan_Applicant__c);
        if(tempMap.containskey(finance.FinancialYearFor__c)){
            recordWrapper = tempMap.get(finance.FinancialYearFor__c);
        }


    }
    recordWrapper.Year = finance.FinancialYearFor__c;
    recordWrapper.borrowerName = finance.Applicant_Financial__r.Loan_Applicant__r.FullName__c;
    //list<Bre__c> MonthlyIncome = [Select id,Mnthlyapprincome__c, Applicant__c from Bre__c where Applicant__C  =:finance.Applicant_Financial__r.Loan_Applicant__c and EligibilityType__c = 'Applicant' and isLatest__c=true]; //:finance.Applicant_Financial__r.Loan_Applicant__c
    //Decimal MonthlyObligation = [SELECT sum(EMI__c)sum FROM BureauRespDtl__c where Applicant__c =:finance.Applicant_Financial__r.Loan_Applicant__c and Treatment__c='To continue - Obligate' group by Applicant__c].size()>0 ? (Decimal) [SELECT sum(EMI__c)sum FROM BureauRespDtl__c where Applicant__c =:finance.Applicant_Financial__r.Loan_Applicant__c and Treatment__c='To continue - Obligate' group by Applicant__c][0].get('sum') :0;
    
    // system.debug('MonthlyObligation-->'+MonthlyObligation);
    
    if(monthlyIncMap.containsKey(finance.Applicant_Financial__r.Loan_Applicant__c) && monthlyObligationMap.containsKey(finance.Applicant_Financial__r.Loan_Applicant__c)){
        if (monthlyObligationMap.get(finance.Applicant_Financial__r.Loan_Applicant__c)>0  && monthlyIncMap.get(finance.Applicant_Financial__r.Loan_Applicant__c)>0) {
        recordWrapper.DSCRPre = (monthlyIncMap.get(finance.Applicant_Financial__r.Loan_Applicant__c)/monthlyObligationMap.get(finance.Applicant_Financial__r.Loan_Applicant__c)).setscale(2); 
        } //(MonthlyIncome[0].Mnthlyapprincome__c/MonthlyObligation).setScale(2);
        else{
            recordWrapper.DSCRPre=0;
        }
        if (finance.Applicant_Financial__r.Loan_Applicant__r.LoanAppln__r.EMI_Proposed_Loan__c!=null) {
            recordWrapper.DSCRPost = (monthlyIncMap.get(finance.Applicant_Financial__r.Loan_Applicant__c)/(monthlyObligationMap.get(finance.Applicant_Financial__r.Loan_Applicant__c)+finance.Applicant_Financial__r.Loan_Applicant__r.LoanAppln__r.EMI_Proposed_Loan__c)).setscale(2);
        }
        else{
             if (monthlyObligationMap.get(finance.Applicant_Financial__r.Loan_Applicant__c)>0  && monthlyIncMap.get(finance.Applicant_Financial__r.Loan_Applicant__c)>0) {
   
            recordWrapper.DSCRPost = (monthlyIncMap.get(finance.Applicant_Financial__r.Loan_Applicant__c)/(monthlyObligationMap.get(finance.Applicant_Financial__r.Loan_Applicant__c)+0)).setscale(2);
             }}
        // system.debug('DSCRPre-->'+DSCRPre);
        
    }
    else{
        recordWrapper.DSCRPre=0;
        recordWrapper.DSCRPost=0;
    }
    /*if (monthlyObligationMap.containsKey(finance.Applicant_Financial__r.Loan_Applicant__c)) {//IF(MonthlyIncome.size()>0 && MonthlyObligation!=null && MonthlyObligation > 0 && finance.Applicant_Financial__r.Loan_Applicant__r.LoanAppln__r.EMI_Proposed_Loan__c>0){
        
        recordWrapper.DSCRPost = monthlyObligationMap.get(finance.Applicant_Financial__r.Loan_Applicant__c);//(MonthlyIncome[0].Mnthlyapprincome__c/(MonthlyObligation + finance.Applicant_Financial__r.Loan_Applicant__r.LoanAppln__r.EMI_Proposed_Loan__c)).setScale(2);
        
    }*/


    if(finance.Applicant_Financial__r.recordtype.name == 'Balance Sheet'){
        //do calculaclate for balanceSheet
        
        if (finance.Sundry_creditors__c != null && finance.Advances_from_customers__c != null && finance.Other_current_liabilities__c !=null && finance.Provisions_for_exps_tax_etc__c != null && finance.Bank_Borrowing_Working_Capital_OD_CC__c != null) {
            recordWrapper.totalCurrentLiabilities = ((finance.Sundry_creditors__c + finance.Advances_from_customers__c + finance.Other_current_liabilities__c + finance.Provisions_for_exps_tax_etc__c + finance.Bank_Borrowing_Working_Capital_OD_CC__c)/lakh).setScale(2);
           //innerfinancialMap.put('totalCurrentLiabilities', totalCurrentLiabilities);
        }

        if (finance.Stock__c != null && finance.LessSix_months__c != null && finance.Greaterthan6__c != null && finance.Advances_to_Suppliers__c != null && finance.Investments__c != null && finance.Prepaid_expenses__c != null && finance.Other_current_assets__c != null && finance.Cash_Bank_Balances__c != null) {
           recordWrapper.totalCurrentAssets = ((finance.Stock__c + finance.LessSix_months__c + finance.Greaterthan6__c + finance.Advances_to_Suppliers__c + finance.Investments__c + finance.Prepaid_expenses__c + finance.Other_current_assets__c +finance.Other_loans_advances__c + finance.Cash_Bank_Balances__c)/lakh).setScale(2);
           // innerfinancialMap.put('totalCurrentAssets', totalCurrentAssets);
         }

         if (finance.Total_Loan_funds__c != null && finance.Bank_Borrowing_Working_Capital_OD_CC__c != null) {
             system.debug('Total_Loan_funds__c-->'+finance.Total_Loan_funds__c);
             system.debug('Bank_Borrowing_Working_Capital_OD_CC__c-->'+finance.Bank_Borrowing_Working_Capital_OD_CC__c);
             system.debug('fiancialYear-->'+finance.FinancialYearFor__c);
             System.debug('Borrower Name'+finance.Applicant_Financial__r.Loan_Applicant__r.TabName__c);
             recordWrapper.totalDebt = ((finance.Total_Loan_funds__c - finance.Bank_Borrowing_Working_Capital_OD_CC__c)/lakh).setScale(2);
                  // innerfinancialMap.put('totalDebt', (totalDebt).setScale(2));
          }

          if (finance.Adjusted_tangible_Netwroth__c != null) {
                 recordWrapper.adjustedNetworth = (finance.Adjusted_tangible_Netwroth__c/lakh).setScale(2);
                   
               if (recordWrapper.totalDebt != null && recordWrapper.adjustedNetworth>0) {
                     recordWrapper.debtEquityRatio = (recordWrapper.totalDebt/recordWrapper.adjustedNetworth).setScale(2);
                           if (recordWrapper.totalCurrentLiabilities != null) {
                            if(recordWrapper.adjustedNetworth>0){
                              recordWrapper.laverageRatio = ((recordWrapper.totalDebt+recordWrapper.totalCurrentLiabilities)/recordWrapper.adjustedNetworth).setScale(2);
                            }
                            else{
                                recordWrapper.laverageRatio = 0;
                            }
                     }
                 }
             }

             
                  recordWrapper.stockValue = (finance.Stock__c != null ? finance.Stock__c/lakh : 0).setScale(2);
                  system.debug('recordWrapper.stockValue-->'+recordWrapper.stockValue);

              
            if (recordWrapper.totalCurrentAssets!=null && recordWrapper.totalCurrentLiabilities != null) {
                recordWrapper.networkingCapital = recordWrapper.totalCurrentAssets-recordWrapper.totalCurrentLiabilities;
                if(recordWrapper.totalCurrentLiabilities>0){
                recordWrapper.currentRatio = (recordWrapper.totalCurrentAssets/recordWrapper.totalCurrentLiabilities).setScale(2);
            }
            else{
                recordWrapper.currentRatio = 0;
            }
                if (recordWrapper.stockValue != null) {
                    if(recordWrapper.totalCurrentLiabilities>0){
                     recordWrapper.quickRatio =((recordWrapper.totalCurrentAssets-recordWrapper.stockValue)/recordWrapper.totalCurrentLiabilities).setScale(2);
                    }
                    else{
                        recordWrapper.quickRatio =0;
                    }
                } 
            }

            if (finance.LessSix_months__c != null && finance.Greaterthan6__c != null) {
                Decimal debtor = finance.LessSix_months__c + finance.Greaterthan6__c;
                   recordWrapper.debtors = (debtor/lakh).setScale(2);
              
           }
          
           if(finance.Sundry_creditors__c !=null){
           recordWrapper.creditors = (finance.Sundry_creditors__c/lakh).setScale(2);
        }
                    

    }else if(finance.Applicant_Financial__r.recordtype.name == 'Profit & Loss'){
        
        //do calculaclate for balanceSheet

        recordWrapper.turnOver = finance.Total_Sales__c != null ? (finance.Total_Sales__c/lakh).setScale(2) : 0;
        recordWrapper.totalSales = finance.Total_Sales__c != null?finance.Total_Sales__c:0;

        if (finance.EBITDA__c != null) {
                                recordWrapper.EBIDTA_PBDIT = (finance.EBITDA__c/lakh).setScale(2);
                            if (finance.Interest_on_Term_Loans__c != null && finance.Interest_on_CC_OD_limits__c != null){
                               if((finance.Interest_on_Term_Loans__c + finance.Interest_on_CC_OD_limits__c) >0){
                                recordWrapper.interestCoverageRatio = (finance.EBITDA__c/(finance.Interest_on_Term_Loans__c + finance.Interest_on_CC_OD_limits__c)).setScale(2);
                            }
                            else{
                                recordWrapper.interestCoverageRatio =0;
                            }
                            } 
                        }
                    
                        recordWrapper.PBDT = finance.Profit_Before_Depreciation_and_Tax_PBDT__c != null ? (finance.Profit_Before_Depreciation_and_Tax_PBDT__c/lakh).setScale(2) : 0;
                        recordWrapper.PBT = finance.Profit_Before_Tax__c != null ? (finance.Profit_Before_Tax__c/lakh).setScale(2) : 0;
                        recordWrapper.PAT = finance.PAT__c != null ? (finance.PAT__c/lakh).setScale(2) : 0;
                        recordWrapper.purchase = finance.Purchases__c != null ? finance.Purchases__c: 0;

                        if (finance.PAT__c != null && finance.Depreciation__c != null && finance.Interest_on_Partner_Capital__c != null && finance.Non_Operating_Expenses_FxLoss_AssetLoss__c != null && finance.Salary_to_Partner_Directors__c != null) {
                            recordWrapper.cashProfit = ((finance.PAT__c+finance.Depreciation__c+finance.Interest_on_Partner_Capital__c+finance.Non_Operating_Expenses_FxLoss_AssetLoss__c+finance.Salary_to_Partner_Directors__c)/lakh).setScale(2);
                             }

                             if (finance.Gross_Profit__c != null && finance.Total_Sales__c !=null && finance.Other_Operating_Income_IncomeIncidental__c != null ) {
                                if((finance.Total_Sales__c+finance.Other_Operating_Income_IncomeIncidental__c)>0){
                                 recordWrapper.grossProfitMargin = ((finance.Gross_Profit__c/(finance.Total_Sales__c+finance.Other_Operating_Income_IncomeIncidental__c))*100).setScale(2);
                                }
                                else{
                                    recordWrapper.grossProfitMargin =0;
                                }
                            }   

                            if (recordWrapper.PBT != null && recordWrapper.turnOver != null){
                                if(recordWrapper.turnOver>0){
                                 recordWrapper.netProfitMargin = ((recordWrapper.PBT/recordWrapper.turnOver)*100).setScale(2);
                                }
                                else{
                                    recordWrapper.netProfitMargin = 0;
                                }
                             }

                             if (finance.Opening_Stock__c != null && finance.Purchases__c != null && finance.Direct_Expenses__c != null && finance.Closing_Stock__c != null ) {
                                if(finance.Opening_Stock__c+finance.Closing_Stock__c >0){
                                  recordWrapper.inventryTorunOver = ((finance.Opening_Stock__c+finance.Purchases__c+finance.Direct_Expenses__c-finance.Closing_Stock__c)/((finance.Opening_Stock__c+finance.Closing_Stock__c)/2)).setScale(2);
                                }
                                else{
                                    recordWrapper.inventryTorunOver = 0;
                                }
                                
                                //   if(finance.Stock__c != null && (finance.Opening_Stock__c + finance.Purchases__c+finance.Direct_Expenses__c-finance.Closing_Stock__c)>0){
                                //     system.debug('stockReplenishment-->');
                                //     recordWrapper.stockReplenishnentPeriod = finance.Stock__c != null ? ((finance.Stock__c/(finance.Opening_Stock__c+finance.Purchases__c+finance.Direct_Expenses__c-finance.Closing_Stock__c))*365).setScale(2) : 0;
                                //     system.debug('stockReplenishment after-->'+recordWrapper.stockReplenishnentPeriod);  
                                // }
                                // else{
                                //     recordWrapper.stockReplenishnentPeriod =0;
                                //    system.debug('stockReplenishment else-->'+recordWrapper.stockReplenishnentPeriod); 
                                // }

                                recordWrapper.openingStock = finance.Opening_Stock__c/lakh;
                                recordWrapper.closingStock = finance.Closing_Stock__c/lakh;
                                recordWrapper.directExpense = finance.Direct_Expenses__c/lakh;
                            }


    }

   
       // assigned out because both record types fields are there

       if (recordWrapper.openingStock != null && recordWrapper.purchase != null && recordWrapper.directExpense != null && recordWrapper.closingStock != null ) {

        decimal purchaseInLac = recordWrapper.purchase/lakh;
        if((recordWrapper.openingStock+purchaseInLac+recordWrapper.directExpense-recordWrapper.closingStock)>0){
           
            recordWrapper.stockReplenishnentPeriod = recordWrapper.stockValue != null ? ((recordWrapper.stockValue/(recordWrapper.openingStock+purchaseInLac+recordWrapper.directExpense-recordWrapper.closingStock))*365).setScale(2) : 0;
                                                                             
            
        }
        else{
            recordWrapper.stockReplenishnentPeriod =0;
            system.debug('stockReplenishment else-->'+recordWrapper.stockReplenishnentPeriod); 
        }
    }

        if(recordWrapper.debtors !=null){
            if(recordWrapper.debtors>0 && recordWrapper.totalSales>0){
            recordWrapper.debtorsCollectionPeriod =  recordWrapper.totalSales != null ? (((recordWrapper.debtors*lakh)/recordWrapper.totalSales)*365).setScale(2): 0;
        }
        else{
            recordWrapper.debtorsCollectionPeriod = 0;
        }
        }

        if (recordWrapper.creditors != null) {
            if(recordWrapper.purchase>0)
             {
             recordWrapper.creditorsPayementPeriod = recordWrapper.purchase != null ? (((recordWrapper.creditors*lakh)/recordWrapper.purchase)*365).setScale(2) : 0;
            }
            else{
                recordWrapper.creditorsPayementPeriod =0;
            }
       }


    if(finalMapOfFinancialDetails.containskey(finance.Applicant_Financial__r.Loan_Applicant__c)){
        Map<String,FinancialRecordWrapper> tempMap=  finalMapOfFinancialDetails.get(finance.Applicant_Financial__r.Loan_Applicant__c);
        tempMap.put(finance.FinancialYearFor__c,recordWrapper);
        finalMapOfFinancialDetails.put(finance.Applicant_Financial__r.Loan_Applicant__c,tempMap);
    }else{
        Map<String,FinancialRecordWrapper> tempMap = new Map<String,FinancialRecordWrapper>();
                    tempMap.put(finance.FinancialYearFor__c,recordWrapper);
                    finalMapOfFinancialDetails.put(finance.Applicant_Financial__r.Loan_Applicant__c,tempMap);
    }

    system.debug('finalMapOfFinancialDetails-->'+JSON.serialize(finalMapOfFinancialDetails));
}

Map<Id,ConsoilidateFinancialWrapper> finalaConolidatedMap = new Map<Id,ConsoilidateFinancialWrapper>();

Integer i=0;
for(Id fnMap:finalMapOfFinancialDetails.keySet()){

     recordWrapper  = new FinancialRecordWrapper();
    ConsoilidateFinancialWrapper ConsolidateWrapper = new ConsoilidateFinancialWrapper();
i=0;
//  decimal currentTurnOver;
//  decimal previousTurnOver;
for(String Year : finalMapOfFinancialDetails.get(fnMap).keySet()){
    recordWrapper = finalMapOfFinancialDetails.get(fnMap).get(year);
    // ConsolidateWrapper.previousFinancialRecord = false;
    // ConsolidateWrapper.currentFinancialRecord = false;
    // ConsolidateWrapper.provisionFinancialRecord = false;
    ConsolidateWrapper.DSCRPree = recordWrapper.DSCRPre;
    ConsolidateWrapper.DSCRPostt = recordWrapper.DSCRPost;

    if(i==0){
        
        ConsolidateWrapper.lastFinancialYear =recordWrapper;
        ConsolidateWrapper.previousFinancialRecord = true;
        ConsolidateWrapper.finacialYear1 = +'FY'+' '+Year;
        consolidateWrapper.borrowerNameConsolidate = recordWrapper.borrowerName;
       // previousTurnOver = recordWrapper.turnOver;

    }else if(i==1){
        ConsolidateWrapper.currentFinancialYear = recordWrapper;
        ConsolidateWrapper.currentFinancialRecord = true;
        ConsolidateWrapper.finacialYear2 = +'FY'+' '+Year;
        consolidateWrapper.borrowerNameConsolidate = recordWrapper.borrowerName;
       if(ConsolidateWrapper.currentFinancialYear.turnOver != null && consolidateWrapper.lastFinancialYear.turnOver !=null){
        if(consolidateWrapper.lastFinancialYear.turnOver >0){
        recordWrapper.turnOverGrowthRate = (((ConsolidateWrapper.currentFinancialYear.turnOver - consolidateWrapper.lastFinancialYear.turnOver) / consolidateWrapper.lastFinancialYear.turnOver)*100).setScale(2);
        recordWrapper.turnOverGrowthRatePercent = recordWrapper.turnOverGrowthRate+'%';
    }
    else{
        recordWrapper.turnOverGrowthRate = 0;
        recordWrapper.turnOverGrowthRatePercent = recordWrapper.turnOverGrowthRate+'%';
    }
      }
       // currentTurnOver = recordWrapper.turnOver;

        // if(previousTurnOver !=null){
        //     recordWrapper.turnOverGrowthRate = (currentTurnOver - previousTurnOver)/previousTurnOver;
        // }

    }else{
        ConsolidateWrapper.provisionalFinancialYear = recordWrapper;
        ConsolidateWrapper.provisionFinancialRecord = true;
        ConsolidateWrapper.finacialYear3 = +'FY'+' '+Year;
        consolidateWrapper.borrowerNameConsolidate = recordWrapper.borrowerName;
       if(ConsolidateWrapper.provisionalFinancialYear.turnOver !=null && consolidateWrapper.currentFinancialYear.turnOver !=null){
        if(consolidateWrapper.currentFinancialYear.turnOver>0){
        recordWrapper.turnOverGrowthRate = (((ConsolidateWrapper.provisionalFinancialYear.turnOver - consolidateWrapper.currentFinancialYear.turnOver) / consolidateWrapper.currentFinancialYear.turnOver)*100).setScale(2);
        recordWrapper.turnOverGrowthRatePercent = recordWrapper.turnOverGrowthRate+'%';
    }
    else{
        recordWrapper.turnOverGrowthRate = 0;
        recordWrapper.turnOverGrowthRatePercent = recordWrapper.turnOverGrowthRate+'%';
    }
   }
    }
    i++;
}
finalaConolidatedMap.put(fnMap,ConsolidateWrapper);
}
system.debug('finalaConolidatedMap-->'+JSON.serialize(finalaConolidatedMap));
return finalaConolidatedMap;
}
    /*public Static Map<Id,ConsoilidateFinancialWrapper> getfinancialSatement(String recordId) {
        Map<string, Map<string, Map<string, decimal>>> outerfinancialSummaryMap = new Map<string, Map<string, Map<string, decimal>>>();
        
        Map<string, Map<string, decimal>> financialSummaryMap = new map<string, Map<string, decimal>>();
        Map<string, String> innerfinancialMap = new map<string, String>();
        long lakh = 100000;
        Decimal Turnover;
        Decimal totalCurrentLiabilities;
        Decimal totalCurrentAssets;
        Decimal totalDebt;
        Decimal AdjustedNetWorth;
        Decimal stockValue;
        Decimal debtors;
        Decimal creditors;
        List<Applicant_Financial_Summary__c> financialStatementDate = [Select Id,Applicant_Financial__r.Loan_Applicant__c,Applicant_Financial__r.Loan_Applicant__r.TabName__c, Total_Sales__c , EBITDA__c , Profit_Before_Depreciation_and_Tax_PBDT__c, Profit_Before_Tax__c, PAT__c, Depreciation__c, 
                                                                       Interest_on_Partner_Capital__c, Salary_to_Partner_Directors__c, Non_Operating_Expenses_FxLoss_AssetLoss__c,
                                                                       Gross_Profit__c, Other_Operating_Income_IncomeIncidental__c, Sundry_creditors__c, Advances_from_customers__c,
                                                                       Other_current_liabilities__c, Provisions_for_exps_tax_etc__c, Bank_Borrowing_Working_Capital_OD_CC__c,
                                                                       Stock__c, Debtors__c, Advances_to_Suppliers__c, Investments__c, Prepaid_expenses__c, Other_current_assets__c,
                                                                       Cash_Bank_Balances__c, Total_Loan_funds__c, Adjusted_tangible_Netwroth__c, Opening_Stock__c, Purchases__c,
                                                                       Direct_Expenses__c, Closing_Stock__c, Interest_on_Term_Loans__c, Interest_on_CC_OD_limits__c,
                                                                       Applicant_Financial__r.Loan_Applicant__r.id, Applicant_Financial__r.RecordType.Name, FinancialYearFor__c from Applicant_Financial_Summary__c
                                                                       where Applicant_Financial__r.Loan_Applicant__r.LoanAppln__r.id =:recordId Order BY FinancialYearFor__c ASC];
        
        FinancialRecordWrapper recordWrapper = new financialRecordWrapper();//assign the values;
        //ConsoilidateFinancialWrapper returnWrapper = new ConsoilidateFinancialWrapper();
        List<ConsoilidateFinancialWrapper> returnWrapper = new List<ConsoilidateFinancialWrapper>();
        Map<Id,ConsoilidateFinancialWrapper> applicantToFinancialWrap = new Map<Id,ConsoilidateFinancialWrapper>();
        Integer index = 0;
        For(Applicant_Financial_Summary__c finance: financialStatementDate){
            
            if (finance.Applicant_Financial__r.Loan_Applicant__r.TabName__c != null) {
                recordWrapper = new financialRecordWrapper();
                
                
                recordWrapper.Id = finance.Applicant_Financial__r.Loan_Applicant__c;//finance.Id;
                recordWrapper.Year =finance.FinancialYearFor__c;
                
                recordWrapper.borrowerName = finance.Applicant_Financial__r.Loan_Applicant__r.TabName__c;
                // if(recordWrapper.borrowerName !=null && recordWrapper.borrowerName != finance.Applicant_Financial__r.Loan_Applicant__r.TabName__c){
                //     index =0;
                // }
                /*if(innerfinancialMap.containsKey(recordWrapper.borrowerName)==false){
index =0;
innerfinancialMap.put(recordWrapper.borrowerName, '');
}*/
                
                
               // recordWrapper.turnOver = finance.Total_Sales__c != null ? finance.Total_Sales__c/lakh : 0;
                
                // innerfinancialMap.put('Turnover', Turnover);
                /*if (financialSummaryMap.get(string.valueof(Integer.valueof(finance.FinancialYearFor__c)-1))!=null) {
Decimal TurnoverGrowthRatio=(Turnover-financialSummaryMap.get(string.valueof(Integer.valueof(finance.FinancialYearFor__c)-1)).get('Turnover'))*100;
}*/
               /* if (finance.EBITDA__c != null) {
                    recordWrapper.EBIDTA_PBDIT = (finance.EBITDA__c/lakh);
                    if (finance.Interest_on_Term_Loans__c != null && finance.Interest_on_CC_OD_limits__c != null){
                        recordWrapper.interestCoverageRatio = (finance.EBITDA__c/(finance.Interest_on_Term_Loans__c+finance.Interest_on_CC_OD_limits__c)).setScale(2);
                    } 
                }
                
                recordWrapper.PBDT = finance.Profit_Before_Depreciation_and_Tax_PBDT__c != null ? finance.Profit_Before_Depreciation_and_Tax_PBDT__c/lakh : 0;
                recordWrapper.PBT = finance.Profit_Before_Tax__c != null ? finance.Profit_Before_Tax__c/lakh : 0;
                recordWrapper.PAT = finance.PAT__c != null ? finance.PAT__c/lakh : 0;
                // System.debug('Ebidta');
                if (finance.PAT__c != null && finance.Depreciation__c != null && finance.Interest_on_Partner_Capital__c != null && finance.Non_Operating_Expenses_FxLoss_AssetLoss__c != null && finance.Salary_to_Partner_Directors__c != null) {
                    recordWrapper.cashProfit = (finance.PAT__c+finance.Depreciation__c+finance.Interest_on_Partner_Capital__c+finance.Non_Operating_Expenses_FxLoss_AssetLoss__c+finance.Salary_to_Partner_Directors__c)/lakh;
                }
                //System.debug('Ebidta');
                if (finance.Gross_Profit__c != null && finance.Total_Sales__c !=null && finance.Other_Operating_Income_IncomeIncidental__c != null) {
                    recordWrapper.grossProfitMargin = ((finance.Gross_Profit__c/(finance.Total_Sales__c+finance.Other_Operating_Income_IncomeIncidental__c))*100).setScale(2);
                } 
                // System.debug('Ebidta');
                if (finance.Profit_Before_Tax__c != null && finance.Total_Sales__c != null){
                    recordWrapper.netProfitMargin = ((finance.Profit_Before_Tax__c/finance.Total_Sales__c)*100).setScale(2);
                }
                // System.debug('Ebidta');
                if (finance.Sundry_creditors__c != null && finance.Advances_from_customers__c != null && finance.Other_current_liabilities__c !=null && finance.Provisions_for_exps_tax_etc__c != null && finance.Bank_Borrowing_Working_Capital_OD_CC__c != null) {
                    recordWrapper.totalCurrentLiabilities = finance.Sundry_creditors__c + finance.Advances_from_customers__c + finance.Other_current_liabilities__c + finance.Provisions_for_exps_tax_etc__c + finance.Bank_Borrowing_Working_Capital_OD_CC__c;
                    //innerfinancialMap.put('totalCurrentLiabilities', totalCurrentLiabilities);
                }
                // System.debug('Ebidta');
                if (finance.Stock__c != null && finance.Debtors__c != null && finance.Advances_to_Suppliers__c != null && finance.Investments__c != null && finance.Prepaid_expenses__c != null && finance.Other_current_assets__c != null && finance.Cash_Bank_Balances__c != null) {
                    recordWrapper.totalCurrentAssets = finance.Stock__c + finance.Debtors__c + finance.Advances_to_Suppliers__c + finance.Investments__c + finance.Prepaid_expenses__c + finance.Other_current_assets__c + finance.Cash_Bank_Balances__c;
                    // innerfinancialMap.put('totalCurrentAssets', totalCurrentAssets);
                }
                if (finance.Total_Loan_funds__c != null && finance.Bank_Borrowing_Working_Capital_OD_CC__c != null) {
                    recordWrapper.totalDebt = ((finance.Total_Loan_funds__c - finance.Bank_Borrowing_Working_Capital_OD_CC__c)/lakh).setScale(2);
                    // innerfinancialMap.put('totalDebt', (totalDebt).setScale(2));
                }
                if (finance.Adjusted_tangible_Netwroth__c != null) {
                    recordWrapper.adjustedNetworth = (finance.Adjusted_tangible_Netwroth__c/lakh).setScale(2);
                    // innerfinancialMap.put('AdjustedNetWorth', (finance.Adjusted_tangible_Netwroth__c/lakh).setScale(2));
                    if (recordWrapper.totalDebt != null) {
                        recordWrapper.debtEquityRatio = (recordWrapper.totalDebt/recordWrapper.adjustedNetworth).setScale(2);
                        if (recordWrapper.totalCurrentLiabilities != null) {
                            recordWrapper.laverageRatio = ((recordWrapper.totalDebt+recordWrapper.totalCurrentLiabilities)/recordWrapper.adjustedNetworth).setScale(2);
                        }
                    }
                }
                if(finance.Stock__c != null){
                    recordWrapper.stockValue = (finance.Stock__c/lakh != null ? finance.Stock__c/lakh : 0).setScale(2);
                }
                // innerfinancialMap.put('stockValue', (stockValue).setScale(2));
                if (recordWrapper.totalCurrentAssets!=null && recordWrapper.totalCurrentLiabilities != null) {
                    recordWrapper.networkingCapital = recordWrapper.totalCurrentAssets-recordWrapper.totalCurrentLiabilities;
                    recordWrapper.currentRatio = (recordWrapper.totalCurrentAssets/recordWrapper.totalCurrentLiabilities).setScale(2);
                    if (recordWrapper.stockValue != null) {
                        recordWrapper.quickRatio =((recordWrapper.totalCurrentAssets-recordWrapper.stockValue)/recordWrapper.totalCurrentLiabilities).setScale(2);
                    } 
                }
                if (finance.Debtors__c != null) {
                    recordWrapper.debtors = finance.Debtors__c/lakh;
                    // innerfinancialMap.put('debtors', debtors);
                    recordWrapper.debtorsCollectionPeriod =  finance.Total_Sales__c != null ? ((recordWrapper.debtors*lakh)/(finance.Total_Sales__c*365)).setScale(2): 0;
                }
                if (finance.Sundry_creditors__c != null) {
                    recordWrapper.creditors = finance.Sundry_creditors__c/lakh;
                    //innerfinancialMap.put('creditors',creditors);
                    recordWrapper.creditorsPayementPeriod = finance.Purchases__c != null ? ((recordWrapper.creditors*lakh)/finance.Purchases__c).setScale(2) : 0;
                }
                if (finance.Opening_Stock__c != null && finance.Purchases__c != null && finance.Direct_Expenses__c != null && finance.Closing_Stock__c != null) {
                    recordWrapper.inventryTorunOver = ((finance.Opening_Stock__c+finance.Purchases__c+finance.Direct_Expenses__c-finance.Closing_Stock__c)/((finance.Opening_Stock__c+finance.Closing_Stock__c)/2)).setScale(2);
                    recordWrapper.stockReplenishnentPeriod = finance.Stock__c != null ? ((finance.Stock__c/(finance.Opening_Stock__c+finance.Purchases__c+finance.Direct_Expenses__c-finance.Closing_Stock__c))*365).setScale(2) : 0;
                    //innerfinancialMap.put('Stock replenishment period (days)', finance.Stock__c != null ? ((finance.Stock__c/(finance.Opening_Stock__c+finance.Purchases__c+finance.Direct_Expenses__c-finance.Closing_Stock__c))*365).setScale(2) : 0);
                }
                // financialSummaryMap.put(finance.FinancialYearFor__c, innerfinancialMap);
                // outerfinancialSummaryMap.put(borrowername, financialSummaryMap);
                ConsoilidateFinancialWrapper wrapObj;
                if(applicantToFinancialWrap.containsKey(finance.Applicant_Financial__r.Loan_Applicant__c)){
                    wrapObj = applicantToFinancialWrap.get(finance.Applicant_Financial__r.Loan_Applicant__c);
                    if(wrapObj.currentFinancialYear == null){
                        wrapObj.currentFinancialYear = recordWrapper;
                        wrapObj.currentFinancialRecord = true;
                        wrapObj.finacialYear2 = finance.FinancialYearFor__c;
                        //wrapObj.Id = recordWrapper.Id;
                    }else{
                        wrapObj.provisionalFinancialYear = recordWrapper;
                        wrapObj.provisionFinancialRecord = true;
                        wrapObj.finacialYear3 = finance.FinancialYearFor__c;
                        //wrapObj.Id = recordWrapper.Id;
                    }
                    applicantToFinancialWrap.put(finance.Applicant_Financial__r.Loan_Applicant__c,wrapObj);
                }else{
                    wrapObj = new ConsoilidateFinancialWrapper();
                    wrapObj.lastFinancialYear = recordWrapper;
                    wrapObj.previousFinancialRecord = true;
                    wrapObj.finacialYear1 = finance.FinancialYearFor__c;
                    //wrapObj.Id = recordWrapper.Id;
                    applicantToFinancialWrap.put(finance.Applicant_Financial__r.Loan_Applicant__c,wrapObj);
                }
            }
            
            
            // returnWrapper = new ConsoilidateFinancialWrapper();
            /*ConsoilidateFinancialWrapper lstWrapperData = new ConsoilidateFinancialWrapper();
if(index == 0){
// ConsoilidateFinancialWrapper lstWrapperData = new ConsoilidateFinancialWrapper();
// returnWrapper = new ConsoilidateFinancialWrapper();
lstWrapperData.lastFinancialYear =recordWrapper;
lstWrapperData.previousFinancialRecord = true;
lstWrapperData.finacialYear1 = finance.FinancialYearFor__c;
lstWrapperData.Id = recordWrapper.Id;
//  returnWrapper.add(lstWrapperData);
}else if(index==1){
//  ConsoilidateFinancialWrapper lstWrapperData = new ConsoilidateFinancialWrapper();
//  returnWrapper = new ConsoilidateFinancialWrapper();
lstWrapperData.currentFinancialYear = recordWrapper;
lstWrapperData.currentFinancialRecord = true;
lstWrapperData.finacialYear2 = finance.FinancialYearFor__c;
lstWrapperData.Id = recordWrapper.Id;
// returnWrapper.add(lstWrapperData);
}else if (index==2){
//  ConsoilidateFinancialWrapper lstWrapperData = new ConsoilidateFinancialWrapper();
// returnWrapper = new ConsoilidateFinancialWrapper();
lstWrapperData.provisionalFinancialYear = recordWrapper;
lstWrapperData.provisionFinancialRecord = true;
lstWrapperData.finacialYear3 = finance.FinancialYearFor__c;
lstWrapperData.Id = recordWrapper.Id;
//returnWrapper.add(lstWrapperData);
}
index++;
returnWrapper.add(lstWrapperData);*/
        //}
        //keylist = outerfinancialSummaryMap.keySet();
        //   System.debug('outerfinancialSummaryMap '+ outerfinancialSummaryMap);
        //System.debug('returnWrapper-->'+ returnWrapper);
        //return Map<Id,ConsoilidateFinancialWrapper>
        //system.debug('applicantToFinancialWrap'+applicantToFinancialWrap);
        //return applicantToFinancialWrap;
  //  }
    
    /*public ConsoilidateFinancialWrapper getfinancialSatement(String recordId) {
        System.debug('Inside Method');
        //Map<string, Map<string, Map<string, decimal>>> outerfinancialSummaryMap = new Map<string, Map<string, Map<string, decimal>>>();
        outerfinancialSummaryMap = new Map<string, Map<string, Map<string, decimal>>>();
        Map<string, Map<string, decimal>> financialSummaryMap = new map<string, Map<string, decimal>>();
        map<String, string> nameMap = new map<string, string>();
        map<string, decimal> innerfinancialMap = new map<string, decimal>();
        long lakh = 100000;
        Decimal Turnover;
        Decimal totalCurrentLiabilities;
        Decimal totalCurrentAssets;
        Decimal totalDebt;
        Decimal AdjustedNetWorth;
        Decimal stockValue;
        Decimal debtors;
        Decimal creditors;
        List<Applicant_Financial_Summary__c> financialStatementDate = [Select Applicant_Financial__r.Loan_Applicant__r.TabName__c, Total_Sales__c , EBITDA__c , Profit_Before_Depreciation_and_Tax_PBDT__c, Profit_Before_Tax__c, PAT__c, Depreciation__c, 
                                                                       Interest_on_Partner_Capital__c, Salary_to_Partner_Directors__c, Non_Operating_Expenses_FxLoss_AssetLoss__c,
                                                                       Gross_Profit__c, Other_Operating_Income_IncomeIncidental__c, Sundry_creditors__c, Advances_from_customers__c,
                                                                       Other_current_liabilities__c, Provisions_for_exps_tax_etc__c, Bank_Borrowing_Working_Capital_OD_CC__c,
                                                                       Stock__c, Debtors__c, Advances_to_Suppliers__c, Investments__c, Prepaid_expenses__c, Other_current_assets__c,
                                                                       Cash_Bank_Balances__c, Total_Loan_funds__c, Adjusted_tangible_Netwroth__c, Opening_Stock__c, Purchases__c,
                                                                       Direct_Expenses__c, Closing_Stock__c, Interest_on_Term_Loans__c, Interest_on_CC_OD_limits__c,
                                                                       Applicant_Financial__r.Loan_Applicant__r.id, FinancialYearFor__c from Applicant_Financial_Summary__c
                                                                       where Applicant_Financial__r.Loan_Applicant__r.LoanAppln__r.id = 'a08C40000063xjHIAQ' Order BY FinancialYearFor__c ASC];
        
        FinancialRecordWrapper recordWrapper = new financialRecordWrapper();//assign the values;
        returnWrapper = new ConsoilidateFinancialWrapper();
        Integer index = 0;
        For(Applicant_Financial_Summary__c finance: financialStatementDate){
            if (finance.Applicant_Financial__r.Loan_Applicant__r.TabName__c != null) {
                system.debug('Turnover'+finance.Total_Sales__c);
                recordWrapper = new financialRecordWrapper();
                recordWrapper.borrowerName = finance.Applicant_Financial__r.Loan_Applicant__r.TabName__c;
                System.debug('name+year' + recordWrapper.borrowerName + finance.FinancialYearFor__c);
               /* if(!nameMap.containsKey(recordWrapper.borrowerName)){
                    index =0;
            }
                nameMap.put(recordWrapper.borrowerName, '');*/
                
              /*  recordWrapper.turnOver = finance.Total_Sales__c != null ? finance.Total_Sales__c/lakh : 0;
                innerfinancialMap.put('Turnover', recordWrapper.turnOver);
                /*if (financialSummaryMap.get(string.valueof(Integer.valueof(finance.FinancialYearFor__c)-1))!=null) {
Decimal TurnoverGrowthRatio=(Turnover-financialSummaryMap.get(string.valueof(Integer.valueof(finance.FinancialYearFor__c)-1)).get('Turnover'))*100;
}*/
              /*  if (finance.EBITDA__c != null) {
                    recordWrapper.EBIDTA_PBDIT = (finance.EBITDA__c/lakh);
                    innerfinancialMap.put('EBIDTA_PBDIT', recordWrapper.EBIDTA_PBDIT);
                    if (finance.Interest_on_Term_Loans__c != null && finance.Interest_on_CC_OD_limits__c != null){
                        recordWrapper.interestCoverageRatio = (finance.EBITDA__c/(finance.Interest_on_Term_Loans__c+finance.Interest_on_CC_OD_limits__c)).setScale(2);
                        innerfinancialMap.put('interestCoverageRatio', recordWrapper.interestCoverageRatio);
                    } 
                }
                
                recordWrapper.PBDT = finance.Profit_Before_Depreciation_and_Tax_PBDT__c != null ? finance.Profit_Before_Depreciation_and_Tax_PBDT__c/lakh : 0;
                innerfinancialMap.put('PBDT', recordWrapper.PBDT);
                recordWrapper.PBT = finance.Profit_Before_Tax__c != null ? finance.Profit_Before_Tax__c/lakh : 0;
                innerfinancialMap.put('PBT', recordWrapper.PBT);
                recordWrapper.PAT = finance.PAT__c != null ? finance.PAT__c/lakh : 0;
                innerfinancialMap.put('PAT', recordWrapper.PAT);
                 System.debug('Ebidta');
                if (finance.PAT__c != null && finance.Depreciation__c != null && finance.Interest_on_Partner_Capital__c != null && finance.Non_Operating_Expenses_FxLoss_AssetLoss__c != null && finance.Salary_to_Partner_Directors__c != null) {
                    recordWrapper.cashProfit = (finance.PAT__c+finance.Depreciation__c+finance.Interest_on_Partner_Capital__c+finance.Non_Operating_Expenses_FxLoss_AssetLoss__c+finance.Salary_to_Partner_Directors__c)/lakh;
                    innerfinancialMap.put('cashProfit', recordWrapper.cashProfit);
                }
                System.debug('Ebidta');
                if (finance.Gross_Profit__c != null && finance.Total_Sales__c !=null && finance.Other_Operating_Income_IncomeIncidental__c != null) {
                    recordWrapper.grossProfitMargin = ((finance.Gross_Profit__c/(finance.Total_Sales__c+finance.Other_Operating_Income_IncomeIncidental__c))*100).setScale(2);
                    innerfinancialMap.put('grossProfitMargin', recordWrapper.grossProfitMargin);
                } 
                System.debug('Ebidta');
                if (finance.Profit_Before_Tax__c != null && finance.Total_Sales__c != null){
                    recordWrapper.netProfitMargin = ((finance.Profit_Before_Tax__c/finance.Total_Sales__c)*100).setScale(2);
                    innerfinancialMap.put('Net Profit Margin', recordWrapper.netProfitMargin);
                }
                System.debug('Ebidta');
                if (finance.Sundry_creditors__c != null && finance.Advances_from_customers__c != null && finance.Other_current_liabilities__c !=null && finance.Provisions_for_exps_tax_etc__c != null && finance.Bank_Borrowing_Working_Capital_OD_CC__c != null) {
                    recordWrapper.totalCurrentLiabilities = finance.Sundry_creditors__c + finance.Advances_from_customers__c + finance.Other_current_liabilities__c + finance.Provisions_for_exps_tax_etc__c + finance.Bank_Borrowing_Working_Capital_OD_CC__c;
                    innerfinancialMap.put('totalCurrentLiabilities', recordWrapper.totalCurrentLiabilities);
                }
                System.debug('Ebidta');
                if (finance.Stock__c != null && finance.Debtors__c != null && finance.Advances_to_Suppliers__c != null && finance.Investments__c != null && finance.Prepaid_expenses__c != null && finance.Other_current_assets__c != null && finance.Cash_Bank_Balances__c != null) {
                    recordWrapper.totalCurrentAssets = finance.Stock__c + finance.Debtors__c + finance.Advances_to_Suppliers__c + finance.Investments__c + finance.Prepaid_expenses__c + finance.Other_current_assets__c + finance.Cash_Bank_Balances__c;
                    innerfinancialMap.put('totalCurrentAssets', recordWrapper.totalCurrentAssets);
                }
                if (finance.Total_Loan_funds__c != null && finance.Bank_Borrowing_Working_Capital_OD_CC__c != null) {
                    recordWrapper.totalDebt = ((finance.Total_Loan_funds__c - finance.Bank_Borrowing_Working_Capital_OD_CC__c)/lakh).setScale(2);
                    innerfinancialMap.put('totalDebt', (recordWrapper.totalDebt).setScale(2));
                }
                if (finance.Adjusted_tangible_Netwroth__c != null) {
                    recordWrapper.adjustedNetworth = (finance.Adjusted_tangible_Netwroth__c/lakh).setScale(2);
                    innerfinancialMap.put('AdjustedNetWorth', (finance.Adjusted_tangible_Netwroth__c/lakh).setScale(2));
                    if (recordWrapper.totalDebt != null) {
                        recordWrapper.debtEquityRatio = (recordWrapper.totalDebt/recordWrapper.adjustedNetworth).setScale(2);
                        if (recordWrapper.totalCurrentLiabilities != null) {
                            recordWrapper.laverageRatio = ((recordWrapper.totalDebt+recordWrapper.totalCurrentLiabilities)/recordWrapper.adjustedNetworth).setScale(2);
                        }
                    }
                }System.debug('After adjustedNetworth');
                recordWrapper.stockValue = (finance.Stock__c != null ? finance.Stock__c/lakh : 0).setScale(2);
                innerfinancialMap.put('stockValue', (recordWrapper.stockValue).setScale(2));
                if (recordWrapper.totalCurrentAssets!=null && recordWrapper.totalCurrentLiabilities != null) {
                    recordWrapper.networkingCapital = recordWrapper.totalCurrentAssets-recordWrapper.totalCurrentLiabilities;
                    recordWrapper.currentRatio = (recordWrapper.totalCurrentAssets/recordWrapper.totalCurrentLiabilities).setScale(2);
                    if (recordWrapper.stockValue != null) {
                        recordWrapper.quickRatio =((recordWrapper.totalCurrentAssets-recordWrapper.stockValue)/recordWrapper.totalCurrentLiabilities).setScale(2);
                    } 
                }System.debug('After stockValue');
                if (finance.Debtors__c != null) {
                    recordWrapper.debtors = finance.Debtors__c/lakh;
                    innerfinancialMap.put('debtors', debtors);
                    recordWrapper.debtorsCollectionPeriod =  finance.Total_Sales__c != null ? ((recordWrapper.debtors*lakh)/(finance.Total_Sales__c*365)).setScale(2): 0;
                    innerfinancialMap.put('debtorsCollectionPeriod', recordWrapper.debtorsCollectionPeriod);
                }System.debug('After debtors');
                if (finance.Sundry_creditors__c != null) {
                    recordWrapper.creditors = finance.Sundry_creditors__c/lakh;
                    innerfinancialMap.put('creditors',creditors);
                    recordWrapper.creditorsPayementPeriod = finance.Purchases__c != null ? ((recordWrapper.creditors*lakh)/finance.Purchases__c).setScale(2) : 0;
                    innerfinancialMap.put('creditorsPayementPeriod',recordWrapper.creditorsPayementPeriod);
                }System.debug('After Creditors');
                if (finance.Opening_Stock__c != null && finance.Purchases__c != null && finance.Direct_Expenses__c != null && finance.Closing_Stock__c != null) {
                    recordWrapper.inventryTorunOver = ((finance.Opening_Stock__c+finance.Purchases__c+finance.Direct_Expenses__c-finance.Closing_Stock__c)/((finance.Opening_Stock__c+finance.Closing_Stock__c)/2)).setScale(2);
                    recordWrapper.stockReplenishnentPeriod = finance.Stock__c != null ? ((finance.Stock__c/(finance.Opening_Stock__c+finance.Purchases__c+finance.Direct_Expenses__c-finance.Closing_Stock__c))*365).setScale(2) : 0;
                    innerfinancialMap.put('Stock replenishment period', finance.Stock__c != null ? ((finance.Stock__c/(finance.Opening_Stock__c+finance.Purchases__c+finance.Direct_Expenses__c-finance.Closing_Stock__c))*365).setScale(2) : 0);
                }
               
                
            }
            
            if(index == 0){
                returnWrapper.lastFinancialYear = recordWrapper;
                returnWrapper.previousFinancialRecord = true;
                returnWrapper.finacialYear1 = finance.FinancialYearFor__c;
            }else if(index==1){
                returnWrapper.currentFinancialYear = recordWrapper;
                returnWrapper.currentFinancialRecord = true;
                returnWrapper.finacialYear2 = finance.FinancialYearFor__c;
            }else if (index==2){
                returnWrapper.provisionalFinancialYear = recordWrapper;
                returnWrapper.provisionFinancialRecord = true;
                returnWrapper.finacialYear3 = finance.FinancialYearFor__c;
            }
            System.debug('finance.FinancialYearFor__c'+ finance.FinancialYearFor__c);
            financialSummaryMap.put(finance.FinancialYearFor__c, innerfinancialMap);
                
            System.debug('financialSummaryMap'+ financialSummaryMap);
            outerfinancialSummaryMap.put(finance.Applicant_Financial__r.Loan_Applicant__r.TabName__c, financialSummaryMap);
            System.debug('index '+ index);
            System.debug('return returnWrapper'+returnWrapper);
            index++;
            System.debug('Inner ' + innerfinancialMap);
        }
        //keylist = outerfinancialSummaryMap.keySet();
        //   System.debug('outerfinancialSummaryMap '+ outerfinancialSummaryMap);
        
        System.debug('returnWrapper.finacialYear1' + returnWrapper.finacialYear1);
        System.debug('returnWrapper.finacialYear2' + returnWrapper.finacialYear2);
        System.debug('returnWrapper-->'+ returnWrapper);
        System.debug('Outer Map '+ outerfinancialSummaryMap);
        
        return returnWrapper;
    }*/
    
    public ResponseWrapper fetchRecords(String recordId) {
        String incomeProgramAppl ='Cash Flow - Assessed income,Business income - Regular Income Program (P&L),Gross Eligible Salary with Bank Credit,Net Eligible Salary with Bank Credit,Cash Salary,Net Salary,Rental bank credit,Rental without bank credit,Pension Income,Other Income,Agriculture Income,Gross Salary';
        applicantEliMap = new Map<Id,ApplicantEligibility>();
        //BRE  Eligibility And Applicant Obj data
        List<BRE_Eligibility__c> breList = new List<BRE_Eligibility__c>();
        breList = [SELECT Id, Name, BREResponse__c, Type__c, IncomeProgram__c,BREResponse__r.Applicant__c,BREResponse__r.Applicant__r.FullName__c,BREResponse__r.Applicant__r.AssessmentProgram__c, BREResponse__r.LoanAppl__c, BREValue__c, BREValueType__c, IsLatest__c FROM BRE_Eligibility__c WHERE IsLatest__c=true AND type__c = 'Applicant' AND BREResponse__r.LoanAppl__c=:recordId];
        
        ApplicantEligibility wrapObj = new ApplicantEligibility();
        system.debug('breList-->'+breList);
        
        ResponseWrapper resp = new ResponseWrapper();
        resp.application = new ApplicantEligibility();
        for (BRE_Eligibility__c record : breList) {
            wrapObj.applicantRecord = record.BREResponse__r.Applicant__r.FullName__c;
            wrapObj.ApplicantId = record.BREResponse__r.Applicant__c;
            
            if(record.Type__c =='Applicant' && record.BREResponse__r.Applicant__c != null){
                system.debug('In Applicant type');
                wrapObj = (applicantEliMap.containsKey(record.BREResponse__r.Applicant__c)) ? applicantEliMap.get(record.BREResponse__r.Applicant__c): new ApplicantEligibility();
                
                wrapObj.assesmentProgram =(record.BREResponse__r.Applicant__r.AssessmentProgram__c != null)? record.BREResponse__r.Applicant__r.AssessmentProgram__c: 'Not Available';
                resp.showAssesmentProgram =(record.BREResponse__r.Applicant__r.AssessmentProgram__c != null);
                
                
                /*if(record.IncomeProgram__c == 'Cash Flow - Assessed income'){
                    resp.showcashFlowAssessedIncome = true;
                    wrapObj.cashFlowAssedIncome = record.BREValue__c;
                }*/
                if(record.IncomeProgram__c == 'Business income - Regular Income Program (P&L)'){
                    resp.showBusinessIncome = true;
                    wrapObj.businessIncome = record.BREValue__c;
                }if(record.IncomeProgram__c == 'Gross Eligible Salary with Bank Credit'){
                    resp.showGrossWithBankCredit = true;
                    wrapObj.grossSalaryBankCredit = record.BREValue__c;
                }if(record.IncomeProgram__c == 'Net Eligible Salary with Bank Credit'){
                    resp.showNetWithBankCredit = true;
                    wrapObj.netSalaryBankCredit = record.BREValue__c;
                    
                }
                applicantEliMap.put(record.BREResponse__r.Applicant__c,wrapObj);
            }
        }
        system.debug('Manish1'+applicantEliMap.values().size());
        for(Applicant__c appli : [select id,LoanAppln__c, ApplType__c, FullName__c,Type_of_Borrower__c,Average_Monthly_Rental_No_Bank_Credit__c,
                                  Average_Monthly_Rental_With_Bank_Credit__c,Average_Other_Income__c,AssessmentProgram__c,
                                  AverageMonthlyAgricultureIncome__c,Average_Monthly_Cash_Salary__c,Average_Monthly_Pension__c,
                                  Average_Monthly_Gross_Salary__c, Average_Net_Salary__c, (select NET_CASH_PROFIT_LOSS__c from Applicant_Income__r where RecordType.DeveloperName = 'cashflow_map')
                                  FROM Applicant__c where Type_of_Borrower__c='Financial' AND ApplType__c IN('P','G','C') AND LoanAppln__c=:recordId]){
                                      
                                      wrapObj =(applicantEliMap.containsKey(appli.Id))?applicantEliMap.get(appli.Id):new ApplicantEligibility();
                                      
                                      //wrapObj =(applicantEliMap.containsKey(appli.Id))? applicantEliMap.get(appli.Id):new ApplicantEligibility();
                                      
                                      wrapObj.ApplicantId = appli.Id;          
                                      wrapObj.applicantRecord = appli.FullName__c;
                                      
                                      wrapObj.assesmentProgram =(appli.AssessmentProgram__c != null)?appli.AssessmentProgram__c:'';
                                      if (appli.AssessmentProgram__c != null) {
                                        resp.showAssesmentProgram=(appli.AssessmentProgram__c != null);
                                      }
                                      
                                      if(appli.Applicant_Income__r.size() > 0){
                                        wrapObj.cashFlowAssedIncome =(appli.Applicant_Income__r[0].NET_CASH_PROFIT_LOSS__c != null)?appli.Applicant_Income__r[0].NET_CASH_PROFIT_LOSS__c:0;
                                          if (appli.Applicant_Income__r[0].NET_CASH_PROFIT_LOSS__c != null) {
                                            resp.showcashFlowAssessedIncome = (appli.Applicant_Income__r[0].NET_CASH_PROFIT_LOSS__c != null);
                                          }
                                      }
                                      wrapObj.cashSalary =(appli.Average_Monthly_Cash_Salary__c != null)?appli.Average_Monthly_Cash_Salary__c:0;
                                      if (appli.Average_Monthly_Cash_Salary__c != null) {
                                        resp.showCashSalary=(appli.Average_Monthly_Cash_Salary__c != null);
                                      }
                                      system.debug(resp.showCashSalary);
                                      
                                      wrapObj.rentalBankCredit =(appli.Average_Monthly_Rental_With_Bank_Credit__c != null)?appli.Average_Monthly_Rental_With_Bank_Credit__c:0;
                                      if (appli.Average_Monthly_Rental_With_Bank_Credit__c != null) {
                                        resp.showRentalWBankCredit =(appli.Average_Monthly_Rental_With_Bank_Credit__c != null);
                                      }
                                      // wrapObj.showRentalWBankCredit =(appli.Average_Monthly_Rental_With_Bank_Credit__c != null);
                                      wrapObj.rentalWithoutBankCredit =(appli.Average_Monthly_Rental_No_Bank_Credit__c != null)?appli.Average_Monthly_Rental_No_Bank_Credit__c:0;
                                      if (appli.Average_Monthly_Rental_No_Bank_Credit__c != null) {
                                        resp.showRentalWNoBankCredit =(appli.Average_Monthly_Rental_No_Bank_Credit__c != null);
                                      }
                                      
                                      wrapObj.PensionIncome = (appli.Average_Monthly_Pension__c != null) ? appli.Average_Monthly_Pension__c : 0;
                                      if (appli.Average_Monthly_Pension__c != null) {
                                        resp.showPensionIncome = (appli.Average_Monthly_Pension__c != null);
                                      }
                                      
                                      wrapObj.AgricultureIncome =(appli.AverageMonthlyAgricultureIncome__c != null)? appli.AverageMonthlyAgricultureIncome__c:0;
                                      if (appli.AverageMonthlyAgricultureIncome__c != null) {
                                        resp.showAgricultureIncome = (appli.AverageMonthlyAgricultureIncome__c != null);
                                      }
                                      
                                      wrapObj.OtherIncome =(appli.Average_Other_Income__c != null)?appli.Average_Other_Income__c:0;
                                      if (appli.Average_Other_Income__c != null) {
                                        resp.showOtherIncome =(appli.Average_Other_Income__c != null);
                                      }
                                      
                                      applicantEliMap.put(appli.Id,wrapObj);    
                                  }
        system.debug('applicantEliMap-->'+applicantEliMap);
        List<BRE__c> breRespList = new List<BRE__c>();
        system.debug('Manish1'+applicantEliMap.values().size());
        
        breRespList=[SELECT Id, LoanAppl__c, Applicant__c,Max_EMI_Other_than_Cash_Salary__c, EligibilityType__c, AppraisedMonIncome__c, RAACROI__c, Applicable_FOIR__c, Appl_EMI_Net_Salary__c, Applicable_FOIR_Cash_Salary__c, Max_EMI_Cash_Salary__c, Eligible_tenure_in_Months__c, FinaLnEligOthr_Cash_Salary__c, FinLoanEligibCashSalary__c,FinancialLoanEligibilityTotal__c, Financial_Loan_Eligibility_Total__c, Application_level_Assessment_program__c,MaxBreLnEliWoIns__c,MaxBreLnEliWIns__c,MaxBreLnEliWDeviation__c,MaxFinLnEligblwithDevi__c,EMI__c,Actual_FOIR__c, Actual_LTV__c, CombLTV_FOIR__c,Combined_LTV_And_FOIR_without_Insurance__c,MaxcoltrlLnEliWDeviation__c,LTVApplWDeviation__c,TotlLTVBsdLnEliWIns__c,AddLTVBsdEliIns__c,LTVBsdEliWOIns__c,LTVApplLnWtInsurance__c,LTVApplLnWOInsurance__c FROM BRE__c where LoanAppl__c=:recordId];
        system.debug('breRespList>>>>'+breRespList);
        for (BRE__c recordBREResp : breRespList) {
            
          if(recordBREResp.EligibilityType__c =='Applicant' && recordBREResp.Applicant__c != null){
                
                wrapObj =(applicantEliMap.containsKey(recordBREResp.Applicant__c))? applicantEliMap.get(recordBREResp.Applicant__c):new ApplicantEligibility();
                
                wrapObj.ApprMonthIncOtherthanCashSalary =(recordBREResp.AppraisedMonIncome__c != null)?recordBREResp.AppraisedMonIncome__c:0;
               system.debug('wrapObj.ApprMonthIncOtherthanCashSalary-->'+wrapObj.ApprMonthIncOtherthanCashSalary);
                
                wrapObj.ApplFOIR =(recordBREResp.Applicable_FOIR__c != null)?recordBREResp.Applicable_FOIR__c:0;
                
                wrapObj.ApplEMINetSalary =  (recordBREResp.Appl_EMI_Net_Salary__c != null)?recordBREResp.Appl_EMI_Net_Salary__c: 0;              
                
                wrapObj.MaxEMIOtherCashSalary =(recordBREResp.Max_EMI_Other_than_Cash_Salary__c != null)?recordBREResp.Max_EMI_Other_than_Cash_Salary__c:0;
                
                wrapObj.ApplFOIRCashSalary=(recordBREResp.Applicable_FOIR_Cash_Salary__c != null)?recordBREResp.Applicable_FOIR_Cash_Salary__c:0;
                wrapObj.MaxEMICashSalary =(recordBREResp.Max_EMI_Cash_Salary__c != null)?recordBREResp.Max_EMI_Cash_Salary__c:0;
                applicantEliMap.put(recordBREResp.Applicant__c,wrapObj);
                
            }
            
            if(recordBREResp.EligibilityType__c =='Application' && recordBREResp.LoanAppl__c != null){
                
                
                resp.application.EliTenureMonths =Integer.valueof((recordBREResp.Eligible_tenure_in_Months__c != null)? recordBREResp.Eligible_tenure_in_Months__c:0);
                system.debug('resp.application.EliTenureMonths-->'+resp.application.EliTenureMonths);
                
                resp.application.RAACROI = (recordBREResp.RAACROI__c != null) ? recordBREResp.RAACROI__c:0;
                
               // resp.application.LoanEliOtherCashSalary =(recordBREResp.FinaLnEligOthr_Cash_Salary__c != null) ? recordBREResp.FinaLnEligOthr_Cash_Salary__c:0;
                
                //resp.application.FinLoanEliCashSalary = (recordBREResp.FinLoanEligibCashSalary__c != null)? recordBREResp.FinLoanEligibCashSalary__c:0;
                
                resp.application.FinLoanEliTotal = (recordBREResp.FinancialLoanEligibilityTotal__c != null)? recordBREResp.FinancialLoanEligibilityTotal__c:0;
                system.debug('resp.application.FinLoanEliTotal-->'+resp.application.FinLoanEliTotal);                
                //resp.application.MaxFinLoanElideviation =(recordBREResp.MaxFinLnEligblwithDevi__c != null)?  recordBREResp.MaxFinLnEligblwithDevi__c:0;
                
                resp.application.ApplLevelAssprogram = (recordBREResp.Application_level_Assessment_program__c != null)? recordBREResp.Application_level_Assessment_program__c:'';
                system.debug('recordBREResp123'+recordBREResp.MaxBreLnEliWoIns__c);
                resp.application.MaxBreLnEliWoIns =(recordBREResp.MaxBreLnEliWoIns__c != null) ?  recordBREResp.MaxBreLnEliWoIns__c:0;
                
                resp.application.MaxBreLnEliWIns =(recordBREResp.MaxBreLnEliWIns__c != null)?  recordBREResp.MaxBreLnEliWIns__c:0;
                resp.application.MaxBreLnEliWDeviation =(recordBREResp.MaxBreLnEliWDeviation__c != null)?  recordBREResp.MaxBreLnEliWDeviation__c:0;
                
                resp.application.EMI =(recordBREResp.EMI__c != null)?  recordBREResp.EMI__c:0;
                resp.application.ActuaFOIR =(recordBREResp.Actual_FOIR__c != null)?  (recordBREResp.Actual_FOIR__c).setscale(2):0;
                resp.application.ActualLTV =(recordBREResp.Actual_LTV__c != null)?  (recordBREResp.Actual_LTV__c).setscale(2):0;
                resp.application.CombLTVFOIR =(recordBREResp.Combined_LTV_And_FOIR_without_Insurance__c != null)? (recordBREResp.Combined_LTV_And_FOIR_without_Insurance__c).setscale(2):0;
                
                
                //applicantEliMap.put(recordBREResp.Applicant__c,wrapObj);
                
            }
            
            if(recordBREResp.EligibilityType__c =='Application'){
                //additional for consideration values table
                resp.application.ApprMonthIncOtherthanCashSalary =(recordBREResp.AppraisedMonIncome__c != null)?recordBREResp.AppraisedMonIncome__c:0;
                resp.application.MaxEMIOtherCashSalary =(recordBREResp.Max_EMI_Other_than_Cash_Salary__c != null)?recordBREResp.Max_EMI_Other_than_Cash_Salary__c:0;
                resp.application.MaxEMICashSalary =(recordBREResp.Max_EMI_Cash_Salary__c != null)?recordBREResp.Max_EMI_Cash_Salary__c:0;
                //applicantEliMap.put(recordBREResp.Applicant__c,wrapObj);
            }
            
            
            
        }
        system.debug('Manish2'+applicantEliMap.values().size());
        
        
        //This is for obligation table
        for(AggregateResult aggr : [SELECT Applicant__c, SUM(EMI__c)amt FROM BureauRespDtl__c WHERE Treatment__c = 'To continue - Obligate' AND LoanApplication__c=:recordId and Applicant__c != null GROUP BY Applicant__c ]){
            wrapObj = applicantEliMap.containsKey((id)aggr.get('Applicant__c'))? applicantEliMap.get((id)aggr.get('Applicant__c')): new ApplicantEligibility();
            //wrapObj = applicantEliMap.get((id)aggr.get('Applicant__c'));
            //wrapObj.obligationAMount = (decimal)aggr.get('amt');
            applicantEliMap.put((id)aggr.get('Applicant__c'),wrapObj);
        }
        system.debug('Manish1'+applicantEliMap.values().size());
        resp.eligibilityList = applicantEliMap.values();
        system.debug('all data of EligibilityScreenDataController>>>>>'+JSON.serialize(resp));
        return resp;
    }
    public responseWrapper2 propDetails(string recordid) {
        responseWrapper2 resp = new responseWrapper2();
        List<BRE__c> breRespList = new List<BRE__c>();
        breRespList=[SELECT Id,Applicant_Asset__c, LoanAppl__c, Applicant__c,LTVApplWDeviation__c,MaxcoltrlLnEliWDeviation__c,TotlLTVBsdLnEliWIns__c,AddLTVBsdEliIns__c,LTVBsdEliWOIns__c,LTVApplLnWtInsurance__c,LTVApplLnWOInsurance__c,EligibilityType__c FROM BRE__c where LoanAppl__c=:recordid];
        //wrapObj.TotlLTVBsdLnEliWIns = 0;
        resp.TotlLTVBsdLnEliWIns = 0;
        for (BRE__c recordBREResp : breRespList) {
            //For Property  Table
            
            if(recordBREResp.EligibilityType__c =='Property'){
                               
                //wrapObj.LTVApplLnWOInsurance =(recordBREResp.LTVApplLnWOInsurance__c != null)?  recordBREResp.LTVApplLnWOInsurance__c:0;
               // wrapObj.LTVApplLnWtInsurance =(recordBREResp.LTVApplLnWtInsurance__c != null)?  recordBREResp.LTVApplLnWtInsurance__c:0;
               // wrapObj.LTVBsdEliWOIns =(recordBREResp.LTVBsdEliWOIns__c != null)?  recordBREResp.LTVBsdEliWOIns__c:0;
               // wrapObj.AddLTVBsdEliIns =(recordBREResp.AddLTVBsdEliIns__c != null)?  recordBREResp.AddLTVBsdEliIns__c:0;
                //resp.TotlLTVBsdLnEliWIns += (recordBREResp.TotlLTVBsdLnEliWIns__c != null)?  recordBREResp.TotlLTVBsdLnEliWIns__c:0;
                resp.TotlLTVBsdLnEliWIns = (recordBREResp.TotlLTVBsdLnEliWIns__c != null)?  recordBREResp.TotlLTVBsdLnEliWIns__c:0;
                
                //wrapObj.LTVApplWDeviation =(recordBREResp.LTVApplWDeviation__c != null)?  recordBREResp.LTVApplWDeviation__c:0;
                //wrapObj.MaxcoltrlLnEliWDeviation =(recordBREResp.MaxcoltrlLnEliWDeviation__c != null)?  recordBREResp.MaxcoltrlLnEliWDeviation__c:0;
                
                
            }
        }
        //LAK-10323 - Start
        List<DedupeResponse__c> dedupeResp = [SELECT ID, Lan__c, Applicant__c,UCID__c FROM DedupeResponse__c WHERE RecordType.Name = 'DedupeMatchCr' AND IntnlDeduRelevance__c = 'Accurate Match found'  AND LoanAppln__c = :recordId];
        list<loanappl__c> sanctionLoanAmount = [Select SanLoanAmt__c,TotalLoanAmtInclInsurance__c from LoanAppl__c where id =:recordId];
        List<Id> appIdsMatchFound = new List<Id>();
        for(DedupeResponse__c dedupe : dedupeResp){
            appIdsMatchFound.add(dedupe.Applicant__c);
        }
        List<DedupeResponse__c> enpaResp = [SELECT Id, AUM__c, Lan__c,UCID__c, Loan_to_be_closed_internally__c  FROM DedupeResponse__c WHERE RecordType.Name = 'ENPA' AND LoanAppln__c = :recordId AND Applicant__c IN :appIdsMatchFound];

        
        Decimal sumFedfinaExposure = 0;
        Set<String> pastLans = new Set<String>();
        Set<String> ucidSet = new Set<String>();
        for(DedupeResponse__c enpa : enpaResp){
            if(enpa.Lan__c != null && enpa.UCID__c != null && enpa.AUM__C != null){
                if(!pastLans.contains(enpa.Lan__c) && !ucidSet.contains(enpa.UCID__c) && enpa.Loan_to_be_closed_internally__c == 'No'){
                    
                        sumFedfinaExposure += enpa.AUM__c;
                        pastLans.add(enpa.Lan__c);
                        ucidSet.add(enpa.UCID__c);
                    
                }
            }
        }

        resp.sumFedFinaExpLnAmt = sumFedfinaExposure;
        
        if (sanctionLoanAmount.size()>0 && sanctionLoanAmount[0].TotalLoanAmtInclInsurance__c !=null) {
            
            resp.TotalFedfinaLoanExposureIns = sanctionLoanAmount[0].TotalLoanAmtInclInsurance__c + resp.sumFedFinaExpLnAmt;
        }
        
        if (sanctionLoanAmount.size()>0 && sanctionLoanAmount[0].SanLoanAmt__c !=null) {
            resp.TotalfedfinaLoanExposure = sanctionLoanAmount[0].SanLoanAmt__c + resp.sumFedFinaExpLnAmt;
        }
        //LAK-10323 - End
        return resp;
  }
    
    public void getFIORandLTV(string recordid) {
        breObj=new BRE__c();
        List<BRE__c> breObjList = New List<BRE__c>();
        breObjList=[Select id,Actual_LTV__c,Actual_FOIR__c,Combined_LTV_And_FOIR_without_Insurance__c, Combined_LTV_And_FOIR_with_Insurance__c,Application_level_Assessment_program__c from BRE__c where isLatest__c= true AND EligibilityType__c='Application' AND LoanAppl__c=:recordid LIMIT 1];
        if(!breObjList.isEmpty()){
            breObj = breObjList[0];
        }
        system.debug('breObj----------------->'+breObj);
    }


    
    public List<HLRelatedDetailsWrapper> getHLRelatedDetailsData(String recordId){
        
        List<HLRelatedDetailsWrapper> listRecordWrapperHL = new List<HLRelatedDetailsWrapper>();
        
        List<ApplAsset__c>  applicantAssetsList = new List<ApplAsset__c>();
        List<LoanAppl__c>  loanApplicationList = new List<LoanAppl__c>();
        
       applicantAssetsList = [Select id,Agrem_Value__c, Regi_Cost__c, Stamp_Duty__c, Amenities__c, Total_Prop_Cost__c,
                              Down_payment_PartORegisteredAgreement__c, Balance_OCR_to_be_arranged_by_customer__c,
                              Total_estimate_as_per_architect_agreemen__c,Stage_of_Construction__c, 
                              StageOfConstrAsPerValuatioReport__c,Land_Valu__c,ValuationToBeTakenAheadForCalculation__c,
                              Built_up_area_Valu__c from ApplAsset__c where LoanAppln__c =:recordId]; //a08C4000007x0uSIAQ
        
        loanApplicationList = [Select id,Final_Loan_Disbursal_Amount__c,Product__c,SchemeId__c from LoanAppl__c where id=:recordId];
        
        
      //   List<SchMapping__c> schObjectList = new List<SchMapping__c>();
        
     //   if(loanApplicationList.size()>0){
            
     //       schObjectList=[select id,SchemeDesc__c,IsConstruction__c from SchMapping__c where id=:loanApplicationList[0].SchemeId__c];
     //      }
            
        
        
        decimal registeredAggrementValueSum =0;
        decimal downPaymentSum =0;
        decimal balanceAmountSum =0;
        decimal fedfinaLoanFundingSum =0;
        decimal balanceOCRSum =0;
        decimal mktValueOfPropertySum =0;
        
     if(applicantAssetsList.size()>0){
            
        for(ApplAsset__c appAsset: applicantAssetsList){
            
            
            
            registeredAggrementValueSum += appAsset.Agrem_Value__c == null ? 0 : appAsset.Agrem_Value__c;
            downPaymentSum += appAsset.Down_payment_PartORegisteredAgreement__c == null ? 0 : appAsset.Down_payment_PartORegisteredAgreement__c;
            balanceOCRSum  += appAsset.Balance_OCR_to_be_arranged_by_customer__c == null ? 0 : appAsset.Balance_OCR_to_be_arranged_by_customer__c;
            mktValueOfPropertySum += appAsset.ValuationToBeTakenAheadForCalculation__c == null ? 0 : appAsset.ValuationToBeTakenAheadForCalculation__c;
            
            
            
        }
            
        
        
            
            HLRelatedDetailsWrapper RecordWrapperHLData = new HLRelatedDetailsWrapper();
           // RecordWrapperHLData.isConstruction = false;
            RecordWrapperHLData.isHomeLoan = false;
            RecordWrapperHLData.registeredAggrementValue = registeredAggrementValueSum;
            RecordWrapperHLData.downPayment = downPaymentSum;
            RecordWrapperHLData.balanceAmount = registeredAggrementValueSum - downPaymentSum;
            RecordWrapperHLData.balanceOCR  = balanceOCRSum;
            RecordWrapperHLData.mktValueOfProperty = mktValueOfPropertySum;
            if(loanApplicationList.size()>0){
                 RecordWrapperHLData.fedfinaLoanFunding = loanApplicationList[0].Final_Loan_Disbursal_Amount__c == null ? 0 : loanApplicationList[0].Final_Loan_Disbursal_Amount__c;
            }
         
       //     if(schObjectList.size()>0)
       //     {
       //         if(schObjectList[0].IsConstruction__c=='Yes')
       //         {
        //           RecordWrapperHLData.isConstruction=true; 
        //        }
                
        //    }
         if(loanApplicationList.size()>0)
            {
                if(loanApplicationList[0].Product__c== 'Home Loan')
                {
                   RecordWrapperHLData.isHomeLoan=true; 
                }
                
            }
            
            listRecordWrapperHL.add(RecordWrapperHLData);
            
            system.debug('listRecordWrapperHL-->'+listRecordWrapperHL);
       
        }
         return listRecordWrapperHL;
           
        
    }
    
    
    
    public List<ConstructionRelatedDetailsWrapper> getConstructionRelatedDetailData(String recordId){
        
        List<ConstructionRelatedDetailsWrapper> listRecordWrapperConstruction = new List<ConstructionRelatedDetailsWrapper>();
        
        List<ApplAsset__c>  applicantAssetsList = new List<ApplAsset__c>();
        List<LoanAppl__c>  loanApplicationList = new List<LoanAppl__c>();
        List<CollateralVisitJn__c>  collateralVisitList = new List<CollateralVisitJn__c>();
        
       applicantAssetsList = [Select id,Agrem_Value__c, Regi_Cost__c, Stamp_Duty__c, Amenities__c, Total_Prop_Cost__c,
                              Down_payment_PartORegisteredAgreement__c, Balance_OCR_to_be_arranged_by_customer__c,
                              Total_estimate_as_per_architect_agreemen__c,Stage_of_Construction__c, 
                              StageOfConstrAsPerValuatioReport__c,Land_Valu__c,ValuationToBeTakenAheadForCalculation__c,
                              Built_up_area_Valu__c,PropAddrs__c,Appr_Cost_of_Const__c from ApplAsset__c where LoanAppln__c =:recordId];
        
        loanApplicationList = [Select id,Final_Loan_Disbursal_Amount__c,Product__c,SchemeId__c from LoanAppl__c where id=:recordId];
        
        
         List<SchMapping__c> schObjectList = new List<SchMapping__c>();
        
        if(loanApplicationList.size()>0){
            
            schObjectList=[select id,SchemeDesc__c,IsConstruction__c from SchMapping__c where id=:loanApplicationList[0].SchemeId__c];
           }
        
        Map<Id,String>MapOfLatestDateofConstruction = new Map<Id,String>();
        
         collateralVisitList = [select id, Resp__c,case__r.ApplAssetId__c from CollateralVisitJn__c 
                where Case__r.RecordType.Name = 'Collateral Visit' 
                AND PropQues__r.Question_Tiltle__c  ='Tentative Date of Completion' 
                and case__r.isCompleted__C = true and case__r.Loan_Application__c =:recordId 
                order by Case__r.CreatedDate Desc];
        
      if(collateralVisitList.size()>0){
            
       for(CollateralVisitJn__c cvjn: collateralVisitList){
           
          if(!MapOfLatestDateofConstruction.containsKey(cvjn.case__r.ApplAssetId__c)){
            MapOfLatestDateofConstruction.put(cvjn.case__r.ApplAssetId__c,cvjn.Resp__c);
              system.debug('MapOfLatestDateofConstruction-->'+MapOfLatestDateofConstruction);
          }
           
         }
            }
        
        
     if(applicantAssetsList.size()>0){
            
        for(ApplAsset__c appAsset: applicantAssetsList){
            
            system.debug('count');
            
             ConstructionRelatedDetailsWrapper RecordWrapperConstructionData = new ConstructionRelatedDetailsWrapper();
            RecordWrapperConstructionData.isConstruction = false;
            //RecordWrapperConstructionData.isHomeLoan = false; 
            RecordWrapperConstructionData.totalEstimateAsPerArtitech = /*appAsset.Total_estimate_as_per_architect_agreemen__c == null? 0:*/ appAsset.Appr_Cost_of_Const__c;
            RecordWrapperConstructionData.stageOfConstruction = /*appAsset.Stage_of_Construction__c == null? 0:*/appAsset.Stage_of_Construction__c;
            RecordWrapperConstructionData.landValue = /*appAsset.Land_Valu__c == null? 0:*/appAsset.Land_Valu__c;
            RecordWrapperConstructionData.constructionValue = /*appAsset.Built_up_area_Valu__c == null? 0:*/appAsset.Built_up_area_Valu__c;
            RecordWrapperConstructionData.totalValuation = /*appAsset.ValuationToBeTakenAheadForCalculation__c == null? 0:*/appAsset.ValuationToBeTakenAheadForCalculation__c;
            RecordWrapperConstructionData.EstimateDate   = MapOfLatestDateofConstruction.get(appAsset.Id);
            RecordWrapperConstructionData.propertyAddress = appAsset.PropAddrs__c;
            
             if(schObjectList.size()>0)
            {
                if(schObjectList[0].IsConstruction__c=='Yes')
                {
                   RecordWrapperConstructionData.isConstruction=true; 
                }
                
            }
       //  if(loanApplicationList.size()>0)
      //      {
       //         if(loanApplicationList[0].Product__c== 'Home Loan')
        //        {
         //          RecordWrapperConstructionData.isHomeLoan=true; 
           //     }
                
          //  }
            
            
            listRecordWrapperConstruction.add(RecordWrapperConstructionData);
           
            
            
            
        }
            
         system.debug('listRecordWrapperConstruction-->'+listRecordWrapperConstruction);
            system.debug('listRecordWrapperConstruction size()-->'+listRecordWrapperConstruction.size());
        
        }
         return listRecordWrapperConstruction;
           
        
    }

    public class FinancialRecordWrapper{
        @AuraEnabled
        public String Year{get;set;}
        @AuraEnabled
        public String Id{get;set;}
        @AuraEnabled
        public String borrowerName{get;set;}
        @AuraEnabled
        public decimal turnOver{get;set;}
        @AuraEnabled
        public decimal totalSales{get;set;}
        @AuraEnabled
        public decimal purchase{get;set;}
        @AuraEnabled
        public decimal turnOverGrowthRate{get;set;}
        @AuraEnabled
        public string turnOverGrowthRatePercent{get;set;}
        @AuraEnabled
        public decimal EBIDTA_PBDIT{get;set;}
        @AuraEnabled
        public decimal PBDT{get;set;}
        @AuraEnabled
        public decimal PBT{get;set;}
        @AuraEnabled
        public decimal PAT{get;set;}
        @AuraEnabled
        public decimal cashProfit{get;set;}
        @AuraEnabled
        public decimal grossProfitMargin{get;set;}
        @AuraEnabled
        public decimal netProfitMargin{get;set;}
        @AuraEnabled
        public decimal totalCurrentLiabilities{get;set;}
        @AuraEnabled
        public decimal totalCurrentAssets{get;set;}
        @AuraEnabled
        public decimal totalDebt{get;set;}
        @AuraEnabled
        public decimal adjustedNetworth{get;set;}
        @AuraEnabled
        public decimal debtors{get;set;}
        @AuraEnabled
        public decimal creditors{get;set;}
        @AuraEnabled
        public decimal stockValue{get;set;}
        @AuraEnabled
        public decimal debtorsCollectionPeriod{get;set;}
        @AuraEnabled
        public decimal creditorsPayementPeriod{get;set;}
        @AuraEnabled
        public decimal stockReplenishnentPeriod{get;set;} 
        @AuraEnabled
        public decimal inventryTorunOver{get;set;}
        @AuraEnabled
        public decimal networkingCapital{get;set;}
        @AuraEnabled
        public decimal currentRatio{get;set;}
        @AuraEnabled
        public decimal quickRatio{get;set;}
        @AuraEnabled
        public decimal interestCoverageRatio{get;set;}
        @AuraEnabled
        public decimal debtEquityRatio{get;set;}
        @AuraEnabled
        public decimal laverageRatio{get;set;}
        @AuraEnabled
        public decimal dscrPre{get;set;}
        @AuraEnabled
        public decimal dscrPost{get;set;}
        @AuraEnabled
        public decimal openingStock{get;set;}
        @AuraEnabled
        public decimal closingStock{get;set;}
        @AuraEnabled
        public decimal directExpense{get;set;}
    
    
    }

Public class ConsoilidateFinancialWrapper{
    Public FinancialRecordWrapper lastFinancialYear{get;set;}
    Public FinancialRecordWrapper currentFinancialYear{get;set;}
    Public FinancialRecordWrapper provisionalFinancialYear{get;set;}
    public Boolean currentFinancialRecord{get;set;}
    public Boolean previousFinancialRecord{get;set;}
    public Boolean provisionFinancialRecord{get;set;}
    Public String finacialYear1{get;set;}
    Public String finacialYear2{get;set;}
    Public String finacialYear3{get;set;}
    Public String Id{get;set;}
    Public String borrowerNameConsolidate{get;set;}
    public decimal DSCRPree{get;set;}
    public decimal DSCRPostt{get;set;}
    
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
public String gender {get;set;}
@AuraEnabled
public String maxDPD {get;set;}

}
    
    public class getBankingDetailsSummaryForCASAWrapper{
        
    @AuraEnabled
    public ApplBanking__c listApplicantBankingWrapper {get;set;}
    @AuraEnabled
    public ApplBankDetail__c listApplicantBankingDetailWrapper {get;set;}
    @AuraEnabled
    public Decimal totalValueSummationDebit {get;set;}
    @AuraEnabled
    public Decimal totalValueSummationCredit {get;set;}
    @AuraEnabled
    public Decimal totalCountDebit {get;set;}
    @AuraEnabled
    public Decimal totalCountCredit {get;set;}
    @AuraEnabled
    public Decimal totalInwardReturns {get;set;}
    @AuraEnabled
    public Decimal totalOutwardReturns {get;set;}
    @AuraEnabled
    public Decimal totalStopPayment {get;set;}
    @AuraEnabled
    public Decimal totalMinBalanceCharges {get;set;}
    @AuraEnabled
    public Decimal totalAverageBankBalance {get;set;}
    
    public Decimal totalLimit {get;set;}    
    
    public Decimal totalUtilisation{get;set;}
    
    @AuraEnabled
    public Decimal averageValueSummationDebit {get;set;}
    @AuraEnabled
    public Decimal averageValueSummationCredit {get;set;}
    @AuraEnabled
    public Decimal averageCountDebit {get;set;}
    @AuraEnabled
    public Decimal averageCountCredit {get;set;}
    @AuraEnabled
    public Decimal averageInwardReturns {get;set;}
    @AuraEnabled
    public Decimal averageOutwardReturns {get;set;}
    @AuraEnabled
    public Decimal averageStopPayment {get;set;}
    @AuraEnabled
    public Decimal averageMinBalanceCharges {get;set;}
    @AuraEnabled
    public Decimal averageAverageBankBalance {get;set;}
    
    public Decimal averageUtilisation{get;set;}
    
    public Decimal averageLimit{get;set;}
    
    public String minBalanceSumCheck{get;set;}    
}
    public class ApplicantEligibility{
        
        //These are BRE Eligibility data
        @auraEnabled public String ApplicantId{get;set;}
        @auraEnabled public string applicantRecord{get;set;}
        
        //@auraEnabled public decimal obligationAMount{get;set;}
        
        //  @auraEnabled public string breApplicantRecord{get;set;}
        // @auraEnabled public Applicant__c applicantRecord{get;set;}
        @auraEnabled public decimal cashFlowAssedIncome{get;set;}
        @auraEnabled public decimal businessIncome{get;set;}
        @auraEnabled public decimal grossSalaryBankCredit{get;set;}
        @auraEnabled public decimal netSalaryBankCredit{get;set;}
        
        //These are Applicant data
        @auraEnabled public string assesmentProgram{get;set;}
        @auraEnabled public decimal cashSalary{get;set;}
        @auraEnabled public decimal rentalBankCredit{get;set;}
       // @auraEnabled public  boolean showRentalWBankCredit{get;set;}
        @auraEnabled public decimal rentalWithoutBankCredit{get;set;}
        @auraEnabled public decimal PensionIncome{get;set;}
        @auraEnabled public decimal AgricultureIncome{get;set;}
        @auraEnabled public decimal OtherIncome{get;set;}
        
        //These Are BRE Respnse data
        
        @auraEnabled public decimal RAACROI{get;set;}
        @auraEnabled public decimal ApprMonthIncOtherthanCashSalary{get;set;}
        @auraEnabled public decimal ApplFOIR{get;set;}
        @auraEnabled public decimal ApplEMINetSalary {get;set;}
        @auraEnabled public decimal MaxEMIOtherCashSalary{get;set;}
        @auraEnabled public decimal ApplFOIRCashSalary{get;set;}
        @auraEnabled public decimal MaxEMICashSalary{get;set;}
        @auraEnabled public decimal EliTenureMonths{get;set;}
        @auraEnabled public decimal LoanEliOtherCashSalary{get;set;}
        @auraEnabled public decimal FinLoanEliCashSalary{get;set;}
        @auraEnabled public decimal FinLoanEliTotal{get;set;}
        @auraEnabled public decimal MaxFinLoanElideviation{get;set;}
        @auraEnabled public string ApplLevelAssprogram{get;set;}
        
        @auraEnabled public decimal MaxBreLnEliWoIns{get;set;}
        @auraEnabled public decimal MaxBreLnEliWIns{get;set;}
        @auraEnabled public decimal MaxBreLnEliWDeviation{get;set;}
        
        //Recommandation Table Fields data 
        @auraEnabled public decimal EMI{get;set;}
        @auraEnabled public decimal ActuaFOIR{get;set;}
        @auraEnabled public decimal ActualLTV{get;set;}
        @auraEnabled public decimal CombLTVFOIR{get;set;}
        
        //These Are BRE data for Type Property
        @auraEnabled public decimal LTVApplLnWOInsurance{get;set;}
        @auraEnabled public decimal LTVApplLnWtInsurance{get;set;}
        @auraEnabled public decimal LTVBsdEliWOIns{get;set;}
        @auraEnabled public decimal AddLTVBsdEliIns{get;set;}      
        @auraEnabled public decimal TotlLTVBsdLnEliWIns{get;set;}
        @auraEnabled public decimal LTVApplWDeviation{get;set;}
        @auraEnabled public decimal MaxcoltrlLnEliWDeviation{get;set;}
        //These Are SFDC data for Type Property
        @auraEnabled public string PropAddrs{get;set;} 
        @auraEnabled public string PropType{get;set;}
        @auraEnabled public string PropSubType{get;set;}
        @auraEnabled public string PropertyUsage{get;set;}
        @auraEnabled public decimal ApproxValue{get;set;}
        
        
    }
    
    Public class ResponseWrapper{
        @auraEnabled public List<ApplicantEligibility> eligibilityList{get;set;}
        //  @auraEnabled public List<ApplicantBREREsponse> BREResponse {get;set;}
        @auraEnabled public  boolean showAssesmentProgram{get;set;}
        @auraEnabled public  boolean showcashFlowAssessedIncome{get;set;}
        @auraEnabled public  boolean showBusinessIncome{get;set;}
        @auraEnabled public  boolean showGrossWithBankCredit{get;set;}
        @auraEnabled public  boolean showNetWithBankCredit{get;set;}
        
        @auraEnabled public  boolean showCashSalary{get;set;}
        @auraEnabled public  boolean showRentalWBankCredit{get;set;}
        @auraEnabled public  boolean showRentalWNoBankCredit{get;set;}
        @auraEnabled public  boolean showPensionIncome{get;set;}
        @auraEnabled public  boolean showAgricultureIncome{get;set;}
        @auraEnabled public  boolean showOtherIncome{get;set;}
        @auraEnabled public ApplicantEligibility application {get;set;}
        
        @auraEnabled public ApplicantEligibility property {get;set;}
        
        //@auraEnabled public BRE__c application {get;set;}
        //@auraEnabled public  boolean showRentalIncome{get;set;}
        
    }
    Public class ResponseWrapper2{
        @auraEnabled public decimal sumFedFinaExpLnAmt{get;set;}
        @auraEnabled public decimal TotlLTVBsdLnEliWIns{get;set;}
        @auraEnabled public decimal TotalfedfinaLoanExposure{get;set;}
        @auraEnabled public decimal TotalFedfinaLoanExposureIns{get;set;}//LAK-10323
    }

    public class HLRelatedDetailsWrapper{
        // For HL
        @AuraEnabled
        public decimal registeredAggrementValue{get;set;}
        @AuraEnabled
        public decimal downPayment{get;set;}
        @AuraEnabled
        public decimal balanceAmount{get;set;}
        @AuraEnabled
        public decimal fedfinaLoanFunding{get;set;}
        @AuraEnabled
        public decimal balanceOCR{get;set;}
        @AuraEnabled
        public decimal mktValueOfProperty{get;set;}
        @AuraEnabled
        public boolean isConstruction{get;set;}
        @AuraEnabled
        public boolean isHomeLoan{get;set;}
        
        
    }
    
    public class ConstructionRelatedDetailsWrapper{
        // For Construction
        
         @AuraEnabled
        public decimal totalEstimateAsPerArtitech{get;set;}
         @AuraEnabled
        public String EstimateDate{get;set;}
         @AuraEnabled
        public decimal stageOfConstruction{get;set;}
        @AuraEnabled
        public decimal landValue{get;set;}
        @AuraEnabled
        public decimal constructionValue{get;set;}
        @AuraEnabled
        public decimal totalValuation{get;set;}
        @AuraEnabled
        public String propertyAddress{get;set;}
         @AuraEnabled
        public boolean isConstruction{get;set;}
        @AuraEnabled
        public boolean isHomeLoan{get;set;}
    }
}