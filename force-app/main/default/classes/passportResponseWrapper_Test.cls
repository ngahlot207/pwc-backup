@isTest
public class passportResponseWrapper_Test {

    @isTest
    static void testParseMethod() {
        
        String sampleJson = '{' +
            '"result": {' +
                '"passportNumber": {' +
                    '"passportNumberFromSource": "S3733862",' +
                    '"passportNumberMatch": true' +
                '},' +
                '"applicationDate": "14/05/2018",' +
                '"typeOfApplication": "Tatkaal",' +
                '"dateOfIssue": {' +
                    '"dispatchedOnFromSource": "14/05/2018",' +
                    '"dateOfIssueMatch": true' +
                '},' +
                '"name": {' +
                    '"nameScore": "1",' +
                    '"nameMatch": true,' +
                    '"surnameFromPassport": "SHIRHATTI",' +
                    '"nameFromPassport": "OMKAR MILIND"' +
                '}' +
            '},' +
            '"requestId": "f3de6c55-6c0f-11e9-bf8e-610d4b51e956",' +
            '"statusCode": 101,' +
            '"clientData": {' +
                '"caseId": "123456"' +
            '}' +
        '}';
        
        
        passportResponseWrapper parsedResponse = passportResponseWrapper.parse(sampleJson);
   
    }
}