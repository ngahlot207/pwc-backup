public class PerfiosGenerateReportResponseProcessor implements IintMsgCalloutResponseProcessor{
    
    //Implementing the process method
    public static void process(List<IntgMsg__c> responses){ 
        Map<Id,PerfiosGenerateReportResponseWrapper> responseMap = new Map<Id,PerfiosGenerateReportResponseWrapper>();
        for(IntgMsg__c integrationMessage : responses){
            if(integrationMessage.Svc__c != 'Report generation' && integrationMessage.BU__c != GlobalConstants.INT_MSG_BU_TYPE){
                throw new processException('Error! This is not the correct service'); 
            }
            
            try{
                PerfiosGenerateReportResponseWrapper responseWrapper = PerfiosGenerateReportResponseWrapper.parse(integrationMessage.Resp__c);
                if(responseWrapper != null){
                    if(integrationMessage.ParentRefId__c!=null){
                        responseMap.put(integrationMessage.ParentRefId__c,responseWrapper);
                    }
                }
            }
            //Exception Handling
            catch(Exception ex){
                GlobalUtility.logMessage('Error', 'PerfiosGenerateReportResponseProcessor class', 
                                         'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            } 
        }
        if(!responseMap.isEmpty()){
            processResponses(responses,responseMap);
        }
    }
    
    
    public static void processResponses(List<IntgMsg__c> responseList,Map<Id,PerfiosGenerateReportResponseWrapper> responseMap){
        try{
            if(!responseList.isEmpty()){
                Map<Id,ApplBanking__c> applBankMap = new Map<Id,ApplBanking__c>([Select Id,IntegrationStatus__c,IntegrationErrorMessage__c from ApplBanking__c where Id IN:responseMap.keySet()]);
                List<ApplBanking__c> appBankList = new List<ApplBanking__c>();
                for(IntgMsg__c integrationMessage: responseList){
                    if(responseMap.containsKey(integrationMessage.ParentRefId__c)){
                        PerfiosGenerateReportResponseWrapper response = responseMap.get(integrationMessage.ParentRefId__c);
                        if(response != null){
                            if(response.success!=null){
                                
                                ApplBanking__c appBank = new ApplBanking__c();
                                appBank.Id = integrationMessage.ParentRefId__c;
                                appBank.IntegrationStatus__c = PerfiosAPIController.replaceAndUpdateString('Perfios Report Generation: Failure', 'Perfios Report Generation: Success', applBankMap.get(integrationMessage.ParentRefId__c).IntegrationStatus__c, ';');
                                appBank.IntegrationErrorMessage__c = PerfiosAPIController.replaceAndUpdateString('Perfios Report Generation', '', applBankMap.get(integrationMessage.ParentRefId__c).IntegrationErrorMessage__c, ';');
                                appBankList.add(appBank);
                                
                                if(integrationMessage.Trigger_Platform_Event__c){
                                    publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                                    platformWra.intId = integrationMessage.Id; 
                                    platformWra.recId = integrationMessage.ParentRefId__c;
                                    platformWra.ServiceName = integrationMessage.Svc__c ;
                                    platformWra.Status = integrationMessage.Status__c ;
                                    platformWra.success = True;
                                    publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
                                }
                                APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Success');
                            }
                            else{
                                String errorMessage = (response.error!=null && String.isNotBlank(response.error.message)) ? response.error.message:'';
                                ApplBanking__c appBank = new ApplBanking__c();
                                appBank.Id = integrationMessage.ParentRefId__c;
                                appBank.Initiate_Perfios_Status__c = 'Failure';
                                appBank.IntegrationStatus__c = PerfiosAPIController.replaceAndUpdateString('Perfios Report Generation: Success', 'Perfios Report Generation: Failure', applBankMap.get(integrationMessage.ParentRefId__c).IntegrationStatus__c, ';');
                                appBank.IntegrationErrorMessage__c = PerfiosAPIController.replaceAndUpdateString('Perfios Report Generation', 'Perfios Report Generation: ' + errorMessage, applBankMap.get(integrationMessage.ParentRefId__c).IntegrationErrorMessage__c, ';');
                                appBankList.add(appBank);
                                
                                if(integrationMessage.Trigger_Platform_Event__c){
                                    publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                                    platformWra.intId = integrationMessage.Id; 
                                    platformWra.recId = integrationMessage.ParentRefId__c;
                                    platformWra.ServiceName = integrationMessage.Svc__c ;
                                    platformWra.Status = integrationMessage.Status__c ;
                                    platformWra.success = False;
                                    platformWra.errorMessage = errorMessage;
                                    publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
                                }
                                APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Failure');
                            }
                        }
                    }
                }
                
                if(!appBankList.isEmpty()){
                    fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { ApplBanking__c.SObjectType });
                    List<string> fieldNamesList = New List<string>{'IntegrationStatus__c','IntegrationErrorMessage__c','Initiate_Perfios_Status__c'};
                        String sObjectName = 'ApplBanking__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                    uow.registerDirty(appBankList);
                    uow.commitWork();
                }
            }
        }
        catch(exception ex){
            system.debug('error message and line number '+ ex.getMessage() + 'line' + ex.getLineNumber());
        }      
    }
}