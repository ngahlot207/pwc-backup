@isTest

public class KycOcrResponseProcessorTest {
    @isTest
    static void testProcessMethodWithAadhaar() {
       
       LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
        
        
            Applicant__c appli = new Applicant__c();
		appli.LoanAppln__c =loan.Id;
        appli.LName__c = 'test';
        appli.MobNumber__c = '9876567899';
        appli.LName__c = 'method';
        appli.ApplType__c = 'P';
        if (true) {
            TriggerBase.bypass('Applicant__c');
            insert appli;
            TriggerBase.clearBypass('Applicant__c');
        }
        
        
       

// Define a list of KYC document types
 List<ApplKyc__c> aplist = new List<ApplKyc__c>();
List<String> kycDocTypes = new List<String>{'Voter Id','Pan', 'Driving License', 'Passport', 'Aadhaar'};

// Iterate over each KYC document type and create a corresponding ApplKyc__c record
for (String kycDocType : kycDocTypes) {
    ApplKyc__c kycRecord = new ApplKyc__c();
    kycRecord.Applicant__c =appli.Id;
    kycRecord.kycDoc__c = kycDocType;
    aplist.add(kycRecord);
}
		
			insert aplist;
        List<ApplKyc__c>  kyclist = [select id from ApplKyc__c];
     /*   List<ApplKyc__c> aplist = new List<ApplKyc__c>();
         ApplKyc__c ap = new ApplKyc__c();
            ap.Applicant__c =appli.Id;
            ap.AadharEncripted__c = '123456789098';
            ap.Address__c = 'Pune';
            ap.VotIdEpicNo__c = '123456789';
            ap.kycDoc__c = 'Voter Id';
            ap.kycId__c = '12345';
        aplist.add(ap);
        
            insert aplist;
        */ 
        List<IntgMsg__c> intMsglist = new List<IntgMsg__c>();
        for (ApplKyc__c apId : kyclist) {
        IntgMsg__c newlit = new IntgMsg__c();
        newlit.Name = 'DRIVER\'S LICENSE AUTHENTICATION';
        newlit.BU__c = 'Vehicle Loan';
        newlit.ParentRefId__c=apId.Id;
        newlit.Svc__c = 'Initiate Transaction';
        newlit.IsActive__c = true;
     //   newlit.RefId__c = appId;
        newlit.Status__c = 'New';
        newlit.MStatus__c = 'Blank';
        newlit.RefObj__c = 'Applicant__c';
        intMsglist.add(newlit);
        }
        insert intMsglist;
        
		// List<IntgMsg__c> responses = new List<IntgMsg__c>{intMsglist};

        Test.startTest();
        KycOcrResponseProcessor.process(intMsglist);
        Test.stopTest();
    } 
        

    }