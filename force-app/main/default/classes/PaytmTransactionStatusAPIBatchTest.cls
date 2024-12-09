@isTest
public class PaytmTransactionStatusAPIBatchTest {
    
    @testSetup
    public static void setupTestData(){
        
        LoanAppl__c la = TestDataFactory.createLoanApplication(true);
        
        Applicant__c app = new  Applicant__c();
        app.LoanAppln__c=la.Id;
        insert app;
        
        la.Applicant__c=app.id;
        update la;
        
        Payment__c pay=new Payment__c();
        pay.LoanAppl__c=la.Id;
        pay.TransAmt__c=100;
        pay.PaytmOrderId__c='690196521';
        insert pay;
        
        ApplIMD__c imd =new ApplIMD__c();
        imd.LoanAppln__c=la.Id;
        imd.PaytmOrderId__c='690196521';
        imd.TransAmt__c=100;
        insert imd;
        
        List<IntgMsg__c> IntgMsgList =new List<IntgMsg__c>();
        
         IntgMsg__c intg=New IntgMsg__c();
        intg.Name='Transaction Status API';
        intg.BU__c='HL / STL';
        intg.Status__c='New';
        intg.MStatus__c='Blank';
        intg.Svc__c='Transaction Status API';
        intg.ApiVendor__c='Paytm';
        intg.RefId__c=imd.id;
        intg.RefObj__c='ApplIMD__c';
        intg.Resp__c='{"head":{"responseTimestamp":"1553496322922","version":"v1","clientId":"C11","signature":"xxxxx"},"body":{"resultInfo":{"resultStatus":"TXN_SUCCESS","resultCode":"01","resultMsg":"Txn Success"},"txnId":"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx","bankTxnId":"xxxxxxxxxxxxxxx","orderId":"690196521","txnAmount":"100.00","txnType":"SALE","gatewayName":"HDFC","bankName":"HSBC","mid":"xxxxxxxxxxxxxxxxxxxx","paymentMode":"CC","refundAmt":"100.00","txnDate":"2019-02-20 12:35:20.0","authRefId":"50112883"}}';
        IntgMsgList.add(intg);
        
        IntgMsg__c intg1=New IntgMsg__c();
        intg1.Name='Transaction Status API';
        intg1.BU__c='HL / STL';
        intg1.Status__c='New';
        intg1.MStatus__c='Blank';
        intg1.Svc__c='Transaction Status API';
        intg1.ApiVendor__c='Paytm';
        intg1.RefId__c=pay.id;
        intg1.RefObj__c='Payment__c';
        intg1.Resp__c='{"head":{"responseTimestamp":"1553496322922","version":"v1","clientId":"C11","signature":"xxxxx"},"body":{"resultInfo":{"resultStatus":"TXN_SUCCESS","resultCode":"01","resultMsg":"Txn Success"},"txnId":"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx","bankTxnId":"xxxxxxxxxxxxxxx","orderId":"690196521","txnAmount":"100.00","txnType":"SALE","gatewayName":"HDFC","bankName":"HSBC","mid":"xxxxxxxxxxxxxxxxxxxx","paymentMode":"CC","refundAmt":"100.00","txnDate":"2019-02-20 12:35:20.0","authRefId":"50112883"}}';
        IntgMsgList.add(intg1);
        
        TriggerBase.bypass('IntgMsg__c');
        insert IntgMsgList;
        TriggerBase.clearBypass('IntgMsg__c');
        
    }
   
        
    @isTest
    public static void Testmethod1(){
        
        List<IntgMsg__c> intgMsgList = [SELECT Id, Name, BU__c, Status__c, MStatus__c, Svc__c, ApiVendor__c, Req__c FROM IntgMsg__c];
        
        Test.Starttest();
        
        PaytmTransactionStatusAPIBatch batch = new PaytmTransactionStatusAPIBatch();
        batch.execute(null);
        
        Test.Stoptest();
        
    }
}