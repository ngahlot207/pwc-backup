@isTest
public class ValidateOTPTest {
    
    @isTest
    public static void testValidateOTP(){
       
        Lead testLead = new Lead(LastName = 'Test Lead',MobilePhone  = '1234567890');
        insert testLead;
        
        Task taskRec = new Task(Type = 'SMS Task',Subject ='SMS Task',whoId = testLead.Id, OTP__c = '123456',MobNum__c = testLead.MobilePhone);
        insert taskRec;
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/validateOTP';
        req.httpMethod = 'GET';
        req.addParameter('taskId',taskRec.id);
        req.addParameter('otp','123456');
        
        RestContext.request = req;
        RestContext.response = res; 
       // Test.startTest();
       ValidateOTP.valOTP();
       // Test.stopTest();
        
    }
}