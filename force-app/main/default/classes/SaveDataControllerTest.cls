@isTest
public class SaveDataControllerTest {
    
     @isTest
    static void testSaveDataWithValidJson() {
        String jsonData = '[{"objApiName":"Account","recordId":null},{"objApiName":"Contact","recordId":null}]';

        Test.startTest();
        SaveDataController.saveData(jsonData);
        Test.stopTest();

    }

    @isTest
    static void testSaveDataWithNullJson() {
        Test.startTest();
        SaveDataController.saveData(null);
        Test.stopTest();
    }

    
}