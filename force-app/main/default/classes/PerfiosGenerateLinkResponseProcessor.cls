public class PerfiosGenerateLinkResponseProcessor implements IintMsgCalloutResponseProcessor{
    
    public static void process(List<IntgMsg__c> responses){ 
        Map<IntgMsg__c,PerfiosGenerateLinkResponseWrapper> responseMap = new Map<IntgMsg__c,PerfiosGenerateLinkResponseWrapper>();
        Map<IntgMsg__c,String> failureResponseMap = new Map<IntgMsg__c,String>();
        Set<Id> refIds = new Set<Id>();
        for(IntgMsg__c integrationMessage : responses){
            try{
                if(integrationMessage.RefId__c!=null){
                    refIds.add(integrationMessage.RefId__c);
                }
                PerfiosGenerateLinkResponseWrapper responseWrapper = PerfiosGenerateLinkResponseWrapper.parse(integrationMessage.Resp__c);
                if(responseWrapper != null){
                    if(integrationMessage!=null){
                        responseMap.put(integrationMessage,responseWrapper);
                    }
                }
            }
            //Exception Handling
            catch(Exception ex){
                failureResponseMap.put(integrationMessage,IntegrationUtility.getCustomErrorMessage(ex.getMessage().substringBefore(':')));
                GlobalUtility.logMessage('Error', 'PerfiosGenerateLinkResponseProcessor class', 
                                         'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            } 
        }
        
        Map<Id,ApplBanking__c> applBankMap = new Map<Id,ApplBanking__c>([Select Id,IntegrationStatus__c,IntegrationErrorMessage__c from ApplBanking__c where Id IN:refIds]);
        if(!responseMap.isEmpty()){
            processResponses(applBankMap,responseMap);
        }
        if(!failureResponseMap.isEmpty()){
            processFailure(applBankMap,failureResponseMap);
        }
    }
    
    public static void processResponses(Map<Id,ApplBanking__c> applBankMap,Map<IntgMsg__c,PerfiosGenerateLinkResponseWrapper> responseMap){
        
        if(!responseMap.isEmpty()){
            //Map<Id,ApplBanking__c> applBankMap = new Map<Id,ApplBanking__c>([Select Id,IntegrationStatus__c,IntegrationErrorMessage__c from ApplBanking__c where Id IN:refIds]);
            List<ApplBanking__c> appBankList = new List<ApplBanking__c>();
            List<IntgMsg__c> createRequestList = new List<IntgMsg__c>();
            Set<Id> refIds = new Set<Id>();
            for(IntgMsg__c integrationMessage: responseMap.keySet()){
                try{
                    PerfiosGenerateLinkResponseWrapper response = responseMap.get(integrationMessage);
                    if(response != null){
                        if(response.transactionLink!=null){
                            
                            ApplBanking__c appBank = new ApplBanking__c();
                            appBank.Id = integrationMessage.RefId__c;
                            appBank.IntegrationStatus__c = 'Perfios Generate Link: Success'; //PerfiosAPIController.replaceAndUpdateString('Perfios Generate Link: Failure', 'Perfios Generate Link: Success', applBankMap.get(integrationMessage.RefId__c).IntegrationStatus__c, ';');
                            appBank.IntegrationErrorMessage__c = ''; //PerfiosAPIController.replaceAndUpdateString('Perfios Generate Link', '', applBankMap.get(integrationMessage.RefId__c).IntegrationErrorMessage__c, ';');
                            appBank.TransactionId__c = response.transactionLink.perfiosTransactionId;
                            appBank.TransactionLink__c = response.transactionLink.url;
                            if(String.isNotBlank(response.transactionLink.expires)){
                                String[] dateValue = response.transactionLink.expires.split('[- :]');
                                appBank.TransactionExpiryDate__c = Datetime.newInstance(Integer.valueOf(dateValue[0]), Integer.valueOf(dateValue[1]), Integer.valueOf(dateValue[2]), Integer.valueOf(dateValue[3]), Integer.valueOf(dateValue[4]),0);
                            }
                            appBankList.add(appBank);
                            refIds.add(integrationMessage.RefId__c);
                            if(integrationMessage.Trigger_Platform_Event__c){
                                publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                                platformWra.intId = integrationMessage.Id; 
                                platformWra.recId = integrationMessage.RefId__c;
                                platformWra.ServiceName = integrationMessage.Svc__c ;
                                platformWra.Status = integrationMessage.Status__c ;
                                platformWra.success = True;
                                publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
                            }
                            
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
                            
                            APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Success');
                        }
                        else{
                            
                            String errorMessage ='';
                            List<String> errorMessages = new List<String>();
                            if(response.error!=null){
                                if(String.isNotBlank(response.error.message)){
                                    errorMessages.add(response.error.message);
                                }
                                if(response.error.details!=null && !response.error.details.isEmpty()){
                                    for(PerfiosGenerateLinkResponseWrapper.Details detail : response.error.details){
                                        if(detail.message!=null && String.isNotBlank(detail.message)){
                                            errorMessages.add(detail.message);
                                        }
                                    }
                                }
                            }
                            if(!errorMessages.isEmpty()){
                                errorMessage = String.join(errorMessages,',');
                            }
                            
                            
                            ApplBanking__c appBank = new ApplBanking__c();
                            appBank.Id = integrationMessage.RefId__c;
                            appBank.Initiate_Perfios_Status__c = 'Failure';
                            appBank.IntegrationStatus__c = PerfiosAPIController.replaceAndUpdateString('Perfios Generate Link: Success', 'Perfios Generate Link: Failure', applBankMap.get(integrationMessage.RefId__c).IntegrationStatus__c, ';');
                            appBank.IntegrationErrorMessage__c = PerfiosAPIController.replaceAndUpdateString('Perfios Generate Link', 'Perfios Generate Link: ' + errorMessage, applBankMap.get(integrationMessage.RefId__c).IntegrationErrorMessage__c, ';');
                            appBankList.add(appBank);
                            
                            if(integrationMessage.Trigger_Platform_Event__c){
                                publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                                platformWra.intId = integrationMessage.Id; 
                                platformWra.recId = integrationMessage.ParentRefId__c;
                                platformWra.ServiceName = integrationMessage.Svc__c ;
                                platformWra.Status = integrationMessage.Status__c ;
                                platformWra.success = False;
                                platformWra.errorMessage = errorMessage;
                                publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
                            }
                            APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Failure');
                        }
                    }
                }
                catch(exception ex){
                    system.debug('error message and line number '+ ex.getMessage() + 'line' + ex.getLineNumber());
                }
            }
            
            if(!appBankList.isEmpty()){
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { ApplBanking__c.SObjectType });
                List<string> fieldNamesList = New List<string>{'IntegrationStatus__c','IntegrationErrorMessage__c','Initiate_Perfios_Status__c','TransactionId__c','TransactionLink__c','TransactionExpiryDate__c'};
                    String sObjectName = 'ApplBanking__c';
                Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                uow.registerDirty(appBankList);
                uow.commitWork();
            }
            if(!createRequestList.isEmpty()){
                insert createRequestList;
            }
        }
        
    }
    
    public static void processFailure(Map<Id,ApplBanking__c> applBankMap,Map<IntgMsg__c,String> failureResponses){
        
        try{
            
            //Map<Id,ApplBanking__c> applBankMap = new Map<Id,ApplBanking__c>([Select Id,IntegrationStatus__c,IntegrationErrorMessage__c from ApplBanking__c where Id IN:refIds]);
            List<ApplBanking__c> appBankList = new List<ApplBanking__c>();    
            for(IntgMsg__c integrationMessage : failureResponses.keySet()){
                
                ApplBanking__c appBank = new ApplBanking__c();
                appBank.Id = integrationMessage.RefId__c;
                appBank.Initiate_Perfios_Status__c = 'Failure';
                appBank.IntegrationStatus__c = PerfiosAPIController.replaceAndUpdateString('Perfios Generate Link: Success', 'Perfios Generate Link: Failure', applBankMap.get(integrationMessage.RefId__c).IntegrationStatus__c, ';');
                appBank.IntegrationErrorMessage__c = PerfiosAPIController.replaceAndUpdateString('Perfios Generate Link', 'Perfios Generate Link: ' + failureResponses.get(integrationMessage), applBankMap.get(integrationMessage.RefId__c).IntegrationErrorMessage__c, ';');
                appBankList.add(appBank);
                
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
            
            if(!appBankList.isEmpty()){
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { ApplBanking__c.SObjectType });
                List<string> fieldNamesList = New List<string>{'IntegrationStatus__c','IntegrationErrorMessage__c','Initiate_Perfios_Status__c'};
                    String sObjectName = 'ApplBanking__c';
                Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                uow.registerDirty(appBankList);
                uow.commitWork();
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
                SMS_Template_Details__mdt smsTemplate = SMS_Template_Details__mdt.getInstance('Perfios_Template');
                if(smsTemplate!=null){
                    for(ApplBanking__c applBank : [SELECT Id,Appl__r.MobNumber__c, TransactionLink__c FROM ApplBanking__c  WHERE Id IN: referenceIds]){
                        if(applBank.Appl__r.MobNumber__c!=null && applBank.TransactionLink__c!=null && smsTemplate.SMS_Template__c!=null){
                            Id smsRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('SMS').getRecordTypeId();
                            Task taskRec = new Task();
                            taskRec.MobNum__c = applBank.Appl__r.MobNumber__c;
                            taskRec.Type = 'SMS Task';
                            taskRec.Subject = 'Perfios SMS Task';
                            taskRec.WhatId = applBank.Id;
                            taskRec.Description = smsTemplate.SMS_Template__c.replace('<<__TransactionLink__>>',applBank.TransactionLink__c);
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
            
            SMS_Template_Details__mdt smsTemplate = [SELECT Recipient_Field__c, Recipient_Object__c, SMS_Template__c, Template_Fields__c, Query_Criteria__c FROM SMS_Template_Details__mdt WHERE DeveloperName ='Perfios_Template'];
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
                    ApplBanking__c applBank = (ApplBanking__c) templateData[0];
                    if(applBank.ShortURL__c!=null && applBank.Appl__r.MobNumber__c!=null && smsTemplate.SMS_Template__c!=null){
                        List<Task> tasklist =new List<Task>();
                        Id smsRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('SMS').getRecordTypeId();
                        Task taskRec = new Task();
                        taskRec.MobNum__c = applBank.Appl__r.MobNumber__c;
                        taskRec.Type = 'SMS Task';
                        taskRec.Subject = 'Perfios SMS Task';
                        taskRec.WhatId = referenceId !=null ? referenceId:'';
                        taskRec.Description = smsTemplate.SMS_Template__c.replace('<<__TransactionLink__>>',applBank.ShortURL__c).replace('<<__RecipientName__>>',(String.isNotBlank(applBank.Appl__r.FullName__c) ? applBank.Appl__r.FullName__c :'Customer'));
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
                    else if(applBank.TransactionLink__c!=null && String.isNotBlank(applBank.TransactionLink__c)){
                        List<IntgMsg__c> createRequestList = new List<IntgMsg__c>();
                        IntgMsg__c intmsg =new IntgMsg__c();
                        intmsg.Name='Generate Short URL';
                        intmsg.BU__c='HL / STL';
                        intmsg.Status__c='New';
                        intmsg.MStatus__c='Blank';
                        intmsg.Svc__c='Generate Short URL';
                        intmsg.IsActive__c=true;
                        intmsg.RefId__c= referenceId;
                        intmsg.RefObj__c='ApplBanking__c';
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