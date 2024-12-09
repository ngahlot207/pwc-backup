@istest
public class SObjectDynamicRecordProviderTest {
    
    @testsetup
    static void dataSetupMethod(){
        LoanAppl__c loanAppRecord= TestDataFactory.createLoanApplication(true);
        Applicant__c app=TestDataFactory.createSingleApplicant(true,loanAppRecord.Id);
        ApplRegltry__c appRegulatory=TestDataFactory.createApplRegltry(true,app.Id,loanAppRecord.Id);
        RegltryPrsonl__c regulaPersnl=TestDataFactory.createRegPersonal(true,appRegulatory.Id);
        List<RegltryPrsonl__c> regulaPersnlList = new List<RegltryPrsonl__c>(); 
        regulaPersnlList.add(regulaPersnl);
    }
    
    static testmethod void sObjectDynamicRecordProviderTestMethod(){
        Applicant__c appRecords = [SELECT id FROM Applicant__c LIMIT 1];
        SObjectDynamicRecordProvider.SobjectQueryParams params = new SObjectDynamicRecordProvider.SobjectQueryParams();
        params.ParentObjectName = 'ApplRegltry__c';
        params.ChildObjectRelName = 'Regulatory_Personnel__r';
        List<String>parentObjField = new List<String>{'IsBorowrOrRelFFDir__c'};
            params.parentObjFields = parentObjField;
        List<String>childObjField = new List<String>{'DirName__c','Desgntn__c','Reltnshp__c'};
            params.childObjFields = childObjField;
        String dynamicId = appRecords.Id;
        params.queryCriteria = ' where Appl__c = \'' + dynamicId + '\'' ;
        SObjectDynamicRecordProvider.SobjctDataWrapper result = SObjectDynamicRecordProvider.getSobjectDatawithRelatedRecords(params);
        
        SObjectDynamicRecordProvider.SobjctDataWrapper filterResult = SObjectDynamicRecordProvider.getSobjectDatawithFilterRelatedRecords(params);
        SObjectDynamicRecordProvider.SobjctDataWrapper filterResultwithOuCa = SObjectDynamicRecordProvider.getFilterRelRecordsWithOutCache(params);
        SObjectDynamicRecordProvider.ParentSobjctDataWrapper parentResult = SObjectDynamicRecordProvider.getSobjectData(params);
        SObjectDynamicRecordProvider.ParentSobjctDataWrapper parentResultNonCachable = SObjectDynamicRecordProvider.getSobjectDataNonCacheable(params);
        SObjectDynamicRecordProvider.ParentSobjctDataWrapper assetPropertyType = SObjectDynamicRecordProvider.getAssetPropType(params);
        List<SObjectDynamicRecordProvider.SobjctDataWrapper> assetPropertyType1 = SObjectDynamicRecordProvider.getAllSobjectDatawithRelatedRecords(params);
        List<SObjectDynamicRecordProvider.SobjctDataWrapper> result1 = SObjectDynamicRecordProvider.getSobjDtwithFltrRelatedRecordsWithoutCache(params);
        List<SObjectDynamicRecordProvider.SobjctDataWrapper> assetPropertyType2 = SObjectDynamicRecordProvider.getSobjectDataWithoutCacheable(params);
        List<SObject> Obj= SObjectDynamicRecordProvider.upsertMultipleRecord(new List<SObject>{appRecords});
        SObjectDynamicRecordProvider.SobjectUpsertData data =new SObjectDynamicRecordProvider.SobjectUpsertData();
        data.parentRecord = (Applicant__c)appRecords;
        data.ParentFieldNameToUpdate = 'ApplType__c';
        data.ChildRecords = new List<SObject>{appRecords};
        SObjectDynamicRecordProvider.upsertMultipleParentsWithMultipleChilds(new List<SObjectDynamicRecordProvider.SobjectUpsertData>{data});
        SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds(data);
        ApplRegltry__c appRegulatory = [SELECT id FROM ApplRegltry__c WHERE Appl__c=: appRecords.id LIMIT 1];
        RegltryPrsonl__c regulaPersnl = [SELECT id FROM RegltryPrsonl__c WHERE Applicant_Regulatory__c=: appRegulatory.id LIMIT 1];     
        
        SObjectDynamicRecordProvider.SobjectUpsertData upsertData = new SObjectDynamicRecordProvider.SobjectUpsertData();
        String parentObjectName = 'ApplRegltry__c';
        sObject parentRecorddu = Schema.getGlobalDescribe().get(parentObjectName).newSObject();
        parentRecorddu.put('Desgntn__c', 'Associate');
        parentRecorddu.put('Id',appRegulatory.Id);
        upsertData.parentRecord = parentRecorddu;
        // Create Child SObject records dynamically
        String childObjectName = 'RegltryPrsonl__c';
        List<sObject> childRecordsss = new List<sObject>();
        
        sObject childRecord1 = Schema.getGlobalDescribe().get(childObjectName).newSObject();
        childRecord1.put('Desgntn__c','Senior Associate');
        childRecordsss.add(childRecord1);
        upsertData.ChildRecords = childRecordsss;
        upsertData.ParentFieldNameToUpdate = 'Applicant_Regulatory__c';
        system.debug('Data format >>>>>>'+ upsertData);
        SObjectDynamicRecordProvider.upsertSobjDataWIthRelatedChilds(upsertData);
        
        ApplRegltry__c appRegulatoryFina = [SELECT id,Desgntn__c FROM ApplRegltry__c WHERE Appl__c=: appRecords.id LIMIT 1];
        system.assertEquals('Associate', appRegulatoryFina.Desgntn__c);
    }
    static testmethod void sObjectDynamicRecDeleteTestMethod(){
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        List<SObject> recordsToDelete = new List<SObject>{ acc};
        SObjectDynamicRecordProvider.deleteRecord(recordsToDelete);

    }
}