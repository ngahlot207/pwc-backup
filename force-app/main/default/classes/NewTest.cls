public class NewTest implements IintMsgCalloutResponseProcessor {
    //Implementing the process method
    public static void process(List<IntgMsg__c> responses) { 
        //Processing all responses
        for(IntgMsg__c integrationMessage : responses) {
            if(integrationMessage.Svc__c != GlobalConstants.INT_CONFIG_SERVICE_HUNTER_API_SERVICE
               && integrationMessage.BU__c != GlobalConstants.INT_MSG_BU_TYPE) {
                   throw new processException('Error! This is not the correct service'); 
               }
            try {
                //parse response
                HunterResponseWrapper responseWrapper = (HunterResponseWrapper) JSON.deserialize(integrationMessage.Resp__c, HunterResponseWrapper.class); 
                Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(integrationMessage.Resp__c);
                System.debug('###Response Map-'+responseMap);
                //check if responseWrapper is empty or not
                if(responseWrapper != NULL) {
                    List<String> errorMessages = new List<String>();
                    if(responseWrapper.clientResponsePayload!=null && !responseWrapper.clientResponsePayload.decisionElements.isEmpty()){
                        
                        if(responseWrapper.clientResponsePayload.decisionElements[0]!=null ){
                            
                            if(!responseWrapper.clientResponsePayload.decisionElements[0].warningsErrors.isEmpty()){
                                for(HunterResponseWrapper.WarningsErrors warningError : responseWrapper.clientResponsePayload.decisionElements[0].warningsErrors){
                                    if(warningError.responseType=='ERROR' && String.isNotBlank(warningError.responseMessage)){
                                        errorMessages.add(warningError.responseMessage);
                                    }
                                }
                            }
                            if(!errorMessages.isEmpty()){
                                
                                HunterRequestWrapper requestWrapper = (HunterRequestWrapper) JSON.deserialize(integrationMessage.Req__c, HunterRequestWrapper.class);
                                DateTime requestTime = DateTime.Valueof(requestWrapper.header.messageTime.replace('T', ' '));
                                String resType = 'ERROR';
                                String msg = String.join(errorMessages,',');
                                String clientId = responseWrapper.responseHeader.clientReferenceId;
                                DateTime responseTime = DateTime.Valueof(responseWrapper.responseHeader.messageTime.replace('T', ' '));
                                hunterVerificationErrorRecord(resType, msg, responseTime, requestTime, integrationMessage.RefId__c, integrationMessage.RefObj__c, clientId, integrationMessage);
                            }
                            else{
                                if(responseWrapper.clientResponsePayload.decisionElements[0].otherData!=null && responseWrapper.clientResponsePayload.decisionElements[0].otherData.response!=null && responseWrapper.clientResponsePayload.decisionElements[0].otherData.response.matchSummary!=null){
                                    Integer matchesVar = responseWrapper.clientResponsePayload.decisionElements[0].otherData.response.matchSummary.matches;
                                    List<String> matchedNamesList = new List<String>();
                                    String matchedNames='';
                                    if(matchesVar != NULL && matchesVar != 0) {
                                        if(!responseWrapper.clientResponsePayload.decisionElements[0].matches.isEmpty()){
                                            for(HunterResponseWrapper.Matches match : responseWrapper.clientResponsePayload.decisionElements[0].matches){
                                                if(String.isNotBlank(match.name)){
                                                    matchedNamesList.add(match.name);
                                                }
                                            }
                                            if(!matchedNamesList.isEmpty()){
                                                matchedNames = String.join(matchedNamesList,',');
                                            }
                                        }
                                    }
                                    DateTime responseTime = DateTime.Valueof(responseWrapper.responseHeader.messageTime.replace('T', ' '));
                                    DateTime requestTime = DateTime.Valueof(responseWrapper.originalRequestData.application.originalRequestTime.replace('T', ' '));
                                    String msg = responseWrapper.responseHeader.responseMessage;
                                    String clientId = responseWrapper.responseHeader.clientReferenceId;
                                    hunterVerificationRecord(matchesVar, matchedNames, responseTime, requestTime, integrationMessage.RefId__c, integrationMessage.RefObj__c, msg, clientId, integrationMessage);
                                }
                            }
                        }
                        
                    }
                    
                } 
            }
            //Exception Handling
            catch(Exception ex){
                GlobalUtility.logMessage('Error', 'HunterResponseProcsessor', 
                                         'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }  
            
        } 
    }
    public static void hunterVerificationRecord(Integer matchesVar, String matchedNames, DateTime resTime, DateTime reqTime, String refId, String refObj, String resMsg, String clientId, IntgMsg__c integrationMessage) {
        try {
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { HunterVer__c.SObjectType });
            List<Id> applIds = new List<Id>();
            List<HunterVer__c> newhunterVerRecToInsert = new List<HunterVer__c>();
            Id loanApplId;
            String matchedOrNot;
            
            if(refObj == 'Applicant__c') {
                applIds.addAll(refId.split(','));
            }   
            else if(refObj == 'LoanAppl__c') {
                loanApplId = refId;
            }
            
            List<LoanAppl__c> loanApplList = new List<LoanAppl__c>();
            if(!applIds.isEmpty()) {
                loanApplList = [SELECT Id, (SELECT Id FROM Applicants__r WHERE ApplType__c = 'P') FROM LoanAppl__c WHERE Id IN (SELECT LoanAppln__c FROM Applicant__c WHERE Id IN : applIds)];
            }
            else if(loanApplId != NULL) {
                loanApplList = [SELECT Id, (SELECT Id FROM Applicants__r WHERE ApplType__c = 'P') FROM LoanAppl__c WHERE Id =: loanApplId];
            }
            //List<Applicant__c> applList = [SELECT Id, LoanAppln__c FROM Applicant__c WHERE ID IN :applIds OR LoanAppln__c =:loanApplId];
            
            if(!loanApplList.isEmpty()) {
                //String loanAppId;
                List<Id> LAList = new List<Id>();
                for(LoanAppl__c temp : loanApplList) {
                    Id applyId;
                    if(!temp.Applicants__r.isEmpty()) {
                        applyId = temp.Applicants__r[0].Id;
                    }
                    HunterVer__c newHunterVerRec = new HunterVer__c();
                    newHunterVerRec.LoanAplcn__c = temp.Id;
                    newHunterVerRec.Appl__c = applyId;
                    if(matchesVar == 0) {
                        matchedOrNot = 'No Match'; 
                    }
                    else if(matchesVar == 1) {
                        matchedOrNot = 'Match';  
                    }   
                    newHunterVerRec.ResTime__c = resTime;
                    newHunterVerRec.ReqTime__c = reqTime;
                    newHunterVerRec.IntegrationStatus__c = 'Success';
                    newHunterVerRec.IntegrationErrorMessage__c = resMsg;
                    newHunterVerRec.HunMatchSta__c = matchedOrNot;
                    newHunterVerRec.IsLatest__c = true;
                    if(String.isNotBlank(clientId)) {
                        newHunterVerRec.ClientReferenceId__c = clientId;
                    }
                    
                    if(String.isNotBlank(matchedNames)) {
                        newHunterVerRec.HunStaWheMatFound__c = matchedNames.removeEnd(','); 
                    }   
                    
                    newhunterVerRecToInsert.add(newHunterVerRec);
                    LAList.add(temp.Id);
                }
                if(!LAList.isEmpty()) {
                    updateOldHunterVerificationRecords(LAList);
                }
            }
            
            if(!newhunterVerRecToInsert.isEmpty()) {
                List<string> fieldNamesList = New List<string>{ 'LoanAplcn__c', 'ResTime__c', 'ReqTime__c', 'HunMatchSta__c', 'IsLatest__c', 'ClientReferenceId__c', 'IntegrationStatus__c', 'IntegrationErrorMessage__c', 'Appl__c', 'HunStaWheMatFound__c' };
                    String sObjectName = 'HunterVer__c';
                Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkInsert(objType,fieldNamesList);
                uow.registerNew(newhunterVerRecToInsert);
                uow.commitWork();
            }
            
        }
        catch(Exception ex){
            GlobalUtility.logMessage('Error', 'HunterResponseProcsessor', 'hunterVerificationRecord', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        } 
        APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Success');
        if(integrationMessage.Trigger_Platform_Event__c) {
            publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
            platformWra.intId = integrationMessage.Id; 
            platformWra.recId = integrationMessage.ParentRefId__c;
            platformWra.ServiceName = integrationMessage.Svc__c ;
            platformWra.Status = integrationMessage.Status__c ;
            platformWra.success=true;
            publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
        }
    }
    
    public static void hunterVerificationErrorRecord(String resType, String resMsg, DateTime resTime, DateTime reqTime, String refId, String refObj, String clientId, IntgMsg__c integrationMessage) {
        try {
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { HunterVer__c.SObjectType });
            List<Id> applIds = new List<Id>();
            List<HunterVer__c> newhunterVerRecToInsert = new List<HunterVer__c>();
            Id loanApplId;
            
            if(refObj == 'Applicant__c') 
                applIds.addAll(refId.split(','));
            else if(refObj == 'LoanAppl__c')
                loanApplId = refId;
            
            List<LoanAppl__c> loanApplList = new List<LoanAppl__c>();
            if(!applIds.isEmpty()) {
                loanApplList = [SELECT Id, (SELECT Id FROM Applicants__r WHERE ApplType__c = 'P') FROM LoanAppl__c WHERE Id IN (SELECT LoanAppln__c FROM Applicant__c WHERE Id IN : applIds)];
            }
            else if(loanApplId != NULL) {
                loanApplList = [SELECT Id, (SELECT Id FROM Applicants__r WHERE ApplType__c = 'P') FROM LoanAppl__c WHERE Id =: loanApplId];
            }
            //List<Applicant__c> applList = [SELECT Id, LoanAppln__c FROM Applicant__c WHERE ID IN :applIds OR LoanAppln__c =:loanApplId];
            
            if(!loanApplList.isEmpty()) {
                List<Id> LAList = new List<Id>();
                for(LoanAppl__c temp : loanApplList) {
                    Id applyId;
                    if(!temp.Applicants__r.isEmpty()) {
                        applyId = temp.Applicants__r[0].Id;
                    }
                    HunterVer__c newHunterVerRec = new HunterVer__c();
                    newHunterVerRec.LoanAplcn__c = temp.Id;
                    newHunterVerRec.Appl__c = applyId;
                    newHunterVerRec.ResTime__c = resTime;
                    newHunterVerRec.ReqTime__c = reqTime;
                    newHunterVerRec.IsLatest__c = true;
                    if(String.isNotBlank(clientId)) {
                        newHunterVerRec.ClientReferenceId__c = clientId;
                    }
                    newHunterVerRec.IntegrationStatus__c = 'Failure';
                    newHunterVerRec.IntegrationErrorMessage__c = resMsg;
                    newHunterVerRec.IsLatest__c = true;
                    newhunterVerRecToInsert.add(newHunterVerRec);
                    LAList.add(temp.Id);
                }
                if(!LAList.isEmpty()) {
                    updateOldHunterVerificationRecords(LAList);
                }
            }
            
            if(!newhunterVerRecToInsert.isEmpty()) {
                List<string> fieldNamesList = New List<string>{ 'LoanAplcn__c', 'ResTime__c', 'ReqTime__c', 'HunMatchSta__c', 'IsLatest__c', 'ClientReferenceId__c', 'IntegrationStatus__c', 'IntegrationErrorMessage__c', 'Appl__c' };
                    String sObjectName = 'HunterVer__c';
                Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkInsert(objType,fieldNamesList);
                uow.registerNew(newhunterVerRecToInsert);
                uow.commitWork();
            }
        }
        catch(Exception ex){
            GlobalUtility.logMessage('Error', 'HunterResponseProcsessor', 'hunterVerificationErrorRecord', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        } 
        APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Failure');
        if(integrationMessage.Trigger_Platform_Event__c) {
            publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
            platformWra.intId = integrationMessage.Id; 
            platformWra.recId = integrationMessage.ParentRefId__c;
            platformWra.ServiceName = integrationMessage.Svc__c ;
            platformWra.Status = integrationMessage.Status__c ;
            platformWra.errorMessage = resMsg;
            publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
        }
    }
    
    public static void updateOldHunterVerificationRecords(List<Id> LAList) {
        try {
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { HunterVer__c.SObjectType });
            List<HunterVer__c> hunterVerRecsToUpdate = [SELECT Id, IsLatest__c FROM HunterVer__c WHERE LoanAplcn__c IN : LAList];
            
            if(!hunterVerRecsToUpdate.isEmpty()) {
                for(HunterVer__c tempRec : hunterVerRecsToUpdate) {
                    tempRec.IsLatest__c = false;
                }
                String sObjectName = 'HunterVer__c';
                List<String> fieldNamesList = new List<String>{ 'IsLatest__c' };
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                uow.registerDirty(hunterVerRecsToUpdate);
                uow.commitWork();
            }
        }
        catch(Exception ex){
            GlobalUtility.logMessage('Error', 'HunterResponseProcsessor', 'updateOldHunterVerificationRecords', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        } 
    }
}