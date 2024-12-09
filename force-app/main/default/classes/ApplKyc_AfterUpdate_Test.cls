@isTest
public class ApplKyc_AfterUpdate_Test {
    static testMethod void testAfterUpdate() {
        // Create test data
        
        // Populate the necessary fields for your ApplKyc__c record
        
        // Insert the test record
        //  insert applKyc;
        
        LoanAppl__c loanApp =  TestDataFactory.createLoanApplication(true);  
        Applicant__c applicant = TestDataFactory.createSingleApplicant(true, loanApp.Id);
        DocMstr__c docMstr = TestDataFactory.createDocumentMaster(true, 'Master document');
        
        list<ApplKyc__c> appkycNewList = new list<ApplKyc__c>();
        
        PincodeMstr__c pinMst = new PincodeMstr__c();
        pinMst.PIN__c = '400701';
        insert pinMst;
        
        ApplKyc__c applKyc1 = new ApplKyc__c();
        applKyc1.ValidationStatus__c = GlobalConstants.MSG_SUCCESS;
        applKyc1.Pincode__c = '400701';
        applkyc1.OCRStatus__c = GlobalConstants.MSG_SUCCESS;
        applkyc1.Applicant__c =applicant.Id;
        applkyc1.kycDoc__c = 'Passport';
        applkyc1.FatherName__c = 'Father!';
        applkyc1.Gender__c = 'M';
        applkyc1.Name__c = 'Sahn Man Sing';
        applkyc1.HusbandName__c = 'Sajy Sing';
        applkyc1.PassExpDt__c = system.today();
        insert applKyc1;
        
        
        list<ApplKyc__c> appkycOldList = new list<ApplKyc__c>();
        ApplKyc__c applKyc = new ApplKyc__c();
        applKyc.id = applKyc1.id;
        applKyc.Pincode__c = '400701';
        applkyc.OCRStatus__c = GlobalConstants.MSG_INPROGRESS;
        //applkyc.Applicant__c =applicant.Id;
        applkyc.kycDoc__c = 'Passport';
        update applKyc;
        
        DocDtl__c docDtl = TestDataFactory.createDocumentDetail(true, 'Test', applicant.Id, docMstr.Id);
        // docDtl.DocTyp__c ='Residence Address proof - OVD';
        docDtl.Applicant_KYC__c = applKyc.Id;
        docDtl.DocCatgry__c='KYC Documents';
        docDtl.DocTyp__c = 'Identity Proof';
        update docDtl;
        
        appkycNewList.add(applKyc1);
        appkycOldList.add(applKyc);
        
        ApplKyc_AfterUpdate triggerHandler = new ApplKyc_AfterUpdate();
        Test.startTest();
        triggerHandler.Afterupdate(appkycNewList, appkycOldList);
        Test.stopTest();
    }
    static testMethod void testAfterUpdate1() {
        // Create test data
        
        // Populate the necessary fields for your ApplKyc__c record
        
        // Insert the test record
        //  insert applKyc;
        
        LoanAppl__c loanApp =  TestDataFactory.createLoanApplication(true);  
        Applicant__c applicant = TestDataFactory.createSingleApplicant(true, loanApp.Id);
        DocMstr__c docMstr = TestDataFactory.createDocumentMaster(true, 'Master document');
        
        list<ApplKyc__c> appkycNewList = new list<ApplKyc__c>();
        
        PincodeMstr__c pinMst = new PincodeMstr__c();
        pinMst.PIN__c = '400701';
        insert pinMst;
        
        ApplKyc__c applKyc1 = new ApplKyc__c();
        applKyc1.ValidationStatus__c = GlobalConstants.MSG_SUCCESS;
        applKyc1.Pincode__c = '400701';
        applkyc1.OCRStatus__c = GlobalConstants.MSG_SUCCESS;
        applkyc1.Applicant__c =applicant.Id;
        applkyc1.kycDoc__c = 'Passport';
        insert applKyc1;
        appkycNewList.add(applKyc1);
        
        
        list<ApplKyc__c> appkycOldList = new list<ApplKyc__c>();
        ApplKyc__c applKyc = new ApplKyc__c();
        applKyc.id = applKyc1.id;
        applkyc.OCRStatus__c = GlobalConstants.MSG_INPROGRESS;
        //applkyc.Applicant__c =applicant.Id;
        applkyc.kycDoc__c = 'Passport';
        update applKyc;
        
        appkycOldList.add(applKyc);
        
        DocDtl__c docDtl = TestDataFactory.createDocumentDetail(true, 'Test', applicant.Id, docMstr.Id);
        // docDtl.DocTyp__c ='Residence Address proof - OVD';
        docDtl.Applicant_KYC__c = applKyc.Id;
        docDtl.DocCatgry__c='KYC Documents';
        docDtl.DocTyp__c = 'Residence Address proof - OVD';
        update docDtl;
        
        ApplAddr__c appAdd = new ApplAddr__c();
        appAdd.Applicant__c = applicant.id;
        appAdd.AddrTyp__c = 'Residence Address';
        appAdd.Pincode__c = '110001';
        insert appAdd;
        
        ApplKyc_AfterUpdate triggerHandler = new ApplKyc_AfterUpdate();
        Map<String,PincodeMstr__c> pincodeMap= new  Map<String,PincodeMstr__c>();
        pincodeMap.put(pinMst.PIN__c,pinMst);
        Test.startTest();
        triggerHandler.Afterupdate(appkycNewList, appkycOldList);
        triggerHandler.UpsertApplicantResiAddress(appkycNewList,pincodeMap);
        Test.stopTest();
    }
    static testMethod void testAfterUpdate2() {
        // Create test data
        
        // Populate the necessary fields for your ApplKyc__c record
        
        // Insert the test record
        //  insert applKyc;
        
        LoanAppl__c loanApp =  TestDataFactory.createLoanApplication(true);  
        Applicant__c applicant = TestDataFactory.createSingleApplicant(true, loanApp.Id);
        DocMstr__c docMstr = TestDataFactory.createDocumentMaster(true, 'Master document');
        
        list<ApplKyc__c> appkycNewList = new list<ApplKyc__c>();
        
        ApplKyc__c applKyc1 = new ApplKyc__c();
        applKyc1.ValidationStatus__c = GlobalConstants.MSG_SUCCESS;
        applKyc1.Pincode__c = '400701';
        applkyc1.OCRStatus__c = GlobalConstants.MSG_SUCCESS;
        applkyc1.Applicant__c =applicant.Id;
        applkyc1.kycDoc__c = 'Passport';
        insert applKyc1;
        appkycNewList.add(applKyc1);
        
        
        list<ApplKyc__c> appkycOldList = new list<ApplKyc__c>();
        ApplKyc__c applKyc = new ApplKyc__c();
        applKyc.id = applKyc1.id;
        applKyc.Pincode__c = '400701';
        applkyc.OCRStatus__c = GlobalConstants.MSG_INPROGRESS;
        //applkyc.Applicant__c =applicant.Id;
        applkyc.kycDoc__c = 'Passport';
        update applKyc;
        
        appkycOldList.add(applKyc);
        
        DocDtl__c docDtl = TestDataFactory.createDocumentDetail(true, 'Test', applicant.Id, docMstr.Id);
        // docDtl.DocTyp__c ='Residence Address proof - OVD';
        docDtl.Applicant_KYC__c = applKyc.Id;
        docDtl.DocCatgry__c='KYC Documents';
        docDtl.DocTyp__c = 'DOB Proof';
        update docDtl;
        
        ApplKyc_AfterUpdate triggerHandler = new ApplKyc_AfterUpdate();
        Test.startTest();
        triggerHandler.Afterupdate(appkycNewList, appkycOldList);
        Test.stopTest();
    }
    static testMethod void testAfterUpdate3() {
        // Create test data
        
        // Populate the necessary fields for your ApplKyc__c record
        
        // Insert the test record
        //  insert applKyc;
        
        LoanAppl__c loanApp =  TestDataFactory.createLoanApplication(true);  
        Applicant__c applicant = TestDataFactory.createSingleApplicant(true, loanApp.Id);
        DocMstr__c docMstr = TestDataFactory.createDocumentMaster(true, 'Master document');
        
        list<ApplKyc__c> appkycNewList = new list<ApplKyc__c>();
        
        ApplKyc__c applKyc1 = new ApplKyc__c();
        applKyc1.ValidationStatus__c = GlobalConstants.MSG_SUCCESS;
        applKyc1.Pincode__c = '400701';
        applkyc1.OCRStatus__c = GlobalConstants.MSG_SUCCESS;
        applkyc1.Applicant__c =applicant.Id;
        applkyc1.kycDoc__c = 'Aadhaar';
        insert applKyc1;
        appkycNewList.add(applKyc1);
        
        
        list<ApplKyc__c> appkycOldList = new list<ApplKyc__c>();
        ApplKyc__c applKyc = new ApplKyc__c();
        applKyc.id = applKyc1.id;
        applKyc.Pincode__c = '400701';
        applkyc.OCRStatus__c = GlobalConstants.MSG_INPROGRESS;
        //applkyc.Applicant__c =applicant.Id;
        applkyc.kycDoc__c = 'Aadhaar';
        update applKyc;
        
        appkycOldList.add(applKyc);
        
        DocDtl__c docDtl = TestDataFactory.createDocumentDetail(true, 'Test', applicant.Id, docMstr.Id);
        // docDtl.DocTyp__c ='Residence Address proof - OVD';
        docDtl.Applicant_KYC__c = applKyc.Id;
        docDtl.DocCatgry__c='KYC Documents';
        docDtl.DocTyp__c = 'DOB Proof';
        update docDtl;
        
        ApplKyc_AfterUpdate triggerHandler = new ApplKyc_AfterUpdate();
        Test.startTest();
        triggerHandler.Afterupdate(appkycNewList, appkycOldList);
        Test.stopTest();
    }
}