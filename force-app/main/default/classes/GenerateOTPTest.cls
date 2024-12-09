@isTest
public class GenerateOTPTest {
    
    @isTest
    public static void testGenerateOTP(){
        user u=TestDataFactory.UserData(true);
        lead l=TestDataFactory.LeadData(true,u.id);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/generateOTP';
        req.httpMethod = 'GET';
        req.addParameter('leadId',l.id);
        req.addParameter('mobileNumber','9999999999');
        
        RestContext.request = req;
        RestContext.response = res; 
       // Test.startTest();
        GenerateOTP.getOTP();
       // Test.stopTest();
        
    }
}