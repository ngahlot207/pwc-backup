@isTest//(SeeAllData=true)
public class APIRetriggerBatchTest {
	
   
    
    @isTest//(SeeAllData=true)
    Public static void testAPIRetriggerBatchMethod(){
     
        LoanAppl__c loanApp=TestDataFactory.createLoanApplication(true);
        Applicant__c appli=TestDataFactory.createSingleApplicant(true,loanApp.Id);
        
        APICoutTrckr__c apiCtrkr= new APICoutTrckr__c();
        apiCtrkr.LAN__c= loanApp.Id;
        apiCtrkr.Appl__c = appli.Id;
        apiCtrkr.Retry__c =true;
        apiCtrkr.MaxRetryExceeded__c=false;
        apiCtrkr.APIName__c='Risk API';
        apiCtrkr.IntgMsgName__c='Risk API';
        apiCtrkr.BU__c='HL / STL';
        apiCtrkr.RefId__c=appli.Id;
        apiCtrkr.RefObj__c= 'Applicant__c';
        apiCtrkr.Retry_Count__c=1;
        insert apiCtrkr;
        //Test.setCreatedDate(apiCtrkr.Id,DateTime.now().addDays(-1));
        Test.Starttest();
        APICoutTrckr__c api = [Select Id, CreatedDate,LastmodifiedDate from APICoutTrckr__c where Id =:apiCtrkr.ID LIMIT 1];
        system.debug(':::'+api);
        APIRetriggerBatch batchJob = new APIRetriggerBatch();
        batchJob.execute(null);
        //Database.executeBatch(batchJob);
        Test.Stoptest();
        
    }
    
}