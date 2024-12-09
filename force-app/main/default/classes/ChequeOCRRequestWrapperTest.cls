@isTest
public class ChequeOCRRequestWrapperTest {
 static testMethod void testWrp()
    {
        ChequeOCRRequestWrapper wrp = new ChequeOCRRequestWrapper();
        wrp.fileB64 = 'test';
        ChequeOCRRequestWrapper wrp1 = new ChequeOCRRequestWrapper();
        wrp1=  ChequeOCRRequestWrapper.parse(JSON.serialize(wrp));
     
        system.Assert(true);
        system.assertEquals(wrp1.fileB64,wrp.fileB64);
       
    }
}