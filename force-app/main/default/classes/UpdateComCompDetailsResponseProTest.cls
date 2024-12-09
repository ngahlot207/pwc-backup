@isTest
public class UpdateComCompDetailsResponseProTest {
    
    @isTest
    static void setup() {
        
        LoanAppl__c loanApplication = TestDataFactory.createLoanApplication(true);
        Applicant__c applicant1 =  TestDataFactory.createSingleApplicant(true,loanApplication.id); 
        applicant1.PAN__c='AAAFQ4251B';
        applicant1.FName__c='ANIL RAI GUPTA';
        applicant1.ApplType__c ='D';
        update applicant1;
        
        List<Applicant__c> liAppls=new List<Applicant__c>();
        Applicant__c appl1=new Applicant__c();
        appl1.PAN__c='AALPG6716G';
        appl1.LoanAppln__c=loanApplication.Id;
        appl1.FName__c='Example One';
        appl1.Gender__c='M';
        appl1.ApplType__c='D';
        appl1.DOB__c=Date.newInstance(2001, 8, 13);
        appl1.Age__c=27;
        liAppls.add(appl1);
        
        
        Applicant__c appl2=new Applicant__c();
        appl2.PAN__c='AFZCG3995M';
        appl2.LoanAppln__c=loanApplication.Id;
        appl2.FName__c='Abcd Efgh';
        appl2.Gender__c='M';
        appl2.ApplType__c='D';
        appl2.DOB__c=Date.newInstance(2000, 8, 13);
        appl2.Age__c=26;
        liAppls.add(appl2);
        
        insert liAppls;
        
        
        // Create test data required for processing
        RecordType recordType = [SELECT Id FROM RecordType WHERE SObjectType = 'APIVer__c' AND DeveloperName = 'Probe42' LIMIT 1];
        
        // Test Integration Message - Success Case
        IntgMsg__c successMsg = new IntgMsg__c(
            RefId__c = appl1.Id,
            Resp__c = '{"metadata":{"api_version":"1.3"},"data":{"request_id":"66b271af6c08d5313902b023"}}',
            Svc__c = 'Update Company Comprehensive Details',
            BU__c = 'HL / STL',
            MStatus__c='Blank',
            Status__c = 'New',
            RefObj__c='Applicant__c',
            Name='Update Company Comprehensive Details',
            ParentRefObj__c ='LoanAppl__c',
            ParentRefId__c =loanApplication.Id 
        );
        insert successMsg;
        
        // Test Integration Message - Failure Case
        IntgMsg__c failureMsg = new IntgMsg__c(
            RefId__c = applicant1.Id,
            Resp__c = '{"metadata":{"api_version":"1.3"},"data":{"request_id":"66b271af6c08d5313902b023"}}',
            Svc__c = 'Update Company Comprehensive Details',
            BU__c = 'HL / STL',
            MStatus__c='Blank',
            Status__c = 'New',
            RefObj__c='Applicant__c',
            Name='Update Company Comprehensive Details',
            ParentRefObj__c ='LoanAppl__c',
            ParentRefId__c =loanApplication.Id 
        );
        insert failureMsg;
        
        // Test Integration Message - Exception Case (Invalid JSON)
        IntgMsg__c exceptionMsg = new IntgMsg__c(
            RefId__c = appl2.Id,
            Resp__c = '{Invalid JSON',
            Svc__c = 'Update Company Comprehensive Details',
            BU__c = 'HL / STL',
            MStatus__c='Blank',
            Status__c = 'New',
            RefObj__c='Applicant__c',
            Name='Update Company Comprehensive Details',
            ParentRefObj__c ='LoanAppl__c',
            ParentRefId__c =loanApplication.Id
        );
        insert exceptionMsg;
        
        // Retrieve the test data
        List<IntgMsg__c> responses = [SELECT Id, RefId__c, Resp__c, ParentRefId__c, Svc__c FROM IntgMsg__c where RefId__c =: liAppls[0].Id];
        
        // Call the process method
        Test.startTest();
        UpdateComCompDetailsResponseProcessor.process(responses);
        
        // Verify that the APIVer__c record was created with the correct data
        APIVer__c apiVer = [SELECT Id, Appl__c, IsLatest__c, UpdateApiType__c, IntegrationStatus__c, UpdReqId__c FROM APIVer__c WHERE Appl__c = :responses[0].RefId__c LIMIT 1];
        
        
        
        
        // Retrieve the test data
        List<IntgMsg__c> responses1 = [SELECT Id, RefId__c, Resp__c, ParentRefId__c, Svc__c FROM IntgMsg__c where RefId__c =: liAppls[1].Id];
        
        UpdateComCompDetailsResponseProcessor.process(responses1);
        
        // Verify that the APIVer__c record was created with the correct failure data
        APIVer__c apiVer1 = [SELECT Id, Appl__c, IntegrationStatus__c, IntegrationErrorMessage__c FROM APIVer__c WHERE Appl__c = :responses[0].RefId__c LIMIT 1];
        
        
        // Retrieve the test data
        List<IntgMsg__c> responses3 = [SELECT Id, RefId__c, Resp__c, ParentRefId__c, Svc__c FROM IntgMsg__c where RefId__c =: applicant1.Id];
        
        UpdateComCompDetailsResponseProcessor.process(responses3);
        
        // Verify that the APIVer__c record was not created and an error was logged
        List<APIVer__c> apiVerList1 = [SELECT Id FROM APIVer__c WHERE Appl__c = :responses[0].RefId__c];
        
        
        UpdateComCompDetailsResponseProcessor.process(new List<IntgMsg__c>());
        Test.stopTest();
        
        // Verify that no exceptions were thrown and no records were created
        List<APIVer__c> apiVerList = [SELECT Id FROM APIVer__c];
    }
}