@isTest
public class PlatFormEventWrapperClassTest {
    static testMethod void testWrp()
    {
        PlatFormEventWrapperClass wrp = new PlatFormEventWrapperClass();
        wrp.Status = '1233456';
        wrp.ServiceName = 'Test';
        wrp.loanAppId = '1234567';
        wrp.appId = '2345456';
        
        
       // Test.startTest();
        PlatFormEventWrapperClass wrp1 = new PlatFormEventWrapperClass();
        wrp1 = PlatFormEventWrapperClass.parse(JSON.serialize(wrp));
       // Test.stopTest();
        system.Assert(true);
        system.assertEquals(wrp1.Status,wrp.Status);
        system.assertEquals(wrp1.ServiceName,wrp.ServiceName);
        system.assertEquals(wrp1.ServiceName,wrp.ServiceName);
        system.assertEquals(wrp1.appId,wrp.appId);
    }
}