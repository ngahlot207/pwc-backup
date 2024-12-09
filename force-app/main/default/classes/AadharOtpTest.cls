@isTest
public class AadharOtpTest {
    
    @isTest
    public static void testGenerateMethod() {
        LoanAppl__c la=new LoanAppl__c();
        la.ChannelName__c='test';
        
        TriggerBase.bypass('LoanAppl__c');
        insert la;
        TriggerBase.clearBypass('LoanAppl__c');
        
        
        Applicant__c ap=new Applicant__c();
        ap.LoanAppln__c=la.id;
        TriggerBase.bypass('Applicant__c');
        insert ap;
        TriggerBase.clearBypass('Applicant__c');
        
        
        ApplKyc__c ak=new ApplKyc__c();
        ak.Applicant__c=ap.id;
        ak.kycDoc__c='Aadhaar';
        ak.AadharEncripted__c='492515815873';
        ak.ReferenceId__c='R12346565';
        ak.OTP__c='123456';
        ak.TransactionId__c='TXN4RDDYOZE5O';
        insert ak;
        
        IntgMsg__c intgMsg = new IntgMsg__c();
        intgMsg.Name='SFDC Aadhar OTP Verification';
        intgMsg.BU__c='HL / STL';
        intgMsg.Status__c='New';
        intgMsg.MStatus__c='Blank';
        intgMsg.RefId__c=ak.id;
        intgMsg.ParentRefId__c=ak.Id;
        //intgMsg.Resp__c='{"status":"success","reference_id":"xxxxxxxx","transaction_id":"xxxxxx","message":"xxxxxxxx","response_time_stamp":"YYYY-MM-DDTHH:MM:SS","result":{"validated_data":{"full_name":"xxxx","aadhaar_number":"xxxx","dob":"YYYY-MM-DD","gender":"xxxx","address":{"country":"xxxx","dist":"xxxx","state":"xxxx","po":"xxxx","loc":"xxxx","vtc":"xxxx","subdist":"xxxx","street":"xxxx","house":"xxxx","landmark":"","zip":"xxxxxx","profile_image":"base64 image data","has_image":true,"raw_xml":"xxxx","zip_data":"xxxx","care_of":"xxxx","share_code":"xxxx","mobile_verified":true,"reference_id":"xxxx","aadhaar_pdf":{}}},"error":"error_message","error_code":"error_code"}';
        
        insert intgMsg;
        
        
        //Request
        List<IntgMsg__c> intgMsgRecords = new List<IntgMsg__c>{intgMsg};
            AadharOTPRequestGenerator generator = new AadharOTPRequestGenerator();
        generator.generate(intgMsgRecords, 'SFDC Aadhar OTP Verification', 'Async');
        
      
        //Wrapper class
        String jsonrequest = '{"reference_id":"ggfdgfdhg","transaction_id":"fgfdfdbewr","otp":"123456"}';
        string jsonresponse='{"status":"success","reference_id":"123456789","transaction_id":"987654321","message":"Aadhar OTP verification successful","response_time_stamp":"2024-02-12T08:30:00","result":{"validated_data":{"full_name":"John Doe","aadhaar_number":"1234 5678 9012","dob":"1990-01-01","gender":"Male","address":{"country":"India","dist":"Dummy District","state":"Dummy State","po":"Dummy Post Office","loc":"Dummy Location","vtc":"Dummy Village/Town/City","subdist":"Dummy Sub-District","street":"Dummy Street","house":"123","landmark":"Near Dummy Landmark"},"face_status":true,"face_score":"95","zip":"123456","profile_image":"base64encodedimagedata","has_image":true,"raw_xml":"<xml>...</xml>","zip_data":"Dummy Zip Data","care_of":"Dummy Care Of","share_code":"Dummy Share Code","mobile_verified":true,"reference_id":"987654321","aadhaar_pdf":{}}},"error":null,"error_code":null}';
        
        AadharOTPRequestwrapper wrapperrequest = AadharOTPRequestwrapper.parse(jsonrequest);
        AadharOTPResponsewrapper wrapperresponse=AadharOTPResponsewrapper.parse(jsonresponse);
    }
}