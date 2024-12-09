public class PerfiosAAInitiateConsentRespProcessor implements IintMsgCalloutResponseProcessor{
    
    public static void process(List<IntgMsg__c> responses){ 
        Map<IntgMsg__c,PerfiosAAInitiateConsentResponseWrapper> successResponseMap = new Map<IntgMsg__c,PerfiosAAInitiateConsentResponseWrapper>();
        Map<IntgMsg__c,String> failureResponseMap = new Map<IntgMsg__c,String>();
        Set<Id> refIds = new Set<Id>();
        for(IntgMsg__c integrationMessage : responses){
             try{
                if(integrationMessage.RefId__c!=null){
                    refIds.add(integrationMessage.RefId__c);
                }
                PerfiosAAInitiateConsentResponseWrapper response = PerfiosAAInitiateConsentResponseWrapper.parse(integrationMessage.Resp__c);
                if(response != null){
                    if(response.errorCode!=null){
                        failureResponseMap.put(integrationMessage,(response.errorMessage!=null && String.isNotBlank(response.errorMessage) ? response.errorMessage : response.errorCode));
                    }
                    else{
                        successResponseMap.put(integrationMessage,response);
                    }
                }
            }
            //Exception Handling
            catch(Exception ex){
                failureResponseMap.put(integrationMessage,IntegrationUtility.getCustomErrorMessage(ex.getMessage().substringBefore(':')));
                GlobalUtility.logMessage('Error', 'PerfiosAAInitiateConsentRespProcessor class', 
                                         'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            } 
        }
        
        Map<Id,Applicant__c> applicantMap = new Map<Id,Applicant__c> ([SELECT Id,IntegrationStatus__c,IntegrationErrorMessage__c FROM Applicant__c WHERE ID IN:refIds]);
        if(!successResponseMap.isEmpty()){
            processSuccess(applicantMap,successResponseMap);
        }
        if(!failureResponseMap.isEmpty()){
            processFailure(applicantMap,failureResponseMap);
        }
    }

    public static void processSuccess(Map<Id,Applicant__c> applicantMap,Map<IntgMsg__c,PerfiosAAInitiateConsentResponseWrapper> successResponses){
        try{
            if(!successResponses.isEmpty()){
                APIConfiguration__c config = APIConfiguration__c.getInstance('Perfios AA');
                
                List<Applicant__c> applicantRecords = new List<Applicant__c>();
                List<IntgMsg__c> createRequestList = new List<IntgMsg__c>();
                for(IntgMsg__c integrationMessage : successResponses.keySet()){
                    PerfiosAAInitiateConsentResponseWrapper response = successResponses.get(integrationMessage);
                    if(response!=null){
                        if(applicantMap.containsKey(integrationMessage.RefId__c)){
                            Applicant__c appl =new Applicant__c();
                            appl.Id=integrationMessage.RefId__c;
                            appl.TransactionId__c = response.txnId!=null && String.isNotBlank(response.txnId) ? response.txnId : '';
                            appl.TransactionLink__c = response.redirectURL!=null && String.isNotBlank(response.redirectURL) ? response.redirectURL : '';
                            appl.IntegrationStatus__c = PerfiosAPIController.replaceAndUpdateString('Perfios AA Initiate Consent:', 'Perfios AA Initiate Consent: Success', applicantMap.get(integrationMessage.RefId__c).IntegrationStatus__c, ';');
                            appl.IntegrationErrorMessage__c = PerfiosAPIController.replaceAndUpdateString('Perfios AA Initiate Consent', '', applicantMap.get(integrationMessage.RefId__c).IntegrationErrorMessage__c, ';');
                            appl.AggrLinkExpiryDate__c = (config!=null && config.Threshold__c!=null) ? System.now().addDays(Integer.valueOf(config.Threshold__c)) : null;
                            if(appl.TransactionLink__c!=null ){
                                IntgMsg__c intmsg =new IntgMsg__c();
                                intmsg.Name='Generate Short URL';
                                intmsg.BU__c='HL / STL';
                                intmsg.Status__c='New';
                                intmsg.MStatus__c='Blank';
                                intmsg.Svc__c='Generate Short URL';
                                intmsg.IsActive__c=true;
                                intmsg.RefId__c= integrationMessage.RefId__c;
                                intmsg.RefObj__c= integrationMessage.RefObj__c;
                                createRequestList.add(intmsg);
                            }
                            applicantRecords.add(appl);
                            
                            if(integrationMessage.Trigger_Platform_Event__c){
                                publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                                platformWra.intId = integrationMessage.Id; 
                                platformWra.recId = integrationMessage.RefId__c;
                                platformWra.ServiceName = integrationMessage.Svc__c ;
                                platformWra.Status = integrationMessage.Status__c ;
                                platformWra.success = True;
                                publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
                            }
                            
                            APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Success');
                        }
                    }
                }
                
                if(!applicantRecords.isEmpty()){
                    update applicantRecords;
                    
                    if(!createRequestList.isEmpty()){
                        insert createRequestList;
                    }
                }
                
                
            }
        }
        catch(exception ex){
            system.debug('Error message: '+ ex.getMessage() + ' and Line number: ' + ex.getLineNumber());
        }
        
    }
    
    public static void processFailure(Map<Id,Applicant__c> applicantMap,Map<IntgMsg__c,String> failureResponses){
        try{
            List<Applicant__c> applicantRecords = new List<Applicant__c>();
            for(IntgMsg__c integrationMessage : failureResponses.keySet()){
                if(applicantMap.containsKey(integrationMessage.RefId__c)){
                    Applicant__c appl = new Applicant__c();
                    appl.Id = integrationMessage.RefId__c;
                    appl.Perfios_AA_Status__c = 'Failure';
                    appl.IntegrationStatus__c = PerfiosAPIController.replaceAndUpdateString('Perfios AA Initiate Consent:', 'Perfios AA Initiate Consent: Failure', applicantMap.get(integrationMessage.RefId__c).IntegrationStatus__c, ';');
                    appl.IntegrationErrorMessage__c = PerfiosAPIController.replaceAndUpdateString('Perfios AA Initiate Consent', 'Perfios AA Initiate Consent: ' + failureResponses.get(integrationMessage), applicantMap.get(integrationMessage.RefId__c).IntegrationErrorMessage__c, ';');
                    applicantRecords.add(appl);
                    
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
            }
            if(!applicantRecords.isEmpty()){
                update applicantRecords;
            }
        }
        catch(exception ex){
            system.debug('Error message: '+ ex.getMessage() + ' and Line number: ' + ex.getLineNumber());
        }
        
    }
    
    /*public static void sendSMS(Set<Id> referenceIds){
        try{
            if(!referenceIds.isEmpty()){
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { Task.SObjectType });
                List<Task> tasklist =new List<Task>();
                SMS_Template_Details__mdt smsTemplate = SMS_Template_Details__mdt.getInstance('Perfios_AA_Consent_Template');
                if(smsTemplate!=null){
                    for(Applicant__c appl : [SELECT Id, MobNumber__c,BankingMobNumber__c,isAlternateAggMob__c,TransactionLink__c FROM Applicant__c  WHERE Id IN: referenceIds]){
                        if((appl.MobNumber__c!=null || (appl.isAlternateAggMob__c == 'Y' && appl.BankingMobNumber__c !=null)) && appl.TransactionLink__c!=null && smsTemplate.SMS_Template__c!=null){
                            Id smsRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('SMS').getRecordTypeId();
                            Task taskRec = new Task();
                            taskRec.MobNum__c = appl.isAlternateAggMob__c == 'Y' ? appl.BankingMobNumber__c : appl.MobNumber__c;
                            taskRec.Type = 'SMS Task';
                            taskRec.Subject = 'Perfios SMS Task';
                            taskRec.WhatId = appl.Id;
                            taskRec.Description = smsTemplate.SMS_Template__c.replace('<<__TransactionLink__>>',appl.TransactionLink__c);
                            taskRec.RecordTypeId = smsRecordTypeId;
                            taskRec.Status = 'Completed';
                            tasklist.add(taskRec);
                        } 
                    }
                }
                if(!tasklist.isEmpty()){
                    List<string> fieldNamesList = New List<string>{'MobNum__c','Type','Subject','WhatId','Description','RecordTypeId','Status'};
                        String sObjectName = 'Task';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                    uow.registerNew(tasklist);
                }
                uow.commitWork();
            }
        }
        catch(exception ex){
            system.debug('Error message: '+ ex.getMessage() + ' and Line number: ' + ex.getLineNumber());
        }
    }*/
    
    @AuraEnabled
    public static void createSMSTask(String referenceId){
        
        try{
            SMS_Template_Details__mdt smsTemplate = SMS_Template_Details__mdt.getInstance('Perfios_AA_Consent_Template');
            if(smsTemplate!=null){
                String fieldsToQuery = 'SELECT Id ';
                if(string.isNotBlank(smsTemplate.Recipient_Field__c)){
                    fieldsToQuery += ',' + smsTemplate.Recipient_Field__c;
                }
                if(string.isNotBlank(smsTemplate.Template_Fields__c)){
                    fieldsToQuery += ',' + smsTemplate.Template_Fields__c;
                }
                String query = fieldsToQuery + ' FROM '+ smsTemplate.Recipient_Object__c;
                
                if(String.isNotBlank(smsTemplate.Query_Criteria__c)){
                    query += ' WHERE ' + smsTemplate.Query_Criteria__c.replace('<<__Id__>>','\''+ referenceId + '\'');
                }
                
                List<Object> templateData = Database.Query(query);
                
                if(!templateData.isEmpty()){
                    Applicant__c appl = (Applicant__c) templateData[0];
                    if(appl.ShortURL__c!=null  && (appl.MobNumber__c!=null || (appl.isAlternateAggMob__c == 'Y' && appl.BankingMobNumber__c !=null)) && smsTemplate.SMS_Template__c!=null){
                            List<Task> tasklist =new List<Task>();
                            Id smsRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('SMS').getRecordTypeId();
                            Task taskRec = new Task();
                            taskRec.MobNum__c = appl.isAlternateAggMob__c == 'Y' ? appl.BankingMobNumber__c : appl.MobNumber__c;
                            taskRec.Type = 'SMS Task';
                            taskRec.Subject = 'Perfios SMS Task';
                            taskRec.WhatId = referenceId !=null ? referenceId:'';
                            taskRec.Description = smsTemplate.SMS_Template__c.replace('<<__TransactionLink__>>',appl.ShortURL__c);
                            taskRec.RecordTypeId = smsRecordTypeId;
                            taskRec.Status = 'Completed';
                            tasklist.add(taskRec);
                            
                            if(!tasklist.isEmpty()){
                                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { Task.SObjectType });
                                List<string> fieldNamesList = New List<string>{'MobNum__c','Type','Subject','WhatId','Description','RecordTypeId','Status'};
                                    String sObjectName = 'Task';
                                Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                                fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                                uow.registerNew(tasklist);
                                uow.commitWork();
                            }
                        }
                        else if(appl.TransactionLink__c!=null && String.isNotBlank(appl.TransactionLink__c)){
                            List<IntgMsg__c> createRequestList = new List<IntgMsg__c>();
                            IntgMsg__c intmsg =new IntgMsg__c();
                            intmsg.Name='Generate Short URL';
                            intmsg.BU__c='HL / STL';
                            intmsg.Status__c='New';
                            intmsg.MStatus__c='Blank';
                            intmsg.Svc__c='Generate Short URL';
                            intmsg.IsActive__c=true;
                            intmsg.RefId__c= referenceId;
                            intmsg.RefObj__c='Applicant__c';
                            createRequestList.add(intmsg);
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
                
            } 
        }
        catch(exception ex){
            system.debug('Error message: '+ ex.getMessage() + ' and Line number: ' + ex.getLineNumber());
        }
    }
}