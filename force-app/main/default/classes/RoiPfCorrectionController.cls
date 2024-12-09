public without sharing class RoiPfCorrectionController {
    @AuraEnabled
    public static RoiPfCorrWpr getRoiPfData(
        string loanAppid,
        string loanAppealId,
        string actionType
    ) {
        try {
            LoanAppl__c laonApp = [
                SELECT
                    tolabel(Rate_Type_Floating_Flag__c),
                    EffectiveROI__c,
                    RevisedROI__c,
                    LeadROI__c,
                    PFInPercentage__c,
                    BrchCode__c,
                    BranchTier__c,
                    BrchName__c,
                    City__c,
                    SanLoanAmt__c,
                    Product__c,
                    PricingApprovalApplicable__c
                FROM LoanAppl__c
                WHERE Id = :loanAppid
                LIMIT 1
            ];
            //calculateRoiSum(Date.today());
            list<String> productTypeList = new List<String>();
            productTypeList.add(laonApp.Product__c);
            List<BRE__c> breRec = [
                SELECT Id, RAACROI__c
                FROM BRE__c
                WHERE
                    IsLatest__c = TRUE
                    AND EligibilityType__c = 'Application'
                    AND LoanAppl__c = :loanAppid
                LIMIT 1
            ];
            Decimal raacRoi = 0;
            if (breRec.size() > 0) {
                raacRoi = breRec[0].RAACROI__c != null
                    ? breRec[0].RAACROI__c
                    : 0;
            }
            List<LonaApplCharges__c> charges = [
                SELECT Id, LoanApplication__c, ChargeCodeID__c, PF__c
                FROM LonaApplCharges__c
                WHERE LoanApplication__c = :loanAppid AND ChargeCodeID__c = '35'
                LIMIT 1
            ];
            Decimal raacPF = 0;
            if (charges.size() > 0) {
                raacPF = charges[0].PF__c != null ? charges[0].PF__c : 0;
            }

            List<RoiTracker__c> roiTrackerList = new List<RoiTracker__c>();
            Decimal ratedRoiBranch = 0;
            Decimal ratedRoiRegion = 0;
            Decimal ratedRoiPanInd = 0;
            final Map<Integer, String> monthMap = new Map<Integer, String>{1=>'JAN', 2=>'FEB', 3=>'MAR', 4=>'APR', 5=>'MAY', 6=>'JUN', 7=>'JUL', 8=>'AUG', 9=>'SEP', 10=>'OCT', 11=>'NOV',12=>'DEC'};
            String month = monthMap.get(Date.today().month());
            String year = String.ValueOf(Date.today().year());
            roiTrackerList = [
                SELECT
                    Id,
                    RoiType__c,
                    ZonalCode__c,
                    Sum_DisAmnt_x_ROI__c,
                    Sum_DisAmnt_x_PF__c,
                    Sum_of_Disbursment_Amount__c,
                    Last_Calculated_Date__c,
                    BranchCode__c
                FROM RoiTracker__c where Month__c =: month AND Year__c =: year
            ];
            if (!roiTrackerList.isEmpty()) {
                for (RoiTracker__c roiTrckr : roiTrackerList) {
                    decimal sumOfdisAmt = roiTrckr.Sum_of_Disbursment_Amount__c != null
                        ? roiTrckr.Sum_of_Disbursment_Amount__c
                        : 0;
                    decimal snLoanAmt = laonApp.SanLoanAmt__c != null
                        ? laonApp.SanLoanAmt__c
                        : 0;
                    decimal sumOfdisxROIAmt = roiTrckr.Sum_DisAmnt_x_ROI__c != null
                        ? roiTrckr.Sum_DisAmnt_x_ROI__c
                        : 0;
                        if(sumOfdisxROIAmt > 0 && sumOfdisAmt > 0){
                    if (
                        roiTrckr.RoiType__c == 'Branch' &&
                        roiTrckr.BranchCode__c == laonApp.BrchCode__c
                    ) {
                        try{
                        //ratedRoiBranch =((sumOfdisAmt *  snLoanAmt ) / (sumOfdisxROIAmt * 100)).setScale(2, System.RoundingMode.HALF_UP) ;
                        ratedRoiBranch = ((sumOfdisxROIAmt / sumOfdisAmt) * 100)
                        .setScale(2, System.RoundingMode.HALF_UP);
                        }catch(Exception e){
                            System.debug('Divide by zero error: ' + e.getMessage());
                        }
                    }
                    if (roiTrckr.RoiType__c == 'India') {
                        try{
                        //ratedRoiPanInd =  ((sumOfdisAmt *  snLoanAmt ) / (sumOfdisxROIAmt * 100) ).setScale(2, System.RoundingMode.HALF_UP);
                        ratedRoiPanInd = ((sumOfdisxROIAmt / sumOfdisAmt) * 100)
                            .setScale(2, System.RoundingMode.HALF_UP);
                        }catch(Exception e){
                            System.debug('Divide by zero error: ' + e.getMessage());
                        }
                    }

                        }
                }
            }
            RoiPfCorrWpr rw = new RoiPfCorrWpr();
            rw.RateType = laonApp != null &&
                laonApp.Rate_Type_Floating_Flag__c != null
                ? laonApp.Rate_Type_Floating_Flag__c
                : '';
            rw.RaacROI = raacRoi; //laonApp !=null && laonApp.LeadROI__c != null ? laonApp.LeadROI__c : 0;
            rw.RaacPF = raacPF; //laonApp !=null && laonApp.PFInPercentage__c != null ? laonApp.PFInPercentage__c : 0;
            rw.EffRoiUw = laonApp != null &&
                laonApp.RevisedROI__c != null
                ? laonApp.RevisedROI__c
                : 0;
            rw.RevRoiMaxVal = raacRoi > rw.EffRoiUw ? raacRoi : rw.EffRoiUw;
            rw.IsPricingApplicable = 'Y'; //laonApp.PricingApprovalApplicable__c != null ? laonApp.PricingApprovalApplicable__c : 'N';
            rw.BranchRoi = ratedRoiBranch;
            rw.PanRoi = ratedRoiPanInd;
            rw.LoanAppId = loanAppid;
            rw.RegionRoi = 0;
            if (actionType == 'Create') {
                rw.RevRoi = rw.RevRoiMaxVal; //0;
                rw.RevPf = (rw.RaacPF != null ||
                    rw.RaacPF != 0)
                    ? rw.RaacPF
                    : null;
                rw.RevPfStr = '';
                rw.ApproverId = '';
                rw.RecomenderId = '';
                rw.RationalComment = '';
                rw.RecAppComments = '';
                rw.ApproverLevel = 0;
                rw.LoanAppealId = '';
                rw.Status = 'New';
                rw.RecTypeId = Schema.SObjectType.LoanAppeal__c.getRecordTypeInfosByName()
                    .get('Roi Pf Correction')
                    .getRecordTypeId();
            } else if (actionType == 'getOlder') {
                LoanAppeal__c loanAppeallList = new LoanAppeal__c();
                loanAppeallList = [
                    SELECT
                        Id,
                        Name,
                        RecordTypeId,
                        CreatedDate,
                        Recommender__r.Name,
                        Approver__r.Name,
                        Status__c,
                        LoanAppl__c,
                        Comments__c,
                        OwnerName__c,
                        LAN__c,
                        Recommender__c,
                        Approver__c,
                        ApproverLevel__c,
                        (
                            SELECT
                                Id,
                                SalesComments__c,
                                Comments__c,
                                CreatedDate,
                                LoanAppeal__c,
                                Revised_ROI__c,
                                Revised_PF__c,
                                Recomender__c,
                                Recomender__r.Name,
                                Recomended_To__c,
                                Recomended_To__r.Name
                            FROM Loan_Appeal_Items__r
                        )
                    FROM LoanAppeal__c
                    WHERE
                        Id = :loanAppealId
                        AND RecordType.name = 'Roi Pf Correction'
                    LIMIT 1
                ];

                List<LoanAppealItem__c> applItemList = new List<LoanAppealItem__c>();
                applItemList = loanAppeallList.Loan_Appeal_Items__r;
                List<applItem> appItemList = new List<applItem>();
                if (!applItemList.isEmpty()) {
                    for (LoanAppealItem__c apitm : applItemList) {
                        applItem appItm = new applItem();
                        appItm.RecomeddedTo = apitm.Recomended_To__r.Name;
                        appItm.RecomendedBy = apitm.Recomender__r.Name; // UserInfo.getUserName();
                        appItm.RevPF = apitm.Revised_PF__c == 0
                            ? 0
                            : apitm.Revised_PF__c;
                        appItm.RevPfStr = apitm.Revised_PF__c == 0
                            ? '0'
                            : String.valueOf(apitm.Revised_PF__c);
                        appItm.RevRoi = apitm.Revised_ROI__c;
                        appItm.Id = apitm.Id;
                        appItm.Comment = apitm.SalesComments__c;
                        appItm.RecAppComment = apitm.Comments__c;
                        appItm.CreatedDate = apitm.CreatedDate;

                        appItemList.add(appItm);
                    }
                }
                //rw.RevRoi = 0;
                //rw.RevPf = 0;
                rw.ApproverId = loanAppeallList.Approver__c;
                rw.RecomenderId = loanAppeallList.Recommender__c;
                rw.RationalComment = '';
                rw.RecAppComments = '';
                rw.ApproverLevel = loanAppeallList.ApproverLevel__c;
                rw.LoanAppealId = loanAppeallList.Id;
                rw.Status = loanAppeallList.Status__c;
                rw.RecTypeId = loanAppeallList.RecordTypeId;
                rw.ApplItemList = appItemList;
            }

            system.debug('final val ' + rw);
            return rw;
        } catch (Exception e) {
            System.debug(
                'error message and line number ' +
                    e.getMessage() +
                    ' line ' +
                    e.getLineNumber()
            );
            throw new AuraHandledException(e.getMessage());
        }
    }
    public static void calculateRoiSum(Date todayDate) {
        List<AggregateResult> loanAppList = new List<AggregateResult>();
        final Map<Integer, String> monthMap = new Map<Integer, String>{1=>'JAN', 2=>'FEB', 3=>'MAR', 4=>'APR', 5=>'MAY', 6=>'JUN', 7=>'JUL', 8=>'AUG', 9=>'SEP', 10=>'OCT', 11=>'NOV',12=>'DEC'};
        String month = monthMap.get(todayDate.month());
        String year = String.ValueOf(todayDate.year());
        Map<string, RoiTracker__c> roiBranchMap = new Map<string, RoiTracker__c>();
        List<RoiTracker__c> roiTrackerList = new List<RoiTracker__c>();
        roiTrackerList = [
            SELECT
                Id,
                RoiType__c,
                ZonalCode__c,
                Sum_DisAmnt_x_ROI__c,
                Sum_DisAmnt_x_PF__c,
                Sum_of_Disbursment_Amount__c,
                Last_Calculated_Date__c,
                BranchCode__c
            FROM RoiTracker__c where Month__c =: month AND Year__c =: year
        ];
        datetime lastUpdateddate;
        if (!roiTrackerList.isEmpty() || roiTrackerList.size() > 0) {
            lastUpdateddate = roiTrackerList[0].Last_Calculated_Date__c;
        }
        //LAK-9983
        RoiTracker__c indRoiTracker;
        if (!roiTrackerList.isEmpty() && roiTrackerList.size() > 0) {
            for (RoiTracker__c roiTrk : roiTrackerList) {
                if (roiTrk.BranchCode__c != null) {
                    if (roiBranchMap.containsKey(roiTrk.BranchCode__c)) {
                        roiBranchMap.put(roiTrk.BranchCode__c, roiTrk);
                    } else if (roiTrk.RoiType__c == 'India') {
                        //roiBranchMap.put(roiTrk.BranchCode__c, new List<RoiTracker__c>{roiTrk});
                        indRoiTracker = roiTrk;
                    }
                }
            }
        }

        Map<string, AggregateResultWrapper> branchLoanMap = new Map<string, AggregateResultWrapper>();
        Date startDate = todayDate.toStartOfMonth();
        // List<AggregateResultWrapper> wrapperList = new  List<AggregateResultWrapper> ();
        //loanAppList =  [SELECT   sum(SanLoanAmt__c) disxroiLnAmt, sum(EffectiveROI__c ) EffRoi,BrchCode__c  FROM LoanAppl__c  WHERE SanLoanAmt__c != null AND EffectiveROI__c != null  AND CreatedDate >: lastUpdateddate AND BrchCode__c != null group By BrchCode__c  ];
        String queyString = 'SELECT sum(DisAmntXpf__c) dispfLnAmt,sum(DisAmntXroi__c) disroiLnAmt, sum(DisbursedAmount__c ) disLonAmt,BrchCode__c  FROM LoanAppl__c  WHERE DisbursedAmount__c != null AND DisbursementDate__c !=null AND EffectiveROI__c != null AND BrchCode__c != null AND DisbursementDate__c >=: startDate';
        if (lastUpdateddate != null) {
            queyString += ' AND FinnSubDtTime__c >: lastUpdateddate group By BrchCode__c';
        } else {
            queyString += ' group By BrchCode__c';
        }
        //loanAppList =  [SELECT sum(DisAmntXroi__c) disroiLnAmt, sum(DisbursedAmount__c ) disLonAmt,BrchCode__c  FROM LoanAppl__c  WHERE DisbursedAmount__c != null AND EffectiveROI__c != null  AND DisbursementDate__c >: lastUpdateddate AND BrchCode__c != null group By BrchCode__c  ];
        loanAppList = Database.query(queyString);
        system.debug('loanAppList :: ' + loanAppList);
        if (!loanAppList.isEmpty() && loanAppList.Size() > 0) {
            for (AggregateResult ln : loanAppList) {
                //   branchLoanMap.put(ln.BrchCode__c, ln);
                String branchCode = (String) ln.get('BrchCode__c');
                Decimal disroiLnAmt = (Decimal) ln.get('disroiLnAmt');
                Decimal disLonAmt = (Decimal) ln.get('disLonAmt');
                Decimal dispfLnAmt = (Decimal) ln.get('dispfLnAmt');

                // Create an object or a list of values as needed
                // Here, I'm using a simple wrapper class to store the values
                AggregateResultWrapper wrapper = new AggregateResultWrapper(
                    disroiLnAmt,
                    dispfLnAmt,
                    disLonAmt,
                    branchCode
                );
                // wrapperList.add(wrapper);
                branchLoanMap.put(branchCode, wrapper);
            }
        }

        List<RoiTracker__c> roiTrackerUpdateList = new List<RoiTracker__c>();
        /*if(!branchLoanMap.keySet().isEmpty()){
            
            
            if(!roiTrackerList.isEmpty() ){
                for (RoiTracker__c rt : roiTrackerList) {
                    RoiTracker__c roiTr = new RoiTracker__c();
                    if(rt.RoiType__c == 'Branch'){
                        roiTr = rt;
                        if(branchLoanMap.get(rt.BranchCode__c) != null){
                            roiTr.Sum_DisAmnt_x_ROI__c += branchLoanMap.get(rt.BranchCode__c).disxroiLnAmt  ;
                        }
                        if(branchLoanMap.get(rt.BranchCode__c) != null){
                            roiTr.Sum_of_Disbursment_Amount__c += branchLoanMap.get(rt.BranchCode__c).EffRoi ;
                        }
                        roiTr.Last_Calculated_Date__c = system.now();
                        roiTrackerUpdateList.add(roiTr);
                        
                        
                    }else  if(rt.RoiType__c == 'Zone'){
                        
                    }else  if(rt.RoiType__c == 'India'){
                        
                        
                    }
                    
                }
            }else{*/

        Decimal disbAmtROIPan = 0;
        Decimal disbAmtPFPan = 0;
        Decimal disAmtSum = 0;
        String branchCode = '';
        if (!branchLoanMap.keySet().isEmpty()) {
            for (string br : branchLoanMap.keySet()) {
                RoiTracker__c roiTr = roiBranchMap.get(br);
                if (roiTr == null) {
                    roiTr = new RoiTracker__c(
                        RoiType__c = 'Branch',
                        Sum_DisAmnt_x_ROI__c = 0,
                        Sum_DisAmnt_x_PF__c =0,
                        Month__c = month,
                        Year__c = year,
                        Sum_of_Disbursment_Amount__c = 0
                    );
                }
                // for Branch
                //roiTr.RoiType__c = 'Branch';
                roiTr.BranchCode__c = br;
                roiTr.Sum_DisAmnt_x_ROI__c += branchLoanMap.get(br).disxroiLnAmt;
                roiTr.Sum_DisAmnt_x_PF__c += branchLoanMap.get(br).disxPFLnAmt;
                disbAmtROIPan = disbAmtROIPan + branchLoanMap.get(br).disxroiLnAmt;
                disbAmtPFPan = disbAmtPFPan + branchLoanMap.get(br).disxPFLnAmt;
                roiTr.Sum_of_Disbursment_Amount__c += branchLoanMap.get(br).sumDisAmt;
                disAmtSum = disAmtSum + branchLoanMap.get(br).sumDisAmt;
                roiTr.Last_Calculated_Date__c = system.now();
                roiTrackerUpdateList.add(roiTr);
            }
        }

        if (disbAmtROIPan != null && disAmtSum != null) {
            //RoiTracker__c roiTr = new RoiTracker__c();
            // for India
            if(indRoiTracker == null ){
                indRoiTracker = new RoiTracker__c(
                    RoiType__c = 'India',
                    Sum_DisAmnt_x_ROI__c = 0,
                    Sum_DisAmnt_x_PF__c = 0,
                    Month__c = month,
                    Year__c = year,
                    Sum_of_Disbursment_Amount__c = 0
            );

            }
            indRoiTracker.RoiType__c = 'India';
            indRoiTracker.Sum_DisAmnt_x_ROI__c += disbAmtROIPan;
            indRoiTracker.Sum_DisAmnt_x_PF__c += disbAmtPFPan;
            indRoiTracker.Sum_of_Disbursment_Amount__c += disAmtSum;
            indRoiTracker.Last_Calculated_Date__c = System.now();
            roiTrackerUpdateList.add(indRoiTracker);
        }

        if (!roiTrackerUpdateList.isEmpty()) {
            system.debug('roiTrackerUpdateList ' + roiTrackerUpdateList);
            upsert roiTrackerUpdateList;
        }
    }
    @AuraEnabled
    public static string saveRoiPfData(
        RoiPfCorrWpr roiPfdata,
        string actionType
    ) {
        try {
            System.debug('roiPfdata ' + roiPfdata);
            LoanAppeal__c lappl = new LoanAppeal__c();
            if (roiPfdata.Status == 'New') {
                //Id,RecordTypeId, Status__c, LoanAppl__c, Comments__c, DocDet__c,  OwnerName__c, LAN__c, OwnerEmail__c
                lappl.Status__c = 'In Progress';
            } else {
                if (
                    roiPfdata.Decision == 'Approve' ||
                    roiPfdata.Decision == 'Reject'
                ) {
                    lappl.Status__c = roiPfdata.Decision;
                    if (roiPfdata.Decision == 'Approve') {
                        lappl.Recommender__c = roiPfdata.ApproverId;
                    } else {
                        //lappl.Recommender__c = ApproverId;
                    }
                } else {
                    lappl.Status__c = roiPfdata.Status;
                }

                lappl.Id = roiPfdata.LoanAppealId;
            }
            if (roiPfdata.IsPricingApplicable == 'Y') {
                if (roiPfdata.Decision == 'Forward To Recommender') {
                    lappl.OwnerId = roiPfdata.RecomenderId;
                    lappl.Recommender__c = roiPfdata.RecomenderId != null
                        ? roiPfdata.RecomenderId
                        : '';
                } else if (roiPfdata.Decision == 'Forward To Approver') {
                    lappl.OwnerId = roiPfdata.ApproverId;
                }
                lappl.RecordTypeId = roiPfdata.RecTypeId;
                lappl.LoanAppl__c = roiPfdata.LoanAppId;

                lappl.Approver__c = roiPfdata.ApproverId;
                lappl.RevisedRoi__c = roiPfdata.RevRoi;
                lappl.RevisedPF__c = roiPfdata.RevPf;
                lappl.BranchRoi__c = roiPfdata.BranchRoi;
                lappl.ZoneRoi__c = roiPfdata.RegionRoi;
                lappl.PanIndiaRoi__c = roiPfdata.PanRoi;
                lappl.Decision__c = roiPfdata.Decision;
                lappl.ApproverLevel__c = roiPfdata.ApproverLevel;
                upsert lappl;
                System.debug('lappl ' + lappl);
                updateLanPa(roiPfdata.LoanAppId, roiPfdata.IsPricingApplicable);
                LoanAppealItem__c lapplItm = new LoanAppealItem__c();
                lapplItm.Recomender__c = UserInfo.getUserId();
                if (roiPfdata.Decision == 'Forward To Recommender') {
                    lapplItm.Recomended_To__c = roiPfdata.RecomenderId != null
                        ? roiPfdata.RecomenderId
                        : '';
                }
                lapplItm.Revised_PF__c = roiPfdata.RevPf;
                lapplItm.Revised_ROI__c = roiPfdata.RevRoi;
                lapplItm.LoanAppeal__c = lappl.Id;
                lapplItm.SalesComments__c = roiPfdata.RationalComment;
                lapplItm.Comments__c = roiPfdata.RecAppComments;
                lapplItm.ApproverLevel__c = roiPfdata.ApproverLevel;
                upsert lapplItm;
                if (lappl.Status__c == 'Approve') {
                    updateLan(
                        lappl.RevisedRoi__c,
                        lappl.RevisedPF__c,
                        lappl.LoanAppl__c
                    );
                }
            } else if (roiPfdata.IsPricingApplicable == 'N') {
                updateLanPa(roiPfdata.LoanAppId, roiPfdata.IsPricingApplicable);
            }

            return 'Save';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    public static void updateLanPa(string loanId, string paApplicable) {
        LoanAppl__c lan = new LoanAppl__c();
        lan.Id = loanId;
        lan.PricingApprovalApplicable__c = paApplicable;

        update lan;
        System.debug(
            'updated loan detail ,...... ' +
                paApplicable +
                '  ::  ' +
                loanId +
                '  ::  ' +
                lan
        );
    }
    public static void updateLan(decimal roi, decimal pf, string loanId) {
        LoanAppl__c lan = new LoanAppl__c();
        lan.Id = loanId;
        lan.RevisedPF__c = pf;
        lan.RevisedROI__c = roi;
        lan.EffectiveROI__c = roi;
        update lan;
        System.debug(
            'updated loan detail ,...... ' +
                roi +
                '  ::  ' +
                pf +
                '  ::  ' +
                loanId +
                '  ::  ' +
                lan
        );
    }
    public static Void createIntMsz(string loanAplId) {
        IntgMsg__c intMsz = new IntgMsg__c();
        intMsz.Name = 'Crif Auth Login';
        intMsz.BU__c = 'HL / STL';
        intMsz.IsActive__c = true;
        intMsz.Svc__c = 'Crif Auth Login';
        intMsz.Status__c = 'New';
        intMsz.Outbound__c = true;
        intMsz.RefObj__c = 'LoanAppl__c';
        intMsz.ApiVendor__c = 'Crif';
        intMsz.RefId__c = loanAplId;

        // fieldsWo['Name'] = 'Crif Auth Login'; //serviceName;//'KYC OCR'
        // fieldsWo['BU__c'] = 'HL / STL';
        // fieldsWo['IsActive__c'] = true;
        // fieldsWo['Svc__c'] = 'Crif Auth Login'; //serviceName;
        // fieldsWo['Status__c'] = 'New';
        // fieldsWo['Outbound__c'] = true;
        // fieldsWo['RefObj__c'] = 'LoanAppl__c';
        // fieldsWo['ApiVendor__c'] = 'Crif';
        // fieldsWo['RefId__c'] = loanAplId;

        insert intMsz;
    }

    public class AggregateResultWrapper {
        public Decimal disxroiLnAmt { get; set; }
        public Decimal disxPFLnAmt { get; set; }
        public Decimal sumDisAmt { get; set; }
        public String branchCode { get; set; }

        public AggregateResultWrapper(
            Decimal disxroiLnAmt,
            Decimal disxPFLnAmt,
            Decimal sumDisAmt,
            String branchCode
        ) {
            this.disxroiLnAmt = disxroiLnAmt;
            this.disxPFLnAmt = disxPFLnAmt;
            this.sumDisAmt = sumDisAmt;
            this.branchCode = branchCode;
        }
    }

    public class RoiPfCorrWpr {
        @AuraEnabled
        public String RateType { get; set; }
        @AuraEnabled
        public Decimal RaacROI { get; set; }
        @AuraEnabled
        public Decimal RaacPF { get; set; }
        @AuraEnabled
        public Decimal EffRoiUw { get; set; }
        @AuraEnabled
        public Decimal RevRoiMaxVal { get; set; }
        @AuraEnabled
        public Decimal RevRoi { get; set; }
        @AuraEnabled
        public Decimal RevPf { get; set; }
        @AuraEnabled
        public string RevPfStr { get; set; }
        @AuraEnabled
        public Decimal BranchRoi { get; set; }
        @AuraEnabled
        public Decimal RegionRoi { get; set; }
        @AuraEnabled
        public Decimal PanRoi { get; set; }
        @AuraEnabled
        public string ApproverId { get; set; }
        @AuraEnabled
        public string RecomenderId { get; set; }
        @AuraEnabled
        public string RationalComment { get; set; }
        @AuraEnabled
        public string RoutRec { get; set; }
        @AuraEnabled
        public Decimal ApproverLevel { get; set; }
        @AuraEnabled
        public String LoanAppId { get; set; }
        @AuraEnabled
        public String LoanAppealId { get; set; }
        @AuraEnabled
        public String RecTypeId { get; set; }
        @AuraEnabled
        public String Status { get; set; }
        @AuraEnabled
        public String Decision { get; set; }
        @AuraEnabled
        public string RecAppComments { get; set; }
        @AuraEnabled
        public string IsPricingApplicable { get; set; }
        @AuraEnabled
        public List<applItem> ApplItemList { get; set; }
    }

    public class applItem {
        @AuraEnabled
        public String RecomeddedTo { get; set; }
        @AuraEnabled
        public String RecomendedBy { get; set; }
        @AuraEnabled
        public Decimal RevPF { get; set; }
        @AuraEnabled
        public string RevPfStr { get; set; }
        @AuraEnabled
        public Decimal RevRoi { get; set; }
        @AuraEnabled
        public string Id { get; set; }
        @AuraEnabled
        public string Comment { get; set; }
        @AuraEnabled
        public string RecAppComment { get; set; }
        @AuraEnabled
        public Datetime CreatedDate { get; set; }
    }
}