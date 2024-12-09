@istest
public class CommercialACKTest {
    @isTest
    public static void testGenerateMethod() {
        
        LoanAppl__c La=new LoanAppl__c();
        la.ReqLoanAmt__c=100000;
        la.Product__c='Home Loan';
        la.LoanPurpose__c='Education of Family members/ Self';
        
        TriggerBase.bypass('LoanAppl__c');
        insert La;
        TriggerBase.clearBypass('LoanAppl__c');
        
        Applicant__c app=new Applicant__c();
        app.LoanAppln__c=la.Id;
        app.Gender__c='	M';
        app.DOB__c=Date.valueof('1998-12-31');
        app.MobNumber__c='9134268746';
        app.Constitution__c='ASSOCIATION OF PERSONS';
        
        TriggerBase.bypass('Applicant__c');
        insert app;
        TriggerBase.clearBypass('Applicant__c');
        
        
        ApplKyc__c apkyc=new ApplKyc__c();
        apkyc.Applicant__c=app.Id;
        apkyc.Pan__c='DOKPS1833M';
        apkyc.Name__c='test';
        apkyc.kycDoc__c='Pan';
        insert apkyc;
        
        ApplAddr__c adrs=new ApplAddr__c();
        adrs.HouseNo__c='23';
        adrs.Applicant__c=app.Id;
        adrs.AddrLine1__c='test';
        adrs.AddrLine2__c='test';
        adrs.AddrTyp__c='Principal place for business';
        adrs.City__c='Tiptur';
        adrs.Pincode__c='572201';
        adrs.State__c='Karnataka';
        insert adrs;
        
        IntgMsg__c intgMsg =new IntgMsg__c();
        intgMsg.Name='Commercial ACK Request';
        intgMsg.BU__c='HL / STL';
        intgMsg.Status__c='New';
        intgMsg.MStatus__c='Blank';
        intgMsg.RefObj__c='Applicant__c';
        intgMsg.RefId__c = app.Id;
        intgMsg.Trigger_Platform_Event__c=true;
        intgMsg.Resp__c='{"STATUS":"SUCCESS","ACKNOWLEDGEMENT-ID":9151651,"HEADER":{"CUST-ID":"A-002258","APPLICATION-ID":"LAN-0143","RESPONSE-TYPE":"ACKNOWLEDGEMENT","REQUEST-RECEIVED-TIME":"19122023 21:52:36"}}';
        insert intgMsg;
        
        List<IntgMsg__c> req =new List<IntgMsg__c>{intgMsg};
            CommercialACKRequestGenerator generator = new CommercialACKRequestGenerator();
        generator.generate(req, 'Commercial ACK Request', 'Async');
        
        
        List<IntgMsg__c> responses = new List<IntgMsg__c>{intgMsg};
            CommercialACKResponseProcess.process(responses);
        
        IntgMsg__c intgMsg1 =new IntgMsg__c();
        intgMsg1.Name='Commercial ACK Request';
        intgMsg1.BU__c='HL / STL';
        intgMsg1.Status__c='New';
        intgMsg1.MStatus__c='Blank';
        intgMsg1.RefObj__c='Applicant__c';
        intgMsg1.RefId__c = app.Id;
        intgMsg.Trigger_Platform_Event__c=true;
        intgMsg1.Resp__c='{"STATUS":"ERROR","ERRORS":[{"CODE":"E135","DESCRIPTION":"Applicant name is compulsory"}],"HEADER":{"CUST-ID":"A-000126","APPLICATION-ID":"LAN-0143","RESPONSE-TYPE":"ACKNOWLEDGEMENT","REQUEST-RECEIVED-TIME":"21112023 15:26:55"}}';
        insert intgMsg1;
        
        List<IntgMsg__c> responses1 = new List<IntgMsg__c>{intgMsg1};
            CommercialACKResponseProcess.process(responses1);
        
        
        CommercialACKResponseWrapper res = CommercialACKResponseWrapper.praser(intgMsg1.Resp__c);
        
    }
}