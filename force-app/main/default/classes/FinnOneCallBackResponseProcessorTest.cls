@isTest
public class FinnOneCallBackResponseProcessorTest {
    
    @isTest
    public static void testGenerateMethod() {
        
        LoanAppl__c la = TestDataFactory.createLoanApplication(true);
        la.FinnoneAppid__c='588310';
        la.Status__c='Finnone Pending';
        la.DisbursalType__c='MULTIPLE';
        update la;
        
        Applicant__c app = TestDataFactory.createSingleApplicant(true,la.id);
        
        
        Disbursement__c db=new Disbursement__c();
        db.Loan_Appli__c=la.id;
        insert db;
        
        Split_Disbur__c sd=new Split_Disbur__c();
        sd.DisburseRela__c=db.id;
        insert sd;
        
        
        IntgMsg__c intgMsg =new IntgMsg__c();
        intgMsg.Name='Finnone Callback';
        intgMsg.BU__c='HL / STL';
        intgMsg.Status__c='New';
        intgMsg.MStatus__c='Blank';
        intgMsg.Req__c='{"lmsErrorMsg":"","lmsRequestId":"578720038","lmsApplicationID":"588310","lmsLanNo":"FEDMUM0HL0503763","lanDisbursementDate":"02-JAN-2024","lmsErrorCode":"","lmsDisburseAmt":"574941"}';
        insert intgMsg;
        
        
        List<IntgMsg__c> resp =new List<IntgMsg__c>{intgMsg};
        
        Test.StartTest();
        FinnOneCallBackResponseProcessor.process(resp);
        Test.StopTest();
        
    }
    
}