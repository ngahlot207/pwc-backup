@isTest
public class AddTrancheDisRequestWrapperTestClass {
    @isTest
    static void testParseMethod() {
        // Create sample JSON data to deserialize
        String sampleJSON = '{ "unqRequestId": "12345", "sourceSystem": "SystemX", "userId": "user123", "password": "pass456", ' +
                            '"disbursalDetail": { "applicationID": "APP001", "agreementNo": "AGREEMENT123", "disbursalAmount": "5000", ' +
                            '"disbursalDate": "2024-01-05", "disbusalDesc": "Description", "principalRecoveryFlag": "Yes", "repaymentDate": "2024-02-05", ' +
                            '"paymentDetails": [ { "disbursalTo": "Recipient1", "amount": "2500", "creditPeriod": "30", "paymentMode": "Mode1", ' +
                            '"ftMode": "FT", "ifscCode": "IFSC123", "chequeDate": "2024-01-10", "chequeNo": "CHQ001", "effectiveDate": "2024-01-15", ' +
                            '"accountNo": "ACC123", "disbrsmntBank": "BankX", "createdBy": "UserA", "inFavourOf": "Favour1", "remarks": "Remarks1", ' +
                            '"city": "CityX", "bpID": "BP001" } ] } }';
        
        // Call the parse method
        AddTrancheDisRequestWrapper parsedWrapper = AddTrancheDisRequestWrapper.parse(sampleJSON);

        // Validate if the parsing was successful
        System.assertNotEquals(null, parsedWrapper);
        System.assertEquals('12345', parsedWrapper.unqRequestId);
        System.assertEquals('SystemX', parsedWrapper.sourceSystem);
        System.assertEquals('user123', parsedWrapper.userId);
        System.assertEquals('pass456', parsedWrapper.password);
        System.assertNotEquals(null, parsedWrapper.disbursalDetail);
        System.assertEquals('APP001', parsedWrapper.disbursalDetail.applicationID);
        // Add more assertions for other fields as needed
    }

}