public class WorkappPDGetResponseProcessor implements IintMsgCalloutResponseProcessor {

    public static void process(List<IntgMsg__c> responses) {
        if (responses.isEmpty()) {
            return;
        }

        Set<Id> refIds = new Set<Id>();
        List<PDResp__c> pdResList = new List<PDResp__c>();
        Map<Id, List<WorkappPDGetResponseWrapper.VideoCalls>> videoCallsMap = new Map<Id, List<WorkappPDGetResponseWrapper.VideoCalls>>();
        Map<Id, List<WorkappPDGetResponseWrapper.Documents>> documentsMap = new Map<Id, List<WorkappPDGetResponseWrapper.Documents>>();

        // Validate all responses and collect reference IDs
        for (IntgMsg__c intmsg : responses) {
            if (intmsg.Svc__c != GlobalConstants.INT_CONFIG_SERVICE_WORKAPPS_GET_API_SERVICE
                && intmsg.BU__c != GlobalConstants.INT_MSG_BU_TYPE) {
                throw new processException('Error! This is not the correct service');
            }
            refIds.add(intmsg.RefId__c);
        }

        // Query all related PD records in one go
        Map<Id, PD__c> pdMap = new Map<Id, PD__c>([
            SELECT Id, Name FROM PD__c WHERE Id IN :refIds
        ]);

        // Process each response and prepare PDResp__c list
        for (IntgMsg__c intmsg : responses) {
            try {
                WorkappPDGetResponseWrapper responseWrapper = (WorkappPDGetResponseWrapper) JSON.deserialize(intmsg.Resp__c, WorkappPDGetResponseWrapper.class);
                List<PD__c> listPds = new List<PD__c>();
                if(responseWrapper!=null && responseWrapper.scpUrl !=null && responseWrapper.firstName !=null){
                    //Success
                    
                    
                    
                    PD__c pdEach =new PD__c();
                    pdEach.Id=intmsg.RefId__c;
                    pdEach.WorkAppVideoPdGetStatus__c ='Success';
                    listPds.add(pdEach);


                    if (responseWrapper.videoCalls != null && !responseWrapper.videoCalls.isEmpty()) {
                        //videoCallsMap.put(intmsg.RefId__c, responseWrapper.videoCalls);
                        for (WorkappPDGetResponseWrapper.VideoCalls eachVideoData : responseWrapper.videoCalls) {
                            PDResp__c pdResObj = new PDResp__c();
                            pdResObj.CustVidRec__c = eachVideoData.customerVideoRecording;
                            pdResObj.PrsnlDisc__c = intmsg.RefId__c;
                            pdResObj.AgentVideoRecLink__c=eachVideoData.agentVideoRecording;
                            
                            pdResList.add(pdResObj);
                        }
                    }
    
                    if (responseWrapper.documents != null && !responseWrapper.documents.isEmpty()) {
                       // documentsMap.put(intmsg.RefId__c, responseWrapper.documents);
                        for (WorkappPDGetResponseWrapper.Documents eachDocs : responseWrapper.documents) {
                            PDResp__c pdResObj = new PDResp__c();
                            pdResObj.DocFileName__c = eachDocs.fileName;
                            pdResObj.PrsnlDisc__c = intmsg.RefId__c;
                            pdResObj.DocumentType__c=eachDocs.documentType;
                            pdResObj.DocUrl__c=eachDocs.url;
                            
                            pdResList.add(pdResObj);
                        }
                        
                    }
                    

                    if(listPds !=null && !listPds.isEmpty()){
                        insert listPds;  
                    } 

                    if(pdResList !=null && !pdResList.isEmpty()){
                        insert pdResList;   
                    }
                    APICalloutTracker.update_ApiTrackerWithIntMsg(intmsg.Id,intmsg.Svc__c, intmsg.RefId__c, 'Success');
                }else{
                    //failure
                    processFailure(responseWrapper.message,intmsg.RefId__c,intmsg.ParentRefId__c);
                    APICalloutTracker.update_ApiTrackerWithIntMsg(intmsg.Id,intmsg.Svc__c, intmsg.RefId__c, 'Failure');


                }
                
                //updatePersonalDisStatus(intmsg, intmsg.RefId__c, responseWrapper, pdMap.get(intmsg.RefId__c));
               
                }
                catch (Exception ex) {
                GlobalUtility.logMessage('Error', 'WorkappPDGetResponseProcessor',
                    'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
                system.debug('error message and line number ' + ex.getMessage() + ' line ' + ex.getLineNumber());
            }
        }
    }



    public static void processFailure(String errormessage,Id refId,Id parentRefId){
        try{
            
            List<PD__c> pdObjList=new List<PD__c>();
            
            if(refId!=null && String.isNotBlank(errormessage)){
                
                PD__c pdEach =new PD__c();
                pdEach.Id=refId;
                pdEach.WorkAppVideoPdGetAPIError__c=errormessage;
                pdEach.WorkAppVideoPdGetStatus__c='Failure';
                pdObjList.add(pdEach);
            }
            if(!pdObjList.isEmpty()) {
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> {PD__c.SObjectType}); 
                String sObjectName = 'PD__c';
                List<String> fieldNamesList = new List<String>{'WorkAppVideoPdGetAPIError__c','WorkAppVideoPdGetStatus__c'};
                Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                uow.registerDirty(pdObjList);
                uow.commitWork();
            }
            
        }catch (Exception ex) {
            GlobalUtility.logMessage('Error', 'WorkappPDGetResponse Processor', 
                                     'processFailure', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
    }


    // public static void updatePersonalDisStatus(IntgMsg__c integrationMessage, Id referenceId, WorkappPDGetResponseWrapper responseWrapper, PD__c pdRecord) {
    //     // Implement the logic for updating personal status

    //     //modify this success logic
    //     if(responseWrapper.scpUrl!=null){

    //     }
    //     //failure
    //     else{


    //     }
    // }

    // public static String getSignature(String path, String apiSecret) {
    //     try {
    //         Blob mac = Crypto.generateMac('HmacSHA256', Blob.valueOf(path), Blob.valueOf(apiSecret));
    //         String signature = EncodingUtil.base64Encode(mac);
    //         return signature;
    //     } catch (Exception e) {
    //         // Handle the exception if HMAC generation fails
    //         System.debug('Error generating HMAC: ' + e.getMessage());
    //         return null;
    //     }
    // }
}