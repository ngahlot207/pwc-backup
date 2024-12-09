@istest
public class OcrDLServiceResponseProcessorTestClass {
    
    @istest
    static void dlServiceTest1(){
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        Applicant__c appli =  TestDataFactory.createSingleApplicant(true,loanApp.id);
        DocMstr__c docMast  = TestDataFactory.createDocumentMaster(true,'DRIVING LICENCE');

        DocDtl__c docDet = new DocDtl__c();
        docDet.Appl__c = appli.Id;
        docDet.DocMstr__c = docMast.Id ;
        docDet.DocTyp__c = 'PAN';
        //docDet.Name = docMast.Name;
        insert docDet;
        system.debug('docDet::::::'+docDet);
        
        string appId = appli.id;
        
        String jsonResponse = '{"statusCode": 101, "requestId": "12345", "result": [{"type": "DL", "details": {"dob": {"conf": "High", "value": "01/01/1990"}, "dlNo": {"conf": "High", "value": "ABC123456"}, "name": {"conf": "High", "value": "John Doe"}}}]}';
        
        List<IntgMsg__c> intMsglist = TestDataFactory.createIntMsg(true,'DL Authentication',appId,jsonResponse);
        OcrDLServiceResponseProcessor.process(intMsglist);
        List<OcrDLServiceWrapperClass.Result> wrapList = new List<OcrDLServiceWrapperClass.Result>();
        OcrDLServiceWrapperClass.Result resWra = new OcrDLServiceWrapperClass.Result();
        
        resWra.type = 'DL Front';
        OcrDLServiceWrapperClass.Details detaWra = new OcrDLServiceWrapperClass.Details();
        OcrDLServiceWrapperClass.Dob clasdlNowra = new OcrDLServiceWrapperClass.Dob();
        clasdlNowra.value = 'Entbujs789dfh';
        clasdlNowra.conf = '1.0';
        detaWra.dlNo = clasdlNowra;
        
        wrapList.add(resWra);
        OcrDLServiceWrapperClass wrapper = new OcrDLServiceWrapperClass();
        wrapper.Result = wrapList;
        try{
        OcrDLServiceResponseProcessor.createApplicantKYCRecord(wrapper, appId);
        }
        catch(exception e){
            
        }
    }
    
    @istest
    static void dlServiceTest2(){
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        Applicant__c appli =  TestDataFactory.createSingleApplicant(true,loanApp.id);
        DocMstr__c docMast  = TestDataFactory.createDocumentMaster(true,'DRIVING LICENCE');

        DocDtl__c docDet = new DocDtl__c();
        docDet.Appl__c = appli.Id;
        docDet.DocMstr__c = docMast.Id ;
        docDet.DocTyp__c = 'PAN';
        //docDet.Name = docMast.Name;
        insert docDet;
        system.debug('docDet::::::'+docDet);
        
        string appId = appli.id;
        
        String jsonResponse = '{"statusCode": 102, "requestId": "12345", "result": [{"type": "DL", "details": {"dob": {"conf": "High", "value": "01/01/1990"}, "dlNo": {"conf": "High", "value": "ABC123456"}, "name": {"conf": "High", "value": "John Doe"}}}]}';
        
        List<IntgMsg__c> intMsglist = TestDataFactory.createIntMsg(true,'DL Authentication',appId,jsonResponse);
        OcrDLServiceResponseProcessor.process(intMsglist);
        
        
    }
    
    /*static testmethod void dlVerTestMethod(){
        
        List<IntgMsg__c> intMsglistToUpdate = new List<IntgMsg__c>();
        
        IntgMsg__c intmsgRecord = [SELECT Id,BU__c,Name,Svc__c,IsActive__c,RefId__c,Status__c,RefObj__c,Resp__c FROM IntgMsg__c LIMIT 1];
        system.debug('in test class:::::::'+intmsgRecord);
        
        intMsglistToUpdate.add(intmsgRecord);
        
        publishPlatFormeventControllerClass.platformEventWrapper wrap = new publishPlatFormeventControllerClass.platformEventWrapper();
        wrap.appId = intmsgRecord.RefId__c;
        wrap.intId = intmsgRecord.Id;
        wrap.ServiceName = intmsgRecord.Svc__c;
        wrap.Status = intmsgRecord.Status__c;
        
        List<OcrDLServiceWrapperClass.Result> resWraList = new List<OcrDLServiceWrapperClass.Result>();
        OcrDLServiceWrapperClass.Result resWra = new OcrDLServiceWrapperClass.Result();
        resWra.type = 'DL Front';
        OcrDLServiceWrapperClass.Details detaWra = new OcrDLServiceWrapperClass.Details();
        OcrDLServiceWrapperClass.Dob clasdlNowra = new OcrDLServiceWrapperClass.Dob();
        clasdlNowra.value = 'Entbujs789dfh';
        clasdlNowra.conf = '1.0';
        detaWra.dlNo = clasdlNowra;
        
        OcrDLServiceWrapperClass.Dob clasDobwra = new OcrDLServiceWrapperClass.Dob();
        clasDobwra.value = '07/06/1995';
        clasDobwra.conf = '1.0';
        detaWra.dob = clasDobwra;
        
        OcrDLServiceWrapperClass.Dob clasNamewra = new OcrDLServiceWrapperClass.Dob();
        clasNamewra.value = 'Salesforce';
        clasNamewra.conf = '1.0';
        detaWra.name = clasNamewra;
        
        resWra.details = detaWra;
        resWraList.add(resWra);
        
        OcrDLServiceWrapperClass panProDet = new OcrDLServiceWrapperClass();
        panProDet.result = resWraList; 
        
        Test.startTest();
        try{
            //OcrDLServiceResponseProcessor.process(intMsglistToUpdate); 
            //OcrDLServiceResponseProcessor.process(null);
        }catch(NullPointerException ex){
            system.assertEquals('Attempt to de-reference a null object', ex.getMessage());
            system.debug('Attempt to de-reference a null object '+ ex.getMessage());
        }
        OcrDLServiceResponseProcessor.createApplicantKYCRecord(panProDet,intmsgRecord.RefId__c);
        List<ApplKyc__c>AppKyc = [SELECT Id FROM  ApplKyc__c];
        system.assertEquals(1, AppKyc.size());
        Test.stopTest();
    }*/
    
}