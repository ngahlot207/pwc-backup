@istest
public class IntOCRPanResponseProcessorTest {
    
    @testsetup
    static void passportResponseTestFactory(){
        
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        
        Applicant__c appli =  TestDataFactory.createSingleApplicant(true,loanApp.id); 
        
        //DocMstr__c docMast =  TestDataFactory.createDocumentMaster(true,'Pan Card' );
        DocMstr__c docMast =  new DocMstr__c();
        docMast.BU__c = 'Vehicle Loan';
        docMast.DocType__c = 'PAN';
        docMast.Active__c =true;
        docMast.Required__c = true ;
        insert docMast;
        system.debug('docMast::::::'+docMast);
        string appId = appli.id;
        
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
        
        List<IntOCRPanResponseWrapper.cls_result> resWraList = new List<IntOCRPanResponseWrapper.cls_result>();
        IntOCRPanResponseWrapper.cls_result resWra = new IntOCRPanResponseWrapper.cls_result();
        resWra.type = 'Pan';
        IntOCRPanResponseWrapper.cls_details detaWra = new IntOCRPanResponseWrapper.cls_details();
        
        IntOCRPanResponseWrapper.cls_panNo clasPanNowra = new IntOCRPanResponseWrapper.cls_panNo();
        clasPanNowra.value = 'ENTPS7889Z';
        clasPanNowra.conf = '1';
        detaWra.panNo = clasPanNowra;
        
        IntOCRPanResponseWrapper.cls_name clsNamewra = new IntOCRPanResponseWrapper.cls_name();
        clsNamewra.value = 'ENTPS7889Z';
        clsNamewra.conf = '1';
        detaWra.name = clsNamewra;
        
        IntOCRPanResponseWrapper.cls_date dateOfBirthewra = new IntOCRPanResponseWrapper.cls_date();
        dateOfBirthewra.value = '22/03/1994';
        dateOfBirthewra.conf = '1';
        detaWra.dateValue = dateOfBirthewra;
        
        IntOCRPanResponseWrapper.cls_dateOfIssue dateOfIsuuewra = new IntOCRPanResponseWrapper.cls_dateOfIssue();
        dateOfIsuuewra.value = '22/03/1994';
        dateOfIsuuewra.conf = '1';
        detaWra.dateOfIssue = dateOfIsuuewra;
        
        IntOCRPanResponseWrapper.cls_father clasFathWra = new IntOCRPanResponseWrapper.cls_father();
        clasFathWra.value = 'Salesforce';
        clasFathWra.conf = '1';
        detaWra.father = clasFathWra;
        
        resWra.details = detaWra;
        resWraList.add(resWra);
        
        IntOCRPanResponseWrapper panProDet = new IntOCRPanResponseWrapper();
        panProDet.result = resWraList;
        panProDet.statusCode = 101 ;
        String wrapperdata = JSON.serialize(panProDet);
        system.debug('wrapperdataoooo'+wrapperdata);
        
        List<IntgMsg__c> intMsglist = TestDataFactory.createIntMsg(true,'KYC OCR',appId,wrapperdata);
    }
    
    static testmethod void passportVerTestMethod(){
        passportResponseTestFactory();
        Applicant__c appli = [SELECT Id FROM Applicant__c LIMIT 1];
        
        ApplKyc__c ap = new ApplKyc__c(Applicant__c = appli.Id,kycDoc__c = 'pan');
        insert ap;
        
        string Id = ap.Id;
        system.debug('Id00000'+Id);
        List<IntgMsg__c> intMsglistToUpdate = new List<IntgMsg__c>();
        IntgMsg__c intmsgRecord = [SELECT Id,BU__c,Name,Svc__c,IsActive__c,RefId__c,Status__c,RefObj__c,Resp__c,ParentRefId__c FROM IntgMsg__c LIMIT 1];
        intmsgRecord.ParentRefId__c = Id;
        intmsgRecord.Trigger_Platform_Event__c = true;
        update intmsgRecord;
        system.debug('in test class:::::::'+intmsgRecord);
        
        intMsglistToUpdate.add(intmsgRecord);
        
        publishPlatFormeventControllerClass.platformEventWrapper wrap = new publishPlatFormeventControllerClass.platformEventWrapper();
        wrap.appId = intmsgRecord.RefId__c;
        wrap.intId = intmsgRecord.Id;
        wrap.ServiceName = intmsgRecord.Svc__c;
        wrap.Status = intmsgRecord.Status__c;
        
        List<IntOCRPanResponseWrapper.cls_result> resWraList = new List<IntOCRPanResponseWrapper.cls_result>();
        IntOCRPanResponseWrapper.cls_result resWra = new IntOCRPanResponseWrapper.cls_result();
        resWra.type = 'Pan';
        IntOCRPanResponseWrapper.cls_details detaWra = new IntOCRPanResponseWrapper.cls_details();
        
        IntOCRPanResponseWrapper.cls_panNo clasPanNowra = new IntOCRPanResponseWrapper.cls_panNo();
        clasPanNowra.value = 'ENTPS7889Z';
        clasPanNowra.conf = '1';
        detaWra.panNo = clasPanNowra;
        
        IntOCRPanResponseWrapper.cls_name clsNamewra = new IntOCRPanResponseWrapper.cls_name();
        clsNamewra.value = 'ENTPS7889Z';
        clsNamewra.conf = '1';
        detaWra.name = clsNamewra;
        
        IntOCRPanResponseWrapper.cls_date dateOfBirthewra = new IntOCRPanResponseWrapper.cls_date();
        dateOfBirthewra.value = '22/03/1994';
        dateOfBirthewra.conf = '1';
        detaWra.dateValue = dateOfBirthewra;
        
        IntOCRPanResponseWrapper.cls_dateOfIssue dateOfIsuuewra = new IntOCRPanResponseWrapper.cls_dateOfIssue();
        dateOfIsuuewra.value = '22/03/1994';
        dateOfIsuuewra.conf = '1';
        detaWra.dateOfIssue = dateOfIsuuewra;
        
        IntOCRPanResponseWrapper.cls_father clasFathWra = new IntOCRPanResponseWrapper.cls_father();
        clasFathWra.value = 'Salesforce';
        clasFathWra.conf = '1';
        detaWra.father = clasFathWra;
        
        resWra.details = detaWra;
        resWraList.add(resWra);
        
        IntOCRPanResponseWrapper panProDet = new IntOCRPanResponseWrapper();
        panProDet.result = resWraList;
        panProDet.statusCode = 101 ;
        
        Test.startTest();
        try{
            IntOCRPanResponseProcessor.process(intMsglistToUpdate); 
            IntOCRPanResponseProcessor.process(null);
        }catch(NullPointerException ex){
            system.assertEquals('Attempt to de-reference a null object', ex.getMessage());
            system.debug('Attempt to de-reference a null object '+ ex.getMessage());
        }
        
        //IntOCRPanResponseProcessor.createApplicantKYCRecord(panProDet,intmsgRecord.RefId__c);
        
        List<ApplKyc__c>AppKyc = [SELECT Id FROM  ApplKyc__c];
        //system.debug('AppKyc:::::::'+AppKyc);
        //system.assertEquals(4, AppKyc.size());
        
        //IntOCRPanResponseProcessor.updateApplicant(intmsgRecord.RefId__c, panProDet);
        IntOCRPanResponseProcessor.process(intMsglistToUpdate);
        // system.assertEquals('ENTPS7889Z', appli.Pan_No__c);
        Test.stopTest();
    } 
    
    static testmethod void passportVerTestMethod1(){
        passportResponseTestFactory();
        Applicant__c appli = [SELECT Id FROM Applicant__c LIMIT 1];
        
        ApplKyc__c ap = new ApplKyc__c(Applicant__c = appli.Id,kycDoc__c = 'pan');
        insert ap;
        
        string Id = ap.Id;
        
        List<IntOCRPanResponseWrapper.cls_result> resWraList = new List<IntOCRPanResponseWrapper.cls_result>();
        IntOCRPanResponseWrapper.cls_result resWra = new IntOCRPanResponseWrapper.cls_result();
        resWra.type = 'Passport';
        IntOCRPanResponseWrapper.cls_details detaWra = new IntOCRPanResponseWrapper.cls_details();
        
        IntOCRPanResponseWrapper.cls_panNo clasPanNowra = new IntOCRPanResponseWrapper.cls_panNo();
        clasPanNowra.value = 'ENTPS7889Z';
        clasPanNowra.conf = '1';
        detaWra.panNo = clasPanNowra;
        
        IntOCRPanResponseWrapper.cls_name clsNamewra = new IntOCRPanResponseWrapper.cls_name();
        clsNamewra.value = 'ENTPS7889Z';
        clsNamewra.conf = '1';
        detaWra.name = clsNamewra;
        
        IntOCRPanResponseWrapper.cls_date dateOfBirthewra = new IntOCRPanResponseWrapper.cls_date();
        dateOfBirthewra.value = '22/03/1994';
        dateOfBirthewra.conf = '1';
        detaWra.dateValue = dateOfBirthewra;
        
        IntOCRPanResponseWrapper.cls_dateOfIssue dateOfIsuuewra = new IntOCRPanResponseWrapper.cls_dateOfIssue();
        dateOfIsuuewra.value = '22/03/1994';
        dateOfIsuuewra.conf = '1';
        detaWra.dateOfIssue = dateOfIsuuewra;
        
        IntOCRPanResponseWrapper.cls_father clasFathWra = new IntOCRPanResponseWrapper.cls_father();
        clasFathWra.value = 'Salesforce';
        clasFathWra.conf = '1';
        detaWra.father = clasFathWra;
        
        resWra.details = detaWra;
        resWraList.add(resWra);
        
        IntOCRPanResponseWrapper panProDet = new IntOCRPanResponseWrapper();
        panProDet.result = resWraList;
        panProDet.statusCode = 102;
        String wrapperdata = JSON.serialize(panProDet);
        Applicant__c appRec = [Select Id from Applicant__c LIMIT 1];
        String appId = appRec.Id;
        List<IntgMsg__c> intMsglist = TestDataFactory.createIntMsg(true,'KYC OCR',appId,wrapperdata);
        
        List<IntgMsg__c> intMsglistToUpdate = new List<IntgMsg__c>();
        IntgMsg__c intmsgRecord = [SELECT Id,BU__c,Name,Svc__c,IsActive__c,RefId__c,Status__c,RefObj__c,Resp__c,ParentRefId__c FROM IntgMsg__c WHERE Id =: intMsglist[0].Id LIMIT 1];
        intmsgRecord.ParentRefId__c = Id;
        intmsgRecord.Trigger_Platform_Event__c = true;
        update intmsgRecord;
        system.debug('in test class:::::::'+intmsgRecord);
        intMsglistToUpdate.add(intmsgRecord);
        
        publishPlatFormeventControllerClass.platformEventWrapper wrap = new publishPlatFormeventControllerClass.platformEventWrapper();
        wrap.appId = intmsgRecord.RefId__c;
        wrap.intId = intmsgRecord.Id;
        wrap.ServiceName = intmsgRecord.Svc__c;
        wrap.Status = intmsgRecord.Status__c;
        
        
        Test.startTest();
        try{
            IntOCRPanResponseProcessor.process(intMsglistToUpdate); 
            IntOCRPanResponseProcessor.process(null);
        }catch(NullPointerException ex){
            system.assertEquals('Attempt to de-reference a null object', ex.getMessage());
            system.debug('Attempt to de-reference a null object '+ ex.getMessage());
        }
                
        List<ApplKyc__c>AppKyc = [SELECT Id FROM  ApplKyc__c];
        
        IntOCRPanResponseProcessor.process(intMsglistToUpdate);
        Test.stopTest();
    } 
}