public class DrivingLicenseRespProcessor implements IintMsgCalloutResponseProcessor{
    
    //Implementing the process method
    public static void process(List<IntgMsg__c> responses){ 
        
        //Processing all responses
        for(IntgMsg__c integrationMessage : responses){
            if(integrationMessage.Svc__c != GlobalConstants.INT_CONFIG_SERVICE_DRIVERS_LICENSE_AUTHENTICATION){
                throw new processException('Error! This is not the correct service'); 
            }
            try{
                system.debug('integrationMessage.Resp__c '+integrationMessage.Resp__c);
                //parse response
                String fatherOrHusband;
                Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(integrationMessage.Resp__c);
                
                if(jsonMap.containskey('result')){
                    fatherOrHusband =(String)((Map<String, Object>)jsonMap.get('result')).get('father/husband');
                }
                
                
                DrivingLicenseWrapper responseWrapper = (DrivingLicenseWrapper) JSON.deserialize(integrationMessage.Resp__c, DrivingLicenseWrapper.class); 
                
                //check if responseWrapper is empty or not
                if(responseWrapper != null){
                    //Note : Waiting for fields Information which need to be updated 
                    system.debug('responseWrapper '+ responseWrapper);
                    system.debug('responseWrapper get Status code ' +  responseWrapper.statusCode);
                    system.debug('requestId '+ responseWrapper.requestId);
                    
                    if(responseWrapper.statusCode==GlobalConstants.karza_Status_101){
                        //updateApplicantKyc(responseWrapper,integrationMessage.RefId__c);
                        updateApplicantKyc(responseWrapper,integrationMessage.RefId__c,integrationMessage.ParentRefId__c,fatherOrHusband,integrationMessage);
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
                                //platformWra.success=true;
                                List<String> transport;
                                List<String> nontransport;
                                Date transportTo;
                                Date nontransportTo;
                                if(responseWrapper.result!=null && responseWrapper.result.validity!=null){
                                    if(responseWrapper.result.validity.transport.containsIgnoreCase('to')){
                                        transport = responseWrapper.result.validity.transport.split('[- ]');
                                        if(transport.size()>=7 && !String.isBlank(responseWrapper.result.validity.transport)){
                                            transportTo = Date.newInstance(Integer.valueof(transport[6]),Integer.valueof(transport[5]),Integer.valueof(transport[4]));
                                        }
                                    }
                                    else{
                                        transport = responseWrapper.result.validity.transport.split('-');
                                        if(transport.size()>=3 && !String.isBlank(responseWrapper.result.validity.transport)){
                                            transportTo = Date.newInstance(Integer.valueof(transport[2]),Integer.valueof(transport[1]),Integer.valueof(transport[0]));
                                        }
                                    }
                                    
                                    
                                    if(responseWrapper.result.validity.nontransport.containsIgnoreCase('to')){
                                        nontransport = responseWrapper.result.validity.nontransport.split('[- ]');
                                        if(nontransport.size()>=7 && !String.isBlank(responseWrapper.result.validity.nontransport)){
                                            nontransportTo = Date.newInstance(Integer.valueof(nontransport[6]),Integer.valueof(nontransport[5]),Integer.valueof(nontransport[4]));
                                        }
                                    }
                                    else{
                                        nontransport = responseWrapper.result.validity.nontransport.split('-');
                                        if(nontransport.size()>=3 && !String.isBlank(responseWrapper.result.validity.nontransport)){
                                            nontransportTo = Date.newInstance(Integer.valueof(nontransport[2]),Integer.valueof(nontransport[1]),Integer.valueof(nontransport[0]));
                                        }
                                    }
                                }
                                
                                
                                if((nontransportTo!=null && nontransportTo<System.today()) || (transportTo!=null && transportTo<System.today())){
                                    platformWra.errorMessage='DL expired: Kindly provide alternate KYC proof';
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
            //Exception Handling
            catch(Exception ex){
                GlobalUtility.logMessage('Error', 'DrivingLicenseRespProcessor', 
                                         'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }  
            
        }       
    }
    
    //Update Applicant Kyc Record with response processor data
    //**************************************************************************************************************************************//    
    public static void updateApplicantKYCError(DrivingLicenseWrapper responseWrapper,IntgMsg__c integrationMessage){
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
                else {
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
    
    //****************************************************************************************************************************************//  
    public static void updateApplicantKyc(DrivingLicenseWrapper responseWrapper, Id referenceId,Id parentreferenceId,String fatherOrHusband,IntgMsg__c integrationMessage){
        try{
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { ApplKyc__c.SObjectType,IntgMsg__c.SObjectType, ApplAddr__c.SObjectType,Applicant__c.SObjectType} );
            
            List<ApplKyc__c>appKyc = [SELECT Id,Applicant__c,kycDoc__c,DOBValidationStatus__c,DtOfBirth__c FROM ApplKyc__c  WHERE Id=:parentreferenceId and kycDoc__c='Driving License'];
            
            List<ApplAddr__c>  updateAppaddr=[select id,Applicant__r.id,AddrTyp__c from ApplAddr__c where Applicant__r.id=:appKyc[0].Applicant__c and AddrTyp__c='Residence Address'];
            //String	DocDtl=[Select Id,DocTyp__c from DocDtl__c where Id=:referenceId].DocTyp__c;
            List<DocDtl__c> docDtl =[Select Id, CreatedBY.Name,Applicant_KYC__c,DocCatgry__c,DocTyp__c,DocSubTyp__c,Applicant_KYC__r.Applicant__r.LoanAppln__c,
                                     Applicant_KYC__r.Applicant__c,Applicant_KYC__r.ValidationStatus__c,Applicant_KYC__r.OCRStatus__c,
                                     Applicant_KYC__r.AdrsSplitStatus__c,Applicant_KYC__r.AddrLine1__c,Applicant_KYC__r.AddrLine2__c,
                                     Applicant_KYC__r.Landmark__c,Applicant_KYC__r.Locality__c,Applicant_KYC__r.HouseNo__c,
                                     Applicant_KYC__r.Country__c,Applicant_KYC__r.Pincode__c,Applicant_KYC__r.City__c,
                                     Applicant_KYC__r.State__c FROM DocDtl__c WHERE Id=:referenceId];
            List<ApplKyc__c> appKycList = new List<ApplKyc__c>();
            List<ApplAddr__c> updateAdrList = new List<ApplAddr__c>();
            List<Applicant__c> updateAppList=new List<Applicant__c>();
            List<IntgMsg__c> intgMsgList =new List<IntgMsg__c>();
            
            Boolean updateApplicantDetials=false;
            if(responseWrapper != null){
                if(!appKyc.isEmpty()){
                    ApplKyc__c updateAppKyc = new ApplKyc__c();
                    updateAppKyc.id = appKyc[0].id ; 
                    updateAppKyc.Name__c = responseWrapper.result.name;
                    updateAppKyc.kycId__c = responseWrapper.result.dlNumber;
                    updateAppKyc.DLNo__c = responseWrapper.result.dlNumber;
                    
                    List<String> doi = responseWrapper.result.dob.split('-');      
                    if(doi != null && doi.size()>=3){
                        updateAppKyc.DtOfBirth__c = Date.newInstance(Integer.valueof(doi[2]),Integer.valueof(doi[1]),Integer.valueof(doi[0]));
                    }
                    
                    //LAK-9313 - Changes Start
                    List<String> addressDetails = new List<String>();
                    if(responseWrapper.result.address[0].completeAddress!=null && String.isNotBlank(responseWrapper.result.address[0].completeAddress)){
                        addressDetails.add(responseWrapper.result.address[0].completeAddress);
                    }
                    if(responseWrapper.result.address[0].district!=null && String.isNotBlank(responseWrapper.result.address[0].district)){
                        addressDetails.add(responseWrapper.result.address[0].district);
                    }
                    if(responseWrapper.result.address[0].state!=null && String.isNotBlank(responseWrapper.result.address[0].state)){
                        addressDetails.add(responseWrapper.result.address[0].state);
                    }
                    if(responseWrapper.result.address[0].pin!=null){
                        addressDetails.add(String.valueOf(responseWrapper.result.address[0].pin));
                    }
                    
                    if(addressDetails!=null && !addressDetails.isEmpty()){
                        updateAppKyc.AdrsSplitStatus__c = 'In progress';
                        updateAppKyc.Address__c =  String.join(addressDetails,',');
                        
                        IntgMsg__c intMsgRec = new IntgMsg__c();
                        intMsgRec.Name = 'Address Split';
                        intMsgRec.BU__c = 'HL / STL';
                        intMsgRec.Status__c = GlobalConstants.INT_MSG_STATUS_NEW;
                        intMsgRec.MStatus__c = GlobalConstants.INT_MSG_MStatus_BLANK;
                        intMsgRec.Svc__c = 'Address Split';
                        intMsgRec.RefId__c = integrationMessage.RefId__c;
                        intMsgRec.RefObj__c = integrationMessage.RefObj__c;
                        intMsgRec.ParentRefId__c = integrationMessage.ParentRefId__c;
                        intMsgRec.ParentRefObj__c = integrationMessage.ParentRefObj__c;
                        intMsgRec.IsActive__c = TRUE;
                        intgMsgList.add(intMsgRec);
                        
                    }
                    //LAK-9313 - Changes End
                    updateAppKyc.validated__c = true ;
                    updateAppKyc.FatherName__c = fatherOrHusband;
                    
                    
                    List<String> transport;
                    List<String> nontransport;
                    if(responseWrapper.result.validity!=null){
                        if(responseWrapper.result.validity.transport.containsIgnoreCase('to')){
                            transport = responseWrapper.result.validity.transport.split('[- ]');
                            if(transport.size()>=7 && !String.isBlank(responseWrapper.result.validity.transport)){
                                updateAppKyc.DLTransportFrom__c= Date.newInstance(Integer.valueof(transport[2]),Integer.valueof(transport[1]),Integer.valueof(transport[0]));
                                updateAppKyc.DLTransportTo__c= Date.newInstance(Integer.valueof(transport[6]),Integer.valueof(transport[5]),Integer.valueof(transport[4]));
                            }
                        }
                        else{
                            transport = responseWrapper.result.validity.transport.split('-');
                            if(transport.size()>=3 && !String.isBlank(responseWrapper.result.validity.transport)){
                                updateAppKyc.DLTransportTo__c = Date.newInstance(Integer.valueof(transport[2]),Integer.valueof(transport[1]),Integer.valueof(transport[0]));
                            }
                        }
                        
                        if(responseWrapper.result.validity.nontransport.containsIgnoreCase('to')){
                            nontransport = responseWrapper.result.validity.nontransport.split('[- ]');
                            if(nontransport.size()>=7 && !String.isBlank(responseWrapper.result.validity.nontransport)){
                                updateAppKyc.DLNonTransportFrom__c= Date.newInstance(Integer.valueof(nontransport[2]),Integer.valueof(nontransport[1]),Integer.valueof(nontransport[0]));
                                updateAppKyc.DLNonTransportTo__c= Date.newInstance(Integer.valueof(nontransport[6]),Integer.valueof(nontransport[5]),Integer.valueof(nontransport[4]));
                            }
                        }
                        else{
                            nontransport = responseWrapper.result.validity.nontransport.split('-');
                            if(nontransport.size()>=3 && !String.isBlank(responseWrapper.result.validity.nontransport)){
                                updateAppKyc.DLNonTransportTo__c = Date.newInstance(Integer.valueof(nontransport[2]),Integer.valueof(nontransport[1]),Integer.valueof(nontransport[0]));
                            }
                        }
                    }
                    
                    
                    updateAppKyc.AddrLine1__c=responseWrapper.result.address[0].addressLine1;
                    updateAppKyc.State__c=responseWrapper.result.address[0].state;
                    updateAppKyc.Pincode__c=String.valueof(responseWrapper.result.address[0].pin);
                    updateAppKyc.Country__c=responseWrapper.result.address[0].country;
                    
                    
                    if((updateAppKyc.DLNonTransportTo__c!=null && updateAppKyc.DLNonTransportTo__c<System.today()) || (updateAppKyc.DLTransportTo__c!=null && updateAppKyc.DLTransportTo__c<System.today())){
                        updateAppKyc.ValidationStatus__c=GlobalConstants.MSG_FAILURE;
                        updateAppKyc.Validation_Error_Message__c='DL Expired';
                        
                    }
                    else{
                        updateAppKyc.ValidationStatus__c=Globalconstants.MSG_SUCCESS;
                        updateAppKyc.Validation_Error_Message__c='';
                        updateApplicantDetials=true;   
                    }
                    
                    updateAppKyc.District__c=responseWrapper.result.address[0].district;
                    updateAppKyc.AddressType__c=responseWrapper.result.address[0].type;
                    updateAppKyc.DLStatus__c=responseWrapper.result.status;
                    
                    if((!responseWrapper.result.covDetails.isEmpty()) && String.isNotBlank(responseWrapper.result.covDetails[0].issueDate)){
                        List<String> dlExpiryDate = responseWrapper.result.covDetails[0].issueDate.split('-');      
                        if(dlExpiryDate != null && dlExpiryDate.size()>=3){
                            updateAppKyc.DLIssueDt__c = Date.newInstance(Integer.valueof(dlExpiryDate[2]),Integer.valueof(dlExpiryDate[1]),Integer.valueof(dlExpiryDate[0]));
                        }
                    }   
                    
                    updateAppKyc.DOBValidationStatus__c = (appKyc[0].DtOfBirth__c!=null || updateAppKyc.DtOfBirth__c!=null) ? Globalconstants.MSG_SUCCESS : GlobalConstants.MSG_FAILURE;
                    updateAppKyc.DLExpDt__c = updateAppKyc.DLTransportTo__c!=null ? updateAppKyc.DLTransportTo__c : updateAppKyc.DLNonTransportTo__c;  
                    
                    appKycList.add(updateAppKyc);
                }
                
            }
            
            
            if(!appKycList.isEmpty()){
                
                List<string> fieldNamesList = New List<string>{'Name__c','kycId__c','DLNo__c','DtOfBirth__c','Address__c','validated__c','FatherName__c','DLIssueDt__c','ValidationStatus__c','DLNonTransportFrom__c','DLNonTransportTo__c','DLTransportFrom__c','DLTransportTo__c','District__c','AddressType__c','DLStatus__c','AddrLine1__c','State__c','Pincode__c','Country__c','Validation_Error_Message__c'};
                    String sObjectName = 'ApplKyc__c';
                Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                uow.registerDirty(appKycList);
                
            }
            uow.commitWork();
            
            if(!intgMsgList.isEmpty()) {
                insert intgMsgList;
            }
            
            
            if(updateApplicantDetials && !docDtl.isEmpty()){
                ApplicantUpdate au = new ApplicantUpdate();
                au.Afterinsert(docDtl);
            }
            APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Success');
        }
        catch(exception ex){
            system.debug('error message and line number '+ ex.getMessage() + 'line' + ex.getLineNumber());
        }	
    }
}