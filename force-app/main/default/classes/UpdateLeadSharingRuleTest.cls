@isTest
public class UpdateLeadSharingRuleTest {

     @isTest
    Public Static Void createSharingRulesTest()
    { 
        Profile p = [SELECT Id FROM Profile WHERE Name != 'System Administrator' LIMIT 1];
        User u1 = new user();
        u1.LastName = 'Test Code';
        u1.Email = 'test@test.com';
        u1.Alias = 'Tcode';
        u1.Username = 'test123tringtring@test12121.com';
        u1.TimeZoneSidKey = 'GMT';
        u1.LocaleSidKey = 'en_US';

        u1.ProfileID = p.Id;
        u1.LanguageLocaleKey = 'en_US';
        u1.EmailEncodingKey = 'UTF-8';
        TriggerBase.bypass('User');
            insert u1;
            TriggerBase.clearBypass('User');
       user u=TestDataFactory.UserData(true);
     //  system.runAs(u){
      
        user sup=TestDataFactory.supervisor(true);
       lead l=TestDataFactory.LeadData(true,u.id);
        
         lead l1=TestDataFactory.LeadData(true,sup.id);
        lead l2=TestDataFactory.LeadDataupdate(true,l.id,sup.id);
        list<lead> leadlist=new list<lead>();
        list<lead> leadlistupdated=new list<lead>();
      BankBrchMstr__c bnk=  TestDataFactory.TestDataBankBranchMaster(true);
    //  LeadShare LS=TestDataFactory.LeadShareData(true,l.id);
        TeamHierarchy__c tns=TestDataFactory.TestDataTeamHierarchy_nonSup(true,l.ownerId,bnk.id);
        TeamHierarchy__c tns1=TestDataFactory.TestDataTeamHierarchy_nonSup1(true,l1.ownerId,bnk.id,tns.id);
        TeamHierarchy__c ts=TestDataFactory.TestDataTeamHierarchy(true,l.ownerId,bnk.id,tns.id);
        TeamHierarchy__c ts1=TestDataFactory.TestDataTeamHierarchy(true,l1.ownerId,bnk.id,tns1.id);
       //BankBrchMstr__c b:TestDataFactory.TestDataBankBranchMaster(true,'MUMBAI');
        leadlist.add(l);
        leadlistupdated.add(l2);
        
        
            try{
                System.runAs(u1) {
               UpdateLeadSharingRule.updateSharingRules(leadlistupdated,leadlist);
                UpdateLeadSharingRule.afterUpdate(leadlistupdated,leadlist);
                }
                for(LeadShare LS :[select id,LeadId,LeadAccessLevel from LeadShare where LeadId=:InsertLeadSharingRule.successRecord])
               // LeadShare[] LS=[select id,LeadId,LeadAccessLevel from LeadShare where LeadId=:InsertLeadSharingRule.successRecord];
                {
                    
                system.assertEquals('Edit', LS.LeadAccessLevel);
                }
            }catch(exception e){
               // system.assertEquals('Script-thrown exception', e.getMessage());
            }
            
            
        }
    
    }
//}