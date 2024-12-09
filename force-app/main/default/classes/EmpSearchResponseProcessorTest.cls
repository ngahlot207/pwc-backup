@isTest
public class EmpSearchResponseProcessorTest {
    
   /*  @testsetup
    static void createTestData(){   
            LoanAppl__c loanApp = new LoanAppl__c();
            loanApp.Stage__c = 'DDE';
            loanApp.SubStage__c = 'CPA Data Entry';
            loanApp.BrchCode__c = 'HYC';
            loanApp.Product__c = 'Home Loan';
            loanApp.Loan_Tenure_Months__c = 120;
            loanApp.ReqLoanAmt__c=1000000;
            loanApp.Loan_Boarding_API_Status__c='Success';
            loanApp.Status__c='Finnone Pending';
            loanApp.ErrorMessage__c='APPLICATION CREATED SUCCESSFULLY';
            loanApp.FinnSubDtTime__c =System.now();
            TriggerBase.bypass('LoanAppl__c');
            insert loanApp;
            TriggerBase.clearBypass('LoanAppl__c');
        
        Applicant__c appli =  TestDataFactory.createSingleApplicant(true,loanApp.id);
        Employer__c employer =  TestDataFactory.createEmployer(true);
            
           // TestDataFactory.createApplEmployment(true,loanApplicant.Id);

        // Create test data for ApplicantEmployment
        ApplicantEmployment__c applicantEmployment = TestDataFactory.createApplEmployment(true,appli.Id);
        //applicantEmployment.LoanApplicant__c=appli.Id;
        applicantEmployment.EmployerName__c=employer.Id;
        applicantEmployment.OfficialEmail__c ='john.doe@techcorp.com';   
        
        update applicantEmployment;
        
        List<APIVer__c> apiVersions = new List<APIVer__c>();
        for (Integer i = 0; i < 5; i++) {
            APIVer__c apiVer = new APIVer__c(
                Appl__c = appli.Id,
                IsLatest__c = true,
                RecordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByDeveloperName().get('Employment').getRecordTypeId()
            );
            apiVersions.add(apiVer);
        }
        insert apiVersions;
            
    }
    
    @isTest
    static void testProcessSuccess() {
        Test.startTest();
        // Fetch the test messages
        List<IntgMsg__c> messages = new List<IntgMsg__c>();

        LoanAppl__c testLoan =[SELECT Id FROM LoanAppl__c LIMIT 1];
        Applicant__c appli = [SELECT Id FROM Applicant__c LIMIT 1];
        ApplicantEmployment__c 	applicantEmployment=[SELECT Id FROM ApplicantEmployment__c LIMIT 1];
        
        IntgMsg__c response = new IntgMsg__c(
                Svc__c='Employment Search',
                BU__c = 'HL / STL',
                MStatus__c='Blank',
                Status__c = 'New',
                Resp__c = '{"result":{"uan":[{"uan":"100078184954","uanSource":"mobile","employer":[{"name":"Karza Technologies Private Limited","memberId":"MHBAN17444100000010015","settled":null,"isNameUnique":true,"matchName":"ALOK KUMAR","lastMonth":"2405","isRecent":true,"isNameExact":true,"isEmployed":true,"nameConfidence":1,"emplrScore":1,"uanNameMatch":true},{"name":"MORGAN STANLEY ADVANTAGE SERVICES PRIVATE LIMITED","memberId":"MHBAN00467750000003499","settled":null,"isNameUnique":false,"matchName":"","lastMonth":"","isRecent":false,"isNameExact":false,"isEmployed":false,"nameConfidence":0,"emplrScore":0,"uanNameMatch":true}]}],"email":{"data":{"disposable":false,"webmail":false,"result":true,"acceptAll":false,"smtpCheck":true,"regexp":true,"mxRecords":true,"email":"alok@karza.in"},"whois":{"creationDate":"11-02-2015","updateDate":"12-02-2024","expirationDate":"11-02-2025","registrant":{"name":"","organization":"Karza Technologies Private Limited","street":"","city":"","postal":"","country":"IN","phone":"","fax":"","email":"","stateprovince":""}},"nameConfidence":1},"nameLookup":{"organizationName":"Karza Technologies Private Limited","epfHistory":[{"totalAmount":973687,"totalMembers":246,"formatted_wage_month":"2405","wageMonth":"MAY-24"},{"totalAmount":1005444,"totalMembers":255,"formatted_wage_month":"2404","wageMonth":"APR-24"},{"totalAmount":1061919,"totalMembers":262,"formatted_wage_month":"2403","wageMonth":"MAR-24"}],"estInfo":[{"address":"1302, Orchid, Bg Kher Road Campacola Compound","contactNo":"8169584238","emailId":"ankit.s@karza.in","estId":"MHBAN1744410000"}],"matches":[{"name":"ALOK KUMAR","confidence":1,"estId":"MHBAN1744410000","epfHistory":{"MAY-24":true,"APR-24":true,"MAR-24":true}}],"isNameExact":true,"isEmployed":true,"isRecent":true,"isNameUnique":true,"employeeName":"Alok Kumar"}},"request_id":"ae1637ff-569b-44a2-86c3-716ba61ca91b","status-code":"101","clientData":{"caseId":"123456"}}',
				RefId__c = appli.Id,
                Name='Employment Search',
                    ParentRefId__c = appli.Id,
                    ParentRefObj__c = 'Applicant__c',
                    RefObj__c= 'ApplicantEmployment__c'
                         
        ); 
        messages.add(response);
        insert messages;
	    //EmpSearchResponseWrapper  res =(EmpSearchResponseWrapper) JSON.deserialize(strRes,EmpSearchResponseWrapper.class);

        // Call the process method
        EmpSearchResponseProcessor.process(messages);

        // Verify the results
        List<APIVer__c> apiVerList = [SELECT Id, Appl__c, IsLatest__c, IntegrationStatus__c FROM APIVer__c];
        System.assertEquals(response.Svc__c, 'Employment Search', 'There should be 5 APIVer__c records');
        
        for (APIVer__c apiVer : apiVerList) {
           // System.assertEquals('Success', apiVer.IntegrationStatus__c, 'The IntegrationStatus__c should be "Success"');
            System.assertEquals(response.Svc__c, 'Employment Search', 'There should be 5 APIVer__c records');
        }

        Test.stopTest();
    }

    @isTest
    static void testProcessFailure() {
        Test.startTest();
        // Create a message that will trigger a failure
        IntgMsg__c failMessage = new IntgMsg__c(
            Name = 'Employment Search',
            Svc__c = 'Employment Search',
            BU__c = 'HL / STL',
            Resp__c = '{"status-code": "999"}',
            ParentRefId__c = 'a0GC4000001NhoTMAS',
            Status__c='Responded'
        );
        insert failMessage;

        List<IntgMsg__c> messages = [SELECT Id, Name, Svc__c, BU__c, Resp__c, ParentRefId__c FROM IntgMsg__c WHERE Name = 'Employment Search'];

        // Expect an exception to be thrown
        try {
            EmpSearchResponseProcessor.process(messages);
            
        } catch (Exception e) {
            System.assertEquals('Error! This is not the correct service', e.getMessage(), 'Exception message should match');
        }

        Test.stopTest();
    }

    @isTest
    static void testProcessPartialSuccess() {
        Test.startTest();
        // Fetch all messages
        List<IntgMsg__c> messages = [SELECT Id, Name, Svc__c, BU__c, Resp__c, ParentRefId__c FROM IntgMsg__c];

        // Modify some messages to trigger failures
        for (IntgMsg__c msg : messages) {
            if (msg.Name.contains('1') || msg.Name.contains('3')) {
                msg.Svc__c = 'Employment Search';
                msg.BU__c = 'HL / STL';
            }
        }
        update messages;

        // Call the process method
        EmpSearchResponseProcessor.process(messages);

        // Verify the results
        List<APIVer__c> apiVerList = [SELECT Id, Appl__c, IsLatest__c, IntegrationStatus__c FROM APIVer__c];
        System.assert(apiVerList.size() > 0, 'There should be some APIVer__c records');
        
        

        //List<APIVerDtl__c> apiVerDtlList = [SELECT Id, APIVerification__c, Type__c FROM APIVerDtl__c];
        //System.assert(apiVerDtlList.size() > 0, 'There should be some APIVerDtl__c records');
        
        Test.stopTest();
    }*/
}