public class ShopEstablishmentCheckResponseProcessor implements IintMsgCalloutResponseProcessor {
    
    public static void process(List<IntgMsg__c> responses) {
        
        if(!responses.isEmpty()){
            
            Map<IntgMsg__c,ShopAndEstablishmentCheckResponseWrapper> successResponseMap = new Map<IntgMsg__c,ShopAndEstablishmentCheckResponseWrapper>();
            Map<IntgMsg__c,String> failureResponseMap = new Map<IntgMsg__c,String>();
            
            for(IntgMsg__c intmsg:responses){
                
                if(String.isnotBlank(intmsg.Resp__c)){
                    
                    try{
                        ShopAndEstablishmentCheckResponseWrapper  res =(ShopAndEstablishmentCheckResponseWrapper) JSON.deserialize(intmsg.Resp__c.replace('father\'sNameOfOccupier','fathersNameOfOccupier'),ShopAndEstablishmentCheckResponseWrapper.class);
                        
                        //Success
                        if(res.statusCode ==GlobalConstants.karza_Status_101){//101
                            
                            successResponseMap.put(intmsg,res);
                        }
                        
                        //Failure
                        else if(res.statusCode !=GlobalConstants.karza_Status_101 || res.status!=null){
                            
                            failureResponseMap.put(intmsg,GlobalConstants.karza_Status_Code_Authn_Description.ContainsKey(res.statusCode)?GlobalConstants.karza_Status_Code_Authn_Description.get(res.statusCode):res.error);
                            
                        }
                        
                    }catch(Exception ex){
                        GlobalUtility.logMessage('Error', 'ShopEstablishmentCheckResponseProcessor class', 
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
    public static void processSuccess(Map<IntgMsg__c,ShopAndEstablishmentCheckResponseWrapper> successResp){
        
        try{
            
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> {IntgMsg__c.SObjectType});
            
            Set<Id> docIds =new Set<Id>();
            Set<Id> kycIds =new Set<Id>();
            Set<Id> applicantIds =new Set<Id>();
            Map<Id,ApplKyc__c> applicantKycMap;
            
            List<SObject> recordsToUpdate = new List<SObject>(); 
            List<IntgMsg__c> intgMsgList =new List<IntgMsg__c>();
            
            Id recordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByDeveloperName().get('ShopEstablishment').getRecordTypeId();
            
            //Looping to get Doc and kycId
            for(IntgMsg__c intmsg:successResp.keyset()){
                
                if(String.isNotblank(intmsg.RefId__c)){
                    docIds.add(intmsg.RefId__c);
                }
                
                if(String.isNotblank(intmsg.ParentRefId__c)){
                    kycIds.add(intmsg.ParentRefId__c);
                }
            }
            
            if(!kycIds.isEmpty()){
                
                applicantKycMap =new Map<Id,ApplKyc__c>([Select Id,kycDoc__c,Applicant__c,Applicant__r.LoanAppln__c,Address__c from ApplKyc__c Where Id IN:kycIds AND kycDoc__c='Shop and Establishment']);
            }
            
            //looping to get Applicant IDs
            if(!kycIds.isempty() && !applicantKycMap.isempty()){
                
                for(Id appids:kycIds){
                    
                    if(applicantKycMap.containskey(appids)){
                        ApplKyc__c kyc =applicantKycMap.get(appids);
                        
                        if(kyc.Applicant__c!=null){
                            applicantIds.add(kyc.Applicant__c); 
                        }
                    }
                }
            }
            
            //SOQL to check old records
            List<APIVer__c> apiVer =[Select id,Appl__c,IsLatest__c,RecordType.Name from APIVer__c Where Appl__c IN:applicantIds AND RecordType.DeveloperName='ShopEstablishment' AND IsLatest__c=true];
            if(!apiVer.isEmpty()){
                IntegrationUtility.updateBooleanFlag(apiVer,'IsLatest__c',false);
            }
            
            //Looping to update the records
            for(IntgMsg__c msg:successResp.keyset()){
                
                if(successResp.containskey(msg) && string.isNotblank(msg.ParentRefId__c)){
                    
                    ShopAndEstablishmentCheckResponseWrapper resp =successResp.get(msg);
                    
                    if(!applicantKycMap.isEmpty() && applicantKycMap.containsKey(msg.ParentRefId__c)){
                        
                        ApplKyc__c appKyc=ApplicantkycMap.get(msg.ParentRefId__c);
                        
                        //Updating ApplKyc__c
                        if(appKyc!=null){
                            
                            appKyc = (ApplKyc__c)updateSobject(resp, appKyc, 'ApplKyc__c');
                            recordsToUpdate.add(appKyc);
                            
                            if(String.isNotblank(appKyc.Address__c)){
                                
                                IntgMsg__c intMsgRec = new IntgMsg__c();
                                intMsgRec.Name = 'Address Split';
                                intMsgRec.BU__c = 'HL / STL';
                                intMsgRec.Status__c = GlobalConstants.INT_MSG_STATUS_NEW;
                                intMsgRec.MStatus__c = GlobalConstants.INT_MSG_MStatus_BLANK;
                                intMsgRec.Svc__c = 'Address Split';
                                intMsgRec.RefId__c = String.isNotblank(msg.RefId__c)?msg.RefId__c:'';
                                intMsgRec.RefObj__c = 'DocDtl__c';
                                intMsgRec.ParentRefId__c = String.isNotblank(msg.ParentRefId__c)?msg.ParentRefId__c:'';
                                intMsgRec.ParentRefObj__c = 'ApplKyc__c';
                                intMsgRec.IsActive__c = TRUE;
                                intgMsgList.add(intMsgRec);
                            }
                        }
                        
                        //creating APIVer__c
                        if(appKyc.Applicant__c!=null){
                            
                            APIVer__c verification = (APIVer__c)updateSobject(resp, new APIVer__c(Appl__c=appKyc.Applicant__c,LoanAplcn__c=appKyc.Applicant__r.LoanAppln__c,RecordTypeId=recordTypeId,IsLatest__c=true), 'APIVer__c');
                            recordsToUpdate.add(verification);
                        }
                        
                        if(msg.Trigger_Platform_Event__c){
                            publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                            platformWra.intId = msg.Id; 
                            platformWra.recId = msg.ParentRefId__c;
                            platformWra.ServiceName = msg.Svc__c ;
                            platformWra.Status = msg.Status__c ;
                            platformWra.success=true;
                            publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
                        }
                        APICalloutTracker.update_ApiTrackerWithIntMsg(msg.Id,msg.Svc__c, msg.ParentRefId__c, 'Success');
                    }
                }
                
            }
            
            if(!recordsToUpdate.isEmpty()){
                upsert recordsToUpdate;
            }
            
            //Creating the IntgMsg__c
            if(!intgMsgList.isEmpty()) {
                String sObjectName = 'IntgMsg__c';
                List<String> fieldNamesList = new List<String>{'Name','BU__c','Status__c','MStatus__c','Svc__c','RefId__c','RefObj__c','IsActive__c'};
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                uow.registerNew(intgMsgList);
                uow.commitWork();
            }
            
            //Calling Trigger to Upsert Address
            if(!docIds.isEmpty()){
                
                List<DocDtl__c> doc=[Select id,Applicant_KYC__c,DocCatgry__c,DocTyp__c,DocSubTyp__c,Applicant_KYC__r.Applicant__r.LoanAppln__c,
                                     Applicant_KYC__r.Applicant__c,Applicant_KYC__r.ValidationStatus__c,Applicant_KYC__r.OCRStatus__c,
                                     Applicant_KYC__r.AdrsSplitStatus__c,Applicant_KYC__r.AddrLine1__c,Applicant_KYC__r.AddrLine2__c,
                                     Applicant_KYC__r.Landmark__c,Applicant_KYC__r.Locality__c,Applicant_KYC__r.HouseNo__c,
                                     Applicant_KYC__r.Country__c,Applicant_KYC__r.Pincode__c,Applicant_KYC__r.City__c,
                                     Applicant_KYC__r.State__c from DocDtl__c where Id IN:docIds AND 
                                     DocSubTyp__c='Shop and Establishment' AND DocCatgry__c='KYC Documents'];
                
                if(!doc.isEmpty()){
                    ApplicantUpdate au = new ApplicantUpdate();
                    au.Afterinsert(doc);
                }
                
            }
            
            
        }catch(Exception ex){
            GlobalUtility.logMessage('Error', 'ShopEstablishmentCheckResponseProcessor', 
                                     'processSuccess', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            
        }
    }
    //*******************************************************************************************************************************************   
    public static void processFailure(Map<IntgMsg__c,String> failureResp){
        
        try{
            
            
            Set<Id> kycIds =new Set<Id>();
            Set<Id> applicantIds =new Set<Id>();
            Map<Id,ApplKyc__c> applicantKycMap;
            List<APIVer__c> appVerList=new List<APIVer__c>();
            List<ApplKyc__c> appKycList=new List<ApplKyc__c>();
            
            Id recordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByDeveloperName().get('ShopEstablishment').getRecordTypeId();
            
            //looping to get KycIds
            for(IntgMsg__c msg:failureResp.keyset()){
                
                if(string.isNotblank(msg.ParentRefId__c)){
                    kycIds.add(msg.ParentRefId__c);
                }
            }
            
            if(!kycIds.isEmpty()){
                applicantKycMap =new Map<Id,ApplKyc__c>([Select Id,kycDoc__c,Applicant__c from ApplKyc__c Where Id IN:kycIds AND kycDoc__c='Shop and Establishment']); 
            }
            
            
            //looping to get Applicant IDs
            if(!kycIds.isempty() && !applicantKycMap.isempty()){
                
                for(Id appids:kycIds){
                    
                    if(applicantKycMap.containskey(appids)){
                        ApplKyc__c kyc =applicantKycMap.get(appids);
                        
                        if(kyc.Applicant__c!=null){
                            applicantIds.add(kyc.Applicant__c); 
                        }
                    }
                }
            }
            
            //SOQL to check old records
            List<APIVer__c> apiVer =[Select id,Appl__c,IsLatest__c,RecordType.Name from APIVer__c Where Appl__c IN:applicantIds AND RecordType.DeveloperName='ShopEstablishment' AND IsLatest__c=true];
            if(!apiVer.isEmpty()){
                IntegrationUtility.updateBooleanFlag(apiVer,'IsLatest__c',false);
            }
            
            //Looping to update the records
            for(IntgMsg__c msg:failureResp.keyset()){
                
                if(failureResp.containsKey(msg) && String.isNotblank(msg.ParentRefId__c)){
                    
                    if(ApplicantkycMap.containsKey(msg.ParentRefId__c)){
                        
                        ApplKyc__c appKyc=ApplicantkycMap.get(msg.ParentRefId__c);
                        
                        //Updating ApplKyc__c
                        if(appKyc!=null){
                            appKyc.Validation_Error_Message__c=failureResp.get(msg);
                            appKyc.ValidationStatus__c='Failure';
                            appKycList.add(appKyc);
                        }
                        
                        //creating APIVer__c
                        if(appKyc.Applicant__c!=null){
                            
                            APIVer__c apiveri =new APIVer__c();
                            apiveri.Appl__c=appKyc.Applicant__c;
                            apiveri.IntegrationStatus__c='Failure';
                            apiveri.IntegrationErrorMessage__c=failureResp.get(msg);
                            apiveri.IsLatest__c=true;
                            apiveri.RecordTypeId=recordTypeId!=null?recordTypeId:'';
                            appVerList.add(apiveri);
                        }
                    }
                    
                    
                }
                
                
                if(msg.Trigger_Platform_Event__c){
                    publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                    platformWra.intId = msg.Id; 
                    platformWra.recId = msg.ParentRefId__c;
                    platformWra.ServiceName = msg.Svc__c ;
                    platformWra.Status = msg.Status__c ;
                    platformWra.errorMessage=failureResp.get(msg);
                    publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
                } 
                APICalloutTracker.update_ApiTrackerWithIntMsg(msg.Id,msg.Svc__c, msg.ParentRefId__c, 'Failure');
            }
            
            //Creating API Verification Record
            if(!appVerList.isEmpty()) {
                Insert appVerList;
            }
            
            //Updating the Applicant Kyc
            if(!appKycList.isEmpty()) {
                Update appKycList;
            }
            
        }catch (Exception ex) {
            GlobalUtility.logMessage('Error', 'ShopEstablishmentCheckResponseProcessor', 
                                     'processFailure', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
    }
    
    //******************************************************************************************************************************************* 
    public static SObject updateSobject(ShopAndEstablishmentCheckResponseWrapper res, SObject recordToUpdate, String objectAPIName) {
        
        try {
            
            if (res != null && res.result!=null && recordToUpdate != null && String.isNotBlank(objectAPIName)) {
                
                ShopAndEstablishmentCheckResponseWrapper.ResultClass result =res.result;
                
                if(objectAPIName=='ApplKyc__c'){
                    
                    recordToUpdate.put('ValidationStatus__c','Success');
                    recordToUpdate.put('Validation_Error_Message__c','');
                }
                
                if(objectAPIName=='APIVer__c'){
                    
                    recordToUpdate.put('IntegrationStatus__c','Success');
                    
                }
                
                if(String.isNotBlank(result.category)){
                    recordToUpdate.put('ShopEstCat__c',result.category);
                }
                
                if(String.isNotBlank(result.status)){
                    recordToUpdate.put('ShopEstStatus__c',result.status);
                }
                
                if(String.isNotBlank(result.ownerName)){
                    recordToUpdate.put('ShopEstOwnername__c',result.ownerName);
                }
                
                if(String.isNotBlank(result.entityName)){
                    recordToUpdate.put('ShopEstEntityname__c',result.entityName);
                }
                
                if(String.isNotBlank(result.registrationDate) && parseDate(result.registrationDate)!=null){
                    recordToUpdate.put('DtOfShopEstReg__c',parseDate(result.registrationDate));
                }
                
                if(String.isNotBlank(result.validTo) && parseDate(result.validTo)!=null){
                    recordToUpdate.put('DtOfExp__c',parseDate(result.validTo));
                }
                
                if(String.isNotBlank(result.contact)){
                    recordToUpdate.put('ShopEstCon__c',result.contact);
                }
                
                if(String.isNotBlank(result.commenceDate) && parseDate(result.commenceDate)!=null){
                    recordToUpdate.put('DteOfComm__c',parseDate(result.commenceDate));
                }
                
                if(String.isNotBlank(result.totalWorkers)){
                    recordToUpdate.put('ShopEstTotWorkers__c',result.totalWorkers);
                }
                
                if(String.isNotBlank(result.fathersNameOfOccupier)){
                    recordToUpdate.put('FatherName__c',result.fathersNameOfOccupier);
                }
                
                if(String.isNotBlank(result.natureOfBusiness)){
                    recordToUpdate.put('ShopEstNatureBus__c',result.natureOfBusiness);
                }
                
                if(String.isNotBlank(result.validFrom) && parseDate(result.validFrom)!=null){
                    recordToUpdate.put('ShopEstValidFrom__c',parseDate(result.validFrom));
                }
                
                if(String.isNotBlank(result.email)){
                    recordToUpdate.put('Email__c',result.email);
                }
                
                if(String.isNotBlank(result.applicantName)){
                    recordToUpdate.put('Name__c',result.applicantName);
                }
                
                if(String.isNotBlank(result.address)){
                    recordToUpdate.put('Address__c',result.address);
                }
                
                return recordToUpdate;
            }
        }catch (Exception ex) {
            GlobalUtility.logMessage('Error', 'ShopEstablishmentCheckResponseProcessor', 
                                     'updateSobject', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        return null; 
    }
    //*******************************************************************************************************************************************       
    public static Date parseDate(String dateString) {
        
        Date parsedDate;
        
        try{
            List<String> dateParts = dateString.split('/'); 
            
            if(dateParts.size()==3){
                
                parsedDate = Date.newInstance(Integer.valueOf(dateParts[2]),Integer.valueOf(dateParts[1]),Integer.valueOf(dateParts[0])); 
                return parsedDate;
            }
            
            
        }catch(Exception ex){
            GlobalUtility.logMessage('Error', 'ShopEstablishmentCheckResponseProcessor', 
                                     'parseDate', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            
        }
        
        return null;
    }
}