@istest
public class EligibilityCheckDataControllerTest {
    
    @isTest
    public static void eligibilityCheckDataControllerTestMethod(){
        List<BRE_Eligibility__c> breEligibilityList = new List<BRE_Eligibility__c>();
        
        LoanAppl__c la = TestDataFactory.createLoanApplication(true);
        
        Applicant__c app = TestDataFactory.createSingleApplicant(true, la.Id);
        app.Type_of_Borrower__c = 'Financial';
        app.Average_Monthly_Cash_Salary__c = 60000;
        update app;
        
        BRE__c bre = new BRE__c();
        bre.Applicant__c  = app.Id;
        bre.LoanAppl__c = la.Id;
        TriggerBase.bypass('BRE__c');
        insert bre;
        TriggerBase.clearBypass('BRE__c'); 
        
        BRE_Eligibility__c breEligibilityRenBankCrd = new BRE_Eligibility__c();
        breEligibilityRenBankCrd.IncomeProgram__c = 'Rental bank credit';
        breEligibilityRenBankCrd.BREValue__c = 20;
        breEligibilityRenBankCrd.BREResponse__c = bre.Id;
        breEligibilityRenBankCrd.IsLatest__c = true;
        breEligibilityList.add(breEligibilityRenBankCrd);

        BRE_Eligibility__c breEligibilityCashSalry = new BRE_Eligibility__c();
        breEligibilityCashSalry.IncomeProgram__c = 'Cash Salary';
        breEligibilityCashSalry.BREValue__c = 20;
        breEligibilityCashSalry.BREResponse__c = bre.Id;
        breEligibilityCashSalry.IsLatest__c = true;
        breEligibilityList.add(breEligibilityCashSalry);
       
        BRE_Eligibility__c breEligibilityRentalWiotBkCrdt = new BRE_Eligibility__c();
        breEligibilityRentalWiotBkCrdt.IncomeProgram__c = 'Rental without bank credit';
        breEligibilityRentalWiotBkCrdt.BREValue__c = 20;
        breEligibilityRentalWiotBkCrdt.BREResponse__c = bre.Id;
        breEligibilityRentalWiotBkCrdt.IsLatest__c = true;
        breEligibilityList.add(breEligibilityRentalWiotBkCrdt);
        
        BRE_Eligibility__c breEligibilityPenInc = new BRE_Eligibility__c();
        breEligibilityPenInc.IncomeProgram__c = 'Pension Income';
        breEligibilityPenInc.BREValue__c = 20;
        breEligibilityPenInc.BREResponse__c = bre.Id;
        breEligibilityPenInc.IsLatest__c = true;
        breEligibilityList.add(breEligibilityPenInc);
        
        BRE_Eligibility__c breEligibilityOthInc = new BRE_Eligibility__c();
        breEligibilityOthInc.IncomeProgram__c = 'Other Income';
        breEligibilityOthInc.BREValue__c = 20;
        breEligibilityOthInc.BREResponse__c = bre.Id;
        breEligibilityOthInc.IsLatest__c = true;
        breEligibilityList.add(breEligibilityOthInc);
        
        BRE_Eligibility__c breEligibilityAgrInc = new BRE_Eligibility__c();
        breEligibilityAgrInc.IncomeProgram__c = 'Agriculture Income';
        breEligibilityAgrInc.BREValue__c = 20;
        breEligibilityAgrInc.BREResponse__c = bre.Id;
        breEligibilityAgrInc.IsLatest__c =true;
        breEligibilityList.add(breEligibilityAgrInc);
        
        BRE_Eligibility__c breEligibilityCashFlowAssdInc = new BRE_Eligibility__c();
        breEligibilityCashFlowAssdInc.IncomeProgram__c = 'Cash Flow - Assessed income';
        breEligibilityCashFlowAssdInc.BREValue__c = 20;
        breEligibilityCashFlowAssdInc.BREResponse__c = bre.Id;
        breEligibilityCashFlowAssdInc.IsLatest__c = true;
        breEligibilityList.add(breEligibilityCashFlowAssdInc);
        
        TriggerBase.bypass('BRE_Eligibility__c');
        insert breEligibilityList;
        TriggerBase.clearBypass('BRE_Eligibility__c'); 
        
        EligibilityCheckDataController.CombinedObjectData resp =  EligibilityCheckDataController.fetchRecords(la.Id);
         
        system.debug('resp is '+ resp.actualApplList);
        List<Applicant__c> actualApplicant = (List<Applicant__c>) System.JSON.deserialize(resp.actualApplList, List<Applicant__c>.class);
        
        system.debug('resp is actualApplicant'+ actualApplicant.size());
        System.assertEquals(1, actualApplicant.size());
        List<BRE_Eligibility__c> breEligibilityListNew = new List<BRE_Eligibility__c>();
        
        LoanAppl__c laNew = TestDataFactory.createLoanApplication(true);
        
        Applicant__c appTwo = TestDataFactory.createSingleApplicant(true, laNew.Id);
        appTwo.Type_of_Borrower__c = 'Financial';
        appTwo.Average_Monthly_Cash_Salary__c = 60000;
        update appTwo; 
        
        BRE_Eligibility__c breEligibilityRenBankCrdT = new BRE_Eligibility__c();
        breEligibilityRenBankCrdT.IncomeProgram__c = 'Rental bank credit';
        breEligibilityRenBankCrdT.BREValue__c = 20;
        breEligibilityRenBankCrdT.BREResponse__c = bre.Id;
        breEligibilityListNew.add(breEligibilityRenBankCrdT);
        
        BRE_Eligibility__c breEligibilityCashSalryTo = new BRE_Eligibility__c();
        breEligibilityCashSalryTo.IncomeProgram__c = 'Cash Salary';
        breEligibilityCashSalryTo.BREValue__c = 20;
        breEligibilityCashSalryTo.BREResponse__c = bre.Id;
        breEligibilityListNew.add(breEligibilityCashSalryTo);
        
        BRE_Eligibility__c breEligibilityRentalWiotBkCrdtTw = new BRE_Eligibility__c();
        breEligibilityRentalWiotBkCrdtTw.IncomeProgram__c = 'Rental without bank credit';
        breEligibilityRentalWiotBkCrdtTw.BREValue__c = 20;
        breEligibilityRentalWiotBkCrdtTw.BREResponse__c = bre.Id;
        breEligibilityListNew.add(breEligibilityRentalWiotBkCrdtTw);
        
        BRE_Eligibility__c breEligibilityPenIncTwo = new BRE_Eligibility__c();
        breEligibilityPenIncTwo.IncomeProgram__c = 'Pension Income';
        breEligibilityPenIncTwo.BREValue__c = 20;
        breEligibilityPenIncTwo.BREResponse__c = bre.Id;
        breEligibilityListNew.add(breEligibilityPenIncTwo);
        
        BRE_Eligibility__c breEligibilityOthIncTwo = new BRE_Eligibility__c();
        breEligibilityOthIncTwo.IncomeProgram__c = 'Other Income';
        breEligibilityOthIncTwo.BREValue__c = 20;
        breEligibilityOthIncTwo.BREResponse__c = bre.Id;
        breEligibilityListNew.add(breEligibilityOthIncTwo);
        
        BRE_Eligibility__c breEligibilityAgrIncT = new BRE_Eligibility__c();
        breEligibilityAgrIncT.IncomeProgram__c = 'Agriculture Income';
        breEligibilityAgrIncT.BREValue__c = 20;
        breEligibilityAgrIncT.BREResponse__c = bre.Id;
        breEligibilityListNew.add(breEligibilityAgrIncT);
        
        BRE_Eligibility__c breEligibilityCashFlowAssdIncT = new BRE_Eligibility__c();
        breEligibilityCashFlowAssdIncT.IncomeProgram__c = 'Cash Flow - Assessed income';
        breEligibilityCashFlowAssdIncT.BREValue__c = 20;
        breEligibilityCashFlowAssdIncT.BREResponse__c = bre.Id;
        breEligibilityListNew.add(breEligibilityCashFlowAssdIncT);
        
        TriggerBase.bypass('BRE_Eligibility__c');
        insert breEligibilityListNew;
        TriggerBase.clearBypass('BRE_Eligibility__c'); 
        
        EligibilityCheckDataController.CombinedObjectData respNew = EligibilityCheckDataController.fetchRecords(laNew.Id);
       system.debug('respNew is '+ respNew.actualApplList);
        List<Applicant__c> actualApplicantNew = (List<Applicant__c>) System.JSON.deserialize(respNew.actualApplList, List<Applicant__c>.class);
        
        system.debug('resp is actualApplicantNew'+ actualApplicantNew.size());
        System.assertEquals(1, actualApplicantNew.size());
    }
}