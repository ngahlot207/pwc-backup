public class CrifExecuteAPIRequestGeneratorHelper {
    
    
    public static Map<Id,LoanAppl__c> loanMapDeatils(Set<Id> loanIDs){
        
        Map<Id,LoanAppl__c> loanMap =new Map<Id,LoanAppl__c>();
        
        try{
            
            loanMap.putAll([SELECT Id, Name, OwnContriCash__c, OwnContriBank__c, SanLoanAmt__c, EffectiveROI__c, Product__c, City__c,
                            Loan_Tenure_Months__c, SchemeId__c, BrchCode__c, Stage__c, SubStage__c, RefinanceSaleAgreementAmt__c, 
                            RefinanceSaleAgreementDate__c, AllSellerBTNormMet__c, LoanApplSubDt__c, BranchTier__c, 
                            BalTransferFinaStatus__c, IsItRefinanceTransaction__c, IsitSellerBalTransferTransaction__c, 
                            PeriodSinceSaleAgreementExecuted__c, ProductSubType__c,BTLoanAmt__c,BTLoanOutstndVal__c,OthrBTFinancr__c,
                            ExistngFedFinaLoanAccNo__c,AssessedIncAppln__c,SchmCode__c,LoanPurpose__c, LoanPurposeId__c, ChannelCode__c,
                            ChannelName__c,PromCode__c,InsAmt__c,ReqLoanAmt__c,TotalIMDAmount__c,LeadSource__c,BrchName__c,
                            PaymentDoneInLast12MonthsBank__c,PaymentDoneInLast12MonthsCash__c,PaymentDoneInLast6MonthsBank__c,
                            PaymentDoneInLast6MonthsCash__c,ReqTenInMonths__c,TotalLoanAmtInclInsurance__c,Rate_Type_Floating_Flag__c, 
                            PropCat__c, LoginAcceptDate__c, ChanelNme__r.Name, ChanelNme__r.DSAConnId__c, ChanelNme__r.VCReferralId__c, 
                            RevisedPF__c, RevisedROI__c, Is_there_TypeA_devia__c, Is_there_TypeB_devia__c, BonceBTloanSesingtreql18mths__c, 
                            BonceBTloanSesingtreql12mths__c, BonceBTloanSesingless12mths__c, 
                            (SELECT Id, Repayment_Mode__c FROM Repayment_Account__r WHERE Is_Active__c = TRUE AND Type__c != NULL AND 
                             Type__c = 'REPAYMENT ACCOUNT' AND Repayment_Mode__c != NULL LIMIT 1), 
                            (SELECT Id, DocTyp__c, DocCatgry__c FROM Applicant_Document_Details__r 
                             WHERE DocCatgry__c = 'Collateral Documents' AND DocTyp__c = 'Property Papers' ), 
                            (SELECT Id,BTFinancier__c,SpecifyOtherBTFinancier__c, BTFinancierStatus__c, BTOriginalLoanAmt__c, BTLoanOutstandingValue__c FROM BT_Loans__r), 
                            (SELECT Id, ReportResult__c, Final_RCU_status_Reason__c FROM Cases__r 
                             WHERE RecordType.Name = 'RCU' ORDER BY CreatedDate DESC), 
                            (SELECT Id, MatchwithAccHolderName__c FROM Repayment_Acct_Verifications__r 
                             WHERE MatchwithAccHolderName__c = 'Yes'), 
                            (SELECT Id,LoanAppln__c, FundInESGPol__c, DealngIndstry__c, CharDiscrmtn__c, IsBorowrOrRelFFDir__c, 
                             FFDirRelIntrstAsPart__c, FFDirRelIntrstAsSH__c FROM Applicant_Regulatory__r ORDER BY CreatedDate DESC), 
                            (SELECT Id, LoanAppln__c, CheqBounceReason__c, InstrumentAmt__c, IMDStatus__c, BounceReasonID__c 
                             FROM Applicant_IMD__r ORDER BY CreatedDate ASC), 
                            (SELECT Id, Name, HunMatchSta__c, HunStaWheMatFound__c, HunterStatWhereMatchFound__c, IsLatest__c 
                             FROM Hunter_Verifications__r WHERE IsLatest__c = True), 
                            (SELECT Id, LoanAppln__c, NatureofProp__c, Pin_Code__c, PropType__c, DistFrmNearBrch__c, DistFrmSourceBrch__c, 
                             PropIdentified__c, ServiceableCity__c, PropSubTypeDesc__c, PropSubType__c, AllPropGnrlNrmsMet__c, 
                             AllPropSbtypNrmsMet__c, AveNetMnthlyRentalAsPerBankCredit__c, Appr_Cost_of_Const__c, 
                             Per_Sq_Ft_rate_Built_up_area__c, Per_Sq_Ft_rate_Land_area__c, No_of_Tenants__c, Property_Usage__c, 
                             Total_Prop_Cost__c, Land_Valu__c, Prop_Bui_up_ar__c, Approx_Age_of_Prop__c, Regi_Cost__c, Stamp_Duty__c, 
                             Land_Area__c, Stage_of_Construction__c, RecmndByTechVal__c, Total_estimate_as_per_architect_agreemen__c, 
                             Agrem_Value__c, Property_Carpet_area_Sq_Ft__c, Negative_Caution_Area__c, 
                             Improvement_construction_estimate_docum__c, Is_the_property_Multi_Tenanted__c, Built_up_area_Valu__c, 
                             Resi_Age__c, Is_the_title_clear_markateble__c, Prop_Owners__c, PropCat__c, City__c, 
                             Per_Sq_Ft_Approved_Cost_of_Const__c, ValuationToBeTakenAheadForCalculation__c, Total_Valua__c, 
                             ChangeRequiredInValuationAsPerPolicyNorm__c,CopyAddFrmExAdd__c FROM Applicant_Assets__r) , 
                            (SELECT Id, ApplType__c, Guarantor_is_bringing_in_SPDC__c FROM Applicants__r WHERE ApplType__c = 'G') 
                            FROM LoanAppl__c WHERE Id IN : loanIDs]);
            
        }catch(Exception ex){
            GlobalUtility.logMessage('Error', 'CrifExecuteAPIRequestGeneratorHelper', 'loanMapDeatils', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        
        return loanMap;
    }
    
    
    public static Map<Id, List<DedupeResponse__c>> dedupeResLAMap(Set<Id> loanIDs){
        
        Map<Id, List<DedupeResponse__c>> dedupeRes = new Map<Id, List<DedupeResponse__c>>();
        
        try{
            
            for(DedupeResponse__c dr : [SELECT Id, PastAppDate__c, LoanAppln__c, IsLatest__c, IntnlDeduRelevance__c, SecuritisationStatus__c, LoanAmount__c, SystemDPD__c, DPD__c FROM DedupeResponse__c  WHERE LoanAppln__c != NULL AND LoanAppln__c IN : loanIDs AND recordtype.Name = 'DedupeMatchCr']) {
                if(!dedupeRes.containsKey(dr.LoanAppln__c)) {
                    List<DedupeResponse__c> tempList = new List<DedupeResponse__c>();
                    tempList.add(dr);
                    dedupeRes.put(dr.LoanAppln__c, tempList);
                }
                else {
                    if(!dedupeRes.isEmpty() && dedupeRes.containsKey(dr.LoanAppln__c) && dedupeRes.get(dr.LoanAppln__c) != NULL) {
                        dedupeRes.get(dr.LoanAppln__c).add(dr);
                    }
                }
            }
            
            
        }catch(Exception ex){
            GlobalUtility.logMessage('Error', 'CrifExecuteAPIRequestGeneratorHelper', 'dedupeResLAMap', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        return dedupeRes;
    }
    
    
    public static Map<String, String> balTranFin(Set<String> btFin){
        
        Map<String, String> balTranFinMap = new Map<String, String>();
        
        try{
            
            for(BalTranFinancier__c btf : [SELECT Id, Name, CRIFCode__c FROM BalTranFinancier__c WHERE Name IN : btFin]) {
                if(btf.Name != NULL && btf.CRIFCode__c != NULL) {
                    balTranFinMap.put(btf.Name, btf.CRIFCode__c);
                }
            }
            
        }catch(Exception ex){
            GlobalUtility.logMessage('Error', 'CrifExecuteAPIRequestGeneratorHelper', 'balTranFin', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        return balTranFinMap;
    }
    
    public static Map<String, String> promCodes(Set<String> promCode){
        
        Map<String, String> promCodeMap = new Map<String, String>();
        
        try{
            
            for(PromoMapping__c temp : [SELECT Id, PromoDesc__c, PromoId__c FROM PromoMapping__c WHERE PromoDesc__c IN : promCode]) {
                if(!promCodeMap.containskey(temp.PromoDesc__c)) {
                    if(temp.PromoDesc__c != NULL && temp.PromoId__c != NULL) {
                        promCodeMap.put(temp.PromoDesc__c, temp.PromoId__c);
                    }
                }
            }
            
        }catch(Exception ex){
            GlobalUtility.logMessage('Error', 'CrifExecuteAPIRequestGeneratorHelper', 'promCodes', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        
        return promCodeMap;
    }
    
    public static Map<Id, List<Case>> appAssCase(Set<Id> applyAsstIds){
        
        Map<Id, List<Case>> appAssCaseMap=new Map<Id, List<Case>>();
        
        try{
            
            for(Case cs : [SELECT Id, WaiveCPV__c, ReportResult__c, Distance_from_Fedfina_Branch__c, ApplAssetId__c, Status, 
                           RecordType.Name, Total_Valuation_Land_Valuation_B__c, IsTheTitleClearNdMarketable__c, 
                           IsTSRwaived__c, Is_Vetting_waived__c, Property_Reconstruction_Cost__c, Approved_Plan_OC_available__c, 
                           Recommended_by_Technical_Valuer__c, Built_up_area_Valuation_In_Rs__c, Property_Built_up_area_Sq_Ft__c, 
                           Land_Valuation_in_Rs__c, Approx_Age_of_Property_in_Years__c, Residual_Age_in_Years__c, 
                           Land_Area_Sq_Ft__c, Plot_is_non_agricultural__c,Date_of_Report__c,DateofVisit__c
                           FROM Case WHERE ApplAssetId__c IN : applyAsstIds ORDER BY CreatedDate DESC]) {
                               
                               if(!appAssCaseMap.containsKey(cs.ApplAssetId__c)) {
                                   List<Case> tempList = new List<Case>();
                                   tempList.add(cs);
                                   appAssCaseMap.put(cs.ApplAssetId__c, tempList);
                               }
                               else {
                                   appAssCaseMap.get(cs.ApplAssetId__c).add(cs);
                               }
                           }
            
        }Catch(Exception ex){
            GlobalUtility.logMessage('Error', 'CrifExecuteAPIRequestGeneratorHelper', 'appAssCase', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        
        return appAssCaseMap;
    }
    
    public static Map<String, String> properSub(Set<String> properSub){
        
        Map<String, String> properSubMap = new Map<String, String>();
        
        try{
            
            for(PropSubTypeMstr__c temp : [SELECT Id, Value__c, Desc__c FROM PropSubTypeMstr__c WHERE Desc__c IN : properSub]) {
                if(temp.Desc__c != NULL && temp.Value__c != NULL) {
                    properSubMap.put(temp.Desc__c, temp.Value__c);
                }
            }
            
        }Catch(Exception ex){
            GlobalUtility.logMessage('Error', 'CrifExecuteAPIRequestGeneratorHelper', 'properSub', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        
        return properSubMap;
    }
    
    public static Map<String, String> loanPur(Set<String> loanPur){
        
        Map<String, String> loanPurMap = new Map<String, String>();
        
        try{
            
            for(LoanPurpose__c temp : [SELECT Id, Name, Value__c FROM LoanPurpose__c WHERE Id IN : loanPur]) {
                if(temp.Value__c != NULL) {
                    loanPurMap.put(temp.Id, temp.Value__c);
                }
            }
            
        }Catch(Exception ex){
            GlobalUtility.logMessage('Error', 'CrifExecuteAPIRequestGeneratorHelper', 'loanPur', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        
        return loanPurMap;
    }
    
    public static Map<String, BankBrchMstr__c> bankBranchMstr(Set<String> branchCds){
        
        Map<String, BankBrchMstr__c> bankBranchMstrMap = new Map<String, BankBrchMstr__c>();
        
        try{
            
            for(BankBrchMstr__c temp : [SELECT Id, BrchCode__c, OffcCode__c FROM BankBrchMstr__c WHERE BrchCode__c IN : branchCds]) {
                bankBranchMstrMap.put(temp.BrchCode__c, temp);
            }
            
        }Catch(Exception ex){
            GlobalUtility.logMessage('Error', 'CrifExecuteAPIRequestGeneratorHelper', 'bankBranchMstr', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        
        return bankBranchMstrMap;
    }
    
    public static Map<Id, Decimal> totOblig(Set<Id> applyIdList){
        
        Map<Id, Decimal> totObligMap = new Map<Id, Decimal>();
        
        try{
            
            for(BureauRespDtl__c brd : [SELECT Id, Applicant__c, EMI__c FROM BureauRespDtl__c WHERE Applicant__c IN : applyIdList AND Treatment__c = 'To continue - Obligate' AND EMI__c != NULL AND EMI__c != 0 AND Applicant__r.Type_of_Borrower__c != 'Non Financial']) {
                if(!totObligMap.containsKey(brd.Applicant__c)) {
                    totObligMap.put(brd.Applicant__c, brd.EMI__c.setScale(2));
                }
                else {
                    if(!totObligMap.isEmpty() && totObligMap.containsKey(brd.Applicant__c)) {
                        Decimal pervAmt = totObligMap.get(brd.Applicant__c);
                        totObligMap.put(brd.Applicant__c, pervAmt + brd.EMI__c.setScale(2));
                    }
                }
            }
            
        }Catch(Exception ex){
            GlobalUtility.logMessage('Error', 'CrifExecuteAPIRequestGeneratorHelper', 'totOblig', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        
        return totObligMap;
    }
    
    //Dedupe Responses
    public static Map<Id, List<DedupeResponse__c>> dedupeRes(Set<Id> applyIdList){
        
        Map<Id, List<DedupeResponse__c>> dedupeResMap = new Map<Id, List<DedupeResponse__c>>();
        
        try{
            
            for(DedupeResponse__c dr : [SELECT Id, IsLatest__c, RecordType.Name, FinalAssetClass__c, AUF__c, AUM__c, RejectionReason__c, LinkedUCIC__c, NPADate__c, UCID__c, IntrnlDeduperes__c, LoanType__c, SecuritisationStatus__c, Applicant__c, Dedupe__r.IsLatest__c, IntnlDeduRelevance__c, DPD__c, IsPDDpending__c, MatchSource__c FROM DedupeResponse__c WHERE Applicant__c IN : applyIdList ORDER BY CreatedDate DESC]) {
                if(!dedupeResMap.containsKey(dr.Applicant__c)) {
                    List<DedupeResponse__c> tempList = new List<DedupeResponse__c>();
                    tempList.add(dr);
                    dedupeResMap.put(dr.Applicant__c, tempList);
                }
                else {
                    if(!dedupeResMap.isEmpty() && dedupeResMap.containsKey(dr.Applicant__c) && dedupeResMap.get(dr.Applicant__c) != NULL) {
                        dedupeResMap.get(dr.Applicant__c).add(dr);
                    }
                }
            }
            
        }Catch(Exception ex){
            GlobalUtility.logMessage('Error', 'CrifExecuteAPIRequestGeneratorHelper', 'dedupeRes', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        
        return dedupeResMap;
    }
    
    
    public static Map<Id, List<DocDtl__c>> applyDoc(Set<Id> applyIdList){
        
        Map<Id, List<DocDtl__c>> applyDocMap = new Map<Id, List<DocDtl__c>>();
        
        try{
            
            for(DocDtl__c doc : [SELECT Id, DocCatgry__c, DocTyp__c, DocSubTyp__c, Appl__c, DocStatus__c FROM DocDtl__c WHERE Appl__c IN : applyIdList]) {
                if(!applyDocMap.containsKey(doc.Appl__c)) {
                    List<DocDtl__c> tempList = new List<DocDtl__c>();
                    tempList.add(doc);
                    applyDocMap.put(doc.Appl__c, tempList);
                }
                else {
                    if(!applyDocMap.isEmpty() && applyDocMap.containsKey(doc.Appl__c) && applyDocMap.get(doc.Appl__c) != NULL) {
                        applyDocMap.get(doc.Appl__c).add(doc);
                    }
                }
            }
            
        }Catch(Exception ex){
            GlobalUtility.logMessage('Error', 'CrifExecuteAPIRequestGeneratorHelper', 'applyDoc', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        
        return applyDocMap;
    }
    
    //ApplAssetJn__c
    public static Map<Id,Boolean> propertyOwner(Set<Id> applyIdList){
        
        Map<Id,Boolean> propertyOwnerMap =new Map<Id,Boolean>();
        
        try{
            
            for(ApplAssetJn__c asertJn:[Select id,ApplAsset__c,Appl__c from ApplAssetJn__c 
                                        Where ApplAsset__c!=null AND Appl__c IN:applyIdList]){
                                            
                                            if(!propertyOwnerMap.containsKey(asertJn.Appl__c)){
                                                propertyOwnerMap.put(asertJn.Appl__c,TRUE);
                                            }
                                            
                                        }
            
        }Catch(Exception ex){
            GlobalUtility.logMessage('Error', 'CrifExecuteAPIRequestGeneratorHelper', 'propertyOwner', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        
        return propertyOwnerMap;
    }
    
    //Applicant Id and List of BureauEnquiry__c records map
    public static Map<Id, List<BureauEnquiry__c>> consBurEnq(Set<Id> conBureauResIds){
        
        Map<Id, List<BureauEnquiry__c>> consBurEnqMap = new Map<Id, List<BureauEnquiry__c>>();
        
        try{
            
            for(BureauEnquiry__c abe : [SELECT Id, DateReported__c, EnqAmount__c, EnquiryPurpose__c, ReportingName__c, Bureau__r.Applicant__c FROM BureauEnquiry__c WHERE Bureau__c IN : conBureauResIds AND IsLatest__c = TRUE]) {
                if(consBurEnqMap.containsKey(abe.Bureau__r.Applicant__c)) {
                    consBurEnqMap.get(abe.Bureau__r.Applicant__c).add(abe);
                }
                else {
                    List<BureauEnquiry__c> abeList = new List<BureauEnquiry__c>();
                    abeList.add(abe);
                    consBurEnqMap.put(abe.Bureau__r.Applicant__c, abeList);
                }
            }
            
        }Catch(Exception ex){
            GlobalUtility.logMessage('Error', 'CrifExecuteAPIRequestGeneratorHelper', 'consBurEnq', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        
        return consBurEnqMap;
    }
    
    
    //Applicant Id and List of BureauRespDtl__c records map
    public static  Map<Id, List<BureauRespDtl__c>> consBurResDet(Set<Id> conBureauResIds,Set<Id> applyIdList){
        
        Map<Id, List<BureauRespDtl__c>> consBurResDetMap = new Map<Id, List<BureauRespDtl__c>>();
        
        try{
            
            for(BureauRespDtl__c abrd : [SELECT Id, Applicant__c, Bureau__r.Applicant__c, LoanAmount__c, CurrentOs__c, CloseDate__c,DisbursalDate__c, NatureOfLoan__c, Source__c, Name, Overdues__c, EMI__c, DateReportedCert__c,LastPayment__c, CreditLmt__c, Cashlmt__c, ActPayAmt__c, PayHis2__c, PayHis1__c, Value_of_col__c,Tenure__c, ROI__c, PaymentStartDate__c, PaymentEndDate__c, Bureau__c, Treatment__c,LoanCapacity__c, Applicant__r.Type_of_Borrower__c,WrittenOffAmtPrincipal__c,SettlementAmt__c,SuitFiledWillfulDft__c,WrittenOffAmtTotal__c,WrittenOffSettledStatus__c FROM BureauRespDtl__c WHERE RecordType.Name = 'Consumer Obligation' AND ((Source__c !='Manual' AND IsLatest__c = TRUE AND Bureau__c IN : conBureauResIds) OR (Source__c ='Manual' AND Applicant__r.Type_of_Borrower__c ='Financial' AND LoanApplication__r.Add_Another_Loan__c = 'Yes' AND Applicant__c IN : applyIdList))]) {
                if(consBurResDetMap.containsKey(abrd.Applicant__c)) {
                    consBurResDetMap.get(abrd.Applicant__c).add(abrd);
                }
                else {
                    List<BureauRespDtl__c> abrdList = new List<BureauRespDtl__c>();
                    abrdList.add(abrd);
                    consBurResDetMap.put(abrd.Applicant__c, abrdList);
                }
            }
            
        }Catch(Exception ex){
            GlobalUtility.logMessage('Error', 'CrifExecuteAPIRequestGeneratorHelper', 'consBurResDet', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        
        return consBurResDetMap;
    }
    
    //Applicant Id and List of BureauDemography__c records mapp
    public static  Map<Id, List<BureauDemography__c>> consBurDemog(Set<Id> conBureauResIds){
        
        Map<Id, List<BureauDemography__c>> consBurDemogMap = new Map<Id, List<BureauDemography__c>>();
        
        try{
            
            for(BureauDemography__c abd : [SELECT Id, Address1__c, Address2__c, Address3__c, Address4__c, Bureau__r.Applicant__c, Bureau__r.Name, AddressCategory__c, IdValue__c, IdType__c, ExpiryDate__c, Pincode__c, FirstName__c, LastName__c FROM BureauDemography__c WHERE Bureau__c IN : conBureauResIds AND IsLatest__c = TRUE]) {
                if(consBurDemogMap.containsKey(abd.Bureau__r.Applicant__c)) {
                    consBurDemogMap.get(abd.Bureau__r.Applicant__c).add(abd);
                }
                else {
                    List<BureauDemography__c> abdList = new List<BureauDemography__c>();
                    abdList.add(abd);
                    consBurDemogMap.put(abd.Bureau__r.Applicant__c, abdList);
                }
            }
            
        }Catch(Exception ex){
            GlobalUtility.logMessage('Error', 'CrifExecuteAPIRequestGeneratorHelper', 'consBurDemog', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        
        return consBurDemogMap;
    }
    
    //Applicant Id and List of BureauHeader__c records map
    public static  Map<Id, List<BureauHeader__c>> consBurHead(Set<Id> conBureauResIds){
        
        Map<Id, List<BureauHeader__c>> consBurHeadMap = new Map<Id, List<BureauHeader__c>>();
        
        try{
            
            for(BureauHeader__c abh : [SELECT Id, DateProceed__c, Bureau__r.Applicant__c FROM BureauHeader__c WHERE Bureau__c IN : conBureauResIds]) {
                if(consBurHeadMap.containsKey(abh.Bureau__r.Applicant__c)) {
                    consBurHeadMap.get(abh.Bureau__r.Applicant__c).add(abh);
                }
                else {
                    List<BureauHeader__c> abhList = new List<BureauHeader__c>();
                    abhList.add(abh);
                    consBurHeadMap.put(abh.Bureau__r.Applicant__c, abhList);
                }
            }
            
        }Catch(Exception ex){
            GlobalUtility.logMessage('Error', 'CrifExecuteAPIRequestGeneratorHelper', 'consBurHead', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        
        return consBurHeadMap;
    }
    
    //Applicant Id and List of Rank__c records map
    public static Map<Id, List<Rank__c>> rank(Set<Id> commBureauResIds){
        
        Map<Id, List<Rank__c>> rankMap = new Map<Id, List<Rank__c>>();
        
        try{
            
            for(Rank__c rnk : [SELECT Id, RankName__c, RankVal__c, ExclusionRes__c, BureauResponse__r.Applicant__c FROM Rank__c WHERE BureauResponse__c IN : commBureauResIds]) {
                if(rankMap.containsKey(rnk.BureauResponse__r.Applicant__c)) {
                    rankMap.get(rnk.BureauResponse__r.Applicant__c).add(rnk);
                }
                else {
                    List<Rank__c> rnkList = new List<Rank__c>();
                    rnkList.add(rnk);
                    rankMap.put(rnk.BureauResponse__r.Applicant__c, rnkList);
                }
            }
            
        }Catch(Exception ex){
            GlobalUtility.logMessage('Error', 'CrifExecuteAPIRequestGeneratorHelper', 'rank', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        
        return rankMap;
    }
    
    //Location Master
    public static Map<String, LocMstr__c> locatMaster(Set<String> cityIds){
        
        Map<String, LocMstr__c> locatMasterMap = new Map<String, LocMstr__c>();
        
        try{
            for(LocMstr__c locaVar : [SELECT Id, StateId__c, CityId__c, City__c, IsServiceable__c, State__c FROM LocMstr__c WHERE City__c IN : cityIds]) {
                locatMasterMap.put(locaVar.City__c, locaVar);
            }
            
        }Catch(Exception ex){
            GlobalUtility.logMessage('Error', 'CrifExecuteAPIRequestGeneratorHelper', 'locatMaster', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        
        return locatMasterMap;
    }
    //Master Data Map
    public static Map<String, List<Map<String, String>>> masterData(Set<String> masterDataKey,Set<String> custProfSel,Set<String> crifValSet){
        
        Map<String, List<Map<String, String>>> masterDataMap = new Map<String, List<Map<String, String>>>();
        
        try{
            
            for(MasterData__c temp : [SELECT Id, FinnoneCode__c, FinnoneVal__c, SalesforceCode__c, Name, Type__c, CRIFValue__c, CRIFCode__c from MasterData__c WHERE FinnoneVal__c IN : masterDataKey OR ID IN : custProfSel OR CRIFValue__c IN : crifValSet]) {
                if(String.isNotBlank(temp.Type__c)) {
                    if(!masterDataMap.containsKey(temp.Type__c)) {
                        List<Map<String, String>> mpVar = new List<Map<String, String>>();
                        Map<String, String> md = new Map<String, String>();
                        if(temp.Type__c != NULL && temp.Type__c.equalsIgnoreCase('Customer Profile Selection')) {
                            md.put(String.valueOf(temp.Id).toUpperCase(), temp.FinnoneCode__c);//Converting Id to Uppercase due to LAK-9870
                        }
                        else if(temp.Type__c != NULL && !temp.Type__c.equalsIgnoreCase('Address Type') && !temp.Type__c.equalsIgnoreCase('Selected Eligibility Program') && !temp.Type__c.equalsIgnoreCase('Negative Report reason') && !temp.Type__c.equalsIgnoreCase('Neighbour Reference Check') && !temp.Type__c.equalsIgnoreCase('Product Sub Type') && !temp.Type__c.equalsIgnoreCase('Branch Tier') && !temp.Type__c.equalsIgnoreCase('Funding Under ESG Policy') && !temp.Type__c.equalsIgnoreCase('Property Category') && !temp.Type__c.equalsIgnoreCase('Type of Accounts') && !temp.Type__c.equalsIgnoreCase('Final RCU Status Reason') && !temp.Type__c.equalsIgnoreCase('Final RCU Status') && !temp.Type__c.equalsIgnoreCase('FI Report Result') && !temp.Type__c.equalsIgnoreCase('Final RCU Hunter Status') && !temp.Type__c.equalsIgnoreCase('Hunter Status') && !temp.Type__c.equalsIgnoreCase('KYC Udyam Reg Cert') && !temp.Type__c.equalsIgnoreCase('Technical Report Result') && !temp.Type__c.equalsIgnoreCase('Vetting Report Result') && !temp.Type__c.equalsIgnoreCase('Legal Report Result') && !temp.Type__c.equalsIgnoreCase('TSR Report Result') && String.isNotBlank(temp.FinnoneVal__c) && String.isNotBlank(temp.FinnoneCode__c)) {
                            md.put(temp.FinnoneVal__c.toUpperCase(), temp.FinnoneCode__c);
                        }
                        else if(temp.Type__c != NULL && (temp.Type__c.equalsIgnoreCase('Address Type') || temp.Type__c.equalsIgnoreCase('Selected Eligibility Program') || temp.Type__c.equalsIgnoreCase('Negative Report reason') || temp.Type__c.equalsIgnoreCase('Neighbour Reference Check') || temp.Type__c.equalsIgnoreCase('Product Sub Type') || temp.Type__c.equalsIgnoreCase('Branch Tier') || temp.Type__c.equalsIgnoreCase('Funding Under ESG Policy') || temp.Type__c.equalsIgnoreCase('Property Category') || temp.Type__c.equalsIgnoreCase('Type of Accounts') || temp.Type__c.equalsIgnoreCase('Final RCU Status Reason') || temp.Type__c.equalsIgnoreCase('Final RCU Status') || temp.Type__c.equalsIgnoreCase('FI Report Result') || temp.Type__c.equalsIgnoreCase('Final RCU Hunter Status') || temp.Type__c.equalsIgnoreCase('Hunter Status') || temp.Type__c.equalsIgnoreCase('KYC Udyam Reg Cert') || temp.Type__c.equalsIgnoreCase('Technical Report Result') || temp.Type__c.equalsIgnoreCase('Vetting Report Result') || temp.Type__c.equalsIgnoreCase('Legal Report Result') || temp.Type__c.equalsIgnoreCase('TSR Report Result')) && String.isNotBlank(temp.CRIFValue__c) && String.isNotBlank(temp.CRIFCode__c)) {
                            md.put(temp.CRIFValue__c.toUpperCase(), temp.CRIFCode__c);
                        }
                        
                        mpVar.add(md);
                        masterDataMap.put(temp.Type__c, mpVar);
                    }
                    else {
                        Map<String, String> md = new Map<String, String>();
                        if(temp.Type__c != NULL && temp.Type__c.equalsIgnoreCase('Customer Profile Selection') && String.isNotBlank(temp.FinnoneCode__c)) {
                            md.put(String.valueOf(temp.Id).toUpperCase(), temp.FinnoneCode__c);//Converting Id to Uppercase due to LAK-9870
                        }
                        else if(temp.Type__c != NULL && !temp.Type__c.equalsIgnoreCase('Address Type') && !temp.Type__c.equalsIgnoreCase('Selected Eligibility Program') && !temp.Type__c.equalsIgnoreCase('Negative Report reason') && !temp.Type__c.equalsIgnoreCase('Neighbour Reference Check') && !temp.Type__c.equalsIgnoreCase('Product Sub Type') && !temp.Type__c.equalsIgnoreCase('Branch Tier') && !temp.Type__c.equalsIgnoreCase('Funding Under ESG Policy') && !temp.Type__c.equalsIgnoreCase('Property Category') && !temp.Type__c.equalsIgnoreCase('Type of Accounts') && !temp.Type__c.equalsIgnoreCase('Final RCU Status') && !temp.Type__c.equalsIgnoreCase('Final RCU Status Reason') && !temp.Type__c.equalsIgnoreCase('FI Report Result') && !temp.Type__c.equalsIgnoreCase('Final RCU Hunter Status') && !temp.Type__c.equalsIgnoreCase('Hunter Status') && !temp.Type__c.equalsIgnoreCase('KYC Udyam Reg Cert') && !temp.Type__c.equalsIgnoreCase('Technical Report Result') && !temp.Type__c.equalsIgnoreCase('Vetting Report Result') && !temp.Type__c.equalsIgnoreCase('Legal Report Result') && !temp.Type__c.equalsIgnoreCase('TSR Report Result') && String.isNotBlank(temp.FinnoneVal__c) && String.isNotBlank(temp.FinnoneCode__c)){
                            md.put(temp.FinnoneVal__c.toUpperCase(), temp.FinnoneCode__c);
                        }
                        else if(temp.Type__c != NULL &&(temp.Type__c.equalsIgnoreCase('Address Type') || temp.Type__c.equalsIgnoreCase('Selected Eligibility Program') || temp.Type__c.equalsIgnoreCase('Negative Report reason') || temp.Type__c.equalsIgnoreCase('Neighbour Reference Check') || temp.Type__c.equalsIgnoreCase('Product Sub Type') || temp.Type__c.equalsIgnoreCase('Branch Tier') || temp.Type__c.equalsIgnoreCase('Funding Under ESG Policy') || temp.Type__c.equalsIgnoreCase('Property Category') || temp.Type__c.equalsIgnoreCase('Type of Accounts') || temp.Type__c.equalsIgnoreCase('Final RCU Status') || temp.Type__c.equalsIgnoreCase('Final RCU Status Reason') || temp.Type__c.equalsIgnoreCase('FI Report Result') || temp.Type__c.equalsIgnoreCase('Final RCU Hunter Status') || temp.Type__c.equalsIgnoreCase('Hunter Status') || temp.Type__c.equalsIgnoreCase('KYC Udyam Reg Cert') || temp.Type__c.equalsIgnoreCase('Technical Report Result') || temp.Type__c.equalsIgnoreCase('Vetting Report Result') || temp.Type__c.equalsIgnoreCase('Legal Report Result') || temp.Type__c.equalsIgnoreCase('TSR Report Result')) && String.isNotBlank(temp.CRIFValue__c) && String.isNotBlank(temp.CRIFCode__c)) {
                            md.put(temp.CRIFValue__c.toUpperCase(), temp.CRIFCode__c);
                        }
                        masterDataMap.get(temp.Type__c).add(md);
                    }
                }
            }
            
            
        }Catch(Exception ex){
            GlobalUtility.logMessage('Error', 'CrifExecuteAPIRequestGeneratorHelper', 'masterData', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        return masterDataMap;
    }
    
    //LAK-6471 Start
    public static Map<Id,HunterVer__c> hunter(Set<Id> loanIDs){
        
        Map<Id,HunterVer__c> hunterMap =new Map<Id,HunterVer__c>();
        
        try{
            
            for(HunterVer__c hunterver:[Select id,LoanAplcn__c,HunMatchSta__c from HunterVer__c Where LoanAplcn__c  IN:loanIDs AND IsLatest__c =true Order by CreatedDate DESC]){
                
                if(!hunterMap.containsKey(hunterver.LoanAplcn__c)){
                    hunterMap.put(hunterver.LoanAplcn__c,hunterver);
                }
            }
            
        }Catch(Exception ex){
            GlobalUtility.logMessage('Error', 'CrifExecuteAPIRequestGeneratorHelper', 'hunter', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        
        return hunterMap;
    }
    
    public static Map<Id,Case> caseVal(Set<Id> loanIDs){
        
        Map<Id,Case> caseMap =new Map<Id,Case>();
        
        try{
            
            for(Case cs:[Select id,Loan_Application__c,Date_of_Report__c,RecordType.DeveloperName from Case 
                         where Loan_Application__c IN:loanIDs AND RecordType.DeveloperName='RCU' Order by CreatedDate DESC]){
                             
                             if(!caseMap.ContainsKey(cs.Loan_Application__c)){
                                 caseMap.put(cs.Loan_Application__c,cs);
                             }
                             
                         }
            
        }Catch(Exception ex){
            GlobalUtility.logMessage('Error', 'CrifExecuteAPIRequestGeneratorHelper', 'caseVal', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        
        return caseMap;
    }
    
    public Static Map<Id,UWDecision__c> UWDecision(Set<Id> loanIDs){
        
        Map<Id,UWDecision__c> UWDecisionMap=new Map<Id,UWDecision__c>();
        
        try{
            
            Set<String> decisionVal =new Set<String>{'Approved','Soft Approved'};
                for(UWDecision__c uwd:[Select id,LoanAppl__c, DecisionDt__c,Decision__c  from UWDecision__c Where LoanAppl__c IN:loanIDs
                                       AND Decision__c IN:decisionVal AND DecisionDt__c!=null Order By  DecisionDt__c ASC]){
                                           
                                           if(!UWDecisionMap.containsKey(uwd.LoanAppl__c)){
                                               UWDecisionMap.put(uwd.LoanAppl__c,uwd);
                                           }
                                       }
        }Catch(Exception ex){
            GlobalUtility.logMessage('Error', 'CrifExecuteAPIRequestGeneratorHelper', 'UWDecision', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        
        return UWDecisionMap;
    }
    //LAK-6471 End
    
    //LAK-9870 Start
    public Static Map<Id,String> applVerification(Set<Id> applyIdList){
        
        Map<Id,String> applVerificationMap =new Map<Id,String>();
        
        try{
            
            for(APIVer__c ver:[select id,RiskType__c,Appl__c,IsLatest__c from APIVer__c where IsLatest__c =true 
                               and RecordType.DeveloperName ='CrimeCheck' AND Appl__c IN:applyIdList]){
                                   
                                   if(!applVerificationMap.ContainsKey(ver.Appl__c)){
                                       applVerificationMap.put(ver.Appl__c,ver.RiskType__c);
                                   }
                               }
            
        }Catch(Exception ex){
            GlobalUtility.logMessage('Error', 'CrifExecuteAPIRequestGeneratorHelper', 'applVerification', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        
        return applVerificationMap;
    }
    //LAK-9870 End
    
    //LAK-9870 Start
    public static Map<String,String> applyKyc(List<ApplKyc__c> kyc){
        
        Map<String,String> kycMappingMap =new Map<String,String>();
        
        try{
            Map<String, String> kycTypeMapping = new Map<String, String>{
                'Driving License' => 'DL',
                    'Passport' => 'Passport',
                    'Aadhaar' => 'Aadhaar',
                    'Voter Id' => 'VoterId'
                    };
            
            for(ApplKyc__c applyKYC:kyc){
                
                if(applyKYC.kycDoc__c!=null && applyKYC.kycDoc__c=='Electricity Bill'){
                    
                    if(applyKYC.ElectAmtPayable__c!=null){
                        kycMappingMap.put('ElectAmtPayable',applyKYC.ElectAmtPayable__c);
                    }
                    
                    if(applyKYC.ElectBillAmt__c!=null){
                        kycMappingMap.put('ElectBillAmt',applyKYC.ElectBillAmt__c);
                    }
                    
                    if(applyKYC.ElectTotAmt__c!=null){
                        kycMappingMap.put('ElectTotAmt',applyKYC.ElectTotAmt__c);
                    }
                }
                
                if (applyKYC.Name_Match_Score__c != null && kycTypeMapping.containsKey(applyKYC.kycDoc__c)) {
                    kycMappingMap.put(kycTypeMapping.get(applyKYC.kycDoc__c), String.valueOf(applyKYC.Name_Match_Score__c));
                }
            }
            
        }Catch(Exception ex){
            GlobalUtility.logMessage('Error', 'CrifExecuteAPIRequestGeneratorHelper', 'applyKyc', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        
        return kycMappingMap;
    }
  
   //LAK-9870 End

    public static Map<String,String> docDetailsValue(List<DocDtl__c> docDtl,Map<Id, Boolean> fin44ADMap,Id appId){
        
        Map<String,String> docTypeMap =new Map<String,String>();
        
        try{
            
            Map<String,String> docTypeMapping =new Map<String,String>{
                'Last 3 month\'s payslip'=>'payslp3',
                    'Latest Year Form 16'=>'form16',
                    'Previous year Financials - P&L and BS'=>'prvYrFin',
                    'Latest year Financials - P&L and BS'=>'ltsYrFin',
                    'Previous Year Audit report along with schedules'=>'prvYrAud',
                    'Latest Year Audit report along with schedules'=>'ltsYrAud',
                    'Latest year ITR & computation'=>'lstYrITR',
                    'Previous year ITR & computation'=>'prvYrITR',
                    'Form 26AS'=>'form26AS',
                    'Udyam Registration Certificate'=>'docUdy',
                    'AOA'=>'aoa',
                    'Certificate of incorporation'=>'certifiIncorp',
                    'Certificate/ registration document issued by competent authorities'=>'certifiRegistrDoc',
                    'Electricity Bill'=>'electricityBill',
                    'GST certificate'=>'GSTcertificate',
                    'MOA'=>'moa',
                    'Patnership Deed'=>'patnershipDeed',
                    'Piped gas bill'=>'pipedGasBill',
                    'Post-paid mobile phone bill'=>'PostPaidMobBill',
                    'Shop and Establishment'=>'ShopEstablish',
                    'Telephone Bill'=>'telephoneBill',
                    'Trust/ Society Deed'=>'trustSocietyDeed',
                    'Water bill'=>'waterBill'
                    };
                        
                        for(DocDtl__c docdt:docDtl){
                            
                            if(docdt.DocCatgry__c != NULL && docdt.DocSubTyp__c != NULL){
                                
                                if(docdt.DocCatgry__c.equalsIgnoreCase('Income Documents')){
                                    
                                    if(docTypeMapping.containsKey(docdt.DocSubTyp__c) &&
                                       docdt.DocSubTyp__c!='Previous year Financials - P&L and BS' && 
                                       docdt.DocSubTyp__c!='Latest year Financials - P&L and BS'){
                                           
                                           docTypeMap.put(docTypeMapping.get(docdt.DocSubTyp__c),'Yes');
                                       }
                                    
                                    else if(docTypeMapping.containsKey(docdt.DocSubTyp__c) &&
                                            docdt.DocSubTyp__c=='Previous year Financials - P&L and BS' && 
                                            docdt.DocSubTyp__c=='Latest year Financials - P&L and BS'&&
                                            !fin44ADMap.isEmpty() && fin44ADMap.containsKey(appId) && fin44ADMap.get(appId) != NULL && fin44ADMap.get(appId) == TRUE){
                                                
                                                docTypeMap.put(docTypeMapping.get(docdt.DocSubTyp__c),'Yes');
                                            }
                                }
                                
                                else if(docdt.DocCatgry__c.equalsIgnoreCase('KYC Documents') && 
                                        docdt.DocTyp__c.equalsIgnoreCase('Principal Place of Business - Address Proof') &&
                                        docTypeMapping.containsKey(docdt.DocSubTyp__c)){
                                    
                                            docTypeMap.put(docTypeMapping.get(docdt.DocSubTyp__c),'Yes');
                                    
                                 }
                             }
                            
                        }
            
            
        }Catch(Exception ex){
            GlobalUtility.logMessage('Error', 'CrifExecuteAPIRequestGeneratorHelper', 'docDetailsValue', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        
        return docTypeMap;
    }
    
    //LAK-9870 Start
    public static Map<Id,ApplBankDetail__c> applBankDetail(Set<Id> applyIdList){
        
        Map<Id,ApplBankDetail__c> applBankDetailMap =new Map<Id,ApplBankDetail__c>();
        
        try{
            
            for(ApplBankDetail__c abd:[Select id,Type__c, SubType__c,StatementStatus__c, TransactionStartDate__c,TransactionEndDate__c,ApplBanking__c,
                                       ApplBanking__r.Appl__c from ApplBankDetail__c  where IsLatest__c =true AND Type__c ='Statement Details' AND SubType__c ='Statement Accounts' AND
                                      ApplBanking__r.Appl__c IN:applyIdList]){
                                          
                                          if(!applBankDetailMap.containsKey(abd.ApplBanking__c)){
                                              applBankDetailMap.put(abd.ApplBanking__c,abd);
                                          }
            }
            
        }Catch(Exception ex){
            GlobalUtility.logMessage('Error', 'CrifExecuteAPIRequestGeneratorHelper', 'applBankDetail', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        return applBankDetailMap;
    }
    //LAK-9870 END
                }