@isTest
public class UpdateAnnTurnOverOnAppliHandTest {
    @isTest
    public static void testUpdateAnnualTurnoverAmount(){ 
        
        Id stExam = Schema.SObjectType.Applicant_Financial__c.getRecordTypeInfosByName().get('Profit & Loss').getRecordTypeId();
        LoanAppl__c loanAppl = new LoanAppl__c(BrchName__c = 'Bhagalpur');
        insert loanAppl;
        
        Applicant__c applicant = new Applicant__c(LoanAppln__c = loanAppl.Id);
        insert applicant;
        
        Applicant_Financial__c applicantFinancial = new Applicant_Financial__c(
            Loan_Applicant__c = applicant.Id,
            Income_Documents__c = 'Latest year ITR & computation',
            RecordTypeId = stExam
        );
        insert applicantFinancial;
        
        Applicant_Financial_Summary__c financialSummary = new Applicant_Financial_Summary__c(
            Applicant_Financial__c = applicantFinancial.Id,
            Total_Sales__c = 50000.00,
            Financial_Year__c = String.valueOf(Date.today().year())
        );
        insert financialSummary;
        
        financialSummary.Total_Sales__c = 20000.00;
        
        update financialSummary;
        
        
        List<Applicant_Financial_Summary__c> financialSummaryList = new List<Applicant_Financial_Summary__c>{financialSummary};
        
        UpdateAnnualTurnoverOnApplicantHandler.updateAnnualTurnoverAmount(financialSummaryList);
        
        Applicant__c updatedApplicant = [SELECT Annual_Turnover__c FROM Applicant__c WHERE Id = :applicant.Id];
        
        System.assertEquals(20000.00, updatedApplicant.Annual_Turnover__c, 'Annual Turnover should be updated to 50000.00');
    }
    
    @isTest
    public static void testUpdateAnnualTurnoverAmount2(){
        
        Id stExam = Schema.SObjectType.Applicant_Financial__c.getRecordTypeInfosByName().get('Profit & Loss').getRecordTypeId();
        LoanAppl__c loanAppl = new LoanAppl__c(BrchName__c = 'Bhagalpur');
        insert loanAppl;
        
        Applicant__c applicant = new Applicant__c(LoanAppln__c = loanAppl.Id);
        insert applicant;
        
        Applicant_Financial__c applicantFinancial = new Applicant_Financial__c(
            Loan_Applicant__c = applicant.Id,
            Income_Documents__c = 'Latest year ITR & computation',
            RecordTypeId = stExam
        );
        insert applicantFinancial;
        
        Applicant_Financial_Summary__c financialSummary = new Applicant_Financial_Summary__c(
            Applicant_Financial__c = applicantFinancial.Id,
            Total_Sales__c = 50000.00,
            Financial_Year__c = String.valueOf(Date.today().year())
        );
        insert financialSummary;
        
        delete financialSummary;
        
        
        List<Applicant_Financial_Summary__c> financialSummaryList = new List<Applicant_Financial_Summary__c>{financialSummary};
        
        UpdateAnnualTurnoverOnApplicantHandler.updateAnnualTurnoverAmount(financialSummaryList);
    }
    
    @isTest
    public static void testUpdateAnnualTurnoverAmount3(){
        
        Id stExam = Schema.SObjectType.Applicant_Financial__c.getRecordTypeInfosByName().get('Profit & Loss').getRecordTypeId();
        
        LoanAppl__c loanAppl = new LoanAppl__c(BrchName__c = 'Bhagalpur');
        insert loanAppl;
        
        Applicant__c applicant = new Applicant__c(LoanAppln__c = loanAppl.Id);
        insert applicant;
        
        Applicant_Financial__c applicantFinancial = new Applicant_Financial__c(
            Loan_Applicant__c = applicant.Id,
            Income_Documents__c = 'Latest Year Form 16',
            RecordTypeId = stExam
        );
        insert applicantFinancial;
        
        Applicant_Financial_Summary__c financialSummary = new Applicant_Financial_Summary__c(
            Applicant_Financial__c = applicantFinancial.Id,
            Total_Sales__c = 50000.00,
            Financial_Year__c = String.valueOf(Date.today().year())
        );
        insert financialSummary;
        
        Applicant_Financial_Summary__c financialSummary2 = new Applicant_Financial_Summary__c(
            Applicant_Financial__c = applicantFinancial.Id,
            Total_Sales__c = 10000.00,
            Financial_Year__c = String.valueOf(Date.today().year())
        );
        insert financialSummary2;
        
        List<Applicant_Financial_Summary__c> financialSummaryList = new List<Applicant_Financial_Summary__c>{financialSummary};
            
            List<Applicant_Financial_Summary__c> financialSummaryList2 = new List<Applicant_Financial_Summary__c>{financialSummary2};
        
        UpdateAnnualTurnoverOnApplicantHandler.updateAnnualTurnoverAmount(financialSummaryList2,financialSummaryList);
    }
}