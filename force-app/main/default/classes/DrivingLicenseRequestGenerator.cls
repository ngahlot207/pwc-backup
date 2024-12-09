public class DrivingLicenseRequestGenerator implements ICalloutRequestGenerator{
    
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
        List<ApplKyc__c> appKycList = new List<ApplKyc__c>([SELECT Id,DLNo__c,Applicant__c,DtOfBirth__c FROM ApplKyc__c WHERE id IN :Ids AND kycDoc__c = 'Driving License']);
        
        system.debug('appKycList :::: '+appKycList);
        for(ApplKyc__c appku : appKycList){
            appKycMap.put(appku.id,appku);
        }
        Map<Id,Applicant__c> appRecMap = new Map<Id,Applicant__c>([SELECT Id,dob__c FROM Applicant__c WHERE Id=:appKycList[0].Applicant__c]);
        system.debug('appKycMap :::: '+ appKycMap);
        try{
            //If the List of new Integration Message records is not empty, then iterating over and assigning data to variables from Wrapper Class
            List<IntgMsg__c>UpdateIntrecods=New List<IntgMsg__c>();
            
            if(!msgs.isEmpty()){
                
                for(IntgMsg__c intMsg : msgs){
                    
                    Applicant__c ApplRec = appRecMap.get(appKycList[0].Applicant__c);
                    
                    ApplKyc__c applKycRec = appKycMap.get(intMsg.ParentRefId__c);
                    
                    DrivingLicenseWrapper drivingLicenseDetails = new DrivingLicenseWrapper();
                    
                    drivingLicenseDetails.consent = GlobalConstants.CONSENT_Y;
                    drivingLicenseDetails.additionalDetails =true;
                    ClientData cd = new ClientData();
                    cd.caseId=GlobalUtility.getUniqueNumber();
                    drivingLicenseDetails.clientData=cd;
                    
                    //if(applKycRec.DLNo__c != null){
                    //    if(applKycRec.DtOfBirth__c != null){                     
                            drivingLicenseDetails.dlNo = applKycRec.DLNo__c != null ? applKycRec.DLNo__c : '';        
                            drivingLicenseDetails.dob = applKycRec.DtOfBirth__c != null ? String.valueOf(DateTime.newInstance(applKycRec.DtOfBirth__c.year(), applKycRec.DtOfBirth__c.month(), applKycRec.DtOfBirth__c.day()).format('dd-MM-yyyy')) : '';       
                            IntgMsg__c intg = New IntgMsg__c();
                            intg.id=intMsg.id;
                            intg.Req__c =  JSON.serialize(drivingLicenseDetails); 
                            intg.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                            UpdateIntrecods.add(intg);
                            
                    //    }else{
                    //        throw new drivingLicenseException('Date of Birth is null');
                            //intg.addError('date of birth is null');
                    //    }
                    //}
                    //else{
                    //    throw new drivingLicenseException('driving license Number is null');
                    //}  
                }
                if(!UpdateIntrecods.isEmpty()){
                    List<string> fieldNamesList = New List<string>{'Req__c','Status__c'};
                        String sObjectName = 'IntgMsg__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                    uow.registerDirty(UpdateIntrecods);  
                }
            }
            uow.commitWork();
        }
        //Catch bloack to catch Exceptions occured during generation of payload and displaying the passing the same in GlobalUtility class
        catch(Exception ex){
            GlobalUtility.logMessage('Error', 'DrivingLicenseRequestGenerator' + ex.getLineNumber(), 
                                     'Generate', null, null, ex.getMessage() + ' Line: ' + ex.getLineNumber(), null, ex, null);
        }
    }
    
    //Wrapper class
    public class DrivingLicenseWrapper{
        public String consent {get;set;}
        public String dlNo {get;set;}
        public String dob {get;set;}
        public boolean additionalDetails;
        public ClientData clientData;

    }
    public class ClientData {
        public String caseId;
      }
    public class drivingLicenseException extends Exception {
        
    }
}