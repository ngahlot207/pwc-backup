@istest
public class ENPAResponseProcessorTest {
    @isTest
    static void enpaResponseProcessorTestMethod() {
        
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        
        Applicant__c appli =  TestDataFactory.createSingleApplicant(true,loanApp.id); 
        
        List<ENPAResponseWrapper.Data> dataList = new List<ENPAResponseWrapper.Data>(); 
        ENPAResponseWrapper.Data resWra = new ENPAResponseWrapper.Data();
        resWra.UCIC = '12784057';
        resWra.CustomerID = '891524';
        resWra.LAN = 'FEDGL03940004822';
        resWra.CustomerName = 'ANAND BABURAO RATHOD';
        resWra.AUM = '201800.00';
        resWra.AUF = '201800.00';
        resWra.DisbursementDate = '2022-09-05';
        resWra.DPD = '0';
        resWra.NPA_DATE = '2022-09-05';
        resWra.Product = 'Lcode';
        resWra.SecuritizationFlg = 'N';
        resWra.Tenure = '2';
        resWra.LINKED_UCIC = 'Linked-12784057';
        resWra.TotalProvisionWithoutVarAmount = '809.89';
        resWra.FinalAssetClass = 'STD';
        resWra.TotalProvisionWithVarAmount = '809.89';
        resWra.LoanAmount ='201800';
        dataList.add(resWra);
        
        ENPAResponseWrapper enpaRespDet = new ENPAResponseWrapper();
        enpaRespDet.Data = dataList;
        enpaRespDet.status = 1;
        enpaRespDet.message = 'Success';
        
        String wrapperdata = JSON.serialize(enpaRespDet);
        
        List<IntgMsg__c> intMsglist =  TestDataFactory.createIntMsg(true, 'ENPADeatils', appli.id, wrapperdata);
        
        
        Test.startTest();
        ENPAResponseProcessor.process(intMsglist);
        Test.stopTest();
        
        Id enpaRecordTypeId = Schema.SObjectType.DedupeResponse__c.getRecordTypeInfosByDeveloperName().get('ENPA').getRecordTypeId();
        List<DedupeResponse__c> existingdedupeList = [Select Id,IsLatest__c FROM DedupeResponse__c WHERE IsLatest__c=True AND Applicant__c=: appli.Id AND LoanAppln__c=:loanApp.Id AND RecordTypeId=:enpaRecordTypeId];
        
        System.assertEquals(1, existingdedupeList.size());
        //system.debug('existingdedupeList ' + existingdedupeList.size());
        Applicant__c appliUpdated = [SELECT Id,IntegrationErrorMessage__c,IntegrationStatus__c FROM  Applicant__c LIMIT 1 ];
        //system.debug('appliUpdated ' + appliUpdated);
        System.assertEquals('ENPA: Success', appliUpdated.IntegrationStatus__c);
        
        List<IntgMsg__c> updateIntMsglist = new List<IntgMsg__c>();
        for(IntgMsg__c intmsg : intMsglist){
            IntgMsg__c intMsgg = new IntgMsg__c();
            intMsgg.Id  = intmsg.Id;
            intMsgg.Trigger_Platform_Event__c = true;
            updateIntMsglist.add(intMsgg);
        }
        update updateIntMsglist;
        Boolean assertsBool = true;
        try{
            TriggerBase.bypass('IntgMsg__c');
            ENPAResponseProcessor.process(updateIntMsglist);
            TriggerBase.clearBypass('IntgMsg__c');
            
        }catch(processException ex){
            assertsBool = false;
            system.assertEquals('Error! This is not the correct service', ex.getMessage());
        }  
         system.assertEquals(false, assertsBool);
        
        ENPAResponseWrapper enpaRespDetError = new ENPAResponseWrapper();
        enpaRespDetError.Data = dataList;
        enpaRespDetError.status = 0;
        enpaRespDetError.message = 'Error';
        
        String wrapperdataErr = JSON.serialize(enpaRespDetError);
        
        List<IntgMsg__c> intMsglistNew =  TestDataFactory.createIntMsg(true, 'ENPADeatils', appli.id, wrapperdataErr);
        
        List<DedupeResponse__c> enpaRecList = new List<DedupeResponse__c>(); 
        DedupeResponse__c dedupeRes = new DedupeResponse__c();
        dedupeRes.IsLatest__c =true;
        dedupeRes.AppId__c = appli.Id;
        dedupeRes.LoanAppln__c = loanApp.Id;
        dedupeRes.RecordTypeId = enpaRecordTypeId;
        enpaRecList.add(dedupeRes);
        
        
       // ENPAResponseProcessor.process(null);
       Boolean assertsBoolNew = true;
        try{
            TriggerBase.bypass('IntgMsg__c');     
            ENPAResponseProcessor.process(intMsglistNew);
             ENPAResponseProcessor.process(null);
            TriggerBase.clearBypass('IntgMsg__c');
            
        }catch(NullPointerException ex){
            assertsBoolNew = false;
            system.assertEquals('Attempt to de-reference a null object', ex.getMessage());
        } 
        system.assertEquals(false, assertsBoolNew);
    }   
}