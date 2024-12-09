@isTest
public class PaytmCallbackResponseprocessorTest {
	@isTest
    static void testProcess(){
        
        LoanAppl__c LoanApp=TestDataFactory.createLoanApplication(true);
        Applicant__c app = TestDataFactory.createSingleApplicant(true,LoanApp.id);
        
        ApplIMD__c imd=new ApplIMD__c();
        imd.LoanAppln__c=LoanApp.Id;
        imd.PaytmOrderId__c='919344011';
        insert imd;
        
        Payment__c pay=new Payment__c();
        pay.LoanAppl__c=LoanApp.Id;
        pay.PaytmOrderId__c='919344011';
        insert pay;
        
        
        
        List<IntgMsg__c> intmsglist=new List<IntgMsg__c>();
        
        IntgMsg__c intmsg=new IntgMsg__c();
        intmsg.Name='Paytm UAT API';
        intmsg.Status__c='Processed';
        intmsg.Req__c='CURRENCY=INR&LINKDESCRIPTION=IMD+Payment&GATEWAYNAME=PPBLC&RESPMSG=Txn+Success&BANKNAME=&PAYMENTMODE=UPI&CUSTID=N.A&MID=FEDBAN72272366692608&MERC_UNQ_REF=LI_487507&RESPCODE=01&TXNID=20240307011640000972580438247951222&TXNAMOUNT=2950.00&ORDERID=919344011&STATUS=TXN_SUCCESS&BANKTXNID=5549754&udf_2=&TXNDATETIME=2024-03-07+19%3A27%3A26.0&udf_1=IMD+Payment&TXNDATE=2024-03-07&CHECKSUMHASH=4%2F5WIBe5JuxSDIY%2BtS3x8biKRKACFhaUTDXjhChncZ73BxqKmM7cOLbJO50oe7QE0rL35%2BLLnU8%2BSohvCrycGBlBwlEpYLcBwnBxyg%2BVcCw%3D';
        intmsg.IsActive__c=true;
        intmsg.Inbound__c=true;
        intmsglist.add(intmsg);
        
        insert intmsglist;
        
        Test.StartTest();
        PaytmCallbackResponseprocessor.process(intmsglist);
        Test.StopTest();
    }
}