@isTest
public class BatchToSendODCPDDDocumentCommuniTest {
    
    
    @isTest
    Public static void testmethod1(){
        
        User lstUser = [SELECT ID,Name, Email FROM User WHERE ID =: UserInfo.getUserId()];
        User u = TestDataFactory.UserData(true);
        system.runAs(u){
            LoanAppl__c loanApp = new LoanAppl__c(); 
            loanApp.Stage__c = 'Disbursed';
            loanApp.SubStage__c = 'DI Check' ;
            loanApp.FinnSubDtTime__c = System.today().addDays(-7);
            loanApp.Loan_Boarding_API_Status__c = 'Success';
            loanApp.RMSMName__c = u.Id;
            loanApp.BrchName__c = 'MUMBAI';
            loanApp.BrchCode__c = 'MUM';
            loanApp.Product__c = 'Home Loan';
            TriggerBase.bypass('LoanAppl__c');
            Insert loanApp; 
            TriggerBase.clearBypass('LoanAppl__c');
            system.debug('RM sm Name :'+loanApp.RMSMName__c);
            
            
            Applicant__c app = TestDataFactory.createSingleApplicant(True,loanApp.Id);
            DocMstr__c docMaster =  TestDataFactory.createDocumentMaster(True,'Test');
            DocDtl__c docDtl = TestDataFactory.createDocumentDetail(True,'OTC',app.Id,docMaster.Id);
            docDtl.DocStatus__c = 'OTC';
            docDtl.LAN__c =  loanApp.Id;   
            Update docDtl;
            

            BankBrchMstr__c objBandMaster = new BankBrchMstr__c();
            objBandMaster.Name = 'Test';
            objBandMaster.BrchCode__c = 'MUM'; 
            TriggerBase.bypass('BankBrchMstr__c');
            Insert objBandMaster;
            TriggerBase.clearBypass('BankBrchMstr__c');
            
            TeamHierarchy__c teamHirachay = TestDataFactory.TestDataTeamHierarchy_nonSup(TRUE,u.Id,objBandMaster.Id);
            teamHirachay.EmpRole__c = 'BBH';
            teamHirachay.EmpBrch__c = objBandMaster.Id;
            Update teamHirachay;
            
            TeamHierarchy__c teamHirachay1 = TestDataFactory.TestDataTeamHierarchy_nonSup(TRUE,u.Id,objBandMaster.Id);
            teamHirachay1.EmpRole__c = 'CPA';
            teamHirachay1.EmpBrch__c = objBandMaster.Id;
         
            Update teamHirachay1;
            Test.StartTest();
            BatchToSendODCPDDDocumentCommunication objBatch = new   BatchToSendODCPDDDocumentCommunication();
            Database.executeBatch(objBatch); 
            Test.StopTest();
            
        }     
    }
    
    
    @isTest
    Public static void testmethod2(){
        
        User lstUser = [SELECT ID,Name, Email FROM User WHERE ID =: UserInfo.getUserId()];
        User u = TestDataFactory.UserData(true);
        system.runAs(u){
            
            
            LoanAppl__c loanApp = new LoanAppl__c(); 
            loanApp.Stage__c = 'Disbursed';
            loanApp.SubStage__c = 'DI Check' ;
            loanApp.FinnSubDtTime__c = System.today().addDays(-14);
            loanApp.Loan_Boarding_API_Status__c = 'Success';
            loanApp.RMSMName__c = u.Id;
            loanApp.BrchName__c = 'MUMBAI';
            loanApp.BrchCode__c = 'MUM';
            loanApp.Product__c = 'Home Loan';
            TriggerBase.bypass('LoanAppl__c');
            Insert loanApp; 
            TriggerBase.clearBypass('LoanAppl__c');
            system.debug('RM sm Name :'+loanApp.RMSMName__c);
            
            
            Applicant__c app = TestDataFactory.createSingleApplicant(True,loanApp.Id);
            DocMstr__c docMaster =  TestDataFactory.createDocumentMaster(True,'Test');
            DocDtl__c docDtl = TestDataFactory.createDocumentDetail(True,'OTC',app.Id,docMaster.Id);
            docDtl.DocStatus__c = 'OTC';
            docDtl.LAN__c =  loanApp.Id;   
            Update docDtl;
            
            List<DocDtl__c> doctl = [SELECT ID, LAN__r.SubStage__c  FROM DocDtl__c WHERE ID =:docDtl.Id];
            system.debug('doctl:'+doctl);
            
            BankBrchMstr__c objBandMaster = new BankBrchMstr__c();
            objBandMaster.Name = 'Test';
            objBandMaster.BrchCode__c = 'MUM';    
            Insert objBandMaster;
            
            TeamHierarchy__c teamHirachay = TestDataFactory.TestDataTeamHierarchy_nonSup(TRUE,u.Id,objBandMaster.Id);
            teamHirachay.EmpRole__c = 'BBH';
            teamHirachay.EmpBrch__c = objBandMaster.Id;
            Update teamHirachay;
            
            TeamHierarchy__c teamHirachay1 = TestDataFactory.TestDataTeamHierarchy_nonSup(TRUE,u.Id,objBandMaster.Id);
            teamHirachay1.EmpRole__c = 'CPA';
            teamHirachay1.EmpBrch__c = objBandMaster.Id;
            Update teamHirachay1;
            
            Test.StartTest();
            BatchToSendOTCPDDDocumentAfterfourteenDy objBatch = new   BatchToSendOTCPDDDocumentAfterfourteenDy();
            Database.executeBatch(objBatch); 
            Test.StopTest();
        }     
    }
}