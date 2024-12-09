@istest
public class VoterIdResponseProcessorTest {
    
      @isTest
     static void processTestSuccessStatsMethod(){

        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        Applicant__c appli =  TestDataFactory.createSingleApplicant(true,loanApp.id); 
        
        List<IntgMsg__c> intMsglist = new List<IntgMsg__c>();
        
        IntgMsg__c newlit = new IntgMsg__c();
        newlit.Name = 'DRIVER\'S LICENSE AUTHENTICATION';
        newlit.BU__c = 'Vehicle Loan';
        newlit.Svc__c = 'Voterid Verification';
        newlit.IsActive__c = true;
        newlit.RefId__c = appli.Id;
        newlit.Status__c = 'New';
        newlit.MStatus__c = 'Blank';
        newlit.RefObj__c = 'Applicant__c'; 
        newlit.Resp__c ='{"requestId":"123546578","result":{},"statusCode":101,"statusMessage":"Invalid Input"}';
        newlit.Trigger_Platform_Event__c=true;
         
        TriggerBase.bypass('IntgMsg__c');
        insert newlit;
        TriggerBase.clearBypass('IntgMsg__c');   
        intMsglist.add(newlit);
        
        Test.startTest();
        try{
            VoterIdResponseProcessor.process(intMsglist);
            VoterIdResponseProcessor.process(null);
        }catch(NullPointerException ex){
            system.assertEquals('Attempt to de-reference a null object', ex.getMessage());
            system.debug('Attempt to de-reference a null object '+ ex.getMessage());
        }
       Test.stopTest();
    }
    
    
      @isTest
     static void processTestFailedStatsMethod(){

        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        Applicant__c appli =  TestDataFactory.createSingleApplicant(true,loanApp.id); 
        
        List<IntgMsg__c> intMsglist = new List<IntgMsg__c>();
        
        IntgMsg__c newlit = new IntgMsg__c();
        newlit.Name = 'DRIVER\'S LICENSE AUTHENTICATION';
        newlit.BU__c = 'Vehicle Loan';
        newlit.Svc__c = 'Voterid Verification';
        newlit.IsActive__c = true;
        newlit.RefId__c = appli.Id;
        newlit.Status__c = 'New';
        newlit.MStatus__c = 'Blank';
        newlit.RefObj__c = 'Applicant__c'; 
        newlit.Resp__c ='{"requestId":"123546578","result":{},"statusCode":200,"statusMessage":"Invalid Input"}';
        newlit.Trigger_Platform_Event__c=true;
         
        TriggerBase.bypass('IntgMsg__c');
        insert newlit;
        TriggerBase.clearBypass('IntgMsg__c');   
        intMsglist.add(newlit);
        
        Test.startTest();
        try{
            VoterIdResponseProcessor.process(intMsglist);
            VoterIdResponseProcessor.process(null);
        }catch(NullPointerException ex){
            system.assertEquals('Attempt to de-reference a null object', ex.getMessage());
            system.debug('Attempt to de-reference a null object '+ ex.getMessage());
        }
       Test.stopTest();
    }
    
      @isTest
     static void processTestNullStatsMethod(){

        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        Applicant__c appli =  TestDataFactory.createSingleApplicant(true,loanApp.id); 
        
        List<IntgMsg__c> intMsglist = new List<IntgMsg__c>();
        
        IntgMsg__c newlit = new IntgMsg__c();
        newlit.Name = 'DRIVER\'S LICENSE AUTHENTICATION';
        newlit.BU__c = 'Vehicle Loan';
        newlit.Svc__c = 'Voterid Verification';
        newlit.IsActive__c = true;
        newlit.RefId__c = appli.Id;
        newlit.Status__c = 'New';
        newlit.MStatus__c = 'Blank';
        newlit.RefObj__c = 'Applicant__c'; 
        newlit.Resp__c ='{"requestId":"123546578","result":{},"statusCode":null,"statusMessage":"Invalid Input"}';
        newlit.Trigger_Platform_Event__c=true;
         
        TriggerBase.bypass('IntgMsg__c');
        insert newlit;
        TriggerBase.clearBypass('IntgMsg__c');   
        intMsglist.add(newlit);
        
        Test.startTest();
        try{
            VoterIdResponseProcessor.process(intMsglist);
           // VoterIdResponseProcessor.process(null);
        }catch(NullPointerException ex){
            system.assertEquals('Attempt to de-reference a null object', ex.getMessage());
            system.debug('Attempt to de-reference a null object '+ ex.getMessage());
        }
       Test.stopTest();
    }
    
    
     @isTest
    static void testUpdateApplicantKyc() {
       
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        Applicant__c appli =  TestDataFactory.createSingleApplicant(true,loanApp.id); 
        ApplKyc__c appkyc = [SELECT Id, Applicant__c FROM  ApplKyc__c Where Applicant__c =: appli.Id Limit 1];
        /*ApplKyc__c appkyc = new ApplKyc__c();
        appkyc.kycDoc__c = 'Voter Id';
        appkyc.VotIdEpicNo__c = 'EUHNK9875';
        appkyc.Applicant__c = appli.id;
        insert appkyc; */
        
        
        DocMstr__c docMast = TestDataFactory.createDocumentMaster(true,'Vehicle Loan');
        /*DocMstr__c docMast =  new DocMstr__c();
        docMast.BU__c = 'Vehicle Loan';
        docMast.DocType__c = 'KYC';
        docMast.Active__c =true;
        docMast.Required__c = true ;
        docMast.DocId__c = '23456';
        TriggerBase.bypass('DocMstr__c');
        insert docMast;
        TriggerBase.clearBypass('DocMstr__c'); */
        
        DocDtl__c docDetList = TestDataFactory.createDocumentDetail(true,'Driving license', appli.id,docMast.id);
        /*List<DocDtl__c> docDetList = new List<DocDtl__c>(); 
        DocDtl__c appDocDet = new DocDtl__c();
        appDocDet.DocTyp__c = 'Identity Proof';
        appDocDet.DocCatgry__c = 'KYC Documents';
        appDocDet.DocSubTyp__c = 'Driving license';
        appDocDet.LAN__c = loanApp.Id;
        appDocDet.Appl__c = appli.Id;
        appDocDet.DocMstr__c = docMast.id ;
        
        TriggerBase.bypass('DocDtl__c');
        insert appDocDet;
        TriggerBase.clearBypass('DocDtl__c'); */
        
        List<IntgMsg__c> intMsglist = new List<IntgMsg__c>();
        
        IntgMsg__c newlit = new IntgMsg__c();
        newlit.Name = 'DRIVER\'S LICENSE AUTHENTICATION';
        newlit.BU__c = 'Vehicle Loan';
        newlit.Svc__c = 'Voterid Verification';
        newlit.IsActive__c = true;
        newlit.Status__c = 'New';
        newlit.MStatus__c = 'Blank';
        newlit.RefObj__c = 'Applicant__c';
        newlit.RefId__c = '87687690';
        newlit.ParentRefId__c = appkyc.id;
        newlit.Trigger_Platform_Event__c=true;
        
        TriggerBase.bypass('IntgMsg__c');
        insert newlit;
        TriggerBase.clearBypass('IntgMsg__c');   
        intMsglist.add(newlit);
        
        voterIdResponseWrapper.Result wrapRes= new voterIdResponseWrapper.Result();
        wrapRes.name = 'voter id';
        wrapRes.epicNo = 'EUHNK9875';        
        wrapRes.dob = '15-01-1992';
        wrapRes.psName = 'MH';
        wrapRes.gender = 'M';
        wrapRes.rlnType = 'F';
        
        voterIdResponseWrapper mockResponse = new voterIdResponseWrapper();       
        mockResponse.result = wrapRes;
        
        // Call the method
        Test.startTest();
        VoterIdResponseProcessor.updateApplicantKyc(mockResponse, newlit);
        Test.stopTest();  
    }
    
       @isTest
    static void testUpdateApplicantKycForRlnType() {
       
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        Applicant__c appli =  TestDataFactory.createSingleApplicant(true,loanApp.id); 
        ApplKyc__c appkyc = [SELECT Id, Applicant__c FROM  ApplKyc__c Where Applicant__c =: appli.Id Limit 1];
        /*ApplKyc__c appkyc = new ApplKyc__c();
        appkyc.kycDoc__c = 'Voter Id';
        appkyc.VotIdEpicNo__c = 'EUHNK9875';
        appkyc.Applicant__c = appli.id;
        insert appkyc; */
        
        
        DocMstr__c docMast = TestDataFactory.createDocumentMaster(true,'Vehicle Loan');
        /*DocMstr__c docMast =  new DocMstr__c();
        docMast.BU__c = 'Vehicle Loan';
        docMast.DocType__c = 'KYC';
        docMast.Active__c =true;
        docMast.Required__c = true ;
        docMast.DocId__c = '23456';
        TriggerBase.bypass('DocMstr__c');
        insert docMast;
        TriggerBase.clearBypass('DocMstr__c'); */
        
        DocDtl__c docDetList = TestDataFactory.createDocumentDetail(true,'Driving license', appli.id,docMast.id);
        /*List<DocDtl__c> docDetList = new List<DocDtl__c>(); 
        DocDtl__c appDocDet = new DocDtl__c();
        appDocDet.DocTyp__c = 'Identity Proof';
        appDocDet.DocCatgry__c = 'KYC Documents';
        appDocDet.DocSubTyp__c = 'Driving license';
        appDocDet.LAN__c = loanApp.Id;
        appDocDet.Appl__c = appli.Id;
        appDocDet.DocMstr__c = docMast.id ;
        
        TriggerBase.bypass('DocDtl__c');
        insert appDocDet;
        TriggerBase.clearBypass('DocDtl__c'); */
        
        List<IntgMsg__c> intMsglist = new List<IntgMsg__c>();
        
        IntgMsg__c newlit = new IntgMsg__c();
        newlit.Name = 'DRIVER\'S LICENSE AUTHENTICATION';
        newlit.BU__c = 'Vehicle Loan';
        newlit.Svc__c = 'Voterid Verification';
        newlit.IsActive__c = true;
        newlit.Status__c = 'New';
        newlit.MStatus__c = 'Blank';
        newlit.RefObj__c = 'Applicant__c';
        newlit.RefId__c = '87687690';
        newlit.ParentRefId__c = appkyc.id;
        newlit.Trigger_Platform_Event__c=true;
        
        TriggerBase.bypass('IntgMsg__c');
        insert newlit;
        TriggerBase.clearBypass('IntgMsg__c');   
        intMsglist.add(newlit);
        
        voterIdResponseWrapper.Result wrapRes= new voterIdResponseWrapper.Result();
        wrapRes.name = 'voter id';
        wrapRes.epicNo = 'EUHNK9875';        
        wrapRes.dob = '15-01-1992';
        wrapRes.psName = 'MH';
        wrapRes.gender = 'F';
        wrapRes.rlnType = 'H';
        
        voterIdResponseWrapper mockResponse = new voterIdResponseWrapper();       
        mockResponse.result = wrapRes;
        
        // Call the method
        Test.startTest();
        VoterIdResponseProcessor.updateApplicantKyc(mockResponse, newlit);
        Test.stopTest();  
    }
    
     @isTest
    static void testUpdateApplicantKYCError() {
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        Applicant__c appli =  TestDataFactory.createSingleApplicant(true,loanApp.id); 
        ApplKyc__c appkyc = [SELECT Id, Applicant__c FROM  ApplKyc__c Where Applicant__c =: appli.Id Limit 1];
       // List<IntgMsg__c> intMess = TestDataFactory.createIntegrationMessage(true,appli.id); 
        
       /* ApplKyc__c appkyc = new ApplKyc__c();
        appkyc.kycDoc__c = 'Voter Id';
        appkyc.VotIdEpicNo__c = 'EUHNK9875';
        appkyc.Applicant__c = appli.id;
        insert appkyc; */

        List<IntgMsg__c> intMsglist = new List<IntgMsg__c>();
        
        IntgMsg__c newlit = new IntgMsg__c();
        newlit.Name = 'DRIVER\'S LICENSE AUTHENTICATION';
        newlit.BU__c = 'Vehicle Loan';
        newlit.Svc__c = 'Voterid Verification';
        newlit.IsActive__c = true;
        newlit.RefId__c = appli.Id;
        newlit.Status__c = 'New';
        newlit.MStatus__c = 'Blank';
        newlit.RefObj__c = 'Applicant__c'; 
        newlit.ParentRefId__c = appkyc.id;
        newlit.Trigger_Platform_Event__c=true;
       
        TriggerBase.bypass('IntgMsg__c');
        insert newlit;
        TriggerBase.clearBypass('IntgMsg__c');   
        intMsglist.add(newlit);
        
        voterIdResponseWrapper.Result wrapRes= new voterIdResponseWrapper.Result();
        wrapRes.name = 'voter id';
        wrapRes.epicNo = 'EUHNK9875';        
        wrapRes.dob = '15-01-1992';
        wrapRes.psName = 'MH';
        wrapRes.rlnType = 'F';
        wrapRes.gender = 'M';
        
        voterIdResponseWrapper mockResponse = new voterIdResponseWrapper();       
        mockResponse.result = wrapRes;
        
        String errorMessage = 'DOB missing: Kindly provide alternate KYC proof';

        Test.startTest();
        VoterIdResponseProcessor.updateApplicantKYCError(mockResponse, newlit, errorMessage);
        Test.stopTest();
        
       
    }
    


    @isTest
    static void testCheckValidDOB() {
   LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        Applicant__c appli =  TestDataFactory.createSingleApplicant(true,loanApp.id); 
       // List<IntgMsg__c> intMess = TestDataFactory.createIntegrationMessage(true,appli.id); 
        ApplKyc__c appkyc = [SELECT Id, Applicant__c FROM  ApplKyc__c Where Applicant__c =: appli.Id Limit 1];
        /*ApplKyc__c appkyc = new ApplKyc__c();
        appkyc.kycDoc__c = 'Voter Id';
        appkyc.VotIdEpicNo__c = 'EUHNK9875';
        appkyc.Applicant__c = appli.id;
        insert appkyc; */
        
        List<IntgMsg__c> intMsglist = new List<IntgMsg__c>();
        
        IntgMsg__c newlit = new IntgMsg__c();
        newlit.Name = 'DRIVER\'S LICENSE AUTHENTICATION';
        newlit.BU__c = 'Vehicle Loan';
        newlit.Svc__c = 'Voterid Verification';
        newlit.IsActive__c = true;
        newlit.RefId__c = appli.Id;
        newlit.Status__c = 'New';
        newlit.MStatus__c = 'Blank';
        newlit.RefObj__c = 'Applicant__c'; 
        newlit.ParentRefId__c = appkyc.id;
        newlit.Trigger_Platform_Event__c=true;
        newlit.Resp__c ='{"result":{"dob":"15-05-1993","req_id":"123456","msisdn":"21345","status":{"statusCode":"101"}}}';
        
        TriggerBase.bypass('IntgMsg__c');
        insert newlit;
        TriggerBase.clearBypass('IntgMsg__c');   

        Test.startTest();
        VoterIdResponseProcessor.checkValidDOB(newlit);
        Test.stopTest();
        
    }
    
    
     @isTest
    static void testInvalidDOB() {
   LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);
        Applicant__c appli =  TestDataFactory.createSingleApplicant(true,loanApp.id); 
       // List<IntgMsg__c> intMess = TestDataFactory.createIntegrationMessage(true,appli.id); 
        ApplKyc__c appkyc = [SELECT Id, Applicant__c FROM  ApplKyc__c Where Applicant__c =: appli.Id Limit 1];
        /*ApplKyc__c appkyc = new ApplKyc__c();
        appkyc.kycDoc__c = 'Voter Id';
        appkyc.VotIdEpicNo__c = 'EUHNK9875';
        appkyc.Applicant__c = appli.id;
        insert appkyc; */
        
        List<IntgMsg__c> intMsglist = new List<IntgMsg__c>();
        
        IntgMsg__c newlit = new IntgMsg__c();
        newlit.Name = 'DRIVER\'S LICENSE AUTHENTICATION';
        newlit.BU__c = 'Vehicle Loan';
        newlit.Svc__c = 'Voterid Verification';
        newlit.IsActive__c = true;
        newlit.RefId__c = appli.Id;
        newlit.Status__c = 'New';
        newlit.MStatus__c = 'Blank';
        newlit.RefObj__c = 'Applicant__c'; 
        newlit.ParentRefId__c = appkyc.id;
        newlit.Trigger_Platform_Event__c=true;
        newlit.Resp__c ='{"result":{"dob":"","req_id":"123456","msisdn":"21345","status":{"statusCode":"101"}}}';
        
        TriggerBase.bypass('IntgMsg__c');
        insert newlit;
        TriggerBase.clearBypass('IntgMsg__c');   

        Test.startTest();
        VoterIdResponseProcessor.checkValidDOB(newlit);
        Test.stopTest();
        
    }
}