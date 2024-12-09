public class VerificationExpiry {
    
    Public static List<String> expiryDetail(String loanApplicationId){
        List<String> listOfExpiry = new List<String>();
        List<LoanAppl__c> listOfLoanApplication = new  List<LoanAppl__c>();
        Map<String,Verfication_Expiry__mdt> verificationNameToMDT = new Map<String,Verfication_Expiry__mdt>();
        Set<string> metadataDevition = new Set<string>();
        Map<Id, Case> mapOfappplicantAssetToLegal = new Map<Id,Case>();
        Map<Id, Case> mapOfappplicantAssetToTsr = new Map<Id,Case>();
        Map<Id, Case> mapOfappplicantAssetToCV = new Map<Id,Case>();
        Map<string, Case> mapOfappplicantAndAddressToCpv = new Map<string,Case>();
        Map<Id, Case> mapOfappplicantAssetToTechanical = new Map<Id,Case>();
        Map<Id,Pd__c> MapOfApplicantToPd = new Map<Id,Pd__c>();
        Set<String> setOfExpiry = new Set<String>();
        
        try {
            
            listOfLoanApplication = [SELECT ID,Product__c,ApprovedValidTill__c FROM LoanAppl__c WHERE ID =:loanApplicationId ];
            
            for(Verfication_Expiry__mdt expMdt : [SELECT ID,Deviation__c,ProductType__c, ValidityInDays__c,VerificationName__c,DeveloperName,label,DeviationCode__c FROM Verfication_Expiry__mdt WHERE ProductType__c =:listOfLoanApplication[0].Product__c AND Deviation__c != null]){
                verificationNameToMDT.put(expMdt.VerificationName__c,expMdt);
                metadataDevition.add(String.valueOf(Integer.valueOf(expMdt.DeviationCode__c)));
            }
            
            system.debug('verificationNameToMDT:'+verificationNameToMDT);
            system.debug('metadataDevitionCode:'+metadataDevition);
            
            Set<String> devitionSf = new Set<String>();
            for(Deviation__c deviationObj : [SELECT Id,LoanAppln__c,DeviationCategory__c,Devia_Desrp__c,DevCode__c,Deviation__c FROM Deviation__c where LoanAppln__c =: loanApplicationId AND Deviation__c IN : metadataDevition AND Deviation__c != null]){
                devitionSf.add(deviationObj.Deviation__c); 
            }
            
            system.debug('devitionSf:'+devitionSf);
            
            //Legal
            
            For(Case objCase : [SELECT ID,CaseType__c,ApplAssetId__c,Date_of_Report__c,ExpiryDate__c,status from Case WHERE Loan_Application__c =:loanApplicationId AND CaseType__c = 'Legal' AND ApplAssetId__c != null AND ExpiryDate__c != null AND Status = 'Closed' order by Date_of_Report__c DESC]){
                system.debug('legal expiry date:'+objCase.ExpiryDate__c);
                if(!mapOfappplicantAssetToLegal.containsKey(objCase.ApplAssetId__c)){
                    mapOfappplicantAssetToLegal.Put(objCase.ApplAssetId__c, objCase);
                    if(objCase.ExpiryDate__c < date.today()  && !devitionSf.contains(String.valueOf(Integer.valueOf(verificationNameToMDT.get(GlobalConstants.Verification_Name_Legal).DeviationCode__c)))){
                        setOfExpiry.add(verificationNameToMDT.get(GlobalConstants.Verification_Name_Legal).VerificationName__c);  
                    }
                }
            } 
            
            //TSR
            For(Case objCase : [SELECT ID,CaseType__c,ApplAssetId__c,Date_of_Report__c,ExpiryDate__c,Status from Case WHERE Loan_Application__c =:loanApplicationId AND CaseType__c = 'TSR' AND ApplAssetId__c != null  AND ExpiryDate__c != null AND Status = 'Closed' order by Date_of_Report__c DESC]){
                if(!mapOfappplicantAssetToTsr.containsKey(objCase.ApplAssetId__c)){
                    mapOfappplicantAssetToTsr.Put(objCase.ApplAssetId__c, objCase);  
                    if(objCase.ExpiryDate__c < date.today() && !devitionSf.contains(String.valueOf(Integer.valueOf(verificationNameToMDT.get(GlobalConstants.Verification_Name_TSR).DeviationCode__c)))){
                        setOfExpiry.add(verificationNameToMDT.get(GlobalConstants.Verification_Name_TSR).VerificationName__c);  
                    }
                }
            }
            
            //Collateral Visit
            For(Case objCase : [SELECT ID,CaseType__c,ApplAssetId__c,Date_of_Report__c,ExpiryDate__c,Status from Case WHERE Loan_Application__c =:loanApplicationId AND CaseType__c ='Collateral Visit'  AND ApplAssetId__c != null AND IsCompleted__c = TRUE order by DateofVisit__c DESC]){
                if(!mapOfappplicantAssetToCV.containsKey(objCase.ApplAssetId__c)){
                    mapOfappplicantAssetToCV.Put(objCase.ApplAssetId__c, objCase);  
                    if(objCase.ExpiryDate__c != null & objCase.ExpiryDate__c < date.today() && !devitionSf.contains(String.valueof(Integer.valueOf(verificationNameToMDT.get(GlobalConstants.Verification_Name_Collateral).DeviationCode__c))) ){
                        setOfExpiry.add(verificationNameToMDT.get(GlobalConstants.Verification_Name_Collateral).VerificationName__c);  
                    }
                }
            } 
            
            //CPV
            
            For(Case objCase : [SELECT ID,CaseType__c,ApplAddr__c,Date_of_Report__c,ExpiryDate__c,Applicant__c,status from Case WHERE Loan_Application__c =:loanApplicationId AND CaseType__c = 'CPVFI' AND ApplAddr__c != null AND Applicant__c !=null AND IsMandatory__c = TRUE   order by Date_of_Report__c DESC]){
                if(!mapOfappplicantAndAddressToCpv.containsKey(objCase.ApplAddr__c+'-'+objCase.Applicant__c) ){
                    mapOfappplicantAndAddressToCpv.Put(objCase.ApplAddr__c+'-'+objCase.Applicant__c, objCase);  
                    if(objCase.ExpiryDate__c < date.today() && !devitionSf.contains(String.valueOf(Integer.valueOf(verificationNameToMDT.get(GlobalConstants.Verification_Name_CPV).DeviationCode__c))) && objCase.Status == 'Closed'){
                        setOfExpiry.add(verificationNameToMDT.get(GlobalConstants.Verification_Name_CPV).VerificationName__c);  
                    }
                }
            } 
            
            //Technical
            For(Case objCase : [SELECT ID,CaseType__c,ApplAssetId__c,Date_of_Report__c,ExpiryDate__c from Case WHERE Loan_Application__c =:loanApplicationId AND CaseType__c = 'Technical' AND ApplAssetId__c != null AND ExpiryDate__c != null AND IsReinitiatedExpired__c = false AND Status = 'Closed'  order by Date_of_Report__c DESC]){
                if(!mapOfappplicantAssetToTechanical.containsKey(objCase.ApplAssetId__c)){
                    mapOfappplicantAssetToTechanical.Put(objCase.ApplAssetId__c, objCase);
                    system.debug('mapOfappplicantAssetToTechanical:'+mapOfappplicantAssetToTechanical);
                    system.debug('objCase.ExpiryDate__c:'+objCase.ExpiryDate__c);
                    if(objCase.ExpiryDate__c < date.today()  && !devitionSf.contains(String.valueof(Integer.valueOf(verificationNameToMDT.get(GlobalConstants.Verification_Name_Technical).DeviationCode__c)))){
                        setOfExpiry.add(verificationNameToMDT.get(GlobalConstants.Verification_Name_Technical).VerificationName__c);  
                    }
                }
            }
            
            for(DocDtl__c doc : [SELECT Id, Name, LAN__c, DocTyp__c,Expiry_Date__c FROM DocDtl__c Where  LAN__c =: loanApplicationId AND  DocTyp__c = 'Sanction Letter' AND IsLatest__c = TRUE AND  Expiry_Date__c < Today]){
                If(!devitionSf.contains(String.valueOf(Integer.valueOf(verificationNameToMDT.get(GlobalConstants.Verification_Name_Sanction_Letter).DeviationCode__c)))){ 
                    setOfExpiry.add(verificationNameToMDT.get(GlobalConstants.Verification_Name_Sanction_Letter).VerificationName__c);       
                }
            }
            
            Map<String, DedupeResponse__c> appWithDedupResp = new Map<String, DedupeResponse__c>();
            for (DedupeResponse__c dedupResp : [SELECT ID, Name, recordType.Name, ExpiryDate__c, LatestReportTime__c,Applicant__c FROM DedupeResponse__c WHERE LoanAppln__c = :loanApplicationId AND recordType.Name = 'Dedupe' AND IsLatest__c = TRUE]) {
              if (appWithDedupResp.containsKey(dedupResp.Applicant__c)) {
                  if(appWithDedupResp.get(dedupResp.Applicant__c).LatestReportTime__c < dedupResp.LatestReportTime__c){
                      appWithDedupResp.put(dedupResp.Applicant__c,dedupResp);
                  }
              } else {
                  appWithDedupResp.put(dedupResp.Applicant__c,dedupResp);
              }
            }
        system.debug('appWithDedupResp ' + appWithDedupResp);
            For(DedupeResponse__c dedupe: appWithDedupResp.values()){
              if(!devitionSf.contains(String.valueOf(Integer.valueOf(verificationNameToMDT.get(GlobalConstants.Verification_Name_Dedupe).DeviationCode__c))) && dedupe.ExpiryDate__c < system.today()){
                  setOfExpiry.add(verificationNameToMDT.get(GlobalConstants.Verification_Name_Dedupe).VerificationName__c);       
              }        
          } 
            // For(DedupeResponse__c dedupe:[SELECT ID,Name,recordType.Name,ExpiryDate__c From  DedupeResponse__c where LoanAppln__c =:loanApplicationId AND recordType.Name = 'Dedupe' AND IsLatest__c = True AND ExpiryDate__c < Today]){
            //     if(!devitionSf.contains(String.valueOf(verificationNameToMDT.get(GlobalConstants.Verification_Name_Dedupe).DeviationCode__c))){
            //         setOfExpiry.add(verificationNameToMDT.get(GlobalConstants.Verification_Name_Dedupe).VerificationName__c);       
            //     }        
            // } 
            
            For(APIVer__c apiVerfi : [SELECT ID,Name,ExpiryDate__c FROM APIVer__c WHERE LoanAplcn__c =:loanApplicationId AND recordType.Name = 'Watchout' AND IsLatest__c = TRUE AND ExpiryDate__c != NULL AND ExpiryDate__c < Today]){
                if(!devitionSf.contains(String.valueOf(Integer.valueOf(verificationNameToMDT.get(GlobalConstants.Verification_Name_Watchout).DeviationCode__c)))){
                    system.debug('Watchout');
                    setOfExpiry.add(verificationNameToMDT.get(GlobalConstants.Verification_Name_Watchout).VerificationName__c);
                }   
            }
            
            For(HunterVer__c hunter : [SELECT Id,ExpiryDate__c FROM HunterVer__c WHERE LoanAplcn__c =: loanApplicationId AND IsLatest__c = TRUE AND ExpiryDate__c < Today]){
                If(!devitionSf.contains(String.ValueOf(Integer.valueOf(verificationNameToMDT.get(GlobalConstants.Verification_Name_Hunter).DeviationCode__c)))){
                    setOfExpiry.add(verificationNameToMDT.get(GlobalConstants.Verification_Name_Hunter).VerificationName__c);
                }    
            }
            Map<String,PD__c> latestPDMap = new Map<String,PD__c>();
            For(PD__c pdObj : [SELECT ID,ExpiryDate__c,Appl__c,Appl__r.CustProfile__c,PdTyp__c FROM PD__c WHERE LoanAppl__c =:loanApplicationId and CmpltDt__c != NULL ORDER BY CmpltDt__c DESC]){
                //AND ExpiryDate__c < Today
                system.debug('pdObj exDate:'+ pdObj.ExpiryDate__c);
                system.debug('pd today date:' +date.today());
                system.debug('Pd metadat:' +verificationNameToMDT.get(GlobalConstants.Verification_Name_PD).DeviationCode__c);
                if(!latestPDMap.containsKey(pdObj.Appl__c) && pdObj.Appl__r.CustProfile__c != 'Salaried' && pdObj.PdTyp__c.contains('Physical PD')){
                    latestPDMap.put(pdObj.Appl__c,pdObj);     
                    system.debug('latestPDMap:'+latestPDMap.values());

                }
                if(!latestPDMap.containsKey(pdObj.Appl__c) && pdObj.Appl__r.CustProfile__c == 'Salaried'){
                    latestPDMap.put(pdObj.Appl__c,pdObj);                   
                }
               /* If(!devitionSf.contains(verificationNameToMDT.get(GlobalConstants.Verification_Name_PD).Deviation__c)){
                    listOfExpiry.add(verificationNameToMDT.get(GlobalConstants.Verification_Name_PD).VerificationName__c);
                }*/
                
            }
            for(PD__c pdobj : latestPDMap.values()){
                if(pdobj.ExpiryDate__c < date.today()){
                    system.debug('Is Pd Expired');
                    MapOfApplicantToPd.put(pdobj.Appl__c,pdobj);
                    system.debug('MapOfApplicantToPd:'+MapOfApplicantToPd);
                }
                
                
            }
            if(!MapOfApplicantToPd.isEmpty()){
                system.debug('enter in pd');
                system.debug('metadata devaition : '+verificationNameToMDT.get(GlobalConstants.Verification_Name_PD).DeviationCode__c);
                If(!devitionSf.contains(String.ValueOf(Integer.valueOf(verificationNameToMDT.get(GlobalConstants.Verification_Name_PD).DeviationCode__c)))){
                    system.debug('Is Pd contains');
                    setOfExpiry.add(verificationNameToMDT.get(GlobalConstants.Verification_Name_PD).VerificationName__c);
                }
            }
            
            
            for(Bureau__c objBurey : [SELECT ID,LoanApp__c,IsLatest__c,Applicant__r.FullName__c FROM Bureau__c WHERE LoanApp__c =:loanApplicationId AND  IsLatest__c = TRUE AND ExpiryDate__c < TODAY AND ExpiryDate__c != null AND (RecordType.DeveloperName = 'ConsumerBureau' OR  RecordType.DeveloperName = 'CommercialBureau')]){
                 If(!devitionSf.contains(String.ValueOf(Integer.valueOf(verificationNameToMDT.get(GlobalConstants.Verification_Name_Bureau).DeviationCode__c)))){
                    setOfExpiry.add( objBurey.Applicant__r.FullName__c +' : '+ verificationNameToMDT.get(GlobalConstants.Verification_Name_Bureau).VerificationName__c );
                }    
            }
            
            
            system.debug('setOfExpiry:'+setOfExpiry);
            
            if(!setOfExpiry.isEmpty()){
               List<String> listOfExpiry1 = new List<String>(setOfExpiry);
               Return listOfExpiry1;
            }
        }catch(Exception e) {
            System.debug('An exception occurred: ' + e.getMessage());
            System.debug('An exception occurred line number: ' + e.getLineNumber());
            
        }
        
        Return null;
    }
}