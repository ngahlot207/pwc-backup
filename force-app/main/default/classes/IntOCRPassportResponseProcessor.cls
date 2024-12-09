public class IntOCRPassportResponseProcessor implements IintMsgCalloutResponseProcessor{
    
    //Implementing the process method
    public static void process(List<IntgMsg__c> responses){ 
        
        //Processing all responses
        for(IntgMsg__c integrationMessage : responses){
            if(integrationMessage.Svc__c != GlobalConstants.INT_CONFIG_SERVICE_KYC_OCR 
               && integrationMessage.BU__c != GlobalConstants.INT_MSG_BU_TYPE){
                   throw new processException('Error! This is not the correct service'); 
               }
            try{
                //parse response
                IntOCRPassportResponseWrapper responseWrapper = (IntOCRPassportResponseWrapper) JSON.deserialize(integrationMessage.Resp__c, IntOCRPassportResponseWrapper.class); 
                
                
                
                //check if responseWrapper is empty or not
                if(responseWrapper != null){
                    
                    //createApplicantKYCRecord(responseWrapper,integrationMessage.RefId__c);
                    
                    if(responseWrapper.statusCode!=null){
                        if(responseWrapper.statusCode==GlobalConstants.karza_Status_101){//
                            if(responseWrapper.result[0].type.contains('Passport')){
                                updateApplicantKYCRecord(responseWrapper,integrationMessage.ParentRefId__c,integrationMessage);
                            } else {
                                updateApplicantKYCRecorderror(responseWrapper,integrationMessage.ParentRefId__c,GlobalConstants.General_Message_KYCOCR,integrationMessage);
                            }
                        }
                        if(responseWrapper.statusCode!=GlobalConstants.karza_Status_101){
                            String errorMessage=GlobalConstants.karza_Status_Code_OCR_Description.containsKey(responseWrapper.statusCode)?GlobalConstants.karza_Status_Code_OCR_Description.get(responseWrapper.statusCode):'';
                            updateApplicantKYCRecordError(responseWrapper,integrationMessage.ParentRefId__c,errorMessage,integrationMessage);
                        }
                    }
                    else {
                        String errorMessage = KarzaErrorResponseController.getErrorMessage(integrationMessage);
                        updateApplicantKYCRecordError(responseWrapper,integrationMessage.ParentRefId__c,errorMessage,integrationMessage);
                    }
                    
                    if(integrationMessage.Trigger_Platform_Event__c){
                        publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                        platformWra.intId = integrationMessage.Id; 
                        platformWra.recId = integrationMessage.ParentRefId__c;
                        platformWra.ServiceName = integrationMessage.Svc__c ;
                        platformWra.Status = integrationMessage.Status__c ;
                        
                        if(responseWrapper.statusCode!=null){
                            if(responseWrapper.statusCode==GlobalConstants.karza_Status_101){
                                if(responseWrapper.result[0].type.contains('Passport')){
                                    platformWra.success=true;
                                }
                                else{
                                    platformWra.errorMessage=GlobalConstants.General_Message_KYCOCR;
                                }
                            }
                            if(responseWrapper.statusCode!=GlobalConstants.karza_Status_101){
                                platformWra.errorMessage=GlobalConstants.karza_Status_Code_OCR_Description.containsKey(responseWrapper.statusCode)?GlobalConstants.karza_Status_Code_OCR_Description.get(responseWrapper.statusCode):'';
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
                GlobalUtility.logMessage('Error', 'IntOCRPassportResponseProcessor class', 
                                         'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }  
            
        }  
        
    }
    
    public static void createApplicantKYCRecord(IntOCRPassportResponseWrapper responseWrapper,Id referenceId){
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( 
            new List<SObjectType> { ApplKyc__c.SObjectType }
        );
        List<string> fieldNamesList = New List<string>{'Applicant__c','kycDoc__c'};
            
            String sObjectName = 'ApplKyc__c';
        Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
        fflib_SecurityUtils.checkInsert(objType,fieldNamesList);
        
        if(responseWrapper != null){
            ApplKyc__c AppKyc=New ApplKyc__c();
            if(responseWrapper.result[0].type == 'Passport Front' || responseWrapper.result[0].type == 'Passport Back' ){
                
            }
            
            AppKyc.Applicant__c = referenceId;
            AppKyc.kycDoc__c = 'Passport'; 
            AppKyc.PassNo__c =responseWrapper.result[0].details.passportNum.value;
            system.debug('responseWrapper.result creation'+responseWrapper.result[0].details.passportNum.value);
            
            AppKyc.Name__c =responseWrapper.result[0].details.surname.value;
            //system.debug('date>>'+ Date.valueOf(responseWrapper.result[0].details.dob.value));
            if(!String.isBlank(responseWrapper.result[0].details.dob.value)){
                List<String> doi = responseWrapper.result[0].details.dob.value.split('/');
                if(doi != null && doi.size()>=2){
                    AppKyc.DtOfBirth__c = Date.newInstance(Integer.valueof(doi[2]),Integer.valueof(doi[1]),Integer.valueof(doi[0]));
                } 
                // AppKyc.DtOfBirth__c = Date.valueOf(responseWrapper.result[0].details.dob.value);   
            }
            
            if(!String.isBlank(responseWrapper.result[0].details.doi.value)){
                //AppKyc.DtOfIssue__c =Date.valueOf(responseWrapper.result[0].details.doi.value);
                List<String> doi = responseWrapper.result[0].details.doi.value.split('/');
                if(doi != null && doi.size()>=2){
                    AppKyc.DtOfIssue__c = Date.newInstance(Integer.valueof(doi[2]),Integer.valueof(doi[1]),Integer.valueof(doi[0]));
                } 
                system.debug(' responseWrapper.result[0].details.doi.value'+ responseWrapper.result[0].details.doi.value);
            }
            if(!String.isBlank(responseWrapper.result[0].details.doe.value)){
                
                List<String> doi = responseWrapper.result[0].details.doe.value.split('/');
                if(doi != null && doi.size()>=2){
                    AppKyc.DtOfExp__c = Date.newInstance(Integer.valueof(doi[2]),Integer.valueof(doi[1]),Integer.valueof(doi[0]));
                } 
                // AppKyc.DtOfExp__c =Date.valueOf(responseWrapper.result[0].details.doe.value) ; 
            }
            
            if(AppKyc != null){
                uow.registerNew(AppKyc);
                //insert AppKyc;
                system.debug(' applicant kyc record creation successfull');
            }
        }
        uow.commitWork();
    }
    
    public static void updateApplicantKYCRecord(IntOCRPassportResponseWrapper responseWrapper,Id referenceId,IntgMsg__c integrationMessage){
        
        system.debug('responseWrapper'+responseWrapper);
        system.debug('responseWrapper');
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { ApplKyc__c.SObjectType });
        
        try{
            if(responseWrapper != null){
                ApplKyc__c appKyc=New ApplKyc__c();
                appKyc.Id = referenceId;
                appKyc.OCRStatus__c=GlobalConstants.MSG_SUCCESS;
                
                system.debug(responseWrapper.result.size());
                for(IntOCRPassportResponseWrapper.Result res: responseWrapper.result)
                {
                    if(res.type=='Passport Front')
                    {
                        if(!String.isBlank(res.details.dob.value)){
                            List<String> dob = res.details.dob.value.split('/');
                            if(dob != null && dob.size()>=2){
                                AppKyc.DtOfBirth__c = Date.newInstance(Integer.valueof(dob[2]),Integer.valueof(dob[1]),Integer.valueof(dob[0]));
                            } 
                        }
                        if(!String.isBlank(res.details.doi.value)){
                            List<String> doi =res.details.doi.value.split('/');
                            if(doi != null && doi.size()>=2){
                                AppKyc.PassIssueDt__c = Date.newInstance(Integer.valueof(doi[2]),Integer.valueof(doi[1]),Integer.valueof(doi[0]));
                            } 
                        }
                        if(!String.isBlank(res.details.doe.value)){
                            List<String> doe =res.details.doe.value.split('/');
                            if(doe != null && doe.size()>=2){
                                AppKyc.PassExpDt__c = Date.newInstance(Integer.valueof(doe[2]),Integer.valueof(doe[1]),Integer.valueof(doe[0]));
                            }
                        }
                        system.debug('res--->'+res);
                        if(!String.isBlank(res.details.givenName.value)){
                            appKyc.Name__c = String.isNotBlank(res.details.surname.value)?res.details.givenName.value +' '+ res.details.surname.value :res.details.givenName.value; 
                        }
                        if(!String.isBlank(res.details.surname.value)){
                            appKyc.LName__c =res.details.surname.value; 
                        }
                        if(!String.isBlank(res.details.passportNum.value)){
                            appKyc.PassNo__c =res.details.passportNum.value; 
                        }
                        if(!String.isBlank(res.details.gender.value)){
                            appKyc.Gender__c =res.details.gender.value.toLowerCase()=='male'?'M':res.details.gender.value.toLowerCase()=='female'?'F':''; 
                        }
                    }
                    
                    if(!String.isBlank(res.type) && res.type=='Passport Back'){
                        if(!String.isBlank(res.details.father.value)){
                            appKyc.FatherName__c =res.details.father.value; 
                        }
                        if(!String.isBlank(res.details.fileNum.value)){
                            appKyc.FileNo__c = res.details.fileNum.value; 
                        }
                        if(!String.isBlank(res.details.addressSplit.city)){
                            appKyc.City__c = res.details.addressSplit.city;
                        }
                        if(!String.isBlank(res.details.addressSplit.line1)){
                            appKyc.AddrLine1__c = res.details.addressSplit.line1;
                        }
                        if(!String.isBlank(res.details.addressSplit.line2)){
                            appKyc.AddrLine2__c = res.details.addressSplit.line2;
                        }
                        if(!String.isBlank(res.details.addressSplit.state)){
                            appKyc.State__c = res.details.addressSplit.state;
                        }
                        if(!String.isBlank(res.details.addressSplit.landmark)){
                            appKyc.Landmark__c = res.details.addressSplit.landmark;
                        }
                        if(!String.isBlank(res.details.addressSplit.locality)){
                            appKyc.Locality__c = res.details.addressSplit.locality;
                        }
                        if(!String.isBlank(res.details.addressSplit.houseNumber)){
                            appKyc.HouseNo__c = res.details.addressSplit.houseNumber;
                        }
                        if(!String.isBlank(res.details.addressSplit.pin)){
                            appKyc.Pincode__c = res.details.addressSplit.pin;
                        }
                        if(!String.isBlank(res.details.addressSplit.district)){
                            appKyc.District__c = res.details.addressSplit.district;
                        }
                        if(!String.isBlank(res.details.addressSplit.street)){
                            appKyc.Street__c = res.details.addressSplit.street;
                        }
                        if(!String.isBlank(res.details.spouse.value)){
                            appKyc.HusbandName__c =res.details.spouse.value; 
                        }
                        if(!String.isBlank(res.details.address.value)){
                            appKyc.Address__c =res.details.address.value; 
                        }
                    }    
                    
                    
                }
                
                if(AppKyc != null){
                    List<string> fieldNamesList = New List<string>{'OCRStatus__c','DtOfBirth__c','PassIssueDt__c','PassExpDt__c','Name__c','FatherName__c','PassNo__c','FileNo__c','City__c','AddrLine1__c','AddrLine2__c','State__c','Landmark__c','Locality__c','HouseNo__c','Pincode__c','District__c','Street__c','HusbandName__c','Gender__c','LName__c','Address__c'};
                        String sObjectName = 'ApplKyc__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                    uow.registerDirty(appKyc);
                }
                
                
            }
        }
        catch(exception ex){
            system.debug('error message and line number '+ ex.getMessage() + 'line' + ex.getLineNumber());
        }       
        uow.commitWork();
        APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Success');
        
        //Create Integration Message for Verification
                if(integrationMessage!=null && string.isNotblank(integrationMessage.RefId__c)){
                    
                    List<DocDtl__c> dtl=[Select id,Is_Generated_from_Lead_Flow__c,Is_Ready_for_KYC_Validations__c from DocDtl__c Where Id =:integrationMessage.RefId__c];
                    
                    if(dtl!=null && dtl[0].Is_Generated_from_Lead_Flow__c && dtl[0].Is_Ready_for_KYC_Validations__c){
                        
                        Map<String,Object> jsonDataMap = new Map<String, Object>();
                        
                        jsonDataMap.put('Name','Passport Verification');
                        jsonDataMap.put('Status','New');
                        jsonDataMap.put('MStatus','Blank');
                        jsonDataMap.put('BU',integrationMessage.BU__c);
                        jsonDataMap.put('RefId',integrationMessage.RefId__c);
                        jsonDataMap.put('RefObj',integrationMessage.RefObj__c);
                        jsonDataMap.put('ParentRefId',integrationMessage.ParentRefId__c);
                        jsonDataMap.put('ParentObject',integrationMessage.ParentRefObj__c);
                        jsonDataMap.put('Svc','Passport Verification');
                        jsonDataMap.put('IsActive',true);
                        
                        IntegrationUtility.createIntegrationMessage(JSON.serialize(jsonDataMap));
                    }
                }
    }
    
    public static void updateApplicantKYCRecordError(IntOCRPassportResponseWrapper responseWrapper,Id referenceId,String errorMessage,IntgMsg__c integrationMessage){
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { ApplKyc__c.SObjectType });
        try{
            if(responseWrapper != null){
                ApplKyc__c AppKyc=New ApplKyc__c();
                AppKyc.Id = referenceId;
                AppKyc.OCRStatus__c=GlobalConstants.MSG_FAILURE;
                Appkyc.OCR_Error_Message__c=errorMessage;
                
                if(AppKyc != null){
                    List<string> fieldNamesList = New List<string>{'OCRStatus__c','OCR_Error_Message__c'};
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