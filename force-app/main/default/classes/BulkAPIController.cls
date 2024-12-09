public class BulkAPIController {
    @AuraEnabled
    public static void uploadData(List<String> csvLines, String objectName) {
        String baseUrl = URL.getOrgDomainURL().toExternalForm();
        System.debug('csvLine::: ' + csvLines);
        System.debug('objectName::: ' + objectName);
        System.debug('baseUrl::: ' + baseUrl);
        String endpoint = baseUrl + '/services/data/v59.0/jobs/ingest/' + objectName;
        System.debug('endpoint::: ' + endpoint);
        String accessToken = UserInfo.getSessionId().substring(15);
		System.debug('accessToken::: ' + accessToken);        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'text/csv; charset=UTF-8');
        req.setBody(String.join(csvLines, '\n'));
        System.debug('geBody::: ' + req.getBody());
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        if (res.getStatusCode() == 201) {
            System.debug('Job created successfully.');
        } else {
            System.debug('Error creating job: ' + res.getBody());
        }
    }
}