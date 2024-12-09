@isTest
public class ChangeSummaryHandlerTest {

    @isTest
    static void testGetRetriggerData() {
        // Create test data
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Contact testContact = new Contact(FirstName = 'John', LastName = 'Doe', AccountId = testAccount.Id);
        insert testContact;
        
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
		Applicant__c applicant = TestDataFactory.createSingleApplicant(true, loanApp.Id);        

        RetriggerUpsertAudit__c testAuditRecord = new RetriggerUpsertAudit__c(
            LoanApp__c = loanApp.id,
            Appl__c = applicant.Id,
            FieldApiName__c = 'FirstName',
            ModTime__c = System.now(),
            ModBy__c = UserInfo.getUserId(),
            OldValue__c = 'Old Value',
            NewValue__c = 'New Value',
            ObjApiName__c = 'Contact'
        );
        insert testAuditRecord;

        APIRetriggerTracker__c testApiRetrigger = new APIRetriggerTracker__c(
            RetriggerUpsertAudit__c = testAuditRecord.Id,
            APIName__c = 'Test API',
            RefID__c = 'Test Ref ID',
            RefObj__c = 'Test Ref Object',
            IsProcessed__c = false
        );
        insert testApiRetrigger;

        Test.startTest();

        // Call the method to be tested
        List<ChangeSummaryHandler.ChangeSummaryData> result = ChangeSummaryHandler.getRetriggerData(testAuditRecord.LoanApp__c);

        Test.stopTest();

        // Perform assertions
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(1, result.size(), 'Result size should be 1');
        ChangeSummaryHandler.ChangeSummaryData changeSummaryData = result[0];
        System.assertEquals(testAuditRecord.Id, changeSummaryData.retriggerUpsertAuditId, 'Incorrect retriggerUpsertAuditId');
        //System.assertEquals(testContact.TabName__c, changeSummaryData.applicantName, 'Incorrect applicantName');
        System.assertEquals('First Name', changeSummaryData.fieldName, 'Incorrect fieldName');
        System.assertEquals('Old Value', changeSummaryData.oldValue, 'Incorrect oldValue');
        System.assertEquals('New Value', changeSummaryData.newValue, 'Incorrect newValue');
        System.assertEquals(testAuditRecord.ModTime__c, changeSummaryData.timeStamp, 'Incorrect timeStamp');
        System.assertEquals(UserInfo.getName(), changeSummaryData.whoChanged, 'Incorrect whoChanged');
        System.assertEquals('Test API', changeSummaryData.retriggerApis, 'Incorrect retriggerApis');
    }
}