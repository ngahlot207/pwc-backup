public class BillDeskResponseProcessor implements IintMsgCalloutResponseProcessor{
	
    public static void process(List<IntgMsg__c> responses){ 
        
        Map<IntgMsg__c,BillDeskResponseWrapper> successResponseMap = new Map<IntgMsg__c,BillDeskResponseWrapper>();
        Map<IntgMsg__c,String> failureResponseMap = new Map<IntgMsg__c,String>();
        for(IntgMsg__c integrationMessage : responses){
            try{
                
                if(integrationMessage.Resp__c!=null){
                    String base64DecodeResponse = BillDeskAPIController.getbase64DecodeResponse(integrationMessage.Resp__c);
                    
                    if(base64DecodeResponse!=null){
                        BillDeskResponseWrapper response = BillDeskResponseWrapper.parse(base64DecodeResponse);
                        if(response!=null){
                            if(response.status!=null && response.status.equalsIgnoreCase('ACTIVE')){
                                successResponseMap.put(integrationMessage,response);
                            }
                            else {
                                failureResponseMap.put(integrationMessage, (response.message!=null && String.isNotBlank(response.message) ? response.message :  response.error_type !=null && String.isNotBlank(response.error_type) ? response.error_type : ''));
                            }
                            
                        }
                    }
                    
                }
            }
            catch(Exception ex){
                failureResponseMap.put(integrationMessage,IntegrationUtility.getCustomErrorMessage(ex.getMessage().substringBefore(':')));
                GlobalUtility.logMessage('Error', 'BillDeskResponseProcessor class', 
                                         'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            } 
        }
        
        if(!successResponseMap.isEmpty()){
            processSuccess(successResponseMap);
        }
        if(!failureResponseMap.isEmpty()){
            processFailure(failureResponseMap);
        }
    }
	
    public static void processSuccess(Map<IntgMsg__c,BillDeskResponseWrapper> successResponses){
        try{
            List<sObject> sObjectUpdateList =new List<sObject>();
            List<IntgMsg__c> createRequestList = new List<IntgMsg__c>();
            IntgSvcMgmt__mdt svc = IntgSvcMgmt__mdt.getInstance('BillDesk');
            for(IntgMsg__c integrationMessage:successResponses.keyset()){
                if(integrationMessage.RefId__c!=null && successResponses.containsKey(integrationMessage)){
                    BillDeskResponseWrapper response = successResponses.get(integrationMessage);
                    if(response!=null){
                        Id refId = integrationMessage.RefId__c;
                        String objName =refId.getSObjectType().getDescribe().getName();
                        SObject recordToUpdate = refId.getSObjectType().newSObject(refId);
                        recordToUpdate.put('BillDeskAPIStatus__c','Success');
                        recordToUpdate.put('BillDeskAPIErrorMessage__c','');
                        recordToUpdate.put('BDLinkURL__c',svc.CallbackURL__c!=null? svc.CallbackURL__c+'?id=' + refId : '');
                        if(response.orderid!=null && String.isNotBlank(response.orderid)){
                            recordToUpdate.put('OrderId__c',response.orderid);
                        }
                        if(response.bdorderid!=null && String.isNotBlank(response.bdorderid)){
                            recordToUpdate.put('BDOrderId__c',response.bdorderid);
                        }
                        if(response.mercid!=null && String.isNotBlank(response.mercid)){
                            recordToUpdate.put('BDMercId__c',response.mercid);
                        }
                        
                        if(response.links!=null && !response.links.isEmpty()){
                            for(BillDeskResponseWrapper.Links link : response.links){
                                if(link.href!=null && String.isNotBlank(link.href)){
                                    recordToUpdate.put('BDURL__c',link.href);
                                }
                                if(link.rel!=null && link.rel.equalsIgnoreCase('redirect') && link.method!=null && link.method.equalsIgnoreCase('POST')){
                                    if(link.parameters!=null){
                                        if(link.parameters.rdata!=null && String.isNotBlank(link.parameters.rdata)){
                                            recordToUpdate.put('RData__c',link.parameters.rdata);
                                        }
                                    }
                                }
                                if(link.valid_date!=null && String.isNotBlank(link.valid_date)){
                                    
                                    List<String>dateValue = link.valid_date.split('[- T : +]');
                                    if(dateValue!=null && dateValue.size()>=6){
                                        recordToUpdate.put('BillDeskLinkExpiryDate__c',Datetime.newInstance(Integer.valueOf(dateValue[0]), Integer.valueOf(dateValue[1]), Integer.valueOf(dateValue[2]), Integer.valueOf(dateValue[3]), Integer.valueOf(dateValue[4]),Integer.valueOf(dateValue[5])));
                                    }
                                    
                                }
                            }
                        }
                        
                        sObjectUpdateList.add(recordToUpdate);
                        
                        IntgMsg__c intmsg =new IntgMsg__c();
                        intmsg.Name='Generate Short URL';
                        intmsg.BU__c='HL / STL';
                        intmsg.Status__c='New';
                        intmsg.MStatus__c='Blank';
                        intmsg.Svc__c='Generate Short URL';
                        intmsg.IsActive__c=true;
                        intmsg.RefId__c= refId;
                        intmsg.RefObj__c= objName;
                        createRequestList.add(intmsg);
                    }
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
            if(!sObjectUpdateList.isEmpty()){
                update sObjectUpdateList;
                
                if(!createRequestList.isEmpty()){
                    insert createRequestList;
                }
                
            }
        }
        catch(Exception ex){
            GlobalUtility.logMessage('Error', 'BillDeskResponseProcessor class', 
                                     'processSuccess', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
    }
    public static void processFailure(Map<IntgMsg__c,String> failureResponses){
        
        try{
            
            List<sObject> sObjectUpdateList =new List<sObject>();
            for(IntgMsg__c integrationMessage:failureResponses.keyset()){
                if(integrationMessage.RefId__c!=null && failureResponses.containsKey(integrationMessage)){
                    Id refId = integrationMessage.RefId__c;
                    String objName =refId.getSObjectType().getDescribe().getName();
                    SObject recordToUpdate = refId.getSObjectType().newSObject(refId);
                    recordToUpdate.put('BillDeskAPIStatus__c','Failure');
                    recordToUpdate.put('BillDeskAPIErrorMessage__c',failureResponses.get(integrationMessage));
                    recordToUpdate.put('OrderId__c','');
                    recordToUpdate.put('BDOrderId__c','');
                    recordToUpdate.put('BDMercId__c','');
                    recordToUpdate.put('BDURL__c','');
                    recordToUpdate.put('RData__c','');
                    recordToUpdate.put('BillDeskLinkExpiryDate__c',null);
                    sObjectUpdateList.add(recordToUpdate);
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
            
            if(!sObjectUpdateList.isEmpty()){
                update sObjectUpdateList;
            }
            
        }catch(Exception ex){
            GlobalUtility.logMessage('Error', 'BillDeskResponseProcessor class', 
                                     'processFailure', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
    }
    
}