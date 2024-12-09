public class IntOCRPanResponseProcessor implements IintMsgCalloutResponseProcessor{
    
    //Implementing the process method
    public static void process(List<IntgMsg__c> responses){ 
        
        //Processing all responses
        for(IntgMsg__c integrationMessage : responses){
            if(integrationMessage.Svc__c != GlobalConstants.INT_CONFIG_SERVICE_KYC_OCR_PAN 
               && integrationMessage.BU__c != GlobalConstants.INT_MSG_BU_TYPE){
                   //throw new processException('Error! This is not the correct service'); 
               }
            try{
                //parse response
                IntOCRPanResponseWrapper responseWrapper = (IntOCRPanResponseWrapper) JSON.deserialize(integrationMessage.Resp__c, IntOCRPanResponseWrapper.class); 
                
                //check if responseWrapper is empty or not                
                if(responseWrapper != null){
                    //Note : Waiting for fields Information which need to be updated 
                    if(responseWrapper.statusCode!=null){
                        if(responseWrapper.statusCode==GlobalConstants.karza_Status_101){
                            if(responseWrapper.result[0].type.contains('Pan')){
                                checkPanStatus(integrationMessage);
                            }
                            else{
                                updateApplicantKYCRecorderror(responseWrapper,integrationMessage,GlobalConstants.General_Message_KYCOCR);
                            }
                        }
                        if(responseWrapper.statusCode!=GlobalConstants.karza_Status_101){
                            String errorMessage=GlobalConstants.karza_Status_Code_OCR_Description.containsKey(responseWrapper.statusCode)?GlobalConstants.karza_Status_Code_OCR_Description.get(responseWrapper.statusCode):'';
                            updateApplicantKYCRecorderror(responseWrapper,integrationMessage,errorMessage);
                        }
                    }
                    else {
                        String errorMessage = KarzaErrorResponseController.getErrorMessage(integrationMessage);
                        updateApplicantKYCRecorderror(responseWrapper,integrationMessage,errorMessage);
                    }
                    
                    
                    /*if(integrationMessage.Trigger_Platform_Event__c){
publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
platformWra.intId = integrationMessage.Id; 
platformWra.recId = integrationMessage.ParentRefId__c;
platformWra.ServiceName = integrationMessage.Svc__c ;
platformWra.Status = integrationMessage.Status__c ;


if(responseWrapper.statusCode==GlobalConstants.karza_Status_101){
if(responseWrapper.result[0].type.contains('Pan')){
platformWra.success=true;
}
else{
platformWra.errorMessage=GlobalConstants.General_Message_KYCOCR;
}

}
if(responseWrapper.statusCode!=GlobalConstants.karza_Status_101){
platformWra.errorMessage=GlobalConstants.karza_Status_Code_OCR_Description.containsKey(responseWrapper.statusCode)?GlobalConstants.karza_Status_Code_OCR_Description.get(responseWrapper.statusCode):'';
}

publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
}*/
                    
                } 
            }
            //Exception Handling
            catch(Exception ex){
                system.debug('ex.getMessage()'+ex.getMessage());
                GlobalUtility.logMessage('Error', 'IntOCRPanServiceResponseProcessor class', 
                                         'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }  
            
        }  
        
    }
    
    
    
    public static void updateApplicantKYCRecord(IntOCRPanResponseWrapper responseWrapper,IntgMsg__c intgMsgRecord,String dateOfBirth){
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { ApplKyc__c.SObjectType,Applicant__c.SObjectType });
        
        try{
            if(responseWrapper != null){
                Map<String,ApplKyc__c> appKycMap = new Map<String,ApplKyc__c>([SELECT Id,Applicant__c,Applicant__r.Constitution__c,kycDoc__c,DtOfBirth__c,NameInPan__c,FatherName__c,DtOfIssue__c FROM ApplKyc__c WHERE Id=:intgMsgRecord.ParentRefId__c and kycDoc__c='Pan']);
                String companyName;
                Date dtOfIssue; 
                ApplKyc__c AppKyc=New ApplKyc__c();
                AppKyc.Id = intgMsgRecord.ParentRefId__c;
                AppKyc.OCRStatus__c=GlobalConstants.MSG_SUCCESS;
                if(!String.isBlank(responseWrapper.result[0].details.name.value)){
                    AppKyc.NameInPan__c = responseWrapper.result[0].details.name.value;
                    AppKyc.Name__c = responseWrapper.result[0].details.name.value;
                    companyName = responseWrapper.result[0].details.name.value;
                }
                if(!String.isBlank(responseWrapper.result[0].details.father.value)){
                    AppKyc.FatherName__c =responseWrapper.result[0].details.father.value;
                }
                if(!String.isBlank(responseWrapper.result[0].details.panNo.value)){
                    AppKyc.Pan__c =responseWrapper.result[0].details.panNo.value;
                }
                if(responseWrapper.result[0].details.dateOfIssue.value!= null){
                    if(!String.isBlank(responseWrapper.result[0].details.dateOfIssue.value)){
                        //AppKyc.DtOfIssue__c = Date.valueOf(responseWrapper.result[0].details.dateOfIssue.value);
                        List<String> doi = responseWrapper.result[0].details.dateOfIssue.value.split('/');
                        if(doi != null && doi.size()>=2){
                            AppKyc.DtOfIssue__c = Date.newInstance(Integer.valueof(doi[2]),Integer.valueof(doi[1]),Integer.valueof(doi[0]));
                        }
                    }
                }
                system.debug('valuess'+responseWrapper.result[0].details);
                
                if(!String.isBlank(dateOfBirth)){
                    List<String> dob = dateOfBirth.split('/');
                    
                    if(dob != null && dob.size()>=2){
                        if(dob[0].isNumeric() && dob[1].isNumeric() && dob[2].isNumeric()){
                            dtOfIssue = Date.newInstance(Integer.valueof(dob[2]),Integer.valueof(dob[1]),Integer.valueof(dob[0]));
                            AppKyc.DtOfBirth__c = dtOfIssue;
                        }
                    }  
                }
                
                
                if(AppKyc != null){
                    List<string> fieldNamesList = New List<string>{'NameInPan__c','FatherName__c','Pan__c','DtOfIssue__c','DtOfBirth__c','OCRStatus__c','Name__c'};
                        String sObjectName = 'ApplKyc__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                    uow.registerDirty(AppKyc);
                }
                
                if(appKycMap.containsKey(intgMsgRecord.ParentRefId__c) && appKycMap.get(intgMsgRecord.ParentRefId__c).Applicant__c!=null){
                    if(appKycMap.get(intgMsgRecord.ParentRefId__c).Applicant__r.Constitution__c!='INDIVIDUAL' && appKycMap.get(intgMsgRecord.ParentRefId__c).Applicant__r.Constitution__c != 'PROPERITORSHIP'){
                        Applicant__c updateApp = new Applicant__c();
                        updateApp.id = appKycMap.get(intgMsgRecord.ParentRefId__c).Applicant__c;
                        updateApp.CompanyName__c = companyName;
                        updateApp.DOI__c = dtOfIssue;
                        
                        List<string> applicantfieldList = New List<string>{'CompanyName__c','DOI__c'};    
                            String  applicantObject= 'Applicant__c';
                        Schema.SObjectType applicantObjType  = Schema.getGlobalDescribe().get(applicantObject);
                        fflib_SecurityUtils.checkUpdate(applicantObjType,applicantfieldList);
                        uow.registerDirty(updateApp);
                    }
                }
                
                
            }
        }
        catch(exception ex){
            system.debug('error message and line number '+ ex.getMessage() + 'line' + ex.getLineNumber());
        }
        if(intgMsgRecord.Trigger_Platform_Event__c){
            publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
            platformWra.intId = intgMsgRecord.Id; 
            platformWra.recId = intgMsgRecord.ParentRefId__c;
            platformWra.ServiceName = intgMsgRecord.Svc__c ;
            platformWra.Status = intgMsgRecord.Status__c ;
            platformWra.success=true;
            publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
        }
        uow.commitWork();
        
        APICalloutTracker.update_ApiTrackerWithIntMsg(intgMsgRecord.Id,intgMsgRecord.Svc__c, intgMsgRecord.RefId__c, 'Success');
        
        //Create Integration Message for Verification
                if(intgMsgRecord!=null && string.isNotblank(intgMsgRecord.RefId__c)){
                    
                    List<DocDtl__c> dtl=[Select id,Is_Generated_from_Lead_Flow__c,Is_Ready_for_KYC_Validations__c from DocDtl__c Where Id =:intgMsgRecord.RefId__c];
                    
                    if(dtl!=null && dtl[0].Is_Generated_from_Lead_Flow__c && dtl[0].Is_Ready_for_KYC_Validations__c){
                        
                        Map<String,Object> jsonDataMap = new Map<String, Object>();
                        
                        jsonDataMap.put('Name','Pan Validation');
                        jsonDataMap.put('Status','New');
                        jsonDataMap.put('MStatus','Blank');
                        jsonDataMap.put('BU',intgMsgRecord.BU__c);
                        jsonDataMap.put('RefId',intgMsgRecord.RefId__c);
                        jsonDataMap.put('RefObj',intgMsgRecord.RefObj__c);
                        jsonDataMap.put('ParentRefId',intgMsgRecord.ParentRefId__c);
                        jsonDataMap.put('ParentObject',intgMsgRecord.ParentRefObj__c);
                        jsonDataMap.put('Svc','Pan Validation');
                        jsonDataMap.put('IsActive',true);
                        
                        IntegrationUtility.createIntegrationMessage(JSON.serialize(jsonDataMap));
                    }
                }
    }
    
    public static void updateApplicantKYCRecorderror(IntOCRPanResponseWrapper responseWrapper,IntgMsg__c intgMsgRecord,String errorMessage){
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { ApplKyc__c.SObjectType });
        try{
            if(responseWrapper != null){
                ApplKyc__c AppKyc=New ApplKyc__c();
                AppKyc.Id = intgMsgRecord.ParentRefId__c;
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
        
        if(intgMsgRecord.Trigger_Platform_Event__c){
            publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
            platformWra.intId = intgMsgRecord.Id; 
            platformWra.recId = intgMsgRecord.ParentRefId__c;
            platformWra.ServiceName = intgMsgRecord.Svc__c ;
            platformWra.Status = intgMsgRecord.Status__c ;
            platformWra.errorMessage=errorMessage;
            publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
        }
        APICalloutTracker.update_ApiTrackerWithIntMsg(intgMsgRecord.Id,intgMsgRecord.Svc__c, intgMsgRecord.RefId__c, 'Failure');
    }
    
    public static void checkPanStatus(IntgMsg__c intgMsgRecord){
        
        Map<Id,ApplKyc__c> applKyc = new Map<Id,ApplKyc__c>([Select Id, Applicant__c,Applicant__r.Constitution__c FROM ApplKyc__c WHERE Id=:intgMsgRecord.ParentRefId__c]);
        IntOCRPanResponseWrapper responseWrapper = (IntOCRPanResponseWrapper) JSON.deserialize(intgMsgRecord.Resp__c,IntOCRPanResponseWrapper.class); 
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(intgMsgRecord.Resp__c);
        String dateofBirth;
        if(responseMap.containsKey('result')){
            List<Object> resultList = (List<Object>) responseMap.get('result');
            if(!resultList.isEmpty()){
                Map<String, Object> result = (Map<String, Object>) resultList[0];
                if(result.containsKey('details')){
                    Map<String, Object> details = (Map<String, Object>) result.get('details');
                    if(details.containsKey('date')){
                        Map<String, Object> dateInfo = (Map<String, Object>) details.get('date');
                        dateofBirth = (String) dateInfo.get('value');
                    }
                }
            }
        }
        
        if(responseWrapper != null){
            if(!String.isBlank(responseWrapper.result[0].details.panNo.value)){
                
                String panNumber = responseWrapper.result[0].details.panNo.value;
                String panStatus = panNumber.substring(3,4).toUpperCase();
                
                if(applKyc.containsKey(intgMsgRecord.ParentRefId__c) && applKyc.get(intgMsgRecord.ParentRefId__c).Applicant__r.Constitution__c !=null && panStatus!=null){
                    if((panStatus=='P' && (applKyc.get(intgMsgRecord.ParentRefId__c).Applicant__r.Constitution__c=='INDIVIDUAL' || applKyc.get(intgMsgRecord.ParentRefId__c).Applicant__r.Constitution__c=='PROPERITORSHIP')) ||
                       (panStatus=='C' && (applKyc.get(intgMsgRecord.ParentRefId__c).Applicant__r.Constitution__c=='PRIVATE LIMITED COMPANY' || applKyc.get(intgMsgRecord.ParentRefId__c).Applicant__r.Constitution__c=='PUBLIC LIMITED COMPANY')) ||
                       (panStatus=='H' && applKyc.get(intgMsgRecord.ParentRefId__c).Applicant__r.Constitution__c=='HUF') ||
                       (panStatus=='A' && (applKyc.get(intgMsgRecord.ParentRefId__c).Applicant__r.Constitution__c=='ASSOCIATION OF PERSONS' || applKyc.get(intgMsgRecord.ParentRefId__c).Applicant__r.Constitution__c=='SOCIETY')) ||
                       (panStatus=='F' && (applKyc.get(intgMsgRecord.ParentRefId__c).Applicant__r.Constitution__c=='LIMITED LIABILITY PARTNERSHIP' || applKyc.get(intgMsgRecord.ParentRefId__c).Applicant__r.Constitution__c=='PARTNERSHIP')) ||
                       (panStatus=='T' && applKyc.get(intgMsgRecord.ParentRefId__c).Applicant__r.Constitution__c=='TRUST')
                      ){
                          updateApplicantKYCRecord(responseWrapper,intgMsgRecord,dateOfBirth);
                      } 
                    else{
                        updateApplicantKYCRecorderror(responseWrapper,intgMsgRecord,'Uploaded PAN does not match the applicant\'s constitution');
                    }
                }
            }
        }   
    }
}