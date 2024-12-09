@istest
public class IntOCRPassportResponseProcessorTest {
    
    @testsetup
    static void passportResponseTestFactory(){
      
            LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
            
            Applicant__c appli =  TestDataFactory.createSingleApplicant(true,loanApp.id);
            
            DocMstr__c docMast  = TestDataFactory.createDocumentMaster(true,'Passport');
         
            ApplKyc__c app = new ApplKyc__c(Applicant__c = appli.Id,kycDoc__c = 'passport');
        	insert app;
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
            
            List<IntOCRPassportResponseWrapper.Result> resWraList = new List<IntOCRPassportResponseWrapper.Result>();
            IntOCRPassportResponseWrapper.Result resWra = new IntOCRPassportResponseWrapper.Result();
            resWra.type = 'Passport Front';
            IntOCRPassportResponseWrapper.Details detaWra = new IntOCRPassportResponseWrapper.Details();
            
            IntOCRPassportResponseWrapper.PassportNum passportnum = new IntOCRPassportResponseWrapper.PassportNum();
            passportnum.value = 'ENRYKN868MK';
            passportnum.conf = '1.0';
            detaWra.passportNum = passportnum;
            
            IntOCRPassportResponseWrapper.PassportNum dobWra = new IntOCRPassportResponseWrapper.PassportNum();
            dobWra.value = '07/06/1995';
            dobWra.conf = '1.0';
            detaWra.dob = dobWra;
        
            IntOCRPassportResponseWrapper.PassportNum givenName = new IntOCRPassportResponseWrapper.PassportNum();
            givenName.value = 'givenName';
            givenName.conf = '1.0';
            detaWra.surname = givenName;
            
            IntOCRPassportResponseWrapper.PassportNum doiWra = new IntOCRPassportResponseWrapper.PassportNum();
            doiWra.value = '24/09/2012';
            doiWra.conf = '1.0';
            detaWra.doi = doiWra;
            
            IntOCRPassportResponseWrapper.PassportNum surnameWra = new IntOCRPassportResponseWrapper.PassportNum();
            surnameWra.value = 'surname';
            surnameWra.conf = '1.0';
            detaWra.surname = surnameWra;
            
            IntOCRPassportResponseWrapper.PassportNum doeWra = new IntOCRPassportResponseWrapper.PassportNum();
            doeWra.value = '23/09/2022';
            doeWra.conf = '1.0';
            detaWra.doe = doeWra;
            
            resWra.details = detaWra;
            resWraList.add(resWra);
            
            IntOCRPassportResponseWrapper panProDet = new IntOCRPassportResponseWrapper();
            panProDet.result = resWraList;
            panProDet.statusCode = 101 ;
            
            String wrapperdata = JSON.serialize(panProDet);
            
            List<IntgMsg__c> intMsglist = TestDataFactory.createIntMsg(true,'KYC OCR',appId,wrapperdata);

    }
    
    static testmethod void passportVerTestMethod(){

            List<IntgMsg__c> intMsglistToUpdate = new List<IntgMsg__c>();
            ApplKyc__c app = [Select Id from ApplKyc__c limit 1];
            string aid = app.Id;
            IntgMsg__c intmsgRecord = [SELECT Id,BU__c,Name,Svc__c,IsActive__c,RefId__c,Status__c,RefObj__c,Resp__c,ParentRefId__c FROM IntgMsg__c LIMIT 1];
            intmsgRecord.Trigger_Platform_Event__c = true;
        	intmsgRecord.ParentRefId__c = aid;
			update intmsgRecord;
            system.debug('in test class:::::::'+intmsgRecord);
            
            intMsglistToUpdate.add(intmsgRecord);
            
            publishPlatFormeventControllerClass.platformEventWrapper wrap = new publishPlatFormeventControllerClass.platformEventWrapper();
            wrap.appId = intmsgRecord.RefId__c;
            wrap.intId = intmsgRecord.Id;
            wrap.ServiceName = intmsgRecord.Svc__c;
            wrap.Status = intmsgRecord.Status__c;
            
            List<IntOCRPassportResponseWrapper.Result> resWraList = new List<IntOCRPassportResponseWrapper.Result>();
            IntOCRPassportResponseWrapper.Result resWra = new IntOCRPassportResponseWrapper.Result();
            resWra.type = 'Passport Front';
            IntOCRPassportResponseWrapper.Details detaWra = new IntOCRPassportResponseWrapper.Details();
            
            IntOCRPassportResponseWrapper.PassportNum passportnum = new IntOCRPassportResponseWrapper.PassportNum();
            passportnum.value = 'ENRYKN868MK';
            passportnum.conf = '1.0';
            detaWra.passportNum = passportnum;
            
            IntOCRPassportResponseWrapper.PassportNum surnameWra = new IntOCRPassportResponseWrapper.PassportNum();
            surnameWra.value = 'surname';
            surnameWra.conf = '1.0';
            detaWra.surname = surnameWra;
            
            IntOCRPassportResponseWrapper.PassportNum dobWra = new IntOCRPassportResponseWrapper.PassportNum();
            dobWra.value = '07/06/1995';
            dobWra.conf = '1.0';
            detaWra.dob = dobWra;
            
            IntOCRPassportResponseWrapper.PassportNum doiWra = new IntOCRPassportResponseWrapper.PassportNum();
            doiWra.value = '24/09/2012';
            doiWra.conf = '1.0';
            detaWra.doi = doiWra;
            
            IntOCRPassportResponseWrapper.PassportNum doeWra = new IntOCRPassportResponseWrapper.PassportNum();
            doeWra.value = '23/09/2022';
            doeWra.conf = '1.0';
            detaWra.doe = doeWra;
            
            resWra.details = detaWra;
            resWraList.add(resWra);
            
            IntOCRPassportResponseWrapper panProDet = new IntOCRPassportResponseWrapper();
            panProDet.result = resWraList;
            panProDet.statusCode = 101 ;
            
            Test.startTest();
            try{
                IntOCRPassportResponseProcessor.process(intMsglistToUpdate); 
                IntOCRPassportResponseProcessor.process(null);
            }catch(NullPointerException ex){
                system.assertEquals('Attempt to de-reference a null object', ex.getMessage());
                system.debug('Attempt to de-reference a null object '+ ex.getMessage());
            }
            IntOCRPassportResponseProcessor.createApplicantKYCRecord(panProDet,intmsgRecord.RefId__c);
            List<ApplKyc__c>AppKyc = [SELECT Id FROM  ApplKyc__c];
            //system.assertEquals(3, AppKyc.size());
            Test.stopTest();
      
    }
    
        static testmethod void passportVerTestMethod1(){

            List<IntgMsg__c> intMsglistToUpdate = new List<IntgMsg__c>();
            ApplKyc__c app = [Select Id from ApplKyc__c limit 1];
            string aid = app.Id;
            IntgMsg__c intmsgRecord = [SELECT Id,BU__c,Name,Svc__c,IsActive__c,RefId__c,Status__c,RefObj__c,Resp__c,ParentRefId__c FROM IntgMsg__c LIMIT 1];
        	intmsgRecord.Resp__c = '{"statusCode": 102, "requestId": "12345", "result": [{"type": "passport", "details": {"passportNum": {"value": "AB123456", "conf": "90"}}}]}';
            intmsgRecord.Trigger_Platform_Event__c = true;
            intmsgRecord.ParentRefId__c = aid;
            update intmsgRecord;
            system.debug('in test class:::::::'+intmsgRecord);
            
            intMsglistToUpdate.add(intmsgRecord);
                  
            Test.startTest();
            try{
                IntOCRPassportResponseProcessor.process(intMsglistToUpdate); 
                IntOCRPassportResponseProcessor.process(null);
            }catch(NullPointerException ex){
                system.assertEquals('Attempt to de-reference a null object', ex.getMessage());
                system.debug('Attempt to de-reference a null object '+ ex.getMessage());
            }
            //IntOCRPassportResponseProcessor.createApplicantKYCRecord(panProDet,intmsgRecord.RefId__c);
            List<ApplKyc__c>AppKyc = [SELECT Id FROM  ApplKyc__c];
            //system.assertEquals(3, AppKyc.size());
            Test.stopTest();
      
    }
    
     static testmethod void passportVerTestMethod2(){

            List<IntgMsg__c> intMsglistToUpdate = new List<IntgMsg__c>();
            ApplKyc__c app = [Select Id from ApplKyc__c limit 1];
            string aid = app.Id;
            IntgMsg__c intmsgRecord = [SELECT Id,BU__c,Name,Svc__c,IsActive__c,RefId__c,Status__c,RefObj__c,Resp__c,ParentRefId__c FROM IntgMsg__c LIMIT 1];
        	intmsgRecord.Resp__c = '{"statusCode":101,"requestId":"someRequestId","result":[{"type":"Passport Front","details":{"passportNum":{"value":"ABCD12345","conf":"high"},"givenName":{"value":"John","conf":"medium"},"surname":{"value":"Doe","conf":"high"},"gender":{"value":"Male","conf":"low"},"dob":{"value":"1990-01-01","conf":"high"},"placeOfBirth":{"value":"Anytown","conf":"medium"},"countryCode":{"value":"US","conf":"high"},"nationality":{"value":"American","conf":"high"},"placeOfIssue":{"value":"Anyplace","conf":"low"},"doi":{"value":"2022-01-01","conf":"high"},"doe":{"value":"2032-01-01","conf":"high"},"type":{"value":"Type A","conf":"low"},"mrz":{"line1":"YYZD123456<1<1234567890123456789012345678901","line2":"1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890","conf":"medium"},"father":{"value":"John Doe Sr.","conf":"medium"},"mother":{"value":"Jane Doe","conf":"medium"},"spouse":{"value":"Sarah Doe","conf":"low"},"address":{"value":"123 Main St","conf":"medium"},"pin":{"value":"12345","conf":"high"},"oldPassportNum":{"value":"WXYZ98765","conf":"low"},"oldDoi":{"value":"2012-01-01","conf":"low"},"fileNum":{"value":"FILE123","conf":"low"},"addressSplit":{"city":"Anytown","district":"District A","pin":"12345","locality":"Locality B","line2":"Apt 101","line1":"123 Main St","state":"CA","street":"Main St","landmark":"Near Park","houseNumber":"123"}}}]}';
            intmsgRecord.Trigger_Platform_Event__c = true;
            intmsgRecord.ParentRefId__c = aid;
            update intmsgRecord;
            system.debug('in test class:::::::'+intmsgRecord);
            
            intMsglistToUpdate.add(intmsgRecord);
            
            Test.startTest();
            try{
                IntOCRPassportResponseProcessor.process(intMsglistToUpdate); 
                IntOCRPassportResponseProcessor.process(null);
            }catch(NullPointerException ex){
                system.assertEquals('Attempt to de-reference a null object', ex.getMessage());
                system.debug('Attempt to de-reference a null object '+ ex.getMessage());
            }
            //IntOCRPassportResponseProcessor.createApplicantKYCRecord(panProDet,intmsgRecord.RefId__c);
            List<ApplKyc__c>AppKyc = [SELECT Id FROM  ApplKyc__c];
            //system.assertEquals(3, AppKyc.size());
            Test.stopTest();
      
    }
    
    static testmethod void passportVerTestMethod3(){

            List<IntgMsg__c> intMsglistToUpdate = new List<IntgMsg__c>();
            ApplKyc__c app = [Select Id from ApplKyc__c limit 1];
            string aid = app.Id;
            IntgMsg__c intmsgRecord = [SELECT Id,BU__c,Name,Svc__c,IsActive__c,RefId__c,Status__c,RefObj__c,Resp__c,ParentRefId__c FROM IntgMsg__c LIMIT 1];
        	intmsgRecord.Resp__c = '{"statusCode":101,"requestId":"someRequestId","result":[{"type":"Passport Back","details":{"passportNum":{"value":"ABCD12345","conf":"high"},"givenName":{"value":"John","conf":"medium"},"surname":{"value":"Doe","conf":"high"},"gender":{"value":"Male","conf":"low"},"dob":{"value":"1990-01-01","conf":"high"},"placeOfBirth":{"value":"Anytown","conf":"medium"},"countryCode":{"value":"US","conf":"high"},"nationality":{"value":"American","conf":"high"},"placeOfIssue":{"value":"Anyplace","conf":"low"},"doi":{"value":"2022-01-01","conf":"high"},"doe":{"value":"2032-01-01","conf":"high"},"type":{"value":"Type A","conf":"low"},"mrz":{"line1":"YYZD123456<1<1234567890123456789012345678901","line2":"1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890","conf":"medium"},"father":{"value":"John Doe Sr.","conf":"medium"},"mother":{"value":"Jane Doe","conf":"medium"},"spouse":{"value":"Sarah Doe","conf":"low"},"address":{"value":"123 Main St","conf":"medium"},"pin":{"value":"12345","conf":"high"},"oldPassportNum":{"value":"WXYZ98765","conf":"low"},"oldDoi":{"value":"2012-01-01","conf":"low"},"fileNum":{"value":"FILE123","conf":"low"},"addressSplit":{"city":"Anytown","district":"District A","pin":"12345","locality":"Locality B","line2":"Apt 101","line1":"123 Main St","state":"CA","street":"Main St","landmark":"Near Park","houseNumber":"123"}}}]}';
            intmsgRecord.Trigger_Platform_Event__c = true;
            intmsgRecord.ParentRefId__c = aid;
            update intmsgRecord;
            system.debug('in test class:::::::'+intmsgRecord);
            
            intMsglistToUpdate.add(intmsgRecord);
            
            Test.startTest();
            try{
                IntOCRPassportResponseProcessor.process(intMsglistToUpdate); 
                IntOCRPassportResponseProcessor.process(null);
            }catch(NullPointerException ex){
                system.assertEquals('Attempt to de-reference a null object', ex.getMessage());
                system.debug('Attempt to de-reference a null object '+ ex.getMessage());
            }
            //IntOCRPassportResponseProcessor.createApplicantKYCRecord(panProDet,intmsgRecord.RefId__c);
            List<ApplKyc__c>AppKyc = [SELECT Id FROM  ApplKyc__c];
            //system.assertEquals(3, AppKyc.size());
            Test.stopTest();
      
    }
}