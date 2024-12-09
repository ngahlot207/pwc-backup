@isTest
public class NotOperationTest {

    @isTest
    static void testNotOperation_IntegerDecimalListDecimal() {
        // Arrange
        Decimal a = 3.0;
        //List<Decimal> bValues = new List<Decimal>{5.0, 6.0, 7.0};
        String bValues = '5.0,6.0,7.0';
        BaseType aBaseType = new BaseType(a, BaseType.enumType.DECIMAL_TYPE);
        BaseType bBaseType = new BaseType(bValues, BaseType.enumType.LIST_DECIMAL);

        NotOperation notOperation = new NotOperation('!=');

        // Act
        Boolean result = notOperation.resolve(aBaseType, bBaseType);

        // Assert
        System.assertEquals(true, result);
    }

    @isTest
    static void testNotOperation_IntegerDecimal() {
        // Arrange
        Decimal a = 3.0;
        Decimal b = 5.0;
        BaseType aBaseType = new BaseType(a, BaseType.enumType.DECIMAL_TYPE);
        BaseType bBaseType = new BaseType(b, BaseType.enumType.DECIMAL_TYPE);

        NotOperation notOperation = new NotOperation('!=');

        // Act
        Boolean result = notOperation.resolve(aBaseType, bBaseType);

        // Assert
        System.assertEquals(true, result);
    }

    @isTest
    static void testNotOperation_IntegerInteger() {
        // Arrange
        Decimal a = 3.0;
        Decimal b = 5.0;
        BaseType aBaseType = new BaseType(a, BaseType.enumType.INTEGER_TYPE);
        BaseType bBaseType = new BaseType(b, BaseType.enumType.INTEGER_TYPE);

        NotOperation notOperation = new NotOperation('!=');

        // Act
        Boolean result = notOperation.resolve(aBaseType, bBaseType);

        // Assert
        System.assertEquals(true, result);
    }

    @isTest
    static void testNotOperation_FailCase() {
        // Arrange
        Decimal a = 3.0;
        Decimal b = 3.0;
        BaseType aBaseType = new BaseType(a, BaseType.enumType.DECIMAL_TYPE);
        BaseType bBaseType = new BaseType(b, BaseType.enumType.DECIMAL_TYPE);

        NotOperation notOperation = new NotOperation('!=');

        // Act
        Boolean result = notOperation.resolve(aBaseType, bBaseType);

        // Assert
        System.assertEquals(false, result);
    }
}