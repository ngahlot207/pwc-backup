public class CrifAuthLoginResponseProcessor implements IintMsgCalloutResponseProcessor{
    
    //Implementing the process method
    public static void process(List<IntgMsg__c> responses){ 
        
        try{
            List<IntgMsg__c> createRequestList = new List<IntgMsg__c>();
            for(IntgMsg__c integrationMessage : responses){
                
                try{
                    CrifAuthLoginResponseWrapper responseWrapper = (CrifAuthLoginResponseWrapper) JSON.deserialize(integrationMessage.Resp__c, CrifAuthLoginResponseWrapper.class); 
                    //check if responseWrapper is empty or not                
                    if(responseWrapper != null){
                        if(!String.isBlank(responseWrapper.access_token)){
                            IntgMsg__c intmsg =new IntgMsg__c();
                            intmsg.Name='Crif Execute API';
                            intmsg.BU__c='HL / STL';
                            intmsg.RefId__c=integrationMessage.RefId__c;
                            intmsg.Status__c='New';
                            intmsg.MStatus__c='Blank';
                            intmsg.RefObj__c=integrationMessage.RefObj__c;
                            intmsg.Svc__c='Crif Execute API';
                            intmsg.IsActive__c=true;
                            intmsg.ParentRefId__c=integrationMessage.Id;
                            intmsg.ParentRefObj__c='IntgMsg__c';
                            createRequestList.add(intmsg);
                            APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Success');
                        }
                        else if(!String.isBlank(responseWrapper.error)){
                            
                            if(integrationMessage.Trigger_Platform_Event__c){
                                publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                                platformWra.intId = integrationMessage.Id; 
                                platformWra.recId = integrationMessage.ParentRefId__c;
                                platformWra.ServiceName = integrationMessage.Svc__c ;
                                platformWra.Status = integrationMessage.Status__c ;
                                platformWra.errorMessage = String.isNotBlank(responseWrapper.message)?responseWrapper.message:responseWrapper.error;
                                publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
                            }
                            errorvalues(String.isNotBlank(responseWrapper.message)?responseWrapper.message:responseWrapper.error,integrationMessage.id,integrationMessage.Resp__c,integrationMessage.RefId__c);
                            APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Failure');
                        }
                        
                        else{
                            //brelatest(integrationMessage.RefId__c);
                            
                            if(integrationMessage.Trigger_Platform_Event__c){
                                publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                                platformWra.intId = integrationMessage.Id; 
                                platformWra.recId = integrationMessage.ParentRefId__c;
                                platformWra.ServiceName = integrationMessage.Svc__c ;
                                platformWra.Status = integrationMessage.Status__c ;
                                platformWra.errorMessage = String.isNotBlank(integrationMessage.Resp__c)?integrationMessage.Resp__c:'';
                                publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
                            }
                            errorvalues('Time Out',integrationMessage.id,integrationMessage.Resp__c,integrationMessage.RefId__c);
                            APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Failure');
                        }
                    }
                    
                }
                catch(Exception ex){
                    GlobalUtility.logMessage('Error', 'CrifAuthLoginResponseProcessor class', 
                                             'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
                    String errorMessage ='';
                    String error = ex.getMessage().substringBefore(':');
                    if(error!=null && String.isNotBlank(error)){
                        if(error.containsIgnoreCase('Unexpected character')){
                            errorMessage = 'API Internal Server Error';
                        } 
                        else if(error.containsIgnoreCase('Illegal unquoted character')){
                            errorMessage = 'An error occurred due to a special character in the response';
                        }
                        else {
                            errorMessage = 'An unexpected error has occurred';
                        }
                    }
                    else{
                        errorMessage = 'An unexpected error has occurred';
                    }
                    errorvalues(errorMessage,integrationMessage.id,integrationMessage.Resp__c,integrationMessage.RefId__c);
                    APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Failure');
                }
            }
            
            if(!createRequestList.isEmpty()){
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> { IntgMsg__c.SObjectType});
                List<string> fieldNamesList = New List<string>{'Name','BU__c','RefId__c','Status__c','MStatus__c','RefObj__c','Svc__c','ApiVendor__c',
                    'IsActive__c','ParentRefId__c','ParentRefObj__c'};
                        String sObjectName = 'IntgMsg__c';
                Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkInsert(objType,fieldNamesList); 
                uow.registerNew(createRequestList);
                uow.commitWork();
            }
            
        }
        //Exception Handling
        catch(Exception ex){
            GlobalUtility.logMessage('Error', 'CrifAuthLoginResponseProcessor class', 
                                     'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        } 
        
    }
    //**************************************************************************************************************************
     public static void errorvalues(String errorMessage,Id ids,string priorvalue,Id loanids){
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> {IntgMsg__c.SObjectType,LoanAppl__c.SObjectType});
        
        if(errorMessage!=null && ids !=null){
            
            try {
                List<IntgMsg__c> updateintmsg=new List<IntgMsg__c>();
                List<LoanAppl__c> loanlist =new List<LoanAppl__c>();
                
               	if(!string.isBlank(errorMessage)){
                    IntgMsg__c intmsg =new IntgMsg__c();
                    intmsg.id=ids;
                    intmsg.Resp__c=priorvalue +'\n'+errorMessage;
                    updateintmsg.add(intmsg);
                }
                
                //Updating loan Application
                if(loanids!=null){
                    LoanAppl__c la =new LoanAppl__c();
                    la.id=loanids;
                    la.MaxBreLnEliWIns__c=0;
                    la.MaxBreLnEliWoIns__c=0;
                    la.EMIIcludingInsurance__c=0;
                    //la.EffectiveROI__c=0;
                    la.FinalCustProfile__c='';
                    loanlist.add(la);
                }
                //Checking Bre record 
                 List<BRE__c> oldbre =[Select id,LoanAppl__c,IsLatest__c from BRE__c where IsLatest__c=true AND LoanAppl__c=:loanids];
                   if(!oldbre.isempty()){
                      IsLatestFalse(oldbre,'IsLatest__c');
                  }
                
                if(updateintmsg!=null){
                    List<string> fieldNamesList = New List<string>{'id','Resp__c'};
                            String sObjectName = 'IntgMsg__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList); 
                    uow.registerDirty(updateintmsg);
                }
                
                if(loanlist!=null){
                    List<string> fieldNamesList = New List<string>{'MaxBreLnEliWIns__c','MaxBreLnEliWoIns__c','FinalCustProfile__c'};
                            String sObjectName = 'LoanAppl__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkupdate(objType,fieldNamesList); 
                    uow.registerDirty(loanlist);
                }
                
                uow.commitWork();
                
                
            } catch (Exception ex) {
                GlobalUtility.logMessage('Error', 'CrifExecuteAPIResponseProcessor class', 
                                     'errorvalues', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
        }
        
    }
   
   
    //*********************************************************************************************************************************
    public Static void IsLatestFalse(List<SObject> recordList, String fieldName){
        
        if(!recordList.isempty()){
            // SObjectType sObjectType = recordList.getSObjectType();
            
            List<SObject> recordsToUpdate = new List<SObject>();
            
            for (SObject record : recordList) {
                if (record.get(fieldName) != null) {
                    record.put(fieldName, false);
                    recordsToUpdate.add(record);
                }
            }
            
            if (!recordsToUpdate.isEmpty()) {
                update recordsToUpdate;
            }
        }
        
        
        
    }
    
}