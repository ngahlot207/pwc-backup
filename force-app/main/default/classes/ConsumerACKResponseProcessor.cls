public class ConsumerACKResponseProcessor implements IintMsgCalloutResponseProcessor {
    
    public static void process(List<IntgMsg__c> responses) {
        
        
        if(!responses.isEmpty()){
            
            Map<IntgMsg__c,ConsumerACKResponseWrapper> successResponseMap = new Map<IntgMsg__c,ConsumerACKResponseWrapper>();
            Map<IntgMsg__c,String> failureResponseMap = new Map<IntgMsg__c,String>();
            
            
            for(IntgMsg__c intmsg:responses){
                
                if(String.isnotBlank(intmsg.Resp__c)){
                    
                    try{
                        
                        ConsumerACKResponseWrapper res=(ConsumerACKResponseWrapper) JSON.deserialize(intmsg.Resp__c.replace('ACKNOWLEDGEMENT-ID','ACKNOWLEDGEMENT_ID'), ConsumerACKResponseWrapper.class);
                        
                        
                        //Success
                        if(res.STATUS=='SUCCESS'){
                            successResponseMap.put(intmsg,res);
                        }
                        //Failure
                        if(res.STATUS!='SUCCESS'){
                            failureResponseMap.put(intmsg,res.ERRORS[0].DESCRIPTION);
                        }
                    }
                    catch(Exception Ex){
                        GlobalUtility.logMessage('Error', 'ConsumerACKResponseProcessor class', 
                                                 'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
                        failureResponseMap.put(intmsg,IntegrationUtility.getCustomErrorMessage(ex.getMessage().substringBefore(':')));
                    }
                }
            }
            
            if(!successResponseMap.isEmpty()){
                processSuccess(successResponseMap);
            }
            
            if(!failureResponseMap.isEmpty()){
                processFailure(failureResponseMap);
            }
        }
        
        
    }
    
    //******************************************************************************************************************************************
    public static void processSuccess(Map<IntgMsg__c,ConsumerACKResponseWrapper> successResp){
        
        try{
            
            Set<Id> applicantIds =new Set<Id>();
            List<Bureau__c> insertBureau = new List<Bureau__c>();
            Id recordTypeId = Schema.SObjectType.Bureau__c.getRecordTypeInfosByDeveloperName().get('ConsumerBureau').getRecordTypeId();
            
            for(IntgMsg__c intmsg:successResp.keyset()){
                applicantIds.add(intmsg.RefId__c);
            }
            
            //IsLatest False
            if(!applicantIds.isEmpty()){
                
                List<Bureau__c> existingBureau = [Select Id,IsLatest__c,Applicant__c,BureauAPI__c,RecordType.DeveloperName FROM Bureau__c 
                                                  WHERE IsLatest__c=True AND Applicant__c IN:applicantIds AND BureauAPI__c='Consumer'
                                                  AND RecordType.DeveloperName='ConsumerBureau'];
                
                if(!existingBureau.isEmpty()){
                    IntegrationUtility.updateBooleanFlag(existingBureau,'IsLatest__c',false);
                }
            }
            
            for(IntgMsg__c intmsg:successResp.keyset()){
                
                ConsumerACKResponseWrapper response=successResp.get(intmsg);
                
                if(response!=null){
                    
                    Bureau__c insertRec=New Bureau__c();
                    insertRec.IsLatest__c=true;
                    insertRec.RecordTypeId=recordTypeId;
                    insertRec.BureauAPI__c='Consumer';
                    insertRec.TriggerCount__c=1;
                    insertRec.Trigger_Type__c=String.isNotblank(intmsg.TriggerType__c)?intmsg.TriggerType__c:'';
                    insertRec.Applicant__c=String.isNotblank(intmsg.RefId__c)?intmsg.RefId__c:'';
                    insertRec.LoanApp__c=String.isNotblank(intmsg.ParentRefId__c)?intmsg.ParentRefId__c:'';
                    insertRec.AckId__c=response.ACKNOWLEDGEMENT_ID!=null?Decimal.Valueof(response.ACKNOWLEDGEMENT_ID):null;
                    
                    //Create Cusomer Issue Request Integration Message with 1 min Delay
                    Map<String,Object> jsonDataMap = new Map<String, Object>();
                    
                    jsonDataMap.put('Name','Cusomer Issue Request');
                    jsonDataMap.put('Status','New');
                    jsonDataMap.put('MStatus','Blank');
                    jsonDataMap.put('BU',intmsg.BU__c);
                    jsonDataMap.put('RefId',intmsg.RefId__c);
                    jsonDataMap.put('RefObj',intmsg.RefObj__c);
                    jsonDataMap.put('Svc','Cusomer Issue Request');
                    jsonDataMap.put('ApiVendor',intmsg.ApiVendor__c);
                    jsonDataMap.put('IsActive',true);
                    
                    String jsonSer = JSON.serialize(jsonDataMap);
                    
                    System.enqueueJob(new BureauQueueable(jsonSer), Integer.valueof(system.label.Bureau_Timer));
                    
                    insertBureau.add(insertRec);
                    
                    
                }
                
                if(intmsg.Trigger_Platform_Event__c){
                    publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                    platformWra.intId = intmsg.Id; 
                    platformWra.recId = intmsg.RefId__c;
                    platformWra.ServiceName = intmsg.Svc__c ;
                    platformWra.Status = intmsg.Status__c ;
                    platformWra.success=true;
                    publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
                } 
                
                APICalloutTracker.update_ApiTrackerWithIntMsg(intmsg.Id,intmsg.Svc__c, intmsg.RefId__c, 'Success');
            }
            
            if(!insertBureau.isEmpty()){
                Insert insertBureau;
            }
            
        }catch(Exception ex){
            GlobalUtility.logMessage('Error', 'ConsumerACKResponseProcessor', 
                                     'processSuccess', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            
        }
        
    }
    //******************************************************************************************************************************************
    public static void processFailure(Map<IntgMsg__c,String> failureResp){
        
        try{
            
            Set<Id> applicantIds =new Set<Id>();
            List<Bureau__c> insertBureau = new List<Bureau__c>();
            Id recordTypeId = Schema.SObjectType.Bureau__c.getRecordTypeInfosByDeveloperName().get('ConsumerBureau').getRecordTypeId();
            
            for(IntgMsg__c intmsg:failureResp.keyset()){
                applicantIds.add(intmsg.RefId__c);
            }
            
            //IsLatest False
            if(!applicantIds.isEmpty()){
                
                List<Bureau__c> existingBureau = [Select Id,IsLatest__c,Applicant__c,BureauAPI__c,RecordType.DeveloperName FROM Bureau__c 
                                                  WHERE IsLatest__c=True AND Applicant__c IN:applicantIds AND BureauAPI__c='Consumer'
                                                  AND RecordType.DeveloperName='ConsumerBureau'];
                
                if(!existingBureau.isEmpty()){
                    IntegrationUtility.updateBooleanFlag(existingBureau,'IsLatest__c',false);
                }
            }
            
            
            for(IntgMsg__c intmsg:failureResp.keyset()){
                
                Bureau__c insertRec=New Bureau__c();
                insertRec.IsLatest__c=true;
                insertRec.RecordTypeId=recordTypeId;
                insertRec.BureauAPI__c='Consumer';
                insertRec.TriggerCount__c=1;
                insertRec.Trigger_Type__c=String.isNotblank(intmsg.TriggerType__c)?intmsg.TriggerType__c:'';
                insertRec.Applicant__c=String.isNotblank(intmsg.RefId__c)?intmsg.RefId__c:'';
                insertRec.LoanApp__c=String.isNotblank(intmsg.ParentRefId__c)?intmsg.ParentRefId__c:'';
                insertRec.ErrorMess__c=string.isNotblank(failureResp.get(intmsg))?failureResp.get(intmsg):'';
                insertBureau.add(insertRec);
                
                
                if(intmsg.Trigger_Platform_Event__c){
                    publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                    platformWra.intId = intmsg.Id; 
                    platformWra.recId = intmsg.RefId__c;
                    platformWra.ServiceName = intmsg.Svc__c ;
                    platformWra.Status = intmsg.Status__c ;
                    platformWra.errorMessage=string.isNotblank(failureResp.get(intmsg))?failureResp.get(intmsg):'';
                    publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
                }
                
                APICalloutTracker.update_ApiTrackerWithIntMsg(intmsg.Id,intmsg.Svc__c, intmsg.RefId__c, 'Failure');
            }
            
            if(!insertBureau.isEmpty()){
                Insert insertBureau;
            }
            
        }catch(Exception ex){
            GlobalUtility.logMessage('Error', 'ConsumerACKResponseProcessor', 
                                     'processFailure', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            
        }
    }
    
}