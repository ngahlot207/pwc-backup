public class UdyamVerificationAPIResponseProcessor implements IintMsgCalloutResponseProcessor {
    
    public static void process(List<IntgMsg__c> responses) {
        
        if(!responses.isEmpty()){
            
            Map<IntgMsg__c,UdyamVerificationAPIResponseWrapper> successResponseMap = new Map<IntgMsg__c,UdyamVerificationAPIResponseWrapper>();
            Map<IntgMsg__c,String> failureResponseMap = new Map<IntgMsg__c,String>();
            
            for(IntgMsg__c intmsg:responses){
                
                if(String.isnotBlank(intmsg.Resp__c)){
                    
                    try{
                        
                        UdyamVerificationAPIResponseWrapper  res =(UdyamVerificationAPIResponseWrapper) JSON.deserialize(intmsg.Resp__c,UdyamVerificationAPIResponseWrapper.class);
                        
                        //Success
                        if(res.statusCode ==GlobalConstants.karza_Status_101){//101
                            successResponseMap.put(intmsg,res);
                        }
                        
                        //Failure
                        else if(res.statusCode !=GlobalConstants.karza_Status_101){
                            failureResponseMap.put(intmsg,GlobalConstants.karza_Status_Code_Authn_Description.ContainsKey(res.statusCode)?GlobalConstants.karza_Status_Code_Authn_Description.get(res.statusCode):'');
                        }
                        
                        
                    }catch(Exception ex){
                        GlobalUtility.logMessage('Error', 'UdyamVerificationAPIResponseProcessor class', 
                                                 'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
                        failureResponseMap.put(intmsg,IntegrationUtility.getCustomErrorMessage(ex.getMessage().substringBefore(':')));
                    }
                    
                }
            }
            
            if(!successResponseMap.isEmpty()){
                processSuccess(successResponseMap);
            }
            
            if(!failureResponseMap.isEmpty()){
                processFailure(failureResponseMap);
            }
        }
        
    }
    //*******************************************************************************************************************************************
    public static void processSuccess(Map<IntgMsg__c,UdyamVerificationAPIResponseWrapper> successResp){
        
        try{
            
            Set<Id> appKcIds =new Set<Id>();
            Set<Id> applicantIds =new Set<Id>();
            Set<Id> docIds =new Set<Id>();
            
            Map<Id, ApplKyc__c> ApplicantkycMap;
            Map<Id, ApplicantEmployment__c> employmentMap=new Map<id, ApplicantEmployment__c>();
            Map<Id,String> pdfMap =new Map<Id,String>();
            Map<Id,DocDtl__c> docMap =new Map<Id,DocDtl__c>();
            
            List<SObject> recordsToUpdate = new List<SObject>();
            List<ContentVersion> contentVersionList =new List<ContentVersion>();
            
            Id recordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByDeveloperName().get('Udyam').getRecordTypeId();
            
            //looping to get Applicant and ApplicantKyc ids
            for(IntgMsg__c intmsg:successResp.keyset()){
                
                if(successResp.containsKey(intmsg) && string.isNotblank(intmsg.RefId__c)){
                    appKcIds.add(intmsg.RefId__c);
                }
                
                if(successResp.containsKey(intmsg) && string.isNotblank(intmsg.ParentRefId__c)){
                    applicantIds.add(intmsg.ParentRefId__c);
                }
            }
            
            //SOQL to get ApplicantKyc
            if(!appKcIds.isEmpty()){
                
                ApplicantkycMap =new Map<id, ApplKyc__c>([SELECT Id,kycDoc__c,Applicant__r.LoanAppln__c from ApplKyc__c Where Id IN:appKcIds AND kycDoc__c ='Udyam Registration Certificate']);
            }
            
            //SOQL to get Applicant Employment
            if(!applicantIds.isEmpty()){
                
                for(ApplicantEmployment__c aem:[SELECT Id,LoanApplicant__c FROM ApplicantEmployment__c WHERE LoanApplicant__c IN:applicantIds]){
                    employmentMap.put(aem.LoanApplicant__c,aem);
                }
                
            }
            
            //SOQL to check old records
            List<APIVer__c> apiVer =[Select id,Appl__c,IsLatest__c,RecordType.Name from APIVer__c Where Appl__c IN:applicantIds AND RecordType.Name='Udyam' AND IsLatest__c=true];
            if(!apiVer.isEmpty()){
                IntegrationUtility.updateBooleanFlag(apiVer,'IsLatest__c',false);
            }
            
            //Looping to update the records
            for(IntgMsg__c msg:successResp.keyset()){
                
                if(successResp.containsKey(msg)){
                    
                    UdyamVerificationAPIResponseWrapper response =successResp.get(msg);
                    
                    if(String.isNotblank(msg.Req__c) && response!=null){
                        
                        UdyamVerificationAPIRequestWrapper  request =(UdyamVerificationAPIRequestWrapper) JSON.deserialize(msg.Req__c,UdyamVerificationAPIRequestWrapper.class);
                        
                        if(String.isNotblank(request.isPDFRequired) && request.isPDFRequired=='Y' &&
                           response.result!=null && string.isNotblank(response.result.pdfData)){
                               
                               pdfMap.put(msg.RefId__c,response.result.pdfData); 
                               
                           }
                        
                        if(ApplicantkycMap!=null && ApplicantkycMap.containsKey(msg.RefId__c)){
                            
                            ApplKyc__c appKyc=ApplicantkycMap.get(msg.RefId__c);
                            
                            if(appKyc!=null){
                                
                                appKyc = (ApplKyc__c)updateSobject(response, appKyc, 'ApplKyc__c');
                                recordsToUpdate.add(appKyc); 
                            }
                        }
                        
                        if(employmentMap!=null && employmentMap.containsKey(msg.ParentRefId__c)){
                            
                            ApplicantEmployment__c aem=employmentMap.get(msg.ParentRefId__c);
                            
                            if(aem!=null){
                                
                                aem = (ApplicantEmployment__c)updateSobject(response, aem, 'ApplicantEmployment__c');
                                recordsToUpdate.add(aem);
                            }
                        }
                        
                        
                        APIVer__c verification = (APIVer__c)updateSobject(response, new APIVer__c(Appl__c=msg.ParentRefId__c,
                                                                                                  LoanAplcn__c=ApplicantkycMap.ContainsKey(msg.RefId__c)?ApplicantkycMap.get(msg.RefId__c).Applicant__r.LoanAppln__c:'',
                                                                                                  RecordTypeId=recordTypeId,IsLatest__c=true), 'APIVer__c');
                        recordsToUpdate.add(verification);
                        
                        if(msg.Trigger_Platform_Event__c){
                            publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                            platformWra.intId = msg.Id; 
                            platformWra.recId = msg.RefId__c;
                            platformWra.ServiceName = msg.Svc__c ;
                            platformWra.Status = msg.Status__c ;
                            platformWra.success=true;
                            publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
                        }
                        APICalloutTracker.update_ApiTrackerWithIntMsg(msg.Id,msg.Svc__c, msg.RefId__c, 'Success');
                    }
                    
                }
                
            }
            
            
            if(!appKcIds.isEmpty()){
                for(DocDtl__c doc:[Select id,Applicant_KYC__c,DocCatgry__c,DocTyp__c,DocSubTyp__c,Applicant_KYC__r.Applicant__r.LoanAppln__c,
                                         Applicant_KYC__r.Applicant__c,Applicant_KYC__r.ValidationStatus__c,Applicant_KYC__r.OCRStatus__c,
                                         Applicant_KYC__r.AdrsSplitStatus__c,Applicant_KYC__r.AddrLine1__c,Applicant_KYC__r.AddrLine2__c,
                                         Applicant_KYC__r.Landmark__c,Applicant_KYC__r.Locality__c,Applicant_KYC__r.HouseNo__c,
                                         Applicant_KYC__r.Country__c,Applicant_KYC__r.Pincode__c,Applicant_KYC__r.City__c,
                                         Applicant_KYC__r.State__c from DocDtl__c where Applicant_KYC__c IN:appKcIds AND 
                                         DocSubTyp__c='Udyam Registration Certificate' AND DocCatgry__c='KYC Documents']){
                    
                    docIds.add(doc.Id);
                    docMap.put(doc.Applicant_KYC__c,doc);
                }
            }
            if(!pdfMap.isEmpty()){
                
                
                //Deleting the files
                if(!docIds.isEmpty()){
                    List<ContentDocumentLink> doclist = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN:docIds];
                    
                    if(!doclist.isEmpty()){
                        Delete doclist;
                    }
                }
                
                //Looping to create PDF
                for(string kycId:pdfMap.keyset()){
                    
                    if(docMap.containsKey(kycId)){
                        
                        String pfdValues=pdfMap.get(kycId);//EncodingUtil.base64Decode
                        DocDtl__c docDetail=docMap.get(kycId);
                        
                        ContentVersion contentVersion = new ContentVersion();
                        contentVersion.VersionData = EncodingUtil.base64Decode(pfdValues);
                        contentVersion.Title = 'Udyam Registration Certificate';
                        contentVersion.PathOnClient = 'Udyam Registration Certificate.pdf';
                        contentVersion.FirstPublishLocationId = docDetail.Id;
                        contentVersionList.add(contentVersion);
                    }
                }
            }
            
            if(!recordsToUpdate.isEmpty()){
                upsert recordsToUpdate;
            }
            
            if(!contentVersionList.isEmpty()){
                Insert contentVersionList;
            }
            
            if(!docMap.isEmpty()){
                ApplicantUpdate au = new ApplicantUpdate();
                    au.Afterinsert(docMap.values());
            }
            
        }
        catch(Exception ex){
            GlobalUtility.logMessage('Error', 'UdyamVerificationAPIResponseProcessor', 
                                     'processSuccess', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            
        }
        
    } 
    
    //***************************************************************************************************************************************
    public static void processFailure(Map<IntgMsg__c,String> failureResp){
        
        try{
            
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> {ApplKyc__c.SObjectType,ApplicantEmployment__c.SObjectType,APIVer__c.SObjectType});
            
            Set<Id> applicantIds =new Set<Id>();
            Map<Id,ApplicantEmployment__c> employmentMap =new Map<Id,ApplicantEmployment__c>();
            List<ApplKyc__c> appKycEmpList=new List<ApplKyc__c>();
            List<ApplicantEmployment__c> employmentList =new List<ApplicantEmployment__c>();
            List<APIVer__c> appVerList=new List<APIVer__c>();
            
            Id recordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByDeveloperName().get('Udyam').getRecordTypeId();
            
            //looping to get ApplicantIds
            for(IntgMsg__c msg:failureResp.keyset()){
                
                if(string.isNotblank(msg.ParentRefId__c)){
                    applicantIds.add(msg.ParentRefId__c);
                }
            }
            
            
            if(!applicantIds.isEmpty()){
                
                for(ApplicantEmployment__c aem:[SELECT Id,LoanApplicant__c FROM ApplicantEmployment__c WHERE LoanApplicant__c IN:applicantIds]){
                    
                    employmentMap.put(aem.LoanApplicant__c,aem);
                }
                
                //Checking if any record  present
                List<APIVer__c> apiVer =[Select id,Appl__c,IsLatest__c,RecordType.Name from APIVer__c Where Appl__c IN:applicantIds AND RecordType.Name='Udyam' AND IsLatest__c=true];
                
                if(!apiVer.isEmpty()){
                    IntegrationUtility.updateBooleanFlag(apiVer,'IsLatest__c',false);
                }
            }
            
            //update error message
            for(IntgMsg__c intmsg:failureResp.keyset()){
                
                //Updating Applicant Kyc Record
                if(String.isNotblank(intmsg.RefId__c)){
                    
                    ApplKyc__c kyc =new ApplKyc__c();
                    kyc.Id=intmsg.RefId__c;
                    kyc.Validation_Error_Message__c=failureResp.get(intmsg);
                    kyc.ValidationStatus__c='Failure';
                    appKycEmpList.add(kyc);    
                }
                
                //Updating Applicant Employment Record
                if(employmentMap.containsKey(intmsg.ParentRefId__c)){
                    
                    ApplicantEmployment__c emp =new ApplicantEmployment__c();
                    emp.Id=employmentMap.get(intmsg.ParentRefId__c).id;
                    emp.UdyamErrorMess__c=failureResp.get(intmsg);
                    emp.UdyamAPIStatus__c='Failure';
                    employmentList.add(emp);
                }
                
                //Creating API Verification Record
                if(String.isNotblank(intmsg.ParentRefId__c)){
                    
                    APIVer__c apiveri =new APIVer__c();
                    apiveri.Appl__c=intmsg.ParentRefId__c;
                    apiveri.IntegrationStatus__c='Failure';
                    apiveri.IntegrationErrorMessage__c=failureResp.get(intmsg);
                    apiveri.IsLatest__c=true;
                    apiveri.RecordTypeId=recordTypeId!=null?recordTypeId:'';
                    appVerList.add(apiveri);
                }
                
                if(intmsg.Trigger_Platform_Event__c){
                    publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                    platformWra.intId = intmsg.Id; 
                    platformWra.recId = intmsg.RefId__c;
                    platformWra.ServiceName = intmsg.Svc__c ;
                    platformWra.Status = intmsg.Status__c ;
                    platformWra.errorMessage=failureResp.get(intmsg);
                    publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
                } 
                APICalloutTracker.update_ApiTrackerWithIntMsg(intmsg.Id,intmsg.Svc__c, intmsg.RefId__c, 'Failure');
            }
            
            //Updating the Applicant Kyc
            if(!appKycEmpList.isEmpty()) {
                String sObjectName = 'ApplKyc__c';
                List<String> fieldNamesList = new List<String>{'Validation_Error_Message__c','ValidationStatus__c'};
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                uow.registerDirty(appKycEmpList);
            }
            
            //Updating the Applicant Employment
            if(!employmentList.isEmpty()) {
                String sObjectName = 'ApplicantEmployment__c';
                List<String> fieldNamesList = new List<String>{'UdyamErrorMess__c','UdyamAPIStatus__c'};
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                uow.registerDirty(employmentList);
            }
            
            //Creating API Verification Record
            if(!appVerList.isEmpty()) {
                String sObjectName = 'APIVer__c';
                List<String> fieldNamesList = new List<String>{'Appl__c','IntegrationStatus__c','IntegrationErrorMessage__c','IsLatest__c','RecordTypeId'};
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                uow.registerNew(appVerList);
            }
            
            uow.commitWork();
            
        }catch (Exception ex) {
            GlobalUtility.logMessage('Error', 'UdyamVerificationAPIResponseProcessor', 
                                     'processFailure', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
    }
    //***************************************************************************************************************************************
    public static SObject updateSobject(UdyamVerificationAPIResponseWrapper res, SObject recordToUpdate, String objectAPIName) {
        
        try {
            if (res != null && recordToUpdate != null && String.isNotBlank(objectAPIName)) {
                
                
                if(objectAPIName=='ApplicantEmployment__c'){
                    
                    recordToUpdate.put('UdyamErrorMess__c','');
                    recordToUpdate.put('UdyamAPIStatus__c','Success');
                }
                
                //udyamRegistrationNo
                if(res.result != null && String.isNotBlank(res.result.udyamRegistrationNo) && objectAPIName=='ApplKyc__c'){
                    recordToUpdate.put('URC_Number__c',res.result.udyamRegistrationNo);
                }
                
                // Date of Udyam Registration
                if (res.result != null && res.result.dateOfRegistration != null) {
                    recordToUpdate.put('DateOfUdyamRegistration__c', Date.valueof(res.result.dateOfRegistration));
                }
                
                // Type of enterprise as per URC
                if (res.result != null && res.result.enterpriseType != null) {
                    recordToUpdate.put('TypeOfEnterprise_URC__c', String.isNotBlank(res.result.enterpriseType[0].enterpriseType) ? res.result.enterpriseType[0].enterpriseType : '');
                }
                
                // Industry, Sub Sector, Activity, NIC, Activity description as per URC
                if (res.result != null && res.result.industry != null) {
                    UdyamVerificationAPIResponseWrapper.Industry ind = res.result.industry[0];
                    
                    if (String.isNotBlank(ind.industry)) {
                        recordToUpdate.put('Industry_URC__c', ind.industry);
                    }
                    if (String.isNotBlank(ind.subSector)) {
                        recordToUpdate.put('SubSector_URC__c', ind.subSector);
                    }
                    if (String.isNotBlank(ind.activity)) {
                        recordToUpdate.put('Activity_URC__c', ind.activity);
                    }
                    if (String.isNotBlank(ind.nicCode)) {
                        recordToUpdate.put('NIC_URC__c', ind.nicCode);
                    }
                    if (String.isNotBlank(ind.activityDescription)) {
                        recordToUpdate.put('ActivityDescription_URC__c', ind.activityDescription);
                    }
                }
                
                //Profile
                if(res.result != null && res.result.profile != null){
                    
                    UdyamVerificationAPIResponseWrapper.Profile prf =res.result.profile;
                    
                    if(String.isNotBlank(prf.name)){
                        recordToUpdate.put('UdyamPrfName__c', prf.name);
                        
                        if(objectAPIName=='ApplKyc__c' || objectAPIName=='APIVer__c'){
                            recordToUpdate.put('Name__c', prf.name);
                        }
                    }
                    
                    if(String.isNotBlank(prf.organizationType)){
                        recordToUpdate.put('OrgType__c', prf.organizationType);
                    }
                    
                    if(String.isNotBlank(prf.dateOfIncorporation)){
                        recordToUpdate.put('DteOfIncorp__c', Date.valueof(prf.dateOfIncorporation));
                    }
                    
                    if(String.isNotBlank(prf.dateOfCommencement)){
                        recordToUpdate.put('DteOfComm__c', Date.valueof(prf.dateOfCommencement));
                    }
                    
                    if(String.isNotBlank(prf.emailId) && (objectAPIName=='ApplKyc__c'|| objectAPIName=='APIVer__c')){
                        recordToUpdate.put('Email__c', prf.emailId);
                    }
                }
                
                //Address
                if(String.isNotBlank(objectAPIName) && (objectAPIName=='ApplKyc__c'|| objectAPIName=='APIVer__c')){
                    
                    if(objectAPIName=='ApplKyc__c'){
                        recordToUpdate.put('Validation_Error_Message__c','');
                        recordToUpdate.put('ValidationStatus__c','Success');
                    }
                    
                    if(objectAPIName=='APIVer__c'){
                        recordToUpdate.put('IntegrationStatus__c','Success');
                    }
                    
                    if(res.result != null && res.result.officialAddress != null){
                        
                        UdyamVerificationAPIResponseWrapper.OfficialAddress offadrs =res.result.officialAddress;
                        
                        if(String.isNotBlank(offadrs.flat) || (String.isNotBlank(offadrs.block))){
                            String concatenatedString = '';
                            
                            if (String.isNotBlank(offadrs.flat)) {
                                concatenatedString += offadrs.flat;
                            }
                            
                            if (String.isNotBlank(offadrs.block)) {
                                concatenatedString += String.isNotBlank(concatenatedString)?',Block-'+offadrs.block:'Block-'+offadrs.block;
                                
                            }
                            recordToUpdate.put('HouseNo__c',concatenatedString);
                        }
                        
                        if(String.isNotBlank(offadrs.premises)){
                            recordToUpdate.put('AddrLine1__c', offadrs.premises);
                        }
                        
                        if(String.isNotBlank(offadrs.road)){
                            recordToUpdate.put('AddrLine2__c', offadrs.road);
                        }
                        
                        if(String.isNotBlank(offadrs.village)){
                            recordToUpdate.put('VillageTownCity__c', offadrs.village);
                        }
                        
                        if(String.isNotBlank(offadrs.city)){
                            recordToUpdate.put('City__c', offadrs.city);
                        }
                        
                        if(String.isNotBlank(offadrs.state)){
                            recordToUpdate.put('State__c', offadrs.state);
                        }
                        
                        if(String.isNotBlank(offadrs.pincode)){
                            recordToUpdate.put('Pincode__c', offadrs.pincode);
                        }
                        
                        if(String.isNotBlank(offadrs.district)){
                            recordToUpdate.put('District__c', offadrs.district);
                        }
                        
                    }
                }
                
                return recordToUpdate;
            }
        } catch (Exception ex) {
            GlobalUtility.logMessage('Error', 'UdyamVerificationAPIResponseProcessor', 
                                     'updateSobject', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        return null; 
    }
    
}