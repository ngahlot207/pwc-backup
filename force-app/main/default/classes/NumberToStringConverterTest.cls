@isTest
private class NumberToStringConverterTest { 

    @isTest
    static void testConvertToWordsPositive() { 
        System.assertEquals('Zero', NumberToStringConverter.convertToWords(0));
        System.assertEquals('One Rupees', NumberToStringConverter.convertToWords(1));
        System.assertEquals('Fifteen Rupees', NumberToStringConverter.convertToWords(15));
        System.assertEquals('One Hundred Rupees', NumberToStringConverter.convertToWords(100));
        System.assertEquals('Five Thousand Four Hundred Twenty Three Rupees', NumberToStringConverter.convertToWords(5423));
        System.assertEquals('Two Lakh Thirty Thousand Five Hundred Sixty Seven Rupees', NumberToStringConverter.convertToWords(230567));
        System.assertEquals('Three Crore Forty Five Lakh Sixty Seven Thousand Eight Hundred Ninety Rupees', NumberToStringConverter.convertToWords(34567890));
    }

    @isTest
    static void testConvertToWordsNegative() {         
        System.assertNotEquals('Two Rupees', NumberToStringConverter.convertToWords(3));
        System.assertNotEquals('Forty Rupees', NumberToStringConverter.convertToWords(42));
        System.assertNotEquals('Two Thousand Rupees', NumberToStringConverter.convertToWords(1000));
        System.assertNotEquals('One Thousand Rupees', NumberToStringConverter.convertToWords(10000));
        System.assertNotEquals('Two Lakh Rupees', NumberToStringConverter.convertToWords(100000));
        System.assertNotEquals('Two Crore Rupees', NumberToStringConverter.convertToWords(10000000));
    }
}