@RestResource(urlMapping='/generateOTP/*')
global class GenerateOTP {
    
    @HttpGet
    global static list<String> getOTP() {
        String leadId = '';
        String mobileNumber = '';
        String consentType = '';
        List<String> otp = new List<String>();
        
        RestRequest restReq = RestContext.request;
        RestResponse restRes = RestContext.response;
        
        leadId = restReq.params.get('leadId');
        mobileNumber = restReq.params.get('mobileNumber');
        consentType = restReq.params.get('consentType');
        
        system.debug('LeadId:'+leadId+':::MobileNumber:'+mobileNumber);
        
        if(!String.isBlank(leadId) && !String.isBlank(mobileNumber)) {
            if(consentType == 'OTP Consent'){
                otp=CreateLeadController.generateOTP(leadId, mobileNumber);
            }else{
                otp=CreateLeadController.generateLink(leadId, mobileNumber);
            }
            
        }
        return otp;
    }
    
}