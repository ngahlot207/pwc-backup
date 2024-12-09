public class UpdateApiRetriggerTrackerHandler implements TriggerAction.AfterUpdate,TriggerAction.AfterInsert{
    
    public static void afterUpdate(List<APICoutTrckr__c> newList, List<APICoutTrckr__c> oldList) {
        
        Set<String> uniqeKeys = new Set<String>();
        Set<String> apiNames = new Set<String>();
        Set<Id> loanAppIds = new Set<Id>();
        // Set<String> apiNamesHun = new Set<String>();
        //Set<Id> loanAppIdsHun = new Set<Id>();
        Set<Id> appIds = new Set<Id>();
        List<APIRetriggerTracker__c> apiRetriggerTrckrRecrds = new List<APIRetriggerTracker__c>();
        // List<APIRetriggerTracker__c> apiRetriggerTrckrRecrdsHunter = new List<APIRetriggerTracker__c>();
        List<APIRetriggerTracker__c> apiRetriggerTrckrRecrdsToUpdate = new List<APIRetriggerTracker__c>();
        
        Map<String,Set<String>> loanWithAppIds = new Map<String,Set<String>>();
        Map<String,Set<String>> loanWithAppIdsBurea = new Map<String,Set<String>>();
        Map<Id,APICoutTrckr__c> oldRecordsMap = new Map<Id,APICoutTrckr__c>(oldList);
        
        for(APICoutTrckr__c apTracker : newList){
            if(apTracker.LtstRespCode__c == 'Success' && apTracker.CrntStatus__c == 'Completed' 
               && apTracker.LstSucesDtTime__c != oldRecordsMap.get(apTracker.Id).LstSucesDtTime__c) { // Added LstSucesDtTime__c for LAK-8084
                loanAppIds.add(apTracker.LAN__c);
                appIds.add(apTracker.Appl__c);
                if(apTracker.APIName__c == 'Consumer ACK Request' || apTracker.APIName__c == 'Commercial ACK Request' || apTracker.APIName__c == 'Commercial Issue Request' || apTracker.APIName__c == 'Cusomer Issue Request'){
                    apiNames.add('Consumer ACK Request');
                    apiNames.add('Commercial ACK Request');
                }else{
                    apiNames.add(apTracker.APIName__c);
                }
                   
                if(apTracker.APIName__c == 'Email Verification' || apTracker.APIName__c == 'Email Authentication Advanced'){
                    apiNames.add('Email Verification');
                    apiNames.add('Email Authentication Advanced');
                    uniqeKeys.add(apTracker.LAN__c+','+apTracker.Appl__c);
                }else{
                    uniqeKeys.add(apTracker.LAN__c+','+apTracker.Appl__c + ',' + apTracker.APIName__c);
                }
                
                if(apTracker.APIName__c == 'Risk API' || apTracker.APIName__c == 'Screening API'){
                    Set<String> appIdsList = loanWithAppIds.get(apTracker.LAN__c);
                    if(appIdsList == null){
                        appIdsList = new Set<String>();
                    }
                    appIdsList.add(apTracker.Appl__c);
                    loanWithAppIds.put(apTracker.LAN__c,appIdsList);
                }else if(apTracker.APIName__c == 'Consumer ACK Request' || apTracker.APIName__c == 'Commercial ACK Request'){
                    Set<String> appIdsList = loanWithAppIdsBurea.get(apTracker.LAN__c);
                    if(appIdsList == null){
                        appIdsList = new Set<String>();
                    }
                    appIdsList.add(apTracker.Appl__c);
                    loanWithAppIdsBurea.put(apTracker.LAN__c,appIdsList);
                }
            }
            /*else if(apTracker.APIName__c == 'Hunter Token'){
apiNamesHun.add(apTracker.APIName__c);
loanAppIdsHun.add(apTracker.LAN__c);
}*/
        }
        if(loanAppIds != null && loanAppIds.size() > 0){
            apiRetriggerTrckrRecrds = [SELECT Id,IsProcessed__c,APIName__c,LoanApp__c,App__c FROM APIRetriggerTracker__c WHERE LoanApp__c IN :loanAppIds AND (App__c IN : appIds OR App__c = NULL) AND APIName__c IN : apiNames ];
        }
        /* if(loanAppIdsHun != null && loanAppIdsHun.size() > 0){
apiRetriggerTrckrRecrds = [SELECT Id,IsProcessed__c,APIName__c,LoanApp__c,App__c FROM APIRetriggerTracker__c WHERE LoanApp__c IN :loanAppIdsHun AND APIName__c IN : apiNamesHun ];
}*/
        if(apiRetriggerTrckrRecrds != null && apiRetriggerTrckrRecrds.size() > 0){
            
            for(APIRetriggerTracker__c apiRetriggerRecord : apiRetriggerTrckrRecrds){
                 String str;
                if(apiRetriggerRecord.APIName__c == 'Email Verification' || apiRetriggerRecord.APIName__c == 'Email Authentication Advanced'){
                    str = apiRetriggerRecord.LoanApp__c+','+apiRetriggerRecord.App__c;
                }else{
                    str = apiRetriggerRecord.LoanApp__c+','+apiRetriggerRecord.App__c + ',' + apiRetriggerRecord.APIName__c;
                }
                
                //String str = apiRetriggerRecord.LoanApp__c+','+apiRetriggerRecord.App__c + ',' + apiRetriggerRecord.APIName__c;
                
                if(apiRetriggerRecord.APIName__c == 'Consumer ACK Request' || apiRetriggerRecord.APIName__c == 'Commercial ACK Request'
                   || apiRetriggerRecord.APIName__c == 'Commercial Issue Request' || apiRetriggerRecord.APIName__c == 'Cusomer Issue Request'){
                       Set<String> appIdsFromLoan =   loanWithAppIdsBurea.get(apiRetriggerRecord.LoanApp__c);
                       if(appIdsFromLoan != null && appIdsFromLoan.size() > 0 && appIdsFromLoan.contains(apiRetriggerRecord.App__c) || apiRetriggerRecord.App__c == null){
                           APIRetriggerTracker__c apiRtgrTrcrRec = new APIRetriggerTracker__c();  
                           apiRtgrTrcrRec.Id = apiRetriggerRecord.Id;
                           apiRtgrTrcrRec.IsProcessed__c = true; 
                           apiRetriggerTrckrRecrdsToUpdate.add(apiRtgrTrcrRec);
                       }
                   }else{
                       if(uniqeKeys.contains(str)){
                           APIRetriggerTracker__c apiRtgrTrcrRec = new APIRetriggerTracker__c();  
                           apiRtgrTrcrRec.Id = apiRetriggerRecord.Id;
                           if(apiRetriggerRecord.APIName__c == 'Risk API' || apiRetriggerRecord.APIName__c == 'Screening API'){
                               Set<String> appIdsFromLoan =   loanWithAppIds.get(apiRetriggerRecord.LoanApp__c);
                               if(appIdsFromLoan != null && appIdsFromLoan.size() > 0 && appIdsFromLoan.contains(apiRetriggerRecord.App__c) || apiRetriggerRecord.App__c == null){
                                   apiRtgrTrcrRec.IsProcessed__c = true; 
                               }
                           }else{ 
                               apiRtgrTrcrRec.IsProcessed__c = true; 
                           }
                           apiRetriggerTrckrRecrdsToUpdate.add(apiRtgrTrcrRec);
                       }
                   }
            }
        }
        if(apiRetriggerTrckrRecrdsToUpdate != null && apiRetriggerTrckrRecrdsToUpdate.size() > 0){
            update apiRetriggerTrckrRecrdsToUpdate;
        }
    }
    
    public static void afterInsert(List<APICoutTrckr__c> newList) {
        Set<String> uniqeKeys = new Set<String>();
        Set<String> apiNames = new Set<String>();
        Set<Id> loanAppIds = new Set<Id>();
        Set<Id> appIds = new Set<Id>();
        List<APIRetriggerTracker__c> apiRetriggerTrckrRecrds = new List<APIRetriggerTracker__c>();
        List<APIRetriggerTracker__c> apiRetriggerTrckrRecrdsToUpdate = new List<APIRetriggerTracker__c>();
        
        Map<String,Set<String>> loanWithAppIds = new Map<String,Set<String>>();
        Map<String,Set<String>> loanWithAppIdsBurea = new Map<String,Set<String>>();
        
        for(APICoutTrckr__c apTracker : newList){
            if(apTracker.LtstRespCode__c == 'Success' && apTracker.CrntStatus__c == 'Completed') {
                loanAppIds.add(apTracker.LAN__c);
                appIds.add(apTracker.Appl__c);
                if(apTracker.APIName__c == 'Consumer ACK Request' || apTracker.APIName__c == 'Commercial ACK Request' || apTracker.APIName__c == 'Commercial Issue Request' || apTracker.APIName__c == 'Cusomer Issue Request'){
                    apiNames.add('Consumer ACK Request');
                    apiNames.add('Commercial ACK Request');
                }else{
                    apiNames.add(apTracker.APIName__c);
                }
                uniqeKeys.add(apTracker.LAN__c+','+apTracker.Appl__c + ',' + apTracker.APIName__c);
                if(apTracker.APIName__c == 'Risk API' || apTracker.APIName__c == 'Screening API'){
                    Set<String> appIdsList = loanWithAppIds.get(apTracker.LAN__c);
                    if(appIdsList == null){
                        appIdsList = new Set<String>();
                    }
                    appIdsList.add(apTracker.Appl__c);
                    loanWithAppIds.put(apTracker.LAN__c,appIdsList);
                }else if(apTracker.APIName__c == 'Consumer ACK Request' || apTracker.APIName__c == 'Commercial ACK Request'
                         || apTracker.APIName__c == 'Cusomer Issue Request' || apTracker.APIName__c == 'Commercial Issue Request'){
                             Set<String> appIdsList = loanWithAppIdsBurea.get(apTracker.LAN__c);
                             if(appIdsList == null){
                                 appIdsList = new Set<String>();
                             }
                             appIdsList.add(apTracker.Appl__c);
                             loanWithAppIdsBurea.put(apTracker.LAN__c,appIdsList);
                         }
            }
        }
        if(loanAppIds != null && loanAppIds.size() > 0){
            apiRetriggerTrckrRecrds = [SELECT Id,IsProcessed__c,APIName__c,LoanApp__c,App__c FROM APIRetriggerTracker__c WHERE LoanApp__c IN :loanAppIds AND (App__c IN : appIds OR App__c = NULL) AND APIName__c IN : apiNames ];
        }
        
        if(apiRetriggerTrckrRecrds != null && apiRetriggerTrckrRecrds.size() > 0){
            
            for(APIRetriggerTracker__c apiRetriggerRecord : apiRetriggerTrckrRecrds){ 
                String str = apiRetriggerRecord.LoanApp__c+','+apiRetriggerRecord.App__c + ',' + apiRetriggerRecord.APIName__c;
                if(apiRetriggerRecord.APIName__c == 'Consumer a	 Request' || apiRetriggerRecord.APIName__c == 'Commercial ACK Request'
                   || apiRetriggerRecord.APIName__c == 'Cusomer Issue Request' || apiRetriggerRecord.APIName__c == 'Commercial Issue Request'){
                       Set<String> appIdsFromLoan =   loanWithAppIdsBurea.get(apiRetriggerRecord.LoanApp__c);
                       if(appIdsFromLoan != null && appIdsFromLoan.size() > 0 && appIdsFromLoan.contains(apiRetriggerRecord.App__c) || apiRetriggerRecord.App__c == null){
                           APIRetriggerTracker__c apiRtgrTrcrRec = new APIRetriggerTracker__c();  
                           apiRtgrTrcrRec.Id = apiRetriggerRecord.Id;
                           apiRtgrTrcrRec.IsProcessed__c = true; 
                           apiRetriggerTrckrRecrdsToUpdate.add(apiRtgrTrcrRec);
                       }
                   }else{
                       if(uniqeKeys.contains(str)){
                           APIRetriggerTracker__c apiRtgrTrcrRec = new APIRetriggerTracker__c();  
                           apiRtgrTrcrRec.Id = apiRetriggerRecord.Id;
                           if(apiRetriggerRecord.APIName__c == 'Risk API' || apiRetriggerRecord.APIName__c == 'Screening API'){
                               Set<String> appIdsFromLoan =   loanWithAppIds.get(apiRetriggerRecord.LoanApp__c);
                               if(appIdsFromLoan != null && appIdsFromLoan.size() > 0 && appIdsFromLoan.contains(apiRetriggerRecord.App__c) || apiRetriggerRecord.App__c == null){
                                   apiRtgrTrcrRec.IsProcessed__c = true; 
                               }
                           }
                           else{ 
                               apiRtgrTrcrRec.IsProcessed__c = true; 
                           } 
                           apiRetriggerTrckrRecrdsToUpdate.add(apiRtgrTrcrRec);
                       } 
                   }
            }
        }
        if(apiRetriggerTrckrRecrdsToUpdate != null && apiRetriggerTrckrRecrdsToUpdate.size() > 0){
            update apiRetriggerTrckrRecrdsToUpdate;
        }
    }
}