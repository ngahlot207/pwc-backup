/**
 * @description       : Hunter Response Processor Class
 * @author            : Ripul Rawat
 * @last modified on  : 10-09-2023
 * @last modified by  : Ripul Rawat
**/

public class HunterTokenResponseProcessor implements IintMsgCalloutResponseProcessor {
    //Implementing the process method
    public static void process(List<IntgMsg__c> responses) {
        try {
            //Processing all responses
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { IntgMsg__c.SObjectType });
            List<IntgMsg__c> intMsgRecsToInsert = new List<IntgMsg__c>();
            for(IntgMsg__c integrationMessage : responses) {
                if(integrationMessage.Svc__c != GlobalConstants.INT_CONFIG_SERVICE_HUNTER_TOKEN_SERVICE
                   && integrationMessage.BU__c != GlobalConstants.INT_MSG_BU_TYPE) {
                       throw new processException('Error! This is not the correct service'); 
                   }
                
                //parse response
                HunterTokenResponseParser responseWrapper = (HunterTokenResponseParser)JSON.deserialize(integrationMessage.Resp__c, HunterTokenResponseParser.class); 
                Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(integrationMessage.Resp__c);
                
                //check if responseWrapper is empty or not
                if(responseWrapper != null) {
                    system.debug('###responseWrapper- '+ responseWrapper);
                    if(responseMap.containsKey('access_token')  && responseMap.get('access_token') != NULL) { 
                        IntgMsg__c intMsgRec = new IntgMsg__c();
                        intMsgRec.Name = GlobalConstants.INT_CONFIG_SERVICE_HUNTER_API_SERVICE;
                        intMsgRec.BU__c = GlobalConstants.INT_MSG_BU_TYPE_HUNTER;
                        intMsgRec.Status__c = GlobalConstants.INT_MSG_STATUS_NEW;
                        intMsgRec.MStatus__c = GlobalConstants.INT_MSG_MStatus_BLANK;
                        intMsgRec.Svc__c = GlobalConstants.INT_CONFIG_SERVICE_HUNTER_API_SERVICE;
                        intMsgRec.ParentRefId__c = integrationMessage.Id;
                        intMsgRec.ParentRefObj__c = 'IntgMsg__c';
                        intMsgRec.RefId__c = integrationMessage.RefId__c;
                        intMsgRec.RefObj__c = integrationMessage.RefObj__c;
                        intMsgRec.IsActive__c = true;
                        intMsgRec.ApiVendor__c = 'Experian';
                        intMsgRecsToInsert.add(intMsgRec);
                        APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Success');
                    } 
                    else{
                        APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Failure');
                    }
                }
            } 
            if(!intMsgRecsToInsert.isEmpty()) {
                List<string> fieldNamesList = New List<string>{ 'Name', 'BU__c', 'Status__c', 'MStatus__c', 'Svc__c', 'ParentRefId__c', 'ParentRefObj__c', 'RefId__c', 'RefObj__c', 'IsActive__c', 'ApiVendor__c' };
                String sObjectName = 'IntgMsg__c';
                Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkInsert(objType,fieldNamesList);
                uow.registerNew(intMsgRecsToInsert);
                uow.commitWork();
            }
        }
        //Exception Handling
        catch(Exception ex) {
        	GlobalUtility.logMessage('Error', 'HunterTokenResponseProcessor', 'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        } 
    }
}