public class IMDChargesCalculation {

    public static void calculateIMD(Map<Id,LoanAppl__c> loans,Map<Id,Applicant__c> appl){
        if (loans.isEmpty()) return;

        Map<Id, String> loanBranchCodes = new Map<Id, String>();
        Set<String> products = new Set<String>();
        for (LoanAppl__c loan : loans.values()) { 
            loanBranchCodes.put(loan.Id, loan.BrchCode__c); 
            products.add(loan.Product__c);
        }

        Map<String, String> branchStates = getStateForBranches(new Set<String>(loanBranchCodes.values()));
        getIMDMasters(branchStates, loans,products);
        
    }

    private static Map<String, String> getStateForBranches(Set<String> branchCodes) {
        Map<String, String> branchStates = new Map<String, String>();

        for (LocBrchJn__c junction : [SELECT Location__r.State__c, Branch__r.BrchCode__c FROM LocBrchJn__c WHERE Branch__r.BrchCode__c IN :branchCodes]) {
            branchStates.put(junction.Branch__r.BrchCode__c, junction.Location__r.State__c);
        }
		system.debug('branchStates'+branchStates);
        return branchStates;
    }

    private static void getIMDMasters(Map<String, String> branchStates, Map<Id,LoanAppl__c> loans, Set<String> products) {
        Decimal imdAmount = 0 ;
        Decimal pfAmount = 0 ;
        Decimal pfInpercent = 0;
        List<IMDMstr__c> imdList = new List<IMDMstr__c>(); 

        imdList = [SELECT Id, State__c, Tax__c, PF__c, IMDAmt__c, Customer_Profile__c, EligibilityProgram__c, LeadSource__c, 
                    MaxLoanAmt__c, MinLoanAmt__c, PrdType__c, PromoCode__c, ChargeType__c 
                    FROM IMDMstr__c WHERE State__c =:branchStates.values() AND PrdType__c = :products and ChargeType__c != NULl];

        List<IMDMstr__c> imdMstrList = new List<IMDMstr__c>();
        Map<String, List<IMDMstr__c>> imdMstrMap = new Map<String, List<IMDMstr__c>>(); 
        for (IMDMstr__c imdMstr : imdList) {
            if (String.isNotBlank(imdMstr.State__c) && String.isNotBlank(imdMstr.PrdType__c)) {
                String key = imdMstr.State__c + '-' + imdMstr.PrdType__c+'-'+imdMstr.ChargeType__c;
                if (!imdMstrMap.containsKey(key)) {
                    imdMstrMap.put(key, new List<IMDMstr__c>());
                }
                imdMstrMap.get(key).add(imdMstr);
            }
        }
        system.debug('imdMstrMap'+imdMstrMap);
        Map<Id,LoanAppl__c> loansToBeUpdated = new Map<Id,LoanAppl__c>();
        Map<Id,Integer> loanToAssetCount = new Map<Id,Integer>();
        for (LoanAppl__c loan : loans.values()) { 
            imdAmount = roundNumberMethod(calculateIMD_PF(imdMstrMap.get(branchStates.get(loan.BrchCode__c)+'-'+loan.Product__c+'-'+'IMD'),'IMD',loan).value);
            ReturnChargeWrapper pfCalculation = calculateIMD_PF(imdMstrMap.get(branchStates.get(loan.BrchCode__c)+'-'+loan.Product__c+'-'+'PF'),'PF',loan);
            Decimal loanAMount = loan.SanLoanAmt__c!=Null || loan.InsAmt__c != null ?loan.TotalLoanAmtInclInsurance__c:loan.ReqLoanAmt__c;
            
            pfAmount = roundNumberMethod(pfCalculation.value);  
            pfInpercent = pfCalculation.pf;
            LoanAppl__c loanRecord = new LoanAppl__c();
            loanRecord = loan;
            loanRecord.IMDAmount__c = imdAmount != null ? imdAmount : loan.IMDAmount__c;
            loanRecord.IMD_GSTAmt__c = roundNumberMethod(calculateGSTAmount(loanRecord.IMDAmount__c));
            loanRecord.IMD_ActualAmt__c = roundNumberMethod(loanRecord.IMDAmount__c - calculateGSTAmount(loanRecord.IMDAmount__c));
            if(loan.RevisedPF__c != Null){
                loanRecord.PFAmount__c = ((loan.RevisedPF__c/100) * loanAMount) + ((loan.RevisedPF__c/100) * loanAMount)* Decimal.valueOf(System.Label.GST);
                if(loanRecord.PFAmount__c != null){
                    loanRecord.PFAmount__c = roundNumberMethod(loanRecord.PFAmount__c);
                }
            }else{
                loanRecord.PFAmount__c = pfAmount != null ? pfAmount : loan.PFAmount__c;
                loanRecord.PFInPercentage__c = pfInpercent;
            }   
            
            
            loanToAssetCount.put(loanRecord.Id,loanRecord.Applicant_Assets__r.size());
            loansToBeUpdated.put(loanRecord.Id,loanRecord);
        }
        system.debug('loan records ---> '+loansToBeUpdated);
        if (!loansToBeUpdated.isEmpty()) {
            upsert loansToBeUpdated.values();
        }
        
        upsertCharges(loansToBeUpdated,loanToAssetCount);
        
    }

    Public Class ReturnChargeWrapper{
        Decimal value;
        Decimal pf;

    }

    private static ReturnChargeWrapper calculateIMD_PF(List<IMDMstr__c> imdList , String ChargeType , LoanAppl__c loan){
        system.debug('imdList'+imdList);
        system.debug('Loan -->'+loan);
        Decimal returnValue = 0;
        ReturnChargeWrapper wrap = new ReturnChargeWrapper();
        wrap.value = 0;
        wrap.pf = 0;
        String eligibilityProgram = (loan.AssessedIncAppln__c) ? 'Assessed Income Program' : 'Regular Income Program';
        List<IMDMstr__c> basedOnLeadSource = new List<IMDMstr__c>();
        List<IMDMstr__c> basedOnPromotion = new List<IMDMstr__c>();
        List<IMDMstr__c> basedOnAmount = new List<IMDMstr__c>();
        List<IMDMstr__c> basedOnProfile = new List<IMDMstr__c>(); 
        List<IMDMstr__c> basedOnEligibilty = new List<IMDMstr__c>();
        Decimal loanAMount = loan.SanLoanAmt__c!=Null || loan.InsAmt__c != null ?loan.TotalLoanAmtInclInsurance__c:loan.ReqLoanAmt__c;
        system.debug('loanAMount ---'+loanAMount);
        if(imdList != null && !imdList.isEmpty() && imdList.size() == 1){
            if(imdList[0].ChargeType__c == ChargeType){
                system.debug('imdList ---> '+imdList[0]);
                returnValue = ChargeType == 'IMD' ? imdList[0].IMDAmt__c + ((imdList[0].IMDAmt__c * imdList[0].Tax__c)/100) :
                ChargeType == 'PF' ? ((imdList[0].PF__c/100) * loanAMount) + ((imdList[0].PF__c/100) * loanAMount)* imdList[0].Tax__c/100 : 0;
            }
            wrap.value = returnValue;
            wrap.pf = ChargeType=='PF'?imdList[0].PF__c:0;
            return wrap;
        }else{
            basedOnLeadSource = new List<IMDMstr__c>(); 
            if(imdList != null && !imdList.isEmpty()){ 
                for(IMDMstr__c imdRec : imdList){
                    if(imdRec.LeadSource__c == loan.LeadSource__c) basedOnLeadSource.add(imdRec);
                }
            }
            if(basedOnLeadSource != null && !basedOnLeadSource.isEmpty() && basedOnLeadSource.size() == 1){
                if(basedOnLeadSource[0].ChargeType__c == ChargeType){
                    system.debug('imdList basedOnLeadSource ---> '+basedOnLeadSource[0]);
                    returnValue = ChargeType == 'IMD' ? basedOnLeadSource[0].IMDAmt__c + ((basedOnLeadSource[0].IMDAmt__c * basedOnLeadSource[0].Tax__c)/100) :
                    ChargeType == 'PF' ? ((basedOnLeadSource[0].PF__c/100) * loanAMount) + ((basedOnLeadSource[0].PF__c/100) * loanAMount)* basedOnLeadSource[0].Tax__c/100 : 0;
                }
                wrap.value = returnValue;
                wrap.pf = ChargeType=='PF'?basedOnLeadSource[0].PF__c:0;
                return wrap;
            }
        }
        basedOnPromotion = new List<IMDMstr__c>();
        if(basedOnLeadSource != null && !basedOnLeadSource.isEmpty()){
            for(IMDMstr__c imdRec : basedOnLeadSource){
                if(imdRec.PromoCode__c == loan.PromotionId__c) basedOnPromotion.add(imdRec);
            }
        }
        if(basedOnPromotion != null && !basedOnPromotion.isEmpty() && basedOnPromotion.size() == 1){
            if(basedOnPromotion[0].ChargeType__c == ChargeType){
                system.debug('imdList basedOnPromotion---> '+basedOnPromotion[0]);
                returnValue = ChargeType == 'IMD' ? basedOnPromotion[0].IMDAmt__c + ((basedOnPromotion[0].IMDAmt__c * basedOnPromotion[0].Tax__c)/100) :
                ChargeType == 'PF' ? ((basedOnPromotion[0].PF__c/100) * loanAMount) + ((basedOnPromotion[0].PF__c/100) * loanAMount)* basedOnPromotion[0].Tax__c/100 : 0;
            }
            wrap.value = returnValue;
            wrap.pf = ChargeType=='PF'?basedOnPromotion[0].PF__c:0;
            return wrap;
        }
        basedOnAmount = new List<IMDMstr__c>();
        if(basedOnPromotion != null && !basedOnPromotion.isEmpty()){
            for(IMDMstr__c imdRec : basedOnPromotion){
                if(imdRec.MinLoanAmt__c <= loan.ReqLoanAmt__c) basedOnAmount.add(imdRec);
                else if(imdRec.MaxLoanAmt__c >= loan.ReqLoanAmt__c) basedOnAmount.add(imdRec);
            }
        }
        if(basedOnAmount != null && !basedOnAmount.isEmpty() && basedOnAmount.size() == 1){
            if(basedOnAmount[0].ChargeType__c == ChargeType){
                 system.debug('imdList basedOnAmount---> '+basedOnAmount[0]);
                returnValue = ChargeType == 'IMD' ? basedOnAmount[0].IMDAmt__c + ((basedOnAmount[0].IMDAmt__c * basedOnAmount[0].Tax__c)/100) :
                ChargeType == 'PF' ? ((basedOnAmount[0].PF__c/100) * loanAMount) + ((basedOnAmount[0].PF__c/100) * loanAMount)* basedOnAmount[0].Tax__c/100 : 0;
            }
            
            wrap.value = returnValue;
            wrap.pf = ChargeType=='PF'?basedOnAmount[0].PF__c:0;
            return wrap;
        }
        basedOnProfile = new List<IMDMstr__c>();
        if(basedOnAmount != null && !basedOnAmount.isEmpty()){
            for(IMDMstr__c imdRec : basedOnAmount){
                if(imdRec.Customer_Profile__c == loan.Applicant__r.CustProfile__c) basedOnProfile.add(imdRec);
            }
        }
        if(basedOnProfile != null && !basedOnProfile.isEmpty() && basedOnProfile.size() == 1){
            if(basedOnProfile[0].ChargeType__c == ChargeType){
                system.debug('imdList basedOnProfile---> '+basedOnProfile[0]);
                returnValue = ChargeType == 'IMD' ? basedOnProfile[0].IMDAmt__c + ((basedOnProfile[0].IMDAmt__c * basedOnProfile[0].Tax__c)/100) :
                ChargeType == 'PF' ? ((basedOnProfile[0].PF__c/100) * loanAMount) + ((basedOnProfile[0].PF__c/100) * loanAMount)* basedOnProfile[0].Tax__c/100 : 0;
            }
            wrap.value = returnValue;
            wrap.pf = ChargeType=='PF'?basedOnProfile[0].PF__c:0;
            return wrap;
        }
        basedOnEligibilty = new List<IMDMstr__c>();
        if(basedOnProfile != null && !basedOnProfile.isEmpty()){
        	for(IMDMstr__c imdRec : basedOnProfile){
            	if(imdRec.EligibilityProgram__c == eligibilityProgram) basedOnEligibilty.add(imdRec);
        	}
        }        
        if(basedOnEligibilty != null && !basedOnEligibilty.isEmpty() && basedOnEligibilty.size() == 1){ 
            if(basedOnEligibilty[0].ChargeType__c == ChargeType){
                system.debug('imdList basedOnEligibilty---> '+basedOnEligibilty[0]);
                returnValue = ChargeType == 'IMD' ? basedOnEligibilty[0].IMDAmt__c + ((basedOnEligibilty[0].IMDAmt__c * basedOnEligibilty[0].Tax__c)/100) :
                ChargeType == 'PF' ? ((basedOnEligibilty[0].PF__c/100) * loanAMount) + ((basedOnEligibilty[0].PF__c/100) * loanAMount)* basedOnEligibilty[0].Tax__c/100 : 0;
            }
            wrap.value = returnValue;
            wrap.pf = ChargeType=='PF'?basedOnEligibilty[0].PF__c:0;
            return wrap;
        }
        wrap.value = 0;
        wrap.pf = 0;
        return wrap;  
    }

    private static Decimal roundNumberMethod(decimal amount){
        Decimal roundedNumber = Math.round(amount);
        return roundedNumber;
    }

    private static void upsertCharges(Map<Id,LoanAppl__c> loans,Map<Id,Integer> loanToAssetCount){ 
        if (loans != null) {
            Integer aboveAmtValue = Integer.valueOf(System.Label.Above5LakhCharges);
            Integer belowAmtValue = Integer.valueOf(System.Label.Below5LakhCharges);
            Integer amtValueCheck = Integer.valueOf(System.Label.RequestedLoanAmount);
            List<LonaApplCharges__c> loanChargeUpdateList = new List<LonaApplCharges__c>();
            Map<String, String> chargeCodeMap = new Map<String, String>{
                'PFChargeCodeId' => System.Label.PFChargeCodeId, 
                'CersaiChargeCodeId' => System.Label.CersaiChargeCodeId
            };

            List<LonaApplCharges__c> loanCharges = [SELECT Id, Name, Amount__c, ActualAmt__c,GST_Amount__c, Processing_Fees__c, ChargeCodeDesc__c, ChargeCodeID__c, LoanApplication__c,PF__c 
                                                    FROM LonaApplCharges__c WHERE ChargeCodeID__c IN :chargeCodeMap.values() AND LoanApplication__c =: loans.keySet()];

            Map<String,LonaApplCharges__c> chargesMap = new Map<String,LonaApplCharges__c>();
            for(LonaApplCharges__c charge : loanCharges){
                String key = charge.LoanApplication__c + '-' +charge.ChargeCodeID__c;
                chargesMap.put(key, charge);
                /*if (!chargesMap.containsKey(key)) {
                    chargesMap.put(key, charge);
                }
                chargesMap.get(key).add(charge);*/
            }

            for(LoanAppl__c loanAppl : loans.values()){
                Integer applAssetCount = loanToAssetCount.get(loanAppl.Id);
                Decimal cersaiAmount = 0;
                Decimal loanAmount = loanAppl.SanLoanAmt__c!=Null || loanAppl.InsAmt__c != null?loanAppl.TotalLoanAmtInclInsurance__c:loanAppl.ReqLoanAmt__c;
                if(loanAmount > amtValueCheck){
                    cersaiAmount = (aboveAmtValue * applAssetCount);  
                }else{
                    cersaiAmount = (belowAmtValue * applAssetCount); 
                }
                if(chargesMap.containsKey(loanAppl.Id+'-'+chargeCodeMap.get('PFChargeCodeId'))){
                    LonaApplCharges__c updatedLoanCharge = chargesMap.get(loanAppl.Id+'-'+chargeCodeMap.get('PFChargeCodeId'));
                    updatedLoanCharge.Amount__c = loanAppl.PFAmount__c ;
                    updatedLoanCharge.PF__c = loanAppl.PFInPercentage__c;
                    updatedLoanCharge.GST_Amount__c = roundNumberMethod(calculateGSTAmount(loanAppl.PFAmount__c));
                    updatedLoanCharge.ActualAmt__c = roundNumberMethod(loanAppl.PFAmount__c - calculateGSTAmount(loanAppl.PFAmount__c));                    
                    updatedLoanCharge.Processing_Fees__c = loanAppl.PFAmount__c ;
                    updatedLoanCharge.Revised_PF__c = loanAppl.RevisedPF__c;
                    loanChargeUpdateList.add(updatedLoanCharge); 
                }else{
                    LonaApplCharges__c pfLoanCharge = new LonaApplCharges__c(
                        LoanApplication__c = loanAppl.Id,
                        ChargeCodeID__c = System.Label.PFChargeCodeId,
                        ChargeCodeDesID__c = System.Label.PFChargeCodeId,
                        ChargeCodeDesc__c = System.Label.PFChargeCodeDesc,
                        Amount__c = loanAppl.PFAmount__c ,
                        GST_Amount__c = roundNumberMethod(calculateGSTAmount(loanAppl.PFAmount__c)),
                        ActualAmt__c = roundNumberMethod(loanAppl.PFAmount__c - calculateGSTAmount(loanAppl.PFAmount__c)),
                        Processing_Fees__c = loanAppl.PFAmount__c,
                        PF__c = loanAppl.PFInPercentage__c,
                        Revised_PF__c = loanAppl.RevisedPF__c
                        );
                    loanChargeUpdateList.add(pfLoanCharge);
                    
                }if(chargesMap.containsKey(loanAppl.Id+'-'+chargeCodeMap.get('CersaiChargeCodeId'))){
                    LonaApplCharges__c updatedLoanCharge = chargesMap.get(loanAppl.Id+'-'+chargeCodeMap.get('CersaiChargeCodeId'));
                    updatedLoanCharge.Amount__c = cersaiAmount + cersaiAmount * Decimal.valueOf(System.Label.GST) ;
                    updatedLoanCharge.ActualAmt__c = cersaiAmount;
                    updatedLoanCharge.GST_Amount__c = cersaiAmount * Decimal.valueOf(System.Label.GST);
                    loanChargeUpdateList.add(updatedLoanCharge);
                    //updateCersaiCharge(updatedLoanCharge[0], loanAppl);
                }else{
                    
                    LonaApplCharges__c cersaiLoanCharge = new LonaApplCharges__c(
                        LoanApplication__c = loanAppl.Id,
                        ChargeCodeID__c = System.Label.CersaiChargeCodeId,
                        ChargeCodeDesID__c = System.Label.CersaiChargeCodeDesID,
                        ChargeCodeDesc__c = System.Label.CersaiChargeCodeDesc,
                        Amount__c = cersaiAmount + cersaiAmount * Decimal.valueOf(System.Label.GST),
                        ActualAmt__c = cersaiAmount,
                        GST_Amount__c = cersaiAmount * Decimal.valueOf(System.Label.GST)
                        );
                        //updateCersaiCharge(cersaiLoanCharge, loanAppl);
    
                    loanChargeUpdateList.add(cersaiLoanCharge);
                }
            }
                       
            if (!loanChargeUpdateList.isEmpty()) { 
                upsert loanChargeUpdateList;
            }
        }
    }

    private static void updateCersaiCharge(LonaApplCharges__c updatedLoanCharge, LoanAppl__c loan) {
        Decimal amount = PFCalculationForSanAmount.amountCalculation_Cersai(loan);
        updatedLoanCharge.Amount__c = amount + (amount * Decimal.valueOf(System.Label.GST));
    }
    
    public static Decimal calculateGSTAmount(Decimal amt){
        Decimal gstAmount = 0 ;
        Decimal gstPercentage = Decimal.valueOf(System.Label.GST);
        Decimal ActualAmount = (amt*100)/(100+ (gstPercentage*100));
        gstAmount  = amt - ActualAmount;
        return gstAmount;
    }

}