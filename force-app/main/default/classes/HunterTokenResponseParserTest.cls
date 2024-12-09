@isTest
public class HunterTokenResponseParserTest {
    @isTest
	public static void testTokenResponseParser() {
        HunterTokenResponseParser tokenResponse = new HunterTokenResponseParser();

        // Set values for testing
        tokenResponse.issued_at = '1234567890';
        tokenResponse.expires_in = '3600';
        tokenResponse.token_type = 'Bearer';
        tokenResponse.access_token = 'access_token_value';
        tokenResponse.refresh_token = 'refresh_token_value';
        String jsonSTR = JSON.serialize(tokenResponse);
        String jsonSTR1 = '{"issued_at":"1707824393","expires_in":"1800","token_type":"Bearer","access_token":"eyJraWQiOiJJSmpTMXJQQjdJODBHWjgybmNsSlZPQkF3V3B3ZTVYblNKZUdSZHdpcEY5IiwidHlwIjoiSldUIiwiYWxnIjoiUlMyNTYifQ.eyJzdWIiOiJyYWprdW1hci51cGFkaHlheUBmZWRmaW5hLmNvbSIsIkVtYWlsIjpudWxsLCJGaXJzdE5hbWUiOm51bGwsImlzcyI6IkVYUEVSSUFOIiwiTGFzdE5hbWUiOm51bGwsImV4cCI6MTcwNzgyNjE5MywiaWF0IjoxNzA3ODI0MzkzLCJqdGkiOiIyZWQ4NjQ2Ny1mNGM0LTQ0YzMtOTVjYy0wMmRhNDBjOWI3N2QifQ.HkHYaHAVDSNys4f4u0H0SdN4xdcoLjeWOVmKoTcezLBbft4NQBdPJLQmonAiZBcZXm0ox45Y2w_sbykjDTyXZfgWSAkNDDEBlIpcljSx3ooLIF3U3rKbOQnsD-ZRz3DhiVhqkEvtyJM7WfQrL1huH9o8eUcZpFM29Ym35iyjMZAOiftxzmIp0dDRewdTAwo7albnmPretAGtCNwXqXpjaGh5Sic47fOLouEfmT6qqRc6YPqyaxFM6Mkl2x139uykl0N8i91IPuBW_gkLP5bHBAvdnD5Q0SzZh0mRAdQNvlXRxUNQ44oPbs-8SjVN6CkReqgO-Q08T18rsY6V1fQ9aA","refresh_token":"y2GQutAId9hZnaDpl4uSvmst6c6WoVG8"}';
        HunterTokenResponseParser wrp1 = new HunterTokenResponseParser();
        wrp1 = HunterTokenResponseParser.parse(jsonSTR1);

        // Test the values
        System.assertEquals('1234567890', tokenResponse.issued_at);
        System.assertEquals('3600', tokenResponse.expires_in);
        System.assertEquals('Bearer', tokenResponse.token_type);
        System.assertEquals('access_token_value', tokenResponse.access_token);
        System.assertEquals('refresh_token_value', tokenResponse.refresh_token);
    }
}