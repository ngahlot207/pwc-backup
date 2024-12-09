@isTest
public class CompositePaymentRequestGenerator_Test {
    
    @isTest
    public static void generateTest(){  
        
        LoanAppl__c la=new LoanAppl__c();
        la.ChannelName__c='test';
        insert la;
        
        Applicant__c ap=new Applicant__c();
        ap.LoanAppln__c=la.id;
        ap.Constitution__c='INDIVIDUAL';
        insert ap;
        
        ApplKyc__c ak=new ApplKyc__c();
        ak.Applicant__c=ap.id;
        ak.kycDoc__c='Pan';
        ak.Name__c='test';
        ak.Pan__c='KIOPA1722K';
        insert ak;
        
        Repayment_Account__c ra = new Repayment_Account__c();
        ra.Name = 'CompositePaymentRequestGenerator';
        ra.Loan_Application__c = la.id;
        insert ra;
        
        RepayAccVerify__c rav = new RepayAccVerify__c();
        rav.RepayAcc__c = ra.Id;
        rav.RefId__c = ap.Id;
        insert rav;
        
        IntgMsg__c intgMsg = new IntgMsg__c();
        intgMsg.Name='ICICI PennyDrop';
        intgMsg.BU__c='HL / STL';
        intgMsg.Status__c='New';
        intgMsg.MStatus__c='Blank';
        intgMsg.RefObj__c='RepayAccVerify__c';
        intgMsg.RefId__c = rav.Id;
        
        intgMsg.Trigger_Platform_Event__c=true;
        insert intgMsg;
        
        Disbursement__c dis = new Disbursement__c();
        dis.Loan_Appli__c = la.id;
        dis.ApplicationID__c = ap.id;
        insert dis;
        Split_Disbur__c splidDis = new Split_Disbur__c();
        splidDis.RefId__c = ap.id;
        splidDis.DisburseRela__c = dis.id;
        insert splidDis;
        
        IntgMsg__c intgMsg1 = new IntgMsg__c();
        intgMsg1.Name='ICICI PennyDrop';
        intgMsg1.BU__c='HL / STL';
        intgMsg1.Status__c='New';
        intgMsg1.MStatus__c='Blank';
        intgMsg1.RefObj__c='Split_Disbur__c';
        intgMsg1.RefId__c = splidDis.Id;
       
        intgMsg1.Trigger_Platform_Event__c=true;
        insert intgMsg1;
        
            //Request Class
            List<IntgMsg__c> msgs = new List<IntgMsg__c>{intgMsg,intgMsg1};
            CompositePaymentRequestGenerator requestGenerator = new CompositePaymentRequestGenerator();
            requestGenerator.generate(msgs, 'CompositePaymentRequestGenerator', 'Async');
    }
}