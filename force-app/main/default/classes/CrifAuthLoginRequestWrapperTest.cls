@isTest
public class CrifAuthLoginRequestWrapperTest {
 static testMethod void testWrp()
    {
        CrifAuthLoginRequestWrapper wrp = new CrifAuthLoginRequestWrapper();
        wrp.userId = 'JWTUSER';
        wrp.password = 'Admin@123';
        wrp.domain = 'FEDFINA';
        wrp.mode='STRATEGYONE';
        //Test.startTest(); 
        CrifAuthLoginRequestWrapper wrp1 = new CrifAuthLoginRequestWrapper();
        wrp1=  CrifAuthLoginRequestWrapper.parse(JSON.serialize(wrp));
       // Test.stopTest();
        system.Assert(true);
        
        system.assertEquals(wrp1.userId,wrp.userId);
        system.assertEquals(wrp1.password,wrp.password);
    }

}