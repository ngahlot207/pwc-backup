global class GetOrgBaseUrl {
    @InvocableMethod (Label='Get Salesforce base and record URL') 
    global static List<Results> getBaseUrl(List<Id> loanIds){
        
        User u = [Select Id, Profile.Name from User where Id = :UserInfo.getUserId()];
        
        system.debug('loanIds--->' + loanIds);
        List<Results> sfdeURLs = new List<Results>();
        Results r = new Results();
        
        if (loanIds != null && loanIds.size() > 0 && loanIds[0] != null) {
           if (u.Profile.Name == 'DSA') {
               r.sfdcBaseURL = System.Label.Community_DSA_Url;
               r.sfdcRecordURL = System.Label.Community_DSA_Url +'/'+loanIds[0];
           } else {
               r.sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
                r.sfdcRecordURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + loanIds[0];
            }
       sfdeURLs.add(r); // Add the Results object to the list
       }
       
        system.debug('sfdcBaseURL--->' + r.sfdcBaseURL);
        system.debug('sfdcRecordURL--->' + r.sfdcRecordURL);
        system.debug('sfdeURLs--->' + sfdeURLs);
        
        return sfdeURLs;
    }
    
    global class Results{
        @InvocableVariable 
        global String sfdcBaseURL;
        @InvocableVariable 
        global String sfdcRecordURL;
    } 
}