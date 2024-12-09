@isTest
public class RetriggerAPIsValueChangeTest {

    @isTest
    static void testAfterInsert() {
        boolean isError = true;
        try{
            LoanAppl__c loan = testDataFactory.createLoanApplication(true);
            Applicant__c appl = testDataFactory.createSingleApplicant(true, loan.Id);
  
            Test.startTest();
            RetriggerAPIsValueChange.afterInsert(new List<Applicant__c>{appl});
            Test.stopTest();
        }
        catch(exception e){
            isError = false;
        }
        system.assertEquals(isError, true);
       	      
    }

    @isTest
    static void testAfterUpdate() {
        boolean isError = true;
        try{
            LoanAppl__c loan = testDataFactory.createLoanApplication(true);
            Applicant__c appl = testDataFactory.createSingleApplicant(true, loan.Id);
            
            LoanAppl__c loan1 = testDataFactory.createLoanApplication(true);
            appl.LoanAppln__c = loan1.Id;
            update appl;
            
            Test.startTest();
            RetriggerAPIsValueChange.afterUpdate(new List<Applicant__c>{appl},new List<Applicant__c>{appl});
            Test.stopTest();
        }
        catch(exception e){
            isError = false;
        }
        system.assertEquals(isError, true);
       
    }

    @isTest
    static void testAfterDelete() {
        boolean isError = true;
        try{
            LoanAppl__c loan = testDataFactory.createLoanApplication(true);
            Applicant__c appl = testDataFactory.createSingleApplicant(true, loan.Id);    
            delete appl;
            
            Test.startTest();
            RetriggerAPIsValueChange.afterDelete(new List<Applicant__c>{appl});
            Test.stopTest();
		}
        catch(exception e){
            isError = false;
        }
        system.assertEquals(isError, true); 
    }

    @isTest
    static void testAfterInsertWithNullNewList() {
        boolean isError = true;
        try{
            LoanAppl__c loan = testDataFactory.createLoanApplication(true);
            Applicant__c appl = testDataFactory.createSingleApplicant(true, loan.Id);
            RetriggerAPIsValueChange.afterInsert(new List<Applicant__c>());
        }
		catch(exception e){
            isError = false;
        }
        system.assertEquals(isError, true);         
    }

    @isTest
    static void testAfterUpdateWithNullNewList() {
        boolean isError = true;
        try{
            LoanAppl__c loan = testDataFactory.createLoanApplication(true);
            Applicant__c appl = testDataFactory.createSingleApplicant(true, loan.Id);
            
            LoanAppl__c loan1 = testDataFactory.createLoanApplication(true);
            appl.LoanAppln__c = loan1.Id;
            update appl;
        }
        catch(exception e){
            isError = false;
        }
        system.assertEquals(isError, true);

    }

    @isTest
    static void testAfterUpdateWithNullOldList() {
        boolean isError = true;
        try{
            LoanAppl__c loan = testDataFactory.createLoanApplication(true);
            Applicant__c appl = testDataFactory.createSingleApplicant(true, loan.Id);
            
            LoanAppl__c loan1 = testDataFactory.createLoanApplication(true);
            appl.LoanAppln__c = loan1.Id;
            update appl;
        }
        catch(exception e){
            isError = false;
        }
        system.assertEquals(isError, true);
    }

    @isTest
    static void testAfterDeleteWithNullNewList() {
         boolean isError = true;
        try{
            LoanAppl__c loan = testDataFactory.createLoanApplication(true);
            Applicant__c appl = testDataFactory.createSingleApplicant(true, loan.Id);
            RetriggerAPIsValueChange.afterDelete(new List<Applicant__c>()); 
        }
		catch(exception e){
            isError = false;
        }
        system.assertEquals(isError, true);
    }
}