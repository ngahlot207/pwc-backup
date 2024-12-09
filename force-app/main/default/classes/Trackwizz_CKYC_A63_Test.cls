@istest
public class Trackwizz_CKYC_A63_Test {
    
    @istest
    public static void testGenerateMethod(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='LOS Base User'];
        
        User us=new user();
        us.Alias='LOS';
        us.Email='test@gmail.com';
        us.EmailEncodingKey='UTF-8';
        us.LastName='Testing';
        us.LanguageLocaleKey='en_US';
        us.LocaleSidKey='en_US';
        us.ProfileId = p.Id; 
        us.TimeZoneSidKey='America/Los_Angeles';
        us.UserName='standarduser@fidfinna.com';
        insert us;
        
        LoanAppl__c la =TestDataFactory.createLoanApplication(true);
        la.LeadSource__c='Digital';
        la.Stage__c = 'QDE';
        la.Product__c = 'Home Loan';
        la.Loan_Tenure_Months__c = 120;
        la.BrchCode__c='MUM';
        la.SanLoanAmt__c=2470000;
        la.InsAmt__c=5000;
        la.ReqLoanAmt__c=2600000;
        la.RMSMName__c=us.id;
        la.LoginAcceptDate__c=Date.newInstance(2023, 12, 9);
        update la;
            
        Applicant__c app= TestDataFactory.createSingleApplicant(true,la.id);
        app.LoanAppln__c=la.id;
        app.Title__c='Mr.';
        app.FName__c='test';
        app.MName__c='test';
        app.LName__c='test';
        app.Gender__c='M';
        app.DOB__c=Date.newInstance(1996,12, 9);
        app.Father_Name__c='test';
        app.MthrMdnName__c='SURESH GUPTA';
        app.SpName__c='NARENDRA GUNTUPALLI';
        app.UCID__c='13006102';
        app.EduQual__c='GRAD';
        app.MariStatus__c='M';
        app.Constitution__c='INDIVIDUAL';
        app.DOI__c=Date.newInstance(2023,08, 9);
        app.EmailId__c='test@gmail.com';
        app.MobNumber__c='1234567890';
        app.PhoneNumber__c='1234567890';
        update app;
        
        List<DocDtl__c> ddList = new List<DocDtl__c>();
        DocDtl__c dd1 = new DocDtl__c();
        dd1.DocCatgry__c = 'PAN Documents';
        dd1.DocTyp__c = 'PAN';
        dd1.Appl__c = app.Id;
        ddList.add(dd1);
        
        DocDtl__c dd2 = new DocDtl__c();
        dd2.DocCatgry__c = 'KYC Documents';
        dd2.DocTyp__c = 'Constitution wise Mandatory KYC documents';
        dd2.Appl__c = app.Id;
        ddList.add(dd2);
        
        DocDtl__c dd3 = new DocDtl__c();
        dd3.DocCatgry__c = 'KYC Documents';
        dd3.DocTyp__c = 'Registered office - Address Proof';
        dd3.Appl__c = app.Id;
        ddList.add(dd3);
        
        INSERT ddList;
        
        APIVer__c av =new APIVer__c();
        av.Appl__c=app.id;
        av.Risk_Rating_Final__c='Low';
        av.IsLatest__c=true;
        insert av;
        
        List<ApplKyc__c> kycList =new List<ApplKyc__c>();
        ApplKyc__c ak1 = new ApplKyc__c();
        ak1.Applicant__c=app.Id;
        ak1.kycDoc__c='Voter Id';
        ak1.VotIdEpicNo__c='U2209545'; 
        kycList.add(ak1);
        
        ApplKyc__c ak2 = new ApplKyc__c();
        ak2.Applicant__c=app.Id;
        ak2.kycDoc__c='Pan';
        ak2.Pan__c='U2209545'; 
        kycList.add(ak2);
        
        ApplKyc__c ak3 = new ApplKyc__c();
        ak3.Applicant__c=app.Id;
        ak3.kycDoc__c='Aadhaar';
        ak3.AadharNo__c='123456789987';
        kycList.add(ak3);
        
        ApplKyc__c ak4 = new ApplKyc__c();
        ak4.Applicant__c=app.Id;
        ak4.kycDoc__c='Letter issued by the National Population Register';
        ak4.NPRNumber__c='123456789987';
        kycList.add(ak4);
        
        Date myDate = date.newinstance(2027, 2, 17);
        ApplKyc__c ak5 = new ApplKyc__c();
        ak5.Applicant__c=app.Id;
        ak5.kycDoc__c='Passport';
        ak5.PassExpDt__c = myDate;
        ak5.PassNo__c='123456789987';
        kycList.add(ak5);
        
        ApplKyc__c ak6 = new ApplKyc__c();
        ak6.Applicant__c=app.Id;
        ak6.kycDoc__c='Driving License';
        ak6.DLExpDt__c = myDate;
        ak6.DLNo__c='123456789987';
        kycList.add(ak6);
        
        INSERT kycList;
        
        ApplAddr__c addrs=new ApplAddr__c();
        addrs.Applicant__c=app.Id;
        addrs.AddrLine1__c='There are many variations of passages of Lorem Ipsum available, but the majority have suffered alteration in some form, by injected humour, or randomised words which dont look even slightly believable.';
        addrs.AddrLine2__c='There are many variations of passages of Lorem Ipsum available, but the majority have suffered alteration in some form, by injected humour, or randomised words which dont look even slightly believable.';
        addrs.AddrTyp__c='Permanent Address';
        addrs.Landmark__c = 'test';
        addrs.HouseNo__c='123';
        addrs.Pincode__c='12345';
        addrs.City__c='test';
        addrs.State__c='test';
        insert addrs;
        
        ApplicantEmployment__c ae=new ApplicantEmployment__c();
        ae.Name='Self';
        ae.LoanApplicant__c=app.Id;
        ae.OfficialEmail__c='test@gmail.com';
        ae.NatureOfBusinessIndividual__c='S';
        insert ae;
        
        IntgMsg__c intgMsg =new IntgMsg__c();
        intgMsg.Name='CKYC API';
        intgMsg.BU__c='HL / STL';
        intgMsg.Svc__c='CKYC API';
        intgMsg.Status__c='New';
        intgMsg.MStatus__c='Blank';
        intgMsg.RefObj__c='Applicant__c';
        intgMsg.RefId__c = app.Id;
        intgMsg.Resp__c='<Response><RequestStatus>RejectedByTW</RequestStatus><RequestRejectionDescription>Error: Invalid data</RequestRejectionDescription><Detail><CustomerIntegrationStatusCode>RejectedByTW</CustomerIntegrationStatusCode><TrackWizzInitialRejectionDescription>Error: Incomplete Information</TrackWizzInitialRejectionDescription></Detail></Response>';
       // intgMsg.Resp__c='<?xml version="1.0" encoding="utf-8"?><A63CustomerResponse xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ApiToken>ffed6396-2dd1-4457-93fc-ea226ac54dbd</ApiToken><RequestId>e7c56f76-8d50-4fe0-905c-d7c31e0319e1</RequestId><RequestStatus>AcceptedbyTW</RequestStatus><ParentCompany>Fedbank</ParentCompany><CustomerResponseDetails><A63CustomerResponseDetail><TransactionId>A-000007</TransactionId><SourceSystemName>Salesforce</SourceSystemName><SourceSystemCustomerCode>1234</SourceSystemCustomerCode><CustomerIntegrationStatusCode>AcceptedbyTW</CustomerIntegrationStatusCode><TrackWizzUpdatedOn>09-01-2024</TrackWizzUpdatedOn></A63CustomerResponseDetail></CustomerResponseDetails></A63CustomerResponse>';
        insert intgMsg;
        
       
        
        
         IntgMsg__c intgMsg1 =new IntgMsg__c();
        intgMsg1.Name='CKYC API';
        intgMsg1.BU__c='HL / STL';
        intgMsg1.Svc__c='CKYC API';
        intgMsg1.Status__c='New';
        intgMsg1.MStatus__c='Blank';
        intgMsg1.RefObj__c='Applicant__c';
        intgMsg1.RefId__c = app.Id;
        intgMsg1.Resp__c='<?xml version="1.0" encoding="utf-8"?><A63CustomerResponse xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ApiToken>ffed6396-2dd1-4457-93fc-ea226ac54dbd</ApiToken><RequestId>e7c56f76-8d50-4fe0-905c-d7c31e0319e1</RequestId><RequestStatus>AcceptedbyTW</RequestStatus><ParentCompany>Fedbank</ParentCompany><CustomerResponseDetails><A63CustomerResponseDetail><TransactionId>A-000007</TransactionId><SourceSystemName>Salesforce</SourceSystemName><SourceSystemCustomerCode>1234</SourceSystemCustomerCode><CustomerIntegrationStatusCode>AcceptedbyTW</CustomerIntegrationStatusCode><TrackWizzUpdatedOn>09-01-2024</TrackWizzUpdatedOn></A63CustomerResponseDetail></CustomerResponseDetails></A63CustomerResponse>';
        insert intgMsg1;
        
        string reqjson='{"CustomerRelatedPartyCreateUpdateRequest":{"RecordRequestDetails":{"RecordRequestDetail":{"TransactionId":"A-000007","TaxIdentificationDetails":{},"Tags":{"TagDetail":{"Tag":"RiskRating"}},"SpousePrefix":"","SpouseMiddleName":"","SpouseLastName":"","SpouseFirstName":"","SourceSystemName":"Salesforce","SourceSystemCustomerCreationDate":"08-Jan-2024","SourceSystemCustomerCode":"1234","Segments":{},"RMDetails":{},"ReputationClassification":{},"RelationDetails":{"RelationDetail":{"SourceSystemName":"Salesforce","SourceSystemCustomerCode":"1234","ShareHoldingPercentage":0,"RelationStartDate":"","Relation":"","RecordIdentifier":"1234"}},"RelatedPersonCountForCKYC":0,"RegulatoryAMLRisk":"","RegAMLSpecialCategoryDetails":{},"RecordIdentifier":"1234","PropertyOwnerFlag":0,"ProofOfIDSubmitted":"","ProductSegments":{},"Prefix":"Mr","PermanentAddressProofOthersValue":"","PermanentAddressProof":"","PEPClassification":{},"PEP":"","OccupationType":"","NextRiskReviewDate":"31-Mar-2024","NetWorthDetails":{},"NatureOfBusinessOther":"","NatureOfBusiness":{"NatureOfBusinessDetail":{"Business":""}},"Nationality":{},"MotherPrefix":"Mrs","MotherMiddleName":"","MotherLastName":"","MotherFirstName":"","ModuleApplicable":{"ModuleDetail":{"Module":"CKYC"}},"Minor":0,"MiddleName":"","MaritalStatus":"","MaidenPrefix":"","MaidenMiddleName":"","MaidenLastName":"","MaidenFirstName":"","Listed":0,"Links":"","LastRiskReviewDate":"08-Jan-2024","LastName":"Rawat","KYCVerificationDate":"","KYCVerificationBranch":"","KYCPlaceOfDeclaration":"","KYCEmployeeName":"Sanket Satkar","KYCEmployeeDesignation":"","KYCEmployeeCode":"RM","KYCDateOfDeclaration":"","KYCAttestationType":1,"IUPartyType":"","IsSmallCustomer":"0","IntermediaryCode":"","InsiderInformation":"","Industry":"","IncomeDetails":{},"IdentificationDetails":{"IdentificationDetail":[{"IssueCountry":"","IdType":"Pancard","IdNumber":"ABCPR5504D","ExpiryDate":""}]},"HolderforImages":"","Gender":"F","FormSixty":0,"FirstName":"Ripul","FatherPrefix":"Mr","FatherMiddleName":"","FatherLastName":"","FatherFirstName":"","FamilyCode":"","EmailDetails":{"EmailDetail":[{"EmailType":"Personal","EmailId":"","Disabled":0}]},"EkycOTPBased":"0","EducationalQualificationDetails":{"EducationalQualificationDetail":[{"EducationalQualification":""}]},"DateofBirth":"24-Sep-1997","CustomerType":"1","CustomerSubType":"","CustomerStatus":{"StatusDetail":{"Status":"Ative","EffectiveDate":""}},"CountryOfResidence":"IN","CountryofOperation":{},"CountryOfBirth":"","CorrespondenceAddressProof":"","ContactPersonDetails":{},"ContactDetails":{"ContactDetail":{"ISDCode":"91","ContactType":"Personal","ContactNumber":"+919811373636"}},"CommencementDate":"","Citizenship":{"CountryDetail":{"Country":"IN"}},"Channel":"","BirthCity":"","ApplicationRefNumber":"","AdverseMediaDetails":"","AdverseMediaClassification":{},"AdverseMedia":0,"AddressDetails":{"AddressDetail":[]},"ActivitySectorDetails":{},"ActivityEmployerDetails":{}}},"ParentCompany":"Fedbank","ApiToken":"ffed6396-2dd1-4457-93fc-ea226ac54dbd"}}';
        
         List<IntgMsg__c> msg =new List<IntgMsg__c>{intgMsg};
         List<IntgMsg__c> msg1 =new List<IntgMsg__c>{intgMsg1};
         Trackwizz_CKYC_A63_RequestGenerator req=new Trackwizz_CKYC_A63_RequestGenerator();
         
         Test.startTest();
            req.generate(msg,'CKYC API','Async');
        	Trackwizz_CKYC_A63_RequestGenerator.fetchApplCKYCDataReport(new List<String>{app.LoanAppln__c});
            Trackwizz_CKYC_A63_ResponseProcessor.process(msg);
            Trackwizz_CKYC_A63_ResponseProcessor.process(msg1);
        Trackwizz_CKYC_A63_RequestWrapper request = Trackwizz_CKYC_A63_RequestWrapper.praser(reqjson);
        Test.stopTest();
    }

}