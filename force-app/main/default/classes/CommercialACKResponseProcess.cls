public class CommercialACKResponseProcess  implements IintMsgCalloutResponseProcessor {
    
    public static void process(List<IntgMsg__c> responses) {
        try{
            CommercialACKResponseWrapper res=(CommercialACKResponseWrapper) JSON.deserialize(responses[0].Resp__c, CommercialACKResponseWrapper.class);
            
            List<Applicant__c> applist=[Select id,LoanAppln__c from Applicant__c where id=:responses[0].RefId__c];
            
            if(res.STATUS=='SUCCESS'){
               CommercialACKSuccess(responses,applist[0].LoanAppln__c);
                
                if(responses[0].Trigger_Platform_Event__c){
                    publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                    platformWra.intId = responses[0].Id; 
                    platformWra.recId = responses[0].RefId__c;
                    platformWra.ServiceName = responses[0].Svc__c ;
                    platformWra.Status = responses[0].Status__c ;
                    platformWra.success=true;
                    publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
                } 
                APICalloutTracker.update_ApiTrackerWithIntMsg(responses[0].Id,responses[0].Svc__c, responses[0].RefId__c, 'Success');
            }
            
            if(res.STATUS!='SUCCESS'){
               CommercialACKFailure(res,responses[0].RefId__c,applist[0].LoanAppln__c,responses[0].TriggerType__c);
                if(responses[0].Trigger_Platform_Event__c){
                    publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                    platformWra.intId = responses[0].Id; 
                    platformWra.recId = responses[0].RefId__c;
                    platformWra.ServiceName = responses[0].Svc__c ;
                    platformWra.Status = responses[0].Status__c ;
                    platformWra.errorMessage=res.ERRORS[0].DESCRIPTION;
                    publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
                } 
                APICalloutTracker.update_ApiTrackerWithIntMsg(responses[0].Id,responses[0].Svc__c, responses[0].RefId__c, 'Failure');
            }
        }
        catch(Exception Ex){
            GlobalUtility.logMessage('Error', 'CommercialACKResponseProcess class', 
                                     'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        
    }

    //************************************************************************************************************************************
    public static void CommercialACKSuccess(List<IntgMsg__c> responses,Id Loanid){
        
        
        string ackid;      
        Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(responses[0].Resp__c);
        if(jsonMap.containskey('ACKNOWLEDGEMENT-ID')){
            ackid =String.Valueof(jsonMap.get('ACKNOWLEDGEMENT-ID'));
        }
        List<Bureau__c> existingBureauList = [Select Id,IsLatest__c,Applicant__c,BureauAPI__c FROM Bureau__c WHERE IsLatest__c=True AND Applicant__c=:responses[0].RefId__c AND BureauAPI__c='Commercial'];
        Id recordTypeId = Schema.SObjectType.Bureau__c.getRecordTypeInfosByDeveloperName().get('CommercialBureau').getRecordTypeId();

        if(!existingBureauList.isEmpty()){
            IsLatestFalse(existingBureauList);
        }
        List<Bureau__c> inserRequest = new List<Bureau__c>();
        try{

            Bureau__c insertRec=New Bureau__c();
            if(responses!=null){
                
                
                if(responses[0].RefId__c!=null){
                    insertRec.Applicant__c=responses[0].RefId__c;
                }
                if(Loanid!=null){
                    insertRec.LoanApp__c=Loanid;
                }
                
                if(ackid!=null){
                    insertRec.AckId__c=Decimal.Valueof(ackid);
                }
                insertRec.IsLatest__c=true;
                insertRec.RecordTypeId=recordTypeId;
                insertRec.BureauAPI__c='Commercial';
                insertRec.Trigger_Type__c=responses[0].TriggerType__c;
                insertRec.TriggerCount__c=1;
           
            // //Create Commercial Issue Request Integration Message with 1 min Delay
           
                
                
                
                Map<String,Object> jsonDataMap = new Map<String, Object>();
                
                jsonDataMap.put('Name','Commercial Issue Request');
                jsonDataMap.put('Status','New');
                jsonDataMap.put('MStatus','Blank');
                jsonDataMap.put('BU',responses[0].BU__c);
                jsonDataMap.put('RefId',responses[0].RefId__c);
                jsonDataMap.put('RefObj',responses[0].RefObj__c);
                jsonDataMap.put('Svc','Commercial Issue Request');
                jsonDataMap.put('ApiVendor',responses[0].ApiVendor__c);
                jsonDataMap.put('IsActive',true);
                
                String jsonSer = JSON.serialize(jsonDataMap);
                
                System.enqueueJob(new BureauQueueable(jsonSer),Integer.valueof(system.label.Bureau_Timer));
                
                inserRequest.add(insertRec);
                
            }
            

            if(inserRequest!=null){
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> {Bureau__c.SObjectType});
                List<string> fieldNamesList = New List<string>{'Applicant__c','AckId__c','IsLatest__c','RecordTypeId',
                                                               'BureauAPI__c','Trigger_Type__c','TriggerCount__c'};
                    String sObjectName = 'Bureau__c';
                Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkInsert(objType,fieldNamesList); 
                uow.registerNew(inserRequest);
                uow.commitWork();
            }
            
        
        }
        catch(Exception ex){
            GlobalUtility.logMessage('Error', 'CommercialACKResponseProcess class', 
                                     'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            
        }
        
    }
    //*****************************************************************************************************************************************
    public static void CommercialACKFailure(CommercialACKResponseWrapper res,Id refid,Id Loanid,string triggertype){
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { Bureau__c.SObjectType });
        List<Bureau__c> inserRequest = new List<Bureau__c>();
        
        try{
            Id recordTypeId = Schema.SObjectType.Bureau__c.getRecordTypeInfosByDeveloperName().get('CommercialBureau').getRecordTypeId();
            List<Bureau__c> existingBureauList = [Select Id,IsLatest__c,Applicant__c FROM Bureau__c WHERE IsLatest__c=True AND Applicant__c=:refid];
            if(!existingBureauList.isEmpty()){
                IsLatestFalse(existingBureauList);
            }
            if(res!=null){
                Bureau__c insertRec=New Bureau__c();
                
                if(refid!=null){
                    insertRec.Applicant__c=refid;
                }
                if(Loanid!=null){
                    insertRec.LoanApp__c=Loanid;
                    insertRec.IsLatest__c=true;
                    insertRec.RecordTypeId=recordTypeId;
                    insertRec.Trigger_Type__c=triggertype;
                }
                
                if(!string.isBlank(res.ERRORS[0].DESCRIPTION)){
                    insertRec.ErrorMess__c=res.ERRORS[0].DESCRIPTION;
                }
                inserRequest.add(insertRec);
            }
            
            if(inserRequest!=null){
                List<string> fieldNamesList = New List<string>{'Applicant__c','ErrorMess__c','IsLatest__c','Trigger_Type__c'};
                    String sObjectName = 'Bureau__c';
                Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkUpdate(objType,fieldNamesList); 
                uow.registerNew(inserRequest);
            }
            uow.commitWork();
            
        }
        catch(Exception ex){
            GlobalUtility.logMessage('Error', 'CommercialACKResponseProcess class', 
                                     'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
    }
    //************************************************************************************************************************************************
    public static void IsLatestFalse(List<Bureau__c> responses){
        if(!responses.isEmpty()){
            for(Bureau__c res : responses){
                res.IsLatest__c=false;
            }
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { Bureau__c.SObjectType });
            List<string> fieldNamesList = New List<string>{'IsLatest__c'};
                String sObjectName = 'Bureau__c';
            Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
            fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
            uow.registerDirty(responses);
            uow.commitWork();
        }
    }    
}