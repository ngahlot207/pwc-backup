public class UcidResponseProcessor implements IintMsgCalloutResponseProcessor{

      
    //Implementing the process method
    public static void process(List<IntgMsg__c> responses){ 
        for(IntgMsg__c integrationMessage : responses){
            try{
                UcidResponseWrapper responseWrapper = (UcidResponseWrapper) JSON.deserialize(integrationMessage.Resp__c, UcidResponseWrapper.class);
                if((responseWrapper.success !=null) && boolean.valueOf(responseWrapper.success)){
                    createUcidSuccess(responseWrapper,integrationMessage.RefId__c);
                    APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Success');
                }
                else {
                    createUcidError(responseWrapper,integrationMessage.RefId__c); 
                    APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Failure');
                }
                
                if(integrationMessage.Trigger_Platform_Event__c){
                    publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                    platformWra.intId = integrationMessage.Id; 
                    platformWra.recId = integrationMessage.ParentRefId__c;
                    platformWra.ServiceName = integrationMessage.Svc__c ;
                    platformWra.Status = integrationMessage.Status__c ;
                    platformWra.success = boolean.valueOf(responseWrapper.success);
                    platformWra.errorMessage = responseWrapper.message;
                    /*if(boolean.valueOf(responseWrapper.success)){
                    platformWra.success=true;
                    }
                    else{
                    platformWra.errorMessage=responseWrapper.message;
                    }*/
                    publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
                }
            }
            catch(Exception ex){
                GlobalUtility.logMessage('Error', 'UcidResponseProcessor class', 
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
                
                if(integrationMessage.Trigger_Platform_Event__c){
                    publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                    platformWra.intId = integrationMessage.Id; 
                    platformWra.recId = integrationMessage.ParentRefId__c;
                    platformWra.ServiceName = integrationMessage.Svc__c ;
                    platformWra.Status = integrationMessage.Status__c ;
                    // platformWra.success = boolean.valueOf(responseWrapper.success);
                    platformWra.errorMessage = string.isNotBlank(errorMessage)?errorMessage:'';
                    publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
                }
                APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Failure');
                
            } 
        }
    }
    
    public static void createUcidSuccess(UcidResponseWrapper responseWrapper, Id referenceId){
        try{
            Map<Id,Applicant__c> applMap = new Map<Id,Applicant__c>([Select Id,LoanAppln__c,IntegrationStatus__c,IntegrationErrorMessage__c from Applicant__c where Id=:referenceId]);
            List<Applicant__c> updateApplList = new List<Applicant__c>();            
            if(applMap.containsKey(referenceId)){
                if(responseWrapper!=null){
                    List<IntgMsg__c> createRequestList = new List<IntgMsg__c>();
                    
                    Applicant__c appl= new Applicant__c();
                    appl.Id=referenceId;
                    appl.UCID__c = String.isNotBlank(responseWrapper.ucid)? responseWrapper.ucid : '';
                    appl.IntegrationStatus__c= replaceAndUpdateString('UCID API', 'UCID API: Success', applMap.get(referenceId).IntegrationStatus__c,';');
                    appl.IntegrationErrorMessage__c=replaceAndUpdateString('UCID API', '', applMap.get(referenceId).IntegrationErrorMessage__c,';');
                    updateApplList.add(appl);
                    
                    /*
                    if(String.isNotBlank(responseWrapper.ucid)){
                    	IntgMsg__c intmsg =new IntgMsg__c();
                        intmsg.Name='ENPA';
                        intmsg.BU__c='HL / STL';
                        intmsg.RefId__c=referenceId;
                        intmsg.Status__c='New';
                        intmsg.MStatus__c='Blank';
                        intmsg.RefObj__c='Applicant__c';
                        intmsg.Svc__c='ENPADeatils';
                        intmsg.IsActive__c=true;
                        createRequestList.add(intmsg);
                	}*/
					
                    
                    
                    if(!updateApplList.isEmpty()){
                        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { Applicant__c.SObjectType });
                        List<string> fieldNamesList = New List<string>{'UCID__c','IntegrationStatus__c','IntegrationErrorMessage__c'};
                            String sObjectName = 'Applicant__c';
                        Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                        fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                        uow.registerDirty(updateApplList);
                        uow.commitWork();
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
            } 
        }
        catch(exception ex){
            system.debug('error message and line number '+ ex.getMessage() + 'line' + ex.getLineNumber());
        }  
        
    }
    
    public static void createUcidError(UcidResponseWrapper responseWrapper, Id referenceId){
        Map<Id,Applicant__c> applMap = new Map<Id,Applicant__c>([Select Id,LoanAppln__c,IntegrationStatus__c,IntegrationErrorMessage__c from Applicant__c where Id=:referenceId]);
        List<Applicant__c> updateApplList = new List<Applicant__c>();
        
        if(applMap.containsKey(referenceId)){
            if(responseWrapper!=null){
                String errorMessage = String.isNotBlank(responseWrapper.message) ? responseWrapper.message:String.isNotBlank(responseWrapper.msg) ? responseWrapper.msg:'';
                Applicant__c appl= new Applicant__c();
                appl.Id=referenceId;
                appl.IntegrationStatus__c= replaceAndUpdateString('UCID API', 'UCID API: Failure', applMap.get(referenceId).IntegrationStatus__c,';');
              	appl.IntegrationErrorMessage__c=replaceAndUpdateString('UCID API', 'UCID API: '+ errorMessage, applMap.get(referenceId).IntegrationErrorMessage__c,';');
                updateApplList.add(appl);
            }
            
            if(!updateApplList.isEmpty()){
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { Applicant__c.SObjectType });
                List<string> fieldNamesList = New List<string>{'IntegrationStatus__c','IntegrationErrorMessage__c'};
                    String sObjectName = 'Applicant__c';
                Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                uow.registerDirty(updateApplList);
                uow.commitWork();
            }
           
        }        
    }
    

 
    
    public static string replaceAndUpdateString(String toRemove, String toAdd,String actualString,String splitIdentifier){
        String updatedString;
        List<String> updatedStringList = new List<String>();
        if(String.isNotBlank(actualString)){
            List<String> existingStringList = actualString.split(splitIdentifier);
            system.debug(existingStringList);
            if(!existingStringList.isEmpty()){
                for(string value : existingStringList){
                    if(!value.contains(toRemove)){
                        updatedStringList.add(value);
                    }
                }
            }
        }	
        if(String.isNotBlank(toAdd)){
            updatedStringList.add(toAdd);
        }
        
        updatedString= String.join(updatedStringList,splitIdentifier).removeStart(splitIdentifier).removeEnd(splitIdentifier);
        
        return updatedString; 
    }
}