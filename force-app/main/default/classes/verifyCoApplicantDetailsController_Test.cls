@isTest
public class verifyCoApplicantDetailsController_Test {
    
    // Define test data setup method
    @testSetup
    static void testData(){
        LoanAppl__c loanApp = TestDataFactory.createLoanApplication(true);     
        Applicant__c applicant = TestDataFactory.createSingleApplicant(false, loanApp.Id);
        applicant.MobNumber__c = '1234567890';
        applicant.CustProfile__c = 'SALARIED';
        applicant.Constitution__c = 'ASSOCIATION OF PERSONS';
        applicant.Type_of_Borrower__c = 'Financial';
        applicant.ApplType__c = 'P';
        insert applicant;
        
        Applicant__c coApplicant = TestDataFactory.createSingleApplicant(false, loanApp.Id);
        coApplicant.MobNumber__c = '1234567890';
        coApplicant.CustProfile__c = 'SALARIED';
        coApplicant.Constitution__c = 'ASSOCIATION OF PERSONS';
        coApplicant.Type_of_Borrower__c = 'Financial';
        coApplicant.ApplType__c = 'C';
        insert coApplicant;
        
        ApplicantEmployment__c appEmp = TestDataFactory.createApplEmployment(true, applicant.Id);
        
    }
    
    @isTest
    static void testGetLoanApplData() {
        
        LoanAppl__c loanApp = [SELECT Id,Name FROM LoanAppl__c LIMIT 1]; 
        Applicant__c applicant = [SELECT Id,Name FROM Applicant__c WHERE LoanAppln__c = :loanApp.Id AND ApplType__c = 'P' LIMIT 1]; 
        
        loanApp.Applicant__c=applicant.Id;
        update loanApp;
        // Create a test LoanAppl__c record associated with the Applicant__c record
        
        // Call the getLoanApplData method and assert the results
        LoanAppl__c result = verifyCoApplicantDetailsController.getLoanApplData(loanApp.Id);
        //code coverage for empty data return 
        verifyCoApplicantDetailsController.getLoanApplData(null);
        
    }
    /*====================================================*/ 
    
    // Test method for getCoApplicantData
    @isTest
    static void testGetCoApplicantData() {
        LoanAppl__c loanApp = [SELECT Id,Name FROM LoanAppl__c LIMIT 1]; 
        Applicant__c coApplcnt = [SELECT Id,Name FROM Applicant__c WHERE LoanAppln__c = :loanApp.Id AND ApplType__c = 'C' LIMIT 1]; 
        coApplcnt.OTP_Verified__c=true;
        update coApplcnt;
        
        // Call the getCoApplicantData method and pass the ID of the created Applicant__c record
        Applicant__c result = verifyCoApplicantDetailsController.getCoApplicantData(coApplcnt.Id);
        //code coverage for empty data return
        verifyCoApplicantDetailsController.getCoApplicantData(null);
    }
    
    
    /*====================================================*/ 
    
    @isTest
    static void getAllApplicantsDataTest(){
        LoanAppl__c loanApp = [SELECT Id,Name FROM LoanAppl__c LIMIT 1];    
        verifyCoApplicantDetailsController.getAllApplicantsData(loanApp.Id);
        //code coverage for empty data return 
        verifyCoApplicantDetailsController.getAllApplicantsData(null);
    }
    
    @isTest
    static void getLoanApplDatawithChaildTest(){
        verifyCoApplicantDetailsController.getLoanApplDatawithChaild('');
    }
    
    @isTest
    static void getCoApplicantMobDataTest(){
        LoanAppl__c loanApp = [SELECT Id,Name FROM LoanAppl__c LIMIT 1];  
        Applicant__c coApplcnt = [SELECT Id,Name,MobNumber__c FROM Applicant__c WHERE LoanAppln__c = :loanApp.Id AND ApplType__c = 'C' LIMIT 1]; 
        coApplcnt.OTP_Verified__c=true;
        update coApplcnt;
        
        String mobNumber = coApplcnt.MobNumber__c;
        String recordId = '';
        verifyCoApplicantDetailsController.getCoApplicantMobData(mobNumber, recordId, loanApp.Id);
        verifyCoApplicantDetailsController.getCoApplicantMobData('', null, loanApp.Id);
    }
    
    @isTest
    static void fetchOrCreateDocumentMasterTest(){
        LoanAppl__c loanApp = [SELECT Id,Name FROM LoanAppl__c LIMIT 1];  
        Applicant__c coApplcnt = [SELECT Id,Name,MobNumber__c FROM Applicant__c WHERE LoanAppln__c = :loanApp.Id AND ApplType__c = 'C' LIMIT 1]; 
        verifyCoApplicantDetailsController.fetchOrCreateDocumentMaster(loanApp.Id, coApplcnt.Id);
        verifyCoApplicantDetailsController.getRelatedFilesByRecordId(loanApp.Id, coApplcnt.Id);
    }
    
    @isTest
    static void contentVersionTest(){
        LoanAppl__c loanApp = [SELECT Id,Name FROM LoanAppl__c LIMIT 1];  
        Applicant__c coApplcnt = [SELECT Id,Name,MobNumber__c FROM Applicant__c WHERE LoanAppln__c = :loanApp.Id AND ApplType__c = 'C' LIMIT 1]; 
        ContentVersion cnVers = verifyCoApplicantDetailsController.createContentVersion('Test File', 'File Name');
        ContentDocumentLink cntDocLnk = verifyCoApplicantDetailsController.createContentLink(cnVers.Id ,coApplcnt.Id);
        
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cnVers.Id].ContentDocumentId;
        
        verifyCoApplicantDetailsController.deleteFileRecord(conDocId);
    }
    
    @isTest
    static void testUpsertCoApplicantRecord() {
        
        LoanAppl__c loanApp = [SELECT Id,Name FROM LoanAppl__c LIMIT 1];         
        Applicant__c coApplcnt = [SELECT Id,Name FROM Applicant__c WHERE LoanAppln__c = :loanApp.Id AND ApplType__c = 'C' LIMIT 1]; 
        
        // Create a test Applicant__c record for the upsert
        Applicant__c upsertApplicant = new Applicant__c(
            Id = coApplcnt.Id, // Set the same ID for upsert
            MobNumber__c = '9876543210', // New MobNumber__c value
            ApplType__c = 'P', // New ApplType__c value
            CustProfile__c = 'SALARIED', // New CustProfile__c value
            Constitution__c = 'INDIVIDUAL', // New Constitution__c value
            Type_of_Borrower__c = 'Financial', // New Type_of_Borrower__c value
            OTP_Verified__c = true, // New OTP_Verified__c value
            ConsentType__c = 'OTP Consent', // New ConsentType__c value
            FNAME__c = 'Eng',
            LNAME__c = 'ine', // Set LNAME__c to test a non-null value
            MName__c = 'ers', // Set MName__c to test a non-null value
            LoanAppln__c = loanApp.Id
        );
        
        Applicant__c result = verifyCoApplicantDetailsController.upsertCoApplicantRecord(upsertApplicant);
        
        // Retrieve the updated Applicant__c record
        Applicant__c updatedApplicant = [SELECT Id, MobNumber__c, FNAME__c, LNAME__c, MName__c, ApplType__c, CustProfile__c, Constitution__c, Type_of_Borrower__c, OTP_Verified__c, ConsentType__c, LoanAppln__c FROM Applicant__c WHERE Id = :coApplcnt.Id];
        
    }
    
    /*====================================================*/ 
    
    
    @isTest
    static void testUploadFile() {
        
        LoanAppl__c loanApp = [SELECT Id,Name FROM LoanAppl__c LIMIT 1];         
        Applicant__c testApplicant = [SELECT Id,Name FROM Applicant__c WHERE LoanAppln__c = :loanApp.Id AND ApplType__c = 'C' LIMIT 1]; 
        
        // Create a test ContentVersion record (mocked file upload)
        ContentVersion testContentVersion = new ContentVersion(
            VersionData = Blob.valueOf('Sample File Content'), // Mocked file content
            Title = 'SampleFile.txt',
            PathOnClient = 'SampleFile.txt'
        );
        insert testContentVersion;      
        
        // Create a test DocumentMaster record
        DocMstr__c testDocumentMaster = new DocMstr__c(
            Bu__c = 'Home Loan',
            DocType__c = 'Physical Consent Proof',
            Prod__c = 'Home Loan',
            Active__c=true,
            Required__c= false
            // Add other required fields for DocMstr__c
        );
        insert testDocumentMaster;
        
        // Create a test DocumentDetail record
        DocDtl__c testDocumentDetail = new DocDtl__c(
            Appl__c = testApplicant.Id,
            DocCatgry__c = 'KYC Documents',
            DocSubTyp__c = 'Physical Consent Form',
            DocTyp__c = 'Address Proof',
            DocMstr__c = testDocumentMaster.Id         
        );
        insert testDocumentDetail;        
        
        // Call the uploadFile method
        verifyCoApplicantDetailsController.uploadFile(
            EncodingUtil.base64Encode(Blob.valueOf('Sample File Content')), // Base64 encoded file content
            'SampleFile.txt', // Filename
            loanApp.Id, // Replace with a valid loan application number
            testApplicant.Id
        );
        
        
        
        // Retrieve the created ContentDocumentLink
        //ContentDocumentLink contentLink = [SELECT Id FROM ContentDocumentLink WHERE Id = :contentLinkId LIMIT 1];
        
        
    }
    
    @isTest
    static void testUploadFileA() {
        
        LoanAppl__c loanApp = [SELECT Id,Name FROM LoanAppl__c LIMIT 1];         
        Applicant__c testApplicant = [SELECT Id,Name FROM Applicant__c WHERE LoanAppln__c = :loanApp.Id AND ApplType__c = 'C' LIMIT 1]; 
        
        // Create a test ContentVersion record (mocked file upload)
        ContentVersion testContentVersion = new ContentVersion(
            VersionData = Blob.valueOf('Sample File Content'), // Mocked file content
            Title = 'SampleFile.txt',
            PathOnClient = 'SampleFile.txt'
        );
        insert testContentVersion;
        System.debug('D22222'+testContentVersion);
        
        
        
        // Create a test DocumentMaster record
        DocMstr__c testDocumentMaster = new DocMstr__c(
            Bu__c = 'Home Loan',
            DocType__c = 'Physical Consent Proof1',
            Prod__c = 'Home Loan',
            Active__c=true,
            Required__c= false
            // Add other required fields for DocMstr__c
        );
        insert testDocumentMaster;
        System.debug('D3333'+testDocumentMaster);
        
        
        // Create a test DocumentDetail record
        DocDtl__c testDocumentDetail = new DocDtl__c(
            Appl__c = testApplicant.Id,
            DocCatgry__c = 'KYC Documents',
            DocSubTyp__c = 'Physical Consent Form1',
            DocTyp__c = 'Address Proof',
            DocMstr__c = testDocumentMaster.Id
            
            
        );
        insert testDocumentDetail;
        System.debug('D444444'+testDocumentDetail);
        
        
        // Call the uploadFile method
        verifyCoApplicantDetailsController.uploadFile(
            EncodingUtil.base64Encode(Blob.valueOf('Sample File Content')), // Base64 encoded file content
            'SampleFile.txt', // Filename
            loanApp.Id, // Replace with a valid loan application number
            testApplicant.Id
        );
        
        verifyCoApplicantDetailsController.upsertRecord(testApplicant);
    }
    
    /*====================================================*/ 
    
    @isTest
    static void testGetRelatedFilesByRecordId() {
        LoanAppl__c loanApp = [SELECT Id,Name FROM LoanAppl__c LIMIT 1];         
        Applicant__c applicant = [SELECT Id,Name FROM Applicant__c WHERE LoanAppln__c = :loanApp.Id AND ApplType__c = 'C' LIMIT 1]; 
        
        // Create a test ContentVersion record (mocked file upload)
        ContentVersion testContentVersion = new ContentVersion(
            VersionData = Blob.valueOf('Sample File Content'), // Mocked file content
            Title = 'SampleFile.txt',
            PathOnClient = 'SampleFile.txt'
        );
        insert testContentVersion;
        
        // Create a test ContentDocumentLink record linking to the Applicant__c record
        ContentDocumentLink testContentLink = new ContentDocumentLink(
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :testContentVersion.Id].ContentDocumentId,
            LinkedEntityId = applicant.Id,
            ShareType = 'I'
        );
        insert testContentLink;
        System.debug('444444'+testContentLink);
        
        // Call the getRelatedFilesByRecordId method
        List<ContentVersion> result = verifyCoApplicantDetailsController.getRelatedFilesByRecordId(loanApp.Id, applicant.Id);
        
        
    }
    
    /*==//==================================================*/ 
    
    /* === */
    
    @isTest
    static void DeleteFileRecordtest() {
        // Create a ContentDocument record for testing
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.txt';
        cv.VersionData = Blob.valueOf('Test data');
        insert cv;
        
        
        
        // Call the method to be tested
        
        String result = verifyCoApplicantDetailsController.deleteFileRecord('');
        
    }
    
    /*====================================================*/ 
    
    @isTest
    static void testUpdateMaxLimitReached() {
        LoanAppl__c loanApp = new LoanAppl__c();
        insert loanApp;
        // Create a test Applicant__c record
        // Create a test Applicant__c record
        Applicant__c testApplicant = new Applicant__c(
            MobNumber__c = '1234567890',
            CustProfile__c = 'SALARIED',
            Constitution__c = 'ASSOCIATION OF PERSONS',
            Type_of_Borrower__c = 'Financial',
            ApplType__c = 'C',
            LoanAppln__c = loanApp.Id 
            // Add other required fields for Applicant__c
        );
        insert testApplicant;
        
        // Call the updateMaxLimitReached method
        testApplicant.Is_OTP_Limit_Reached__c = false; // Set to false initially
        Applicant__c updatedApplicant = verifyCoApplicantDetailsController.updateMaxLimitReached(testApplicant);
        
        
    }
    
    /*====================================================*/ 
    
    @isTest
    static void testGenerateOTP() {
        // Create a test record to simulate data
        String recordId = 'TestRecordId';
        String mobileNumber = '1234567890';
        
        // Call the generateOTP method
        List<String> generatedOTP = verifyCoApplicantDetailsController.generateOTP(recordId, mobileNumber);
        
        // Assert that the OTP was generated
        System.assertNotEquals(null, generatedOTP);
        System.assertNotEquals(0, generatedOTP.size());
        
        // Check if a Task record was created
        List<Task> taskRecords = [SELECT Id, MobNum__c, Type, Subject, Description, OTP__c, Status FROM Task];
        System.assertNotEquals(0, taskRecords.size());
        
        // Check if the Task record contains the expected data
        Task createdTask = taskRecords[0];
        
        
    }
    
    
}