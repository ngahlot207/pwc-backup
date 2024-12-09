@isTest
private class LightningLoginFormControllerTest {
    
    @isTest
    static void testLogin() {
        // Test data
        String username = 'test@example.com';
        String password = 'password123';
        String startUrl = '/home';
        
        // Call the method
        Test.startTest();
        String result = LightningLoginFormController.login(username, password, startUrl);
        Test.stopTest();
        
        System.assertEquals(null, result, 'Login should be successful with valid credentials');
    }
    
    @isTest
    static void testGetIsUsernamePasswordEnabled() {
        Boolean result = LightningLoginFormController.getIsUsernamePasswordEnabled();
    }
    
    @isTest
    static void testgetIsSelfRegistrationEnabled() {
        Boolean result = LightningLoginFormController.getIsSelfRegistrationEnabled();
    }
    
    @isTest
    static void testgetSelfRegistrationUrl() {
        String result = LightningLoginFormController.getSelfRegistrationUrl();
    }
    
    @isTest
    static void testgetForgotPasswordUrl() {
        String result = LightningLoginFormController.getForgotPasswordUrl();
    }
    
    @isTest
    static void testSetExperienceId() {
        String expId = 'exp123';
        
        // Call the method
        Test.startTest();
        String result = LightningLoginFormController.setExperienceId(expId);
        Test.stopTest();
    }
}