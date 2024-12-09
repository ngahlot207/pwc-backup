@isTest
public class LeadAssignmentHandlerTest {
    @testSetup
    static void testData(){
          Profile testProfile = [SELECT Id FROM profile WHERE Name = 'LOS Base User' LIMIT 1];
        User testUser = new User(LastName = 'test user 1', 
                                 Username = 'test.createLoanTeam@example.com', 
                                 Email = 'test.1@example.com', 
                                 Alias = 'testu1', 
                                 TimeZoneSidKey = 'GMT', 
                                 LocaleSidKey = 'en_GB', 
                                 EmailEncodingKey = 'ISO-8859-1', 
                                 ProfileId = testProfile.Id, 
                                 LanguageLocaleKey = 'en_US'); 
        
        insert testUser;
        //user u=TestDataFactory.UserData(true);
        Lead testLead = TestDataFactory.LeadData(true,testUser.Id);
        
    }
    @isTest
    public static void testAfterInsert(){
        user u = [SELECT Id, Name FROM User LIMIT 1];
        BankBrchMstr__c bnk=  TestDataFactory.TestDataBankBranchMaster(true);
        LocMstr__c locMst=  TestDataFactory.LocMaster(true);
        TeamHierarchy__c tns=TestDataFactory.TestDataTeamHierarchyBBH(true,u.id,bnk.id,locMst.Id);
        
        list<Lead> lstLead =new list<Lead>();
        lead l = new lead();
        l.leadSource = 'Digital';
        l.City= 'Hyderabad';
        l.Status= 'New';
        l.LastName='Test1';
        lstLead.add(l);
        lead l1 = new lead();
        l1.leadSource = 'Digital';
        l1.City= 'Hyderabad';
        l1.Status= 'New';
        l1.LastName='Test2';
        lstLead.add(l1);
        lead l2 = new lead();
        l2.leadSource = 'Digital';
        l2.City= 'Hyderabad';
        l2.Status= 'New';
        l2.LastName='Test2';
        lstLead.add(l2);
        lead l3 = new lead();
        l3.leadSource = 'Digital';
        l3.City= 'PUNE';
        l3.Status= 'New';
        l3.LastName='Test2';
        lstLead.add(l3);
        //insert lstLead;
        LeadAssignmentHandler.afterInsert(lstLead);
    }
}