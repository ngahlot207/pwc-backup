public class Trackwizz_CKYC_A37_ResponseProcessor implements IintMsgCalloutResponseProcessor {
    
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
                            appl.IntegrationStatus__c= replaceAndUpdateString('CKYC A37', 'CKYC A37: Failure', applMap.get(integrationMessage.RefId__c).IntegrationStatus__c,';');
                            appl.CKYC_Attachment_API_Status__c='Failure';
                            isSuccess=false;
                        }
                        if(!childElement.getChildElements().isEmpty()){
                            for (Dom.XMLNode detailElement : childElement.getChildElements()){
                                if(detailElement.getName()=='RejectionDescription' && String.isNotBlank(detailElement.getText())){
                                    errorMessage=detailElement.getText();
                                    appl.IntegrationErrorMessage__c=replaceAndUpdateString('CKYC A37', 'CKYC A37: '+ errorMessage, applMap.get(integrationMessage.RefId__c).IntegrationErrorMessage__c,';');
                                    appl.CKYC_Attachment_ErrorMessage__c=errorMessage!=null?errorMessage:'';
                                }
                                if(!detailElement.getChildElements().isEmpty()){
                                    for (Dom.XMLNode detailElement1 : detailElement.getChildElements()){
                                        if(!detailElement1.getChildElements().isEmpty()){
                                            for (Dom.XMLNode detailElement2 : detailElement1.getChildElements()){
                                                if(detailElement2.getName()=='CustomerStatus' && String.isNotBlank(detailElement2.getText()) && detailElement2.getText()=='RejectedByTW'){
                                                    appl.IntegrationStatus__c= replaceAndUpdateString('CKYC A37', 'CKYC A37: Failure', applMap.get(integrationMessage.RefId__c).IntegrationStatus__c,';');
                                                    appl.CKYC_Attachment_API_Status__c='Failure';
                                                    isSuccess=false;
                                                }
                                                if(detailElement2.getName()=='CustomerStatus' && String.isNotBlank(detailElement2.getText()) && detailElement2.getText()=='AcceptedbyTW'){
                                                    appl.IntegrationStatus__c= replaceAndUpdateString('CKYC A37', 'CKYC A37: Success', applMap.get(integrationMessage.RefId__c).IntegrationStatus__c,';');
                                                    appl.IntegrationErrorMessage__c=replaceAndUpdateString('CKYC A37', '', applMap.get(integrationMessage.RefId__c).IntegrationErrorMessage__c,';');
                                                    appl.CKYC_Attachment_ErrorMessage__c='';
                                                    appl.CKYC_Attachment_API_Status__c='Success';
                                                    isSuccess=true;
                                                    
                                                }
                                                if(!detailElement2.getChildElements().isEmpty()){
                                                    for (Dom.XMLNode detailElement3 : detailElement2.getChildElements()){
                                                        if(!detailElement3.getChildElements().isEmpty()){
                                                            for (Dom.XMLNode detailElement4 : detailElement3.getChildElements()){
                                                                if(detailElement4.getName()=='RejectionDescription' && String.isNotBlank(detailElement4.getText())){
                                                                    errorMessageList.add(detailElement4.getText());
                                                                }
                                                            }
                                                            if(!errorMessageList.isEmpty()){
                                                                errorMessage = String.Join(errorMessageList,',');
                                                                appl.IntegrationErrorMessage__c=replaceAndUpdateString('CKYC A37', 'CKYC A37: '+ errorMessage, applMap.get(integrationMessage.RefId__c).IntegrationErrorMessage__c,';');
                                                                appl.CKYC_Attachment_ErrorMessage__c=errorMessage!=null?errorMessage:'';
                                                            }
                                                        }    
                                                    }
                                                }
                                            }
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
                List<string> fieldNamesList = New List<string>{'IntegrationStatus__c','IntegrationErrorMessage__c','CKYC_Attachment_ErrorMessage__c','CKYC_Attachment_API_Status__c'};
                    String sObjectName = 'Applicant__c';
                Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                uow.registerDirty(updateApplList);
                uow.commitWork();
            }
        }
        //Exception Handling
        catch(Exception ex){
            GlobalUtility.logMessage('Error', 'Trackwizz_CKYC_A37_ResponseProcessor class', 
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