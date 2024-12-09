@isTest
private class LoanBoardingResponseProcessorTest {

     @testsetup
    static void createTestData(){   
            LoanAppl__c loanApp = new LoanAppl__c();
            loanApp.Stage__c = 'DDE';
            loanApp.SubStage__c = 'CPA Data Entry';
            loanApp.BrchCode__c = 'HYC';
            loanApp.Product__c = 'Home Loan';
            loanApp.Loan_Tenure_Months__c = 120;
            loanApp.ReqLoanAmt__c=1000000;
            loanApp.Loan_Boarding_API_Status__c='Success';
            loanApp.Status__c='Finnone Pending';
            loanApp.ErrorMessage__c='APPLICATION CREATED SUCCESSFULLY';
            loanApp.FinnSubDtTime__c =System.now();
            TriggerBase.bypass('LoanAppl__c');
            insert loanApp;
            TriggerBase.clearBypass('LoanAppl__c');
        
        Applicant__c appli =  TestDataFactory.createSingleApplicant(true,loanApp.id);
        
                Disbursement__c updDisb = new Disbursement__c();
                updDisb.Disbur_Status__c='INITIATED';  
                updDisb.Loan_Appli__c = loanApp.id;
                TriggerBase.bypass('Disbursement__c');
                insert updDisb;
                TriggerBase.clearBypass('Disbursement__c');        
            
    }
    
    @isTest
    static void testProcess_Success() {
    
        LoanAppl__c testLoan =[SELECT Id FROM LoanAppl__c LIMIT 1];
        Applicant__c appli = [SELECT Id FROM Applicant__c LIMIT 1];
        Disbursement__c disbRec = [SELECT Id FROM Disbursement__c LIMIT 1];
        
             IntgMsg__c response = new IntgMsg__c(
                Svc__c='Loan Boarding',
                BU__c = 'HL / STL',
                MStatus__c='Blank',
                Status__c = 'New',
                Resp__c = '{"applicationID":"123357","unqRequestId":"688191406apjh","errorcode":"0","errorDescription":"APPLICATION CREATED SUCCESSFULLY WITH ID : 12345 AT STAGE DISBURSED"}',
                RefId__c = testLoan.Id,
                RefObj__c='LoanAppl__c',
                Name='Loan Boarding',
                Upsert_Record_Ids__c = disbRec.Id            
        );          
               TriggerBase.bypass('IntgMsg__c');
                 insert response;
               TriggerBase.clearBypass('IntgMsg__c');
  
        LoanBoardingResponseWrapper responseWrapper = new LoanBoardingResponseWrapper();
        responseWrapper.errorDescription = 'APPLICATION CREATED SUCCESSFULLY';
        
          
      
        Test.startTest();
        LoanBoardingResponseProcessor.process(new List<IntgMsg__c>{ response });
        Test.stopTest();
        
      
        LoanAppl__c updatedLoan = [SELECT Id, Loan_Boarding_API_Status__c, FinnSubDtTime__c FROM LoanAppl__c WHERE Id =:testLoan.Id];
        
      //  System.assertEquals('Success', updatedLoan.Loan_Boarding_API_Status__c);
       // System.assertNotEquals(null, updatedLoan.FinnSubDtTime__c);
        system.debug('updatedLoan------------->'+ updatedLoan);
    }
    
   /* @isTest
    static void testProcess_Failure() {
        // Test data setup
          LoanAppl__c testLoan =[SELECT Id FROM LoanAppl__c LIMIT 1];
         Applicant__c appli = [SELECT Id FROM Applicant__c LIMIT 1];
        
          IntgMsg__c response = new IntgMsg__c(
            Svc__c = GlobalConstants.INT_CONFIG_SERVICE_LOAN_BOARDING_API_SERVICE,
            BU__c = GlobalConstants.INT_MSG_BU_TYPE,
            Status__c = 'New',
            Resp__c = '{"requestId":"123546578","result":{},"statusCode":101,"statusMessage":"Invalid Input"}',
            RefId__c = testLoan.Id
        );
          TriggerBase.bypass('IntgMsg__c');
             insert response;
           TriggerBase.clearBypass('IntgMsg__c');
        
   
        
        LoanBoardingResponseWrapper responseWrapper = new LoanBoardingResponseWrapper();
        responseWrapper.errorDescription = 'Some error occurred';
        
        // Call the method to be tested
        Test.startTest();
        LoanBoardingResponseProcessor.process(new List<IntgMsg__c>{ response });
        Test.stopTest();
        
        // Retrieve the updated record and verify
        LoanAppl__c updatedLoan = [SELECT Id, Loan_Boarding_API_Status__c, ErrorMessage__c FROM LoanAppl__c WHERE Id = :testLoan.Id];
        //System.assertEquals('Failure', updatedLoan.Loan_Boarding_API_Status__c);
        //System.assertEquals(responseWrapper.errorDescription, updatedLoan.ErrorMessage__c);
    }
    
    @isTest
    static void testProcess_WrongService() {
        LoanAppl__c testLoan =[SELECT Id FROM LoanAppl__c LIMIT 1];
        Applicant__c appli = [SELECT Id FROM Applicant__c LIMIT 1];
        
          IntgMsg__c response = new IntgMsg__c(
            Svc__c = GlobalConstants.INT_CONFIG_SERVICE_RISK_RATING,
            BU__c = GlobalConstants.INT_MSG_BU_TYPE,
            Status__c = 'New',
            Resp__c = '{"requestId":"123546578","result":{},"statusCode":101,"statusMessage":"Invalid Input"}',
            RefId__c = testLoan.Id
        );
          TriggerBase.bypass('IntgMsg__c');
             insert response;
           TriggerBase.clearBypass('IntgMsg__c');
        
      
        Test.startTest();
          LoanBoardingResponseProcessor.process(new List<IntgMsg__c>{ response });
        // System.assert(false, 'Expected exception was not thrown');
     
        Test.stopTest();
    }*/
    
   
}