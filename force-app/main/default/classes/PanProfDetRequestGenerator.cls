public class PanProfDetRequestGenerator implements ICalloutRequestGenerator{
    
    public void generate(List<IntgMsg__c> msgs, String service, String processType){  
         fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( 
            new List<SObjectType> { IntgMsg__c.SObjectType }
        );
        //Creating a List of ids
        List<Id> ids = new List<Id>();
        
        //Iterating over new Intgeration Message record ids to add them into the above List
        for(IntgMsg__c intMsg : msgs){ 
            ids.add(intMsg.ParentRefId__c);
        }
        
        //Fetching required fields to create Request Payload
       Map<Id,ApplKyc__c> appRecMap = new Map<Id,ApplKyc__c>();
        for(ApplKyc__c appku : [SELECT Id,Pan__c,Applicant__c FROM ApplKyc__c WHERE id IN :ids]){
            appRecMap.put(appku.Id,appku);
        }
        System.debug('query '+appRecMap);
        try{
            //If the List of new Integration Message records is not empty, then iterating over and assigning data to variables from Wrapper Class
            List<IntgMsg__c> updateIntrecods = new List<IntgMsg__c>(); 
            
            if(!msgs.isEmpty()){
                for(IntgMsg__c intMsg : msgs){
                    ApplKyc__c applRec = appRecMap.get(intMsg.ParentRefId__c);
                    System.debug('applRec0000 '+applRec);
                    System.debug('applRec '+appRecMap.get(intMsg.RefId__c)+' IntMsg '+intMsg.RefId__c);
                    PanWrapper panDetails = new PanWrapper();
                    PanWrapper.ClientData cd= new PanWrapper.ClientData();
                    cd.caseId=GlobalUtility.getUniqueNumber();
                    panDetails.consent = GlobalConstants.CONSENT_Y;
                                   
                    panDetails.pan = applRec.Pan__c;
                    panDetails.ClientData=cd;
                  
             
                    IntgMsg__c intg=New IntgMsg__c();
                    intg.id = intMsg.Id;
                    intg.Req__c = JSON.serialize(panDetails); 
                    intg.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                    updateIntrecods.add(intg);
                }
                if(!updateIntrecods.isEmpty()) {
                    String sObjectName = 'IntgMsg__c';
                    List<String> fieldNamesList = new List<String>{'Req__c','Status__c'};
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                    uow.registerDirty(updateIntrecods);
                    //update updateIntrecods;
                }
            }
             uow.commitWork();
        }
        //Catch bloack to catch Exceptions occured during generation of payload and displaying the passing the same in GlobalUtility class
        catch(Exception ex){
            System.debug('error'+ex.getMessage());
            GlobalUtility.logMessage('Error', 'PanProfDetRequestGenerator' + ex.getLineNumber(), 
                                     'Generate', null, null, ex.getMessage() + ' Line: ' + ex.getLineNumber(), null, ex, null);
        }
    }
    

    // Exception class
    public class PanException extends Exception {
        
    }
}