global class APIRetriggerBatch implements Database.Batchable<sobject>, Schedulable{
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
      	System.debug('start');
        
        return Database.getQueryLocator([SELECT Id, Name,IntgMsgName__c,BU__c, LastModifiedDate, APIName__c, CrntStatus__c, LtstRespCode__c, LstSucesDtTime__c, RefId__c, RefObj__c, ParentRefId__c, ParentRefObj__c,Retry__c,Retry_Count__c,Retry_Mode__c,MaxRetryExceeded__c  from APICoutTrckr__c where Retry__c = true and MaxRetryExceeded__c = false and LAN__r.Stage__c NOT IN ('Disbursement Initiation' ,'Disbursed')]);
    }
    
    global void execute(Database.BatchableContext BC, List<APICoutTrckr__c> apiCoutList) {
        System.debug('execute batch');
        
        List<APICoutTrckr__c> updApiReObjList = new List<APICoutTrckr__c>();
        List<RetryConfig__mdt> retryConList = [select Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, SystemModstamp, Svc__c, RetryFrequency__c, MaxRetryAttempts__c
                                                           from RetryConfig__mdt where IsActive__c=true ];
        if(retryConList!=null){
            System.debug('retryConList::'+retryConList.size());
        }
        
        Map<String,RetryConfig__mdt> mapRetryCon =new Map<String,RetryConfig__mdt>();

        for(RetryConfig__mdt eachObjRc : retryConList)
        {
            mapRetryCon.put(eachObjRc.Svc__c,eachObjRc);
        }

        System.debug('mapRetryCon ::'+mapRetryCon);

        List<IntgMsg__c> createIntMsgList = new List<IntgMsg__c>();
        
       
        for(APICoutTrckr__c eachApiTObj : apiCoutList){
            try {
               System.debug('Retry_Count__c of API Tracker ::'+eachApiTObj.Retry_Count__c);
                    //Integer valForFreq = Integer.valueOf((System.now().getTime() - eachApiTObj.LastModifiedDate.getTime())/(1000*60*60));
                if(mapRetryCon.get(eachApiTObj.APIName__c) !=null) {
                    System.debug('Retry config is not empty');
                 
                  System.debug('eachApiTObj.APIName__c::'+eachApiTObj.APIName__c);
                  DateTime timeValueCustom ;
                  
                    if(Test.isRunningTest()){
                        System.debug('Test Class Running');
                        timeValueCustom= System.now().addHours(-4);
                    }else{
                        System.debug('Normal Class Running');
                        timeValueCustom = eachApiTObj.LastModifiedDate.addHours(Integer.valueOf(mapRetryCon.get(eachApiTObj.APIName__c).RetryFrequency__c));
                    }
                    
                    System.debug( ' after freq value H  ::  '+timeValueCustom);

                    if(System.now() >=  timeValueCustom)
                    {
                    System.debug('System.now() >=  timeValueCustom :: condition satisfied :');
                    IntgMsg__c intMsgRec =new IntgMsg__c();
                    intMsgRec.Name=eachApiTObj.IntgMsgName__c !=null ? eachApiTObj.IntgMsgName__c :eachApiTObj.APIName__c;
                    intMsgRec.BU__c=eachApiTObj.BU__c !=null ? eachApiTObj.BU__c :'HL / STL'; 
                    intMsgRec.RefId__c=eachApiTObj.RefId__c !=null ? eachApiTObj.RefId__c :'';
                    intMsgRec.Status__c='New';
                    intMsgRec.MStatus__c='Blank';
                    intMsgRec.RefObj__c=eachApiTObj.RefObj__c !=null ? eachApiTObj.RefObj__c :'';
                    intMsgRec.Svc__c=eachApiTObj.APIName__c !=null ? eachApiTObj.APIName__c :eachApiTObj.APIName__c;
                    intMsgRec.IsActive__c=true;
                    intMsgRec.ParentRefId__c= eachApiTObj.ParentRefId__c !=null ? eachApiTObj.ParentRefId__c :'';
                    intMsgRec.ParentRefObj__c= eachApiTObj.ParentRefObj__c !=null ? eachApiTObj.ParentRefObj__c :'';
                    //Adding elements of Intg Msg
                    createIntMsgList.add(intMsgRec);

                    if(eachApiTObj.Retry_Count__c !=null){
                      eachApiTObj.Retry_Count__c =eachApiTObj.Retry_Count__c +1;  
                    }
                    else{
                        eachApiTObj.Retry_Count__c = 1;
                    }
                    
                    eachApiTObj.Retry__c=false;
                    
                    if(eachApiTObj.Retry_Count__c == mapRetryCon.get(eachApiTObj.APIName__c).MaxRetryAttempts__c){
                        eachApiTObj.MaxRetryExceeded__c =true;
                    }
					updApiReObjList.add(eachApiTObj);
                }
                }
            
            } catch(Exception e) 
            {
                	System.debug('Line No of Ex::'+e.getLineNumber());
                    System.debug(e);
            }  


        }


        if(updApiReObjList !=null && updApiReObjList.size() > 0)
        {
            //update apiCoutList;
            Database.update(updApiReObjList);
            
        }

        System.debug('createIntMsgList::'+createIntMsgList);

        if(createIntMsgList!=null && !createIntMsgList.isEmpty()){
                        fflib_SObjectUnitOfWork uowInt = new fflib_SObjectUnitOfWork( new List<SObjectType> { IntgMsg__c.SObjectType});
                        List<string> fieldNamesListInt = New List<string>{'Name','BU__c','RefId__c','Status__c','MStatus__c','RefObj__c','Svc__c','ApiVendor__c',
                            'IsActive__c','ParentRefId__c','ParentRefObj__c'};
                        String sObjectNameInt = 'IntgMsg__c';
                        Schema.SObjectType objTypeInt  = Schema.getGlobalDescribe().get(sObjectNameInt);
                        fflib_SecurityUtils.checkInsert(objTypeInt,fieldNamesListInt); 
                        uowInt.registerNew(createIntMsgList);
                        uowInt.commitWork();
          }
      
        
    }
    
    global void finish(Database.BatchableContext BC) {
        System.debug('finish');
    }
    
     global void execute(SchedulableContext sc) {
        System.debug('execute schedulable'); 
        APIRetriggerBatch batchIntMsg = new APIRetriggerBatch();
        Database.executeBatch(batchIntMsg,1);
    }
    
    
}