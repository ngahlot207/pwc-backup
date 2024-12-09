public class EPFOValidationResponseProcessor implements IintMsgCalloutResponseProcessor{
    
    public static void process(List<IntgMsg__c> responses) {
        
        if(!responses.isEmpty()){
            
            Map<IntgMsg__c,EPFOValidationResponseWrapper> successResponseMap = new Map<IntgMsg__c,EPFOValidationResponseWrapper>();
            Map<IntgMsg__c,String> failureResponseMap = new Map<IntgMsg__c,String>();
            
            for(IntgMsg__c intmsg:responses){
                
                if(string.isNotblank(intmsg.Resp__c)){
                    
                    try{
                        
                        EPFOValidationResponseWrapper  res =(EPFOValidationResponseWrapper) JSON.deserialize(intmsg.Resp__c,EPFOValidationResponseWrapper.class);
                        
                        
                        //Success
                        if(res.statusCode ==GlobalConstants.karza_Status_101){//101
                            successResponseMap.put(intmsg,res);
                        }
                        
                        //Failure
                        else if(res.statusCode !=GlobalConstants.karza_Status_101 || String.isNotBlank(res.error)){
                            failureResponseMap.put(intmsg,GlobalConstants.karza_Status_Code_Authn_Description.ContainsKey(res.statusCode)?GlobalConstants.karza_Status_Code_Authn_Description.get(res.statusCode):res.error);
                        } 
                        
                    }catch(Exception ex){
                        GlobalUtility.logMessage('Error', 'EPFOValidationResponseProcessor class', 
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
    //****************************************************************************************************************************************
    public static void processSuccess(Map<IntgMsg__c,EPFOValidationResponseWrapper> successResp){
        
        try{
            
            Set<Id> applicantIds =new Set<Id>();
            Map<Id,Map<String,APIVer__c>> verificationMap =new Map<Id,Map<String,APIVer__c>>();
            List<APIVer__c> apiverList =new List<APIVer__c>();
            List<APIVerDtl__c> apiVerDtlList =new List<APIVerDtl__c>();
            List<IntgMsg__c> intmsgList =new List<IntgMsg__c>();
            
            //getting ApplicantIDs AND UAN numbers
            for(IntgMsg__c msg:successResp.keyset()){
                
                if(string.isNotblank(msg.RefId__c)){
                    applicantIds.add(msg.RefId__c);
                }
            }
            
            //Get the API verification Record
            for(APIVer__c api:[Select Id,Appl__c,IsLatest__c,RecordType.DeveloperName,Uan__c from APIVer__c Where Appl__c IN:applicantIds 
                               AND IsLatest__c=True AND RecordType.DeveloperName='Employment']){
                                   
                                   if(verificationMap.containsKey(api.Appl__c)){
                                       
                                       verificationMap.get(api.Appl__c).put(api.Uan__c,api);
                                   }
                                   else{
                                       verificationMap.put(api.Appl__c,new Map<string,APIVer__c>{api.Uan__c=>api});
                                   }
                               }
            
            //Process Response
            for(IntgMsg__c msg:successResp.keyset()){
                
                if(string.isNotblank(msg.RefId__c) && verificationMap.containsKey(msg.RefId__c) &&
                   string.isNotblank(msg.ParentRefId__c) && verificationMap.get(msg.RefId__c).containsKey(msg.ParentRefId__c)){
                       
                       EPFOValidationResponseWrapper resp=successResp.get(msg);
                       
                       //APIVerification Record
                       APIVer__c apiVer=verificationMap.get(msg.RefId__c).get(msg.ParentRefId__c);
                       apiVer.EPFOValidationStatus__c= 'Success';
                       
                       if(resp!=null && resp.result!=null){
                           
                           //remarks
                           if(string.isNotblank(resp.result.remark)){
                               apiVer.Remark__c=resp.result.remark;
                           }
                           
                           //personalDetails
                           if(resp.result.personalDetails!=null){
                               
                               EPFOValidationResponseWrapper.PersonalDetails Perdtls =resp.result.personalDetails;
                               
                               if(String.isNotblank(Perdtls.name)){
                                   apiVer.Name__c=Perdtls.name;
                                   
                                   //Creating Integration Message for  Name Smililarity
                                   IntgMsg__c intMsgRec = new IntgMsg__c();
                                   intMsgRec.Name = 'Name Similarity';
                                   intMsgRec.BU__c = 'HL / STL';
                                   intMsgRec.Status__c = GlobalConstants.INT_MSG_STATUS_NEW;
                                   intMsgRec.MStatus__c = GlobalConstants.INT_MSG_MStatus_BLANK;
                                   intMsgRec.Svc__c = 'Name Similarity';
                                   intMsgRec.RefId__c = apiVer.Id;
                                   intMsgRec.RefObj__c = 'APIVer__c';
                                   intMsgRec.ParentRefId__c = apiVer.Appl__c;
                                   intMsgRec.ParentRefObj__c = 'Applicant__c';
                                   intMsgRec.IsActive__c = TRUE;
                                   intmsgList.add(intMsgRec);
                               }
                               
                               if(String.isNotblank(Perdtls.fatherOrHusbandName)){
                                   apiVer.FatherOrHusbandName__c=Perdtls.fatherOrHusbandName;
                               }
                               
                               if(String.isNotblank(Perdtls.aadhaarVerificationStatus)){
                                   apiVer.AadhaarVerification__c=Perdtls.aadhaarVerificationStatus;
                               }
                               
                               if(String.isNotblank(Perdtls.bankAccountStatus)){
                                   apiVer.BnkAccStatus__c=Perdtls.bankAccountStatus;
                               }
                               
                               if(String.isNotblank(Perdtls.panVerificationStatus)){
                                   apiVer.PanVerification__c=Perdtls.panVerificationStatus;
                               }
                               
                               if(String.isNotblank(Perdtls.contactNo)){
                                   apiVer.ContactMobNum__c=Perdtls.contactNo;
                               }
                           }
                           
                           //summary
                           if(resp.result.summary!=null){
                               
                               if(resp.result.summary.minimumWorkExperienceInMonths!=null){
                                   apiVer.WrkExpInMnths__c=resp.result.summary.minimumWorkExperienceInMonths;
                               }
                               
                               //lastEmployer
                               if(resp.result.summary.lastEmployer!=null){
                                   
                                   EPFOValidationResponseWrapper.LastEmployer lastEmp =resp.result.summary.lastEmployer;
                                   
                                   if(String.isNotblank(lastEmp.employerName)){
                                       apiVer.EmployerName__c=lastEmp.employerName;
                                   }
                                   
                                   if(String.isNotblank(lastEmp.startMonthYear)){
                                       apiVer.StartMonthYear__c=lastEmp.startMonthYear;
                                   }
                                   
                                   if(String.isNotblank(lastEmp.lastMonthYear)){
                                       apiVer.LstMonthYear__c=lastEmp.lastMonthYear;
                                   }
                                   
                                   if(lastEmp.vintageInMonths!=null){
                                       apiVer.VintageInMonths__c=lastEmp.vintageInMonths;
                                   }
                               }
                           }
                           
                           //Creating Api Verification Details based on employers Tag
                           if(resp.result.employers!=null){
                               
                               for(EPFOValidationResponseWrapper.Employers emp:resp.result.employers){
                                   
                                   APIVerDtl__c verDtl =new APIVerDtl__c();
                                   verDtl.APIVerification__c=apiVer.Id;
                                   
                                   if(string.isNotblank(emp.startMonthYear)){
                                       verDtl.StartMonthYear__c=emp.startMonthYear;
                                   }
                                   
                                   if(string.isNotblank(emp.lastMonthYear)){
                                       verDtl.LstMonthYear__c=emp.lastMonthYear;
                                   }
                                   
                                   if(string.isNotblank(emp.establishmentId)){
                                       verDtl.EstablishmentId__c=emp.establishmentId;
                                   }
                                   
                                   if(string.isNotblank(emp.establishmentName)){
                                       verDtl.EstablishmentName__c=emp.establishmentName;
                                   }
                                   
                                   if(string.isNotblank(emp.memberId)){
                                       verDtl.memberId__c=emp.memberId;
                                   }
                                   
                                   if(string.isNotblank(emp.exitReason)){
                                       verDtl.ExitReason__c=emp.exitReason;
                                   }
                                   
                                   if(string.isNotblank(emp.status)){
                                       verDtl.Status__c=emp.status;
                                   }
                                   
                                   //Address tag
                                   if(emp.address!=null){
                                       
                                       if(string.isNotblank(emp.address.city)){
                                           verDtl.City__c=emp.address.city;
                                       }
                                       
                                       if(string.isNotblank(emp.address.state)){
                                           verDtl.State__c=emp.address.state;
                                       }
                                       
                                       if(string.isNotblank(emp.address.pincode)){
                                           verDtl.Pincode__c=emp.address.pincode;
                                       }
                                       if(string.isNotblank(emp.address.district)){
                                           verDtl.District__c=emp.address.district;
                                       }
                                       
                                       if(string.isNotblank(emp.address.address)){
                                           verDtl.Address__c=emp.address.address;
                                       }
                                   }
                                   
                                   apiVerDtlList.add(verDtl);
                               }
                           }
                           
                           
                       }
                       
                       apiverList.add(apiVer);
                       
                   }
                
                APICalloutTracker.update_ApiTrackerWithIntMsg(msg.Id,msg.Svc__c, msg.RefId__c, 'Success');
            }
            
            if(!apiverList.isEmpty()){
                Update apiverList;
            }
            
            if(!apiVerDtlList.isEmpty()){
                Insert apiVerDtlList;
            }
            
            if(!intmsgList.isEmpty()){
                Insert intmsgList;
            }
            
        }catch(Exception ex){
            GlobalUtility.logMessage('Error', 'EPFOValidationResponseProcessor', 
                                     'processSuccess', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            
        }
    }
    //**************************************************************************************************************************************** 
    public static void processFailure(Map<IntgMsg__c,String> failureResp){
        
        try{
            
            Set<Id> applicantIds =new Set<Id>();
            Map<Id,Map<String,APIVer__c>> verificationMap =new Map<Id,Map<String,APIVer__c>>();
            List<APIVer__c> apiverList =new List<APIVer__c>();
            
            
            //getting ApplicantIDs AND UAN numbers
            for(IntgMsg__c msg:failureResp.keyset()){
                
                if(string.isNotblank(msg.RefId__c)){
                    applicantIds.add(msg.RefId__c);
                }
            }
            
            //Get the API verification Record
            for(APIVer__c api:[Select Id,Appl__c,IsLatest__c,RecordType.DeveloperName,Uan__c from APIVer__c Where Appl__c IN:applicantIds 
                               AND IsLatest__c=True AND RecordType.DeveloperName='Employment']){
                                   
                                   if(verificationMap.containsKey(api.Appl__c)){
                                       
                                       verificationMap.get(api.Appl__c).put(api.Uan__c,api);
                                   }
                                   else{
                                       verificationMap.put(api.Appl__c,new Map<string,APIVer__c>{api.Uan__c=>api});
                                   }
                               }
            
            //Process Response
            for(IntgMsg__c msg:failureResp.keyset()){
                
                
                if(string.isNotblank(msg.RefId__c) && verificationMap.containsKey(msg.RefId__c) &&
                   string.isNotblank(msg.ParentRefId__c) && verificationMap.get(msg.RefId__c).containsKey(msg.ParentRefId__c)){
                       
                       APIVer__c apiVer=verificationMap.get(msg.RefId__c).get(msg.ParentRefId__c);
                       apiVer.EPFOValidationStatus__c= 'Failure';
                       apiVer.IntegrationErrorMessage__c=failureResp.get(msg);
                       apiverList.add(apiVer);
                   }
                
                APICalloutTracker.update_ApiTrackerWithIntMsg(msg.Id,msg.Svc__c, msg.RefId__c, 'Failure');
            }
            
            
            if(!apiverList.isEmpty()){
                Update apiverList;
            }
            
        }catch(Exception ex){
            GlobalUtility.logMessage('Error', 'EPFOValidationResponseProcessor', 
                                     'processFailure', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            
        }
    }
}