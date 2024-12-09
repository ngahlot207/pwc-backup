public class Demo   {
    
   // In Apex, you need to use the `Blob` class for cryptographic operations.
    public static String getSignature(String path, String apiSecret) {
        String signature = null;
        
        // Use `Crypto` class for HMAC-SHA256 hashing in Apex.
        Blob hmac256 = Crypto.generateMac('HmacSHA256', Blob.valueOf(path), Blob.valueOf(apiSecret));
        
        // Convert the resulting hash to Base64 encoded string.
        signature = EncodingUtil.base64Encode(hmac256);
        
        return signature;
    }

    // Apex doesn't use a `main` method; you typically call methods directly or from triggers.
    // For demonstration, you can define a method to simulate the main logic.
    public static void simulateMainLogic() {
        String apiKey = 'cb8fedb939fe11ef9b7b0267c6221b81';
        String apiSecret = 'LIGTiBlCBXQMSAhIaVmQWZZQBSFRSnVdfKYeDbkIIkPYOimdOQ';
        Long timeStamp = System.currentTimeMillis();
        
        String apiTimePair = apiKey + ':' + String.valueOf(timeStamp);
        System.debug('apiTimePair = ' + apiTimePair);
        
        // Call the getSignature method to compute the signature.
        String signature = getSignature(apiTimePair, apiSecret);
        System.debug('signature: ' + signature);
    }
    
   /* public static void calculate1()
    {
        Map<String ,Id> mapUse = new Map<String ,Id>();

        List<APIVer__c> verList =[SELECT Id,name,(select id from API_Verification_Details__r) from APIVer__c  where id In ('a1aC40000006jX7IAI','a1aC40000006p6HIAQ')];

        Integer cnt=1;
        for(APIVer__c eachObj : verList){

            integer reslt= 0;
            if(!eachObj.API_Verification_Details__r.isEmpty()){
                System.debug('size =='+eachObj.API_Verification_Details__r.size());
                reslt=eachObj.API_Verification_Details__r.size();
            }
            
            
            mapUse.put('Occur: '+reslt + ',Count:' +cnt, eachObj.Id);
            cnt++;

        }

        System.debug('The o/p is::'+mapUse);

    }   */
    /*
    public static Map<Id, Id> getIdForApiVerDetls(Set<Id> IdOfAppls){
        Map<Id, Id> applToApiVerIdMap1 = new Map<Id, Id>();
        if (IdOfAppls == null || IdOfAppls.isEmpty()) {
                return applToApiVerIdMap1; // Return an empty map
        }
        List<APIVer__c> listFinalAPiver = [
                SELECT Id, Appl__c, IsLatest__c, RecordType.Name
                FROM APIVer__c
                WHERE Appl__c IN :IdOfAppls
                AND RecordType.Name = 'Probe42'
                AND IsLatest__c = true
        ];

        for (APIVer__c eachApiVer : listFinalAPiver) {
                    applToApiVerIdMap1.put(eachApiVer.Appl__c, eachApiVer.Id);
        }
        return applToApiVerIdMap1;
    }
    /*
   public static void process(List<IntgMsg__c> responses) {
        
        
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> {APIVer__c.SObjectType ,APIVerDtl__c.SObjectType});
        
        try{
        
        
        List<IntgMsg__c> responses1=[SELECT Id,name,Resp__c,RefId__c,ParentRefId__c from IntgMsg__c where id='a0GC4000001MenuMAC'];
         Set<Id> applicantIds = new Set<Id>();
            Set<Id> loanAppIds = new Set<Id>();
            for (IntgMsg__c intmsg : responses1) {
                if (String.isNotBlank(intmsg.RefId__c)) {
                    applicantIds.add(intmsg.RefId__c);
                }
                if (String.isNotBlank(intmsg.ParentRefId__c)) {
                    loanAppIds.add(intmsg.ParentRefId__c);
                }
            }
        
        if(!responses1.isEmpty()){
            
            List<APIVer__c> apiVerListInsert = new List<APIVer__c>();
            for(IntgMsg__c intmsg:responses1){
                
                if(String.isNotBlank(intmsg.Resp__c)){
                    
                    
                        Demowrapper  resObj =(Demowrapper) JSON.deserialize(intmsg.Resp__c,Demowrapper.class);
                        
                        APIVer__c apiVerObj = new APIVer__c();
                        apiVerObj.RecordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByDeveloperName().get('Probe42').getRecordTypeId();
                        apiVerObj.Appl__c = intmsg.RefId__c;
                        apiVerObj.IsLatest__c = true;
                        apiVerObj.IntegrationStatus__c = 'Success';
                       
                        
                        if(resObj !=null){

                    	if(resObj.metadata !=null ){

                        apiVerObj.ApiVersion__c =resObj.metadata.api_version;
                        apiVerObj.Lstupdt__c = Date.valueOf(resObj.metadata.last_updated);

                    	}
                            
                        uow.registerNew(apiVerObj);
                        
                            
                            if(resObj.data.authorized_signatories !=null){
                                for(Demowrapper.Authorized_signatories eachAuth :resObj.data.authorized_signatories ){
                                    APIVerDtl__c firDtl= new APIVerDtl__c();
                                    firDtl.AuthSignPan__c=eachAuth.pan; 
                                    firDtl.Type__c='Additional Address';
                                    //uow.registerNew(firDtl);
                                    uow.registerNew(firDtl, firDtl.Id, apiVerObj);
                                    
                                    if(eachAuth.association_history !=null){
                                        for(Demowrapper.Association_history eachHis :eachAuth.association_history){
                                            APIVerDtl__c secDtl= new APIVerDtl__c();
                                            secDtl.AuthSignPan__c=eachHis.event;
                                            secDtl.Type__c='Employers History';
                                            //uow.registerNew(secDtl);
                                            uow.registerRelationship(secDtl, secDtl.Id, firDtl);
      										uow.registerNew(secDtl, apiVerObj.Id, apiVerObj);
                                            
                                        }
                                    }
                                    
                                }
                            }
                            
                            
                            
                            
                        }
                    
                }
            }
            
        }
        
    }catch(Exception ex){
                       System.debug('Error');
                        
                      
     }
    }
    
    
    public static void process(List<IntgMsg__c> responses) {
    // Initialize the Unit of Work
    fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> {APIVer__c.SObjectType, APIVerDtl__c.SObjectType});

    try {
        // Query the IntgMsg__c records
        List<IntgMsg__c> responses1 = [SELECT Id, name, Resp__c, RefId__c, ParentRefId__c FROM IntgMsg__c WHERE id = 'a0GC4000001MenuMAC'];
        Set<Id> applicantIds = new Set<Id>();
        Set<Id> loanAppIds = new Set<Id>();

        // Extract IDs from the responses
        for (IntgMsg__c intmsg : responses1) {
            if (String.isNotBlank(intmsg.RefId__c)) {
                applicantIds.add(intmsg.RefId__c);
            }
            if (String.isNotBlank(intmsg.ParentRefId__c)) {
                loanAppIds.add(intmsg.ParentRefId__c);
            }
        }

        // Process the responses if not empty
        if (!responses1.isEmpty()) {
            for (IntgMsg__c intmsg : responses1) {
                if (String.isNotBlank(intmsg.Resp__c)) {
                    // Deserialize the response JSON
                    Demowrapper resObj = (Demowrapper) JSON.deserialize(intmsg.Resp__c, Demowrapper.class);

                    // Create and register the APIVer__c record
                    APIVer__c apiVerObj = new APIVer__c();
                    apiVerObj.RecordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByDeveloperName().get('Probe42').getRecordTypeId();
                    apiVerObj.Appl__c = intmsg.RefId__c;
                    apiVerObj.IsLatest__c = true;
                    apiVerObj.IntegrationStatus__c = 'Success';

                    if (resObj != null && resObj.metadata != null) {
                        apiVerObj.ApiVersion__c = resObj.metadata.api_version;
                        apiVerObj.Lstupdt__c = Date.valueOf(resObj.metadata.last_updated);
                    }

                    uow.registerNew(apiVerObj);

                    // Process and register APIVerDtl__c records
                    if (resObj.data.authorized_signatories != null) {
                        for (Demowrapper.Authorized_signatories eachAuth : resObj.data.authorized_signatories) {
                            APIVerDtl__c firDtl = new APIVerDtl__c();
                            firDtl.AuthSignPan__c = eachAuth.pan;
                            firDtl.Type__c = 'Additional Address';
                            firDtl.APIVerification__c = apiVerObj.Id;

                            uow.registerNew(firDtl);

                            if (eachAuth.association_history != null) {
                                for (Demowrapper.Association_history eachHis : eachAuth.association_history) {
                                    APIVerDtl__c secDtl = new APIVerDtl__c();
                                    secDtl.AuthSignPan__c = eachHis.event;
                                    secDtl.Type__c = 'Employers History';
                                    secDtl.ApiVerDetails__c = firDtl.Id;
                                    secDtl.APIVerification__c=apiVerObj.Id;

                                    uow.registerNew(secDtl);
                                }
                            }
                        }
                    }
                }
            }
        }

        // Commit the Unit of Work - all DML operations are performed here
        uow.commitWork();
        
        

    } catch (Exception ex) {
        System.debug('Error: ' + ex.getMessage());
        System.debug('Error line : ' + ex.getLineNumber());
    }
}

*/

    
    //self lookup
    /*
    public static void process(List<IntgMsg__c> responses) {
    // Initialize the Unit of Work
    fflib_SObjectUnitOfWork uow1 = new fflib_SObjectUnitOfWork(new List<SObjectType> {APIVer__c.SObjectType, APIVerDtl__c.SObjectType   }); 
    fflib_SObjectUnitOfWork uow2 = new fflib_SObjectUnitOfWork(new List<SObjectType> {APIVer__c.SObjectType, APIVerDtl__c.SObjectType   }); 

    try {
        // Query the IntgMsg__c records
        List<IntgMsg__c> responses1 = [SELECT Id, name, Resp__c, RefId__c, ParentRefId__c FROM IntgMsg__c WHERE id = 'a0GC4000001MenuMAC'];

        // Process the responses if not empty
        if (!responses1.isEmpty()) {
            for (IntgMsg__c intmsg : responses1) {
                if (String.isNotBlank(intmsg.Resp__c)) {
                    // Deserialize the response JSON
                    Demowrapper resObj = (Demowrapper) JSON.deserialize(intmsg.Resp__c, Demowrapper.class);

                    // Create and register the APIVer__c record
                    APIVer__c apiVerObj = new APIVer__c();
                    apiVerObj.RecordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByDeveloperName().get('Probe42').getRecordTypeId();
                    apiVerObj.Appl__c = intmsg.RefId__c;
                    apiVerObj.IsLatest__c = true;
                    apiVerObj.IntegrationStatus__c = 'Success';

                    if (resObj != null && resObj.metadata != null) {
                        apiVerObj.ApiVersion__c = resObj.metadata.api_version;
                        apiVerObj.Lstupdt__c = Date.valueOf(resObj.metadata.last_updated);
                    }

                    // Register the APIVer__c record
                    uow1.registerNew(apiVerObj);

                    // Process and register APIVerDtl__c records
                    if (resObj.data.authorized_signatories != null) {
                        APIVerDtl__c previousDtl = null; // To keep track of previous APIVerDtl__c record

                        for (Demowrapper.Authorized_signatories eachAuth : resObj.data.authorized_signatories) {
                            APIVerDtl__c firDtl = new APIVerDtl__c();
                            firDtl.AuthSignPan__c = eachAuth.pan;
                            firDtl.Type__c = 'Additional Address';
                            //firDtl.APIVerification__c = apiVerObj.Id;

                            // Register APIVerDtl__c record and establish relationship with APIVer__c
                           
                            uow1.registerRelationship(firDtl, APIVerDtl__c.APIVerification__c, apiVerObj);  
							uow1.registerNew(firDtl);
                            
                            if (eachAuth.association_history != null) {
                                for (Demowrapper.Association_history eachHis : eachAuth.association_history) {
                                    System.debug('Association_history Obj :'+eachHis);
                                    APIVerDtl__c secDtl = new APIVerDtl__c();
                                    //secDtl.AuthSignPan__c = eachHis.event;
                                    secDtl.Type__c = 'Employers History';
                                    //secDtl.APIVerification__c = apiVerObj.Id;
                                    //secDtl.ApiVerDetails__c = firDtl.Id;

                                   
                                    //uow.registerRelationship(secDtl, API_Verification_Detail_Child__c.API_Verification_Detail__c, firDtl);
                                    //uow.registerNew(secDtl);
                                    
                                    //uow.registerRelationship(secDtl, APIVerDtl__c.ApiVerDetails__c, firDtl);  
                                    uow2.registerRelationship(secDtl, APIVerDtl__c.ApiVerDetails__c, firDtl);
                                    uow2.registerRelationship(secDtl, APIVerDtl__c.APIVerification__c, apiVerObj);
                                    uow2.registerNew(secDtl);
                              
                        }
                    }
                        }         
                }
            }
        }

        // Commit the Unit of Work - all DML operations are performed here
        uow1.commitWork();
            uow2.commitWork();
        }
    } catch (Exception ex) {
        System.debug('Error: ' + ex.getMessage());
        System.debug('Error line : ' + ex.getLineNumber());
    }
} */

}