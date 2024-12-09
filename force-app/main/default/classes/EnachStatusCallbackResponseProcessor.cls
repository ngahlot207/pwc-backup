public class EnachStatusCallbackResponseProcessor {
	public Static void process(List<IntgMsg__c> responses) {
		try {
			//fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { IntgMsg__c.SObjectType });
            //List<IntgMsg__c> updateIntRecords = new List<IntgMsg__c>();
			Map<String,EnachStatusResponseWrapper> jsonresponsemap=new  Map<String,EnachStatusResponseWrapper> ();
			Map<String,String> intgMsgRefIdsMap = new Map<String,String>();
			for(IntgMsg__c integrationMessage:responses) {
                if(integrationMessage.Req__c != null ) {
                    EnachStatusResponseWrapper res = (EnachStatusResponseWrapper) JSON.deserialize(integrationMessage.Req__c, EnachStatusResponseWrapper.class);
                    if(String.isNotBlank(res.payload.api_mandate.id)) {
                        jsonresponsemap.put(res.payload.api_mandate.id,res);
                        intgMsgRefIdsMap.put(integrationMessage.Id,res.payload.api_mandate.id);
                    }
                    /*IntgMsg__c intg = New IntgMsg__c();
                    intg.id = integrationMessage.Id;
                    intg.Status__c = 'Processed';
                    updateIntRecords.add(intg);*/
                }
            }
			
			if(!jsonresponsemap.isempty()){
                enachCallbackSucess(intgMsgRefIdsMap,jsonresponsemap); 
                
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
		catch(Exception ex) {
            GlobalUtility.logMessage('Error', 'EnachStatusCallbackResponseProcessor', 'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
	}
	
	Public static void enachCallbackSucess(Map<String,String> intgMsgRefIdsMap,Map<String,EnachStatusResponseWrapper> responsemap) {
		try {
			fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { NACH__c.SObjectType,IntgMsg__c.SObjectType });
			if(!responsemap.isempty()) {
				List<NACH__c> nachList = new List<NACH__c>();
                List<IntgMsg__c> updateIntgMsgRecords = new List<IntgMsg__c>(); 
                Map<String,NACH__c> nachMap = new Map<String,NACH__c>();
				for(NACH__c temp:[SELECT Id, Mandate_Id__c,UMRN__c,LoanAppl__c,LoanAppl__r.Applicant__c FROM NACH__c WHERE Mandate_Id__c IN:responsemap.keyset()]) {
                   	nachMap.put(temp.Mandate_Id__c,temp);
                    if(responsemap.containskey(temp.Mandate_Id__c)){
                        NACH__c nachRec = new NACH__c();
                        nachRec.id = temp.Id;
                        //if(String.isNotBlank(responsemap.get(temp.Mandate_Id__c).payload.api_mandate.txn_reject_reason)) {
                        nachRec.eNACH_Rejection_Reasons__c = String.isNotBlank(responsemap.get(temp.Mandate_Id__c).payload.api_mandate.txn_reject_reason) ? responsemap.get(temp.Mandate_Id__c).payload.api_mandate.txn_reject_reason : '';
                        //}
                        //if(String.isNotBlank(responsemap.get(temp.Mandate_Id__c).payload.api_mandate.current_status)) {
                        nachRec.eNACH_Registration_Status__c = String.isNotBlank(responsemap.get(temp.Mandate_Id__c).payload.api_mandate.current_status) ? responsemap.get(temp.Mandate_Id__c).payload.api_mandate.current_status : '';
                        //}
                        //if(responsemap.get(temp.Mandate_Id__c).payload.api_mandate.umrn!=null && String.isNotBlank(responsemap.get(temp.Mandate_Id__c).payload.api_mandate.umrn)) {
                        nachRec.UMRN__c = (responsemap.get(temp.Mandate_Id__c).payload.api_mandate.umrn!=null && String.isNotBlank(responsemap.get(temp.Mandate_Id__c).payload.api_mandate.umrn)) ? responsemap.get(temp.Mandate_Id__c).payload.api_mandate.umrn : '';
                        //}
                        if(responsemap.get(temp.Mandate_Id__c).created_at!=null && String.isNotBlank(responsemap.get(temp.Mandate_Id__c).created_at)){
                            
                            Long created_at=Long.valueof(responsemap.get(temp.Mandate_Id__c).created_at);
                            Datetime unixTimeStamp=DateTime.newInstance(created_at);
                            
                            nachRec.EnachResponseDateTime__c=unixTimeStamp;
                        }
                        nachList.add(nachRec);
                    }
				}
				
                if(!intgMsgRefIdsMap.isEmpty()){
                    for(String intgMsgId : intgMsgRefIdsMap.keySet()){
                        IntgMsg__c intg = new IntgMsg__c();
                        intg.id =  intgMsgId;
                        intg.Status__c = 'Processed';
                        if(nachMap.containskey(intgMsgRefIdsMap.get(intgMsgId))){
                            if(nachMap.get(intgMsgRefIdsMap.get(intgMsgId)).LoanAppl__c!=null){
                                intg.LoanAppln__c = nachMap.get(intgMsgRefIdsMap.get(intgMsgId)).LoanAppl__c;
                                if(nachMap.get(intgMsgRefIdsMap.get(intgMsgId)).LoanAppl__r.Applicant__c!=null){
                                    intg.Appl__c = nachMap.get(intgMsgRefIdsMap.get(intgMsgId)).LoanAppl__r.Applicant__c;
                                }
                            }
                        }
                        updateIntgMsgRecords.add(intg);
                    }
                }
                
				if(!nachList.isEmpty()){
					List<string> fieldNamesList = New List<string>{ 'eNACH_Registration_Status__c','eNACH_Rejection_Reasons__c','UMRN__c','EnachResponseDateTime__c'};
                    String sObjectName = 'NACH__c';
					Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
					fflib_SecurityUtils.checkUpdate(objType,fieldNamesList); 
					uow.registerDirty(nachList);
				}
                if(updateIntgMsgRecords!=null && !updateIntgMsgRecords.isEmpty()){
                    String sObjectName = 'IntgMsg__c';
                    List<String> fieldNamesList = new List<String>{'Status__c','LoanAppln__c','Appl__c'};
                        Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                    uow.registerDirty(updateIntgMsgRecords);
                }
                uow.commitWork();
			}
		}
		
		//Exception Handling
		catch(Exception ex) {
            GlobalUtility.logMessage('Error', 'EnachStatusCallbackResponseProcessor', 'enachCallbackSucess', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
	}
}