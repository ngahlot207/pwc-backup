@isTest
public class CrimeCheckAddReportAPITest {
    
    @isTest
    public Static Void testMethod1(){
        
        LoanAppl__c la = TestDataFactory.createLoanApplication(true);
        
        Applicant__c app1 = new  Applicant__c();
        app1.LoanAppln__c=la.Id;
        app1.Constitution__c='INDIVIDUAL';
        
        insert app1;
        
        List<ApplAddr__c> addrsList =new List<ApplAddr__c>();
        
        ApplAddr__c addrs1 =new ApplAddr__c();
        addrs1.LoanAppl__c=la.id;
        addrs1.Applicant__c=app1.Id;
        addrs1.AddrTyp__c='Principal place for business';
        addrs1.HouseNo__c='test';
        addrs1.AddrLine1__c='test';
        addrs1.AddrLine2__c='test';
        addrs1.State__c='Karnataka';
        addrs1.City__c='Bangalore';
        addrs1.Pincode__c='560001';
        
        addrsList.add(addrs1);
        
        ApplAddr__c addrs2 =new ApplAddr__c();
        addrs2.LoanAppl__c=la.id;
        addrs2.Applicant__c=app1.Id;
        addrs2.AddrTyp__c='Residence Address';
        addrs2.HouseNo__c='test';
        addrs2.AddrLine1__c='test';
        addrs2.AddrLine2__c='test';
        addrs2.State__c='Karnataka';
        addrs2.City__c='Bangalore';
        addrs2.Pincode__c='560001';
        
        addrsList.add(addrs2);
        
        ApplAddr__c addrs3 =new ApplAddr__c();
        addrs3.LoanAppl__c=la.id;
        addrs3.Applicant__c=app1.Id;
        addrs3.AddrTyp__c='Residence Cum office';
        addrs3.HouseNo__c='test';
        addrs3.AddrLine1__c='test';
        addrs3.AddrLine2__c='test';
        addrs3.State__c='Karnataka';
        addrs3.City__c='Bangalore';
        addrs3.Pincode__c='560001';
        
        addrsList.add(addrs3);
        
        insert addrsList;
        
        
        ApplKyc__c kyc1 =new ApplKyc__c();
        kyc1.Applicant__c=app1.Id;
        kyc1.kycDoc__c='Pan';
        kyc1.Pan__c='KOYPA188D';
        insert kyc1;
        
        
        
        Id recordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByDeveloperName().get('CrimeCheck').getRecordTypeId(); 
        
       
        APIConfiguration__c apiconfig =new APIConfiguration__c();
        apiconfig.Name='Crime Check';
        apiconfig.Priority__c='test';
        apiconfig.APIKey__c='test';
        apiconfig.URL__c='test';
        apiconfig.Consent__c=false;
        Insert apiconfig;
        
        List<IntgMsg__c> intmsglist =new List<IntgMsg__c>();
        
        IntgMsg__c intgMsg1 =new IntgMsg__c();
        intgMsg1.Name='Crime Check';
        intgMsg1.BU__c='HL / STL';
        intgMsg1.Status__c='New';
        intgMsg1.MStatus__c='Blank';
        intgMsg1.RefObj__c='Applicant__c';
        intgMsg1.RefId__c = app1.Id;
        intgMsg1.Trigger_Platform_Event__c=true;
        intgMsg1.Resp__c='{"status":"OK","requestTime":"11/04/2018 12:58:17","requestId":"1"}';
        intmsglist.add(intgMsg1);
        
        insert intmsglist;
        
        Test.startTest();
        CrimeCheckAddReportAPIRequestGenerator request =new CrimeCheckAddReportAPIRequestGenerator();
        request.generate(intmsglist,'Crime Check', 'Async');
        
        CrimeCheckAddReportAPIResponseProcessor.process(intmsglist);
        Test.stopTest();
    }
    
    @istest
    public Static Void testMethod2(){
        LoanAppl__c la = TestDataFactory.createLoanApplication(true);
        
        Applicant__c app1 = new  Applicant__c();
        app1.LoanAppln__c=la.Id;
        app1.Constitution__c='PROPERITORSHIP';
        insert app1;
        
        Applicant__c app2 = new  Applicant__c();
        app2.LoanAppln__c=la.Id;
        app2.Constitution__c='PROPERITORSHIP';
        insert app2;
        
         APIConfiguration__c apiconfig =new APIConfiguration__c();
        apiconfig.Name='Crime Check';
        apiconfig.Priority__c='test';
        apiconfig.APIKey__c='test';
        apiconfig.URL__c='test';
        apiconfig.Consent__c=false;
        Insert apiconfig;
        
        List<ApplAddr__c> addrsList =new List<ApplAddr__c>();
        
        ApplAddr__c addrs4 =new ApplAddr__c();
        addrs4.LoanAppl__c=la.id;
        addrs4.Applicant__c=app1.id;
        addrs4.AddrTyp__c='Principal place for business';
        addrs4.HouseNo__c='test';
        addrs4.AddrLine1__c='test';
        addrs4.AddrLine2__c='test';
        addrs4.State__c='Karnataka';
        addrs4.City__c='Bangalore';
        addrs4.Pincode__c='560001';
        
        addrsList.add(addrs4);
        
        ApplAddr__c addrs5 =new ApplAddr__c();
        addrs5.LoanAppl__c=la.id;
        addrs5.Applicant__c=app1.id;
        addrs5.AddrTyp__c='Residence Address';
        addrs5.HouseNo__c='test';
        addrs5.AddrLine1__c='test';
        addrs5.AddrLine2__c='test';
        addrs5.State__c='Karnataka';
        addrs5.City__c='Bangalore';
        addrs5.Pincode__c='560001';
        
        addrsList.add(addrs5);
        
        ApplAddr__c addrs6 =new ApplAddr__c();
        addrs6.LoanAppl__c=la.id;
        addrs6.Applicant__c=app1.id;
        addrs6.AddrTyp__c='Residence Cum office';
        addrs6.HouseNo__c='test';
        addrs6.AddrLine1__c='test';
        addrs6.AddrLine2__c='test';
        addrs6.State__c='Karnataka';
        addrs6.City__c='Bangalore';
        addrs6.Pincode__c='560001';
        
        addrsList.add(addrs6);
        
        
        ApplAddr__c addrs7 =new ApplAddr__c();
        addrs7.LoanAppl__c=la.id;
        addrs7.Applicant__c=app2.id;
        addrs7.AddrTyp__c='Principal place for business';
        addrs7.HouseNo__c='test';
        addrs7.AddrLine1__c='test';
        addrs7.AddrLine2__c='test';
        addrs7.State__c='Karnataka';
        addrs7.City__c='Bangalore';
        addrs7.Pincode__c='560001';
        
        addrsList.add(addrs7);
        
        
        ApplAddr__c addrs8 =new ApplAddr__c();
        addrs8.LoanAppl__c=la.id;
        addrs8.Applicant__c=app2.id;
        addrs8.AddrTyp__c='Residence Address';
        addrs8.HouseNo__c='test';
        addrs8.AddrLine1__c='test';
        addrs8.AddrLine2__c='test';
        addrs8.State__c='Karnataka';
        addrs8.City__c='Bangalore';
        addrs8.Pincode__c='560001';
        
        addrsList.add(addrs8);
        
        insert addrsList;
        
        ApplKyc__c kyc2 =new ApplKyc__c();
        kyc2.Applicant__c=app1.Id;
        kyc2.kycDoc__c='Pan';
        kyc2.Pan__c='KOYPA188D';
        insert kyc2;
        
        IntgMsg__c intgMsg2 =new IntgMsg__c();
        intgMsg2.Name='Crime Check';
        intgMsg2.BU__c='HL / STL';
        intgMsg2.Status__c='New';
        intgMsg2.MStatus__c='Blank';
        intgMsg2.RefObj__c='Applicant__c';
        intgMsg2.RefId__c = app1.Id;
        intgMsg2.Trigger_Platform_Event__c=true;
        intgMsg2.Resp__c='{"status":"OK","requestTime":"11/04/2018 12:58:17","requestId":"2"}';
        
        IntgMsg__c intgMsg3 =new IntgMsg__c();
        intgMsg3.Name='Crime Check';
        intgMsg3.BU__c='HL / STL';
        intgMsg3.Status__c='New';
        intgMsg3.MStatus__c='Blank';
        intgMsg3.RefObj__c='Applicant__c';
        intgMsg3.RefId__c = app2.Id;
        intgMsg3.Trigger_Platform_Event__c=true;
        intgMsg3.Resp__c='invalid';
        
        List<IntgMsg__c> intmsglist =new List<IntgMsg__c>{intgMsg2,intgMsg3};
            insert intmsglist;
        
        Test.startTest();
        CrimeCheckAddReportAPIRequestGenerator request =new CrimeCheckAddReportAPIRequestGenerator();
        request.generate(intmsglist,'Crime Check', 'Async');
        CrimeCheckAddReportAPIResponseProcessor.process(intmsglist);
        Test.stopTest();
    }
    
    @istest
    public Static Void testMethod3(){
        LoanAppl__c la = TestDataFactory.createLoanApplication(true);
        
        Applicant__c app1 = new  Applicant__c();
        app1.LoanAppln__c=la.Id;
        app1.Constitution__c='HUF';
        insert app1;
        
        
         ApplicantEmployment__c emp =new ApplicantEmployment__c();
        emp.LoanApplicant__c=app1.Id;
        emp.GSTIN__c='gst12345678';
        insert emp;
        
         APIConfiguration__c apiconfig =new APIConfiguration__c();
        apiconfig.Name='Crime Check';
        apiconfig.Priority__c='test';
        apiconfig.APIKey__c='test';
        apiconfig.URL__c='test';
        apiconfig.Consent__c=false;
        Insert apiconfig;
        
        ApplAddr__c addrs7 =new ApplAddr__c();
        addrs7.LoanAppl__c=la.id;
        addrs7.Applicant__c=app1.id;
        addrs7.AddrTyp__c='Principal place for business';
        addrs7.HouseNo__c='test';
        addrs7.AddrLine1__c='test';
        addrs7.AddrLine2__c='test';
        addrs7.State__c='Karnataka';
        addrs7.City__c='Bangalore';
        addrs7.Pincode__c='560001';
        
        insert addrs7;
        
        ApplKyc__c kyc2 =new ApplKyc__c();
        kyc2.Applicant__c=app1.Id;
        kyc2.kycDoc__c='Pan';
        kyc2.Pan__c='KOYPA188D';
        insert kyc2;
        
        IntgMsg__c intgMsg2 =new IntgMsg__c();
        intgMsg2.Name='Crime Check';
        intgMsg2.BU__c='HL / STL';
        intgMsg2.Status__c='New';
        intgMsg2.MStatus__c='Blank';
        intgMsg2.RefObj__c='Applicant__c';
        intgMsg2.RefId__c = app1.Id;
        intgMsg2.Trigger_Platform_Event__c=true;
        intgMsg2.Resp__c='{"status":"OK","requestTime":"11/04/2018 12:58:17","requestId":"3"}';
        
        List<IntgMsg__c> intmsglist =new List<IntgMsg__c>{intgMsg2};
            insert intmsglist;
        
        Test.startTest();
        CrimeCheckAddReportAPIRequestGenerator request =new CrimeCheckAddReportAPIRequestGenerator();
        request.generate(intmsglist,'Crime Check', 'Async');
        
        Test.stopTest();
    }
    
}