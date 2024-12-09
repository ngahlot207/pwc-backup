@istest
public class IntOCRAhdarServiceResponseProcessorTest {
    
    @testsetup
    static void passportResponseTestFactory(){
        
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        
        Applicant__c appli =  TestDataFactory.createSingleApplicant(true,loanApp.id); 
        
        DocMstr__c docMast =  new DocMstr__c();
        docMast.BU__c = 'Vehicle Loan';
        docMast.DocType__c = 'KYC';
        docMast.Active__c =true;
        docMast.Required__c = true ;
        insert docMast;
        
        string appId = appli.id;
        
        ApplKyc__c app = new ApplKyc__c(Applicant__c = appli.Id,kycDoc__c = 'passport');
        insert app;
        
        List<IntegrationStatusGenerator.IntegrationProgress> intStatusWraList = new  List<IntegrationStatusGenerator.IntegrationProgress>();
        
        IntegrationStatusGenerator.IntegrationProgress intStatusWra1 = new IntegrationStatusGenerator.IntegrationProgress();
        intStatusWra1.StageName ='Applicant Details' ;
        intStatusWra1.IntName = 'PAN-PROFILE';
        intStatusWra1.Status = 'In Progress';
        intStatusWra1.IntDateTime = System.now();
        intStatusWraList.add(intStatusWra1);
        
        IntegrationStatusGenerator.IntegrationProgress intStatusWra2 = new IntegrationStatusGenerator.IntegrationProgress();
        intStatusWra2.StageName ='Bank Details' ;
        intStatusWra2.IntName = 'PASSPORT VERIFICATION';
        intStatusWra2.Status = 'In Progress';
        intStatusWra2.IntDateTime = System.now();
        intStatusWraList.add(intStatusWra2);
        
        List<IntOCRAdharServiceResponseWrapper.Result> resWraList = new List<IntOCRAdharServiceResponseWrapper.Result>();
        IntOCRAdharServiceResponseWrapper.Result resWra = new IntOCRAdharServiceResponseWrapper.Result();
        
        IntOCRAdharServiceResponseWrapper.Details detaWra = new IntOCRAdharServiceResponseWrapper.Details();
        
        IntOCRAdharServiceResponseWrapper.Aadhaar aadharWra = new IntOCRAdharServiceResponseWrapper.Aadhaar();
        aadharWra.value = '98678985678';
        aadharWra.conf = '1';
        detaWra.aadhaar = aadharWra;
        
        IntOCRAdharServiceResponseWrapper.Address nameWra = new IntOCRAdharServiceResponseWrapper.Address();
        nameWra.value = 'salesforce';
        nameWra.conf = '1';
        detaWra.name = nameWra;
        
        IntOCRAdharServiceResponseWrapper.Address addressWra = new IntOCRAdharServiceResponseWrapper.Address();
        addressWra.value = 'street';
        addressWra.conf = '1';
        detaWra.address = addressWra;
        
        IntOCRAdharServiceResponseWrapper.AddressSplit addressSplitWra = new IntOCRAdharServiceResponseWrapper.AddressSplit();
        addressSplitWra.line1 = 'line 1';
        addressSplitWra.line2 = 'line 2';
        addressSplitWra.city = 'Bangalore';
        addressSplitWra.state = 'Karnataka';
        addressSplitWra.pin = '524282';
        detaWra.addressSplit = addressSplitWra;
        
        resWra.details = detaWra;
        resWraList.add(resWra);
        
        IntOCRAdharServiceResponseWrapper panProDet = new IntOCRAdharServiceResponseWrapper();
        panProDet.result = resWraList;
        panProDet.statusCode = 101 ;
        
        List<IntgMsg__c> intMsglist = new List<IntgMsg__c>();
        IntgMsg__c newlit = new IntgMsg__c();
        newlit.Name = 'KYC AADHAR';
        newlit.BU__c = 'Vehicle Loan';
        newlit.Svc__c = 'KYC OCR';
        newlit.IsActive__c = true;
        newlit.RefId__c = appId;
        newlit.Status__c = 'Responded';
        newlit.MStatus__c = 'Blank';
        newlit.RefObj__c = 'Applicant__c';
        newlit.Resp__c = JSON.serialize(panProDet);
        intMsglist.add(newlit);
        insert intMsglist;
    }
    
    
    static testmethod void passportVerTestMethod(){
        
        List<IntgMsg__c> intMsglistToUpdate = new List<IntgMsg__c>();
        
        ApplKyc__c app = [Select Id from ApplKyc__c limit 1];
        string aid = app.Id;
        
        IntgMsg__c intmsgRecord = [SELECT Id,BU__c,Name,Svc__c,IsActive__c,RefId__c,Status__c,RefObj__c,Resp__c,ParentRefId__c FROM IntgMsg__c LIMIT 1];
        intmsgRecord.ParentRefId__c = aid;
        intmsgRecord.Trigger_Platform_Event__c = true;
        system.debug('in test class:::::::'+intmsgRecord);
        update intmsgRecord;
        intMsglistToUpdate.add(intmsgRecord);
        
        publishPlatFormeventControllerClass.platformEventWrapper wrap = new publishPlatFormeventControllerClass.platformEventWrapper();
        wrap.appId = intmsgRecord.RefId__c;
        wrap.intId = intmsgRecord.Id;
        wrap.ServiceName = intmsgRecord.Svc__c;
        wrap.Status = intmsgRecord.Status__c;
        
        
        List<IntOCRAdharServiceResponseWrapper.Result> resWraList = new List<IntOCRAdharServiceResponseWrapper.Result>();
        IntOCRAdharServiceResponseWrapper.Result resWra = new IntOCRAdharServiceResponseWrapper.Result();
        
        IntOCRAdharServiceResponseWrapper.Details detaWra = new IntOCRAdharServiceResponseWrapper.Details();
        
        IntOCRAdharServiceResponseWrapper.Aadhaar aadharWra = new IntOCRAdharServiceResponseWrapper.Aadhaar();
        aadharWra.value = '98678985678';
        aadharWra.conf = '1';
        detaWra.aadhaar = aadharWra;
        
        IntOCRAdharServiceResponseWrapper.Address nameWra = new IntOCRAdharServiceResponseWrapper.Address();
        nameWra.value = 'salesforce';
        nameWra.conf = '1';
        detaWra.name = nameWra;
        
        IntOCRAdharServiceResponseWrapper.Address addressWra = new IntOCRAdharServiceResponseWrapper.Address();
        addressWra.value = 'street';
        addressWra.conf = '1';
        detaWra.address = addressWra;
        
        IntOCRAdharServiceResponseWrapper.AddressSplit addressSplitWra = new IntOCRAdharServiceResponseWrapper.AddressSplit();
        addressSplitWra.line1 = 'line 1';
        addressSplitWra.line2 = 'line 2';
        addressSplitWra.city = 'Bangalore';
        addressSplitWra.state = 'Karnataka';
        addressSplitWra.pin = '524282';
        detaWra.addressSplit = addressSplitWra;
        
        resWra.details = detaWra;
        resWraList.add(resWra);
        
        IntOCRAdharServiceResponseWrapper panProDet = new IntOCRAdharServiceResponseWrapper();
        panProDet.result = resWraList;
        panProDet.statusCode = 101 ;
        
        Test.startTest();
        try{
            IntOCRAhdarServiceResponseProcessor.process(intMsglistToUpdate); 
            IntOCRAhdarServiceResponseProcessor.process(null);
        }catch(NullPointerException ex){
            system.assertEquals('Attempt to de-reference a null object', ex.getMessage());
            system.debug('Attempt to de-reference a null object '+ ex.getMessage());
        }
        Test.stopTest();
    }
    
    static testmethod void passportVerTestMethod1(){
        
        List<IntgMsg__c> intMsglistToUpdate = new List<IntgMsg__c>();
        
        ApplKyc__c app = [Select Id from ApplKyc__c limit 1];
        string aid = app.Id;
        
        IntgMsg__c intmsgRecord = [SELECT Id,BU__c,Name,Svc__c,IsActive__c,RefId__c,Status__c,RefObj__c,Resp__c,ParentRefId__c FROM IntgMsg__c LIMIT 1];
        intmsgRecord.ParentRefId__c = aid;
        intmsgRecord.Trigger_Platform_Event__c = true;
        intmsgRecord.Resp__c = '{"requestId":"someRequestId","result":[{"type":"Aadhaar","details":{"Aadhaar":{"conf":"high","isMasked":"true","value":"1234 5678 9012"},"address":{"conf":"medium","value":"123 Main St"},"addressSplit":{"careOf":"Mr. John","city":"Anytown","district":"District A","houseNumber":"123","landmark":"Near Park","line1":"123 Main St","line2":"Apt 101","locality":"Locality B","pin":"12345","state":"CA","street":"Main St"},"father":{"conf":"low","value":"John Doe Sr."},"husband":{"conf":"low","value":"Mr. Husband"},"imageUrl":{"value":"https://example.com/image.jpg"},"name":{"conf":"medium","value":"John Doe"},"pin":{"conf":"high","value":"12345"},"qr":{"value":"https://example.com/qr.png"},"qualityCheck":{"brightness":"high","isBlackWhite":"false","isBlur":"false","isCutCard":"true"},"dob":{"conf":"high","value":"1990-01-01"},"gender":{"conf":"low","value":"Male"},"mother":{"conf":"low","value":"Jane Doe"}}}],"statusCode":101}';
        system.debug('in test class:::::::'+intmsgRecord);
        update intmsgRecord;
        
        intMsglistToUpdate.add(intmsgRecord);
        
        Test.startTest();
        try{
            IntOCRAhdarServiceResponseProcessor.process(intMsglistToUpdate); 
            IntOCRAhdarServiceResponseProcessor.process(null);
        }catch(NullPointerException ex){
            system.assertEquals('Attempt to de-reference a null object', ex.getMessage());
            system.debug('Attempt to de-reference a null object '+ ex.getMessage());
        }
        Test.stopTest();
    }
    
    static testmethod void passportVerTestMethod2(){
        
        List<IntgMsg__c> intMsglistToUpdate = new List<IntgMsg__c>();
        
        ApplKyc__c app = [Select Id from ApplKyc__c limit 1];
        string aid = app.Id;
        
        IntgMsg__c intmsgRecord = [SELECT Id,BU__c,Name,Svc__c,IsActive__c,RefId__c,Status__c,RefObj__c,Resp__c,ParentRefId__c FROM IntgMsg__c LIMIT 1];
        intmsgRecord.ParentRefId__c = aid;
        intmsgRecord.Trigger_Platform_Event__c = true;
        intmsgRecord.Resp__c = '{"requestId":"someRequestId","result":[{"type":"Aadhaar","details":{"Aadhaar":{"conf":"high","isMasked":"true","value":"1234 5678 9012"},"address":{"conf":"medium","value":"123 Main St"},"addressSplit":{"careOf":"Mr. John","city":"Anytown","district":"District A","houseNumber":"123","landmark":"Near Park","line1":"123 Main St","line2":"Apt 101","locality":"Locality B","pin":"12345","state":"CA","street":"Main St"},"father":{"conf":"low","value":"John Doe Sr."},"husband":{"conf":"low","value":"Mr. Husband"},"imageUrl":{"value":"https://example.com/image.jpg"},"name":{"conf":"medium","value":"John Doe"},"pin":{"conf":"high","value":"12345"},"qr":{"value":"https://example.com/qr.png"},"qualityCheck":{"brightness":"high","isBlackWhite":"false","isBlur":"false","isCutCard":"true"},"dob":{"conf":"high","value":"1990-01-01"},"gender":{"conf":"low","value":"Male"},"mother":{"conf":"low","value":"Jane Doe"}}}],"statusCode":102}';
        system.debug('in test class:::::::'+intmsgRecord);
        update intmsgRecord;
        
        intMsglistToUpdate.add(intmsgRecord);
        
        Test.startTest();
        try{
            IntOCRAhdarServiceResponseProcessor.process(intMsglistToUpdate); 
            IntOCRAhdarServiceResponseProcessor.process(null);
        }catch(NullPointerException ex){
            system.assertEquals('Attempt to de-reference a null object', ex.getMessage());
            system.debug('Attempt to de-reference a null object '+ ex.getMessage());
        }
        Test.stopTest();
    }
    
    static testmethod void passportVerTestMethod3(){
        
        List<IntgMsg__c> intMsglistToUpdate = new List<IntgMsg__c>();
        
        ApplKyc__c app = [Select Id from ApplKyc__c limit 1];
        string aid = app.Id;
        
        IntgMsg__c intmsgRecord = [SELECT Id,BU__c,Name,Svc__c,IsActive__c,RefId__c,Status__c,RefObj__c,Resp__c,ParentRefId__c FROM IntgMsg__c LIMIT 1];
        intmsgRecord.ParentRefId__c = aid;
        intmsgRecord.Trigger_Platform_Event__c = true;
        intmsgRecord.Resp__c = '{"requestId":"someRequestId","result":[{"type":"Aadhaar Front Bottom","details":{"Aadhaar":{"conf":"high","isMasked":"true","value":"1234 5678 9012"},"address":{"conf":"medium","value":"123 Main St"},"addressSplit":{"careOf":"Mr. John","city":"Anytown","district":"District A","houseNumber":"123","landmark":"Near Park","line1":"123 Main St","line2":"Apt 101","locality":"Locality B","pin":"12345","state":"CA","street":"Main St"},"father":{"conf":"low","value":"John Doe Sr."},"husband":{"conf":"low","value":"Mr. Husband"},"imageUrl":{"value":"https://example.com/image.jpg"},"name":{"conf":"medium","value":"John Doe"},"pin":{"conf":"high","value":"12345"},"qr":{"value":"https://example.com/qr.png"},"qualityCheck":{"brightness":"high","isBlackWhite":"false","isBlur":"false","isCutCard":"true"},"dob":{"conf":"high","value":"1990-01-01"},"gender":{"conf":"low","value":"Male"},"mother":{"conf":"low","value":"Jane Doe"}}}],"statusCode":101}';
        system.debug('in test class:::::::'+intmsgRecord);
        update intmsgRecord;
        
        intMsglistToUpdate.add(intmsgRecord);
        
        Test.startTest();
        try{
            IntOCRAhdarServiceResponseProcessor.process(intMsglistToUpdate); 
            IntOCRAhdarServiceResponseProcessor.process(null);
        }catch(NullPointerException ex){
            system.assertEquals('Attempt to de-reference a null object', ex.getMessage());
            system.debug('Attempt to de-reference a null object '+ ex.getMessage());
        }
        Test.stopTest();
    }
    
    static testmethod void passportVerTestMethod4(){
        
        List<IntgMsg__c> intMsglistToUpdate = new List<IntgMsg__c>();
        
        ApplKyc__c app = [Select Id from ApplKyc__c limit 1];
        string aid = app.Id;
        
        IntgMsg__c intmsgRecord = [SELECT Id,BU__c,Name,Svc__c,IsActive__c,RefId__c,Status__c,RefObj__c,Resp__c,ParentRefId__c FROM IntgMsg__c LIMIT 1];
        intmsgRecord.ParentRefId__c = aid;
        intmsgRecord.Trigger_Platform_Event__c = true;
        intmsgRecord.Resp__c = '{"requestId":"someRequestId","result":[{"type":"Aadhaar Front Top","details":{"Aadhaar":{"conf":"high","isMasked":"true","value":"1234 5678 9012"},"address":{"conf":"medium","value":"123 Main St"},"addressSplit":{"careOf":"Mr. John","city":"Anytown","district":"District A","houseNumber":"123","landmark":"Near Park","line1":"123 Main St","line2":"Apt 101","locality":"Locality B","pin":"12345","state":"CA","street":"Main St"},"father":{"conf":"low","value":"John Doe Sr."},"husband":{"conf":"low","value":"Mr. Husband"},"imageUrl":{"value":"https://example.com/image.jpg"},"name":{"conf":"medium","value":"John Doe"},"pin":{"conf":"high","value":"12345"},"qr":{"value":"https://example.com/qr.png"},"qualityCheck":{"brightness":"high","isBlackWhite":"false","isBlur":"false","isCutCard":"true"},"dob":{"conf":"high","value":"1990-01-01"},"gender":{"conf":"low","value":"Male"},"mother":{"conf":"low","value":"Jane Doe"}}}],"statusCode":101}';
        system.debug('in test class:::::::'+intmsgRecord);
        update intmsgRecord;
        
        intMsglistToUpdate.add(intmsgRecord);
        
        Test.startTest();
        try{
            IntOCRAhdarServiceResponseProcessor.process(intMsglistToUpdate); 
            IntOCRAhdarServiceResponseProcessor.process(null);
        }catch(NullPointerException ex){
            system.assertEquals('Attempt to de-reference a null object', ex.getMessage());
            system.debug('Attempt to de-reference a null object '+ ex.getMessage());
        }
        Test.stopTest();
    }
    
        static testmethod void passportVerTestMethod5(){
        
        List<IntgMsg__c> intMsglistToUpdate = new List<IntgMsg__c>();
        
        ApplKyc__c app = [Select Id from ApplKyc__c limit 1];
        string aid = app.Id;
        
        IntgMsg__c intmsgRecord = [SELECT Id,BU__c,Name,Svc__c,IsActive__c,RefId__c,Status__c,RefObj__c,Resp__c,ParentRefId__c FROM IntgMsg__c LIMIT 1];
        intmsgRecord.ParentRefId__c = aid;
        intmsgRecord.Trigger_Platform_Event__c = true;
        intmsgRecord.Resp__c = '{"requestId":"someRequestId","result":[{"type":"Aadhaar Back","details":{"Aadhaar":{"conf":"high","isMasked":"true","value":"1234 5678 9012"},"address":{"conf":"medium","value":"123 Main St"},"addressSplit":{"careOf":"Mr. John","city":"Anytown","district":"District A","houseNumber":"123","landmark":"Near Park","line1":"123 Main St","line2":"Apt 101","locality":"Locality B","pin":"12345","state":"CA","street":"Main St"},"father":{"conf":"low","value":"John Doe Sr."},"husband":{"conf":"low","value":"Mr. Husband"},"imageUrl":{"value":"https://example.com/image.jpg"},"name":{"conf":"medium","value":"John Doe"},"pin":{"conf":"high","value":"12345"},"qr":{"value":"https://example.com/qr.png"},"qualityCheck":{"brightness":"high","isBlackWhite":"false","isBlur":"false","isCutCard":"true"},"dob":{"conf":"high","value":"1990-01-01"},"gender":{"conf":"low","value":"Male"},"mother":{"conf":"low","value":"Jane Doe"}}}],"statusCode":101}';
        system.debug('in test class:::::::'+intmsgRecord);
        update intmsgRecord;
        
        intMsglistToUpdate.add(intmsgRecord);
        
        Test.startTest();
        try{
            IntOCRAhdarServiceResponseProcessor.process(intMsglistToUpdate); 
            IntOCRAhdarServiceResponseProcessor.process(null);
        }catch(NullPointerException ex){
            system.assertEquals('Attempt to de-reference a null object', ex.getMessage());
            system.debug('Attempt to de-reference a null object '+ ex.getMessage());
        }
        Test.stopTest();
    }
}