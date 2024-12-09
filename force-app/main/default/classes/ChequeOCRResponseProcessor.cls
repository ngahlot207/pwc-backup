public class ChequeOCRResponseProcessor implements IintMsgCalloutResponseProcessor{
    
    //Implementing the process method
    public static void process(List<IntgMsg__c> responses){
        
        for(IntgMsg__c integrationMessage : responses){
            
            if(integrationMessage.Svc__c != 'Cheque OCR'
               && integrationMessage.BU__c != GlobalConstants.INT_MSG_BU_TYPE){
                   throw new processException('Error! This is not the correct service'); 
               }
            try{
                ChequeOCRResponseWrapper responseWrapper = (ChequeOCRResponseWrapper) JSON.deserialize(integrationMessage.Resp__c, ChequeOCRResponseWrapper.class); 
                //check if responseWrapper is empty or not                
                if(responseWrapper != null){
                    
                    
                    if(responseWrapper.statusCode==GlobalConstants.karza_Status_101){
                        updateApplicantIMD(responseWrapper,integrationMessage.ParentRefId__c);
                    }
                    if(responseWrapper.statusCode!=GlobalConstants.karza_Status_101){
                        updateApplicantIMDError(responseWrapper,integrationMessage.ParentRefId__c);
                    }
                    if(integrationMessage.Trigger_Platform_Event__c){
                        publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                        platformWra.intId = integrationMessage.Id; 
                        platformWra.recId = integrationMessage.ParentRefId__c;
                        platformWra.ServiceName = integrationMessage.Svc__c ;
                        platformWra.Status = integrationMessage.Status__c ;
                        
                        if(responseWrapper.statusCode!=null){
                            if(responseWrapper.statusCode==GlobalConstants.karza_Status_101){
                                platformWra.success=true;
                            }
                            if(responseWrapper.statusCode!=GlobalConstants.karza_Status_101){
                                platformWra.errorMessage=GlobalConstants.karza_Status_Code_OCR_Description.containsKey(responseWrapper.statusCode)?GlobalConstants.karza_Status_Code_OCR_Description.get(responseWrapper.statusCode):'';
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
                GlobalUtility.logMessage('Error', 'ChequeOCRResponseProcessor class', 
                                         'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            } 
        }
    }
    
    
    public static void updateApplicantIMD(ChequeOCRResponseWrapper responseWrapper,Id referenceId){
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { ApplIMD__c.SObjectType });
        
        try{
            if(responseWrapper != null){
                ApplIMD__c applIMD = new ApplIMD__c();
                applIMD.Id=referenceId;
                applIMD.ChequeOCRStatus__c = Globalconstants.MSG_SUCCESS;
                
                if(!String.isBlank(responseWrapper.result.accNo)){
                    applIMD.BankAccountNo__c =responseWrapper.result.accNo;
                }
                if(!String.isBlank(responseWrapper.result.chequeNo)){
                    applIMD.InstrumentNo__c =responseWrapper.result.chequeNo;
                }
                
                if(!String.isBlank(responseWrapper.result.micr)){
                    
                    List<MICRCodeMstr__c> micrList = [Select Id,City__c,City__r.Name,Bank__c,Bank__r.Name,BrchName__c,BanckBrchId__c,MICRCode__c FROM MICRCodeMstr__c WHERE MICRCode__c=:responseWrapper.result.micr];
                    
                    
                    applIMD.MICRCode__c = responseWrapper.result.micr;
                    if(!micrList.isEmpty()){
                   		MICRCodeMstr__c micr = micrList[0];
                        applIMD.BankBrch__c = micr.BrchName__c; 
                        applIMD.BankName__c = micr.Bank__r.Name;
                        applIMD.BankId__c = micr.Bank__c;
                        applIMD.City__c = micr.City__r.Name;
                        applIMD.CityId__c = micr.City__c;
                    }
                    else{
                        
                        if(!String.isBlank(responseWrapper.result.bank)){
                            applIMD.BankName__c =responseWrapper.result.bank;
                        }
                        if(!String.isBlank(responseWrapper.result.bankDetails.branch)){
                            applIMD.BankBrch__c = responseWrapper.result.bankDetails.branch;
                        }
                        if(!String.isBlank(responseWrapper.result.bankDetails.city)){
                            applIMD.City__c = responseWrapper.result.bankDetails.city;
                        }
                    }  
                }
                
                if(applIMD != null){
                    List<string> fieldNamesList = New List<string>{'ChequeOCRStatus__c','BankAccountNo__c','InstrumentNo__c','MICRCode__c','BankBrch__c','BankName__c','BankId__c','City__c','CityId__c'};
                    String sObjectName = 'ApplIMD__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                    uow.registerDirty(applIMD);
                }
            }
        }
        catch(exception ex){
            system.debug('error message and line number '+ ex.getMessage() + 'line' + ex.getLineNumber());
        }       
        uow.commitWork();
        
    }
    
    public static void updateApplicantIMDError(ChequeOCRResponseWrapper responseWrapper,Id referenceId){
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { ApplKyc__c.SObjectType });
        try{
            if(responseWrapper != null){
                ApplIMD__c applIMD=New ApplIMD__c();
                applIMD.Id = referenceId;
                applIMD.ChequeOCRStatus__c=GlobalConstants.MSG_FAILURE;
                
                if(applIMD != null){
                    List<string> fieldNamesList = New List<string>{'ChequeOCRStatus__c'};
                    String sObjectName = 'ApplIMD__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                    uow.registerDirty(applIMD);
                }
            }
        }
        catch(exception ex){
            system.debug('error message and line number '+ ex.getMessage() + 'line' + ex.getLineNumber());
        }	     
        uow.commitWork();
        
    }   
}