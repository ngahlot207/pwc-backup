@isTest
public class TestExcelDataToJsonApexClass {
    @TestSetup
    static void setupTestData() {
        LoanAppl__c loanApp = new LoanAppl__c(Product__c = 'Small Ticket LAP');
        if (true) {
            TriggerBase.bypass('LoanAppl__c');
            insert loanApp;
            TriggerBase.clearBypass('LoanAppl__c');
        }
        Applicant__c app = TestDataFactory.createSingleApplicant(true,loanApp.id);
        ApplBanking__c accbnk = new ApplBanking__c(LoanAppl__c=loanApp.Id);
        insert accbnk;
		DocDtl__c docDtl = new DocDtl__c(Appl__c=app.Id,ApplBanking__c = accbnk.Id, IsLatest__c = true);
        insert docDtl;
        LoanAppl__c loanApp1 = new LoanAppl__c(
            SanLoanAmt__c = 50000,
            product__c = 'Test Product',
            BrchName__c = 'Test Branch',
            ReqLoanAmt__c = 50000
        );
        insert loanApp1;
        
        // Create Applicant Records
        Applicant__c applicant1 = new Applicant__c(
            FName__c = 'John Doe',
            ApplType__c = 'P',
            Constitution__c = 'INDIVIDUAL',
            LoanAppln__c = loanApp.Id
        );
        insert applicant1;

        Applicant__c applicant2 = new Applicant__c(
            FName__c = 'Jane Smith',
            ApplType__c = 'C',
            Constitution__c = 'PRIVATE LIMITED COMPANY',
            LoanAppln__c = loanApp.Id
        );
        insert applicant2;
        
        // Create Address Records for the Applicants
        ApplAddr__c applicantAddr1 = new ApplAddr__c(
            AddrTyp__c = 'Residence Address',
            City__c = 'New York',
            Applicant__c = applicant1.Id
        );
        insert applicantAddr1;

        ApplAddr__c applicantAddr2 = new ApplAddr__c(
            AddrTyp__c = 'Registered place for business',
            City__c = 'San Francisco',
            Applicant__c = applicant2.Id
        );
        insert applicantAddr2;
        LoanAppl__c loanApp2 = new LoanAppl__c(
        EffectiveROI__c=17,
        Loan_Tenure_Months__c=180,
        SanLoanAmt__c=1000000.00,
        InsAmt__c=50000.00,
        EMIIcludingInsurance__c=16160.00,
        EffectiveNextIntStartDt__c = Date.today(),
            DueDay__c='3',
            Rate_Type_Floating_Flag__c='Y',
        DisbursalType__c = 'SINGLE',
        Product__c = 'Small Ticket LAP',
        LoanPLRRate__c = 6.5);
        if (true) {
            TriggerBase.bypass('LoanAppl__c');
            insert loanApp2;
            TriggerBase.clearBypass('LoanAppl__c');
        }
    }
    @IsTest
    static void testCreateDocumentLink() {
        ApplBanking__c acc = [SELECT Id FROM ApplBanking__c LIMIT 1];
        String excelData = EncodingUtil.base64Encode(Blob.valueOf('Test Excel Data'));
		Test.startTest();
        String result = ExcelDataToJsonApexClass.CreateDocumentLink(acc.Id, excelData);
        Test.stopTest();
		ContentVersion insertedContent = [SELECT Id, Title FROM ContentVersion WHERE Title = 'Banking Details' LIMIT 1];
        System.assertNotEquals(null, insertedContent, 'ContentVersion should be inserted');
    }

    @IsTest
    static void testUploadExcelFile() {
        ApplBanking__c acc = [SELECT Id FROM ApplBanking__c LIMIT 1];
		String fileContents = EncodingUtil.base64Encode(Blob.valueOf('Test File Data'));
        String fileName = 'TestFile.xlsx';
		Test.startTest();
        Id contentVersionId = ExcelDataToJsonApexClass.uploadExcelFile(fileContents, fileName, acc.Id);
        Test.stopTest();
		ContentVersion insertedContent = [SELECT Id, Title FROM ContentVersion WHERE Id = :contentVersionId];
        System.assertEquals(fileName, insertedContent.Title, 'The file name should match');
    }

    @IsTest
    static void testGetAllDocDetaRecs() {
        ApplBanking__c acc = [SELECT Id FROM ApplBanking__c LIMIT 1];
        DocDtl__c docDtl = [SELECT Id, IsLatest__c FROM DocDtl__c WHERE ApplBanking__c = :acc.Id LIMIT 1];
		Test.startTest();
        ExcelDataToJsonApexClass.getAllDocDetaRecs(acc.Id);
        Test.stopTest();
        DocDtl__c updatedDocDtl = [SELECT Id, IsLatest__c FROM DocDtl__c WHERE Id = :docDtl.Id];
        System.assertEquals(false, updatedDocDtl.IsLatest__c, 'IsLatest__c should be updated to false');
    }
	@isTest
    static void createTestData(){
        List<EXCELTOJSONNEW__c> cusSettList=new List<EXCELTOJSONNEW__c>();
        EXCELTOJSONNEW__c cusSettRec= new EXCELTOJSONNEW__c();
        cusSettRec.Target_Object_Name__c='ApplBanking__c';
        cusSettRec.Name='TestRec';
        EXCELTOJSONNEW__c cusSettRec1= new EXCELTOJSONNEW__c();
        cusSettRec1.Target_Object_Name__c='ApplBankDetail__c';
        cusSettRec1.Name='TestRec1';
        cusSettRec1.Sequence__c=1;
        cusSettList.add(cusSettRec);
        cusSettList.add(cusSettRec1);
        insert cusSettList;
        List<EXCELTOJSONNEW__c> jsonMetaDataList = ExcelDataToJsonApexClass.getJsonToExcelMetadataForAppliBank();
        List<EXCELTOJSONNEW__c> jsonMetaDataList1 =  ExcelDataToJsonApexClass.MetadataForAppliBankDetail();
    }
    @isTest
    static void getMetadataForProfit(){
        List<FinancialSheetMapping__c> cusSettList=new List<FinancialSheetMapping__c>();
        FinancialSheetMapping__c cusSettRec= new FinancialSheetMapping__c();
        cusSettRec.Sheet_Name__c='Profit and loss';
        cusSettRec.Name='TestRec';
        cusSettRec.Sequence__c=1;
        FinancialSheetMapping__c cusSettRec1= new FinancialSheetMapping__c();
        cusSettRec1.Sheet_Name__c='Profit and loss 2 table';
        cusSettRec1.Name='TestRec1';
        cusSettRec1.Sequence__c=1;
        FinancialSheetMapping__c cusSettRec2= new FinancialSheetMapping__c();
        cusSettRec2.Sheet_Name__c='Profit and loss 3 table';
        cusSettRec2.Name='TestRec2';
        cusSettRec2.Sequence__c=1;
        FinancialSheetMapping__c cusSettRec3= new FinancialSheetMapping__c();
        cusSettRec3.Sheet_Name__c='Balance Sheet';
        cusSettRec3.Name='TestRec4';
        cusSettRec3.Sequence__c=1;
        FinancialSheetMapping__c cusSettRec4= new FinancialSheetMapping__c();
        cusSettRec4.Sheet_Name__c='Asset Sheet';
        cusSettRec4.Name='TestRec3';
        cusSettRec4.Sequence__c=1;
        cusSettList.add(cusSettRec);
        cusSettList.add(cusSettRec1);
        cusSettList.add(cusSettRec2);
        cusSettList.add(cusSettRec3);
        cusSettList.add(cusSettRec4);
        insert cusSettList;
        List<FinancialSheetMapping__c> getMetadata1 = ExcelUploadNdDownForFinancial.getMetadataForProfit();
        Map<string, List<FinancialSheetMapping__c>> getMetadata =  ExcelUploadNdDownForFinancial.getMetadataForProfitTab2();
    }
    @IsTest
    public static void testControllerConstructor() {
        LoanAppl__c loanApp=[select id,SanLoanAmt__c, TotalLoanAmtInclInsurance__c,product__c,Formatted_Login_Acceptance_Date__c,BrchName__c, ReqLoanAmt__c  from LoanAppl__c where Loan_Tenure_Months__c =180 LIMIT 1];
        Test.startTest();
		
       
        Test.setCurrentPage(Page.PreEmiPFInterestDedcutionLetter);
        ApexPages.currentPage().getParameters().put('recordId', loanApp.Id);
        PreEmiPFDeducLetterController controller = new PreEmiPFDeducLetterController();
        Test.stopTest();
        System.assertNotEquals(null, controller.loanApplRec, 'Loan application record should be set.');    }

    @IsTest
    public static void testNumberToEnglish() {
        Integer testValue = 234567;
        String result = PreEmiPFDeducLetterController.numberToEnglish(testValue);
        System.assertEquals('Two Lakh Thirty Four Thousand Five Hundred Sixty Seven', result, 'Number to words conversion should return correct result.');
        Integer smallValue = 15;
        String smallResult = PreEmiPFDeducLetterController.numberToEnglish(smallValue);
        System.assertEquals('Fifteen', smallResult, 'Small number to words conversion should return correct result.');
    }
}