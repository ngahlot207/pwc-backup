@isTest
public class ChequeOCRResponseProcessor_Test {
    
    @testsetup
    Public static void insertChequeOCRecord(){
        LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
        Applicant__c appli =  TestDataFactory.createSingleApplicant(true,loan.id);
        ApplIMD__c appImd = TestDataFactory.applIMDData(True, loan.id);
        appImd.PaytmShortURL__c = 'https://paytm.me/AH-y45c';
        appImd.IMDAmt__c = 1233; 
        TriggerBase.bypass('ApplIMD__c');
        Update appImd;
        TriggerBase.clearBypass('ApplIMD__c');
        
        MICRCodeMstr__c objMICR = new MICRCodeMstr__c();
        objMICR.MICRCode__c = 'MICR456';
        TriggerBase.bypass('MICRCodeMstr__c');
        Insert objMICR;
        TriggerBase.clearBypass('MICRCodeMstr__c');
    }
    
    @isTest
    Public static void test_process_1(){
        List<IntgMsg__c> intMsglist1 = new List<IntgMsg__c>();
        List<LoanAppl__c> loan =[SELECT Id FROM LoanAppl__c LIMIT 1];
        List<Applicant__c> lstAplicant = [SELECT Id From Applicant__c Limit 1];
        List<ApplIMD__c> lstappImd = [SELECT ID FROM ApplIMD__c Limit 1];
        system.assert(!loan.isEmpty(), 'loan list should not empty.');  
        
        String jsonString = '{"requestId": "145ee733-99bb-4159-b832-ef", "result": {"accNo": "123456", "bank": "Sample Bank", "chequeNo": "789012", "ifsc": "IFSC123", "micr": "MICR456", "bankDetails": {"address": "Sample Address", "branch": "Sample Branch", "city": "Sample City", "contact": "1234567890", "district": "Sample District", "state": "Sample State"}, "name": ["John Doe", "Jane Doe"]}, "statusCode": 101, "clientData": {"caseId": "123456"}}';
        List<IntgMsg__c> intMsglist =  TestDataFactory.createIntMsg(true, 'Cheque OCR', lstAplicant[0].id, jsonString);
        for(IntgMsg__c intMessage : intMsglist){
            intMessage.ParentRefId__c = lstappImd[0].Id;
            intMessage.ParentRefObj__c = 'ApplIMD__c';
            intMsglist1.add(intMessage);
        }
        Test.StartTest();
        ChequeOCRResponseProcessor.process(intMsglist1);
        Test.StopTest();
        
    }
    
    @isTest
    Public static void test_process_2(){
        List<IntgMsg__c> intMsglist1 = new List<IntgMsg__c>();
        List<LoanAppl__c> loan =[SELECT Id FROM LoanAppl__c LIMIT 1];
        List<Applicant__c> lstAplicant = [SELECT Id From Applicant__c Limit 1];
        List<ApplIMD__c> lstappImd = [SELECT ID FROM ApplIMD__c Limit 1];
        system.assert(!loan.isEmpty(), 'loan list should not empty.');  
        
        String jsonString = '{"requestId": "145ee733-99bb-4159-b832-ef", "result": {"accNo": "123456", "bank": "Sample Bank", "chequeNo": "789012", "ifsc": "IFSC123", "micr": "MICR456", "bankDetails": {"address": "Sample Address", "branch": "Sample Branch", "city": "Sample City", "contact": "1234567890", "district": "Sample District", "state": "Sample State"}, "name": ["John Doe", "Jane Doe"]}, "statusCode": 103, "clientData": {"caseId": "123456"}}';
        List<IntgMsg__c> intMsglist =  TestDataFactory.createIntMsg(true, 'Cheque OCR', lstAplicant[0].id, jsonString);
        for(IntgMsg__c intMessage : intMsglist){
            intMessage.ParentRefId__c = lstappImd[0].Id;
            intMessage.ParentRefObj__c = 'ApplIMD__c';
            intMsglist1.add(intMessage);
        }
        Test.StartTest();
        ChequeOCRResponseProcessor.process(intMsglist1);
        Test.StopTest();
    }
    
    @isTest
    Public static void test_process_3(){
        List<IntgMsg__c> intMsglist1 = new List<IntgMsg__c>();
        List<LoanAppl__c> loan =[SELECT Id FROM LoanAppl__c LIMIT 1];
        List<Applicant__c> lstAplicant = [SELECT Id From Applicant__c Limit 1];
        List<ApplIMD__c> lstappImd = [SELECT ID FROM ApplIMD__c Limit 1];
        system.assert(!loan.isEmpty(), 'loan list should not empty.');  
        
        String jsonString = '{"requestId": "145ee733-99bb-4159-b832-ef", "result": {"accNo": "123456", "bank": "Sample Bank", "chequeNo": "789012", "ifsc": "IFSC123", "micr": "MICR456", "bankDetails": {"address": "Sample Address", "branch": "Sample Branch", "city": "Sample City", "contact": "1234567890", "district": "Sample District", "state": "Sample State"}, "name": ["John Doe", "Jane Doe"]}, "clientData": {"caseId": "123456"}}';
        List<IntgMsg__c> intMsglist =  TestDataFactory.createIntMsg(true, 'Cheque OCR', lstAplicant[0].id, jsonString);
        for(IntgMsg__c intMessage : intMsglist){
            intMessage.ParentRefId__c = lstappImd[0].Id;
            intMessage.ParentRefObj__c = 'ApplIMD__c';
            intMsglist1.add(intMessage);
        }
        Test.StartTest();
        ChequeOCRResponseProcessor.process(intMsglist1);
        Test.StopTest();
    }
}