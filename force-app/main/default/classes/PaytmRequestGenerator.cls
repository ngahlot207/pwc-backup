public class PaytmRequestGenerator implements ICalloutRequestGenerator{
    
    public void generate(List<IntgMsg__c> msgs, String service, String processType){ 
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> { IntgMsg__c.SObjectType });
        
        //Creating a Set of Ids
        Set<Id> applIMDIds = new Set<Id>();
        Set<Id> paymentIds = new Set<Id>();
        
        IntgSvcMgmt__mdt svc = IntgSvcMgmt__mdt.getInstance('Paytm');
        //Iterating over new Intgeration Message record Ids to add them into the above List
        for(IntgMsg__c intMsg : msgs){ 
            if(intMsg.RefObj__c=='ApplIMD__c'){
                applIMDIds.add(intMsg.RefId__c);
            }
            else if(intMsg.RefObj__c=='Payment__c'){
                paymentIds.add(intMsg.RefId__c);
            }
        }
        
        Map<Id,ApplIMD__c> applIMDMap;
        Map<Id,Payment__c> paymentMap;
        
        if(!applIMDIds.isEmpty()){
            applIMDMap = new Map<Id,ApplIMD__c>([SELECT Id,Name,IMDAmt__c,InstrumentAmt__c FROM ApplIMD__c WHERE Id IN :applIMDIds]);
        }
        if(!paymentIds.isEmpty()){
            paymentMap = new Map<Id,Payment__c>([SELECT Id, TransAmt__c,InstrumentAmt__c,LoanAppl__r.TotalCharges__c FROM Payment__c WHERE Id IN:paymentIds]);
        }    
        try{
            List<IntgMsg__c>updateIntMsgList=New List<IntgMsg__c>(); 
            
            if(!msgs.isEmpty()){
                for(IntgMsg__c intMsg : msgs){
                    if(intMsg.RefId__c!=null){
                        
                        
                        PaytmRequestWrapper paytmReuestDetials = new PaytmRequestWrapper();
                        PaytmRequestWrapper.Head requestHead = new PaytmRequestWrapper.Head();
                        PaytmRequestWrapper.Body requestBody = new PaytmRequestWrapper.Body();
                        
                        requestBody.mid=svc.MerchantId__c;
                        requestBody.linkType=GlobalConstants.linkType;
                        requestBody.linkOrderId=GlobalUtility.getUniqueNumber();
                        requestBody.singleTransactionOnly =true;
                        Datetime expiryDate = system.now().addDays(1);
                        requestBody.maxPaymentsAllowed ='1';
                        requestBody.expiryDate = String.valueOf(DateTime.newInstance(expiryDate.year(), expiryDate.month(), expiryDate.day(),expiryDate.hour(),expiryDate.minute(),expiryDate.second()).format('dd/MM/YYYY HH:mm:ss'));//'18/07/2024 15:00:00';
                        
                        if(intMsg.RefObj__c=='ApplIMD__c'){
                            ApplIMD__c applIMD = applIMDMap.get(intMsg.RefId__c);
                            requestBody.linkDescription='IMD Payment';
                            requestBody.linkName='IMDPayment';
                            requestBody.amount= (applIMDMap.containsKey(intMsg.RefId__c) && applIMDMap.get(intMsg.RefId__c).InstrumentAmt__c !=null)?applIMD.InstrumentAmt__c:0;
                        }
                        else if(intMsg.RefObj__c=='Payment__c'){
                            Payment__c payment = paymentMap.get(intMsg.RefId__c);
                            requestBody.linkDescription='Payment';
                            requestBody.linkName='Payment';
                            requestBody.amount= (paymentMap.containsKey(intMsg.RefId__c) && paymentMap.get(intMsg.RefId__c).TransAmt__c!=null)?payment.TransAmt__c:0;
                        }
                        
                        PaytmChecksum paytmChecksum = new PaytmChecksum();
                        
                        requestHead.signature= paytmChecksum.generateSignature(JSON.serialize(requestBody), svc.PrivateKey__c);
                        requestHead.tokenType = GlobalConstants.tokenType;
                        
                        paytmReuestDetials.head=requestHead;
                        paytmReuestDetials.body=requestBody;
                        
                        IntgMsg__c intg=New IntgMsg__c();
                        intg.id=intMsg.id;
                        intg.Req__c = JSON.serialize(paytmReuestDetials); 
                        intg.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                        updateIntMsgList.add(intg);
                        
                    }
                    else{
                        throw new PaytmRequestGeneratorException('Invalid Reference Id');
                    }
                }
                
                if(!updateIntMsgList.isEmpty()){
                    String sObjectName = 'IntgMsg__c';
                    List<String> fieldNamesList = new List<String>{'Req__c','Status__c'};
                        Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                    uow.registerDirty(updateIntMsgList);
                    
                }
            }
            uow.commitWork();
        }
        //Catch bloack to catch Exceptions occured during generation of payload and displaying the passing the same in GlobalUtility class
        catch(Exception ex){
            GlobalUtility.logMessage('Error', 'PaytmRequestGenerator' + ex.getLineNumber(), 
                                     'Generate', null, null, ex.getMessage() + ' Line: ' + ex.getLineNumber(), null, ex, null);
        }
    }
    
    public class PaytmRequestGeneratorException extends Exception {
        
    }
}