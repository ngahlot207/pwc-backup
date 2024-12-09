@isTest
public class DisbursementCommunicationTest {
    
    @testsetup
    Public static void insertData(){
        LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
        Applicant__c appli =  TestDataFactory.createSingleApplicant(true,loan.id); 
        NDC__c NDC = TestDataFactory.NDCData(True,loan.Id,appli.Id);
        
        DocMstr__c docmaster =  TestDataFactory.createDocumentMaster(True,'Test');
        DocDtl__c appDocDet = TestDataFactory.createDocumentDetail(True,'Techanical Report',appli.Id,docmaster.Id);
        appDocDet.DocStatus__c = 'PDD';
        appDocDet.LAN__c = loan.Id;
        Update appDocDet;
        
       
        DocDtl__c appDocDet1 = TestDataFactory.createDocumentDetail(True,'Techanical Report',appli.Id,docmaster.Id);
        appDocDet1.DocStatus__c = 'OTC';
        appDocDet1.LAN__c = loan.Id;
        Update appDocDet1;
        
        
        Application_Query__c objApplictionQuery = new Application_Query__c();
        objApplictionQuery.Responded__c = false;
        objApplictionQuery.QryTyp__c = 'NDC Query';
        objApplictionQuery.NDC__c = NDC.Id;
        TriggerBase.bypass('Application_Query__c');
        Insert objApplictionQuery;
        TriggerBase.clearBypass('Application_Query__c');
        
    }
    
    @isTest
    Public static void testMethod1(){
        List<LoanAppl__c> lstLoanApplicaton = [SELECT ID,Name FROM LoanAppl__c LIMIT 1];
        List<Application_Query__c> lstAppQuery = [SELECT Id,Responded__c,QryTyp__c from Application_Query__c WHERE QryTyp__c = 'NDC Query'];
        List<DocDtl__c> lstDocDtlPDD = [SELECT ID, Name From DocDtl__c where DocStatus__c = 'PDD'];
        List<DocDtl__c> lstDocDtlOTC = [SELECT ID, Name From DocDtl__c where DocStatus__c = 'OTC'];
        system.assert(!lstLoanApplicaton.isEmpty(), 'Loan application list should not empty');
        Test.StartTest();
        DisbursementCommunication ObjDisbu = new DisbursementCommunication();
        ObjDisbu.loanApplicationId = lstLoanApplicaton[0].Id;
        ObjDisbu.applicationQueryList = lstAppQuery;
        ObjDisbu.OtcList = lstDocDtlPDD;
        ObjDisbu.PddList = lstDocDtlOTC;
        ObjDisbu.getOpsQueryResults();
        ObjDisbu.getApplicationQuery();
        ObjDisbu.getOTCDocDetails();
        ObjDisbu.getPDDDocDetails();
        Test.StopTest();
    }
    
}