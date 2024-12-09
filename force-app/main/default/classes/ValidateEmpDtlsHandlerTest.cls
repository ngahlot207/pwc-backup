@istest
public class ValidateEmpDtlsHandlerTest {
    @isTest
    public static void testAfterUpdate(){
        // Create test data
        LoanAppl__c testLoanApplication = TestDataFactory.createLoanApplication(true);
        Applicant__c testApplicant =TestDataFactory.createSingleApplicant(true,testLoanApplication.Id);
        List<ApplicantEmployment__c> appEmpOldList = new List<ApplicantEmployment__c>();    
        List<ApplicantEmployment__c> appEmpNewList = new List<ApplicantEmployment__c>(); 
        appEmpOldList.add(new ApplicantEmployment__c(
            LoanApplicant__c = testApplicant.Id,
            Proprietorship_firm_part_of_the_proposal__c = 'NO',
            MainRBIIndustry__c = 'Test'
        ));
        TriggerBase.bypass('ApplicantEmployment__c');
        insert appEmpOldList;
        TriggerBase.clearBypass('ApplicantEmployment__c');
        
        appEmpNewList.add(new ApplicantEmployment__c(
            Id=appEmpOldList[0].Id,
            LoanApplicant__c = testApplicant.Id,
            Proprietorship_firm_part_of_the_proposal__c = 'YES',
            MainRBIIndustry__c = 'Test'
        ));
        TriggerBase.bypass('ApplicantEmployment__c');
        update appEmpNewList;
        TriggerBase.clearBypass('ApplicantEmployment__c');
        system.debug('appEmpNewList' + appEmpNewList);
        system.debug('appEmpOldList' + appEmpOldList);
        Test.startTest();
        ValidateEmpDtlsHandler.beforeUpdate(appEmpNewList,appEmpOldList);
        Test.stopTest();   
    }
}