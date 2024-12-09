public class AadharVaultRequestGenerator implements ICalloutRequestGenerator {
    
    public void generate(List<IntgMsg__c> msgs, String service, String processType){ 
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> { IntgMsg__c.SObjectType });
        
        List<Id> Ids =new List<Id>();
        
        for(IntgMsg__c intMsg : msgs){ 
            Ids.add(intMsg.RefId__c);
        }
        
        Map<Id,ApplKyc__c> appKycMap = new Map<Id,ApplKyc__c>([SELECT Id,AadharEncripted__c FROM ApplKyc__c WHERE Id IN :Ids ]);
        
        try{
            List<IntgMsg__c>updateIntMsgList=New List<IntgMsg__c>(); 
            
            if(!msgs.isempty()){
                IntgSvcMgmt__mdt svc = IntgSvcMgmt__mdt.getInstance('Aadhar_Vault');
                for(IntgMsg__c intMsg : msgs){
                    
                    if(appKycMap.containsKey(intMsg.RefId__c)){
                        
                        ApplKyc__c applKycRec = appKycMap.get(intMsg.RefId__c);
                        
                        //string jsonbody=system.label.Aadhar_Vault_URL+'?UIDToken='+system.label.Aadhar_Vault_Token+'&AadhaarNo='+applKycRec.AadharEncripted__c + '&AppKey='+system.label.Aadhar_Vault_AppKey;
                        string jsonbody=+'callout:APIGateway?UIDToken='+svc.APIToken__c+'&AadhaarNo='+ applKycRec.AadharEncripted__c + '&AppKey='+svc.APIKey__c + '&RRN='+GlobalConstants.RRN;      
                        IntgMsg__c intg=New IntgMsg__c();
                        intg.id=intMsg.id;
                        //intg.Req__c = EncodingUtil.urlEncode(jsonbody, 'UTF-8'); 
                        intg.Req__c = jsonbody; 
                        intg.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                        updateIntMsgList.add(intg);
                        
                    }  
                }
                if(!updateIntMsgList.isEmpty()){
                    String sObjectName = 'IntgMsg__c';
                    List<String> fieldNamesList = new List<String>{'Req__c','Status__c'};
                        Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                    uow.registerDirty(updateIntMsgList);
                    
                }
            }
            uow.commitWork();
            
        }
        catch(Exception ex){
            GlobalUtility.logMessage('Error', 'AadharVaultRequestGenerator class', 
                                     'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        
    }
    
    
}