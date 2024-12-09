@isTest
public class RequiredFieldsUtilTest {
	@isTest
    static void testGetRequiredFields() {
        // Test case 1: Valid object API name
        List<String> requiredFields1 = RequiredFieldsUtil.getRequiredFields('Account');
        
        System.assertEquals(5, requiredFields1.size(), 'Expected number of required fields for Account is 2');
        
        }
}