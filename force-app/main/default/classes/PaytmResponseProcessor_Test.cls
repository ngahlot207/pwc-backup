@isTest
public class PaytmResponseProcessor_Test {
    @testsetup
    Public static void insertIntergrationMessageRecord(){
        LoanAppl__c loan = TestDataFactory.createLoanApplication(true);
        Applicant__c appli =  TestDataFactory.createSingleApplicant(true,loan.id);
        ApplIMD__c appImd = TestDataFactory.applIMDData(True, loan.id);
        appImd.PaytmShortURL__c = 'https://paytm.me/AH-y45c';
        appImd.IMDAmt__c = 1233;        
        Update appImd;
        
        Payment__c objPay = new Payment__c();
        objPay.LoanAppl__c = loan.Id;
        TriggerBase.bypass('Payment__c');
        Insert objPay;
        TriggerBase.clearBypass('Payment__c');
    } 
    @isTest
    Public static void test_process_1(){
        List<IntgMsg__c> intMsglist1 = new List<IntgMsg__c>();
         List<LoanAppl__c> loan =[SELECT Id FROM LoanAppl__c LIMIT 1];
         List<Applicant__c> lstAplicant = [SELECT Id From Applicant__c Limit 1];
         List<ApplIMD__c> lstappImd = [SELECT ID FROM ApplIMD__c Limit 1];
        system.assert(!loan.isEmpty(), 'loan list should not empty.');
         TestDataFactory.PaytmResponseWrapperTestData testData = TestDataFactory.createPaytmResponseWrapperTestData();
      //   String json1 = '{"head":{"version":"1.0","timestamp":"1566994462639","channelId":"web","tokenType":"AES","clientId":"12345"},"body":{"linkId":"5861","linkType":"FIXED","longUrl":"https://securegw-stage.paytm.in/link/PAYMENTLINKNAME/LL_5861","shortUrl":"https://paytm.me/ID-PBo7","expiryDate":"27/08/2020 17:44:22","isActive":true,"merchantHtml":"","createdDate":"28/08/2019 17:44:22","notificationDetails":[{"customerName":"John Doe","contact":"1234567890","notifyStatus":"SUCCESS","timestamp":"1566994462639"}],"resultInfo":{"resultStatus":"SUCCESS","resultCode":"200","resultMessage":"Payment link is created successfully"},"linkOrderId":"123"}}';
         List<IntgMsg__c> intMsglist =  TestDataFactory.createIntMsg(true, 'Paytm', lstAplicant[0].id, testData.jsonString);
         for(IntgMsg__c intMessage : intMsglist){
            intMessage.Resp__c = testData.jsonString;
            intMessage.Req__c = testData.jsonString;
            intMessage.RefObj__c = 'ApplIMD__c';
            intMessage.RefId__c =  lstappImd[0].Id;
           // intMessage.reApplIMD__c
             intMsglist1.add(intMessage);
        }
        Test.StartTest();
         PaytmResponseProcessor.process(intMsglist1);
        Test.StopTest();
        
    }
    
    
      @isTest
    Public static void test_process_2(){
        List<IntgMsg__c> intMsglist1 = new List<IntgMsg__c>();
         List<LoanAppl__c> loan =[SELECT Id FROM LoanAppl__c LIMIT 1];
         List<Applicant__c> lstAplicant = [SELECT Id From Applicant__c Limit 1];
         List<Payment__c> lstappPay = [SELECT ID FROM Payment__c Limit 1];
         system.assert(!loan.isEmpty(), 'loan list should not empty.');
         TestDataFactory.PaytmResponseWrapperTestData testData = TestDataFactory.createPaytmResponseWrapperTestData();
      //   String json1 = '{"head":{"version":"1.0","timestamp":"1566994462639","channelId":"web","tokenType":"AES","clientId":"12345"},"body":{"linkId":"5861","linkType":"FIXED","longUrl":"https://securegw-stage.paytm.in/link/PAYMENTLINKNAME/LL_5861","shortUrl":"https://paytm.me/ID-PBo7","expiryDate":"27/08/2020 17:44:22","isActive":true,"merchantHtml":"","createdDate":"28/08/2019 17:44:22","notificationDetails":[{"customerName":"John Doe","contact":"1234567890","notifyStatus":"SUCCESS","timestamp":"1566994462639"}],"resultInfo":{"resultStatus":"SUCCESS","resultCode":"200","resultMessage":"Payment link is created successfully"},"linkOrderId":"123"}}';
         List<IntgMsg__c> intMsglist =  TestDataFactory.createIntMsg(true, 'Paytm', lstAplicant[0].id, testData.jsonString);
         for(IntgMsg__c intMessage : intMsglist){
            intMessage.Resp__c = testData.jsonString;
            intMessage.Req__c = testData.jsonString;
            intMessage.RefObj__c = 'Payment__c';
            intMessage.RefId__c =  lstappPay[0].Id;
           // intMessage.reApplIMD__c
             intMsglist1.add(intMessage);
        }
         PaytmResponseProcessor.process(intMsglist1);
    }
    
    
       @isTest
    Public static void test_process_3(){
         List<IntgMsg__c> intMsglist1 = new List<IntgMsg__c>();
         List<LoanAppl__c> loan =[SELECT Id FROM LoanAppl__c LIMIT 1];
         List<Applicant__c> lstAplicant = [SELECT Id From Applicant__c Limit 1];
         List<Payment__c> lstappPay = [SELECT ID FROM Payment__c Limit 1];
         system.assert(!loan.isEmpty(), 'loan list should not empty.');
         TestDataFactory.PaytmResponseWrapperTestData testData = TestDataFactory.createPaytmResponseWrapperTestData();
         testData.resultInfo.resultCode = '300';
         String json1 = '{"head":{"version":"1.0","timestamp":"1566994462639","channelId":"web","tokenType":"AES","clientId":"12345"},"body":{"linkId":"5861","linkType":"FIXED","longUrl":"https://securegw-stage.paytm.in/link/PAYMENTLINKNAME/LL_5861","shortUrl":"https://paytm.me/ID-PBo7","expiryDate":"27/08/2020 17:44:22","isActive":true,"merchantHtml":"","createdDate":"28/08/2019 17:44:22","notificationDetails":[{"customerName":"John Doe","contact":"1234567890","notifyStatus":"error","timestamp":"1566994462639"}],"resultInfo":{"resultStatus":"error","resultCode":"300","resultMessage":"Payment link is created successfully"},"linkOrderId":"123"}}';

         List<IntgMsg__c> intMsglist =  TestDataFactory.createIntMsg(true, 'Paytm', lstAplicant[0].id, testData.jsonString);
         for(IntgMsg__c intMessage : intMsglist){
            intMessage.Resp__c = json1;
            intMessage.Req__c = testData.jsonString;
            intMessage.RefObj__c = 'Payment__c';
            intMessage.RefId__c =  lstappPay[0].Id;
           // intMessage.reApplIMD__c
             intMsglist1.add(intMessage);
        }
         PaytmResponseProcessor.process(intMsglist1);
    }

    @isTest
    Public static void test_process_4(){
         List<IntgMsg__c> intMsglist1 = new List<IntgMsg__c>();
         List<LoanAppl__c> loan =[SELECT Id FROM LoanAppl__c LIMIT 1];
         List<Applicant__c> lstAplicant = [SELECT Id From Applicant__c Limit 1];
         List<Payment__c> lstappPay = [SELECT ID FROM Payment__c Limit 1];
         TestDataFactory.PaytmResponseWrapperTestData testData = TestDataFactory.createPaytmResponseWrapperTestData();
         testData.resultInfo.resultCode = '300';
         String json1 = '{"head":{"version":"1.0","timestamp":"1566994462639","channelId":"web","tokenType":"AES","clientId":"12345"},"body":{"linkId":"5861","linkType":"FIXED","longUrl":"https://securegw-stage.paytm.in/link/PAYMENTLINKNAME/LL_5861","shortUrl":"https://paytm.me/ID-PBo7","expiryDate":"27/08/2020 17:44:22","isActive":true,"merchantHtml":"","createdDate":"28/08/2019 17:44:22","notificationDetails":[{"customerName":"John Doe","contact":"1234567890","notifyStatus":"error","timestamp":"1566994462639"}],"resultInfo":{"resultStatus":"error","resultCode":"300","resultMessage":"Payment link is created successfully"},"linkOrderId":"123"}}';
         List<ApplIMD__c> lstappImd = [SELECT ID FROM ApplIMD__c Limit 1];
         system.assert(!loan.isEmpty(), 'loan list should not empty.');

         List<IntgMsg__c> intMsglist =  TestDataFactory.createIntMsg(true, 'Paytm', lstAplicant[0].id, testData.jsonString);
         for(IntgMsg__c intMessage : intMsglist){
            intMessage.Resp__c = json1;
            intMessage.Req__c = testData.jsonString;
            intMessage.RefObj__c = 'ApplIMD__c';
            intMessage.RefId__c =  lstappImd[0].Id;
           // intMessage.reApplIMD__c
             intMsglist1.add(intMessage);
        }
         PaytmResponseProcessor.process(intMsglist1);
    }

}