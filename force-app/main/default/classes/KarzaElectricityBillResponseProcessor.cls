public class KarzaElectricityBillResponseProcessor implements IintMsgCalloutResponseProcessor {
    public static void process(List<IntgMsg__c> responses) {
        try {

            Set<Id> ids = new Set<Id>();
           
            
            for(IntgMsg__c integrationMessage : responses) {
                ids.add(integrationMessage.ParentRefId__c);
            }
            Map<Id,ApplKyc__c> applKycMap = new Map<Id,ApplKyc__c>([SELECT Id, Applicant__c, kycDoc__c FROM ApplKyc__c WHERE Id IN : ids AND kycDoc__c = 'Electricity Bill']);
            for(IntgMsg__c integrationMessage : responses) {
                if(integrationMessage.Svc__c != GlobalConstants.INT_CONFIG_SERVICE_ELECTRICITY_BILL_AUTHENTICATION) {
                    throw new processException('Error! This is not the correct service'); 
                }

                //parse response
                String jsonResp = integrationMessage.Resp__c != NULL ? integrationMessage.Resp__c.replace('status-code' , 'statusCode') : '';
                KarzaElectricityBillResponseWrapper responseWrapper = String.isNotBlank(jsonResp) ? (KarzaElectricityBillResponseWrapper)JSON.deserialize(jsonResp, KarzaElectricityBillResponseWrapper.class) : NULL;

                if(responseWrapper != NULL) {
                    if(responseWrapper.statusCode == String.valueOf(GlobalConstants.karza_Status_101)) {
                        updateApplicantKYCDetials(responseWrapper, integrationMessage.ParentRefId__c, integrationMessage);
                    }
                    if(responseWrapper.statusCode != String.valueOf(GlobalConstants.karza_Status_101)) {
                        updateApplicantKYCError(responseWrapper, integrationMessage);
                    }

                    if(integrationMessage.Trigger_Platform_Event__c) {
                        publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                        platformWra.intId = integrationMessage.Id; 
                        platformWra.recId = integrationMessage.ParentRefId__c;
                        platformWra.ServiceName = integrationMessage.Svc__c ;
                        platformWra.Status = integrationMessage.Status__c ;
                        
                        if(responseWrapper.statusCode != NULL) {
                            if(responseWrapper.statusCode == String.valueOf(GlobalConstants.karza_Status_101)){
                                platformWra.success = TRUE;
                            }
                            if(responseWrapper.statusCode != String.valueOf(GlobalConstants.karza_Status_101)) {
                                platformWra.errorMessage = GlobalConstants.karza_Status_Code_Authn_Description.containsKey(Integer.valueOf(responseWrapper.statusCode)) ? GlobalConstants.karza_Status_Code_Authn_Description.get(Integer.valueOf(responseWrapper.statusCode)) : '';
                            }
                        }
                        else {
                            platformWra.errorMessage = KarzaErrorResponseController.getErrorMessage(integrationMessage);
                        }
                        publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
                    }
                }
            }
        }
        catch(Exception ex) {
            System.debug('error' + ex.getMessage());
            GlobalUtility.logMessage('Error', 'KarzaElectricityBillResponseProcessor', 
                                     'Process', NULL, NULL, ex.getMessage() + ' line ' + ex.getLineNumber(), NULL, ex, NULL);
        } 
    } 

    //Handle error response
    public static void updateApplicantKYCError(KarzaElectricityBillResponseWrapper responseWrapper, IntgMsg__c integrationMessage) {
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { ApplKyc__c.SObjectType });
        try {
            if(responseWrapper != NULL) {
                ApplKyc__c AppKyc = new ApplKyc__c();
                AppKyc.Id = integrationMessage.ParentRefId__c;
                AppKyc.ValidationStatus__c = GlobalConstants.MSG_FAILURE;

                if(responseWrapper.statusCode != NULL) {
                    AppKyc.Validation_Error_Message__c = GlobalConstants.karza_Status_Code_Authn_Description.containsKey(Integer.valueOf(responseWrapper.statusCode)) ? GlobalConstants.karza_Status_Code_Authn_Description.get(Integer.valueOf(responseWrapper.statusCode)) : '';
                }
                else {
                    AppKyc.Validation_Error_Message__c = KarzaErrorResponseController.getErrorMessage(integrationMessage);
                }

                if(AppKyc != NULL) {
                    List<String> fieldNamesList = new List<String>{'ValidationStatus__c', 'Validation_Error_Message__c'};
                    String sObjectName = 'ApplKyc__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType, fieldNamesList);
                    uow.registerDirty(AppKyc);
                }

                uow.commitWork();
                APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Failure');
            }
        }
        catch(Exception ex) {
            System.debug('error' + ex.getMessage());
            GlobalUtility.logMessage('Error', 'KarzaElectricityBillResponseProcessor', 
                                     'updateApplicantKYCError', NULL, NULL, ex.getMessage() + ' line ' + ex.getLineNumber(), NULL, ex, NULL);
        }
    }

    //Update Applicant Kyc Record with response processor data
    public static void updateApplicantKYCDetials(KarzaElectricityBillResponseWrapper responseWrapper, Id parentReferenceId, IntgMsg__c integrationMessage) {
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> { ApplKyc__c.SObjectType, IntgMsg__c.SObjectType });
        try {
            List<ApplKyc__c> appKycList = new List<ApplKyc__c>();
            List<IntgMsg__c> intMsgRecsToInsert = new List<IntgMsg__c>();
            if(responseWrapper != NULL) {
                ApplKyc__c updateAppKyc = new ApplKyc__c();
                updateAppKyc.Id = parentReferenceId ?? NULL;
                updateAppKyc.Address__c = responseWrapper.result.address ?? '';
                updateAppKyc.ElectBillNo__c = responseWrapper.result.bill_no ?? '';
                updateAppKyc.ElectConsrName__c = responseWrapper.result.consumer_name ?? '';
                updateAppKyc.Name__c = responseWrapper.result.consumer_name ?? '';
                updateAppKyc.ElectAmtPayable__c = responseWrapper.result.amount_payable ?? '';
                updateAppKyc.ElectBillAmt__c = responseWrapper.result.bill_amount ?? '';
                updateAppKyc.Email__c = responseWrapper.result.email_address ?? '';
                updateAppKyc.MobileNo__c = responseWrapper.result.mobile_number ?? '';
                updateAppKyc.ElectTotAmt__c = responseWrapper.result.total_amount ?? '';
                updateAppKyc.AdrsSplitStatus__c = String.isNotBlank(responseWrapper.result.address) ? 'In progress' : NULL;
                updateAppKyc.ValidationStatus__c = GlobalConstants.MSG_SUCCESS;
                updateAppKyc.Validation_Error_Message__c = NULL;
                
                if(parentReferenceId != NULL) {
                    appKycList.add(updateAppKyc);
                }
                
                if(String.isNotBlank(responseWrapper.result.address) && parentReferenceId != NULL) {
                    IntgMsg__c intMsgRec = new IntgMsg__c();
                    intMsgRec.Name = 'Address Split';
                    intMsgRec.BU__c = 'HL / STL';
                    intMsgRec.Status__c = GlobalConstants.INT_MSG_STATUS_NEW;
                    intMsgRec.MStatus__c = GlobalConstants.INT_MSG_MStatus_BLANK;
                    intMsgRec.Svc__c = 'Address Split';
                    intMsgRec.RefId__c = integrationMessage.RefId__c;
                    intMsgRec.RefObj__c = 'DocDtl__c';
                    intMsgRec.ParentRefId__c = parentReferenceId;
                    intMsgRec.ParentRefObj__c = 'ApplKyc__c';
                    intMsgRec.IsActive__c = TRUE;
                    intMsgRecsToInsert.add(intMsgRec);
                    APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Success');
                }
                else{
                    APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Failure');
                }
            }

            if(!appKycList.isEmpty()) {
                List<string> fieldNamesList = New List<string>{'Name__c','Address__c', 'ElectBillNo__c', 'ElectConsrName__c', 'AdrsSplitStatus__c', 'ValidationStatus__c', 'Validation_Error_Message__c'};
                String sObjectName = 'ApplKyc__c';
                Schema.SObjectType objType = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                uow.registerDirty(appKycList);
                uow.commitWork();
            }
			
            if(!intMsgRecsToInsert.isEmpty()) {
                List<string> fieldNamesList = New List<string>{ 'Name', 'BU__c', 'Status__c', 'MStatus__c', 'Svc__c', 'RefId__c', 'RefObj__c', 'IsActive__c' };
                String sObjectName = 'IntgMsg__c';
                Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkInsert(objType,fieldNamesList);
                uow.registerNew(intMsgRecsToInsert);
                uow.commitWork();
            }
            //Calling Trigger for name similarity
            if(string.isNotblank(integrationMessage.RefId__c)){
                
                List<DocDtl__c> doc=[Select id,Applicant_KYC__c,DocCatgry__c,DocTyp__c,DocSubTyp__c,Applicant_KYC__r.Applicant__r.LoanAppln__c,
                                     Applicant_KYC__r.Applicant__c,Applicant_KYC__r.ValidationStatus__c,Applicant_KYC__r.OCRStatus__c,
                                     Applicant_KYC__r.AdrsSplitStatus__c,Applicant_KYC__r.AddrLine1__c,Applicant_KYC__r.AddrLine2__c,
                                     Applicant_KYC__r.Landmark__c,Applicant_KYC__r.Locality__c,Applicant_KYC__r.HouseNo__c,
                                     Applicant_KYC__r.Country__c,Applicant_KYC__r.Pincode__c,Applicant_KYC__r.City__c,
                                     Applicant_KYC__r.State__c from DocDtl__c where Id =:integrationMessage.RefId__c];
                if(!doc.isEmpty()){
                    ApplicantUpdate au = new ApplicantUpdate();
                    au.Afterinsert(doc);
                }
            }
            
            APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Success');
        }
        catch(Exception ex) {
            System.debug('error' + ex.getMessage());
            GlobalUtility.logMessage('Error', 'KarzaElectricityBillResponseProcessor', 
                                     'updateApplicantKYCDetials', NULL, NULL, ex.getMessage() + ' line ' + ex.getLineNumber(), NULL, ex, NULL);
        }
    }
}