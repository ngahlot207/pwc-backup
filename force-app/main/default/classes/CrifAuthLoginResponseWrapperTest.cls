@isTest
public class CrifAuthLoginResponseWrapperTest {
 static testMethod void testWrp()
    {
        CrifAuthLoginResponseWrapper wrp = new CrifAuthLoginResponseWrapper();
        wrp.access_token = 'JWTUSER';
        wrp.token_type = 'Bearer';
        wrp.expires_in = 123456;
        wrp.timestamp='2023-10-04T10:01:59.403+02:00';
        wrp.status = 401;
        wrp.error = 'Unauthorized';
        wrp.message = 'Admin@123';
        wrp.path = 'JWTUSER';
        wrp.reason = 'Admin@123';
        wrp.code = 'Admin@123';
        //Test.startTest(); 
        CrifAuthLoginResponseWrapper wrp1 = new CrifAuthLoginResponseWrapper();
        wrp1=  CrifAuthLoginResponseWrapper.parse(JSON.serialize(wrp));
       // Test.stopTest();
        system.Assert(true);
        
        system.assertEquals(wrp1.token_type,wrp.token_type);
        system.assertEquals(wrp1.timestamp,wrp.timestamp);
    }

}