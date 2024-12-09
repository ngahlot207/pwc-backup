public class PerfiosRetrieveReportResponseWrapper {
    
    public CustomerInfo customerInfo;
    public List<StatementDetails> statementdetails;
    public List<AccountAnalysis> accountAnalysis;
    public List<CombinedMonthlyDetails> combinedMonthlyDetails;
    public List<AccountXns> accountXns;
    //public AdditionalBankingMonthlyDetails AdditionalBankingMonthlyDetails;
    public Map<String,List<BankingMonthlyData1>> AdditionalBankingMonthlyDetails;
    //public AdditionalFedfinaMonthlyDetails AdditionalFedfinaMonthlyDetails;
    public Map<String,List<FedfinaMothlyData1>> AdditionalFedfinaMonthlyDetails;
    //public AdditionalTransactionMonthlyDetails AdditionalTransactionMonthlyDetails;
    public Map<String,List<MonthlyData1>> AdditionalTransactionMonthlyDetails;
    //public AdditionalSummaryInfo AdditionalSummaryInfo;
    public Map<String,List<SummaryInfo1>> AdditionalSummaryInfo;
    public class CustomerInfo {
        public String name;	//M/S. RUDRA BUILDCON
        public String address;	//C/O RB GROUND FLR C/O OM RESIDENCY 135/1 PAGI ROOM SILVER STAR CHAR NR D P PATEL PLAY SCHOOL GOTA AHMEDABAD 382481 GUJARAT INDIA
        public String landline;	//
        public String mobile;	//18002026161
        public String email;	//D.PRINCE.J@GMAIL.COM
        public String pan;	//
        public String perfiosTransactionId;	//2MD31687442206712
        public String customerTransactionId;	//123456
        public String bank;	//HDFC Bank, India
        public Integer instId;	//20
    }
    
    public class StatementDetails {
        public String fileName;	//HDFCRudrastmntFY2223.pdf
        public String statementStatus;	//VERIFIED
        public String remarks;
        public CustomerInfo customerInfo;
        public List<StatementAccounts> statementAccounts;
    }
    
    public class StatementAccounts {
        public String accountNo;	//50200028575953
        public String accountType;	//Bank
        public String xnsStartDate;	//2022-04-07
        public String xnsEndDate;	//2023-03-31
    }
    
    public class AccountAnalysis {
        public String accountNo;	//50200028575953
        public String accountType;	//
        public List<LoanTrackDetails> loanTrackDetails;
        public SummaryInfo summaryInfo;
        public List<MonthlyDetails> monthlyDetails;
        public List<MonthlyDetails> partialMonthDetails;
        public List<EODBalances> eODBalances;
        public List<EODBalances> partialMonthEODBalances;
        public List<Xns> onlineCreditXns;
        public List<Top5Funds> top5FundsReceived;
        public List<Top10Payments> top10PaymentsReceived;
        public List<Xns> eMILOANXns;
        public List<Xns> salaryXns;
        public List<Xns> onlineDebitXns;
        public List<Top5Funds> top5FundsTransferred;
        public List<Top10Payments> top10PaymentsMade;
        public List<Xns> inwEMIBounceXns;
        public List<Xns> regularCredits;
        public List<Xns> regularDebits;
        public List<Xns> bouncedOrPenalChargeXns;
        public List<Xns> transferFromToInterGroupXns;
        public FCUAnalysis fCUAnalysis;
    }
    
    public class LoanTrackDetails {
        public Double amount;	//12630
        public String category;	//Loan
        public String PerfiosDates;	// Actual Parameter dates, 07-Jun-22 07-Jul-22 07-Aug-22
    }
    
    public class SummaryInfo {
        public String instName;	//HDFC Bank, India
        public String accNo;	//50200028575953
        public String accType;	//
        public Integer fullMonthCount;	//12
        public Summary total;
        public Summary average;
    }
    
    public class Summary {
        public Double avgUtilization;	//0
        public Double bal1;	//10985206
        public Double bal10;	//13334271
        public Double bal15;	//10861598
        public Double bal20;	//10954495
        public Double bal25;	//14660633
        public Double bal5;	//12422752
        public Double balAvg;	//12696056.71
        public Double balMax;	//39649069
        public Double balMin;	//2418157
        public Double bankCharges;	//0
        public Double belowMinBalPenalties;	//0
        public Double cardSettlements;	//0
        public Double cashBacks;	//0
        public Double cashDeposits;	//0
        public Double cashWithdrawals;	//0
        public Double chqDeposits;	//12
        public Double chqIssues;	//167
        public Double creditCardPayments;	//8
        public Double credits;	//35
        public Double creditsSC;	//0
        public Double creditsSelf;	//1
        public Double debits;	//169
        public Double debitsSC;	//0
        public Double debitsSelf;	//6
        public Double dpLimit;	//0
        public Double emiOrLoans;	//13
        public Double houseRent;	//0
        public Double insuranceExpenses;	//0
        public Double interestCharges;	//0
        public Double interestIncomes;	//0
        public Double intPayDelay;	//0
        public Double invIncomes;	//0
        public Double inwBounceCharges;	//0
        public Double inwBounceNonTechnical;	//0
        public Double inwBounces;	//1
        public Double inwBounceTechnical;	//1
        public Double inwChqBounceNonTechnical;	//0
        public Double inwEMIBounces;	//0
        public Double loanDisbursals;	//0
        public Double onlineShopping;	//0
        public Double otherExpenses;	//1
        public Double otherIncomes;	//0
        public Double outwBounceCharges;	//0
        public Double outwBounces;	//0
        public Double outwChqBounces;	//0
        public Double overdrawnAmountPeak;	//0
        public Double overdrawnDays;	//0
        public Double overdrawnDaysPeak;	//0
        public Double overdrawnInstances;	//0
        public Double paymentFromTop5;	//31
        public Double paymentToTop5;	//12
        public Double penalCharges;	//0
        public Double pension;	//0
        public Double posExpenses;	//0
        public Double rentCredits;	//0
        public Double salaries;	//0
        public Double salaryPaid;	//0
        public Double snLimit;	//0
        public Double stopPayments;	//0
        public Double taxPayment;	//0
        public Double totalAvgCredit;	//2260603.45
        public Double totalBankCharge;	//0
        public Double totalBelowMinBalPenalty;	//0
        public Double totalCardSettlement;	//0
        public Double totalCashBack;	//0
        public Double totalCashDeposit;	//0
        public Double totalCashWithdrawal;	//0
        public Double totalChqDeposit;	//31864343
        public Double totalChqIssue;	//68518142
        public Double totalCredit;	//68531686
        public Double totalCreditCardPayment;	//384858
        public Double totalCreditSC;	//0
        public Double totalCreditSelf;	//250000
        public Double totalDebit;	//53365567
        public Double totalDebitSC;	//0
        public Double totalDebitSelf;	//15114219
        public Double totalEmiOrLoan;	//155690
        public Double totalHouseRent;	//0
        public Double totalInsuranceExpense;	//0
        public Double totalInterestCharged;	//0
        public Double totalInterestIncome;	//0
        public Double totalInvIncome;	//0
        public Double totalInwBounce;	//423431
        public Double totalInwBounceCharge;	//0
        public Double totalInwChqBounceNonTechnical;	//0
        public Double totalInwEMIBounce;	//0
        public Double totalInwEMIBounceNonTechnical;	//0
        public Double totalInwEMIBounceTechnical;	//0
        public Double totalLoanDisbursal;	//0
        public Double totalOnlineShopping;	//0
        public Double totalOtherExpense;	//217
        public Double totalOtherIncome;	//0
        public Double totalOutwBounce;	//0
        public Double totalOutwBounceCharge;	//0
        public Double totalOutwChqBounce;	//0
        public Double totalPaymentFromTop5;	//62505272
        public Double totalPaymentToTop5;	//27731148
        public Double totalPenalCharge;	//0
        public Double totalPension;	//0
        public Double totalPosExpense;	//0
        public Double totalRentCredit;	//0
        public Double totalSalary;	//0
        public Double totalSalaryPaid;	//0
        public Double totalTaxPayment;	//0
        public Double totalTransferToWallet;	//0
        public Double totalUpiCredit;	//0
        public Double totalUpiDebit;	//0
        public Double totalUtilityExpense;	//0
        public Double transferToWallet;	//0
        public Double upiCredits;	//0
        public Double upiDebits;	//0
        public Double utilityExpenses;	//0
        public Double xnsCount;	//213
    }
    
    public class MonthlyDetails {
        public Double avgUtilization;	//0
        public Double bal1;	//452895
        public Double bal10;	//505265
        public Double bal15;	//280765
        public Double bal20;	//233565
        public Double bal25;	//233565
        public Double bal5;	//2952895
        public Double balAvg;	//701181
        public Double balMax;	//2952895
        public Double balMin;	//133065
        public Double bankCharges;	//0
        public Double belowMinBalPenalties;	//0
        public Double cardSettlements;	//0
        public Double cashBacks;	//0
        public Double cashDeposits;	//0
        public Double cashWithdrawals;	//0
        public Double chqDeposits;	//0
        public Double chqIssues;	//25
        public Double creditCardPayments;	//0
        public Double credits;	//1
        public Double creditsSC;	//0
        public Double creditsSelf;	//0
        public Double debits;	//25
        public Double debitsSC;	//0
        public Double debitsSelf;	//0
        public Double dpLimit;	//0
        public Double emiOrLoans;	//1
        public Double houseRent;	//0
        public Double insuranceExpenses;	//0
        public Double interestCharges;	//0
        public Double interestIncomes;	//0
        public Double intPayDelay;	//0
        public Double invIncomes;	//0
        public Double inwBounceCharges;	//0
        public Double inwBounceNonTechnical;	//0
        public Double inwBounces;	//0
        public Double inwBounceTechnical;	//0
        public Double inwChqBounceNonTechnical;	//0
        public Double inwEMIBounces;	//0
        public Double loanDisbursals;	//0
        public String monthName;	//Jun-22
        public Double onlineShopping;	//0
        public Double otherExpenses;	//0
        public Double otherIncomes;	//0
        public Double outwBounceCharges;	//0
        public Double outwBounces;	//0
        public Double outwChqBounces;	//0
        public Double overdrawnAmountPeak;	//0
        public Double overdrawnDays;	//0
        public Double overdrawnDaysPeak;	//0
        public Double overdrawnInstances;	//0
        public Double paymentFromTop5;	//1
        public Double paymentToTop5;	//0
        public Double penalCharges;	//0
        public Double pension;	//0
        public Double posExpenses;	//0
        public Double rentCredits;	//0
        public Double salaries;	//0
        public Double salaryPaid;	//0
        public Double snLimit;	//0
        public String startDate;	//2022-06-01
        public Double stopPayments;	//0
        public Double taxPayment;	//0
        public Double totalAvgCredit;	//83333.33
        public Double totalBankCharge;	//0
        public Double totalBelowMinBalPenalty;	//0
        public Double totalCardSettlement;	//0
        public Double totalCashBack;	//0
        public Double totalCashDeposit;	//0
        public Double totalCashWithdrawal;	//0
        public Double totalChqDeposit;	//0
        public Double totalChqIssue;	//2819830
        public Double totalCredit;	//2500000
        public Double totalCreditCardPayment;	//0
        public Double totalCreditSC;	//0
        public Double totalCreditSelf;	//0
        public Double totalDebit;	//2819830
        public Double totalDebitSC;	//0
        public Double totalDebitSelf;	//0
        public Double totalEmiOrLoan;	//12630
        public Double totalHouseRent;	//0
        public Double totalInsuranceExpense;	//0
        public Double totalInterestCharged;	//0
        public Double totalInterestIncome;	//0
        public Double totalInvIncome;	//0
        public Double totalInwBounce;	//0
        public Double totalInwBounceCharge;	//0
        public Double totalInwChqBounceNonTechnical;	//0
        public Double totalInwEMIBounce;	//0
        public Double totalInwEMIBounceNonTechnical;	//0
        public Double totalInwEMIBounceTechnical;	//0
        public Double totalLoanDisbursal;	//0
        public Double totalOnlineShopping;	//0
        public Double totalOtherExpense;	//0
        public Double totalOtherIncome;	//0
        public Double totalOutwBounce;	//0
        public Double totalOutwBounceCharge;	//0
        public Double totalOutwChqBounce;	//0
        public Double totalPaymentFromTop5;	//2500000
        public Double totalPaymentToTop5;	//0
        public Double totalPenalCharge;	//0
        public Double totalPension;	//0
        public Double totalPosExpense;	//0
        public Double totalRentCredit;	//0
        public Double totalSalary;	//0
        public Double totalSalaryPaid;	//0
        public Double totalTaxPayment;	//0
        public Double totalTransferToWallet;	//0
        public Double totalUpiCredit;	//0
        public Double totalUpiDebit;	//0
        public Double totalUtilityExpense;	//0
        public Double transferToWallet;	//0
        public Double upiCredits;	//0
        public Double upiDebits;	//0
        public Double utilityExpenses;	//0
        public Double xnsCount;	//26
    }
    
    public class EODBalances {
        public String PerfiosDate;	//2022-06-01 Actual Parameter Name: date
        public Double balance;	//452895
    }
    
    public class Top5Funds {
        public String month;	//Jun-22
        public String category;	//Transfer from SKY INFRA
        public Double amount;	//2500000
    }
    
    public class Top10Payments {
        public String party;	//SKYINFRA
        public Double amount;	//51812929
        public Double count;	//21
    }
    
    public class FCUAnalysis {
        public PossibleFraudIndicators possibleFraudIndicators;
        public BehaviouralTransactionalIndicators behaviouralTransactionalIndicators;
    }
    
    public class PossibleFraudIndicators {
        public SuspiciousBankEStatements suspiciousBankEStatements;
        public TransactionOnHolidayXns transactionOnHolidayXns;
        public ChqDepositOnHolidayXns chqDepositOnHolidayXns;
        public RTGSTransactionOnHolidayXns rtgsTransactionOnHolidayXns;
        public NEFTTransactionOnHolidayXns neftTransactionOnHolidayXns;
        public CashDepositOnHolidayXns cashDepositOnHolidayXns;
        public InterestTransactionOnHolidayXns interestTransactionOnHolidayXns;
        public SuspiciousATMXns suspiciousATMXns;
        public ATMWithChqNoXns aTMWithChqNoXns;
        public ATMWithSuspiciousAmountXns aTMWithSuspiciousAmountXns;
        public SalaryOnHolidayXns salaryOnHolidayXns;
		public InterestCreditXns interestCreditXns;
		public InterestChargeXns interestChargeXns;
		public SuspiciousRTGSXns suspiciousRTGSXns;
        public AmountBalanceMismatchXns amountBalanceMismatchXns;
        public RotationOfMoney rotationOfMoney;
        public LowAccountVintage lowAccountVintage;
        public TransactionsOnSaturdayXns TransactionsOnSaturdayXns;
		public CashDepositsWithDecimalXns CashDepositsWithDecimalXns;
        public List<Month> irregularAdminFeeTransactionsMonths;
		public List<Month> interestNotPresentInFewMonthsMonths;
		public List<Month> interestTaxNotPresentInFewMonthsMonths;
		public TaxNotPresentComparedToInterestXns taxNotPresentComparedToInterestXns;
        public AccountNumberMismatch accountNumberMismatch;
    }
    
    public class SuspiciousBankEStatements {
        public String status;	//false
    }
    public class TransactionOnHolidayXns{
        public List<Xns> transactionOnHolidayXns;
    }
    public class ChqDepositOnHolidayXns{
        public List<Xns> chqDepositOnHolidayXns;
    }
    public class RTGSTransactionOnHolidayXns{
        public List<Xns> rtgsTransactionOnHolidayXns;
    }
    public class NEFTTransactionOnHolidayXns{
        public List<Xns> neftTransactionOnHolidayXns;
    }
    public class CashDepositOnHolidayXns{
        public List<Xns> cashDepositOnHolidayXns;
    }
    public class InterestTransactionOnHolidayXns{
        public List<Xns> interestTransactionOnHolidayXns;
    }
    public class SuspiciousATMXns{
        public List<Xns> suspiciousATMXns;
    }
    public class ATMWithChqNoXns{
        public List<Xns> aTMWithChqNoXns;
    }
    public class ATMWithSuspiciousAmountXns{
        public List<Xns> aTMWithSuspiciousAmountXns;
    }
    public class SalaryOnHolidayXns{
        public List<Xns> salaryOnHolidayXns;
    }
    public class InterestCreditXns{
        public List<Xns> interestCreditXns;
    }
    public class InterestChargeXns{
        public List<Xns> interestChargeXns;
    }
    public class SuspiciousRTGSXns{
        public List<Xns> suspiciousRTGSXns;
    }
    public class AmountBalanceMismatchXns{
        public List<Xns> amountBalanceMismatchXns;
    }
    public class RotationOfMoney {
        public String status;
    }
    public class LowAccountVintage {
        public String status;
    }
    public class TransactionsOnSaturdayXns{
        public List<Xns> TransactionsOnSaturdayXns;
    }
    public class CashDepositsWithDecimalXns{
        public List<Xns> CashDepositsWithDecimalXns;
    }
    public class Month{
        public String month;
    }
    public class TaxNotPresentComparedToInterestXns{
        public List<Xns> taxNotPresentComparedToInterestXns;
    }
    public class AccountNumberMismatch{
        public String declaredAccountNo;
        public String actualAccountNo;
    }
    
    
    public class BehaviouralTransactionalIndicators {
        
        public BigDebitAfterSalaryXns bigDebitAfterSalaryXns;
        public CashWithdrawalAfterCashDepositXns cashWithdrawalAfterCashDepositXns;
        public CashWithdrawalAfterCreditXns cashWithdrawalAfterCreditXns;
		public SalaryAmountNotVaryingXns salaryAmountNotVaryingXns;
		public MoreCashXns moreCashXns;
        public MoreCashDepositXns moreCashDepositXns;
		public TaxPaymentXns taxPaymentXns;
		public NegativeEODBalanceXns negativeEODBalanceXns;
		public NegativeAllEODBalanceXns negativeAllEODBalanceXns;
		public HighCashDepositXns highCashDepositXns;
        public EqualCreditDebitXns equalCreditDebitXns;
        public SuspiciousSalaryDebitXns SuspiciousSalaryDebitXns;
        public NeftImpsWithChqNoXns neftImpsWithChqNoXns;
        public NeftImpsRtgsAgainstSalaryXns neftImpsRtgsAgainstSalaryXns;
        public RoundedSalaryTransactionXns roundedSalaryTransactionXns;
        public List<Xns> irregularInterestDebitXns;
		public List<Xns> irregularSalaryCreditXns;
		public List<Xns> irregularTransferToPartiesXns;
		public List<Xns> irregularEmiEcsXns;
        public List<Month> lowXns;
		public List<Month> noXnMonths;
		public List<Month> noPosXnMonths;
        public RevenueSheriffXns revenueSheriffXns;
        public Status mismatchSummaryAgainstCalculatedValues;
        public Status onlyAtmDebitsInAnyOfLastThreeMonths;
        public Status debitTransactionToEmployer;
        public List<PartiesInCreditsAndDebits> partiesInCreditsAndDebits;
        public Status discontinuityInCredits;
        public SalaryThroughIMPSOrUPI salaryThroughIMPSOrUPI;
        public SalaryThroughIMPSOrMPAYOrCHQ salaryThroughIMPSOrMPAYOrCHQ;
        public Status nonRoundFigureCredits;
		public Status hugeBalances;
		public Status creditInterestNotReflecting;
		public Status debitInterestNotReflecting;
		public ChequeNumberInSeriesXns chequeNumberInSeriesXns;
        public Status unusualODCCActivity;
        public Count irregularCreditTransactions;
        public Status consecutiveEMIChequeBounces;
        public DebitEODBalanceXns debitEODBalanceXns;
        public CreditEODBalanceXns creditEODBalanceXns;
        public DepositsRelatedToGovtAgenciesXns depositsRelatedToGovtAgenciesXns;
		public CasinoRelatedXns casinoRelatedXns;
		public FinancialCommitmentRelatedXns financialCommitmentRelatedXns;
		public LargeValueCreditXns largeValueCreditXns;
		public RoundFigureXns roundFigureXns;
		public ChqReturnXns chqReturnXns;
		public PartiesInCreditsAndDebitsWhenCreditGreaterThanAMB partiesInCreditsAndDebitsWhenCreditGreaterThanAMB;
		public CashDepositGreaterThanAMB cashDepositGreaterThanAMB;
		public NeftRtgsGreaterThanAMB neftRtgsGreaterThanAMB;
		public ChqWithdrawalOnHolidayXns chqWithdrawalOnHolidayXns;
		public UpiAboveThresholdXns upiAboveThresholdXns;
		public ImpsAboveThresholdXns impsAboveThresholdXns;
		public SalaryWithSameNarrationXns salaryWithSameNarrationXns;
		public MajorityRoundFigureXns majorityRoundFigureXns;
		 
    }
    
    
    public class BigDebitAfterSalaryXns{
        public List<Xns> bigDebitAfterSalaryXns;
    }
    public class CashWithdrawalAfterCashDepositXns{
        public List<Xns> cashWithdrawalAfterCashDepositXns;
    }
    public class CashWithdrawalAfterCreditXns{
        public List<Xns> cashWithdrawalAfterCreditXns;
    }
    public class SalaryAmountNotVaryingXns{
        public List<Xns> salaryAmountNotVaryingXns;
    }
    public class MoreCashXns {
        public String status;	//false
    }
    public class MoreCashDepositXns{
        public List<Xns> moreCashDepositXns;
    }
    public class TaxPaymentXns{
        public List<Xns> taxPaymentXns;
    }
    public class NegativeEODBalanceXns{
        public List<Xns> negativeEODBalanceXns;
    }
    public class NegativeAllEODBalanceXns{
        public List<Xns> negativeAllEODBalanceXns;
    }
    public class HighCashDepositXns{
        public List<Xns> highCashDepositXns;
    }
    public class EqualCreditDebitXns {
        public String status;	//false
    }
    public class SuspiciousSalaryDebitXns{
        public List<Xns> SuspiciousSalaryDebitXns;
    }
    public class NeftImpsWithChqNoXns {
        public List<Xns> neftImpsWithChqNoXns;
    }
    public class NeftImpsRtgsAgainstSalaryXns{
        public List<Xns> neftImpsRtgsAgainstSalaryXns;
    }
    public class RoundedSalaryTransactionXns{
        public List<Xns> roundedSalaryTransactionXns;
    }
    public class RevenueSheriffXns{
        public List<Xns> revenueSheriffXns;
    }
    public class Status {
        public String status;
    }
    public class PartiesInCreditsAndDebits {
        public String partyName;	//SKY INFRA
    }
    public class SalaryThroughIMPSOrUPI{
        public List<Xns> salaryThroughIMPSOrUPIs;
    }
    public class salaryThroughIMPSOrMPAYOrCHQ{
        public List<Xns> salaryThroughIMPSOrMPAYOrCHQs;
    }
    public class ChequeNumberInSeriesXns{
        public List<Xns> chequeNumberInSeriesXns;
    }
    public class Count{
        public Integer count;
    }
    public class DebitEODBalanceXns{
        public List<Xns> debitEODBalanceXns;
    }
    public class CreditEODBalanceXns{
        public List<Xns> creditEODBalanceXns;
    }
    public class DepositsRelatedToGovtAgenciesXns{
        public List<Xns> depositsRelatedToGovtAgenciesXns;
    }
    public class CasinoRelatedXns{
        public List<Xns> casinoRelatedXns;
    }
    public class FinancialCommitmentRelatedXns{
        public List<Xns> financialCommitmentRelatedXns;
    }
    public class LargeValueCreditXns{
        public List<Xns> largeValueCreditXns;
    }
    public class RoundFigureXns{
        public List<Xns> roundFigureXns;
    }
    public class ChqReturnXns{
        public List<Xns> chqReturnXns;
    }
    public class PartiesInCreditsAndDebitsWhenCreditGreaterThanAMB{
        public List<Xns> partiesInCreditsAndDebitsWhenCreditGreaterThanAMBs;
    }
    public class CashDepositGreaterThanAMB{
        public List<Xns> cashDepositGreaterThanAMBs;
    }
    public class NeftRtgsGreaterThanAMB{
        public List<Xns> neftRtgsGreaterThanAMBs;
    }
    public class ChqWithdrawalOnHolidayXns{
        public List<Xns> chqWithdrawalOnHolidayXns;
    }
    public class UpiAboveThresholdXns{
        public List<Xns> upiAboveThresholdXns;
    }
    public class ImpsAboveThresholdXns{
        public List<Xns> impsAboveThresholdXns;
    }
    public class SalaryWithSameNarrationXns{
        public List<Xns> salaryWithSameNarrationXns;
    }
    public class MajorityRoundFigureXns{
        public List<Xns> majorityRoundFigureXns;
    }
    
    
    public class CombinedMonthlyDetails {
        public String monthName;	//Jun-22
        public String startDate;	//2022-06-01
    }
    
    public class AccountXns {
        public String accountNo;	//50200028575953
        public String accountType;	//
        public List<Xns> xns;
    }
    
    public class Xns {
        public String PerfiosGroup; // Actual Parameter Name: group
        public String PerfiosDate;	//2022-06-03 Actual Parameter Name: date
        public String chqNo;	//
        public String narration;	//50200031807870-TPT-BILL-SKY INFRA (Ref# 187597038)
        public Double amount;	//2500000
        public String category;	//Transfer from SKY INFRA
        public Double balance;	//2952895
        public String mode;
    }
    
    public class AdditionalBankingMonthlyDetails {
        public List<BankingMonthlyData1> MonthlyData1;
    }
    
    public class MonthlyData1 {
        public String monthName;	//Jun-22
        public Double otherTransfer;	//0
        public Double totalOtherTransfer;	//0
        public Double nonBusiness;	//0
        public Double totalNonBusiness;	//0
        public Double otherSupplier;	//25
        public Double totalOtherSupplier;	//2819830
        public Double inwardBouncesWithBankCharges;	//0
    }
    
    public class FedfinaMothlyData1{
        public String monthName;	//Jan-24
        public String belowMinBalPenalties;	//string
        public Double avgBalance;	//1.12
        public Double limitUtilization;	//1.12
        public Double inwardBounces;	//1
        public Double tradeCredits;	//1
        public Double totalTradeCredit;	//1
    }
    
    public class BankingMonthlyData1{
        public String monthName;
        public Double credits;
        public Double totalCredit;
        public Double debits;
        public Double totalDebit;
        public Double cashDepositPercent;
        public Double cashWithdrawalPercent;
        public Double inwBouncePercent;
        public Double inwTechBouncePercent;
        public Double inwNonTechBouncePercent;
        public Double outwBouncePercent;
        public Double avgOverdrawnDay;
        public Double inwardBounces;
        public Double bankCharges;
    }
    
    public class AdditionalFedfinaMonthlyDetails {
        public List<FedfinaMothlyData1> MonthlyData1;
    }
    
    public class AdditionalTransactionMonthlyDetails {
        public List<MonthlyData1> MonthlyData1;
    }
    
    public class AdditionalSummaryInfo {
        public List<SummaryInfo1> summaryInfo1;
    }
    
    public class SummaryInfo1 {
        public Double balAvgLatestThree;	//1565073.23
        public Double balMinLatestThree;	//225177
        public Double balMaxLatestThree;	//11000332
        public Double balAvgLatestSix;	//2991556.64
        public Double balMinLatestSix;	//225177
        public Double balMaxLatestSix;	//11000332
        public Double grossDebitLatestThree;	//31
        public Double totalGrossDebitLatestThree;	//30870953
        public Double cashWithdrawalLatestThree;	//0
        public Double totalCashWithdrawalLatestThree;	//0
        public Double chqIssuesLatestThree;	//29
        public Double totalChqIssuesLatestThree;	//31100746
        public Double inwChqBounceLatestThree;	//0
        public Double totalInwChqBounceLatestThree;	//0
        public Double debitsSCLatestThree;	//0
        public Double totalDebitsSCLatestThree;	//0
        public Double emiOrLoansLatestThree;	//4
        public Double totalEmiOrLoanLatestThree;	//42020
        public Double inwEMIBounceLatestThree;	//0
        public Double totalInwEMIBounceLatestThree;	//0
        public Double grossDebitLatestSix;	//75
        public Double totalGrossDebitLatestSix;	//44242940
        public Double cashWithdrawalLatestSix;	//0
        public Double totalCashWithdrawalLatestSix;	//0
        public Double chqIssuesLatestSix;	//70
        public Double totalChqIssuesLatestSix;	//44440513
        public Double inwChqBounceLatestSix;	//0
        public Double totalInwChqBounceLatestSix;	//0
        public Double debitsSCLatestSix;	//0
        public Double totalDebitsSCLatestSix;	//0
        public Double emiOrLoansLatestSix;	//7
        public Double totalEmiOrLoanLatestSix;	//79910
        public Double inwEMIBounceLatestSix;	//0
        public Double totalInwEMIBounceLatestSix;	//0
        public Double grossCreditLatestThree;	//13
        public Double totalGrossCreditLatestThree;	//31331686
        public Double cashDepositLatestThree;	//0
        public Double totalCashDepositLatestThree;	//0
        public Double chqDepositLatestThree;	//6
        public Double totalChqDepositLatestThree;	//19639343
        public Double outwChqBounceLatestThree;	//0
        public Double totalOutwChqBounceLatestThree;	//0
        public Double creditsSCLatestThree;	//0
        public Double totalCreditsSCLatestThree;	//0
        public Double loanDisbursalLatestThree;	//0
        public Double totalLoanDisbursalLatestThree;	//0
        public Double grossCreditLatestSix;	//23
        public Double totalGrossCreditLatestSix;	//44831686
        public Double cashDepositLatestSix;	//0
        public Double totalCashDepositLatestSix;	//0
        public Double chqDepositLatestSix;	//9
        public Double totalChqDepositLatestSix;	//23864343
        public Double outwChqBounceLatestSix;	//0
        public Double totalOutwChqBounceLatestSix;	//0
        public Double creditsSCLatestSix;	//0
        public Double totalCreditsSCLatestSix;	//0
        public Double loanDisbursalLatestSix;	//0
        public Double totalLoanDisbursalLatestSix;	//0
        public Double grossChargesLatestThree;	//0
        public Double totalGrossChargesLatestThree;	//0
        public Double inwChargesLatestThree;	//0
        public Double totalInwChargesLatestThree;	//0
        public Double outwChargesLatestThree;	//0
        public Double totalOutwChargesLatestThree;	//0
        public Double belowMinBalPenaltiesLatestThree;	//0
        public Double totalBelowMinBalPenaltyLatestThree;	//0
        public Double penalChargesLatestThree;	//0
        public Double totalPenalChargeLatestThree;	//0
        public Double interestChargesLatestThree;	//0
        public Double totalInterestChargedLatestThree;	//0
        public Double bankChargesLatestThree;	//0
        public Double totalBankChargeLatestThree;	//0
        public Double grossChargesLatestSix;	//0
        public Double totalGrossChargesLatestSix;	//0
        public Double inwChargesLatestSix;	//0
        public Double totalInwChargesLatestSix;	//0
        public Double outwChargesLatestSix;	//0
        public Double totalOutwChargesLatestSix;	//0
        public Double belowMinBalPenaltiesLatestSix;	//0
        public Double totalBelowMinBalPenaltyLatestSix;	//0
        public Double penalChargesLatestSix;	//0
        public Double totalPenalChargeLatestSix;	//0
        public Double interestChargesLatestSix;	//0
        public Double totalInterestChargedLatestSix;	//0
        public Double bankChargesLatestSix;	//0
        public Double totalBankChargeLatestSix;	//0
    } 
    
    public Error error;
	public class Error {
		public String code;	//TransactionNotCompleted
		public String message;	//The Perfios Transaction referred to by the Client has not been completed
	}
    
    public static PerfiosRetrieveReportResponseWrapper parse(String json){
        return (PerfiosRetrieveReportResponseWrapper) System.JSON.deserialize(json, PerfiosRetrieveReportResponseWrapper.class);
    }
    
}