public class BillDeskRequestGenerator implements ICalloutRequestGenerator{

    public void generate(List<IntgMsg__c> msgs, String service, String processType){ 
        Set<Id> applIMDIds = new Set<Id>();
        Set<Id> paymentIds = new Set<Id>();
        Set<Id> usersIds = new Set<Id>();
        
        for(IntgMsg__c intMsg : msgs){ 
            if(intMsg.RefObj__c=='ApplIMD__c'){
                applIMDIds.add(intMsg.RefId__c);
            }
            else if(intMsg.RefObj__c=='Payment__c'){
                paymentIds.add(intMsg.RefId__c);
            }
            usersIds.add(intMsg.CreatedById);
        }
        
        Map<Id,AuthSession> authSessionMap = new Map<Id,AuthSession>();
        Map<Id,ApplIMD__c> applIMDMap = new Map<Id,ApplIMD__c>([SELECT Id,Name,IMDAmt__c,InstrumentAmt__c FROM ApplIMD__c WHERE Id IN :applIMDIds]);
        Map<Id,Payment__c> paymentMap = new Map<Id,Payment__c>([SELECT Id, TransAmt__c,InstrumentAmt__c,LoanAppl__r.TotalCharges__c FROM Payment__c WHERE Id IN:paymentIds]);
        for(AuthSession authSession : [SELECT Id,UsersId,SourceIp FROM AuthSession WHERE UsersId IN:usersIds ORDER BY CreatedDate DESC]){
            if(!authSessionMap.containsKey(authSession.UsersId)){
                authSessionMap.put(authSession.UsersId,authSession);
            }
        }
        
        try{
            List<IntgMsg__c>updateIntMsgList=New List<IntgMsg__c>(); 
            
            if(!msgs.isEmpty()){
                for(IntgMsg__c intMsg : msgs){
                    if(intMsg.RefId__c!=null){
                        
                        IntgSvcMgmt__mdt svc = IntgSvcMgmt__mdt.getInstance('BillDesk');
                        BillDeskRequestWrapper requestPayload = new BillDeskRequestWrapper();
                        if(intMsg.RefObj__c=='ApplIMD__c'){
                            requestPayload.amount = (applIMDMap.containsKey(intMsg.RefId__c) && applIMDMap.get(intMsg.RefId__c).InstrumentAmt__c !=null) ? String.valueOf(applIMDMap.get(intMsg.RefId__c).InstrumentAmt__c) : '0';
                        }
                        else if(intMsg.RefObj__c=='Payment__c'){
                            requestPayload.amount = (paymentMap.containsKey(intMsg.RefId__c) && paymentMap.get(intMsg.RefId__c).TransAmt__c!=null) ? String.valueOf(paymentMap.get(intMsg.RefId__c).TransAmt__c):'0';
                        }
                        requestPayload.currencyCode = svc.StaticKey__c!=null ? svc.StaticKey__c : '';

						BillDeskRequestWrapper.Device device = System.label.BillDeskDeviceConfig!=null ? (BillDeskRequestWrapper.Device) JSON.deserialize(System.label.BillDeskDeviceConfig, BillDeskRequestWrapper.Device.class) : new BillDeskRequestWrapper.Device();
                        if(authSessionMap.containsKey(intMsg.CreatedById)){
                            device.ip = authSessionMap.get(intMsg.CreatedById).SourceIp;
                        }
                        
						requestPayload.device = device;                        
                        requestPayload.itemcode = svc.ProcessCode__c!=null ? svc.ProcessCode__c : '';
                        requestPayload.mercid = svc.MerchantId__c!=null ? svc.MerchantId__c : '';
                        requestPayload.order_date = String.valueOf(DateTime.newInstance(System.Now().year(), system.now().month(), system.now().day(),system.now().hour(),system.now().minute(),System.now().second()).format('yyyy-MM-dd\'T\'HH:mm:ss')) + '+05:30';
                        requestPayload.orderid = intmsg.Integration_Message_Number__c + BillDeskAPIController.getepochTime(DateTime.now());
                        requestPayload.ru = svc.CallbackURL__c;
						
                        
                        BillDeskAPIController.RequestWrapper  request = new BillDeskAPIController.RequestWrapper();
                        request.encrypted_Payload = BillDeskAPIController.getEncryptedPayload(JSON.serialize(requestPayload).replace('currencyCode','currency'));
                        Map<String,String> header = new Map<String,String>();
                        header.put('BD-Timestamp',BillDeskAPIController.getepochTime(intMsg.CreatedDate));
                        header.put('BD-Traceid',requestPayload.orderid);
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
        }
        catch(Exception ex){
            GlobalUtility.logMessage('Error', 'BillDeskRequestGenerator' + ex.getLineNumber(), 
                                     'Generate', null, null, ex.getMessage() + ' Line: ' + ex.getLineNumber(), null, ex, null);
        }
        
        
        
    }
}