@isTest
private class ScreeningRequestWrapperTest {

    @isTest
    static void testParsing() {
        // Create a sample JSON string for testing
        String sampleJson = '{"ScreeningRequestData":{"ApiToken":"39475a23-6dd8-43db-8a31-e12dc969324c","Records":{"Record":[{"RequestId":123457,"RecordIdentifier":"TestRec1","ApplicationFormNumber":"AppForm1","BranchName":"B1","RegionId":"Reg1","SystemName":"Support1","ParentCompany":"Fedfina","Products":{"Product":"BSE_CASH"},"FirstName":"First Name","MiddleName":"Middle Name","LastName":"Last Name","CustomerCategory":"IND","Gender":"M","Pan":"AAAAA1234A","Din":"DIN124","Cin":"U1234P2007PLC546789","DateOfBirth":"15-Jul-1986","PlaceOfBirth":"","CountryOfBirth":"","Nationality":"IND","Citizenships":{"Citizenship":["IND"]},"Passport":"D1234","DrivingLicenceNumber":"MH-1220050000188","CorrespondenceAddress1":"Everest Bldg","CorrespondenceAddress2":"C Wing,","CorrespondenceAddress3":"Senapati Bapat Marg ,Lower Parel","CorrespondenceAddressCity":"Mumbai","CorrespondenceAddressState":"Maharastra","CorrespondenceAddressCountry":"IND","CorrespondenceAddressPin":400013,"PermanentAddress1":"Everest Bldg","PermanentAddress2":"C Wing,","PermanentAddress3":"Senapati Bapat Marg ,Lower Parel","PermanentAddressCity":"Mumbai","PermanentAddressState":"Maharastra","PermanentAddressCountry":"IN","PermanentAddressPin":400013,"PEP":"NotAPEP","Occupation":"SE","RMDetails":{"RMDetail":{"UserCode":404,"Type":"BM","FromDate":"20-Jan-2019"}},"CreateAlert":"Yes","ScreeningCategory":"Initial Screening Master"}]}}}}';

        // Parse the JSON string
        ScreeningRequestWrapper result = ScreeningRequestWrapper.parse(sampleJson);

        // Perform assertions based on your requirements
        System.assertEquals('39475a23-6dd8-43db-8a31-e12dc969324c', result.ScreeningRequestData.ApiToken);
        // Add more assertions as needed for other fields
    }
}