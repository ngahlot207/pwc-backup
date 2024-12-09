public without sharing class EligibilityScreenPropertyDetails {
    @AuraEnabled(cacheable=true)
    public static String fetchPropRecords(String params,string applId) {
        
        Map<Id,PropertyEligibility> propertyMap = new Map<Id,PropertyEligibility>();
        PropertyEligibility wrapObj = new PropertyEligibility();
        
        ResponseWrapper resp = new ResponseWrapper();
        resp.application = new PropertyEligibility();
        
        List<ApplAsset__c> applAsstList = new List<ApplAsset__c>(); 
        applAsstList =[select id,PropAddrs__c, PropType__c, Prop_Owners__c, PropSubType__c, Property_Usage__c,Total_Valua__c,LoanAppln__c,Appl__c,Valuation_as_per_policy_norms__c,ValuationToBeTakenAheadForCalculation__c,ChangeRequiredInValuationAsPerPolicyNorm__c from ApplAsset__c where LoanAppln__c=:params];
        integer i=1;
        for(ApplAsset__c prop:applAsstList ){
            wrapObj =(propertyMap.containsKey(prop.Id))?propertyMap.get(prop.Id):new PropertyEligibility();
            wrapObj.ApplicantAssetId = prop.Id;
            wrapObj.propertyDisplayName = 'Property '+i;
            wrapObj.propertyType = prop.PropType__c;
            wrapObj.PropAddrs =(prop.PropAddrs__c != null)?prop.PropAddrs__c:''; 
            wrapObj.PropType =(prop.PropType__c != null)?prop.PropType__c:''; 
            wrapObj.PropSubType =(prop.PropSubType__c != null)?prop.PropSubType__c:''; 
            wrapObj.PropertyUsage =(prop.Property_Usage__c != null)?prop.Property_Usage__c:''; 
             if(prop.ChangeRequiredInValuationAsPerPolicyNorm__c!=null){
                if(prop.ChangeRequiredInValuationAsPerPolicyNorm__c=='NO'){
                  wrapObj.ApproxValue =( prop.Valuation_as_per_policy_norms__c != null)? prop.Valuation_as_per_policy_norms__c:0;  
                        }if(prop.ChangeRequiredInValuationAsPerPolicyNorm__c=='YES'){
                           wrapObj.ApproxValue =( prop.ValuationToBeTakenAheadForCalculation__c != null)? prop.ValuationToBeTakenAheadForCalculation__c:0;   
                        }
            }
           // wrapObj.ApproxValue =(prop.Total_Valua__c != null)?prop.Total_Valua__c:0; 
           
           
            i++;
            propertyMap.put(prop.Id,wrapObj); 
        }
        //system.debug('Manish'+propertyMap.values().size());
        List<BRE__c> breRespList = new List<BRE__c>();
        
        
        breRespList=[SELECT Id,Applicant_Asset__c, LoanAppl__c, Applicant__c,LTVApplWDeviation__c,MaxcoltrlLnEliWDeviation__c,TotlLTVBsdLnEliWIns__c,AddLTVBsdEliIns__c,LTVBsdEliWOIns__c,LTVApplLnWtInsurance__c,LTVApplLnWOInsurance__c,EligibilityType__c FROM BRE__c where LoanAppl__c=:params AND IsLatest__c=true];
        //wrapObj.TotlLTVBsdLnEliWIns = 0;
        wrapObj.SummationTotlLTVBsdLnEliWIns = 0;
        for (BRE__c recordBREResp : breRespList) {
            //For Property  Table
            
            if(recordBREResp.EligibilityType__c =='Property'){
               
                wrapObj =(propertyMap.containsKey(recordBREResp.Applicant_Asset__c))?propertyMap.get(recordBREResp.Applicant_Asset__c):new PropertyEligibility();
                
                wrapObj.LTVApplLnWOInsurance =(recordBREResp.LTVApplLnWOInsurance__c != null)?  recordBREResp.LTVApplLnWOInsurance__c:0;
                wrapObj.LTVApplLnWtInsurance =(recordBREResp.LTVApplLnWtInsurance__c != null)?  recordBREResp.LTVApplLnWtInsurance__c:0;
                wrapObj.LTVBsdEliWOIns =(recordBREResp.LTVBsdEliWOIns__c != null)?  recordBREResp.LTVBsdEliWOIns__c:0;
                wrapObj.AddLTVBsdEliIns =(recordBREResp.AddLTVBsdEliIns__c != null)?  recordBREResp.AddLTVBsdEliIns__c:0;
                wrapObj.TotlLTVBsdLnEliWIns = (recordBREResp.TotlLTVBsdLnEliWIns__c != null)?  recordBREResp.TotlLTVBsdLnEliWIns__c:0;
                //wrapObj.SummationTotlLTVBsdLnEliWIns += (wrapObj.TotlLTVBsdLnEliWIns != null) ? wrapObj.TotlLTVBsdLnEliWIns : 0;
                wrapObj.LTVApplWDeviation =(recordBREResp.LTVApplWDeviation__c != null)?  recordBREResp.LTVApplWDeviation__c:0;
                wrapObj.MaxcoltrlLnEliWDeviation =(recordBREResp.MaxcoltrlLnEliWDeviation__c != null)?  recordBREResp.MaxcoltrlLnEliWDeviation__c:0;
                
                propertyMap.put(recordBREResp.Applicant_Asset__c,wrapObj);  
            }
            
            if(recordBREResp.EligibilityType__c =='Application'){
                
                resp.application.LTVBsdEliWOIns =(recordBREResp.LTVBsdEliWOIns__c != null)?  recordBREResp.LTVBsdEliWOIns__c:0;
                resp.application.AddLTVBsdEliIns =(recordBREResp.AddLTVBsdEliIns__c != null)?  recordBREResp.AddLTVBsdEliIns__c:0;
                resp.application.TotlLTVBsdLnEliWIns =(recordBREResp.TotlLTVBsdLnEliWIns__c != null)?  recordBREResp.TotlLTVBsdLnEliWIns__c:0;
                resp.application.MaxcoltrlLnEliWDeviation =(recordBREResp.MaxcoltrlLnEliWDeviation__c != null)?  recordBREResp.MaxcoltrlLnEliWDeviation__c:0;
                
                
            }
        }
        List<Applicant_Financial_Summary__c> summaryListPL = new List<Applicant_Financial_Summary__c>();
        summaryListPL =[SELECT Id,Profit_Before_Tax__c,Depreciation__c,Interest_on_Partner_Capital__c,Interest_on_Term_Loans__c,Taxes__c,FinancialYearFor__c, Financial_Year__c,Applicant_Financial__r.RecordType.Name,Applicant_Financial__r.Loan_Applicant__r.LoanAppln__c,Applicant_Financial__r.Loan_Applicant__r.ApplType__c,Applicant_Financial__r.Loan_Applicant__r.FullName__c  FROM Applicant_Financial_Summary__c Where Applicant_Financial__r.RecordType.Name='Profit & Loss' AND Applicant_Financial__r.Loan_Applicant__c=:applId];
        if(!summaryListPL.isEmpty()){
            resp.applFinanacialObj = summaryListPL;
        }
        
        
        // List<DedupeResponse__c> fedfinaExp = new List<DedupeResponse__c>();

        //LAK-8570
        List<DedupeResponse__c> dedupeResp = [SELECT ID, Lan__c, Applicant__c,UCID__c FROM DedupeResponse__c WHERE RecordType.Name = 'DedupeMatchCr' AND IntnlDeduRelevance__c = 'Accurate Match found'  AND LoanAppln__c = :params];

        List<Id> appIdsMatchFound = new List<Id>();
        for(DedupeResponse__c dedupe : dedupeResp){
            appIdsMatchFound.add(dedupe.Applicant__c);
        }
        List<DedupeResponse__c> enpaResp = [SELECT Id, AUM__c, Lan__c,UCID__c, Loan_to_be_closed_internally__c  FROM DedupeResponse__c WHERE RecordType.Name = 'ENPA' AND LoanAppln__c = :params AND Applicant__c IN :appIdsMatchFound];

        
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

        // List<AggregateResult> aggregateResults = [SELECT SUM(AUM__c) FROM DedupeResponse__c WHERE RecordType.Name = 'ENPA' 
        //                                           AND Loan_to_be_closed_internally__c ='No'AND LoanAppln__c = :params];
        // if (!aggregateResults.isEmpty() && aggregateResults[0].get('expr0') != null) {
        //     resp.sumFedFinaExpLnAmt = (Decimal)aggregateResults[0].get('expr0');
        // }
                
        LoanAppl__c loanApplicationData = [select id,Product__c from LoanAppl__c where id =:params LIMIT 1];

        if(loanApplicationData !=null && loanApplicationData.Product__c != null){
          string productTypevalue = loanApplicationData.Product__c;  
          System.debug('productTypevalue =='+productTypevalue);

          String mstrValOfLoanTyp = '';
          //LAK-8830
          MasterData__c masterDataRecord = [SELECT id,FinnoneCode__c FROM MasterData__c WHERE Type__c = 'Product' AND Name = :productTypeValue LIMIT 1];
            
            if (masterDataRecord != null && masterDataRecord.FinnoneCode__c != null) {
            mstrValOfLoanTyp = masterDataRecord.FinnoneCode__c;
            }

            List<DedupeResponse__c> enpaRespPrd = [select Id, AUM__c, Lan__c,UCID__c, Loan_to_be_closed_internally__c from DedupeResponse__c  where LoanType__c =:mstrValOfLoanTyp  
                                                                     AND LoanAppln__c=:params AND RecordType.Name = 'ENPA' AND Applicant__c IN :appIdsMatchFound  ];
            

            Decimal sumFedfinaPrdExposure = 0;
            Set<String> pastLansPrd = new Set<String>();
            Set<String> ucidSetPrd = new Set<String>();
            for(DedupeResponse__c enpa : enpaRespPrd){
                if(enpa.Lan__c != null && enpa.UCID__c != null && enpa.AUM__C != null){
                    if(!pastLansPrd.contains(enpa.Lan__c) && !ucidSetPrd.contains(enpa.UCID__c) && enpa.Loan_to_be_closed_internally__c == 'No'){
                        
                        sumFedfinaPrdExposure += enpa.AUM__c;
                        pastLansPrd.add(enpa.Lan__c);
                        ucidSetPrd.add(enpa.UCID__c);
                        
                    }
                }
            }                       
            resp.sumFedFinaProdAmt = sumFedfinaPrdExposure;                      
        //     if (!aggregatePrduct.isEmpty() && aggregatePrduct[0].get('expr0') != null) {
        //     resp.sumFedFinaProdAmt = (Decimal)aggregatePrduct[0].get('expr0');
        // }
        }
                

        system.debug('resp.sumFedFinaProdAmt>>>>>>'+resp.sumFedFinaProdAmt);
        //system.debug('Manish2'+propertyMap.values().size());
        resp.propertyList = propertyMap.values();
        system.debug('all data of EligibilityScreenPropertyDetails>>>>>'+JSON.serialize(resp));
        return JSON.serialize(resp);
    }

    @AuraEnabled
    public static String fetchPropRecordsNonCacheable(String params,string applId) {
        
        Map<Id,PropertyEligibility> propertyMap = new Map<Id,PropertyEligibility>();
        PropertyEligibility wrapObj = new PropertyEligibility();
        
        ResponseWrapper resp = new ResponseWrapper();
        resp.application = new PropertyEligibility();
        
        List<ApplAsset__c> applAsstList = new List<ApplAsset__c>(); 
        applAsstList =[select id,PropAddrs__c, PropType__c, Prop_Owners__c, PropSubType__c, Property_Usage__c,Total_Valua__c,LoanAppln__c,Appl__c,Valuation_as_per_policy_norms__c,ValuationToBeTakenAheadForCalculation__c,ChangeRequiredInValuationAsPerPolicyNorm__c from ApplAsset__c where LoanAppln__c=:params];
        integer i=1;
        for(ApplAsset__c prop:applAsstList ){
            wrapObj =(propertyMap.containsKey(prop.Id))?propertyMap.get(prop.Id):new PropertyEligibility();
            wrapObj.ApplicantAssetId = prop.Id;
            wrapObj.propertyDisplayName = 'Property '+i;
            wrapObj.propertyType = prop.PropType__c;
            wrapObj.PropAddrs =(prop.PropAddrs__c != null)?prop.PropAddrs__c:''; 
            wrapObj.PropType =(prop.PropType__c != null)?prop.PropType__c:''; 
            wrapObj.PropSubType =(prop.PropSubType__c != null)?prop.PropSubType__c:''; 
            wrapObj.PropertyUsage =(prop.Property_Usage__c != null)?prop.Property_Usage__c:''; 
             if(prop.ChangeRequiredInValuationAsPerPolicyNorm__c!=null){
                if(prop.ChangeRequiredInValuationAsPerPolicyNorm__c=='NO'){
                  wrapObj.ApproxValue =( prop.Valuation_as_per_policy_norms__c != null)? prop.Valuation_as_per_policy_norms__c:0;  
                        }if(prop.ChangeRequiredInValuationAsPerPolicyNorm__c=='YES'){
                           wrapObj.ApproxValue =( prop.ValuationToBeTakenAheadForCalculation__c != null)? prop.ValuationToBeTakenAheadForCalculation__c:0;   
                        }
            }
           // wrapObj.ApproxValue =(prop.Total_Valua__c != null)?prop.Total_Valua__c:0; 
           
           
            i++;
            propertyMap.put(prop.Id,wrapObj); 
        }
        //system.debug('Manish'+propertyMap.values().size());
        List<BRE__c> breRespList = new List<BRE__c>();
        
        
        breRespList=[SELECT Id,Applicant_Asset__c, LoanAppl__c, Applicant__c,LTVApplWDeviation__c,MaxcoltrlLnEliWDeviation__c,TotlLTVBsdLnEliWIns__c,AddLTVBsdEliIns__c,LTVBsdEliWOIns__c,LTVApplLnWtInsurance__c,LTVApplLnWOInsurance__c,EligibilityType__c FROM BRE__c where LoanAppl__c=:params];
        //wrapObj.TotlLTVBsdLnEliWIns = 0;
        wrapObj.SummationTotlLTVBsdLnEliWIns = 0;
        for (BRE__c recordBREResp : breRespList) {
            //For Property  Table
            
            if(recordBREResp.EligibilityType__c =='Property'){
               
                wrapObj =(propertyMap.containsKey(recordBREResp.Applicant_Asset__c))?propertyMap.get(recordBREResp.Applicant_Asset__c):new PropertyEligibility();
                
                wrapObj.LTVApplLnWOInsurance =(recordBREResp.LTVApplLnWOInsurance__c != null)?  recordBREResp.LTVApplLnWOInsurance__c:0;
                wrapObj.LTVApplLnWtInsurance =(recordBREResp.LTVApplLnWtInsurance__c != null)?  recordBREResp.LTVApplLnWtInsurance__c:0;
                wrapObj.LTVBsdEliWOIns =(recordBREResp.LTVBsdEliWOIns__c != null)?  recordBREResp.LTVBsdEliWOIns__c:0;
                wrapObj.AddLTVBsdEliIns =(recordBREResp.AddLTVBsdEliIns__c != null)?  recordBREResp.AddLTVBsdEliIns__c:0;
                wrapObj.TotlLTVBsdLnEliWIns = (recordBREResp.TotlLTVBsdLnEliWIns__c != null)?  recordBREResp.TotlLTVBsdLnEliWIns__c:0;
                //wrapObj.SummationTotlLTVBsdLnEliWIns += (wrapObj.TotlLTVBsdLnEliWIns != null) ? wrapObj.TotlLTVBsdLnEliWIns : 0;
                wrapObj.LTVApplWDeviation =(recordBREResp.LTVApplWDeviation__c != null)?  recordBREResp.LTVApplWDeviation__c:0;
                wrapObj.MaxcoltrlLnEliWDeviation =(recordBREResp.MaxcoltrlLnEliWDeviation__c != null)?  recordBREResp.MaxcoltrlLnEliWDeviation__c:0;
                
                propertyMap.put(recordBREResp.Applicant_Asset__c,wrapObj);  
            }
            
            if(recordBREResp.EligibilityType__c =='Application'){
                
                resp.application.LTVBsdEliWOIns =(recordBREResp.LTVBsdEliWOIns__c != null)?  recordBREResp.LTVBsdEliWOIns__c:0;
                resp.application.AddLTVBsdEliIns =(recordBREResp.AddLTVBsdEliIns__c != null)?  recordBREResp.AddLTVBsdEliIns__c:0;
                resp.application.TotlLTVBsdLnEliWIns =(recordBREResp.TotlLTVBsdLnEliWIns__c != null)?  recordBREResp.TotlLTVBsdLnEliWIns__c:0;
                resp.application.MaxcoltrlLnEliWDeviation =(recordBREResp.MaxcoltrlLnEliWDeviation__c != null)?  recordBREResp.MaxcoltrlLnEliWDeviation__c:0;
                
                
            }
        }
        List<Applicant_Financial_Summary__c> summaryListPL = new List<Applicant_Financial_Summary__c>();
        summaryListPL =[SELECT Id,Profit_Before_Tax__c,Depreciation__c,Provisional_Financial_Year__c,Interest_on_Partner_Capital__c,Interest_on_Term_Loans__c,Taxes__c,FinancialYearFor__c, Financial_Year__c,Applicant_Financial__r.RecordType.Name,Applicant_Financial__r.Loan_Applicant__r.LoanAppln__c,Applicant_Financial__r.Loan_Applicant__r.ApplType__c,Applicant_Financial__r.Loan_Applicant__r.FullName__c  FROM Applicant_Financial_Summary__c Where Applicant_Financial__r.RecordType.Name='Profit & Loss' AND Applicant_Financial__r.Loan_Applicant__c=:applId];
        if(!summaryListPL.isEmpty()){
            resp.applFinanacialObj = summaryListPL;
        }
        
        //LAK-8570
        List<DedupeResponse__c> dedupeResp = [SELECT ID, Lan__c, Applicant__c, UCID__c FROM DedupeResponse__c WHERE RecordType.Name = 'Dedupe' AND IntnlDeduRelevance__c = 'Accurate Match found' AND LoanAppln__c = :params];

        List<Id> appIdsMatchFound = new List<Id>();
        for(DedupeResponse__c dedupe : dedupeResp){
            appIdsMatchFound.add(dedupe.Applicant__c);
        }
        List<DedupeResponse__c> enpaResp = [SELECT Id, AUM__c, Lan__c, UCID__c, LoanAmount__c, Loan_to_be_closed_internally__c FROM DedupeResponse__c WHERE RecordType.Name = 'ENPA' AND LoanAppln__c = :params AND Applicant__c IN :appIdsMatchFound];

        
        Decimal sumFedfinaExposure = 0;
        Set<String> pastLans = new Set<String>();
        Set<String> ucidSet = new Set<String>();
        for(DedupeResponse__c enpa : enpaResp){
            if(enpa.Lan__c != null && enpa.UCID__c!= null && enpa.LoanAmount__c != null){
                if(!pastLans.contains(enpa.Lan__c) && !ucidSet.contains(enpa.UCID__c) && enpa.Loan_to_be_closed_internally__c == 'No'){
                    sumFedfinaExposure += enpa.LoanAmount__c;
                    pastLans.add(enpa.Lan__c);
                    ucidSet.add(enpa.UCID__c);
                }
            }
        }

        resp.sumFedFinaExpLnAmt = sumFedfinaExposure;
        
        // List<DedupeResponse__c> fedfinaExp = new List<DedupeResponse__c>();
        // List<AggregateResult> aggregateResults = [SELECT SUM(LoanAmount__c) FROM DedupeResponse__c WHERE RecordType.Name = 'ENPA' AND LoanAppln__c = :params 
        //                                            AND Loan_to_be_closed_internally__c ='No'];
        // if (!aggregateResults.isEmpty() && aggregateResults[0].get('expr0') != null) {
        //     resp.sumFedFinaExpLnAmt = (Decimal)aggregateResults[0].get('expr0');
        // }
        
        //
        LoanAppl__c loanApplicationData = [select id,Product__c from LoanAppl__c where id =:params LIMIT 1];

        if(loanApplicationData !=null && loanApplicationData.Product__c != null){
          string productTypevalue = loanApplicationData.Product__c;  
          System.debug('productTypevalue =='+productTypevalue);

          String mstrValOfLoanTyp = '';
          //LAK-8830
          MasterData__c masterDataRecord = [SELECT id,FinnoneCode__c FROM MasterData__c WHERE Type__c = 'Product' AND Name = :productTypeValue LIMIT 1];
            
            if (masterDataRecord != null && masterDataRecord.FinnoneCode__c != null) {
            mstrValOfLoanTyp = masterDataRecord.FinnoneCode__c;
            }
            List<DedupeResponse__c> enpaRespPrd = [select Id, AUM__c, Lan__c,UCID__c,LoanAmount__c, Loan_to_be_closed_internally__c from DedupeResponse__c  where LoanType__c =:mstrValOfLoanTyp  
            AND LoanAppln__c=:params AND RecordType.Name = 'ENPA' AND Applicant__c IN :appIdsMatchFound ];


            // List<AggregateResult> aggregatePrduct = [select SUM(LoanAmount__c)  from DedupeResponse__c  where LoanType__c =:mstrValOfLoanTyp  AND 
            //                                                            LoanAppln__c=:params AND RecordType.Name = 'ENPA' AND Loan_to_be_closed_internally__c ='No'];
     
            Decimal sumFedfinaPrdExposure = 0;
            Set<String> pastLansPrd = new Set<String>();
            Set<String> ucidSetPrd = new Set<String>();
            for(DedupeResponse__c enpa : enpaRespPrd){
                if(enpa.Lan__c != null && enpa.UCID__c != null && enpa.LoanAmount__c != null){
                    if(!pastLansPrd.contains(enpa.Lan__c) && !ucidSetPrd.contains(enpa.UCID__c) && enpa.Loan_to_be_closed_internally__c == 'No'){
                        
                        sumFedfinaPrdExposure += enpa.LoanAmount__c;
                        pastLansPrd.add(enpa.Lan__c);
                        ucidSetPrd.add(enpa.UCID__c);
                        
                    }
                }
            }                       
            resp.sumFedFinaProdAmt = sumFedfinaPrdExposure;    

            //    if (!aggregatePrduct.isEmpty() && aggregatePrduct[0].get('expr0') != null) {
            // resp.sumFedFinaProdAmt = (Decimal)aggregatePrduct[0].get('expr0');
        // }
        }
        
        //
        system.debug('resp.sumFedFinaProdAmt>>>>>>'+resp.sumFedFinaProdAmt);
        //system.debug('Manish2'+propertyMap.values().size());
        resp.propertyList = propertyMap.values();
        system.debug('all data of EligibilityScreenPropertyDetails>>>>>'+JSON.serialize(resp));
        return JSON.serialize(resp);
    }
    
    public class PropertyEligibility{
        @auraEnabled public String ApplicantAssetId{get;set;}
        @auraEnabled public String propertyDisplayName{get;set;}
        @auraEnabled public String propertyType{get;set;} 
    
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
        @auraEnabled public decimal SummationTotlLTVBsdLnEliWIns{get;set;}
        
    }
    
    Public class ResponseWrapper{
        
        @auraEnabled public PropertyEligibility application {get;set;}
        
        @auraEnabled public List<PropertyEligibility> propertyList {get;set;}
        @auraEnabled public List<Applicant_Financial_Summary__c> applFinanacialObj {get;set;}
        @auraEnabled public  Decimal sumFedFinaExpLnAmt {get;set;}
         @auraEnabled public  Decimal sumFedFinaProdAmt {get;set;}
        
    }
}