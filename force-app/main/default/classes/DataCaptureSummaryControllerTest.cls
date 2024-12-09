@isTest
public class DataCaptureSummaryControllerTest {

    @isTest
    public static void test1(){
        
        LoanAppl__c la = TestDataFactory.createLoanApplication(true);
        Applicant__c app = TestDataFactory.createSingleApplicant(true, la.Id);
        
        Deviation__c devObj = new Deviation__c();
        devObj.LoanAppln__c = la.Id;
        insert devObj;
        
        UWDecision__c uw = new UWDecision__c();
        uw.LoanAppl__c= la.Id;
        uw.Decision__c='Approved';
        insert uw;
        
         Sanction_Conditions__c testRecord = new Sanction_Conditions__c(
            Remarks__c = 'Test Remarks',
            Loan_Application__c = la.Id, // Replace with a valid Loan Application Id
            Condition__c = 'Test Condition'
        );
        insert testRecord;
        
        DataCaptureSummaryController.CombinedObjectData cod = DataCaptureSummaryController.getCombinedObjData(la.Id);
    }
}