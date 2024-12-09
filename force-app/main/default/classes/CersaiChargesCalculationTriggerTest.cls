@isTest
public class CersaiChargesCalculationTriggerTest {
 @testsetup
    Public static void insertData(){
        user u = TestDataFactory.UserData(true);
        system.runAs(u){
            
            LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
            Applicant__c appli =  TestDataFactory.createSingleApplicant(true,loanApp.id); 
            ApplAsset__c asset = TestDataFactory.createApplAsset(true,appli.Id,loanApp.Id);
         	MasterData__c mst = TestDataFactory.mstrData(true);
            LonaApplCharges__c charge=TestDataFactory.chargeData(true, loanApp.Id, mst.Id);
            list<ApplAsset__c> newList = new list <ApplAsset__c>{asset};
            
        }
    }
    @isTest
    static void testAfterInsert(){
        LoanAppl__c loan =[select id from LoanAppl__c Limit 1];
        Applicant__c app=[select id from Applicant__c Limit 1];
       
        list<ApplAsset__c> newList =[select id,LoanAppln__c,Appl__c from ApplAsset__c where LoanAppln__c =: loan.Id AND Appl__c =: app.Id];
         CersaiChargesCalculationTrigger.afterInsert(newList);
         LonaApplCharges__c chg =[select id,Amount__c from LonaApplCharges__c limit 1];
        system.assertEquals(118,chg.Amount__c);
        
        
    }
     @isTest
    static void testAfterUpdate(){
        LoanAppl__c loan =[select id from LoanAppl__c Limit 1];
        Applicant__c app=[select id from Applicant__c Limit 1];
        list<ApplAsset__c> oldList =[select id,LoanAppln__c,Appl__c from ApplAsset__c where LoanAppln__c =: loan.Id AND Appl__c =: app.Id];
         CersaiChargesCalculationTrigger.afterDelete(oldList);
        LonaApplCharges__c chg =[select id,Amount__c from LonaApplCharges__c limit 1];
         
        
    }
}