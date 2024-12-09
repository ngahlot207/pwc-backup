public class FinFortOrderStatusCallbackProcessor {
    
	public Static void process(List<IntgMsg__c> responses){
        
        try{
            
            Map<IntgMsg__c,jsonBody> successResponseMap =new Map<IntgMsg__c,jsonBody>();
            Map<IntgMsg__c,jsonBody> failureResponseMap =new Map<IntgMsg__c,jsonBody>();
            List<IntgMsg__c> intMsgList =new List<IntgMsg__c>();
            
            if(!responses.isEmpty()){
                
                for(IntgMsg__c intmsg:responses){
                    
                    if(String.isNotblank(intmsg.Req__c)){
                        
                        jsonBody res= (jsonBody) JSON.deserialize(intmsg.Req__c,jsonBody.class);
                        
                       /* if(res!=null && String.isNotblank(res.orderStatus) && res.orderStatus.tolowercase()=='completed'){
                            successResponseMap.put(intmsg,res);
                        }else{
                            failureResponseMap.put(intmsg,res);
                        }*/
                        Map<String,String> jsonMap =new Map<String,String>();
                        jsonMap.put('Code','200');
                        jsonMap.put('Status','Success');
                        jsonMap.put('Message','Order Status Notification received successfully');
                        
                        IntgMsg__c msg =new IntgMsg__c();
                        msg.Id=intmsg.Id;
                        msg.Resp__c=JSON.serialize(jsonMap);
                        msg.Status__c='Processed';
                        intMsgList.add(msg);
                    }
                }
            }
            if(!intMsgList.isEmpty()){
                Update intMsgList;
            }
            
            if(!successResponseMap.isEmpty()){
                //processSuccess(successResponseMap);
            }
            
            if(!failureResponseMap.isEmpty()){
               // processFailure(failureResponseMap);
            }
        } 
        catch (Exception ex) {
            system.debug('error message and line number '+ ex.getMessage() + 'line' + ex.getLineNumber());
        }
    }
    
   //***************************************************************************************
    public static Void processSuccess(Map<IntgMsg__c,jsonBody> successResponse){
        
        try{
            List<IntgMsg__c> intMsgList =new List<IntgMsg__c>();
            
            for(IntgMsg__c intmsg:successResponse.keyset()){
                
                jsonBody mapValue =successResponse.get(intmsg);
                
                if(mapValue!=null){
                    
                    jsonBody resp =new jsonBody();
                    
                    resp.code=200;
                    resp.lender_name=String.isNotblank(mapValue.lender_name)?mapValue.lender_name:'';
                    resp.lender_referenceNumber=String.isNotblank(mapValue.lender_referenceNumber)?mapValue.lender_referenceNumber:'';
                    resp.ffOrderId=String.isNotblank(mapValue.ffOrderId)?mapValue.ffOrderId:'';
                    resp.borrower_pan=String.isNotblank(mapValue.borrower_pan)?mapValue.borrower_pan:'';
                    resp.orderStatus=String.isNotblank(mapValue.orderStatus)?mapValue.orderStatus:'';
                    resp.orderStatusReceipt='Success';
                    resp.fileCount=String.isNotblank(mapValue.fileCount)?mapValue.fileCount:'';
                    resp.failureReason='NA';
                    
                    
                    //Updating IntgMsg__c
                    if(resp!=null){
                        
                        IntgMsg__c msg =new IntgMsg__c();
                        msg.Id=intmsg.Id;
                        msg.Resp__c=JSON.serialize(resp);
                        msg.Status__c='Processed';
                        intMsgList.add(msg);
                    }
                }
                
                
            }
            
            
            if(!intMsgList.isEmpty()){
                Update intMsgList;
            }
            
        }catch (Exception ex) {
            system.debug('error message and line number '+ ex.getMessage() + 'line' + ex.getLineNumber());
        }
    }
   //***************************************************************************************
    public static Void processFailure(Map<IntgMsg__c,jsonBody> failureResponse){
        
        try{
            List<IntgMsg__c> intMsgList =new List<IntgMsg__c>();
            
            for(IntgMsg__c intmsg:failureResponse.keyset()){
                
                jsonBody mapValue =failureResponse.get(intmsg);
                
                if(mapValue!=null){
                    
                    jsonBody resp =new jsonBody();
                    
                    resp.code=400;
                    resp.lender_name=String.isNotblank(mapValue.lender_name)?mapValue.lender_name:'';
                    resp.lender_referenceNumber=String.isNotblank(mapValue.lender_referenceNumber)?mapValue.lender_referenceNumber:'';
                    resp.ffOrderId=String.isNotblank(mapValue.ffOrderId)?mapValue.ffOrderId:'';
                    resp.borrower_pan=String.isNotblank(mapValue.borrower_pan)?mapValue.borrower_pan:'';
                    resp.orderStatus=String.isNotblank(mapValue.orderStatus)?mapValue.orderStatus:'';
                    resp.orderStatusReceipt='Failure';
                    resp.fileCount=String.isNotblank(mapValue.fileCount)?mapValue.fileCount:'';
                    resp.failureReason='Order not found';
                    
                    
                    //Updating IntgMsg__c
                    if(resp!=null){
                        
                        IntgMsg__c msg =new IntgMsg__c();
                        msg.Id=intmsg.Id;
                        msg.Resp__c=JSON.serialize(resp);
                        msg.Status__c='Processed';
                        intMsgList.add(msg);
                    }
                }
                
                
            }
            
            if(!intMsgList.isEmpty()){
                Update intMsgList;
            }
            
        }catch (Exception ex) {
            system.debug('error message and line number '+ ex.getMessage() + 'line' + ex.getLineNumber());
        }
    }
 //***************************************************************************************
    Public class jsonBody{
        public string lender_name;
        public string lender_referenceNumber;
        public string borrower_pan;
        public string ffOrderId;
        public string orderStatus;
        public string orderStatusReceipt;
        public string failureReason;
        public string fileCount;
        public string cancellationReason;
        public integer code;
    }   
}