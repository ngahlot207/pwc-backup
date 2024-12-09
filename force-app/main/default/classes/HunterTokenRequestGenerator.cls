/**
 * @description       : Hunter Request Generator Class
 * @author            : Ripul Rawat
 * @last modified on  : 10-09-2023
 * @last modified by  : Ripul Rawat
**/

public class HunterTokenRequestGenerator implements ICalloutRequestGenerator {
	public void generate(List<IntgMsg__c> msgs, String service, String processType) { 
		fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( 
            new List<SObjectType> { IntgMsg__c.SObjectType }
        );
		try {
			if(!msgs.isEmpty()) {
				HunterTokenRequestParser hunterTokenDetails = new HunterTokenRequestParser(); 
				hunterTokenDetails.username = Label.HunterUserName;
				hunterTokenDetails.password = Label.HunterIntegrationPassword;
				hunterTokenDetails.client_id = Label.HunterClientId;
				hunterTokenDetails.client_secret = Label.HunterClientSecret;
				String requestBody = JSON.serialize(hunterTokenDetails);
				
				List<IntgMsg__c> updateIntrecods = new List<IntgMsg__c>();
				for(IntgMsg__c intMsg : msgs) {
					IntgMsg__c intg = New IntgMsg__c();
                    intg.id = intMsg.Id;
                    intg.Req__c = requestBody; 
                    intg.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                    updateIntrecods.add(intg);
				}
				if(!updateIntrecods.isEmpty()) {
                    String sObjectName = 'IntgMsg__c';
                    List<String> fieldNamesList = new List<String>{ 'Req__c', 'Status__c' };
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                    uow.registerDirty(updateIntrecods);
                    uow.commitWork();
                }
			}
			
		}
		catch(Exception ex) {
            System.debug('error'+ex.getMessage());
            GlobalUtility.logMessage('Error', 'HunterTokenRequestGenerator' + ex.getLineNumber(), 
                                     'Generate', null, null, ex.getMessage() + ' Line: ' + ex.getLineNumber(), null, ex, null);
        }
	}
}