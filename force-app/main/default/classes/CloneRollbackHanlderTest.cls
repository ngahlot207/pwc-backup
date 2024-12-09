@istest
public class CloneRollbackHanlderTest {
    
    @isTest
    static void cloneRollbackHanlderTestMethod() {
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        Applicant__c app = TestDataFactory.createSingleApplicant(true,loanApp.id);
        
        Id conBureRecordTypeId = Schema.SObjectType.Bureau__c.getRecordTypeInfosByName()
            .get('Consumer Bureau').getRecordTypeId();
        Id commBureRecordTypeId = Schema.SObjectType.Bureau__c.getRecordTypeInfosByName()
            .get('Commercial Bureau').getRecordTypeId();
        List<Bureau__c> bureauResRecrds = new List<Bureau__c>();
        bureauResRecrds.add(new Bureau__c(
            Applicant__c = app.Id,
            Message__c = 'Test',
            RecordTypeId = conBureRecordTypeId
        ));
        bureauResRecrds.add(new Bureau__c(
            Applicant__c = app.Id,
            Message__c = 'Test2',
            RecordTypeId = commBureRecordTypeId
        ));
        TriggerBase.bypass('Bureau__c');
        insert bureauResRecrds;
        TriggerBase.clearBypass('Bureau__c');
        
        List<Case> caseList = new List<Case>();
        Id cvRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
            .get('Collateral Visit').getRecordTypeId();
        Id technicalRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
            .get('Technical').getRecordTypeId();
        Id cpvfiRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
            .get('CPVFI').getRecordTypeId();
        Id legalRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
            .get('Legal').getRecordTypeId();
        caseList.add(new Case(
            CVStatus__c = 'In Progress',
            Status = 'Closed',
            IsReinitiated__c = false,
            Loan_Application__c = loanApp.Id,
            Applicant__c = app.Id,
            RecordTypeId = cvRecordTypeId
        ));
        caseList.add(new Case(
            CVStatus__c = 'In Progress',
            Status = 'Closed',
            IsReinitiated__c = false,
            IsCompleted__c = true,
            Property_Visit_Final_Status__c = 'Negative',
            Loan_Application__c = loanApp.Id,
            Applicant__c = app.Id,
            RecordTypeId = technicalRecordTypeId
        ));
        caseList.add(new Case(
            CVStatus__c = 'In Progress',
            Status = 'Closed',
            IsReinitiated__c = false,
            Loan_Application__c = loanApp.Id,
            Applicant__c = app.Id,
            RecordTypeId = legalRecordTypeId
        ));
        caseList.add(new Case(
            CVStatus__c = 'In Progress',
            Status = 'Closed',
            WaiveCPV__c = 'Yes',
            Loan_Application__c = loanApp.Id,
            Applicant__c = app.Id,
            RecordTypeId = cpvfiRecordTypeId
        ));
        TriggerBase.bypass('Case');
        insert caseList;
        TriggerBase.clearBypass('Case');
        
        List<DocDtl__c> docDtlList = new List<DocDtl__c>();
        docDtlList.add(new DocDtl__c(
            DocCatgry__c = 'KYC Documents',
            DocTyp__c = 'Residence Address proof - OVD',
            Appl__c = app.id,
            LAN__c = loanApp.Id,
            Case__c = caseList[0].Id,
            DocSubTyp__c = 'Voter Id'
        ));
        docDtlList.add(new DocDtl__c(
            DocCatgry__c = 'Application Form',
            DocTyp__c = 'Application Form',
            Appl__c = app.id,
            Case__c = caseList[0].Id,
            LAN__c = loanApp.Id,
            DocSubTyp__c = 'Application Form'
        ));
        TriggerBase.bypass('DocDtl__c');
        insert docDtlList;
        TriggerBase.clearBypass('DocDtl__c');
        
        List<BureauRespDtl__c> bureauResDtlRecrds = new List<BureauRespDtl__c>();
        
        bureauResDtlRecrds.add(new BureauRespDtl__c(
            Applicant__c = app.Id,
            Message__c = 'Test'
        ));
        TriggerBase.bypass('BureauRespDtl__c');
        insert bureauResDtlRecrds;
        TriggerBase.clearBypass('BureauRespDtl__c');
        
        List<CM_BureauRelationShipDetail__c> bureauRelDetl = new List<CM_BureauRelationShipDetail__c>(); 
        bureauRelDetl.add(new CM_BureauRelationShipDetail__c(
            BureauResponse__c = bureauResRecrds[0].Id,
            BusCat__c = 'Test'
        ));
        TriggerBase.bypass('CM_BureauRelationShipDetail__c');
        insert bureauRelDetl;
        TriggerBase.clearBypass('CM_BureauRelationShipDetail__c');
        
        List<CM_Bureau_Child_Relation_Ship__c> bureauChildRelDetl = new List<CM_Bureau_Child_Relation_Ship__c>(); 
        bureauChildRelDetl.add(new CM_Bureau_Child_Relation_Ship__c(
            BureauRelationShip_Detail__c = bureauRelDetl[0].Id,
            Pan__c = 'ENUYT8786H'
        ));
        TriggerBase.bypass('CM_Bureau_Child_Relation_Ship__c');
        insert bureauChildRelDetl;
        TriggerBase.clearBypass('CM_Bureau_Child_Relation_Ship__c');
        
        List<CM_Person_Entity_Detail__c> persEntyDtl = new List<CM_Person_Entity_Detail__c>(); 
        persEntyDtl.add(new CM_Person_Entity_Detail__c(
            BureauResponse__c = bureauResRecrds[0].Id,
            Address__c = 'Test'
        ));
        TriggerBase.bypass('CM_Person_Entity_Detail__c');
        insert persEntyDtl;
        TriggerBase.clearBypass('CM_Person_Entity_Detail__c');
        
        List<CM_Person_Entity_Class_Activity__c> persEntClsAct = new List<CM_Person_Entity_Class_Activity__c	>();
        
        persEntClsAct.add(new CM_Person_Entity_Class_Activity__c(
            PersonEntity_Detail__c = persEntyDtl[0].Id,
            ClsActivityResponse__c = 'Test'
        ));
        TriggerBase.bypass('CM_Person_Entity_Class_Activity__c');
        insert persEntClsAct;
        TriggerBase.clearBypass('CM_Person_Entity_Class_Activity__c');
        
        List<CM_Person_Entity_ID_Detail__c> persEntIdDtls = new List<CM_Person_Entity_ID_Detail__c	>();
        
        persEntIdDtls.add(new CM_Person_Entity_ID_Detail__c(
            PersonEntity_Detail__c = persEntyDtl[0].Id,
            CIN__c = 'FGHJ8677BN'
        ));
        TriggerBase.bypass('CM_Person_Entity_ID_Detail__c');
        insert persEntIdDtls;
        TriggerBase.clearBypass('CM_Person_Entity_ID_Detail__c');
        
        List<CM_Borrower_Delinquency__c> borrDelqncy = new List<CM_Borrower_Delinquency__c	>();
        
        borrDelqncy.add(new CM_Borrower_Delinquency__c(
            PersonEntityDetail__c = persEntyDtl[0].Id,
            Relationship__c = 'Cousin'
        ));
        TriggerBase.bypass('CM_Borrower_Delinquency__c');
        insert borrDelqncy;
        TriggerBase.clearBypass('CM_Borrower_Delinquency__c');
        
        
        List<CM_LocationDetail__c> locaDtl = new List<CM_LocationDetail__c>(); 
        locaDtl.add(new CM_LocationDetail__c(
            BureauResponse__c = bureauResRecrds[0].Id,
            Message__c = 'test'
        ));
        TriggerBase.bypass('CM_LocationDetail__c');
        insert locaDtl;
        TriggerBase.clearBypass('CM_LocationDetail__c');
        
        List<CM_LocationInfo__c> locaInfo = new List<CM_LocationInfo__c>(); 
        locaInfo.add(new CM_LocationInfo__c(
            LocationDetail__c = locaDtl[0].Id,
            Address__c = 'test'
        ));
        TriggerBase.bypass('CM_LocationInfo__c');
        insert locaInfo;
        TriggerBase.clearBypass('CM_LocationInfo__c');
        
        CloneRollbackHanlder.rollbackClonedloanApp(loanApp.Id);
    }
}