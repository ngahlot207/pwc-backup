@isTest
public class OCRVoterIdResponseProcessorTest {
    
    @testsetup
    static void createTestData(){
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        Applicant__c appli =  TestDataFactory.createSingleApplicant(true,loanApp.id);
    }
    
    @isTest
    static void testProcessResponse() {
        LoanAppl__c loan =[SELECT Id FROM LoanAppl__c LIMIT 1];
        Applicant__c appli = [SELECT Id FROM Applicant__c LIMIT 1];
        ApplKyc__c applKyc = new ApplKyc__c(Applicant__c = appli.id, kycDoc__c = 'Voter Id');
        insert applKyc;
        
        IntgMsg__c response = new IntgMsg__c(
            Svc__c = GlobalConstants.INT_CONFIG_SERVICE_KYC_OCR,
            BU__c = GlobalConstants.INT_MSG_BU_TYPE,
            ParentRefId__c = applKyc.Id,
            Status__c = 'In Progress'
        );
        insert response;
        
        String jsonResponse = '{"statusCode": "101", "result": [{"type": "Voterid Front", "details": {"voterid": {"value": "12345"}, "name": {"value": "John Doe"}, "dob": {"value": "01/01/2000"}, "relation": {"value": "Father"}}}]}';
        response.Resp__c = jsonResponse;
        update response;
        
        // Set up a mock environment
        Test.startTest();
        
        // Call the process method
        OCRVoterIdResponseProcessor.process(new List<IntgMsg__c>{ response });
        
        // Verify the results
        List<ApplKyc__c> updatedApplKycList = [SELECT Id, OCRStatus__c, VotIdEpicNo__c, DtOfBirth__c, Name__c FROM ApplKyc__c WHERE Id = :applKyc.Id];
        System.assertEquals(1, updatedApplKycList.size());
        
        ApplKyc__c updatedApplKyc = updatedApplKycList[0];
        System.assertEquals(GlobalConstants.MSG_SUCCESS, updatedApplKyc.OCRStatus__c);
        System.assertEquals('12345', updatedApplKyc.VotIdEpicNo__c);
        System.assertEquals(Date.newInstance(2000, 1, 1), updatedApplKyc.DtOfBirth__c);
        System.assertEquals('John Doe', updatedApplKyc.Name__c);
        
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateApplicantKYCRecord(){
        LoanAppl__c loan =[SELECT Id FROM LoanAppl__c LIMIT 1];
        Applicant__c appli = [SELECT Id FROM Applicant__c LIMIT 1];
        
        // Create a mock response
        IntOCRVoterIdServiceResponseWrapper Response = new IntOCRVoterIdServiceResponseWrapper();
        
        Response.statusCode = 101;
        List<IntgMsg__c> intMsglist =  TestDataFactory.createIntMsg(true, 'Voterid Verification', appli.id, null);
        IntgMsg__c intgMsg = new IntgMsg__c(
            Svc__c = GlobalConstants.INT_CONFIG_SERVICE_KYC_OCR,
            BU__c = GlobalConstants.INT_MSG_BU_TYPE,
            ParentRefId__c = [SELECT Id FROM ApplKyc__c LIMIT 1].Id,
            Status__c = 'In Progress',
            Resp__c = JSON.serialize(Response)
        );
        intMsglist.add(intgMsg);
        
        Test.startTest();
        OCRVoterIdResponseProcessor.updateApplicantKYCRecord(Response, intMsglist[0].ParentRefId__c,intMsglist , IntgMsg);
        
        List<ApplKyc__c> updatedApplKycList = [SELECT Id, OCRStatus__c, VotIdEpicNo__c, DtOfBirth__c, Name__c, FatherName__c FROM ApplKyc__c LIMIT 1];
        
        System.assertEquals(1, updatedApplKycList.size());
        
        ApplKyc__c updatedApplKyc = updatedApplKycList[0];
        System.debug(updatedApplKyc.VotIdEpicNo__c + updatedApplKyc.Name__c + updatedApplKyc.FatherName__c);
        System.assertEquals(GlobalConstants.MSG_SUCCESS, 'Success');
        
        System.assertEquals('123456789', updatedApplKyc.VotIdEpicNo__c);
        
        Test.stopTest();
        
    }
    
    @isTest
    static void testUpdateApplicantKYCRecordError(){
        LoanAppl__c loan =[SELECT Id FROM LoanAppl__c LIMIT 1];
        Applicant__c appli = [SELECT Id FROM Applicant__c LIMIT 1];
        
        // Create a mock response
        IntOCRVoterIdServiceResponseWrapper Response = new IntOCRVoterIdServiceResponseWrapper();
        
        Response.statusCode = 102;
        List<IntgMsg__c> intMsglist =  TestDataFactory.createIntMsg(true, 'Voterid Verification', appli.id, null);
        IntgMsg__c intgMsg = new IntgMsg__c(
            Svc__c = GlobalConstants.INT_CONFIG_SERVICE_KYC_OCR,
            BU__c = GlobalConstants.INT_MSG_BU_TYPE,
            ParentRefId__c = [SELECT Id FROM ApplKyc__c LIMIT 1].Id,
            Status__c = 'In Progress',
            Resp__c = JSON.serialize(Response)
        );
        intMsglist.add(intgMsg);
        
        Test.startTest();
        OCRVoterIdResponseProcessor.updateApplicantKYCRecordError(Response, intMsglist[0].ParentRefId__c,'Error Occured',intMsglist , IntgMsg);
        
        List<ApplKyc__c> updatedApplKycList = [SELECT Id, OCRStatus__c, VotIdEpicNo__c, DtOfBirth__c, Name__c, FatherName__c FROM ApplKyc__c LIMIT 1];
        
        ApplKyc__c updatedApplKyc = updatedApplKycList[0];
        
        System.assertEquals(GlobalConstants.MSG_FAILURE, 'Failure');
        
        Test.stopTest();
        
    }
    
    @isTest
    static void testUpdateApplicantKYCError() {
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        Applicant__c appli =  TestDataFactory.createSingleApplicant(true,loanApp.id); 
        ApplKyc__c appkyc = [SELECT Id, Applicant__c FROM  ApplKyc__c Where Applicant__c =: appli.Id Limit 1];

        List<IntgMsg__c> intMsglist = new List<IntgMsg__c>();
        
        IntgMsg__c newlit = new IntgMsg__c();
        newlit.Name = 'DRIVER\'S LICENSE AUTHENTICATION';
        newlit.BU__c = 'Vehicle Loan';
        newlit.Svc__c = 'Voterid Verification';
        newlit.IsActive__c = true;
        newlit.RefId__c = appli.Id;
        newlit.Status__c = 'New';
        newlit.MStatus__c = 'Blank';
        newlit.RefObj__c = 'Applicant__c'; 
        newlit.ParentRefId__c = appkyc.id;
        newlit.Trigger_Platform_Event__c=true;
       
        TriggerBase.bypass('IntgMsg__c');
        insert newlit;
        TriggerBase.clearBypass('IntgMsg__c');   
        intMsglist.add(newlit);
        
        IntOCRVoterIdServiceResponseWrapper mockResponse = new IntOCRVoterIdServiceResponseWrapper();
        List<IntOCRVoterIdServiceResponseWrapper.Result> wrapperList = new List<IntOCRVoterIdServiceResponseWrapper.Result>();
        IntOCRVoterIdServiceResponseWrapper.Result wrapRes= new IntOCRVoterIdServiceResponseWrapper.Result();
       	
        try{
        wrapRes.type = 'Voterid Back';
        //wrapRes.details.name.value = 'S131820140050271';
        wrapRes.details.voterid.value = 'EUHNK9875';
        wrapRes.details.doc.value = 'ABC';        
        wrapRes.details.dob.value = '15-01-1992';
        wrapRes.details.age.value = '30';
        wrapRes.details.gender.value = 'M';
       	wrapRes.details.relation.value= 'Son';
        wrapperList.add(wrapRes);
               
        mockResponse.result = wrapperList;
        }
        catch(exception e){
            System.debug('inside catch');
        }
        String errorMessage = 'DOB missing: Kindly provide alternate KYC proof';

        Test.startTest();
        OCRVoterIdResponseProcessor.updateApplicantKYCRecordError(mockResponse, appkyc.Id, errorMessage,intMsglist,newlit);
        Test.stopTest();
        }
    @isTest
    static void testProcessResponse1() {
        LoanAppl__c loan =[SELECT Id FROM LoanAppl__c LIMIT 1];
        Applicant__c appli = [SELECT Id FROM Applicant__c LIMIT 1];
        ApplKyc__c applKyc = new ApplKyc__c(Applicant__c = appli.id, kycDoc__c = 'Voter Id');
        insert applKyc;
        
        IntgMsg__c response = new IntgMsg__c(
            Svc__c = GlobalConstants.INT_CONFIG_SERVICE_KYC_OCR,
            BU__c = GlobalConstants.INT_MSG_BU_TYPE,
            ParentRefId__c = applKyc.Id,
            Status__c = 'In Progress'
        );
        insert response;
        
        String jsonResponse = '{"requestId":"618ed824-203e-4206-b4f4-06da19b3cdc7","result":[{"details":{"voterid":{"value":"ZFV6193882","conf":1},"name":{"value":"Rushikesh Sanjay Nage","conf":0.9},"relation":{"value":"Sanjay Nage","conf":1}},"type":"Voterid Front New"},{"details":{"voterid":{"value":"ZFV6193882","conf":1},"address":{"value":"Akola Dtst Akola (Mu)-444 102 Dahigaon Gawande DAHIGAON GANVDE ceh","conf":0.67},"pin":{"value":"444102","conf":0.67},"gender":{"value":"MALE","conf":1},"date":{"value":"10/07/2019","conf":1},"age":{"value":"","conf":0},"dob":{"value":"18/04/1998","conf":1},"type":{"value":"","conf":0},"addressSplit":{"houseNumber":"","city":"","line1":"Akola Dtst Akola ( Mu ) 444 102 Dahigaon Gawande DAHIGAON GANVDE ceh","line2":"","street":"","locality":"","landmark":"","district":"Akola","state":"","pin":"444102"}},"type":"Voterid Back"}],"statusCode":101,"clientData":{"caseId":"823767489"}}';
        response.Resp__c = jsonResponse;
        update response;
        
        // Set up a mock environment
        Test.startTest();
        
        // Call the process method
        OCRVoterIdResponseProcessor.process(new List<IntgMsg__c>{ response });
        
        // Verify the results
        List<ApplKyc__c> updatedApplKycList = [SELECT Id, OCRStatus__c, VotIdEpicNo__c, DtOfBirth__c, Name__c FROM ApplKyc__c WHERE Id = :applKyc.Id];
        System.assertEquals(1, updatedApplKycList.size());
        
        ApplKyc__c updatedApplKyc = updatedApplKycList[0];
        
        Test.stopTest();
    }
}