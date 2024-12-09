public class AddressSplitAPIResponseProcessor implements IintMsgCalloutResponseProcessor {
    
    public static void process(List<IntgMsg__c> responses) {
        
        if(!responses.isEmpty()){
            
            Map<IntgMsg__c,AddressSplitAPIResponseWrapper> successResponseMap = new Map<IntgMsg__c,AddressSplitAPIResponseWrapper>();
            Map<IntgMsg__c,String> failureResponseMap = new Map<IntgMsg__c,String>();
            
            for(IntgMsg__c intmsg:responses){
                
                try{ 
                    
                    AddressSplitAPIResponseWrapper res =(AddressSplitAPIResponseWrapper) JSON.deserialize(intmsg.Resp__c.replace('status-code','statuscode'),AddressSplitAPIResponseWrapper.class);
                    
                    //Success
                    if(res.statusCode ==String.valueOf(GlobalConstants.karza_Status_101) && res.result!=null){
                        successResponseMap.put(intmsg,res);
                        
                    }
                    //Failure
                    else if(res.statusCode !=String.valueOf(GlobalConstants.karza_Status_101)){
                        failureResponseMap.put(intmsg,GlobalConstants.karza_Status_Code_Authn_Description.ContainsKey(Integer.valueOf(res.statusCode))?GlobalConstants.karza_Status_Code_Authn_Description.get(Integer.valueOf(res.statusCode)):'');
                    }
                    
                    
                }catch(Exception ex){
                    GlobalUtility.logMessage('Error', 'AddressSplitAPIResponseProcessor class', 
                                             'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
                    
                    failureResponseMap.put(intmsg,IntegrationUtility.getCustomErrorMessage(ex.getMessage().substringBefore(':')));
                    
                }
                
            }
            
            
            if(!successResponseMap.isempty()){
                processSuccess(successResponseMap);
            }
            
            if(!failureResponseMap.isempty()){
                processFailure(failureResponseMap);
            }
        }
        
        
    }

    //*************************************************************************************************************************************
    public static void processSuccess(Map<IntgMsg__c,AddressSplitAPIResponseWrapper> successResp){
        

        try{
            
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> { ApplKyc__c.SObjectType});
            
            List<ApplKyc__c> applKycList =new List<ApplKyc__c>();
            Set<Id> docIds =new Set<Id>();
            
            for(IntgMsg__c intmsg:successResp.keyset()){
                
                if(successResp.containsKey(intmsg) && String.isNotblank(intmsg.ParentRefId__c)){
                    
                    AddressSplitAPIResponseWrapper res =successResp.get(intmsg);
                    
                    if(res!=null && res.result!=null){
                        
                        
                        
                        
                        ApplKyc__c kyc =new ApplKyc__c();
                        kyc.Id=intmsg.ParentRefId__c;
                        kyc.AdrsSplitStatus__c='Success';
                        kyc.AdrsSplitErrMess__c='';
                        
                        //adding DocIds
                        if(String.isNotblank(intmsg.RefId__c)){
                            docIds.add(intmsg.RefId__c);
                        }
                        
                        //House No
                        if(String.isNotBlank(res.result.Floor) || String.isNotBlank(res.result.House)){
                            kyc.HouseNo__c=concatenateFields(res.result.Floor,res.result.House);
                        }
                        
                        //Address Line 1
                        if(String.isNotBlank(res.result.Building)){
                            kyc.AddrLine1__c=res.result.Building;
                        }
                        
                        //Address Line 2
                        if(String.isNotBlank(res.result.Complex) || String.isNotBlank(res.result.Street) ){
                            kyc.AddrLine2__c=concatenateFields(res.result.Complex,res.result.Street);
                        }
                        
                        //Landmark
                        if(String.isNotBlank(res.result.Landmark) || String.isNotBlank(res.result.Untagged)){
                            kyc.Landmark__c=concatenateFields(res.result.Landmark,res.result.Untagged);
                            
                        }
                        
                        //Area of Locality
                        if(String.isNotBlank(res.result.locality)){
                            kyc.Locality__c=res.result.locality;
                        }
                        //Pincode
                        if(String.isNotBlank(res.result.Pin)){
                            kyc.Pincode__c=res.result.Pin;
                        }
                        
                        //City
                        if(String.isNotBlank(res.result.City)){
                            kyc.City__c=res.result.City;
                        }
                        
                        //District
                        if(String.isNotBlank(res.result.District)){
                            kyc.District__c=res.result.District;
                        }
                        
                        //State
                        if(String.isNotBlank(res.result.State)){
                            kyc.State__c=res.result.State;
                        }
                        
                        applKycList.add(kyc);
                    }
                    
                    
                    if(intmsg.Trigger_Platform_Event__c){
                            publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                            platformWra.intId = intmsg.Id; 
                            platformWra.recId = intmsg.ParentRefId__c;
                            platformWra.ServiceName = intmsg.Svc__c ;
                            platformWra.Status = intmsg.Status__c ;
                            platformWra.success=true;
                            publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
                        } 
                        
                        APICalloutTracker.update_ApiTrackerWithIntMsg(intmsg.Id,intmsg.Svc__c, intmsg.ParentRefId__c, 'Success');
                }
            }
            
            
            //Updating the Applicant KYC
                if(!applKycList.isEmpty()) {
                    String sObjectName = 'ApplKyc__c';
                    List<String> fieldNamesList = new List<String>{'HouseNo__c','AddrLine1__c','AddrLine2__c','Landmark__c',
                        'Locality__c','Pincode__c','AdrsSplitStatus__c','AdrsSplitErrMess__c'};
                            Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                    uow.registerDirty(applKycList);
                }
                uow.commitWork();
            
            if(!docIds.isEmpty()){
               
                Map<DocDtl__c,ApplKyc__c> docKycMap=new Map<DocDtl__c,ApplKyc__c>();
                Set<String> docTypeSet =new Set<String> {'Residence Address proof - OVD','Residence Address proof - Deemed OVD',
                                                         'Registered office - Address Proof','Principal Place of Business - Address Proof'};
                    
                /*List<DocDtl__c> docDtl =[Select Id,Applicant_KYC__c,DocTyp__c,DocCatgry__c,DocSubTyp__c,Applicant_KYC__r.Applicant__r.LoanAppln__c,
                                         Applicant_KYC__r.Applicant__c,Applicant_KYC__r.ValidationStatus__c,Applicant_KYC__r.OCRStatus__c,
                                         Applicant_KYC__r.AdrsSplitStatus__c,Applicant_KYC__r.AddrLine1__c,Applicant_KYC__r.AddrLine2__c,
                                         Applicant_KYC__r.Landmark__c,Applicant_KYC__r.Locality__c,Applicant_KYC__r.HouseNo__c,
                                         Applicant_KYC__r.Country__c,Applicant_KYC__r.Pincode__c,Applicant_KYC__r.City__c,
                                         Applicant_KYC__r.State__c FROM DocDtl__c WHERE Id IN:docIds];*/
                for (DocDtl__c doc :[Select Id,Applicant_KYC__c,DocTyp__c,DocCatgry__c,DocSubTyp__c,Applicant_KYC__r.Applicant__r.LoanAppln__c,
                                         Applicant_KYC__r.Applicant__c,Applicant_KYC__r.ValidationStatus__c,Applicant_KYC__r.OCRStatus__c,
                                         Applicant_KYC__r.AdrsSplitStatus__c,Applicant_KYC__r.AddrLine1__c,Applicant_KYC__r.AddrLine2__c,
                                         Applicant_KYC__r.Landmark__c,Applicant_KYC__r.Locality__c,Applicant_KYC__r.HouseNo__c,
                                         Applicant_KYC__r.Country__c,Applicant_KYC__r.Pincode__c,Applicant_KYC__r.City__c,
                                         Applicant_KYC__r.State__c FROM DocDtl__c WHERE Id IN:docIds AND
                                        DocTyp__c IN:docTypeSet]) {
                                             
                                             if(doc.Applicant_KYC__c!=null){
                                               docKycMap.put(doc,doc.Applicant_KYC__r);  
                                             }
                    
                }
                
                if(!docKycMap.isEmpty()){
                    
                    //ApplicantUpdate au = new ApplicantUpdate();
                    //au.Afterinsert(docDtl);
                    ApplicantUpdate.upsertApplicantAddress(docKycMap);
                }
            }
            
        }catch(Exception ex){
                GlobalUtility.logMessage('Error', 'AddressSplitAPIResponseProcessor class', 
                                         'processSuccess', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
        
    }
    //*************************************************************************************************************************************
    public static void processFailure(Map<IntgMsg__c,String> failureResp){
        
        
        try{
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> {ApplKyc__c.SObjectType});
            
            List<ApplKyc__c> appKycEmpList=new List<ApplKyc__c>();
            
            
            for(IntgMsg__c intmsg:failureResp.keyset()){
                
                if(failureResp.containsKey(intmsg) && String.isNotblank(intmsg.ParentRefId__c)){
                    
                    ApplKyc__c kyc =new ApplKyc__c();
                    kyc.Id=intmsg.ParentRefId__c;
                    kyc.AdrsSplitStatus__c='Failure';
                    kyc.AdrsSplitErrMess__c=failureResp.get(intmsg)!=null?failureResp.get(intmsg):'';
                    appKycEmpList.add(kyc);
                    
                }
                if(intmsg.Trigger_Platform_Event__c){
                        publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                        platformWra.intId = intmsg.Id; 
                        platformWra.recId = intmsg.ParentRefId__c;
                        platformWra.ServiceName = intmsg.Svc__c ;
                        platformWra.Status = intmsg.Status__c ;
                        platformWra.errorMessage=failureResp.get(intmsg)!=null?failureResp.get(intmsg):'';
                        publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
                      } 
					APICalloutTracker.update_ApiTrackerWithIntMsg(intmsg.Id,intmsg.Svc__c, intmsg.RefId__c, 'Failure');
                
            }
            
             //Updating the Applicant Kyc
            if(!appKycEmpList.isEmpty()) {
                String sObjectName = 'ApplKyc__c';
                List<String> fieldNamesList = new List<String>{'AdrsSplitStatus__c','AdrsSplitErrMess__c'};
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                uow.registerDirty(appKycEmpList);
            }
            uow.commitWork();
            
            
        }catch (Exception ex) {
            GlobalUtility.logMessage('Error', 'AddressSplitAPIResponseProcessor', 
                                     'processFailure', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        
       
    }
    //*************************************************************************************************************************************
    public static String concatenateFields(String value1, String value2) {
        
        String concatenatedString = '';
        
        try{
            if (String.isNotBlank(value1)) {
                concatenatedString += value1 + ' ';
            }
            
            if (String.isNotBlank(value2)) {
                concatenatedString += value2;
            }
            
        }catch(Exception ex){
            GlobalUtility.logMessage('Error', 'AddressSplitAPIResponseProcessor class', 
                                     'concatenateFields', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        
        return concatenatedString;
    }
}