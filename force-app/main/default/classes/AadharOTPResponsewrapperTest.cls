@isTest
private class AadharOTPResponsewrapperTest {
    @isTest
    static void testParseMethod() {
        // Arrange
        String sampleJson = TestDataFactory.getSampleAadharOTPResponsewrapperJSON();

        // Act
        AadharOTPResponsewrapper result = AadharOTPResponsewrapper.parse(sampleJson);

        // Assert
        System.assertNotEquals(null, result);
        System.assertEquals('success', result.status);
        // Add more assertions based on your specific requirements
    }

    // Add more test methods as needed
}