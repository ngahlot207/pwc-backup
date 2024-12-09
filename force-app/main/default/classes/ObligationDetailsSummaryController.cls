public without sharing class ObligationDetailsSummaryController {
    
    @AuraEnabled(cacheable=true)
    public static LoanAppl__c getLoanAppData(String recordId){
        
        LoanAppl__c lstOfLoanAppDetails = [select Id,SanLoanAmt__c,InsAmt__c,TotalLoanAmtInclInsurance__c,Loan_Tenure_Months__c,EffectiveROI__c, Applicant__c,EMIIcludingInsurance__c from LoanAppl__c where Id=:recordId];
        if(lstOfLoanAppDetails!=null){
            return lstOfLoanAppDetails;
        }
        else{
            return null;
        }
    }
    
    
    @AuraEnabled(cacheable=true)
    public static List<Applicant_Financial_Summary__c> getFinancialSummaries(String recordId) {
        List<Applicant_Financial_Summary__c> listFinancialSummary = [select Applicant_Financial__r.Loan_Applicant__r.TabName__c,ID,Liabilities__c,EBITDA__c,Financial_Year__c,Profit_Before_Depreciation_and_Tax_PBDT__c,
                                                                     PAT__c,Profit_Before_Tax__c,Assets__c,Debtors__c,Sundry_creditors__c,Stock__c,Date_of_Filing_ITR__c from Applicant_Financial_Summary__c WHERE Applicant_Financial__r.Loan_Applicant__r.LoanAppln__c=:recordId];
        if(listFinancialSummary.size()>0){
            return listFinancialSummary;
        }
        else{
            return null;
        }
        
    }
    
    @AuraEnabled(cacheable=true)
    public static List<BureauRespDtl__c> getObligationDetailsSummary(String recordId){
        try {
            //LAK-7316 - Changes under BIL UW Summary
            List<BureauRespDtl__c> lstObligationDetails = [select Id,BounceInLast12Months__c ,Applicant__r.FullName__c,Treatment__c,FinancierName__c,NatureOfLoan__c,LoanAmount__c,Tenure__c,NoEMIPaid__c,EMI__c,CurrentOs__c,EMISource__c,ConsiderObligation__c,MaxDPDLst12month__c,Remarks__c,DisbursalDate__c from BureauRespDtl__c where LoanApplication__c=:recordId and Treatment__c='To continue - Obligate'];  //used other component loan application id is a08C4000005yfVKIAY
            if(lstObligationDetails.size()>0){
                return lstObligationDetails;
            }
            else{
                return null;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Bureau__c> getObligationDetailsSummaryBureau(String recordId){
        try {
            
            List<Bureau__c> lstObligationDetailsBureau = [select Id,TotalEnquirieslast30day__c ,Applicant__r.FullName__c,Totalliveloan__c,Totalloanexposure__c,Totalunsecuredloan__c,Totalcreditcardoutstanding__c,Totaloanoverdue__c,Totalcreditcardoverdue__c,MaxcurrentDPDLiveFacilities__c,MaxDPDlast12months__c,TotalEnquiries__c,TotalMortgageEnqlst30days__c,TotalMortgageloan__c from Bureau__c where LoanApp__c=:recordId AND IsLatest__c=true order by Applicant__r.CreatedDate Asc];  //used other component loan application id is a08C4000005yfVKIAY
            if(lstObligationDetailsBureau.size()>0){
                return lstObligationDetailsBureau;
            }
            else{
                return null;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    @AuraEnabled(cacheable=true)
    public static List<getBankingDetailsSummaryForCASAWrapper> getBankingDetailsSummaryForCASA(String recordId){
        try {
            
            List<getBankingDetailsSummaryForCASAWrapper> listBankingDetailsSummaryWrapper = new List<getBankingDetailsSummaryForCASAWrapper>(); 
            
            List<ApplBanking__c> listBankingDetailsSummaryCASA = [Select Id, 
                                                                  Summary_Type__c,Appl__r.TabName__c,Appl__r.FullName__c,Appl__c ,
                                                                  (Select id,Month__c,Year__c,ValueSummationDebit__c,ValueSummationCredit__c,CountofDebit__c,
                                                                   CountofCredit__c,InwardReturnsCount__c,OutwardReturnsCount__c,StopPaymentCount__c,MinBalanceCharges__c,
                                                                   AverageBankBalance__c from Applicant_Banking_Detail__r) 
                                                                  from ApplBanking__c where Type__c ='Banking Summary'
                                                                  and Appl__c IN (Select id from Applicant__c where LoanAppln__c =:recordId)    //a08C4000007YPb3IAG
                                                                  and Summary_Type__c ='Combined Banking (CASA)'];
       
            decimal TotalVSD=0.0;
            decimal TotalVSC=0.0;
            decimal TotalCD=0.0;
            decimal TotalCC=0.0;
            decimal TotalIRC=0.0;
            decimal TotalORC=0.0;
            decimal TotalSPC=0.0;
            decimal TotalABB=0.0;
            String TotalsumcheckMiniChan ='N';
            
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
                 
                    List<ApplBankDetail__c> listAppBank = lstAppBank.Applicant_Banking_Detail__r;
                    System.debug('listAppBankDetails-->'+listAppBank);
                    System.debug('listAppBankDetails-->'+listAppBank.size());                 
                    
                    for(ApplBankDetail__c appBankDetails : listAppBank){
                        
                        wrapperData.listApplicantBankingDetailWrapper = appBankDetails;
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
                    
                    wrapperData.totalValueSummationDebit = TotalVSD;
                    wrapperData.totalValueSummationCredit = TotalVSC;
                    wrapperData.totalCountDebit = TotalCD;
                    wrapperData.totalCountCredit = TotalCC;
                    wrapperData.totalInwardReturns = TotalIRC;
                    wrapperData.totalOutwardReturns = TotalORC;
                    wrapperData.totalStopPayment = TotalSPC;
                    wrapperData.totalAverageBankBalance = TotalABB;
                    wrapperData.totalMinBalanceCharges = TotalsumcheckMiniChan;
                    
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
                    
                    listBankingDetailsSummaryWrapper.add(wrapperData)  ;                 
                    
                }
                return listBankingDetailsSummaryWrapper;
            }
            else{
                return null;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    @AuraEnabled(cacheable=true)
    public static List<getBankingDetailsSummaryForCASAWrapper> getBankingDetailsSummaryForODCC(String recordId){
        try {
            
            List<getBankingDetailsSummaryForCASAWrapper> listBankingDetailsSummaryWrapper = new List<getBankingDetailsSummaryForCASAWrapper>(); 
            
            List<ApplBanking__c> listBankingDetailsSummaryCASA = [Select Id, 
                                                                  Summary_Type__c,Appl__r.FullName__c,Appl__c ,
                                                                  (Select id,Month__c,Year__c,ValueSummationDebit__c,ValueSummationCredit__c,CountofDebit__c,
                                                                   CountofCredit__c,InwardReturnsCount__c,OutwardReturnsCount__c,StopPaymentCount__c,MinBalanceCharges__c,
                                                                   AverageBankBalance__c, MonthlyLimit__c, Utilization__c from Applicant_Banking_Detail__r) 
                                                                  from ApplBanking__c where Type__c ='Banking Summary'
                                                                  and Appl__c IN (Select id from Applicant__c where LoanAppln__c =:recordId)   //a08C4000007YPb3IAG
                                                                  and Summary_Type__c ='Combined Banking (OD/CC)'];       
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
                    
                    List<ApplBankDetail__c> listAppBank = lstAppBank.Applicant_Banking_Detail__r;
                    
                    for(ApplBankDetail__c appBankDetails : listAppBank){
                        
                        wrapperData.listApplicantBankingDetailWrapper = appBankDetails;
                        
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
                    
                    listBankingDetailsSummaryWrapper.add(wrapperData);                 
                    
                }
                
                return listBankingDetailsSummaryWrapper;
            }
            else{
                return null;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    

    @AuraEnabled(cacheable=true)
    public static List<ApplAsset__c> getCollateralVisitDetails(String recordId){
        try {
            
            List<ApplAsset__c> listCollateralVisitDetails = [SELECT Id,PropAddrs__c,Prop_Owners__c,NatureofProp__c,PropType__c,PropSubType__c,Property_Usage__c,Approx_Age_of_Prop__c,Resi_Age__c,Land_Area__c,Prop_Bui_up_ar__c,Property_Negative_Area__c,Comments_on_Collateral__c,No_of_Tenants__c,Is_the_property_Multi_Tenanted__c,Negative_Caution_Area__c FROM ApplAsset__c where LoanAppln__c =:recordId];//'a08C4000007cVgHIAU'//where Case__r.Loan_Application__c='a08C40000063xjHIAQ'  //used other component loan application id is a08C4000005yfVKIAY
            if(listCollateralVisitDetails.size()>0){
                return listCollateralVisitDetails;
            }
            else{
                return null;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<getCollateralVerificationDetailsWrapper> getCollateralVerificationDetails(String recordId){
       
            List<getCollateralVerificationDetailsWrapper> WrapperList = new List<getCollateralVerificationDetailsWrapper>();
            List<ApplAsset__c> listCollateralVerificationDetails = [SELECT Id,Valuation_as_per_policy_norms__c,ValuationToBeTakenAheadForCalculation__c,DistFrmNearBrch__c,DistFrmSourceBrch__c,Negative_Caution_Area__c,PropAddrs__c,(select Id,DateofVisit__c,Date_of_Report__c,ExpiryDate__c,Total_Valuation_Land_Valuation_B__c,Status,RecordTypeId,recordtype.name,IsCompleted__c,ReportResult__c,Property_Visit_Final_Status__c,Assigned_To__r.name from cases__r ) FROM ApplAsset__c where LoanAppln__c =:recordId];//'a08C4000007cVgHIAU'//recordType.name ='Technical' and//where Case__r.Loan_Application__c='a08C40000063xjHIAQ'  //used other component loan application id is a08C4000005yfVKIAY
            
            if(listCollateralVerificationDetails.size()>0){
               
                Map<Id,Case> cvCase = new Map<Id,Case>();
                Map<Id,Case> legalCase = new Map<Id,Case>();
                Map<Id,Case> tsrCase = new Map<Id,Case>();

                For(ApplAsset__c appAssetList: listCollateralVerificationDetails){
                    
                    getCollateralVerificationDetailsWrapper CollaterVerDetailsWrapp = new getCollateralVerificationDetailsWrapper();
                    
                    CollaterVerDetailsWrapp.lstOfApplicantAssetsWrapp = appAssetList;
                    list<case> casesRecord = appAssetList.cases__r;
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
                }
                return WrapperList;
            }
            else{
                return null;
            }
        
    }
    
    @AuraEnabled(cacheable=true)
    public static List<getBorrowerVerificationDetailWrapper> getBorrowerVerificationDetail(String recordId) {
        try {
            
            List<getBorrowerVerificationDetailWrapper> WrapperBorrowerList = new List<getBorrowerVerificationDetailWrapper>();
            
            list<Applicant__c> lstApplicantDetails = [Select Id,LoanAppln__c,name,TabName__c,FullName__c, PAN__c, DLNo__c, VotIdEpicNo__c, PassNo__c,CAVerStatus__c,DoctorApiVerStatus__c,ArchVerStatus__c,(Select id,Applicant__c,IntnlDeduRelevance__c,LoanAppln__c,IsLatest__c,RecordType.name  from Dedupe_Responses__r where IsLatest__c =true),(select Id, WatchoutInvestor__c,ScrRes__c,Result_Relevance__c,RecordTypeId,RecordType.name,IsLatest__c from API_Verifications__r where IsLatest__c=true),(Select id,kycDoc__c,ValidationStatus__c,OCRStatus__c,Applicant__c   from Applicant_KYC__r  where kycDoc__c  IN  ('Passport','PAN','Voter Id','Driving License')),(Select id, GSTIN__c,Applicant__c,Main_GSTIN__c,GSTIN_Status__c  from Applicant_GST__r  where Main_GSTIN__c = True) from Applicant__c where LoanAppln__c =:recordId and ApplType__c in ('P','C','G' ) order by createdDate Asc ]; //(select Id, GSTIN_Status__c,Main_GSTIN__c from Applicant_Employments__r),

            if (lstApplicantDetails.size()>0) {
                
                for(Applicant__c appList: lstApplicantDetails){
                    getBorrowerVerificationDetailWrapper borrowerVerDetailsWrapp = new getBorrowerVerificationDetailWrapper();
                    
                    borrowerVerDetailsWrapp.lstOfApplicantDetailsWrapp = appList;
                    borrowerVerDetailsWrapp.ca = appList.CAVerStatus__c != null ? appList.CAVerStatus__c:'';
                    borrowerVerDetailsWrapp.doctor = appList.DoctorApiVerStatus__c != null ? appList.DoctorApiVerStatus__c:'';
                    borrowerVerDetailsWrapp.architect = appList.ArchVerStatus__c != null ? appList.ArchVerStatus__c:'';
                    
                    List<DedupeResponse__c> dedupResp = appList.Dedupe_Responses__r;
                    List<APIVer__c> apiVerList = appList.API_Verifications__r;
                    List<ApplKyc__c> applKycList = appList.Applicant_KYC__r;
                    List<ApplGST__c> applGSTList = appList.Applicant_GST__r;
                    
                   for(ApplKyc__c kyc:applKycList){
                       
                   
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

                    for(DedupeResponse__c dedup : dedupResp){
                        if(dedup.RecordType.name == 'Dedupe' && dedup.IntnlDeduRelevance__c == 'Accurate Match found'){
                            borrowerVerDetailsWrapp.deDupe = dedup.IntnlDeduRelevance__c;
                        }
                        else{
                            borrowerVerDetailsWrapp.deDupe = 'Inaccurate match found';
                        }
                        
                    }
               
                    for(APIVer__c apiVer : apiVerList){
                        
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
    
    @AuraEnabled(cacheable=true)
    public static List<getBorrowerFinalCPVSummaryDetailsWrapper> getBorrowerFinalCPVSummaryDetails(String recordId){
        try {
            
            List<getBorrowerFinalCPVSummaryDetailsWrapper> borrowerFinalCPVWrapperList = new List<getBorrowerFinalCPVSummaryDetailsWrapper>();
            
            List<Applicant__c> listBorrowerFinalCPVSummaryDetails = [Select Id, LoanAppln__c, name,FullName__c, TabName__c, (select Id,WaiveCPV__c , RecordTypeId, RecordType.name, Address_Type__c, ReportResult__c from cases__r where RecordType.name = 'CPVFI') from Applicant__c where ApplType__c IN ('P','G','C') AND LoanAppln__c =:recordId order by createdDate Asc];
            if(listBorrowerFinalCPVSummaryDetails.size()>0){
                
                for(Applicant__c applcnList: listBorrowerFinalCPVSummaryDetails){
                    
                    getBorrowerFinalCPVSummaryDetailsWrapper borrowerFinalCPVWrapper = new getBorrowerFinalCPVSummaryDetailsWrapper();
                    
                    borrowerFinalCPVWrapper.lstOfCaseApplicantDetailsWrapp = applcnList;
                    
                    List<case> caseChildList = applcnList.cases__r;
                    
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
                         if(c.Address_Type__c != null && c.Address_Type__c == 'Residence Address' && String.isBlank(borrowerFinalCPVWrapper.residenceCPV)){  //&& c.ReportResult__c != null && c.ReportResult__c =='Positive'
                                                              
                                    borrowerFinalCPVWrapper.residenceCPV = 'Waived';
                                  
                            }
                            
                            if(c.Address_Type__c != null && c.Address_Type__c == 'Residence Cum office' && String.isBlank(borrowerFinalCPVWrapper.resiCumOfficeCPV)){
                               
                                    borrowerFinalCPVWrapper.resiCumOfficeCPV = 'Waived';
                                
                            }
                            if(c.Address_Type__c != null && c.Address_Type__c == 'Permanent Address' && String.isBlank(borrowerFinalCPVWrapper.permanentAddressCPV)){
                                
                                    borrowerFinalCPVWrapper.permanentAddressCPV = 'Waived';
                                
                            }
                            if(c.Address_Type__c != null && (c.Address_Type__c == 'Office Address' || c.Address_Type__c == 'Principal place for business') && String.isBlank(borrowerFinalCPVWrapper.officeCPV)){
                               
                                    borrowerFinalCPVWrapper.officeCPV ='Waived';
                              
                            }
                        	if(c.Address_Type__c != null && c.Address_Type__c == 'Other Address' && String.isBlank(borrowerFinalCPVWrapper.otherAddressCPV)){
                                
                                
                                    borrowerFinalCPVWrapper.otherAddressCPV = 'Waived';
                                
                                
                            }
                    }
                        
                    }
                    borrowerFinalCPVWrapperList.add(borrowerFinalCPVWrapper);
                    
                }
                
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
    @AuraEnabled(cacheable=true)
    public static list<Deviation__c> getDeviationDetail(String recordId) {
        try {
            list<Deviation__c> listDeviationDetail = [Select Id, Deviation__c, Req_Apprv_Level__c, Devia_Desrp__c, Mitigation__c,Apprv_By__c,Apprv_By__r.Name, Appr_Remarks__c, Approved_Date__c, Format_App_Date__c
                                                      from Deviation__c where LoanAppln__r.Id =:recordId AND (Dev_Type__c ='Manual' OR (Dev_Type__c ='System' AND BRE__r.IsLatest__c=TRUE))];
            if (listDeviationDetail.size()>0) {
                return listDeviationDetail;
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
    @AuraEnabled(cacheable=true)
    public static list<Sanction_Conditions__c> getSancionCondition(String recordId) {
        try {
            //LAK-7316 - Changes under BIL UW Summary
            list<Sanction_Conditions__c>  listSanctionConditionDetail = [SELECT Id,Name, Sanction_Con_Master__c, Remarks__c, Condition__c 
                                                                         FROM Sanction_Conditions__c WHERE Loan_Application__c =:recordId];
            
                                                                         if (listSanctionConditionDetail.size()>0) {
                return listSanctionConditionDetail;
            }
            else {
                return null;
            }
        }
        Catch (exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    // Decision Summary
    @AuraEnabled(cacheable=true)
    public static list<UWDecision__c> getDecisionSummary(String recordId) {
        try {
            //
            list<UWDecision__c>  listDecisionSummary = [select Id,name,LoanAppl__c,LoanAppl__r.BDApplicantCoapp__c,LoanAppl__r.IncomerelateComm__c,LoanAppl__r.AddationalComm__c,LoanAppl__r.PrsnldetailsofPromotrs__c,User__r.name,Decision__c,PrsnldetailsofPromotrs__c,BDApplicantCoapp__c,IncomerelateComm__c,AddationalComm__c,DecisionRmrks__c,DecisionDt__c from UWDecision__c where Decision_Type__c = 'UW Decision' AND LoanAppl__c=:recordId];
            if (listDecisionSummary.size()>0) {
                return listDecisionSummary;
            }
            else {
                return null;
            }
        }
        Catch (exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getUwAndApprover(String recordId){
        try {
            List<UWDecision__c> firstForwardDecision = [
                SELECT Id, Name, User__c, User__r.Name, Decision__c, DecisionRmrks__c, DecisionDt__c, CreatedDate
                FROM UWDecision__c
                WHERE LoanAppl__c = :recordId 
                AND Decision__c = 'Forward'
                ORDER BY CreatedDate ASC
                LIMIT 1
            ];

            String uwUser;
            String approver;
            List<String> res = new List<String>();
            
            if(firstForwardDecision.size()>0){
                uwUser = firstForwardDecision[0].User__r.Name!=null ? firstForwardDecision[0].User__r.Name:'';
            }
            List<UWDecision__c> approvedDecisions = [SELECT Id, User__r.Name, Decision__c, DecisionDt__c
                                                     FROM UWDecision__c
                                                     WHERE LoanAppl__c = :recordId AND Decision__c = 'Approved'
                                                     ORDER BY DecisionDt__c DESC LIMIT 1];
    
            if (approvedDecisions.size() > 0) {
                UWDecision__c approvedDecision = approvedDecisions[0];
                
                approver = approvedDecision.User__r.Name!=null? approvedDecision.User__r.Name:'';
                
            }
            res.add(uwUser);
            res.add(approver);
            return res;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static getLoanDetailsSummaryWrapper getLoanDetailsSummary( String recordId) {
        try {
            
            List<SchMapping__c> schemeNameList;
            List<ApplIMD__c> imdStatus;
            String empNameBBH='';
            String schemeNamee='';
            String City='';
            String state='';
            String securitisationCheck;
            Decimal TotalLoanAmount;
            list<String> LinkedLoans = new list<String>();
            String maxValueSubProperty='';
            String applPropertyType='';
            String natureOfBusinessIndv='';
            String ESGNegative ='';
            String loanToRelativeCheck='';
            String MSMEcategorisation='';
            String nameRMSM='';
            String ChannelRName='';
            String strLinkedLoans = null;
            String imdStatuss='';
            String loginDate='';
            String BTFinancier='';
            String BDApplicantCoapp='';
                String IncomerelateComm='';
                String AddationalComm='';
                String PrsnldetailsofPromotrs='';
            String PropertyUsage='';
            Decimal FOIRLoanAmountInsurance=0;
            Decimal LTVInsurance=0;
                Decimal CombinedLTV=0;
            Decimal FOIRPerIncome=0;
            Decimal TotalFedfinaExposure=0;
            String urcUacNumber='';
            //LAK-7316 - Changes under BIL UW Summary
            Decimal businessVintage=0;  
            String existingBLProduct='';
            String existingOtherProduct='';

            
            list<loanAppl__c>  listLoanDetailsSummary = [select id,IncomerelateComm__c,AddationalComm__c,PrsnldetailsofPromotrs__c,BDApplicantCoapp__c, name, Status__c, BrchName__c, BrchCode__c, Product__c, RMSMName__r.Name, ChanelNme__r.Name,ChannelCode__c, SanLoanAmt__c,
                                                         Loan_Tenure_Months__c, LoginAcceptDate__c, City__c, SchemeId__c, ChannelName__c, BTFinancierId__c,TotalLoanAmtInclInsurance__c,
                                                         Insurance_Amount__c, EffectiveROI__c, Final_MSME__c, LoanPurpose__c, stage__c, Applicant__r.MSME__c,Applicant__r.ApplType__c, AssesIncomeAppl__c
                                                         from LoanAppl__c
                                                         where id =:recordId];
            
            if (listLoanDetailsSummary.size()>0) {
                
                BRE__c breObj=new BRE__c();
        	List<BRE__c> breObjList = New List<BRE__c>();
        	breObjList=[Select id,Actual_LTV__c,Actual_FOIR__c,Combined_LTV_And_FOIR_with_Insurance__c from BRE__c where isLatest__c= true AND EligibilityType__c='Application' AND LoanAppl__c=:recordid LIMIT 1];
        	if(!breObjList.isEmpty()){
            breObj = breObjList[0];
                 FOIRLoanAmountInsurance=breObj.Actual_FOIR__c;
             LTVInsurance=breObj.Actual_LTV__c;
                 CombinedLTV=breObj.Combined_LTV_And_FOIR_with_Insurance__c;
             FOIRPerIncome=breObj.Actual_FOIR__c;
        	}
        system.debug('breObj----------------->'+breObj);
                //LAK-7316 - Changes under BIL UW Summary
                list<ApplicantEmployment__c> ApplicantEmploymentDetail=new list<ApplicantEmployment__c>();
                ApplicantEmploymentDetail = [Select LoanApplicant__r.Constitution__c, LoanApplicant__r.CustProfile__c,LoanApplicant__c,LoanApplicant__r.ApplType__c,Is_URC_UAC_available__c,Select_applicability_for_URC_UAC__c,UdyamAssistCertificate__c,UdyamRegistrationNumber__c, CurrentBusinessVintage_Years__c
                                                                                  from ApplicantEmployment__c where LoanApplicant__r.LoanAppln__r.id =:recordId];
            Set<id> applicantId=new Set<id>();
            urcUacNumber = 'NA';
            if (ApplicantEmploymentDetail.size()>0) {
                 system.debug('ApplicantEmploymentDetail----------------->'+ApplicantEmploymentDetail);
                for(ApplicantEmployment__c appObj:ApplicantEmploymentDetail)
                {
                    applicantId.add(appObj.LoanApplicant__c);
                    if(appObj.LoanApplicant__r.ApplType__c == 'P' && appObj.Is_URC_UAC_available__c == 'YES' && (appObj.LoanApplicant__r.CustProfile__c!='SALARIED')){
                        
                        if(appObj.Select_applicability_for_URC_UAC__c =='UDYAM ASSIST CERTIFICATE (UAC)'){
                            urcUacNumber = appObj.UdyamAssistCertificate__c;
                        }else{
                            urcUacNumber = appObj.UdyamRegistrationNumber__c;
                        }
                //LAK-7316 - Changes under BIL UW Summary
                    }
                    if(appObj.LoanApplicant__r.ApplType__c == 'P' && (appObj.LoanApplicant__r.CustProfile__c!='SALARIED')){
                        
                        businessVintage = appObj.CurrentBusinessVintage_Years__c;
                        system.debug('businessVintage 727'+businessVintage);
                       
                    }
                }}

                
                datetime mydatetime=listLoanDetailsSummary[0].LoginAcceptDate__c;
                 TotalFedfinaExposure = listLoanDetailsSummary[0].TotalLoanAmtInclInsurance__c;
                String productTypeValue = listLoanDetailsSummary[0].Product__c;
                 BDApplicantCoapp=listLoanDetailsSummary[0].BDApplicantCoapp__c;
                 IncomerelateComm=listLoanDetailsSummary[0].IncomerelateComm__c;
                 AddationalComm=listLoanDetailsSummary[0].AddationalComm__c;
                 PrsnldetailsofPromotrs=listLoanDetailsSummary[0].PrsnldetailsofPromotrs__c;
                if(mydatetime != null){
                    loginDate = mydatetime.format('dd-MM-yyyy');
                }
                
                if(listLoanDetailsSummary[0].ChanelNme__r.Name !=null){
                    ChannelRName = listLoanDetailsSummary[0].ChanelNme__r.Name;
                }
                
                For (loanAppl__c MSME: listLoanDetailsSummary) {
                    
                    if (MSME.Applicant__r.MSME__c!=null && MSME.Applicant__r.ApplType__c != null && MSME.Applicant__r.ApplType__c == 'P') {
                       
                        MSMEcategorisation = MSME.Applicant__r.MSME__c;
                    }
                }
                
                if(listLoanDetailsSummary[0].RMSMName__r.Name !=null){
                    nameRMSM = listLoanDetailsSummary[0].RMSMName__r.Name;
                }
                
                List<BankBrchMstr__c> BranchCityStateData = [Select id, LocationMaster__r.City__c, LocationMaster__r.State__c from BankBrchMstr__c where BrchCode__c =:listLoanDetailsSummary[0].BrchCode__c];
                
                if(BranchCityStateData.size()>0){
                    City = BranchCityStateData[0].LocationMaster__r.City__c;
                    state = BranchCityStateData[0].LocationMaster__r.State__c;
                }
                
                schemeNameList = [Select SchemeDesc__c from SchMapping__c where id=:listLoanDetailsSummary[0].SchemeId__c]; //== null ? schemeName : [Select name from SchMapping__c limit 1];
                
                if(schemeNameList.size()>0){
                    schemeNamee = schemeNameList[0].SchemeDesc__c;
                }
               
                imdStatus = [SELECT Id,IMDStatus__c FROM ApplIMD__c where LoanAppln__c =:listLoanDetailsSummary[0].id Order by createdDate Desc limit 1]; //IMDReceived__c//== null ? schemeName : [Select name from SchMapping__c limit 1];
                
                if(imdStatus.size()>0 && imdStatus[0].IMDStatus__c !=null){

                    imdStatuss = imdStatus[0].IMDStatus__c;
                    
                }
                else{
                    imdStatuss = 'Pending';
                }
                //LAK-7316 - Changes under BIL UW Summary
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
                
                List<TeamHierarchy__c>  TeamHirerEmpName = [Select id, Employee__r.Name, EmpRole__c, EmpBrch__r.BrchCode__c, Product_Type__c 
                                                            from TeamHierarchy__c where EmpRole__c = 'BBH' AND EmpBrch__r.BrchCode__c =:listLoanDetailsSummary[0].BrchCode__c AND Product_Type__c Includes (:productTypeValue) AND IsActive__c =true];
                
                if(TeamHirerEmpName.size()>0){
                    empNameBBH = TeamHirerEmpName[0].Employee__r.Name;
                }
                
                
                List<DedupeResponse__c> lstSecuritisationcheck = [Select id, lan__c, SecuritisationStatus__c,Loantobelinkedwithproposedloan__c from DedupeResponse__c where LoanAppln__r.id=:listLoanDetailsSummary[0].id]; 
                
                List<DedupeResponse__c> lstLinkedLoan = [Select id, lan__c, SecuritisationStatus__c,Loantobelinkedwithproposedloan__c from DedupeResponse__c where LoanAppln__r.id=:listLoanDetailsSummary[0].id AND RecordType.name = 'ENPA' and IsLatest__c = True]; 

                
                if(lstSecuritisationcheck.size()>0){
                    for (DedupeResponse__c Dedupe: lstSecuritisationcheck) {
                        if (Dedupe.SecuritisationStatus__c == 'Y' && Dedupe.SecuritisationStatus__c!=Null && Dedupe.SecuritisationStatus__c!='') {
                            securitisationCheck = 'Y';
                            Break;
                        }
                        else{
                            securitisationCheck = 'N';
                        }
                    }
                }
                else {
                    {
                        securitisationCheck = 'N';
                    }
                }
                
                if (listLoanDetailsSummary[0].Insurance_Amount__c!= Null && listLoanDetailsSummary[0].SanLoanAmt__c != null) {
                    TotalLoanAmount = listLoanDetailsSummary[0].Insurance_Amount__c + listLoanDetailsSummary[0].SanLoanAmt__c;
                }
                else{
                    TotalLoanAmount = 0.0;
                }
                
                
                if (lstLinkedLoan.size()>0){
                    For (DedupeResponse__c Lan: lstLinkedLoan){
                        System.debug('Lan.lan__c '+Lan.lan__c);
                        if (Lan.lan__c!=Null && Lan.Loantobelinkedwithproposedloan__c == 'Yes') {  
                            Linkedloans.add(String.valueOf(lan.lan__c));
                            
                            
                        }
                    }
                    for(Integer i=0;i<Linkedloans.size();i++)
                    {
                        If(strLinkedLoans == null)
                        {
                            strLinkedLoans = Linkedloans[i];
                        }else{
                            strLinkedLoans = strLinkedLoans  +','+Linkedloans[i];
                        }
                        
                    }
                    
                }
                
                List<ApplAsset__c> propType = [Select id, PropType__c,Property_Usage__c, PropSubType__c, Total_Valua__c,ValuationToBeTakenAheadForCalculation__c from ApplAsset__c where Appl__r.LoanAppln__r.Id =:listLoanDetailsSummary[0].Id and ValuationToBeTakenAheadForCalculation__c!=null order by ValuationToBeTakenAheadForCalculation__c desc];
                System.debug(' propType'+ propType);
                if (propType.size()>0){
                    maxValueSubProperty = propType[0].PropSubType__c != null ? propType[0].PropSubType__c: '';
                    applPropertyType = propType[0].PropType__c!= null ? propType[0].PropType__c: '';
                     PropertyUsage = propType[0].Property_Usage__c!= null ? propType[0].Property_Usage__c: '';
                }
                
                
                List<ApplicantEmployment__c> NatureOfBusiness = [Select id, NatureOfBusinessIndividual__c,NatureOfBusinessCorporate__c,LoanApplicant__r.Constitution__c
                                                                 from ApplicantEmployment__c where LoanApplicant__r.ApplType__c = 'P' and LoanApplicant__r.LoanAppln__r.id=:listLoanDetailsSummary[0].Id];
                
                
                
                Schema.DescribeFieldResult fieldResult1 = ApplicantEmployment__c.NatureOfBusinessIndividual__c.getDescribe(); 
                Schema.DescribeFieldResult fieldResult2 = ApplicantEmployment__c.NatureOfBusinessCorporate__c.getDescribe(); 
                
                List<Schema.PicklistEntry> natureOfBusinessIndividual = fieldResult1.getPicklistValues();
                
                List<Schema.PicklistEntry> natureOfBusinessCorporate = fieldResult2.getPicklistValues();
                
                Map<String,String> natureOfBusinessIndividualMap = new map<String,String>();
                for( Schema.PicklistEntry v : natureOfBusinessIndividual) {
                    
                    natureOfBusinessIndividualMap.put(v.getValue(),v.getLabel());
                   
                    
                }
                
                Map<String,String> natureOfBusinessCorporateMap = new map<String,String>();
                for( Schema.PicklistEntry v : natureOfBusinessCorporate) {
                    
                    natureOfBusinessCorporateMap.put(v.getValue(),v.getLabel());
                }
                
                if(NatureOfBusiness.size()>0){
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
                
                
                List<ApplRegltry__c> ApplRegulatory = [Select DealngIndstry__c, IsBorowrOrRelFFDir__c, FFDirRelIntrstAsPart__c, FFDirRelIntrstAsSH__c from ApplRegltry__c where LoanAppln__r.Id=:listLoanDetailsSummary[0].Id];
                
                if(ApplRegulatory.size()>0){
                    
                    
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
                }
                
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
                }
                else{
                    BTFinancier='NA';
                }
                //LAK-7316 - Changes under BIL UW Summary
               return new getLoanDetailsSummaryWrapper(city,state,schemeNamee,empNameBBH,securitisationCheck,TotalLoanAmount,strLinkedLoans,maxValueSubProperty,applPropertyType,natureOfBusinessIndv,loanToRelativeCheck,ESGNegative,MSMEcategorisation,nameRMSM,ChannelRName,imdStatuss,loginDate,BTFinancier,BDApplicantCoapp,IncomerelateComm,AddationalComm,PrsnldetailsofPromotrs,PropertyUsage,FOIRLoanAmountInsurance,LTVInsurance,CombinedLTV,FOIRPerIncome,TotalFedfinaExposure,urcUacNumber,businessVintage,existingBLProduct,existingOtherProduct);
            }
            else {
                return null;
                
            }
        }
        Catch (exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    
    
    @AuraEnabled(cacheable=true)
    public static List<getBoroowerDetailsWrapper> getBorrowerDetails(String recordId){
        try{
            List<getBoroowerDetailsWrapper> borrowerwrapperData = new List<getBoroowerDetailsWrapper>();
            set<Id> setOfApplicantId = new set<Id>();
            Map<Id,String> mapOfDPD = new map<Id,String>();
            //LAK-7316 - Changes under BIL UW Summary
            List<Applicant__c>  listOfApplicantDetails = [Select Id, FullName__c, TabName__c, ApplType__c, CustProfile__c, Constitution__c, Gender__c, DOB__c , Relationship__c, Age__c, UCID__c, Type_of_Borrower__c,LoanAppln__r.Loan_Tenure_Months__c,LoanAppln__r.Product__c, (select Id,Appl__c,ApplAsset__c from ApplAssetJn__r), (Select Id,Score__c from Bureau_Responses__r order by Score__c,createddate desc ) from Applicant__c where LoanAppln__c=:recordId and ApplType__c in ('P','C','G') ORDER BY CreatedDate ASC]; //
            if(listOfApplicantDetails.size()>0){
                
                
                for(Applicant__c applns: listOfApplicantDetails){

                    setOfApplicantId.add(applns.Id);
                }

               List<AggregateResult>  listOfDedupeResponse    = [select MAX(DPD__c)max,Applicant__c from DedupeResponse__c where LoanAppln__c =:recordId and   RecordType.Name = 'ENPA' and IsLatest__c = True AND Applicant__c in:setOfApplicantId Group BY Applicant__c]; 

               if(listOfDedupeResponse.size()>0){


                for (AggregateResult dedupResp: listOfDedupeResponse) {
                    if(dedupResp!=null){
                    String ApplicantId = (string)dedupResp.get('Applicant__c');
                    string max = (string)dedupResp.get('max');
                    mapOfDPD.put(ApplicantId,max);
                }
                }
                
        }

                
                for(Applicant__c appln: listOfApplicantDetails){
                    
                    getBoroowerDetailsWrapper getWrapperData = new getBoroowerDetailsWrapper();
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
                    
                    if(appln.Age__c != null && appln.LoanAppln__r.Loan_Tenure_Months__c !=null){
                        
                        
                        Decimal ageMaturity =0;
                        Integer ageAtMaturity;
                        ageMaturity = appln.Age__c + appln.LoanAppln__r.Loan_Tenure_Months__c/12;
                        ageAtMaturity = ageMaturity.intValue();
                        getWrapperData.ageAtLonaMaturityWrapper = ageAtMaturity;
                    }
                    
                    // List<ApplAsset__c> applAsstList = appln.Applicant_Assets__r;
                    List<ApplAssetJn__c> applAsstList = appln.ApplAssetJn__r;
                    List<Bureau__c> bureauList = appln.Bureau_Responses__r;
                    
                    if(applAsstList.size()>0){
                        
                        getWrapperData.propertyOwnerWrapper = 'Yes';
                        
                    }
                    else{
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
                
            }
            return borrowerwrapperData;
        }
        Catch (exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


        
        @AuraEnabled(Cacheable=true)
    public Static Map<Id,ConsoilidateFinancialWrapper> getfinancialSatement(String recordId, String activeTab) {
        FinancialRecordWrapper recordWrapper = new financialRecordWrapper();
        Map<Id,Map<String,FinancialRecordWrapper>> finalMapOfFinancialDetails = new Map<Id,Map<String,FinancialRecordWrapper>>();
        
        long lakh = 100000;
        Decimal Turnover;
        Decimal totalCurrentLiabilities;
        Decimal totalCurrentAssets;
        Decimal totalDebt;
        Decimal AdjustedNetWorth;
        Decimal stockValue;
        Decimal debtors;
        Decimal creditors;
        String getfinancialSatement;
        
        
        List<Applicant_Financial_Summary__c> financialStatementDate=new List<Applicant_Financial_Summary__c>();       
        String ObjectName = id.valueof(recordId).getSObjectType().getDescribe().getName();
        
        if(ObjectName=='LoanAppl__c')
        {
            financialStatementDate = [Select Id,Applicant_Financial__r.Loan_Applicant__c,Applicant_Financial__r.Loan_Applicant__r.TabName__c,Applicant_Financial__r.Loan_Applicant__r.FullName__c, Total_Sales__c , EBITDA__c , Profit_Before_Depreciation_and_Tax_PBDT__c, Profit_Before_Tax__c, PAT__c, Depreciation__c, 
                                      Interest_on_Partner_Capital__c, Salary_to_Partner_Directors__c, Non_Operating_Expenses_FxLoss_AssetLoss__c,
                                      Gross_Profit__c, Other_Operating_Income_IncomeIncidental__c, Sundry_creditors__c, Advances_from_customers__c,
                                      Other_current_liabilities__c, Provisions_for_exps_tax_etc__c, Bank_Borrowing_Working_Capital_OD_CC__c,
                                      Stock__c, Debtors__c, LessSix_months__c,Greaterthan6__c,Advances_to_Suppliers__c, Investments__c, Other_loans_advances__c, Prepaid_expenses__c, Other_current_assets__c,
                                      Cash_Bank_Balances__c, Total_Loan_funds__c, Adjusted_tangible_Netwroth__c, Opening_Stock__c, Purchases__c,
                                      Direct_Expenses__c, Closing_Stock__c, Interest_on_Term_Loans__c, Interest_on_CC_OD_limits__c,Applicant_Financial__r.Loan_Applicant__r.LoanAppln__r.EMIIcludingInsurance__c, 
                                      Applicant_Financial__r.Loan_Applicant__r.id, FinancialYearFor__c,Applicant_Financial__r.RecordType.Name,Applicant_Financial__r.Loan_Applicant__r.LoanAppln__r.EMI_Proposed_Loan__c,Date_of_Filing_ITR__c, ITR_Filing_Gap_Days__c,Comments_on_Profit_Loss__c,Comments_on_Balance_sheet__c ,GST_Month_Year__c,Gross_Turnover_as_per_GST_excl_taxes__c,Index__c from Applicant_Financial_Summary__c
                                       where Applicant_Financial__r.recordtype.name IN('Balance Sheet','Profit & Loss') AND Applicant_Financial__r.Loan_Applicant__r.LoanAppln__r.id =:recordId ORDER BY FinancialYearFor__c,Applicant_Financial__r.RecordType.Name ASC]; //a08C4000007x0uSIAQ old id a08C40000063xjHIAQ
        }
        else if(ObjectName=='Applicant__c')
        {
            
            financialStatementDate = [Select Id,Applicant_Financial__r.Loan_Applicant__c,Applicant_Financial__r.Loan_Applicant__r.TabName__c,Applicant_Financial__r.Loan_Applicant__r.FullName__c, Total_Sales__c , EBITDA__c , Profit_Before_Depreciation_and_Tax_PBDT__c, Profit_Before_Tax__c, PAT__c, Depreciation__c, 
                                      Interest_on_Partner_Capital__c, Salary_to_Partner_Directors__c, Non_Operating_Expenses_FxLoss_AssetLoss__c,
                                      Gross_Profit__c, Other_Operating_Income_IncomeIncidental__c, Sundry_creditors__c, Advances_from_customers__c,
                                      Other_current_liabilities__c, Provisions_for_exps_tax_etc__c, Bank_Borrowing_Working_Capital_OD_CC__c,
                                      Stock__c, Debtors__c, LessSix_months__c,Greaterthan6__c,Advances_to_Suppliers__c, Investments__c, Other_loans_advances__c, Prepaid_expenses__c, Other_current_assets__c,
                                      Cash_Bank_Balances__c, Total_Loan_funds__c, Adjusted_tangible_Netwroth__c, Opening_Stock__c, Purchases__c,
                                      Direct_Expenses__c, Closing_Stock__c, Interest_on_Term_Loans__c, Interest_on_CC_OD_limits__c,Applicant_Financial__r.Loan_Applicant__r.LoanAppln__r.EMIIcludingInsurance__c, 
                                      Applicant_Financial__r.Loan_Applicant__r.id, FinancialYearFor__c,Applicant_Financial__r.RecordType.Name,Applicant_Financial__r.Loan_Applicant__r.LoanAppln__r.EMI_Proposed_Loan__c,Date_of_Filing_ITR__c, ITR_Filing_Gap_Days__c,Comments_on_Profit_Loss__c,GST_Month_Year__c,Gross_Turnover_as_per_GST_excl_taxes__c,Index__c,Comments_on_Balance_sheet__c  from Applicant_Financial_Summary__c
                                      where Applicant_Financial__r.recordtype.name IN('Balance Sheet','Profit & Loss') AND Applicant_Financial__r.Loan_Applicant__c =:recordId ORDER BY FinancialYearFor__c,Applicant_Financial__r.RecordType.Name ASC]; //a08C4000007x0uSIAQ old id a08C40000063xjHIAQ
        }
        
        list<id> applicantIds = new list<id>();
        Map<id, decimal> monthlyIncMap = new Map<id, decimal>();
        Map<id, decimal> monthlyObligationMap = new Map<id, decimal>();
        if(financialStatementDate.size()>0){
            For(Applicant_Financial_Summary__c finance: financialStatementDate) {
                applicantIds.add(finance.Applicant_Financial__r.Loan_Applicant__c);
            }
        }
        Map<Id,ConsoilidateFinancialWrapper> applicantToFinancialWrap = new Map<Id,ConsoilidateFinancialWrapper>();
        Map<Id,ConsoilidateFinancialWrapper> finalaConolidatedMap = new Map<Id,ConsoilidateFinancialWrapper>();
        Integer index = 0;
        list<Bre__c> MonthlyIncome = [Select id,Mnthlyapprincome__c, Applicant__c from Bre__c where Applicant__C  in:(applicantIds) and EligibilityType__c = 'Applicant' and isLatest__c=true]; //:finance.Applicant_Financial__r.Loan_Applicant__c
        list<AggregateResult> MonthlyObligation = [SELECT Applicant__c, sum(EMI__c)sum FROM BureauRespDtl__c where Applicant__c in:(applicantIds) and Treatment__c='To continue - Obligate' group by Applicant__c]; //.size()>0 ? (Decimal) [SELECT sum(EMI__c)sum FROM BureauRespDtl__c where Applicant__c in:(applicantIds) and Treatment__c='To continue - Obligate' group by Applicant__c][0].get('sum') :0;
        
        for (Bre__c monthlyInc: MonthlyIncome) {
            monthlyIncMap.put(monthlyInc.Applicant__c, monthlyInc.Mnthlyapprincome__c);
        }
        for (AggregateResult monthObligation: MonthlyObligation) {
            String ApplicantId = (string)monthObligation.get('Applicant__c');
            decimal sum = (decimal)monthObligation.get('sum');
            monthlyObligationMap.put(ApplicantId, sum);
        }
        
        
        if(financialStatementDate.size()>0)
        {
            For(Applicant_Financial_Summary__c finance: financialStatementDate){
                
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
               
                if (monthlyIncMap.containsKey(finance.Applicant_Financial__r.Loan_Applicant__c)) {
                    Decimal dscrMonthlyIncomeData = monthlyIncMap.get(finance.Applicant_Financial__r.Loan_Applicant__c) != null ? monthlyIncMap.get(finance.Applicant_Financial__r.Loan_Applicant__c) : 0;
                    Decimal dscrObligationData = monthlyObligationMap.containsKey(finance.Applicant_Financial__r.Loan_Applicant__c) ? monthlyObligationMap.get(finance.Applicant_Financial__r.Loan_Applicant__c) : 0;
                    Decimal dscrEmiAmount = finance.Applicant_Financial__r.Loan_Applicant__r.LoanAppln__r.EMIIcludingInsurance__c != null ? finance.Applicant_Financial__r.Loan_Applicant__r.LoanAppln__r.EMIIcludingInsurance__c : 0;
                    
                    Decimal denominatorValue = dscrObligationData + (dscrEmiAmount != null ? dscrEmiAmount : 0);
                    
                    if (dscrMonthlyIncomeData > 0 && denominatorValue > 0) {
                         if(dscrObligationData > 0){
                            recordWrapper.DSCRPre = (dscrMonthlyIncomeData / dscrObligationData).setScale(2);
                        }else{
                            recordWrapper.DSCRPre = 0;
                        }
                        recordWrapper.DSCRPost = (dscrMonthlyIncomeData / denominatorValue).setScale(2);
                    } else {
                        recordWrapper.DSCRPre = 0;
                        recordWrapper.DSCRPost = 0;
                    }
                } else {
                    recordWrapper.DSCRPre = 0;
                    recordWrapper.DSCRPost = 0;
                }
                
                
                
                if(finance.Applicant_Financial__r.recordtype.name == 'Balance Sheet'){
                    //do calculaclate for balanceSheet
                    
                    if (finance.Sundry_creditors__c != null && finance.Advances_from_customers__c != null && finance.Other_current_liabilities__c !=null && finance.Provisions_for_exps_tax_etc__c != null && finance.Bank_Borrowing_Working_Capital_OD_CC__c != null) {
                        recordWrapper.totalCurrentLiabilities = ((finance.Sundry_creditors__c + finance.Advances_from_customers__c + finance.Other_current_liabilities__c + finance.Provisions_for_exps_tax_etc__c + finance.Bank_Borrowing_Working_Capital_OD_CC__c)/lakh).setScale(2);
                       
                    }
                    
                    if (finance.Stock__c != null && finance.LessSix_months__c != null && finance.Greaterthan6__c != null && finance.Advances_to_Suppliers__c != null && finance.Investments__c != null && finance.Other_loans_advances__c != null && finance.Prepaid_expenses__c != null && finance.Other_current_assets__c != null && finance.Cash_Bank_Balances__c != null) {
                        recordWrapper.totalCurrentAssets = ((finance.Stock__c + finance.LessSix_months__c + finance.Greaterthan6__c + finance.Advances_to_Suppliers__c + finance.Investments__c + finance.Other_loans_advances__c + finance.Prepaid_expenses__c + finance.Other_current_assets__c + finance.Cash_Bank_Balances__c)/lakh).setScale(2);
                       
                    }

                    
                    if (finance.Total_Loan_funds__c != null && finance.Bank_Borrowing_Working_Capital_OD_CC__c != null) {
                        recordWrapper.totalDebt = ((finance.Total_Loan_funds__c - finance.Bank_Borrowing_Working_Capital_OD_CC__c)/lakh).setScale(2);
                       
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
                    
                    
                    recordWrapper.stockValue = finance.Stock__c != null ? (finance.Stock__c/lakh).setScale(2) : 0;
                    //Drop 2 LAK-125
                    if(finance.Comments_on_Balance_sheet__c  != null){
                        recordWrapper.finCommentsBS = finance.Comments_on_Balance_sheet__c ;
                    }

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
                    
                    recordWrapper.turnOver = (finance.Total_Sales__c != null ? finance.Total_Sales__c/lakh : 0).setScale(2);
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

                    //LAK-7316 - Changes under BIL UW Summary
                    recordWrapper.itrFilingDate = '';
                    if(finance.Date_of_Filing_ITR__c!=null){
                        DateTime filingdate = finance.Date_of_Filing_ITR__c;
                        recordWrapper.itrFilingDate = filingdate.format('dd-MM-yyyy');
                    }
                    if(finance.ITR_Filing_Gap_Days__c != null){
                        recordWrapper.gapDays = finance.ITR_Filing_Gap_Days__c;
                    }
                    //Drop 2 LAK-125
                    if(finance.Comments_on_Profit_Loss__c != null){
                        recordWrapper.finCommentsPL = finance.Comments_on_Profit_Loss__c;
                    }
                    
                    recordWrapper.PBDT = finance.Profit_Before_Depreciation_and_Tax_PBDT__c != null ? (finance.Profit_Before_Depreciation_and_Tax_PBDT__c/lakh).setScale(2) : 0;
                    recordWrapper.PBT = finance.Profit_Before_Tax__c != null ? (finance.Profit_Before_Tax__c/lakh).setScale(2): 0;
                    recordWrapper.PAT = finance.PAT__c != null ? (finance.PAT__c/lakh).setScale(2) : 0;
                    recordWrapper.purchase = finance.Purchases__c != null ? (finance.Purchases__c).setScale(2): 0;
                    
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
                            recordWrapper.netProfitMargin = (( recordWrapper.PBT/recordWrapper.turnOver)*100).setScale(2);
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
                        
                        recordWrapper.openingStock = finance.Opening_Stock__c/lakh;
                        recordWrapper.closingStock = finance.Closing_Stock__c/lakh;
                        recordWrapper.directExpense = finance.Direct_Expenses__c/lakh;
                        
                    }
                    
                    
                }
                //LAK-7316 - Changes under BIL UW Summary
                else if(finance.Applicant_Financial__r.recordtype.name == 'Consolidate GST'){
                    if(finance.GST_Month_Year__c != null){
                        recordWrapper.gstMonthYear = finance.GST_Month_Year__c;
                    }
                    if(finance.Gross_Turnover_as_per_GST_excl_taxes__c != null ){
                        recordWrapper.grossTurnGstExcTaxes = finance.Gross_Turnover_as_per_GST_excl_taxes__c;
                    }
                    if(finance.Index__c != null){
                        recordWrapper.gstIndex = finance.Index__c;
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
                
            }
            
            
            
            Integer i=0;
            
            for(Id fnMap:finalMapOfFinancialDetails.keySet()){
                
                recordWrapper  = new FinancialRecordWrapper();
                ConsoilidateFinancialWrapper ConsolidateWrapper = new ConsoilidateFinancialWrapper();
                
                i=0;
                
                for(String Year : finalMapOfFinancialDetails.get(fnMap).keySet()){
                    recordWrapper = finalMapOfFinancialDetails.get(fnMap).get(year);
                    // ConsolidateWrapper.previousFinancialRecord = false;
                    ConsolidateWrapper.DSCRPree = recordWrapper.DSCRPre;
                    ConsolidateWrapper.DSCRPostt = recordWrapper.DSCRPost;
                    
                    if(i==0){
                        
                        ConsolidateWrapper.lastFinancialYear =recordWrapper;
                        ConsolidateWrapper.previousFinancialRecord = true;
                        ConsolidateWrapper.finacialYear1 = +'FY'+' '+Year;
                        consolidateWrapper.borrowerNameConsolidate = recordWrapper.borrowerName;
                        
                        
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
            
        }
        return finalaConolidatedMap;
    }
    
    @AuraEnabled(Cacheable=true)
    public static ResponseWrapper fetchRecords(String recordId) {
        String incomeProgramAppl ='Cash Flow - Assessed income,Business income - Regular Income Program (P&L),Gross Eligible Salary with Bank Credit,Net Eligible Salary with Bank Credit,Cash Salary,Net Salary,Rental bank credit,Rental without bank credit,Pension Income,Other Income,Agriculture Income,Gross Salary';
        Map<Id,ApplicantEligibility> applicantEliMap = new Map<Id,ApplicantEligibility>();
       
        List<BRE_Eligibility__c> breList = new List<BRE_Eligibility__c>();
        breList = [SELECT Id, Name, BREResponse__c, Type__c, IncomeProgram__c,BREResponse__r.Applicant__c,BREResponse__r.Applicant__r.FullName__c,BREResponse__r.Applicant__r.AssessmentProgram__c, BREResponse__r.LoanAppl__c, BREValue__c, BREValueType__c, IsLatest__c FROM BRE_Eligibility__c WHERE IsLatest__c=true AND type__c = 'Applicant' AND BREResponse__r.LoanAppl__c=:recordId];
        
        ApplicantEligibility wrapObj = new ApplicantEligibility();
      
        
        ResponseWrapper resp = new ResponseWrapper();
        resp.application = new ApplicantEligibility();
        for (BRE_Eligibility__c record : breList) {
            wrapObj.applicantRecord = record.BREResponse__r.Applicant__r.FullName__c;
            wrapObj.ApplicantId = record.BREResponse__r.Applicant__c;
            
            if(record.Type__c =='Applicant' && record.BREResponse__r.Applicant__c != null){
                
                wrapObj = (applicantEliMap.containsKey(record.BREResponse__r.Applicant__c)) ? applicantEliMap.get(record.BREResponse__r.Applicant__c): new ApplicantEligibility();
                
                wrapObj.assesmentProgram =(record.BREResponse__r.Applicant__r.AssessmentProgram__c != null)? record.BREResponse__r.Applicant__r.AssessmentProgram__c: 'Not Available';
                resp.showAssesmentProgram =(record.BREResponse__r.Applicant__r.AssessmentProgram__c != null);
                
               
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
        
        for(Applicant__c appli : [select id,LoanAppln__c, ApplType__c, FullName__c,Type_of_Borrower__c,Average_Monthly_Rental_No_Bank_Credit__c,
                                  Average_Monthly_Rental_With_Bank_Credit__c,Average_Other_Income__c,AssessmentProgram__c,
                                  AverageMonthlyAgricultureIncome__c,Average_Monthly_Cash_Salary__c,Average_Monthly_Pension__c,
                                  Average_Monthly_Gross_Salary__c, Average_Net_Salary__c, (select NET_CASH_PROFIT_LOSS__c from Applicant_Income__r where RecordType.DeveloperName = 'cashflow_map')
                                  FROM Applicant__c where Type_of_Borrower__c='Financial' AND ApplType__c IN('P','G','C') AND LoanAppln__c=:recordId]){
                                      
                                      wrapObj =(applicantEliMap.containsKey(appli.Id))?applicantEliMap.get(appli.Id):new ApplicantEligibility();
                                      
                                      
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
                                      
                                      
                                      wrapObj.rentalBankCredit =(appli.Average_Monthly_Rental_With_Bank_Credit__c != null)?appli.Average_Monthly_Rental_With_Bank_Credit__c:0;
                                      if (appli.Average_Monthly_Rental_With_Bank_Credit__c != null) {
                                          resp.showRentalWBankCredit =(appli.Average_Monthly_Rental_With_Bank_Credit__c != null);
                                      }
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
        List<BRE__c> breRespList = new List<BRE__c>();
        
        
        breRespList=[SELECT Id, LoanAppl__c, Applicant__c,Max_EMI_Other_than_Cash_Salary__c, EligibilityType__c, AppraisedMonIncome__c, RAACROI__c, Applicable_FOIR__c, Appl_EMI_Net_Salary__c, Applicable_FOIR_Cash_Salary__c, Max_EMI_Cash_Salary__c, Eligible_tenure_in_Months__c, FinaLnEligOthr_Cash_Salary__c, FinLoanEligibCashSalary__c,FinancialLoanEligibilityTotal__c, Financial_Loan_Eligibility_Total__c, Application_level_Assessment_program__c,MaxBreLnEliWoIns__c,MaxBreLnEliWIns__c,MaxBreLnEliWDeviation__c,MaxFinLnEligblwithDevi__c,EMI__c,Actual_FOIR__c, Actual_LTV__c, CombLTV_FOIR__c,MaxcoltrlLnEliWDeviation__c,LTVApplWDeviation__c,TotlLTVBsdLnEliWIns__c,AddLTVBsdEliIns__c,LTVBsdEliWOIns__c,LTVApplLnWtInsurance__c,LTVApplLnWOInsurance__c,Combined_LTV_And_FOIR_with_Insurance__c FROM BRE__c where LoanAppl__c=:recordId];
       
        for (BRE__c recordBREResp : breRespList) {
            
            if(recordBREResp.EligibilityType__c =='Applicant' && recordBREResp.Applicant__c != null){
                
                wrapObj =(applicantEliMap.containsKey(recordBREResp.Applicant__c))? applicantEliMap.get(recordBREResp.Applicant__c):new ApplicantEligibility();
                
                wrapObj.ApprMonthIncOtherthanCashSalary =(recordBREResp.AppraisedMonIncome__c != null)?recordBREResp.AppraisedMonIncome__c:0;
                
                wrapObj.ApplFOIR =(recordBREResp.Applicable_FOIR__c != null)?recordBREResp.Applicable_FOIR__c:0;
                
                wrapObj.ApplEMINetSalary =  (recordBREResp.Appl_EMI_Net_Salary__c != null)?recordBREResp.Appl_EMI_Net_Salary__c: 0;              
                
                wrapObj.MaxEMIOtherCashSalary =(recordBREResp.Max_EMI_Other_than_Cash_Salary__c != null)?recordBREResp.Max_EMI_Other_than_Cash_Salary__c:0;
                
                wrapObj.ApplFOIRCashSalary=(recordBREResp.Applicable_FOIR_Cash_Salary__c != null)?recordBREResp.Applicable_FOIR_Cash_Salary__c:0;
                wrapObj.MaxEMICashSalary =(recordBREResp.Max_EMI_Cash_Salary__c != null)?recordBREResp.Max_EMI_Cash_Salary__c:0;
                applicantEliMap.put(recordBREResp.Applicant__c,wrapObj);
                
            }
            
            if(recordBREResp.EligibilityType__c =='Application' && recordBREResp.LoanAppl__c != null){
                
                
                resp.application.EliTenureMonths =(recordBREResp.Eligible_tenure_in_Months__c != null)? recordBREResp.Eligible_tenure_in_Months__c:0;
                
                resp.application.RAACROI = (recordBREResp.RAACROI__c != null) ? recordBREResp.RAACROI__c:0;
                
                
                resp.application.FinLoanEliTotal = (recordBREResp.FinancialLoanEligibilityTotal__c != null)? recordBREResp.FinancialLoanEligibilityTotal__c:0;
                              
                
                resp.application.ApplLevelAssprogram = (recordBREResp.Application_level_Assessment_program__c != null)? recordBREResp.Application_level_Assessment_program__c:'';
                
                resp.application.MaxBreLnEliWoIns =(recordBREResp.MaxBreLnEliWoIns__c != null) ?  recordBREResp.MaxBreLnEliWoIns__c:0;
                
                resp.application.MaxBreLnEliWIns =(recordBREResp.MaxBreLnEliWIns__c != null)?  recordBREResp.MaxBreLnEliWIns__c:0;
                resp.application.MaxBreLnEliWDeviation =(recordBREResp.MaxBreLnEliWDeviation__c != null)?  recordBREResp.MaxBreLnEliWDeviation__c:0;
                
                resp.application.EMI =(recordBREResp.EMI__c != null)?  recordBREResp.EMI__c:0;
                resp.application.ActuaFOIR =(recordBREResp.Actual_FOIR__c != null)?  (recordBREResp.Actual_FOIR__c).setscale(2):0;
                resp.application.ActualLTV =(recordBREResp.Actual_LTV__c != null)?  (recordBREResp.Actual_LTV__c).setscale(2):0;
                resp.application.CombLTVFOIR =(recordBREResp.Combined_LTV_And_FOIR_with_Insurance__c != null)? (recordBREResp.Combined_LTV_And_FOIR_with_Insurance__c).setscale(2):0;
                
                
            }
            
            if(recordBREResp.EligibilityType__c =='Application'){
                
                resp.application.ApprMonthIncOtherthanCashSalary =(recordBREResp.AppraisedMonIncome__c != null)?recordBREResp.AppraisedMonIncome__c:0;
                resp.application.MaxEMIOtherCashSalary =(recordBREResp.Max_EMI_Other_than_Cash_Salary__c != null)?recordBREResp.Max_EMI_Other_than_Cash_Salary__c:0;
                resp.application.MaxEMICashSalary =(recordBREResp.Max_EMI_Cash_Salary__c != null)?recordBREResp.Max_EMI_Cash_Salary__c:0;
               
            }
            
            
            
        }
       
        
        
        //This is for obligation table
        for(AggregateResult aggr : [SELECT Applicant__c, SUM(EMI__c)amt FROM BureauRespDtl__c WHERE Treatment__c = 'To continue - Obligate' AND LoanApplication__c=:recordId and Applicant__c != null GROUP BY Applicant__c ]){
            wrapObj = applicantEliMap.get((id)aggr.get('Applicant__c'));
            
            applicantEliMap.put((id)aggr.get('Applicant__c'),wrapObj);
        }
       
        resp.eligibilityList = applicantEliMap.values();
        return resp;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<HLRelatedDetailsWrapper> getHLRelatedDetailsData(String recordId){
        
        List<HLRelatedDetailsWrapper> listRecordWrapperHL = new List<HLRelatedDetailsWrapper>();
        
        List<ApplAsset__c>  applicantAssetsList = new List<ApplAsset__c>();
        List<LoanAppl__c>  loanApplicationList = new List<LoanAppl__c>();
        
       applicantAssetsList = [Select id,Agrem_Value__c, Regi_Cost__c, Stamp_Duty__c, Amenities__c, Total_Prop_Cost__c,
                              Down_payment_PartORegisteredAgreement__c, Balance_OCR_to_be_arranged_by_customer__c,
                              Total_estimate_as_per_architect_agreemen__c,Stage_of_Construction__c, 
                              StageOfConstrAsPerValuatioReport__c,Land_Valu__c,ValuationToBeTakenAheadForCalculation__c,
                              Built_up_area_Valu__c from ApplAsset__c where LoanAppln__c =:recordId]; //a08C4000007x0uSIAQ
        
        loanApplicationList = [Select id,Final_Loan_Disbursal_Amount__c,Product__c,SchemeId__c from LoanAppl__c where id=:recordId];
       
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
           
            RecordWrapperHLData.isHomeLoan = false;
            RecordWrapperHLData.registeredAggrementValue = registeredAggrementValueSum;
            RecordWrapperHLData.downPayment = downPaymentSum;
            RecordWrapperHLData.balanceAmount = registeredAggrementValueSum - downPaymentSum;
            RecordWrapperHLData.balanceOCR  = balanceOCRSum;
            RecordWrapperHLData.mktValueOfProperty = mktValueOfPropertySum;
            if(loanApplicationList.size()>0){
                 RecordWrapperHLData.fedfinaLoanFunding = loanApplicationList[0].Final_Loan_Disbursal_Amount__c == null ? 0 : loanApplicationList[0].Final_Loan_Disbursal_Amount__c;
            }
         
       
         if(loanApplicationList.size()>0)
            {
                if(loanApplicationList[0].Product__c== 'Home Loan')
                {
                   RecordWrapperHLData.isHomeLoan=true; 
                }
                
            }
            
            listRecordWrapperHL.add(RecordWrapperHLData);
            
       
        }
         return listRecordWrapperHL;
           
        
    }
    
    
    @AuraEnabled(cacheable=true)
    public static List<ConstructionRelatedDetailsWrapper> getConstructionRelatedDetailData(String recordId){
        
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
	      }
           
         }
            }
        
        
     if(applicantAssetsList.size()>0){
            
        for(ApplAsset__c appAsset: applicantAssetsList){
            
            
             ConstructionRelatedDetailsWrapper RecordWrapperConstructionData = new ConstructionRelatedDetailsWrapper();
            RecordWrapperConstructionData.isConstruction = false;
            //RecordWrapperConstructionData.isHomeLoan = false; 
            RecordWrapperConstructionData.totalEstimateAsPerArtitech = /*appAsset.Appr_Cost_of_Const__c == null? 0:*/appAsset.Appr_Cost_of_Const__c;
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
            
            
            listRecordWrapperConstruction.add(RecordWrapperConstructionData);
           
            
            
            
        }
            
        
        }
         return listRecordWrapperConstruction;
           
        
    }
    @AuraEnabled(Cacheable=true)
    public static responseWrapper2 propDetails(string recordId) {
        responseWrapper2 resp = new responseWrapper2();
        List<BRE__c> breRespList = new List<BRE__c>();
        breRespList=[SELECT Id,Applicant_Asset__c, LoanAppl__c, Applicant__c,LTVApplWDeviation__c,MaxcoltrlLnEliWDeviation__c,TotlLTVBsdLnEliWIns__c,AddLTVBsdEliIns__c,LTVBsdEliWOIns__c,LTVApplLnWtInsurance__c,LTVApplLnWOInsurance__c,EligibilityType__c FROM BRE__c where LoanAppl__c=:recordid];
       
        resp.TotlLTVBsdLnEliWIns2 = 0;
        for (BRE__c recordBREResp : breRespList) {
            //For Property  Table
            
            if(recordBREResp.EligibilityType__c =='Property'){
                
               resp.TotlLTVBsdLnEliWIns2 = (recordBREResp.TotlLTVBsdLnEliWIns__c != null)?  recordBREResp.TotlLTVBsdLnEliWIns__c:0;
             
                
            }
        }
        //LAK-7688
        // List<AggregateResult> aggregateResults = [SELECT SUM(AUM__c)sum FROM DedupeResponse__c WHERE RecordType.Name = 'ENPA' 
        //                                           AND Loan_to_be_closed_internally__c ='No'AND LoanAppln__c = :recordId];
        // list<loanappl__c> sanctionLoanAmount = [Select SanLoanAmt__c,TotalLoanAmtInclInsurance__c from LoanAppl__c where id =:recordId];
        // resp.sumFedFinaExpLnAmt=0;
        
        // if (aggregateResults.size()>0 && aggregateResults[0].get('sum') != null) {
        //     resp.sumFedFinaExpLnAmt = (Decimal)aggregateResults[0].get('sum');
            
        // }

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
        //LAK-10323 - End

        if (sanctionLoanAmount.size()>0 && sanctionLoanAmount[0].TotalLoanAmtInclInsurance__c !=null) {
           
            resp.TotalfedfinaLoanExposure = sanctionLoanAmount[0].TotalLoanAmtInclInsurance__c + resp.sumFedFinaExpLnAmt;
        }
        return resp;
    }
//LAK-125 -- Drop 2
    @AuraEnabled
    public static list<Applicant__c> getGstDetails(string recordId){
        try{
            
           List<Applicant__c> GstDetails = [Select Id, Total_Turnover_as_per_GST__c, FullName__c from Applicant__c where LoanAppln__r.id=:recordId and Type_of_Borrower__c = 'Financial' and Constitution__c != 'INDIVIDUAL'];
           
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

    @AuraEnabled(Cacheable=true)
    public static List<getHunterAndRCUDataWrapper> getHunterAndRCUStatus(String recordId){
        
        List<HunterVer__c> hunterList = new List<HunterVer__c>();
        List<getHunterAndRCUDataWrapper> allWrapperDataHunter = new List<getHunterAndRCUDataWrapper>();
        getHunterAndRCUDataWrapper wrapperDataHunter = new getHunterAndRCUDataWrapper();

        hunterList = [SELECT Id,HunMatchSta__c FROM HunterVer__c WHERE IsLatest__c = true and LoanAplcn__c =:recordId Limit 1];
        if(!hunterList.isEmpty()){
            
            wrapperDataHunter.hunter = hunterList[0].HunMatchSta__c;
        }

        List<Case> rcuList = new List<Case>();
        rcuList = [SELECT Id,ReportResult__c,Final_RCU_status_Reason__c FROM Case WHERE RecordType.Name= 'RCU' and Loan_Application__c =:recordId ORDER BY Date_of_Report__c DESC Limit 1 ];
        if(!rcuList.isEMpty()){
          
            wrapperDataHunter.RCUStatus = rcuList[0].ReportResult__c;
            wrapperDataHunter.RCUProfileStatus = rcuList[0].Final_RCU_status_Reason__c;
            wrapperDataHunter.Id = rcuList[0].Id;
        }

        allWrapperDataHunter.add(wrapperDataHunter);

       if(allWrapperDataHunter.size()>0){
        return allWrapperDataHunter;
    }else{
        return null;
    }
    }
    
Public class getHunterAndRCUDataWrapper{
    @auraEnabled public String hunter{get;set;}
    @auraEnabled public string RCUStatus{get;set;}
    @auraEnabled public String RCUProfileStatus{get;set;}
    @auraEnabled public String Id{get;set;}
    

}

    public class ApplicantEligibility{
        
        //These are BRE Eligibility data
        @auraEnabled public String ApplicantId{get;set;}
        @auraEnabled public string applicantRecord{get;set;}
        
       
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
        
        
    }
    Public class ResponseWrapper2{
        @auraEnabled public decimal sumFedFinaExpLnAmt{get;set;}
        @auraEnabled public decimal TotlLTVBsdLnEliWIns2{get;set;}
        @auraEnabled public decimal TotalfedfinaLoanExposure{get;set;}
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
        public string turnOverGrowthRatePercent{get;set;}
        @AuraEnabled
        public decimal DSCRPre{get;set;}
        @AuraEnabled
        public decimal DSCRPost{get;set;}
        @AuraEnabled
        public decimal openingStock{get;set;}
        @AuraEnabled
        public decimal closingStock{get;set;}
        @AuraEnabled
        public decimal directExpense{get;set;}
        //LAK-7316 - Changes under BIL UW Summary
        @AuraEnabled
        public String itrFilingDate{get;set;}
        @AuraEnabled
        public String gapDays{get;set;}
        @AuraEnabled
        public String finCommentsPL{get;set;}
        @AuraEnabled
        public String finCommentsBS{get;set;}
        @AuraEnabled
        public Decimal gstIndex{get;set;}
        @AuraEnabled
        public Decimal grossTurnGstExcTaxes{get;set;}
        @AuraEnabled
        public String gstMonthYear{get;set;}
        
    }
    
    Public class ConsoilidateFinancialWrapper{
        @AuraEnabled
        Public FinancialRecordWrapper lastFinancialYear{get;set;}
        @AuraEnabled
        Public FinancialRecordWrapper currentFinancialYear{get;set;}
        @AuraEnabled
        Public FinancialRecordWrapper provisionalFinancialYear{get;set;}
        @AuraEnabled
        public Boolean currentFinancialRecord{get;set;}
        @AuraEnabled
        public Boolean previousFinancialRecord{get;set;}
        @AuraEnabled
        public Boolean provisionFinancialRecord{get;set;}
        @AuraEnabled
        Public String finacialYear1{get;set;}
        @AuraEnabled
        Public String finacialYear2{get;set;}
        @AuraEnabled
        Public String finacialYear3{get;set;}
        @AuraEnabled
        Public String Id{get;set;}
        @AuraEnabled
        Public String borrowerNameConsolidate{get;set;}
        @AuraEnabled
        public decimal DSCRPree{get;set;}
        @AuraEnabled
        public decimal DSCRPostt{get;set;}
        
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
        public String totalMinBalanceCharges {get;set;}
        @AuraEnabled
        public Decimal totalAverageBankBalance {get;set;}
        @AuraEnabled
        public Decimal totalLimit {get;set;}    
        @AuraEnabled
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
        public String averageMinBalanceCharges {get;set;}
        @AuraEnabled
        public Decimal averageAverageBankBalance {get;set;}
        @AuraEnabled
        public Decimal averageUtilisation{get;set;}
        @AuraEnabled
        public Decimal averageLimit{get;set;}
        
    }
    
    
    public class getDecisionSummaryWrapper{
        @AuraEnabled
        public UWDecision__c listDecisionSummaryWrapper {get;set;}
        @AuraEnabled
        public String fedfinaUnderwriterWrapp {get;set;}
        @AuraEnabled
        public String fedfinaApproverWrap {get;set;}
        
        
    }
    
    public class getBoroowerDetailsWrapper{
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
    
    public class getLoanDetailsSummaryWrapper{
        
        @AuraEnabled
        public String branchCity {get;set;}
        @AuraEnabled
        public String branchState {get;set;}
        @AuraEnabled
        public String schemeName {get;set;}
        @AuraEnabled
        public String empNameBBH {get;set;}
        @AuraEnabled
        public String securitisationCheck {get;set;}
        @AuraEnabled
        public decimal TotalLoanAmount {get;set;}
        @AuraEnabled
        public String strLinkedLoans {get;set;}
        @AuraEnabled
        public String maxValueSubProperty {get;set;}
        @AuraEnabled
        public String applPropertyType {get;set;}
        @AuraEnabled
        public String natureOfBusinessIndv {get;set;}
        @AuraEnabled
        public String loanToRelativeCheck {get;set;}
        @AuraEnabled
        public String ESGNegative {get;set;}
        @AuraEnabled
        public String MSMEcategorisation {get;set;}
        @AuraEnabled
        public String nameRMSM {get;set;}
         @AuraEnabled
        public String ChannelRName {get;set;}
        
        @AuraEnabled
        public String imdStatus {get;set;}
        
        @AuraEnabled
        public String loginDate {get;set;}
        
        @AuraEnabled
        public String BTFinancier {get;set;}
         @AuraEnabled
        public String BDApplicantCoapp {get;set;}
         @AuraEnabled
        public String IncomerelateComm {get;set;}
         @AuraEnabled
        public String AddationalComm {get;set;}
         @AuraEnabled
        public String PrsnldetailsofPromotrs {get;set;}
       @AuraEnabled
        public String PropertyUsage {get;set;}
        @AuraEnabled
        public Decimal FOIRLoanAmountInsurance {get;set;}
        @AuraEnabled
        public Decimal LTVInsurance {get;set;}
        @AuraEnabled
        public Decimal CombinedLTV {get;set;}
        @AuraEnabled
        public Decimal FOIRPerIncome {get;set;}
        @AuraEnabled
        public Decimal TotalFedfinaExposure {get;set;}
        @AuraEnabled
        public String urcUacNumber {get;set;}
        //LAK-7316 - Changes under BIL UW Summary
        @AuraEnabled
        public Decimal businessVintage {get;set;}
        @AuraEnabled
        public String existingBLProduct{get;set;}
        @AuraEnabled
        public String existingOtherProduct{get;set;}
        
        
        
        public getLoanDetailsSummaryWrapper(String branchCity, String branchState, String schemeName, String empNameBBH, String securitisationCheck, decimal TotalLoanAmount, String strLinkedLoans,String maxValueSubProperty,String applPropertyType, String natureOfBusinessIndv,String loanToRelativeCheck,String ESGNegative,String MSMEcategorisation, String nameRMSM,String ChannelRName, String imdStatus,String loginDate,String BTFinancier,String BDApplicantCoapp,String IncomerelateComm,String AddationalComm,String PrsnldetailsofPromotrs,String PropertyUsage,Decimal FOIRLoanAmountInsurance,Decimal LTVInsurance,Decimal CombinedLTV,Decimal FOIRPerIncome,Decimal TotalFedfinaExposure,String urcUacNumber, Decimal businessVintage,String existingBLProduct, String existingOtherProduct) {
            this.branchCity = branchCity;
            this.branchState = branchState;
            this.schemeName = schemeName;
            this.empNameBBH = empNameBBH;
            this.TotalLoanAmount = TotalLoanAmount;
            this.securitisationCheck = securitisationCheck;
            this.strLinkedLoans = strLinkedLoans;
            this.maxValueSubProperty = maxValueSubProperty;
            this.applPropertyType = applPropertyType;
            this.natureOfBusinessIndv = natureOfBusinessIndv;
            this.loanToRelativeCheck = loanToRelativeCheck;
            this.ESGNegative = ESGNegative;
            this.MSMEcategorisation = MSMEcategorisation;
            this.nameRMSM = nameRMSM;
            this.ChannelRName=ChannelRName;
            this.imdStatus = imdStatus;
            this.loginDate = loginDate;
            this.BTFinancier = BTFinancier;
            this.BDApplicantCoapp=BDApplicantCoapp;
            this.IncomerelateComm=IncomerelateComm;
            this.AddationalComm=AddationalComm;
            this.PrsnldetailsofPromotrs=PrsnldetailsofPromotrs;
            this.PropertyUsage=PropertyUsage;
            this.FOIRLoanAmountInsurance=FOIRLoanAmountInsurance;
            this.LTVInsurance=LTVInsurance;
            this.CombinedLTV=CombinedLTV;
            this.FOIRPerIncome=FOIRPerIncome;
            this.TotalFedfinaExposure=TotalFedfinaExposure;
            this.urcUacNumber=urcUacNumber;
            //LAK-7316 - Changes under BIL UW Summary
            this.businessVintage = businessVintage;
            this.existingBLProduct = existingBLProduct;
            this.existingOtherProduct = existingOtherProduct;
        }
    }
    
    // wrapper class with @AuraEnabled and {get;set;} properties 
    public class getCollateralVerificationDetailsWrapper{
        
        @AuraEnabled
        public ApplAsset__c lstOfApplicantAssetsWrapp{get;set;}
        @AuraEnabled
        public String propertyVisitStatus {get;set;}
        @AuraEnabled
        public Decimal totalValuation1 {get;set;}
        @AuraEnabled
        public Decimal totalValuation2 {get;set;}
        @AuraEnabled
        public Decimal totalValuation3 {get;set;}
        @AuraEnabled
        public string propertyVisitOfficer {get;set;}
        @AuraEnabled
        public case legalCase {get;set;}
        @AuraEnabled
        public case tsrCase {get;set;}
        @AuraEnabled
        public case visitCase {get;set;}
        
       
       
        
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
    
    // transient public list<EmploymentWrapper> EmploymentList{get;set;}
    @AuraEnabled(cacheable=true)
    public static list<ObligationDetailsSummaryController.EmploymentWrapper> getApplicantEmploymentDetail(String recordId) {
         list<ApplicantEmployment__c> ApplicantEmploymentDetail;
        try {
            ApplicantEmploymentDetail = [Select Id,MainRBIIndustry__c, SubIndustry__r.Name, toLabel(TypeOfOrganisation__c),
                                         LoanApplicant__r.FullName__c
                                         from ApplicantEmployment__c where LoanApplicant__r.LoanAppln__r.id =:recordId order by CreatedDate Asc];
            Set<id> applicantId=new Set<id>();
            Map<Id,PD__c> applPD=new Map<Id,PD__c>();
            list<ObligationDetailsSummaryController.EmploymentWrapper> EmploymentList=new list<ObligationDetailsSummaryController.EmploymentWrapper>();
            if (ApplicantEmploymentDetail.size()>0) {
                for(ApplicantEmployment__c appObjj:ApplicantEmploymentDetail)
                {
                    applicantId.add(appObjj.LoanApplicant__c);
                }
                
                for(PD__c pdObj:[Select id,PDStatus__c,PDRmrks__c,Appl__c,PdTyp__c,Appl__r.CustProfile__c,CmpltDt__c,AsgnTo__r.name from PD__c where Appl__c IN:applicantId and CmpltDt__c != NULL ORDER BY CmpltDt__c DESC])  // CmpltDt__c!=null 
                {
                    applPD.put(pdObj.Appl__c,pdObj);
                    
                    if(!applPD.containsKey(pdObj.Appl__c) && pdObj.Appl__r.CustProfile__c != 'Salaried' && pdObj.PdTyp__c.contains('Physical PD')){
                        applPD.put(pdObj.Appl__c,pdObj);     
                        
                        
                    }
                    if(!applPD.containsKey(pdObj.Appl__c) && pdObj.Appl__r.CustProfile__c == 'Salaried'){
                        applPD.put(pdObj.Appl__c,pdObj);                   
                    }
                }
                
                for(ApplicantEmployment__c appObj:ApplicantEmploymentDetail)
                {
                    ObligationDetailsSummaryController.EmploymentWrapper empObj=new ObligationDetailsSummaryController.EmploymentWrapper();
                    empObj.borrowerName=appObj.LoanApplicant__r.FullName__c;
                    empObj.typeOfEmployment=appObj.TypeOfOrganisation__c;
                    empObj.industryOfMainEstablishment=appObj.MainRBIIndustry__c;
                    empObj.subIndustryOfMainEstablishment=appObj.SubIndustry__r.Name;
                    
                    empObj.pdStatus=applPD.size()>0?(applPD.get(appObj.LoanApplicant__c)!=null?applPD.get(appObj.LoanApplicant__c).PDStatus__c:''):'';
                    empObj.pdRemarksSummary=applPD.size()>0?(applPD.get(appObj.LoanApplicant__c)!=null?applPD.get(appObj.LoanApplicant__c).PDRmrks__c:''):'';
                    empObj.pdAuthorityName=applPD.size()>0?(applPD.get(appObj.LoanApplicant__c)!=null?applPD.get(appObj.LoanApplicant__c).AsgnTo__r.name:''):'';
                    empObj.pdDate=applPD.size()>0?(applPD.get(appObj.LoanApplicant__c)!=null?String.valueof(applPD.get(appObj.LoanApplicant__c).CmpltDt__c):''):'';
                    EmploymentList.add(empObj);
                    
                }
                
                
                
                return EmploymentList;
            }
            else {
                
                return EmploymentList;
            }
        }
        Catch (exception e) {
            system.debug('Line number'+e.getLinenumber());
            throw new AuraHandledException(e.getMessage());
        }
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