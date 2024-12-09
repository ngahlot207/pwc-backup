@isTest
private class PerfiosGenerateReportTest {

   @istest
    static void testProcessValidResponse() {       
        LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
        Applicant__c appl = TestDataFactory.createSingleApplicant(true, loan.Id);
        
        ApplIMD__c imd = TestDataFactory.applIMDData(true,loan.Id);
        imd.AppId__c = appl.Id;
        imd.IntegrationStatus__c = 'Success';
        imd.FinnoneChequeId__c = '691627';
        upsert imd;
        
		ApplBanking__c appBank =new ApplBanking__c();
        appBank.AC_No__c= '6583467';
        appBank.AccountType__c= 'SAVINGS';
        appBank.Bank_Branch__c= 'MARUTI KUNJ ROAD;NEAR KIIT COLLEGE;VILLAGE BHONDS';
        appBank.BankName__c= 'STATE BANK OF INDIA';
        appBank.Bank_City__c= 'GREATER NOIDA';
        appBank.Appl__c= appl.ID;
        appBank.LoanAppl__c=loan.Id;
        insert appBank;
            
        // Create a sample IntgMsg__c record with a valid IMD response
        IntgMsg__c integrationMessage = createSampleIntgMsg('CRIF', GlobalConstants.INT_MSG_BU_TYPE);
        PerfiosGenerateReportResponseWrapper responseWrapper = createValidResponseWrapper();
       
        integrationMessage.Resp__c = JSON.serialize(responseWrapper); 
        integrationMessage.Status__c = 'Responded';
        integrationMessage.ParentRefId__c = appBank.id;
        integrationMessage.APIStatus__c = 'Success';
        upsert integrationMessage;

        Test.startTest();
        PerfiosGenerateReportResponseProcessor.process(new List<IntgMsg__c>{ integrationMessage });
        Test.stopTest();
    }
      @istest
    static void testProcessValidResponse123() {       
        LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
        Applicant__c appl = TestDataFactory.createSingleApplicant(true, loan.Id);
        
        ApplIMD__c imd = TestDataFactory.applIMDData(true,loan.Id);
        imd.AppId__c = appl.Id;
        imd.IntegrationStatus__c = 'Success';
        imd.FinnoneChequeId__c = '691627';
        upsert imd;
        
		ApplBanking__c appBank =new ApplBanking__c();
        appBank.AC_No__c= '6583467';
        appBank.AccountType__c= 'SAVINGS';
        appBank.Bank_Branch__c= 'MARUTI KUNJ ROAD;NEAR KIIT COLLEGE;VILLAGE BHONDS';
        appBank.BankName__c= 'STATE BANK OF INDIA';
        appBank.Bank_City__c= 'GREATER NOIDA';
        appBank.Appl__c= appl.ID;
        appBank.LoanAppl__c=loan.Id;
        insert appBank;
            
        // Create a sample IntgMsg__c record with a valid IMD response
        IntgMsg__c integrationMessage = createSampleIntgMsg('CRIF', GlobalConstants.INT_MSG_BU_TYPE);
        PerfiosGenerateReportResponseWrapper responseWrapper = createValidResponseWrapper1();
       
        integrationMessage.Resp__c = JSON.serialize(responseWrapper); 
        integrationMessage.Status__c = 'Responded';
        integrationMessage.ParentRefId__c = appBank.id;
        integrationMessage.APIStatus__c = 'Success';
        upsert integrationMessage;

        Test.startTest();
        PerfiosGenerateReportResponseProcessor.process(new List<IntgMsg__c>{ integrationMessage });
        Test.stopTest();
    }
     private static IntgMsg__c createSampleIntgMsg(String service, String buType) {
        // Create and insert a sample IntgMsg__c record
        IntgMsg__c integrationMessage = new IntgMsg__c(
            Svc__c = service,
            BU__c = buType,
            Trigger_Platform_Event__c = true,
            Status__c = 'Processed'
        );
        insert integrationMessage;
        return integrationMessage;
    }
 private static PerfiosGenerateReportResponseWrapper createValidResponseWrapper() {
        // Create a sample valid PerfiosGenerateReportResponseWrapper
        PerfiosGenerateReportResponseWrapper imdRes = new PerfiosGenerateReportResponseWrapper();
        PerfiosGenerateReportResponseWrapper.Success s =new PerfiosGenerateReportResponseWrapper.Success();
         PerfiosGenerateReportResponseWrapper.Error E =new PerfiosGenerateReportResponseWrapper.Error();
        E.code = '123';
        E.message='error';

           imdRes.Success= s;
           imdRes.error= E;
        return imdRes;
    }
     private static PerfiosGenerateReportResponseWrapper createValidResponseWrapper1 () {
        // Create a sample valid PerfiosGenerateReportResponseWrapper
        PerfiosGenerateReportResponseWrapper imdRes = new PerfiosGenerateReportResponseWrapper();
        PerfiosGenerateReportResponseWrapper.Success s =new PerfiosGenerateReportResponseWrapper.Success();
         PerfiosGenerateReportResponseWrapper.Error E =new PerfiosGenerateReportResponseWrapper.Error();
        E.code = '123';
        E.message='error';

          // imdRes.Success= s;
           imdRes.error= E;
        return imdRes;
    }
}