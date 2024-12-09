public class VoterIdResponseProcessor implements IintMsgCalloutResponseProcessor{
    
    //Implementing the process method
    public static void process(List<IntgMsg__c> responses){ 
        
        //Processing all responses
        for(IntgMsg__c integrationMessage : responses){
            if(integrationMessage.Svc__c != GlobalConstants.INT_CONFIG_SERVICE_VOTER_ID_AUTHENTICATION){
                throw new processException('Error! This is not the correct service'); 
            }
            try{
                //parse response
                voterIdResponseWrapper responseWrapper = (voterIdResponseWrapper) JSON.deserialize(integrationMessage.Resp__c, voterIdResponseWrapper.class); 
                
                
                //check if responseWrapper is empty or not
                if(responseWrapper != null){
                    //Note : Waiting for fields Information which need to be updated 
                    system.debug('responseWrapper '+ responseWrapper);
                    system.debug('responseWrapper get Status code ' +  responseWrapper.statusCode);
                    system.debug('requestId '+ responseWrapper.requestId);
                    
                    if(responseWrapper.statusCode!=null){
                        if(responseWrapper.statusCode==GlobalConstants.karza_Status_101){
                            //updateApplicantKyc(responseWrapper,integrationMessage.RefId__c,integrationMessage.ParentRefId__c);
                            checkValidDOB(integrationMessage);
                            
                        }
                        if(responseWrapper.statusCode!=GlobalConstants.karza_Status_101){
                            String errorMessage=GlobalConstants.karza_Status_Code_Authn_Description.containsKey(responseWrapper.statusCode)?GlobalConstants.karza_Status_Code_Authn_Description.get(responseWrapper.statusCode):'';
                            updateApplicantKYCError(responseWrapper,integrationMessage,errorMessage);
                        } 
                    }
                    else{
                        String errorMessage= KarzaErrorResponseController.getErrorMessage(integrationMessage);
                        updateApplicantKYCError(responseWrapper,integrationMessage,errorMessage);
                    }
                    /*if(integrationMessage.Trigger_Platform_Event__c){
                        publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                        platformWra.intId = integrationMessage.Id; 
                        platformWra.recId = integrationMessage.ParentRefId__c;
                        platformWra.ServiceName = integrationMessage.Svc__c ;
                        platformWra.Status = integrationMessage.Status__c ;
                        
                        if(responseWrapper.statusCode==GlobalConstants.karza_Status_101){
                            platformWra.success=true;
                        }
                        if(responseWrapper.statusCode!=GlobalConstants.karza_Status_101){
                            platformWra.errorMessage=GlobalConstants.karza_Status_Code_Authn_Description.containsKey(responseWrapper.statusCode)?GlobalConstants.karza_Status_Code_Authn_Description.get(responseWrapper.statusCode):'';
                        }
                        
                        publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
                    }*/   
                } 
            }
            //Exception Handling
            catch(Exception ex){
                GlobalUtility.logMessage('Error', 'VoterIdResponseProcessor', 
                                         'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }  
            
        }       
    }
    
    //Update Applicant Kyc Record with response processor data
    public static void updateApplicantKYCError(voterIdResponseWrapper responseWrapper,IntgMsg__c integrationMessage,string errorMessage){
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { ApplKyc__c.SObjectType });
        try{
            if(responseWrapper != null){
                ApplKyc__c AppKyc=New ApplKyc__c();
                AppKyc.Id = integrationMessage.ParentRefId__c;
                AppKyc.ValidationStatus__c= errorMessage !='DOB missing: Kindly provide alternate KYC proof' ?GlobalConstants.MSG_FAILURE : Globalconstants.MSG_SUCCESS ;
                AppKyc.Validation_Error_Message__c=errorMessage;
                AppKyc.DOBValidationStatus__c = GlobalConstants.MSG_FAILURE;
                
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
        if(integrationMessage.Trigger_Platform_Event__c){
            publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
            platformWra.intId = integrationMessage.Id; 
            platformWra.recId = integrationMessage.ParentRefId__c;
            platformWra.ServiceName = integrationMessage.Svc__c ;
            platformWra.Status = integrationMessage.Status__c ;
            platformWra.errorMessage= errorMessage;
            publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
        }
        
        if(errorMessage =='DOB missing: Kindly provide alternate KYC proof'){
            APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Success');
        } 
        else{
            APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Failure');
        }
        
    }
    
    //********************************************************************************************************************************//  
    public Static Void updateApplicantKyc(voterIdResponseWrapper responseWrapper, IntgMsg__c integrationMessage){
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { ApplKyc__c.SObjectType,ApplAddr__c.SObjectType,Applicant__c.SObjectType });
        
        //List<ApplKyc__c>appKyc = [SELECT Id,Applicant__c,kycDoc__c FROM ApplKyc__c WHERE Id=:parentreferenceId and kycDoc__c='Voter Id'];
        //List<ApplAddr__c>  updateAppaddr=[select id,Applicant__r.id,AddrTyp__c from ApplAddr__c where Applicant__r.id=:appKyc[0].Applicant__c and AddrTyp__c='Residence Address'];
        //String DocDtl=[Select Id,DocTyp__c from DocDtl__c where Id=:referenceId].DocTyp__c;
        //List<ApplAddr__c> updateAdrList = new List<ApplAddr__c>();
        //List<Applicant__c> updateAppList = new List<Applicant__c>();
        
        List<DocDtl__c> docDtl =[Select Id, CreatedBY.Name,Applicant_KYC__c,DocCatgry__c,DocTyp__c,DocSubTyp__c,Applicant_KYC__r.Applicant__r.LoanAppln__c,
                                     Applicant_KYC__r.Applicant__c,Applicant_KYC__r.ValidationStatus__c,Applicant_KYC__r.OCRStatus__c,
                                     Applicant_KYC__r.AdrsSplitStatus__c,Applicant_KYC__r.AddrLine1__c,Applicant_KYC__r.AddrLine2__c,
                                     Applicant_KYC__r.Landmark__c,Applicant_KYC__r.Locality__c,Applicant_KYC__r.HouseNo__c,
                                     Applicant_KYC__r.Country__c,Applicant_KYC__r.Pincode__c,Applicant_KYC__r.City__c,
                                     Applicant_KYC__r.State__c FROM DocDtl__c WHERE Id=:integrationMessage.RefId__c];
        List<ApplKyc__c> appKycList = new List<ApplKyc__c>();
        
        if(responseWrapper != null){
            if(integrationMessage.ParentRefId__c!=null){
                ApplKyc__c updateAppKyc = new ApplKyc__c();
                updateAppKyc.id = integrationMessage.ParentRefId__c;//appKyc[0].id ; 
                updateAppKyc.Name__c = responseWrapper.result.name;
                updateAppKyc.kycId__c = responseWrapper.result.epicNo;
                List<String> doi = responseWrapper.result.dob.split('-');      
                if(doi != null && doi.size()>=2){
                    if(doi[0].isNumeric() && doi[1].isNumeric() && doi[2].isNumeric()){
                        updateAppKyc.DtOfBirth__c = Date.newInstance(Integer.valueof(doi[2]),Integer.valueof(doi[1]),Integer.valueof(doi[0]));
                    }
                    
                }
                //updateAppKyc.Address__c =responseWrapper.result.psName;
                updateAppKyc.RelationshipType__c=responseWrapper.result.rlnType;
                if(responseWrapper.result.rlnType=='F'){
                    updateAppKyc.FatherName__c=responseWrapper.result.rlnName;
                }
                else if(responseWrapper.result.rlnType=='H'){
                    updateAppKyc.HusbandName__c=responseWrapper.result.rlnName;
                }
                updateAppKyc.validated__c = true ;
                updateAppKyc.ValidationStatus__c=Globalconstants.MSG_SUCCESS;
                if(responseWrapper.result.gender == 'M'){
                    updateAppKyc.Gender__c = 'M';
                }else if(responseWrapper.result.gender == 'F'){
                    updateAppKyc.Gender__c = 'F';
                }
                
                updateAppKyc.DOBValidationStatus__c= updateAppKyc.DtOfBirth__c!=null? Globalconstants.MSG_SUCCESS : GlobalConstants.MSG_FAILURE; 
                    
                appKycList.add(updateAppKyc);
                
            }
            
            /*if(!updateAppaddr.isempty()){
            if(DocDtl=='Residence Address proof - OVD'){
            ApplAddr__c updateAdd=new ApplAddr__c();
            updateAdd.id=updateAppaddr[0].id;
            updateAdd.State__c=responseWrapper.result.state;
            updateAdd.HouseNo__c=responseWrapper.result.houseNo;
            updateAdd.Pincode__c=responseWrapper.result.pin;
            updateAdd.AddrLine1__c=responseWrapper.result.psName;
            updateAdrList.add(updateAdd);
            }
            
            if(DocDtl=='Identity Proof'){ 
            String Fullname=responseWrapper.result.name;
            String[] nameParts = Fullname.split(' ');
            List<String> doi = responseWrapper.result.dob.split('-');  
            
            Applicant__c updateApp = new Applicant__c();
            updateApp.id = appKyc[0].Applicant__c;
            updateApp.FName__c=nameParts[0];
            updateApp.LName__c=responseWrapper.result.rlnName;
            updateApp.Gender__c=responseWrapper.result.gender;
            
            if(doi != null && doi.size()>=2){
            if(doi[0].isNumeric() && doi[1].isNumeric() && doi[2].isNumeric()){
            updateApp.DOB__c = Date.newInstance(Integer.valueof(doi[2]),Integer.valueof(doi[1]),Integer.valueof(doi[0]));
            }
            
            }
            updateApp.Age__c=Decimal.valueof(responseWrapper.result.age);
            updateAppList.add(updateApp);
            }
            }*/
        }
        
        if(!appKycList.isEmpty()){
            
            List<string> fieldNamesList = New List<string>{'Name__c','kycId__c','VotIdEpicNo__c','DtOfBirth__c','Address__c','validated__c','Gender__c','ValidationStatus__c','RelationshipType__c','FatherName__c','HusbandName__c','DOBValidationStatus__c'};
                String sObjectName = 'ApplKyc__c';
            Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
            fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
            uow.registerDirty(appKycList);
            
        }
        
        /*if(!updateAdrList.isEmpty()){
        List<string> fieldNamesList = New List<string>{'State__c','HouseNo__c','Pincode__c','AddrLine1__c'};
        String sObjectName = 'ApplAddr__c';
        Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
        fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
        uow.registerDirty(updateAdrList);
        }
        
        if(!updateAppList.isEmpty()){
        List<string> fieldNamesList = New List<string>{'FName__c','LName__c','Gender__c','DOB__c','Age__c'};
        String sObjectName = 'Applicant__c';
        Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
        fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
        uow.registerDirty(updateAppList);
        }*/
        uow.commitWork();
        
        if(integrationMessage.Trigger_Platform_Event__c){
            publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
            platformWra.intId = integrationMessage.Id; 
            platformWra.recId = integrationMessage.ParentRefId__c;
            platformWra.ServiceName = integrationMessage.Svc__c ;
            platformWra.Status = integrationMessage.Status__c ;
            platformWra.success=true;
            publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
        }
        if(!docDtl.isEmpty()){
            ApplicantUpdate au = new ApplicantUpdate();
            au.Afterinsert(docDtl);
        }
        APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Success');
    }
    
    public static void checkValidDOB(IntgMsg__c integrationMessage){
        Map<Id,ApplKyc__c> applKyc = new Map<Id,ApplKyc__c>([Select Id,kycDoc__c,DtOfBirth__c FROM ApplKyc__c WHERE Id=:integrationMessage.ParentRefId__c AND kycDoc__c='Voter Id']);
        Map<Id,DocDtl__c> docDtlMap = new Map<Id,DocDtl__c>([Select Id,DocTyp__c from DocDtl__c where Id=:integrationMessage.RefId__c]);
        voterIdResponseWrapper responseWrapper = (voterIdResponseWrapper) JSON.deserialize(integrationMessage.Resp__c, voterIdResponseWrapper.class); 
        if(responseWrapper != null){
            
            if(docDtlMap.containsKey(integrationMessage.RefId__c) && docDtlMap.get(integrationMessage.RefId__c).DocTyp__c=='DOB Proof'){
                Date dateOfBirth;
                List<String> dob = responseWrapper.result.dob.split('-');      
                if(dob != null && dob.size()>=2){
                    if(dob[0].isNumeric() && dob[1].isNumeric() && dob[2].isNumeric()){
                        dateOfBirth = Date.newInstance(Integer.valueof(dob[2]),Integer.valueof(dob[1]),Integer.valueof(dob[0]));
                    }
                    
                }
                if((applKyc.containsKey(integrationMessage.ParentRefId__c) &&  applKyc.get(integrationMessage.ParentRefId__c).DtOfBirth__c!=null) || dateOfBirth!=null){
                    updateApplicantKyc(responseWrapper,integrationMessage);
                }
                else{
                    updateApplicantKYCError(responseWrapper,integrationMessage,'DOB missing: Kindly provide alternate KYC proof');    
                }
            }
            else{
                updateApplicantKyc(responseWrapper,integrationMessage);
            }
        }
    }   
}