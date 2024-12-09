@isTest
private class DynamicLWCDataTableControllerTest {

    @isTest
    static void testGetWrapperOfSObjectFieldColumnActionValues() {
        // Test data setup
        DynamicLWCDataTableController.RequiredParams params = new DynamicLWCDataTableController.RequiredParams();
        params.tableTitle = 'Test Table';
        params.query = 'SELECT Id, Name FROM Account WHERE Name = :nameParam';
        
        DynamicLWCDataTableController.DataTableColumns column1 = new DynamicLWCDataTableController.DataTableColumns();
        column1.label = 'Account ID';
        column1.fieldName = 'Id';
        column1.type = 'text';
        column1.editable = false;

        params.columnsData = new List<DynamicLWCDataTableController.DataTableColumns>{column1};

        DynamicLWCDataTableController.QueryParamWrapp param1 = new DynamicLWCDataTableController.QueryParamWrapp();
        param1.key = 'nameParam';
        param1.value = 'Test Account';

        params.queryParams = new List<DynamicLWCDataTableController.QueryParamWrapp>{param1};

        // Test the method with query parameters
        Test.startTest();
        DynamicLWCDataTableController.DataTableResponse resultWithParams = DynamicLWCDataTableController.getWrapperOfSObjectFieldColumnActionValues(params);
        

        Test.stopTest();

    }
}