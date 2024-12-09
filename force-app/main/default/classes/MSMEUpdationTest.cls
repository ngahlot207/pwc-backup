@isTest
public class MSMEUpdationTest {
 
    @isTest
    static void MSMEUpdationTestHandler() {
        // Test data setup
        List<Investment_in_Plant_and_Machinery__mdt> listInvestment = [SELECT Id,Min__c,Max__c,MSME_Type__c from Investment_in_Plant_and_Machinery__mdt];

        List<Annual_Turnover__mdt> listAnnualTurnover = [SELECT Id,Min__c,Max__c,MSME_Type__c from Annual_Turnover__mdt];
		 
        LoanAppl__c testLoanApp = TestDataFactory.createLoanApplication(true);
        
        List<Applicant__c> applicants = new List<Applicant__c>();
        List<Applicant__c> oldapplicants = new List<Applicant__c>();
        
      	Applicant__c appli=New Applicant__c(); 
        appli.FName__c='test';
        appli.MobNumber__c='9876567899';
        appli.LName__c='method';
        appli.ApplType__c='P';
  		appli.Investment_in_Plant_and_Machinery__c=100000000;
       	appli.Annual_Turnover__c=1000000;
        appli.Constitution__c='INDIVIDUAL';
        appli.CustProfile__c = 'SELF EMPLOYED NON PROFESSIONAL';
        appli.LoanAppln__c=testLoanApp.Id;
        appli.MSME__c='No';
        appli.MSME_Type__c='Small';
        oldapplicants.add(appli);
        insert oldapplicants;
        
        Applicant__c appUpdate=New Applicant__c();                
  		appli.Investment_in_Plant_and_Machinery__c=200000000;
       	appli.Annual_Turnover__c=2000000;
        appUpdate.Constitution__c='INDIVIDUAL'; 
        appli.CustProfile__c = 'SELF EMPLOYED NON PROFESSIONAL';
        appUpdate.LoanAppln__c=testLoanApp.Id;
        appUpdate.MSME__c='Yes';
        appUpdate.MSME_Type__c='Micro';
        appUpdate.Id = appli.Id;
        applicants.add(appUpdate);
        update applicants;
        
        Test.startTest();
        MSMEUpdation.afterUpdate(applicants, oldapplicants);        
        Test.stopTest();
        
        LoanAppl__c testLoan = [SELECT Id, Final_MSME__c FROM LoanAppl__c WHERE Id = :testLoanApp.Id];
        system.assertEquals('Micro',testLoan.Final_MSME__c); 

    }
  
    @isTest
    static void MSMEUpdationTestHandler1() {
        // Test data setup
        List<Investment_in_Plant_and_Machinery__mdt> listInvestment = [SELECT Id,Min__c,Max__c,MSME_Type__c from Investment_in_Plant_and_Machinery__mdt];

        List<Annual_Turnover__mdt> listAnnualTurnover = [SELECT Id,Min__c,Max__c,MSME_Type__c from Annual_Turnover__mdt];
		 
        LoanAppl__c testLoanApp = TestDataFactory.createLoanApplication(true);
        
        List<Applicant__c> applicants = new List<Applicant__c>();
        List<Applicant__c> oldapplicants = new List<Applicant__c>();
        
      	Applicant__c appli=New Applicant__c(); 
        appli.FName__c='test';
        appli.MobNumber__c='9876567899';
        appli.LName__c='method';
        appli.ApplType__c='P';
  		appli.Investment_in_Plant_and_Machinery__c=100000000;
       	appli.Annual_Turnover__c=1000000;
        appli.Constitution__c='INDIVIDUAL';        	
        appli.LoanAppln__c=testLoanApp.Id;
        appli.MSME__c='No';
        appli.MSME_Type__c='Micro';
        oldapplicants.add(appli);
        insert oldapplicants;
        
        Applicant__c appUpdate=New Applicant__c();                
  		appli.Investment_in_Plant_and_Machinery__c=200000000;
       	appli.Annual_Turnover__c=2000000;
        appUpdate.Constitution__c='PRIVATE LIMITED COMPANY';        	
        appUpdate.LoanAppln__c=testLoanApp.Id;
        appUpdate.MSME__c='Yes';
        appUpdate.MSME_Type__c='Medium';
        appUpdate.Id = appli.Id;
        applicants.add(appUpdate); 
        update applicants;
        
        Test.startTest();
        MSMEUpdation.afterUpdate(applicants, oldapplicants);   
        Test.stopTest();
		
        LoanAppl__c testLoan = [SELECT Id, Final_MSME__c FROM LoanAppl__c WHERE Id = :testLoanApp.Id];
        system.debug('testLoan1 -- '+ testLoan);

    }
    
    @isTest
    static void MSMEUpdationTestHandler2() {
        // Test data setup
        List<Investment_in_Plant_and_Machinery__mdt> listInvestment = [SELECT Id,Min__c,Max__c,MSME_Type__c from Investment_in_Plant_and_Machinery__mdt];

        List<Annual_Turnover__mdt> listAnnualTurnover = [SELECT Id,Min__c,Max__c,MSME_Type__c from Annual_Turnover__mdt];
		 
        LoanAppl__c testLoanApp = TestDataFactory.createLoanApplication(true);
        
        List<Applicant__c> applicants = new List<Applicant__c>();
        List<Applicant__c> oldapplicants = new List<Applicant__c>();
        
      	Applicant__c appli=New Applicant__c(); 
        appli.FName__c='test';
        appli.MobNumber__c='9876567899';
        appli.LName__c='method';
        appli.ApplType__c='P';
  		appli.Investment_in_Plant_and_Machinery__c=100000000;
       	appli.Annual_Turnover__c=1000000;
        appli.Constitution__c='INDIVIDUAL';        	
        appli.LoanAppln__c=testLoanApp.Id;
        appli.MSME__c='No';
        appli.MSME_Type__c='Small';
        oldapplicants.add(appli);
        insert oldapplicants;
        
        Applicant__c appUpdate=New Applicant__c();                
  		appli.Investment_in_Plant_and_Machinery__c=200000000;
       	appli.Annual_Turnover__c=2000000;
        appUpdate.Constitution__c='PRIVATE LIMITED COMPANY';        	
        appUpdate.LoanAppln__c=testLoanApp.Id;
        appUpdate.MSME__c='Yes';
        appUpdate.MSME_Type__c='Small';
        appUpdate.Id = appli.Id;
        applicants.add(appUpdate); 
        update applicants;
        
        Test.startTest();
        MSMEUpdation.afterUpdate(applicants, oldapplicants);   
        Test.stopTest();
		
        LoanAppl__c testLoan = [SELECT Id, Final_MSME__c FROM LoanAppl__c WHERE Id = :testLoanApp.Id];
        system.debug('testLoan2 -- '+ testLoan);
        
    }

}