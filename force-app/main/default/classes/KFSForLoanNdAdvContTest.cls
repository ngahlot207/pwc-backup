@isTest
public class KFSForLoanNdAdvContTest {
    @isTest
    static void createTestData() {
        LoanAppl__c loanApp = new LoanAppl__c(
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
            insert loanApp;
            TriggerBase.clearBypass('LoanAppl__c');
        }
        LonaApplCharges__c lanChaRec= new LonaApplCharges__c(
        LoanApplication__c=loanApp.Id, 
        ChargeCodeID__c = '600255');
        if (true) {
            TriggerBase.bypass('LonaApplCharges__c');
            insert lanChaRec;
            TriggerBase.clearBypass('LonaApplCharges__c');
        }
        List<MasterData__c> mastList=new List<MasterData__c>();
        MasterData__c mastRec=new MasterData__c(
        Product__c='Small Ticket LAP',
		Type__c='KFS Contingent Charges',
		Sequence__c=1,
        DescriptionOfChargeAsPerFedfinaKFS__c='Penal Charges');
        MasterData__c mastRec1=new MasterData__c(
        Product__c='Small Ticket LAP',
		Name='Customer Contact Details KFS'
        );
        MasterData__c mastRec2=new MasterData__c(
        Product__c='Small Ticket LAP',
		type__C='Partner Funding',
            Active_funding_flag__c = 'Yes',
            Funding__c=10.00
        );
        MasterData__c mastRec3=new MasterData__c(
        Product__c='Small Ticket LAP',
		type__C='Charge Master',
            FinnoneCode__c = '600255');
        mastList.add(mastRec);
        mastList.add(mastRec1);
        mastList.add(mastRec2);
        if (true) {
            TriggerBase.bypass('MasterData__c');
            insert mastList;
            TriggerBase.clearBypass('MasterData__c');
        }
        
        Test.setCurrentPage(Page.KFSforLoansAdvances);
        ApexPages.currentPage().getParameters().put('recordId', loanApp.Id);
        KFSForLoanNdAdvController controller = new KFSForLoanNdAdvController();
    }
}