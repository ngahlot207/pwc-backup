public class VoterIdRequestGenerator implements ICalloutRequestGenerator{
    
    public void generate(List<IntgMsg__c> msgs, String service, String processType){  
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( 
            new List<SObjectType> { IntgMsg__c.SObjectType }
        );
        //Creating a List of Ids
        List<Id> Ids = new List<Id>();
        
        //Iterating over new Intgeration Message record Ids to add them into the above List
        for(IntgMsg__c intMsg : msgs){ 
            Ids.add(intMsg.ParentRefId__c);
        }
        
        Map<Id,ApplKyc__c> appKycMap = new Map<Id,ApplKyc__c>();
        //Fetching required fields to create Request Payload
        List<ApplKyc__c> appKycList = new List<ApplKyc__c>([SELECT Id,VotIdEpicNo__c,Applicant__c FROM ApplKyc__c WHERE id In :Ids AND kycDoc__c = 'Voter Id']);
        
        for(ApplKyc__c appku : appKycList){
            appKycMap.put(appku.id,appku);
        }
        try{
            List<IntgMsg__c>UpdateIntrecods=New List<IntgMsg__c>(); 
            
            //If the List of new Integration Message records is not empty, then iterating over and assigning data to variables from Wrapper Class            
            if(!msgs.isEmpty()){
                for(IntgMsg__c intMsg : msgs){
                    
                    ApplKyc__c applKycRec = appKycMap.get(intMsg.ParentRefId__c); 
                    
                    OCRVoterIdWrapperClass voterIdDetails = new OCRVoterIdWrapperClass();
                    voterIdDetails.consent =GlobalConstants.CONSENT_Y;
                    
                    //if(applKycRec.VotIdEpicNo__c != null){
                        voterIdDetails.epicNo = applKycRec.VotIdEpicNo__c != null ? applKycRec.VotIdEpicNo__c : null ;
                        OCRVoterIdWrapperClass.ClientData cd=new OCRVoterIdWrapperClass.ClientData();
                            cd.caseId=GlobalUtility.getUniqueNumber();
                            voterIdDetails.ClientData=cd;

                        IntgMsg__c intg=New IntgMsg__c();
                        intg.id=intMsg.id;
                        intg.Req__c = JSON.serialize(voterIdDetails); 
                        intg.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                        UpdateIntrecods.add(intg);
                        
                    //}
                    //else{
                    //    throw new voterIdException('epic Number is null');
                    //}  
                }
                if(!UpdateIntrecods.isEmpty()){
                    String sObjectName = 'IntgMsg__c';
                    List<String> fieldNamesList = new List<String>{'Req__c','Status__c'};
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                    uow.registerDirty(updateIntrecods);
                    //update UpdateIntrecods;
                }
            }
            uow.commitWork();
        }
        //Catch bloack to catch Exceptions occured during generation of payload and displaying the passing the same in GlobalUtility class
        catch(Exception ex){
            GlobalUtility.logMessage('Error', 'VoterIdRequestGenerator' + ex.getLineNumber(), 
                                     'Generate', null, null, ex.getMessage() + ' Line: ' + ex.getLineNumber(), null, ex, null);
        }
    }
    

    
    public class voterIdException extends Exception {
        
    }
}