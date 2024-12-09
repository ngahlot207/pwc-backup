@isTest
public class IMDResponseProcessorTest {

    @isTest
    static void testProcessValidResponse() {       
        LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
        Applicant__c appl = TestDataFactory.createSingleApplicant(true, loan.Id);
        
        ApplIMD__c imd = new ApplIMD__c();//TestDataFactory.applIMDData(true,loan.Id);
        imd.AppId__c = appl.Id;
        imd.LoanAppln__c=loan.Id;
        imd.IntegrationStatus__c = 'Success';
        imd.FinnoneChequeId__c = '691627';
        Insert imd;
        
        Payment__c pay=new Payment__c();
        pay.LoanAppl__c=loan.Id;
        insert pay;
        
        IntgMsg__c intmsg=new IntgMsg__c();
        intmsg.Name='IMD';
        intmsg.Status__c='New';
        intmsg.BU__c='HL / STL';
        intmsg.RefId__c=imd.Id;
        intmsg.RefObj__c='ApplIMD__c';
        intmsg.Svc__c='IMD';
        intmsg.ApiVendor__c='Finnone';
        intmsg.Trigger_Platform_Event__c=true;
        intmsg.Req__c='{"utrNo":"","user":"imdweb","transactionCode":"1","sourceId":"SFDC","schemeId":"541","requestId":"019086452","requestedForFlag":null,"receiptNo":"445566","receiptDate":"01-Feb-2024","receiptChannel":null,"receiptAmount":"3000","reason":null,"productFlag":"LAP","payableAt":null,"password":"zqbAx8rZ0LvWMftg38eTatwjEANYAo/6","modeOfPayment":"Q","loanNumber":null,"inFavourOf":"Fedbank Financial Service Limited","imdFlag":"Y","imdCustom7":"L0000000197","imdCustom6":null,"imdCustom5":"9999999999","imdCustom4":"","imdCustom3":"Q Q Q JHAJJAR 123444 HARYANA India","imdCustom2":"YU R","imdCustom1":"","homeBranch":null,"ftMode":"CR","expiryDate":null,"drawnOn":"694","dealingBank":"11","city":"100","chequeStatus":"R","chequeNumber":"445566","chequeDate":"01-Feb-2024","chargeId":"56","cashAc":null,"cardNo":null,"cardHolderName":null,"cardCategory":null,"branch":"5","bpType":"LS","bpId":null,"approvalCode":null,"applicationId":"589604","allocationType":null,"agency":null}';
        intmsg.Resp__c='{"requestId":"019086452","status":"SUCCESS","applicationId":"589604","chequeId":"7245950","errorcode":"0000"}';
		insert intmsg;
        
        IntgMsg__c intmsg1=new IntgMsg__c();
        intmsg1.Name='IMD';
        intmsg1.Status__c='New';
        intmsg1.BU__c='HL / STL';
        intmsg1.RefId__c=pay.Id;
        intmsg1.RefObj__c='Payment__c';
        intmsg1.Svc__c='IMD';
        intmsg1.ApiVendor__c='Finnone';
        intmsg1.Trigger_Platform_Event__c=true;
        intmsg1.Req__c='{"utrNo":"","user":"imdweb","transactionCode":"1","sourceId":"SFDC","schemeId":"559","requestId":"987000898","requestedForFlag":null,"receiptNo":"444444","receiptDate":"01-Feb-2024","receiptChannel":null,"receiptAmount":"3000","reason":null,"productFlag":"LAP","payableAt":null,"password":"zqbAx8rZ0LvWMftg38eTatwjEANYAo/6","modeOfPayment":"Q","loanNumber":null,"inFavourOf":"Fedbank Financial Service Limited","imdFlag":"Y","imdCustom7":"L0000000183","imdCustom6":null,"imdCustom5":"9999999999","imdCustom4":"","imdCustom3":"A A A FARIDABAD 112254 HARYANA India","imdCustom2":"PRK Q","imdCustom1":"","homeBranch":null,"ftMode":"CR","expiryDate":null,"drawnOn":"694","dealingBank":"12","city":"100","chequeStatus":"R","chequeNumber":"444444","chequeDate":"01-Feb-2024","chargeId":"56","cashAc":null,"cardNo":null,"cardHolderName":null,"cardCategory":null,"branch":"5","bpType":"LS","bpId":null,"approvalCode":null,"applicationId":"589581","allocationType":null,"agency":null}';
        intmsg1.Resp__c='{"requestId":"987000898","status":"FAIL","applicationId":"589581","errorcode":"400","errorDescription":"##This CHEQUENUMBER already processed for the application-589581"}';
		insert intmsg1;
        
        List<IntgMsg__c> IntgMsglist=new List<IntgMsg__c>{intmsg,intmsg1};
            
            Test.StartTest();
            IMDResponseProcessor.process(IntgMsglist);
            Test.StopTest();  
    }
}