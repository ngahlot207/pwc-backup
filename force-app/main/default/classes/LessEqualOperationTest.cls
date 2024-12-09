@isTest
public class LessEqualOperationTest {

    @isTest
    static void testLessEqualOperation_IntegerDecimalListDecimal() {
        // Arrange
        Decimal a = 3.0;
        //List<String> bValues = new List<String>{'5.0', '6.0', '7.0'};
        String bValues = '5.0,6.0,7.0';
        BaseType aBaseType = new BaseType(a, BaseType.enumType.DECIMAL_TYPE);
        BaseType bBaseType = new BaseType(bValues, BaseType.enumType.LIST_DECIMAL);

        LessEqualOperation lessEqualOperation = new LessEqualOperation('<=');

        // Act
        Boolean result = lessEqualOperation.resolve(aBaseType, bBaseType);

        // Assert
        System.assertEquals(true, result);
    }

    @isTest
    static void testLessEqualOperation_IntegerDecimal() {
        // Arrange
        Decimal a = 3.0;
        Decimal b = 5.0;
        BaseType aBaseType = new BaseType(a, BaseType.enumType.DECIMAL_TYPE);
        BaseType bBaseType = new BaseType(b, BaseType.enumType.DECIMAL_TYPE);

        LessEqualOperation lessEqualOperation = new LessEqualOperation('<=');

        // Act
        Boolean result = lessEqualOperation.resolve(aBaseType, bBaseType);

        // Assert
        System.assertEquals(true, result);
    }

    @isTest
    static void testLessEqualOperation_IntegerInteger() {
        // Arrange
        Decimal a = 3.0;
        Decimal b = 5.0;
        BaseType aBaseType = new BaseType(a, BaseType.enumType.INTEGER_TYPE);
        BaseType bBaseType = new BaseType(b, BaseType.enumType.INTEGER_TYPE);

        LessEqualOperation lessEqualOperation = new LessEqualOperation('<=');

        // Act
        Boolean result = lessEqualOperation.resolve(aBaseType, bBaseType);

        // Assert
        System.assertEquals(true, result);
    }

    @isTest
    static void testLessEqualOperation_FailCase() {
        // Arrange
        Decimal a = 5.0;
       // List<String> bValues = new List<String>{'3.0', '4.0', '5.0'};
        String bValues = '2.0,3.0,4.0';
        BaseType aBaseType = new BaseType(a, BaseType.enumType.DECIMAL_TYPE);
        BaseType bBaseType = new BaseType(bValues, BaseType.enumType.LIST_DECIMAL);

        LessEqualOperation lessEqualOperation = new LessEqualOperation('<=');

        // Act 
        Boolean result = lessEqualOperation.resolve(aBaseType, bBaseType);

        // Assert
        System.assertEquals(false, result);
    }
}