@isTest
public class IntegrationMessage_PopulatedateTest {
@isTest
    public static void testMethodIntegMesg(){
        
        LoanAppl__c La = TestDataFactory.createLoanApplication(true);
    	Applicant__c app = TestDataFactory.createSingleApplicant(true,La.id);
        DocMstr__c docMstr = TestDataFactory.createDocumentMaster(true,null);
        DocDtl__c docdtl = TestDataFactory.createDocumentDetail(true,'KYC Doc',app.id,docMstr.id);
        Payment__c paymt = new Payment__c();
        paymt.LoanAppl__c = la.id;
        paymt.InstrumentAmt__c = 500;
        insert paymt;
        Repayment_Account__c repayAcc=TestDataFactory.rePayAccData(true,la.id);
        
        RepayAccVerify__c repay= new RepayAccVerify__c();
        repay.RepayAcc__c = repayAcc.id;
        insert repay;
        ApplKyc__c appKYC = new ApplKyc__c();
        appKYC.Applicant__c =app.id;
        appKYC.kycDoc__c = 'Aadhaar';
        insert appKYC;
        
        ApplIMD__c appIMD = new ApplIMD__c();
        appIMD.AppId__c = app.id;
        appIMD.LoanAppln__c = la.id;
        insert appIMD;
        Task tsk = new Task();
        tsk.Subject = 'Call';
        tsk.WhatId = appIMD.id;
        insert tsk;
        
        Task tsk1 = new Task();
        tsk1.Subject = 'Call';
        tsk1.WhatId = la.id;
        insert tsk1;
        
        Task tsk2 = new Task();
        tsk2.Subject = 'Call';
        tsk2.WhatId = paymt.id;
        insert tsk2;
        
       IntgMsg__c intgMsg = new IntgMsg__c();
        intgMsg.Name='CompositePaymentRequestGenerator';
        intgMsg.BU__c='HL / STL';
        intgMsg.Status__c='New';
        intgMsg.MStatus__c='Blank';
        intgMsg.RefObj__c='Task';
        intgMsg.ParentRefObj__c='ApplIMD__c';
        intgMsg.RefId__c = tsk.Id;
        intgMsg.ParentRefId__c = appIMD.Id;
        insert intgMsg;
        
        IntgMsg__c intgMsg2 = new IntgMsg__c();
        intgMsg2.Name='CompositePaymentRequestGenerator';
        intgMsg2.BU__c='HL / STL';
        intgMsg2.Status__c='New';
        intgMsg2.MStatus__c='Blank';
        intgMsg2.RefObj__c='Task';
        intgMsg2.ParentRefObj__c='LoanAppl__c';
        intgMsg2.RefId__c = tsk1.Id;
        intgMsg2.ParentRefId__c = la.Id;
        insert intgMsg2;
        
        IntgMsg__c intgMsg3 = new IntgMsg__c();
        intgMsg3.Name='CompositePaymentRequestGenerator';
        intgMsg3.BU__c='HL / STL';
        intgMsg3.Status__c='New';
        intgMsg3.MStatus__c='Blank';
        intgMsg3.RefObj__c='ApplKyc__c';
        intgMsg3.ParentRefObj__c='Applicant__c';
        intgMsg3.RefId__c = appKYC.Id;
        intgMsg3.ParentRefId__c = app.Id;
        insert intgMsg3;
        
        IntgMsg__c intgMsg1 = new IntgMsg__c();
        intgMsg1.Name='CompositePaymentRequestGenerator';
        intgMsg1.BU__c='HL / STL';
        intgMsg1.Status__c='New';
        intgMsg1.MStatus__c='Blank';
        intgMsg1.RefObj__c='Applicant__c';
        intgMsg1.ParentRefId__c=la.id;
        intgMsg1.ParentRefObj__c='LoanAppl__c';
        intgMsg1.RefId__c = app.Id;
        insert intgMsg1;
        
        IntgMsg__c intgMsg4 = new IntgMsg__c();
        intgMsg4.Name='CompositePaymentRequestGenerator';
        intgMsg4.BU__c='HL / STL';
        intgMsg4.Status__c='New';
        intgMsg4.MStatus__c='Blank';
        intgMsg4.RefObj__c='DocDtl__c';
        intgMsg4.ParentRefId__c=la.id;
        intgMsg4.ParentRefObj__c='LoanAppl__c';
        intgMsg4.RefId__c = docdtl.id;
        insert intgMsg4;
        
        IntgMsg__c intgMsg5 = new IntgMsg__c();
        intgMsg5.Name='CompositePaymentRequestGenerator';
        intgMsg5.BU__c='HL / STL';
        intgMsg5.Status__c='New';
        intgMsg5.MStatus__c='Blank';
        intgMsg5.RefObj__c='Payment__c';
        intgMsg5.ParentRefId__c=la.id;
        intgMsg5.ParentRefObj__c='LoanAppl__c';
        intgMsg5.RefId__c = paymt.id;
        insert intgMsg5;
        
        IntgMsg__c intgMsg6 = new IntgMsg__c();
        intgMsg6.Name='CompositePaymentRequestGenerator';
        intgMsg6.BU__c='HL / STL';
        intgMsg6.Status__c='New';
        intgMsg6.MStatus__c='Blank';
        intgMsg6.RefObj__c='Task';
        intgMsg6.ParentRefObj__c='Payment__c';
        intgMsg6.RefId__c = tsk2.Id;
        intgMsg6.ParentRefId__c = paymt.Id;
        insert intgMsg6;
        
        IntgMsg__c intgMsg7 = new IntgMsg__c();
        intgMsg7.Name='CompositePaymentRequestGenerator';
        intgMsg7.BU__c='HL / STL';
        intgMsg7.Status__c='New';
        intgMsg7.MStatus__c='Blank';
        intgMsg7.ParentRefObj__c='LoanAppl__c';
        intgMsg7.RefId__c = la.Id;
        intgMsg7.ParentRefId__c = repay.Id;
        intgMsg7.RefObj__c = 'RepayAccVerify__c';
        insert intgMsg7;
        
         IntgMsg__c intgMsg8 = new IntgMsg__c();
        intgMsg8.Name='CompositePaymentRequestGenerator';
        intgMsg8.BU__c='HL / STL';
        intgMsg8.Status__c='New';
        intgMsg8.MStatus__c='Blank';
        intgMsg8.ParentRefObj__c='LoanAppl__c';
        intgMsg8.RefId__c = appimd.Id;
        intgMsg8.ParentRefId__c = la.Id;
        intgMsg8.RefObj__c = 'ApplIMD__c';
        insert intgMsg8;
        
        IntgMsg__c intgMsg9 = new IntgMsg__c();
        intgMsg9.Id=intgMsg8.Id;
        intgMsg9.Status__c ='In Progress';
        update intgMsg9;

        list<IntgMsg__c> IntgMsgList = new list<IntgMsg__c>{intgMsg,intgMsg1,intgMsg2,intgMsg3,intgMsg4,intgMsg5,intgMsg6,intgMsg7,intgMsg8};
        list<IntgMsg__c> IntgMsgList1 = new list<IntgMsg__c>();
        Test.startTest();
        IntegrationMessage_Populatedate IntgMesgPop = new IntegrationMessage_Populatedate();
      IntgMesgPop.Beforeupdate(IntgMsgList, IntgMsgList1);
        Test.stopTest();
    }
}