public without sharing class passportResponseProcessor implements IintMsgCalloutResponseProcessor{
    
    //Implementing the process method
    public static void process(List<IntgMsg__c> responses){ 
        
        try{ 
            //Processing all responses
            set<Id> ids = new set<Id>();
            for(IntgMsg__c integrationMessage : responses){
                ids.add(integrationMessage.ParentRefId__c);
            }
            Map<Id,ApplKyc__c> applKycMap = new Map<Id,ApplKyc__c>([SELECT Id,Applicant__c,kycDoc__c,PassExpDt__c FROM ApplKyc__c WHERE Id IN:ids and kycDoc__c='Passport']);
            
            for(IntgMsg__c integrationMessage : responses){
                if(integrationMessage.Svc__c != GlobalConstants.INT_CONFIG_SERVICE_PASSPORT_VERIFICATION){
                    throw new processException('Error! This is not the correct service'); 
                }
                
                //parse response
                passportResponseWrapper responseWrapper = (passportResponseWrapper) JSON.deserialize(integrationMessage.Resp__c, passportResponseWrapper.class); 
                
                //check if responseWrapper is empty or not
                if(responseWrapper != null){
                    //Note : Waiting for fields Information which need to be updated 
                    system.debug('responseWrapper '+ responseWrapper);
                    system.debug('responseWrapper get Status code ' +  responseWrapper.statusCode);
                    system.debug('requestId '+ responseWrapper.requestId);
                    system.debug('RESPONSE RESULT '+ responseWrapper);
                    
                    if(responseWrapper.statusCode==GlobalConstants.karza_Status_101){
                        updateApplicantDetials(responseWrapper,integrationMessage.RefId__c,integrationMessage.ParentRefId__c,integrationMessage);
                    }
                    if(responseWrapper.statusCode!=GlobalConstants.karza_Status_101){
                        updateApplicantKYCError(responseWrapper,integrationMessage);
                    }
                    
                    if(integrationMessage.Trigger_Platform_Event__c){
                        publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                        platformWra.intId = integrationMessage.Id; 
                        platformWra.recId = integrationMessage.ParentRefId__c;
                        platformWra.ServiceName = integrationMessage.Svc__c ;
                        platformWra.Status = integrationMessage.Status__c ;
                        
                        if(responseWrapper.statusCode!=null){
                            if(responseWrapper.statusCode==GlobalConstants.karza_Status_101){
                                
                                if(applKycMap.containsKey(integrationMessage.ParentRefId__c) && applKycMap.get(integrationMessage.ParentRefId__c).PassExpDt__c!=null && applKycMap.get(integrationMessage.ParentRefId__c).PassExpDt__c<System.today()){
                                    platformWra.errorMessage='Passport expired: Kindly provide alternate KYC proof';
                                }
                                else{
                                    platformWra.success=true;
                                }
                                
                            }
                            if(responseWrapper.statusCode!=GlobalConstants.karza_Status_101){
                                platformWra.errorMessage=GlobalConstants.karza_Status_Code_Authn_Description.containsKey(responseWrapper.statusCode)?GlobalConstants.karza_Status_Code_Authn_Description.get(responseWrapper.statusCode):'';
                            }
                        }
                        else{
                            platformWra.errorMessage = KarzaErrorResponseController.getErrorMessage(integrationMessage);
                        }
                        publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
                    } 
                }    
            }
        }
        //Exception Handling
        catch(Exception ex){
            GlobalUtility.logMessage('Error', 'passportResponseProcessor', 
                                     'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            system.debug('EXCEPTION IN PASSPORT RESPO:::::::::'+ex.getMessage() + '/n' + ' Line Number ' + ex.getLineNumber());
        }  
        //system.debug('appKyc'+appKycList+'appKyc SIZE::::::'+appKycList.size());
        
    }
    
    //Update Applicant Kyc Record with response processor data
    
    public static void updateApplicantKYCError(passportResponseWrapper responseWrapper,IntgMsg__c integrationMessage){
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { ApplKyc__c.SObjectType });
        try{
            if(responseWrapper != null){
                ApplKyc__c AppKyc=New ApplKyc__c();
                AppKyc.Id = integrationMessage.ParentRefId__c;
                AppKyc.ValidationStatus__c=GlobalConstants.MSG_FAILURE;
                AppKyc.DOBValidationStatus__c = GlobalConstants.MSG_FAILURE;
                if(responseWrapper.statusCode!=null){
                	AppKyc.Validation_Error_Message__c=GlobalConstants.karza_Status_Code_Authn_Description.containsKey(responseWrapper.statusCode)?GlobalConstants.karza_Status_Code_Authn_Description.get(responseWrapper.statusCode):'';
                }
                else{
                    AppKyc.Validation_Error_Message__c=KarzaErrorResponseController.getErrorMessage(integrationMessage);
                }
                if(AppKyc != null){
                    List<string> fieldNamesList = New List<string>{'ValidationStatus__c','Validation_Error_Message__c','DOBValidationStatus__c'};
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
    //*********************************************************************************************************************************
    public static void updateApplicantDetials(passportResponseWrapper responseWrapper, Id referenceId, ID parentReferenceId,IntgMsg__c integrationMessage){
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> { Applicant__c.SObjectType, ApplKyc__c.SObjectType });
        
        List<ApplKyc__c>appKyc =[SELECT Id,Applicant__c,kycDoc__c,PassExpDt__c,DtOfBirth__c FROM ApplKyc__c WHERE Id=:parentReferenceId and kycDoc__c='Passport'];
        List<DocDtl__c> docDtl =[Select Id, CreatedBY.Name,Applicant_KYC__c,DocCatgry__c,DocTyp__c,DocSubTyp__c,Applicant_KYC__r.Applicant__r.LoanAppln__c,
                                     Applicant_KYC__r.Applicant__c,Applicant_KYC__r.ValidationStatus__c,Applicant_KYC__r.OCRStatus__c,
                                     Applicant_KYC__r.AdrsSplitStatus__c,Applicant_KYC__r.AddrLine1__c,Applicant_KYC__r.AddrLine2__c,
                                     Applicant_KYC__r.Landmark__c,Applicant_KYC__r.Locality__c,Applicant_KYC__r.HouseNo__c,
                                     Applicant_KYC__r.Country__c,Applicant_KYC__r.Pincode__c,Applicant_KYC__r.City__c,
                                     Applicant_KYC__r.State__c FROM DocDtl__c WHERE Id=:referenceId];
        
        List<ApplKyc__c> appKycList = new List<ApplKyc__c>();
        List<Applicant__c> updateAppList = new List<Applicant__c>();
        Boolean updateApplicantDetials=false;
        if(responseWrapper != null){
            if(!appKyc.isEmpty()){
                ApplKyc__c updateAppKyc = new ApplKyc__c();
                updateAppKyc.id = parentReferenceId ;
                
                List<String> doi = responseWrapper.result.dateOfIssue.dispatchedOnFromSource.split('/'); 
                
                if(doi != null && doi.size()>=2){
                    if(doi[0].isNumeric() && doi[1].isNumeric() && doi[2].isNumeric()){
                        updateAppKyc.PassIssueDt__c = Date.newInstance(Integer.valueof(doi[2]),Integer.valueof(doi[1]),Integer.valueof(doi[0]));
                    }
                }
                
                updateAppKyc.Name__c = String.isNotBlank(responseWrapper.result.name.surnameFromPassport) ? responseWrapper.result.name.nameFromPassport +' '+ responseWrapper.result.name.surnameFromPassport: responseWrapper.result.name.nameFromPassport;
                updateAppKyc.LName__c = responseWrapper.result.name.surnameFromPassport;
                updateAppKyc.kycId__c = responseWrapper.result.passportNumber.passportNumberFromSource;
                if(responseWrapper.result.passportNumber.passportNumberMatch==true){
                    updateAppKyc.PassNoMatch__c=true;
                }
                updateAppKyc.PassApplType__c=responseWrapper.result.typeOfApplication;
                if(String.isNotBlank(responseWrapper.result.name.nameScore) && responseWrapper.result.name.nameScore!=null  && responseWrapper.result.name.nameScore.isNumeric()){
                    updateAppKyc.PassNameMatchScore__c=Decimal.ValueOf(responseWrapper.result.name.nameScore);
                }
                if(responseWrapper.result.name.nameMatch==true){
                    updateAppKyc.PassNameMatch__c=true;
                }
                if(appKyc[0].PassExpDt__c!=null && appKyc[0].PassExpDt__c<system.today()){
                    updateAppKyc.ValidationStatus__c=GlobalConstants.MSG_FAILURE;
                    updateAppKyc.Validation_Error_Message__c='Passport Expired';
                    
                }
                else {
                    updateAppKyc.validated__c = true ;
                	updateAppKyc.ValidationStatus__c=Globalconstants.MSG_SUCCESS;
                    updateAppKyc.Validation_Error_Message__c='';
                    updateApplicantDetials=true;
                    
                    /*if(appKyc[0].Applicant__c!=null && docDtl[0].Id !=null && docDtl[0].DocTyp__c=='Identity Proof'){
                    Applicant__c updateApp = new Applicant__c();
                    updateApp.id = appKyc[0].Applicant__c;
                    if(!String.isBlank(responseWrapper.result.name.nameFromPassport)){
                        List<String> names = responseWrapper.result.name.nameFromPassport.split(' ');
                        if(!names.isEmpty()){
                            updateApp.FName__c=names[0];
                            if(names.size()>1 && names[1]!=null){
                                updateApp.MName__c=names[1];
                            }
                        }
                    }
                    if(!String.isBlank(responseWrapper.result.name.surnameFromPassport)){
                        updateApp.LName__c = responseWrapper.result.name.surnameFromPassport;
                    }
                    
                    updateAppList.add(updateApp);
                }*/
                }
                
                updateAppKyc.DOBValidationStatus__c =(appKyc[0].DtOfBirth__c!=null) ? Globalconstants.MSG_SUCCESS : GlobalConstants.MSG_FAILURE;
                    
                appKycList.add(updateAppKyc);
                
                
            }
        }
        
        if(!appKycList.isEmpty()){
            
            List<string> fieldNamesList = New List<string>{'PassIssueDt__c','Name__c','kycId__c','PassNo__c','validated__c','ValidationStatus__c','PassNoMatch__c','PassApplType__c','PassNameMatchScore__c','PassNameMatch__c','Validation_Error_Message__c','LName__c','DOBValidationStatus__c'};
                String sObjectName = 'ApplKyc__c';
            Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
            fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
            uow.registerDirty(appKycList);
            
        }
        
       /* if(!updateAppList.isEmpty()){
            List<string> fieldNamesList = New List<string>{'FName__c','MName__c','LName__c'};
                String sObjectName = 'Applicant__c';
            Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
            fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
            uow.registerDirty(updateAppList);
        }*/
        
        uow.commitWork();
        if(updateApplicantDetials && !docDtl.isEmpty()){
        	ApplicantUpdate au = new ApplicantUpdate();
            au.Afterinsert(docDtl);
         }
        
        APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Success');
        
    }
    
}