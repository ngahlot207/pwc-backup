public class ScreeningResponseProcessor implements IintMsgCalloutResponseProcessor{
    
    //Implementing the process method
    public static void process(List<IntgMsg__c> responses){
        for(IntgMsg__c integrationMessage : responses){
            try{
                ScreeningResponseWrapper responseWrapper = (ScreeningResponseWrapper) JSON.deserialize(integrationMessage.Resp__c, ScreeningResponseWrapper.class);
                if(responseWrapper.Result!=null){
                    processScreeningResponse(responseWrapper,integrationMessage.ParentRefId__c,integrationMessage);
                } else if(responseWrapper.Message!=null){
                    processScreeningErrorResponse(responseWrapper,integrationMessage);
                }
            }
            catch(Exception ex){
                GlobalUtility.logMessage('Error', 'ScreeningResponseProcessor class', 
                                         'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
        }
    }
    
    public static void processScreeningResponse(ScreeningResponseWrapper responseWrapper, Id referenceId,IntgMsg__c integrationMessage){
        
        try{
            if(responseWrapper.Result!=null){
                Map<String,Applicant__c> applMap = new Map<String,Applicant__c>();
                
                List<Id> existingApplicantIds = new List<Id>();
                for(Applicant__c app : [select id,Name,Gender__c,LoanAppln__c,ApplType__c,FullName__c,Constitution__c,CompanyName__c from Applicant__c where LoanAppln__c=:referenceId]){
                    applMap.put(app.Name,app);
                }
                system.debug('applMap'+applMap);
                Id trackWizzRecordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByDeveloperName().get('Screening').getRecordTypeId();
                List<APIVer__c> trackwizzList = new List<APIVer__c>();
                List<APICalloutTracker.ApiTrackerWrapper> apiCalloutTrackerList = new List<APICalloutTracker.ApiTrackerWrapper>();
                //String strResp = '<?xml version=\"1.0\" encoding=\"utf-16\"?>\r\n<ScreeningApiResults xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">\r\n <ScreeningResult>\r\n <SystemName>Support1</SystemName>\r\n <RequestId>123412488</RequestId>\r\n <RecordIdentifier>TestRec1</RecordIdentifier>\r\n <Matched>NotMatch</Matched>\r\n <CaseId xsi:nil=\"true\" />\r\n <AlertCount xsi:nil=\"true\" />\r\n <Alerts>\r\n <Alert>\r\n <CaseId xsi:nil=\"true\" />\r\n <AlertId xsi:nil=\"true\" />\r\n <WatchlistChangeLogActionableId xsi:nil=\"true\" />\r\n <AmlWatchlistId>0</AmlWatchlistId>\r\n <MatchTypeRefEnumValueId xsi:nil=\"true\" />\r\n </Alert>\r\n </Alerts>\r\n </ScreeningResult>\r\n <ScreeningResult>\r\n <SystemName>Support1</SystemName>\r\n <RequestId>123412489</RequestId>\r\n <RecordIdentifier>TestRec2</RecordIdentifier>\r\n <Matched>NotMatch</Matched>\r\n <CaseId xsi:nil=\"true\" />\r\n <AlertCount xsi:nil=\"true\" />\r\n <Alerts>\r\n <Alert>\r\n <CaseId xsi:nil=\"true\" />\r\n <AlertId xsi:nil=\"true\" />\r\n <WatchlistChangeLogActionableId xsi:nil=\"true\" />\r\n <AmlWatchlistId>0</AmlWatchlistId>\r\n <MatchTypeRefEnumValueId xsi:nil=\"true\" />\r\n </Alert>\r\n </Alerts>\r\n </ScreeningResult>\r\n</ScreeningApiResults>';
                Dom.Document doc = new Dom.Document();  
                //doc.load(strResp);
                doc.load(responseWrapper.Result);
                Dom.XMLNode rootElement = doc.getRootElement();  
                for (Dom.XMLNode childElement : rootElement.getChildElements()) {
                    //root elements of each array
                    APIVer__c trackwizz = new APIVer__c();
                    List<String> sourceList = new List<String>();
                    
                    APICalloutTracker.ApiTrackerWrapper apiCalloutTracker = new APICalloutTracker.ApiTrackerWrapper();
                    apiCalloutTracker.intMsgName = integrationMessage.Name;
                    apiCalloutTracker.apiName = integrationMessage.Svc__c;
                    apiCalloutTracker.parentRefId = integrationMessage.ParentRefId__c;
                    
                    for (Dom.XMLNode detailElement : childElement.getChildElements()){
                        //childs elements of each array
                        if(detailElement.getName()=='RecordIdentifier' && String.isNotBlank(detailElement.getText())){
                            system.debug('::::::::'+detailElement.getText() +'::::'+applMap.containsKey(detailElement.getText()) );
                            if(applMap.containsKey(detailElement.getText())){
                                
                                existingApplicantIds.add(applMap.get(detailElement.getText()).Id);
                                
                                trackwizz.Appl__c = applMap.get(detailElement.getText()).Id;
                                trackwizz.RecordTypeId = trackWizzRecordTypeId;
                                trackwizz.LoanAplcn__c = applMap.get(detailElement.getText()).LoanAppln__c;
                                trackwizz.ApplNme__c = applMap.get(detailElement.getText()).Constitution__c =='INDIVIDUAL' ? applMap.get(detailElement.getText()).FullName__c : applMap.get(detailElement.getText()).CompanyName__c;
                                trackwizz.ApplTyp__c = applMap.get(detailElement.getText()).ApplType__c;
                                //trackwizz.Source__c = 'SFDC';
                                trackwizz.IsLatest__c=true;
                                
                                apiCalloutTracker.refId = applMap.get(detailElement.getText()).Id;
                            }
                        }
                        
                        if(detailElement.getName()=='Matched'){
                            trackwizz.ScrRes__c = detailElement.getText();
                            trackwizz.ScrDec__c = detailElement.getText()=='Match' ? 'Accepted by Trackwizz' : detailElement.getText()=='NotMatch' ? 'Call back not Required No Match Found' : '' ;
                            trackwizz.IntegrationStatus__c = detailElement.getText()=='Error' ? 'Failure' : 'Success';
                            
                            apiCalloutTracker.statusCode = detailElement.getText()=='Error' ? 'Failure' : 'Success';
                        }
                        if(detailElement.getName()=='RejectionMessage'){
                            trackwizz.IntegrationErrorMessage__c = detailElement.getText();
                        }
                        
                        //2024-10-01 Eshan - LAK-7471 - Changes Start
                        if(detailElement.getName() == 'Alerts'){
                            for (Dom.XMLNode detailElement1 : detailElement.getChildElements()){
                                
                                if(detailElement1.getName() == 'Alert'){
                                    for (Dom.XMLNode detailElement2 : detailElement1.getChildElements()){
                                        system.debug('>>>>>>>>>>>>>>'+ detailElement2.getName());
                                        if(detailElement2.getName() == 'Source' && String.isNotBlank(detailElement2.getText())){
                                            sourceList.add(detailElement2.getText());
                                        }
                                    }
                                }
                            }
                        }
                        //2024-10-01 Eshan - LAK-7471 - Changes End
                        
                        //for (Dom.XMLNode detailElement1 : detailElement.getChildElements()){
                        //childs elements of each childs array
                        //}
                    } 
                    
                    trackwizz.Source__c = !sourceList.isEmpty() ? String.join(sourceList,',') : '';
                    
                    trackwizzList.add(trackwizz);
                    apiCalloutTrackerList.add(apiCalloutTracker);
                }  
                system.debug('List: '+trackwizzList);
                if(!existingApplicantIds.isEmpty()){
                    List<APIVer__c> existingAPIVerList = [Select Id,IsLatest__c,Appl__c FROM APIVer__c WHERE IsLatest__c=True AND Appl__c IN :existingApplicantIds AND RecordType.Name='Screening'];
                    if(!existingAPIVerList.isEmpty()){
                        updateExisitngResposnes(existingAPIVerList);
                    }
                }
                if(!trackwizzList.isEmpty()){
                    fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { APIVer__c.SObjectType });
                    List<string> fieldNamesList = New List<string>{'Appl__c','RecordTypeId','LoanAplcn__c','ApplNme__c','ApplTyp__c','Source__c','ScrRes__c','ScrDec__c','IsLatest__c','IntegrationStatus__c','IntegrationErrorMessage__c'};
                        String sObjectName = 'APIVer__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkInsert(objType,fieldNamesList);
                    uow.registerNew(trackwizzList);
                    uow.commitWork();
                }
                //APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Success');
                APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,'Success',apiCalloutTrackerList);
            }
        }
        catch(exception ex){
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
    
    public static void processScreeningErrorResponse(ScreeningResponseWrapper responseWrapper,IntgMsg__c integrationMessage){
        try{ 
            if(responseWrapper.Message!=null){
                Dom.Document doc = new Dom.Document();  
                //doc.load(strResp);
                doc.load(responseWrapper.Message);
                String errorMessage;
                Dom.XMLNode rootElement = doc.getRootElement();  
                for (Dom.XMLNode childElement : rootElement.getChildElements()) {
                    if(childElement.getName()=='ErrorMessage'){
                        errorMessage = childElement.getText();
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
                    List<APIVer__c> existingAPIVerList = [Select Id,IsLatest__c,Appl__c FROM APIVer__c WHERE IsLatest__c=True AND Appl__c IN :appIds AND RecordType.Name='Screening'];
                    List<APIVer__c> trackwizzList = new List<APIVer__c>();
                    List<APICalloutTracker.ApiTrackerWrapper> apiCalloutTrackerList = new List<APICalloutTracker.ApiTrackerWrapper>();
                    Id trackWizzRecordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByDeveloperName().get('Screening').getRecordTypeId();
                    if(!existingAPIVerList.isEmpty()){
                        updateExisitngResposnes(existingAPIVerList);
                    }
                    Map<Id,Applicant__c>applMap = new Map<Id,Applicant__c>([select id,Name,Gender__c,LoanAppln__c,ApplType__c,FullName__c,Constitution__c,CompanyName__c from Applicant__c where ID IN:appIds]); 
                    
                    for(Id appId : appIds){
                        if(applMap.containsKey(appId)){
                            APIVer__c trackwizz = new APIVer__c();
                            trackwizz.Appl__c = appId;
                            trackwizz.RecordTypeId = trackWizzRecordTypeId;
                            trackwizz.LoanAplcn__c = applMap.get(appId).LoanAppln__c;
                            trackwizz.ApplNme__c = applMap.get(appId).Constitution__c =='INDIVIDUAL' ? applMap.get(appId).FullName__c : applMap.get(appId).CompanyName__c;
                            trackwizz.ApplTyp__c = applMap.get(appId).ApplType__c;
                            trackwizz.IsLatest__c=true;
                            trackwizz.IntegrationStatus__c='Failure';
                            trackwizz.IntegrationErrorMessage__c = errorMessage;
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