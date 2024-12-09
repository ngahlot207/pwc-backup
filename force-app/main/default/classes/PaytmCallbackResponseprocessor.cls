public class PaytmCallbackResponseprocessor {
    
    public static void process(List<IntgMsg__c> responses){ 
        System.debug(':::::::::PaytmResponseProcessor');
        //fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> { IntgMsg__c.SObjectType });
        //List<IntgMsg__c> updateIntRecords = new List<IntgMsg__c>(); 
        Map<string,Map<string, string>> responsePaytmMap=new Map<string,Map<string, string>>();
        Map<String,String> intgMsgRefIdsMap = new Map<String,String>();
        for(IntgMsg__c integrationMessage : responses){
            if(integrationMessage.Req__c!=null){
                String paytmCallbackResponse = EncodingUtil.urlDecode(integrationMessage.Req__c,'UTF-8');
                list<string> callbackResponseSplit=paytmCallbackResponse.split('&');
                Map<string, string> paytmCallbackResponseMap=new map<string,string>();
                for(string response: callbackResponseSplit){
                    list<string> keyValueList=response.split('=');
                    if(keyValueList.size()>=2){
                        paytmCallbackResponseMap.put(keyValueList[0],keyValueList[1]);
                    }else {
                        paytmCallbackResponseMap.put(keyValueList[0],'');
                    }
                }
                if(paytmCallbackResponseMap.containsKey('ORDERID')){
                    responsePaytmMap.put(paytmCallbackResponseMap.get('ORDERID'),paytmCallbackResponseMap);
                    intgMsgRefIdsMap.put(integrationMessage.Id,paytmCallbackResponseMap.get('ORDERID'));
                }
                
                //if(!paytmCallbackResponseMap.isEmpty()){
                //    updateApplicantIMD(paytmCallbackResponseMap);
                //}
                /*IntgMsg__c intg=New IntgMsg__c();
                intg.id=integrationMessage.Id;
                intg.Status__c = 'Processed';
                updateIntRecords.add(intg);*/
            }
        }
        
        if(!responsePaytmMap.isEmpty()){
            updateRecords(intgMsgRefIdsMap,responsePaytmMap);
        }
        /*if(!updateIntRecords.isEmpty()) {
            String sObjectName = 'IntgMsg__c';
            List<String> fieldNamesList = new List<String>{'Status__c'};
                Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
            fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
            uow.registerDirty(updateIntRecords);
        }
        uow.commitWork();*/
        
    }
    
    /*public static void updateApplicantIMD(Map<string, string> response){
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { ApplIMD__c.SObjectType });
        
        try{
            if(response.containsKey('ORDERID')){
                List<ApplIMD__c> applIMDList = [Select Id FROM ApplIMD__c WHERE PaytmOrderId__c=:response.get('ORDERID')];
                if(!applIMDList.isEmpty()){
                    ApplIMD__c applIMD = applIMDList[0];
                    if(response.containsKey('STATUS')){
                        applIMD.TransStatus__c= response.get('STATUS')=='TXN_SUCCESS' ? 'Success': 'Failure';
                        applIMD.IMDReceived__c= response.get('STATUS')=='TXN_SUCCESS' ? 'Yes' : 'No';
                        if(response.get('STATUS')=='TXN_SUCCESS'){
                            applIMD.IMDStatus__c = 'Received';
                        }
                    }
                    if(response.containsKey('TXNAMOUNT')){
                        applIMD.TransAmt__c = Decimal.valueOf(response.get('TXNAMOUNT'));
                    }
                    if(response.containsKey('TXNID')){
                        applIMD.TransId__c= response.get('TXNID');
                    }
                    if(response.containsKey('BANKTXNID')){
                        applIMD.PaymentRefNo__c = response.get('BANKTXNID');
                    }
                    if(response.containsKey('TXNDATETIME')){
                        //TXNDATETIME=2023-09-22 12:04:32.0
                        List<String>dateValue =response.get('TXNDATETIME').split('[- : .]');
                        if(dateValue.size()>=7){
                            applIMD.TransDt__c= Datetime.newInstance(Integer.valueOf(dateValue[0]), Integer.valueOf(dateValue[1]), Integer.valueOf(dateValue[2]), Integer.valueOf(dateValue[3]), Integer.valueOf(dateValue[4]),Integer.valueOf(dateValue[5]));
                        }
                    }
                    
                    if(applIMD != null){
                        List<string> fieldNamesList = New List<string>{'TransStatus__c','IMDReceived__c','TransAmt__c','TransId__c','PaymentRefNo__c','TransDt__c'};
                            String sObjectName = 'ApplIMD__c';
                        Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                        fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                        uow.registerDirty(applIMD);
                    }	
                }
            }
            
        }
        catch(exception ex){
            system.debug('error message and line number '+ ex.getMessage() + 'line' + ex.getLineNumber());
            GlobalUtility.logMessage('Error', 'PaytmCallbackResponseprocessor' + ex.getLineNumber(), 
                                     'Generate', null, null, ex.getMessage() + ' Line: ' + ex.getLineNumber(), null, ex, null);
        }       
        uow.commitWork();
        
    }*/
    
    public static void updateRecords(Map<String,String> intgMsgRefIdsMap,Map<string, Map<string, string>> responseMap){
        //fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { ApplIMD__c.SObjectType });
        
        try{
            List<ApplIMD__c> applIMDList = [Select Id,PaytmOrderId__c,LoanAppln__c,LoanAppln__r.Applicant__c FROM ApplIMD__c WHERE PaytmOrderId__c=:responseMap.keySet()];
            List<Payment__c> paymentLsit = [Select Id,PaytmOrderId__c,LoanAppl__c,LoanAppl__r.Applicant__c FROM Payment__c WHERE PaytmOrderId__c=:responseMap.keySet()];
            List<SObject> updateList = new List<SObject>();
            Map<String,ApplIMD__c> applIMDMap = new Map<String,ApplIMD__c>();
            Map<String,Payment__c> paymentMap = new Map<String,Payment__c>();
            if(!applIMDList.isEmpty()){
            	for(ApplIMD__c app : applIMDList){
                    applIMDMap.put(app.PaytmOrderId__c,app);
                    if(responseMap.containsKey(app.PaytmOrderId__c)){
                        Map<String,String>  response = responseMap.get(app.PaytmOrderId__c);
                        
                        SObject record = (SObject) Type.forName('ApplIMD__c').newInstance();
                		record.Id = app.Id;
                        if(response.containsKey('STATUS')){
                        	record.put('TransStatus__c',response.get('STATUS')=='TXN_SUCCESS' ? 'Success': 'Failure');
                            record.put('IMDReceived__c',response.get('STATUS')=='TXN_SUCCESS' ? 'Yes' : 'No');
                            if(response.get('STATUS')=='TXN_SUCCESS'){
                                record.put('IMDStatus__c','Cleared');
                            }
                        }
                        if(response.containsKey('TXNAMOUNT')){
                            record.put('TransAmt__c',Decimal.valueOf(response.get('TXNAMOUNT')));
                            record.put('InstrumentAmt__c',Decimal.valueOf(response.get('TXNAMOUNT')));
                        }
                        if(response.containsKey('TXNID')){
                            record.put('TransId__c',response.get('TXNID'));
                        }
                        if(response.containsKey('BANKTXNID')){
                            record.put('PaymentRefNo__c',response.get('BANKTXNID'));
                        }
                        if(response.containsKey('TXNDATETIME')){
                            //TXNDATETIME=2023-09-22 12:04:32.0
                            List<String>dateValue =response.get('TXNDATETIME').split('[- : .]');
                            if(dateValue.size()>=7){
                                record.put('TransDt__c',Datetime.newInstance(Integer.valueOf(dateValue[0]), Integer.valueOf(dateValue[1]), Integer.valueOf(dateValue[2]), Integer.valueOf(dateValue[3]), Integer.valueOf(dateValue[4]),Integer.valueOf(dateValue[5])));
                            }
                        }
                        
                        //
                        if(response.containsKey('RESPMSG')){
                            record.put('PaytmErrMess__c',response.get('RESPMSG'));
                        }
                        
                        updateList.add(record);
                        
                    }
                }
            }
            if(!paymentLsit.isEmpty()){
                for(Payment__c payment : paymentLsit){
                    paymentMap.put(payment.PaytmOrderId__c,payment);
                    if(responseMap.containsKey(payment.PaytmOrderId__c)){
                        Map<String,String>  response = responseMap.get(payment.PaytmOrderId__c);
                        
                        SObject record = (SObject) Type.forName('Payment__c').newInstance();
                		record.Id = payment.Id;
                        if(response.containsKey('STATUS')){
                        	record.put('TransStatus__c',response.get('STATUS')=='TXN_SUCCESS' ? 'Success': 'Failure');
                            record.put('PaymentReceived__c',response.get('STATUS')=='TXN_SUCCESS' ? 'Yes' : 'No');
                        }
                        if(response.containsKey('TXNAMOUNT')){
                            record.put('TransAmt__c',Decimal.valueOf(response.get('TXNAMOUNT')));
                        }
                        if(response.containsKey('TXNID')){
                            record.put('TransId__c',response.get('TXNID'));
                        }
                        if(response.containsKey('BANKTXNID')){
                            record.put('PaymentRefNo__c',response.get('BANKTXNID'));
                        }
                        if(response.containsKey('TXNDATETIME')){
                            //TXNDATETIME=2023-09-22 12:04:32.0
                            List<String>dateValue =response.get('TXNDATETIME').split('[- : .]');
                            if(dateValue.size()>=7){
                                record.put('TransDt__c',Datetime.newInstance(Integer.valueOf(dateValue[0]), Integer.valueOf(dateValue[1]), Integer.valueOf(dateValue[2]), Integer.valueOf(dateValue[3]), Integer.valueOf(dateValue[4]),Integer.valueOf(dateValue[5])));
                            }
                        }
                        if(response.containsKey('RESPMSG')){
                            record.put('PaytmErrMess__c',response.get('RESPMSG'));
                        }
                        updateList.add(record);
                        
                    }
                }
            }
            
            if(!updateList.isEmpty()){
                update updateList;
            }
            if(!intgMsgRefIdsMap.isEmpty()){
                List<IntgMsg__c> updateIntgMsgRecords = new List<IntgMsg__c>(); 
                for(String intgMsgId : intgMsgRefIdsMap.keySet()){
                    IntgMsg__c intg = new IntgMsg__c();
                    intg.id =  intgMsgId;
                    intg.Status__c = 'Processed';
                    if(applIMDMap.containskey(intgMsgRefIdsMap.get(intgMsgId))){
                        if(applIMDMap.get(intgMsgRefIdsMap.get(intgMsgId)).LoanAppln__c!=null){
                            intg.LoanAppln__c = applIMDMap.get(intgMsgRefIdsMap.get(intgMsgId)).LoanAppln__c;
                            if(applIMDMap.get(intgMsgRefIdsMap.get(intgMsgId)).LoanAppln__r.Applicant__c!=null){
                            intg.Appl__c = applIMDMap.get(intgMsgRefIdsMap.get(intgMsgId)).LoanAppln__r.Applicant__c;
							}
                        }
                    }
                    else if(paymentMap.containskey(intgMsgRefIdsMap.get(intgMsgId))){
                        if(paymentMap.get(intgMsgRefIdsMap.get(intgMsgId)).LoanAppl__c!=null){
                            intg.LoanAppln__c = paymentMap.get(intgMsgRefIdsMap.get(intgMsgId)).LoanAppl__c;
                            if(paymentMap.get(intgMsgRefIdsMap.get(intgMsgId)).LoanAppl__r.Applicant__c!=null){
                            intg.Appl__c = paymentMap.get(intgMsgRefIdsMap.get(intgMsgId)).LoanAppl__r.Applicant__c;
							}
                        }
                    }
                    updateIntgMsgRecords.add(intg);
                }
                
                if(updateIntgMsgRecords!=null && !updateIntgMsgRecords.isEmpty()){
                    fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { IntgMsg__c.SObjectType });
                    String sObjectName = 'IntgMsg__c';
                    List<String> fieldNamesList = new List<String>{'Status__c','LoanAppln__c','Appl__c'};
                        Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                    uow.registerDirty(updateIntgMsgRecords);
                    uow.commitWork();    
                }
            
            }
            
        }
        catch(exception ex){
            system.debug('error message and line number '+ ex.getMessage() + 'line' + ex.getLineNumber());
            GlobalUtility.logMessage('Error', 'PaytmCallbackResponseprocessor' + ex.getLineNumber(), 
                                     'Generate', null, null, ex.getMessage() + ' Line: ' + ex.getLineNumber(), null, ex, null);
        }       
        //uow.commitWork();
        
    } 
}