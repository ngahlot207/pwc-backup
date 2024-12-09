@isTest
public class AadharMaskingWrapperTest {

    @isTest
   public static void testParserMethod() {
        
        String jsonrequest = '{"uid":"testUid","slk":"testSlk","rrn":"testRrn","env":"testEnv","lat":"testLat","lon":"testLon","devid":"testDevid","refr":"testRefr","sertype":"testSertype","ver":"testVer","txnmode":"testTxnmode","file":"testFile"}';
         
       String jsonresponse = '{"respcode":"testRespcode","respdesc":"testRespdesc","txnid":"testTxnid","rrn":"testRrn","refr":"testRefr","file":"testFile","txnmode":"testTxnmode","timespan":"testTimespan","aadhaars":"testAadhaars"}';
        
        AadharMaskingRequestWrapper wrapperrequest = AadharMaskingRequestWrapper.parser(jsonrequest);
        AadharMaskingResponseWrapper wrapperresponse = AadharMaskingResponseWrapper.praser(jsonresponse);

       
    }
}