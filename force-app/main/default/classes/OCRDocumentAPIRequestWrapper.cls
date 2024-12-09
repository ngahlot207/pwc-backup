public without sharing class OCRDocumentAPIRequestWrapper {
    
    private static final String REQUEST_STRUCTURE = '<?xml version=\"1.0\" encoding=\"UTF-8\"?>'+
        '<REQUEST>'+
        '<ORGID>__ORGID</ORGID>'+
        '<SVCNAME>__SVCNAME</SVCNAME>'+
        '<APIVERSION>__APIVERSION</APIVERSION>'+
        '<APIVENDOR>null</APIVENDOR>'+
        '<REQUESTID>__REQUESTID</REQUESTID>'+
        '<DATA><![CDATA[__CDATA]]></DATA>'+
        '<SFDCSOAPREQUESTDATA></SFDCSOAPREQUESTDATA>'+
        '</REQUEST>';
    
    public String getWrapper(String requestData, IntgMsg__c integrationMessage) {
        
        System.debug('requestData...**' +requestData);
        System.debug('integrationMessage...**' +integrationMessage);
        System.debug('getOrganizationId...**' + UserInfo.getOrganizationId());
        
        //get request structure
        String request = REQUEST_STRUCTURE;
        //add org id
        request = request.replace('__ORGID', UserInfo.getOrganizationId());
        //add service name
        request = request.replace('__SVCNAME', integrationMessage.Svc__c);
        //add client id
        //request = request.replace('__CLIENTID', integrationMessage.CLIENTID__c);
        //add version
        request = request.replace('__APIVERSION', ''+integrationMessage.ApiVersion__c);
        
        //request = request.replace('__APIVENDOR', integrationMessage.ApiVendor__c);
        //add request id
        if(integrationMessage != null && !String.isBlank(integrationMessage.ID)){
            System.debug('InSideIF...**');
            request = request.replace('__REQUESTID', integrationMessage.Id);
        }
        /* if(loanNumber != null || loanNumber != '')
{
request = request.replace('__LOANNO', loanNumber);
}
else
{
if(integrationMessage.RefId__c != null){
request = request.replace('__LOANNO', integrationMessage.RefId__c);
}
}*/
        //add request
        //request = request.replace('__CDATA', requestData);
        
        //add request
        request = request.replace('__CDATA', requestData);
        
        System.debug('request...**' +request);
        //return request
        return request;
    }
}