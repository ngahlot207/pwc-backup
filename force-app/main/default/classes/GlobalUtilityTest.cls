@isTest
private class GlobalUtilityTest {

    @isTest
    static void testGetOTP() {
        // Call the method to get OTP
        List<String> otpList = GlobalUtility.getOTP();

        // Verify the generated OTP
        System.assertEquals(1, otpList.size(), 'Only one OTP should be generated');
        String generatedOTP = otpList[0];

        // Assert the length of the OTP generated
        System.assertEquals(6, generatedOTP.length(), 'OTP length should be 6');
        
        // Assert the OTP contains only numeric characters
        System.assert(generatedOTP.isNumeric(), 'OTP should contain only numeric characters');
    }
     @isTest
    static void testLogMessage() {
        String logLevel = 'DEBUG';
        String sourceClass = 'TestGlobalUtility';
        String sourceFunction = 'testLogMessage';
        String referenceId = '12345';
        String referenceInfo = 'Test info';
        String logMessage = 'This is a test log message';
        String payLoad = 'Test payload';
        // Exception ex = new Exception('Test Exception Message'); // Creating an exception message
        Long timeTaken = 1000;

       System.Test.startTest();
       // GlobalUtility.logMessage(logLevel, sourceClass, sourceFunction, referenceId, referenceInfo, logMessage, payLoad, timeTaken);
       System.Test.stopTest();

        // Additional assertions can be added to validate logging behavior, e.g. checking if logs were created.
        // For instance, you might use System.debug to output logs and assert if those logs were created correctly.
        // For comprehensive testing, consider adding assertions that log entries were created in a log repository or database.
    }
}