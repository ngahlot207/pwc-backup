@isTest
public class CreateLeadControllerTest {  
    @isTest
    static void testGenerateOTP() {
        // Test data setup
        Lead testLead = new Lead(LastName = 'Test Lead', MobilePhone = '1234567890');
        insert testLead;
         
        // Call the method
      //  Test.startTest();
        List<String> otpResult = CreateLeadController.generateOTP(testLead.Id, testLead.MobilePhone);
      //  Test.stopTest();
    }
    
    @isTest
    static void testUpdateLead() {
        // Test data setup
        Lead testLead = new Lead(LastName = 'Test Lead');
        insert testLead;
        testLead.Disposition_Status__c = 'Customer not contactable';
        
        // Call the method
       // Test.startTest();
        Lead updatedLead = CreateLeadController.updateLead(testLead);
      //  Test.stopTest();
    }
    @isTest
    static void testUpdateLead1() {
        // Test data setup
        Lead testLead = new Lead(LastName = 'Test Lead');
        insert testLead;
        testLead.Disposition_Status__c = 'Lead converted';
        
        // Call the method
      //  Test.startTest();
        Lead updatedLead = CreateLeadController.updateLead(testLead);
      //  Test.stopTest();
    }
    
    @isTest
    static void testUpdateLead2() {
        // Test data setup
        Lead testLead = new Lead(LastName = 'Test Lead');
        insert testLead;
        testLead.Disposition_Status__c = 'Lead closed';
        
        // Call the method
      //  Test.startTest();
        Lead updatedLead = CreateLeadController.updateLead(testLead);
       // Test.stopTest();
    }
    
    @isTest
    static void testUpdateLead3() {
        // Test data setup
        Lead testLead = new Lead(LastName = 'Test Lead');
        insert testLead;
        testLead.Disposition_Status__c = 'XYZ';
        
        // Call the method
      //  Test.startTest();
        Lead updatedLead = CreateLeadController.updateLead(testLead);
       // Test.stopTest();
    }
    @isTest
    static void testUpdateMaxLimitReached() {
        // Test data setup
        Lead testLead = new Lead(LastName = 'Test Lead');
        insert testLead;
        
        // Call the method
       // Test.startTest();
        Lead updatedLead = CreateLeadController.updateMaxLimitReached(testLead);
      //  Test.stopTest();
    }
    
    @isTest
    static void testGetLeadData() {
        // Test data setup
        Lead testLead = new Lead(LastName = 'Test Lead', MobilePhone = '1234567890');
        insert testLead;
        
        // Call the method
       // Test.startTest();
        Lead resultLead = CreateLeadController.getLeadData(testLead.Id);
      //  Test.stopTest();
        
    }
    
    @isTest
    static void testIsMobileNumberVerified() {
        // Test data setup
        Lead testLead = new Lead(LastName = 'Test Lead', MobilePhone = '1234567890');
        insert testLead;
        
        // Call the method
     //   Test.startTest();
        boolean isVerified = CreateLeadController.isMobileNumberVerified(testLead.MobilePhone, testLead.Id);
      //  Test.stopTest();
        
    }
    
    @isTest
    static void testGetUploadedFiles() {
        // Test data setup
        Lead testLead = new Lead(LastName = 'Test Lead');
        insert testLead;
        
        String contentBody = 'Test Content';
        Blob contentBlob = Blob.valueOf(contentBody);
        
        ContentVersion testContentVersion = new ContentVersion(
            Title = 'Test File',
            PathOnClient = 'TestFile.txt',
            VersionData = contentBlob,
            IsMajorVersion = true,
            FirstPublishLocationId = testLead.Id
        );
        insert testContentVersion;
        
        // Call the method
      //  Test.startTest();
        List<ContentDocument> documents = CreateLeadController.getUploadedFiles(testLead.Id);
      //  Test.stopTest();
    }

    @isTest
    static void testOtpVerifiedSuccess() {
        // Test data setup
        Lead testLead = new Lead(LastName = 'Test Lead', MobilePhone = '1234567890');
        insert testLead;
        
        Task taskRec = new Task(Type = 'SMS Task',Subject ='SMS Task',whoId = testLead.Id, OTP__c = '123456',MobNum__c = testLead.MobilePhone);
        insert taskRec;
        // Call the method
       // Test.startTest();
        String returnMsg = CreateLeadController.validateOtp(taskRec.Id,'123456');
      //  Test.stopTest();
        
    }
    @isTest
    static void testOtpVerifiedFailure() {
        // Test data setup
        Lead testLead = new Lead(LastName = 'Test Lead',MobilePhone  = '1234567890');
        insert testLead;
        
        Task taskRec = new Task(Type = 'SMS Task',Subject ='SMS Task',whoId = testLead.Id, OTP__c = '123456',MobNum__c = testLead.MobilePhone);
        insert taskRec;
        // Call the method
       // Test.startTest();
        String returnMsg = CreateLeadController.validateOtp(taskRec.Id,'123458');
      //  Test.stopTest();
        
    }
    
}