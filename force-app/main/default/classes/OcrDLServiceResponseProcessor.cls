public class OcrDLServiceResponseProcessor implements IintMsgCalloutResponseProcessor{
    //Implementing the process method
    public static void process(List<IntgMsg__c> responses){ 
        system.debug('responses from integration msg '+responses);
        //Processing all responses
        for(IntgMsg__c integrationMessage : responses){
            if(integrationMessage.Svc__c != GlobalConstants.INT_CONFIG_SERVICE_KYC_OCR_DL){
                //throw new processException('Error! This is not the correct service'); 
            }
            try{
                //parse response
                OcrDLServiceWrapperClass responseWrapper = (OcrDLServiceWrapperClass) JSON.deserialize(integrationMessage.Resp__c, OcrDLServiceWrapperClass.class); 
                
                
                if(responseWrapper != null){
                    //Note : Waiting for fields Information which need to be updated 
                    system.debug('responseWrapper '+ responseWrapper);
                    system.debug('responseWrapper get Status code ' +  responseWrapper.statusCode);
                    system.debug('requestId '+ responseWrapper.requestId);
                    
                    
                    if(responseWrapper.statusCode!=null){
                        if(responseWrapper.statusCode==GlobalConstants.karza_Status_101){
                            if(responseWrapper.result[0].type.contains('DL')){
                                updateApplicantKYCRecord(responseWrapper,integrationMessage.ParentRefId__c,integrationMessage);
                            }
                            else{
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
                                if(responseWrapper.result[0].type.contains('DL')){
                                    platformWra.success=true;
                                }else{
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
                GlobalUtility.logMessage('Error', 'OcrDLServiceResponseProcessor class', 
                                         'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }  
            
        }  
        
    }
    
    public static void createApplicantKYCRecord(OcrDLServiceWrapperClass responseWrapper,Id referenceId){
        if(responseWrapper != null){
            List<string> fieldNamesList = New List<string>{'Applicant__c','kycDoc__c','DLNo__c'};
                
                String sObjectName = 'ApplKyc__c';
            Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
            fflib_SecurityUtils.checkInsert(objType,fieldNamesList);
            
            ApplKyc__c AppKyc=New ApplKyc__c();
            AppKyc.Applicant__c = referenceId;
            if(responseWrapper.result[0].type == 'DL Front'){               
                AppKyc.kycDoc__c = 'Driving Licence';                 
            }
            //    List<DocDtl__c> DocDetails = [SELECT Id FROM DocDtl__c]; //DocType__c,DocMstr__r.nameWhere Applicant__c =: referenceId and DocType__c =: 'KYC' and Name =: 'DRIVING LICENCE'];
            //    system.debug('DocDetails'+DocDetails);
            //     if(!DocDetails.isEmpty()){
            //         AppKyc.docDtl__c = DocDetails[0].Id;
            //     }
            
            //    if(!String.isBlank(responseWrapper.result[0].details.dlNo.value)){
            //         AppKyc.DLNo__c =responseWrapper.result[0].details.dlNo.value;
            //     }
            
            // AppKyc. =responseWrapper.result[0].details.name.value;
            if(!String.isBlank(responseWrapper.result[0].details.dob.value)){
                List<String> doi = responseWrapper.result[0].details.dob.value.split('/');
                if(doi != null && doi.size()>=2){
                    //           AppKyc.DtOfBirth__c = Date.newInstance(Integer.valueof(doi[2]),Integer.valueof(doi[1]),Integer.valueof(doi[0]));
                }
                //AppKyc.DtOfBirth__c = date.parse(responseWrapper.result[0].details.dob.value);
            }
            
            // AppKyc.Address__ = responseWrapper.result[0].details.value;
            // AppKyc.Address__c = responseWrapper.result[0].details.address.value;
            // 
            //  if(AppKyc != null){
            //      database.insert (AppKyc);
            //     system.debug('AppKyc'+AppKyc);
            //  }
        }
    }    
    
    public static void updateApplicantKYCRecord(OcrDLServiceWrapperClass responseWrapper,Id referenceId,IntgMsg__c integrationMessage){
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { ApplKyc__c.SObjectType });
        
        try{
            if(responseWrapper != null){
                ApplKyc__c appKyc=New ApplKyc__c();
                AppKyc.Id = referenceId;
                appKyc.OCRStatus__c=GlobalConstants.MSG_SUCCESS;
                
                if(!String.isBlank(responseWrapper.result[0].details.dlNo.value)){
                    appKyc.DLNo__c =responseWrapper.result[0].details.dlNo.value;
                }
                
                if(!String.isBlank(responseWrapper.result[0].details.dob.value)){
                    List<String> doi = responseWrapper.result[0].details.dob.value.split('/');
                    if(doi != null && doi.size()>=2){
                        appKyc.DtOfBirth__c = Date.newInstance(Integer.valueof(doi[2]),Integer.valueof(doi[1]),Integer.valueof(doi[0]));
                    }
                }
                if(!String.isBlank(responseWrapper.result[0].details.name.value)){
                    appKyc.Name__c = responseWrapper.result[0].details.name.value;
                }
                
                if(AppKyc != null){
                    List<string> fieldNamesList = New List<string>{'OCRStatus__c','DLNo__c','DtOfBirth__c','Name__c'};
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
        APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Success');
        //Create Integration Message for Verification
                if(integrationMessage!=null && string.isNotblank(integrationMessage.RefId__c)){
                    
                    List<DocDtl__c> dtl=[Select id,Is_Generated_from_Lead_Flow__c,Is_Ready_for_KYC_Validations__c from DocDtl__c Where Id =:integrationMessage.RefId__c];
                    
                    if(dtl!=null && dtl[0].Is_Generated_from_Lead_Flow__c && dtl[0].Is_Ready_for_KYC_Validations__c){
                        
                        Map<String,Object> jsonDataMap = new Map<String, Object>();
                        
                        jsonDataMap.put('Name','DL Authentication');
                        jsonDataMap.put('Status','New');
                        jsonDataMap.put('MStatus','Blank');
                        jsonDataMap.put('BU',integrationMessage.BU__c);
                        jsonDataMap.put('RefId',integrationMessage.RefId__c);
                        jsonDataMap.put('RefObj',integrationMessage.RefObj__c);
                        jsonDataMap.put('ParentRefId',integrationMessage.ParentRefId__c);
                        jsonDataMap.put('ParentObject',integrationMessage.ParentRefObj__c);
                        jsonDataMap.put('Svc','DL Authentication');
                        jsonDataMap.put('IsActive',true);
                        
                        IntegrationUtility.createIntegrationMessage(JSON.serialize(jsonDataMap));
                    }
                }
    }
    
    public static void updateApplicantKYCRecordError(OcrDLServiceWrapperClass responseWrapper,Id referenceId,String errorMessage,IntgMsg__c integrationMessage){
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