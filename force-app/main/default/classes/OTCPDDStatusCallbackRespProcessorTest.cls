@isTest
public class OTCPDDStatusCallbackRespProcessorTest {

    @isTest
   public  static void testProcessMethod() {
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        loanApp.FinnoneAppid__c='589467';
        update loanApp;
       
        Applicant__c appli =  TestDataFactory.createSingleApplicant(true,loanApp.id); 
        
        
       
        DocMstr__c dm=new DocMstr__c();
        dm.Active__c=true;
        dm.DocTyp__c='Disbursal Documents';
        dm.Catgry__c='Mandatory Post Sanction Documents';
        dm.Prod__c='Home Loan';
        dm.DocId__c='235';
        insert dm;
       
       DocDtl__c dd=new DocDtl__c();
       dd.DocMstr__c=dm.Id;
       dd.LAN__c=loanApp.Id;
       dd.Appl__c=appli.Id;
       insert dd;
       
       IntgMsg__c intmsg=new IntgMsg__c();
       intmsg.Name='OTCPDDStatusUpdate';
       intmsg.RefId__c='';
       intmsg.Status__c='New';
       intmsg.Req__c='{"REF_NO":"17","DOCDESC":"ALLOTMENT LETTER","DOCID":"235","APPLID":"589467","RECEIVED":"COMPLETED","RECEIVEDDATE":"2024-02-15T00:00:00","REMARKS":"Original Allotment Letter","ORIGINALS":"Y","TARGETDATE":"2024-02-15T00:00:00","VALIDTILLDATE":"2024-02-15T00:00:00","DATELASTUPDT":"2024-02-15T00:00:00","CRITICAL":"Critical"}';
       insert intmsg;
       
       
       
       List<IntgMsg__c> IntgMsglist=new List<IntgMsg__c>{intmsg};
           
           Test.Starttest();
       OTCPDDStatusCallbackResponseProcessor.process(IntgMsglist);
           Test.Stoptest();
   }
}