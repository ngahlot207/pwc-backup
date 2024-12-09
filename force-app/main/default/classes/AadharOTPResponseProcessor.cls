public class AadharOTPResponseProcessor implements IintMsgCalloutResponseProcessor {
    //Implementing the process method
    public static void process(List<IntgMsg__c> responses) {
        for (IntgMsg__c integrationMessage : responses) {
            if (integrationMessage.Svc__c != 'SFDC Aadhar OTP Verification' &&
                integrationMessage.BU__c != GlobalConstants.INT_MSG_BU_TYPE) {
                //throw new processException('Error! This is not the correct service');
            }

            try {
                SigndeskAPIController.EncryptedResponse encryptedresponse = (SigndeskAPIController.EncryptedResponse) JSON.deserialize(integrationMessage.Resp__c, SigndeskAPIController.EncryptedResponse.class);
                if (encryptedresponse.status.tolowerCase() == 'success') {
                    String decryptedResponse = SigndeskAPIController.getDecryptedResponse(encryptedResponse.encrypted_response);
                    if (String.isNotBlank(decryptedResponse)) {
                        AadharOTPResponsewrapper responseWrapper = (AadharOTPResponsewrapper) JSON.deserialize(decryptedResponse,AadharOTPResponsewrapper.class);
                        //check if responseWrapper is empty or not
                        if (responseWrapper != null) {
                            if (responseWrapper.status.tolowerCase() =='success') {
                                updateApplicantKYC(responseWrapper,integrationMessage);
                            } else {
                                String errorMessage = String.isNotBlank(responseWrapper.message)? responseWrapper.message: '';
                                updateApplicantKYCError(integrationMessage,errorMessage);
                            }
                        }
                    }
                } else {
                    updateApplicantKYCError(integrationMessage,encryptedresponse.ErrorMsg);
                }
                //Exception Handling
            } catch (Exception ex) {
                GlobalUtility.logMessage('Error','AadharOTPResponseProcessor class','Process',null,null,
                                         ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex,null);
            }
        }
    }

    public static void updateApplicantKYC(AadharOTPResponsewrapper responseWrapper,IntgMsg__c integrationMessage) {
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType>{ ApplKyc__c.SObjectType } );
        
        List<DocDtl__c> docDtl = [SELECT Id, CreatedBY.Name, Applicant_KYC__c,DocCatgry__c,DocTyp__c,DocSubTyp__c,Applicant_KYC__r.Applicant__r.LoanAppln__c,
                                     Applicant_KYC__r.Applicant__c,Applicant_KYC__r.ValidationStatus__c,Applicant_KYC__r.OCRStatus__c,
                                     Applicant_KYC__r.AdrsSplitStatus__c,Applicant_KYC__r.AddrLine1__c,Applicant_KYC__r.AddrLine2__c,
                                     Applicant_KYC__r.Landmark__c,Applicant_KYC__r.Locality__c,Applicant_KYC__r.HouseNo__c,
                                     Applicant_KYC__r.Country__c,Applicant_KYC__r.Pincode__c,Applicant_KYC__r.City__c,
                                     Applicant_KYC__r.State__c FROM DocDtl__c WHERE Id = :integrationMessage.RefId__c];
        
        List<ApplKyc__c>appKyc =[SELECT Id,Applicant__c,kycDoc__c,DtOfBirth__c FROM ApplKyc__c WHERE Id=:integrationMessage.ParentRefId__c 
                                 and kycDoc__c='Aadhaar'];
        try {
            if (responseWrapper != null) {
                ApplKyc__c updateRec = new ApplKyc__c();
                updateRec.id = integrationMessage.ParentRefId__c;

                updateRec.ValidationStatus__c = Globalconstants.MSG_SUCCESS;
                updateRec.validated__c = true;

                if (!String.isBlank(responseWrapper.result.validated_data.full_name)) {
                    updateRec.NameInAdhr__c = responseWrapper.result.validated_data.full_name;
                    updateRec.Name__c = responseWrapper.result.validated_data.full_name;
                }
                if (!String.isBlank(responseWrapper.result.validated_data.aadhaar_number )) {
                    updateRec.AadharNo__c = responseWrapper.result.validated_data.aadhaar_number;
                }
                if (!String.isBlank(responseWrapper.result.validated_data.dob)) {
                    List<String> dob = responseWrapper.result.validated_data.dob.split('-');
                    if (dob != null && dob.size() >= 2) {
                        updateRec.DtOfBirth__c = Date.newInstance(Integer.valueof(dob[0]),Integer.valueof(dob[1]),Integer.valueof(dob[2]) );
                    }
                }
                if (!String.isBlank(responseWrapper.result.validated_data.gender)) {
                    updateRec.Gender__c = responseWrapper.result.validated_data.gender;
                }
                if (!String.isBlank(responseWrapper.result.validated_data.address.country)) {
                    updateRec.Country__c = responseWrapper.result.validated_data.address.country;
                }
                if (!String.isBlank(responseWrapper.result.validated_data.address.dist)) {
                    updateRec.District__c = responseWrapper.result.validated_data.address.dist;
                }
                if (!String.isBlank(responseWrapper.result.validated_data.address.state ) ) {
                    updateRec.State__c = responseWrapper.result.validated_data.address.state;
                }
                if (!String.isBlank(responseWrapper.result.validated_data.address.street)) {
                    updateRec.Street__c = responseWrapper.result.validated_data.address.street;
                    updateRec.AddrLine1__c = responseWrapper.result.validated_data.address.street;
                }
                if (!String.isBlank(responseWrapper.result.validated_data.address.loc)) {
                    updateRec.AddrLine2__c = responseWrapper.result.validated_data.address.loc;
                }
                if (!String.isBlank(responseWrapper.result.validated_data.address.subdist)) {
                    updateRec.SubDistrict__c = responseWrapper.result.validated_data.address.subdist;
                }
                if (!String.isBlank(responseWrapper.result.validated_data.address.vtc)) {
                    updateRec.VillageTownCity__c = responseWrapper.result.validated_data.address.vtc;
                }
                if (!String.isBlank(responseWrapper.result.validated_data.address.house)) {
                    updateRec.HouseNo__c = responseWrapper.result.validated_data.address.house;
                }
                if (!String.isBlank(responseWrapper.result.validated_data.address.landmark)) {
                    updateRec.Landmark__c = responseWrapper.result.validated_data.address.landmark;
                }
                if (!String.isBlank(responseWrapper.result.validated_data.zip)) {
                    updateRec.Pincode__c = responseWrapper.result.validated_data.zip;
                }
				
                updateRec.DOBValidationStatus__c = (appKyc[0].DtOfBirth__c!=null || updateRec.DtOfBirth__c!=null) ? Globalconstants.MSG_SUCCESS : GlobalConstants.MSG_FAILURE;
                
                if (updateRec != null) {
                    List<string> fieldNamesList = new List<string>{'ValidationStatus__c','validated__c','NameInAdhr__c','Name__c',
                                                                   'AadharEncripted__c','DtOfBirth__c','Gender__c','Country__c',
                                                                   'District__c','State__c','Street__c','HouseNo__c','Landmark__c',
                                                                   'Pincode__c','AddrLine1__c','AddrLine2__c',
                                                                    'SubDistrict__c','VillageTownCity__c','DOBValidationStatus__c'};
                    String sObjectName = 'ApplKyc__c';
                    Schema.SObjectType objType = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType, fieldNamesList);
                    uow.registerDirty(updateRec);
                }
            }
        } catch (exception ex) {
            system.debug('error message and line number ' +ex.getMessage() +'line' +ex.getLineNumber() );
        }
        uow.commitWork();
        
        if (integrationMessage.Trigger_Platform_Event__c) {
            publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
            platformWra.intId = integrationMessage.Id;
            platformWra.recId = integrationMessage.ParentRefId__c;
            platformWra.ServiceName = integrationMessage.Svc__c;
            platformWra.Status = integrationMessage.Status__c;
            platformWra.success = true;
            publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra );
        }
        APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id, integrationMessage.Svc__c,integrationMessage.RefId__c,'Success');
        if (!docDtl.isEmpty()) {
            ApplicantUpdate au = new ApplicantUpdate();
            au.Afterinsert(docDtl);
        }
    }

    public static void updateApplicantKYCError(IntgMsg__c integrationMessage,string errorMessage ) {
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType>{ ApplKyc__c.SObjectType });
        try {
            if (integrationMessage != null) {
                ApplKyc__c AppKyc = new ApplKyc__c();
                AppKyc.Id = integrationMessage.ParentRefId__c;
                AppKyc.ValidationStatus__c = GlobalConstants.MSG_FAILURE;
                AppKyc.DOBValidationStatus__c = GlobalConstants.MSG_FAILURE;
                AppKyc.Validation_Error_Message__c = errorMessage;

                if (AppKyc != null) {
                    List<string> fieldNamesList = new List<string>{'ValidationStatus__c','Validation_Error_Message__c'};
                    String sObjectName = 'ApplKyc__c';
                    Schema.SObjectType objType = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType, fieldNamesList);
                    uow.registerDirty(AppKyc);
                }
            }
        } catch (exception ex) {
            system.debug('error message and line number ' + ex.getMessage() + 'line' + ex.getLineNumber());
        }
        uow.commitWork();
        if (integrationMessage.Trigger_Platform_Event__c) {
            publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
            platformWra.intId = integrationMessage.Id;
            platformWra.recId = integrationMessage.ParentRefId__c;
            platformWra.ServiceName = integrationMessage.Svc__c;
            platformWra.Status = integrationMessage.Status__c;
            platformWra.errorMessage = errorMessage;
            publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
        }
        APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c,integrationMessage.RefId__c,'Failure');
    }
}