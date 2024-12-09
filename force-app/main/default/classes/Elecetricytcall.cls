public class Elecetricytcall {
    
    public static void eccall()
    {
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        req.setEndpoint('https://uat-api.fedfina.com/sandbox/test/workflow/singleendpoint');//https://testapi.karza.in/v2/pan	 //https://uat-api.fedfina.com/uat/v2/pan
        req.setBody('{"reference_id": "121343","source_type": "id","source": "240789858325"}'); //{"consent": "Y","pan": "AHXPC2384H","clientData": {"caseId": "123456"}}
        req.setMethod('POST');
        req.setHeader('x-client-id','BDJHZhBnMHMWHcZeLKQCPdQCZhKAFYZRCbEf');
        req.setHeader('x-client-secret','LIGTiBlCBXQMSAhIaVmQWZZQBSFRSnVdfKYeDbkIIkPYOimdOQ');
        req.setHeader('x-application-id','fac7bd67-c7ca-4b38-81a2-c851827f6d6c');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('x-karza-key','7fVDbPh7U7x9J3mA');
        req.setHeader('encryption_key','InpEW75s9taLul1YsNKso5KkHYjRtxzN');
        req.setHeader('x-parse-rest-api-key','81855ad8681d0d86d1e91e00167939cb');
        req.setHeader('x-parse-application','fedbankfinancialservicesltd_kyc_uat');
        req.setHeader('APIVendor','Signdesk');
        req.setHeader('APIname','Aadhar XML Verification API');
        req.setHeader('RecordID','a0GC4000000PcdBMAS');
                
     /*   req.setEndpoint('https://kyc-uat.signdesk.co/api/sandbox/aadhaarXMLVerification');//https://testapi.karza.in/v2/pan	 //https://uat-api.fedfina.com/uat/v2/pan
        req.setBody('{"reference_id": "121343","source_type": "id","source": "240789858325"}');
        req.setMethod('POST');
      //  req.setHeader('encryption_key','InpEW75s9taLul1YsNKso5KkHYjRtxzN');
        req.setHeader('x-parse-rest-api-key','81855ad8681d0d86d1e91e00167939cb');
        req.setHeader('x-parse-application','fedbankfinancialservicesltd_kyc_uat');
        req.setHeader('Content-Type', 'application/json');*/
      
        
        res = http.send(req);
        
        system.debug('test'+ res.getbody());
         
    }
    
}