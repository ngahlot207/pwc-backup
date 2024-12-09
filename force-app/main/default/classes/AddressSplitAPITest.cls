@isTest
public class AddressSplitAPITest {

    @isTest
    public static void successMethod(){
        
         LoanAppl__c la = TestDataFactory.createLoanApplication(true);
        
        Applicant__c app = new  Applicant__c();
        app.LoanAppln__c=la.Id;
        insert app;
        
        ApplKyc__c kyc =new ApplKyc__c();
        kyc.Applicant__c=app.Id;
        kyc.kycDoc__c='Udyam';
        kyc.Address__c='test';
        insert kyc;
        
        DocDtl__c dd=new DocDtl__c();
        dd.Appl__c=app.Id;
        insert dd;
        
        List<IntgMsg__c> intmsglist =new List<IntgMsg__c>();
        
        IntgMsg__c intgMsg =new IntgMsg__c();
        intgMsg.Name='Address Split';
        intgMsg.BU__c='HL / STL';
        intgMsg.Status__c='New';
        intgMsg.MStatus__c='Blank';
        intgMsg.RefObj__c='ApplKyc__c';
        intgMsg.RefId__c = dd.Id;
        intgMsg.ParentRefObj__c='Applicant__c';
        intgMsg.ParentRefId__c=kyc.Id;
        intgMsg.Trigger_Platform_Event__c=true;
        intgMsg.Resp__c='{"result":{"C/O":"ALOK KUMAR PANKAJ","House":"test","Floor":"test","Building":"test","Complex":"test","Street":"test","Untagged":"CHOTI","locality":"DOULATPUR","State":"BIHAR","District":"MUNGER","City":"JAMALPUR","Landmark":"test","Pin":811214},"request_id":"3e30c64b-11b8-461c-ae06-fe9ad9de25ab","status-code":"101","clientData":{"caseId":"IM0000015800"}}';
        intmsglist.add(intgMsg);
        
        
        IntgMsg__c intgMsg1 =new IntgMsg__c();
        intgMsg1.Name='Address Split';
        intgMsg1.BU__c='HL / STL';
        intgMsg1.Status__c='New';
        intgMsg1.MStatus__c='Blank';
        intgMsg1.RefObj__c='ApplKyc__c';
        intgMsg1.RefId__c = dd.Id;
        intgMsg1.ParentRefObj__c='Applicant__c';
        intgMsg1.ParentRefId__c=kyc.Id;
        intgMsg1.Trigger_Platform_Event__c=true;
        intgMsg1.Resp__c='dfsff';
        intmsglist.add(intgMsg1);
        
        //Request     
        AddressSplitAPIRequestGenerator request =new AddressSplitAPIRequestGenerator();
        
        Test.startTest();
        request.generate(intmsglist,'Address Split','Async');
        
        //Response
        AddressSplitAPIResponseProcessor.process(intmsglist);
        Test.stopTest();
    }
    
     @isTest
    public static void failureMethod(){
        
         LoanAppl__c la = TestDataFactory.createLoanApplication(true);
        
        Applicant__c app = new  Applicant__c();
        app.LoanAppln__c=la.Id;
        insert app;
        
        ApplKyc__c kyc =new ApplKyc__c();
        kyc.Applicant__c=app.Id;
        kyc.kycDoc__c='Udyam';
        kyc.Address__c='test';
        insert kyc;
        
        DocDtl__c dd=new DocDtl__c();
        dd.Appl__c=app.Id;
        insert dd;
        
        List<IntgMsg__c> intmsglist =new List<IntgMsg__c>();
        
        IntgMsg__c intgMsg =new IntgMsg__c();
        intgMsg.Name='Address Split';
        intgMsg.BU__c='HL / STL';
        intgMsg.Status__c='New';
        intgMsg.MStatus__c='Blank';
        intgMsg.RefObj__c='ApplKyc__c';
        intgMsg.RefId__c = dd.Id;
        intgMsg.ParentRefObj__c='Applicant__c';
        intgMsg.ParentRefId__c=kyc.Id;
        intgMsg.Trigger_Platform_Event__c=true;
        intgMsg.Resp__c='{"result":{"Building":"SUNILAPARTMENT","City":"","Pin":400254,"District":"","Floor":"1","House":"BLOCKNO.X,SECTOR5,FLATC-19/04","locality":"KAMALNAGAR","State":"","Complex":"","Landmark":"NEARPUJARIHOSPITAL","Untagged":"MARATHE|,ARDEE|PUNE","C/O":"","Street":"MILLROAD"},"request_id":"2096b15b-be2d-4b02-a283-6609dfff56ac","status-code":"11","clientData":{"caseId":"123456"}}';
        intmsglist.add(intgMsg);
        
        Test.startTest();
        //Response
        AddressSplitAPIResponseProcessor.process(intmsglist);
        Test.stopTest();
    }
}