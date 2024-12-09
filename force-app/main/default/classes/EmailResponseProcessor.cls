public class EmailResponseProcessor implements IintMsgCalloutResponseProcessor{
    
    // Implementing the process method
    public static void process(List<IntgMsg__c> responses) { 
        
        Map<IntgMsg__c,EmailResponseWrapper> successResponseMap = new Map<IntgMsg__c,EmailResponseWrapper>();
        Map<IntgMsg__c,String> failureResponseMap = new Map<IntgMsg__c,String>();
        Set<Id> refIds = new Set<Id>();
        
        
        
        // Processing all responses
        for (IntgMsg__c integrationMessage : responses) {
            try {
                EmailResponseWrapper response = (EmailResponseWrapper) JSON.deserialize(integrationMessage.Resp__c.replace('status-code','statuscode'), EmailResponseWrapper.class);
                refIds.add(integrationMessage.RefId__c);
                if(response!=null){
                    if(response.statusCode!=null){
                        if(Integer.valueOf(response.statusCode) == GlobalConstants.karza_Status_101){
                            successResponseMap.put(integrationMessage,response);
                        }
                        else{
                            failureResponseMap.put(integrationMessage,GlobalConstants.karza_Status_Code_Authn_Description.containsKey(Integer.valueOf(response.statusCode))?GlobalConstants.karza_Status_Code_Authn_Description.get(Integer.valueOf(response.statusCode)):'');
                        }
                    }
                    else if(response.status!=null){
                        failureResponseMap.put(integrationMessage,(response.error!=null && String.isNotBlank(response.error) ? response.error : ''));
                    }
                }
            }
            // Exception Handling
            catch (Exception ex) {
                failureResponseMap.put(integrationMessage,IntegrationUtility.getCustomErrorMessage(ex.getMessage().substringBefore(':')));
                GlobalUtility.logMessage('Error', 'EmailResponseProcessor class', 
                                         'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }  
        }  
        
        Map<Id,Applicant__c> applicantMap = new Map<Id,Applicant__c> ([SELECT id,Name,Gender__c,LoanAppln__c,ApplType__c,FullName__c,Constitution__c,CompanyName__c FROM Applicant__c WHERE ID IN:refIds]);
                
        if(!successResponseMap.isEmpty()){
            processSuccess(applicantMap,successResponseMap);
        }
        if(!failureResponseMap.isEmpty()){
            processFailure(applicantMap,failureResponseMap);
        }
    }
    
    
    public static void processSuccess(Map<Id,Applicant__c> applicantMap,Map<IntgMsg__c,EmailResponseWrapper> successResponses){
        
        try{
            
            if(!successResponses.isEmpty()){
                Id emailRecordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByDeveloperName().get('OfficialEmail').getRecordTypeId();
                set<Id> existingApplicantIds = new set<Id>();
                List<APIVer__c> apiVerList = new List<APIVer__c>();
                List<Applicant__c> applicantList = new List<Applicant__c>();
                
                IntgSvcMgmt__mdt svc = IntgSvcMgmt__mdt.getInstance('Email_Verification');
                
                for(IntgMsg__c integrationMessage : successResponses.keySet()){
                    
                    EmailResponseWrapper response = successResponses.get(integrationMessage);
                    if(response!=null && response.result!=null && response.result.data!=null){
                        
                        if(applicantMap.containsKey(integrationMessage.RefId__c)){
                            
                            existingApplicantIds.add(integrationMessage.RefId__c);
                            
                            //Applicant Update
                            Applicant__c app =new Applicant__c();
                            app.Id=integrationMessage.RefId__c;
                            
                             if(String.isNotblank(response.result.data.result) && containsValidStatus(response.result.data.result.tolowercase(),svc.ProcessCode__c.tolowercase())){
                                app.EmailVerified__c=true;
                                app.EmailIDverificationStatus__c = 'Verified';
                                
                            }else{
                                app.EmailVerified__c=false;
                                app.EmailIDverificationStatus__c = 'Failed';
                            }
                            applicantList.add(app);
                            
                            
                            
                            
                            
                            APIVer__c apiVer = new APIVer__c();
                            apiVer.IntegrationStatus__c = GlobalConstants.MSG_SUCCESS;
                            apiVer.IsLatest__c = True;
                            apiVer.RecordTypeId = emailRecordTypeId;
                            
                            apiVer.Appl__c = applicantMap.get(integrationMessage.RefId__c).Id ;
                            apiVer.LoanAplcn__c = applicantMap.get(integrationMessage.RefId__c).LoanAppln__c ;  
                            apiVer.ApplNme__c = applicantMap.get(integrationMessage.RefId__c).FullName__c ;  
                            apiVer.ApplTyp__c = applicantMap.get(integrationMessage.RefId__c).ApplType__c ;  
                            
                            if(response.result.data.disposable!=null){
                                apiVer.Disposable__c = response.result.data.disposable;
                            }
                            if(response.result.data.webmail!=null){
                                apiVer.Webmail__c = response.result.data.webmail;
                            }
                            if(response.result.data.result!=null && String.isNotBlank(response.result.data.result)){
                                apiVer.Result__c = response.result.data.result;
                                if(containsValidStatus(response.result.data.result.tolowercase(),svc.ProcessCode__c.tolowercase())){
                                    apiVer.ValidEmail__c =true;
                                }
                            }
                            if(response.result.data.acceptAll!=null){
                                apiVer.AcceptAll__c = response.result.data.acceptAll;
                            }
                            if(response.result.data.smtpCheck!=null){
                                apiVer.SmtpCheck__c = response.result.data.smtpCheck;
                            }
                            if(response.result.data.regexp!=null){
                                apiVer.RegExp__c = response.result.data.regexp;
                            }
                            if(response.result.data.mxRecords!=null){
                                apiVer.MxRecords__c = response.result.data.mxRecords;
                            }
                            if(response.result.data.email!=null && String.isNotBlank(response.result.data.email)){
                                apiVer.Email__c = response.result.data.email;
                            }
                            if(response.result.data.smtpServer!=null){
                                apiVer.SmtpServer__c = response.result.data.smtpServer;
                            }
                            if(response.result.data.isBlocked!=null){
                                apiVer.IsBlocked__c = response.result.data.isBlocked;
                            }
                            if(response.result.data.reason!=null && String.isNotBlank(response.result.data.reason)){
                                apiVer.Reason__c = response.result.data.reason;
                            }
                            apiVerList.add(apiVer);
                            
                            
                        }
                        
                        if(integrationMessage.Trigger_Platform_Event__c){
                            publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                            platformWra.intId = integrationMessage.Id; 
                            platformWra.recId = integrationMessage.RefId__c;
                            platformWra.ServiceName = integrationMessage.Svc__c ;
                            platformWra.Status = integrationMessage.Status__c ;
                            platformWra.success=true;
                            publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
                        }
                        
                        APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Success');
                    }
                    
                }
                
                if(!existingApplicantIds.isEmpty()){
                    Set<String> recordTypeDeveloperName =New Set<String>{'OfficialEmail','EmailAuthAdvance'};
                    List<APIVer__c> existingAPIVerList = [Select Id,IsLatest__c,Appl__c,RecordType.DeveloperName FROM APIVer__c WHERE IsLatest__c=True AND Appl__c IN :existingApplicantIds AND 
                                                          RecordType.DeveloperName IN:recordTypeDeveloperName];
                    if(!existingAPIVerList.isEmpty()){
                        IntegrationUtility.updateBooleanFlag(existingAPIVerList, 'IsLatest__c', false);
                    }
                }
                
                if(!apiVerList.isEmpty()){
                    fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { APIVer__c.SObjectType });
                    uow.registerNew(apiVerList);
                    uow.commitWork();
                }
                
                if(!applicantList.isEmpty()){
                    fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { Applicant__c.SObjectType });
                    uow.registerDirty(applicantList);
                    uow.commitWork();
                    
                }
            }
            
        }
        catch(exception ex){
            system.debug('Error message: '+ ex.getMessage() + ' and Line number: ' + ex.getLineNumber());
        }
           
    }
    
    public static void processFailure(Map<Id,Applicant__c> applicantMap,Map<IntgMsg__c,String> failureResponses){
        
        try{
            
            Id emailRecordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByDeveloperName().get('OfficialEmail').getRecordTypeId();
            set<Id> existingApplicantIds = new set<Id>();
            List<APIVer__c> apiVerList = new List<APIVer__c>();
             List<Applicant__c> applicantList = new List<Applicant__c>();
            
            for(IntgMsg__c integrationMessage : failureResponses.keySet()){
             	
                if(applicantMap.containsKey(integrationMessage.RefId__c)){
                    
                    existingApplicantIds.add(integrationMessage.RefId__c);
                    
                    
                    Applicant__c app =new Applicant__c();
                    app.Id=integrationMessage.RefId__c;
                    app.EmailVerified__c=false;
                    app.EmailIDverificationStatus__c = 'Failed';
                    applicantList.add(app);                    
                    
                    APIVer__c apiVer = new APIVer__c();
                    apiVer.IntegrationStatus__c = GlobalConstants.MSG_FAILURE;
                    apiVer.IntegrationErrorMessage__c = failureResponses.containsKey(integrationMessage)? failureResponses.get(integrationMessage) : '';
                    apiVer.IsLatest__c = True;
                    apiVer.RecordTypeId = emailRecordTypeId;
                    apiVer.Appl__c = applicantMap.get(integrationMessage.RefId__c).Id ;
                    apiVer.LoanAplcn__c = applicantMap.get(integrationMessage.RefId__c).LoanAppln__c ;  
                    apiVer.ApplNme__c = applicantMap.get(integrationMessage.RefId__c).FullName__c ;  
                    apiVer.ApplTyp__c = applicantMap.get(integrationMessage.RefId__c).ApplType__c ;  
                    
                    apiVerList.add(apiVer);
                    
                    
                }
                
                if(integrationMessage.Trigger_Platform_Event__c){
                    publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                    platformWra.intId = integrationMessage.Id; 
                    platformWra.recId = integrationMessage.RefId__c;
                    platformWra.ServiceName = integrationMessage.Svc__c ;
                    platformWra.Status = integrationMessage.Status__c ;
                    platformWra.errorMessage = failureResponses.containsKey(integrationMessage)? failureResponses.get(integrationMessage) : '';
                    publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
                }
                APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Failure');
            }
            
            if(!existingApplicantIds.isEmpty()){
                     Set<String> recordTypeDeveloperName =New Set<String>{'OfficialEmail','EmailAuthAdvance'};
                    List<APIVer__c> existingAPIVerList = [Select Id,IsLatest__c,Appl__c FROM APIVer__c WHERE IsLatest__c=True AND 
                                                          Appl__c IN :existingApplicantIds AND RecordType.DeveloperName IN:recordTypeDeveloperName];
                    if(!existingAPIVerList.isEmpty()){
                        IntegrationUtility.updateBooleanFlag(existingAPIVerList, 'IsLatest__c', false);
                    }
                }
                
                if(!apiVerList.isEmpty()){
                    fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { APIVer__c.SObjectType });
                    List<string> fieldNamesList = New List<string>{'Appl__c','RecordTypeId','LoanAplcn__c','ApplNme__c','ApplTyp__c','IsLatest__c','IntegrationStatus__c','IntegrationErrorMessage__c'};
                        String sObjectName = 'APIVer__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkInsert(objType,fieldNamesList);
                    uow.registerNew(apiVerList);
                    uow.commitWork();
                }
            
            if(!applicantList.isEmpty()){
                    fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { Applicant__c.SObjectType });
                    uow.registerDirty(applicantList);
                    uow.commitWork();
                }
        }
        catch(exception ex){
            system.debug('Error message: '+ ex.getMessage() + ' and Line number: ' + ex.getLineNumber());
        }
        
    }
    
    
    public Static Boolean containsValidStatus(String responseResult, String validKey){
        
        List<String> statusList = validKey.split(',');
        
        for (String metadataValues : statusList) {
            if (responseResult.contains(metadataValues)) {
                return true;
            }
        }
        return false;
    }
}