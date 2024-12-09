@isTest
public class TestDataFactoryTest {

    @isTest
    static void testTeamHierarchyDataInsertAndUpdate() {
        // Create a test User
        User testUser = TestDataFactory.UserData(true); 
        
        // Create a test Lead
        Lead testLead = TestDataFactory.LeadData(true, testUser.Id);
        
        // Update the Lead data using TestDataFactory
        testLead.LastName = 'Test';
        TestDataFactory.LeadDataupdate(true, testLead.Id, testUser.Id); // Insert should be false for update
        
        // Fetch the updated Lead data
        Lead updatedLead = [SELECT Id, LastName FROM Lead WHERE Id = :testLead.Id];
        
        
        // Create a Lead Share Data
        LeadShare testLeadShare = TestDataFactory.LeadShareData(true, testLead.Id);
        
        
        // Create a Supervisor User
        User supervisorUser = TestDataFactory.supervisor(true);
        
        // Create a Sanction Condition Master
        Sanction_Conditions_Master__c sanctionMaster = TestDataFactory.createsanctionmaster(true);
        
        // Create a test Bank Branch Master
        BankBrchMstr__c testBankBranch = TestDataFactory.TestDataBankBranchMaster(true);
        
        // Create and insert Team Hierarchy data
        TeamHierarchy__c testTeamHierarchy = TestDataFactory.TestDataTeamHierarchy_nonSup(true, testUser.Id, testBankBranch.Id);
        
        // Update the Team Hierarchy data using TestDataFactory
        testTeamHierarchy.Emprole__c = 'RM';
        TestDataFactory.TestDataTeamHierarchy_nonSup(false, testUser.Id, testBankBranch.Id); // Insert should be false for update
        
        // Create and insert Team Hierarchy data
        TeamHierarchy__c testTeamHierarchy1 = TestDataFactory.TestDataTeamHierarchy_nonSup1(true, testUser.Id, testBankBranch.Id, null);
        
        // Update the Team Hierarchy data using TestDataFactory
        testTeamHierarchy1.Emprole__c = 'SM'; 
        TestDataFactory.TestDataTeamHierarchy_nonSup1(false, testUser.Id, testBankBranch.Id, null); // Insert should be false for update
        
        
        // Fetch the updated Team Hierarchy data
        TeamHierarchy__c updatedTeamHierarchy = [SELECT Id, Emprole__c FROM TeamHierarchy__c WHERE Id = :testTeamHierarchy.Id];
        
        // Assert that the Team Hierarchy data was updated correctly
        System.assertEquals('RM', updatedTeamHierarchy.Emprole__c);
    }
}