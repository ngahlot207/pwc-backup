@isTest
public class EnachCreateMandateRequestGeneratorTest {
    @testsetup
    static void testDataMethod(){
        LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
        Applicant__c appli =  TestDataFactory.createSingleApplicant(true,loan.id); 
       
        NACH__c objNach = new NACH__c();
        objNach.LoanAppl__c = loan.Id;
        objNach.Authorise__c = 'test';
        TriggerBase.bypass('NACH__c');
        Insert objNach;
        TriggerBase.clearBypass('NACH__c');
    }
    
    @isTest
    public static void testGenerateMethod() {
        List<IntgMsg__c> lstIntMsglist = new  List<IntgMsg__c>();
        List<NACH__c> nachObj = [Select Id,LoanAppl__c,Authorise__c FROM NACH__c WHERE Authorise__c = 'Test'];
        List<LoanAppl__c> loan =[SELECT Id FROM LoanAppl__c LIMIT 1];
        List<Applicant__c> lstapp  =[SELECT Id FROM Applicant__c LIMIT 1];
        
        List<IntgMsg__c> intMsglist =  TestDataFactory.createIntMsg(true, 'KYC OCR', lstapp[0].id, null);
        for(IntgMsg__c intmes : intMsglist){
            intmes.RefObj__c = 'NACH__c';
            intmes.RefId__c = nachObj[0].Id;
            lstIntMsglist.add(intmes);
        }
        
        String jsonString = '{"customer_identifier": "123456","auth_mode": "OTP","mandate_type": "Fixed","corporate_config_id": "789","notify_customer": true,"mandate_data": {"maximum_amount": "1000","instrument_type": "Bank","first_collection_date": "2024-01-10","is_recurring": true,"frequency": "Monthly","management_category": "General","customer_name": "John Doe","customer_account_number": "987654321","destination_bank_id": "456","destination_bank_name": "Bank of Example","customer_account_type": "Savings"},"expire_in_days": "30"}';
        //EnachCreateMandateRequestWrapper res = EnachCreateMandateRequestWrapper.parse(jsonString);
        
        String sampleJson = '{'+'"id": "12345",'+'"mandate_id": "M567",'+'"state": "Active",'+'"type": "Type1",'+'"bank_details": {'+'"shared_with_bank": "Yes",'+
                     '"bank_name": "ABC Bank",'+'"state": "California"'+'},'+'"created_at": "2024-01-05",'+'"mode": "Online",'+'"service_provider_details": {'+
                     '"service_provider_name": "ServiceCo",'+'"service_provider_utility_code": "SC123"'+'},'+'"details": "Mandate details",'+'"code": "200",'+'"message": "Mandate created successfully"'+'}';
        
        //EnachCreateMandateResponseWrapper res1 = EnachCreateMandateResponseWrapper.parse(sampleJson);   
        
        String json1 = '{"entities":["Entity1","Entity2"],"payload":{"api_mandate":{"txn_timestamp":"2022-01-01","txn_reject_reason":null,"umrn":"U1234567890","auth_sub_mode":"Online","txn_reject_code":null,"current_status":"Success","message_id":"M1234567890","id":"Mandate123","npci_txn_id":"NPCITransaction123","others":{"scheme_ref_number":"SchemeRef123","customer_ref_number":"CustomerRef123"},"tags":null}},"created_at":"2022-01-01T12:00:00Z","id":"123456","event":"MandateSuccessEvent"}';
        //EnachStatusResponseWrapper result = EnachStatusResponseWrapper.parse(json1);
        
        EnachCreateMandateRequestGenerator testGenerator = new EnachCreateMandateRequestGenerator();
        Test.startTest();
        testGenerator.generate(lstIntMsglist, 'TestService', 'TestProcessType');
        Test.stopTest();
        system.assert(!intMsglist.isEmpty(),'Integration message List Should not empty');
    }
}