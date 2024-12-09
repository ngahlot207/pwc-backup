public class PanProfDetResponseProcessor implements IintMsgCalloutResponseProcessor{
    
    //Implementing the process method
    public static void process(List<IntgMsg__c> responses){ 
        
        //Processing all responses
        for(IntgMsg__c integrationMessage : responses){
            if(integrationMessage.Svc__c != GlobalConstants.INT_CONFIG_SERVICE_PAN_PROFILE_DETAILED
               && integrationMessage.BU__c != GlobalConstants.INT_MSG_BU_TYPE){
                   throw new processException('Error! This is not the correct service'); 
               }
            try{
                //parse response
                PanProfDetResponseWrapper responseWrapper = (PanProfDetResponseWrapper) JSON.deserialize(integrationMessage.Resp__c, PanProfDetResponseWrapper.class); 
                Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(integrationMessage.Resp__c);
                //check if responseWrapper is empty or not
                if(responseWrapper != null){
                    //Note : Waiting for fields Information which need to be updated 
                    system.debug('responseWrapper '+ responseWrapper);
                    system.debug('responseWrapper get Status code ' +  responseWrapper.statusCode);
                    //  system.debug('requestId '+ responseWrapper.requestId);
                    
                    if(Integer.valueOf(responseMap.get('status-code'))==GlobalConstants.karza_Status_101){
                        updateApplicantKYC(integrationMessage.ParentRefId__c,responseWrapper,integrationMessage);
                    }
                    if(Integer.valueOf(responseMap.get('status-code'))!=GlobalConstants.karza_Status_101){
                        updateApplicantKYCError(responseWrapper,integrationMessage);
                    }
                    system.debug('updateapplicant completed');
                    
                    if(integrationMessage.Trigger_Platform_Event__c){
                        publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                        platformWra.intId = integrationMessage.Id; 
                        platformWra.recId = integrationMessage.ParentRefId__c;
                        platformWra.ServiceName = integrationMessage.Svc__c ;
                        platformWra.Status = integrationMessage.Status__c ;
                        
                        if(Integer.valueOf(responseMap.get('status-code'))!=null){
                            if(Integer.valueOf(responseMap.get('status-code'))==GlobalConstants.karza_Status_101){
                                platformWra.success=true;
                            }
                            if(Integer.valueOf(responseMap.get('status-code'))!=GlobalConstants.karza_Status_101){
                                platformWra.errorMessage=GlobalConstants.karza_Status_Code_Authn_Description.containsKey(Integer.valueOf(responseMap.get('status-code'))) ? GlobalConstants.karza_Status_Code_Authn_Description.get(Integer.valueOf(responseMap.get('status-code'))):'';
                            }
                        }
                        else {
                            platformWra.errorMessage = KarzaErrorResponseController.getErrorMessage(integrationMessage);
                        }
                        
                        publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
                    } 
                    
                } 
            }
            //Exception Handling
            catch(Exception ex){
                GlobalUtility.logMessage('Error', 'PanProfDetResponseProcessor', 
                                         'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }  
            
        }       
    }
    
    
    public static void updateApplicantKYC(id referenceid,PanProfDetResponseWrapper responseWrapper,IntgMsg__c integrationMessage){
        List<ApplKyc__c>appKyc =[SELECT Id,Applicant__c,Applicant__r.LoanAppln__c,Applicant__r.Constitution__c,kycDoc__c,DtOfBirth__c,NameInPan__c,FatherName__c,DtOfIssue__c FROM ApplKyc__c WHERE Id=:referenceid and kycDoc__c='Pan'];
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> {Applicant__c.SObjectType, ApplKyc__c.SObjectType,IntgMsg__c.SObjectType });
        List<string> fieldNamesList = New List<string>{'NameInPan__c','ValidationStatus__c','Name__c'};
        List<IntgMsg__c> createRequestList = new List<IntgMsg__c>();    
        String sObjectName = 'ApplKyc__c';
        Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
        fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
        
        ApplKyc__c updateRec=New ApplKyc__c();
        updateRec.id=referenceid;
        updateRec.NameInPan__c = responseWrapper.result.name != null ? responseWrapper.result.name : null;
        updateRec.Name__c = responseWrapper.result.name != null ? responseWrapper.result.name : null;
        updateRec.ValidationStatus__c=Globalconstants.MSG_SUCCESS;
        updateRec.DOBValidationStatus__c = (!appKyc.isEmpty() && appKyc[0].DtOfBirth__c!=null) ? Globalconstants.MSG_SUCCESS : GlobalConstants.MSG_FAILURE;
        uow.registerDirty(updateRec);
        
        if(appKyc[0].Applicant__c!=null){
            if(appKyc[0].Applicant__r.Constitution__c == 'PRIVATE LIMITED COMPANY' || appKyc[0].Applicant__r.Constitution__c =='PUBLIC LIMITED COMPANY' || appKyc[0].Applicant__r.Constitution__c == 'LIMITED LIABILITY PARTNERSHIP' || appKyc[0].Applicant__r.Constitution__c =='PROPERITORSHIP'){
                IntgMsg__c intmsg = new IntgMsg__c();
                intmsg.BU__c='HL / STL';
                intmsg.Status__c='New';
                intmsg.MStatus__c='Blank';
                intmsg.RefObj__c='Applicant__c';
                intmsg.ParentRefId__c= appKyc[0].Applicant__r.LoanAppln__c;
                intmsg.ParentRefObj__c='LoanAppl__c';
                intmsg.RefId__c = appKyc[0].Applicant__c;
                intmsg.IsActive__c = true;
                
                if((appKyc[0].Applicant__r.Constitution__c == 'PRIVATE LIMITED COMPANY' || appKyc[0].Applicant__r.Constitution__c =='PUBLIC LIMITED COMPANY')){
                    //Calling Company Base Details API
                    intmsg.Name='Company Base Details';
                    intmsg.Svc__c='Company Base Details';
                }
                else if((appKyc[0].Applicant__r.Constitution__c == 'LIMITED LIABILITY PARTNERSHIP' || appKyc[0].Applicant__r.Constitution__c =='PROPERITORSHIP')){
                    //Calling LLP Base Details API
                    intmsg.Name='LLP Base Details';
                    intmsg.Svc__c='LLP Base Details';
                }
                
                createRequestList.add(intmsg); 
                
                
            } 
        }
        
        uow.commitWork();

        APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Success');

        if(!createRequestList.isEmpty()){
                
            // List<string> fieldNamesList = New List<string>{'Name','BU__c','RefId__c','Status__c','MStatus__c','RefObj__c','Svc__c','ApiVendor__c',
            //     'IsActive__c','ParentRefId__c','ParentRefObj__c'};
            //         String sObjectName = 'IntgMsg__c';
            // Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
            // fflib_SecurityUtils.checkInsert(objType,fieldNamesList); 
            // uow.registerNew(createRequestList);

            INSERT createRequestList;
            
        }
        
        if(String.isNotblank(integrationMessage.RefId__c)){
            ApplicantUpdate.createIntgMsgForNameMatch(new Set<Id>{integrationMessage.RefId__c});
        }
    }
    
    /*  public static void createPermanentAddressMethod(PanProfDetResponseWrapper responseWrapper, Id referenceid){

fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( 
new List<SObjectType> { ApplAddr__c.SObjectType }
);

if(responseWrapper != null){
ApplAddr__c appladdres = new ApplAddr__c();
appladdres.AddrTyp__c = 'Permanent';
appladdres.Applicant__c = referenceid;
appladdres.AddrLine1__c = responseWrapper.result.address.buildingName != null ? responseWrapper.result.address.buildingName : null;
appladdres.AddrLine2__c = responseWrapper.result.address.streetName != null ? responseWrapper.result.address.streetName : null;
appladdres.City__c = responseWrapper.result.address.city != null ? responseWrapper.result.address.city : null;
appladdres.Country__c = responseWrapper.result.address.country != null ? responseWrapper.result.address.country : null;
appladdres.State__c = responseWrapper.result.address.state != null ? responseWrapper.result.address.state : null;
appladdres.Pincode__c = responseWrapper.result.address.pinCode != null ? responseWrapper.result.address.pinCode : null;

if(appladdres != null){
List<string> fieldNamesList = New List<string>{'AddrTyp__c','Applicant__c','AddrLine1__c','AddrLine2__c','City__c','Country__c','State__c','Pincode__c'};
String sObjectName = 'ApplAddr__c';
Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
fflib_SecurityUtils.checkInsert(objType,fieldNamesList);

uow.registerNew(appladdres);
}
uow.commitWork();
}
}*/
    
    public static void updateApplicantKYCError(PanProfDetResponseWrapper responseWrapper,IntgMsg__c integrationMessage){
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(integrationMessage.Resp__c);
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { ApplKyc__c.SObjectType ,IntgMsg__c.SObjectType });
        try{
            if(responseWrapper != null){
                ApplKyc__c AppKyc=New ApplKyc__c();
                AppKyc.Id = integrationMessage.ParentRefId__c;
                AppKyc.ValidationStatus__c=GlobalConstants.MSG_FAILURE;
                if(Integer.valueOf(responseMap.get('status-code'))!=null){
                    AppKyc.Validation_Error_Message__c=GlobalConstants.karza_Status_Code_Authn_Description.containsKey(Integer.valueOf(responseMap.get('status-code')))?GlobalConstants.karza_Status_Code_Authn_Description.get(Integer.valueOf(responseMap.get('status-code'))):'';
                }
                else {
                    AppKyc.Validation_Error_Message__c=KarzaErrorResponseController.getErrorMessage(integrationMessage);
                }
                if(AppKyc != null){
                    List<string> fieldNamesList = New List<string>{'ValidationStatus__c','Validation_Error_Message__c'};
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
        APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Failure');
    }
}