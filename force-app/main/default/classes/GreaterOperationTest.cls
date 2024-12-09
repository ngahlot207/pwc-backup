@isTest
private class GreaterOperationTest {
    
    @isTest
    static void testGreaterOperationResolve() {
        // Create test data
        Decimal aValue = 5.0;
        Decimal bValue = 3.0;
        
        // Create instances of BaseType for testing
        BaseType a = new BaseType(aValue, BaseType.enumType.DECIMAL_TYPE);
        BaseType b = new BaseType(bValue, BaseType.enumType.DECIMAL_TYPE);
        
        // Create an instance of GreaterOperation
        GreaterOperation greaterOp = new GreaterOperation('>');
        
        // Test resolve method
        Test.startTest();
        Boolean result = greaterOp.resolve(a, b);
        Test.stopTest();
        
        // Verify the expected result
        System.assertEquals(true, result, 'Result should be true when a > b');
    }
    
    @isTest
    static void testGreaterOperationWithListResolve() {
        // Create test data
        Decimal aValue = 5.0;
        String bListString = '3.0,4.0,2.0';
        
        // Create instances of BaseType for testing
        BaseType a = new BaseType(aValue, BaseType.enumType.DECIMAL_TYPE);
        BaseType b = new BaseType(bListString, BaseType.enumType.LIST_DECIMAL);
        
        // Create an instance of GreaterOperation
        GreaterOperation greaterOp = new GreaterOperation('>');
        
        // Test resolve method with a list
        Test.startTest();
        Boolean result = greaterOp.resolve(a, b);
        Test.stopTest();
        
        // Verify the expected result
        System.assertEquals(true, result, 'Result should be true when a > any element in the list b');
    }
}