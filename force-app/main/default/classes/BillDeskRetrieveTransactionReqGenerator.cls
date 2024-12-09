public class BillDeskRetrieveTransactionReqGenerator implements ICalloutRequestGenerator{
    
    public void generate(List<IntgMsg__c> msgs, String service, String processType){
        if(!msgs.isempty()){
            
            try{
                
                List<IntgMsg__c>updateIntMsgList=New List<IntgMsg__c>();
                
                IntgSvcMgmt__mdt svc = IntgSvcMgmt__mdt.getInstance('BillDesk');
                
                Set<Id> applIMDIds = new Set<Id>();
                Set<Id> paymentIds = new Set<Id>();
                
                for(IntgMsg__c intMsg :msgs){
                    
                    if(intMsg.RefObj__c=='ApplIMD__c'){
                        applIMDIds.add(intMsg.RefId__c);
                    }
                    else if(intMsg.RefObj__c=='Payment__c'){
                        paymentIds.add(intMsg.RefId__c);
                    }
                }
                
                Map<Id,ApplIMD__c> applIMDMap =new Map<Id,ApplIMD__c>([SELECT Id,OrderId__c,BDOrderId__c from ApplIMD__c Where Id IN:applIMDIds]);
                Map<Id,Payment__c> paymentMap =new Map<Id,Payment__c>([SELECT Id,OrderId__c,BDOrderId__c from Payment__c Where Id IN:paymentIds]);
                
                
                for(IntgMsg__c intMsg : msgs){
                    
                    if(intMsg.RefId__c!=null){
                        
                        BillDeskRetrieveTransactionReqWrapper requestPayload =new BillDeskRetrieveTransactionReqWrapper();
                        requestPayload.mercid = svc.MerchantId__c!=null ? svc.MerchantId__c : '';
                        
                        if(intMsg.RefObj__c=='ApplIMD__c' && applIMDMap.containskey(intMsg.RefId__c)){
                            requestPayload.orderid = applIMDMap.get(intMsg.RefId__c).OrderId__c;
                        }
                        else if(intMsg.RefObj__c=='Payment__c' && paymentMap.containskey(intMsg.RefId__c)){
                            requestPayload.orderId = paymentMap.get(intMsg.RefId__c).OrderId__c;
                        }
                        
                        BillDeskAPIController.RequestWrapper  request = new BillDeskAPIController.RequestWrapper();
                        request.encrypted_Payload = BillDeskAPIController.getEncryptedPayload(JSON.serialize(requestPayload,true));
                        
                        Map<String,String> header = new Map<String,String>();
                        header.put('BD-Timestamp',BillDeskAPIController.getepochTime(intMsg.CreatedDate));
                        header.put('BD-Traceid',intmsg.Integration_Message_Number__c + BillDeskAPIController.getepochTime(DateTime.now()));
                        request.Header = header;
                        
                        IntgMsg__c intg=New IntgMsg__c();
                        intg.id=intMsg.id;
                        intg.Req__c = JSON.serialize(request); 
                        intg.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                        updateIntMsgList.add(intg);
                    }
                    
                    
                }
                
                if(!updateIntMsgList.isEmpty()){
                    update updateIntMsgList;
                }
            }
            catch(Exception ex){
                GlobalUtility.logMessage('Error', 'BillDeskRetrieveTransactionReqGenerator class', 
                                         'generate', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
        }
    }
}