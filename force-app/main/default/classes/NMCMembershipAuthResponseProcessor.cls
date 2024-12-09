public class NMCMembershipAuthResponseProcessor implements IintMsgCalloutResponseProcessor{
    
    public static void process(List<IntgMsg__c> responses){ 
        
        Map<IntgMsg__c,NMCMembershipAuthResponseWrapper> successResponseMap = new Map<IntgMsg__c,NMCMembershipAuthResponseWrapper>();
        Map<IntgMsg__c,String> failureResponseMap = new Map<IntgMsg__c,String>();
        Set<Id> refIds = new Set<Id>();
        
        for(IntgMsg__c integrationMessage : responses){
            
            try{
                
                NMCMembershipAuthResponseWrapper response = (NMCMembershipAuthResponseWrapper) JSON.deserialize(integrationMessage.Resp__c, NMCMembershipAuthResponseWrapper.class);
                refIds.add(integrationMessage.RefId__c);
                if(response!=null){
                    if(response.statusCode!=null){
                        if(Integer.valueOf(response.statusCode) == GlobalConstants.karza_Status_101){
                            successResponseMap.put(integrationMessage,response);
                        }
                        else{
                            failureResponseMap.put(integrationMessage,GlobalConstants.karza_Status_Code_Authn_Description.containsKey(Integer.valueOf(response.statusCode))?GlobalConstants.karza_Status_Code_Authn_Description.get(Integer.valueOf(response.statusCode)):'');
                        }
                    }
                    else if(response.status!=null){
                        failureResponseMap.put(integrationMessage,(response.error!=null && String.isNotBlank(response.error) ? response.error : ''));
                    }
                }
                
            }
            catch(Exception ex){
                
                failureResponseMap.put(integrationMessage,IntegrationUtility.getCustomErrorMessage(ex.getMessage().substringBefore(':')));
                GlobalUtility.logMessage('Error', 'CAMembershipAuthResponseProcessor class', 
                                         'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
                
            }
        }
        
        Map<Id,Applicant__c> applicantMap = new Map<Id,Applicant__c> ([SELECT id,Name,Gender__c,LoanAppln__c,ApplType__c,FullName__c,Constitution__c,CompanyName__c FROM Applicant__c WHERE ID IN:refIds]);
        
        if(!successResponseMap.isEmpty()){
            processSuccess(applicantMap,successResponseMap);
        }
        if(!failureResponseMap.isEmpty()){
            processFailure(applicantMap,failureResponseMap);
        }
    }
    
    public static void processSuccess(Map<Id,Applicant__c> applicantMap,Map<IntgMsg__c,NMCMembershipAuthResponseWrapper> successResponses){
        
        try{
            
            if(!successResponses.isEmpty()){
                Id qualificationCheckRecordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByDeveloperName().get('QualificationCheck').getRecordTypeId();
                set<Id> existingApplicantIds = new set<Id>();
                List<APIVer__c> apiVerList = new List<APIVer__c>();
                Map<Id,Applicant__c> updateApplicantMap = new Map<Id,Applicant__c>();
                
                Map<String,List<APIVerDtl__c>> apiVerDtlMap = new Map<String,List<APIVerDtl__c>>();
                for(IntgMsg__c integrationMessage : successResponses.keySet()){
                    
                    NMCMembershipAuthResponseWrapper response = successResponses.get(integrationMessage);
                    if(response!=null && response.result!=null){
                        
                        if(applicantMap.containsKey(integrationMessage.RefId__c)){
                            
                            existingApplicantIds.add(integrationMessage.RefId__c);
                            
                            Applicant__c app =new Applicant__c();
                            app.Id=integrationMessage.RefId__c;
                            app.DoctorApiVerStatus__c = 'Verified';
                            updateApplicantMap.put(app.Id,app);
                            
                            APIVer__c apiVer = new APIVer__c();
                            apiVer.Prof_Qualification_Check__c = 'Doctor\'s Registration no Check';
                            apiVer.IntegrationStatus__c = GlobalConstants.MSG_SUCCESS;
                            apiVer.IsLatest__c = True;
                            apiVer.RecordTypeId = qualificationCheckRecordTypeId;
                            
                            apiVer.Appl__c = applicantMap.get(integrationMessage.RefId__c).Id ;
                            apiVer.LoanAplcn__c = applicantMap.get(integrationMessage.RefId__c).LoanAppln__c ;  
                            apiVer.ApplNme__c = applicantMap.get(integrationMessage.RefId__c).FullName__c ;  
                            apiVer.ApplTyp__c = applicantMap.get(integrationMessage.RefId__c).ApplType__c ;  
                            
                            
                            if(response.result.doctorId!=null && String.isNotBlank(response.result.doctorId)){
                                apiVer.DoctorId__c = response.result.doctorId;
                            }
                            if(response.result.additionalAddresses!=null && String.isNotBlank(response.result.additionalAddresses)){
                                apiVer.AdditionalAddr__c = response.result.additionalAddresses;
                            }
                            if(response.result.additionalQualifications!=null && !response.result.additionalQualifications.isEmpty()){
                                for(NMCMembershipAuthResponseWrapper.AdditionalQualifications additionalQualification : response.result.additionalQualifications){
                                    APIVerDtl__c apiVerDtl = new APIVerDtl__c();
                                    apiVerDtl.Type__c = 'Additional Qualifications';
                                    if(additionalQualification.qualification!=null && String.isNotBlank(additionalQualification.qualification)){
                                        apiVerDtl.Qualification__c = additionalQualification.qualification;
                                    }
                                    if(additionalQualification.qualificationYear!=null && String.isNotBlank(additionalQualification.qualificationYear)){
                                        apiVerDtl.QualificationYear__c = additionalQualification.qualificationYear;
                                    }
                                    if(additionalQualification.university!=null && String.isNotBlank(additionalQualification.university)){
                                        apiVerDtl.University__c = additionalQualification.university;
                                    }
                                    if(additionalQualification.college!=null && String.isNotBlank(additionalQualification.college)){
                                        apiVerDtl.College__c = additionalQualification.college;
                                    }
                                    
                                    if(apiVerDtlMap.containsKey(applicantMap.get(integrationMessage.RefId__c).Id)){
                                        apiVerDtlMap.get(applicantMap.get(integrationMessage.RefId__c).Id).add(apiVerDtl);
                                    }
                                    else{
                                        apiVerDtlMap.put(applicantMap.get(integrationMessage.RefId__c).Id,new List<APIVerDtl__c>{apiVerDtl});
                                    }
                                }
                            }
                            if(response.result.address!=null && String.isNotBlank(response.result.address)){
                                apiVer.Address__c = response.result.address;
                            }
                            if(response.result.category!=null && String.isNotBlank(response.result.category)){
                                apiVer.Category__c = response.result.category;
                            }
                            if(response.result.dateOfBirth!=null && String.isNotBlank(response.result.dateOfBirth)){
                                List<String> dateOfBirthList = response.result.dateOfBirth.split('-');
                                if(dateOfBirthList!=null && !dateOfBirthList.isEmpty() && dateOfBirthList.size()>=3){
                                    apiVer.DOB__c = Date.newInstance(Integer.valueof(dateOfBirthList[2]),Integer.valueof(dateOfBirthList[1]),Integer.valueof(dateOfBirthList[0]));
                                }
                            }
                            if(response.result.dateOfRegistration!=null && String.isNotBlank(response.result.dateOfRegistration)){
                                List<String> dateOfRegistrationList = response.result.dateOfRegistration.split('-');
                                if(dateOfRegistrationList!=null && !dateOfRegistrationList.isEmpty() && dateOfRegistrationList.size()>=3){
                                    apiVer.DateOfRegistration__c = Date.newInstance(Integer.valueof(dateOfRegistrationList[2]),Integer.valueof(dateOfRegistrationList[1]),Integer.valueof(dateOfRegistrationList[0]));
                                }
                            }
                            if(response.result.fatherName!=null && String.isNotBlank(response.result.fatherName)){
                                apiVer.FatherName__c = response.result.fatherName;
                            }
                            if(response.result.firstName!=null && String.isNotBlank(response.result.firstName)){
                                apiVer.Fname__c = response.result.firstName;
                            }
                            if(response.result.husbandName!=null && String.isNotBlank(response.result.husbandName)){
                                apiVer.HusbandName__c = response.result.husbandName;
                            }
                            if(response.result.isNewlyRegisteredDoctor!=null){
                                apiVer.IsNewlyRegisteredDoctor__c = response.result.isNewlyRegisteredDoctor;
                            }
                            if(response.result.name!=null && String.isNotBlank(response.result.name)){
                                apiVer.Name__c = response.result.name;
                            }
                            if(response.result.qualification!=null){
                                if(response.result.qualification.qualification!=null && String.isNotBlank(response.result.qualification.qualification)){
                                    apiVer.Qualification__c = response.result.qualification.qualification;
                                }
                                if(response.result.qualification.qualificationYear!=null && String.isNotBlank(response.result.qualification.qualificationYear)){
                                    apiVer.QualificationYear__c = response.result.qualification.qualificationYear;
                                }
                                if(response.result.qualification.university!=null && String.isNotBlank(response.result.qualification.university)){
                                    apiVer.University__c = response.result.qualification.university;
                                }
                                if(response.result.qualification.college!=null && String.isNotBlank(response.result.qualification.college)){
                                    apiVer.College__c = response.result.qualification.college;
                                }
                            }
                            if(response.result.registrationNumber!=null && String.isNotBlank(response.result.registrationNumber)){
                                apiVer.RegistrationNumber__c = response.result.registrationNumber;
                            }
                            if(response.result.removedStatus!=null){
                                apiVer.RemovalStatus__c = response.result.removedStatus;
                            }
                            if(response.result.restoredOn!=null && String.isNotBlank(response.result.restoredOn)){
                                List<String> restoredOnList = response.result.restoredOn.split('-');
                                if(restoredOnList!=null && !restoredOnList.isEmpty() && restoredOnList.size()>=3){
                                    apiVer.RestorationDt__c = Date.newInstance(Integer.valueof(restoredOnList[2]),Integer.valueof(restoredOnList[1]),Integer.valueof(restoredOnList[0]));
                                }
                            }
                            if(response.result.restoredStatus!=null){
                                apiVer.RestorationStatus__c = response.result.restoredStatus;
                            }
                            if(response.result.stateMedicalCouncil!=null && String.isNotBlank(response.result.stateMedicalCouncil)){
                                apiVer.MedicalCouncil__c = response.result.stateMedicalCouncil;
                            }
                            if(response.result.stateMedicalCouncilId!=null && String.isNotBlank(response.result.stateMedicalCouncilId)){
                                apiVer.MedicalCouncilStateId__c = response.result.stateMedicalCouncilId;
                            }
                            if(response.result.uniquePermanentRegistrationNumber!=null && String.isNotBlank(response.result.uniquePermanentRegistrationNumber)){
                                apiVer.PermanentRegistrationNumber__c = response.result.uniquePermanentRegistrationNumber;
                            }
                            if(response.result.yearOfInfo!=null && String.isNotBlank(response.result.yearOfInfo)){
                                apiVer.RegistrationYear__c = response.result.yearOfInfo;
                            }
                            if(response.result.yearOfPassing!=null && String.isNotBlank(response.result.yearOfPassing)){
                                apiVer.PassingYear__c = response.result.yearOfPassing;
                            }
                            if(response.result.isBlacklistedDoctor!=null){
                                apiVer.IsBlacklistedDoctor__c = response.result.isBlacklistedDoctor;
                            }
                            if(response.result.suspensions!=null && !response.result.suspensions.isEmpty()){
                                for(NMCMembershipAuthResponseWrapper.Suspensions suspension : response.result.suspensions){
                                    APIVerDtl__c apiVerDtl = new APIVerDtl__c();
                                    apiVerDtl.Type__c = 'Suspension Details';
                                    
                                    if(suspension.suspensionDate!=null && String.isNotBlank(suspension.suspensionDate)){
                                        List<String> suspensionDateList = suspension.suspensionDate.split('/');
                                        if(suspensionDateList!=null && !suspensionDateList.isEmpty() && suspensionDateList.size()>=3){
                                            apiVerDtl.SuspensionDt__c = Date.newInstance(Integer.valueof(suspensionDateList[2]),Integer.valueof(suspensionDateList[1]),Integer.valueof(suspensionDateList[0]));
                                        }
                                    }
                                    if(suspension.restorationDate!=null && String.isNotBlank(suspension.restorationDate)){
                                        List<String> restorationDateList = suspension.restorationDate.split('/');
                                        if(restorationDateList!=null && !restorationDateList.isEmpty() && restorationDateList.size()>=3){
                                            apiVerDtl.RestorationDt__c = Date.newInstance(Integer.valueof(restorationDateList[2]),Integer.valueof(restorationDateList[1]),Integer.valueof(restorationDateList[0]));
                                        }
                                    }
                                    if(suspension.remarks!=null && String.isNotBlank(suspension.remarks)){
                                        apiVerDtl.Rmrks__c = suspension.remarks;
                                    }
                                    
                                    if(apiVerDtlMap.containsKey(applicantMap.get(integrationMessage.RefId__c).Id)){
                                        apiVerDtlMap.get(applicantMap.get(integrationMessage.RefId__c).Id).add(apiVerDtl);
                                    }
                                    else{
                                        apiVerDtlMap.put(applicantMap.get(integrationMessage.RefId__c).Id,new List<APIVerDtl__c>{apiVerDtl});
                                    }
                                }
                            }
                            apiVerList.add(apiVer);
                            
                            
                        }
                        
                        if(integrationMessage.Trigger_Platform_Event__c){
                            publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                            platformWra.intId = integrationMessage.Id; 
                            platformWra.recId = integrationMessage.ParentRefId__c;
                            platformWra.ServiceName = integrationMessage.Svc__c ;
                            platformWra.Status = integrationMessage.Status__c ;
                            platformWra.success=true;
                            publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
                        }
                        
                        APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Success');
                    }
                    
                }
                
                if(!existingApplicantIds.isEmpty()){
                    List<APIVer__c> existingAPIVerList = [Select Id,IsLatest__c,Appl__c FROM APIVer__c WHERE IsLatest__c=True AND Appl__c IN :existingApplicantIds AND RecordTypeId =:qualificationCheckRecordTypeId AND Prof_Qualification_Check__c = 'Doctor\'s Registration no Check'];
                    if(!existingAPIVerList.isEmpty()){
                        IntegrationUtility.updateBooleanFlag(existingAPIVerList, 'IsLatest__c', false);
                    }
                }
                
                if(!apiVerList.isEmpty()){
                    fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { APIVer__c.SObjectType });
                    List<string> fieldNamesList = New List<string>{'Appl__c','RecordTypeId','LoanAplcn__c','ApplNme__c','ApplTyp__c','IsLatest__c','IntegrationStatus__c','IntegrationErrorMessage__c','Prof_Qualification_Check__c','DoctorId__c','AdditionalAddr__c','Address__c','Category__c','DOB__c','DateOfRegistration__c','FatherName__c','Fname__c','HusbandName__c','IsNewlyRegisteredDoctor__c','Name__c','Qualification__c','QualificationYear__c','University__c','College__c','RegistrationNumber__c','RemovalStatus__c','RestorationDt__c','RestorationStatus__c','MedicalCouncil__c','MedicalCouncilStateId__c','PermanentRegistrationNumber__c','RegistrationYear__c','PassingYear__c','IsBlacklistedDoctor__c'};
                        String sObjectName = 'APIVer__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkInsert(objType,fieldNamesList);
                    uow.registerNew(apiVerList);
                    uow.commitWork();
                }
                
                if(!apiVerDtlMap.isEmpty()){
                    createAPIVerificationDetail(apiVerDtlMap);
                    
                }
                
                if(!updateApplicantMap.isEmpty()){
                    fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { Applicant__c.SObjectType });
                    uow.registerDirty(updateApplicantMap.values());
                    uow.commitWork();
                }
            }
            
        }
        catch(exception ex){
            system.debug('Error message: '+ ex.getMessage() + ' and Line number: ' + ex.getLineNumber());
        }
        
    }
    
    public static void processFailure(Map<Id,Applicant__c> applicantMap,Map<IntgMsg__c,String> failureResponses){
        
        try{
            
            Id qualificationCheckRecordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByDeveloperName().get('QualificationCheck').getRecordTypeId();
            set<Id> existingApplicantIds = new set<Id>();
            List<APIVer__c> apiVerList = new List<APIVer__c>();
            Map<Id,Applicant__c> updateApplicantMap = new Map<Id,Applicant__c>();
            
            for(IntgMsg__c integrationMessage : failureResponses.keySet()){
                
                if(applicantMap.containsKey(integrationMessage.RefId__c)){
                    
                    existingApplicantIds.add(integrationMessage.RefId__c);
                    
                    Applicant__c app =new Applicant__c();
                    app.Id=integrationMessage.RefId__c;
                    app.DoctorApiVerStatus__c = 'Failed';
                    updateapplicantMap.put(app.Id,app);
                    
                    
                    APIVer__c apiVer = new APIVer__c();
                    apiVer.Prof_Qualification_Check__c = 'Doctor\'s Registration no Check';
                    apiVer.IntegrationStatus__c = GlobalConstants.MSG_FAILURE;
                    apiVer.IntegrationErrorMessage__c = failureResponses.containsKey(integrationMessage)? failureResponses.get(integrationMessage) : '';
                    apiVer.IsLatest__c = True;
                    apiVer.RecordTypeId = qualificationCheckRecordTypeId;
                    apiVer.Appl__c = applicantMap.get(integrationMessage.RefId__c).Id ;
                    apiVer.LoanAplcn__c = applicantMap.get(integrationMessage.RefId__c).LoanAppln__c ;  
                    apiVer.ApplNme__c = applicantMap.get(integrationMessage.RefId__c).FullName__c ;  
                    apiVer.ApplTyp__c = applicantMap.get(integrationMessage.RefId__c).ApplType__c ;  
                    
                    apiVerList.add(apiVer);
                    
                    
                }
                
                if(integrationMessage.Trigger_Platform_Event__c){
                    publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                    platformWra.intId = integrationMessage.Id; 
                    platformWra.recId = integrationMessage.ParentRefId__c;
                    platformWra.ServiceName = integrationMessage.Svc__c ;
                    platformWra.Status = integrationMessage.Status__c ;
                    platformWra.errorMessage = failureResponses.containsKey(integrationMessage)? failureResponses.get(integrationMessage) : '';
                    publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
                }
                APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Failure');
            }
            
            if(!existingApplicantIds.isEmpty()){
                List<APIVer__c> existingAPIVerList = [Select Id,IsLatest__c,Appl__c FROM APIVer__c WHERE IsLatest__c=True AND Appl__c IN :existingApplicantIds AND RecordTypeId =:qualificationCheckRecordTypeId AND Prof_Qualification_Check__c = 'Doctor\'s Registration no Check'];
                if(!existingAPIVerList.isEmpty()){
                    IntegrationUtility.updateBooleanFlag(existingAPIVerList, 'IsLatest__c', false);
                }
            }
            
            if(!apiVerList.isEmpty()){
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { APIVer__c.SObjectType });
                List<string> fieldNamesList = New List<string>{'Appl__c','RecordTypeId','LoanAplcn__c','ApplNme__c','ApplTyp__c','IsLatest__c','IntegrationStatus__c','IntegrationErrorMessage__c'};
                    String sObjectName = 'APIVer__c';
                Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkInsert(objType,fieldNamesList);
                uow.registerNew(apiVerList);
                uow.commitWork();
            }
            
            if(!updateApplicantMap.isEmpty()){
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { Applicant__c.SObjectType });
                uow.registerDirty(updateApplicantMap.values());
                uow.commitWork();
            }
        }
        catch(exception ex){
            system.debug('Error message: '+ ex.getMessage() + ' and Line number: ' + ex.getLineNumber());
        }
        
    }
    
    public static void createAPIVerificationDetail(Map<String,List<APIVerDtl__c>> apiVerDtlMap){
        
        if(apiVerDtlMap!=null && !apiVerDtlMap.isEmpty()){
            Id qualificationCheckRecordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByDeveloperName().get('QualificationCheck').getRecordTypeId();
            Map<String,APIVer__c> apiVerMap = new Map<String,APIVer__c>();
            List<APIVerDtl__c> insertAPIVerDtlList = new List<APIVerDtl__c>();
            
            for(APIVer__c apiVer : [Select Id,IsLatest__c,Appl__c FROM APIVer__c WHERE IsLatest__c=True AND Appl__c IN :apiVerDtlMap.keySet() AND RecordTypeId =:qualificationCheckRecordTypeId AND Prof_Qualification_Check__c = 'Doctor\'s Registration no Check']){
                apiVerMap.put(apiVer.Appl__c,apiVer);
            }
            
            for(String key : apiVerDtlMap.keySet()){
                if(apiVerDtlMap.containsKey(key) && apiVerDtlMap.get(key)!=null && !apiVerDtlMap.get(key).isEmpty()){
                    if(apiVerMap.containsKey(key)){
                        for(APIVerDtl__c apiVerDtl : apiVerDtlMap.get(key)){
                            apiVerDtl.APIVerification__c = apiVerMap.get(key).Id;
                            insertAPIVerDtlList.add(apiVerDtl);
                        }
                    }
                }
            }
            
            if(!insertAPIVerDtlList.isEmpty()){
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { APIVerDtl__c.SObjectType });
                List<string> fieldNamesList = New List<string>{'APIVerification__c','Type__c','Qualification__c','QualificationYear__c','University__c','College__c','SuspensionDt__c','RestorationDt__c','Rmrks__c'};
                    String sObjectName = 'APIVerDtl__c';
                Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkInsert(objType,fieldNamesList);
                uow.registerNew(insertAPIVerDtlList);
                uow.commitWork();
            }
        }
    }
}