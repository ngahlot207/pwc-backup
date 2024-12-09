@isTest
public class CparenthesisOperationTest {
 @isTest
 static void testResolve() {
   // Create test data
Decimal aValue = 5.0;
Decimal bValue = 3.0;
// Create instances of BaseType for testing
BaseType a = new BaseType(aValue, BaseType.enumType.DECIMAL_TYPE);
BaseType b = new BaseType(bValue, BaseType.enumType.DECIMAL_TYPE);
   CparenthesisOperation cparenthesisOperation = new CparenthesisOperation();
   System.assertEquals(null, cparenthesisOperation.resolve(a,b));
}
}