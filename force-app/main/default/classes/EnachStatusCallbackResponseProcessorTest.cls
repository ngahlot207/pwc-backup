@isTest
public class EnachStatusCallbackResponseProcessorTest {
	 @isTest
    static void testProcessMethod() {
        
        LoanAppl__c LoanApp=TestDataFactory.createLoanApplication(true);
        Applicant__c app = TestDataFactory.createSingleApplicant(true,LoanApp.id);
        
        NACH__c nach=new NACH__c();
        nach.LoanAppl__c=LoanApp.Id;
        nach.Mandate_Id__c='ENA240307163115505DIZEDH4P9BPXAP';
        nach.UMRN__c='';
        insert nach;
        
        
        
         List<IntgMsg__c> intmsglist=new List<IntgMsg__c>();
        
        IntgMsg__c intmsg=new IntgMsg__c();
        intmsg.Name='Paytm UAT API';
        intmsg.Status__c='Processed';
        intmsg.Req__c='{"entities":["api_mandate"],"payload":{"api_mandate":{"txn_timestamp":1535021979000,"txn_reject_reason":null,"umrn":"UMRN1872131634333538","auth_sub_mode":"debit","txn_reject_code":"000","current_status":"register_success","message_id":"MMI240307163434953UCVQCLQHVOQJDG","id":"ENA240307163115505DIZEDH4P9BPXAP","npci_txn_id":"8cff752e65c549f2b4e0906cd5e35d3a","others":{"scheme_ref_number":null,"customer_ref_number":null},"tags":null}},"created_at":1709809501000,"id":"WHN240307163501070LEIXSRLUR624UC","event":"apimndt.destaccept"}';
        intmsg.IsActive__c=true;
        intmsg.Inbound__c=true;
        intmsglist.add(intmsg);
        
        insert intmsglist;
        
        Test.StartTest();
        EnachStatusCallbackResponseProcessor.process(intmsglist);
        Test.StopTest();
    }
}