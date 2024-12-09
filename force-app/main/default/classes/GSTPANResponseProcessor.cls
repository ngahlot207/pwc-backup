public class GSTPANResponseProcessor implements IintMsgCalloutResponseProcessor {
    
    public static void process(List<IntgMsg__c> responses){ 
        try {
            Map<IntgMsg__c,GSTPANResponseWrapper> successResponseMap = new Map<IntgMsg__c,GSTPANResponseWrapper>();
            Map<IntgMsg__c,String> failureResponseMap = new Map<IntgMsg__c,String>();
            Set<Id> applicantIds = new Set<Id>();
            for(IntgMsg__c integrationMessage : responses){
                
                try{
                    
                    GSTPANResponseWrapper response = (GSTPANResponseWrapper) JSON.deserialize(integrationMessage.Resp__c, GSTPANResponseWrapper.class);
                    
                    if(integrationMessage.RefObj__c == 'Applicant__c'){
                        applicantIds.add(integrationMessage.RefId__c);
                    }
                    else if(integrationMessage.ParentRefObj__c == 'Applicant__c'){
                        applicantIds.add(integrationMessage.ParentRefId__c);
                    }
                    
                    
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
                    GlobalUtility.logMessage('Error', 'GSTPANResponseProcessor class', 
                                             'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
                    
                }
            }
            
            if(!successResponseMap.isEmpty()){
                processSuccess(applicantIds,successResponseMap);
            }
            if(!failureResponseMap.isEmpty()){
                processFailure(failureResponseMap);
            }
        }
        catch(Exception ex) {
            System.debug('error' + ex.getMessage());
            GlobalUtility.logMessage('Error', 'GSTPANResponseProcessor', 
                                     'Process', NULL, NULL, ex.getMessage() + ' line ' + ex.getLineNumber(), NULL, ex, NULL);
        }
    }
    
    public static void processSuccess(Set<Id> applicantIds,Map<IntgMsg__c,GSTPANResponseWrapper> successResponses){
        
        try{
            
            Map<Id,List<ApplicantEmployment__c>> applEmpMap = new Map<Id,List<ApplicantEmployment__c>>();
            Map<Id,Map<String,ApplGST__c>> applGSTMap = new Map<Id,Map<String,ApplGST__c>>();
            //List<ApplKyc__c> applKycList =new List<ApplKyc__c>();
            List<SObject> updateSObject =new List<SObject>();
            List<ApplicantEmployment__c> applEmpList = new List<ApplicantEmployment__c>();
            List<ApplGST__c> applGSTUpsrtList = new List<ApplGST__c>();
            //List<APIVer__c> apiVerList = new List<APIVer__c>();
            List<IntgMsg__c> createRequestList = new List<IntgMsg__c>();
            Set<Id> existingApplIds = new Set<Id>();
            
            if(!applicantIds.isEmpty()){
                for(ApplicantEmployment__c applEmp : [SELECT Id,LoanApplicant__c, GST_Registered__c FROM ApplicantEmployment__c WHERE LoanApplicant__c IN : applicantIds]){
                    if(applEmpMap.containsKey(applEmp.LoanApplicant__c)){
                        applEmpMap.get(applEmp.LoanApplicant__c).add(applEmp);
                    }
                    else{
                        applEmpMap.put(applEmp.LoanApplicant__c,new List<ApplicantEmployment__c>{applEmp});
                    }
                }
                
                for(ApplGST__c applGST : [Select Id,Applicant__c,GSTIN__c FROM ApplGST__c WHERE Applicant__c IN : applicantIds]){
                    if(applGST.GSTIN__c!=null){
                        if(applGSTMap.containsKey(applGST.Applicant__c)){
                            applGSTMap.get(applGST.Applicant__c).put(applGST.GSTIN__c,applGST);
                        }
                        else{
                            applGSTMap.put(applGST.Applicant__c,new Map<String,ApplGST__c>{applGST.GSTIN__c=>applGST});
                        }
                    }
                }
            }
            if(!successResponses.isEmpty()){
                
                for(IntgMsg__c integrationMessage : successResponses.keySet()){
                    if((integrationMessage.RefId__c!=null && integrationMessage.ParentRefId__c!=null  && integrationMessage.RefObj__c == 'ApplKyc__c') || (integrationMessage.RefObj__c == 'Applicant__c' && integrationMessage.RefId__c!=null) ){
                        GSTPANResponseWrapper response = successResponses.get(integrationMessage);
                        Id applicantId  = integrationMessage.RefObj__c == 'Applicant__c' ? integrationMessage.RefId__c : integrationMessage.ParentRefObj__c == 'Applicant__c' ? integrationMessage.ParentRefId__c : null;
                        
                        if(response!=null){
                            if(response.result!=null && !response.result.isEmpty()){
                                
                                if(applEmpMap.containsKey(applicantId) && !applEmpMap.get(applicantId).isEmpty()){
                                    
                                    for(ApplicantEmployment__c applEmp : applEmpMap.get(applicantId)){
                                        applEmpList.add(new ApplicantEmployment__c(Id = applEmp.Id, GST_Registered__c = 'YES'));
                                    }
                                }
                                else{
                                    if(string.isNotblank(applicantId)){
                                        applEmpList.add(new ApplicantEmployment__c(LoanApplicant__c=applicantId, GST_Registered__c = 'YES'));
                                    }
                                }
                                
                                for(GSTPANResponseWrapper.result result : response.result){
                                    
                                    if(applicantId!=null){
                                        existingApplIds.add(applicantId);
                                        ApplGST__c applGST = (ApplGST__c) assignSobject(result, new ApplGST__c(Applicant__c=applicantId), 'ApplGST__c');
                                        if(applGSTMap.containsKey(applicantId) && applGSTMap.get(applicantId).containsKey(applGST.GSTIN__c)){
                                            applGST.ID = applGSTMap.get(applicantId).get(applGST.GSTIN__c).Id;
                                            applGST.Invalid__c=false;
                                        }
                                        applGSTUpsrtList.add(applGST);
                                    }
                                }
                                
                                
                            }
                            else{
                                if(applEmpMap.containsKey(applicantId) && !applEmpMap.get(applicantId).isEmpty()){
                                    
                                    for(ApplicantEmployment__c applEmp : applEmpMap.get(applicantId)){
                                        applEmpList.add(new ApplicantEmployment__c(Id = applEmp.Id, GST_Registered__c = 'NO'));
                                    }
                                }
                                if(string.isNotblank(applicantId)){
                                        applEmpList.add(new ApplicantEmployment__c(LoanApplicant__c=applicantId, GST_Registered__c = 'NO'));
                                    }
                            }
                            
                            
                            
                            SObject record = Id.valueOf(integrationMessage.RefId__c).getSObjectType().newSObject(Id.valueOf(integrationMessage.RefId__c));
                            record.put('GSTSearchAPIStatus__c',GlobalConstants.MSG_SUCCESS);
                            record.put('GSTSearchAPIErrorMsg__c','');
                            updateSObject.add(record);
                            
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
                    
                }
                
                
                if(!updateSObject.isEmpty()){
                    update updateSObject;
                }
                
                //Applicant Employment
                if(!applEmpList.isEmpty()) {
                   /* fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> {ApplicantEmployment__c.SObjectType});
                    String sObjectName = 'ApplicantEmployment__c';
                    List<String> fieldNamesList = new List<String>{'GST_Registered__c'};
                        Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                    uow.registerDirty(applEmpList);
                    uow.commitWork();*/
                    UPSERT applEmpList;
                }
                
                //Applicant GST
                if(!applGSTUpsrtList.isEmpty()){
                    fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> {ApplGST__c.SObjectType});
                    uow.registerUpsert(applGSTUpsrtList);
                    uow.commitWork();
                    
                    if(!existingApplIds.isEmpty()){
                        List<ApplGST__c> invalidApplGSTList = [Select Id,Invalid__c FROM ApplGST__c WHERE ID NOT IN:applGSTUpsrtList  AND Invalid__c=FALSE AND Applicant__c IN :existingApplIds];
                        if(!invalidApplGSTList.isEmpty()){
                            IntegrationUtility.updateBooleanFlag(invalidApplGSTList, 'Invalid__c', TRUE);
                        }
                    }
                    
                    for(ApplGST__c applGST : [Select Id,Applicant__c from ApplGST__c WHERE ID IN : applGSTUpsrtList]) {
                        IntgMsg__c intMsgRec = new IntgMsg__c();
                        intMsgRec.Name = 'GSP GST Authentication';
                        intMsgRec.BU__c = 'HL / STL';
                        intMsgRec.Status__c = GlobalConstants.INT_MSG_STATUS_NEW;
                        intMsgRec.MStatus__c = GlobalConstants.INT_MSG_MStatus_BLANK;
                        intMsgRec.Svc__c = 'GSP GST Authentication';
                        intMsgRec.RefId__c = applGST.Id;
                        intMsgRec.RefObj__c = 'ApplGST__c';
                        intMsgRec.ParentRefId__c = applGST.Applicant__c;
                        intMsgRec.ParentRefObj__c = 'Applicant__c';
                        intMsgRec.IsActive__c = TRUE;
                        createRequestList.add(intMsgRec);
                        
                    }
                    
                }
                
                //API Verfication
                /*if(!apiVerList.isEmpty()){
                    fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> {APIVer__c.SObjectType});
                    if(!existingApplIds.isEmpty()){
                        List<APIVer__c> existingAPIVerList = [Select Id,IsLatest__c,Appl__c FROM APIVer__c WHERE IsLatest__c=True AND Appl__c IN :existingApplIds AND RecordTypeId =:Schema.SObjectType.APIVer__c.getRecordTypeInfosByName().get('GST').getRecordTypeId()];
                        if(!existingAPIVerList.isEmpty()){
                            IntegrationUtility.updateBooleanFlag(existingAPIVerList, 'IsLatest__c', false);
                        }
                    }
                    
                    uow.registerNew(apiVerList);
                    uow.commitWork();
                }*/
                
                //Integration Message
                if(!createRequestList.isEmpty()){
                    fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> { IntgMsg__c.SObjectType});
                    List<string> fieldNamesList = New List<string>{'Name','BU__c','RefId__c','Status__c','MStatus__c','RefObj__c','Svc__c','ApiVendor__c',
                        'IsActive__c','ParentRefId__c','ParentRefObj__c'};
                            String sObjectName = 'IntgMsg__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkInsert(objType,fieldNamesList); 
                    uow.registerNew(createRequestList);
                    uow.commitWork();
                }
                
            }
        }
        catch(exception ex){
            system.debug('Error message: '+ ex.getMessage() + ' and Line number: ' + ex.getLineNumber());
        }
        
        
    }
    
    public static void processFailure(Map<IntgMsg__c,String> failureResponses){
        
        try{
            
			List<SObject> updateSObject =new List<SObject>();
            
            for(IntgMsg__c integrationMessage : failureResponses.keySet()){
                
                if(integrationMessage.RefId__c!=null){
                    
                    SObject record = Id.valueOf(integrationMessage.RefId__c).getSObjectType().newSObject(Id.valueOf(integrationMessage.RefId__c));
                    record.put('GSTSearchAPIStatus__c',GlobalConstants.MSG_FAILURE);
                    record.put('GSTSearchAPIErrorMsg__c',failureResponses.containsKey(integrationMessage)? failureResponses.get(integrationMessage) : '');
                    updateSObject.add(record);
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
            
            if(!updateSObject.isEmpty()){
                update updateSObject;
            }
            
        }
        catch(exception ex){
            system.debug('Error message: '+ ex.getMessage() + ' and Line number: ' + ex.getLineNumber());
        }
        
    }
    
    public static SObject assignSobject(GSTPANResponseWrapper.result result, SObject recordToUpdate, String objectAPIName) {
        
        try {
            if (result != null && recordToUpdate != null) {
                
                if(result.emailId!=null && String.isNotBlank(result.emailId) && String.isNotBlank(objectAPIName)){
                    recordToUpdate.put('Email__c',result.emailId);
                }
                if(result.applicationStatus!=null && String.isNotBlank(result.applicationStatus)){
                    recordToUpdate.put('ApplStatus__c',result.applicationStatus);
                }
                if(result.mobNum!=null && String.isNotBlank(result.mobNum)){
                    recordToUpdate.put('MobNo__c',result.mobNum);
                }
                if(result.pan!=null && String.isNotBlank(result.pan)){
                    recordToUpdate.put('Pan__c',result.pan);
                }
                if(result.gstinRefId!=null && String.isNotBlank(result.gstinRefId)){
                    recordToUpdate.put('GSTIN_RefId__c',result.gstinRefId);
                }
                if(result.regType!=null && String.isNotBlank(result.regType)){
                    recordToUpdate.put('Reg_Type__c',result.regType);
                }
                if(result.authStatus!=null && String.isNotBlank(result.authStatus)){
                    recordToUpdate.put('GSTIN_Status__c',result.authStatus);
                }
                if(result.gstinId!=null && String.isNotBlank(result.gstinId)){
                    recordToUpdate.put('GSTIN__c',result.gstinId);
                }
                if(result.registrationName!=null && String.isNotBlank(result.registrationName)){
                    recordToUpdate.put('RegistName__c',result.registrationName);
                }
                if(result.tinNumber!=null && String.isNotBlank(result.tinNumber)){
                    recordToUpdate.put('TinNo__c',result.tinNumber);
                }
                
                return recordToUpdate;
            }
        } catch (Exception ex) {
            system.debug('Error message: '+ ex.getMessage() + ' and Line number: ' + ex.getLineNumber());
        }
        return null; 
    }
}