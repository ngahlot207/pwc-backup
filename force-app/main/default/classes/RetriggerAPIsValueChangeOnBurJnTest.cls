@isTest
public class RetriggerAPIsValueChangeOnBurJnTest {
    @isTest static void bureauHandler(){
        LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
		 Applicant__c Applicant=TestDataFactory.createSingleApplicant(true,loan.id);
        BureauRespDtl__c bureau=TestDataFactory.breResponseDetails(true);
         list<BureauRespDtl__c> bureauList = new list<BureauRespDtl__c>{bureau};
        RetriggerAPIsValueChangeOnBureauJnctn.afterInsert(bureauList);
        RetriggerAPIsValueChangeOnBureauJnctn.afterUpdate(bureauList,bureauList);
        RetriggerAPIsValueChangeOnBureauJnctn.afterDelete(bureauList);
    }
}