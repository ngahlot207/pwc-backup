public class PaytmTransactionStatusResponseProcessor implements IintMsgCalloutResponseProcessor {
    
    public static void process(List<IntgMsg__c> responses) {
        
        if(!responses.isEmpty()){
            
            Map<IntgMsg__c,Map<Id,PaytmTransactionStatusResponseWrapper>> responseMap =new  Map<IntgMsg__c,Map<Id,PaytmTransactionStatusResponseWrapper>>();
            Map<Id,String> catchErrorMap =new Map<Id,String>();
            
            for(IntgMsg__c intmsg:responses){
                
                try{ 
                    
                    if(String.isnotBlank(intmsg.Resp__c)){
                        
                        PaytmTransactionStatusResponseWrapper  res =(PaytmTransactionStatusResponseWrapper) JSON.deserialize(intmsg.Resp__c,PaytmTransactionStatusResponseWrapper.class);
                        
                        if(res!=null && res.body!=null && res.body.resultInfo!=null){
                            
                            //Success
                           // if(res.body.resultInfo.resultStatus=='TXN_SUCCESS'){
                                
                                if(responseMap.containsKey(intmsg)){
                                    responseMap.get(intmsg).put(intmsg.RefId__c,res);
                                    
                                }else{
                                    responseMap.put(intmsg,new Map<Id,PaytmTransactionStatusResponseWrapper>{intmsg.RefId__c=>res});
                                }
                                
                                
                                
                                // APICalloutTracker.update_ApiTrackerWithIntMsg(intmsg.Id,intmsg.Svc__c, intmsg.RefId__c, 'Success');
                           // }
                            
                            //Pending
                           // if(res.body.resultInfo.resultStatus=='PENDING'){
                              //  if(responseMap.containsKey(intmsg)){
                                  //  responseMap.get(intmsg).put(intmsg.RefId__c,res);
//                                    
                               // }else{
                                //    responseMap.put(intmsg,new Map<Id,PaytmTransactionStatusResponseWrapper>{intmsg.RefId__c=>res});
                                //}
                                // paytmPending(res.body.resultInfo.resultMsg,intmsg.RefId__c);
                                // APICalloutTracker.update_ApiTrackerWithIntMsg(intmsg.Id,intmsg.Svc__c, intmsg.RefId__c, 'Failure');
                           // }
                            
                            //Failure
                            //else if(res.body.resultInfo.resultStatus=='TXN_FAILURE'){
                                
                                //if(responseMap.containsKey(intmsg)){
                                 //   responseMap.get(intmsg).put(intmsg.RefId__c,res);
                                    
                               // }else{
                                //   responseMap.put(intmsg,new Map<Id,PaytmTransactionStatusResponseWrapper>{intmsg.RefId__c=>res});
                               // }
                                // paytmFailure(res.body.resultInfo.resultMsg,intmsg.RefId__c);
                                // APICalloutTracker.update_ApiTrackerWithIntMsg(intmsg.Id,intmsg.Svc__c, intmsg.RefId__c, 'Failure');
                           // }
                            
                        }
                        
                    }
                    
                }catch(Exception ex){
                    GlobalUtility.logMessage('Error', 'PaytmTransactionStatusResponseProcessor class', 
                                             'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
                    
                    String errorMessage ='';
                    String error = ex.getMessage().substringBefore(':');
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
                    //paytmFailure(catchErrorMap,intmsg.RefId__c);
                    
                    if(!catchErrorMap.containsKey(intmsg.RefId__c)){
                        catchErrorMap.put(intmsg.RefId__c,errorMessage);
                    }
                    APICalloutTracker.update_ApiTrackerWithIntMsg(intmsg.Id,intmsg.Svc__c, intmsg.RefId__c, 'Failure');
                }
            }
            
            if(!responseMap.isEmpty()){
                processResponse(responseMap);
            }
            if(!catchErrorMap.isEmpty()){
                ProcessCatchFailure(catchErrorMap);
            }
        }
    }
    
    public static void processResponse(Map<IntgMsg__c,Map<Id,PaytmTransactionStatusResponseWrapper>> responseMap){
        
        
        try{
            List<Sobject> Sobjectupdate =new List<Sobject>();
            
            if(!responseMap.isEmpty()){
                
                for(IntgMsg__c intmsg:responseMap.keyset()){
                    
                    if(responseMap.containsKey(intmsg)){
                        
                        Map<Id,PaytmTransactionStatusResponseWrapper> keyvalue =responseMap.get(intmsg);
                        
                        if(!keyvalue.isEmpty()){
                            
                            if(keyvalue.containsKey(intmsg.RefId__c)){
                                
                                String objName =Id.valueOf(intmsg.RefId__c).getSObjectType().getDescribe().getName();
                                SObject recordToUpdate = Id.valueOf(intmsg.RefId__c).getSObjectType().newSObject(intmsg.RefId__c);
                                
                                PaytmTransactionStatusResponseWrapper res =keyvalue.get(intmsg.RefId__c);
                                
                                
                                if(string.isNotBlank(res.body.resultInfo.resultStatus)){
                                    
                                    PaytmTransactionStatusResponseWrapper.Body bodyRes=res.body;
                                    
                                    if(res.body.resultInfo.resultStatus=='TXN_SUCCESS'){
                                        
                                        recordToUpdate.put('PaytmErrMess__c','');
                                        recordToUpdate.put('TransStatus__c','Success');
                                        
                                        if(objName=='ApplIMD__c'){
                                            recordToUpdate.put('IMDReceived__c','Yes');
                                            recordToUpdate.put('IMDStatus__c','Cleared');
                                        }
                                        else if(objName=='Payment__c'){
                                            recordToUpdate.put('PaymentReceived__c','Yes');
                                        }
                                        APICalloutTracker.update_ApiTrackerWithIntMsg(intmsg.Id,intmsg.Svc__c, intmsg.RefId__c, 'Success');
                                    }
                                    
                                    else if(res.body.resultInfo.resultStatus=='PENDING'){
                                        recordToUpdate.put('TransStatus__c','Pending');
                                        recordToUpdate.put('PaytmErrMess__c',String.isNotBlank(res.body.resultInfo.resultMsg)?res.body.resultInfo.resultMsg:'');
                                        
                                        if(objName=='ApplIMD__c'){
                                            recordToUpdate.put('IMDReceived__c','No'); 
                                        }
                                        else if(objName=='Payment__c'){
                                            recordToUpdate.put('PaymentReceived__c','No');
                                        }
                                        
                                        APICalloutTracker.update_ApiTrackerWithIntMsg(intmsg.Id,intmsg.Svc__c, intmsg.RefId__c, 'Success');
                                    }  
                                    
                                    else if(res.body.resultInfo.resultStatus=='TXN_FAILURE'){
                                        
                                        
                                        if(res.body.resultInfo.resultStatus=='TXN_FAILURE' && String.isNotBlank(res.body.resultInfo.resultMsg) && res.body.resultInfo.resultMsg.containsIgnoreCase('Invalid Order ID')){
                                            recordToUpdate.put('PaytmErrMess__c','Looks like the payment is not complete.');
                                            recordToUpdate.put('TransStatus__c','Pending');
                                        }else{
                                            recordToUpdate.put('TransStatus__c','Failure');
                                            recordToUpdate.put('PaytmErrMess__c',String.isNotBlank(res.body.resultInfo.resultMsg)?res.body.resultInfo.resultMsg:'');
                                        }
                                        
                                        
                                        if(objName=='ApplIMD__c'){
                                            recordToUpdate.put('IMDReceived__c','No'); 
                                        }
                                        else if(objName=='Payment__c'){
                                            recordToUpdate.put('PaymentReceived__c','No');
                                        }
                                        APICalloutTracker.update_ApiTrackerWithIntMsg(intmsg.Id,intmsg.Svc__c, intmsg.RefId__c, 'Failure');
                                    }  
                                    
                                    if(String.isNotBlank(bodyRes.txnId)){
                                        recordToUpdate.put('TransId__c',bodyRes.txnId);
                                    }
                                    
                                    if(String.isNotBlank(bodyRes.bankTxnId)){
                                        recordToUpdate.put('PaymentRefNo__c',bodyRes.bankTxnId);
                                    }
                                    
                                    if(String.isNotBlank(bodyRes.txnAmount)){
                                        recordToUpdate.put('TransAmt__c',Decimal.valueOf(bodyRes.txnAmount));
                                    }
                                    
                                    
                                    if(String.isNotBlank(bodyRes.txnDate)){
                                        
                                        List<String>dateValue =bodyRes.txnDate.split('[- : .]');
                                        
                                        recordToUpdate.put('TransDt__c',Datetime.newInstance(Integer.valueOf(dateValue[0]), Integer.valueOf(dateValue[1]), Integer.valueOf(dateValue[2]), Integer.valueOf(dateValue[3]), Integer.valueOf(dateValue[4]),Integer.valueOf(dateValue[5])));
                                    }
                                    
                                    
                                }
                                Sobjectupdate.add(recordToUpdate);
                            }
                        }
                    }
                    
                }
            }
            
            if(!Sobjectupdate.isEmpty()){
                update Sobjectupdate;
            }
            
        }catch(Exception ex){
            GlobalUtility.logMessage('Error', 'PaytmTransactionStatusResponseProcessor', 
                                     'paytmSuccess', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            
        }
        
    }
    
    public static void ProcessCatchFailure(Map<Id,String> catchFailureResponse){
        
        if(!catchFailureResponse.isEmpty()){
            
            try{
                
                List<Sobject> Sobjectupdate =new List<Sobject>();
                
                for(Id refId:catchFailureResponse.keyset()){
                    
                    String objName =refId.getSObjectType().getDescribe().getName();
                    SObject recordToUpdate = refId.getSObjectType().newSObject(refId);
                    
                    recordToUpdate.put('PaytmErrMess__c',catchFailureResponse.get(refId));
                    
                    Sobjectupdate.add(recordToUpdate);
                }
                
                if(!Sobjectupdate.isEmpty()){
                    update Sobjectupdate;
                }
                
            }catch(Exception ex){
                GlobalUtility.logMessage('Error', 'PaytmTransactionStatusResponseProcessor class', 
                                         'ProcessCatchFailure', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
        }
    }
}