@IsTest
public class ComBaseDtlsResponseWrapperTest {

    @IsTest
    static void testComBaseDtlsResponseWrapper() {
        // Creating instances of nested classes and setting values
        ComBaseDtlsResponseWrapper.Registered_address regAddress = new ComBaseDtlsResponseWrapper.Registered_address();
        regAddress.full_address = '1234 Test Street, Test City, TS 12345';
        regAddress.address_line1 = '1234 Test Street';
        regAddress.address_line2 = 'Suite 101';
        regAddress.city = 'Test City';
        regAddress.pincode = '12345';
        regAddress.state = 'TS';
        
        ComBaseDtlsResponseWrapper.Lei lei = new ComBaseDtlsResponseWrapper.Lei();
        lei.number_Z = 'LEI123456789';
        lei.status = 'Active';
        
        ComBaseDtlsResponseWrapper.Company company = new ComBaseDtlsResponseWrapper.Company();
        company.authorized_capital = 1000000.0;
        company.cin = 'U12345TS2024PTC000123';
        company.efiling_status = 'Active';
        company.incorporation_date = '2024-01-01';
        company.legal_name = 'Test Company Pvt Ltd';
        company.paid_up_capital = 500000.0;
        company.sum_of_charges = 100000.0;
        company.active_compliance = 'Yes';
        company.registered_address = regAddress;
        company.classification = 'Private';
        company.status = 'Active';
        company.last_agm_date = '2024-08-01';
        company.last_filing_date = '2024-07-01';
        company.email = 'info@testcompany.com';
        company.lei = lei;
        
        ComBaseDtlsResponseWrapper.Open_charges openCharge = new ComBaseDtlsResponseWrapper.Open_charges();
        openCharge.id = 1;
        openCharge.date_Z = '2024-06-15';
        openCharge.holder_name = 'Test Bank';
        openCharge.amount = 50000.0;
        openCharge.type = 'Secured';
        
        ComBaseDtlsResponseWrapper.Address address = new ComBaseDtlsResponseWrapper.Address();
        address.address_line1 = '123 Test Lane';
        address.address_line2 = 'Apt 202';
        address.city = 'Testville';
        address.pincode = '54321';
        address.state = 'TS';
        address.country = 'Testland';
        
        ComBaseDtlsResponseWrapper.Authorized_signatories signatory = new ComBaseDtlsResponseWrapper.Authorized_signatories();
        signatory.pan = 'ABCDE1234F';
        signatory.din = 'DIN123456';
        signatory.name = 'John Doe';
        signatory.designation = 'Director';
        signatory.din_status = 'Active';
        signatory.gender = 'Male';
        signatory.date_of_birth = '1980-01-01';
        signatory.age = 44;
        signatory.date_of_appointment = '2020-01-01';
        signatory.date_of_appointment_for_current_designation = '2020-01-01';
        signatory.date_of_cessation = null;
        signatory.nationality = 'Testland';
        signatory.address = address;
        
        ComBaseDtlsResponseWrapper.Metadata metadata = new ComBaseDtlsResponseWrapper.Metadata();
        metadata.api_version = '1.0';
        metadata.last_updated = '2024-08-21';
        
        ComBaseDtlsResponseWrapper.Data data = new ComBaseDtlsResponseWrapper.Data();
        data.company = company;
        data.open_charges = new List<ComBaseDtlsResponseWrapper.Open_charges>{openCharge};
        data.authorized_signatories = new List<ComBaseDtlsResponseWrapper.Authorized_signatories>{signatory};
        
        ComBaseDtlsResponseWrapper responseWrapper = new ComBaseDtlsResponseWrapper();
        responseWrapper.metadata = metadata;
        responseWrapper.data = data;
        responseWrapper.message = 'Success';

        // Asserting the values to verify correct instantiation
        System.assertEquals('1.0', responseWrapper.metadata.api_version);
        System.assertEquals('2024-08-21', responseWrapper.metadata.last_updated);
        System.assertEquals('Success', responseWrapper.message);
        System.assertEquals('Test Company Pvt Ltd', responseWrapper.data.company.legal_name);
        System.assertEquals('Active', responseWrapper.data.company.status);
        System.assertEquals(1, responseWrapper.data.open_charges.size());
        System.assertEquals('Test Bank', responseWrapper.data.open_charges[0].holder_name);
        System.assertEquals(1, responseWrapper.data.authorized_signatories.size());
        System.assertEquals('John Doe', responseWrapper.data.authorized_signatories[0].name);
    }
}