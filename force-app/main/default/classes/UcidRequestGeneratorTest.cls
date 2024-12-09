@isTest
public class UcidRequestGeneratorTest {
    
    @isTest
    public static void testGenerateMethod1() {
        
        LoanAppl__c la = TestDataFactory.createLoanApplication(true);
        Applicant__c ap = TestDataFactory.createSingleApplicant(true, la.Id);
        
        List<ApplKyc__c> ApplKycList=new List<ApplKyc__c>();
        
        ApplKyc__c ak=new ApplKyc__c();
        ak.Applicant__c=ap.id;
        ak.kycDoc__c='Aadhaar';
        ak.AadharEncripted__c='492515815873';
        ak.AadharNo__c='492515815873';
        ak.ValidationStatus__c = 'Success';
        ApplKycList.add(ak);
        
        ApplKyc__c ak1=new ApplKyc__c();
        ak1.Applicant__c=ap.id;
        ak1.kycDoc__c='Voter Id';
        ak1.VotIdEpicNo__c = 'EPIC001';
        ak1.AadharEncripted__c='492515815873';
        ak1.ValidationStatus__c = 'Success';
        ApplKycList.add(ak1);
        
        ApplKyc__c ak2=new ApplKyc__c();
        ak2.Applicant__c=ap.id;
        ak2.kycDoc__c='Driving License';
        ak2.DLNo__c = 'DLNO001';
        ak2.AadharEncripted__c='492515815873';
        ak2.ValidationStatus__c = 'Success';
        ApplKycList.add(ak2);
        
        ApplKyc__c ak3=new ApplKyc__c();
        ak3.Applicant__c=ap.id;
        ak3.kycDoc__c='Pan';
        ak3.Pan__c = 'PAN001';
        ak3.AadharEncripted__c='492515815873';
        ak3.ValidationStatus__c = 'Success';
        ApplKycList.add(ak3);
        
        ApplKyc__c ak4=new ApplKyc__c();
        ak4.Applicant__c=ap.id;
        ak4.kycDoc__c='Passport';
        ak4.PassNo__c = 'PASSNO001';
        ak4.AadharEncripted__c='492515815873';
        ak4.ValidationStatus__c = 'Success';
        ApplKycList.add(ak4);
        
        insert ApplKycList;
        
        ApplAddr__c addr1=new ApplAddr__c();
        addr1.Applicant__c=ap.Id;
        addr1.AddrTyp__c='Residence Address';
        addr1.AddrLine1__c='test';
        addr1.AddrLine2__c='test';
        addr1.City__c='test';
        addr1.State__c='test';
        addr1.HouseNo__c='1234';
        addr1.Pincode__c='23456';
        insert addr1;
        
        IntgMsg__c intgMsg1 = new IntgMsg__c();
        intgMsg1.Name='UCIC API Token';
        intgMsg1.BU__c='HL / STL';
        intgMsg1.Status__c='New';
        intgMsg1.MStatus__c='Blank';
        intgMsg1.RefObj__c='LoanAppl__c';
        intgMsg1.ParentRefId__c=ap.id;
        intgMsg1.ParentRefObj__c='Applicant__c';
        intgMsg1.RefId__c = la.Id;
        intgMsg1.Resp__c='{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3MTA3NzA3NTIsInVzZXJfbmFtZSI6ImJpam95QGFjdGlmeWRhdGFsYWJzLmNvbSIsImp0aSI6IjI4NTFhN2ZkLTEyZjgtNGQwNC1iNTgxLWRjOTRhZDgxNWY0MSIsImNsaWVudF9pZCI6ImU5M2JiZDBhOTllMTBkZWUzNzJkOWUyYTkwZTQzOTIxIiwic2NvcGUiOlsicmVhZCIsIndyaXRlIiwidHJ1c3QiXX0.KPP60e32sNII9sm1345ilwA0gGYah2QbeoE4J1P9BEQ","token_type":"bearer","refresh_token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3MTA3ODE1OTUsInVzZXJfbmFtZSI6ImJpam95QGFjdGlmeWRhdGFsYWJzLmNvbSIsImp0aSI6IjAzMTMyYjhmLTM1MjMtNGU0Mi1iYmEzLTVmYjUxMjhlMGU1MiIsImNsaWVudF9pZCI6ImU5M2JiZDBhOTllMTBkZWUzNzJkOWUyYTkwZTQzOTIxIiwic2NvcGUiOlsicmVhZCIsIndyaXRlIiwidHJ1c3QiXSwiYXRpIjoiMjg1MWE3ZmQtMTJmOC00ZDA0LWI1ODEtZGM5NGFkODE1ZjQxIn0.wrVZy2cXwJ0VAbnMlUZMvy5DdsUq96NNLqdYVtVgwhU","expires_in":153,"scope":"read write trust","jti":"2851a7fd-12f8-4d04-b581-dc94ad815f41"}';
        insert intgMsg1;
        
        IntgMsg__c intgMsg2 = new IntgMsg__c();
        intgMsg2.Name='UCIC';
        intgMsg2.BU__c='HL / STL';
        intgMsg2.Status__c='New';
        intgMsg2.MStatus__c='Blank';
        intgMsg2.RefObj__c='Applicant__c';
        intgMsg2.ParentRefId__c=intgMsg1.id;
        intgMsg2.ParentRefObj__c='IntgMsg__c';
        intgMsg2.RefId__c = ap.Id;
        intgMsg2.Resp__c='';
        insert intgMsg2;
        
        List<IntgMsg__c> msgs = new List<IntgMsg__c>{intgMsg2};
            UcidRequestGenerator ucicReqGen = new UcidRequestGenerator();
        ucicReqGen.generate(msgs, 'service', 'processType');
    }
    
    @isTest
    public static void testGenerateMethod2() {
        
        LoanAppl__c la = TestDataFactory.createLoanApplication(true);
        Applicant__c ap = TestDataFactory.createSingleApplicant(true, la.Id);
        
        List<ApplKyc__c> ApplKycList=new List<ApplKyc__c>();
        
        ApplKyc__c ak=new ApplKyc__c();
        ak.Applicant__c=ap.id;
        ak.kycDoc__c='Aadhaar';
        ak.AadharEncripted__c='492515815873';
        ak.AadharNo__c='492515815873';
        ak.ValidationStatus__c = 'Success';
        ApplKycList.add(ak);
        
        ApplKyc__c ak1=new ApplKyc__c();
        ak1.Applicant__c=ap.id;
        ak1.kycDoc__c='Voter Id';
        ak1.VotIdEpicNo__c = 'EPIC001';
        ak1.AadharEncripted__c='492515815873';
        ak1.ValidationStatus__c = 'Success';
        ApplKycList.add(ak1);
        
        ApplKyc__c ak2=new ApplKyc__c();
        ak2.Applicant__c=ap.id;
        ak2.kycDoc__c='Driving License';
        ak2.DLNo__c = 'DLNO001';
        ak2.AadharEncripted__c='492515815873';
        ak2.ValidationStatus__c = 'Success';
        ApplKycList.add(ak2);
        
        ApplKyc__c ak3=new ApplKyc__c();
        ak3.Applicant__c=ap.id;
        ak3.kycDoc__c='Pan';
        ak3.Pan__c = 'PAN001';
        ak3.AadharEncripted__c='492515815873';
        ak3.ValidationStatus__c = 'Success';
        ApplKycList.add(ak3);
        
        ApplKyc__c ak4=new ApplKyc__c();
        ak4.Applicant__c=ap.id;
        ak4.kycDoc__c='Passport';
        ak4.PassNo__c = 'PASSNO001';
        ak4.AadharEncripted__c='492515815873';
        ak4.ValidationStatus__c = 'Success';
        ApplKycList.add(ak4);
        
        insert ApplKycList;
        
        ApplAddr__c addr1=new ApplAddr__c();
        addr1.Applicant__c=ap.Id;
        addr1.AddrTyp__c='Residence Cum office';
        addr1.AddrLine1__c='test';
        addr1.AddrLine2__c='test';
        addr1.City__c='test';
        addr1.State__c='test';
        addr1.HouseNo__c='1234';
        addr1.Pincode__c='23456';
        insert addr1;
        
        IntgMsg__c intgMsg1 = new IntgMsg__c();
        intgMsg1.Name='UCIC API Token';
        intgMsg1.BU__c='HL / STL';
        intgMsg1.Status__c='New';
        intgMsg1.MStatus__c='Blank';
        intgMsg1.RefObj__c='LoanAppl__c';
        intgMsg1.ParentRefId__c=ap.id;
        intgMsg1.ParentRefObj__c='Applicant__c';
        intgMsg1.RefId__c = la.Id;
        intgMsg1.Resp__c='{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3MTA3NzA3NTIsInVzZXJfbmFtZSI6ImJpam95QGFjdGlmeWRhdGFsYWJzLmNvbSIsImp0aSI6IjI4NTFhN2ZkLTEyZjgtNGQwNC1iNTgxLWRjOTRhZDgxNWY0MSIsImNsaWVudF9pZCI6ImU5M2JiZDBhOTllMTBkZWUzNzJkOWUyYTkwZTQzOTIxIiwic2NvcGUiOlsicmVhZCIsIndyaXRlIiwidHJ1c3QiXX0.KPP60e32sNII9sm1345ilwA0gGYah2QbeoE4J1P9BEQ","token_type":"bearer","refresh_token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3MTA3ODE1OTUsInVzZXJfbmFtZSI6ImJpam95QGFjdGlmeWRhdGFsYWJzLmNvbSIsImp0aSI6IjAzMTMyYjhmLTM1MjMtNGU0Mi1iYmEzLTVmYjUxMjhlMGU1MiIsImNsaWVudF9pZCI6ImU5M2JiZDBhOTllMTBkZWUzNzJkOWUyYTkwZTQzOTIxIiwic2NvcGUiOlsicmVhZCIsIndyaXRlIiwidHJ1c3QiXSwiYXRpIjoiMjg1MWE3ZmQtMTJmOC00ZDA0LWI1ODEtZGM5NGFkODE1ZjQxIn0.wrVZy2cXwJ0VAbnMlUZMvy5DdsUq96NNLqdYVtVgwhU","expires_in":153,"scope":"read write trust","jti":"2851a7fd-12f8-4d04-b581-dc94ad815f41"}';
        insert intgMsg1;
        
        IntgMsg__c intgMsg2 = new IntgMsg__c();
        intgMsg2.Name='UCIC';
        intgMsg2.BU__c='HL / STL';
        intgMsg2.Status__c='New';
        intgMsg2.MStatus__c='Blank';
        intgMsg2.RefObj__c='Applicant__c';
        intgMsg2.ParentRefId__c=intgMsg1.id;
        intgMsg2.ParentRefObj__c='IntgMsg__c';
        intgMsg2.RefId__c = ap.Id;
        intgMsg2.Resp__c='';
        insert intgMsg2;
        
        List<IntgMsg__c> msgs = new List<IntgMsg__c>{intgMsg2};
            UcidRequestGenerator ucicReqGen = new UcidRequestGenerator();
        ucicReqGen.generate(msgs, 'service', 'processType');
    }
    
    @isTest
    public static void testGenerateMethod3() {
        
        LoanAppl__c la = TestDataFactory.createLoanApplication(true);
        Applicant__c ap = TestDataFactory.createSingleApplicant(true, la.Id);
        ap.Constitution__c='HUF';
        update ap;
        
        List<ApplKyc__c> ApplKycList=new List<ApplKyc__c>();
        
        ApplKyc__c ak=new ApplKyc__c();
        ak.Applicant__c=ap.id;
        ak.kycDoc__c='Aadhaar';
        ak.AadharEncripted__c='492515815873';
        ak.AadharNo__c='492515815873';
        ak.ValidationStatus__c = 'Success';
        ApplKycList.add(ak);
        
        ApplKyc__c ak1=new ApplKyc__c();
        ak1.Applicant__c=ap.id;
        ak1.kycDoc__c='Voter Id';
        ak1.VotIdEpicNo__c = 'EPIC001';
        ak1.AadharEncripted__c='492515815873';
        ak1.ValidationStatus__c = 'Success';
        ApplKycList.add(ak1);
        
        ApplKyc__c ak2=new ApplKyc__c();
        ak2.Applicant__c=ap.id;
        ak2.kycDoc__c='Driving License';
        ak2.DLNo__c = 'DLNO001';
        ak2.AadharEncripted__c='492515815873';
        ak2.ValidationStatus__c = 'Success';
        ApplKycList.add(ak2);
        
        ApplKyc__c ak3=new ApplKyc__c();
        ak3.Applicant__c=ap.id;
        ak3.kycDoc__c='Pan';
        ak3.Pan__c = 'PAN001';
        ak3.AadharEncripted__c='492515815873';
        ak3.ValidationStatus__c = 'Success';
        ApplKycList.add(ak3);
        
        ApplKyc__c ak4=new ApplKyc__c();
        ak4.Applicant__c=ap.id;
        ak4.kycDoc__c='Passport';
        ak4.PassNo__c = 'PASSNO001';
        ak4.AadharEncripted__c='492515815873';
        ak4.ValidationStatus__c = 'Success';
        ApplKycList.add(ak4);
        
        insert ApplKycList;
        
        ApplAddr__c addr1=new ApplAddr__c();
        addr1.Applicant__c=ap.Id;
        addr1.AddrTyp__c='Principal place for business';
        addr1.AddrLine1__c='test';
        addr1.AddrLine2__c='test';
        addr1.City__c='test';
        addr1.State__c='test';
        addr1.HouseNo__c='1234';
        addr1.Pincode__c='23456';
        insert addr1;
        
        IntgMsg__c intgMsg1 = new IntgMsg__c();
        intgMsg1.Name='UCIC API Token';
        intgMsg1.BU__c='HL / STL';
        intgMsg1.Status__c='New';
        intgMsg1.MStatus__c='Blank';
        intgMsg1.RefObj__c='LoanAppl__c';
        intgMsg1.ParentRefId__c=ap.id;
        intgMsg1.ParentRefObj__c='Applicant__c';
        intgMsg1.RefId__c = la.Id;
        intgMsg1.Resp__c='{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3MTA3NzA3NTIsInVzZXJfbmFtZSI6ImJpam95QGFjdGlmeWRhdGFsYWJzLmNvbSIsImp0aSI6IjI4NTFhN2ZkLTEyZjgtNGQwNC1iNTgxLWRjOTRhZDgxNWY0MSIsImNsaWVudF9pZCI6ImU5M2JiZDBhOTllMTBkZWUzNzJkOWUyYTkwZTQzOTIxIiwic2NvcGUiOlsicmVhZCIsIndyaXRlIiwidHJ1c3QiXX0.KPP60e32sNII9sm1345ilwA0gGYah2QbeoE4J1P9BEQ","token_type":"bearer","refresh_token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3MTA3ODE1OTUsInVzZXJfbmFtZSI6ImJpam95QGFjdGlmeWRhdGFsYWJzLmNvbSIsImp0aSI6IjAzMTMyYjhmLTM1MjMtNGU0Mi1iYmEzLTVmYjUxMjhlMGU1MiIsImNsaWVudF9pZCI6ImU5M2JiZDBhOTllMTBkZWUzNzJkOWUyYTkwZTQzOTIxIiwic2NvcGUiOlsicmVhZCIsIndyaXRlIiwidHJ1c3QiXSwiYXRpIjoiMjg1MWE3ZmQtMTJmOC00ZDA0LWI1ODEtZGM5NGFkODE1ZjQxIn0.wrVZy2cXwJ0VAbnMlUZMvy5DdsUq96NNLqdYVtVgwhU","expires_in":153,"scope":"read write trust","jti":"2851a7fd-12f8-4d04-b581-dc94ad815f41"}';
        insert intgMsg1;
        
        IntgMsg__c intgMsg2 = new IntgMsg__c();
        intgMsg2.Name='UCIC';
        intgMsg2.BU__c='HL / STL';
        intgMsg2.Status__c='New';
        intgMsg2.MStatus__c='Blank';
        intgMsg2.RefObj__c='Applicant__c';
        intgMsg2.ParentRefId__c=intgMsg1.id;
        intgMsg2.ParentRefObj__c='IntgMsg__c';
        intgMsg2.RefId__c = ap.Id;
        intgMsg2.Resp__c='';
        insert intgMsg2;
        
        List<IntgMsg__c> msgs = new List<IntgMsg__c>{intgMsg2};
            UcidRequestGenerator ucicReqGen = new UcidRequestGenerator();
        ucicReqGen.generate(msgs, 'service', 'processType');
    }
}