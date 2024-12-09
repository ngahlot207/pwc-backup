public class IntOCRAhdarServiceResponseProcessor implements IintMsgCalloutResponseProcessor {
    //Implementing the process method
    public static void process(List<IntgMsg__c> responses) {
        Map<id, string> ApplicantkycMap = new Map<id, string>();
        set<id> applicantkycid = new Set<id>();
        //List<IntgMsg__c> createRequestList = new List<IntgMsg__c>();
        //Processing all responses
        for (IntgMsg__c integrationMessage : responses) {
            if (
                integrationMessage.Svc__c !=
                GlobalConstants.INT_CONFIG_SERVICE_KYC_OCR &&
                integrationMessage.BU__c != GlobalConstants.INT_MSG_BU_TYPE
            ) {
                throw new processException(
                    'Error! This is not the correct service'
                );
            }
            if (integrationMessage.ParentRefId__c != null){
                applicantkycid.add(integrationMessage.ParentRefId__c);
            }
            /*
            IntgMsg__c intmsg =new IntgMsg__c();
            intmsg.Name='SFDC Aadhar Masking';
            intmsg.BU__c='HL / STL';
            intmsg.Status__c='New';
            intmsg.MStatus__c='Blank';
            intmsg.RefId__c=integrationMessage.RefId__c;
            intmsg.RefObj__c=integrationMessage.RefObj__c;
            intmsg.ParentRefId__c=integrationMessage.ParentRefId__c;
            intmsg.ParentRefObj__c=integrationMessage.ParentRefObj__c;
            intmsg.Svc__c='SFDC Aadhar Masking';
            intmsg.IsActive__c=true;
            intmsg.Trigger_Platform_Event__c=true;
            createRequestList.add(intmsg);
			*/
        }
        /*if(!createRequestList.isEmpty()){
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> { IntgMsg__c.SObjectType});
            List<string> fieldNamesList = New List<string>{'Name','BU__c','RefId__c','Status__c','MStatus__c','RefObj__c','Svc__c','ApiVendor__c',
                'IsActive__c','ParentRefId__c','ParentRefObj__c'};
                    String sObjectName = 'IntgMsg__c';
            Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
            fflib_SecurityUtils.checkInsert(objType,fieldNamesList); 
            uow.registerNew(createRequestList);
            uow.commitWork();
        }*/
        if (applicantkycid.size() > 0) {
            CheckValidOCR(applicantkycid, responses);
        }
    }

    public static void CheckValidOCR(
        set<id> kycid,
        List<IntgMsg__c> responses
    ) {
        Map<Id, ApplKyc__c> applKycMap;
        IntOCRAdharServiceResponseWrapper responseWrapper;
        if (kycid.size() > 0) {
            applKycMap = new Map<Id, ApplKyc__c>(
                [SELECT Id, kycDoc__c FROM ApplKyc__c WHERE Id IN :kycid]
            );
        }
        if (!responses.isEmpty()) {
            //responseWrapper = (IntOCRAdharServiceResponseWrapper) JSON.deserialize(responses[0].Resp__c, IntOCRAdharServiceResponseWrapper.class);
            processResponse(responses);
        }

        /*if(responseWrapper.result[0].type.contains('Aadhaar'))//applKycMap.get(responses[0].ParentRefId__c).kycDoc__c))
        {
            processResponse(responses);
        }
        else
        {
            updateApplicantKYCRecordError(responseWrapper,responses[0].ParentRefId__c,GlobalConstants.General_Message_KYCOCR,responses);
        }*/
    }

    public static void processResponse(List<IntgMsg__c> responses) {
        if (!responses.isEmpty()) {
            try {
                //parse response
                IntOCRAdharServiceResponseWrapper responseWrapper = (IntOCRAdharServiceResponseWrapper) JSON.deserialize(
                    responses[0].Resp__c,
                    IntOCRAdharServiceResponseWrapper.class
                );

                //check if responseWrapper is empty or not
                if (responseWrapper != null) {
                    if (responseWrapper.statusCode != null) {
                        if (                            responseWrapper.statusCode == GlobalConstants.karza_Status_101) {
                            if (responseWrapper.result[0].type.contains('Aadhaar')
                            ) {
                                updateApplicantKYC(
                                    responseWrapper,
                                    responses[0].ParentRefId__c,
                                    responses,
                                    responses[0]
                                );
                            } else {
                                updateApplicantKYCRecordError(
                                    responseWrapper,
                                    responses[0].ParentRefId__c,
                                    GlobalConstants.General_Message_KYCOCR,
                                    responses,
                                    responses[0]
                                );
                            }
                        }
                        if (
                            responseWrapper.statusCode !=
                            GlobalConstants.karza_Status_101
                        ) {
                            updateApplicantKYCRecordError(
                                responseWrapper,
                                responses[0].ParentRefId__c,
                                '',
                                responses,
                                responses[0]
                            );
                        }
                    } else {
                        string errorMessage = KarzaErrorResponseController.getErrorMessage(
                            responses[0]
                        );
                        updateApplicantKYCRecordError(
                            responseWrapper,
                            responses[0].ParentRefId__c,
                            errorMessage,
                            responses,
                            responses[0]
                        );
                    }
                    //   publishpaltformevent(responseWrapper,responses);
                }
            }
            //Exception Handling
            catch (Exception ex) {
                system.debug('ex--->'+ex);
                GlobalUtility.logMessage(
                    'Error',
                    'IntOCRAhdarServiceResponseProcessor class',
                    'Process',
                    null,
                    null,
                    ex.getMessage() + ' line ' + ex.getLineNumber(),
                    null,
                    ex,
                    null
                );
            }
        }
    }

    public static void updateApplicantKYC(
        IntOCRAdharServiceResponseWrapper responseWrapper,
        Id referenceId,
        List<IntgMsg__c> responses,
        IntgMsg__c integrationMessage
    ) {
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new List<SObjectType>{ ApplKyc__c.SObjectType }
        );
		
        List<string> fieldNamesList = new List<string>{
            'OCRStatus__c',
            'kycDoc__c',
            'AadharEncripted__c',
            'AdhrVer__c',
            'NameInAdhr__c',
            'AdhrAdd__c',
            'AddrLine1__c',
            'AddrLine2__c',
            'City__c',
            'Country__c',
            'State__c',
            'Pincode__c',
            'DtOfBirth__c',
            'FatherName__c',
            'HusbandName__c',
            'Gender__c',
            'District__c',
            'Locality__c',
            'Landmark__c',
            'Street__c',
            'HouseNo__c',
            'Name__c'
        };

        String sObjectName = 'ApplKyc__c';
        Schema.SObjectType objType = Schema.getGlobalDescribe()
            .get(sObjectName);
        fflib_SecurityUtils.checkUpdate(objType, fieldNamesList);

        ApplKyc__c AppKyc = new ApplKyc__c();
        string wrapperdata = JSON.serialize(responseWrapper);
        system.debug('wrapperdata==>' + wrapperdata);
        system.debug('responseWrapper in method==>' + responseWrapper);
        AppKyc.Id = referenceId;

        if (!responseWrapper.result.isEmpty()) {
            for (
                IntOCRAdharServiceResponseWrapper.Result result : responseWrapper.result
            ) {
                if (result.type == 'Aadhaar Front Bottom') {
                    if (
                        (!String.isBlank(result.details.aadhaar.value)) &&
                        result.details.aadhaar.value.length() == 12
                    ) {
                        AppKyc.AadharEncripted__c = result.details.aadhaar.value;
                        AppKyc.AadharNo__c =
                            'X'.repeat(8) +
                            result.details.aadhaar.value.substring(8);
                    }
                    if (!String.isBlank(result.details.dob.value)) {
                        List<String> dob = result.details.dob.value.split('/');
                        if (dob != null && dob.size() >= 2) {
                            if (
                                dob[0].isNumeric() &&
                                dob[1].isNumeric() &&
                                dob[2].isNumeric()
                            ) {
                                AppKyc.DtOfBirth__c = Date.newInstance(
                                    Integer.valueof(dob[2]),
                                    Integer.valueof(dob[1]),
                                    Integer.valueof(dob[0])
                                );
                            }
                        }
                    }
                    if (!String.isBlank(result.details.father.value)) {
                        AppKyc.FatherName__c = result.details.father.value;
                    }
                    if (!String.isBlank(result.details.gender.value)) {
                        AppKyc.Gender__c = result.details.gender.value.toLowerCase() ==
                            'male'
                            ? 'M'
                            : result.details.gender.value.toLowerCase() ==
                                  'female'
                                  ? 'F'
                                  : '';
                    }
                    //if(!String.isBlank(result.details.mother.value)){}
                    if (!String.isBlank(result.details.name.value)) {
                        AppKyc.NameInAdhr__c = result.details.name.value;
                        AppKyc.Name__c = result.details.name.value;
                    }
                }
                if (result.type == 'Aadhaar Front Top') {
                    if (
                        (!String.isBlank(result.details.aadhaar.value)) &&
                        result.details.aadhaar.value.length() == 12
                    ) {
                        AppKyc.AadharEncripted__c = result.details.aadhaar.value;
                        AppKyc.AadharNo__c =
                            'X'.repeat(8) +
                            result.details.aadhaar.value.substring(8);
                    }
                    if (!String.isBlank(result.details.name.value)) {
                        AppKyc.NameInAdhr__c = result.details.name.value;
                        AppKyc.Name__c = result.details.name.value;
                    }
                    if (!String.isBlank(result.details.AddressSplit.city)) {
                        AppKyc.City__c = result.details.AddressSplit.city;
                    }
                    if (!String.isBlank(result.details.AddressSplit.district)) {
                        AppKyc.District__c = result.details.AddressSplit.district;
                    }
                    if (!String.isBlank(result.details.AddressSplit.pin)) {
                        AppKyc.Pincode__c = result.details.AddressSplit.pin;
                    }
                    if (!String.isBlank(result.details.AddressSplit.locality)) {
                        AppKyc.Locality__c = result.details.AddressSplit.locality;
                    }
                    if (!String.isBlank(result.details.AddressSplit.line1)) {
                        AppKyc.AddrLine1__c = result.details.AddressSplit.line1;
                    }
                    if (!String.isBlank(result.details.AddressSplit.line2)) {
                        AppKyc.AddrLine2__c = result.details.AddressSplit.line2;
                    }
                    if (!String.isBlank(result.details.AddressSplit.state)) {
                        AppKyc.State__c = result.details.AddressSplit.state;
                    }
                    if (!String.isBlank(result.details.AddressSplit.street)) {
                        AppKyc.Street__c = result.details.AddressSplit.street;
                    }
                    if (!String.isBlank(result.details.AddressSplit.landmark)) {
                        AppKyc.Landmark__c = result.details.AddressSplit.landmark;
                    }
                    if (
                        !String.isBlank(result.details.AddressSplit.houseNumber)
                    ) {
                        AppKyc.HouseNo__c = result.details.AddressSplit.houseNumber;
                    }
                    if (!String.isBlank(result.details.address.value)) {
                        AppKyc.AdhrAdd__c = result.details.address.value;
                        AppKyc.Address__c = result.details.address.value;
                    }
                    if (!String.isBlank(result.details.father.value)) {
                        AppKyc.FatherName__c = result.details.father.value;
                    }
                    if (!String.isBlank(result.details.husband.value)) {
                        AppKyc.HusbandName__c = result.details.husband.value;
                    }
                }
                if (result.type == 'Aadhaar Back') {
                    if (!String.isBlank(result.details.AddressSplit.city)) {
                        AppKyc.City__c = result.details.AddressSplit.city;
                    }
                    if (!String.isBlank(result.details.AddressSplit.district)) {
                        AppKyc.District__c = result.details.AddressSplit.district;
                    }
                    if (!String.isBlank(result.details.AddressSplit.pin)) {
                        AppKyc.Pincode__c = result.details.AddressSplit.pin;
                    }
                    if (!String.isBlank(result.details.AddressSplit.locality)) {
                        AppKyc.Locality__c = result.details.AddressSplit.locality;
                    }
                    if (!String.isBlank(result.details.AddressSplit.line1)) {
                        AppKyc.AddrLine1__c = result.details.AddressSplit.line1;
                    }
                    if (!String.isBlank(result.details.AddressSplit.line2)) {
                        AppKyc.AddrLine2__c = result.details.AddressSplit.line2;
                    }
                    if (!String.isBlank(result.details.AddressSplit.state)) {
                        AppKyc.State__c = result.details.AddressSplit.state;
                    }
                    if (!String.isBlank(result.details.AddressSplit.street)) {
                        AppKyc.Street__c = result.details.AddressSplit.street;
                    }
                    if (!String.isBlank(result.details.AddressSplit.landmark)) {
                        AppKyc.Landmark__c = result.details.AddressSplit.landmark;
                    }
                    if (
                        !String.isBlank(result.details.AddressSplit.houseNumber)
                    ) {
                        AppKyc.HouseNo__c = result.details.AddressSplit.houseNumber;
                    }
                    if (!String.isBlank(result.details.address.value)) {
                        AppKyc.AdhrAdd__c = result.details.address.value;
                        AppKyc.Address__c = result.details.address.value;
                    }
                    if (!String.isBlank(result.details.father.value)) {
                        AppKyc.FatherName__c = result.details.father.value;
                    }
                    if (!String.isBlank(result.details.husband.value)) {
                        AppKyc.HusbandName__c = result.details.husband.value;
                    }
                }
            }
        }

        AppKyc.Country__c = 'India';
        AppKyc.AdhrVer__c = true;
        AppKyc.OCRStatus__c = GlobalConstants.MSG_SUCCESS;
        uow.registerDirty(AppKyc);
        publishpaltformevent(responseWrapper, '', responses);
        //insert updateApplicantAddress;
        uow.commitWork();
        
        APICalloutTracker.update_ApiTrackerWithIntMsg(
            integrationMessage.Id,
            integrationMessage.Svc__c,
            integrationMessage.RefId__c,
            'Success'
        );
    }

    public static void updateApplicantKYCRecordError(
        IntOCRAdharServiceResponseWrapper responseWrapper,
        Id referenceId,
        String errormessage,
        List<IntgMsg__c> responses,
        IntgMsg__c integrationMessage
    ) {
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new List<SObjectType>{ ApplKyc__c.SObjectType }
        );
        try {
            if (responseWrapper != null) {
                ApplKyc__c AppKyc = new ApplKyc__c();
                AppKyc.Id = referenceId;
                AppKyc.OCRStatus__c = GlobalConstants.MSG_FAILURE;
                if (errormessage == '') {
                    AppKyc.OCR_Error_Message__c = GlobalConstants.karza_Status_Code_OCR_Description.containsKey(
                            responseWrapper.statusCode
                        )
                        ? GlobalConstants.karza_Status_Code_OCR_Description.get(
                              responseWrapper.statusCode
                          )
                        : '';
                } else {
                    AppKyc.OCR_Error_Message__c = errormessage;
                }
                publishpaltformevent(responseWrapper, errormessage, responses);
                if (AppKyc != null) {
                    List<string> fieldNamesList = new List<string>{
                        'OCRStatus__c',
                        'OCR_Error_Message__c'
                    };
                    String sObjectName = 'ApplKyc__c';
                    Schema.SObjectType objType = Schema.getGlobalDescribe()
                        .get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType, fieldNamesList);
                    uow.registerDirty(AppKyc);
                }
            }
        } catch (exception ex) {
            system.debug(
                'error message and line number ' +
                    ex.getMessage() +
                    'line' +
                    ex.getLineNumber()
            );
        }
        uow.commitWork();
        APICalloutTracker.update_ApiTrackerWithIntMsg(
            integrationMessage.Id,
            integrationMessage.Svc__c,
            integrationMessage.RefId__c,
            'Failure'
        );
    }

    public static void publishpaltformevent(
        IntOCRAdharServiceResponseWrapper responseWrapper,
        string errormessage,
        List<IntgMsg__c> responses
    ) {
        if (responses[0].Trigger_Platform_Event__c) {
            publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
            platformWra.intId = responses[0].Id;
            platformWra.recId = responses[0].ParentRefId__c;
            platformWra.ServiceName = responses[0].Svc__c;
            platformWra.Status = responses[0].Status__c;

            if (
                responseWrapper.statusCode == GlobalConstants.karza_Status_101
            ) {
                platformWra.success = true;
            }
            if (
                responseWrapper.statusCode !=
                GlobalConstants.karza_Status_101 &&
                errormessage == ''
            ) {
                platformWra.errorMessage = GlobalConstants.karza_Status_Code_OCR_Description.containsKey(
                        responseWrapper.statusCode
                    )
                    ? GlobalConstants.karza_Status_Code_OCR_Description.get(
                          responseWrapper.statusCode
                      )
                    : '';
                platformWra.success = false;
            }
            if (errormessage != '') {
                platformWra.errorMessage = errormessage;
                platformWra.success = false;
            }

            publishPlatFormeventControllerClass.publishPlatFormeventmethod(
                platformWra
            );
        }
    }
}