@istest
public class GenereateCheckSumTest {
    
    @isTest
    static void testGenerateChecksum() {
        
        String apiKey = 'M@SObVs5FXw6dlLJ';
        String mid = 'FEDBAN72272366692608';
        String linkType = 'FIXED';
        Decimal amount = 100.00;
        String linkDescription = 'Test Payment';
        String linkName = 'Test';
        
        String expectedParams = '{"mid":"' + mid + '","linkType":"' + linkType + '","amount":"' + amount + '","linkDescription":"' + linkDescription + '","linkName":"' + linkName + '"}';
   
        Genereatechecksum.genereatechecksum();
    
    }

}