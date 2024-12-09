public without sharing class BLandPLCamReport {

    transient public String recordId{get;set;}
    transient public list<loanAppl__c> loanApplData{get;set;}
    transient public string formattedDate{get;set;}
    transient public List<BankBrchMstr__c> BranchCity{get;set;}
    transient public List<SchMapping__c> schemeName{get;set;}
    transient public String SecurityStatusCheck{get;set;}
    transient public List<DedupeResponse__c> pastLan{get;set;}
    transient public string pastLanStr{get;set;}
    transient public List<DedupeResponse__c> lstLinkedLoan{get;set;}
    transient public list<String> Linkedloans{get;set;}
    transient public String natureOfBusinessIndv{get;set;}
    transient public String loanToRelativeCheck{get;set;}
    transient public String ESGNegative{get;set;}
    transient public String MSMEcategorisation{get;set;}
    transient public String urcUACNumber{get;set;}
    transient public list<ApplicantEmployment__c> ApplicantEmploymentDetail{get;set;}
    transient public list<BureauRespDtl__c> lstObligationDetails{get;set;}
    transient public list<Bureau__c> lstObligationDetailsBureau{get;set;}
    transient public String hunterStatus{get;set;}
    transient public Case rcuCase{get;set;}
    transient public String channelCode{get;set;}
    transient public String discrimination{get;set;}
    transient public list<DedupeResponse__c> enpaData{get;set;}
    transient public list<ApplAddr__c> applicantAddress{get;set;}
    transient public String uw{get;set;}
    transient public String approver{get;set;}
    transient public String existingBLProduct{get;set;}
    transient public String existingOtherProduct{get;set;}
    transient public String sourcingName{get;set;}
    transient public Decimal fedfinaExposure{get;set;}
    transient public Decimal businessVantage{get;set;}
    transient public String lastcpa{get;set;}
    transient public Decimal posSum{get;set;}
    transient public list<LoanApplRelationship__c> boDetails{get;set;}



    transient public List<getBorrowerDetailsWrapper> borrowerDetailsWrapper{get;set;}
    transient public Map<Id,ConsoilidateFinancialWrapper> applicantToFinancialWrap1{get;set;}
    transient public  ConsoilidateFinancialWrapper returnWrapper{get;set;}
    transient public List<getBankingDetailsSummaryForCASAWrapper> BankingDetailsSummaryWrapper{get;set;}
    transient public List<getBankingDetailsSummaryForCASAWrapper> BankingDetailsSummaryWrapperODCC{get;set;}
    transient public List<getBankingDetailsSummaryForCASAWrapper> BankingDetailsSummaryWrapperCASAODCC{get;set;}
    transient public List<getBorrowerVerificationDetailWrapper> borrowWrapper{get;set;}
    transient public List<getBorrowerFinalCPVSummaryDetailsWrapper> finalCPVWrapper{get;set;}
    transient public list<Deviation__c> DeviationDetail{get;set;}
    transient public list<SanctionWrapper> sanctionList{get;set;}
    transient public list<DecisionWrapper> listDecisionSummary{get;set;}








    transient public BRE__c breObj{get;set;}



    public BLandPLCamReport(){

        recordId=ApexPages.currentPage().getParameters().get('recordId');
        
        if(recordId==null){
            recordId = 'a08C4000007x0uSIAQ'; //a08C4000007P6asIAC//a08C4000007x0uSIAQ
            System.debug('recordId '+recordId);
        }

        if(recordId!=null)
        {
            getloanApplicationFields(recordId);
            getFIORandLTV(recordId);
            getApplicantEmploymentDetail(recordId);

            borrowerDetailsWrapper=getBorrowerDetails(recordId);
            applicantToFinancialWrap1=getfinancialSatement(recordId);
            getObligationDetailsSummary(recordId);
            getObligationDetailsSummaryBureau(recordId);

            BankingDetailsSummaryWrapper=getBankingDetailsSummaryForCASA(recordId);
            System.debug('BankingDetailsSummaryWrapper'+BankingDetailsSummaryWrapper);
            BankingDetailsSummaryWrapperODCC = getBankingDetailsSummaryForODCC(recordId);
            BankingDetailsSummaryWrapperCASAODCC = getBankingDetailsSummaryForCASAODCC(recordId);
            borrowWrapper=getBorrowerVerificationDetail(recordId);
            finalCPVWrapper=getBorrowerFinalCPVSummaryDetails(recordId);
            getHunterAndRCUStatus(recordId);
            getDeviationDetail(recordId);
            getENPAData(recordId);
            getApplicantAddress(recordId);
            getSancionCondition(recordId);
            getDecisionSummary(recordId);
            getBODetails(recordId);

            
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

    public list<DedupeResponse__c> getENPAData(string recordId) {
        try{
            enpaData = [Select id, Lan__c, CustomerName__c,LoanAmount__c,Tenure__c, AUM__c,SystemDPD__c,DPD__c,Loan_to_be_closed_internally__c,WriteOffFlag__c,WriteoffDate__c,Settled__c,SettledDate__c from DedupeResponse__c where LoanAppln__r.id=:recordId AND RecordType.name = 'ENPA'];
            posSum = 0;
            if (enpaData.size()>0) {
                for(DedupeResponse__c record: enpaData){
                    if(record.Loan_to_be_closed_internally__c == 'No'){
                        posSum += record.AUM__c;
                    }
                }
                
                return enpaData;  
            }
            else{
                return null;
            }
            
        }
        catch (exception e) {
            system.debug(e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    public list<LoanApplRelationship__c> getBODetails(string recordId){
        try{
            boDetails = [Select Id,Loan_Applicant__c,BeneficialOwner__c,Relationship_Type__c,Shareholding__c,ToLabel(Loan_Applicant__r.Gender__c),Loan_Applicant__r.Age__c,Loan_Applicant__r.FName__c,Loan_Applicant__r.LName__c from LoanApplRelationship__c where Loan_Applicant__r.LoanAppln__r.id=:recordId];
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

    public list<ApplAddr__c> getApplicantAddress(string recordId){
        try{
            applicantAddress = [Select id, Applicant__r.FullName__c, ToLabel(Applicant__r.ApplType__c),AddrTyp__c,AddrLine2__c,AddrLine1__c,City__c,Locality__c,Country__c,FullAdrs__c,HouseNo__c,MailAddr__c,Landmark__c,ToLabel(OwnType__c),State__c,Pincode__c from ApplAddr__c where LoanAppl__r.id=:recordId];
            
            if (applicantAddress.size()>0) {
                
                return applicantAddress;  
            }
            else{
                return null;
            }
            
        }
        catch (exception e) {
            system.debug(e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    public list<loanAppl__c> getloanApplicationFields(string recordId) {
        try{
            loanApplData = [Select Id, Name, LoginAcceptDate__c, BrchName__c, BrchCode__c, Product__c, SchemeId__c, LoanPurpose__c, RMSMName__r.Name, ChannelCode__c, ChannelName__c,Loan_Tenure_Months__c,
                SanLoanAmt__c, InsAmt__c, TotalLoanAmtInclInsurance__c, EffectiveROI__c, EMIIcludingInsurance__c, Applicant__r.MSME__c, Applicant__r.ApplType__c, LeadSource__c, ReqLoanAmt__c, ReqTenInMonths__c, Applicant__r.Investment_in_Plant_and_Machinery__c,PrsnldetailsofPromotrs__c,IncomerelateComm__c,AddationalComm__c from LoanAppl__c where Id =:recordId];

            SchMapping__c schObj = new SchMapping__c();
            List<SchMapping__c> schObjectList = new List<SchMapping__c>();
            schObjectList=[select id,SchemeDesc__c from SchMapping__c where id=:loanApplData[0].SchemeId__c];
            if(schObjectList.size()>0){
                schObj = schObjectList[0];
            }


            if(!loanApplData.isEmpty() && loanApplData[0].LoginAcceptDate__c != null) {
                datetime mydatetime=loanApplData[0].LoginAcceptDate__c;
                formattedDate=mydatetime.format('dd-MMM-yyyy');
            }
            
            if(!loanApplData.isEmpty()){
                for (loanAppl__c MSME: loanApplData) {
                    if (MSME.Applicant__r.MSME__c!=null && MSME.Applicant__r.ApplType__c == 'P') {
                        MSMEcategorisation = MSME.Applicant__r.MSME__c;
                    }
                }
            }

            if(!loanApplData.isEmpty()){
                if(loanApplData[0].LeadSource__c != null && (loanApplData[0].LeadSource__c == 'DSA' || loanApplData[0].LeadSource__c == 'Connector')){
                    channelCode = loanApplData[0].ChannelCode__c != null ? loanApplData[0].ChannelCode__c: null;
                    sourcingName = loanApplData[0].ChannelName__c != null ? loanApplData[0].ChannelName__c: null;
                    
                }
                else{
                    channelCode = loanApplData[0].LeadSource__c != null ? loanApplData[0].LeadSource__c: null;
                    sourcingName = loanApplData[0].RMSMName__r.Name != null ? loanApplData[0].RMSMName__r.Name: null;
                }
            }


            if (loanApplData.size()>0){
                String productTypeValue= loanApplData[0].Product__c;           
                BranchCity = [Select id, LocationMaster__r.City__c, LocationMaster__r.State__c from BankBrchMstr__c  where BrchCode__c =:loanApplData[0].BrchCode__c];
                existingBLProduct = 'N';
                existingOtherProduct='N';
                List<DedupeResponse__c> dedupeList = [Select Id, LoanStatus__c,IntnlDeduRelevance__c, LoanType__c from DedupeResponse__c where LoanAppln__r.Id=:recordId AND IntnlDeduRelevance__c='Accurate Match found' AND RecordType.Name='Dedupe'];
                if(!dedupeList.isEmpty()){
                for(DedupeResponse__c dedupeRecord: dedupeList){
                    if(dedupeRecord.LoanType__c == 'BL' && dedupeRecord.LoanStatus__c=='ACTIVE'){
                        existingBLProduct = 'Y';
                        break;
                    }
                    else{
                        existingBLProduct = 'N';
                    }
                }
                for(DedupeResponse__c dedupeRecord1: dedupeList){
                    if(dedupeRecord1.LoanType__c != 'BL' && dedupeRecord1.LoanStatus__c=='ACTIVE'){
                        existingOtherProduct = 'Y';
                        break;
                    }
                    else{
                        existingOtherProduct = 'N';
                    }
                }
                }
                List<DedupeResponse__c> enpaList = [Select Id, AUM__c, Loan_to_be_closed_internally__c from DedupeResponse__c where LoanAppln__r.Id=:recordId AND Loan_to_be_closed_internally__c='No' AND RecordType.Name='ENPA'];


                // Check if enpaList is not empty and AUM__c is not null
                if (!enpaList.isEmpty() && enpaList[0].AUM__c != null) {
                    // Check if loanApplData is not empty and TotalLoanAmtInclInsurance__c is not null
                    if (!loanApplData.isEmpty() && loanApplData[0].TotalLoanAmtInclInsurance__c != null) {
                        fedfinaExposure = enpaList[0].AUM__c + loanApplData[0].TotalLoanAmtInclInsurance__c;
                    } else {
                        fedfinaExposure = enpaList[0].AUM__c; // Only set AUM__c if loan amount is null
                    }
                } else if (!loanApplData.isEmpty() && loanApplData[0].TotalLoanAmtInclInsurance__c != null) {
                    fedfinaExposure = loanApplData[0].TotalLoanAmtInclInsurance__c; // Set only loan amount if AUM__c is null
                } 
            }

            pastLan = [Select id, lan__c, Loantobelinkedwithproposedloan__c, SecuritisationStatus__c,IntnlDeduRelevance__c from DedupeResponse__c where LoanAppln__r.id=:recordId]; 

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

            List<ApplRegltry__c> ApplRegulatory = [Select DealngIndstry__c, IsBorowrOrRelFFDir__c, FFDirRelIntrstAsPart__c, FFDirRelIntrstAsSH__c, CharDiscrmtn__c from ApplRegltry__c where LoanAppln__r.Id=:recordId];
            
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
            for (ApplRegltry__c Appl: ApplRegulatory) {
                if (Appl.CharDiscrmtn__c == 'Yes') {
                    discrimination = 'Yes';
                    Break;
                }
                else {
                    discrimination = 'No';
                }
            }


            for (DedupeResponse__c Dedupe: pastLan) {
                if (Dedupe.IntnlDeduRelevance__c == 'Accurate Match found' && Dedupe.SecuritisationStatus__c == 'Y' && Dedupe.SecuritisationStatus__c!=Null) {
                    SecurityStatusCheck = 'Y';
                    Break;
                }
                else{
                    SecurityStatusCheck = 'N';
                }
            }




            if(!loanApplData.isEmpty()){
                schemeName = [Select SchemeDesc__c from SchMapping__c where id=: loanApplData[0].SchemeId__c];
                
            }

            List<ApplicantEmployment__c> NatureOfBusiness = new List<ApplicantEmployment__c>();
            if(!loanApplData.isEmpty()){
                NatureOfBusiness = [Select id, NatureOfBusinessIndividual__c,NatureOfBusinessCorporate__c,LoanApplicant__r.Constitution__c
                                                                 from ApplicantEmployment__c where LoanApplicant__r.ApplType__c = 'P' and LoanApplicant__r.LoanAppln__r.id=:loanApplData[0].Id];
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



            system.debug('loanApplData '+loanApplData);
            return loanApplData;

        }
        catch (exception e) {
            system.debug(e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    //Obligation Details
    public List<BureauRespDtl__c> getObligationDetailsSummary(string recordid){
        try {
            
            lstObligationDetails = [select Id,BounceInLast12Months__c,Applicant__r.FullName__c,Treatment__c,FinancierName__c,
                                    NatureOfLoan__c,LoanAmount__c,Tenure__c,NoEMIPaid__c,EMI__c,
                                    CurrentOs__c,EMISource__c,ConsiderObligation__c,
                                    MaxDPDLst12month__c,Remarks__c,DisbursalDate__c from BureauRespDtl__c 
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




    public void getFIORandLTV(string recordid) {
        breObj=new BRE__c();
        List<BRE__c> breObjList = New List<BRE__c>();
        breObjList=[Select id,Actual_LTV__c,Actual_FOIR__c,Combined_LTV_And_FOIR_without_Insurance__c, Combined_LTV_And_FOIR_with_Insurance__c,Application_level_Assessment_program__c from BRE__c where isLatest__c= true AND EligibilityType__c='Application' AND LoanAppl__c=:recordid LIMIT 1];
        if(!breObjList.isEmpty()){
            breObj = breObjList[0];
        }
        
    }

    //Financial Borrower Employment and PD Details
    transient public list<EmploymentWrapper> EmploymentList{get;set;}
    public list<ApplicantEmployment__c> getApplicantEmploymentDetail(String recordId) {
        try {
            ApplicantEmploymentDetail = [Select LoanApplicant__r.CustProfile__c,LoanApplicant__r.Constitution__c,LoanApplicant__c,LoanApplicant__r.ApplType__c,TotalWorkExperience_Years__c,LoanApplicant__r.InceptionYears__c,CurrentBusinessVintage_Years__c,Is_URC_UAC_available__c,Select_applicability_for_URC_UAC__c,UdyamAssistCertificate__c,UdyamRegistrationNumber__c,MainRBIIndustry__c, SubIndustry__r.Name, toLabel(TypeOfOrganisation__c),
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
                    if(appObj.LoanApplicant__r.ApplType__c == 'P' && appObj.LoanApplicant__r.CustProfile__c=='SALARIED'){
                        businessVantage = appObj.TotalWorkExperience_Years__c!=null?appObj.TotalWorkExperience_Years__c:null;
                    }
                    if(appObj.LoanApplicant__r.ApplType__c == 'P' && (appObj.LoanApplicant__r.CustProfile__c=='SELF EMPLOYED PROFESSIONAL' || appObj.LoanApplicant__r.CustProfile__c=='SELF EMPLOYED NON PROFESSIONAL')&& appObj.LoanApplicant__r.Constitution__c=='INDIVIDUAL'){
                        businessVantage = appObj.CurrentBusinessVintage_Years__c!=null?appObj.CurrentBusinessVintage_Years__c:null;
                    }
                    if(appObj.LoanApplicant__r.ApplType__c == 'P' && appObj.LoanApplicant__r.Constitution__c!='INDIVIDUAL'){
                        businessVantage = appObj.LoanApplicant__r.InceptionYears__c!=null?appObj.LoanApplicant__r.InceptionYears__c:null;
                    } 
                }
                
                List<PD__C> pdRecords = [Select id,PDStatus__c,PDRmrks__c,Appl__c,PdTyp__c,Appl__r.CustProfile__c,CmpltDt__c,AsgnTo__r.name from PD__c where Appl__c IN:applicantId and CmpltDt__c != NULL ORDER BY CmpltDt__c DESC];
                // for(PD__c pdObj:[Select id,PDStatus__c,PDRmrks__c,Appl__c,PdTyp__c,Appl__r.CustProfile__c,CmpltDt__c,AsgnTo__r.name from PD__c where Appl__c IN:applicantId and CmpltDt__c != NULL ORDER BY CmpltDt__c DESC])  // CmpltDt__c!=null 
                for(PD__c pdObj:pdRecords)
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
                //system.debug('pdList----------->'+[Select id,PDStatus__c,PDRmrks__c,Appl__c from PD__c where Appl__c IN:applicantId and CmpltDt__c != NULL ORDER BY CmpltDt__c DESC]);
                system.debug('applPD------------------>'+applPD);
                for(ApplicantEmployment__c appObj:ApplicantEmploymentDetail)
                {
                    EmploymentWrapper empObj=new EmploymentWrapper();
                    empObj.borrowerName=appObj.LoanApplicant__r.FullName__c;
                    empObj.typeOfEmployment=appObj.TypeOfOrganisation__c;
                    empObj.industryOfMainEstablishment=appObj.MainRBIIndustry__c;
                    empObj.subIndustryOfMainEstablishment=appObj.SubIndustry__r.Name;
                    
                    empObj.pdStatus=applPD.size()>0?(applPD.get(appObj.LoanApplicant__c)!=null?applPD.get(appObj.LoanApplicant__c).PDStatus__c:''):'';
                    empObj.pdType=applPD.size()>0?(applPD.get(appObj.LoanApplicant__c)!=null?applPD.get(appObj.LoanApplicant__c).PdTyp__c:''):'';
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
        catch (exception e) {
            system.debug('Line number'+e.getLinenumber());
            throw new AuraHandledException(e.getMessage());
        }
    }


    // Borrower details
    public List<getBorrowerDetailsWrapper> getBorrowerDetails(String recordId){
        try{
            List<getBorrowerDetailsWrapper> borrowerwrapperData = new List<getBorrowerDetailsWrapper>();

            set<Id> setOfApplicantId = new set<Id>();
            Map<Id,String> mapOfDPD = new map<Id,String>();
            List<Applicant__c>  listOfApplicantDetails = [Select id, FullName__c, TabName__c, ApplType__c, CustProfile__c, Constitution__c, Gender__c, Relationship__c, Age__c,InceptionYears__c, UCID__c, DOB__c,DOI__c,Type_of_Borrower__c,LoanAppln__r.Loan_Tenure_Months__c,(SELECT Id from ApplAssetJn__r), (select Id, Prop_Owners__c from Applicant_Assets__r), (Select Id,Score__c from Bureau_Responses__r order by Score__c,createddate desc ) from Applicant__c where LoanAppln__c=:recordId and ApplType__c in ('P','C','G') ORDER BY CreatedDate ASC];
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
                getWrapperData.borrowerType = 'APPLICANT';
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

            if(appln.Constitution__c != null && appln.Constitution__c =='INDIVIDUAL'){
                getWrapperData.dob = appln.DOB__c!= null?DateTime.newInstance(appln.DOB__c.year(), appln.DOB__c.month(), appln.DOB__c.day()).format('dd-MMM-yyyy'):'';
                getWrapperData.age = appln.Age__c!= null?appln.Age__c:null;
            }
            else if(appln.Constitution__c != null && appln.Constitution__c !='INDIVIDUAL'){
                getWrapperData.dob = appln.DOI__c!= null?DateTime.newInstance(appln.DOI__c.year(), appln.DOI__c.month(), appln.DOI__c.day()).format('dd-MMM-yyyy'):'';
                getWrapperData.age = appln.InceptionYears__c!= null?appln.InceptionYears__c:null;
            }

            

            if(appln.Type_of_Borrower__c != null && appln.Type_of_Borrower__c =='Financial'){
                getWrapperData.financialBorrowerWrapper = 'Yes';
            }
                    
            else if(appln.Type_of_Borrower__c != null && appln.Type_of_Borrower__c !='Financial'){
                getWrapperData.financialBorrowerWrapper = 'No';
            }
                    
                    if(appln.Age__c != null && appln.LoanAppln__r.Loan_Tenure_Months__c !=null){
                        
                        system.debug('Age-->'+appln.Age__c);
                        system.debug('Loan Tenure Months-->'+appln.LoanAppln__r.Loan_Tenure_Months__c);
                        
                        Decimal ageMaturity =0;
                        Integer ageAtMaturity;
                        ageMaturity = (appln.Age__c + appln.LoanAppln__r.Loan_Tenure_Months__c)/12;
                        ageAtMaturity = ageMaturity.intValue();
                        getWrapperData.ageAtLonaMaturityWrapper = ageAtMaturity;
                        system.debug('getWrapperData.ageAtLonaMaturityWrapper-->'+getWrapperData.ageAtLonaMaturityWrapper);
                    }
                    
                    List<ApplAsset__c> applAsstList = appln.Applicant_Assets__r;
                    List<ApplAssetJn__c> applAsstJnList = appln.ApplAssetJn__r;
                    List<Bureau__c> bureauList = appln.Bureau_Responses__r;
                    system.debug('applAsstList-->'+applAsstList);
                    system.debug('bureauList-->'+bureauList);
                    

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

// Banking table CASA
public static List<getBankingDetailsSummaryForCASAWrapper> getBankingDetailsSummaryForCASA(string recordId){
    try {
        
        List<getBankingDetailsSummaryForCASAWrapper> listBankingDetailsSummaryWrapper = new List<getBankingDetailsSummaryForCASAWrapper>(); 
        
        List<ApplBanking__c> listBankingDetailsSummaryCASA = [Select Id, 
                                                              Summary_Type__c,Appl__r.FullName__c,Appl__c ,
                                                              (Select id,Month__c,Year__c,ValueSummationDebit__c,ValueSummationCredit__c,CountofDebit__c,
                                                               CountofCredit__c,InwardReturnsCount__c,OutwardReturnsCount__c,StopPaymentCount__c,MinBalanceCharges__c,
                                                               AverageBankBalance__c,Average_Daily_Bank_Balance__c from Applicant_Banking_Detail__r) 
                                                              from ApplBanking__c where Type__c ='Banking Summary'
                                                              and Appl__c IN (Select id from Applicant__c where LoanAppln__c =:recordId) 
                                                              and Summary_Type__c ='Combined Banking (CASA)'];
        
        decimal TotalVSD=0.0;
        decimal TotalVSC=0.0;
        decimal TotalCD=0.0;
        decimal TotalCC=0.0;
        decimal TotalIRC=0.0;
        decimal TotalORC=0.0;
        decimal TotalSPC=0.0;
        decimal TotalABB=0.0;
        decimal TotalADB=0.0;
        String TotalsumcheckMiniChan='N';
        
        decimal AverageVSD=0.0;
        decimal AverageVSC=0.0;
        decimal AverageCD=0.0;
        decimal AverageCC=0.0;
        decimal AverageIRC=0.0;
        decimal AverageORC=0.0;
        decimal AverageSPC=0.0;
        decimal AverageABB=0.0;
        decimal AverageADB=0.0;
        
        
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
                    TotalADB += appBankDetails.Average_Daily_Bank_Balance__c == null ? 0 : appBankDetails.Average_Daily_Bank_Balance__c; 
                    
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
                wrapperData.totalAverageDailyBankBalance = TotalADB;

                
                if (listAppBank.size()!=0) {
                    
                    AverageVSD = (TotalVSD/listAppBank.size()).setScale(2);
                    AverageVSC = (TotalVSC/listAppBank.size()).setScale(2);
                    AverageCD = (TotalCD/listAppBank.size()).setScale(2);
                    AverageCC = (TotalCC/listAppBank.size()).setScale(2);
                    AverageIRC = (TotalIRC/listAppBank.size()).setScale(2);
                    AverageORC = (TotalORC/listAppBank.size()).setScale(2);
                    AverageSPC = (TotalSPC/listAppBank.size()).setScale(2);
                    AverageABB = (TotalABB/listAppBank.size()).setScale(2);
                    AverageADB = (TotalADB/listAppBank.size()).setScale(2);
                    

                    wrapperData.averageValueSummationDebit = AverageVSD;
                    wrapperData.averageValueSummationCredit = AverageVSC;
                    wrapperData.averageCountDebit = AverageCD;
                    wrapperData.averageCountCredit = AverageCC;
                    wrapperData.averageInwardReturns = AverageIRC;
                    wrapperData.averageOutwardReturns = AverageORC;
                    wrapperData.averageStopPayment = AverageSPC;
                    wrapperData.averageAverageBankBalance = AverageABB;
                    wrapperData.averageAverageDailyBankBalance = AverageADB;
                    
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


public List<getBankingDetailsSummaryForCASAWrapper> getBankingDetailsSummaryForCASAODCC(String recordId){
    try {
        
        List<getBankingDetailsSummaryForCASAWrapper> listBankingDetailsSummaryWrapper = new List<getBankingDetailsSummaryForCASAWrapper>(); 
        
        List<ApplBanking__c> listBankingDetailsSummaryCASA = [Select Id, 
                                                              Summary_Type__c,Appl__r.FullName__c,Appl__c ,
                                                              (Select id,Month__c,Year__c,ValueSummationDebit__c,ValueSummationCredit__c,CountofDebit__c,
                                                               CountofCredit__c,InwardReturnsCount__c,OutwardReturnsCount__c,StopPaymentCount__c,MinBalanceCharges__c,
                                                               AverageBankBalance__c, MonthlyLimit__c, Utilization__c from Applicant_Banking_Detail__r) 
                                                              from ApplBanking__c where Type__c ='Banking Summary'
                                                              and Appl__c IN (Select id from Applicant__c where LoanAppln__c =:recordId) 
                                                              ];
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


public List<getBorrowerVerificationDetailWrapper> getBorrowerVerificationDetail(String recordId) {
    try {
        
        List<getBorrowerVerificationDetailWrapper> WrapperBorrowerList = new List<getBorrowerVerificationDetailWrapper>();
        
        list<Applicant__c> lstApplicantDetails = [Select Id,LoanAppln__c,name,TabName__c,FullName__c, PAN__c, DLNo__c, VotIdEpicNo__c, PassNo__c,(Select id,Applicant__c,IntnlDeduRelevance__c,LoanAppln__c,IsLatest__c,RecordType.name  from Dedupe_Responses__r where IsLatest__c =true),(select Id, WatchoutInvestor__c,ScrRes__c,Result_Relevance__c,RecordTypeId,RecordType.name,IsLatest__c from API_Verifications__r where IsLatest__c=true),(Select id,kycDoc__c,ValidationStatus__c,OCRStatus__c,Applicant__c   from Applicant_KYC__r  where kycDoc__c  IN  ('Passport','PAN','Voter Id','Driving License')),(Select id, GSTIN__c,Applicant__c,Main_GSTIN__c,GSTIN_Status__c  from Applicant_GST__r  where Main_GSTIN__c = True) from Applicant__c where LoanAppln__c =:recordId and ApplType__c in ('P','C','G') order by createdDate ASC ];
        
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

// Sanction Condition
public void getSancionCondition(String recordId) {
    try {

        sanctionList = new  List<SanctionWrapper>();
        SanctionWrapper sanctionWrap;

        List<Sanction_Conditions__c> sanctionConditionsList = [SELECT Name, Remarks__c, Condition__c FROM Sanction_Conditions__c WHERE Loan_Application__c = :recordId];
        
        // for(Sanction_Conditions__c conditions: [SELECT Name, Remarks__c, Condition__c FROM Sanction_Conditions__c WHERE Loan_Application__c = :recordId]){
            for(Sanction_Conditions__c conditions: sanctionConditionsList){
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

public void getDecisionSummary(String recordId) {
    try {
       listDecisionSummary = new  List<DecisionWrapper>();
        DecisionWrapper DecisionWrap;
        List<UWDecision__c> decisionList = [select Id,name,LoanAppl__c,LoanAppl__r.BDApplicantCoapp__c,LoanAppl__r.IncomerelateComm__c,LoanAppl__r.AddationalComm__c,LoanAppl__r.PrsnldetailsofPromotrs__c,User__c,User__r.name,Decision__c,DecisionRmrks__c,
        DecisionDt__c,createddate,IncomerelateComm__c,AddationalComm__c,PrsnldetailsofPromotrs__c,BDApplicantCoapp__c from UWDecision__c where LoanAppl__c=:recordId AND Decision_Type__c = 'UW Decision'];
        
        for(UWDecision__c Decision: decisionList){
        DecisionWrap = new DecisionWrapper();
        DecisionWrap.UserName= Decision.User__r.name!=null?Decision.User__r.name:'';
        DecisionWrap.Decision= Decision.Decision__c!=null?Decision.Decision__c:'';                                                                                                                   
        DecisionWrap.ApproverComment= Decision.DecisionRmrks__c!=null?Decision.DecisionRmrks__c:'';                                                                                                                  
        DecisionWrap.DecisionDate= Decision.DecisionDt__c!=null?Decision.DecisionDt__c:null; 
        //DecisionWrap.formattedDecisionDate = String.valueof(Decision.DecisionDt__c.format('dd-MMM-yyyy'));
       DecisionWrap.formattedDecisionDate=(Decision.DecisionDt__c != null) ? DateTime.newInstance(Decision.DecisionDt__c.year(), Decision.DecisionDt__c.month(), Decision.DecisionDt__c.day()).format('dd-MMM-yyyy'):'';
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

        List<LoanTAT__c> loantatList = [
            SELECT Id, Stage__c, LoanApplication__c, Sub_Stage__c, UserRole__c, OwnerName__c, EntryTime__c, ExitTime__c, TotalTimeDiff__c, Status__c
            FROM LoanTAT__c
            WHERE LoanApplication__c = :recordId AND Stage__c = 'DDE' AND UserRole__c = 'CPA'
            ORDER BY ExitTime__c DESC
            LIMIT 1
        ];
        if(loantatList.size()>0){
            lastcpa = loantatList[0].OwnerName__c!=null ? loantatList[0].OwnerName__c:'';
        }
                                                                                                                        
    }
    Catch (exception e) {
        throw new AuraHandledException(e.getMessage());
    }
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


Public class SanctionWrapper{
    @AuraEnabled
    public String conditionName { get; set; }
    @AuraEnabled
    public String remarks { get; set; }
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
    @AuraEnabled
    public Decimal totalAverageDailyBankBalance {get;set;}
    
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
    @AuraEnabled
    public Decimal averageAverageDailyBankBalance {get;set;}
    
    public Decimal averageUtilisation{get;set;}
    
    public Decimal averageLimit{get;set;}
    
    public String minBalanceSumCheck{get;set;}    
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
        @AuraEnabled
        public String dob {get;set;}
        @AuraEnabled
        public Decimal age {get;set;}
        
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
        public String pdType { get; set; }
    
        @AuraEnabled
        public String pdRemarksSummary { get; set; }
    
        @AuraEnabled
        public String pdAuthorityName { get; set; }
    
        @AuraEnabled
        public String pdDate { get; set; }
        
    }



}