public class AadharXMLVerificationRequestGenerator implements ICalloutRequestGenerator {
    public void generate(
        List<IntgMsg__c> msgs,
        String service,
        String processType
    ) {
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new List<SObjectType>{ IntgMsg__c.SObjectType }
        );

        //Creating a Set of Ids
        Set<Id> Ids = new Set<Id>();

        //Iterating over new Intgeration Message record Ids to add them into the above Set
        for (IntgMsg__c intMsg : msgs) {
            Ids.add(intMsg.ParentRefId__c);
        }

        Map<Id, ApplKyc__c> appKycMap = new Map<Id, ApplKyc__c>(
            [
                SELECT Id, AadharEncripted__c, Applicant__c
                FROM ApplKyc__c
                WHERE Id IN :Ids
            ]
        );

        try {
            List<IntgMsg__c> updateIntMsgList = new List<IntgMsg__c>();

            //If the List of new Integration Message records is not empty, then iterating over and assigning data to variables from Wrapper Class
            if (!msgs.isEmpty()) {
                for (IntgMsg__c intMsg : msgs) {
                    if (appKycMap.containsKey(intMsg.ParentRefId__c)) {
                        ApplKyc__c applKycRec = appKycMap.get(
                            intMsg.ParentRefId__c
                        );

                        AadharXMLVerificationRequestWrapper aadharXMLRequestDetails = new AadharXMLVerificationRequestWrapper();
                        aadharXMLRequestDetails.source_type = 'id';

                        //if(applKycRec.AadharEncripted__c != null){

                        aadharXMLRequestDetails.source = applKycRec.AadharEncripted__c !=
                            null
                            ? applKycRec.AadharEncripted__c
                            : null;
                        aadharXMLRequestDetails.reference_id = GlobalUtility.getUniqueNumber();

                        IntgMsg__c intg = new IntgMsg__c();
                        intg.id = intMsg.id;
                        intg.Req__c = SigndeskAPIController.getEncryptedRequest(
                            JSON.serialize(aadharXMLRequestDetails)
                        );
                        intg.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                        updateIntMsgList.add(intg);

                        //}
                        //else{
                        //    throw new AadharXMLVerificationException('Aadhar Number is null');
                        //}
                    }
                    //else{
                    //    throw new AadharXMLVerificationException('Invalid Reference Id');
                    //}
                }

                if (!updateIntMsgList.isEmpty()) {
                    String sObjectName = 'IntgMsg__c';
                    List<String> fieldNamesList = new List<String>{
                        'Req__c',
                        'Status__c'
                    };
                    Schema.SObjectType objType = Schema.getGlobalDescribe()
                        .get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType, fieldNamesList);
                    uow.registerDirty(updateIntMsgList);
                }
            }
            uow.commitWork();
        }
        //Catch bloack to catch Exceptions occured during generation of payload and displaying the passing the same in GlobalUtility class
        catch (Exception ex) {
            GlobalUtility.logMessage('Error','AadharXMLVerificationRequestGenerator' + ex.getLineNumber(),'Generate',null,null,ex.getMessage() + ' Line: ' + ex.getLineNumber(),null,ex,null);
        }
    }
    public class AadharXMLVerificationException extends Exception {
    }
}