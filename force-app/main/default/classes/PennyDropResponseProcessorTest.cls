@isTest
public class PennyDropResponseProcessorTest {
    @istest
    public static void testGenerateMethod() {
        
        LoanAppl__c la = TestDataFactory.createLoanApplication(true);
        
        Applicant__c app = TestDataFactory.createSingleApplicant(true,la.id);
        
        Repayment_Account__c ra =new Repayment_Account__c();
        ra.Name='test';
        ra.Loan_Application__c=la.id;
        insert ra;
        
        RepayAccVerify__c rav =new RepayAccVerify__c();
        rav.RepayAcc__c=ra.Id;
        insert rav;
        
        Disbursement__c db=new Disbursement__c();
        db.Loan_Appli__c=la.id;
        insert db;
        
        Split_Disbur__c sd=new Split_Disbur__c();
        sd.DisburseRela__c=db.id;
        insert sd;
        
        IntgMsg__c intgMsg =new IntgMsg__c();
        intgMsg.Name='Penny drop';
        intgMsg.BU__c='HL / STL';
        intgMsg.Status__c='New';
        intgMsg.MStatus__c='Blank';
        intgMsg.RefObj__c='Split_Disbur__c';
        intgMsg.RefId__c = sd.Id;
        intgMsg.Resp__c='{"requestId":"696505491","status":"FAIL","applicationId":"588310","errorcode":"400","errorDescription":"##SchemeID not found"}';
        intgMsg.Svc__c='Penny drop';
        insert intgMsg;
        
        IntgMsg__c intgMsg1 =new IntgMsg__c();
        intgMsg1.Name='Penny drop';
        intgMsg1.BU__c='HL / STL';
        intgMsg1.Status__c='New';
        intgMsg1.MStatus__c='Blank';
        intgMsg1.RefObj__c='RepayAccVerify__c';
        intgMsg1.RefId__c = rav.Id;
        intgMsg1.Resp__c='{"requestId":"366163944","status":"SUCCESS","applicationId":"588310","chequeId":"1487","errorcode":"0000"}';
        intgMsg1.Svc__c='Penny drop';
        insert intgMsg1;
        
        List<IntgMsg__c> resp =new List<IntgMsg__c>{intgMsg,intgMsg1};
            
        Test.StartTest();
        PennyDropResponseProcessor.process(resp);
         Test.StopTest();
        
    }

}