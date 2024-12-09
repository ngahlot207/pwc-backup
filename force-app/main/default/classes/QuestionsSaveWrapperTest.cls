@isTest
public class QuestionsSaveWrapperTest {

    @isTest
    static void testQuestionsSaveWrapper() {
        // Create test data
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        // Create an instance of the QuestionsSaveWrapper class
        QuestionsSaveWrapper wrapper = new QuestionsSaveWrapper();
        wrapper.objectType = 'Account';
        wrapper.records = new List<SObject>{ testAccount };
        // Perform assertions
        System.assertEquals('Account', wrapper.objectType);
        System.assertEquals(1, wrapper.records.size());
    }
}