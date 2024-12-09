@isTest
public class PaytmResponseWrapperTest {

    @isTest
    static void testParseMethod() {
        // Create sample data using Test Data Factory
        TestDataFactory.PaytmResponseWrapperTestData testData = TestDataFactory.createPaytmResponseWrapperTestData();

        // Call the parse method and assert the values
        PaytmResponseWrapper parsedResponse = PaytmResponseWrapper.parse(testData.jsonString);

        // Assert Head values
        System.assertEquals(testData.version, parsedResponse.head.version);
        System.assertEquals(testData.timestamp, parsedResponse.head.timestamp);
        System.assertEquals(testData.channelId, parsedResponse.head.channelId);
        System.assertEquals(testData.tokenType, parsedResponse.head.tokenType);
        System.assertEquals(testData.clientId, parsedResponse.head.clientId);

        // Assert Body values
        System.assertEquals(testData.linkId, parsedResponse.body.linkId);
        System.assertEquals(testData.linkType, parsedResponse.body.linkType);
        System.assertEquals(testData.longUrl, parsedResponse.body.longUrl);
        System.assertEquals(testData.shortUrl, parsedResponse.body.shortUrl);
        System.assertEquals(testData.expiryDate, parsedResponse.body.expiryDate);
        System.assertEquals(testData.isActive, parsedResponse.body.isActive);
        System.assertEquals(testData.merchantHtml, parsedResponse.body.merchantHtml);
        System.assertEquals(testData.createdDate, parsedResponse.body.createdDate);

        // Assert NotificationDetails values
       // TestDataFactory.PaytmResponseWrapperTestData.NotificationDetailsTestData notificationTestData = testData.notificationDetails.get(0);
        PaytmResponseWrapper.NotificationDetails parsedNotificationDetails = parsedResponse.body.notificationDetails[0];

       // System.assertEquals(notificationTestData.customerName, parsedNotificationDetails.customerName);
       // System.assertEquals(notificationTestData.contact, parsedNotificationDetails.contact);
       // System.assertEquals(notificationTestData.notifyStatus, parsedNotificationDetails.notifyStatus);
       // System.assertEquals(notificationTestData.timestamp, parsedNotificationDetails.timestamp);

        // Assert ResultInfo values
        System.assertEquals(testData.resultInfo.resultStatus, parsedResponse.body.resultInfo.resultStatus);
        System.assertEquals(testData.resultInfo.resultCode, parsedResponse.body.resultInfo.resultCode);
        System.assertEquals(testData.resultInfo.resultMessage, parsedResponse.body.resultInfo.resultMessage);

        // Assert additional Body values
        System.assertEquals(testData.linkOrderId, parsedResponse.body.linkOrderId);
    }
}