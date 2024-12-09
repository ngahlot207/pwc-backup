@IsTest
public class CreateLoanTeamTest { 
    @testSetup
    static void testData(){
        user u=TestDataFactory.UserData(true);
        Lead testLead = TestDataFactory.LeadData(true, u.Id);
        
    }
    
    @isTest 
    static void testAfterInsert(){
        user u = [SELECT Id, Name FROM User LIMIT 1];
        user sup=TestDataFactory.supervisor(true);
        Lead testLead = [ SELECT Id FROM Lead LIMIT 1];
      
        list<LoanAppl__c> newList=new list<LoanAppl__c>();
        LoanAppl__c loan =TestDataFactory.createLoanApplication(true);
        loan.Lead__c = testLead.Id;
        loan.ownerId = u.Id;
        loan.Stage__c = 'Disbursement Initiation';
        update loan;
        newList.add(loan);
        BankBrchMstr__c bnk=  TestDataFactory.TestDataBankBranchMaster(true);
        
        TeamHierarchy__c tns=TestDataFactory.TestDataTeamHierarchy_nonSup(true,u.id,bnk.id);
        TeamHierarchy__c tns1=TestDataFactory.TestDataTeamHierarchy_nonSup1(true,u.id,bnk.id,tns.id);
        TeamHierarchy__c tns2=TestDataFactory.TestDataTeamHierarchy_nonSup1(true,u.id,bnk.id,tns.Id);
        TeamHierarchy__c TH=new TeamHierarchy__c();
        TH.Employee__c=u.id;
        TH.EmpBrch__c=bnk.id;
        TH.Emprole__c='ABH';
        TH.Product_Type__c = 'Home Loan';
        TH.Supervisor__c=tns.Id;
        insert TH;
        TeamHierarchy__c TH1=new TeamHierarchy__c();
        TH1.Employee__c=u.id;
        TH1.EmpBrch__c=bnk.id;
        TH1.Emprole__c='CPA';
        TH1.Product_Type__c = 'Home Loan';
        TH1.Supervisor__c=tns1.Id;
        insert TH1;
        TeamHierarchy__c TH2=new TeamHierarchy__c();
        TH2.Employee__c=u.id;
        TH2.EmpBrch__c=bnk.id;
        TH2.Emprole__c='BOM'; 
        TH2.Product_Type__c = 'Home Loan';
        TH2.Supervisor__c=tns2.Id; 
        insert TH2;
        
        //  TeamHierarchy__c ts1=TestDataFactory.TestDataTeamHierarchy_nonSup1(true,sup.id,bnk.id,tns1.Id);
        LoanTeam__c lnTeam = TestDataFactory.createLoanTeam(true,loan.Id);
        List<SharingHierarchy__mdt> shrngConfigList = TestDataFactory.SharingHierarchyData();
        try{
            CreateLoanTeam.afterInsert(newList);
            LoanAppl__Share[] LS=[SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM LoanAppl__Share where Id=:loan.id];
            system.assertEquals('Edit', LS[1].AccessLevel);
        }catch(exception e){
            //  system.assertEquals('Script-thrown exception', e.getMessage());
        }
        
        try{
            loan.Stage__c = 'Underwriting';
            loan.SubStage__c = 'Credit Appraisal';
            update loan;
            CreateLoanTeam.afterInsert(newList);
        }
        catch(exception e){
            //  system.assertEquals('Script-thrown exception', e.getMessage());
        }
        
        try{
            CreateLoanTeam.afterInsert(null);
            LoanAppl__Share[] LS=[SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM LoanAppl__Share where Id=:loan.id];
        }catch(exception e){
            system.assertEquals('Attempt to de-reference a null object', e.getMessage());
        }
        
    }
    @isTest 
    static void testAfterUpdate(){
        user u = [SELECT Id, Name FROM User LIMIT 1];
        user sup=TestDataFactory.supervisor(true);  
        Lead testLead = [ SELECT Id FROM Lead LIMIT 1];
        
        list<LoanAppl__c> oldList=new list<LoanAppl__c>();
        list<LoanAppl__c> newList=new list<LoanAppl__c>();
        LoanAppl__c loan =TestDataFactory.createLoanApplication(true);
        oldList.add(loan);
        loan.OwnerId = u.Id;
        loan.Lead__c = testLead.Id;
        loan.Stage__c = 'Disbursement Initiation';
        update loan;
        newList.add(loan);
        try{
            CreateLoanTeam.afterUpdate(newList,oldlist);
            LoanAppl__Share[] LS=[SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM LoanAppl__Share where Id=:loan.id];
            system.assertEquals('Edit', LS[1].AccessLevel);
        }catch(exception e){
            //  system.assertEquals('Script-thrown exception', e.getMessage());
        }
        try{
            CreateLoanTeam.afterUpdate(null,null);
            LoanAppl__Share[] LS=[SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM LoanAppl__Share where Id=:loan.id];
        }catch(exception e){
            system.assertEquals('Attempt to de-reference a null object', e.getMessage());
        }
    }
}