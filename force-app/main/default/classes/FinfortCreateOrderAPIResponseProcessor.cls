public class FinfortCreateOrderAPIResponseProcessor implements IintMsgCalloutResponseProcessor {
    
    public static void process(List<IntgMsg__c> responses) {
        
        if(!responses.isEmpty()){
            
            Map<IntgMsg__c,FinfortCreateOrderAPIResponseWrapper> successResponseMap = new Map<IntgMsg__c,FinfortCreateOrderAPIResponseWrapper>();
            Map<IntgMsg__c,String> failureResponseMap = new Map<IntgMsg__c,String>();
            
            for(IntgMsg__c intmsg :responses){
                
                if(String.isNotblank(intmsg.Resp__c)){
                    
                    try{
                        
                        FinfortCreateOrderAPIResponseWrapper  res =(FinfortCreateOrderAPIResponseWrapper) JSON.deserialize(intmsg.Resp__c,FinfortCreateOrderAPIResponseWrapper.class);
                        
                        if(res!=null){
                            successResponseMap.put(intmsg,res);
                        }
                        
                    }catch(Exception ex){
                        GlobalUtility.logMessage('Error', 'FinfortCreateOrderAPIResponseProcessor class',
                        'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
                        failureResponseMap.put(intmsg,IntegrationUtility.getCustomErrorMessage(ex.getMessage().substringBefore(':')));
                    }
                    
                }
            }
            
            if(!successResponseMap.isEmpty()){
                processResponse(successResponseMap);
            }
            
            if(!failureResponseMap.isEmpty()){
                processFailure(failureResponseMap);
            }
        }
    }
    //******************************************************************************************************************************************
    public static void processResponse(Map<IntgMsg__c,FinfortCreateOrderAPIResponseWrapper> successResp){
        
        try{
            List<Applicant_Financial__c> appfinancialList =new List<Applicant_Financial__c>();
            Map<Id,List<ApplGST__c>> applGstMap=new Map<Id,List<ApplGST__c>>();
            
            Map<Id,List<String>> getExcistingRecordMap =new Map<Id,List<String>>();
            
            Id balanceSheetrecordTypeId = Schema.SObjectType.Applicant_Financial__c.getRecordTypeInfosByDeveloperName().get('Balance_Sheet').getRecordTypeId();
            Id profitLossrecordTypeId = Schema.SObjectType.Applicant_Financial__c.getRecordTypeInfosByDeveloperName().get('Profit_Loss').getRecordTypeId();
            Id gstrecordTypeId = Schema.SObjectType.Applicant_Financial__c.getRecordTypeInfosByDeveloperName().get('GST').getRecordTypeId();
            
            //Getting Applicant ID
            for(IntgMsg__c intmsg:successResp.keyset()){
                
                if(intmsg.Svc__c=='Create Order - ITR' && String.isNotblank(intmsg.RefId__c)){
                    getExcistingRecordMap.put(intmsg.RefId__c,new List<String>{'Profit_Loss','Balance_Sheet'});
                }
                else if(intmsg.Svc__c=='Create Order - GST' && String.isNotblank(intmsg.RefId__c)){
                    getExcistingRecordMap.put(intmsg.RefId__c,new List<String>{'GST'});
                }
                
            }
            
            //updating Islatest  to false
            if(!getExcistingRecordMap.isEmpty()){
                
                Set<String> recordTypeNames = new Set<String>();
                for (List<String> names : getExcistingRecordMap.values()) {
                    recordTypeNames.addAll(names);
                }
                
                List<Applicant_Financial__c> fincal=[Select Id,Loan_Applicant__c,RecordType.DeveloperName,IsLatest__c from Applicant_Financial__c 
                                                     Where Loan_Applicant__c IN:getExcistingRecordMap.keyset() AND 
                                                     RecordType.DeveloperName IN:recordTypeNames];
                
                if(!fincal.isEmpty()){
                    IntegrationUtility.updateBooleanFlag(fincal,'IsLatest__c',False);
                }
            }
            
            //List Of GST
            for(ApplGST__c gst:[Select Id,Applicant__c,GSTIN__c from ApplGST__c Where Applicant__c IN:getExcistingRecordMap.keySet() 
                                        AND (GSTIN__c!=null OR GSTIN__c!='')]){
                
                if(applGstMap.containskey(gst.Applicant__c)){
                    
                    applGstMap.get(gst.Applicant__c).add(gst);
                    
                }else{
                    
                    applGstMap.put(gst.Applicant__c,new list<ApplGST__c>{gst});
                    
                }
            }
            
            
            //Processing IntgMsg__c
            for(IntgMsg__c intmsg:successResp.keyset()){
                
                FinfortCreateOrderAPIResponseWrapper response =successResp.get(intmsg);
                
                if(String.isNotblank(intmsg.RefId__c) && intmsg.Svc__c=='Create Order - ITR'){
                    
                    //Balance Sheet
                    appfinancialList.add(createApplicantFinancialSuccess(intmsg.RefId__c,response,balanceSheetrecordTypeId,'Finfort ITR'));
                    /*Applicant_Financial__c af =new Applicant_Financial__c();
                    af.Loan_Applicant__c=intmsg.RefId__c;
                    af.IsLatest__c=true;
                    af.RecordTypeId=balanceSheetrecordTypeId;
                    af.Type__c='Finfort ITR';
                    
                    if(response.statusCode!=null){
                        af.FinFortAPIStatus__c=apiStatusMap.containsKey(response.statusCode)?apiStatusMap.get(response.statusCode):'';
                    }
                    
                    if(String.isNotblank(response.msg)){
                        af.FinFortMess__c=response.msg;
                    }
                    
                    if(response.data!=null && String.isNotblank(response.data.ffOrderId)){
                        af.FinFortOrderId__c=response.data.ffOrderId;
                    }
                    
                    if(response.data!=null && String.isNotblank(response.data.consent_link)){
                        af.FinFortConsentLink__c=response.data.consent_link;
                    }
                    
                    appfinancialList.add(af);*/
                        
                    //Profit And Loss
                    appfinancialList.add(createApplicantFinancialSuccess(intmsg.RefId__c,response,profitLossrecordTypeId,'Finfort ITR'));
                    
                    /*Applicant_Financial__c fin =new Applicant_Financial__c();
                    fin.Loan_Applicant__c=intmsg.RefId__c;
                    fin.IsLatest__c=true;
                    fin.RecordTypeId=profitLossrecordTypeId;
                    fin.Type__c='Finfort ITR';
                    
                    if(response.statusCode!=null){
                        fin.FinFortAPIStatus__c=apiStatusMap.containsKey(response.statusCode)?apiStatusMap.get(response.statusCode):'';
                    }
                    
                    if(String.isNotblank(response.msg)){
                        fin.FinFortMess__c=response.msg;
                    }
                    
                    if(response.data!=null && String.isNotblank(response.data.ffOrderId)){
                        fin.FinFortOrderId__c=response.data.ffOrderId;
                    }
                    
                    if(response.data!=null && String.isNotblank(response.data.consent_link)){
                        fin.FinFortConsentLink__c=response.data.consent_link;
                    }
                    
                    appfinancialList.add(fin);*/
                        
                    
                }
                
                if(String.isNotblank(intmsg.RefId__c) && intmsg.Svc__c=='Create Order - GST' && 
                   applGstMap.containsKey(intmsg.RefId__c)){
                     
                    List<ApplGST__c>  gstList =applGstMap.get(intmsg.RefId__c);

                    if(!gstList.isEmpty()){

                        for(ApplGST__c gst:gstList){
                            
                            //GST
                            Applicant_Financial__c appFin=createApplicantFinancialSuccess(intmsg.RefId__c,response,gstrecordTypeId,'Finfort GST');
                            appFin.GSTIN__c=gst.GSTIN__c;

                            appfinancialList.add(appFin);
                        }

                    }

                    
                    //GST
                    //appfinancialList.add(createApplicantFinancialSuccess(intmsg.RefId__c,response,gstrecordTypeId,'Finfort GST'));
                    
                }
                
                //API Call out Tracker
                if(response.statusCode!=null && response.statusCode==1){
                    APICalloutTracker.update_ApiTrackerWithIntMsg(intmsg.Id,intmsg.Svc__c, intmsg.ParentRefId__c, 'Success');
                }else{
                    APICalloutTracker.update_ApiTrackerWithIntMsg(intmsg.Id,intmsg.Svc__c, intmsg.ParentRefId__c, 'Failure');
                }
            }
            
            
            if(!appfinancialList.isEmpty()){
                
                Insert appfinancialList;
            }
            
        }catch (Exception ex) {
            GlobalUtility.logMessage('Error', 'FinfortCreateOrderAPIResponseProcessor',
            'processResponse', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
    }
    //******************************************************************************************************************************************
    public static void processFailure(Map<IntgMsg__c,String> failureResp){
        
        try{
            
            if(!failureResp.isEmpty()){
                
                List<Applicant_Financial__c> appfinancialList =new List<Applicant_Financial__c>();
                Map<Id,Set<String>> getExcistingRecordMap =new Map<Id,Set<String>>();
                
                Id balanceSheetrecordTypeId = Schema.SObjectType.Applicant_Financial__c.getRecordTypeInfosByDeveloperName().get('Balance_Sheet').getRecordTypeId();
                Id profitLossrecordTypeId = Schema.SObjectType.Applicant_Financial__c.getRecordTypeInfosByDeveloperName().get('Profit_Loss').getRecordTypeId();
                Id gstrecordTypeId = Schema.SObjectType.Applicant_Financial__c.getRecordTypeInfosByDeveloperName().get('GST').getRecordTypeId();
                
                //Getting Applicant ID
                for(IntgMsg__c intmsg:failureResp.keyset()){
                    
                    if(intmsg.Svc__c=='Create Order - ITR' && String.isNotblank(intmsg.RefId__c)){
                        getExcistingRecordMap.put(intmsg.RefId__c,new Set<String>{'Profit_Loss','Balance_Sheet'});
                    }
                    else if(intmsg.Svc__c=='Create Order - GST' && String.isNotblank(intmsg.RefId__c)){
                        getExcistingRecordMap.put(intmsg.RefId__c,new Set<String>{'GST'});
                    }
                    
                }
                
                //updating Islatest  to false
                if(!getExcistingRecordMap.isEmpty()){
                    
                    Set<String> recordTypeNames = new Set<String>();
                    for (Set<String> names : getExcistingRecordMap.values()) {
                        recordTypeNames.addAll(names);
                    }
                    
                    List<Applicant_Financial__c> fincal=[Select Id,Loan_Applicant__c,RecordType.DeveloperName,IsLatest__c from Applicant_Financial__c 
                                                         Where Loan_Applicant__c IN:getExcistingRecordMap.keyset() AND 
                                                         RecordType.DeveloperName IN:recordTypeNames];
                    
                    if(!fincal.isEmpty()){
                        IntegrationUtility.updateBooleanFlag(fincal,'IsLatest__c',False);
                    }
                }
                
                
                //Processing IntgMsg__c
                for(IntgMsg__c intmsg:failureResp.keyset()){
                    
                    if(String.isNotblank(intmsg.RefId__c) && intmsg.Svc__c=='Create Order - ITR'){
                        
                        //Balance Sheet
                        appfinancialList.add(createApplicantFinancialFailure(intmsg.RefId__c,failureResp.get(intmsg),balanceSheetrecordTypeId,'Finfort ITR'));
                        
                        /* Applicant_Financial__c af =new Applicant_Financial__c();
                        af.Loan_Applicant__c=intmsg.RefId__c;
                        af.IsLatest__c=true;
                        af.RecordTypeId=balanceSheetrecordTypeId;
                        af.FinFortAPIStatus__c='Failure';
                        af.Type__c='Finfort ITR';
                        af.FinFortMess__c=failureResp.get(intmsg);
                        
                        appfinancialList.add(af);*/
                            
                        //Profit and Loss
                        appfinancialList.add(createApplicantFinancialFailure(intmsg.RefId__c,failureResp.get(intmsg),profitLossrecordTypeId,'Finfort ITR'));
                        
                        /*Applicant_Financial__c fin =new Applicant_Financial__c();
                        fin.Loan_Applicant__c=intmsg.RefId__c;
                        fin.IsLatest__c=true;
                        fin.RecordTypeId=profitLossrecordTypeId;
                        fin.FinFortAPIStatus__c='Failure';
                        fin.Type__c='Finfort ITR';
                        fin.FinFortMess__c=failureResp.get(intmsg);
                        
                        appfinancialList.add(fin);*/
                    }
                    
                    if(String.isNotblank(intmsg.RefId__c) && intmsg.Svc__c=='Create Order - GST'){
                        
                        //GST
                        appfinancialList.add(createApplicantFinancialFailure(intmsg.RefId__c,failureResp.get(intmsg),gstrecordTypeId,'Finfort GST'));
                    }
                    
                    //API Call out Tracker
                    APICalloutTracker.update_ApiTrackerWithIntMsg(intmsg.Id,intmsg.Svc__c, intmsg.ParentRefId__c, 'Failure');
                }
                
                if(!appfinancialList.isEmpty()){
                    Insert appfinancialList;
                }
            }
            
        }catch (Exception ex) {
            GlobalUtility.logMessage('Error', 'FinfortCreateOrderAPIResponseProcessor',
            'processFailure', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
    }
    
    //******************************************************************************************************************************************
    public static Applicant_Financial__c createApplicantFinancialSuccess(Id applicantId,FinfortCreateOrderAPIResponseWrapper response,Id recordTypeId,string finFortType){
        
        Applicant_Financial__c fin =new Applicant_Financial__c();
        
        try{
            
            fin.Loan_Applicant__c=applicantId;
            fin.IsLatest__c=true;
            fin.RecordTypeId=recordTypeId;
            fin.Type__c=finFortType;
            
            if(response.statusCode!=null){
                fin.FinFortAPIStatus__c=apiStatusMap.containsKey(response.statusCode)?apiStatusMap.get(response.statusCode):'';
            }
            
            if(String.isNotblank(response.msg)){
                fin.FinFortMess__c=response.msg;
            }
            
            if(response.data!=null && String.isNotblank(response.data.ffOrderId)){
                fin.FinFortOrderId__c=response.data.ffOrderId;
            }
            
            if(response.data!=null && String.isNotblank(response.data.consent_link)){
                fin.FinFortConsentLink__c=response.data.consent_link;
            }
            
            
            
        }catch (Exception ex) {
            GlobalUtility.logMessage('Error', 'FinfortCreateOrderAPIResponseProcessor',
            'createApplicantFinancialSuccess', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        
        return fin;
    }
    
    
    //******************************************************************************************************************************************
    public static Applicant_Financial__c createApplicantFinancialFailure(Id applicantId,string errMsg,Id recordTypeId,string finFortType){
        
        Applicant_Financial__c fin =new Applicant_Financial__c();
        
        try{
            
            fin.Loan_Applicant__c=applicantId;
            fin.IsLatest__c=true;
            fin.RecordTypeId=recordTypeId;
            fin.FinFortAPIStatus__c='Failure';
            fin.Type__c=finFortType;
            fin.FinFortMess__c=errMsg;
            
            
        }catch (Exception ex) {
            GlobalUtility.logMessage('Error', 'FinfortCreateOrderAPIResponseProcessor',
            'createApplicantFinancialFailure', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        
        return fin;
        
    }
    
    
    
    //******************************************************************************************************************************************
    @AuraEnabled
    public static void createFinFortSMSTask(Id appId,string TypeName){
        
        List<Task> tasklist =new List<Task>();
        
        SMS_Template_Details__mdt smsTemplate = SMS_Template_Details__mdt.getInstance('FinFort_Template');
        
        if(smsTemplate!=null && string.isNotBlank(smsTemplate.Recipient_Field__c) &&
        string.isNotBlank(smsTemplate.Template_Fields__c) && String.isNotBlank(smsTemplate.Query_Criteria__c)){
            
            String queryCriteria = smsTemplate.Query_Criteria__c;
            queryCriteria = queryCriteria.replace('<<__Id__>>', '\'' + appId + '\'');
            queryCriteria = queryCriteria.replace('<<__Type__>>', '\'' + TypeName + '\'');
            
            String query = 'SELECT Id,' + smsTemplate.Recipient_Field__c + ',' + smsTemplate.Template_Fields__c + ' FROM '
                + smsTemplate.Recipient_Object__c +' WHERE '
                + queryCriteria;
            
            List<Object> templateData = Database.Query(query);
            
            
            if(!templateData.isEmpty()){
                Applicant_Financial__c app = (Applicant_Financial__c) templateData[0];
                
                if(app.Loan_Applicant__r.MobNumber__c!=null && app.FinFortConsentLink__c!=null && smsTemplate.SMS_Template__c!=null){
                    
                    Id smsRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('SMS').getRecordTypeId();
                    Task taskRec = new Task();
                    taskRec.MobNum__c = app.Loan_Applicant__r.MobNumber__c;
                    taskRec.Type = 'SMS Task';
                    taskRec.Subject = 'FinFort SMS Task';
                    taskRec.WhatId = appId !=null ? appId:'';
                    taskRec.Description = smsTemplate.SMS_Template__c.replace('<<__FinFortLink__>>',app.FinFortConsentLink__c);
                    taskRec.RecordTypeId = smsRecordTypeId;
                    taskRec.Status = 'Completed';
                    tasklist.add(taskRec);
                }
                if(tasklist != null){
                    
                    insert tasklist;
                }
            }
        }
        
    }
    //******************************************************************************************************************************************
    public Static Map<Integer,String>  apiStatusMap=new Map<Integer,String>{
        0=>'Failure',
        1=>'Success',
        2=>'Pending',
    3=>'Failure'};
}