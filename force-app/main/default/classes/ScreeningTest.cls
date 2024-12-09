@isTest
private class ScreeningTest {
    
    
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
       
        ScreeningRequestGenerator generator = new ScreeningRequestGenerator();
        generator.generate(intMsglist, 'Test Service', 'Test Process Type'); 
        
         String jsonresponse = '{"requestId":"8eb39778-4d34-4a75-83a3-d986ddae3aee","result":{"name":{"nameFromPassport":"SRIDEVI","surnameFromPassport":"GUNTUPALLI","nameMatch":true,"nameScore":1},"passportNumber":{"passportNumberFromSource":"S9265723","passportNumberMatch":true},"dateOfIssue":{"dispatchedOnFromSource":"30/01/2019","dateOfIssueMatch":null},"typeOfApplication":"Normal","applicationDate":"28/01/2019"},"statusCode":101,"clientData":{"caseId":"746650859"}}';
        ScreeningRequestWrapper wrapperresponse = ScreeningRequestWrapper.parse(jsonresponse);
        
    }
    
    @isTest
    static void testGenerateMethodParentMsg() {
       
        LoanAppl__c loan =[SELECT Id FROM LoanAppl__c LIMIT 1];
        Applicant__c appli = [SELECT Id FROM  Applicant__c LIMIT 1];
        List<IntgMsg__c> intMsglist =  TestDataFactory.createIntMsg(true, 'KYC OCR', appli.id, null);
        IntgMsg__c intgMsg = new IntgMsg__c();
        
        intgMsg.ParentRefId__c=loan.id;
        intgMsg.RefId__c = '';
        
        intMsglist.add(intgMsg);      
        ScreeningRequestGenerator generator = new ScreeningRequestGenerator();
        generator.generate(intMsglist, 'Test Service', 'Test Process Type');   
    }
    
    @isTest
    static void testGenerateMethodEmptyMsg() {
       
       LoanAppl__c loan =[SELECT Id FROM LoanAppl__c LIMIT 1];
        Applicant__c appli = [SELECT Id FROM  Applicant__c LIMIT 1];
        List<IntgMsg__c> intMsglist =  TestDataFactory.createIntMsg(true, 'KYC OCR', appli.id, null);
        IntgMsg__c intgMsg = new IntgMsg__c();
        
        intgMsg.ParentRefId__c=appli.id;
        intgMsg.RefId__c = '';
        
        intMsglist.add(intgMsg);
        ScreeningRequestGenerator generator = new ScreeningRequestGenerator();
        generator.generate(intMsglist, 'Test Service', 'Test Process Type');   
    }
    
    @isTest
    static void testUpdateExisitngResponses() {
       
        LoanAppl__c loan =[SELECT Id FROM LoanAppl__c LIMIT 1];
        Applicant__c appli = [SELECT Id FROM  Applicant__c LIMIT 1];
        
        List<IntgMsg__c> intMsglist =  TestDataFactory.createIntMsg(true, 'KYC OCR', appli.id, null);
        IntgMsg__c intgMsg = new IntgMsg__c();
        
        intgMsg.ParentRefId__c=loan.id;
        intgMsg.RefId__c =appli.id;
        
        intMsglist.add(intgMsg);  
        
        // Create test responses
        List<APIVer__c> responses = new List<APIVer__c>();
        APIVer__c ap= new APIVer__c();
        ap.LoanAplcn__c=loan.Id;
        ap.ApplNme__c='test';
        ap.Appl__c=appli.id;
        responses.add(ap);
        
        insert responses;

        // Call the updateExisitngResposnes method
        Test.startTest();
        ScreeningResponseProcessor.updateExisitngResposnes(responses);
        Test.stopTest();

        // Verify the changes
        // Query the updated records and verify the changes based on your assertions

        // Add assertions as needed
    }
    
    @isTest
    static void testProcessScreeningResponse() {
       LoanAppl__c loan =[SELECT Id FROM LoanAppl__c LIMIT 1];
        Applicant__c appli = [SELECT Id FROM  Applicant__c LIMIT 1];
        
        List<IntgMsg__c> intMsglist =  TestDataFactory.createIntMsg(true, 'KYC OCR', appli.id, null);
        IntgMsg__c intgMsg = new IntgMsg__c();
        
        intgMsg.ParentRefId__c=loan.id;
        intgMsg.RefId__c =appli.id;
        
        intMsglist.add(intgMsg);

        // Create test response wrapper
        ScreeningResponseWrapper responseWrapper = new ScreeningResponseWrapper();
        responseWrapper.Result='<?xml version=\"1.0\" encoding=\"utf-16\"?>\r\n<ScreeningApiResults xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">\r\n <ScreeningResult>\r\n <SystemName>Support1</SystemName>\r\n <RequestId>123412488</RequestId>\r\n <RecordIdentifier>TestRec1</RecordIdentifier>\r\n <Matched>NotMatch</Matched>\r\n <RejectionMessage>Msg</RejectionMessage>\r\n <CaseId xsi:nil=\"true\" />\r\n <AlertCount xsi:nil=\"true\" />\r\n <Alerts>\r\n <Alert>\r\n <CaseId xsi:nil=\"true\" />\r\n <AlertId xsi:nil=\"true\" />\r\n <WatchlistChangeLogActionableId xsi:nil=\"true\" />\r\n <AmlWatchlistId>0</AmlWatchlistId>\r\n <MatchTypeRefEnumValueId xsi:nil=\"true\" />\r\n </Alert>\r\n </Alerts>\r\n </ScreeningResult>\r\n <ScreeningResult>\r\n <SystemName>Support1</SystemName>\r\n <RequestId>123412489</RequestId>\r\n <RecordIdentifier>A-101426</RecordIdentifier>\r\n <Matched>NotMatch</Matched>\r\n <CaseId xsi:nil=\"true\" />\r\n <AlertCount xsi:nil=\"true\" />\r\n <Alerts>\r\n <Alert>\r\n <CaseId xsi:nil=\"true\" />\r\n <AlertId xsi:nil=\"true\" />\r\n <WatchlistChangeLogActionableId xsi:nil=\"true\" />\r\n <AmlWatchlistId>0</AmlWatchlistId>\r\n <MatchTypeRefEnumValueId xsi:nil=\"true\" />\r\n </Alert>\r\n </Alerts>\r\n </ScreeningResult>\r\n</ScreeningApiResults>';
        
        // Create referenceId for the loan application
        Id referenceId = [SELECT Id FROM LoanAppl__c LIMIT 1].Id;

        // Call the processScreeningResponse method
        Test.startTest();
        ScreeningResponseProcessor.processScreeningResponse(responseWrapper, referenceId,intgMsg);
        Test.stopTest();

        
    }
    
    @isTest
    static void testProcessScreeningErrorResponse() {
        LoanAppl__c loan =[SELECT Id FROM LoanAppl__c LIMIT 1];
        Applicant__c appli = [SELECT Id FROM  Applicant__c LIMIT 1];
        
      
        IntgMsg__c intgMsg = new IntgMsg__c();
        intgMsg.Name='Passport Verification';
        intgMsg.BU__c='HL / STL';
        intgMsg.Status__c='New';
        intgMsg.MStatus__c='Blank';
        intgMsg.ParentRefId__c=appli.id;
        intgMsg.RefId__c =appli.id;
        intgmsg.Trigger_Platform_Event__c=true;
        intgmsg.Svc__c='Passport Verification';
        intgMsg.Resp__c='{"requestId":"8eb39778-4d34-4a75-83a3-d986ddae3aee","result":{"name":{"nameFromPassport":"SRIDEVI","surnameFromPassport":"GUNTUPALLI","nameMatch":true,"nameScore":1},"passportNumber":{"passportNumberFromSource":"S9265723","passportNumberMatch":true},"dateOfIssue":{"dispatchedOnFromSource":"30/01/2019","dateOfIssueMatch":null},"typeOfApplication":"Normal","applicationDate":"28/01/2019"},"statusCode":101,"clientData":{"caseId":"746650859"}}';
        insert intgMsg;
      
        // Create test response wrapper
        ScreeningResponseWrapper responseWrapper = new ScreeningResponseWrapper();
        responseWrapper.Message='<?xml version=\"1.0\" encoding=\"utf-16\"?>\r\n<ScreeningApiResults xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">\r\n <ScreeningResult>\r\n <SystemName>Support1</SystemName>\r\n <RequestId>123412488</RequestId>\r\n <RecordIdentifier>TestRec1</RecordIdentifier>\r\n <Matched>NotMatch</Matched>\r\n <CaseId xsi:nil=\"true\" />\r\n <AlertCount xsi:nil=\"true\" />\r\n <Alerts>\r\n <Alert>\r\n <CaseId xsi:nil=\"true\" />\r\n <AlertId xsi:nil=\"true\" />\r\n <WatchlistChangeLogActionableId xsi:nil=\"true\" />\r\n <AmlWatchlistId>0</AmlWatchlistId>\r\n <MatchTypeRefEnumValueId xsi:nil=\"true\" />\r\n </Alert>\r\n </Alerts>\r\n </ScreeningResult>\r\n <ScreeningResult>\r\n <SystemName>Support1</SystemName>\r\n <RequestId>123412489</RequestId>\r\n <RecordIdentifier>TestRec2</RecordIdentifier>\r\n <Matched>NotMatch</Matched>\r\n <CaseId xsi:nil=\"true\" />\r\n <AlertCount xsi:nil=\"true\" />\r\n <Alerts>\r\n <Alert>\r\n <CaseId xsi:nil=\"true\" />\r\n <AlertId xsi:nil=\"true\" />\r\n <WatchlistChangeLogActionableId xsi:nil=\"true\" />\r\n <AmlWatchlistId>0</AmlWatchlistId>\r\n <MatchTypeRefEnumValueId xsi:nil=\"true\" />\r\n </Alert>\r\n </Alerts>\r\n </ScreeningResult>\r\n</ScreeningApiResults>';
        // Populate responseWrapper with required fields

        // Call the processScreeningErrorResponse method
        Test.startTest();
        ScreeningResponseProcessor.processScreeningErrorResponse(responseWrapper, intgMsg);
        Test.stopTest();

       
    }
    
     @isTest
    static void testProcess() {
        LoanAppl__c loan =[SELECT Id FROM LoanAppl__c LIMIT 1];
        Applicant__c appli = [SELECT Id FROM  Applicant__c LIMIT 1];
        
        List<IntgMsg__c> intMsglist =  TestDataFactory.createIntMsg(true, 'KYC OCR', appli.id, null);
        IntgMsg__c intgMsg = new IntgMsg__c();
        
        intgMsg.ParentRefId__c=loan.id;
        intgMsg.RefId__c =appli.id;
        intgMsg.Resp__c='{"requestId":"8eb39778-4d34-4a75-83a3-d986ddae3aee","result":{"name":{"nameFromPassport":"SRIDEVI","surnameFromPassport":"GUNTUPALLI","nameMatch":true,"nameScore":1},"passportNumber":{"passportNumberFromSource":"S9265723","passportNumberMatch":true},"dateOfIssue":{"dispatchedOnFromSource":"30/01/2019","dateOfIssueMatch":null},"typeOfApplication":"Normal","applicationDate":"28/01/2019"},"statusCode":101,"clientData":{"caseId":"746650859"}}';
        
        intMsglist.add(intgMsg);
     
        
        // Call the process method
        Test.startTest();
        ScreeningResponseProcessor.process(intMsglist);
        Test.stopTest();
    }

	@isTest
    static void testProcessCatchBlock() {
        LoanAppl__c loan =[SELECT Id FROM LoanAppl__c LIMIT 1];
        Applicant__c appli = [SELECT Id FROM  Applicant__c LIMIT 1];
        
      
        IntgMsg__c intgMsg = new IntgMsg__c();
        intgMsg.Name='Passport Verification';
        intgMsg.BU__c='HL / STL';
        intgMsg.Status__c='New';
        intgMsg.MStatus__c='Blank';
        intgMsg.ParentRefId__c=appli.id;
        intgmsg.Trigger_Platform_Event__c=true;
        intgmsg.Svc__c='Passport Verification';
        intgMsg.Resp__c='{"requestId":"8eb39778-4d34-4a75-83a3-d986ddae3aee","result":{"name":{"nameFromPassport":"SRIDEVI","surnameFromPassport":"GUNTUPALLI","nameMatch":true,"nameScore":1},"passportNumber":{"passportNumberFromSource":"S9265723","passportNumberMatch":true},"dateOfIssue":{"dispatchedOnFromSource":"30/01/2019","dateOfIssueMatch":null},"typeOfApplication":"Normal","applicationDate":"28/01/2019"},"statusCode":101,"clientData":{"caseId":"746650859"}}';
        insert intgMsg;
      
        // Create test response wrapper
        ScreeningResponseWrapper responseWrapper = new ScreeningResponseWrapper();
        responseWrapper.Result='test';
        responseWrapper.Message='test';
        // Populate responseWrapper with required fields
        
        Id referenceId = [SELECT Id FROM LoanAppl__c LIMIT 1].Id;

        // Call the processScreeningErrorResponse method
        Test.startTest();
        ScreeningResponseProcessor.processScreeningErrorResponse(responseWrapper, intgMsg);
        ScreeningResponseProcessor.processScreeningResponse(responseWrapper, referenceId,intgMsg);
        Test.stopTest();  
    }
}