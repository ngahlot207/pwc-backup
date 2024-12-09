public class WorkappPDGetRequestGenerator implements ICalloutRequestGenerator{

    public void generate(List<IntgMsg__c> msgs, String service, String processType){ 
        try{
        if (msgs.isEmpty()) {
            return;
        }

        Map<Id, PD__c> perDiscRecordsMap = new Map<Id, PD__c>();
        IntgSvcMgmt__mdt svc = IntgSvcMgmt__mdt.getInstance('Guest_Call_Details');
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { IntgMsg__c.SObjectType });
        List<IntgMsg__c> updateIntRecords = new List<IntgMsg__c>();
        
        if(msgs !=null && !msgs.isEmpty()){
        
            for(IntgMsg__c intMsg : msgs){

                Id persDisId = intMsg.RefId__c !=null ? intMsg.RefId__c :'';

                for(PD__c eachPerDiscObj : [SELECT ID, WorkAppVideoPdId__c FROM PD__c WHERE Id =: persDisId]){
                    perDiscRecordsMap.put(eachPerDiscObj.Id,eachPerDiscObj);  
                }

                PD__c perDisObj = persDisId!=null ?  perDiscRecordsMap.get(persDisId) :null;

                if(perDisObj !=null){

                    Map<String,String> header = new Map<String,String>();
                    Datetime crDateTime = intMsg.CreatedDate;

                    Long reqTimestamp = (crDateTime.getTime());
                    header.put('Timestamp',String.valueOf(reqTimestamp));
                    header.put('Signature',WorkAppCommonReqWrapper.getSignByMainLogic(reqTimestamp));
                    header.put('RequestId',intMsg.Integration_Message_Number__c +'-'+crDateTime.getTime());
                    header.put('GroupId',perDisObj.WorkAppVideoPdId__c);
                                        
                    Map<String, Object> combinedMap = new Map<String, Object>();
                    combinedMap.put('Payload', '');
                    combinedMap.put('Header', header);
                    
                    // Serialize the combined map
                    String jsonString = JSON.serialize(combinedMap);
                    
                    IntgMsg__c intg=New IntgMsg__c();
                    intg.id=intMsg.id;
                    intg.Req__c = jsonString; 
                    intg.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                    updateIntRecords.add(intg);


                }
                }
            }

                if(!updateIntRecords.isEmpty()) {
                    String sObjectName = 'IntgMsg__c';
                    List<String> fieldNamesList = new List<String>{'Req__c','Status__c'};
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                    uow.registerDirty(updateIntRecords);
                }    
            uow.commitWork();
    }
    catch(Exception ex){
        System.debug('error'+ex.getMessage());
        GlobalUtility.logMessage('Error', 'WorkappPDGetRequestGenerator' + ex.getLineNumber(), 
                                 'Generate', null, null, ex.getMessage() + ' Line: ' + ex.getLineNumber(), null, ex, null);
    }   
    }

}