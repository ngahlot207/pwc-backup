public class Trackwizz_CKYC_A63_ResponseProcessor implements IintMsgCalloutResponseProcessor{
    public static void process(List<IntgMsg__c> responses) {
        Set<Id> ids = new Set<Id>();
        for(IntgMsg__c integrationMessage : responses){
            ids.add(integrationMessage.RefId__c);
        }
        Map<Id,Applicant__c> applMap = new Map<Id,Applicant__c>([Select Id,IntegrationStatus__c,IntegrationErrorMessage__c FROM Applicant__c WHERE ID IN:ids]);
        try{
            List<Applicant__c>  updateApplList = new List<Applicant__c>();
            for(IntgMsg__c integrationMessage : responses){
                Boolean isSuccess;
                if(String.isNotBlank(integrationMessage.Resp__c)){
                    Dom.Document doc = new Dom.Document();  
                    doc.load(integrationMessage.Resp__c);              
                    Dom.XMLNode rootElement = doc.getRootElement(); 
                    Applicant__c appl= new Applicant__c();
                    appl.Id = integrationMessage.RefId__c;
                    String errorMessage='';
                    List<String> errorMessageList = new List<String>();
                    for (Dom.XMLNode childElement : rootElement.getChildElements()) {
                        //root elements of each array
                        if(childElement.getName()=='RequestStatus' && String.isNotBlank(childElement.getText()) && childElement.getText()=='RejectedByTW'){
                            appl.IntegrationStatus__c= replaceAndUpdateString('CKYC A63', 'CKYC A63: Failure', applMap.get(integrationMessage.RefId__c).IntegrationStatus__c,';');
                            appl.CKYC_API_Status__c='Failure';
                            isSuccess=false;
                        }
                        if(childElement.getName()=='RequestRejectionDescription' && String.isNotBlank(childElement.getText())){
                            errorMessage=childElement.getText();
                            appl.IntegrationErrorMessage__c=replaceAndUpdateString('CKYC A63', 'CKYC A63: '+ errorMessage, applMap.get(integrationMessage.RefId__c).IntegrationErrorMessage__c,';');
                            appl.CKYC_API_ErrorMessage__c=errorMessage!=null?errorMessage:'';
                        }
                        if(!childElement.getChildElements().isEmpty()){
                            for (Dom.XMLNode detailElement : childElement.getChildElements()){
                                
                                if(!detailElement.getChildElements().isEmpty()){
                                    for (Dom.XMLNode detailElement1 : detailElement.getChildElements()){
                                        if(detailElement1.getName()=='CustomerIntegrationStatusCode' && String.isNotBlank(detailElement1.getText()) && detailElement1.getText()=='RejectedByTW'){
                                            appl.IntegrationStatus__c= replaceAndUpdateString('CKYC A63', 'CKYC A63: Failure', applMap.get(integrationMessage.RefId__c).IntegrationStatus__c,';');
                                            appl.CKYC_API_Status__c='Failure';
                                            isSuccess=false;
                                        }
                                        if(detailElement1.getName()=='CustomerIntegrationStatusCode' && String.isNotBlank(detailElement1.getText()) && detailElement1.getText()=='AcceptedbyTW'){
                                            appl.IntegrationStatus__c= replaceAndUpdateString('CKYC A63', 'CKYC A63: Success', applMap.get(integrationMessage.RefId__c).IntegrationStatus__c,';');
                                            appl.IntegrationErrorMessage__c=replaceAndUpdateString('CKYC A63', '', applMap.get(integrationMessage.RefId__c).IntegrationErrorMessage__c,';');
                                            appl.CKYC_API_ErrorMessage__c='';
                                            appl.CKYC_API_Status__c='Success';
                                            isSuccess=true;
                                        }
                                        if(detailElement1.getName()=='TrackWizzInitialRejectionDescription' && String.isNotBlank(detailElement1.getText())){
                                            errorMessage=detailElement1.getText();
                                            appl.IntegrationErrorMessage__c=replaceAndUpdateString('CKYC A63', 'CKYC A63: '+ errorMessage, applMap.get(integrationMessage.RefId__c).IntegrationErrorMessage__c,';');
                                            appl.CKYC_API_ErrorMessage__c=errorMessage!=null?errorMessage:'';
                                        }
                                    }
                                }
                            }
                        }
                    }
                    updateApplList.add(appl);
                    
                }
                if(isSuccess){
                    APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Success');
                }
                else{
                    APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Failure');
                }
            }
            if(!updateApplList.isEmpty()){
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { Applicant__c.SObjectType });
                List<string> fieldNamesList = New List<string>{'IntegrationStatus__c','IntegrationErrorMessage__c','CKYC_API_Status__c','CKYC_API_ErrorMessage__c'};
                    String sObjectName = 'Applicant__c';
                Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                uow.registerDirty(updateApplList);
                uow.commitWork();
            }
        }
        //Exception Handling
        catch(Exception ex){
            GlobalUtility.logMessage('Error', 'Trackwizz_CKYC_A63_ResponseProcessor class', 
                                     'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
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
}