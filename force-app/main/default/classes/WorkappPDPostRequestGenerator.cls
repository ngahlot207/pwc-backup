public class WorkappPDPostRequestGenerator implements ICalloutRequestGenerator {

    public void generate(List<IntgMsg__c> msgs, String service, String processType) {
        if (msgs.isEmpty()) {
            return;
        }

        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { IntgMsg__c.SObjectType });
        IntgSvcMgmt__mdt svc = IntgSvcMgmt__mdt.getInstance('Guest_Call'); //Guest_Call_Details
        try {
            Set<Id> persDisIds = new Set<Id>(); // PD__c
            Set<Id> applicantIds = new Set<Id>(); // Applicant__c

            // Collecting all Applicant and PD Ids
            for (IntgMsg__c msg : msgs) {
                if (String.isNotBlank(msg.RefId__c)) {
                    persDisIds.add(msg.RefId__c);
                }
                if (String.isNotBlank(msg.ParentRefId__c)) {
                    applicantIds.add(msg.ParentRefId__c);
                }
            }

            if (!persDisIds.isEmpty()) {
                Map<Id, PD__c> perDisMap = getPDRecords(applicantIds);
                
                List<IntgMsg__c> updateIntMsgRecords = new List<IntgMsg__c>();
                for (IntgMsg__c intmsg : msgs) {
                    if (perDisMap.containsKey(intmsg.RefId__c)) {
                        PD__c pdRecord = perDisMap.get(intmsg.RefId__c);
                        WorkAppCommonReqWrapper.WorkappPDPostRequestWrapper mainObj = createWorkappPDPostRequestWrapper(pdRecord,intmsg);
                        
                        Map<String,String> header = new Map<String,String>();
                        long crDateTime = intMsg.CreatedDate.getTime();
                        header.put('Timestamp',String.valueOf(crDateTime));
                        header.put('Signature',WorkAppCommonReqWrapper.getSignByMainLogic(crDateTime));
                        header.put('RequestId',intmsg.Integration_Message_Number__c +'-'+crDateTime);
                        
                        Map<String, Object> combinedMap = new Map<String, Object>();
                        combinedMap.put('Payload', mainObj);
                        combinedMap.put('Header', header);
                            
                        // Serialize the combined map
                        String jsonString = JSON.serialize(combinedMap);
                        
                        IntgMsg__c integrationMessage = new IntgMsg__c();
                        integrationMessage.Id = intmsg.Id;
                        integrationMessage.Req__c = jsonString;
                        integrationMessage.Status__c = GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS;
                        updateIntMsgRecords.add(integrationMessage);

                    }
                }

                // Updating Integration Messages
                if (!updateIntMsgRecords.isEmpty()) {
                    registerAndCommit(uow, updateIntMsgRecords);
                }
            }
        } catch (Exception ex) {
            GlobalUtility.logMessage('Error', 'WorkappPDPostRequestGenerator', 
                                     'generate', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
    }

    private Map<Id, PD__c> getPDRecords(Set<Id> applicantIds) {
        return new Map<Id, PD__c>([SELECT Id, PDRmrks__c, Appl__r.FullName__c,Appl__r.MobNumber__c,Appl__r.EmailId__c,LoanAppl__r.name,Appl__r.name,LoanAppl__r.Product__c, CmpltDt__c, AsgnTo__r.Name,Appl__r.TabName__c, AsgnTo__r.EmployeeNumber, SchDate__c, PDStatus__c 
            FROM PD__c WHERE Appl__c IN :applicantIds ORDER BY CreatedDate DESC ]);
    }

    private WorkAppCommonReqWrapper.WorkappPDPostRequestWrapper createWorkappPDPostRequestWrapper(PD__c pdRecord,IntgMsg__c msg) {
        WorkAppCommonReqWrapper.WorkappPDPostRequestWrapper mainObj = new WorkAppCommonReqWrapper.WorkappPDPostRequestWrapper();
        mainObj.entityId = 221; //Will provided by client maintain in metadata service metadata
        mainObj.productType = 4;//4 – Individual Guest Chat 
        mainObj.firstName = pdRecord.Appl__r.FullName__c;
        mainObj.mobileNumber = pdRecord.Appl__r.MobNumber__c != null ? String.valueOf(pdRecord.Appl__r.MobNumber__c): '' ; // Set appropriate value
        mainObj.email = pdRecord.Appl__r.EmailId__c != null ? pdRecord.Appl__r.EmailId__c: '' ;// Set appropriate value  
        mainObj.statusUrl = ''; // Optional
        mainObj.useCase = 1; // For Video PD it's 1
        mainObj.userPhoto = ''; // optional
        mainObj.countryCode = '91';
       // mainObj.employeeId = pdRecord.AsgnTo__r.EmployeeNumber !=null ? pdRecord.AsgnTo__r.EmployeeNumber :'';

        List<WorkAppCommonReqWrapper.Data> dataList = new List<WorkAppCommonReqWrapper.Data>();
        
        
            WorkAppCommonReqWrapper.Data eachData = new WorkAppCommonReqWrapper.Data();
            eachData.key = 'clientUserId';
            eachData.value =  pdRecord.Appl__r.name!=null ? pdRecord.Appl__r.name : ''; 
            dataList.add(eachData);

            WorkAppCommonReqWrapper.Data eachData1 = new WorkAppCommonReqWrapper.Data();
            eachData1.key ='product';
            eachData1.value = pdRecord.LoanAppl__r.Product__c!=null ? pdRecord.LoanAppl__r.Product__c :'';
            dataList.add(eachData1);

            WorkAppCommonReqWrapper.Data eachData2 = new WorkAppCommonReqWrapper.Data();
            eachData2.key ='customerId'; //OK
            eachData2.value = pdRecord.Appl__r.FullName__c !=null ? pdRecord.Appl__r.FullName__c : '';
            dataList.add(eachData2);

            WorkAppCommonReqWrapper.Data eachData3 = new WorkAppCommonReqWrapper.Data();
            eachData3.key ='trackingId';
            eachData3.value = msg.name;
            dataList.add(eachData3);

            WorkAppCommonReqWrapper.Data eachData4 = new WorkAppCommonReqWrapper.Data();
            eachData4.key ='applicationId';
            eachData4.value = pdRecord.LoanAppl__r.name !=null? pdRecord.LoanAppl__r.name :'';
            dataList.add(eachData4);

            WorkAppCommonReqWrapper.Data eachData5 = new WorkAppCommonReqWrapper.Data();
            eachData5.key ='otherInfo';  //OK
            eachData5.value ='otherInfo';
            dataList.add(eachData5);


            mainObj.data=dataList;
       
            return mainObj;
    }

    private void registerAndCommit(fflib_SObjectUnitOfWork uow, List<IntgMsg__c> updateIntMsgRecords) {
        String sObjectName = 'IntgMsg__c';
        List<String> fieldNamesList = new List<String> { 'Req__c', 'Status__c' };
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(sObjectName);
        fflib_SecurityUtils.checkUpdate(objType, fieldNamesList);
        uow.registerDirty(updateIntMsgRecords);
        uow.commitWork();
    }
}