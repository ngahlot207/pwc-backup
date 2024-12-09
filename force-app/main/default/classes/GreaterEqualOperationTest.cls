@isTest
public class GreaterEqualOperationTest {

    @isTest
    static void testGreaterEqualOperation_IntegerDecimalListDecimal() {
        // Arrange
        Decimal a = 5.0;
        String bValues = '3.0,4.0,5.0';
        BaseType aBaseType = new BaseType(a, BaseType.enumType.DECIMAL_TYPE);
        BaseType bBaseType = new BaseType(bValues, BaseType.enumType.LIST_DECIMAL);

        GreaterEqualOperation greaterEqualOperation = new GreaterEqualOperation('>=');

        // Act
        Boolean result = greaterEqualOperation.resolve(aBaseType, bBaseType);

        // Assert
        System.assertEquals(true, result);
    }

    @isTest
    static void testGreaterEqualOperation_IntegerDecimal() {
        // Arrange
        Decimal a = 5.0;
        Decimal b = 3.0;
        BaseType aBaseType = new BaseType(a, BaseType.enumType.DECIMAL_TYPE);
        BaseType bBaseType = new BaseType(b, BaseType.enumType.DECIMAL_TYPE);

        GreaterEqualOperation greaterEqualOperation = new GreaterEqualOperation('>=');

        // Act
        Boolean result = greaterEqualOperation.resolve(aBaseType, bBaseType);

        // Assert
        System.assertEquals(true, result);
    }

    @isTest
    static void testGreaterEqualOperation_IntegerInteger() {
        // Arrange
        Decimal a = 5.0;
        Decimal b = 3.0;
        BaseType aBaseType = new BaseType(a, BaseType.enumType.INTEGER_TYPE);
        BaseType bBaseType = new BaseType(b, BaseType.enumType.INTEGER_TYPE);

        GreaterEqualOperation greaterEqualOperation = new GreaterEqualOperation('>=');

        // Act
        Boolean result = greaterEqualOperation.resolve(aBaseType, bBaseType);

        // Assert
        System.assertEquals(true, result);
    }

    @isTest
    static void testGreaterEqualOperation_FailCase() {
        // Arrange
        Decimal a = 3.0;
         String bValues = '5.0,6.0,7.0';
        BaseType aBaseType = new BaseType(a, BaseType.enumType.DECIMAL_TYPE);
        BaseType bBaseType = new BaseType(bValues, BaseType.enumType.LIST_DECIMAL);

        GreaterEqualOperation greaterEqualOperation = new GreaterEqualOperation('>=');

        // Act
        Boolean result = greaterEqualOperation.resolve(aBaseType, bBaseType);

        // Assert
        System.assertEquals(false, result);
    }
}