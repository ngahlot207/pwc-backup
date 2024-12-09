@isTest
public class AddTrancheDisResponseProcessorTest {

     @testsetup
    Public static void insertAddTrancheResponseProcessor(){
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        Applicant__c app = TestDataFactory.createSingleApplicant(true,loanApp.Id);
        
        ApplBanking__c appBanking = new ApplBanking__c();
        appBanking.LoanAppl__c = loanApp.Id;
        appBanking.Appl__c = app.Id;
        appBanking.Bank_City__c = 'Mumbai';
        Insert appBanking;
    }
    
     @isTest
    Public static void negative_AddTrancheResponseProcessorData(){
        List<IntgMsg__c> lstIntegrationMessaesge = new List<IntgMsg__c>();
        List<Applicant__c> lstApp = [Select Id,Name From Applicant__c Limit 1];
        List<LoanAppl__c> loanApp = [Select Id,Name From LoanAppl__c Limit 1];
        List<ApplBanking__c> lstApplicantBanking = [SELECT ID,Bank_City__c,Appl__c,LoanAppl__c FROM ApplBanking__c WHERE Bank_City__c = 'Mumbai'];
        
       // String response = '{"disbursalDetail":{"applicationID":"588310","errorcode":"DWS0001","errorDescription":"Disbursal Amount for this tranche exceeds available disbursal amount."},"unqRequestId":"729317327"}';
        
        String response='{"disbursalDetail":{"applicationID":"588310","errorcode":"00000","errorDescription":"Successfull"},"unqRequestId":"99017609145"}';
        String SVC = 'Additional Tranche Disbursal';
        
        Disbursement__c disbObj =new Disbursement__c();
        disbObj.Date_of_Disbur__c=Date.newInstance(2025, 12, 9);
        disbObj.No_of_Disbur__c=1;
        disbObj.Princ_Start_Date__c=Date.newInstance(2024, 12, 9);
        disbObj.Princ_Rec_on__c='Amount Financed';
        disbObj.Loan_Appli__c= loanApp[0].id;
        disbObj.Disbur_No__c=1;
        disbObj.Total_Disb_Amt__c=10000;            
        insert disbObj;
        
        
        List<IntgMsg__c> listOfIntegrationMessae = TestDataFactory.createIntMsg(true,SVC,lstApp[0].Id,response);
        
        IntgMsg__c newlit = new IntgMsg__c();
        newlit.Name = SVC;
        newlit.BU__c = 'HL / STL';
        newlit.Svc__c = SVC;
        newlit.IsActive__c = true;
        newlit.RefId__c = disbObj.Id;
        newlit.Status__c = 'Responded';
        newlit.MStatus__c = 'Acknowledged';
        newlit.Trigger_Platform_Event__c = true;
        newlit.RefObj__c = 'Disbursement__c';
        newlit.ParentRefObj__c ='LoanAppl__c';
        newlit.ParentRefId__c =loanApp[0].Id;
        newlit.Resp__c = response;
        
        lstIntegrationMessaesge.add(newlit);
        insert lstIntegrationMessaesge;
        
        
        
        system.debug('lstIntegrationMessaesge:'+lstIntegrationMessaesge);
        
        AddTrancheDisResponseProcessor.process(lstIntegrationMessaesge);
        
        //system.assert(!lstIntegrationMessaesge.isEmpty(),'Integration message List Should not empty');
    }
    
     @isTest
    Public static void positive_AddTrancheResponseProcessorData(){
        List<IntgMsg__c> lstIntegrationMessaesge = new List<IntgMsg__c>();
        List<Applicant__c> lstApp = [Select Id,Name From Applicant__c Limit 1];
        List<LoanAppl__c> loanApp = [Select Id,Name From LoanAppl__c Limit 1];
        List<ApplBanking__c> lstApplicantBanking = [SELECT ID,Bank_City__c,Appl__c,LoanAppl__c FROM ApplBanking__c WHERE Bank_City__c = 'Mumbai'];
        
        String response = '{"disbursalDetail":{"applicationID":"588310","errorcode":"DWS0001","errorDescription":"Disbursal Amount for this tranche exceeds available disbursal amount."},"unqRequestId":"729317327"}';
        
       // String response='{"disbursalDetail":{"applicationID":"588310","errorcode":"00000","errorDescription":"Successfull"},"unqRequestId":"99017609145"}';
        String SVC = 'Additional Tranche Disbursal';
        
        Disbursement__c disbObj =new Disbursement__c();
        disbObj.Date_of_Disbur__c=Date.newInstance(2025, 12, 9);
        disbObj.No_of_Disbur__c=1;
        disbObj.Princ_Start_Date__c=Date.newInstance(2024, 12, 9);
        disbObj.Princ_Rec_on__c='Amount Financed';
        disbObj.Loan_Appli__c= loanApp[0].id;
        disbObj.Disbur_No__c=1;
        disbObj.Total_Disb_Amt__c=10000;            
        insert disbObj;
        
        
        List<IntgMsg__c> listOfIntegrationMessae = TestDataFactory.createIntMsg(true,SVC,lstApp[0].Id,response);
        
        IntgMsg__c newlit = new IntgMsg__c();
        newlit.Name = SVC;
        newlit.BU__c = 'HL / STL';
        newlit.Svc__c = SVC;
        newlit.IsActive__c = true;
        newlit.RefId__c = disbObj.Id;
        newlit.Status__c = 'Responded';
        newlit.MStatus__c = 'Acknowledged';
        newlit.Trigger_Platform_Event__c = true;
        newlit.RefObj__c = 'Disbursement__c';
        newlit.ParentRefObj__c ='LoanAppl__c';
        newlit.ParentRefId__c =loanApp[0].Id;
        newlit.Resp__c = response;
        
        lstIntegrationMessaesge.add(newlit);
        insert lstIntegrationMessaesge;
        
        
        
        system.debug('lstIntegrationMessaesge:'+lstIntegrationMessaesge);
        
        AddTrancheDisResponseProcessor.process(lstIntegrationMessaesge);
        
        //system.assert(!lstIntegrationMessaesge.isEmpty(),'Integration message List Should not empty');
    }
    
    
    
}