public class BillDeskRetrieveTransactionResProcessor implements IintMsgCalloutResponseProcessor{
    
    public static void process(List<IntgMsg__c> responses){ 
        
        Map<IntgMsg__c,BillDeskRetrieveTransactionResWrapper> responseMap = new Map<IntgMsg__c,BillDeskRetrieveTransactionResWrapper>();
        Map<IntgMsg__c,String> failureResponseMap = new Map<IntgMsg__c,String>();
        Set<Id> refIds = new Set<Id>();
        
        for(IntgMsg__c integrationMessage : responses){
            
            try{
                if(integrationMessage.Resp__c!=null){
                    String base64DecodeResponse = BillDeskAPIController.getbase64DecodeResponse(integrationMessage.Resp__c);
                    
                    if(base64DecodeResponse!=null){
                        BillDeskRetrieveTransactionResWrapper response = BillDeskRetrieveTransactionResWrapper.parse(base64DecodeResponse);
                        if(response!=null){
                            responseMap.put(integrationMessage,response);
                        }
                    }
                }
                
            }
            catch(Exception ex){
                failureResponseMap.put(integrationMessage,IntegrationUtility.getCustomErrorMessage(ex.getMessage().substringBefore(':')));
                GlobalUtility.logMessage('Error', 'BillDeskRetrieveTransactionResProcessor class', 
                                         'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
        }
        
        if(!responseMap.isEmpty()){
            processResponses(responseMap);
        }
        if(!failureResponseMap.isEmpty()){
            processFailure(failureResponseMap);
        }
    }
    public static void processFailure(Map<IntgMsg__c,String> failureResponseMap){
        if(!failureResponseMap.isEmpty()){
            try{
                
                List<Sobject> Sobjectupdate =new List<Sobject>();
                
                for(IntgMsg__c intg:failureResponseMap.keyset()){
                    String objName =Id.valueOf(intg.RefId__c).getSObjectType().getDescribe().getName();
                    SObject recordToUpdate = Id.valueOf(intg.RefId__c).getSObjectType().newSObject(Id.valueOf(intg.RefId__c));
                    recordToUpdate.put('BillDeskAPIErrorMessage__c',failureResponseMap.get(intg));
                    Sobjectupdate.add(recordToUpdate);
                    
                    if(intg.Trigger_Platform_Event__c){
                        publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                        platformWra.intId = intg.Id; 
                        platformWra.recId = intg.ParentRefId__c;
                        platformWra.ServiceName = intg.Svc__c ;
                        platformWra.Status = intg.Status__c ;
                        platformWra.errorMessage = failureResponseMap.containsKey(intg)? failureResponseMap.get(intg) : '';
                        publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
                    }
                    APICalloutTracker.update_ApiTrackerWithIntMsg(intg.Id,intg.Svc__c, intg.RefId__c, 'Failure');
                }
                
                if(!Sobjectupdate.isEmpty()){
                    update Sobjectupdate;
                }
                
            }
            catch(Exception ex){
                GlobalUtility.logMessage('Error', 'BillDeskRetrieveTransactionResProcessor class', 
                                         'processFailure', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
        }
    }
    public static void processResponses(Map<IntgMsg__c,BillDeskRetrieveTransactionResWrapper> responseMap){
        try{
            
            
            if(!responseMap.isEmpty()){
                List<Sobject> sObjectUpdate = new List<Sobject>();
                for(IntgMsg__c intmsg:responseMap.keyset()){
                    
                    if(intMsg.RefId__c!=null && responseMap.containsKey(intmsg)){
                        BillDeskRetrieveTransactionResWrapper response = responseMap.get(intmsg);
                        String objName =Id.valueOf(intmsg.RefId__c).getSObjectType().getDescribe().getName();
                        SObject recordToUpdate = Id.valueOf(intmsg.RefId__c).getSObjectType().newSObject(intmsg.RefId__c);
                        if(response!=null){
                            if(String.isNotBlank(response.transaction_error_type)){
                                
                                if(response.transaction_error_type.equalsIgnoreCase('success')){
                                    recordToUpdate.put('TransStatus__c','Success');
                                    if(objName=='ApplIMD__c'){
                                        recordToUpdate.put('IMDReceived__c','Yes');
                                        recordToUpdate.put('IMDStatus__c','Cleared');
                                        if(String.isNotBlank(response.amount)){
                                            recordToUpdate.put('TransAmt__c',Decimal.valueOf(response.amount));
                                            recordToUpdate.put('InstrumentAmt__c',Decimal.valueOf(response.amount));
                                        }
                                    }
                                    else if(objName=='Payment__c'){
                                        recordToUpdate.put('PaymentReceived__c','Yes');
                                        if(String.isNotBlank(response.amount)){
                                            recordToUpdate.put('TransAmt__c',Decimal.valueOf(response.amount));
                                        }
                                        
                                    }
                                    recordToUpdate.put('TransId__c',String.isNotBlank(response.bank_ref_no)? response.bank_ref_no : response.transactionid);
                                    recordToUpdate.put('PaymentRefNo__c',response.transactionid);
                                    recordToUpdate.put('BillDeskAPIErrorMessage__c',response.transaction_error_desc);
                                    
                                    List<String>dateValue = response.transaction_date.split('[- T : +]');
                                    if(dateValue!=null && dateValue.size()>=6){
                                        recordToUpdate.put('TransDt__c',Datetime.newInstance(Integer.valueOf(dateValue[0]), Integer.valueOf(dateValue[1]), Integer.valueOf(dateValue[2]), Integer.valueOf(dateValue[3]), Integer.valueOf(dateValue[4]),Integer.valueOf(dateValue[5])));
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
                                else{
                                    recordToUpdate.put('TransStatus__c','Failure');
                                    recordToUpdate.put('BillDeskAPIErrorMessage__c',String.isNotBlank(response.transaction_error_desc)? response.transaction_error_desc : response.transaction_error_type);
                                    if(intmsg.Trigger_Platform_Event__c){
                                        publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                                        platformWra.intId = intmsg.Id; 
                                        platformWra.recId = intmsg.ParentRefId__c;
                                        platformWra.ServiceName = intmsg.Svc__c ;
                                        platformWra.Status = intmsg.Status__c ;
                                        platformWra.errorMessage = String.isNotBlank(response.transaction_error_desc)? response.transaction_error_desc : response.transaction_error_type;
                                        publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
                                    }
                                    APICalloutTracker.update_ApiTrackerWithIntMsg(intmsg.Id,intmsg.Svc__c, intmsg.RefId__c, 'Failure');
                                }
                            }  
                            else{
                                recordToUpdate.put('TransStatus__c','Pending');
                                recordToUpdate.put('BillDeskAPIErrorMessage__c',String.isNotBlank(response.message)? response.message : response.error_type);                                
                                if(intmsg.Trigger_Platform_Event__c){
                                    publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                                    platformWra.intId = intmsg.Id; 
                                    platformWra.recId = intmsg.ParentRefId__c;
                                    platformWra.ServiceName = intmsg.Svc__c ;
                                    platformWra.Status = intmsg.Status__c ;
                                    platformWra.errorMessage = String.isNotBlank(response.message)? response.message : response.error_type;
                                    publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
                                }
                                APICalloutTracker.update_ApiTrackerWithIntMsg(intmsg.Id,intmsg.Svc__c, intmsg.RefId__c, 'Failure');
                            }
                            sObjectUpdate.add(recordToUpdate);
                        }
                    }
                }
                
                if(!sObjectUpdate.isEmpty()){
                    update sObjectUpdate;
                }
            }
        }
        catch(Exception ex){
            GlobalUtility.logMessage('Error', 'BillDeskRetrieveTransactionResProcessor class', 
                                     'processResponses', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
    }
}