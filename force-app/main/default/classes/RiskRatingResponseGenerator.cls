public class RiskRatingResponseGenerator implements IintMsgCalloutResponseProcessor{
    
    
    //Implementing the process method
    public static void process(List<IntgMsg__c> responses){
        for(IntgMsg__c integrationMessage : responses){
            
            if(integrationMessage.Svc__c != GlobalConstants.INT_CONFIG_SERVICE_RISK_RATING
               && integrationMessage.BU__c != GlobalConstants.INT_MSG_BU_TYPE){
                   throw new processException('Error! This is not the correct service'); 
               }
            
            try{
                if(String.isNotBlank(integrationMessage.Resp__c)){
                    Dom.Document doc = new Dom.Document();  
                    doc.load(integrationMessage.Resp__c);
                    Dom.XMLNode rootElement = doc.getRootElement();
                    String requestStatus;
                    for (Dom.XMLNode childElement : rootElement.getChildElements()){
                        if(childElement.getName()=='RequestStatus' && String.isNotBlank(childElement.getText())){
                            requestStatus = childElement.getText();
                        }   
                    }
                    if(requestStatus=='AcceptedByTW'){
                       processRiskRatingResponse(integrationMessage.Resp__c,integrationMessage.ParentRefId__c,integrationMessage); 
                    } 
                    else{
                        processRiskRatingErrorResponse(integrationMessage);
                    }
                    
                }
            }
            catch(Exception ex){
                GlobalUtility.logMessage('Error', 'RiskRatingResponseGenerator class', 
                                         'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
        }
    }
    
    public static void processRiskRatingResponse(String responseWrapper, Id referenceId,IntgMsg__c integrationMessage){
        try{
            
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { APIVer__c.SObjectType });  
            List<Id> existingApplicantIds = new List<Id>();
            List<APIVer__c> apiVerList = new List<APIVer__c>();
            List<APICalloutTracker.ApiTrackerWrapper> apiCalloutTrackerList = new List<APICalloutTracker.ApiTrackerWrapper>();
            
            if(!String.isBlank(responseWrapper)){
                
                Map<String,Applicant__c> applMap = new Map<String,Applicant__c>();
                
                for(Applicant__c app : [Select id,Name,Gender__c,LoanAppln__c,ApplType__c,FName__c,FullName__c,Constitution__c,CompanyName__c from Applicant__c where LoanAppln__c =: referenceId]){
                    applMap.put(app.Name,app);
                }
                
                Id riskRatingRecordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByDeveloperName().get('RiskRating').getRecordTypeId();
                
                Dom.Document doc = new Dom.Document();  
                doc.load(responseWrapper);
                Dom.XMLNode rootElement = doc.getRootElement();  
                for (Dom.XMLNode childElement : rootElement.getChildElements()) {
                    for (Dom.XMLNode detailElement1 : childElement.getChildElements()){
                        
                        APIVer__c apVer= new APIVer__c(); 
                        
                        APICalloutTracker.ApiTrackerWrapper apiCalloutTracker = new APICalloutTracker.ApiTrackerWrapper();
                        apiCalloutTracker.intMsgName = integrationMessage.Name;
                        apiCalloutTracker.apiName = integrationMessage.Svc__c;
                        apiCalloutTracker.parentRefId = integrationMessage.ParentRefId__c;
                        
                        for (Dom.XMLNode detailElement : detailElement1.getChildElements()){   
                            //childs elements of each childs array
                            if(applMap.containsKey(detailElement.getText())){
                                if(detailElement.getName()=='RecordIdentifier' && String.isNotBlank(detailElement.getText())){    
                                    Applicant__c appli= applMap.get(detailElement.getText());
                                    existingApplicantIds.add(appli.ID);
                                    
                                   
                                    apVer.Appl__c = appli.ID;
                                
                                    apVer.RecordTypeId = riskRatingRecordTypeId;
                                    apVer.LoanAplcn__c = applMap.get(detailElement.getText()).LoanAppln__c;
                                    apVer.ApplTyp__c = applMap.get(detailElement.getText()).ApplType__c;
                                    apVer.ApplNme__c = applMap.get(detailElement.getText()).Constitution__c =='INDIVIDUAL' ? applMap.get(detailElement.getText()).FullName__c : applMap.get(detailElement.getText()).CompanyName__c;
                                	apVer.ApplTyp__c = applMap.get(detailElement.getText()).ApplType__c;
                                    apVer.IsLatest__c=true;
                                    // apVer.Source__c = 'SFDC';
                                    
                                    apiCalloutTracker.refId = applMap.get(detailElement.getText()).Id;
                                }
                              
                                
                            }
                            if(detailElement.getName()=='Risk' && String.isNotBlank(detailElement.getText())){
                                // apVer.Appl__c = appli.ID;
                                apVer.Risk_Rating_Final__c=detailElement.getText();
                                apVer.Risk_Rating_Decision__c='Call back is not required :'+detailElement.getText();  
                                apVer.Risk_Rating_System__c=detailElement.getText();
                                
                            }
                            if(detailElement.getName()=='TransactionStatus' && String.isNotBlank(detailElement.getText())){
                                    apVer.IntegrationStatus__c = detailElement.getText()=='AcceptedByTW' ? 'Success' : 'Failure';
                                	
                                	apiCalloutTracker.statusCode = detailElement.getText()=='AcceptedByTW' ? 'Success' : 'Failure';
                                }
                            if(detailElement.getName()=='TransactionRejectionDescription' && String.isNotBlank(detailElement.getText())){
                                    apVer.IntegrationErrorMessage__c = detailElement.getText();
                                }
                            
                            
                            
                        } 
                        apiVerList.add(apVer); 
                        apiCalloutTrackerList.add(apiCalloutTracker);
                    }
                }
                
                if(!existingApplicantIds.isEmpty()){
                    List<APIVer__c> existingWoutInvsList = [Select Id,IsLatest__c,Appl__c FROM APIVer__c WHERE IsLatest__c=True AND Appl__c IN :existingApplicantIds AND RecordType.Name='Risk Rating'];
                    if(!existingWoutInvsList.isEmpty()){
                        updateExisitngResposnes(existingWoutInvsList);
                    }
                }
                
            }
            
            if(!apiVerList.isEmpty()){
                
                List<string> fieldNamesList = New List<string>{'RecordTypeId','LoanAplcn__c','ApplNme__c','ApplTyp__c','Source__c','Risk_Rating_Final__c','Risk_Rating_Decision__c','Risk_Rating_System__c','IsLatest__c','Appl__c'};
                    String sObjectName = 'APIVer__c';
                Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkInsert(objType,fieldNamesList);
                uow.registerNew(apiVerList);
                uow.commitWork();
            }
            //APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Success');
            APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,'Success',apiCalloutTrackerList);
        }
        catch(exception ex){
            System.debug(ex);
            system.debug('error message and line number '+ ex.getMessage() + 'line' + ex.getLineNumber());
        }
    }
    
    public static void updateExisitngResposnes(List<APIVer__c> responses){
        if(!responses.isEmpty()){
            for(APIVer__c res : responses){
                res.IsLatest__c=false;
            }
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { APIVer__c.SObjectType });
            List<string> fieldNamesList = New List<string>{'IsLatest__c'};
                String sObjectName = 'APIVer__c';
            Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
            fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
            uow.registerDirty(responses);
            uow.commitWork();
        }
    }
    
    public static void processRiskRatingErrorResponse(IntgMsg__c integrationMessage){
        try{
            
            if(String.isNotBlank(integrationMessage.Resp__c)){
                Dom.Document doc = new Dom.Document();  
                doc.load(integrationMessage.Resp__c);
                Dom.XMLNode rootElement = doc.getRootElement();
                String requestRejectionDescription;
                for (Dom.XMLNode childElement : rootElement.getChildElements()){
                    if(childElement.getName()=='RequestRejectionDescription' && String.isNotBlank(childElement.getText())){
                        requestRejectionDescription = childElement.getText();
                    }   
                }
                
                
                Set<Id> appIds = new Set<Id>();
                
                if(String.isNotBlank(integrationMessage.RefId__c)){
                    List<Id> ids = integrationMessage.RefId__c.split(',');
                    appIds.addAll(ids);
                }
                else if(String.isNotBlank(integrationMessage.ParentRefId__c)){
                    for(Applicant__c app : [SELECT Id,Name,LoanAppln__c,LoanAppln__r.Name, LoanAppln__r.BrchName__c,FName__c,MName__c,LName__c,CompanyName__c,Constitution__c,Gender__c,DOB__c  FROM Applicant__c Where LoanAppln__c =:integrationMessage.ParentRefId__c]){
                        appIds.add(app.Id);
                    }
                }
                
                if(!appIds.isEmpty()){
                    List<APIVer__c> existingAPIVerList = [Select Id,IsLatest__c,Appl__c FROM APIVer__c WHERE IsLatest__c=True AND Appl__c IN :appIds AND RecordType.Name='Risk Rating'];
                    List<APIVer__c> trackwizzList = new List<APIVer__c>();
                    List<APICalloutTracker.ApiTrackerWrapper> apiCalloutTrackerList = new List<APICalloutTracker.ApiTrackerWrapper>();
                    Id riskRatingRecordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByDeveloperName().get('RiskRating').getRecordTypeId();
                    if(!existingAPIVerList.isEmpty()){
                        updateExisitngResposnes(existingAPIVerList);
                    }
                    Map<Id,Applicant__c>applMap = new Map<Id,Applicant__c>([select id,Name,Gender__c,LoanAppln__c,ApplType__c,FullName__c,Constitution__c,CompanyName__c from Applicant__c where ID IN:appIds]); 
                    
                    for(Id appId : appIds){
                        if(applMap.containsKey(appId)){
                            APIVer__c trackwizz = new APIVer__c();
                            trackwizz.Appl__c = appId;
                            trackwizz.RecordTypeId = riskRatingRecordTypeId;
                            trackwizz.LoanAplcn__c = applMap.get(appId).LoanAppln__c;
                            trackwizz.ApplNme__c = applMap.get(appId).Constitution__c =='INDIVIDUAL' ? applMap.get(appId).FullName__c : applMap.get(appId).CompanyName__c;
                            trackwizz.ApplTyp__c = applMap.get(appId).ApplType__c;
                            trackwizz.IsLatest__c=true;
                            trackwizz.IntegrationStatus__c='Failure';
                            trackwizz.IntegrationErrorMessage__c = requestRejectionDescription;
                            trackwizzList.add(trackwizz);
                            
                            APICalloutTracker.ApiTrackerWrapper apiCalloutTracker = new APICalloutTracker.ApiTrackerWrapper();
                            apiCalloutTracker.intMsgName = integrationMessage.Name;
                            apiCalloutTracker.apiName = integrationMessage.Svc__c;
                            apiCalloutTracker.parentRefId = integrationMessage.ParentRefId__c;
                            apiCalloutTracker.refId = appId;
                            apiCalloutTracker.statusCode = 'Failure';
                            apiCalloutTrackerList.add(apiCalloutTracker);
                        }
                    }
                    
                    if(!trackwizzList.isEmpty()){
                        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { APIVer__c.SObjectType });
                        List<string> fieldNamesList = New List<string>{'Appl__c','RecordTypeId','LoanAplcn__c','ApplNme__c','ApplTyp__c','IsLatest__c','IntegrationStatus__c','IntegrationErrorMessage__c'};
                            String sObjectName = 'APIVer__c';
                        Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                        fflib_SecurityUtils.checkInsert(objType,fieldNamesList);
                        uow.registerNew(trackwizzList);
                        uow.commitWork();
                    }
                    
                    //APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Failure');
                    APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,'Failure',apiCalloutTrackerList);
                }
            }       
        }
        catch(exception ex){
            system.debug('error message and line number '+ ex.getMessage() + 'line' + ex.getLineNumber());
        }
    }
    
    
}