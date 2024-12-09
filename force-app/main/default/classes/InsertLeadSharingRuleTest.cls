@isTest
public class InsertLeadSharingRuleTest {

     @isTest
    Public Static Void createSharingRulesTest()
    {
       user u=TestDataFactory.UserData(true);
    
        user sup=TestDataFactory.supervisor(true);
       lead l=TestDataFactory.LeadData(true,u.id);
         lead l1=TestDataFactory.LeadData(true,sup.id);
        list<lead> leadlist=new list<lead>();
      BankBrchMstr__c bnk=  TestDataFactory.TestDataBankBranchMaster(true);
        
       TeamHierarchy__c TH = new TeamHierarchy__c();
        TH.EmpRole__c = 'CPA';
        insert TH;
    //  LeadShare LS=TestDataFactory.LeadShareData(true,l.id);
        //TeamHierarchy__c tns=TestDataFactory.TestDataTeamHierarchy_nonSup(true,l.ownerId,bnk.id);
       // TeamHierarchy__c tns1=TestDataFactory.TestDataTeamHierarchy_nonSup1(true,l1.ownerId,bnk.id);
       // TeamHierarchy__c ts=TestDataFactory.TestDataTeamHierarchy(true,l.ownerId,bnk.id,tns.id);
       // TeamHierarchy__c ts1=TestDataFactory.TestDataTeamHierarchy(true,l1.ownerId,bnk.id,tns1.id);
       TeamHierarchy__c tns=TestDataFactory.TestDataTeamHierarchy_nonSup(true,u.id,bnk.id);
        TeamHierarchy__c tns1=TestDataFactory.TestDataTeamHierarchy_nonSup1(true,sup.id,bnk.id,TH.id);
        TeamHierarchy__c ts=TestDataFactory.TestDataTeamHierarchy(true,u.id,bnk.id,tns.id);
        TeamHierarchy__c ts1=TestDataFactory.TestDataTeamHierarchy(true,sup.id,bnk.id,tns1.id);
        leadlist.add(l);
        
            try{
               InsertLeadSharingRule.afterInsert(leadList);
                LeadShare[] LS=[select id,LeadId,LeadAccessLevel from LeadShare where LeadId=:l.id];
                system.assertEquals('Edit', LS[1].LeadAccessLevel);
            }catch(exception e){
              //  system.assertEquals('Script-thrown exception', e.getMessage());
            }
            
            
        }
    
    }
//}