@isTest
public class BatchToSendBulkOTCPDDDocToLoanApplcnTest {
    
    @isTest    
    Public static void testMethod1(){
    List<LoanAppl__c>  lstloanApp = new  List<LoanAppl__c>(); 
    List<LoanAppl__c>  lstloanApp2 = new  List<LoanAppl__c>(); 
    List<User> lstUser = [SELECT ID,Name, Email FROM User WHERE ID =: UserInfo.getUserId()];
        
    
      
    LoanAppl__c loanApp = new LoanAppl__c(); 
    loanApp.Stage__c = 'Disbursed';
    loanApp.SubStage__c = 'DI Check' ;
    loanApp.FinnSubDtTime__c = System.today().addDays(-10);
    loanApp.Loan_Boarding_API_Status__c = 'Success';
    loanApp.RMSMName__c = lstUser[0].Id;
    loanApp.BrchName__c = 'MUMBAI';
    loanApp.BrchCode__c = 'MUM';
    loanApp.Product__c = 'Home Loan';
    TriggerBase.bypass('LoanAppl__c');
    Insert loanApp; 
    TriggerBase.clearBypass('LoanAppl__c');  
        
    BankBrchMstr__c bankBranchMaster = new BankBrchMstr__c(); 
    bankBranchMaster.BrchCode__c = 'MUM';
    bankBranchMaster.Name = 'Mumbai';
    TriggerBase.bypass('BankBrchMstr__c');
    Insert bankBranchMaster;
    TriggerBase.clearBypass('BankBrchMstr__c'); 
        
    LocMstr__c locMaster1 = TestDataFactory.LocMaster(True);
    locMaster1.State__c = 'Maharashtra';
    Update locMaster1;
        
    LocBrchJn__c locBranchJun = TestDataFactory.locBranchJnData(True,bankBranchMaster.Id,locMaster1.Id);
        
    Applicant__c app = TestDataFactory.createSingleApplicant(True,loanApp.Id);
    DocMstr__c docMaster =  TestDataFactory.createDocumentMaster(True,'Test');
    
  
        
    DocDtl__c docDtl = TestDataFactory.createDocumentDetail(True,'OTC',app.Id,docMaster.Id);
    docDtl.DocStatus__c = 'OTC';
    docDtl.LAN__c =  loanApp.Id;   
    Update docDtl;
        
     TeamHierarchy__c teamHir = TestDataFactory.TestDataTeamHierarchy_nonSup(true,lstUser[0].Id,bankBranchMaster.Id);
     teamHir.Emprole__c = 'BBH';
     
     Update teamHir;
        
     TeamHierarchy__c teamHir1 = TestDataFactory.TestDataTeamHierarchy_nonSup(true,lstUser[0].Id,bankBranchMaster.Id);
     teamHir1.Emprole__c = 'CPA';
     Update teamHir1;
        
     TeamHierarchy__c teamHir2 = TestDataFactory.TestDataTeamHierarchy_nonSup(true,lstUser[0].Id,bankBranchMaster.Id);
     teamHir2.Emprole__c = 'NOM';
     Update teamHir2;
        
        
    Test.StartTest();  
    BatchToSendBulkOTCPDDDocToLoanApplcn objBatc = new BatchToSendBulkOTCPDDDocToLoanApplcn();
    Database.executeBatch(objBatc);
    Test.StopTest(); 
 
    }
    
    
    @isTest    
    Public static void testMethod2(){
    List<LoanAppl__c>  lstloanApp = new  List<LoanAppl__c>(); 
    List<LoanAppl__c>  lstloanApp2 = new  List<LoanAppl__c>(); 
    List<User> lstUser = [SELECT ID,Name, Email FROM User WHERE ID =: UserInfo.getUserId()];
      
    LoanAppl__c loanApp = new LoanAppl__c(); 
    loanApp.Stage__c = 'Disbursed';
    loanApp.SubStage__c = 'DI Check' ;
    loanApp.FinnSubDtTime__c = System.today().addDays(-14);
    loanApp.Loan_Boarding_API_Status__c = 'Success';
    loanApp.RMSMName__c = lstUser[0].Id;
    loanApp.BrchName__c = 'MUMBAI';
    loanApp.BrchCode__c = 'MUM';
    loanApp.Product__c = 'Home Loan';
    TriggerBase.bypass('LoanAppl__c');
    Insert loanApp; 
    TriggerBase.clearBypass('LoanAppl__c');  
  BankBrchMstr__c bankBranchMaster = new BankBrchMstr__c(); 
    bankBranchMaster.BrchCode__c = 'MUM';
    bankBranchMaster.Name = 'Mumbai';
    TriggerBase.bypass('BankBrchMstr__c');
    Insert bankBranchMaster;
    TriggerBase.clearBypass('BankBrchMstr__c'); 
        
    LocMstr__c locMaster1 = TestDataFactory.LocMaster(True);
    locMaster1.State__c = 'Maharashtra';
    Update locMaster1;
        
    LocBrchJn__c locBranchJun = TestDataFactory.locBranchJnData(True,bankBranchMaster.Id,locMaster1.Id);
        
    Applicant__c app = TestDataFactory.createSingleApplicant(True,loanApp.Id);
    DocMstr__c docMaster =  TestDataFactory.createDocumentMaster(True,'Test');
    
  
        
    DocDtl__c docDtl = TestDataFactory.createDocumentDetail(True,'OTC',app.Id,docMaster.Id);
    docDtl.DocStatus__c = 'OTC';
    docDtl.LAN__c =  loanApp.Id;   
    Update docDtl;
        
     TeamHierarchy__c teamHir = TestDataFactory.TestDataTeamHierarchy_nonSup(true,lstUser[0].Id,bankBranchMaster.Id);
     teamHir.Emprole__c = 'BBH';
     
     Update teamHir;
        
     TeamHierarchy__c teamHir1 = TestDataFactory.TestDataTeamHierarchy_nonSup(true,lstUser[0].Id,bankBranchMaster.Id);
     teamHir1.Emprole__c = 'CPA';
     Update teamHir1;
        
     TeamHierarchy__c teamHir2 = TestDataFactory.TestDataTeamHierarchy_nonSup(true,lstUser[0].Id,bankBranchMaster.Id);
     teamHir2.Emprole__c = 'NOM';
     Update teamHir2;

        
    Test.StartTest();  
    BatchToSendbulkOTCPDDToLANAfter14Days objBatc = new BatchToSendbulkOTCPDDToLANAfter14Days();
    Database.executeBatch(objBatc);
    Test.StopTest(); 
 
    }
}