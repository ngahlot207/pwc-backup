@isTest
public class UdyamVerificationAPITest {
    
    @istest
    public static void successMethod(){
        
        LoanAppl__c la = TestDataFactory.createLoanApplication(true);
        
        Applicant__c app = new  Applicant__c();
        app.LoanAppln__c=la.Id;
        insert app;
        
        ApplKyc__c kyc =new ApplKyc__c();
        kyc.Applicant__c=app.Id;
        kyc.kycDoc__c='Udyam Registration Certificate';
        insert kyc;
        
        
        ApplicantEmployment__c emp=TestDataFactory.createApplEmployment(true,app.id);
        emp.UdyamRegistrationNumber__c='UDYAM-MP-23-0007772';
        update emp;
        
        Id recordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByDeveloperName().get('Udyam').getRecordTypeId();
        
        APIVer__c ver =new APIVer__c();
        ver.Appl__c=app.id;
        ver.IsLatest__c=true;
        ver.RecordTypeId=recordTypeId;
        insert ver;
        
        DocDtl__c dd =new DocDtl__c();
        dd.Applicant_KYC__c=kyc.Id;
        dd.Appl__c=app.Id;
        insert dd;
        
        List<IntgMsg__c> intmsglist =new List<IntgMsg__c>();
        
        IntgMsg__c intgMsg =new IntgMsg__c();
        intgMsg.Name='Udyam Registration Check';
        intgMsg.BU__c='HL / STL';
        intgMsg.Status__c='New';
        intgMsg.MStatus__c='Blank';
        intgMsg.RefObj__c='ApplKyc__c';
        intgMsg.RefId__c = kyc.Id;
        intgMsg.ParentRefObj__c='Applicant__c';
        intgMsg.ParentRefId__c=app.Id;
        intgMsg.Trigger_Platform_Event__c=true;
        intgMsg.Req__c='{"udyamRegistrationNo":"UDYAM-MP-23-0007772","isPDFRequired":"Y","getEnterpriseDetails":"Y","consent":"Y","clientData":{"caseId":"IM0000016022"}}';
        intgMsg.Resp__c='{"requestId":"ee7be0cc-b6fc-4e84-b561-53008cd423ae","result":{"udyamRegistrationNo":"UDYAM-MP-23-0007772","dateOfRegistration":"2020-12-09","interestedInTreds":null,"interestedInGem":null,"profile":{"name":"FIGZY FOODS","majorActivity":"Manufacturing","organizationType":"Proprietary","ownerName":null,"pan":null,"previousITRStatus":null,"itrType":null,"gstnStatus":null,"mobile":null,"emailId":null,"socialCategory":"General","gender":null,"speciallyAbled":null,"dateOfIncorporation":"2020-09-17","dateOfCommencement":"2020-09-17"},"bankDetails":{"bank":null,"ifsc":null,"acNo":null},"employmentDetails":{"male":null,"female":null,"others":null,"total":null},"financials":{"financialYear":null,"details":{"wdvPme":null,"exclusion":null,"netInvestmentInPme":null,"totalTurnover":null,"exportTurnover":null,"netTurnover":null}},"branchDetails":[{"name":"FIGZY FOODS","flat":"65","premises":"UTKARSH VIHAR COLONY","village":"INDORE","block":"0","road":"KHAJRANA MAIN ROAD","city":"INDORE","state":"MADHYA PRADESH","pincode":"452018","district":"INDORE"}],"officialAddress":{"flat":"65","premises":"UTKARSH VIHAR COLONY","village":"INDORE","block":"0","road":"KHAJRANA MAIN ROAD","city":"INDORE","state":"MADHYA PRADESH","pincode":"452018","district":"indore","email":"SHAH.ANKIT0305@GMAIL.COM","mobile":"8104006469"},"industry":[{"industry":"Manufacture of food products","subSector":"Manufacture of other food products n.e.c.","activityDescription":"Processing of edible nuts","industryCode":"10","subSectorCode":"1079","nicCode":"10793","activity":"Manufacturing"}],"enterpriseType":[{"classificationYear":"2022-23","enterpriseType":"Micro","classificationDate":"2022-06-26"}],"pdfData":"base 64 format"},"statusCode":101,"clientData":{"caseId":"123456"}}';
        intmsglist.add(intgMsg);
        
        IntgMsg__c intgMsg1 =new IntgMsg__c();
        intgMsg1.Name='Udyam Registration Check';
        intgMsg1.BU__c='HL / STL';
        intgMsg1.Status__c='New';
        intgMsg1.MStatus__c='Blank';
        intgMsg1.RefObj__c='ApplKyc__c';
        intgMsg1.RefId__c = kyc.Id;
        intgMsg1.ParentRefObj__c='Applicant__c';
        intgMsg1.ParentRefId__c=app.Id;
        intgMsg1.Trigger_Platform_Event__c=true;
        intgMsg1.Resp__c='dfsff';
        intmsglist.add(intgMsg1);
        
        
        
        //Request     
        UdyamVerificationAPIRequestGenerator request =new UdyamVerificationAPIRequestGenerator();
        
        Test.startTest();
        request.generate(intmsglist,'Udyam Registration Check','Async');
        
        //Response
        UdyamVerificationAPIResponseProcessor.process(intmsglist);
        Test.stopTest();
    }
    
    @istest
    public static void FailureMethod(){
        
        LoanAppl__c la = TestDataFactory.createLoanApplication(true);
        
        Applicant__c app = new  Applicant__c();
        app.LoanAppln__c=la.Id;
        insert app;
        
        ApplKyc__c kyc =new ApplKyc__c();
        kyc.Applicant__c=app.Id;
        kyc.kycDoc__c='Udyam';
        insert kyc;
        
        
        ApplicantEmployment__c emp=TestDataFactory.createApplEmployment(true,app.id);
        emp.UdyamRegistrationNumber__c='UDYAM-MP-23-0007772';
        update emp;
        
        Id recordTypeId = Schema.SObjectType.APIVer__c.getRecordTypeInfosByDeveloperName().get('Udyam').getRecordTypeId();
        
        
        APIVer__c ver =new APIVer__c();
        ver.Appl__c=app.id;
        ver.IsLatest__c=true;
        ver.RecordTypeId=recordTypeId;
        insert ver;
        
        
        
        IntgMsg__c intgMsg =new IntgMsg__c();
        intgMsg.Name='Udyam Registration Check';
        intgMsg.BU__c='HL / STL';
        intgMsg.Status__c='New';
        intgMsg.MStatus__c='Blank';
        intgMsg.RefObj__c='ApplKyc__c';
        intgMsg.RefId__c = kyc.Id;
        intgMsg.ParentRefObj__c='Applicant__c';
        intgMsg.ParentRefId__c=app.Id;
        intgMsg.Trigger_Platform_Event__c=true;
        intgMsg.Resp__c='{"requestId":"ee7be0cc-b6fc-4e84-b561-53008cd423ae","result":{"udyamRegistrationNo":"UDYAM-MP-23-0007772","dateOfRegistration":"2020-12-09","interestedInTreds":null,"interestedInGem":null,"profile":{"name":"FIGZY FOODS","majorActivity":"Manufacturing","organizationType":"Proprietary","ownerName":null,"pan":null,"previousITRStatus":null,"itrType":null,"gstnStatus":null,"mobile":null,"emailId":null,"socialCategory":"General","gender":null,"speciallyAbled":null,"dateOfIncorporation":"2020-09-17","dateOfCommencement":"2020-09-17"},"bankDetails":{"bank":null,"ifsc":null,"acNo":null},"employmentDetails":{"male":null,"female":null,"others":null,"total":null},"financials":{"financialYear":null,"details":{"wdvPme":null,"exclusion":null,"netInvestmentInPme":null,"totalTurnover":null,"exportTurnover":null,"netTurnover":null}},"branchDetails":[{"name":"FIGZY FOODS","flat":"65","premises":"UTKARSH VIHAR COLONY","village":"INDORE","block":"0","road":"KHAJRANA MAIN ROAD","city":"INDORE","state":"MADHYA PRADESH","pincode":"452018","district":"INDORE"}],"officialAddress":{"flat":"65","premises":"UTKARSH VIHAR COLONY","village":"INDORE","block":"0","road":"KHAJRANA MAIN ROAD","city":"INDORE","state":"MADHYA PRADESH","pincode":"452018","district":"indore","email":"SHAH.ANKIT0305@GMAIL.COM","mobile":"8104006469"},"industry":[{"industry":"Manufacture of food products","subSector":"Manufacture of other food products n.e.c.","activityDescription":"Processing of edible nuts","industryCode":"10","subSectorCode":"1079","nicCode":"10793","activity":"Manufacturing"}],"enterpriseType":[{"classificationYear":"2022-23","enterpriseType":"Micro","classificationDate":"2022-06-26"}],"pdfData":"base 64 format"},"statusCode":11,"clientData":{"caseId":"123456"}}';
        insert intgMsg;
        
        List<IntgMsg__c> intmsglist =new List<IntgMsg__c>{intgMsg};
            
        //Response
        Test.startTest();
        UdyamVerificationAPIResponseProcessor.process(intmsglist);
        Test.stopTest();
    }
}