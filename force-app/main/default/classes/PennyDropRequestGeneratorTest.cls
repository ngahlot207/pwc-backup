@isTest
public class PennyDropRequestGeneratorTest {
    
    
    @testsetup 
    Public static void InsertPennyDropRequestGeneratorData(){
        SchMapping__c schemeMapping = TestDataFactory.createSchemeMapping(true);
        LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
        loan.SchemeId__c = schemeMapping.Id;
        Update loan;
        
        Applicant__c appli =  TestDataFactory.createSingleApplicant(true,loan.id); 
        BankBrchMstr__c baranchMaster = TestDataFactory.TestDataBankBranchMaster(true);
        Repayment_Account__c objRepaymentAccount = new Repayment_Account__c();
        objRepaymentAccount.Name = 'Test';
        objRepaymentAccount.Loan_Application__c = loan.Id;
        TriggerBase.bypass('Repayment_Account__c');
        Insert objRepaymentAccount;
        TriggerBase.clearBypass('Repayment_Account__c');
        
        RepayAccVerify__c objrepaymentAccountVerfication = new RepayAccVerify__c();
        objrepaymentAccountVerfication.RepayAcc__c = objRepaymentAccount.Id;
        objrepaymentAccountVerfication.ResponseReason__c = 'Test1';
        TriggerBase.bypass('RepayAccVerify__c');
        Insert objrepaymentAccountVerfication;
        TriggerBase.clearBypass('RepayAccVerify__c');
        
        Disbursement__c objDis = new Disbursement__c();
        objDis.Loan_Appli__c = loan.Id;
        TriggerBase.bypass('Disbursement__c');
        Insert objDis;
        TriggerBase.clearBypass('Disbursement__c');
        
        Split_Disbur__c objSplitDis = new Split_Disbur__c();
        objSplitDis.DisburseRela__c = objDis.Id;
        objSplitDis.Benef_Nm_of_Penny_Drop__c = 'Test';
        TriggerBase.bypass('Disbursement__c');
        Insert objSplitDis;
        TriggerBase.clearBypass('Disbursement__c');        
        
    }
    
    @isTest
    Public static void PennyDropRequestGenerator_Test(){
        List<IntgMsg__c> lstIntMsglist = new  List<IntgMsg__c>();
         List<LoanAppl__c> loan =[SELECT Id FROM LoanAppl__c LIMIT 1];
         List<Applicant__c> lstAplicant = [SELECT Id From Applicant__c Limit 1];
         List<RepayAccVerify__c> lstRepayAccVerfiy = [SELECT ID,Name,RepayAcc__c from RepayAccVerify__c WHERE ResponseReason__c = 'Test1'];
         List<IntgMsg__c> intMsglist =  TestDataFactory.createIntMsg(true, 'KYC OCR', lstAplicant[0].id, null);
          for(IntgMsg__c intmes : intMsglist){
            intmes.RefObj__c = 'RepayAccVerify__c';
            intmes.RefId__c = lstRepayAccVerfiy[0].Id;
            lstIntMsglist.add(intmes);
        }
        
        PennyDropRequestGenerator testGenerator = new PennyDropRequestGenerator();
        Test.startTest();
        testGenerator.generate(lstIntMsglist, 'TestService', 'TestProcessType');
        Test.stopTest();
        system.assert(!intMsglist.isEmpty(),'Integration message List Should not empty');
        
        
        String json = '{' + '"user": "pennyweb",' +'"password": "zqbAx8rZ0LvWMftg38eTatwjEANYAo/6",' +'"requestId": "jyJUpRC8EaIan7WI5QtYv011",' +
            '"applicationId": "586144",' +'"sourceId": "SFDC",' +'"chequeStatus": "S",' +'"inFavourOf": "AJIT",' +'"productFlag": "LAP",' +'"schemeId": "540",' +
            '"branch": "5",' +'"ftMode": "IM",' +'"modeOfPayment": "F",' +'"receiptAmount": "1",' +'"receiptChannel": "FEDBANK",' +
            '"dealingBank": "497",' +'"drawnOn": "485",' +'"imdFlag": "P",' +'"bpType": "LS",' +'"bpId": "",' +'"receiptDate": "02-OCT-2022",' +'"chequeDate": "01-OCT-2022",' +
            '"utrNo": "3526654646",' +'"receiptNo": "23155",' +'"imdCustom2": "Saurabh Rai",' +'"imdCustom3": "Saurabh Rai",' +'"imdCustom4": "FDRL0001001",' +
            '"imdCustom5": "10010200015128",' +'"imdCustom6": "Penny Drop Description"' +'}';
        
         PennyDropRequestWrapper parsedWrapper = PennyDropRequestWrapper.parse(json);
        
         String json1 = '{' +'"requestId": "uwhpcUUx0ixaJpBhxGnsjy",' +'"status": "SUCCESS",' +'"applicationId": "586371",' +'"chequeId": "691627",' +'"errorcode": "0000",' +'"errorDescription": ""' +'}';
         PennyDropResponseWrappper parsedWrapper1 = PennyDropResponseWrappper.parse(json1);
        
        //System.assertEquals('uwhpcUUx0ixaJpBhxGnsjy', parsedWrapper.requestId);
        
        //System.assertEquals('SUCCESS', parsedWrapper.status);
        //System.assertEquals('pennyweb', parsedWrapper.user);
        // System.assertEquals('jyJUpRC8EaIan7WI5QtYv011', parsedWrapper.requestId);
    }
    
    @isTest
    Public Static void PennyDropRequestGenerator_Test1(){
          List<IntgMsg__c> lstIntMsglist = new  List<IntgMsg__c>();
         List<LoanAppl__c> loan =[SELECT Id FROM LoanAppl__c LIMIT 1];
         List<Applicant__c> lstAplicant = [SELECT Id From Applicant__c Limit 1];
         List<Split_Disbur__c> lstSplitDis = [SELECT ID,Benef_Nm_of_Penny_Drop__c From Split_Disbur__c WHERE Benef_Nm_of_Penny_Drop__c = 'Test' Limit 1];
         system.debug('lstSplitDis:'+lstSplitDis);
         List<IntgMsg__c> intMsglist =  TestDataFactory.createIntMsg(true, 'KYC OCR', lstAplicant[0].id, null);
          for(IntgMsg__c intmes : intMsglist){
            intmes.RefObj__c = 'Split_Disbur__c';
            intmes.RefId__c = lstSplitDis[0].Id;
            lstIntMsglist.add(intmes);
        }
        
        PennyDropRequestGenerator testGenerator = new PennyDropRequestGenerator();
        Test.startTest();
        testGenerator.generate(lstIntMsglist, 'TestService', 'TestProcessType');
        Test.stopTest();
        system.assert(!intMsglist.isEmpty(),'Integration message List Should not empty');
        
    }
}