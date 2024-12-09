public without sharing class KFSForLoanNdAdvController {
    transient public String recordId { get; set; }
    transient public String disbSchedule { get; set; }
    public LoanAppl__c loanApplRec { get; set; }
    transient public string rateofInter { get; set; }
    transient public decimal showFlotingCharge { get; set; }
    transient public decimal finalRate { get; set; }
    transient public decimal totalAmount { get; set; }
    //public string StaticContent { get; set; }
    public List<Applicant__c> applicantList { get; set; }
    public Decimal loanAmount { get; set; }
    public Decimal rateOfInterest { get; set; }
    public Decimal tenure { get; set; }
    public Decimal emi { get; set; }
    public Decimal InteresetRate { get; set; }
    transient public string Grievance { get; set; }
    transient public string Engagement { get; set; }
    public Decimal ProessFee { get; set; }
    public Decimal InsuranceFee { get; set; }
    transient public Decimal APRCal { get; set; }
    transient public string dateOfCheck { get; set; }
    transient public Decimal TotalFeeChar { get; set; }
    transient public Decimal TotalFeeCharForA { get; set; }
    transient public Decimal TotalFeeCharForB { get; set; }
    transient public Decimal totalDisAmount { get; set; }
    transient public list<ApplicantWrapper> AppWrapperList { get; set; }
    transient public list<ChargeWrapper> ChargeWrapperList { get; set; }
    transient public String CurrentDateTime { get; set; }
    transient public String CurrentDate { get; set; }
    transient public Decimal ImpactEMI { get; set; }
    transient public Decimal APRVAL { get; set; }
    //public List<RepaymentSchedule> scheduleList { get; set; }
    transient public String kfsEmail { get; set; }
    transient public String kfsPhone { get; set; }
    transient public Decimal ResetperiVal { get; set; }
    transient public Decimal ResetperiVal1 { get; set; }
    transient public Decimal newTenureVal { get; set; }
    public List<partnerFunding> partFun { get; set; }
    public List<RepaymentScheduleWrapper> result1 { get; set; }
    public static final double GUESS = (double) 0.1;
    public static Integer MAX_ITERATION_COUNT = 300;
    public static final double ABSOLUTE_ACCURACY = 0.0000001;
    transient public boolean showFloating { get; set; }
    transient public String CurrentDateTime1{get;set;}
    public KFSForLoanNdAdvController() {
        recordId = ApexPages.currentPage().getParameters().get('recordId');
        if (recordId == null) {
            recordId = 'a08C40000082ahBIAQ';
            System.debug('recordId ' + recordId);
        }
        loanApplRec = [
            SELECT
                id,
            	InsAmt__c,
                TotalLoanAmtInclInsurance__c,
                Final_Loan_Disbursal_Amount__c,
                FirstEMIDate__c,
                SimpleInterest__c,
                TotalCharges__c,
                LoanPLRRate__c,
                SpreadID__c,
                DisbursalType__c,
                EffectiveROI__c,
                tolabel(Repayment_Frequency__c),
                SanLoanAmt__c,
                SchmCode__c,
                Rate_Type_Floating_Flag__c,
                ProductSubType__c,
                EMIIcludingInsurance__c,
                Name,
                ReqLoanAmt__c,
                Loan_Tenure_Months__c,
                PropertyIdentified__c,
                Formatted_Login_Acceptance_Date__c,
                Product__c,
                BrchCode__c,
                BrchName__c,
                RMSMName__r.Name,
                RMSMEmployeeID__c,
                ChannelName__c,
                ChannelCode__c,
                ChanelNme__r.name,
                LoanPurpose__c,
            TotalIMDAmount__c
            FROM LoanAppl__c
            WHERE id = :recordId
            LIMIT 1
        ];
        loanApplRec.SanLoanAmt__c = loanApplRec.SanLoanAmt__c != null
            ? (loanApplRec.SanLoanAmt__c).setScale(0)
            : 0;
        ResetperiVal = loanApplRec.EffectiveROI__c + 0.25;
        if (loanApplRec.FirstEMIDate__c != null) {
            datetime mydate = loanApplRec.FirstEMIDate__c;
            Integer dayOfMonth = Integer.valueOf(mydate.format('dd'));
			String suffix;
            if (dayOfMonth == 1 || dayOfMonth == 21 || dayOfMonth == 31) {
                suffix = 'st';
            } else if (dayOfMonth == 2 || dayOfMonth == 22) {
                suffix = 'nd';
            } else if (dayOfMonth == 3 || dayOfMonth == 23) {
                suffix = 'rd';
            } else {
                suffix = 'th';
            }
			String dayWithSuffix = String.valueOf(dayOfMonth) + suffix;
            dateOfCheck = dayWithSuffix+' of each month';
            //string formateDate = mydate.format('dd-MMM-yyyy');
            //dateOfCheck = formateDate;
        }
        /*List<MasterData__c> chareMasRec = [
            SELECT Id, Engagement_clause__c, Grievance_clause__c, Product__c
            FROM MasterData__c
            WHERE Grievance_clause__c != '' OR Engagement_clause__c != ''
        ];
        for (MasterData__c record : chareMasRec) {
            if (
                record.Product__c.contains(loanApplRec.Product__c) &&
                record.Engagement_clause__c != ''
            ) {
                Engagement = record.Engagement_clause__c;
            }
            if (
                record.Product__c.contains(loanApplRec.Product__c) &&
                record.Grievance_clause__c != ''
            ) {
                Grievance = record.Grievance_clause__c;
            }
        }*/

        decimal loanPLR = loanApplRec.LoanPLRRate__c == null
            ? 0
            : loanApplRec.LoanPLRRate__c;
        decimal Spread = loanApplRec.SpreadID__c == null
            ? 0
            : loanApplRec.SpreadID__c;
        finalRate = loanPLR + Spread;

        decimal sanctionAmou = loanApplRec.TotalLoanAmtInclInsurance__c == null
            ? 0
            : (loanApplRec.TotalLoanAmtInclInsurance__c).setScale(0);
        decimal InterestAmou = loanApplRec.SanLoanAmt__c == null
            ? 0
            : (loanApplRec.SanLoanAmt__c).setScale(0);

        applicantList = [
            SELECT id, FullName__c, tolabel(ApplType__c)
            FROM Applicant__c
            WHERE
                LoanAppln__c = :recordId
                AND (ApplType__c = 'C'
                OR ApplType__c = 'p'  or ApplType__c = 'G')
        ];
        if (
            loanApplRec.DisbursalType__c == 'SINGLE' ||
            loanApplRec.product__c == 'Small Ticket LAP' ||
            loanApplRec.product__c == 'Loan Against Property'
        ) {
            disbSchedule = '100% upfront';
        } else if (loanApplRec.DisbursalType__c == 'MULTIPLE') { 
            List<MasterData__c> masterDataCha = [SELECT Id, Disbursement_Clause__c, type__c FROM MasterData__c WHERE type__c = :'Disbursement Clause' Limit 1];
            disbSchedule = masterDataCha[0].Disbursement_Clause__c;
        }
        if (loanApplRec.Rate_Type_Floating_Flag__c == 'Y') {
            rateofInter = 'Floating';
            showFloating=true;
            showFlotingCharge =  loanApplRec.LoanPLRRate__c !=null ? loanApplRec.LoanPLRRate__c + 0.25: 0.25 ;
        } else if (loanApplRec.Rate_Type_Floating_Flag__c == 'N') {
            rateofInter = 'Fixed';
            showFloating=false;
         }
        system.debug('lanCharges');
        //getStaticData();
        system.debug('lanCharges');
        List<LonaApplCharges__c> lanCharges = [
            SELECT
                id,
            	ActualAmt__c,
                ChargeCodeDesc__c,
                ChargeCodeID__c,
                GST_Amount__c,
                Amount__c,
                Processing_Fees__c
            FROM LonaApplCharges__c
            WHERE LoanApplication__c = :recordId
        ];
        system.debug('lanCharges' + lanCharges);
        List<string> chargeId = new List<string>();
        //Map<string, ChargeMaster__c> mapOfCharMas=new Map<string, ChargeMaster__c>();
        for (LonaApplCharges__c lanChar : lanCharges) {
            chargeId.add(lanChar.ChargeCodeID__c);
        }

        Map<string, MasterData__c> mapOfMasData = new Map<string, MasterData__c>();
        List<MasterData__c> masterDataCha = [
            SELECT Id, FinnoneVal__c, FinnoneCode__c, type__c, Payable_Type__c
            FROM MasterData__c
            WHERE type__c = :'Charge Master' AND FinnoneCode__c IN :chargeId
        ];
       if (masterDataCha.size() > 0) {
            for (MasterData__c masData : masterDataCha) {
                mapOfMasData.put(masData.FinnoneCode__c, masData);
            }
        }
        if (lanCharges.size() > 0) {
            AppWrapperList = new List<ApplicantWrapper>();
            integer forIndex = 0;
            TotalFeeCharForA = 0;
            TotalFeeCharForB = 0;
            for (LonaApplCharges__c lanChar : lanCharges) {
                if(lanChar.ChargeCodeID__c !='600254'){
                   forIndex++;
                    ApplicantWrapper appWrap = new ApplicantWrapper();
                    
                    appWrap.Index = forIndex;
                    if (mapOfMasData.containsKey(lanChar.ChargeCodeID__c)) {
                        MasterData__c masterRec = mapOfMasData.get(
                            lanChar.ChargeCodeID__c
                        );
                        if (lanChar.ChargeCodeID__c == '35') {
                            appWrap.chargeName = 'PROCESSING FEE';
                        } else {
                            appWrap.chargeName = masterRec.FinnoneVal__c != ''
                                ? masterRec.FinnoneVal__c
                                : lanChar.ChargeCodeDesc__c;
                        }
                        if (
                            masterRec.Payable_Type__c ==
                            'Payable to third party through RE'
                        ) {
                            appWrap.chargetype3Party = 'One Time';
                            if (lanChar.Amount__c != null) {
                                appWrap.chargeAmount3Party = Math.round(
                                    lanChar.Amount__c
                                );
                                TotalFeeCharForB += Math.round(
                                    lanChar.Amount__c);
                            }
                        } else {
                            appWrap.chargetype = 'One Time';
                            if (lanChar.Amount__c != null) {
                                appWrap.chargeAmount = Math.round(
                                    lanChar.Amount__c
                                );
                                TotalFeeCharForA += Math.round(
                                    lanChar.Amount__c);
                            }
                        }
                    } else {
                        if (lanChar.ChargeCodeID__c == '35') {
                            appWrap.chargeName = 'PROCESSING FEE';
                        } else {
                            appWrap.chargeName = lanChar.ChargeCodeDesc__c;
                        }
                        //appWrap.chargeName= lanChar.ChargeCodeDesc__c;
                        appWrap.chargetype3Party = '';
                        appWrap.chargeAmount3Party = null;
                        appWrap.chargetype = 'One Time';
                        if (lanChar.Amount__c != null) {
                            appWrap.chargeAmount = Math.round(lanChar.Amount__c);
                            TotalFeeCharForA += Math.round(
                                    lanChar.Amount__c);
                        }
                    }
                    AppWrapperList.add(appWrap); 
                }
            }
        }
        if(loanApplRec.InsAmt__c !=null){
            ApplicantWrapper appWrap = new ApplicantWrapper();
            appWrap.Index= AppWrapperList.size()+1;
            appWrap.chargetype3Party = 'One Time';  
            appWrap.chargeName = 'INSURANCE CHARGES';
            appWrap.chargeAmount3Party = loanApplRec.InsAmt__c != null ? Math.round( loanApplRec.InsAmt__c) : null;
            AppWrapperList.add(appWrap); 
            TotalFeeCharForB += appWrap.chargeAmount3Party;
        }
        /*if(loanApplRec.TotalIMDAmount__c !=null){
            ApplicantWrapper appWrap = new ApplicantWrapper();
            appWrap.Index= AppWrapperList.size()+1;
            appWrap.chargetype = 'One Time';  
            appWrap.chargeName = 'IMD CHARGES';
            appWrap.chargeAmount = loanApplRec.TotalIMDAmount__c != null ? Math.round( loanApplRec.TotalIMDAmount__c) : null;
            AppWrapperList.add(appWrap); 
            TotalFeeCharForA += appWrap.chargeAmount;
        }*/
        
        loanAmount = Math.round(loanApplRec.TotalLoanAmtInclInsurance__c);

        rateOfInterest = loanApplRec.EffectiveROI__c != null
            ? loanApplRec.EffectiveROI__c
            : 0;
        tenure = loanApplRec.Loan_Tenure_Months__c != null
            ? loanApplRec.Loan_Tenure_Months__c
            : 0;
        emi = loanApplRec.EMIIcludingInsurance__c != null
            ? (loanApplRec.EMIIcludingInsurance__c).setScale(0)
            : 0;
       	//MAX_ITERATION_COUNT = Math.round(tenure);
        //scheduleList = calculateRepaymentSchedule();
        result1 = getDefaultCalculation1(loanApplRec.TotalLoanAmtInclInsurance__c, emi,tenure,rateOfInterest);
        if (AppWrapperList.size() > 0) {
            decimal totalVal = 0;
            TotalFeeCharForA = TotalFeeCharForA != null ? TotalFeeCharForA : 0;
            TotalFeeCharForB = TotalFeeCharForB != null ? TotalFeeCharForB : 0;
            //TotalFeeChar = Math.round(loanApplRec.TotalCharges__c);
            TotalFeeChar = Math.round(TotalFeeCharForB + TotalFeeCharForA);
        }
        decimal totalcharge1 = TotalFeeCharForA == null ? 0 : TotalFeeCharForA;
        decimal totalcharge2 = TotalFeeCharForB == null ? 0 : TotalFeeCharForB;
        totalDisAmount = (loanApplRec.TotalLoanAmtInclInsurance__c -
            totalcharge1 - totalcharge2).setScale(0);
       // totalDisAmount=loanApplRec.Final_Loan_Disbursal_Amount__c !=null ? (loanApplRec.Final_Loan_Disbursal_Amount__c).setScale(0): null;
        totalAmount = (sanctionAmou + InteresetRate).setScale(0);
        List<decimal> monthlyPayment = new List<decimal>();

        setDateTime();
        ImpactEMI = Math.Ceil(
            calculateEMI(
                loanApplRec.TotalLoanAmtInclInsurance__c,
                rateOfInterest + 0.25,
                Integer.valueOf(tenure)
            )
        );
        List<MasterData__c> masRecForCharges = [
            SELECT
                Id,
                DescriptionOfChargeAsPerFedfinaKFS__c,
                ValuesOfChargeKFS__c,
                Product__c
            FROM MasterData__c
            WHERE
                Product__c = :loanApplRec.Product__c
                AND Type__c = 'KFS Contingent Charges' order by Sequence__c
        ];
        system.debug('masRecForCharges' + masRecForCharges);
        Integer sequence = 1;
        ChargeWrapperList = new List<ChargeWrapper>();
        for (MasterData__c record : masRecForCharges) {
            ChargeWrapper charRec = new ChargeWrapper();
            charRec.Index = sequence;
            charRec.valueOfCharge = record.ValuesOfChargeKFS__c;
            charRec.DecsOfCharge = record.DescriptionOfChargeAsPerFedfinaKFS__c;
            charRec.isBold = record.DescriptionOfChargeAsPerFedfinaKFS__c.contains('Penal Charges');
            ChargeWrapperList.add(charRec);
            sequence++;
        }
        List<MasterData__c> emailForKfs = [
            SELECT Id, KFS_customer_Email__c, phone__c,Engagement_clause__c, Grievance_clause__c
            FROM MasterData__c
            WHERE Name = :'Customer Contact Details KFS'
        ];
        if (emailForKfs.size() > 0) {
            kfsEmail = emailForKfs[0].KFS_customer_Email__c;
            kfsPhone = emailForKfs[0].phone__c;
            Grievance = emailForKfs[0].Grievance_clause__c;
            Engagement = emailForKfs[0].Engagement_clause__c;
        }
        newTenureVal = Math.Ceil(
            calculateTenure(
                ResetperiVal,
                loanAmount,
                loanApplRec.EMIIcludingInsurance__c
            )
        );
        partFun = new List<partnerFunding>();
        List<MasterData__c> dataForPartnerRE = [
            SELECT
                Id,
                Active_funding_flag__c,
                Funding__c,
                product__c,
                type__c,
                Partner_RE_Name__c
            FROM MasterData__c
            WHERE
                product__c = :loanApplRec.Product__c
                AND Type__c = 'Partner Funding'
                AND Active_funding_flag__c = :'Yes'
        ];
        if (dataForPartnerRE.size() > 0) {
            for (MasterData__c FunRec : dataForPartnerRE) {
                partnerFunding parFuRecRec = new partnerFunding();
                decimal val = 100 - FunRec.Funding__c;
                parFuRecRec.Name =
                    'Fedbank Financial Services Limited, funding proportion- ' +
                    val +
                    ' Funding % Of Partner RE';
                parFuRecRec.PartnerName =
                    FunRec.Partner_RE_Name__c +
                    ', funding proportion- ' +
                    FunRec.Funding__c +
                    '%';
                parFuRecRec.Roi = string.valueOf(loanApplRec.EffectiveROI__c) +'%';
                partFun.add(parFuRecRec);
            }
        }else{
            partnerFunding parFuRecRec = new partnerFunding();
            parFuRecRec.Name='NA';
            parFuRecRec.PartnerName='NA';
            parFuRecRec.Roi='NA';
            partFun.add(parFuRecRec);
        }
        
        for (RepaymentScheduleWrapper record : result1) {
            monthlyPayment.add(record.instalment.setScale(0, System.RoundingMode.HALF_UP));
        }
        APRVAL = generateCashFlows(
            monthlyPayment,
            totalDisAmount,
            Integer.ValueOf(loanApplRec.Loan_Tenure_Months__c)
        );
    }

    /*public void getStaticData() {
        try {
            StaticResource myHtmlResource = [
                SELECT Body
                FROM StaticResource
                WHERE Name = 'KFSContingentCharges'
            ];
            Blob htmlBlob = myHtmlResource.Body;
            StaticContent = htmlBlob.toString();
        } catch (Exception e) {
        }
    }*/
    /*public class RepaymentSchedule {
        public Integer instalmentNo { get; set; }
        public Decimal outstandingPrincipal { get; set; }
        public Decimal principal { get; set; }
        public Decimal interest { get; set; }
        public Decimal instalment { get; set; }*/

        /*public RepaymentSchedule(
            Integer instalmentNo,
            Decimal outstandingPrincipal,
            Decimal principal,
            Decimal interest,
            Decimal instalment
        ) {
            this.instalmentNo = instalmentNo;
            this.outstandingPrincipal = outstandingPrincipal;
            this.principal = principal;
            this.interest = interest;
            this.instalment = instalment;
        }
    }*/
    /*private List<RepaymentSchedule> calculateRepaymentSchedule() {
        List<RepaymentSchedule> schedules = new List<RepaymentSchedule>();
        Decimal monthlyRate = rateOfInterest / 1200;
        Decimal outstandingPrincipal = Math.round(loanAmount);
        for (Integer i = 1; i <= tenure; i++) {
            if (i == 21) {
                System.debug('outstandingPrincipal==' + outstandingPrincipal);
                System.debug(
                    'interest==' +
                    (outstandingPrincipal *
                    rateOfInterest /
                    1200)
                );
            }
            Decimal interest = Math.round(
                outstandingPrincipal * rateOfInterest / 1200
            );
            Decimal principal = Math.round(emi - interest);
           schedules.add(
                new RepaymentSchedule(
                    i,
                    outstandingPrincipal.setScale(0),
                    principal.setScale(0),
                    interest.setScale(0),
                    emi
                )
            );
            //outstandingPrincipal -= Math.floor(principal);
            outstandingPrincipal = Math.round(outstandingPrincipal - principal);
            //System.debug('Outstanding '+i +': ' + outstandingPrincipal);
            //outstandingPrincipal=Math.round(outstandingPrincipal);
            if (outstandingPrincipal < 0) {
                break;
            }
        }
        decimal totalIntereset = 0;
        for (RepaymentSchedule record : schedules) {
            totalIntereset += record.interest;
        }
        InteresetRate = totalIntereset;
        return schedules;
    }*/

    public void setDateTime() {
        DateTime dt = Datetime.now();
        DateTime currentDateTimePlus30Days = dt.addDays(30);
        CurrentDate = system.Now().format('dd-MMM-yyyy');
        CurrentDateTime = currentDateTimePlus30Days.format('dd-MMM-yyyy');
        CurrentDateTime1=system.Now().format('dd-MMM-yyyy')+', '+system.Now().format('h:mm a');
    }
    public static Decimal calculateEMI(
        Decimal principal,
        Decimal annualInterestRate,
        Integer tenureMonths
    ) {
        Decimal monthlyInterestRate = annualInterestRate / 12 / 100;
        Double monthlyInterestRateDouble = monthlyInterestRate.doubleValue();
        Double power = Math.pow(1 + monthlyInterestRateDouble, tenureMonths);
        Decimal powerDecimal = Decimal.valueOf(power);
        Decimal emi =
            (principal * monthlyInterestRate * powerDecimal) /
            (powerDecimal - 1);

        return emi;
    }

    public static decimal calculateTenure(
        decimal roi,
        decimal loanAmount,
        decimal emi
    ) {
        Double monthlyInterestRate = roi / 12 / 100;
        Double numerator = emi / (loanAmount * monthlyInterestRate);
        Double tenureMonths=0;
        if(numerator > 1){
            tenureMonths =
            Math.log(numerator / (numerator - 1)) /
            Math.log(1 + monthlyInterestRate);
        }
        return tenureMonths;
    }
    class partnerFunding {
        public String Name { get; set; }
        public String PartnerName { get; set; }
        public string Roi { get; set; }
    }
    public List<RepaymentScheduleWrapper> getDefaultCalculation1(decimal sanctionAmount, decimal emi,decimal tenure,decimal rateOfInterest) {
        try {
            List<RepaymentScheduleWrapper> result = new List<RepaymentScheduleWrapper>();
            List<RepaymentScheduleWrapper> result1 = new List<RepaymentScheduleWrapper>();
            Decimal Balance = sanctionAmount.round();
            Decimal mothlyInterestCalcNumber = 1200;
            Decimal monthlyInterestRate = rateOfInterest / mothlyInterestCalcNumber;
            Decimal totalPrincipal = 0;
            Decimal totalInterest = 0;
            Decimal totalInstalment = 0;
            Decimal DiffInPrincipal = 0;
            for (Integer i = 1; i <= tenure; i++) {
                RepaymentScheduleWrapper wrapper = new RepaymentScheduleWrapper();
                wrapper.instalmentNumber = i;
                wrapper.outstandingPrincipal = Balance != null
                    ? Balance
                    : 0;
                wrapper.instalment = emi;
                wrapper.interest = (Balance * monthlyInterestRate) != null
                    ? (Balance * monthlyInterestRate).round(RoundingMode.HALF_UP)
                    : 0;
                wrapper.principal = (wrapper.instalment - wrapper.interest) !=
                    null
                    ? (wrapper.instalment - wrapper.interest)
                    : 0;

                totalPrincipal = totalPrincipal + wrapper.principal;
                totalInterest = totalInterest + wrapper.interest;
                totalInstalment = totalInstalment + wrapper.instalment;
                Balance = (Balance - wrapper.principal).round(RoundingMode.HALF_UP);
                if (i == tenure) {
                    DiffInPrincipal = (sanctionAmount - totalPrincipal).round(RoundingMode.HALF_UP);
                    if (DiffInPrincipal > 0) {
                        wrapper.instalment = (wrapper.instalment +
                            DiffInPrincipal);
                        wrapper.principal = (wrapper.principal +
                            DiffInPrincipal);
                    } else {
                        wrapper.instalment = (wrapper.instalment +
                            (DiffInPrincipal));
                        wrapper.principal = (wrapper.principal +
                            (DiffInPrincipal));
                    }
                }
                result.add(wrapper);
            }
            result1 = result;
            /*for(RepaymentScheduleWrapper appWrap: result){
                RepaymentScheduleWrapper wrapper = new RepaymentScheduleWrapper();
                
                wrapper.instalmentNumber=appWrap.instalmentNumber.round();
                wrapper.outstandingPrincipal=appWrap.outstandingPrincipal.round();
                wrapper.principal=appWrap.principal.round();
                wrapper.interest=appWrap.interest.round();
                wrapper.instalment=appWrap.instalment.round();
                result1.add(wrapper);
            }*/
            InteresetRate = totalInterest;
            System.debug(
                'Total Calc : ' +
                    totalPrincipal +
                    ' : ' +
                    totalInterest +
                    ' : ' +
                    totalInstalment
            );
            system.debug('resultresultresult' + result);
            return result1;
        } catch (Exception ex) {
            return null;
        }
    }

    public static Decimal generateCashFlows(
        List<decimal> monthlyPayment,
        decimal netDisbursementAmount,
        integer loanPeriodMonths
    ) {
        List<Decimal> cashFlows = new List<Decimal>();
        Decimal apr;
        Decimal irrMonthly;
        cashFlows.add(-netDisbursementAmount);

        cashFlows.addAll(monthlyPayment);
        irrMonthly = calculateIRR(cashFlows, GUESS, 'a08C40000082ahBIAQ');
        apr = (irrMonthly * 12 * 100);
        apr = apr.setScale(2, RoundingMode.HALF_UP);
        return apr;
    }

    private static List<Decimal> generateMonthlyPayments(
        List<Decimal> monthlyPayment,
        Integer periods
    ) {
        List<Decimal> payments = new List<Decimal>();
        for (Integer i = 1; i <= periods; i++) {
            payments.add(
                monthlyPayment[i - 1].setScale(0, System.RoundingMode.HALF_UP)
            );
        }
        return payments;
    }
    private static Decimal calculateIRR(
        List<Decimal> cashFlows,
        double guess,
        string loanAppId
    ) {
        Decimal irr = guess;
        try {
            Decimal npv = 0;
            Decimal npvDerivative = 0;
            Decimal irrDelta = 0;
            Integer iterations = 0;

            while (iterations < MAX_ITERATION_COUNT) {
                npv = 0;
                npvDerivative = 0;

                for (Integer i = 0; i < cashFlows.size(); i++) {
                    Decimal base = 1 + irr;
                    npv += cashFlows[i] / Math.pow(base.doubleValue(), i);

                    if (i > 0) {
                        Decimal denominator = Math.pow(
                            base.doubleValue(),
                            i + 1
                        );
                        npvDerivative -= i * cashFlows[i] / denominator;
                    }
                }

                irrDelta = npv / npvDerivative;
                irr -= irrDelta;
                iterations++;
                if (Math.abs(irrDelta) <= ABSOLUTE_ACCURACY) {
                    break;
                }
            }

            return irr;
        } catch (Exception ex) {
            System.debug('An error occurred: ' + ex.getMessage());
            return 0;
        }
    }
    class ApplicantWrapper {
        public Integer Index { get; set; }
        public String chargeName { get; set; }
        public String chargetype { get; set; }
        public Decimal chargeAmount { get; set; }
        public String chargetype3Party { get; set; }
        public Decimal chargeAmount3Party { get; set; }
    }
    class ChargeWrapper {
        public Integer Index { get; set; }
        public String valueOfCharge { get; set; }
        public String DecsOfCharge { get; set; }
        public Boolean isBold { get; set; }
    }
    public class RepaymentScheduleWrapper {
        public Decimal principal { get; set; }
        public Decimal interest { get; set; }
        public Decimal instalment { get; set; }
        public Decimal outstandingPrincipal { get; set; }
        public Decimal instalmentNumber { get; set; }
    }
}