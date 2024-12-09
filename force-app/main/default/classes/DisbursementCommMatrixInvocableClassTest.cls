@isTest
public class DisbursementCommMatrixInvocableClassTest {
    
    @testsetup
    Public static void insertData(){
        string userId = UserInfo.getUserId();
        EmailTemplate testTemplate = new EmailTemplate();
        testTemplate.DeveloperName = 'test_template';
        testTemplate.Name = 'Test Template';
        testTemplate.Subject = 'Test Subject';
        testTemplate.Body = 'Test Body';
        testTemplate.IsActive = true;
        testTemplate.FolderId = userId;
        testTemplate.TemplateType = 'text';
        insert testTemplate;
      
       }
    
    @isTest
    Public static void testSendEmailCommunication_UserRecipient(){
        List<TeamHierarchy__c> lstTeam = [SELECT ID FROM TeamHierarchy__c];
        EmailTemplate emTem = [SELECT ID,Name,Subject,Body,IsActive,DeveloperName FROM EmailTemplate WHERE Name = 'Test Template' Limit 1];
        User u = TestDataFactory.UserData(true);
        LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
        loan.RMSMName__c = u.Id;
        TriggerBase.bypass('LoanAppl__c');
        Update loan;
        TriggerBase.clearBypass('LoanAppl__c');
        
        BankBrchMstr__c B1 =  TestDataFactory.TestDataBankBranchMaster1(True);
        
        TeamHierarchy__c tem1 = new TeamHierarchy__c();
        tem1.EmpRole__c = 'CPA';
        tem1.Employee__c = u.iD;
        TriggerBase.bypass('TeamHierarchy__c');
        Insert tem1;
        TriggerBase.clearBypass('TeamHierarchy__c');
        
        TeamHierarchy__c tem = new TeamHierarchy__c();
        tem.EmpRole__c = 'CPA';
        tem.Employee__c = u.iD;
        tem.Supervisor__c = tem1.Id;
        TriggerBase.bypass('TeamHierarchy__c');
        Insert tem;
        TriggerBase.clearBypass('TeamHierarchy__c');
        
        TeamHierarchy__c teamHirc1 = TestDataFactory.TestDataTeamHierarchy(True,u.Id,B1.Id,tem.Id);
        
        DisbursementCommMatrixInvocableClass.inputVariables testInput = new DisbursementCommMatrixInvocableClass.inputVariables();
        testInput.emailTeamplateId = emTem.Id;
        testInput.targetId = loan.Id;
        testInput.Stage = 'Post Sanction';
        testInput.Substage = 'Ops Query Pool';
        testInput.cpaUser = u.Id;
        testInput.UwUser = u.Id;
        testInput.opsUser = u.id;
        testInput.rmSMUser = u.Id;
        testInput.branchcode ='MUM';
        Test.startTest();
        DisbursementCommMatrixInvocableClass.communicationDisbEmail(new List<DisbursementCommMatrixInvocableClass.inputVariables>{ testInput });
        Test.stopTest();
      
    }
     @isTest
    Public static void testSendEmailCommunication_UserRecipient1(){
        EmailTemplate emTem = [SELECT ID,Name,Subject,Body,IsActive,DeveloperName FROM EmailTemplate WHERE Name = 'Test Template' Limit 1];
        User u = TestDataFactory.UserData(true);
        LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
        loan.RMSMName__c = u.Id;
        TriggerBase.bypass('LoanAppl__c');
         Update loan;
        TriggerBase.clearBypass('LoanAppl__c');
         BankBrchMstr__c B1 =  TestDataFactory.TestDataBankBranchMaster1(True);
        TeamHierarchy__c tem1 = new TeamHierarchy__c();
        tem1.EmpRole__c = 'CPA';
        tem1.Employee__c = u.iD;
        TriggerBase.bypass('TeamHierarchy__c');
        Insert tem1;
        TriggerBase.clearBypass('TeamHierarchy__c');
        
        TeamHierarchy__c tem = new TeamHierarchy__c();
        tem.EmpRole__c = 'CPA';
        tem.Employee__c = u.iD;
        tem.Supervisor__c = tem1.Id;
        TriggerBase.bypass('TeamHierarchy__c');
        Insert tem;
        TriggerBase.clearBypass('TeamHierarchy__c'); 
        
        TeamHierarchy__c teamHirc1 = TestDataFactory.TestDataTeamHierarchy(True,u.Id,B1.Id,tem.Id);
        
        DisbursementCommMatrixInvocableClass.inputVariables testInput = new DisbursementCommMatrixInvocableClass.inputVariables();
        testInput.emailTeamplateId = emTem.Id;
        testInput.targetId = loan.Id;
        testInput.Stage = 'Disbursement Initiation';
        testInput.Substage = 'DI Pool';
        testInput.cpaUser = u.Id;
        testInput.UwUser = u.Id;
        testInput.opsUser = u.id;
        testInput.rmSMUser = u.Id;
        testInput.branchcode ='MUM';
        Test.startTest();
       DisbursementCommMatrixInvocableClass.communicationDisbEmail(new List<DisbursementCommMatrixInvocableClass.inputVariables>{ testInput });
        Test.stopTest();
      
    }

}