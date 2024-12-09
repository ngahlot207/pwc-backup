public class TestingAPI {
    
    
    //public static void initiateTransaction(string payload, string recordId){
        
      //  String method ='POST';
       // String requestDate= String.valueOf(system.now().format('yyyyMMdd\'T\'HHmmss\'Z\''));
        //String url ='/KuberaVault/api/v3/organisations/unicoHousingFinance/transactions';
        
        //String sha256Content = PerfiosAPIController.getSHA256Content(payload);
        //string signature = generateSignature(method,URL,'',payload, requestDate);
        //system.debug('unico test signature::::'+signature);
        
       /* IntgMsg__c intMsg = new IntgMsg__c();
        intMsg.Id= recordId;
        intMsg.Resp__c='Request Date:' + requestDate +'\n' + 'Signature:' + signature + '\n' + 'SHA256Content:' +sha256Content ;
        update intMsg;*/
        
        /*Http http = new Http();
HttpRequest req = new HttpRequest();
req.setMethod('POST');
//req.setEndpoint('https://demo.perfios.com/KuberaVault/api/v3/organisations/fedfina/transactions');
//req.setHeader('host','demo.perfios.com');
req.setEndpoint('https://uat-api.fedfina.com/sandbox/test/workflow/singleendpoint');
req.setHeader('Accept','application/json');
req.setHeader('Content-Type','application/json');
req.setHeader('X-Perfios-Algorithm','PERFIOS1-RSA-SHA256');
req.setHeader('X-Perfios-Content-Sha256',PerfiosAPIController.getSHA256Content(Payload));
req.setHeader('X-Perfios-Date',requestDate);
req.setHeader('X-Perfios-Signature',signature);
req.setHeader('X-Perfios-Signed-Headers','host;x-perfios-content-sha256;x-perfios-date');
req.setHeader('x-client-id','BDJHZhBnMHMWHcZeLKQCPdQCZhKAFYZRCbEf');
req.setHeader('x-client-secret','LIGTiBlCBXQMSAhIaVmQWZZQBSFRSnVdfKYeDbkIIkPYOimdOQ');
req.setHeader('x-application-id','fac7bd67-c7ca-4b38-81a2-c851827f6d6c');
req.setHeader('APIVendor','Perfios');
req.setHeader('APIname','Initiate Transaction');
req.setHeader('RecordID',recordId); 
req.setBody(Payload);
HttpResponse res = http.send(req);

System.debug('::::::StatusCode::::::'+res.getStatusCode());
System.debug('::::::Response::::::' + res.getBody());*/
        
        
        
    //}
    
    /*public static void uploadFiles(string payload, string recordId, String transactionId){
        
        String method ='POST';
        String requestDate= String.valueOf(system.now().format('yyyyMMdd\'T\'HHmmss\'Z\''));
        String url ='/KuberaVault/api/v3/organisations/fedfina/transactions/'+transactionId+'/files';
        String sha256Content = PerfiosAPIController.getSHA256Content(payload);
        string signature = PerfiosAPIController.generateSignature(method,URL,'',payload, requestDate);
        system.debug(signature);
        
        
        IntgMsg__c intMsg = new IntgMsg__c();
        intMsg.Id= recordId;
        intMsg.Resp__c='Request Date:' + requestDate +'\n' + 'Signature:' + signature + '\n' + 'SHA256Content:' +sha256Content ;
        update intMsg;
        
        
    }
    
    public static void processFiles(string payload, string recordId, String transactionId){
        
        
        String method ='POST';
        String requestDate= String.valueOf(system.now().format('yyyyMMdd\'T\'HHmmss\'Z\''));
        String url ='/KuberaVault/api/v3/organisations/fedfina/transactions/'+transactionId+'/bank-statements';
        string signature = PerfiosAPIController.generateSignature(method,URL,'',payload, requestDate);
        String sha256Content = PerfiosAPIController.getSHA256Content(payload);
        system.debug(signature);
        
        IntgMsg__c intMsg = new IntgMsg__c();
        intMsg.Id= recordId;
        intMsg.Resp__c='Request Date:' + requestDate +'\n' + 'Signature:' + signature + '\n' + 'SHA256Content:' +sha256Content ;
        update intMsg;
        
        
        
    }
    
    public static void generateReport(string payload, string recordId, String transactionId){
        
        String method ='POST';
        String requestDate= String.valueOf(system.now().format('yyyyMMdd\'T\'HHmmss\'Z\''));
        String url ='/KuberaVault/api/v3/organisations/fedfina/transactions/'+transactionId+'/reports';
        String sha256Content = PerfiosAPIController.getSHA256Content(payload);
        string signature = PerfiosAPIController.generateSignature(method,URL,'',payload, requestDate);
        system.debug(signature);
        
        
        IntgMsg__c intMsg = new IntgMsg__c();
        intMsg.Id= recordId;
        intMsg.Resp__c='Request Date:' + requestDate +'\n' + 'Signature:' + signature + '\n' + 'SHA256Content:' +sha256Content ;
        update intMsg;
        
        
    }
    
     public static void retrieveReport(string payload, string recordId, String transactionId){
        
        String method ='GET';
        String requestDate= String.valueOf(system.now().format('yyyyMMdd\'T\'HHmmss\'Z\''));
        String url ='/KuberaVault/api/v3/organisations/fedfina/transactions/'+transactionId+'/reports';
        ///WK8G1700475776958/reports  
        String sha256Content = PerfiosAPIController.getSHA256Content(payload);
        string signature = PerfiosAPIController.generateSignature(method,URL,'types=xlsx',payload, requestDate);
        system.debug(signature);
        
        IntgMsg__c intMsg = new IntgMsg__c();
        intMsg.Id= recordId;
        intMsg.Resp__c='Request Date:' + requestDate +'\n' + 'Signature:' + signature + '\n' + 'SHA256Content:' +sha256Content ;
        update intMsg;
        
        
    }*/
    
    /*public static void generateLink(string payload, string recordId){
        String method ='POST';
        String requestDate= String.valueOf(system.now().format('yyyyMMdd\'T\'HHmmss\'Z\''));
        String url ='/KuberaVault/api/v3/organisations/fedfina/transaction-links';
        
        String sha256Content = PerfiosAPIController.getSHA256Content(payload);
        string signature = generateSignature(method,URL,'',payload, requestDate);
        system.debug('unico test signature::::'+signature);
        
       IntgMsg__c intMsg = new IntgMsg__c();
        intMsg.Id= recordId;
        intMsg.Resp__c='Request Date:' + requestDate +'\n' + 'Signature:' + signature + '\n' + 'SHA256Content:' +sha256Content ;
        //update intMsg;
        
        Http http = new Http();
HttpRequest req = new HttpRequest();
req.setMethod('POST');
req.setEndpoint('https://demo.perfios.com/KuberaVault/api/v3/organisations/fedfina/transaction-links');
req.setHeader('host','demo.perfios.com');
//req.setEndpoint('https://uat-api.fedfina.com/sandbox/test/workflow/singleendpoint');
req.setHeader('Accept','application/json');
req.setHeader('Content-Type','application/json');
req.setHeader('X-Perfios-Algorithm','PERFIOS1-RSA-SHA256');
req.setHeader('X-Perfios-Content-Sha256',PerfiosAPIController.getSHA256Content(Payload));
req.setHeader('X-Perfios-Date',requestDate);
req.setHeader('X-Perfios-Signature',signature);
req.setHeader('X-Perfios-Signed-Headers','host;x-perfios-content-sha256;x-perfios-date');

req.setBody(Payload);
HttpResponse res = http.send(req);

System.debug('::::::StatusCode::::::'+res.getStatusCode());
System.debug('::::::Response::::::' + res.getBody());
        
        
        
    }*/
    /*
String payload='{"payload":{"loanAmount":"100000","loanDuration":"24","loanType":"Home","processingType":"STATEMENT","transactionCompleteCallbackUrl":"https://example.com/callback","txnId":"876545639749876587655","acceptancePolicy":"atLeastOneTransactionInRange","employmentType":"Salaried","uploadingScannedStatements":"false","yearMonthFrom":"2023-01","yearMonthTo":"2023-08"}}';
String recordId='a0GC4000000PtNtMAK';             
TestingAPI.initiateTransaction(payload, recordId);             

String payload='';
String recordId='a0GC4000000PtNtMAK';
String transactionId='HW931699008189965';             
TestingAPI.uploadFiles(payload,recordId,transactionId);   

String payload = '{"payload":{"fileId":"43637fd95c867c11456175bf4e2b2fde7e8fbc79"}}';           
String recordId='a0GC4000000PtNtMAK';
String transactionId='HW931699008189965';             
TestingAPI.processFiles(payload,recordId,transactionId);              
*/
    
    
    //public static final String BOUNDARY = '----FormBoundary4Amf13kZd';
    //public static final String EXTRABOUNDARY = '--' + BOUNDARY;
    
    /*public static Blob multiPartFormDataBody(Blob file, String contentType, String filename, Map<String, String> metadataMap) {
        contentType = contentType == '' ? 'application/octet-stream' : contentType;
        String bodyStartHex = EncodingUtil.convertToHex(Blob.valueOf(EXTRABOUNDARY + '\r\nContent-Disposition: form-data; name=\"file\"; filename="' + filename + '"\r\nContent-Type: ' + contentType + '\r\n\r\n'));
        String bodyEndHex = EncodingUtil.convertToHex(Blob.valueOf(EXTRABOUNDARY + '--\r\n'));
        
        bodyStartHex += EncodingUtil.convertToHex(file);
        if (metadataMap != null && metadataMap.size() != 0) {
            String formElements = '\r\n';
            for (String key : metadataMap.keySet()) {
                formElements += EXTRABOUNDARY + '\r\nContent-Disposition: form-data; name=\"' + key + '\"\r\n\r\n' + metadataMap.get(key) + '\r\n';
            }
            bodyStartHex += EncodingUtil.convertToHex(Blob.valueOf(formElements));
        } else {
            bodyEndHex = EncodingUtil.convertToHex(Blob.valueOf('\r\n' + EXTRABOUNDARY + '--'));
        }
        return EncodingUtil.convertFromHex(bodyStartHex + bodyEndHex);
    }*/
    
    /*public class response{
        public List<Integer> PDF_REPORT;
    }*/
    
    /*@future
    public static void processresponse(String recordId, String response){
        ContentDocumentLink cdlList =  [SELECT Id, LinkedEntityId,ContentDocumentId,ContentDocument.FileType FROM
                                        ContentDocumentLink where LinkedEntityId ='a0GC4000000VsTxMAK' ORDER BY SystemModstamp DESC  LIMIT 1 ];
        
        ContentVersion verData = [SELECT VersionData,ContentDocumentId,FileType,FileExtension FROM ContentVersion 
                                  where ContentDocumentId = :cdlList.ContentDocumentId];
        
        String jsonResponse= verData.VersionData.toString().replace('PDF REPORT','PDF_REPORT');
        system.debug(jsonResponse); 
        
        TestingAPI.response res =  (TestingAPI.response) JSON.deserialize(jsonResponse,TestingAPI.response.class);           
        system.debug(res); 
        
        List<Integer> values = res.PDF_REPORT;
        //Integer[] values = new Integer[]{-33, 103, -48, -46, 113, ...};
        // Buffer
        String[] hexValues = new String[0];
        // Hex lookup
        String[] hex = '0123456789abcdef'.split('');
        for(Integer byteValue: values) {
            // Isolate bits 4-7: (240) 0xF0 is the mask
            // Divide by 16 (shift right 4 bits)
            Integer highNybble = (byteValue & 240) >> 4;
            // Isolate bits 0-3 (15) 0x0F is the mask
            Integer lowNybble = byteValue & 15;
            // Write high and low 
            hexValues.add(hex[highNybble]);
            hexValues.add(hex[lowNybble]);
        }
        Blob result = EncodingUtil.convertFromHex(String.join(hexValues,''));
        System.debug(result);
        
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.VersionData = result;
        contentVersion.Title = 'Report';
        contentVersion.PathOnClient = 'Report.pdf';
        insert contentVersion;
        
        system.debug('contentVersion'+contentVersion);
        
        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id LIMIT 1].ContentDocumentId;
        
        ContentDocumentLink contentLink = new ContentDocumentLink();
        contentLink.ContentDocumentId = contentDocumentId;
        contentLink.LinkedEntityId='a0GC4000000PtNtMAK';
        contentLink.ShareType = 'V';
        insert contentLink;
        
        system.debug('contentLink'+contentLink);
    }
    
    public static String generateSignature(String method, String url, String urlQuery,String payload, String requestDate) {
        IntgSvcMgmt__mdt svc = [Select Id,Svc__c, BU__c, ApiVendor__c, IsActive__c, Domain__c, PrivateKey__c, PublicKey__c, AlgorithmName__c, URL__c, CallbackURL__c,SignedHeaders__c from IntgSvcMgmt__mdt where DeveloperName ='Perfios_Initiate_Transaction' LIMIT 1];
        
        String sha256Payload=PerfiosAPIController.getSHA256Content(Payload);
        String headers = 'host:'+PerfiosAPIController.Host+'\n' 
            + 'x-perfios-content-sha256:'+sha256Payload+'\n'
            + 'x-perfios-date:'+requestDate+ '\n'
            + PerfiosAPIController.signedHeaders;
        system.debug('Request Date:\n' + requestDate);
        system.debug('sha256Payload:\n'+ sha256Payload);
        
        
        //Creating a Conanical Request
        String CanonicalRequest=method+'\n'
            + url+'\n'
            + urlQuery+'\n'
            + headers+'\n' 
            + sha256Payload;
        System.debug('CanonicalRequest:\n'+CanonicalRequest);
        System.debug('CanonicalRequestSHA256:\n'+PerfiosAPIController.getSHA256Content(CanonicalRequest));
        
        //Creating a String to sign using Conanical Request
        String StringToSign = 'PERFIOS1-RSA-SHA256' + '\n'
            + requestDate + '\n'
            + PerfiosAPIController.getSHA256Content(CanonicalRequest);
        System.debug('StringToSign:\n'+StringToSign);
        
        
        //Create a checksum using String to sign
        String Checksum=PerfiosAPIController.getSHA256Content(StringToSign);
        System.debug('Checksum:\n'+Checksum);
        
        //Encryption the String to sign using RSA private key
        //String privateKey='MIIJKQIBAAKCAgEA3EbDs473by3nHpdsVP7DMkcPxn+GVsRZt3QG+N4pm8Unw0GCDCMrgv7eWWwezkUMIXZvvXDHHvGtiRtvrKLlvKwy6wIW/5dXr9QkIb+zdnLcYCM1kQsR5B45/tYCjjgZU/kFwn0ULDk9xifCCNEY3g16HxueZwdtW4yr/3v0n0q8JPqoLQ3my//UOTh2ni9Vg9fTdHVNPiySW96BExGiVDTCgjkFxI1qjfhlSdBvsKB2bfOKOUOYmSzMDgYm/u1ojS/vTNtNXNMqLdQ4sF+3s63nz3yodN8qV3s6N6yIvvDZvikUWHTx9R3VJdrf3v12t4vcAlT7Urvj2lQeHCkif8roCx1vWxDqBBN+rSbb97lFA5AzyVnm6Rdd4zsd90vQzeXv7uU+iIXgAfQXFg75eK1bycQwP8NJ1ClHUx5tppqRjOAj0AsFuiCLyE5XZdE9IENR/kQQBJw7HndbaUYUaL1Dq65pEl6AK+fCNjPk4+1dl0desXt8VV+JZPsTtEWqR1hnfDFc4IoNg0ocNoNVwt5d+EA4f+J0REASSQwWhshyva+5m1g5I88FhYP10A+avGAbY8cortmVCbDwTqg3nkQPw/6c1skRCaHvqlBVGEF63sKR1XxLWfC9rOgcANk0zR33noaC8bJxkEm5BbcdEA5yJ9cTKSNSg7/bP5R3+BMCAwEAAQKCAgAM6lVFLO4ssnG2GHjKNWadukIeVStvFCb46H1HXRDuSJpy119xqL1yk9EKFM3SZR5qw9zI+PJwsDwiXHdCyKMhwEYuabpbFOhkr2wvuMnwxjFOFCJq6IENcaKpSREJsUspSK7IXx8UrLjtHZ2oRXvox4kc7WvVn9jb0+nhAMdjo5uLRR5UbfE8J6B6ezYK3LzUQY5TalSAf1dUunB+lruAcz6uwsf0y1N8Rk+VPi4EtC13EVJOCaMwr/2GGpQ+Wqf7rajUeWZ8bKExFYIxZs6IyXr2Oz/ntY7WmRIQlTXIKqtwFYAgFtNGmCll0jYehzJm9qgl6g4TJSy2u26vuTW3Hp+xKyJW93HztsrH1hfC0+Pcar/xLd1KzwCC5bIMIdCIUYRRVI0Uev0a88RB0cb7XrLOU2DOIDOQ40tM6Ys2De1GGswb4LHvfTFhwRwskrbvb+gcqs6uSnZdFubCJXciY9ELQ5DboleqUMmOah1ljxjAO+s0VBRKjivOxIpg5dutbMTErvLkW9/aLZMcrFjWY3/teaCD9blsnoiPoVRALnSFZGl1Wh3rZxMqTsKP+kc/wtyGb2wtqyEBZjbgtQ6tCRe3z/Jg5wglZXQHgWtKEWkUORzG1rM4LJsIo2yjeKqudBIGnf6EHz6gve2cUNN8wYJO5w8y50yYwGzMd856iQKCAQEA70CjhE7LtuyX6FcKerBLHjMxouhv0FYWyFm7BX/WnVJ/p8WN3MHQnsMYIKQdgv45wpsrD7wdOlbi/wLt+yjd1iycbsvuun/ws+HcrnKgBP/UMRmuERtzLZfVuT8JrS+eWAXvMPiRTKRXb41nCsFYLnBZhDiom0WMPkqsOCAY12NmUcjKFuzrXgXdbsB2gru8p1pGQBAdK+i+TVRNaSv06cRQ7bpZjFYopetOiifQIwAxwbqpQQtFLqnVR3Dc1g7jKqNmhqFXvpy9kpJZxBlsleoV0VBCrDTu9NRZUffIztqo2eG8ou2gJo5d+/gUMn/UfdxgXZ/u38XD+Wg/DhpKPQKCAQEA67IT9a8YxCMGxjeEINoOB5qByzamBLsbpxhj3KeqgREGKxiWgynWzBsDDrOie5ep02+9YObInz9uVGZAcI4HMhkfLgBVm97mn3AfgNpOudFp1bsiE13quOCURhh3WlgRoWlXZdWAoUnOEgRxHOtyE7O2JI9fn/Z+WYQbAVAdg3o9G2trmLamOklA1+2U10n2eEF+wiI7Cz+r87PphcwaYjm2ysmrRfj4uPr/PsRDh3GX3nZH6WFOsS0f+KYrl8KAJC3akPq7xbloj45WaEH+a7t5Sk1y3o3MfVtJUql7d79zpF//67Bb8SfUt3jQ5c0wJWZpFk97Hr3K4t+P9fKAjwKCAQBCILmRXj4MJ0StYTFyS7vXcwrrHheZm9HcOoDoujbVcPH7qyzUsXU6DG5kxzeo9x973GuAg9wIPe+r0GF6pAb8pYPvU8p+HdKnxWu7g88a0qMRlyl3bQDevzLBatz/00OOzMUZ4fo3Fs1b9ddfL6Vx4He9hfOERyrGJNmJAcYb8ktbm4XP5FgButlDPUsEQ2OXVepI1qtZcZD3yq9CvHWLD0nXC0So9z9w7KLeqLZslicqhq81XSoYBbT/dAB14dOD+3nhCEM6WhRDqNPK0cQjg3nYSrjC5DaP0QmHEFeeZO16m1wKJGe5gGwVsrHSa2aOCxVPi1741q6eBuQ2v6l5AoIBAQChmmTzFE4v1TBE4jW27Kun7PlHYz3rinsIU8HMvi0693g6Pk6cuigro+2xu9sRUMjBTyES+snd3nkAZ2eRhOBMKktlmBcam3eXJCKFj6lg4MPnJrrTepaAkoM3mHjlOfNEr9yb1wquC9O+KMuBn7GE7rhZUvCm1jSFnf2CJfNGfZ6+WSXZ/In29tj99EkUYAMdKxMFesDvEoYMv3PDKFGCvb2mRyYnAPFQq9Asshb3HBycDI975hs1ghIkw5KqKFMB+2qb8z6h8GFP5LE8JNuT9GPSXU4AaEsoPFoG0mv0jBF3R9dKO46ex8ei0LSyi8CSNCijgnWRe2JLsiub39zjAoIBAQC6iHXQB0SiT/zQwWgj+0stcwldLWSx0ZekEYMiFi1GYZo63w1tWl3MVPivGALx/B+9d+IlkieBDqPaQQghhbDJ6+Lf+/oPIPIX511rDJQ2PJ2F8JZDhYjM8lA1Cl4nsiEG+tQQ9tUQNcGh6lJp8t2eO82d9gcNgTMXYMkDXShJyj9VOPTH90nGdwmBmxw+dGbqYSDuDaBGZBTpHDfdiro7y2VHhX1tDx6McX4VYcpDtMf3KImpSdI7AAUZwEeNQMpzzwVeBM9Bf2GK2zweZuCFPhx2G7kZ+h2UvN1FBSsWaDEnwpxvY08ccH3N2d3OgnKYbRDjxZJBhvAwkdD05cdO';
		//String privateKey = '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';
		//                  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
        //String privateKey ='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';
        String privateKey = svc.PrivateKey__c;
        String algorithmName = 'RSA-SHA256';
        Blob key = EncodingUtil.base64Decode(privateKey); //Blob.valueOf(privateKey);
        Blob input = Blob.valueOf(checksum);//EncodingUtil.convertFromHex(checksum);//Blob.valueOf(checksum);//EncodingUtil.convertFromHex(checksum);
        Blob sign = Crypto.sign(algorithmName, input, key);
        String Signature =EncodingUtil.convertToHex(sign).toLowerCase();
        
        IntgMsg__c im = new IntgMsg__c();
        im.Resp__c = Signature;
        im.id = 'a0GC4000001NOQtMAO';
        //update im;
        system.debug('Signature: '+ Signature+'::::end');
        return Signature;
        
    }*/
    
    // recordId = 'a0GC4000001M8hYMAS' fileId ='a0GC4000001M8hXMAS'
    /*@future
    public static void getTestEsignDocuments(String FileId, String recordId){
        
        ContentDocumentLink cdlList =  [SELECT Id, LinkedEntityId,ContentDocumentId,ContentDocument.FileType FROM
                                        ContentDocumentLink where LinkedEntityId =:FileId ORDER BY SystemModstamp DESC  LIMIT 1 ];
        
        ContentVersion verData = [SELECT VersionData,ContentDocumentId,FileType,FileExtension FROM ContentVersion 
                                  where ContentDocumentId = :cdlList.ContentDocumentId];
        
        system.debug('::::::::::::::::::');
        //String testFileBase64Data = EncodingUtil.base64Encode(verData.VersionData);
        system.debug('1:::::::::::::::::::');
        ESignDocumentUploadRequestWrapper request = new ESignDocumentUploadRequestWrapper();
        request.reference_id = 'xxxx';
        request.docket_title = 'xxxx';
        request.remarks = 'xxxx';
        request.enable_email_notification = 'xxxx';
        
        
        List<ESignDocumentUploadRequestWrapper.Documents> documents = new List<ESignDocumentUploadRequestWrapper.Documents>();
        
        for(integer i=0;i<1;i++){
            ESignDocumentUploadRequestWrapper.Documents document = new ESignDocumentUploadRequestWrapper.Documents();
            document.reference_doc_id = verData.Id;
            document.content_type = 'xxxx';
            document.return_url = 'xxxx';
			document.content = EncodingUtil.base64Encode(verData.VersionData);
            document.signature_sequence = 'xxxx';
            ESignDocumentUploadRequestWrapper.Custom  custom = new ESignDocumentUploadRequestWrapper.Custom();
            custom.parameter_name = 'xxxx';
            document.custom = custom;
            
            documents.add(document);
        }
        
        request.documents = documents;
        ESignDocumentUploadRequestWrapper.WidgetConfiguration  widgetConfiguration = new ESignDocumentUploadRequestWrapper.WidgetConfiguration();
        widgetConfiguration.widget_title = 'xxxx';
        widgetConfiguration.background_color =  'xxxx';
        widgetConfiguration.button_color = 'xxxx';
        widgetConfiguration.button_font_color = 'xxxx';
        widgetConfiguration.font_family = 'xxxx';
        widgetConfiguration.esign_with_otp_button_text = 'xxxx';
        widgetConfiguration.esign_with_biometric_button_text = 'xxxx';
        widgetConfiguration.user_instruction = 'xxxx';
        widgetConfiguration.remark_field_label = 'xxxx';
        widgetConfiguration.usb_signature_title = 'xxxx';
    
        
        request.widget_configuration = widgetConfiguration;
        
        List<ESignDocumentUploadRequestWrapper.SignersInfo> signersInfo = new List<ESignDocumentUploadRequestWrapper.SignersInfo>();
        
        ESignDocumentUploadRequestWrapper.SignersInfo signerInfo = new ESignDocumentUploadRequestWrapper.SignersInfo();
        
        signerInfo.document_to_be_signed = 'xxxx';
        
        ESignDocumentUploadRequestWrapper.SignerPosition signerPosition = new ESignDocumentUploadRequestWrapper.SignerPosition();
        signerPosition.appearance = 'xxxx';
        
        signerInfo.signer_position = signerPosition;
        
        signerInfo.signer_ref_id = 'xxxx';
        signerInfo.signer_email = 'xxxx';
        signerInfo.signer_name = 'xxxx';
        signerInfo.sequence = 'xxxx';
        signerInfo.page_number = 'xxxx';
        signerInfo.esign_type = 'xxxx';
        signerInfo.signer_mobile = 'xxxx';
        
        ESignDocumentUploadRequestWrapper.SignerValidationInputs signerValidationInputs = new ESignDocumentUploadRequestWrapper.SignerValidationInputs();
        
        signerValidationInputs.year_of_birth = 'xxxx';
        signerValidationInputs.gender = 'xxxx';
        signerValidationInputs.name_as_per_aadhaar = 'xxxx';
        signerValidationInputs.last_four_digits_of_aadhaar = 'xxxx';
        
        signerInfo.signer_validation_inputs = signerValidationInputs;
        
        signerInfo.signature_type = 'xxxx';
        signerInfo.access_type = 'xxxx';
        
        signersInfo.add(signerInfo);
        
        request.signers_info = signersInfo;
        
        
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.VersionData = Blob.valueOf(JSON.serialize(request));
        contentVersion.Title = 'Request';
        contentVersion.PathOnClient = 'Request.json';
        insert contentVersion;
        
        system.debug('contentVersion'+contentVersion);
        
        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id LIMIT 1].ContentDocumentId;
        
        ContentDocumentLink contentLink = new ContentDocumentLink();
        contentLink.ContentDocumentId = contentDocumentId;
        contentLink.LinkedEntityId=recordId;
        contentLink.ShareType = 'V';
        insert contentLink;
        
    }*/
    
    /*@future(callout=true)
    public static void maketestAPIcall(){
        
        //ContentDocumentLink cdlList =  [SELECT Id, LinkedEntityId,ContentDocumentId,ContentDocument.FileType FROM
        //                                ContentDocumentLink where LinkedEntityId =''];
        
        ContentVersion verData= [SELECT Title,VersionData,ContentDocumentId,FileType,FileExtension FROM ContentVersion 
                  where ContentDocumentId = '069C4000003DwShIAK'];
        
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        req.setMethod('POST');
        req.setEndpoint('callout:APIGateway'); 
        //req.setBody(verData.VersionData.toString());
        req.setBodyAsBlob(verData.VersionData);
        //
        res = http.send(req);
    }*/
    public static void NCCreateFileRequest(String refId,String caseId, String FileName, Integer docTypeId, String resultId){
        //refId:a0GC4000001WgOXMA0 , resultId:a0GC4000001Wg5CMAS 
        //TestingAPI.NCCreateFileRequest('a0GC4000001WgOXMA0','caseNumber','AAC_4506','83','a0GC4000001Wg5CMAS');
		Set<Id> contentDocumentIds = new Set<Id>();
        for(ContentDocumentLink cdl : [SELECT Id, LinkedEntityId,ContentDocumentId,ContentDocument.FileType FROM ContentDocumentLink where LinkedEntityId =:refId]){
            contentDocumentIds.add(cdl.ContentDocumentId);
        }
		
        
        ContentVersion verData = [SELECT Title,VersionData,ContentDocumentId,FileType,FileExtension,PerfiosFileUploaded__c FROM ContentVersion WHERE ContentDocumentId IN:contentDocumentIds AND Title =:FileName];
    	
        NamasteCreditUploadRequestWrapper requestPayload = new NamasteCreditUploadRequestWrapper();
        requestPayload.document = EncodingUtil.base64Encode(verData.VersionData);
        requestPayload.filename= verData.Title+'.'+verData.FileExtension;
        requestPayload.doc_type_id=docTypeId;
        requestPayload.white_label_id='2548e38e6ee3e0126f1d18c50daaab6f';//2548e38e6ee3e0126f1d18c50daaab6f
        requestPayload.case_id= caseId;
        
        
        Attachment att = new Attachment();
        att.ParentId = resultId;
        att.Body = blob.valueof(JSON.serialize(requestPayload));
        att.Name = verData.Title + '.txt';
        insert att;
    }
    
}