@isTest
public class UpdateRBICheckTest {
    
        
     @isTest
        public static void testAfterUpdate(){
    
       // Create test data
        LoanAppl__c testLoanApplication = TestDataFactory.createLoanApplication(true);
        Applicant__c testApplicant = TestDataFactory.createSingleApplicant(true,testLoanApplication.Id);
            Applicant__c appToUpdate=new Applicant__c(id=testApplicant.Id,Constitution__c='INDIVIDUAL',Type_of_Borrower__c='Financial',LatestyearforwhichITRisavailable__c='test' );
            update appToUpdate;
        ApplicantEmployment__c appEmpC=new ApplicantEmployment__c();
        appEmpC.MainRBIIndustry__c='Test Industry';
        appEmpC.LoanApplicant__c=testApplicant.Id;
        insert appEmpC;

       
        // Trigger the after update operation
        Test.startTest();
        List<ApplicantEmployment__c> newEmployments = new List<ApplicantEmployment__c>{
            new ApplicantEmployment__c(Id = appEmpC.Id, MainRBIIndustry__c = 'New Industry')
        };
        List<ApplicantEmployment__c> oldEmployments = new List<ApplicantEmployment__c>{
             new ApplicantEmployment__c(Id = appEmpC.Id, MainRBIIndustry__c = 'old Industry')
        };    
        
        updateRBICheck.afterUpdate(newEmployments, oldEmployments);
        Test.stopTest();
        
    }
      @isTest
    static void testAfterUpdate_Positive_First() {
        
        LoanAppl__c testLoanApp = TestDataFactory.createLoanApplication(true);
              
        Applicant__c testApplicant =TestDataFactory.createSingleApplicant(true,testLoanApp.Id);
        //Create Applicant Employee
        ApplicantEmployment__c appEmpC=new ApplicantEmployment__c();
        appEmpC.MainRBIIndustry__c='Test Industry';
        appEmpC.LoanApplicant__c=testApplicant.Id;
        insert appEmpC;  
        // Call the afterUpdate method by updating the ApplicantEmployment__c
        appEmpC.MainRBIIndustry__c='test';
        
        Test.startTest();
        update appEmpC;
        Test.stopTest();
        
        // Query the records after the update
       // List<Applicant__c> updatedApplicants = [SELECT Id, TotalIncome__c,Constitution__c,(select id, MainRBIIndustry__c from Applicant_Employments__r) FROM Applicant__c WHERE Id = :testApplicant.Id];
       List<ApplicantEmployment__c> updatedemp=[Select Id,MainRBIIndustry__c From ApplicantEmployment__c ];
    }
    
    
    //===================== NEGATIVE ==========================
    
    @isTest
    static void testAfterUpdate_Negative() {
      
        LoanAppl__c testLoanApp = TestDataFactory.createLoanApplication(true);
        
        
        Applicant__c testApplicant =TestDataFactory.createSingleApplicant(true,testLoanApp.Id);
        testApplicant.TotalIncome__c = 15000;
        testApplicant.Constitution__c='INDIVIDUAL';
        testApplicant.CustProfile__c='SALARIED';
        testApplicant.ApplType__c='C';
        testApplicant.Type_of_Borrower__c='Financial';
        update testApplicant;
        
     
      
        ApplicantEmployment__c appEmpC=new ApplicantEmployment__c();
        appEmpC.MainRBIIndustry__c='Test Industry';
        appEmpC.LoanApplicant__c=testApplicant.Id;
        insert appEmpC;
         appEmpC.MainRBIIndustry__c='test';
        
        Test.startTest();
        update appEmpC;
        Test.stopTest();
        
        // Query the records after the update
       // List<Applicant__c> updatedApplicants = [SELECT Id, TotalIncome__c,Constitution__c,(select id, MainRBIIndustry__c from Applicant_Employments__r) FROM Applicant__c WHERE Id = :testApplicant.Id];
       List<ApplicantEmployment__c> updatedemp=[Select Id,MainRBIIndustry__c From ApplicantEmployment__c ];
		
       
       
        
        
    }
    
    @isTest
    Public static void negativemethod(){
          // Create a test Loan Application
        LoanAppl__c testLoanApp = TestDataFactory.createLoanApplication(true);
         Applicant__c testApplicant =TestDataFactory.createSingleApplicant(true,testLoanApp.Id);
        testApplicant.Type_of_Borrower__c='Non Financial';
        testApplicant.Constitution__c ='PARTNERSHIP'; 
        update testApplicant;
    }
           
}