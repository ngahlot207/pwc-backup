@isTest
public class OcrDLServiceWrapperClassTest {
    static testMethod void testWrp()
    {
        
        OcrDLServiceWrapperClass wrp = new OcrDLServiceWrapperClass();
        wrp.statusCode = 12345;
        wrp.requestId = '12345';
        
        OcrDLServiceWrapperClass.Details wrpRes = new OcrDLServiceWrapperClass.Details();
        OcrDLServiceWrapperClass.Dob wrpDat = new OcrDLServiceWrapperClass.Dob();
        wrpDat.value = '123456';
        wrpDat.conf = '123456';
        wrpRes.name = wrpDat;
        
        OcrDLServiceWrapperClass.Result wrpName = new OcrDLServiceWrapperClass.Result();
        wrpName.type = 'Test';  
        wrpName.details = wrpRes;
        
        list <OcrDLServiceWrapperClass.Result> wrpResultList = new list <OcrDLServiceWrapperClass.Result>();
        OcrDLServiceWrapperClass.Result wrpResult = new OcrDLServiceWrapperClass.Result();
        wrpResult.details = wrpRes;
        wrpResultList.add(wrpResult);
        
        wrp.result = wrpResultList;
       // Test.startTest();
        OcrDLServiceWrapperClass wrp1 = new OcrDLServiceWrapperClass();
        wrp1 = OcrDLServiceWrapperClass.parse(JSON.serialize(wrp));
      //  Test.stopTest();
        
        system.Assert(true);
        system.assertEquals(wrp1.requestId, wrp.requestId);
        system.assertEquals(wrp1.statusCode, wrp.statusCode);
        
        
    }
    
}