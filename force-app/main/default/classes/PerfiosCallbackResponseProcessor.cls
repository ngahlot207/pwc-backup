public class PerfiosCallbackResponseProcessor {
    
    public static void process(List<IntgMsg__c> responses) {
        try{
            //fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { IntgMsg__c.SObjectType });
            //List<IntgMsg__c> updateIntRecords = new List<IntgMsg__c>(); 
            Map<string,Map<string, string>> responsePerfiosMap=new Map<string,Map<string, string>>();
            Map<String,String> intgMsgRefIdsMap = new Map<String,String>();
            for(IntgMsg__c integrationMessage : responses){
                if(integrationMessage.Req__c!=null){
                    String perfiosCallbackResponse = EncodingUtil.urlDecode(integrationMessage.Req__c,'UTF-8');
                    list<string> callbackResponseSplit=perfiosCallbackResponse.split('&');
                    Map<string, string> perfiosCallbackResponseMap=new map<string,string>();
                    for(string response: callbackResponseSplit){
                        list<string> keyValueList=response.split('=');
                        if(keyValueList.size()>=2){
                            perfiosCallbackResponseMap.put(keyValueList[0],keyValueList[1]);
                        }else {
                            perfiosCallbackResponseMap.put(keyValueList[0],'');
                        }
                    }
                    if(perfiosCallbackResponseMap.containsKey('perfiosTransactionId')){
                        responsePerfiosMap.put(perfiosCallbackResponseMap.get('perfiosTransactionId'),perfiosCallbackResponseMap);
                        intgMsgRefIdsMap.put(integrationMessage.Id,perfiosCallbackResponseMap.get('perfiosTransactionId'));
                        
                    }
                    
                    /*IntgMsg__c intg=New IntgMsg__c();
                    intg.id=integrationMessage.Id;
                    intg.Status__c = 'Processed';
                    updateIntRecords.add(intg);*/
                }
            }
            
            if(!responsePerfiosMap.isEmpty()){
                processResponse(intgMsgRefIdsMap,responsePerfiosMap);
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
        //Exception Handling
        catch(Exception ex){
            GlobalUtility.logMessage('Error', 'PerfiosCallbackResponseProcessor class', 
                                     'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
    }
    
    
    public static void processResponse(Map<String,String> intgMsgRefIdsMap,Map<string, Map<string, string>> responseMap){
        try{
            //List<ApplBanking__c> applBankList = [Select Id,TransactionId__c,DocumentDetail__c FROM ApplBanking__c WHERE TransactionId__c=:responseMap.keySet()];
            List<ApplBanking__c> appBankList = new List<ApplBanking__c>();
            List<IntgMsg__c> createRequestList = new List<IntgMsg__c>();
            Map<String,ApplBanking__c> applBankMap = new Map<String,ApplBanking__c>();
            for(ApplBanking__c applBank : [Select Id,TransactionId__c,DocumentDetail__c,IntegrationStatus__c,IntegrationErrorMessage__c,LoanAppl__c,Appl__c FROM ApplBanking__c WHERE TransactionId__c IN: responseMap.keySet()]){
                applBankMap.put(applBank.TransactionId__c,applBank);
                system.debug('applBank'+applBank.LoanAppl__c);
                if(responseMap.containsKey(applBank.TransactionId__c)){
                    Map<String,String>  response = responseMap.get(applBank.TransactionId__c);
                    if(response.containsKey('status')){
                        if(response.get('status') == 'COMPLETED'){
                            ApplBanking__c appBank = new ApplBanking__c();
                            appBank.Id = applBank.Id;
                            appBank.IntegrationStatus__c = PerfiosAPIController.replaceAndUpdateString('Perfios Callback: Failure', 'Perfios Callback: Success', applBank.IntegrationStatus__c, ';');
                            appBank.IntegrationErrorMessage__c = PerfiosAPIController.replaceAndUpdateString('Perfios Callback', '', applBank.IntegrationErrorMessage__c, ';');
                            appBankList.add(appBank);
                            
                            IntgMsg__c intmsg =new IntgMsg__c();
                            intmsg.Name='Retrieve Report:JSON';
                            intmsg.BU__c='HL / STL';
                            intmsg.Status__c='New';
                            intmsg.MStatus__c='Blank';
                            intmsg.Svc__c='Retrieve Report';
                            intmsg.IsActive__c=true;
                            intmsg.RefId__c=applBank.DocumentDetail__c;
                            intmsg.RefObj__c='DocDtl__c';
                            intmsg.ParentRefId__c=applBank.ID;
                            intmsg.ParentRefObj__c='ApplBanking__c';
                            createRequestList.add(intmsg);
                            
                            IntgMsg__c intmsg1 =new IntgMsg__c();
                            intmsg1.Name='Retrieve Report:XLSX';
                            intmsg1.BU__c='HL / STL';
                            intmsg1.Status__c='New';
                            intmsg1.MStatus__c='Blank';
                            intmsg1.Svc__c='Retrieve Report';
                            intmsg1.IsActive__c=true;
                            intmsg1.RefId__c=applBank.DocumentDetail__c;
                            intmsg1.RefObj__c='DocDtl__c';
                            intmsg1.ParentRefId__c=applBank.ID;
                            intmsg1.ParentRefObj__c='ApplBanking__c';
                            createRequestList.add(intmsg1);
                        }
                        else{
                            if(response.containsKey('errorMessage') || response.containsKey('errorCode')){
                                String errorMessage = String.isNotBlank(response.get('errorMessage')) ? response.get('errorMessage') : response.get('errorCode');
                                ApplBanking__c appBank = new ApplBanking__c();
                                appBank.Id = applBank.Id;
                                appBank.Initiate_Perfios_Status__c = 'Failure';
                                appBank.IntegrationStatus__c = PerfiosAPIController.replaceAndUpdateString('Perfios Callback: Success', 'Perfios Callback: Failure', applBank.IntegrationStatus__c, ';');
                                appBank.IntegrationErrorMessage__c = PerfiosAPIController.replaceAndUpdateString('Perfios Callback', 'Perfios Callback: ' + errorMessage, applBank.IntegrationErrorMessage__c, ';');
                                appBankList.add(appBank);
                            }
                        }
                    }
                }
            }
            
            if(!appBankList.isEmpty()){
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { ApplBanking__c.SObjectType });
                List<string> fieldNamesList = New List<string>{'IntegrationStatus__c','IntegrationErrorMessage__c','Initiate_Perfios_Status__c'};
                    String sObjectName = 'ApplBanking__c';
                Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                uow.registerDirty(appBankList);
                uow.commitWork();
            }
            if(!createRequestList.isEmpty()){
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> { IntgMsg__c.SObjectType});
                List<string> fieldNamesList = New List<string>{'Name','BU__c','RefId__c','Status__c','MStatus__c','RefObj__c','Svc__c','ApiVendor__c',
                    'IsActive__c','ParentRefId__c','ParentRefObj__c'};
                        String sObjectName = 'IntgMsg__c';
                Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkInsert(objType,fieldNamesList); 
                uow.registerNew(createRequestList);
                uow.commitWork();
            }
            if(!intgMsgRefIdsMap.isEmpty()){
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { IntgMsg__c.SObjectType });
                List<IntgMsg__c> updateIntgMsgRecords = new List<IntgMsg__c>();
                for(String intgMsgId : intgMsgRefIdsMap.keySet()){
                    IntgMsg__c intg = new IntgMsg__c();
                    intg.id =  intgMsgId;
                    intg.Status__c = 'Processed';
                    if(applBankMap.containskey(intgMsgRefIdsMap.get(intgMsgId))){
                        if(applBankMap.get(intgMsgRefIdsMap.get(intgMsgId)).LoanAppl__c!=null){
                            intg.LoanAppln__c = applBankMap.get(intgMsgRefIdsMap.get(intgMsgId)).LoanAppl__c;
                        }
                        if(applBankMap.get(intgMsgRefIdsMap.get(intgMsgId)).Appl__c!=null){
                            intg.Appl__c = applBankMap.get(intgMsgRefIdsMap.get(intgMsgId)).Appl__c;
                        }
                    }
                    updateIntgMsgRecords.add(intg);
                }
                if(updateIntgMsgRecords!=null && !updateIntgMsgRecords.isEmpty()){
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
        }
    }
    
    
    /*public class PerfiosTransactionWrapper{
        public String perfiosTransactionId;	//Perfios Transaction Id
        public String clientTransactionId;	//Client-specified transaction identifier
        public String status;	//Status of the transaction
        public String errorCode;	//Error code associated with the transaction
        public String errorMessage; //Error message associated with the transaction
    }*/
}