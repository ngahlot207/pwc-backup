@isTest
private class ApplicationQueryOpsChangeTest {
	@isTest
	static void testAfterInsert() {
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        NDC__c ndcRecord = new NDC__c(
        LoanAppl__c=loanApp.Id,
            OpsQuery__c=true
        );
        insert ndcRecord;
        NDC__c ndcRecord1 = new NDC__c(
        LoanAppl__c=loanApp.Id,
            OpsQuery__c=true
        );
        insert ndcRecord1;
        List<Application_Query__c> listToInsert =new List<Application_Query__c>();
        Application_Query__c queryRecordOps = new Application_Query__c(
            NDC__c = ndcRecord.Id,
            Role__c = 'AOM'
        );
        listToInsert.add(queryRecordOps);
        Application_Query__c queryRecordCPA = new Application_Query__c(
            NDC__c = ndcRecord1.Id,
             Role__c = 'CPA',
            QryTyp__c='NDC Query'
        );
        listToInsert.add(queryRecordCPA);
        insert listToInsert;
        set<id> idSet=new set<id>();
        for(Application_Query__c appQu: listToInsert){
            idSet.add(appQu.Id);
        }
        List<Application_Query__c> listToPass=[select id,NDC__c,Role__c from Application_Query__c where id IN: idSet];
        system.debug('listToPass'+listToPass.size());
        Test.startTest();
        applicationQueryOpsChange.afterInsert(listToPass);
        Test.stopTest();
        NDC__c updatedNdcRecord = [SELECT Id, OpsQuery__c FROM NDC__c WHERE Id = :ndcRecord.Id LIMIT 1];
        NDC__c updatedNdcRecord1 = [SELECT Id, OpsQuery__c FROM NDC__c WHERE Id = :ndcRecord1.Id LIMIT 1];
        List<Application_Query__c> updatedQueryRecords = [SELECT Id, Responded__c FROM Application_Query__c WHERE NDC__c = :ndcRecord.Id];
        system.debug('updatedNdcRecord1.OpsQuery__c'+updatedNdcRecord1.OpsQuery__c);
        System.assertEquals(true, updatedNdcRecord.OpsQuery__c, true);
        System.assertEquals(false, updatedNdcRecord1.OpsQuery__c, true);
	}
    

}