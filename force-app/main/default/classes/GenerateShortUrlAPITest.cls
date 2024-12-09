@isTest
public class GenerateShortUrlAPITest {
    
     @isTest
    public static void testGenerateMethod() {
        List<IntgMsg__c> intmsgList =new List<IntgMsg__c>();
        
        LoanAppl__c La = TestDataFactory.createLoanApplication(true);
        Applicant__c ap = TestDataFactory.createSingleApplicant(true,La.id);
        
        
        ApplIMD__c imd =new ApplIMD__c();
        imd.LoanAppln__c=La.id;
        imd.PaytmLinkURL__c='https://tny.fedfina.com/urlutil/health';
        Insert imd;
        
        Payment__c pay =new Payment__c();
        pay.LoanAppl__c=La.id;
        pay.PaytmLinkURL__c='https://tny.fedfina.com/urlutil/health';
        Insert pay;
        
        
        IntgMsg__c intgMsg = new IntgMsg__c();
        intgMsg.Name = 'Generate Short URL';
        intgMsg.BU__c = 'HL / STL';
        intgMsg.Status__c = 'New';
        intgMsg.MStatus__c = 'Blank';
        intgMsg.RefObj__c = 'ApplIMD__c';
        intgMsg.RefId__c = imd.Id;
        intgMsg.Trigger_Platform_Event__c = true;
        intgMsg.Resp__c = '{"status":"1","message":"OK","data":{"shortUrl":"https://tny.fedfina.com/fedFina/oqe9CLvcglST"}}';
        intmsgList.add(intgMsg);
        
        IntgMsg__c intgMsg1 = new IntgMsg__c();
        intgMsg1.Name = 'Generate Short URL';
        intgMsg1.BU__c = 'HL / STL';
        intgMsg1.Status__c = 'New';
        intgMsg1.MStatus__c = 'Blank';
        intgMsg1.RefObj__c = 'Payment__c';
        intgMsg1.RefId__c = pay.Id;
        intgMsg1.Trigger_Platform_Event__c = true;
        intgMsg1.Resp__c = '{"status":"0","message":"OK","data":""}';
        intmsgList.add(intgMsg1);
        
        
            GenerateShortUrlAPIRequestGenerator gen = new GenerateShortUrlAPIRequestGenerator();
        
            Test.starttest();
            gen.generate(intmsgList, 'Generate Short URL', 'Async');
        GenerateShortUrlAPIResponseProcessor.process(intmsgList);
            Test.stoptest();
         
    }

}