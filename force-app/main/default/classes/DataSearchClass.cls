public without sharing class DataSearchClass {
    
    @AuraEnabled(cacheable=true)  
    public static User getRMNameDetails(String rmNameId){
        return [SELECT Id,Name FROM User WHERE Id=:rmNameId];
    } 
    
    @AuraEnabled(cacheable=true) 
    public static List<String> getProducts(String rmName){
        TeamHierarchy__c TH = [SELECT Id,Product_Type__c FROM TeamHierarchy__c WHERE Employee__c =: rmName AND IsActive__c=True LIMIT 1]; 
        List<String> productValues = new List<String>();
        productValues =TH.Product_Type__c.split(';');
        return productValues;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> getProductMappings(String product){
        Set<String> productSubTypes = new Set<String>();
        List<ProdMap__c> productMaps = [SELECT Id,ProdSubType__c,ProdType__c FROM ProdMap__c WHERE ProdType__c=:product];
        for(ProdMap__c p : productMaps ){
            productSubTypes.add(p.ProdSubType__c);
        }
        List<String> subTypes = new List<String>(productSubTypes);
        return subTypes;
    } 
    
    @AuraEnabled(cacheable=true)
    public static List<String> getPromotions(String product){
        Set<String> promotions = new Set<String>();
        List<PromoMapping__c> pro = [SELECT Id, PromoDesc__c FROM PromoMapping__c WHERE ProductType__c =:product];
        for(PromoMapping__c p : pro ){
            promotions.add(p.PromoDesc__c);
        }
        List<String> proMaps = new List<String>(promotions);
        return proMaps;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Object> getData(String fields,String objectName,String inputField,String likeFilter,String field1,String filter1,String field2,String filter2){
        system.debug('getData:::::::::'+field2+'filter2:::::::'+filter2);
        String fieldsToQuery = 'SELECT Id, ';
        if(string.isNotBlank(fields)){
            fieldsToQuery = fieldsToQuery + fields;
        }
        String query = fieldsToQuery + ' FROM '+ objectName;
        
        if(String.isNotBlank(likeFilter)) {
            query +=' WHERE '+ inputField + ' LIKE ' + '\'%' + String.escapeSingleQuotes(likeFilter.trim()) + '%\' ';
        }
        if(String.isNotBlank(likeFilter) && String.isNotBlank(filter1)) {
            query += ' AND '+field1+' = \''+ filter1 + '\'';
        }
        if(!String.isNotBlank(likeFilter) && String.isNotBlank(filter1)) {
            query += ' WHERE '+field1+' = \''+ filter1 + '\''; 
        }
        //Code Changed Earlier "Else If" condition Now only "If"  (changes by Harish)
        else if(String.isNotBlank(filter1) && String.isNotBlank(filter2)) {
            system.debug('query filter1 and filter2:::::::::::'+filter1);
            query += ' AND '+field2+' = \''+ filter2 + '\'';
            system.debug('query:::::::::::'+query);
        }
        else if(String.isNotBlank(filter2)) {
            query += ' AND '+' '+field2+' = \''+ filter2 + '\'';
        }
        
        system.debug('query>>>>>>>>>'+query);        
        return Database.query(query);
    }
    @AuraEnabled(cacheable=true)
    public static Boolean getCityFromLocationMaster(String Cityname) {
        Boolean cityFound = false;
        system.debug('city---'+Cityname);
        // Retrieve the Location record
        List<LocMstr__c> locationRecord = [SELECT City__c, Id, State__c, Name FROM LocMstr__c where City__c=:Cityname];
        if(!locationRecord.isEmpty()){
            cityFound = true;
        } 
        system.debug('locationRecord---'+locationRecord);
        
        return cityFound;
    }
    
    
    @AuraEnabled(cacheable=true)
    public static Boolean getChannelFromDSABranch(String Channelname) {
        Boolean channelFound = false;
        system.debug('Channelname---'+Channelname);
        // Retrieve the Location record
        List<DSABrchJn__c> channelRecord = [SELECT Account__r.Id,Account__r.Name FROM DSABrchJn__c where Account__r.Name=:Channelname];
        if(!channelRecord.isEmpty()){
            channelFound = true;
        } 
        system.debug('channelRecord---'+channelRecord);
        
        return channelFound;
    }
    
    @AuraEnabled(cacheable=true) 
    public static LoanAppl__c getLoanApplication(String recordId){
        
        
        LoanAppl__c loanApplctn = [SELECT Id FROM LoanAppl__c WHERE Id =: recordId limit 1]; 
        
        return loanApplctn;
    }
    @AuraEnabled
    public static SchMapping__c getSchemeDetails(String schemeId){
        return [SELECT Id,Name, MaxAmtFin__c,MinAmtFin__c, IsBT__c,MaxTenure__c,MinTenure__c FROM SchMapping__c WHERE Id=:schemeId];
    } 
    @AuraEnabled
    public static Account getAccountDetails(String channelCode){
        return [SELECT Id,Name, DSAConnId__c, VCReferralCode__c FROM Account WHERE Id=:channelCode];
    } 
    
    @AuraEnabled
    public static Map<String, String> getRelationShipDetails(String loanRecordId, String coApplicantType){
        Map<String, String> relationShipMap = new Map<String, String>();
        String applicantType = 'INDIVIDUAL';
        coApplicantType = String.isNotBlank(coApplicantType) ? coApplicantType : 'INDIVIDUAL';
        LoanAppl__c loanApplctn = [SELECT Id, Applicant__c, Applicant__r.Constitution__c FROM LoanAppl__c WHERE Id =: loanRecordId limit 1]; 
        if(loanApplctn!=null){
            if(String.isNotBlank(loanApplctn.Applicant__r.Constitution__c)){
                if(loanApplctn.Applicant__r.Constitution__c !='INDIVIDUAL'){
                    applicantType = 'NON INDIVIDUAL';
                }else{
                    applicantType = 'INDIVIDUAL';
                }
            }else{
                applicantType = 'INDIVIDUAL';
            }
        }
        List<Relationship__c> relationRecords = new List<Relationship__c>();
        relationRecords = [Select Id, Name, Key__c from Relationship__c where ApplType__c = :applicantType AND CoApplType__c =:coApplicantType];
        if(!relationRecords.isEmpty()){
            for(Relationship__c rr: relationRecords){
                relationShipMap.put(rr.Key__c, rr.Name);
            }
        }
        return relationShipMap ;
    } 
    
    @AuraEnabled(cacheable=true) 
    public static List<ApplAddr__c> getAddressData(String applicationId){
        List<ApplAddr__c> applicantAddressesList = new List<ApplAddr__c>();
        List<Applicant__c> applicantList = new List<Applicant__c>();
        applicantList = [Select Id, LoanAppln__c, (Select Id, MailAddr__c from Applicant_Addresses__r) from Applicant__c where ApplType__c IN ('P','G','C') AND LoanAppln__c!=null AND LoanAppln__c=:applicationId];
        if(!applicantList.isEmpty()){
            for (Applicant__c applicant : applicantList) {
                if (applicant.Applicant_Addresses__r != null && !applicant.Applicant_Addresses__r.isEmpty()) {
                    applicantAddressesList.addAll(applicant.Applicant_Addresses__r);
                }
            }
        }
        
        return applicantAddressesList;
    }
    
    /*@AuraEnabled(cacheable=true) 
public static boolean samePrinlPlaceforBCheckBox(string applicationId ){
List<Applicant__c> applicantcheck = new List<Applicant__c>();
applicantcheck = [Select Id, LoanAppln__c,Same_as_Principal_place_for_business__c from Applicant__c where  LoanAppln__c!=null AND LoanAppln__c=:applicationId];

return applicantcheck[0].Same_as_Principal_place_for_business__c;

}*/
    
    
    @AuraEnabled
    public static void PrinlPlaceforBCheckBox(string applicationId, boolean ischeckedvalue ){
        system.debug('ischeckedvalue==>'+ischeckedvalue);
        system.debug('applicationId==>'+applicationId);
        if(!string.isblank(applicationId)){
            List<Applicant__c> applicantcheck = [Select Id, LoanAppln__c,Same_as_Principal_place_for_business__c from Applicant__c where  LoanAppln__c!=null AND LoanAppln__c=:applicationId];
            
            List<Applicant__c> applicantcheckUpdate = new List<Applicant__c>(); 
            if(!applicantcheck.isEmpty()){
                for(Applicant__c record: applicantcheck){
                    Applicant__c appl = new Applicant__c();
                    appl.id=record.id;
                    appl.Same_as_Principal_place_for_business__c=ischeckedvalue;
                    applicantcheckUpdate.add(appl);
                }
            }
            if(applicantcheckUpdate.size()>0){
                update applicantcheckUpdate;
            } 
        }
    }
    
    @AuraEnabled
    public static string getCityIdFromLocMstr(String cityName){
        return [SELECT Id FROM LocMstr__c where City__c=: cityName LIMIT 1].Id;
    }
    
    @auraEnabled
    public static LeadEmiOutputDataWrpr getLeadEmiData(LeadEmiInputDataWrpr inputdata){
        LeadEmiOutputDataWrpr returnData = new LeadEmiOutputDataWrpr();
        if(inputdata != null && inputdata.loanAmount != null && inputdata.loanTenure != null && inputdata.leadROI != null){
            Decimal leadEmiValue = KFSForLoanNdAdvController.calculateEMI(inputdata.loanAmount, inputdata.leadROI, inputdata.loanTenure).round(RoundingMode.HALF_UP);
            if(leadEmiValue != null){
                returnData.emi = leadEmiValue;
            }
        }
        if(inputdata != null && inputdata.totalNetMonthlyIncome != null){	
            String query = 'SELECT Id, FOIRValue__c,Max__c, Min__c,NMIBandValue__c,Type__c FROM MasterData__c WHERE ';
            List<String> types = new List<String> {'NMI Band', 'FOIR'};
                
                // Join the types into a single string for the IN clause
                String typeList = String.join(types, '\',\'');
            
            query +=
                '((Min__c <= ' +
                inputdata.totalNetMonthlyIncome +
                ' OR Min__c = null) AND (Max__c > ' +
                inputdata.totalNetMonthlyIncome +
                ' OR Max__c = null) AND Type__c IN (\'' + typeList + '\'))';
            system.debug('master data query ' + query);
            // Now execute the query
            List<MasterData__c> mstrDataList = Database.query(query);
            if(mstrDataList != null && !mstrDataList.isEmpty()){
                for(MasterData__c msrData : mstrDataList){
                    if(msrData.Type__c != null && msrData.Type__c == 'NMI Band'){
                        returnData.maxLoanBasisNMIBand = Decimal.valueof(msrData.NMIBandValue__c);
                    }else if(msrData.Type__c != null && msrData.Type__c == 'FOIR'){
                        returnData.applicableFOIR = Decimal.valueof(msrData.FOIRValue__c);
                    }
                }
            }
            if(inputdata.monthlyObligations != null && returnData != null && returnData.applicableFOIR != null){
                returnData.maxEligibleEmi = (inputdata.totalNetMonthlyIncome * returnData.applicableFOIR) - inputdata.monthlyObligations;
                if(returnData.maxEligibleEmi != null && inputdata.loanTenure != null && returnData.emi != null){
                    Decimal leadEmiValueNew;
                    if(inputdata.loanTenure > 60){
                        leadEmiValueNew = KFSForLoanNdAdvController.calculateEMI(inputdata.loanAmount, inputdata.leadROI, 60).round(RoundingMode.HALF_UP);
                    }else {
                        leadEmiValueNew = KFSForLoanNdAdvController.calculateEMI(inputdata.loanAmount, inputdata.leadROI, inputdata.loanTenure).round(RoundingMode.HALF_UP);
                    }
                    system.debug('maxEligibleEmi ' + returnData.maxEligibleEmi);
                    system.debug('leadEmiValueNew ' + leadEmiValueNew);
                    returnData.maxLoanBasisFOIR = (returnData.maxEligibleEmi / leadEmiValueNew) * 100000;
                    //round(RoundingMode.HALF_UP)
                    // returnData.maxLoanBasisFOIR = 0.00;
                }
                if(returnData.maxLoanBasisFOIR != null && returnData.maxLoanBasisNMIBand != null && returnData.maxLoanBasisNMIBand > returnData.maxLoanBasisFOIR){
                    returnData.maxLoanEligibility = returnData.maxLoanBasisFOIR;
                }else if(returnData.maxLoanBasisFOIR != null && returnData.maxLoanBasisNMIBand != null && returnData.maxLoanBasisNMIBand < returnData.maxLoanBasisFOIR){
                    returnData.maxLoanEligibility = returnData.maxLoanBasisNMIBand;
                }
            }
        }
        
        if(inputdata.leadId != null){
            Lead lead = new Lead();
            lead.Id = inputdata.leadId;
            lead.SalaryexcVarPay__c = inputdata.salaryExclVarPay != null ? inputdata.salaryExclVarPay : 0.00;
            lead.AvgVarPay__c = inputdata.avgVarPay != null ? inputdata.avgVarPay : 0.00;
            lead.DeductionsincluIncmeTax__c = inputdata.dedInclIncmeTax != null ? inputdata.dedInclIncmeTax : 0.00;
            lead.NetTakeHomeSalary__c = inputdata.netTakeHomeSalery != null ? inputdata.netTakeHomeSalery : 0.00;
            lead.AvgAdditionalIncome__c = inputdata.avgAdditionalIncome != null ? inputdata.avgAdditionalIncome : 0.00;
            lead.MonthsConsultingincomepostTax__c = inputdata.consuIncme != null ? inputdata.consuIncme : 0.00;
            lead.TotalNetMonthlyIncomeNMI__c = inputdata.totalNetMonthlyIncome != null ? inputdata.totalNetMonthlyIncome : 0.00;
            lead.DeclaredMonthlyObligation__c = inputdata.monthlyObligations != null ? inputdata.monthlyObligations : 0.00;
            lead.EMI__c = returnData.emi != null ? returnData.emi : 0;
            lead.ApplicableFOIR__c = returnData.applicableFOIR != null ? returnData.applicableFOIR : 0;
            lead.MaxEligibleEMI__c = returnData.maxEligibleEmi != null ? returnData.maxEligibleEmi : 0;
            lead.MaxLoanBasisFOIR__c = returnData.maxLoanBasisFOIR != null ? returnData.maxLoanBasisFOIR : 0;
            lead.MaxLoanBasisNMIBand__c = Integer.valueof(returnData.maxLoanBasisNMIBand) != null ? Integer.valueof(returnData.maxLoanBasisNMIBand) : 0;
            lead.MaxLoanEligibility__c = returnData.maxLoanEligibility != null ? returnData.maxLoanEligibility : 0;
            update lead;
        }
        if(returnData != null){
            return returnData;
        }
        return null;
    }
    @auraEnabled
    public static LeadSepEmiOutputDataWrpr getLeadSepEmiData(LeadSepEmiInputDataWrpr inputdata){
        LeadSepEmiOutputDataWrpr returnData = new LeadSepEmiOutputDataWrpr();
        if(inputdata != null){
            if(inputdata.loanAmount != null && inputdata.loanTenure != null && inputdata.leadROI != null){
                Decimal leadEmiValue = KFSForLoanNdAdvController.calculateEMI(inputdata.loanAmount, inputdata.leadROI, inputdata.loanTenure).round(RoundingMode.HALF_UP);
                if(leadEmiValue != null){
                    returnData.emi = leadEmiValue;
                }
            }
            //system.debug('')
            Integer multiplier;
            if(inputdata.qualificationValue != null && (inputdata.qualificationValue == 'DOCBM' || inputdata.qualificationValue == 'DOCB' || inputdata.qualificationValue == 'DOC' || inputdata.qualificationValue == 'DOCS')){
                multiplier = 4;
            }else{
                multiplier = 2;
            }
            system.debug('multiplier ' + multiplier);
            if(inputdata.patValue != null && inputdata.depreciation != null && inputdata.intrstExp != null && inputdata.OtheIcnme != null){
                Decimal patMultiplier = (multiplier * inputdata.patValue);
                system.debug('patMultiplier ' + patMultiplier);
                Decimal overallIncome = (patMultiplier + inputdata.depreciation + inputdata.intrstExp + inputdata.OtheIcnme);
                system.debug('overallIncome ' + overallIncome);
                Decimal monthlyIncme = (overallIncome / 12);
                system.debug('monthlyIncme ' + monthlyIncme);
                Decimal eligibleEMI = (monthlyIncme - inputdata.monthlyObli);
                system.debug('eligibleEMI ' + eligibleEMI);
                //Decimal eligibleEMI = null;
                Decimal leadEmiValueNew;
                if(inputdata.loanTenure > 60 && (inputdata.qualificationValue != 'CA' || inputdata.qualificationValue != 'CS')){
                    leadEmiValueNew = KFSForLoanNdAdvController.calculateEMI(inputdata.loanAmount, inputdata.leadROI, 60).round(RoundingMode.HALF_UP);
                }else if(inputdata.loanTenure > 48 && (inputdata.qualificationValue == 'CA' || inputdata.qualificationValue == 'CS')){
                    leadEmiValueNew = KFSForLoanNdAdvController.calculateEMI(inputdata.loanAmount, inputdata.leadROI, 48).round(RoundingMode.HALF_UP);
                }else {
                    leadEmiValueNew = KFSForLoanNdAdvController.calculateEMI(inputdata.loanAmount, inputdata.leadROI, inputdata.loanTenure).round(RoundingMode.HALF_UP);
                }
                system.debug('leadEmiValueNew ' + leadEmiValueNew);
                Decimal val;
                if(leadEmiValueNew != null){
                    val = (eligibleEMI / leadEmiValueNew);
                }
                if(val > 30){
                    returnData.netProfit = 30;
                }else{
                    returnData.netProfit = val;
                }
                Integer multiplierTwo;
                if(inputdata.qualificationValue == null){
                    multiplierTwo = 0;
                }else if((inputdata.qualificationValue == 'DOCTOR(BDS, MDS)' || inputdata.qualificationValue == 'DOCTOR(BAMS, BHMS, BUMS)' || inputdata.qualificationValue == 'DOCTOR' || inputdata.qualificationValue == 'DOCTOR(MD,MBBS,Surgeons,Specialists)') && inputdata.grossRecipts != null && inputdata.grossRecipts <= 50000000){
                    multiplierTwo = 2;
                }else if((inputdata.qualificationValue == 'DOCTOR(BDS, MDS)' || inputdata.qualificationValue == 'DOCTOR(BAMS, BHMS, BUMS)' || inputdata.qualificationValue == 'DOCTOR' || inputdata.qualificationValue == 'DOCTOR(MD,MBBS,Surgeons,Specialists)') && inputdata.grossRecipts != null && inputdata.grossRecipts <= 100000000){
                    multiplierTwo = 1;
                }else if((inputdata.qualificationValue == 'DOCTOR(BDS, MDS)' || inputdata.qualificationValue == 'DOCTOR(BAMS, BHMS, BUMS)' || inputdata.qualificationValue == 'DOCTOR' || inputdata.qualificationValue == 'DOCTOR(MD,MBBS,Surgeons,Specialists)') && inputdata.grossRecipts != null && inputdata.grossRecipts > 100000000){
                    multiplierTwo = 0;
                }else{
                    multiplierTwo = 2;
                }
                Decimal c = (multiplierTwo * inputdata.grossRecipts);
                Decimal annualObl = (12 * inputdata.monthlyObli);
                Decimal newVal = (c - annualObl) / (Decimal)Math.Pow(10, 5);
                
                if(newVal > 30){
                    returnData.grossProfReceipts = 30;
                }else {
                    returnData.grossProfReceipts = newVal;
                }
            }
            if(inputdata.leadId != null){
                Lead lead = new Lead();
                lead.Id = inputdata.leadId;
                lead.GrossReceipts__c = inputdata.grossRecipts != null ? inputdata.grossRecipts : 0.00;
                lead.PAT__c = inputdata.patValue != null ? inputdata.patValue : 0.00;
                lead.Depreciation__c = inputdata.depreciation != null ? inputdata.depreciation : 0.00;
                lead.InterestExp__c = inputdata.intrstExp != null ? inputdata.intrstExp : 0.00;
                lead.OtherIncme__c = inputdata.OtheIcnme != null ? inputdata.OtheIcnme : 0.00;
                lead.ProfQual__c = inputdata.qualificationValue != null ? inputdata.qualificationValue : '';
                lead.DeclaredMonthlyObligation__c = inputdata.monthlyObli != null ? inputdata.monthlyObli : 0.00;
                lead.EMI__c = returnData.emi != null ? returnData.emi : 0;
                lead.NetProfitNP__c = returnData.netProfit != null ? returnData.netProfit : 0;
                lead.GrsPrfesnalReceiptsGPR__c = returnData.grossProfReceipts != null ? returnData.grossProfReceipts : 0;
                update lead;
            }
        }
        if(returnData != null){
            return returnData;
        }
        return null; 
    }
    @auraEnabled
    public static LeadSeNonpEmiOutputDataWrpr getLeadSeNonpEmiData(LeadSeNonpEmiInputDataWrpr inputdata){
        LeadSeNonpEmiOutputDataWrpr returnData = new LeadSeNonpEmiOutputDataWrpr();
        if(inputdata != null){
            if(inputdata.loanAmount != null && inputdata.loanTenure != null && inputdata.leadROI != null){
                Decimal leadEmiValue = KFSForLoanNdAdvController.calculateEMI(inputdata.loanAmount, inputdata.leadROI, inputdata.loanTenure).round(RoundingMode.HALF_UP);
                if(leadEmiValue != null){
                    returnData.emi = leadEmiValue;
                }
            }
            If(inputdata.program != null){
                if(inputdata.program == 'DSCR'){
                    Decimal tvalueInNew;
                    Decimal tvalueIn = ((inputdata.last12MonthsTurnover - inputdata.turnover) / (inputdata.turnover));
                    if(tvalueIn != null && tvalueIn < -0.1){
                        tvalueInNew = tvalueIn+1;
                    }else{
                        tvalueInNew = 1;
                    }
                    system.debug('tvalueInNew ' + tvalueInNew);
                    Decimal param1 = (tvalueInNew * inputdata.patValue);
                    system.debug('param1 ' + param1);
                    Decimal param2 = (1 * inputdata.depreciation);
                    system.debug('param2 ' + param2);
                    Decimal param3 = (1 * inputdata.intonEMIloanAddBack);
                    system.debug('param3 ' + param3);
                    Decimal param4 = (1 * inputdata.patCapital);
                    system.debug('param4 ' + param4);
                    Decimal appMonthIncome = ((param1 + param2 + param3 + param4)/12).round(RoundingMode.HALF_UP);
                    system.debug('appMonthIncome ' + appMonthIncome);
                    Decimal dscrPre  = (appMonthIncome / inputdata.monthlyObli).round(RoundingMode.HALF_UP);
                    system.debug('dscrPre ' + dscrPre);
                    Decimal maxEligibleEMI = (appMonthIncome - inputdata.monthlyObli);
                    system.debug('maxEligibleEMI ' + maxEligibleEMI);
                    Decimal leadEmiValueNew;
                    if(inputdata.loanTenure > 60 ){
                        leadEmiValueNew = KFSForLoanNdAdvController.calculateEMI(inputdata.loanAmount, inputdata.leadROI, 60).round(RoundingMode.HALF_UP);
                    }else {
                        leadEmiValueNew = KFSForLoanNdAdvController.calculateEMI(inputdata.loanAmount, inputdata.leadROI, inputdata.loanTenure).round(RoundingMode.HALF_UP);
                    }
                    system.debug('leadEmiValueNew ' + leadEmiValueNew);
                    Decimal val;
                    if(leadEmiValueNew != null){
                        val = (maxEligibleEMI / leadEmiValueNew).round(RoundingMode.HALF_UP);
                    }
                    system.debug('eligibility ' + val);
                    if(val > 30){
                        returnData.eligibility = 30;
                    }else{
                        returnData.eligibility = val;
                    }
                }else if(inputdata.program == 'GST'){
                    Decimal param5 = (inputdata.patValue / inputdata.turnover);
                    Decimal param6 = (param5 * inputdata.last12MonthsTurnover);
                    Decimal param7 = (1 * inputdata.depreciation);
                    Decimal param8 = (1 * inputdata.intonEMIloanAddBack);
                    Decimal param9 = (1 * inputdata.patCapital);
                    Decimal appMonthIncomeGST = (param6 + param7 + param8 + param9);
                    Decimal dscrPre  = (appMonthIncomeGST / inputdata.monthlyObli);
                    Decimal maxEligibleEMIGST = (appMonthIncomeGST - inputdata.monthlyObli);
                    Decimal leadEmiValueNew;
                    if(inputdata.loanTenure > 60 ){
                        leadEmiValueNew = KFSForLoanNdAdvController.calculateEMI(inputdata.loanAmount, inputdata.leadROI, 60).round(RoundingMode.HALF_UP);
                    }else {
                        leadEmiValueNew = KFSForLoanNdAdvController.calculateEMI(inputdata.loanAmount, inputdata.leadROI, inputdata.loanTenure).round(RoundingMode.HALF_UP);
                    }
                    system.debug('leadEmiValueNew ' + leadEmiValueNew);
                    Decimal val;
                    if(leadEmiValueNew != null){
                        val = (maxEligibleEMIGST / leadEmiValueNew);
                    }
                    if(val > 30){
                        returnData.eligibility = 30;
                    }else{
                        returnData.eligibility = val;
                    }
                }else if(inputdata.program == 'GST Test'){
                    Decimal multiplier;
                    List<String> types = new List<String> {'NOB Master'};
                        String typeList = String.join(types, '\',\'');
                    String query = 'SELECT Id, FOIRValue__c, Type__c FROM MasterData__c WHERE SalesforceCode__c = \'' + inputdata.natureOfBusiness +'\' Type__c IN (\'' + typeList + '\')';
                    List<MasterData__c> mstrDataList = Database.query(query);
                    
                    if(!mstrDataList.isEmpty()){
                        multiplier = Decimal.valueof(mstrDataList[0].FOIRValue__c);                       
                    }else{
                        multiplier = 0;
                    }
                    Decimal appMonthIncomeGSTTest = ((multiplier * inputdata.last12MonthsTurnover) / 12);
                    Decimal dscrPre  = (appMonthIncomeGSTTest / inputdata.monthlyObli);
                    Decimal maxEligibleEMIGSTTest = ((appMonthIncomeGSTTest * 0.8) - inputdata.monthlyObli);
                    
                    Decimal leadEmiValueNew;
                    if(inputdata.loanTenure > 60 ){
                        leadEmiValueNew = KFSForLoanNdAdvController.calculateEMI(inputdata.loanAmount, inputdata.leadROI, 60).round(RoundingMode.HALF_UP);
                    }else {
                        leadEmiValueNew = KFSForLoanNdAdvController.calculateEMI(inputdata.loanAmount, inputdata.leadROI, inputdata.loanTenure).round(RoundingMode.HALF_UP);
                    }
                    system.debug('leadEmiValueNew ' + leadEmiValueNew);
                    Decimal val;
                    if(leadEmiValueNew != null){
                        val = (maxEligibleEMIGSTTest / leadEmiValueNew);
                    }
                    if(val > 30){
                        returnData.eligibility = 30;
                    }else{
                        returnData.eligibility = val;
                    }
                }else if(inputdata.program == 'ABB' || inputdata.program == 'ABB Test'){
                    Decimal eligibleEMI = ((inputdata.abbValue * 0.2) - inputdata.emiGoingFrmOthrAcnt); 
                    Decimal leadEmiValueNew;
                    if(inputdata.loanTenure > 60 ){
                        leadEmiValueNew = KFSForLoanNdAdvController.calculateEMI(inputdata.loanAmount, inputdata.leadROI, 60).round(RoundingMode.HALF_UP);
                    }else {
                        leadEmiValueNew = KFSForLoanNdAdvController.calculateEMI(inputdata.loanAmount, inputdata.leadROI, inputdata.loanTenure).round(RoundingMode.HALF_UP);
                    }
                    system.debug('leadEmiValueNew ' + leadEmiValueNew);
                    Decimal val;
                    if(leadEmiValueNew != null){
                        val = (eligibleEMI / leadEmiValueNew);
                    }
                    if(val > 30){
                        returnData.eligibility = 30;
                    }else{
                        returnData.eligibility = val;
                    }
                }
            }
        }
        
         if(inputdata != null && inputdata.leadId != null){
                Lead lead = new Lead();
                lead.Id = inputdata.leadId;
                lead.Program__c = inputdata.program != null ? inputdata.program : '';
                lead.NatureofBusiness__c = inputdata.natureOfBusiness != null ? inputdata.natureOfBusiness : '';
                lead.PAT__c = inputdata.patValue != null ? inputdata.patValue : 0.00;
                lead.Depreciation__c = inputdata.depreciation != null ? inputdata.depreciation : 0.00;
                lead.Last12monthsTurnoverasperGST__c = inputdata.last12MonthsTurnover != null ? inputdata.last12MonthsTurnover : 0.00;
                lead.Turnover__c = inputdata.turnover != null ? inputdata.turnover : 0.00;
                lead.InterestonEMIloanaddback__c = inputdata.intonEMIloanAddBack != null ? inputdata.intonEMIloanAddBack : 0.00;
                lead.DeclaredMonthlyObligation__c = inputdata.monthlyObli != null ? inputdata.monthlyObli : 0.00;
                lead.RemandorIntonpartnersCapitalafteTax__c = inputdata.patCapital != null ? inputdata.patCapital : 0.00;
                lead.ABB__c = inputdata.abbValue != null ? inputdata.abbValue : 0.00;
                lead.EMIgoingfromotheraccount__c = inputdata.emiGoingFrmOthrAcnt != null ? inputdata.emiGoingFrmOthrAcnt : 0.00;
                lead.EMI__c = returnData.emi != null ? returnData.emi : 0;
                lead.Eligibility_in_lacs__c = returnData.eligibility != null ? returnData.eligibility : 0;
                update lead;
            }
        if(returnData != null){
            return returnData;
        }
        return null; 
    }
    
    public class LeadSeNonpEmiInputDataWrpr {
        @AuraEnabled
        public String leadId { get; set; }
        @AuraEnabled
        public Decimal loanAmount { get; set; }
        @AuraEnabled
        public Integer loanTenure { get; set; }
        @AuraEnabled
        public Decimal leadROI { get; set; }
        @AuraEnabled
        public Decimal last12MonthsTurnover { get; set; }
        @AuraEnabled
        public Decimal patValue { get; set; }
        @AuraEnabled
        public Decimal depreciation { get; set; }
        @AuraEnabled
        public Decimal turnover { get; set; }
        @AuraEnabled
        public Decimal intonEMIloanAddBack { get; set; }
        @AuraEnabled
        public Decimal monthlyObli { get; set; }
        @AuraEnabled
        public Decimal patCapital { get; set; }
        @AuraEnabled
        public Decimal abbValue { get; set; }
        @AuraEnabled
        public Decimal emiGoingFrmOthrAcnt { get; set; }
        @AuraEnabled
        public String program { get; set; }
        @AuraEnabled
        public String natureOfBusiness { get; set; }
    }
    public class LeadSeNonpEmiOutputDataWrpr {
        @AuraEnabled
        public Decimal emi { get; set; }
        @AuraEnabled
        public Decimal eligibility { get; set; }
    }
    public class LeadSepEmiInputDataWrpr {
        @AuraEnabled
        public String leadId { get; set; }
        @AuraEnabled
        public Decimal loanAmount { get; set; }
        @AuraEnabled
        public Integer loanTenure { get; set; }
        @AuraEnabled
        public Decimal leadROI { get; set; }
        @AuraEnabled
        public Decimal grossRecipts { get; set; }
        @AuraEnabled
        public Decimal patValue { get; set; }
        @AuraEnabled
        public Decimal depreciation { get; set; }
        @AuraEnabled
        public Decimal intrstExp { get; set; }
        @AuraEnabled
        public Decimal OtheIcnme { get; set; }
        @AuraEnabled
        public Decimal monthlyObli { get; set; }
        @AuraEnabled
        public String qualificationValue { get; set; }
    }
    public class LeadSepEmiOutputDataWrpr {
        @AuraEnabled
        public Decimal emi { get; set; }
        @AuraEnabled
        public Decimal netProfit { get; set; }
        @AuraEnabled
        public Decimal grossProfReceipts { get; set; }
    }
    public class LeadEmiInputDataWrpr {
        @AuraEnabled
        public String leadId { get; set; }
        @AuraEnabled
        public Decimal loanAmount { get; set; }
        @AuraEnabled
        public Integer loanTenure { get; set; }
        @AuraEnabled
        public Decimal leadROI { get; set; }
        @AuraEnabled
        public Decimal totalNetMonthlyIncome { get; set; }
        @AuraEnabled
        public Decimal monthlyObligations { get; set; }
        @AuraEnabled
        public Decimal salaryExclVarPay { get; set; }
        @AuraEnabled
        public Decimal avgVarPay { get; set; }
        @AuraEnabled
        public Decimal dedInclIncmeTax { get; set; }
        @AuraEnabled
        public Decimal netTakeHomeSalery { get; set; }
        @AuraEnabled
        public Decimal avgAdditionalIncome { get; set; }
        @AuraEnabled
        public Decimal consuIncme { get; set; }
    }
    public class LeadEmiOutputDataWrpr {
        @AuraEnabled
        public Decimal emi { get; set; }
        @AuraEnabled
        public Decimal applicableFOIR { get; set; }
        @AuraEnabled
        public Decimal maxEligibleEmi { get; set; }
        @AuraEnabled
        public Decimal maxLoanBasisFOIR { get; set; }
        @AuraEnabled
        public Decimal maxLoanBasisNMIBand { get; set; }
        @AuraEnabled
        public Decimal maxLoanEligibility { get; set; }
    }
}