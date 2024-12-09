@isTest
public class ConsumerACKTest {
    @isTest
    public static void testGenerateMethod() {
        
        LoanAppl__c La=new LoanAppl__c();
        la.ReqLoanAmt__c=100000;
        la.Product__c='Home Loan';
        
        TriggerBase.bypass('LoanAppl__c');
        insert La;
        TriggerBase.clearBypass('LoanAppl__c');
        
        Applicant__c app=new Applicant__c();
        app.LoanAppln__c=la.Id;
        app.Gender__c='M';
        app.DOB__c=Date.valueof('1998-12-31');
        app.MobNumber__c='9134268746';
        
        TriggerBase.bypass('Applicant__c');
        insert app;
        TriggerBase.clearBypass('Applicant__c');
        
        List<ApplKyc__c> ApplKyclist =new List<ApplKyc__c>();
        
        ApplKyc__c apkyc1=new ApplKyc__c();
        apkyc1.Applicant__c=app.Id;
        apkyc1.Pan__c='DOKPS1833M';
        apkyc1.Name__c='test';
        apkyc1.kycDoc__c='Pan';
        apkyc1.DtOfIssue__c=Date.newInstance(2016, 12, 9);
        ApplKyclist.add(apkyc1);
        
        ApplKyc__c apkyc2=new ApplKyc__c();
        apkyc2.Applicant__c=app.Id;
        apkyc2.PassNo__c='DOKPS1833M';
        apkyc2.Name__c='test';
        apkyc2.kycDoc__c='Passport';
        apkyc2.PassIssueDt__c=Date.newInstance(2016, 12, 9);
        apkyc2.PassExpDt__c=Date.newInstance(2023, 12, 9);    
        ApplKyclist.add(apkyc2);
        
        ApplKyc__c apkyc3=new ApplKyc__c();
        apkyc3.Applicant__c=app.Id;
        apkyc3.VotIdEpicNo__c='DOKPS1833M';
        apkyc3.Name__c='test';
        apkyc3.kycDoc__c='Voter Id';
        ApplKyclist.add(apkyc3);
        
        ApplKyc__c apkyc4=new ApplKyc__c();
        apkyc4.Applicant__c=app.Id;
        apkyc4.DLNo__c='DOKPS1833M';
        apkyc4.Name__c='test';
        apkyc4.kycDoc__c='Driving License';
        apkyc4.DLIssueDt__c=Date.newInstance(2016, 12, 9);
        apkyc4.DLExpDt__c=Date.newInstance(2023, 12, 9);
        ApplKyclist.add(apkyc4);
        
        if(!ApplKyclist.isempty()){
            TriggerBase.bypass('ApplKyc__c');
            insert ApplKyclist;
            TriggerBase.clearBypass('ApplKyc__c');
        }
        
         
        List<ApplAddr__c> ApplAddrlist=new List<ApplAddr__c>();
        
        ApplAddr__c adrs=new ApplAddr__c();
        adrs.HouseNo__c='23';
        adrs.Applicant__c=app.Id;
        adrs.AddrLine1__c='test';
        adrs.AddrLine2__c='test';
        adrs.AddrTyp__c='Residence Address';
        adrs.City__c='Tiptur';
        adrs.Pincode__c='572201';
        adrs.State__c='Karnataka';
        ApplAddrlist.add(adrs);
        
        ApplAddr__c adrs1=new ApplAddr__c();
        adrs1.HouseNo__c='23';
        adrs1.Applicant__c=app.Id;
        adrs1.AddrLine1__c='test';
        adrs1.AddrLine2__c='test';
        adrs1.AddrTyp__c='Residence Cum office';
        adrs1.City__c='Tiptur';
        adrs1.Pincode__c='572201';
        adrs1.State__c='Karnataka';
        ApplAddrlist.add(adrs1);
        
        if(!ApplAddrlist.isempty()){
            insert ApplAddrlist;
        }
        
        
        IntgMsg__c intgMsg =new IntgMsg__c();
        intgMsg.Name='Consumer ACK Request';
        intgMsg.BU__c='HL / STL';
        intgMsg.Status__c='New';
        intgMsg.MStatus__c='Blank';
        intgMsg.RefObj__c='Applicant__c';
        intgMsg.RefId__c = app.Id;
        intgMsg.Trigger_Platform_Event__c=true;
        intgMsg.Resp__c='{"STATUS":"SUCCESS","ACKNOWLEDGEMENT-ID":9151651,"HEADER":{"CUST-ID":"A-002258","APPLICATION-ID":"LAN-0143","RESPONSE-TYPE":"ACKNOWLEDGEMENT","REQUEST-RECEIVED-TIME":"19122023 21:52:36"}}';
        insert intgMsg;
        
        List<IntgMsg__c> req =new List<IntgMsg__c>{intgMsg};
            ConsumerACKRequestGenerator generator = new ConsumerACKRequestGenerator();
        generator.generate(req, 'Consumer ACK Request', 'Async');
        
        
        List<IntgMsg__c> responses = new List<IntgMsg__c>{intgMsg};
            ConsumerACKResponseProcessor.process(responses);
        
        IntgMsg__c intgMsg1 =new IntgMsg__c();
        intgMsg1.Name='Consumer ACK Request';
        intgMsg1.BU__c='HL / STL';
        intgMsg1.Status__c='New';
        intgMsg1.MStatus__c='Blank';
        intgMsg1.RefObj__c='Applicant__c';
        intgMsg1.RefId__c = app.Id;
        intgMsg.Trigger_Platform_Event__c=true;
        intgMsg1.Resp__c='{"STATUS":"ERROR","ERRORS":[{"CODE":"E135","DESCRIPTION":"Applicant name is compulsory"}],"HEADER":{"CUST-ID":"A-000126","APPLICATION-ID":"LAN-0143","RESPONSE-TYPE":"ACKNOWLEDGEMENT","REQUEST-RECEIVED-TIME":"21112023 15:26:55"}}';
        insert intgMsg1;
        
        List<IntgMsg__c> responses1 = new List<IntgMsg__c>{intgMsg1};
            ConsumerACKResponseProcessor.process(responses1);
        
        
        ConsumerACKResponseWrapper res = ConsumerACKResponseWrapper.praser(intgMsg1.Resp__c);
        
    }
    
    @isTest
    public static void testGenerateMethod2() {
        
        LoanAppl__c La=new LoanAppl__c();
        la.ReqLoanAmt__c=100000;
        la.Product__c='Home Loan';
        
        TriggerBase.bypass('LoanAppl__c');
        insert La;
        TriggerBase.clearBypass('LoanAppl__c');
        
        Applicant__c app=new Applicant__c();
        app.LoanAppln__c=la.Id;
        app.Gender__c='	F';
        app.DOB__c=Date.valueof('1998-12-31');
        app.MobNumber__c='9134268746';
        
        TriggerBase.bypass('Applicant__c');
        insert app;
        TriggerBase.clearBypass('Applicant__c');
        
        List<ApplKyc__c> ApplKyclist =new List<ApplKyc__c>();
        
        ApplKyc__c apkyc2=new ApplKyc__c();
        apkyc2.Applicant__c=app.Id;
        apkyc2.PassNo__c='DOKPS1833M';
        apkyc2.Name__c='test';
        apkyc2.kycDoc__c='Passport';
        apkyc2.PassIssueDt__c=Date.newInstance(2016, 12, 9);
        apkyc2.PassExpDt__c=Date.newInstance(2023, 12, 9);    
        ApplKyclist.add(apkyc2);
        
        ApplKyc__c apkyc3=new ApplKyc__c();
        apkyc3.Applicant__c=app.Id;
        apkyc3.VotIdEpicNo__c='DOKPS1833M';
        apkyc3.Name__c='test';
        apkyc3.kycDoc__c='Voter Id';
        ApplKyclist.add(apkyc3);
        
        ApplKyc__c apkyc4=new ApplKyc__c();
        apkyc4.Applicant__c=app.Id;
        apkyc4.DLNo__c='DOKPS1833M';
        apkyc4.Name__c='test';
        apkyc4.kycDoc__c='Driving License';
        apkyc4.DLIssueDt__c=Date.newInstance(2016, 12, 9);
        apkyc4.DLExpDt__c=Date.newInstance(2023, 12, 9);
        ApplKyclist.add(apkyc4);
        
        ApplKyc__c apkyc1=new ApplKyc__c();
        apkyc1.Applicant__c=app.Id;
        apkyc1.Pan__c='DOKPS1833M';
        apkyc1.Name__c='test';
        apkyc1.kycDoc__c='Pan';
        apkyc1.DtOfIssue__c=Date.newInstance(2016, 12, 9);
        ApplKyclist.add(apkyc1);
        
        if(!ApplKyclist.isempty()){
            TriggerBase.bypass('ApplKyc__c');
            insert ApplKyclist;
            TriggerBase.clearBypass('ApplKyc__c');
        }
        
         
        List<ApplAddr__c> ApplAddrlist=new List<ApplAddr__c>();
        
        ApplAddr__c adrs1=new ApplAddr__c();
        adrs1.Applicant__c=app.Id;
        adrs1.AddrLine1__c='test';
        adrs1.AddrLine2__c='test';
        adrs1.AddrTyp__c='Residence Cum office';
        adrs1.City__c='Tiptur';
        adrs1.Pincode__c='572201';
        adrs1.State__c='Karnataka';
        ApplAddrlist.add(adrs1);
        
        ApplAddr__c adrs=new ApplAddr__c();
        adrs.Applicant__c=app.Id;
        adrs.AddrLine1__c='test';
        adrs.AddrLine2__c='test';
        adrs.AddrTyp__c='Residence Address';
        adrs.City__c='Tiptur';
        adrs.Pincode__c='572201';
        adrs.State__c='Karnataka';
        ApplAddrlist.add(adrs);
        
        if(!ApplAddrlist.isempty()){
            insert ApplAddrlist;
        }
        
        
        IntgMsg__c intgMsg =new IntgMsg__c();
        intgMsg.Name='Consumer ACK Request';
        intgMsg.BU__c='HL / STL';
        intgMsg.Status__c='New';
        intgMsg.MStatus__c='Blank';
        intgMsg.RefObj__c='Applicant__c';
        intgMsg.RefId__c = app.Id;
        intgMsg.Trigger_Platform_Event__c=true;
        intgMsg.Resp__c='{"STATUS":"SUCCESS","ACKNOWLEDGEMENT-ID":9151651,"HEADER":{"CUST-ID":"A-002258","APPLICATION-ID":"LAN-0143","RESPONSE-TYPE":"ACKNOWLEDGEMENT","REQUEST-RECEIVED-TIME":"19122023 21:52:36"}}';
        insert intgMsg;
        
        List<IntgMsg__c> req =new List<IntgMsg__c>{intgMsg};
            ConsumerACKRequestGenerator generator = new ConsumerACKRequestGenerator();
        generator.generate(req, 'Consumer ACK Request', 'Async');
        
        
        List<IntgMsg__c> responses = new List<IntgMsg__c>{intgMsg};
            ConsumerACKResponseProcessor.process(responses);
        
        IntgMsg__c intgMsg1 =new IntgMsg__c();
        intgMsg1.Name='Consumer ACK Request';
        intgMsg1.BU__c='HL / STL';
        intgMsg1.Status__c='New';
        intgMsg1.MStatus__c='Blank';
        intgMsg1.RefObj__c='Applicant__c';
        intgMsg1.RefId__c = app.Id;
        intgMsg.Trigger_Platform_Event__c=true;
        intgMsg1.Resp__c='{"STATUS":"ERROR","ERRORS":[{"CODE":"E135","DESCRIPTION":"Applicant name is compulsory"}],"HEADER":{"CUST-ID":"A-000126","APPLICATION-ID":"LAN-0143","RESPONSE-TYPE":"ACKNOWLEDGEMENT","REQUEST-RECEIVED-TIME":"21112023 15:26:55"}}';
        insert intgMsg1;
        
        List<IntgMsg__c> responses1 = new List<IntgMsg__c>{intgMsg1};
            ConsumerACKResponseProcessor.process(responses1);
        
        
        ConsumerACKResponseWrapper res = ConsumerACKResponseWrapper.praser(intgMsg1.Resp__c);
        
    }
    
    @isTest
    public static void testGenerateMethod3() {
        
        LoanAppl__c La=new LoanAppl__c();
        la.ReqLoanAmt__c=100000;
        la.Product__c='Home Loan';
        
        TriggerBase.bypass('LoanAppl__c');
        insert La;
        TriggerBase.clearBypass('LoanAppl__c');
        
        Applicant__c app=new Applicant__c();
        app.LoanAppln__c=la.Id;
        app.Gender__c='M';
        app.DOB__c=Date.valueof('1998-12-31');
        app.MobNumber__c='9134268746';
        
        TriggerBase.bypass('Applicant__c');
        insert app;
        TriggerBase.clearBypass('Applicant__c');
        
        List<ApplKyc__c> ApplKyclist =new List<ApplKyc__c>();
        
        ApplKyc__c apkyc3=new ApplKyc__c();
        apkyc3.Applicant__c=app.Id;
        apkyc3.VotIdEpicNo__c='DOKPS1833M';
        apkyc3.Name__c='test';
        apkyc3.kycDoc__c='Voter Id';
        ApplKyclist.add(apkyc3);
        
        ApplKyc__c apkyc4=new ApplKyc__c();
        apkyc4.Applicant__c=app.Id;
        apkyc4.DLNo__c='DOKPS1833M';
        apkyc4.Name__c='test';
        apkyc4.kycDoc__c='Driving License';
        apkyc4.DLIssueDt__c=Date.newInstance(2016, 12, 9);
        apkyc4.DLExpDt__c=Date.newInstance(2023, 12, 9);
        ApplKyclist.add(apkyc4);
        
        ApplKyc__c apkyc1=new ApplKyc__c();
        apkyc1.Applicant__c=app.Id;
        apkyc1.Pan__c='DOKPS1833M';
        apkyc1.Name__c='test';
        apkyc1.kycDoc__c='Pan';
        apkyc1.DtOfIssue__c=Date.newInstance(2016, 12, 9);
        ApplKyclist.add(apkyc1);
        
        ApplKyc__c apkyc2=new ApplKyc__c();
        apkyc2.Applicant__c=app.Id;
        apkyc2.PassNo__c='DOKPS1833M';
        apkyc2.Name__c='test';
        apkyc2.kycDoc__c='Passport';
        apkyc2.PassIssueDt__c=Date.newInstance(2016, 12, 9);
        apkyc2.PassExpDt__c=Date.newInstance(2023, 12, 9);    
        ApplKyclist.add(apkyc2);
        
        if(!ApplKyclist.isempty()){
            TriggerBase.bypass('ApplKyc__c');
            insert ApplKyclist;
            TriggerBase.clearBypass('ApplKyc__c');
        }
        
         
        List<ApplAddr__c> ApplAddrlist=new List<ApplAddr__c>();
        
        ApplAddr__c adrs=new ApplAddr__c();
        adrs.Applicant__c=app.Id;
        adrs.AddrLine1__c='test';
        adrs.AddrLine2__c='test';
        adrs.AddrTyp__c='Residence Address';
        adrs.City__c='Tiptur';
        adrs.Pincode__c='572201';
        adrs.State__c='Karnataka';
        ApplAddrlist.add(adrs);
        
        ApplAddr__c adrs1=new ApplAddr__c();
        adrs1.Applicant__c=app.Id;
        adrs1.AddrLine1__c='test';
        adrs1.AddrLine2__c='test';
        adrs1.AddrTyp__c='Residence Cum office';
        adrs1.City__c='Tiptur';
        adrs1.Pincode__c='572201';
        adrs1.State__c='Karnataka';
        ApplAddrlist.add(adrs1);
        
        if(!ApplAddrlist.isempty()){
            insert ApplAddrlist;
        }
        
        
        IntgMsg__c intgMsg =new IntgMsg__c();
        intgMsg.Name='Consumer ACK Request';
        intgMsg.BU__c='HL / STL';
        intgMsg.Status__c='New';
        intgMsg.MStatus__c='Blank';
        intgMsg.RefObj__c='Applicant__c';
        intgMsg.RefId__c = app.Id;
        intgMsg.Trigger_Platform_Event__c=true;
        intgMsg.Resp__c='{"STATUS":"SUCCESS","ACKNOWLEDGEMENT-ID":9151651,"HEADER":{"CUST-ID":"A-002258","APPLICATION-ID":"LAN-0143","RESPONSE-TYPE":"ACKNOWLEDGEMENT","REQUEST-RECEIVED-TIME":"19122023 21:52:36"}}';
        insert intgMsg;
        
        List<IntgMsg__c> req =new List<IntgMsg__c>{intgMsg};
            ConsumerACKRequestGenerator generator = new ConsumerACKRequestGenerator();
        generator.generate(req, 'Consumer ACK Request', 'Async');
        
        
        List<IntgMsg__c> responses = new List<IntgMsg__c>{intgMsg};
            ConsumerACKResponseProcessor.process(responses);
        
        IntgMsg__c intgMsg1 =new IntgMsg__c();
        intgMsg1.Name='Consumer ACK Request';
        intgMsg1.BU__c='HL / STL';
        intgMsg1.Status__c='New';
        intgMsg1.MStatus__c='Blank';
        intgMsg1.RefObj__c='Applicant__c';
        intgMsg1.RefId__c = app.Id;
        intgMsg.Trigger_Platform_Event__c=true;
        intgMsg1.Resp__c='{"STATUS":"ERROR","ERRORS":[{"CODE":"E135","DESCRIPTION":"Applicant name is compulsory"}],"HEADER":{"CUST-ID":"A-000126","APPLICATION-ID":"LAN-0143","RESPONSE-TYPE":"ACKNOWLEDGEMENT","REQUEST-RECEIVED-TIME":"21112023 15:26:55"}}';
        insert intgMsg1;
        
        List<IntgMsg__c> responses1 = new List<IntgMsg__c>{intgMsg1};
            ConsumerACKResponseProcessor.process(responses1);
        
        
        ConsumerACKResponseWrapper res = ConsumerACKResponseWrapper.praser(intgMsg1.Resp__c);
        
    }
    
    @isTest
    public static void testGenerateMethod4() {
        
        LoanAppl__c La=new LoanAppl__c();
        la.ReqLoanAmt__c=100000;
        la.Product__c='Home Loan';
        
        TriggerBase.bypass('LoanAppl__c');
        insert La;
        TriggerBase.clearBypass('LoanAppl__c');
        
        Applicant__c app=new Applicant__c();
        app.LoanAppln__c=la.Id;
        app.Gender__c='	M';
        app.DOB__c=Date.valueof('1998-12-31');
        app.MobNumber__c='9134268746';
        
        TriggerBase.bypass('Applicant__c');
        insert app;
        TriggerBase.clearBypass('Applicant__c');
        
        List<ApplKyc__c> ApplKyclist =new List<ApplKyc__c>();
        
        ApplKyc__c apkyc4=new ApplKyc__c();
        apkyc4.Applicant__c=app.Id;
        apkyc4.DLNo__c='DOKPS1833M';
        apkyc4.Name__c='test';
        apkyc4.kycDoc__c='Driving License';
        apkyc4.DLIssueDt__c=Date.newInstance(2016, 12, 9);
        apkyc4.DLExpDt__c=Date.newInstance(2023, 12, 9);
        ApplKyclist.add(apkyc4);
        
        ApplKyc__c apkyc1=new ApplKyc__c();
        apkyc1.Applicant__c=app.Id;
        apkyc1.Pan__c='DOKPS1833M';
        apkyc1.Name__c='test';
        apkyc1.kycDoc__c='Pan';
        apkyc1.DtOfIssue__c=Date.newInstance(2016, 12, 9);
        ApplKyclist.add(apkyc1);
        
        ApplKyc__c apkyc2=new ApplKyc__c();
        apkyc2.Applicant__c=app.Id;
        apkyc2.PassNo__c='DOKPS1833M';
        apkyc2.Name__c='test';
        apkyc2.kycDoc__c='Passport';
        apkyc2.PassIssueDt__c=Date.newInstance(2016, 12, 9);
        apkyc2.PassExpDt__c=Date.newInstance(2023, 12, 9);    
        ApplKyclist.add(apkyc2);
        
        ApplKyc__c apkyc3=new ApplKyc__c();
        apkyc3.Applicant__c=app.Id;
        apkyc3.VotIdEpicNo__c='DOKPS1833M';
        apkyc3.Name__c='test';
        apkyc3.kycDoc__c='Voter Id';
        ApplKyclist.add(apkyc3);
        
        if(!ApplKyclist.isempty()){
            TriggerBase.bypass('ApplKyc__c');
            insert ApplKyclist;
            TriggerBase.clearBypass('ApplKyc__c');
        }
        
         
        List<ApplAddr__c> ApplAddrlist=new List<ApplAddr__c>();
        
        ApplAddr__c adrs=new ApplAddr__c();
        adrs.Applicant__c=app.Id;
        adrs.AddrLine1__c='test';
        adrs.AddrLine2__c='test';
        adrs.AddrTyp__c='Residence Address';
        adrs.City__c='Tiptur';
        adrs.Pincode__c='572201';
        adrs.State__c='Karnataka';
        ApplAddrlist.add(adrs);
        
        ApplAddr__c adrs1=new ApplAddr__c();
        adrs1.Applicant__c=app.Id;
        adrs1.AddrLine1__c='test';
        adrs1.AddrLine2__c='test';
        adrs1.AddrTyp__c='Residence Cum office';
        adrs1.City__c='Tiptur';
        adrs1.Pincode__c='572201';
        adrs1.State__c='Karnataka';
        ApplAddrlist.add(adrs1);
        
        if(!ApplAddrlist.isempty()){
            insert ApplAddrlist;
        }
        
        
        IntgMsg__c intgMsg =new IntgMsg__c();
        intgMsg.Name='Consumer ACK Request';
        intgMsg.BU__c='HL / STL';
        intgMsg.Status__c='New';
        intgMsg.MStatus__c='Blank';
        intgMsg.RefObj__c='Applicant__c';
        intgMsg.RefId__c = app.Id;
        intgMsg.Trigger_Platform_Event__c=true;
        intgMsg.Resp__c='{"STATUS":"SUCCESS","ACKNOWLEDGEMENT-ID":9151651,"HEADER":{"CUST-ID":"A-002258","APPLICATION-ID":"LAN-0143","RESPONSE-TYPE":"ACKNOWLEDGEMENT","REQUEST-RECEIVED-TIME":"19122023 21:52:36"}}';
        insert intgMsg;
        
        List<IntgMsg__c> req =new List<IntgMsg__c>{intgMsg};
            ConsumerACKRequestGenerator generator = new ConsumerACKRequestGenerator();
        generator.generate(req, 'Consumer ACK Request', 'Async');
        
        
        List<IntgMsg__c> responses = new List<IntgMsg__c>{intgMsg};
            ConsumerACKResponseProcessor.process(responses);
        
        IntgMsg__c intgMsg1 =new IntgMsg__c();
        intgMsg1.Name='Consumer ACK Request';
        intgMsg1.BU__c='HL / STL';
        intgMsg1.Status__c='New';
        intgMsg1.MStatus__c='Blank';
        intgMsg1.RefObj__c='Applicant__c';
        intgMsg1.RefId__c = app.Id;
        intgMsg.Trigger_Platform_Event__c=true;
        intgMsg1.Resp__c='{"STATUS":"ERROR","ERRORS":[{"CODE":"E135","DESCRIPTION":"Applicant name is compulsory"}],"HEADER":{"CUST-ID":"A-000126","APPLICATION-ID":"LAN-0143","RESPONSE-TYPE":"ACKNOWLEDGEMENT","REQUEST-RECEIVED-TIME":"21112023 15:26:55"}}';
        insert intgMsg1;
        
        List<IntgMsg__c> responses1 = new List<IntgMsg__c>{intgMsg1};
            ConsumerACKResponseProcessor.process(responses1);
        
        
        ConsumerACKResponseWrapper res = ConsumerACKResponseWrapper.praser(intgMsg1.Resp__c);
        
    }
    
}