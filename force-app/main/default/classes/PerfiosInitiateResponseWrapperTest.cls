@isTest
public class PerfiosInitiateResponseWrapperTest {
    
 @isTest 
    Public static void PerfiosInitiateResponseWrapper_test(){
        String validJson = '{ "perfiosTransaction": { "perfiosTransactionId": "CBRZ1697718264591" } }';
        PerfiosInitiateResponseWrapper validResponse = PerfiosInitiateResponseWrapper.parse(validJson);
    }
}