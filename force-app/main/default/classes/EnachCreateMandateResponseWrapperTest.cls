@isTest
public class EnachCreateMandateResponseWrapperTest {
	@IsTest
	public static void testParse() { 
        String jsonString = '{"id":"ENA240219111724324DGXJFEP2314XAP","mandate_id":"ENA240219111724324DGXJFEP2314XAP","state":"partial","type":"CREATE","bank_details":{"shared_with_bank":"test_bank@digio.in","bank_name":"YES BANK","state":"partial"},"created_at":"2024-02-19 11:17:24","mode":"api","service_provider_details":{"service_provider_name":"Fedfina","service_provider_utility_code":"NACHTEST0000000000","support_email":"abc@xyz.com","support_mobile":"9000000000","is_enabled_for_aadhaar_auth":true}}';
        EnachCreateMandateResponseWrapper obj = EnachCreateMandateResponseWrapper.parse(jsonString);
		System.assert(obj != null);
	}
    
    @IsTest
	public static void testParse1() { 
        String jsonString = '{"notify_customer":true,"mandate_type":"create","mandate_data":{"maximum_amount":"1700000.00","management_category":"L001","is_recurring":true,"instrument_type":"debit","frequency":"Monthly","first_collection_date":"2024-04-07","destination_bank_name":"BANK OF BARODA","destination_bank_id":"BARB0EXTGUR","customer_name":"KEYUR M SHAH","customer_account_type":"Savings","customer_account_number":"768862385"},"expire_in_days":"15","customer_identifier":"8896944363","corporate_config_id":"TSE210907145432984BYVA178CURG81K","auth_mode":"api"}';
        EnachCreateMandateRequestWrapper obj = EnachCreateMandateRequestWrapper.parse(jsonString);
		System.assert(obj != null);
	}
    
    @IsTest
	public static void testParse2() { 
        String jsonString = '{"entities":["api_mandate"],"payload":{"api_mandate":{"txn_timestamp":1535021979000,"txn_reject_reason":null,"umrn":"UMRN5821341491878546","auth_sub_mode":"debit","txn_reject_code":"000","current_status":"register_success","message_id":"MMI240219164058915LSVUZXPLIESFYK","id":"ENA240219163901646CIS8361V9C48AP","npci_txn_id":"8cff752e65c549f2b4e0906cd5e35d3a","others":{"scheme_ref_number":null,"customer_ref_number":null},"tags":null}},"created_at":1708341069000,"id":"WHN240219164109391TP58DFGOYSZJLF","event":"apimndt.destaccept"}';
        EnachStatusResponseWrapper obj = EnachStatusResponseWrapper.parse(jsonString);
		System.assert(obj != null);
	}
    
}