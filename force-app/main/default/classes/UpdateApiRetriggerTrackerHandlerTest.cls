@isTest
public class UpdateApiRetriggerTrackerHandlerTest {

    @isTest
    static void testAfterUpdate() {
        // Create test data  
        LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
        Applicant__c applicant = TestDataFactory.createSingleApplicant(true, loan.Id);
        
        APICoutTrckr__c apiCounter = new APICoutTrckr__c(
            LAN__c = loan.Id,
            Appl__c = applicant.Id,
            APIName__c = 'Risk API',
            LtstRespCode__c = 'Failure',
            CrntStatus__c = 'In Progress'
        );
        insert apiCounter;
        APICoutTrckr__c apiCounter1 = new APICoutTrckr__c(
            LAN__c = loan.Id,
            Appl__c = applicant.Id,
            APIName__c = 'Cusomer Issue Request',
             LtstRespCode__c = 'Failure',
            CrntStatus__c = 'In Progress'
        );
        insert apiCounter1;

        APIRetriggerTracker__c apiRetriggerTracker = new APIRetriggerTracker__c(
            LoanApp__c = loan.Id,
            App__c = applicant.Id,
            APIName__c = 'Risk API'
        );
        insert apiRetriggerTracker;
        APIRetriggerTracker__c apiRetriggerTracker1 = new APIRetriggerTracker__c(
            LoanApp__c = loan.Id,
            App__c = applicant.Id,
            APIName__c = 'Cusomer Issue Request'
        );
        insert apiRetriggerTracker1;
        

        // Call the afterUpdate method by updating the APICoutTrckr__c record
        Test.startTest();
        apiCounter.LtstRespCode__c = 'Success';
        apiCounter.CrntStatus__c = 'Completed';
        
        update apiCounter;
         apiCounter1.LtstRespCode__c = 'Success';
        apiCounter1.CrntStatus__c = 'Completed';
        update apiCounter1;
        Test.stopTest();
		list<APICoutTrckr__c> listofAPICoutTrckr=new List<APICoutTrckr__c>();
        listofAPICoutTrckr.add(apiCounter);
        listofAPICoutTrckr.add(apiCounter1);
        
        // Verify the expected behavior
        APIRetriggerTracker__c updatedApiRetriggerTracker = [SELECT Id, IsProcessed__c FROM APIRetriggerTracker__c WHERE Id = :apiRetriggerTracker.Id LIMIT 1];
        //System.assertEquals(true, updatedApiRetriggerTracker.IsProcessed__c);
        UpdateApiRetriggerTrackerHandler.afterInsert(listofAPICoutTrckr);
    }
    
}