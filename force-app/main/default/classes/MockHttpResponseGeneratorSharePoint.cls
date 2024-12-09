@isTest
global class MockHttpResponseGeneratorSharePoint implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req) {
        // Create a mock HTTP response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"d":{"ServerRelativeUrl":"/sites/FedSaleForce_UAT/Shared%20Documents/TestFolder","metadata":{"type":"SP.Folder"}}}');
        res.setStatusCode(200);
        return res;
    }
}