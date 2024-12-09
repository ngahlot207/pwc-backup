public class PaytmResponseProcessor implements IintMsgCalloutResponseProcessor{
    
    //Implementing the process method
    public static void process(List<IntgMsg__c> responses){ 
        
        for(IntgMsg__c integrationMessage : responses){
            
            if(integrationMessage.Svc__c != 'Paytm'
               && integrationMessage.BU__c != GlobalConstants.INT_MSG_BU_TYPE){
                   throw new processException('Error! This is not the correct service'); 
               }
            try{
                PaytmResponseWrapper responseWrapper = (PaytmResponseWrapper) JSON.deserialize(integrationMessage.Resp__c, PaytmResponseWrapper.class); 
                PaytmRequestWrapper requestWrapper = (PaytmRequestWrapper) JSON.deserialize(integrationMessage.Req__c, PaytmRequestWrapper.class);
                //check if responseWrapper is empty or not                
                if(responseWrapper != null){
                    
                    if(responseWrapper.body.resultInfo.resultCode=='200'){
                        updateRecord(responseWrapper,integrationMessage.RefId__c,integrationMessage.RefObj__c,requestWrapper.Body.linkOrderId);
                        APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Success');
                    }
                    else{
                        updateErrorRecord(responseWrapper,integrationMessage.RefId__c,integrationMessage.RefObj__c);
                        APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Failure');
                    }
                }
            }
            //Exception Handling
            catch(Exception ex){
                GlobalUtility.logMessage('Error', 'PaytmResponseProcessor class', 
                                         'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            } 
        }
    }
    
    public static void updateRecord(PaytmResponseWrapper responseWrapper,Id referenceId,String referenceObject,String OrderId){
        
        
        fflib_SObjectUnitOfWork uow;
        
        if(referenceObject!=null && referenceObject=='ApplIMD__c'){
            uow = new fflib_SObjectUnitOfWork(new List<SObjectType> {ApplIMD__c.SObjectType });
        }
        else if(referenceObject!=null && referenceObject=='Payment__c'){
            uow = new fflib_SObjectUnitOfWork(new List<SObjectType> {Payment__c.SObjectType });
        }
        
        List<SObject> updateRequest = new List<SObject>();
        List<IntgMsg__c> createRequestList = new List<IntgMsg__c>();
        try{
            if(referenceId!=null && referenceObject!=null && OrderId!=null){
                SObject record = (SObject) Type.forName(referenceObject).newInstance();
                record.Id = referenceId;
                
                if(!String.isBlank(OrderId)){
                    record.put('PaytmOrderId__c',OrderId);
                }
                if(!String.isBlank(responseWrapper.body.linkId)){
                    record.put('PaytmLinkId__c',responseWrapper.body.linkId);
                }
                if(!String.isBlank(responseWrapper.body.longUrl)){
                    record.put('PaytmLinkURL__c',responseWrapper.body.longUrl);
                }
                if(!String.isBlank(responseWrapper.body.shortUrl)){
                    record.put('PaytmShortURL__c',responseWrapper.body.shortUrl);
                }
                if(!String.isBlank(responseWrapper.body.expiryDate)){
                    String[] dateValue =responseWrapper.body.expiryDate.split('[/ :]');
                    record.put('PaytmLinkExpiryDate__c',Datetime.newInstance(Integer.valueOf(dateValue[2]), Integer.valueOf(dateValue[1]), Integer.valueOf(dateValue[0]), Integer.valueOf(dateValue[3]), Integer.valueOf(dateValue[4]),Integer.valueOf(dateValue[5])));
                }
                
                record.put('PaytmAPIStatus__c','Success');
                if(responseWrapper.body!=null && responseWrapper.body.resultInfo!=null && !String.isBlank(responseWrapper.body.resultInfo.resultMessage)){
                    record.put('PaytmAPIMessage__c',responseWrapper.body.resultInfo.resultMessage);
                }
                record.put('ShortURL__c','');
                updateRequest.add(record);
                
                IntgMsg__c intmsg =new IntgMsg__c();
                intmsg.Name='Generate Short URL';
                intmsg.BU__c='HL / STL';
                intmsg.Status__c='New';
                intmsg.MStatus__c='Blank';
                intmsg.Svc__c='Generate Short URL';
                intmsg.IsActive__c=true;
                intmsg.RefId__c= referenceId;
                intmsg.RefObj__c= referenceObject;
                createRequestList.add(intmsg);
                
            }
            
            if(updateRequest!=null){
                List<string> fieldNamesList = New List<string>{'PaytmLinkId__c','PaytmLinkURL__c','PaytmShortURL__c','PaytmLinkExpiryDate__c','PaytmOrderId__c','PaytmAPIStatus__c','PaytmAPIMessage__c'};
                    String sObjectName = referenceObject;
                Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkUpdate(objType,fieldNamesList); 
                uow.registerDirty(updateRequest);
            }
            
            
        }
        catch(exception ex){
            system.debug('error message and line number '+ ex.getMessage() + 'line' + ex.getLineNumber());
        }       
        uow.commitWork();
        
        /*if(referenceObject=='ApplIMD__c'){
            createPaytmSMSTask(referenceId);
        }
        else if(referenceObject=='Payment__c'){
            createPaymentPaytmSMSTask(referenceId);
        }*/
        if(!createRequestList.isEmpty()){
            insert createRequestList;
        }        
    }
    
    public static void updateErrorRecord(PaytmResponseWrapper responseWrapper,Id referenceId,String referenceObject){
        
        
        fflib_SObjectUnitOfWork uow;
        
        if(referenceObject!=null && referenceObject=='ApplIMD__c'){
            uow = new fflib_SObjectUnitOfWork(new List<SObjectType> {ApplIMD__c.SObjectType });
        }
        else if(referenceObject!=null && referenceObject=='Payment__c'){
            uow = new fflib_SObjectUnitOfWork(new List<SObjectType> {Payment__c.SObjectType });
        }
        
        List<SObject> updateRequest = new List<SObject>();
        
        try{
            if(referenceId!=null && referenceObject!=null){
                SObject record = (SObject) Type.forName(referenceObject).newInstance();
                record.Id = referenceId;
                record.put('PaytmAPIStatus__c','Failure');
                if(responseWrapper.body!=null && responseWrapper.body.resultInfo!=null && !String.isBlank(responseWrapper.body.resultInfo.resultMessage)){
                    record.put('PaytmAPIMessage__c',responseWrapper.body.resultInfo.resultMessage);
                }
                
                updateRequest.add(record);
                
            }
            
            if(updateRequest!=null){
                List<string> fieldNamesList = New List<string>{'PaytmAPIStatus__c','PaytmAPIMessage__c'};
                    String sObjectName = referenceObject;
                Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkUpdate(objType,fieldNamesList); 
                uow.registerDirty(updateRequest);
            }
            
            
        }
        catch(exception ex){
            system.debug('error message and line number '+ ex.getMessage() + 'line' + ex.getLineNumber());
        }       
        uow.commitWork();
        
    }
    
    //********************************************************************************************************************************************
    @AuraEnabled
    public static void createPaytmSMSTask(String referenceId){
            
        SMS_Template_Details__mdt smsTemplate = SMS_Template_Details__mdt.getInstance('Paytm_Template');
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
                ApplIMD__c imd = (ApplIMD__c) templateData[0];
                if(imd.ShortURL__c!=null && String.isNotBlank(imd.ShortURL__c)){
                    if(imd.LoanAppln__r.Applicant__r.MobNumber__c!=null && smsTemplate.SMS_Template__c!=null){
                        List<Task> tasklist =new List<Task>();
                        
                        Id smsRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('SMS').getRecordTypeId();
                        Task taskRec = new Task();
                        taskRec.MobNum__c = imd.LoanAppln__r.Applicant__r.MobNumber__c;
                        taskRec.Type = 'SMS Task';
                        taskRec.Subject = 'Paytm SMS Task';
                        taskRec.WhatId = referenceId !=null ? referenceId:'';
                        taskRec.Description = smsTemplate.SMS_Template__c.replace('<<__PaymentLink__>>',imd.ShortURL__c).replace('<<__Amt__>>',String.ValueOf(imd.InstrumentAmt__c));
                        taskRec.RecordTypeId = smsRecordTypeId;
                        taskRec.Status = 'Completed';
                        tasklist.add(taskRec);
                        
                        if(tasklist != null){
                            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { Task.SObjectType });
                            List<string> fieldNamesList = New List<string>{'MobNum__c','Type','Subject','WhatId','Description','RecordTypeId','Status'};
                                String sObjectName = 'Task';
                            Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                            fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                            uow.registerNew(tasklist);
                            uow.commitWork();
                        }
                    }
                }
                else if(imd.PaytmLinkURL__c!=null && String.isNotBlank(imd.PaytmLinkURL__c)){
                    List<IntgMsg__c> createRequestList = new List<IntgMsg__c>();
                    IntgMsg__c intmsg =new IntgMsg__c();
                    intmsg.Name='Generate Short URL';
                    intmsg.BU__c='HL / STL';
                    intmsg.Status__c='New';
                    intmsg.MStatus__c='Blank';
                    intmsg.Svc__c='Generate Short URL';
                    intmsg.IsActive__c=true;
                    intmsg.RefId__c= referenceId;
                    intmsg.RefObj__c='ApplIMD__c';
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
    @AuraEnabled
    public static void createPaymentPaytmSMSTask(String referenceId){
        
        SMS_Template_Details__mdt smsTemplate = SMS_Template_Details__mdt.getInstance('Payment_Paytm_Template');
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
                Payment__c payment = (Payment__c) templateData[0];
                
                if(payment.ShortURL__c!=null && String.isNotBlank(payment.ShortURL__c)){
               		if(payment.LoanAppl__r.Applicant__r.MobNumber__c!=null && smsTemplate.SMS_Template__c!=null){
                        
                        List<Task> tasklist =new List<Task>();
                        
                        Id smsRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('SMS').getRecordTypeId();
                        Task taskRec = new Task();
                        taskRec.MobNum__c = payment.LoanAppl__r.Applicant__r.MobNumber__c;
                        taskRec.Type = 'SMS Task';
                        taskRec.Subject = 'Paytm SMS Task';
                        taskRec.WhatId = referenceId !=null ? referenceId:'';
                        taskRec.Description = smsTemplate.SMS_Template__c.replace('<<__PaymentLink__>>',payment.ShortURL__c).replace('<<__Amt__>>',String.ValueOf(payment.TransAmt__c));
                        taskRec.RecordTypeId = smsRecordTypeId;
                        taskRec.Status = 'Completed';
                        tasklist.add(taskRec);
                        
                        if(tasklist != null){
                            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { Task.SObjectType });
                            List<string> fieldNamesList = New List<string>{'MobNum__c','Type','Subject','WhatId','Description','RecordTypeId','Status'};
                                String sObjectName = 'Task';
                            Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                            fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                            uow.registerNew(tasklist);
                            uow.commitWork();
                        }
                    }
                }
                else if(payment.PaytmLinkURL__c!=null && String.isNotBlank(payment.PaytmLinkURL__c)){
                    List<IntgMsg__c> createRequestList = new List<IntgMsg__c>();
                    IntgMsg__c intmsg =new IntgMsg__c();
                    intmsg.Name='Generate Short URL';
                    intmsg.BU__c='HL / STL';
                    intmsg.Status__c='New';
                    intmsg.MStatus__c='Blank';
                    intmsg.Svc__c='Generate Short URL';
                    intmsg.IsActive__c=true;
                    intmsg.RefId__c= referenceId;
                    intmsg.RefObj__c='Payment__c';
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
}