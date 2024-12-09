@isTest
public class HunterRequestGeneratorTest {
	@isTest
    static void testGenerate1() {
        List<IntgMsg__c> testReqList = new List<IntgMsg__c>();
        
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        Applicant__c appli =  TestDataFactory.createSingleApplicant(true,loanApp.id);
		appli.Constitution__c = 'INDIVIDUAL';
		update appli;
        ApplAddr__c appliAddr = TestDataFactory.applAddData(true, loanApp.id, appli.Id);
        appliAddr.AddrTyp__c = 'Residence Address';
        appliAddr.State__c = 'testState';
        update appliAddr;
        
        List<ApplKyc__c> kycList =new List<ApplKyc__c>();
        ApplKyc__c ak1 = new ApplKyc__c();
        ak1.Applicant__c=appli.Id;
        ak1.kycDoc__c='Voter Id';
        ak1.VotIdEpicNo__c='U2209545'; 
        kycList.add(ak1);
        
        ApplKyc__c ak2 = new ApplKyc__c();
        ak2.Applicant__c=appli.Id;
        ak2.kycDoc__c='Pan';
        ak2.Pan__c='U2209545'; 
        kycList.add(ak2);
        
        ApplKyc__c ak3 = new ApplKyc__c();
        ak3.Applicant__c=appli.Id;
        ak3.kycDoc__c='Aadhaar';
        ak3.AadharNo__c='123456789987';
        kycList.add(ak3);
        
        ApplKyc__c ak4 = new ApplKyc__c();
        ak4.Applicant__c=appli.Id;
        ak4.kycDoc__c='Letter issued by the National Population Register';
        ak4.NPRNumber__c='123456789987';
        kycList.add(ak4);
        
        Date myDate = date.newinstance(2027, 2, 17);
        ApplKyc__c ak5 = new ApplKyc__c();
        ak5.Applicant__c=appli.Id;
        ak5.kycDoc__c='Passport';
        ak5.PassExpDt__c = myDate;
        ak5.PassNo__c='123456789987';
        kycList.add(ak5);
        
        ApplKyc__c ak6 = new ApplKyc__c();
        ak6.Applicant__c=appli.Id;
        ak6.kycDoc__c='Driving License';
        ak6.DLExpDt__c = myDate;
        ak6.DLNo__c='123456789987';
        kycList.add(ak6);
        
        INSERT kycList;
		
		// Create a test response
        IntgMsg__c testReq = new IntgMsg__c();
        testReq.Name = 'Hunter API';
        testReq.RefId__c = appli.Id;
        testReq.RefObj__c = 'Applicant__c';
        testReq.Status__c = 'New';
        testReq.Svc__c = 'Hunter API';
        testReq.BU__c = 'HL / STL';
		testReqList.add(testReq);
		
		// Insert the test response list
        insert testReqList;
		
		// Call the generate method with the test response
        Test.startTest();
        HunterRequestGenerator generInst = new HunterRequestGenerator();
        generInst.generate(testReqList, '', '');
        Test.stopTest();
    }
	
	@isTest
    static void testGenerate2() {
        List<IntgMsg__c> testReqList = new List<IntgMsg__c>();
        
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        Applicant__c appli =  TestDataFactory.createSingleApplicant(true,loanApp.id);
		appli.Constitution__c = 'INDIVIDUAL';
		update appli;
        ApplAddr__c appliAddr = TestDataFactory.applAddData(true, loanApp.id, appli.Id);
		
		// Create a test response
        IntgMsg__c testReq = new IntgMsg__c();
        testReq.Name = 'Hunter API';
        testReq.RefId__c = loanApp.Id;
        testReq.RefObj__c = 'LoanAppl__c';
        testReq.Status__c = 'New';
        testReq.Svc__c = 'Hunter API';
        testReq.BU__c = 'HL / STL';
		testReqList.add(testReq);
		
		// Insert the test response list
        insert testReqList;
		
		// Call the generate method with the test response
        Test.startTest();
        HunterRequestGenerator generInst = new HunterRequestGenerator();
        generInst.generate(testReqList, '', '');
        Test.stopTest();
    }
}