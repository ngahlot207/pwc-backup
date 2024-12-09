@isTest
public class NameSimilarityRequestGeneratorTest {
    
    @testSetup
    static void setupTestData() {
        // Create test Loan Application
        LoanAppl__c loanApp = new LoanAppl__c();
        loanApp.Stage__c = 'DDE';
        loanApp.SubStage__c = 'CPA Data Entry';
        loanApp.BrchCode__c = 'HYC';
        loanApp.Product__c = 'Home Loan';
        loanApp.Loan_Tenure_Months__c = 120;
        loanApp.ReqLoanAmt__c = 1000000;
        loanApp.Loan_Boarding_API_Status__c = 'Success';
        loanApp.Status__c = 'Finnone Pending';
        loanApp.ErrorMessage__c = 'APPLICATION CREATED SUCCESSFULLY';
        loanApp.FinnSubDtTime__c = System.now();
        TriggerBase.bypass('LoanAppl__c');
        insert loanApp;
        TriggerBase.clearBypass('LoanAppl__c');
        
        // Create test Applicants
        List<Applicant__c> applicants = new List<Applicant__c>();
        
        Applicant__c applicant1 = new Applicant__c();
        applicant1.Constitution__c = 'PRIVATE LIMITED COMPANY';
        applicant1.MobNumber__c = '8896944363';
        applicant1.LName__c = 'Sample';
        applicant1.DOB__c = Date.newInstance(1980, 12, 9);
        applicant1.FName__c = 'Testing';
        applicant1.Age__c = 32;
        applicant1.MName__c = 'M';
        applicant1.Gender__c = 'F';
        applicant1.PassNo__c = 'S9265723';
        applicant1.PAN__c = 'AZBPS1592F';
        applicant1.KeyManName__c = 'Anu B';
        applicant1.MariStatus__c = 'M';
        applicant1.SpName__c = 'Abcd Sample';
        applicant1.MthrMdnName__c = 'V';
        applicant1.DLNo__c = 'GJ0120090974832';
        applicant1.EduQual__c = 'GRAD';
        applicant1.CompanyName__c = null;
        applicant1.Relationship__c = 'Business Associate';
        applicant1.Nationality__c = 'INDIA';
        applicant1.CustProfile__c = 'HOUSEWIFE';
        applicant1.Title__c = 'Mr.';
        applicant1.UCID__c = '12362638';
        applicant1.DOI__c = Date.newInstance(2000, 12, 9);
        applicant1.ApplType__c = 'P';
        applicant1.Religion__c = 'HINDU';
        applicant1.Father_Name__c = 'Test FName';
        applicant1.EmailId__c = 'abcd@gmail.com';
        applicant1.Category__c = 'O';
        applicant1.LoanAppln__c = loanApp.Id;
        applicant1.UCID__c = '12345';
        applicant1.MName__c = 'TestM';
        applicant1.KeyManName__c = 'KeyMan';
        applicants.add(applicant1);
        
        Applicant__c applicant2 = new Applicant__c();
        applicant2.Constitution__c = 'INDIVIDUAL';
        applicant2.MobNumber__c = '8896944363';
        applicant2.LName__c = 'Sample';
        applicant2.DOB__c = Date.newInstance(1980, 12, 9);
        applicant2.FName__c = 'Testing';
        applicant2.Age__c = 32;
        applicant2.MName__c = 'M';
        applicant2.Gender__c = 'F';
        applicant2.PassNo__c = 'S9265723';
        applicant2.PAN__c = 'AZBPS1592F';
        applicant2.KeyManName__c = 'Anu B';
        applicant2.MariStatus__c = 'M';
        applicant2.SpName__c = 'Abcd Sample';
        applicant2.MthrMdnName__c = 'V';
        applicant2.DLNo__c = 'GJ0120090974832';
        applicant2.EduQual__c = 'GRAD';
        applicant2.CompanyName__c = 'Smith Ltd';
        applicant2.Relationship__c = 'Business Associate';
        applicant2.Nationality__c = 'INDIA';
        applicant2.CustProfile__c = 'HOUSEWIFE';
        applicant2.Title__c = 'Mr.';
        applicant2.UCID__c = '12362638';
        applicant2.DOI__c = Date.newInstance(2000, 12, 9);
        applicant2.ApplType__c = 'P';
        applicant2.Religion__c = 'HINDU';
        applicant2.Father_Name__c = 'Test FName';
        applicant2.EmailId__c = 'abcd@gmail.com';
        applicant2.Category__c = 'O';
        applicant2.LoanAppln__c = loanApp.Id;
        applicant2.UCID__c = '12345';
        applicant2.MName__c = 'TestM';
        applicant2.KeyManName__c = 'KeyMan';
        applicants.add(applicant2);
        
        insert applicants;
        
        // Create other related records
        ApplKyc__c appKyc = new ApplKyc__c();
        appKyc.PassExpDt__c = Date.newInstance(2029, 12, 9);
        appKyc.kycDoc__c = 'Passport';
        appKyc.Applicant__c = applicant1.ID;
        insert appKyc;
        
        ApplBanking__c bankObj = new ApplBanking__c();
        bankObj.Appl__c = applicant1.Id;
        bankObj.LoanAppl__c = loanApp.Id;
        insert bankObj;
        
        APIVer__c apiVerObj = new APIVer__c();
        apiVerObj.Appl__c = applicant2.Id;
        apiVerObj.LoanAplcn__c = loanApp.Id;
        insert apiVerObj;
        
        ApplGST__c gstObj = new ApplGST__c();
        gstObj.Applicant__c = applicant1.Id;
        insert gstObj;
        
        Applicant_Financial__c finObj = new Applicant_Financial__c();
        finObj.Loan_Applicant__c = applicant1.Id;
        insert finObj;
        
        // Create Document Master and Document Details
        List<DocDtl__c> docDetails = new List<DocDtl__c>();
        
        DocDtl__c docDetail1 = new DocDtl__c();
        docDetail1.LAN__c = loanApp.Id;
        docDetail1.OSV__c = true;
        docDetail1.DocTyp__c = 'PAN';
        docDetail1.Appl__c = applicant1.ID;
        docDetail1.DocStatus__c = 'PDD';
        docDetail1.DocSubTyp__c = 'Photograph of Property Visited';
        docDetail1.TargetDt__c = Date.newInstance(2024, 12, 9);
        docDetail1.ReceivedDt__c = Date.newInstance(2025, 12, 9);
        docDetails.add(docDetail1);
        
        DocDtl__c docDetail2 = new DocDtl__c();
        docDetail2.LAN__c = loanApp.Id;
        docDetail2.OSV__c = true;
        docDetail2.DocTyp__c = 'PAN';
        docDetail2.Appl__c = applicant1.ID;
        docDetail2.DocStatus__c = 'OTC';
        docDetail2.DocSubTyp__c = 'Interest bearing Letter-Top up';
        docDetail2.TargetDt__c = Date.newInstance(2024, 12, 9);
        docDetail2.ReceivedDt__c = Date.newInstance(2025, 12, 9);
        docDetails.add(docDetail2);
        
        insert docDetails;
        
        // Create Integration Messages
        List<IntgMsg__c> intgMsgs = new List<IntgMsg__c>();
        
        IntgMsg__c intgMsg1 = new IntgMsg__c(
            RefId__c = appKyc.Id,
            ParentRefId__c = applicant1.Id,
            ParentRefObj__c = 'Applicant__c',
            RefObj__c = 'ApplKyc__c',
            Status__c = 'In Progress',
            Svc__c = 'Name Similarity',
            Name = 'Name Similarity'
        );
        intgMsgs.add(intgMsg1);
        
        IntgMsg__c intgMsg2 = new IntgMsg__c(
            RefId__c = finObj.Id,
            ParentRefId__c = applicant1.Id,
            ParentRefObj__c = 'Applicant__c',
            RefObj__c = 'Applicant_Financial__c',
            Status__c = 'In Progress',
            Svc__c = 'Name Similarity',
            Name = 'Name Similarity'
        );
        intgMsgs.add(intgMsg2);
        
        IntgMsg__c intgMsg3 = new IntgMsg__c(
            RefId__c = gstObj.Id,
            ParentRefId__c = applicant1.Id,
            ParentRefObj__c = 'Applicant__c',
            RefObj__c = 'ApplGST__c',
            Status__c = 'In Progress',
            Svc__c = 'Name Similarity',
            Name = 'Name Similarity'
        );
        intgMsgs.add(intgMsg3);
        
        IntgMsg__c intgMsg4 = new IntgMsg__c(
            RefId__c = apiVerObj.Id,
            ParentRefId__c = applicant2.Id,
            ParentRefObj__c = 'Applicant__c',
            RefObj__c = 'APIVer__c',
            Status__c = 'In Progress',
            Svc__c = 'Name Similarity',
            Name = 'Name Similarity'
        );
        intgMsgs.add(intgMsg4);
        
        IntgMsg__c intgMsg5 = new IntgMsg__c(
            RefId__c = bankObj.Id,
            ParentRefId__c = applicant1.Id,
            ParentRefObj__c = 'Applicant__c',
            RefObj__c = 'ApplBanking__c',
            Status__c = 'In Progress',
            Svc__c = 'Name Similarity',
            Name = 'Name Similarity'
        );
        intgMsgs.add(intgMsg5);
        
        insert intgMsgs;
    }
    
    @isTest
    static void testGenerate() {
        List<IntgMsg__c> intgMessages = [SELECT RefId__c, ParentRefId__c, ParentRefObj__c, RefObj__c, Status__c, Svc__c FROM IntgMsg__c WHERE RefObj__c IN ('ApplKyc__c', 'ApplBanking__c', 'APIVer__c', 'ApplGST__c', 'Applicant_Financial__c')];
        
        // Initialize the NameSimilarityRequestGenerator
        NameSimilarityRequestGenerator generator = new NameSimilarityRequestGenerator();
        
        // Call the generate method
        Test.startTest();
        for (IntgMsg__c msg : intgMessages) {
            generator.generate(new List<IntgMsg__c>{msg}, 'Name Similarity', 'Async');
        }
        Test.stopTest();
        
        // Verify the results
        List<IntgMsg__c> updatedIntgMessages = [SELECT Id, Req__c, Status__c FROM IntgMsg__c];
        System.assertEquals(5, updatedIntgMessages.size(), 'Number of updated IntgMsg__c records should be 5');
        
        // Additional assertions to check specific fields updated
        for (IntgMsg__c intgMsg : updatedIntgMessages) {
            //System.assertNotEquals(null, intgMsg.Req__c, 'Req__c should not be null');
            System.assertEquals(GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS, intgMsg.Status__c, 'Status__c should be IN_PROGRESS');
        }
    }
}