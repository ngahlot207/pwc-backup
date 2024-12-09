public class DedupeAccessTokenRequestGenerator implements ICalloutRequestGenerator{
    
    public void generate(List<IntgMsg__c> msgs, String service, String processType){ 
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> { IntgMsg__c.SObjectType });
        
        try{
            List<IntgMsg__c>updateIntMsgList=New List<IntgMsg__c>(); 
            
            //If the List of new Integration Message records is not empty, then iterating over and assigning data to variables from Wrapper Class            
            if(!msgs.isEmpty()){
                for(IntgMsg__c intMsg : msgs){
                    
                    if(intMsg.RefId__c!=null){
                        IntgMsg__c intg=New IntgMsg__c();
                        intg.id=intMsg.id;
                        intg.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                        updateIntMsgList.add(intg);
                    }
                    else{
                        throw new DedupeAccessTokenRequestException('Reference Id missing');
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
        //Catch bloack to catch Exceptions occured during generation of payload and displaying the passing the same in GlobalUtility class
        catch(Exception ex){
            GlobalUtility.logMessage('Error', 'DedupeAccessTokenRequestGenerator' + ex.getLineNumber(), 
                                     'Generate', null, null, ex.getMessage() + ' Line: ' + ex.getLineNumber(), null, ex, null);
        }
        
    }
    public class DedupeAccessTokenRequestException extends Exception {
        
    }
}