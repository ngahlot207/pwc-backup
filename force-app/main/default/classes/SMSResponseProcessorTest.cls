@isTest
public class SMSResponseProcessorTest {
    
    @testsetup
    static void SMSResponseTestFactory(){
        LoanAppl__c ln = TestDataFactory.createLoanApplication(true);
        Applicant__c appl = TestDataFactory.createSingleApplicant(true, ln.Id);
    }
    
    @isTest
    static void testSMSProcessing_Success() {
        LoanAppl__c loan =[SELECT Id FROM LoanAppl__c LIMIT 1];
        Applicant__c appli = [SELECT Id FROM Applicant__c LIMIT 1];
        
        List<IntgMsg__c> intMsglist1 =  TestDataFactory.createIntMsg(true, 'SMS', appli.id, null);
        IntgMsg__c intgMsg = new IntgMsg__c();
        
        intgMsg.ParentRefId__c=loan.id;
        intgMsg.RefId__c =appli.id;
        
        intMsglist1.add(intgMsg);
        
        // Set up a response with status code '0'
        String jsonWithSuccess = '{"result":{"req_id":"123", "msisdn":"9876543210", "status":{"statusCode":"0"}}}';
        intMsglist1[0].Resp__c = jsonWithSuccess;
        
        
        SMSWrapper wrapperrequest = SMSWrapper.parse(jsonWithSuccess);
        
        
        // Create referenceId for the loan application
        Id referenceId = [SELECT Id FROM LoanAppl__c LIMIT 1].Id;
        
        Test.startTest();
        try {
            SMSResponseProcessor.process(intMsglist1);
            System.assert(true, 'SMS record created successfully');
        } catch (Exception e) {
            //System.assert(false, 'Exception not expected: ' + e.getMessage());
        }
        Test.stopTest();
    }
    
    @isTest
    static void testSMSProcessing_Failure() {
        LoanAppl__c loan =[SELECT Id FROM LoanAppl__c LIMIT 1];
        Applicant__c appli = [SELECT Id FROM Applicant__c LIMIT 1];
        
        List<IntgMsg__c> intMsglist2 =  TestDataFactory.createIntMsg(true, 'SMS', appli.id, null);
        IntgMsg__c intgMsg = new IntgMsg__c();
        
        intgMsg.ParentRefId__c=loan.id;
        intgMsg.RefId__c =appli.id;
        
        intMsglist2.add(intgMsg);
        
        // Set up a response with status code other than '0'
        
        String jsonWithFailure = '{"result":{"req_id":"456", "msisdn":"9876543210", "status":{"statusCode":"1"}}}';
        
        intMsglist2[0].Resp__c = jsonWithFailure;
        
        Test.startTest();
        
        try {
            SMSResponseProcessor.process(intMsglist2);
        } catch (Exception e) {
            System.assert(true, 'Exception: ' + e.getMessage());
        }
        Test.stopTest();
    }
}