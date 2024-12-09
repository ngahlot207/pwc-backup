@RestResource(urlMapping='/checkDuplicateLead/*')
global class CheckDuplicateLead {
    @HttpGet
    global static string getDuplicateLeads() {
        RestRequest req = RestContext.request;
        String mobileNumber = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        List<GlobalUtility.LeadDuplicateResponse> duplicateLeadsList = GlobalUtility.findDuplicateLeads(mobileNumber);
        return JSON.serializePretty(duplicateLeadsList, false).replace(':null',':""');
    }
}