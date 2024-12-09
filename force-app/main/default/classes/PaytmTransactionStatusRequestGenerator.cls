public class PaytmTransactionStatusRequestGenerator implements ICalloutRequestGenerator{
    
    
    public void generate(List<IntgMsg__c> msgs, String service, String processType){
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> { IntgMsg__c.SObjectType});
        
        if(!msgs.isempty()){
            
            try{
                
                List<IntgMsg__c>updateIntMsgList=New List<IntgMsg__c>();
                
                IntgSvcMgmt__mdt svc = IntgSvcMgmt__mdt.getInstance('Paytm');
                
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
                
                Map<Id,ApplIMD__c> applIMDMap =new Map<Id,ApplIMD__c>([SELECT Id,PaytmOrderId__c from ApplIMD__c Where Id IN:applIMDIds]);
                Map<Id,Payment__c> paymentMap =new Map<Id,Payment__c>([SELECT Id,PaytmOrderId__c from Payment__c Where Id IN:paymentIds]);
              
                
               for(IntgMsg__c intMsg : msgs){
                   
                   if(intMsg.RefId__c!=null){
                       
                       PaytmTransactionStatusRequestWrapper.Body requestbody =new PaytmTransactionStatusRequestWrapper.Body();
                        requestbody.mid=svc.MerchantId__c;
                        
                       if(intMsg.RefObj__c=='ApplIMD__c' && applIMDMap.containskey(intMsg.RefId__c)){
                           
                           ApplIMD__c applIMD = applIMDMap.get(intMsg.RefId__c);
                           requestbody.orderId=applIMD.PaytmOrderId__c;
                       }
                       
                       else if(intMsg.RefObj__c=='Payment__c' && paymentMap.containskey(intMsg.RefId__c)){
                           
                          Payment__c payment = paymentMap.get(intMsg.RefId__c);
                          requestbody.orderId=payment.PaytmOrderId__c;
                       }
                      
                       
                       PaytmChecksum paytmChecksum = new PaytmChecksum();
                       
                       PaytmTransactionStatusRequestWrapper.Head requestHead =new PaytmTransactionStatusRequestWrapper.Head();
                       requestHead.signature=paytmChecksum.generateSignature(JSON.serialize(requestBody), svc.PrivateKey__c);
                       
                       
                       PaytmTransactionStatusRequestWrapper request =new PaytmTransactionStatusRequestWrapper();
                       request.body=requestbody;
                       request.head=requestHead;
                       
                       IntgMsg__c intg=New IntgMsg__c();
                        intg.id=intMsg.id;
                        intg.Req__c = JSON.serialize(request); 
                        intg.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                        updateIntMsgList.add(intg);
                   }
                    
                   
                }

                if(!updateIntMsgList.isEmpty()){
                    String sObjectName = 'IntgMsg__c';
                    List<String> fieldNamesList = new List<String>{'Req__c','Status__c'};
                        Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                    uow.registerDirty(updateIntMsgList);
                    
                }
                uow.commitWork();
                
            }catch(Exception ex){
                GlobalUtility.logMessage('Error', 'PaytmTransactionStatusRequestGenerator class', 
                                         'generate', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
        }
    }

}