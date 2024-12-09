@isTest
public class CompositePaymentRequestWrapperTest {

    @isTest
    static void testParse() {
        // Create a sample JSON string for testing
        String json = '{"localTxnDtTime": "20230123152219", "beneAccNo": "50100242035033", "beneIFSC": "HDFC0001265", "amount": "1", "tranRefNo": "230123152149032", "paymentRef": "230123152149032", "senderName": "NARAYAN PUNDLIK GAWADE", "mobile": "8369265704", "retailerCode": "rcode", "passCode": "cd5cd91514e343568613260edcbdba40", "bcID": "IBCFED01286", "crpId": "FEDBANKF30032017", "crpUsr": "SOUGATAR", "aggrId": "CUST0946"}';

        // Call the parse method
        CompositePaymentRequestWrapper result = CompositePaymentRequestWrapper.parse(json);

        // Add assertions to verify the parsed values
        System.assertEquals('20230123152219', result.localTxnDtTime, 'localTxnDtTime should match');
        System.assertEquals('50100242035033', result.beneAccNo, 'beneAccNo should match');
        System.assertEquals('HDFC0001265', result.beneIFSC, 'beneIFSC should match');
        System.assertEquals('1', result.amount, 'amount should match');
        System.assertEquals('230123152149032', result.tranRefNo, 'tranRefNo should match');
        System.assertEquals('230123152149032', result.paymentRef, 'paymentRef should match');
        System.assertEquals('NARAYAN PUNDLIK GAWADE', result.senderName, 'senderName should match');
        System.assertEquals('8369265704', result.mobile, 'mobile should match');
        System.assertEquals('rcode', result.retailerCode, 'retailerCode should match');
        System.assertEquals('cd5cd91514e343568613260edcbdba40', result.passCode, 'passCode should match');
        System.assertEquals('IBCFED01286', result.bcID, 'bcID should match');
        System.assertEquals('FEDBANKF30032017', result.crpId, 'crpId should match');
        System.assertEquals('SOUGATAR', result.crpUsr, 'crpUsr should match');
        System.assertEquals('CUST0946', result.aggrId, 'aggrId should match');
    }
}