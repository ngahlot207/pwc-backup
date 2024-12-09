@isTest
public class ApplicantAfterDeleteTest {
    @testsetup
    Public static void insertTestData(){
      LoanAppl__c loanApp =  TestDataFactory.createLoanApplication(True);
      Applicant__c appli =  TestDataFactory.createSingleApplicant(True,loanApp.Id);
      SFDCBANKMaster__c sfdcBnkMstr = TestDataFactory.sfdcBankMasterDetails(True);
      ApplBanking__c applBank = TestDataFactory.applBankingDetails(True,appli.Id,loanApp.Id,sfdcBnkMstr.Id);
        
    }
@isTest
    Public static void testmethod1(){
        List<Applicant__c> lstApplicant = [SELECT ID FROM Applicant__c];
        system.assert(!lstApplicant.isempty(), 'Applicant list should not empty');
        ApplicantAfterDelete.beforeDelete(lstApplicant);
    }
}