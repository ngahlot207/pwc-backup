public class passportRequestGenerator implements ICalloutRequestGenerator{
    
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
        
        //Fetching required fields to create Request Payload
     
        Map<Id,ApplKyc__c> appKycMap = new Map<Id,ApplKyc__c>();
        //Fetching required fields to create Request Payload
        List<ApplKyc__c> appKycList = new List<ApplKyc__c>([SELECT Id,PassNo__c,DtOfBirth__c,DtOfIssue__c,FileNo__c,Applicant__c,Name__c FROM ApplKyc__c WHERE Id IN :Ids AND kycDoc__c = 'Passport']);
        
      
        
        for(ApplKyc__c appku : appKycList){
            appKycMap.put(appku.Id,appku);
        }
         Map<Id,Applicant__c> appRecMap = new Map<Id,Applicant__c>([SELECT Id,dob__c,DOI__c FROM Applicant__c WHERE Id=:appKycList[0].Applicant__c]);
        try{
            //If the List of new Integration Message records is not empty, then iterating over and assigning data to variables from Wrapper Class
            List<IntgMsg__c>UpdateIntrecods=New List<IntgMsg__c>();           
            if(!msgs.isEmpty()){
                for(IntgMsg__c intMsg : msgs){
                    
                    Applicant__c ApplRec = appRecMap.get(appKycList[0].Applicant__c);
                    
                    ApplKyc__c applKycRec = appKycMap.get(intMsg.ParentRefId__c); 
                    
                    passportWrapper passportDetails = new passportWrapper();
                    passportDetails.consent = GlobalConstants.CONSENT_Y;
                    
                    //if(applKycRec.FileNo__c != null){
                    //    if(applKycRec.DtOfBirth__c != null){
                            passportDetails.fileNo= applKycRec.FileNo__c!=null ? applKycRec.FileNo__c : null;
                            passportDetails.passportNo = applKycRec.PassNo__c != null ? applKycRec.PassNo__c : null ;
                            passportDetails.dob= applKycRec.DtOfBirth__c !=null ? String.valueOf(DateTime.newInstance(applKycRec.DtOfBirth__c.year(), applKycRec.DtOfBirth__c.month(), applKycRec.DtOfBirth__c.day()).format('dd/MM/yyyy')) : null;
                            
                            //if(applKycRec.DtOfIssue__c!=null){
                                passportDetails.doi= applKycRec.DtOfIssue__c!=null ? String.valueOf(DateTime.newInstance(applKycRec.DtOfIssue__c.year(), applKycRec.DtOfIssue__c.month(), applKycRec.DtOfIssue__c.day()).format('dd/MM/yyyy')) : null;
                            //}
                            
                            passportDetails.name= applKycRec.name__c;

                            passportWrapper.ClientData cd=new passportWrapper.ClientData();
                            cd.caseId=GlobalUtility.getUniqueNumber();
                            passportDetails.ClientData=cd;




                            IntgMsg__c intg=New IntgMsg__c();
                            intg.id=intMsg.id;
                            intg.Req__c= JSON.serialize(passportDetails) ;
                            // intg.Req__c = JSON.serialize(passportDetails); 
                            intg.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                            UpdateIntrecods.add(intg);
                            
                    //    }else{
                    //        throw new passportException('Date of Birth is null');
                    //    }
                    //}
                    //else{
                    //    throw new passportException('fileNo Number is null');
                    //}  
                }
                if(!UpdateIntrecods.isEmpty()){
                    List<string> fieldNamesList = New List<string>{'Req__c','Status__c'};               
                        String sObjectName = 'IntgMsg__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                    uow.registerDirty(UpdateIntrecods);
                    //update UpdateIntrecods;
                }
            }
            uow.commitWork();
        }
        //Catch bloack to catch Exceptions occured during generation of payload and displaying the passing the same in GlobalUtility class
        catch(Exception ex){
            System.debug('error '+ex.getMessage());
            GlobalUtility.logMessage('Error', 'passportRequestGenerator' + ex.getLineNumber(), 
                                     'Generate', null, null, ex.getMessage() + ' Line: ' + ex.getLineNumber(), null, ex, null);
        }
    }
    
   
    public class passportException extends Exception {
        
    }
}