@isTest
public class MultiTrancheResponseProcessorTest {

  	@istest
    static void passMultiTrancheResponseProcessorTest(){
        List<IntgMsg__c> lstIntegrationMessaesge = new List<IntgMsg__c>();
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        
        Applicant__c appli =  TestDataFactory.createSingleApplicant(true,loanApp.id); 
     	
        String response= '{ "Data": [ { "CurrentPOS": "1290393.000", "CurrentOverdue": "0.000", "PendingEMIs": null, "DPD": "0", "Tranches": [ { "TranchID": "1", "Amount": "585000.00", "TranchDate": "2019-09-13T00:00:00", "Message": "null_a0GC4000000aYsnMAE", "CancelledDisbursals": "NO", "DisbursalStatus": "DISBURSED", "TotalDisbursalAmount": "1300000.000", "ExcessAmount": "0.00000", "LoanTenure": "251" } ] } ], "status": 200, "message": "Success" }'; 
        IntgMsg__c newlit = new IntgMsg__c();
        newlit.Name = 'Get Multi Tranch';
        newlit.BU__c = 'HL / STL';
        newlit.Svc__c = 'Get Multi Tranch';
        newlit.IsActive__c = true;
        newlit.RefId__c = loanApp.Id;
        newlit.Status__c = 'Responded';
        newlit.MStatus__c = 'Acknowledged';
        newlit.Trigger_Platform_Event__c = true;
        newlit.RefObj__c = 'LoanAppl__c';
        
        newlit.Resp__c = response;
        
        lstIntegrationMessaesge.add(newlit);
        insert lstIntegrationMessaesge;
        
        MultiTrancheResponseProcessor.process(lstIntegrationMessaesge);
       
        
    }
    
    @istest
    static void failMultiTrancheResponseProcessorTest(){
        List<IntgMsg__c> lstIntegrationMessaesge = new List<IntgMsg__c>();
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        
        Applicant__c appli =  TestDataFactory.createSingleApplicant(true,loanApp.id); 
     	
        
        Disbursement__c disbObj =new Disbursement__c();
        disbObj.Date_of_Disbur__c=Date.newInstance(2025, 12, 9);
        disbObj.No_of_Disbur__c=1;
        disbObj.Princ_Start_Date__c=Date.newInstance(2024, 12, 9);
        disbObj.Princ_Rec_on__c='Amount Financed';
        disbObj.Loan_Appli__c= loanApp.id;
        disbObj.Disbur_No__c=1;
        disbObj.Total_Disb_Amt__c=10000;            
        insert disbObj;
        
        String response= '{ "Data": [ { "CurrentPOS": "1290393.000", "CurrentOverdue": "0.000", "PendingEMIs": null, "DPD": "0", "Tranches": [ { "TranchID": "1", "Amount": "585000.00", "TranchDate": "2019-09-13T00:00:00", "Message": "Success_a0GC4000000aYsnMAE", "CancelledDisbursals": "NO", "DisbursalStatus": "DISBURSED", "TotalDisbursalAmount": "1300000.000", "ExcessAmount": "0.00000", "LoanTenure": "251" } ] } ], "status": 500, "message": "Failure" }'; 
        IntgMsg__c newlit = new IntgMsg__c();
        newlit.Name = 'Get Multi Tranch';
        newlit.BU__c = 'HL / STL';
        newlit.Svc__c = 'Get Multi Tranch';
        newlit.IsActive__c = true;
        newlit.RefId__c = loanApp.Id;
        newlit.Status__c = 'Responded';
        newlit.MStatus__c = 'Acknowledged';
        newlit.Trigger_Platform_Event__c = true;
        newlit.RefObj__c = 'LoanAppl__c';
        
        newlit.Resp__c = response;
        
        lstIntegrationMessaesge.add(newlit);
        insert lstIntegrationMessaesge;
        
        MultiTrancheResponseProcessor.process(lstIntegrationMessaesge);
       
        
    }
    
}