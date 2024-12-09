@isTest
public class SharingRuleDefnTest {
    
    @isTest
    Public Static Void testCreateSharingRules(){
          Profile testProfile = [SELECT Id FROM profile WHERE Name = 'LOS Base User' LIMIT 1];
        User testUser = new User(LastName = 'test user 1', 
                                 Username = 'test.createSharingRule@example.com', 
                                 Email = 'test.12345@example.com', 
                                 Alias = 'testu1', 
                                 TimeZoneSidKey = 'GMT', 
                                 LocaleSidKey = 'en_GB', 
                                 EmailEncodingKey = 'ISO-8859-1', 
                                 ProfileId = testProfile.Id, 
                                 LanguageLocaleKey = 'en_US'); 
        
        insert testUser;
  
        user sup=TestDataFactory.supervisor(true);
       
        list<LoanAppl__c> newList=new list<LoanAppl__c>();
        
        LoanAppl__c loan =TestDataFactory.createLoanApplication(true);
        newList.add(loan);
        BankBrchMstr__c bnk=  TestDataFactory.TestDataBankBranchMaster(true);
        
        TeamHierarchy__c tns=TestDataFactory.TestDataTeamHierarchy_nonSup(true,testUser.id,bnk.id);
        // TeamHierarchy__c tns1=TestDataFactory.TestDataTeamHierarchy_nonSup1(true,sup.id,bnk.id);
        //TeamHierarchy__c ts=TestDataFactory.TestDataTeamHierarchy_nonSup1(true,u.id,bnk.id,tns.Id); 
        TeamHierarchy__c TH=new TeamHierarchy__c();
        TH.Employee__c=testUser.id;
        TH.EmpBrch__c=bnk.id;
        TH.Emprole__c='SM';
        TH.Product_Type__c = 'Home Loan';
        TH.Supervisor__c=tns.Id;
        insert TH;
        //  TeamHierarchy__c ts1=TestDataFactory.TestDataTeamHierarchy_nonSup1(true,sup.id,bnk.id,tns1.Id);
        LoanTeam__c lnTeam =  new LoanTeam__c();
        lnTeam.UserId__c = loan.OwnerId;
        lnTeam.LoanApplication__c = loan.Id;
        lnTeam.ObjAPIName__c = 'LoanAppl__c';
        lnTeam.ObjAccess__c = 'Read';
        lnTeam.ShareReason__c = 'Sales__c';
        lnTeam.LoanApplication__c = loan.Id;      
        List<LoanTeam__c> lstTeams = new list<LoanTeam__c>();
        
        lstTeams.add(lnTeam);
        TriggerBase.bypass('LoanTeam__c');
        insert lstTeams;
        TriggerBase.clearBypass('LoanTeam__c');           
                
        system.debug('lstTeams:::::'+lstTeams);
        try{
            SharingRuleDefn.afterInsert(lstTeams);
        }catch(exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
         try{
            SharingRuleDefn.afterInsert(null);
        }catch(exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
        
        
        
    }
    @isTest
    Public Static Void testAssignSharing(){
        
        list<LoanAppl__c> newList=new list<LoanAppl__c>();
        
        LoanAppl__c loan =TestDataFactory.createLoanApplication(true);
        newList.add(loan);
        
        LoanAppeal__c ln = new LoanAppeal__c();
        ln.LoanAppl__c = loan.Id;
        insert ln;
        
        LoanTeam__c lnTeam =  new LoanTeam__c();
        lnTeam.UserId__c = loan.OwnerId;
        lnTeam.LoanApplication__c = loan.Id;
        lnTeam.ObjAPIName__c = 'LoanAppl__c';
        lnTeam.ObjAccess__c = 'Read';
        lnTeam.ShareReason__c = 'Sales__c';
        lnTeam.LoanApplication__c = loan.Id;      
        
        
        LoanTeam__c lnTeam1 =  new LoanTeam__c();
        lnTeam1.UserId__c = ln.OwnerId;
        lnTeam1.ObjAPIName__c = 'LoanAppeal__c';
        lnTeam1.ObjAccess__c = 'Read';
        lnTeam1.ShareReason__c = 'Sales__c';
        lnTeam1.LoanAppeal__c = ln.Id;      
        List<LoanTeam__c> lstTeams = new list<LoanTeam__c>();
        
        lstTeams.add(lnTeam);
        lstTeams.add(lnTeam1);
        TriggerBase.bypass('LoanTeam__c');
        insert lstTeams;
        TriggerBase.clearBypass('LoanTeam__c');    
        
        list<SharingRuleDefn.WrpSharing> wrpList = new list <SharingRuleDefn.WrpSharing>();
        SharingRuleDefn.WrpSharing wrp = new SharingRuleDefn.WrpSharing();
        wrp.accessLevel = lnTeam.ObjAccess__c;
        wrp.objectId = loan.Id;
        wrp.sharingObjectName = lnTeam.ObjAPIName__c;
        wrp.userOrGroupId = lnTeam.User__c;
        wrp.sharingReason= lnTeam.ShareReason__c;
        wrpList.add(wrp);
        
        SharingRuleDefn.afterInsert(lstTeams);
        try{
           //SharingRuleDefn.afterInsert(null);
        }catch(exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
        
    }
     @isTest
    Public Static Void testAssignSharing1(){
        
        list<LoanAppl__c> newList=new list<LoanAppl__c>();
        
        LoanAppl__c loan =TestDataFactory.createLoanApplication(true);
        newList.add(loan);
        
        Case c = new Case();
         c.Loan_Application__c = loan.Id;
        insert c;    
        LoanTeam__c lnTeam1 =  new LoanTeam__c();
        lnTeam1.UserId__c = c.OwnerId;
        lnTeam1.ObjAPIName__c = 'Case';
        lnTeam1.ObjAccess__c = 'Read';
        lnTeam1.ShareReason__c = 'Sales__c';
        lnTeam1.Case__c = c.Id;      
        List<LoanTeam__c> lstTeams = new list<LoanTeam__c>();
        lstTeams.add(lnTeam1);
        TriggerBase.bypass('LoanTeam__c');
        insert lstTeams;
        TriggerBase.clearBypass('LoanTeam__c');    
        
        list<SharingRuleDefn.WrpSharing> wrpList = new list <SharingRuleDefn.WrpSharing>();
        SharingRuleDefn.WrpSharing wrp = new SharingRuleDefn.WrpSharing();
        wrp.accessLevel = lnTeam1.ObjAccess__c;
        wrp.objectId = c.Id;
        wrp.sharingObjectName = lnTeam1.ObjAPIName__c;
        wrp.userOrGroupId = lnTeam1.User__c;
        wrp.sharingReason= lnTeam1.ShareReason__c;
        wrpList.add(wrp);
        
     
        try{
          // SharingRuleDefn.assignSharing(lstTeams);
        }catch(exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
        
    }
}