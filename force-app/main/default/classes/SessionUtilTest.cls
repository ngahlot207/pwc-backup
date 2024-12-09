@isTest
public class SessionUtilTest {
	@isTest 
    static void testgetSessionId(){
        string testing=SessionUtil.getSessionId();
        system.debug('testing'+testing);
    }
}