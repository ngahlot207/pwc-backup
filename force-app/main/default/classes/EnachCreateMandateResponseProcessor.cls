public class EnachCreateMandateResponseProcessor implements IintMsgCalloutResponseProcessor {

	//Implementing the process method
    public static void process(List<IntgMsg__c> responses) {
		
		//Processing all responses
        for(IntgMsg__c integrationMessage : responses) {
		
			try {
				if(integrationMessage.Svc__c != GlobalConstants.INT_CONFIG_SERVICE_MANDATE_CREATE_FORM_SERVICE && integrationMessage.BU__c != GlobalConstants.INT_MSG_BU_TYPE) {
					throw new processException('Error! This is not the correct service'); 
				}
				
				EnachCreateMandateResponseWrapper responseWrapper = (EnachCreateMandateResponseWrapper) JSON.deserialize(integrationMessage.Resp__c, EnachCreateMandateResponseWrapper.class); 
				Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(integrationMessage.Resp__c);
				if(responseWrapper != null) {
					if(integrationMessage.RefObj__c == 'NACH__c') {
						if(responseMap.containsKey('mandate_id') && responseMap.containsKey('state')) {
							updateNACHRecord(integrationMessage.RefId__c, responseWrapper, integrationMessage);
						}
						else if(!responseMap.containsKey('mandate_id') && responseMap.containsKey('message')) {
							updateNACHErrorRecord(integrationMessage.RefId__c, responseWrapper, integrationMessage);
						}
					}
				}
			}
			
			//Exception Handling
			catch(Exception ex){
                GlobalUtility.logMessage('Error', 'EnachCreateMandateResponseProcessor', 'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
		}
	}
	
	public static void updateNACHRecord(Id referenceid,EnachCreateMandateResponseWrapper responseWrapper, IntgMsg__c integrationMessage) {
		
		try {
			fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { NACH__c.SObjectType });
			List<string> fieldNamesList = New List<string>{ 'Mandate_Id__c','eNACH_Registration_Status__c','eNACH_Rejection_Reasons__c' };
			String sObjectName = 'NACH__c';
			Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
			fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
			NACH__c updateRec = New NACH__c();
			updateRec.Id = referenceid;
			updateRec.Mandate_Id__c = responseWrapper.mandate_id != null ? responseWrapper.mandate_id : null;
			updateRec.eNACH_Registration_Status__c = responseWrapper.state != null ? responseWrapper.state == 'partial' ? GlobalConstants.MANDATE_CREATE_FORM_SERVICE_RESPONSE_STATE_PARTIAL : null : null;
            updateRec.eNACH_Rejection_Reasons__c='';
			uow.registerDirty(updateRec);
			uow.commitWork();
		}
		
		//Exception Handling
		catch(Exception ex){
            GlobalUtility.logMessage('Error', 'EnachCreateMandateResponseProcessor', 'updateNACHRecord', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Success');
	}
	
	public static void updateNACHErrorRecord(Id referenceid,EnachCreateMandateResponseWrapper responseWrapper, IntgMsg__c integrationMessage) {
		
		try {
			fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { NACH__c.SObjectType });
			List<string> fieldNamesList = New List<string>{ 'eNACH_Registration_Status__c','eNACH_Rejection_Reasons__c','EnachResponseDateTime__c'};
			String sObjectName = 'NACH__c';
			Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
			fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
			NACH__c updateRec = New NACH__c();
			updateRec.Id = referenceid;
            updateRec.eNACH_Registration_Status__c='Failed';
			updateRec.eNACH_Rejection_Reasons__c = responseWrapper.message != null ? responseWrapper.message : null;
            updateRec.EnachResponseDateTime__c = System.now();
			uow.registerDirty(updateRec);
			uow.commitWork();
		}
		
		//Exception Handling
		catch(Exception ex){
            GlobalUtility.logMessage('Error', 'EnachCreateMandateResponseProcessor', 'updateNACHErrorRecord', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Failure');
	}
}