@isTest
public class PerfiosGenerateReportResponseWrapperTest {

    @isTest
    static void testParsingSuccess() {
        String json = '{"success": {}}';
        PerfiosGenerateReportResponseWrapper response = PerfiosGenerateReportResponseWrapper.parse(json);

        // Ensure that parsing success scenario works as expected
        System.assertNotEquals(null, response);
        System.assertNotEquals(null, response.success);
        System.assertEquals(null, response.error);
    }

    @isTest
    static void testParsingError() {
        String json = '{"error": {"code": "BadParameter", "message": "Signature is required but missing"}}';
        PerfiosGenerateReportResponseWrapper response = PerfiosGenerateReportResponseWrapper.parse(json);

        // Ensure that parsing error scenario works as expected
        System.assertNotEquals(null, response);
        System.assertNotEquals(null, response.error);
        System.assertEquals(null, response.success);

        // Check values in the error object
        System.assertEquals('BadParameter', response.error.code);
        System.assertEquals('Signature is required but missing', response.error.message);
    }

   /* @isTest
    static void testParsingNull() {
        String json = null;
        PerfiosGenerateReportResponseWrapper response = PerfiosGenerateReportResponseWrapper.parse(json);
        System.assertEquals(null, response);
    }*/
}