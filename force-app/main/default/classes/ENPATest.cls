@isTest
private class ENPATest {

    @testsetup
    static void testDataMethod(){
        
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        Applicant__c appli =  TestDataFactory.createSingleApplicant(true,loanApp.id); 
        
    }
    
    @isTest
    static void testGenerateMethod() {
        
        LoanAppl__c loan =[SELECT Id FROM LoanAppl__c LIMIT 1];
        Applicant__c appli = [SELECT Id FROM  Applicant__c LIMIT 1];
        
        List<IntgMsg__c> intMsglist =  TestDataFactory.createIntMsg(true, 'KYC OCR', appli.id, null);
        IntgMsg__c intgMsg = new IntgMsg__c();
        
        intgMsg.ParentRefId__c=loan.id;
        intgMsg.RefId__c =appli.Id ;
       
        ENPARequestGenerator generator = new ENPARequestGenerator();
        generator.generate(intMsglist, 'Test Service', 'Test Process Type'); 
        
        String jsonrequest = '{"uid":"testUid","slk":"testSlk","rrn":"testRrn","env":"testEnv","lat":"testLat","lon":"testLon","devid":"testDevid","refr":"testRefr","sertype":"testSertype","ver":"testVer","txnmode":"testTxnmode","file":"testFile"}';
          
        String jsonresponse = '{"requestId":"8eb39778-4d34-4a75-83a3-d986ddae3aee","result":{"name":{"nameFromPassport":"SRIDEVI","surnameFromPassport":"GUNTUPALLI","nameMatch":true,"nameScore":1},"passportNumber":{"passportNumberFromSource":"S9265723","passportNumberMatch":true},"dateOfIssue":{"dispatchedOnFromSource":"30/01/2019","dateOfIssueMatch":null},"typeOfApplication":"Normal","applicationDate":"28/01/2019"},"statusCode":101,"clientData":{"caseId":"746650859"}}';
        ENPARequestWrapper wrapperresponse = ENPARequestWrapper.parse(jsonresponse);
        ENPAResponseWrapper wrapperrequest= ENPAResponseWrapper.parse(jsonrequest);
            
    }
    
}