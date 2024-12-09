@isTest
public class ApplicationLogWrapperTest {
    
    static testMethod void testWrp()
    {
        ApplicationLogWrapper wrp = new ApplicationLogWrapper();
        wrp.logMessage = 'test';
        wrp.logCode = '12345';
        //Test.startTest(); 
        ApplicationLogWrapper wrp1 = new ApplicationLogWrapper();
        wrp1=  ApplicationLogWrapper.parse(JSON.serialize(wrp));
       // Test.stopTest();
        system.Assert(true);
        
        system.assertEquals(wrp1.logMessage,wrp.logMessage);
        system.assertEquals(wrp1.logCode,wrp.logCode);
    }
    
}