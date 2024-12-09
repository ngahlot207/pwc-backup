public class ENPAResponseProcessor implements IintMsgCalloutResponseProcessor{
    
    //Implementing the process method
    public static void process(List<IntgMsg__c> responses){ 
        Map<IntgMsg__c,ENPAResponseWrapper> successResponseMap = new Map<IntgMsg__c,ENPAResponseWrapper>();
        Map<IntgMsg__c,String> failureResponseMap = new Map<IntgMsg__c,String>();
        Set<Id>applicantIds = new Set<Id>();
        for(IntgMsg__c integrationMessage : responses){
            if(integrationMessage.Svc__c != 'ENPADeatils' && integrationMessage.BU__c != GlobalConstants.INT_MSG_BU_TYPE){
                throw new processException('Error! This is not the correct service'); 
            }
            
            if(String.isNotBlank(integrationMessage.RefId__c) && String.isNotBlank(integrationMessage.RefObj__c) && integrationMessage.RefObj__c == 'Applicant__c'){
                applicantIds.add(integrationMessage.RefId__c);
            }
            else if(String.isNotBlank(integrationMessage.ParentRefId__c) && String.isNotBlank(integrationMessage.ParentRefObj__c) && integrationMessage.ParentRefObj__c == 'Applicant__c'){
                applicantIds.add(integrationMessage.ParentRefId__c);
            }
            
            try{
                ENPAResponseWrapper responseWrapper = (ENPAResponseWrapper) JSON.deserialize(integrationMessage.Resp__c, ENPAResponseWrapper.class); 
                if(responseWrapper != null){
                    if(responseWrapper.status==1){
                        //processSuccessResponse(responseWrapper,integrationMessage);
                        successResponseMap.put(integrationMessage,responseWrapper);
                    }
                    else{
                        //processErrorResponse(responseWrapper,integrationMessage);
                        failureResponseMap.put(integrationMessage,(String.isNotBlank(responseWrapper.message) ? responseWrapper.message:''));
                    }
                }
            }
            //Exception Handling
            catch(Exception ex){
                failureResponseMap.put(integrationMessage,IntegrationUtility.getCustomErrorMessage(ex.getMessage().substringBefore(':')));
                GlobalUtility.logMessage('Error', 'ENPAResponseProcessor class', 
                                         'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            } 
        }
        
        Map<Id,Applicant__c> applicantMap = new Map<Id,Applicant__c>([Select Id,LoanAppln__c,LoanAppln__r.Stage__c,IntegrationStatus__c,IntegrationErrorMessage__c from Applicant__c WHERE ID IN:applicantIds]);
        if(!successResponseMap.isEmpty()){
            processSuccess(applicantMap,successResponseMap);
        }
        if(!failureResponseMap.isEmpty()){
            processFailure(applicantMap,failureResponseMap);
        }
    }
    
    
    
    public static void processSuccessResponse(ENPAResponseWrapper responseWrapper, IntgMsg__c integrationMessage){
        try{
            Map<Id,Applicant__c> applMap = new Map<Id,Applicant__c>([Select Id,LoanAppln__c,LoanAppln__r.Stage__c,LoanAppln__r.Product__c,IntegrationStatus__c,IntegrationErrorMessage__c from Applicant__c where Id=:integrationMessage.RefId__c]);
            Map<String,DedupeResponse__c> existingENPAMap = new Map<String,DedupeResponse__c>();
            List<Applicant__c> updateApplList = new List<Applicant__c>();            
            if(applMap.containsKey(integrationMessage.RefId__c)){
                if(responseWrapper!=null){
                    List<IntgMsg__c> createRequestList = new List<IntgMsg__c>();
                    Id enpaRecordTypeId = Schema.SObjectType.DedupeResponse__c.getRecordTypeInfosByDeveloperName().get('ENPA').getRecordTypeId();
                    for(DedupeResponse__c resp : [Select Id,Lan__c FROM DedupeResponse__c WHERE Applicant__c=:integrationMessage.RefId__c AND LoanAppln__c=:applMap.get(integrationMessage.RefId__c).LoanAppln__c AND RecordTypeId=:enpaRecordTypeId]){
                        existingENPAMap.put(resp.Lan__c,resp);
                    }
                    //List<DedupeResponse__c> existingENPAList = [Select Id,Lan__c,IsLatest__c FROM DedupeResponse__c WHERE IsLatest__c=True AND Applicant__c=:integrationMessage.RefId__c AND LoanAppln__c=:applMap.get(integrationMessage.RefId__c).LoanAppln__c AND RecordTypeId=:enpaRecordTypeId];
                    Applicant__c appl= new Applicant__c();
                    appl.Id=integrationMessage.RefId__c;
                    appl.IntegrationStatus__c= replaceAndUpdateString('ENPA', 'ENPA: Success', applMap.get(integrationMessage.RefId__c).IntegrationStatus__c,';');
                    appl.IntegrationErrorMessage__c=replaceAndUpdateString('ENPA', '', applMap.get(integrationMessage.RefId__c).IntegrationErrorMessage__c,';');
                    if(applMap.get(integrationMessage.RefId__c).LoanAppln__c !=null && applMap.get(integrationMessage.RefId__c).LoanAppln__r.Stage__c=='UnderWriting'){
                        appl.IsENPSRunAtUW__c =true;
                    }
                    updateApplList.add(appl);
                    List<DedupeResponse__c> enpaList = new List<DedupeResponse__c>();

                    Set<String> finalAssetCls = new Set<String>{'SUB','DB1','DB2','DB3','LOS','BAD','DEBT'};

                    Boolean updLoanStatus = false;//BL,PL product 
                    
                    if(!responseWrapper.Data.isEmpty()){
                        for(ENPAResponseWrapper.Data data : responseWrapper.Data){
                            DedupeResponse__c enpaRes = new DedupeResponse__c();
                            enpaRes.Applicant__c=integrationMessage.RefId__c;
                            enpaRes.LoanAppln__c=applMap.get(integrationMessage.RefId__c).LoanAppln__c;
                            enpaRes.RecordTypeId=enpaRecordTypeId;
                            enpaRes.IsLatest__c=true;
                            enpaRes.LatestReportTime__c =System.now();
                            
                            //for BIL new build
                            if(finalAssetCls.contains(data.FinalAssetClass) || (data.FRAUD_FLAG !=null && data.FRAUD_FLAG == 'External') || (data.Writeoff_Flag !=null && data.Writeoff_Flag == 'Y') || (data.Settled !=null && data.Settled == 'Y')){
                                //application is hard rejected && loan app status__c to rejected
                                updLoanStatus=true;
                            }
                            //for BIL new build End

                            if(String.isNotBlank(data.CustomerID)){
                                enpaRes.CustomerId__c = data.CustomerID;
                            }
                            if(String.isNotBlank(data.LAN)){
                                enpaRes.Lan__c = data.LAN;
                                if(existingENPAMap.containsKey(data.LAN)){
                                    enpaRes.Id = existingENPAMap.get(data.LAN).Id;
                                }
                            }
                            if(String.isNotBlank(data.UCIC)){
                                enpaRes.UCID__c = data.UCIC;
                            }
                            if(String.isNotBlank(data.CustomerName)){
                                enpaRes.CustomerName__c = data.CustomerName;
                            }
                            if(String.isNotBlank(data.AUM)){
                                enpaRes.AUM__c = Decimal.valueOf(data.AUM);
                            }
                            if(String.isNotBlank(data.AUF)){
                                enpaRes.AUF__c = Decimal.valueOf(data.AUF);
                            }
                            if(String.isNotBlank(data.DisbursementDate) && data.DisbursementDate!=null ){
                                List<String>dateValue =data.DisbursementDate.split('[- : .]');
                                if(dateValue.size()>=3){
                                    enpaRes.LoanDisbDate__c= Date.newInstance(Integer.valueOf(dateValue[0]), Integer.valueOf(dateValue[1]), Integer.valueOf(dateValue[2]));
                                }
                            }
                            if(String.isNotBlank(data.DPD)){
                                enpaRes.SystemDPD__c = data.DPD;
                            }
                            if(String.isNotBlank(data.UCID_Level_DPD)){
                                enpaRes.DPD__c = data.UCID_Level_DPD;
                            }
                            if(String.isNotBlank(data.NPA_DATE) && data.NPA_DATE!=null ){ 
                                List<String>dateValue =data.NPA_DATE.split('[- : .]');
                                if(dateValue.size()>=3){
                                    enpaRes.NPADate__c= Date.newInstance(Integer.valueOf(dateValue[0]), Integer.valueOf(dateValue[1]), Integer.valueOf(dateValue[2]));
                                }
                            }
                            if(String.isNotBlank(data.Product)){
                                enpaRes.LoanType__c = data.Product;
                            }
                            if(String.isNotBlank(data.SecuritizationFlg)){
                                enpaRes.SecuritisationStatus__c = data.SecuritizationFlg;
                            }

                            //New Fields LAK-6985
                            
                            if(String.isNotBlank(data.FRAUD_FLAG)){
                                enpaRes.FraudFlag__c = data.FRAUD_FLAG;
                            }
                            if(String.isNotBlank(data.Writeoff_Flag)){
                                enpaRes.WriteOffFlag__c = data.Writeoff_Flag;
                            }
                            
                            if(String.isNotBlank(data.Writeoff_Date) && data.Writeoff_Date!=null ){ 
                                List<String> dateValue =data.Writeoff_Date.split('[- : .]');
                                if(dateValue.size()>=3){
                                    enpaRes.WriteoffDate__c= Date.newInstance(Integer.valueOf(dateValue[0]), Integer.valueOf(dateValue[1]), Integer.valueOf(dateValue[2]));
                                }
                            }
                            
                            if(String.isNotBlank(data.Settled)){
                                enpaRes.Settled__c = data.Settled;
                            }
                            
                            if(String.isNotBlank(data.Settled_Date) && data.Settled_Date!=null ){ 
                                List<String> dateValue =data.Settled_Date.split('[- : .]');
                                if(dateValue.size()>=3){
                                    enpaRes.SettledDate__c= Date.newInstance(Integer.valueOf(dateValue[0]), Integer.valueOf(dateValue[1]), Integer.valueOf(dateValue[2]));
                                }
                            }

                            //New Fields Changes Done

                            if(String.isNotBlank(data.Tenure)){
                                enpaRes.Tenure__c = Decimal.valueOf(data.Tenure);
                            }
                            if(String.isNotBlank(data.LINKED_UCIC)){
                                enpaRes.LinkedUCIC__c = data.LINKED_UCIC;
                            }
                            if(String.isNotBlank(data.FinalAssetClass)){
                                enpaRes.FinalAssetClass__c = data.FinalAssetClass;
                            }
                            if(String.isNotBlank(data.TotalProvisionWithoutVarAmount)){
                                enpaRes.TotalProvisionWithoutVarAmount__c = Decimal.valueOf(data.TotalProvisionWithoutVarAmount);
                            }
                            if(String.isNotBlank(data.TotalProvisionWithVarAmount)){
                                enpaRes.TotalProvisionWithVarAmount__c = Decimal.valueOf(data.TotalProvisionWithVarAmount);
                            }
                            if(String.isNotBlank(data.LoanAmount)){
                                enpaRes.LoanAmount__c = Decimal.valueOf(data.LoanAmount);
                            }
                            enpaList.add(enpaRes);
                        }
                    }
                    system.debug(enpaList.size() + ':'+enpaList);

                    //Trigger Bureau and BRE && //apply check for screen name
                    if(updLoanStatus == false && applMap.containsKey(integrationMessage.RefId__c) && (applMap.get(integrationMessage.RefId__c).LoanAppln__r.Product__c == 'Business Loan' ||  applMap.get(integrationMessage.RefId__c).LoanAppln__r.Product__c == 'Personal Loan') && integrationMessage.TriggFrmScrn__c !=null && integrationMessage.TriggFrmScrn__c == 'Applicant Details'){

                        IntgMsg__c intmsg =new IntgMsg__c();
                        intmsg.Name='Consumer ACK Request';
                        intmsg.BU__c='HL / STL';
                        intmsg.RefId__c=integrationMessage.RefId__c;
                        intmsg.Status__c='New';
                        intmsg.MStatus__c='Blank';
                        intmsg.RefObj__c='Applicant__c';
                        intmsg.Svc__c='Consumer ACK Request';
                        intmsg.ParentRefId__c=applMap.get(integrationMessage.RefId__c).LoanAppln__c;
                        intmsg.ParentRefObj__c='LoanAppl__c';
                        intmsg.IsActive__c=true;
                        intmsg.TriggFrmScrn__c = integrationMessage.TriggFrmScrn__c;
                        createRequestList.add(intmsg);

                    }else if(updLoanStatus == true && applMap.containsKey(integrationMessage.RefId__c) && (applMap.get(integrationMessage.RefId__c).LoanAppln__r.Product__c == 'Business Loan' ||  applMap.get(integrationMessage.RefId__c).LoanAppln__r.Product__c == 'Personal Loan') && integrationMessage.TriggFrmScrn__c !=null && integrationMessage.TriggFrmScrn__c == 'Applicant Details'){
                        LoanAppl__c loanAppObj = new LoanAppl__c();
                        loanAppObj.Id= applMap.get(integrationMessage.RefId__c).LoanAppln__c;
                        loanAppObj.Status__c = 'Rejected'; 
                        update loanAppObj;
                    }else{
                        System.debug('Condition did not match for Consumer ACK Request');
                    }


                    
                    if(!enpaList.isEmpty()){
                        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { DedupeResponse__c.SObjectType });
                        //List<string> fieldNamesList = New List<string>{'Applicant__c','LoanAppln__c','RecordTypeId','IsLatest__c','CustomerId__c','Lan__c','UCID__c','CustomerName__c','AUM__c','AUF__c','DPD__c','NPADate__c','LinkedUCIC__c','FinalAssetClass__c','TotalProvisionWithoutVarAmount__c','TotalProvisionWithVarAmount__c','LoanAmount__c'};
                        //   String sObjectName = 'DedupeResponse__c';
                        //Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                        //fflib_SecurityUtils.checkInsert(objType,fieldNamesList);
                        uow.registerUpsert(enpaList);
                        uow.commitWork();
                        
                    }
                    if(!updateApplList.isEmpty()){
                        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { Applicant__c.SObjectType });
                        List<string> fieldNamesList = New List<string>{'IntegrationStatus__c','IntegrationErrorMessage__c','IsENPSRunAtUW__c'};
                            String sObjectName = 'Applicant__c';
                        Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                        fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                        uow.registerDirty(updateApplList);
                        uow.commitWork();
                    }
                    
                    /*if(!existingENPAList.isEmpty()){
                        updateExistingENPAResponse(existingENPAList);
                    }*/
                    
                    if(integrationMessage.Trigger_Platform_Event__c){
                        publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                        platformWra.intId = integrationMessage.Id; 
                        platformWra.recId = integrationMessage.ParentRefId__c;
                        platformWra.ServiceName = integrationMessage.Svc__c ;
                        platformWra.Status = integrationMessage.Status__c ;
                        platformWra.success = True;
                        publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
                    }

                    if(!createRequestList.isEmpty()){
                        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> { IntgMsg__c.SObjectType});
                        List<string> fieldNamesList = New List<string>{'Name','BU__c','RefId__c','Status__c','MStatus__c','RefObj__c','Svc__c','ApiVendor__c',
                            'IsActive__c','ParentRefId__c','ParentRefObj__c'};
                        String sObjectName = 'IntgMsg__c';
                        Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                        fflib_SecurityUtils.checkInsert(objType,fieldNamesList); 
                        uow.registerNew(createRequestList);
                        uow.commitWork();
                    }
                    
                    APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Success');
                }
            } 
        }
        catch(exception ex){
            system.debug('error message and line number '+ ex.getMessage() + 'line' + ex.getLineNumber());
        }  
        
    }
    
    public static void processSuccess(Map<Id,Applicant__c> applicantMap,Map<IntgMsg__c,ENPAResponseWrapper> successResponses){
        try{
            if(!successResponses.isEmpty()){
                Map<String,Map<String,DedupeResponse__c>> existingENPAMap = new Map<String,Map<String,DedupeResponse__c>>();
                List<Applicant__c> updateApplList = new List<Applicant__c>();
                List<DedupeResponse__c> enpaList = new List<DedupeResponse__c>();
                
                Id enpaRecordTypeId = Schema.SObjectType.DedupeResponse__c.getRecordTypeInfosByDeveloperName().get('ENPA').getRecordTypeId();
                for(DedupeResponse__c resp : [Select Id,Applicant__c,Lan__c FROM DedupeResponse__c WHERE Applicant__c IN:applicantMap.keySet() AND RecordTypeId=:enpaRecordTypeId]){
                    if(existingENPAMap.containsKey(resp.Applicant__c)){
                        existingENPAMap.get(resp.Applicant__c).put(resp.Lan__c,resp);
                    }
                    else{
                        existingENPAMap.put(resp.Applicant__c,new Map<String,DedupeResponse__c>{resp.Lan__c =>resp});
                    }
                }
                
                for(IntgMsg__c integrationMessage : successResponses.keySet()){
                    ENPAResponseWrapper responseWrapper  = successResponses.get(integrationMessage);
                    
                    Boolean enpaFlag = false;
                    
                    if(responseWrapper!=null){
                        if((String.isNotBlank(integrationMessage.RefId__c) && String.isNotBlank(integrationMessage.RefObj__c) && integrationMessage.RefObj__c == 'Applicant__c') ||
                           (String.isNotBlank(integrationMessage.ParentRefId__c) && String.isNotBlank(integrationMessage.ParentRefObj__c) && integrationMessage.ParentRefObj__c == 'Applicant__c')
                          ){
                              String key = integrationMessage.RefObj__c == 'Applicant__c' ? integrationMessage.RefId__c : integrationMessage.ParentRefId__c ;
                              Applicant__c appl= new Applicant__c();
                              appl.Id= key;
                              appl.IntegrationStatus__c= replaceAndUpdateString('ENPA', 'ENPA: Success', applicantMap.get(key).IntegrationStatus__c,';');
                              appl.IntegrationErrorMessage__c=replaceAndUpdateString('ENPA', '', applicantMap.get(key).IntegrationErrorMessage__c,';');
                              if(applicantMap.get(key).LoanAppln__c !=null && applicantMap.get(key).LoanAppln__r.Stage__c=='UnderWriting'){
                                  appl.IsENPSRunAtUW__c =true;
                              }
                              updateApplList.add(appl);
                              
                              if(!responseWrapper.Data.isEmpty()){
                                  for(ENPAResponseWrapper.Data data : responseWrapper.Data){
                                      DedupeResponse__c enpaRes = new DedupeResponse__c();
                                      enpaRes.Applicant__c=key;
                                      enpaRes.LoanAppln__c=applicantMap.get(key).LoanAppln__c;
                                      enpaRes.RecordTypeId=enpaRecordTypeId;
                                      enpaRes.IsLatest__c=true;
                                      enpaRes.LatestReportTime__c =System.now();
                                      if(String.isNotBlank(data.CustomerID)){
                                          enpaRes.CustomerId__c = data.CustomerID;
                                      }
                                      if(String.isNotBlank(data.LAN)){
                                          enpaRes.Lan__c = data.LAN;
                                          if(existingENPAMap.containsKey(key) && existingENPAMap.get(key).containsKey(data.LAN)){
                                              enpaRes.Id = existingENPAMap.get(key).get(data.LAN).Id;
                                          }
                                          else if(integrationMessage.RefObj__c == 'DedupeResponse__c' && !enpaFlag){
                                              enpaRes.Id = integrationMessage.RefId__c;
                                              enpaFlag = true;
                                          }
                                      }
                                      if(String.isNotBlank(data.UCIC)){
                                          enpaRes.UCID__c = data.UCIC;
                                      }
                                      if(String.isNotBlank(data.CustomerName)){
                                          enpaRes.CustomerName__c = data.CustomerName;
                                      }
                                      if(String.isNotBlank(data.AUM)){
                                          enpaRes.AUM__c = Decimal.valueOf(data.AUM);
                                      }
                                      if(String.isNotBlank(data.AUF)){
                                          enpaRes.AUF__c = Decimal.valueOf(data.AUF);
                                      }
                                      if(String.isNotBlank(data.DisbursementDate) && data.DisbursementDate!=null ){
                                          List<String>dateValue =data.DisbursementDate.split('[- : .]');
                                          if(dateValue.size()>=3){
                                              enpaRes.LoanDisbDate__c= Date.newInstance(Integer.valueOf(dateValue[0]), Integer.valueOf(dateValue[1]), Integer.valueOf(dateValue[2]));
                                          }
                                      }
                                      if(String.isNotBlank(data.DPD)){
                                          enpaRes.SystemDPD__c = data.DPD;
                                      }
                                      if(String.isNotBlank(data.UCID_Level_DPD)){
                                          enpaRes.DPD__c = data.UCID_Level_DPD;
                                      }
                                      if(String.isNotBlank(data.NPA_DATE) && data.NPA_DATE!=null ){ 
                                          List<String>dateValue =data.NPA_DATE.split('[- : .]');
                                          if(dateValue.size()>=3){
                                              enpaRes.NPADate__c= Date.newInstance(Integer.valueOf(dateValue[0]), Integer.valueOf(dateValue[1]), Integer.valueOf(dateValue[2]));
                                          }
                                      }
                                      if(String.isNotBlank(data.Product)){
                                          enpaRes.LoanType__c = data.Product;
                                      }
                                      if(String.isNotBlank(data.SecuritizationFlg)){
                                          enpaRes.SecuritisationStatus__c = data.SecuritizationFlg;
                                      }
                                      
                                      //New Fields LAK-6985
                                      
                                      if(String.isNotBlank(data.FRAUD_FLAG)){
                                          enpaRes.FraudFlag__c = data.FRAUD_FLAG;
                                      }
                                      if(String.isNotBlank(data.Writeoff_Flag)){
                                          enpaRes.WriteOffFlag__c = data.Writeoff_Flag;
                                      }
                                      
                                      if(String.isNotBlank(data.Writeoff_Date) && data.Writeoff_Date!=null ){ 
                                          List<String> dateValue =data.Writeoff_Date.split('[- : .]');
                                          if(dateValue.size()>=3){
                                              enpaRes.WriteoffDate__c= Date.newInstance(Integer.valueOf(dateValue[0]), Integer.valueOf(dateValue[1]), Integer.valueOf(dateValue[2]));
                                          }
                                      }
                                      
                                      if(String.isNotBlank(data.Settled)){
                                          enpaRes.Settled__c = data.Settled;
                                      }
                                      
                                      if(String.isNotBlank(data.Settled_Date) && data.Settled_Date!=null ){ 
                                          List<String> dateValue =data.Settled_Date.split('[- : .]');
                                          if(dateValue.size()>=3){
                                              enpaRes.SettledDate__c= Date.newInstance(Integer.valueOf(dateValue[0]), Integer.valueOf(dateValue[1]), Integer.valueOf(dateValue[2]));
                                          }
                                      }
                                      
                                      //New Fields Changes Done
                                      
                                      if(String.isNotBlank(data.Tenure)){
                                          enpaRes.Tenure__c = Decimal.valueOf(data.Tenure);
                                      }
                                      if(String.isNotBlank(data.LINKED_UCIC)){
                                          enpaRes.LinkedUCIC__c = data.LINKED_UCIC;
                                      }
                                      if(String.isNotBlank(data.FinalAssetClass)){
                                          enpaRes.FinalAssetClass__c = data.FinalAssetClass;
                                      }
                                      if(String.isNotBlank(data.TotalProvisionWithoutVarAmount)){
                                          enpaRes.TotalProvisionWithoutVarAmount__c = Decimal.valueOf(data.TotalProvisionWithoutVarAmount);
                                      }
                                      if(String.isNotBlank(data.TotalProvisionWithVarAmount)){
                                          enpaRes.TotalProvisionWithVarAmount__c = Decimal.valueOf(data.TotalProvisionWithVarAmount);
                                      }
                                      if(String.isNotBlank(data.LoanAmount)){
                                          enpaRes.LoanAmount__c = Decimal.valueOf(data.LoanAmount);
                                      }
                                      enpaList.add(enpaRes);
                                  }
                              }
                          } 
                    }
                    if(integrationMessage.Trigger_Platform_Event__c){
                        publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                        platformWra.intId = integrationMessage.Id; 
                        platformWra.recId = integrationMessage.RefId__c;
                        platformWra.ServiceName = integrationMessage.Svc__c ;
                        platformWra.Status = integrationMessage.Status__c ;
                        platformWra.success = True;
                        publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
                    }
                    
                    APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Success');
                    
                }
                if(!enpaList.isEmpty()){
                    fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { DedupeResponse__c.SObjectType });
                    uow.registerUpsert(enpaList);
                    uow.commitWork();
                    
                }
                if(!updateApplList.isEmpty()){
                    fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { Applicant__c.SObjectType });
                    List<string> fieldNamesList = New List<string>{'IntegrationStatus__c','IntegrationErrorMessage__c','IsENPSRunAtUW__c'};
                        String sObjectName = 'Applicant__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                    uow.registerDirty(updateApplList);
                    uow.commitWork();
                }
            }
            
        }
        catch(exception ex){
            system.debug('Error message: '+ ex.getMessage() + ' and Line number: ' + ex.getLineNumber());
        }
    }
    
    public static void processErrorResponse(ENPAResponseWrapper responseWrapper, IntgMsg__c integrationMessage){
        
        Map<Id,Applicant__c> applMap = new Map<Id,Applicant__c>([Select Id,LoanAppln__c,IntegrationStatus__c,IntegrationErrorMessage__c from Applicant__c where Id=:integrationMessage.RefId__c]);
        List<Applicant__c> updateApplList = new List<Applicant__c>();
        //Id enpaRecordTypeId = Schema.SObjectType.DedupeResponse__c.getRecordTypeInfosByDeveloperName().get('ENPA').getRecordTypeId();
        //List<DedupeResponse__c> existingdedupeList = [Select Id,IsLatest__c FROM DedupeResponse__c WHERE IsLatest__c=True AND Applicant__c=:integrationMessage.RefId__c AND LoanAppln__c=:applMap.get(integrationMessage.RefId__c).LoanAppln__c AND RecordTypeId=:enpaRecordTypeId];
        
        
        if(applMap.containsKey(integrationMessage.RefId__c)){
            if(responseWrapper!=null){
                String errorMessage = String.isNotBlank(responseWrapper.message) ? responseWrapper.message:'';
                Applicant__c appl= new Applicant__c();
                appl.Id=integrationMessage.RefId__c;
                appl.IntegrationStatus__c= replaceAndUpdateString('ENPA', 'ENPA: Failure', applMap.get(integrationMessage.RefId__c).IntegrationStatus__c,';');
                appl.IntegrationErrorMessage__c=replaceAndUpdateString('ENPA', 'ENPA: '+ errorMessage, applMap.get(integrationMessage.RefId__c).IntegrationErrorMessage__c,';');
                updateApplList.add(appl);
            }
            
            if(!updateApplList.isEmpty()){
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { Applicant__c.SObjectType });
                List<string> fieldNamesList = New List<string>{'IntegrationStatus__c','IntegrationErrorMessage__c'};
                    String sObjectName = 'Applicant__c';
                Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                uow.registerDirty(updateApplList);
                uow.commitWork();
            }
            /*if(!existingdedupeList.isEmpty()){
                updateExistingENPAResponse(existingdedupeList);
            }*/
            
            if(integrationMessage.Trigger_Platform_Event__c){
                publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                platformWra.intId = integrationMessage.Id; 
                platformWra.recId = integrationMessage.ParentRefId__c;
                platformWra.ServiceName = integrationMessage.Svc__c ;
                platformWra.Status = integrationMessage.Status__c ;
                platformWra.success = False;
                platformWra.errorMessage = responseWrapper.message;
                publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
            }
            
            APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Failure');
            
        }
    }
    
    public static void processFailure(Map<Id,Applicant__c> applicantMap,Map<IntgMsg__c,String> failureResponses){
        try{
            if(!failureResponses.isEmpty()){
                List<Applicant__c> updateApplList = new List<Applicant__c>();
                for(IntgMsg__c integrationMessage : failureResponses.keySet()){
                    
                    if((String.isNotBlank(integrationMessage.RefId__c) && String.isNotBlank(integrationMessage.RefObj__c) && integrationMessage.RefObj__c == 'Applicant__c') ||
                       (String.isNotBlank(integrationMessage.ParentRefId__c) && String.isNotBlank(integrationMessage.ParentRefObj__c) && integrationMessage.ParentRefObj__c == 'Applicant__c')
                      ){
                          String key = integrationMessage.RefObj__c == 'Applicant__c' ? integrationMessage.RefId__c : integrationMessage.ParentRefId__c ;
                          String errorMessage = failureResponses.containsKey(integrationMessage)? failureResponses.get(integrationMessage) : '';
                          
                          Applicant__c appl= new Applicant__c();
                          appl.Id = key;
                          appl.IntegrationStatus__c= replaceAndUpdateString('ENPA', 'ENPA: Failure', applicantMap.get(key).IntegrationStatus__c,';');
                          appl.IntegrationErrorMessage__c=replaceAndUpdateString('ENPA', 'ENPA: '+ errorMessage, applicantMap.get(key).IntegrationErrorMessage__c,';');
                          updateApplList.add(appl);
                          
                          if(integrationMessage.Trigger_Platform_Event__c){
                              publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                              platformWra.intId = integrationMessage.Id; 
                              platformWra.recId = integrationMessage.RefId__c;
                              platformWra.ServiceName = integrationMessage.Svc__c ;
                              platformWra.Status = integrationMessage.Status__c ;
                              platformWra.errorMessage = errorMessage;
                              publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
                          }
                          
                      }
                    
                    APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Failure');
                }
                if(!updateApplList.isEmpty()){
                    fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { Applicant__c.SObjectType });
                    List<string> fieldNamesList = New List<string>{'IntegrationStatus__c','IntegrationErrorMessage__c'};
                        String sObjectName = 'Applicant__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                    uow.registerDirty(updateApplList);
                    uow.commitWork();
                }
            }
        }
        catch(exception ex){
            system.debug('Error message: '+ ex.getMessage() + ' and Line number: ' + ex.getLineNumber());
        }
    }
    
    public static string replaceAndUpdateString(String toRemove, String toAdd,String actualString,String splitIdentifier){
        String updatedString;
        List<String> updatedStringList = new List<String>();
        if(String.isNotBlank(actualString)){
            List<String> existingStringList = actualString.split(splitIdentifier);
            system.debug(existingStringList);
            if(!existingStringList.isEmpty()){
                for(string value : existingStringList){
                    if(!value.contains(toRemove)){
                        updatedStringList.add(value);
                    }
                }
            }
        }	
        if(String.isNotBlank(toAdd)){
            updatedStringList.add(toAdd);
        }
        
        updatedString= String.join(updatedStringList,splitIdentifier).removeStart(splitIdentifier).removeEnd(splitIdentifier);
        
        return updatedString; 
    }

    public static Date convertToDate(String dateString) {
        Map<String, String> monthMap = new Map<String, String>{
            'JAN' => '01', 'FEB' => '02', 'MAR' => '03',
                'APR' => '04', 'MAY' => '05', 'JUN' => '06',
                'JUL' => '07', 'AUG' => '08', 'SEP' => '09',
                'OCT' => '10', 'NOV' => '11', 'DEC' => '12'
                };
                    
        List<String> dateParts = dateString.split('-');
        
        if (dateParts.size() == 3) {
            String year = dateParts[2];
            String month = monthMap.get(dateParts[1].toUpperCase());
            String day = dateParts[0];
            
            String salesforceDateFormat = year + '-' + month + '-' + day;
            
            return Date.valueOf(salesforceDateFormat);
        }
        
        return null; 
    }
    
    /*public static void updateExistingENPAResponse(List<DedupeResponse__c> responses){
        if(!responses.isEmpty()){
            for(DedupeResponse__c res : responses){
                res.IsLatest__c=false;
            }
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { DedupeResponse__c.SObjectType });
            List<string> fieldNamesList = New List<string>{'IsLatest__c'};
                String sObjectName = 'DedupeResponse__c';
            Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
            fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
            uow.registerDirty(responses);
            uow.commitWork();
        }
    }*/
    
}