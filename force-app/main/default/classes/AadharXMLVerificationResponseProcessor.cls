public class AadharXMLVerificationResponseProcessor  implements IintMsgCalloutResponseProcessor{
    
    //Implementing the process method
    public static void process(List<IntgMsg__c> responses){ 
        for(IntgMsg__c integrationMessage : responses){
            if(integrationMessage.Svc__c != 'SFDC Aadhar XML Verification API'
               && integrationMessage.BU__c != GlobalConstants.INT_MSG_BU_TYPE){
                   //throw new processException('Error! This is not the correct service'); 
               }
            
            try{
                SigndeskAPIController.EncryptedResponse encryptedresponse = (SigndeskAPIController.EncryptedResponse) JSON.deserialize(integrationMessage.Resp__c, SigndeskAPIController.EncryptedResponse.class); 
                if(encryptedresponse.status.tolowerCase()=='success'){
                    String decryptedResponse = SigndeskAPIController.getDecryptedResponse(encryptedResponse.encrypted_response);
                    if(String.isNotBlank(decryptedResponse)){
                        AadharXMLVerificationResponseWrapper responseWrapper = (AadharXMLVerificationResponseWrapper) JSON.deserialize(decryptedResponse, AadharXMLVerificationResponseWrapper.class); 
                        //check if responseWrapper is empty or not                
                        if(responseWrapper != null){
                            if(responseWrapper.status.tolowerCase()=='success'){
                                updateApplicantKyc(responseWrapper,integrationMessage);
                            }
                            else{
                                Map<String, Object> jsonResponseMap = (Map<String, Object>) JSON.deserializeUntyped(decryptedResponse);
                                String errorMessage;// = String.isNotBlank(responseWrapper.error) ? responseWrapper.error : '';
                                if(jsonResponseMap.containskey('message')){
                                    errorMessage =((Map<String, Object>)jsonResponseMap.get('message')).containsKey('message')? (String)((Map<String, Object>)jsonResponseMap.get('message')).get('message') : '';
                                }
                                
                                updateApplicantKYCError(integrationMessage,errorMessage);
                            }
                        }
                    }
                }
                else{
                    updateApplicantKYCError(integrationMessage,encryptedresponse.ErrorMsg);
                }
            }
            //Exception Handling
            catch(Exception ex){
                GlobalUtility.logMessage('Error', 'AadharXMLVerificationResponseProcessor class', 
                                         'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            } 
        }
    }
    
    
    public Static Void updateApplicantKyc(AadharXMLVerificationResponseWrapper responseWrapper, IntgMsg__c integrationMessage){
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { ApplKyc__c.SObjectType});
        List<ApplKyc__c> appKycList = new List<ApplKyc__c>();
        Map<Id,ApplKyc__c> appKycMap = new Map<Id,ApplKyc__c>([SELECT Id,Applicant__c,kycDoc__c,AadharEncripted__c FROM ApplKyc__c  WHERE Id=:integrationMessage.ParentRefId__c and kycDoc__c='Aadhaar']);
        if(responseWrapper != null){
            if(integrationMessage.ParentRefId__c!=null){
                ApplKyc__c updateAppKyc = new ApplKyc__c();
                updateAppKyc.id = integrationMessage.ParentRefId__c;
                updateAppKyc.TransactionId__c = responseWrapper.transaction_id;
                updateAppkyc.ReferenceId__c = responseWrapper.reference_id;
                if(appKycMap.containsKey(integrationMessage.ParentRefId__c) && appKycMap.get(integrationMessage.ParentRefId__c).AadharEncripted__c!=null  && appKycMap.get(integrationMessage.ParentRefId__c).AadharEncripted__c.length() == 12 ){
                    updateAppKyc.AadharNo__c = 'X'.repeat(8) + appKycMap.get(integrationMessage.ParentRefId__c).AadharEncripted__c.substring(8);
                }
                
                appKycList.add(updateAppKyc);
                
            }
            
            
        }
        
        if(!appKycList.isEmpty()){
            
            List<string> fieldNamesList = New List<string>{'TransactionId__c','AadharNo__c'};
                String sObjectName = 'ApplKyc__c';
            Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
            fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
            uow.registerDirty(appKycList);
            
        }
        
        uow.commitWork();
       
        if(integrationMessage.Trigger_Platform_Event__c){
            publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
            platformWra.intId = integrationMessage.Id; 
            platformWra.recId = integrationMessage.ParentRefId__c;
            platformWra.ServiceName = integrationMessage.Svc__c ;
            platformWra.Status = integrationMessage.Status__c ;
            platformWra.success=true;
            publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
        }
        APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Success');
    }
    
    public static void updateApplicantKYCError(IntgMsg__c integrationMessage,string errorMessage){
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { ApplKyc__c.SObjectType });
        try{
            if(integrationMessage != null){
                Map<Id,ApplKyc__c> appKycMap = new Map<Id,ApplKyc__c>([SELECT Id,Applicant__c,kycDoc__c,AadharEncripted__c FROM ApplKyc__c  WHERE Id=:integrationMessage.ParentRefId__c and kycDoc__c='Aadhaar']);
                ApplKyc__c AppKyc=New ApplKyc__c();
                AppKyc.Id = integrationMessage.ParentRefId__c;
                AppKyc.ValidationStatus__c=GlobalConstants.MSG_FAILURE;
                AppKyc.Validation_Error_Message__c=errorMessage;
                if(appKycMap.containsKey(integrationMessage.ParentRefId__c) && appKycMap.get(integrationMessage.ParentRefId__c).AadharEncripted__c!=null  && appKycMap.get(integrationMessage.ParentRefId__c).AadharEncripted__c.length() == 12 ){
                    AppKyc.AadharNo__c = 'X'.repeat(8) + appKycMap.get(integrationMessage.ParentRefId__c).AadharEncripted__c.substring(8);
                }
                if(AppKyc != null){
                    List<string> fieldNamesList = New List<string>{'ValidationStatus__c','Validation_Error_Message__c','AadharNo__c'};
                        String sObjectName = 'ApplKyc__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                    uow.registerDirty(AppKyc);
                }
            }
        }
        catch(exception ex){
            system.debug('error message and line number '+ ex.getMessage() + 'line' + ex.getLineNumber());
        }	     
        uow.commitWork();
        if(integrationMessage.Trigger_Platform_Event__c){
            publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
            platformWra.intId = integrationMessage.Id; 
            platformWra.recId = integrationMessage.ParentRefId__c;
            platformWra.ServiceName = integrationMessage.Svc__c ;
            platformWra.Status = integrationMessage.Status__c ;
            platformWra.errorMessage= errorMessage;
            publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
        }
        APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Failure');
    }
}