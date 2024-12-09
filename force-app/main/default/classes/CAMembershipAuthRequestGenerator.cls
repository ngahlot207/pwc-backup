public class CAMembershipAuthRequestGenerator implements ICalloutRequestGenerator {
    
    public void generate(List<IntgMsg__c> msgs,String service, String processType) {
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType>{ IntgMsg__c.SObjectType } );
        
        if(!msgs.isempty()){
            try{
                Set<Id> applicantIds =new Set<Id>();
                for(IntgMsg__c intMsg :msgs){
                    
                    if(String.isnotBlank(intMsg.RefId__c)){
                        applicantIds.add(intMsg.RefId__c);
                    }
                }
                
                Map<Id,Applicant__c> applicantEmpMap =new Map<Id,Applicant__c>([SELECT Id,MembershipNumber__c FROM Applicant__c where Id IN:applicantIds]);
                List<IntgMsg__c> updateIntMsgRecords = new List<IntgMsg__c>();
                
                for(IntgMsg__c intMsg :msgs){
                    
                    if(applicantEmpMap.containsKey(intMsg.RefId__c)){
                        
                        CAMembershipAuthRequestWrapper requestBody = new CAMembershipAuthRequestWrapper();
                        
                        CAMembershipAuthRequestWrapper.ClientData clientData = new CAMembershipAuthRequestWrapper.ClientData();
                        clientData.caseId=intmsg.Integration_Message_Number__c;
                        
                        requestBody.membership_no = applicantEmpMap.get(intMsg.RefId__c).MembershipNumber__c!=null ? String.valueOf(applicantEmpMap.get(intMsg.RefId__c).MembershipNumber__c) : '';
                        requestBody.contactDetails = TRUE;
                        requestBody.consent = GlobalConstants.CONSENT_Y;
                        requestBody.clientData = clientData;
                        
                        IntgMsg__c integrationMessage =new IntgMsg__c();
                        integrationMessage.Id=intmsg.Id;
                        integrationMessage.Req__c=JSON.serialize(requestBody);
                        integrationMessage.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                        updateIntMsgRecords.add(integrationMessage);
                        
                    }
                
                }
                
                
                if(!updateIntMsgRecords.isEmpty()) {
                    String sObjectName = 'IntgMsg__c';
                    List<String> fieldNamesList = new List<String>{'Req__c','Status__c'};
                        Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                    uow.registerDirty(updateIntMsgRecords);
                }
                uow.commitWork();
                
            }
            catch(Exception ex){
                GlobalUtility.logMessage('Error', 'CAMembershipAuthRequestGenerator class', 
                                         'generate', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
        }
    
    }
    
}