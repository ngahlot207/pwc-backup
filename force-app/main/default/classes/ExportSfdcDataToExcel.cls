public class ExportSfdcDataToExcel {
    public static void appliBnkAndAppliBnkDetail(){
        ApplBanking__c appliRec=[select id, Name_of_the_Primary_Account_Holder_s__c, AC_No__c,PeriodOfBankingEnd__c,PeriodOfBankingStart__c,AccountType__c from ApplBanking__c where id=: 'a0hC40000012cAHIAY'];
        List<ApplBankDetail__c> listApplBankDetailRecs  =[select id,CountofDebit__c,CountofCredit__c,InwardReturnsCount__c, StopPaymentCount__c,OutwardReturnsCount__c,ValueSummationCredit__c,ValueSummationDebit__c,MinBalanceCharges__c,Year__c,Month__c,BalanceAt_10th__c,BalanceAt_15th__c,BalanceAt_1st__c,BalanceAt_5th__c,BalanceAt_25th__c,BalanceAt_20th__c from ApplBankDetail__c where ApplBanking__c=:'a0hC40000012cAHIAY'];
    	system.debug('appliRec'+appliRec);
        system.debug('listApplBankDetailRecs'+listApplBankDetailRecs);
        
    }
    public class BankingWrapper{
        public String applBankingId { get; set; }
        public String primaryAccountHolderName { get; set; }
        public String accountNumber { get; set; }
        public Datetime periodOfBankingStart { get; set; }
        public Datetime periodOfBankingEnd { get; set; }
        public String accountType { get; set; }
        public List<ApplBankDetailWrapper> applBankDetailWrappers { get; set; }
    }
    public class ApplBankDetailWrapper {
        public String applBankDetailId { get; set; }
        public Integer countOfDebit { get; set; }
        public Integer countOfCredit { get; set; }
        public Integer inwardReturnsCount { get; set; }
        public Integer stopPaymentCount { get; set; }
        public Integer outwardReturnsCount { get; set; }
        public Decimal valueSummationCredit { get; set; }
        public Decimal valueSummationDebit { get; set; }
        public String minBalanceCharges { get; set; }
        public Integer year { get; set; }
        public String month { get; set; }
        public Decimal balanceAt10th { get; set; }
        public Decimal balanceAt15th { get; set; }
        public Decimal balanceAt1st { get; set; }
        public Decimal balanceAt5th { get; set; }
        public Decimal balanceAt20th { get; set; }
        public Decimal balanceAt25th { get; set; }
	}
    
}