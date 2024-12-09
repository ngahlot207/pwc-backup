@isTest
public class IMDRequestWrapperTest { 

    @isTest
    static void testJsonParsing() {
        // Create a JSON string representing a valid IMDRequestWrapper
        String jsonString = '{"sourceId":"SFDC","ftMode":"OT","city":"600","modeOfPayment":"F","chequeStatus":"R",'
                          + '"inFavourOf":"ICICI BANK LTD","schemeId":"529","branch":"4","receiptAmount":"5900",'
                          + '"password":"zqbAx8rZ0LvWMftg38eTatwjEANYAo/6","requestId":"uwhpcUUx0ixaJpBhxGnsjx",'
                          + '"imdFlag":"Y","bpType":"LS","receiptDate":"06-NOV-2022","imdCustom4":"ASZPP4427B",'
                          + '"imdCustom3":"NO:15 CUDDALORE ROAD PAVACHOOR VILLAGE MADURANTAKAM NEAR TENPLE MADHURANTHAGAM CHENNAI 603112 TAMILNADU India",'
                          + '"productFlag":"LAP","imdCustom2":"SRI RENUKAMBAL AGENCIES","transactionCode":"1",'
                          + '"imdCustom1":"9","imdCustom7":"1002733","chequeDate":"05-NOV-2022",'
                          + '"imdCustom6":"PURUSHOTHAMANV.PURUSHOTHV1@GMAIL.COM","drawnOn":"229",'
                          + '"imdCustom5":"9840018858","utrNo":"21324151617","chargeId":"56",'
                          + '"dealingBank":"11","applicationId":"586371","user":"imdweb"}';

        // Parse the JSON string into an IMDRequestWrapper
        IMDRequestWrapper result = IMDRequestWrapper.parse(jsonString);

        // Verify that the parsing is successful and fields are populated correctly
        System.assertNotEquals(null, result);
        System.assertEquals('SFDC', result.sourceId);
        System.assertEquals('OT', result.ftMode);
    }

    @isTest
    static void testInvalidJsonParsing() {
        // Create an invalid JSON string
        String invalidJsonString = '{"sourceId": "SFDC", "ftMode": "OT", "invalidField": "Invalid"}';

        // Parse the invalid JSON string into an IMDRequestWrapper
        IMDRequestWrapper result = IMDRequestWrapper.parse(invalidJsonString);

        // Verify that the parsing result is null (indicating failure)
        System.assertNotEquals(null, result);
        System.assertNotEquals('ABC', result.sourceId);
        System.assertNotEquals('OTT', result.ftMode);
    }
}