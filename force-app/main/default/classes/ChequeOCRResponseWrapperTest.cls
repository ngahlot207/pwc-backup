@isTest
public class ChequeOCRResponseWrapperTest {
 static testMethod void testWrp()
    {
        ChequeOCRResponseWrapper wrp = new ChequeOCRResponseWrapper();
        wrp.requestId = 'test';
        wrp.statusCode = 123456;
        ChequeOCRResponseWrapper wrp1 = new ChequeOCRResponseWrapper();
        wrp1=  ChequeOCRResponseWrapper.parse(JSON.serialize(wrp));
     
        system.Assert(true);
        system.assertEquals(wrp1.requestId,wrp.requestId);
        system.assertEquals(wrp1.statusCode,wrp.statusCode);
       
    }
}