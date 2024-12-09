public class CAMembershipAuthResponseProcessor implements IintMsgCalloutResponseProcessor{
    
    public static void process(List<IntgMsg__c> responses){ 
        
        Map<IntgMsg__c,CAMembershipAuthResponseWrapper> successResponseMap = new Map<IntgMsg__c,CAMembershipAuthResponseWrapper>();
        Map<IntgMsg__c,String> failureResponseMap = new Map<IntgMsg__c,String>();
        Set<Id> refIds = new Set<Id>();
        
        for(IntgMsg__c integrationMessage : responses){
            
            try{
                
                CAMembershipAuthResponseWrapper response = (CAMembershipAuthResponseWrapper) JSON.deserialize(integrationMessage.Resp__c.replace('status-code','statuscode'), CAMembershipAuthResponseWrapper.class);
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
            catch(Exception ex){
                
                failureResponseMap.put(integrationMessage,IntegrationUtility.getCustomErrorMessage(ex.getMessage().substringBefore(':')));
                GlobalUtility.logMessage('Error', 'CAMembershipAuthResponseProcessor class', 
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
    
    public static void processSuccess(Map<Id,Applicant__c> applicantMap,Map<IntgMsg__c,CAMembershipAuthResponseWrapper> successResponses){
        
        try{
            
            if(!successResponses.isEmpty()){
                Id qualificationCheckRecordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByDeveloperName().get('QualificationCheck').getRecordTypeId();
                set<Id> existingApplicantIds = new set<Id>();
                List<APIVer__c> apiVerList = new List<APIVer__c>();
                Map<Id,Applicant__c> updateApplicantMap = new Map<Id,Applicant__c>();
                
                for(IntgMsg__c integrationMessage : successResponses.keySet()){
                    
                    CAMembershipAuthResponseWrapper response = successResponses.get(integrationMessage);
                    if(response!=null && response.result!=null){
                        
                        if(applicantMap.containsKey(integrationMessage.RefId__c)){
                            
                            existingApplicantIds.add(integrationMessage.RefId__c);
                            
                            Applicant__c app =new Applicant__c();
                            app.Id=integrationMessage.RefId__c;
                            app.CAVerStatus__c = 'Verified';
                            updateapplicantMap.put(app.Id,app);
                            
                            APIVer__c apiVer = new APIVer__c();
                            apiVer.Prof_Qualification_Check__c = 'CA Membership Check';
                            apiVer.IntegrationStatus__c = GlobalConstants.MSG_SUCCESS;
                            apiVer.IsLatest__c = True;
                            apiVer.RecordTypeId = qualificationCheckRecordTypeId;
                            
                            apiVer.Appl__c = applicantMap.get(integrationMessage.RefId__c).Id ;
                            apiVer.LoanAplcn__c = applicantMap.get(integrationMessage.RefId__c).LoanAppln__c ;  
                            apiVer.ApplNme__c = applicantMap.get(integrationMessage.RefId__c).FullName__c ;  
                            apiVer.ApplTyp__c = applicantMap.get(integrationMessage.RefId__c).ApplType__c ;  
                            
                            
                            if(response.result.name!=null && String.isNotBlank(response.result.name)){
                                apiVer.Name__c = response.result.name;
                            }
                            if(response.result.address!=null && String.isNotBlank(response.result.address)){
                                apiVer.Address__c = response.result.address;   
                            }
                            if(response.result.gender!=null && String.isNotBlank(response.result.gender)){
                                apiVer.Gender__c = response.result.gender;
                            }
                            if(response.result.AssociateYear!=null && String.isNotBlank(response.result.AssociateYear)){
                                apiVer.QualificationYear__c = response.result.AssociateYear;
                            }
                            if(response.result.Qualification!=null && String.isNotBlank(response.result.Qualification)){
                                apiVer.Qualification__c = response.result.Qualification;
                            }
                            if(response.result.COPStatus!=null && String.isNotBlank(response.result.COPStatus)){
                                apiVer.COPStatus__c = response.result.COPStatus;
                            }
                            if(response.result.FellowYear!=null && String.isNotBlank(response.result.FellowYear)){
                                apiVer.FellowYear__c = response.result.FellowYear;
                            }
                            if(response.result.memberStatus!=null && String.isNotBlank(response.result.memberStatus)){
                                apiVer.MembershipStatus__c = response.result.memberStatus;
                            }
                            if(response.result.mobileNo!=null && String.isNotBlank(response.result.mobileNo)){
                                apiVer.MobNo__c = response.result.mobileNo;
                            }
                            if(response.result.email!=null && String.isNotBlank(response.result.email)){
                                apiVer.Email__c = response.result.email;
                            }
                            apiVerList.add(apiVer);
                            
                            
                        }
                        
                        if(integrationMessage.Trigger_Platform_Event__c){
                            publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                            platformWra.intId = integrationMessage.Id; 
                            platformWra.recId = integrationMessage.ParentRefId__c;
                            platformWra.ServiceName = integrationMessage.Svc__c ;
                            platformWra.Status = integrationMessage.Status__c ;
                            platformWra.success=true;
                            publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
                        }
                        
                        APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Success');
                    }
                    
                }
                
                if(!existingApplicantIds.isEmpty()){
                    List<APIVer__c> existingAPIVerList = [Select Id,IsLatest__c,Appl__c FROM APIVer__c WHERE IsLatest__c=True AND Appl__c IN :existingApplicantIds AND RecordTypeId =:qualificationCheckRecordTypeId AND Prof_Qualification_Check__c = 'CA Membership Check'];
                    if(!existingAPIVerList.isEmpty()){
                        IntegrationUtility.updateBooleanFlag(existingAPIVerList, 'IsLatest__c', false);
                    }
                }
                
                if(!apiVerList.isEmpty()){
                    fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { APIVer__c.SObjectType });
                    List<string> fieldNamesList = New List<string>{'Appl__c','RecordTypeId','LoanAplcn__c','ApplNme__c','ApplTyp__c','IsLatest__c','IntegrationStatus__c','IntegrationErrorMessage__c','Prof_Qualification_Check__c','Name__c','Address__c','Gender__c','QualificationYear__c','Qualification__c','COPStatus__c','FellowYear__c','MembershipStatus__c','MobNo__c','Email__c'};
                        String sObjectName = 'APIVer__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkInsert(objType,fieldNamesList);
                    uow.registerNew(apiVerList);
                    uow.commitWork();
                }
                
                if(!updateApplicantMap.isEmpty()){
                    fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { Applicant__c.SObjectType });
                    uow.registerDirty(updateApplicantMap.values());
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
            
            Id qualificationCheckRecordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByDeveloperName().get('QualificationCheck').getRecordTypeId();
            set<Id> existingApplicantIds = new set<Id>();
            List<APIVer__c> apiVerList = new List<APIVer__c>();
            Map<Id,Applicant__c> updateApplicantMap = new Map<Id,Applicant__c>();
            
            for(IntgMsg__c integrationMessage : failureResponses.keySet()){
                
                if(applicantMap.containsKey(integrationMessage.RefId__c)){
                    
                    existingApplicantIds.add(integrationMessage.RefId__c);
                    
                    Applicant__c app =new Applicant__c();
                    app.Id=integrationMessage.RefId__c;
                    app.CAVerStatus__c = 'Failed';
                    updateApplicantMap.put(app.Id,app);
                    
                    APIVer__c apiVer = new APIVer__c();
                    apiVer.Prof_Qualification_Check__c = 'CA Membership Check';
                    apiVer.IntegrationStatus__c = GlobalConstants.MSG_FAILURE;
                    apiVer.IntegrationErrorMessage__c = failureResponses.containsKey(integrationMessage)? failureResponses.get(integrationMessage) : '';
                    apiVer.IsLatest__c = True;
                    apiVer.RecordTypeId = qualificationCheckRecordTypeId;
                    apiVer.Appl__c = applicantMap.get(integrationMessage.RefId__c).Id ;
                    apiVer.LoanAplcn__c = applicantMap.get(integrationMessage.RefId__c).LoanAppln__c ;  
                    apiVer.ApplNme__c = applicantMap.get(integrationMessage.RefId__c).FullName__c ;  
                    apiVer.ApplTyp__c = applicantMap.get(integrationMessage.RefId__c).ApplType__c ;  
                    
                    apiVerList.add(apiVer);
                    
                    
                }
                
                if(integrationMessage.Trigger_Platform_Event__c){
                    publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                    platformWra.intId = integrationMessage.Id; 
                    platformWra.recId = integrationMessage.ParentRefId__c;
                    platformWra.ServiceName = integrationMessage.Svc__c ;
                    platformWra.Status = integrationMessage.Status__c ;
                    platformWra.errorMessage = failureResponses.containsKey(integrationMessage)? failureResponses.get(integrationMessage) : '';
                    publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
                }
                APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Failure');
            }
            
            if(!existingApplicantIds.isEmpty()){
                List<APIVer__c> existingAPIVerList = [Select Id,IsLatest__c,Appl__c FROM APIVer__c WHERE IsLatest__c=True AND Appl__c IN :existingApplicantIds AND RecordTypeId =:qualificationCheckRecordTypeId AND Prof_Qualification_Check__c = 'CA Membership Check'];
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
            
            if(!updateApplicantMap.isEmpty()){
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { Applicant__c.SObjectType });
                uow.registerDirty(updateApplicantMap.values());
                uow.commitWork();
            }
        }
        catch(exception ex){
            system.debug('Error message: '+ ex.getMessage() + ' and Line number: ' + ex.getLineNumber());
        }
        
    }
    
}