@isTest
public class HunterTokenRequestParserTest {

    @isTest
    static void testParse() {
        // Create a JSON string for testing
        String json = '{"username": "testUser", "password": "testPassword", "client_id": "testClientId", "client_secret": "testClientSecret"}';
        // Call the parse method in the test
        HunterTokenRequestParser result = HunterTokenRequestParser.parse(json);

        // Perform assertions to verify the results
        System.assertEquals('testUser', result.username);
        System.assertEquals('testPassword', result.password);
        System.assertEquals('testClientId', result.client_id);
        System.assertEquals('testClientSecret', result.client_secret);

    }
}