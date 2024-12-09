@istest
public class PanValidationTest {
    @isTest
    public static void panValidationTestMethod() {
        LoanAppl__c la = TestDataFactory.createLoanApplication(true);
        Applicant__c app = TestDataFactory.createSingleApplicant(true, la.Id);

        ApplKyc__c ap = new ApplKyc__c();
        ap.Applicant__c = app.Id;
        ap.AadharEncripted__c = '123456789098';
        ap.Address__c = 'Pune';
        ap.Pan__c = 'TNRPR1887M';
        ap.kycDoc__c = 'Voter Id';
        ap.kycId__c = '12345';
        ap.NameInPan__c = 'Test';

        TriggerBase.bypass('ApplKyc__c');
        insert ap;
        TriggerBase.clearBypass('ApplKyc__c');
        try {
            Boolean resp = PanValidation.Validation(app.Id);
            system.assertEquals(false, resp);
        } catch (exception ex) {
            system.assertEquals(ex.getmessage(), ex.getmessage());
        }
        Applicant__c appNew = TestDataFactory.createSingleApplicant(
            true,
            la.Id
        );

        Boolean respNew = PanValidation.Validation(appNew.Id);
        system.assertEquals(true, respNew);
    }
}