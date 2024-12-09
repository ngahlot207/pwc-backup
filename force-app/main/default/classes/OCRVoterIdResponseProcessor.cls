public class OCRVoterIdResponseProcessor implements IintMsgCalloutResponseProcessor{
    
    //Implementing the process method
    public static void process(List<IntgMsg__c> responses){ 
        
        Map<id, string> ApplicantkycMap=new Map<id, string>(); 
        set<id> applicantkycid=new set<id>();
        for(IntgMsg__c integrationMessage : responses){
            if(integrationMessage.Svc__c != GlobalConstants.INT_CONFIG_SERVICE_KYC_OCR 
               && integrationMessage.BU__c != GlobalConstants.INT_MSG_BU_TYPE){
                   throw new processException('Error! This is not the correct service'); 
               }
            if(integrationMessage.ParentRefId__c!=null)
                applicantkycid.add(integrationMessage.ParentRefId__c);
        }
        if(applicantkycid.size()>0)
        {
            CheckValidOCR(applicantkycid,responses);
        }
    }
    
    
    public static void CheckValidOCR(set<id> kycid, List<IntgMsg__c> responses)  
    {
        Map<Id,ApplKyc__c> applKycMap;
        IntOCRVoterIdServiceResponseWrapper responseWrapper; 
        if(kycid.size()>0)
        {
            applKycMap = new Map<Id,ApplKyc__c>([SELECT Id,kycDoc__c FROM ApplKyc__c WHERE Id IN: kycid]);
        }
        if(!responses.isEmpty())
        {
            //responseWrapper = (IntOCRVoterIdServiceResponseWrapper) JSON.deserialize(responses[0].Resp__c, IntOCRVoterIdServiceResponseWrapper.class);  
            processResponse(responses);
        }
        /*if(responseWrapper.result[0].type.contains('Voterid'))//applKycMap.get(responses[0].ParentRefId__c).kycDoc__c))
{
processResponse(responses);
}
else
{

updateApplicantKYCRecordError(responseWrapper,responses[0].ParentRefId__c,GlobalConstants.General_Message_KYCOCR,responses);
}*/
        
    }
    
    public static void processResponse(List<IntgMsg__c> responses)
    {
        if(!responses.isEmpty())
        {
            try{
                //parse response
                IntOCRVoterIdServiceResponseWrapper  responseWrapper = (IntOCRVoterIdServiceResponseWrapper) JSON.deserialize(responses[0].Resp__c, IntOCRVoterIdServiceResponseWrapper.class);
                
                //check if responseWrapper is empty or not
                if(responseWrapper != null){
                    if(responseWrapper.statusCode!=null){
                        if(responseWrapper.statusCode==GlobalConstants.karza_Status_101){
                            if(responseWrapper.result[0].type.contains('Voterid')){
                                updateApplicantKYCRecord(responseWrapper,responses[0].ParentRefId__c,responses,responses[0]); 
                            }
                            else{
                                updateApplicantKYCRecordError(responseWrapper,responses[0].ParentRefId__c,GlobalConstants.General_Message_KYCOCR,responses,responses[0]);
                            }
                            
                            
                        }
                        if(responseWrapper.statusCode!=GlobalConstants.karza_Status_101){
                            updateApplicantKYCRecordError(responseWrapper,responses[0].ParentRefId__c,'', responses,responses[0]);
                        }
                    } 
                    else {
                        string errorMessage = KarzaErrorResponseController.getErrorMessage(responses[0]);
                        updateApplicantKYCRecordError(responseWrapper,responses[0].ParentRefId__c,errorMessage,responses,responses[0]);
                    }
                    
                } 
            }
            //Exception Handling
            catch(Exception ex){
                GlobalUtility.logMessage('Error', 'OCRVoterIdResponseProcessor class', 
                                         'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }  
            
        }  
    }
    
    public static void updateApplicantKYCRecord(IntOCRVoterIdServiceResponseWrapper responseWrapper,string referenceId,List<IntgMsg__c> responses,IntgMsg__c integrationMessage){
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { ApplKyc__c.SObjectType });
        
        try{
            if(responseWrapper != null){
                ApplKyc__c appKyc=New ApplKyc__c();
                appKyc.Id = referenceId;
                appKyc.OCRStatus__c=GlobalConstants.MSG_SUCCESS;
                
                if(!responseWrapper.result.isEmpty()){
                    for(IntOCRVoterIdServiceResponseWrapper.Result result: responseWrapper.result){
                        if(result.type=='Voterid Back'){
                            
                            if(!String.isBlank(result.details.voterid.value)){
                                appKyc.VotIdEpicNo__c =result.details.voterid.value;
                            }
                            if(!String.isBlank(result.details.address.value)){
                                appKyc.Address__c=result.details.address.value;
                            }
                            if(!String.isBlank(result.details.pin.value)){
                                appKyc.Pincode__c=result.details.pin.value;
                            }
                            if(!String.isBlank(result.details.dob.value)){
                                List<String> dob = result.details.dob.value.split('/');
                                if(dob != null && dob.size()>=2){
                                    if(dob[0].isNumeric() && dob[1].isNumeric() && dob[2].isNumeric()){
                                        AppKyc.DtOfBirth__c = Date.newInstance(Integer.valueof(dob[2]),Integer.valueof(dob[1]),Integer.valueof(dob[0]));
                                    }
                                }
                            }
                            if(!String.isBlank(result.details.addressSplit.city)){
                                appKyc.City__c = result.details.addressSplit.city;
                            }
                            if(!String.isBlank(result.details.addressSplit.line1)){
                                appKyc.AddrLine1__c = result.details.addressSplit.line1;
                            }
                            if(!String.isBlank(result.details.addressSplit.line2)){
                                appKyc.AddrLine2__c = result.details.addressSplit.line2;
                            }
                            if(!String.isBlank(result.details.addressSplit.state)){
                                appKyc.State__c = result.details.addressSplit.state;
                            }
                            if(!String.isBlank(result.details.addressSplit.landmark)){
                                appKyc.Landmark__c = result.details.addressSplit.landmark;
                            }
                            if(!String.isBlank(result.details.addressSplit.houseNumber)){
                                appKyc.HouseNo__c = result.details.addressSplit.houseNumber;
                            }
                            
                            
                        }
                        if(result.type.contains('Voterid Front')){
                            if(!String.isBlank(result.details.voterid.value)){
                                appKyc.VotIdEpicNo__c =result.details.voterid.value;
                            }
                            if(!String.isBlank(result.details.name.value)){
                                appKyc.Name__c =result.details.name.value;
                            }
                            if(result.details.dob!=null && (!String.isBlank(result.details.dob.value))){
                                List<String> dob = result.details.dob.value.split('/');
                                if(dob != null && dob.size()>=2){
                                    if(dob[0].isNumeric() && dob[1].isNumeric() && dob[2].isNumeric()){
                                        AppKyc.DtOfBirth__c = Date.newInstance(Integer.valueof(dob[2]),Integer.valueof(dob[1]),Integer.valueof(dob[0]));
                                    }    
                                }
                            }
                            if(!String.isBlank(result.details.relation.value)){
                                appKyc.FatherName__c =result.details.relation.value;
                                appKyc.HusbandName__c =result.details.relation.value;
                            }
                            
                        }
                    }
                }
                publishpaltformevent(responseWrapper,'',responses);
                if(AppKyc != null){
                    List<string> fieldNamesList = New List<string>{'OCRStatus__c','VotIdEpicNo__c','DtOfBirth__c','Name__c','City__c','AddrLine1__c','AddrLine2__c','State__c','Landmark__c','HouseNo__c','Address__c','Pincode__c','FatherName__c','HusbandName__c'};
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
                        
                        jsonDataMap.put('Name','Voterid Verification');
                        jsonDataMap.put('Status','New');
                        jsonDataMap.put('MStatus','Blank');
                        jsonDataMap.put('BU',integrationMessage.BU__c);
                        jsonDataMap.put('RefId',integrationMessage.RefId__c);
                        jsonDataMap.put('RefObj',integrationMessage.RefObj__c);
                        jsonDataMap.put('ParentRefId',integrationMessage.ParentRefId__c);
                        jsonDataMap.put('ParentObject',integrationMessage.ParentRefObj__c);
                        jsonDataMap.put('Svc','Voterid Verification');
                        jsonDataMap.put('IsActive',true);
                        
                        IntegrationUtility.createIntegrationMessage(JSON.serialize(jsonDataMap));
                    }
                }
        
    }
    
    public static void updateApplicantKYCRecordError(IntOCRVoterIdServiceResponseWrapper responseWrapper,Id referenceId, String errormessage,List<IntgMsg__c> responses,IntgMsg__c integrationMessage){
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { ApplKyc__c.SObjectType });
        try{
            if(responseWrapper != null){
                ApplKyc__c AppKyc=New ApplKyc__c();
                AppKyc.Id = referenceId;
                AppKyc.OCRStatus__c=GlobalConstants.MSG_FAILURE;
                if(errormessage=='')
                {
                    AppKyc.OCR_Error_Message__c=GlobalConstants.karza_Status_Code_OCR_Description.containsKey(responseWrapper.statusCode)?GlobalConstants.karza_Status_Code_OCR_Description.get(responseWrapper.statusCode):'';  
                }
                else
                {
                    AppKyc.OCR_Error_Message__c=errormessage;
                }
                publishpaltformevent(responseWrapper,errormessage,responses);
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
    
    public Static void publishpaltformevent(IntOCRVoterIdServiceResponseWrapper responseWrapper,string errormessage, List<IntgMsg__c> responses)
    {
        if(responses[0].Trigger_Platform_Event__c){
            publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
            platformWra.intId = responses[0].Id; 
            platformWra.recId = responses[0].ParentRefId__c;
            platformWra.ServiceName = responses[0].Svc__c ;
            platformWra.Status = responses[0].Status__c ;
            
            if(responseWrapper.statusCode==GlobalConstants.karza_Status_101){
                platformWra.success=true;
            }
            if(responseWrapper.statusCode!=GlobalConstants.karza_Status_101 && errormessage==''){
                platformWra.errorMessage=GlobalConstants.karza_Status_Code_OCR_Description.containsKey(responseWrapper.statusCode)?GlobalConstants.karza_Status_Code_OCR_Description.get(responseWrapper.statusCode):'';
                platformWra.success=false;
            }
            if(errormessage!='')
            {
                platformWra.errorMessage=errormessage;
                platformWra.success=false;
            }
            
            publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
        } 
    }
}