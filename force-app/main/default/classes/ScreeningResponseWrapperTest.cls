@isTest
private class ScreeningResponseWrapperTest {

    @isTest
    static void parse_ValidJson_ReturnsScreeningResponseWrapper() {
        // Arrange
        String json = '{"Result": "Success", "Message": "Screening passed"}';

        // Act
        ScreeningResponseWrapper result = ScreeningResponseWrapper.parse(json);

        // Assert
        System.assertEquals('Success', result.Result, 'Result should be "Success"');
        System.assertEquals('Screening passed', result.Message, 'Message should be "Screening passed"');
    }


}