public class CaseUpdateApplicantAsset implements TriggerAction.AfterUpdate{
    public static void afterUpdate(List<Case> newList, List<Case> oldList){
        System.debug('newList:'+newList);   
        System.debug('oldList of value:'+oldList);
        Map<Id,Case> MapOfOldList = new Map<Id,Case>(oldList);
        Set<Id> ApplicantAssetId = new Set<Id>();
        Map<Id,List<Decimal>> MapOfTotalValulation = new Map<Id,List<Decimal>>();
        Map<Id,ApplAsset__c> mapOfApplAsset = new Map<Id,ApplAsset__c>();
        Map<Id,Decimal> mapOfNoCaseRaised = new Map<Id,Decimal>();
        List<Decimal> valuationList = new List<Decimal>();
        ApplAsset__c applicantAsste;
        Case caseObj1;
      
        Map<Id,List<Case>> applicantAssetTocase = new Map<Id,List<Case>>();
        Map<Decimal, Case> mapOfCase = new Map<Decimal,Case>();
        List<RecordType> recordTypeId = [SELECT Name, DeveloperName, Id FROM RecordType where DeveloperName = 'Technical' ];
        
        For(Case caseObj : newList){
            If(caseObj.Status == 'Closed' && caseObj.RecordTypeId ==  recordTypeId[0].Id && MapOfOldList.get(caseObj.Id).Status !=caseObj.Status){
                ApplicantAssetId.add(caseObj.ApplAssetId__c);           
            }
        }
        system.debug('ApplicantAssetId:'+ApplicantAssetId);
        for(Case objCase : [SELECT Id,ApplAssetId__c,RecordType.name,Total_Valuation_Land_Valuation_B__c,ApplAssetId__r.Approx_Age_of_Prop__c,
                            ApplAssetId__r.Resi_Age__c,ApplAssetId__r.Land_Area__c, ApplAssetId__r.Land_Valu__c,ApplAssetId__r.Prop_Bui_up_ar__c,
                            ApplAssetId__r.PerSqFtRateLandArea__c,ApplAssetId__r.PerSqFtRateBuiltUpArea__c,ApplAssetId__r.Stage_of_Construction__c,
                            Stage_of_Construction__c, Property_Built_up_area_Sq_Ft__c,Built_up_area_Valuation_In_Rs__c, Land_Area_Sq_Ft__c, Land_Valuation_in_Rs__c,
                            Approx_Age_of_Property_in_Years__c,Residual_Age_in_Years__c,ApplAssetId__r.Valuation_as_per_policy_norms__c,ApplAssetId__r.Built_up_area_Valu__c
                            ,ApplAssetId__r.ExtraCaseNeedToBeRaised__c,ApplAssetId__r.NoOfCasesRaised__c,Loan_Application__r.NoCasesNeedToRaised__c,ApplAssetId__r.Total_Valua__c,ApplAssetId__r.ChangeRequiredInValuationAsPerPolicyNorm__c
                            FROM Case WHERE ApplAssetId__c IN : ApplicantAssetId  AND  Status = 'Closed' AND RecordTypeId =: recordTypeId[0].Id AND ExpiryDate__c >= TODAY AND IsReinitiatedExpired__c = false
                            AND Loan_Application__r.Stage__c != 'Disbursed' ]  ){
                                
                                if(applicantAssetTocase.containskey(objCase.ApplAssetId__c)){
                                    applicantAssetTocase.get(objCase.ApplAssetId__c).add(objCase); 
                                }else{
                                    applicantAssetTocase.put(objCase.ApplAssetId__c, new List<Case> {objCase});  
                                }
                                
                                if(objCase.Loan_Application__r.NoCasesNeedToRaised__c != null){
                                    mapOfNoCaseRaised.put(objCase.ApplAssetId__c, objCase.Loan_Application__r.NoCasesNeedToRaised__c);
                                }
                                
                                if(MapOfTotalValulation.containskey(objCase.ApplAssetId__c) ){
                                   MapOfTotalValulation.get(objCase.ApplAssetId__c).add(objCase.Total_Valuation_Land_Valuation_B__c);  
                               
                                }else{
                                  MapOfTotalValulation.put(objCase.ApplAssetId__c,new List<Decimal>{objCase.Total_Valuation_Land_Valuation_B__c});  
                                }
                                
                                if(mapOfCase.containskey(objCase.Total_Valuation_Land_Valuation_B__c)){
                                   caseObj1 = mapOfCase.get(objCase.Total_Valuation_Land_Valuation_B__c);
                                }else{
                                   mapOfCase.put(objCase.Total_Valuation_Land_Valuation_B__c, objCase);   
                                }
                                
                            }
        
        
        system.debug('applicantAssetTocase.keyset():'+applicantAssetTocase.keyset());        
        for(String assetId : applicantAssetTocase.keyset()){
            
            ApplAsset__c appAsset = new ApplAsset__c();
            appAsset.Id = assetId; 
           
            for(Case caseObj : applicantAssetTocase.get(assetId)){
              
                system.debug('appAsset.ChangeRequiredInValuationAsPerPolicyNorm__c:'+caseObj.ApplAssetId__r.ChangeRequiredInValuationAsPerPolicyNorm__c);
                system.debug('caseObj:'+caseObj);
                if(appAsset.Approx_Age_of_Prop__c == null){
                    appAsset.Approx_Age_of_Prop__c = caseObj.Approx_Age_of_Property_in_Years__c; 
                }else if(appAsset.Approx_Age_of_Prop__c != null &&  caseObj.Approx_Age_of_Property_in_Years__c > appAsset.Approx_Age_of_Prop__c){
                    appAsset.Approx_Age_of_Prop__c = caseObj.Approx_Age_of_Property_in_Years__c; 
                }
                
                if(appAsset.Land_Area__c == null){
                    appAsset.Land_Area__c = caseObj.Land_Area_Sq_Ft__c; 
                }else if(appAsset.Land_Area__c != null &&  caseObj.Land_Area_Sq_Ft__c < appAsset.Land_Area__c){
                    appAsset.Land_Area__c = caseObj.Land_Area_Sq_Ft__c; 
                }
                
                if(appAsset.Resi_Age__c == null){
                    appAsset.Resi_Age__c = caseObj.Residual_Age_in_Years__c; 
                }else if(appAsset.Resi_Age__c  != null &&  caseObj.Residual_Age_in_Years__c < appAsset.Resi_Age__c ){
                    appAsset.Resi_Age__c  = caseObj.Residual_Age_in_Years__c; 
                }
                
                if(appAsset.Prop_Bui_up_ar__c  == null){
                    appAsset.Prop_Bui_up_ar__c  = caseObj.Property_Built_up_area_Sq_Ft__c; 
                }else if(appAsset.Prop_Bui_up_ar__c   != null &&  caseObj.Property_Built_up_area_Sq_Ft__c < appAsset.Prop_Bui_up_ar__c  ){
                    appAsset.Prop_Bui_up_ar__c   = caseObj.Property_Built_up_area_Sq_Ft__c; 
                } 
                
                if(appAsset.Stage_of_Construction__c  == null){
                    appAsset.Stage_of_Construction__c   = caseObj.Stage_of_Construction__c; 
                }else if(appAsset.Stage_of_Construction__c   != null &&  caseObj.Stage_of_Construction__c < appAsset.Stage_of_Construction__c   ){
                    appAsset.Stage_of_Construction__c    = caseObj.Stage_of_Construction__c; 
                }
                
                if(!MapOfTotalValulation.isEmpty()){
                
               if(MapOfTotalValulation.get(assetId).size()  == 2 && mapOfNoCaseRaised.get(assetId) == 2){
                   valuationList = MapOfTotalValulation.get(assetId);
                   valuationList.sort();
                   system.debug('valuationList:'+valuationList);
                   Decimal totalvaluationDiff = Math.abs(valuationList[1] - valuationList[0]);
                  // Decimal Average = (valuationList[1] + valuationList[0])/2;
                   Decimal percentageDiff = (totalvaluationDiff/valuationList[0] ) * 100;
                   percentageDiff = Math.round(percentageDiff);
                   system.debug('percentageDiff:'+percentageDiff);

                   if(percentageDiff > 30){
                   appAsset.ExtraCaseNeedToBeRaised__c = 1;
                   }else{
                   appAsset.ExtraCaseNeedToBeRaised__c = 0;  
                   }  
            }
        }
                valuationList = MapOfTotalValulation.get(assetId);
                valuationList.sort();
                appAsset.Valuation_as_per_policy_norms__c =valuationList[0];
                if(caseObj.ApplAssetId__r.ChangeRequiredInValuationAsPerPolicyNorm__c == 'NO'){
                 appAsset.ValuationToBeTakenAheadForCalculation__c =  valuationList[0];  
                }
                appAsset.Land_Valu__c = mapOfCase.get(valuationList[0]).Land_Valuation_in_Rs__c;
                appAsset.Built_up_area_Valu__c = mapOfCase.get(valuationList[0]).Built_up_area_Valuation_In_Rs__c;
                mapOfApplAsset.put(assetId,appAsset);
            }
            
        }
         system.debug('lstApplicantAsset:'+mapOfApplAsset.values());
        if(!mapOfApplAsset.isEmpty()){
             Update  mapOfApplAsset.values();  
        }
        
    }        
  }