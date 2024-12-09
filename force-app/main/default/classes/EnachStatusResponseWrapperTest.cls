@isTest
public class EnachStatusResponseWrapperTest {

    @isTest
    static void testParse() {
        // Test data setup
        String json = '{"entities": ["entity1", "entity2"],"payload": {"api_mandate": {"txn_timestamp": "2024-02-20T12:00:00Z","txn_reject_reason": "Rejected",'+
                      '"umrn": "1234567890","auth_sub_mode": "OTP","txn_reject_code": "REJECT_001","current_status": "APPROVED","message_id": "789","id": "456",'+
                      '"npci_txn_id": "987","others": {"scheme_ref_number": "789123","customer_ref_number": "456789"},"tags": "tag1,tag2"}}},' +
                      '"created_at": "2024-02-20T12:30:00Z","id": "123","event": "STATUS_UPDATED"}';

        // Call the parse method
        EnachStatusResponseWrapper result = EnachStatusResponseWrapper.parse(json);

        // Add assertions based on the expected behavior of your code
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(2, result.entities.size(), 'Entities count should be 2');
        System.assertEquals('2024-02-20T12:00:00Z', result.payload.api_mandate.txn_timestamp, 'Txn Timestamp should match');
        System.assertEquals('Rejected', result.payload.api_mandate.txn_reject_reason, 'Txn Reject Reason should match');
        System.assertEquals('1234567890', result.payload.api_mandate.umrn, 'UMRN should match');
        // Add more assertions as needed
    }
}