@isTest
public class PerfiosInitiateResponseProcessorTest {
    
    @testsetup
    Public static void insertPerfiosInitiateResponseProcessor(){
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        Applicant__c app = TestDataFactory.createSingleApplicant(true,loanApp.Id);
        
        ApplBanking__c appBanking = new ApplBanking__c();
        appBanking.LoanAppl__c = loanApp.Id;
        appBanking.Appl__c = app.Id;
        appBanking.Bank_City__c = 'Mumbai';
        Insert appBanking;
    }
    
    @isTest
    Public static void positive_PerfiosInitiateResponseProcessorData(){
        List<IntgMsg__c> lstIntegrationMessaesge = new List<IntgMsg__c>();
        List<Applicant__c> lstApp = [Select Id,Name From Applicant__c Limit 1];
        List<ApplBanking__c> lstApplicantBanking = [SELECT ID,Bank_City__c,Appl__c,LoanAppl__c FROM ApplBanking__c WHERE Bank_City__c = 'Mumbai'];
        
        String response = '{"perfiosTransaction":{"perfiosTransactionId":"CBRZ1697718264591"}}';
        String SVC = 'Initiate Transaction';
    
        List<IntgMsg__c> listOfIntegrationMessae = TestDataFactory.createIntMsg(true,SVC,lstApp[0].Id,response);
        
        for(IntgMsg__c intemes : listOfIntegrationMessae){
            intemes.ParentRefId__c = lstApplicantBanking[0].Id;
            intemes.Trigger_Platform_Event__c = true;
            lstIntegrationMessaesge.add(intemes);
        }
        
        system.debug('lstIntegrationMessaesge:'+lstIntegrationMessaesge);
        system.debug('lstIntegrationSize:'+lstIntegrationMessaesge.size());
        PerfiosInitiateResponseProcessor.process(lstIntegrationMessaesge);
        system.assert(!lstIntegrationMessaesge.isEmpty(),'Integration message List Should not empty');
    }
    
    @isTest
    Public static void negative_PerfiosInitiateResponseProcessorData(){
       List<IntgMsg__c> listOfIntegrationMessae1 = new List<IntgMsg__c>();
       List<Applicant__c> lstApp = [Select Id,Name From Applicant__c Limit 1];
       List<ApplBanking__c> lstApplicantBanking = [SELECT ID,Bank_City__c,Appl__c,LoanAppl__c FROM ApplBanking__c WHERE Bank_City__c = 'Mumbai'];  
       
        String errorJson = '{ "error": { "code": "BadParameter", "message": "Signature is required but missing" } }';
        String SVC = 'Initiate Transaction';
        List<IntgMsg__c> listOfIntegrationMessae = TestDataFactory.createIntMsg(true,SVC,lstApp[0].Id,errorJson);

        for(IntgMsg__c intemess : listOfIntegrationMessae){
            intemess.Trigger_Platform_Event__c = true;
            intemess.ParentRefId__c = lstApplicantBanking[0].Id;
            listOfIntegrationMessae1.add(intemess);
        }
        system.debug(' error listOfIntegrationMessae1:'+listOfIntegrationMessae1);
        system.debug('error listOfIntegrationMessae1:'+listOfIntegrationMessae1.size());
        PerfiosInitiateResponseProcessor.process(listOfIntegrationMessae1);
        system.assert(!listOfIntegrationMessae1.isEmpty(),'Integration message List Should not empty');
    }
}