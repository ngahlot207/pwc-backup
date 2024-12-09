@isTest
private class OparenthesisOperationTest {
    
    @isTest
    static void testOparenthesisOperationResolve() {

        BaseType a = new BaseType(5.0, BaseType.enumType.DECIMAL_TYPE);
        BaseType b = new BaseType(3.0, BaseType.enumType.DECIMAL_TYPE);
        
        OparenthesisOperation oparenthesisOp = new OparenthesisOperation();
        
        Test.startTest();
        Boolean result = oparenthesisOp.resolve(a, b);
        Test.stopTest();
        
        System.assertEquals(null, result, 'Result should be null as the resolve method is not implemented');
    }
}