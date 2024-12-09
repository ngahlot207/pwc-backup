@isTest
public class PaytmRequestWrapperTest {

    @isTest
    static void testParseMethod() {
        // Create sample data using Test Data Factory
        TestDataFactory.PaytmRequestWrapperTestData testData = TestDataFactory.createPaytmRequestWrapperTestData();

        // Call the parse method and assert the values
        PaytmRequestWrapper parsedRequest = PaytmRequestWrapper.parse(testData.jsonString);

        // Assert Head values
        System.assertEquals(testData.tokenType, parsedRequest.head.tokenType);
        System.assertEquals(testData.signature, parsedRequest.head.signature);

        // Assert Body values
        System.assertEquals(testData.mid, parsedRequest.body.mid);
        System.assertEquals(testData.linkType, parsedRequest.body.linkType);
        System.assertEquals(testData.linkDescription, parsedRequest.body.linkDescription);
        System.assertEquals(testData.linkName, parsedRequest.body.linkName);
        System.assertEquals(testData.linkOrderId, parsedRequest.body.linkOrderId);
        System.assertEquals(testData.amount, parsedRequest.body.amount);
    }
}