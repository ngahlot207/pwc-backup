@isTest
public class UcidRequestWrapperTest {

    @isTest
    static void testUcidRequestWrapper() {
        // Create an instance of UcidRequestWrapper and set values for testing
        UcidRequestWrapper ucidWrapper = new UcidRequestWrapper();
        ucidWrapper.aadharNumber = '123456789012';
        ucidWrapper.passportno = 'P1234567';
        ucidWrapper.ckycid = 'CKYC123';
        ucidWrapper.gender = 'Male';
        ucidWrapper.panno = 'ABCDE1234F';
        ucidWrapper.emailId = 'test@example.com';
        ucidWrapper.mothermiddlename = 'MotherMid';
        ucidWrapper.motherlastname = 'MotherLast';
        ucidWrapper.customerMiddleName = 'CustomerMid';
        ucidWrapper.motherfirstname = 'MotherFirst';
        ucidWrapper.customerLastName = 'CustomerLast';
        ucidWrapper.id = 'ID123';
        ucidWrapper.dateofbirth = '1990-01-01';
        ucidWrapper.pincode = '123456';
        ucidWrapper.address1 = '123 Main St';
        ucidWrapper.primarymobileno = '9876543210';
        ucidWrapper.drivinglicenseid = 'DL12345';
        ucidWrapper.husbandorfathermiddlename = 'HusbandMid';
        ucidWrapper.husbandorfatherlastname = 'HusbandLast';
        ucidWrapper.voteridno = 'VOTERID6789';
        ucidWrapper.customerFirstName = 'CustomerFirst';
        ucidWrapper.appid = 'APPID123';
        ucidWrapper.husbandorfatherfirstname = 'HusbandFirst';
        ucidWrapper.customerid = 'CUSTID123';
        ucidWrapper.secondarymobileno = '9876543211';
        ucidWrapper.city = 'CityName';
        ucidWrapper.uniqueRefNumber = 'REF123';
        ucidWrapper.source = 'SourceName';
        
        String jsonWithSuccess = '{"aadharNumber": "123456789012","passportno": "AB1234567","ckycid": "CKYC123","gender": "Male","panno": "ABCDE1234F","emailId": "example@example.com","mothermiddlename": "Mother Middle","motherlastname": "Mother Last","customerMiddleName": "Customer Middle","motherfirstname": "Mother First","customerLastName": "Customer Last","id": "ID123","dateofbirth": "1990-01-01","pincode": "123456","address1": "Address Line 1","primarymobileno": "1234567890","drivinglicenseid": "DL123456","husbandorfathermiddlename": "Father Middle","husbandorfatherlastname": "Father Last","voteridno": "VoterID123","customerFirstName": "Customer First","appid": "APP123","husbandorfatherfirstname": "Father First","customerid": "CID123","secondarymobileno": "9876543210","city": "City","uniqueRefNumber": "UR123","source": "Source"}';        
        String jsonWithSuccess1 = '{"Result":"test","Message":"test1"}';
        UcidRequestWrapper wrapperrequest = UcidRequestWrapper.parse(jsonWithSuccess);
        ScreeningResponseWrapper wrapperrequest1 = ScreeningResponseWrapper.parse(jsonWithSuccess1);

        // Perform assertions to validate the values
        System.assertEquals('123456789012', ucidWrapper.aadharNumber, 'Aadhar Number not set correctly');
        System.assertEquals('P1234567', ucidWrapper.passportno, 'Passport Number not set correctly');
        System.assertEquals('CKYC123', ucidWrapper.ckycid, 'CKYC ID not set correctly');
        System.assertEquals('Male', ucidWrapper.gender, 'Gender not set correctly');
        System.assertEquals('ABCDE1234F', ucidWrapper.panno, 'PAN Number not set correctly');
        System.assertEquals('test@example.com', ucidWrapper.emailId, 'Email ID not set correctly');
        System.assertEquals('MotherMid', ucidWrapper.mothermiddlename, 'Mother Middle Name not set correctly');
        System.assertEquals('MotherLast', ucidWrapper.motherlastname, 'Mother Last Name not set correctly');
        System.assertEquals('CustomerMid', ucidWrapper.customerMiddleName, 'Customer Middle Name not set correctly');
        System.assertEquals('MotherFirst', ucidWrapper.motherfirstname, 'Mother First Name not set correctly');
        System.assertEquals('CustomerLast', ucidWrapper.customerLastName, 'Customer Last Name not set correctly');
        System.assertEquals('ID123', ucidWrapper.id, 'ID not set correctly');
        System.assertEquals('1990-01-01', ucidWrapper.dateofbirth, 'Date of Birth not set correctly');
        System.assertEquals('123456', ucidWrapper.pincode, 'Pincode not set correctly');
        System.assertEquals('123 Main St', ucidWrapper.address1, 'Address not set correctly');
        System.assertEquals('9876543210', ucidWrapper.primarymobileno, 'Primary Mobile Number not set correctly');
        System.assertEquals('DL12345', ucidWrapper.drivinglicenseid, 'Driving License ID not set correctly');
        System.assertEquals('HusbandMid', ucidWrapper.husbandorfathermiddlename, 'Husband/Father Middle Name not set correctly');
        System.assertEquals('HusbandLast', ucidWrapper.husbandorfatherlastname, 'Husband/Father Last Name not set correctly');
        System.assertEquals('VOTERID6789', ucidWrapper.voteridno, 'Voter ID not set correctly');
        System.assertEquals('CustomerFirst', ucidWrapper.customerFirstName, 'Customer First Name not set correctly');
        System.assertEquals('APPID123', ucidWrapper.appid, 'Application ID not set correctly');
        System.assertEquals('HusbandFirst', ucidWrapper.husbandorfatherfirstname, 'Husband/Father First Name not set correctly');
        System.assertEquals('CUSTID123', ucidWrapper.customerid, 'Customer ID not set correctly');
        System.assertEquals('9876543211', ucidWrapper.secondarymobileno, 'Secondary Mobile Number not set correctly');
        System.assertEquals('CityName', ucidWrapper.city, 'City not set correctly');
        System.assertEquals('REF123', ucidWrapper.uniqueRefNumber, 'Unique Ref Number not set correctly');
        System.assertEquals('SourceName', ucidWrapper.source, 'Source not set correctly');
        
        // Add more assertions for other fields

        // Add more test cases as needed based on the business logic and requirements
    }
}