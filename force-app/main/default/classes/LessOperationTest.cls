@isTest
public class LessOperationTest {

 @isTest
 public static void testResolve() {
   // Create test data
Decimal aValue = 5.0;
Decimal bValue = 3.0;
// Create instances of BaseType for testing
BaseType a = new BaseType(aValue, BaseType.enumType.DECIMAL_TYPE);
BaseType b = new BaseType(bValue, BaseType.enumType.DECIMAL_TYPE);
    lessOperation ls = new lessOperation('>');
   ls.resolve(a,b);
}
     @isTest
 public static void testResolve1() {
   // Create test data
Decimal aValue = 5.0;
String bValue = '3.0,4.0';
// Create instances of BaseType for testing
BaseType a = new BaseType(aValue, BaseType.enumType.DECIMAL_TYPE);
BaseType b = new BaseType(bValue, BaseType.enumType.LIST_DECIMAL);
    lessOperation ls = new lessOperation('>');
   ls.resolve(a,b);
}

}