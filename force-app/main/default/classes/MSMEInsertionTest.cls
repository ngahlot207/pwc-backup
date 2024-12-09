@isTest
public class MSMEInsertionTest {
    
    @isTest
    static void MSMEInsertionTestHandler() {

        List<Investment_in_Plant_and_Machinery__mdt> listInvestment = [SELECT Id,Min__c,Max__c,MSME_Type__c from Investment_in_Plant_and_Machinery__mdt];
        List<Annual_Turnover__mdt> listAnnualTurnover = [SELECT Id,Min__c,Max__c,MSME_Type__c from Annual_Turnover__mdt];
        LoanAppl__c la = TestDataFactory.createLoanApplication(true);
        List<Applicant__c> applicants = new List<Applicant__c>();
        for(Integer i = 0; i < 5; i++) {
            applicants.add(new Applicant__c(
                Investment_in_Plant_and_Machinery__c = 10000,
                Annual_Turnover__c = 50000,
                MSME_Type__c = 'Type A',
                LoanAppln__c = la.Id
            ));
        }
        insert applicants;
        
        List<Applicant__c> modifiedApplicants = new List<Applicant__c>();
        for(Applicant__c app : [SELECT Id FROM Applicant__c LIMIT 2]) {
            app.Investment_in_Plant_and_Machinery__c = 20000;
            app.Annual_Turnover__c = 40000;
            app.MSME_Type__c = 'Type B';
            modifiedApplicants.add(app);
        }
        
        ApplicantEmployment__c createApplEmployment1 = TestDataFactory.createApplEmployment(true,modifiedApplicants[0].Id);
        createApplEmployment1.MSME_Industry_selection__c = 'Others';
        update createApplEmployment1;
        ApplicantEmployment__c createApplEmployment2 = TestDataFactory.createApplEmployment(true,modifiedApplicants[1].Id);
        createApplEmployment2.MSME_Industry_selection__c = 'Others';
        update createApplEmployment2;
        
        Test.startTest();
        MSMEInsertion.beforeUpdate(modifiedApplicants, applicants);
        Test.stopTest();
        
        for(Applicant__c app : modifiedApplicants) {
            System.assertEquals('Micro', app.MSME_Type__c);
            System.assertEquals('Yes', app.MSME__c); // Assuming MSME__c should be set to 'Yes'
        }
    }
    
}