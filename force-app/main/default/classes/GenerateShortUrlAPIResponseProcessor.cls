public class GenerateShortUrlAPIResponseProcessor implements IintMsgCalloutResponseProcessor{
    
    
    public static void process(List<IntgMsg__c> responses) {
        
        if(!responses.isEmpty()){
            
            Map<IntgMsg__c,GenerateShortUrlAPIResponseWrapper> successResponseMap = new Map<IntgMsg__c,GenerateShortUrlAPIResponseWrapper>();
            Map<IntgMsg__c,String> failureResponseMap = new Map<IntgMsg__c,String>();
            Set<Id> imdIds =new Set<Id>();
            Set<Id> paymentIds =new Set<Id>();
            Map<Id,SObject> sObjectMap = new Map<Id,SObject>();
            for(IntgMsg__c intmsg:responses){
                
                if(String.isnotBlank(intmsg.Resp__c)){
                    
                    try{
                        
                        if(String.isnotBlank(intmsg.RefId__c)){
                            if(String.isnotBlank(intmsg.RefObj__c) && intmsg.RefObj__c=='ApplIMD__c'){
                                imdIds.add(intmsg.RefId__c);
                            }
                            if(String.isnotBlank(intmsg.RefObj__c) && intmsg.RefObj__c=='Payment__c'){
                                paymentIds.add(intmsg.RefId__c);
                            }
                        }
                        
                        GenerateShortUrlAPIResponseWrapper  res =(GenerateShortUrlAPIResponseWrapper) JSON.deserialize(intmsg.Resp__c,GenerateShortUrlAPIResponseWrapper.class);
                        
                        if(string.isNotBlank(res.status) && res.status=='1'){
                            successResponseMap.put(intmsg,res);
                        }
                        else if(string.isNotBlank(res.status) && res.status!='1'){
                            failureResponseMap.put(intmsg,res.message);
                        }
                        
                    }catch(Exception ex){
                        GlobalUtility.logMessage('Error', 'GenerateShortUrlAPIResponseProcessor class', 
                                                 'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
                        failureResponseMap.put(intmsg,IntegrationUtility.getCustomErrorMessage(ex.getMessage().substringBefore(':')));
                    }
                    
                }
                
            }
            
            if(!imdIds.isEmpty()){
                sObjectMap.putAll([Select Id, PaymentGateway__c FROM ApplIMD__c WHERE Id IN:imdIds]);
            }
            if(!paymentIds.isEmpty()){
                sObjectMap.putAll([Select Id, Payment_Gaterway__c FROM Payment__c WHERE Id IN:paymentIds]);
            }
            
            if(!successResponseMap.isEmpty()){
                processSuccess(sObjectMap,successResponseMap);
            }
            
            if(!failureResponseMap.isEmpty()){
                processFailure(failureResponseMap);
            }
        }
        
    }
    //***************************************************************************************************************************************
    public Static void processSuccess(Map<Id,SObject> sObjectMap, Map<IntgMsg__c,GenerateShortUrlAPIResponseWrapper> successMap){
        
        try{
            
            List<SObject> updateSObject =new List<SObject>();
            
            for(IntgMsg__c msg:successMap.keyset()){
                
                if(msg.RefId__c!=null){
                    GenerateShortUrlAPIResponseWrapper resp =successMap.get(msg);
                    
                    SObject record = Id.valueOf(msg.RefId__c).getSObjectType().newSObject(Id.valueOf(msg.RefId__c));
                    
                    if(resp!=null && resp.data!=null && String.isNotblank(resp.data.shortUrl)){
                        
                        if(String.isnotBlank(msg.RefObj__c) && msg.RefObj__c=='ApplIMD__c' && sObjectMap.containsKey(msg.RefId__c)){
                            ApplIMD__c imd = (ApplIMD__c) sObjectMap.get(msg.RefId__c);
                            if(imd.PaymentGateway__c == 'Billdesk'){
                                record.put('BDShortURL__c',resp.data.shortUrl);
                            }
                            else{
                                record.put('ShortURL__c',resp.data.shortUrl);
                            }
                        }
                        else if(String.isnotBlank(msg.RefObj__c) && msg.RefObj__c=='Payment__c' && sObjectMap.containsKey(msg.RefId__c)){
                            Payment__c payment = (Payment__c) sObjectMap.get(msg.RefId__c);
                            if(payment.Payment_Gaterway__c == 'Bill Desk'){
                                record.put('BDShortURL__c',resp.data.shortUrl);
                            }
                            else{
                                record.put('ShortURL__c',resp.data.shortUrl);
                            }
                        }
                        else{
                            record.put('ShortURL__c',resp.data.shortUrl);
                        }
                        updateSObject.add(record);
                    }
                }
                APICalloutTracker.update_ApiTrackerWithIntMsg(msg.Id,msg.Svc__c, msg.RefId__c, 'Success');
            }
            
            if(!updateSObject.isEmpty()){
                update updateSObject;
                
                for(IntgMsg__c msg:successMap.keyset()){
                    
                    IntegrationUtility.sendSMS(msg.RefId__c);
                }
                
            }
            
        }catch(Exception ex){
            GlobalUtility.logMessage('Error', 'GenerateShortUrlAPIResponseProcessor class', 
                                     'processSuccess', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        
    }
    //*************************************************************************************************************************************** 
    public Static void processFailure(Map<IntgMsg__c,String> failureMap){
        
        try{
            
            List<SObject> updateSObject =new List<SObject>();
            
            for(IntgMsg__c msg:failureMap.keyset()){
                
                SObject record = Id.valueOf(msg.RefId__c).getSObjectType().newSObject(Id.valueOf(msg.RefId__c));
                
                record.put('ShortURLErrorMessage__c',failureMap.get(msg));
                updateSObject.add(record);
                APICalloutTracker.update_ApiTrackerWithIntMsg(msg.Id,msg.Svc__c, msg.RefId__c, 'Failure');
            }
            
            if(!updateSObject.isEmpty()){
                update updateSObject;
            }
            
        }catch(Exception ex){
            GlobalUtility.logMessage('Error', 'GenerateShortUrlAPIResponseProcessor class', 
                                     'processFailure', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        
    }       
}