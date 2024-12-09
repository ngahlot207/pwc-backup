@isTest
public class SanctionLetterControllerTest {
    @isTest
    static void testGetloanApplicationFeilds() {
        
        //Id recordId='a08C4000007hddDIAQ';
        SchMapping__c sc =TestDataFactory.createSchemeMapping(true);
        
        LoanAppl__c la = TestDataFactory.createLoanApplication(true);  
        	la.SchemeId__c=sc.id;
            la.SanLoanAmt__c = 9595060;
            la.Loan_Tenure_Months__c = 24;
            la.EffectiveROI__c = 94;
            la.EMIIcludingInsurance__c = 34354;
            la.Stage__c = 'Soft Sanction';
         la.Rate_Type_Floating_Flag__c = 'Y';
        update la;
        
        Sanction_Conditions__c sanObj=new Sanction_Conditions__c();
        sanObj.Condition__c='test';
        sanObj.Loan_Application__c=la.id;
        insert sanObj;
        
        Payment__c payObj=new Payment__c();
        payObj.TransStatus__c='Success';
        payObj.Type__c='Charges';
        payObj.LoanAppl__c=la.id;
        payObj.TransAmt__c=1000;
        insert payObj;
        
        BankBrchMstr__c bankBranch = TestDatafactory.TestDataBankBranchMaster(true);
        bankBranch.Address__c = 'No 64, Katra Baryan, Fatehpuri, NCT OF Delhi Chandni Chowk New Delhi - 110006';
        update bankBranch;
        
        Id recordId=ApexPages.currentPage().getParameters().put('recordId',la.id);
        
        Applicant__c applicant=TestDataFactory.createSingleApplicant(true,la.id);
        	applicant.ApplType__c='P';
        	applicant.Title__c = 'Mr.';
            applicant.MobNumber__c = '9586676895';
        
        	Insurance__c insurance=TestDataFactory.InsuranceData(true,la.id,applicant.id);
        	insurance.IsActive__c = true;
        	insurance.InsType__c='Life Insurance';
        	insurance.PremiumAmount__c = 4355;
        	update insurance;
            
            ApplAddr__c applAddData=TestDataFactory.applAddData(true, la.Id, applicant.Id);
        applAddData.MailAddr__c=true;
        update applAddData;
        
        ApplAsset__c applAssetData=TestDataFactory.applAssetData(true,applicant.Id);
        applAssetData.LoanAppln__c = la.id;
            update applAssetData;
        MasterData__c mstrData=TestDataFactory.mstrData(true);
        LonaApplCharges__c chargeData=TestDataFactory.chargeData(true, la.Id, mstrData.Id);
        chargeData.Amount__c = 900;
        chargeData.ChargeCodeID__c ='600234';
        update chargeData;
        
        list<LonaApplCharges__c> lacharges= new list<LonaApplCharges__c>();
        lacharges.add(chargeData);
        Test.startTest();
        SanctionLetterController controller = new SanctionLetterController();
        controller.getInsurancePremium(la.id);
        Test.stopTest();
    }
        @isTest
    static void testGetloanApplicationFeilds1() {
        
        //Id recordId='a08C4000007hddDIAQ';
        
        LoanAppl__c la = TestDataFactory.createLoanApplication(true);  
            la.SanLoanAmt__c = 9595060;
            la.Loan_Tenure_Months__c = 24;
            la.EffectiveROI__c = 94;
            la.EMIIcludingInsurance__c = 34354;
            la.Stage__c = 'Soft Sanction';
         la.Rate_Type_Floating_Flag__c = 'Y';
        update la;
        BankBrchMstr__c bankBranch = TestDatafactory.TestDataBankBranchMaster(true);
        bankBranch.Address__c = 'No 64, Katra Baryan, Fatehpuri, NCT OF Delhi Chandni Chowk New Delhi - 110006';
        update bankBranch;
        Id recordId=ApexPages.currentPage().getParameters().put('recordId',la.id);
        
        Applicant__c applicant=TestDataFactory.createSingleApplicant(true,la.id);
        	applicant.ApplType__c='P';
        	applicant.Title__c = 'Mr.';
            applicant.MobNumber__c = '9586676895';
        
        ApplAsset__c applAssetData=TestDataFactory.applAssetData(true,applicant.Id);
        applAssetData.LoanAppln__c = la.id;
            update applAssetData;
        ApplAsset__c applAssetData1=TestDataFactory.applAssetData(true,applicant.Id);
        applAssetData1.LoanAppln__c = la.id;
            update applAssetData1;
        Test.startTest();
        SanctionLetterController controller = new SanctionLetterController();
        Test.stopTest();
    }
}