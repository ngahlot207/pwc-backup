public class UpdateLLPCompreDetailsResponseProcessor implements IintMsgCalloutResponseProcessor{

    public static void process(List<IntgMsg__c> responses) {

        if(!responses.isEmpty()){
            
            Map<IntgMsg__c,UpdateLLPCompreDetailsResponseWrapper> successResponseMap = new Map<IntgMsg__c,UpdateLLPCompreDetailsResponseWrapper>();
            Map<IntgMsg__c,String> failureResponseMap = new Map<IntgMsg__c,String>();
            
            for(IntgMsg__c intmsg:responses){
                
                if(String.isNotBlank(intmsg.Resp__c)){
                    
                    try{
                        UpdateLLPCompreDetailsResponseWrapper  res =(UpdateLLPCompreDetailsResponseWrapper) JSON.deserialize(intmsg.Resp__c,UpdateLLPCompreDetailsResponseWrapper.class);
                        
                        if(res !=null && res.data !=null && res.data.request_id!=null){    
                            successResponseMap.put(intmsg,res);
                        }
                        else if(res !=null && res.message !=null){
                            failureResponseMap.put(intmsg,res.message);
                        }
                        
                    }catch(Exception ex){
                        GlobalUtility.logMessage('Error', 'UpdateLLPCompreDetailsResponseProcessor class', 
                                                 'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
                        
                        failureResponseMap.put(intmsg,IntegrationUtility.getCustomErrorMessage(ex.getMessage().substringBefore(':')));
                    }
                }
            }
            
            if(!successResponseMap.isEmpty()){
                processSuccess(successResponseMap);
            }
            
            if(!failureResponseMap.isEmpty()){
                processFailure(failureResponseMap);
            }
        }

    }

    public static void processSuccess(Map<IntgMsg__c, UpdateLLPCompreDetailsResponseWrapper> successResp) {
        try {

          fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType>{IntgMsg__c.SObjectType, APIVer__c.SObjectType, APIVerDtl__c.SObjectType});
          
            Set<Id> applicantIds = new Set<Id>();

            for (IntgMsg__c intmsg : successResp.keySet()) {
                if (String.isNotBlank(intmsg.RefId__c)) {
                    applicantIds.add(intmsg.RefId__c);
                }
            }

            if(!applicantIds.isEmpty()){
            List<APIVer__c> existingApiVers = getExistingApiVerRecords(applicantIds);
            if (!existingApiVers.isEmpty()) {
                IntegrationUtility.updateBooleanFlag(existingApiVers, 'IsLatest__c', false);
            }
            }

            List<APIVer__c> apiVerListInsert = new List<APIVer__c>();

            //API ver data insert start
            for (IntgMsg__c msg : successResp.keySet()) {

                UpdateLLPCompreDetailsResponseWrapper resObj = successResp.get(msg);
                APIVer__c apiVerObj = new APIVer__c();
                apiVerObj.RecordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByDeveloperName().get('Probe42').getRecordTypeId();
                apiVerObj.Appl__c = msg.RefId__c;
                apiVerObj.IsLatest__c = true;
                apiVerObj.IntegrationStatus__c = 'Success';
                apiVerObj.UpdateApiType__c='Update LLP Comprehensive Details';
                apiVerObj.Type__c='Update LLP Details';

                if(resObj!=null){

                    if(resObj.data!=null && resObj.data.request_id!=null){
                        apiVerObj.UpdReqId__c =resObj.data.request_id;
                    }
                }
                apiVerListInsert.add(apiVerObj);
            }

            if(!apiVerListInsert.isEmpty()){
                List<String> fieldNamesList = new List<String>{
                        'IsLatest__c', 'RecordTypeId','AuthorizedCapital__c','Appl__c','ApiVersion__c','RequestId__c','UpdateApiType__c','IntegrationStatus__c','Type__c','UpdReqId__c' };
                String sObjectName = 'APIVer__c';
                Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkInsert(objType,fieldNamesList);
                uow.registerNew(apiVerListInsert);
                uow.commitWork();
            }

        }catch(Exception ex) {
            GlobalUtility.logMessage('Error', 'UpdateLLPCompreDetailsResponseProcessor',
                'processSuccess', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        
    }

     public static void processFailure(Map<IntgMsg__c,String> failureResp){
        
        try{
            
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> {ApplKyc__c.SObjectType,APIVer__c.SObjectType});
            
            Set<Id> applicantIds =new Set<Id>();
            List<APIVer__c> appVerList=new List<APIVer__c>();
            
            Id recordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByDeveloperName().get('Probe42').getRecordTypeId();
            
           
            for(IntgMsg__c msg:failureResp.keyset()){
                
                if(string.isNotblank(msg.RefId__c)){
                    applicantIds.add(msg.RefId__c);
                }
            }
            
            //SOQL to check old records
            if(applicantIds!=null){
            List<APIVer__c> apiVer =[Select id,Appl__c,IsLatest__c,RecordType.Name,Type__c from APIVer__c Where Appl__c IN:applicantIds AND RecordType.DeveloperName='Probe42' AND IsLatest__c=true and Type__c ='Update LLP Details'];
            if(!apiVer.isEmpty()){
                IntegrationUtility.updateBooleanFlag(apiVer,'IsLatest__c',false);
            }
            }
            
            
            for(IntgMsg__c msg:failureResp.keyset()){
                
                if(failureResp.containsKey(msg) && String.isNotblank(msg.RefId__c)){
                     
                    APIVer__c apiveri =new APIVer__c();
                            apiveri.Appl__c=msg.RefId__c;
                            apiveri.LoanAplcn__c=msg.ParentRefId__c;
                            apiveri.IntegrationStatus__c='Failure';
                            apiveri.Type__c='Update LLP Details';
                            apiveri.IntegrationErrorMessage__c=failureResp.get(msg);
                            apiveri.IsLatest__c=true;
                            apiveri.RecordTypeId=recordTypeId!=null?recordTypeId:'';
                            appVerList.add(apiveri);
                          
                }
                APICalloutTracker.update_ApiTrackerWithIntMsg(msg.Id,msg.Svc__c, msg.RefId__c, 'Failure');
            }
            
            //Creating API Verification Record
            if(!appVerList.isEmpty()) {
                String sObjectName = 'APIVer__c';
                List<String> fieldNamesList = new List<String>{'Appl__c','LoanAplcn__c','Type__c','IntegrationStatus__c','IntegrationErrorMessage__c','IsLatest__c','RecordTypeId'};
                
                Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                uow.registerNew(appVerList);
                uow.commitWork();
            }
            
        }catch (Exception ex) {
            GlobalUtility.logMessage('Error', 'UpdateLLPCompreDetailsResponseProcessor', 
                                     'processFailure', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
    }

    private static List<APIVer__c> getExistingApiVerRecords(Set<Id> applicantIds) {
        system.debug('making list true');
        return [SELECT Id, Appl__c, IsLatest__c, RecordType.Name,Type__c FROM APIVer__c WHERE Appl__c IN :applicantIds AND RecordType.DeveloperName = 'Probe42' AND IsLatest__c = true and Type__c ='Update LLP Details'];
    }
}