@RestResource(urlMapping='/validateDuplicateLeadCheck/*')
global class validateDuplicateLeadCheck {
    
    @HttpGet
    global static string checkDuplicateLead() {
        String leadId = '';
        String mobileNumber = '';
        string duplicateLeadFound = '';
        
        RestRequest restReq = RestContext.request;
        RestResponse restRes = RestContext.response;
        
        leadId = restReq.params.get('leadId');
        mobileNumber = restReq.params.get('mobileNumber');
        
        system.debug('LeadId:'+leadId+':::MobileNumber:'+mobileNumber);
        
        if(!String.isBlank(leadId) && !String.isBlank(mobileNumber)) {
            duplicateLeadFound=LeadHandler.checkDuplicateLead(leadId, mobileNumber);
        }
        return duplicateLeadFound;
    }
    
}