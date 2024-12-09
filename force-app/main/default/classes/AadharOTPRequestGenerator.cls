public class AadharOTPRequestGenerator implements ICalloutRequestGenerator{
    
    public void generate(List<IntgMsg__c> msgs, String service, String processType){ 
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> { IntgMsg__c.SObjectType });
        
        Set<Id> ids = new Set<Id>();
        
        //Iterating over new Intgeration Message record Ids to add them into the above Set
        for(IntgMsg__c intMsg : msgs){ 
            ids.add(intMsg.ParentRefId__c);
        }
        
        Map<Id,ApplKyc__c> appKycMap = new Map<Id,ApplKyc__c>([SELECT Id,Applicant__c,OTP__c,TransactionId__c,ReferenceId__c FROM ApplKyc__c WHERE Id IN :ids ]);
        
        try{
            List<IntgMsg__c>updateIntMsgList=New List<IntgMsg__c>(); 
            
            //If the List of new Integration Message records is not empty, then iterating over and assigning data to variables from Wrapper Class            
            if(!msgs.isEmpty()){
                for(IntgMsg__c intMsg : msgs){
                    if(appKycMap.containsKey(intMsg.ParentRefId__c)){
                        
                        ApplKyc__c applKycRec = appKycMap.get(intMsg.ParentRefId__c); 
                        AadharOTPRequestwrapper aadharOTPRequestDetails = new AadharOTPRequestwrapper();
                        
                        if(applKycRec.Id != null){
                            aadharOTPRequestDetails.reference_id  = applKycRec.ReferenceId__c;
                            aadharOTPRequestDetails.otp=applKycRec.OTP__c;
                            aadharOTPRequestDetails.transaction_id = applKycRec.TransactionId__c;
                            
                            IntgMsg__c intg=New IntgMsg__c();
                            intg.id=intMsg.id;
                            intg.Req__c = SigndeskAPIController.getEncryptedRequest(JSON.serialize(aadharOTPRequestDetails)); 
                            intg.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                            updateIntMsgList.add(intg);
                        }
                        
                    }
                    //else{
                    //    throw new AadharOTPRequestGeneratorException('Invalid Reference Id');
                    //}
                }
                if(!updateIntMsgList.isEmpty()){
                    String sObjectName = 'IntgMsg__c';
                    List<String> fieldNamesList = new List<String>{'Req__c','Status__c'};
                        Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                    uow.registerDirty(updateIntMsgList);
                    
                }
            
            }
            uow.commitWork();
        }
        //Catch bloack to catch Exceptions occured during generation of payload and displaying the passing the same in GlobalUtility class
        catch(Exception ex){
            GlobalUtility.logMessage('Error', 'AadharXMLVerificationRequestGenerator' + ex.getLineNumber(), 
                                     'Generate', null, null, ex.getMessage() + ' Line: ' + ex.getLineNumber(), null, ex, null);
        }
        
    }       
    public class AadharOTPRequestGeneratorException extends Exception {
        
    }
}