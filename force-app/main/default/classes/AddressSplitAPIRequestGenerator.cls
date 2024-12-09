public class AddressSplitAPIRequestGenerator implements ICalloutRequestGenerator{
    
    public void generate(List<IntgMsg__c> msgs, String service, String processType){
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> { IntgMsg__c.SObjectType,ApplKyc__c.SObjectType});
        
        if(!msgs.isempty()){
            
            try{
                
                List<IntgMsg__c> updateIntMsgRecords = new List<IntgMsg__c>();
                List<ApplKyc__c> updateKycRecords = new List<ApplKyc__c>();
                Set<Id> applicantKycIds =new Set<Id>();
                
                //Getting All ApplicantKyc Ids
                for(IntgMsg__c msg :msgs){
                    
                    if(String.isnotBlank(msg.ParentRefId__c)){
                        applicantKycIds.add(msg.ParentRefId__c);
                    }
                }
                
                if(!applicantKycIds.isempty()){
                    //Getting the ApplKyc__c
                    Map<Id,ApplKyc__c> applicantKycMap =new Map<Id,ApplKyc__c>([Select id,Address__c from ApplKyc__c Where Id IN :applicantKycIds]);
                    
                    //Static values
                    IntgSvcMgmt__mdt svc = IntgSvcMgmt__mdt.getInstance('Address_Split');
                    
                    //Looping IntgMsg__c
                    for(IntgMsg__c intmsg :msgs){
                        
                        if(applicantKycMap.containsKey(intmsg.ParentRefId__c)){
                            
                            ApplKyc__c kyc = applicantKycMap.get(intmsg.ParentRefId__c);
                            
                            AddressSplitAPIRequestWrapper.ClientData clientdata =new AddressSplitAPIRequestWrapper.ClientData();
                            clientdata.caseId=intmsg.Integration_Message_Number__c;
                            
                            AddressSplitAPIRequestWrapper.Config config =new AddressSplitAPIRequestWrapper.Config();
                            config.get_state_by_brute_force=false;
                            
                            AddressSplitAPIRequestWrapper request =new AddressSplitAPIRequestWrapper();
                            request.address=string.isNotblank(kyc.Address__c)?kyc.Address__c:'';
                            request.config=Config;
                            request.version=string.isNotBlank(svc.ProcessCode__c)?svc.ProcessCode__c:'';
                            request.clientData=clientdata;


                            IntgMsg__c integrationMessage =new IntgMsg__c();
                            integrationMessage.Id=intmsg.Id;
                            integrationMessage.Req__c=JSON.serialize(request);
                            integrationMessage.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                            updateIntMsgRecords.add(integrationMessage);
                            
                            ApplKyc__c appkyc =new ApplKyc__c();
                            appkyc.Id=kyc.Id;
                            appkyc.AdrsSplitStatus__c='In progress';
                            updateKycRecords.add(appkyc);
                        }
                    }
                    
                }
                
                //Updating the IntgMsg
                if(!updateIntMsgRecords.isEmpty()) {
                    String sObjectName = 'IntgMsg__c';
                    List<String> fieldNamesList = new List<String>{'Req__c','Status__c'};
                        Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                    uow.registerDirty(updateIntMsgRecords);
                }
                
                //Updating the ApplKyc__c
                if(!updateKycRecords.isEmpty()) {
                    String sObjectName = 'ApplKyc__c';
                    List<String> fieldNamesList = new List<String>{'AdrsSplitStatus__c'};
                        Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                    uow.registerDirty(updateKycRecords);
                }
                uow.commitWork();
                
            }catch(Exception ex){
                GlobalUtility.logMessage('Error', 'AddressSplitAPIRequestGenerator class', 
                                         'generate', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
        }
    }
}