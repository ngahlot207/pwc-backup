public class TDF_DummyClass {
    // for Data Search Class 
	/** 
* ********************************************************
* This method is test data for create Scheme Group
* ********************************************************
*/    
    public static SchmGrp__c createSchemeGroup(Boolean doInsert){ 
        SchmGrp__c schGrp = new SchmGrp__c();
        schGrp.Product__c = 'Small Ticket LAP';
        schGrp.SCHDESC__c = 'Test Loan';
        schGrp.SCHID__c = '111';
        if(doInsert){
            TriggerBase.bypass('SchmGrp__c');
        	insert schGrp;
        }
        return schGrp;
    }
    
    /** 
* ********************************************************
* This method is test data for create Scheme Mapping
* ********************************************************
*/    
    public static SchMapping__c createSchemeMapping(Boolean doInsert){ 
        SchMapping__c schMapp = new SchMapping__c();
        schMapp.MaxAmtFin__c = 5000000;
        schMapp.MinAmtFin__c = 500000;
        schMapp.MaxTenure__c = 240;
        schMapp.MinTenure__c = 24;
        schMapp.SchemeDesc__c  = 'BT';
        schMapp.SchGroup__c = TDF_DummyClass.createSchemeGroup(true).Id;
        if(doInsert){
            TriggerBase.bypass('SchMapping__c');
        	insert schMapp;
        }
        return schMapp;
    } 
    
    /** 
* ********************************************************
* This method is test data for create Account
* ********************************************************
*/    
    public static Account createAccountDetails(Boolean doInsert){ 
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.DSAConnId__c = '11';
        acc.VCReferralCode__c = 'ABC123';
        if(doInsert){
            TriggerBase.bypass('Account');
        	insert acc; 
        }
        return acc;
    } 
    
    /** 
* ********************************************************
* This method is test data for create Relationship
* ********************************************************
*/    
    public static Relationship__c createRelationShipDetails(Boolean doInsert){ 
        LoanAppl__c loanAppl = TestDataFactory.createLoanApplication(true);
        Applicant__c appl = TestDataFactory.createSingleApplicant(true,loanAppl.Id);
        appl.Constitution__c = 'HUF';
        upsert appl;
        Relationship__c rel = new Relationship__c();
        rel.Name = 'Test';
        rel.ApplType__c = 'INDIVIDUAL';
        rel.CoApplType__c = 'INDIVIDUAL';
        rel.Key__c = 'TES';
        if(doInsert){
            TriggerBase.bypass('Relationship__c');
        	insert rel; 
        }
        return rel;
    } 
    
    /** 
* ********************************************************
* This method is test data for create Address 
* ********************************************************
*/    
    public static ApplAddr__c createAddressData(Boolean doInsert,String applId){ 
        //LoanAppl__c loanAppl = TestDataFactory.createLoanApplication(true);
        //Applicant__c appl = TestDataFactory.createSingleApplicant(true,loanAppl.Id);
        ApplAddr__c appAdd = new ApplAddr__c();
        appAdd.MailAddr__c = true;
        appAdd.Applicant__c = applId;
        if(doInsert){
            TriggerBase.bypass('ApplAddr__c');
        	insert appAdd; 
        }
        return appAdd;         
    }
    
    /** 
* ***************************************************************
* This method is test data for Applicant PrinlPlaceforBCheckBox
* ***************************************************************
*/    
    public static Applicant__c PrinlPlaceforBCheckBox(Boolean doInsert,string applicationId, boolean ischeckedvalue ){ 
        Applicant__c app = new Applicant__c();
        app.LoanAppln__c = applicationId;
        app.Same_as_Principal_place_for_business__c = ischeckedvalue;
        if(doInsert){
            TriggerBase.bypass('Applicant__c');
        	upsert app; 
        }
        return app;          
    }
    
    //for CreateLOanHandler class
    /** 
* ***************************************************************
* This method is test data for SharingHierarchy__mdt
* ***************************************************************
*/  
    public static List<SharingHierarchy__mdt> SharingHierarchyData(){
        List<SharingHierarchy__mdt> shrngConfigList = [select Id, DeveloperName, MasterLabel, Label,
                                                           QualifiedApiName, SupervisoreRoleSharing__c, BrchRoleSharing__c,SharingReason__c
                                                           from SharingHierarchy__mdt];
        return shrngConfigList;
    }
}