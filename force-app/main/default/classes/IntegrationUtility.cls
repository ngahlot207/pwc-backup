public class IntegrationUtility {
    
    public static void updateBooleanFlag(List<SObject> recordList, String fieldName,Boolean booleanValue){
        
        if(!recordList.isempty()){
            SObjectType sObjectType = recordList.getSObjectType();
            
            List<SObject> recordsToUpdate = new List<SObject>();
            
            for (SObject record : recordList) {
                if (record.get(fieldName) != null) {
                    record.put(fieldName, booleanValue);
                    recordsToUpdate.add(record);
                }
            }
            
            if (!recordsToUpdate.isEmpty()) {
                update recordsToUpdate;
            }
        }
    }
    
    public static string getCustomErrorMessage(string error){
        
        String errorMessage ='';
        if(error!=null && String.isNotBlank(error)){
            if(error.containsIgnoreCase('Unexpected character')){
                errorMessage = 'API Internal Server Error';
            } 
            else if(error.containsIgnoreCase('Illegal unquoted character')){
                errorMessage = 'An error occurred due to a special character in the response';
            }
            else {
                errorMessage = 'An unexpected error has occurred';
            }
        }
        else{
            errorMessage = 'An unexpected error has occurred';
        }
        return errorMessage;
    }
    
    //Format ddmmyyyy(01/06/2022);
    public static Date getConvertedDate(string dateString){
        
        List<String> dateParts = dateString.split('/');
        
        
        Integer month = Integer.valueOf(dateParts[0]);
        Integer day = Integer.valueOf(dateParts[1]);
        Integer year = Integer.valueOf(dateParts[2]);
        
        system.debug(Date.newInstance(year, month, day));
        return Date.newInstance(year, month, day);
    }
    
    
    //Format yyyymmdd(1989-12-13);
    public static Date getConvertedDate2(string dateString){
        
        List<String> dateParts = dateString.split('-');
        
        
        Integer year = Integer.valueOf(dateParts[0]);
        Integer month = Integer.valueOf(dateParts[1]);
        Integer day = Integer.valueOf(dateParts[2]);
        
        system.debug(Date.newInstance(year, month, day));
        return Date.newInstance(year, month, day);
    }
    
    //Format ddmmyyyy(29-09-2010);
    public static Date getConvertedDate3(string dateString){
        
        List<String> dateParts = dateString.split('-');
        
        
        Integer day = Integer.valueOf(dateParts[0]);
        Integer month = Integer.valueOf(dateParts[1]);
        Integer year = Integer.valueOf(dateParts[2]);
        
        system.debug(Date.newInstance(year, month, day));
        return Date.newInstance(year, month, day);
    }
    
    //Format ddmmyyyy(01062022);
    public static Date getDate(string dateString){
        
        Date enquiryDate;
        
        Integer day = Integer.valueOf(dateString.substring(0, 2));
        Integer month = Integer.valueOf(dateString.substring(2, 4));
        Integer year = Integer.valueOf(dateString.substring(4, 8));
        
        enquiryDate= Date.newInstance(year, month, day);
        
        return enquiryDate;
    }
    
    //Format 154246 HMS
    public static Time timeProcess(String timevalue){
        
        Time parsedTime = Time.newInstance(
            Integer.valueOf(timevalue.substring(0, 2)),  // Hours
            Integer.valueOf(timevalue.substring(2, 4)),  // Minutes
            Integer.valueOf(timevalue.substring(4, 6)),  // Seconds
            0 ); 
        
        return parsedTime;
        
    }
    
    //Create Integration Message
    public static Void createIntegrationMessage(string jsonvalue){
        
        if(String.isNotblank(jsonvalue)){
            
            IntegrationRequestWrapper res=(IntegrationRequestWrapper) JSON.deserialize(jsonvalue, IntegrationRequestWrapper.class);
            
            IntgMsg__c msg =new IntgMsg__c();
            
            if(!String.isBlank(res.Name)){
                msg.Name=res.Name;
            }
            if(!String.isBlank(res.Status)){
                msg.Status__c=res.Status;
            }
            if(!String.isBlank(res.MStatus)){
                msg.MStatus__c=res.MStatus;
            }
            if(!String.isBlank(res.BU)){
                msg.BU__c=res.BU;
            }
            if(!String.isBlank(res.RefId)){
                msg.RefId__c=res.RefId;
            }
            if(!String.isBlank(res.RefObj)){
                msg.RefObj__c=res.RefObj;
            }
            if(!String.isBlank(res.ParentRefId)){
                msg.ParentRefId__c=res.ParentRefId;
            }
            if(!String.isBlank(res.ParentObject)){
                msg.ParentRefObj__c=res.ParentObject;
            }
            if(!String.isBlank(res.Svc)){
                msg.Svc__c=res.Svc;
            }
            if(!String.isBlank(res.ApiVendor)){
                msg.ApiVendor__c=res.ApiVendor;
            }
            if(res.IsActive!=null && res.IsActive){
                msg.IsActive__c=res.IsActive;
            }
            if(res.TriggerPlatformEvent!=null && res.TriggerPlatformEvent){
                msg.Trigger_Platform_Event__c=res.TriggerPlatformEvent;
            }
            insert msg;
        }
        
    }
    
    //Integration Request Json Body
    public class IntegrationRequestWrapper{
        public string Name;
        public string Status;
        public string MStatus;
        public string BU;
        public string RefId;
        public string RefObj;
        public string ParentRefId;
        public string ParentObject;
        public string Svc;
        public string ApiVendor;
        public Boolean IsActive;
        public Boolean TriggerPlatformEvent;
    }
    
    
    @AuraEnabled
    public static void sendSMS(Id referenceId){
        if(referenceId!=null){
            SMS_Template_Details__mdt smsTemplate;
            String objectName =referenceId.getSObjectType().getDescribe().getName();
            if(objectName =='ApplIMD__c'){
                smsTemplate = SMS_Template_Details__mdt.getInstance('Paytm_Template');
            }
            else if(objectName =='Payment__c'){
                smsTemplate = SMS_Template_Details__mdt.getInstance('Payment_Paytm_Template');
            }
            else if(objectName == 'Applicant__c'){
                smsTemplate = SMS_Template_Details__mdt.getInstance('Perfios_AA_Consent_Template');
            }
            else if(objectName == 'ApplBanking__c'){
                smsTemplate = [SELECT Recipient_Field__c, Recipient_Object__c, SMS_Template__c, Template_Fields__c, Query_Criteria__c FROM SMS_Template_Details__mdt WHERE DeveloperName ='Perfios_Template'];
            }
            
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
                    
                    if(objectName == 'ApplIMD__c'){
                        ApplIMD__c imd = (ApplIMD__c) templateData[0];
                        if(imd.PaymentGateway__c == 'Paytm'){
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
                        else if(imd.PaymentGateway__c == 'Billdesk'){
                            if(imd.BDShortURL__c!=null && String.isNotBlank(imd.BDShortURL__c)){
                                if(imd.LoanAppln__r.Applicant__r.MobNumber__c!=null && smsTemplate.SMS_Template__c!=null){
                                    List<Task> tasklist =new List<Task>();
                                    
                                    Id smsRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('SMS').getRecordTypeId();
                                    Task taskRec = new Task();
                                    taskRec.MobNum__c = imd.LoanAppln__r.Applicant__r.MobNumber__c;
                                    taskRec.Type = 'SMS Task';
                                    taskRec.Subject = 'BillDesk SMS Task';
                                    taskRec.WhatId = referenceId !=null ? referenceId:'';
                                    taskRec.Description = smsTemplate.SMS_Template__c.replace('<<__PaymentLink__>>',imd.BDShortURL__c).replace('<<__Amt__>>',String.ValueOf(imd.InstrumentAmt__c));
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
                            else if(imd.BDLinkURL__c!=null && String.isNotBlank(imd.BDLinkURL__c)){
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
                    else if(objectName == 'Payment__c'){
                        Payment__c payment = (Payment__c) templateData[0];
                        if(payment.Payment_Gaterway__c == 'Paytm'){
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
                        else if(payment.Payment_Gaterway__c == 'Bill Desk'){
                            if(payment.BDShortURL__c!=null && String.isNotBlank(payment.BDShortURL__c)){
                                if(payment.LoanAppl__r.Applicant__r.MobNumber__c!=null && smsTemplate.SMS_Template__c!=null){
                                    
                                    List<Task> tasklist =new List<Task>();
                                    
                                    Id smsRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('SMS').getRecordTypeId();
                                    Task taskRec = new Task();
                                    taskRec.MobNum__c = payment.LoanAppl__r.Applicant__r.MobNumber__c;
                                    taskRec.Type = 'SMS Task';
                                    taskRec.Subject = 'BillDesk SMS Task';
                                    taskRec.WhatId = referenceId !=null ? referenceId:'';
                                    taskRec.Description = smsTemplate.SMS_Template__c.replace('<<__PaymentLink__>>',payment.BDShortURL__c).replace('<<__Amt__>>',String.ValueOf(payment.TransAmt__c));
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
                            else if(payment.BDLinkURL__c!=null && String.isNotBlank(payment.BDLinkURL__c)){
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
                    else if(objectName == 'Applicant__c'){
                        Applicant__c appl = (Applicant__c) templateData[0];
                        if( appl.ShortURL__c!=null  && (appl.MobNumber__c!=null || (appl.isAlternateAggMob__c == 'Y' && appl.BankingMobNumber__c !=null)) && smsTemplate.SMS_Template__c!=null){
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
                    else if(objectName == 'ApplBanking__c'){
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
        }
    }
}