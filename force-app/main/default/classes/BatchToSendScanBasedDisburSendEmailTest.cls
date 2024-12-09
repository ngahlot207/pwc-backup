@isTest
public class BatchToSendScanBasedDisburSendEmailTest {
    
    @testsetup
    Public static void insertData(){
        
        User u = TestDataFactory.UserData(true);
        BankBrchMstr__c objBank =  TestDataFactory.TestDataBankBranchMaster(True);
        TeamHierarchy__c TH0 =  TestDataFactory.TestDataTeamHierarchy_nonSup(True,u.id,objBank.Id);
        TeamHierarchy__c TH =  TestDataFactory.TestDataTeamHierarchy_nonSup(True,u.id,objBank.Id);
        TH.EmpRole__c = 'BOM';
        TH.Supervisor__c = TH0.id;
        TriggerBase.bypass('TeamHierarchy__c');
        Update TH;
        TriggerBase.clearBypass('TeamHierarchy__c'); 
        
        TeamHierarchy__c TH1 =  new TeamHierarchy__c();
        TH1.EmpRole__c = 'AOM';
        TH1.Supervisor__c = TH.Id; 
        TH1.Employee__c = u.id;
        TH1.EmpBrch__c =  objBank.Id;
        TriggerBase.bypass('TeamHierarchy__c');
        Insert TH1;
        TriggerBase.clearBypass('TeamHierarchy__c'); 
        
        TeamHierarchy__c TH2 =  new TeamHierarchy__c();
        TH2.EmpRole__c = 'ROM';
        TH2.Supervisor__c = TH1.Id; 
        TH2.Employee__c = u.id;
        TH2.EmpBrch__c =  objBank.Id;
        TriggerBase.bypass('TeamHierarchy__c');
        Insert TH2;
        TriggerBase.clearBypass('TeamHierarchy__c'); 
       
        TeamHierarchy__c TH3 =  new TeamHierarchy__c();
        TH3.EmpRole__c = 'ZOM';
        TH3.Supervisor__c = TH2.Id; 
        TH3.Employee__c = u.id;
        TH3.EmpBrch__c =  objBank.Id;
        TriggerBase.bypass('TeamHierarchy__c');
        Insert TH3;
        TriggerBase.clearBypass('TeamHierarchy__c'); 
        
        LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
        loan.NDCType__c = 'Scan Based Disbursement';
        loan.OpsUser__c = u.Id;
        Update loan;
        
        DocDispatch__c docDisp = new DocDispatch__c();
        docDisp.LoanAppln__c = loan.Id;
        docDisp.DateofDispatch__c = date.today().addDays(-6);
        docdisp.DateofReceiptbyOps__c = null;
        docdisp.UserRole__c = 'CPA';
        docdisp.Type__c = 'OTC';
        
        TriggerBase.bypass('DocDispatch__c');
        Insert docDisp;
        TriggerBase.clearBypass('DocDispatch__c');
        
        DocDispatch__c docDisp1 = new DocDispatch__c();
        docDisp1.LoanAppln__c = loan.Id;
        docDisp1.DateofDispatch__c = date.today().addDays(-11);
        docDisp1.DateofReceiptbyOps__c = null;
        docDisp1.UserRole__c = 'CPA';
        docDisp1.Type__c = 'OTC';
        
        TriggerBase.bypass('DocDispatch__c');
        Insert docDisp1;
        TriggerBase.clearBypass('DocDispatch__c');
    }
    
    
    @isTest
    Public static void testmethod1(){
        Test.StartTest();  
        BatchToSendScanBasedDisbursementEmail objBatc = new BatchToSendScanBasedDisbursementEmail();
        Database.executeBatch(objBatc);
        Test.StopTest(); 
    }
    
}