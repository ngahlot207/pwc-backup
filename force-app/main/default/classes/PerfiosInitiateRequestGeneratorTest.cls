@isTest
private class PerfiosInitiateRequestGeneratorTest {

    @testsetup
    static void testDataMethod(){
        
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        Applicant__c appli =  TestDataFactory.createSingleApplicant(true,loanApp.id); 
       ApplicantEmployment__c  appEmp = TestDataFactory.createApplEmployment(true,appli.id);  
    }
    
    @isTest
    static void testGenerateMethod() {
        
        LoanAppl__c loan =[SELECT Id FROM LoanAppl__c LIMIT 1];
        Applicant__c appli = [SELECT Id FROM  Applicant__c LIMIT 1];
        ApplicantEmployment__c appliEmp = [SELECT Id FROM  ApplicantEmployment__c LIMIT 1];
        
        Applicant__c appToUp=new Applicant__c(id=appli.Id, CustProfile__c='SALARIED' );
        Employer__c empRec= new Employer__c();
        insert empRec;
        ApplicantEmployment__c empToUp=new ApplicantEmployment__c(id=appliEmp.Id, LoanApplicant__c=appli.Id, EmployerName__c= empRec.Id, Others__c='test');
        if (true) {
            TriggerBase.bypass('Applicant__c');
            update appToUp;
            TriggerBase.clearBypass('Applicant__c');
        }
        if (true) {
            TriggerBase.bypass('ApplicantEmployment__c');
            update empToUp;
            TriggerBase.clearBypass('ApplicantEmployment__c');
        }
        
        
        ApplicantEmployment__c appEmpl =[SELECT Id From ApplicantEmployment__c LIMIT 1] ;
        ApplBanking__c appBanking = new ApplBanking__c();
        appBanking.LoanAppl__c = loan.Id;
        appBanking.Appl__c = appli.Id;
        appBanking.SisterCompanyName__c='test';
         appBanking.IsThereChangeInLimitDuringThePeri__c='Yes';
        appBanking.PeriodOfBankingStart__c=system.today();
        appBanking.PeriodOfBankingEnd__c=system.today();
        Insert appBanking;
        
       ApplBankDetail__c appBnkDeta=new ApplBankDetail__c(Year__c='2024', Month__c='Jun', MonthlyLimit__c=20.2, ApplBanking__c=appBanking.Id);
        insert appBnkDeta;
        
        
        List<IntgMsg__c> intMsglist =  TestDataFactory.createIntMsg(true, 'KYC OCR', appli.id, null);
        IntgMsg__c intgMsg = new IntgMsg__c();
        
        intgMsg.ParentRefId__c=appBanking.id;
        intgMsg.RefId__c =appli.Id ;
        intgMsg.Status__c ='Blank' ;
        insert intgMsg;
        intMsglist.add(intgMsg);
       
        PerfiosInitiateRequestGenerator generator = new PerfiosInitiateRequestGenerator();
        generator.generate(intMsglist, 'Test Service', 'Test Process Type'); 
        
        String jsonrequest = '{"uid":"testUid","slk":"testSlk","rrn":"testRrn","env":"testEnv","lat":"testLat","lon":"testLon","devid":"testDevid","refr":"testRefr","sertype":"testSertype","ver":"testVer","txnmode":"testTxnmode","file":"testFile"}';
          
        PerfiosInitiateRequestWrapper wrapperrequest= PerfiosInitiateRequestWrapper.parse(jsonrequest);
        string returnVal=PerfiosAPIController.GetContentType();    
    }
     @isTest
    static void testMultiPartFormDataBody() {
        Blob file = Blob.valueOf('Test File Content');
        String contentType = 'text/plain';
        String filename = 'test.txt';
        Map<String, String> metadataMap = new Map<String, String>{'key1' => 'value1', 'key2' => 'value2'};
        
        Blob resultBlob = PerfiosAPIController.multiPartFormDataBody(file, contentType, filename, metadataMap);
        System.assertNotEquals(null, resultBlob);
    }
    
    @isTest
    static void testReplaceAndUpdateString() {
        String toRemove = 'remove';
        String toAdd = 'add';
        String actualString = 'test_remove_test';
        String splitIdentifier = '_';
        
        String updatedString = PerfiosAPIController.replaceAndUpdateString(toRemove, toAdd, actualString, splitIdentifier);
        System.assertNotEquals(null, updatedString);
        System.assertNotEquals(actualString, updatedString);
       // System.assertEquals('test_add_test', updatedString);
    }
    
    @isTest
    static void testRequestWrapper() {
        PerfiosAPIController.Header header = new PerfiosAPIController.Header();
        header.transactionID = '123';
        header.fileId = 'file123';
        // Set other header properties
        
        PerfiosAPIController.RequestWrapper requestWrapper = new PerfiosAPIController.RequestWrapper();
        requestWrapper.Header = header;
        requestWrapper.Payload = 'Test Payload';
        System.assertNotEquals(null, requestWrapper);
        System.assertNotEquals(null, requestWrapper.Header);
       System.assertNotEquals(null, requestWrapper.Payload);
    }
    
}