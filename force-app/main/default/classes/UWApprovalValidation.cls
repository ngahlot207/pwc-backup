public without sharing class UWApprovalValidation {
    @AuraEnabled
    public static List<String> validateData(String decision, String loanId) {
        List<String> errors = new List<String>();
        try {
            Map<string, List<string>> metadataMap = new Map<string, List<string>>();
            Map<string, List<string>> caseMap = new Map<string, List<string>>();
            Map<Id, PD__c> applPDMap = new Map<Id, PD__c>();
            Map<Id, Case> assetCVMap = new Map<Id, Case>();
            Map<Id, Case> assetLegalMap = new Map<Id, Case>();
            Map<Id, Case> assetVettingMap = new Map<Id, Case>();
            Map<Id, Case> assetTsrMap = new Map<Id, Case>();
            Map<Id, List<Case>> assetTechMap = new Map<Id, List<Case>>();
            Case RCURecord;
            boolean rcuDevAvl=false;//LAK-9889
            Set<Id> bankIds = new Set<Id>();
            Set<Id> bankIdsforRepay = new Set<Id>();
            List<ApplBanking__c> bankRecList= new List<ApplBanking__c>();
            Set<Id> divIds = new Set<Id>();
            Set<Id> divLevelIds = new Set<Id>();
            Decimal totalPropertyCost = 0;
            Decimal totalPropertyValue = 0;    
            Set<Id> enpaId = new Set<Id>();
            
            //code for Applicant and coapplicant
            if(
                decision == 'Forward for Review'	||  
                decision == 'Forward for Soft Approval' ||
                decision == 'Forward for Approve' 
            ){                 
                list<ValidateRequiredFieldsAndDoc.Responce> duplicateKycData = DocumentDetailController.findDuplicateDocs(loanId);
                
                if (duplicateKycData != null && duplicateKycData.size() > 0) {
                    errors.add(
                        'Duplicate KYC document found for Applicant and Co-Applicant'
                    );
                }
            }    
            
            List<APICoutTrckr__c> coutTrackers = [
                SELECT Id, LtstRespCode__c, IsInvalid__c
                FROM APICoutTrckr__c
                WHERE APIName__c = 'Crif Auth Login' AND LAN__c = :loanId
            ];
            List<LoanAppl__c> ln = new List<LoanAppl__c>(
                [
                    SELECT
                    Id,
                    Product__c,
                    ReqLoanAmt__c,
                    AssesIncomeAppl__c,
                    Loan_Tenure_Months__c,
                    TotalLoanAmtInclInsurance__c,
                    InsAmt__c,
                    SanLoanAmt__c,
                    ProductSubType__c,
                    SchemeId__c,
                    DueDay__c,
                    IsSellerListDocLODAvl__c,
                    IsSellerBTLoanForeclosureAmt__c,
                    DocAsPerLegalReportMatches__c,
                    SaleDeedBetnBuyerBorr__c,
                    OwnContriPaid__c,
                    LetterFomSellerBTFinancier__c,
                    ChequeForAmtEquiBTAmt__c,
                    SellerVerificationKYCSellerTaken__c,
                    SellerVerCredTeleChk__c,
                    AllSellerBTNormMet__c,
                    OwnContriCash__c,
                    LANRCUStatus__c,
                    Stage__c
                    FROM LoanAppl__c
                    WHERE Id = :loanId
                ]
            );
            Map<Id, Applicant__c> appMap = new Map<Id, Applicant__c>(
                [
                    SELECT
                    Id,
                    FullName__c,
                    CustProfile__c,
                    Constitution__c,
                    Type_of_Borrower__c,
                    Is_Physical_Consent_Validated__c,
                    OTP_Verified__c,
                    Income_Type_Selected__c,
                    TabName__c,
                    LatestyearforwhichITRisavailable__c,
                    PAN__c,
                    (SELECT ID, AddrTyp__c FROM Applicant_Addresses__r),
                    (SELECT ID, GST_Registered__c,LoanApplicant__r.Type_of_Borrower__c FROM Applicant_Employments__r),
                    (SELECT ID, Applicant__c, Main_GSTIN__c FROM Applicant_GST__r),
                    (SELECT ID FROM Applicant_Income__r),
                    (
                        SELECT
                        id,
                        DocCatgry__c,
                        DocTyp__c,
                        Applicant_KYC__r.kycDoc__c,
                        Applicant_KYC__r.AadharNo__c,
                        Applicant_KYC__r.DLNo__c,
                        Applicant_KYC__r.PassNo__c,
                        Applicant_KYC__r.VotIdEpicNo__c,
                        Applicant_KYC__r.OtherDocName__c,
                        Applicant_KYC__r.Pan__c
                        FROM Applicant_Document_Details__r
                        WHERE 
                        (DocTyp__c = 'Residence Address proof - OVD' OR DocCatgry__c = 'PAN Documents') // Pan Missing Validation
                    )
                    FROM Applicant__c
                    WHERE LoanAppln__c = :loanId AND ApplType__c IN ('P', 'C', 'G')
                ]
            );
            SchMapping__c schemeMaping = new SchMapping__c();
            if (!ln.isEmpty() && ln[0].SchemeId__c != null) {
                schemeMaping = [
                    SELECT
                    Id,
                    SellarBT__c,
                    IsBT__c,
                    IsInternalTopUp__c,
                    ApplicableOwnContribution__c,
                    IsFixed__c,
                    IsCostApplicable__c,
                    MinAmtFin__c,
                    MaxAmtFin__c
                    FROM SchMapping__c
                    WHERE Id = :ln[0].SchemeId__c
                    LIMIT 1
                ];
            }
            list<BTLoan__c> btLoan = new List<BTLoan__c>();
            if (!ln.isEmpty()) {
                btLoan = [
                    SELECT
                    Id,
                    Name,
                    BTOriginalLoanAmt__c,
                    BTLoanOutstandingValue__c,
                    SpecifyOtherBTFinancier__c,
                    BTFinancierStatus__c,
                    BTFinancier__c,
                    LoanAppl__c,
                    ExistFedfinaAccNo__c
                    FROM BTLoan__c
                    WHERE LoanAppl__c = :loanId
                ];
            }
            
            List<APICoutTrckr__c> apiResp = [
                SELECT
                Id,
                LtstRespCode__c,
                Appl__r.TabName__c,
                Appl__r.Id,
                CrntStatus__c,
                APIName__c,IntgMsgName__c
                FROM APICoutTrckr__c
                WHERE
                (APIName__c = 'Risk API'
                 OR APIName__c = 'Screening API'
                 OR APIName__c = 'ScreeningWachout'
                 OR APIName__c = 'ENPADeatils'
                 OR APIName__c = 'Hunter API'
                 OR APIName__c = 'Hunter Token'
                 OR APIName__c = 'Dedupe API Token')
                AND LAN__c = :loanId
            ];
            
            List<APIVer__c> watchoutList = [
                SELECT Id, Result_Relevance__c,recordtype.name, IntDedRsltRmrks__c,IntegrationStatus__c,Appl__r.TabName__c,Appl__c
                FROM APIVer__c
                WHERE recordtype.name = 'Watchout' AND WatchoutInvestor__c = TRUE AND IsLatest__c = TRUE AND LoanAplcn__c =: loanId
                
            ];
            if (
                decision == 'Approve' ||
                decision == 'Soft Approve' ||
                decision == 'Forward for Soft Approval' ||
                decision == 'Forward for Approve'
            ) {
                if (schemeMaping != null) {
                    boolean showErrormsg = false;
                    if (!ln.isEmpty() && ln[0].DueDay__c == null) {
                        showErrormsg = true;
                    }
                    if(schemeMaping.SellarBT__c || (!ln.isEmpty() && ln[0].ProductSubType__c == 'Seller BT - 100% Ready Property')) {
                        if (!ln.isEmpty() && (
                            ln[0].IsSellerListDocLODAvl__c == null ||
                            ln[0].IsSellerBTLoanForeclosureAmt__c == null ||
                            ln[0].DocAsPerLegalReportMatches__c == null ||
                            ln[0].SaleDeedBetnBuyerBorr__c == null ||
                            ln[0].OwnContriPaid__c == null ||
                            ln[0].LetterFomSellerBTFinancier__c == null ||
                            ln[0].ChequeForAmtEquiBTAmt__c == null ||
                            ln[0].SellerVerificationKYCSellerTaken__c == null ||
                            ln[0].SellerVerCredTeleChk__c == null ||
                            ln[0].AllSellerBTNormMet__c == null )
                           ) {
                               showErrormsg = true;
                           }
                    }
                    if (schemeMaping.IsBT__c) {
                        if (btLoan.isEmpty()) {
                            showErrormsg = true;
                        } else {
                            boolean btError = false;
                            for (BTLoan__c bt : btLoan) {
                                string btContent = 'Other';
                                if (
                                    bt.BTOriginalLoanAmt__c == null ||
                                    bt.BTLoanOutstandingValue__c == null ||
                                    bt.BTFinancier__c == null
                                ) {
                                    btError = true;
                                } else if (bt.BTFinancier__c.contains(btContent)) {
                                    if (bt.SpecifyOtherBTFinancier__c == null) {
                                        btError = true;
                                    }
                                }
                            }
                            if (btError) {
                                showErrormsg = true;
                                
                            }
                        }
                    }
                    
                    if (showErrormsg) {
                        errors.add(
                            'Mandatory fields on Loan details are not entered. Please complete all required fields.'
                        );
                    }
                }

                if((ln[0].Product__c=='Business Loan' || ln[0].Product__c=='Personal Loan') && (ln[0].Stage__c=='UnderWriting' || ln[0].Stage__c=='Post Sanction')){
                    List<ChangeSummaryHandler.ChangeSummaryData> changeSummaryRecords = ChangeSummaryHandler.getRetriggerData(ln[0].Id);
                    Boolean isChangeSummaryReviwed = true;
                    if(!changeSummaryRecords.isEmpty()){
                        for(ChangeSummaryHandler.ChangeSummaryData cs : changeSummaryRecords){
                            if(cs.uwReviewed==false){
                                isChangeSummaryReviwed=false;
                            }
                        }
                    }
                    if(!isChangeSummaryReviwed){
                        errors.add('Please select all UW Verified checkboxes on change summary');
                    }
                }
            }
            
            Map<Id, ApplAsset__c> assetMap = new Map<Id, ApplAsset__c>(
                [
                    SELECT
                    Id,
                    TotalNoOfCasesNeedToRaised__c,
                    Property_Carpet_area_Sq_Ft__c,
                    Resi_Age__c,
                    Approx_Age_of_Prop__c,
                    Property_Usage__c,
                    NatureofProp__c,
                    PropSubTypeDesc__c,
                    PropSubType__c,
                    PropIdentified__c,
                    Total_Prop_Cost__c,
                    ValuationToBeTakenAheadForCalculation__c,
                    ServiceableCity__c
                    FROM ApplAsset__c
                    WHERE LoanAppln__c = :loanId
                    ORDER BY CreatedDate
                ]
            );
            // sheet changes 1/3/24
            for (Id assetId : assetMap.keyset()) {
                ApplAsset__c appAss = assetMap.get(assetId);
                if (appAss != null) {
                    if (appAss.Total_Prop_Cost__c != null) {
                        totalPropertyCost += appAss.Total_Prop_Cost__c;
                    }
                    if (appAss.ValuationToBeTakenAheadForCalculation__c != null) {
                        totalPropertyValue += appAss.ValuationToBeTakenAheadForCalculation__c;
                    }
                }
            }
            
            if (decision == 'Approve' || decision == 'Forward for Approve') {
                if (schemeMaping != null && schemeMaping.IsCostApplicable__c == true && !ln.isEmpty() && 
                    (ln[0].Product__c == 'Home Loan' ||
                     ((ln[0].Product__c == 'Small Ticket LAP' || ln[0].Product__c == 'Loan Against Property') &&
                      ln[0].ProductSubType__c == 'Commercial Property Purchase'))
                   ) {
                       if (ln[0].TotalLoanAmtInclInsurance__c > totalPropertyCost) {
                           errors.add(
                               'Sum of Loan Amount Including Insurance should not exceed the Sum of Total Property Cost'
                           );
                       }
                   }
                   //LAK-7332 - UW Decision
                if ( !ln.isEmpty() && (ln[0].TotalLoanAmtInclInsurance__c > totalPropertyValue) && (ln[0].Product__c != 'Business Loan' && ln[0].Product__c != 'Personal Loan')) {
                    errors.add(
                        'Sum of loan amount including insurance should not exceed the Total Valuation of all the property'
                    );
                }
                if (
                    schemeMaping != null && !ln.isEmpty() && 
                    (ln[0].TotalLoanAmtInclInsurance__c > schemeMaping.MaxAmtFin__c)
                ) {
                    errors.add(
                        'Total Loan Amount including Insurance should not be greater then the max amount of the scheme'
                    );
                }
                if (
                    schemeMaping != null && !ln.isEmpty() && 
                    (ln[0].TotalLoanAmtInclInsurance__c < schemeMaping.MinAmtFin__c)
                ) {
                    errors.add(
                        'Total Loan Amount including Insurance should not be less than the minimum amount of the scheme'
                    );
                }
                
            }
            
            for (PD__c pd : [
                SELECT
                Id,
                PDTyp__c,
                IsCompleted__c,
                Appl__c,
                PDStatus__c,
                Result__c,
                Appl__r.CustProfile__c
                FROM PD__c
                WHERE
                LoanAppl__c = :loanId
                AND PDStatus__c != 'Withdrawn'
                AND (Appl__r.CustProfile__c = 'SALARIED'
                     OR PDTyp__c = 'Physical PD')
                ORDER BY CreatedDate
            ]) {
                applPDMap.put(pd.Appl__c, pd);
            }
            
            for (Case c : [
                SELECT
                Id,
                IsCompleted__c,
                CVStatus__c,
                Status,
                Property_Visit_Final_Status__c,
                ApplAssetId__c,
                AccountId,
                IsReinitiated__c,
                WaiveCPV__c,
                Address_Type__c,
                Applicant__c,
                RecordType.Name,
                ReportResult__c,
                RCU_Hold_Reason__c,
                Final_RCU_status_Reason__c,
                Date_of_Report__c,
                DateofInitiation__c,
                Remarks_regarding_the_case__c
                FROM Case
                WHERE
                Loan_Application__c = :loanId
                AND (RecordType.Name = 'Collateral Visit'
                     OR RecordType.Name = 'Technical'
                     OR RecordType.Name = 'CPVFI'
                     OR RecordType.Name = 'RCU'
                     OR RecordType.Name = 'Legal'
                     OR RecordType.Name = 'TSR'
                     OR RecordType.Name = 'Vetting')
                ORDER BY CreatedDate
            ]) {
                if (
                    c.RecordType.Name == 'Collateral Visit' &&
                    c.CVStatus__c != 'Withdrawn'
                ) {
                    assetCVMap.put(c.ApplAssetId__c, c);
                } else if (
                    c.RecordType.Name == 'Technical' &&
                    c.AccountId != null &&
                    c.IsReinitiated__c == false &&
                    c.Status != 'Cancelled'
                ) {
                    if (assetTechMap.containsKey(c.ApplAssetId__c)) {
                        assetTechMap.get(c.ApplAssetId__c).add(c);
                    } else {
                        assetTechMap.put(c.ApplAssetId__c, new List<Case>{ c });
                    }
                } else if (
                    c.RecordType.Name == 'CPVFI' &&
                    (c.Status != 'Cancelled' ||
                     c.WaiveCPV__c == 'Yes')
                ) {
                    if (caseMap.containsKey(c.Applicant__c)) {
                        caseMap.get(c.Applicant__c).add(c.Address_Type__c);
                    } else {
                        caseMap.put(c.Applicant__c, new List<string>{ c.Address_Type__c });
                    }
                } else if (c.RecordType.Name == 'RCU') {
                    RCURecord = c;
                } 
                else if (c.RecordType.Name == 'Legal') {
                    
                    assetLegalMap.put(c.ApplAssetId__c, c);
                    
                } 
                else if (c.RecordType.Name == 'Vetting') {
                    assetVettingMap.put(c.ApplAssetId__c, c);
                } 
                else if (c.RecordType.Name == 'TSR') {
                    assetTsrMap.put(c.ApplAssetId__c, c);
                } 
            }
            
            for (ApplBanking__c banking : [
                SELECT Id, MICR_Code__c, IFSC_Code__c
                FROM ApplBanking__c
                WHERE
                LoanAppl__c = :loanId AND Appl__r.Type_of_Borrower__c = 'Financial' AND Repayment_bank_A_c__c = 'Yes'
                //AND MICR_Code__c != NULL
            ]) {
                bankIds.add(banking.Id);
                bankRecList.add(banking);
            }
            system.debug('UserInfo.getUserId()'+UserInfo.getUserId());
            //9889
            List<String> deviationList =new List<String>();
            deviationList = system.label.DeviationRCU.split(',');
            List<SPDD_Approval_Config__c> spddList = [
                SELECT Id, Dev_Level__c, Sanction_Amt__c, Emp__c
                FROM SPDD_Approval_Config__c
                WHERE
                Product__c INCLUDES (:ln[0].Product__c)
                AND Emp__c = :UserInfo.getUserId()
            ];
            system.debug('spddListspddList'+spddList);
            for (Deviation__c div : [
                SELECT Id, Appr_Actn__c, Req_Apprv_Level__c, Devia_Desrp__c, Deviation__c
                FROM Deviation__c
                WHERE
                LoanAppln__c = :loanId
                AND (Dev_Type__c = 'Manual'
                     OR (Dev_Type__c = 'System'
                         AND BRE__r.IsLatest__c = TRUE AND BRE__r.Call_Id__c != '5.0'))
            ]) {
                if (div.Appr_Actn__c != 'Approved') {
                    divIds.add(div.Id);
                }
                //LAK-9889
                if(!deviationList.isEmpty()){
                    if(deviationList.contains(div.Deviation__c)){
                        rcuDevAvl=true;
                    }
                }
                
                system.debug('insideeeee');
                if (!spddList.isEmpty()) {
                    system.debug('spddList[0].Dev_Level__c'+spddList[0].Dev_Level__c);
                    //if (div.Appr_Actn__c != 'Approved' && div.Appr_Actn__c != 'Rejected'){
                    if (
                        
                        div.Req_Apprv_Level__c != null &&
                        spddList[0].Dev_Level__c != null &&
                        Integer.valueOf(div.Req_Apprv_Level__c) >
                        Integer.valueOf(spddList[0].Dev_Level__c)
                    ) {
                        system.debug('43555555');
                        divLevelIds.add(div.Id);
                        
                    }else if( div.Appr_Actn__c != 'Approved' && String.isBlank(spddList[0].Dev_Level__c)){
                        system.debug('439999');
                        divLevelIds.add(div.Id);
                    }
                }
            }
            
            for (MandatoryAddrList__mdt meta : [
                SELECT Constitution__c, CustProf__c, TypeOfAppl__c, AddrType__c
                FROM MandatoryAddrList__mdt
            ]) {
                String key =
                    meta.Constitution__c +
                    '-' +
                    meta.CustProf__c +
                    '-' +
                    meta.TypeOfAppl__c;
                if (metadataMap.containsKey(key)) {
                    metadataMap.get(key).add(meta.AddrType__c);
                } else {
                    metadataMap.put(key, new List<string>{ meta.AddrType__c });
                }
            }
            
            //PD
            for (string appId : appMap.keyset()) {
                Applicant__c appl = appMap.get(appId);
                
                if (
                    decision == 'Approve' ||
                    decision == 'Soft Approve' ||
                    decision == 'Forward for Soft Approval' ||
                    decision == 'Forward for Approve'
                ) {
                    if (
                        appl.Type_of_Borrower__c == 'Financial' &&
                        (appl.CustProfile__c == 'SALARIED' ||
                         appl.CustProfile__c == 'SELF EMPLOYED PROFESSIONAL' ||
                         appl.CustProfile__c == 'SELF EMPLOYED NON PROFESSIONAL')
                    ) {
                        PD__c pd = applPDMap.get(appl.Id);
                        if (pd == null) {
                            errors.add('Please Complete the PD for ' + appl.TabName__c);
                        } else if (pd.IsCompleted__c && pd.Result__c == 'Negative') {
                            errors.add(
                                'Cannot Approve / Soft Approve as PD status is Negative for ' +
                                appl.TabName__c
                            );
                        } else if (pd.IsCompleted__c == false) {
                            errors.add(
                                'Cannot Approve / Soft Approve as PD status is In Progress for ' +
                                appl.TabName__c
                            );
                        }
                    }
                    
                    string uniKey =
                        appl.Constitution__c +
                        '-' +
                        appl.CustProfile__c +
                        '-' +
                        appl.Type_of_Borrower__c;
                    List<String> requiredCPVs = metadataMap.get(uniKey);
                    List<String> addressTypeToCheck = new List<String>();
                    for (ApplAddr__c addr : appl.Applicant_Addresses__r) {
                        if (
                            requiredCPVs != null && requiredCPVs.contains(addr.AddrTyp__c)
                        ) {
                            addressTypeToCheck.add(addr.AddrTyp__c);
                        }
                    }
                    
                    List<String> appCPVs = caseMap.get(appId);
                    if (addressTypeToCheck != null) {
                        for (String cpv : addressTypeToCheck) {
                            if (appCPVs == null || !appCPVs.contains(cpv)) {
                                errors.add(cpv + ' CPV is required for ' + appl.TabName__c);
                            }
                        }
                    }
                    
                    //LAK-6418
                    boolean mainGSTPresent = false;
                    for (ApplGST__c appGst : appl.Applicant_GST__r) {
                        if (appGst.Main_GSTIN__c == true) {
                            mainGSTPresent = true;
                        }
                    }
                    
                    
                    Integer empCount = 0;
                    
                    for (ApplicantEmployment__c appEmp : appl.Applicant_Employments__r) {   
                        empCount++;
                        
                        if(appEmp.GST_Registered__c == 'YES' && mainGSTPresent == false && appEmp.LoanApplicant__r.Type_of_Borrower__c !=null && appEmp.LoanApplicant__r.Type_of_Borrower__c == 'Financial' && appl.Constitution__c != 'INDIVIDUAL'){
                                errors.add(appl.TabName__c + ' : Please Select Main GSTIN');
                        
                        }else{
                            // if (appEmp.GST_Registered__c == 'YES' && mainGSTPresent == false) {
                            //     errors.add(appl.TabName__c + ' : Please Select Main GSTIN');
                            // }
                            System.debug('Applicant Is non financial .');
                        }
                    }
                    if(empCount > 1){
                        errors.add(appl.TabName__c + ' : Multiple Employments Details Present, Please Contact Admin');
                    }
                    
                    if (!appl.Applicant_Document_Details__r.isEmpty()) {
                        for (DocDtl__c dd : appl.Applicant_Document_Details__r) {
                            Boolean showError = false;
                            string docName = dd.Applicant_KYC__r.kycDoc__c;
                            
                            if (
                                docName == 'Driving License' &&
                                dd.Applicant_KYC__r.DLNo__c == null
                            ) {
                                showError = true;
                            } else if (
                                docName == 'Aadhaar' &&
                                dd.Applicant_KYC__r.AadharNo__c == null
                            ) {
                                showError = true;
                            } else if (
                                docName == 'Voter Id' &&
                                dd.Applicant_KYC__r.VotIdEpicNo__c == null
                            ) {
                                showError = true;
                            } else if (
                                docName == 'Passport' &&
                                dd.Applicant_KYC__r.PassNo__c == null
                            ) {
                                showError = true;
                            }
                            // Pan Missing Validation
                            else if(dd.DocCatgry__c == 'PAN Documents' && dd.Applicant_KYC__r.Pan__c != null && appl.PAN__c == null){
                                errors.add(
                                    appl.TabName__c +
                                    ' : ' +
                                    'Something went wrong while updating PAN, Kindly Upload/Validate PAN Again!'
                                );
                            }
                            if (showError) {
                                errors.add(
                                    appl.TabName__c +
                                    ' : ' +
                                    System.Label.Documents_Id_Number_Is_Missing_For_OVD
                                );
                            }
                        }
                    }
                }
                
            }
            Set<Id> appId = new Set<Id>();
            Map<string, List<Applicant_Financial_Summary__c>> finantialMap = new Map<string, List<Applicant_Financial_Summary__c>>();
            List<Applicant_Financial_Summary__c> financialList = [
                SELECT Id, Type_of_Accounts__c, Date_of_Filing_ITR__c,Applicant_Financial__r.Loan_Applicant__c
                FROM Applicant_Financial_Summary__c
                WHERE Applicant_Financial__r.RecordType.name = 'Profit & Loss'
            ];
            if (financialList != null && financialList.size() > 0) {
                for (Applicant_Financial_Summary__c appFinSum : financialList) {
                    if(finantialMap.containsKey(appFinSum.Applicant_Financial__r.Loan_Applicant__c)){
                        finantialMap.get(appFinSum.Applicant_Financial__r.Loan_Applicant__c).add(appFinSum);
                    }else{
                        finantialMap.put(appFinSum.Applicant_Financial__r.Loan_Applicant__c,new List<Applicant_Financial_Summary__c>{appFinSum});
                    }	
                }
            }
            if (
                decision == 'Approve' ||
                decision == 'Soft Approve' ||
                decision == 'Forward for Soft Approval' ||
                decision == 'Forward for Approve'
            ) {
                
                
                if (appMap.keySet().size() > 0) {
                    for (id app : appMap.keySet()) {
                        if (
                            appMap.get(app).Type_of_Borrower__c == 'Financial' &&
                            (appMap.get(app).CustProfile__c == 'SELF EMPLOYED PROFESSIONAL' ||
                             appMap.get(app).CustProfile__c ==
                             'SELF EMPLOYED NON PROFESSIONAL')
                        ) {
                            if (
                                String.isBlank(
                                    appMap.get(app).LatestyearforwhichITRisavailable__c
                                )
                            ) {
                                errors.add(
                                    'Please Fill the Mandatory fields in Financial Details'
                                );
                            }
                            
                            if (
                                String.isNotBlank(
                                    appMap.get(app).LatestyearforwhichITRisavailable__c
                                ) &&
                                appMap.get(app).LatestyearforwhichITRisavailable__c !=
                                'ITR Not Available'
                            ) {
                                if(finantialMap.keySet().size() > 0){
                                    List<Applicant_Financial_Summary__c> appFinanList = finantialMap.get(app);
                                    if(appFinanList != null && appFinanList.size() > 0){
                                        for(Applicant_Financial_Summary__c appFin : appFinanList){
                                            if(appFin.Type_of_Accounts__c != null && appFin.Type_of_Accounts__c != 'Provisional'){
                                                if(appFin.Date_of_Filing_ITR__c == null){                                              
                                                    errors.add(
                                                        'Please Fill the Mandatory fields in Financial Details'
                                                    );
                                                }
                                                else{
                                                    appId.add(appMap.get(app).Id);
                                                }
                                            }
                                        }
                                    }
                                }
                                
                            }
                        }
                    }
                }
                if(appMap.keySet().size() > 0){
                    for (id ap : appMap.keySet()) {
                        if (
                            appMap.get(ap).Type_of_Borrower__c == 'Financial' &&
                            appMap.get(ap).CustProfile__c != 'HOUSEWIFE' &&
                            appMap.get(ap).CustProfile__c != 'OTHERS' && 
                            ( String.isBlank(appMap.get(ap).LatestyearforwhichITRisavailable__c) ||
                             appMap.get(ap).LatestyearforwhichITRisavailable__c =='ITR Not Available')
                            && appMap.get(ap).Applicant_Income__r.size() < 0 //added for LAK-7556
                        ) {
                            //commented below lines for for LAK-7556
                            // if (
                            //     String.isBlank(appMap.get(ap).Income_Type_Selected__c) 
                            // ) { 
                            //added for LAK-7556
                            errors.add(
                                'Atleast One Income Detail is Mandatory for ' + appMap.get(ap).FullName__c
                            );
                            // }
                        }
                    }
                }
                
                List<ApplBanking__c> appBankingList = [
                    SELECT
                    Id,
                    AC_No__c,
                    SFDC_Bank_Master_Name__c,
                    BankName__c,
                    Name_of_the_Primary_Account_Holder_s__c,
                    AccountType__c,
                    ConsideredForABBProgram__c,
                    Appl__r.FullName__c,
                    Repayment_bank_A_c__c,
                    (
                        SELECT
                        Id,
                        AverageBankBalance__c,
                        BalanceAt_10th__c,
                        BalanceAt_15th__c,
                        BalanceAt_5th__c,
                        BalanceAt_25th__c,
                        BalanceAt_20th__c,
                        BalanceAt_1st__c,
                        CountofCredit__c,
                        CountofDebit__c,
                        DailyABBBalance__c,
                        InwardReturnsCount__c,
                        MinBalanceCharges__c,
                        MonthlyLimit__c,
                        OutwardReturnsCount__c,
                        StopPaymentCount__c,
                        Utilization__c,
                        ValueSummationCredit__c,
                        ValueSummationDebit__c,
                        Year__c
                        FROM Applicant_Banking_Detail__r WHERE Type__c IN (NULL, 'Account Analysis') AND SubType__c IN (NULL, 'Monthly Details')
                    )
                    FROM ApplBanking__c
                    WHERE
                    Appl__r.Type_of_Borrower__c = 'Financial'
                    AND LoanAppl__c = :loanId
                    AND Type__c = NULL
                ];
                if (appBankingList != null && appBankingList.size() > 0) {
                    for (ApplBanking__c appBan : appBankingList) {
                        if (
                            appBan.AC_No__c != null &&
                            String.isNotBlank(
                                appBan.Name_of_the_Primary_Account_Holder_s__c
                            ) &&
                            String.isNotBlank(appBan.AccountType__c)
                        ) {
                            if (
                                String.isNotBlank(appBan.Repayment_bank_A_c__c) &&
                                appBan.Repayment_bank_A_c__c == 'Yes'
                            ) {
                                if (String.isEmpty(appBan.BankName__c)) {
                                    if (
                                        decision == 'Approve' ||
                                        decision == 'Forward for Approve'
                                    ){
                                        
                                        errors.add(
                                            appBan.Appl__r.FullName__c +
                                            ': Mandatory fields on Banking details not entered. Please provide all required information for ' +
                                            appBan.SFDC_Bank_Master_Name__c
                                        );
                                        break;
                                    }
                                    
                                }
                            }
                            if (
                                String.isNotBlank(appBan.AccountType__c) &&
                                (appBan.AccountType__c == 'SAVINGS' ||
                                 appBan.AccountType__c == 'CURRENT') &&
                                ln[0].ReqLoanAmt__c != null &&
                                ln[0].ReqLoanAmt__c > 2500000 &&
                                String.isNotBlank(ln[0].AssesIncomeAppl__c) &&
                                ln[0].AssesIncomeAppl__c == 'No'
                            ) {
                                if (String.isEmpty(appBan.ConsideredForABBProgram__c)) {
                                    errors.add(
                                        appBan.Appl__r.FullName__c +
                                        ': Mandatory fields on Banking details not entered. Please provide all required information for ' +
                                        appBan.SFDC_Bank_Master_Name__c
                                    );
                                    break;
                                }
                            }
                            
                            if (
                                appBan.Applicant_Banking_Detail__r != null &&
                                appBan.Applicant_Banking_Detail__r.size() > 0
                            ) {
                                for (
                                    ApplBankDetail__c appBanDeta : appBan.Applicant_Banking_Detail__r
                                ) {
                                    if (
                                        appBanDeta.BalanceAt_10th__c == null ||
                                        appBanDeta.BalanceAt_15th__c == null ||
                                        appBanDeta.BalanceAt_5th__c == null ||
                                        appBanDeta.BalanceAt_25th__c == null ||
                                        appBanDeta.BalanceAt_20th__c == null ||
                                        appBanDeta.BalanceAt_1st__c == null ||
                                        appBanDeta.CountofCredit__c == null ||
                                        appBanDeta.CountofDebit__c == null ||
                                        appBanDeta.InwardReturnsCount__c == null ||
                                        appBanDeta.MinBalanceCharges__c == null ||
                                        appBanDeta.OutwardReturnsCount__c == null ||
                                        appBanDeta.StopPaymentCount__c == null ||
                                        appBanDeta.ValueSummationDebit__c == null ||
                                        appBanDeta.ValueSummationCredit__c == null
                                    ) {
                                        errors.add(
                                            appBan.Appl__r.FullName__c +
                                            ': Mandatory fields on Banking details not entered. Please provide all required information for ' +
                                            appBan.SFDC_Bank_Master_Name__c
                                        );
                                        break;
                                    } else if (
                                        String.isNotBlank(appBan.AccountType__c) &&
                                        (appBan.AccountType__c == 'CC' ||
                                         appBan.AccountType__c == 'OVERDRAFT') &&
                                        appBanDeta.MonthlyLimit__c == null
                                    ) {
                                        errors.add(
                                            appBan.Appl__r.FullName__c +
                                            ': Mandatory fields on Banking details not entered. Please provide all required information for ' +
                                            appBan.SFDC_Bank_Master_Name__c
                                        );
                                        break;
                                    }
                                }
                            }
                        } else {
                            String msg =
                                appBan.Appl__r.FullName__c +
                                ': Mandatory fields on Banking details not entered. Please provide all required information' +
                                (String.isNotBlank(appBan.SFDC_Bank_Master_Name__c)
                                 ? ' for ' + appBan.SFDC_Bank_Master_Name__c
                                 : '');
                            errors.add(msg);
                            break;
                        }
                    }
                }
                //LAK-5901 && LAK-5260
                List<ValidateRequiredFieldsAndDoc.Responce> valRespData = ValidateRequiredFieldsAndDoc.getValidationReport(
                    loanId
                );
                if(valRespData !=null){
                    for (ValidateRequiredFieldsAndDoc.Responce res : valRespData) {
                        if (res.validated == false) {
                            String resp = res.applicantName + ' : ' + res.errorMessage;
                            errors.add(resp);
                        }
                    }
                }

                List<BRE__c> breRespList=[SELECT Id, LoanAppl__c, Actual_FOIR__c, Actual_LTV__c FROM BRE__c where LoanAppl__c=:loanId AND IsLatest__c=true AND EligibilityType__c = 'Application'];
 
                //LAK-10242
                if (
                    decision == 'Forward for Soft Approval' ||
                    decision == 'Forward for Approve' ||
                    decision == 'Approve' || decision == 'Soft Approve'
                ){
                    if(breRespList != null && breRespList.size()>0){
                            if(breRespList[0].Actual_FOIR__c == null){
                                errors.add('Actual FOIR is missing');
                            }
                    }
                }
                //LAK-10242
                if (
                    decision == 'Forward for Approve' || 
                    decision == 'Approve'
                ){
                    if(breRespList != null && breRespList.size()>0){
                            if(breRespList[0].Actual_LTV__c == null){
                                errors.add('Actual LTV is missing');
                            }
                    }
                }
                
                //LAK-5944
                if (
                    decision == 'Approve' ||
                    decision == 'Soft Approve' ||
                    decision == 'Forward for Soft Approval' ||
                    decision == 'Forward for Approve'
                ) {
                    List<DedupeResponse__c> DedupeList = [
                        SELECT
                        id,
                        LoanAppln__c,
                        IntnlDeduRelevance__c,
                        IntrnlDeduperes__c,
                        IntnalDeduperesremark__c,
                        Applicant__c,
                        IsAddMatchingCr__c,
                        Applicant__r.ApplType__c,
                        (
                            SELECT
                            id,
                            IntnlDeduRelevance__c,
                            IntrnlDeduperes__c,
                            IntnalDeduperesremark__c,
                            Applicant__c,
                            IsAddMatchingCr__c
                            FROM Dedupe_Responses__r
                        )
                        FROM DedupeResponse__c
                        WHERE
                        RecordType.Name = 'Dedupe'
                        AND IsLatest__c = TRUE
                        AND LoanAppln__c = :loanId
                        ORDER BY Applicant__r.ApplType__c
                    ];
                    if (DedupeList != null && DedupeList.size() > 0) {
                        for (DedupeResponse__c dedp : DedupeList) {
                            if(dedp.IsAddMatchingCr__c==false){
                                if (String.isBlank(dedp.IntnlDeduRelevance__c)) {
                                    errors.add(' Please complete internal Dedupe Relevance field');
                                    break;
                                }
                                if (String.isNotBlank(dedp.IntnlDeduRelevance__c)) {
                                    if (dedp.IntnlDeduRelevance__c == 'Accurate Match found') {
                                        if (
                                            String.isBlank(dedp.IntrnlDeduperes__c) ||
                                            String.isBlank(dedp.IntnalDeduperesremark__c)
                                        ) {
                                            errors.add('Please complete mandatory dedupe fields');
                                            break;
                                        }
                                    }
                                }
                            }
                            if (
                                dedp.Dedupe_Responses__r != null &&
                                dedp.Dedupe_Responses__r.size() > 0
                            ) {
                                for (DedupeResponse__c dedpdetil : dedp.Dedupe_Responses__r) {
                                    if (String.isBlank(dedpdetil.IntnlDeduRelevance__c)) {
                                        errors.add(
                                            'Please complete internal Dedupe Relevance field'
                                        );
                                        break;
                                    }
                                    if (String.isNotBlank(dedpdetil.IntnlDeduRelevance__c)) {
                                        if (
                                            dedpdetil.IntnlDeduRelevance__c == 'Accurate Match found'
                                        ) {
                                            if (
                                                String.isBlank(dedpdetil.IntrnlDeduperes__c) ||
                                                String.isBlank(dedpdetil.IntnalDeduperesremark__c)
                                            ) {
                                                errors.add('Please complete mandatory dedupe fields');
                                                break;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    if (DedupeList != null && DedupeList.size() > 0) {
                        for (DedupeResponse__c dedp : DedupeList) {
                            if (String.isNotBlank(dedp.IntnlDeduRelevance__c)) {
                                if (dedp.IntnlDeduRelevance__c == 'Accurate Match found') {
                                    enpaId.add(dedp.Applicant__c);
                                }
                            }
                            if (
                                dedp.Dedupe_Responses__r != null &&
                                dedp.Dedupe_Responses__r.size() > 0
                            ) {
                                for (DedupeResponse__c dedpdetil : dedp.Dedupe_Responses__r) {
                                    if (String.isNotBlank(dedpdetil.IntnlDeduRelevance__c)) {
                                        if (
                                            dedpdetil.IntnlDeduRelevance__c == 'Accurate Match found'
                                        ) {
                                            enpaId.add(dedp.Applicant__c);
                                        }
                                    }
                                }
                            }
                        }
                    }
                    List<DedupeResponse__c> enpRespList = [
                        SELECT
                        Id,
                        Internal_Top_up_Original_loan__c,
                        Loan_to_be_closed_internally__c,
                        IsPDDpending__c,
                        Loantobelinkedwithproposedloan__c,
                        LoantobeconsideredinLTVcal__c
                        FROM DedupeResponse__c
                        WHERE
                        RecordType.Name = 'ENPA'
                        AND IsLatest__c = TRUE
                        AND Applicant__c IN :enpaId
                        AND LoanAppln__c = :loanId
                        ORDER BY Applicant__r.ApplType__c
                    ];
                    if (enpRespList.size() > 0) {
                        for (DedupeResponse__c app : enpRespList) {
                            if (
                                String.isEmpty(app.Internal_Top_up_Original_loan__c) ||
                                String.isEmpty(app.Loan_to_be_closed_internally__c) ||
                                String.isEmpty(app.IsPDDpending__c) ||
                                String.isEmpty(app.Loantobelinkedwithproposedloan__c) ||
                                String.isEmpty(app.LoantobeconsideredinLTVcal__c)
                            )
                                errors.add('Please Fill ENPA Inputs');
                            break;
                        }
                    }
                }
                
                // Regulatory details
                Map<Id, list<ApplRegltry__c>> appRegMap = new Map<Id, list<ApplRegltry__c>>();
                list<ApplRegltry__c> appRegList = [
                    SELECT
                    Id,
                    LoanAppln__c,
                    Appl__c,
                    IsBorowrOrRelFFDir__c,
                    FFDirRelIntrstAsSH__c,
                    FFDirRelIntrstAsPart__c,
                    IsUwVerified__c,
                    (
                        SELECT Id, name, DirName__c, Desgntn__c, Reltnshp__c
                        FROM Regulatory_Personnel__r
                    )
                    FROM ApplRegltry__c
                    WHERE LoanAppln__c = :loanId
                    ORDER BY createdDate DESC
                ];
                
                boolean addError = false;
                if (!appRegList.isEmpty()) {
                    for (id app : appMap.keySet()) {
                        if (appMap.get(app).Constitution__c == 'INDIVIDUAL') {
                            if (appRegList[0].IsBorowrOrRelFFDir__c == null) {
                                addError = true;
                                break;
                            }
                        }
                        if (
                            appMap.get(app).Constitution__c != 'INDIVIDUAL' && (appMap.get(app).Constitution__c != 'PRIVATE LIMITED COMPANY' &&
                                                                                appMap.get(app).Constitution__c != 'PUBLIC LIMITED COMPANY')
                        ) {
                            if (appRegList[0].FFDirRelIntrstAsSH__c == null) {
                                addError = true;
                                break;
                            }
                        }
                        if (
                            appMap.get(app).Constitution__c != 'INDIVIDUAL' && (appMap.get(app).Constitution__c == 'PRIVATE LIMITED COMPANY' ||
                                                                                appMap.get(app).Constitution__c == 'PUBLIC LIMITED COMPANY')
                        ) {
                            if (appRegList[0].FFDirRelIntrstAsPart__c == null) {
                                addError = true;
                                break;
                            }
                        }
                    }
                } else {
                    addError = true;
                }
                
                if (addError == false) {
                    if (
                        appRegList[0].IsBorowrOrRelFFDir__c == 'Yes' || appRegList[0].FFDirRelIntrstAsSH__c == 'Yes' || appRegList[0].FFDirRelIntrstAsPart__c == 'Yes'
                    ) {
                        if (!appRegList[0].Regulatory_Personnel__r.isEmpty()) {
                            for (
                                RegltryPrsonl__c regPerson : appRegList[0].Regulatory_Personnel__r
                            ) {
                                if (
                                    regPerson.DirName__c == null || regPerson.Desgntn__c == null || regPerson.Reltnshp__c == null
                                ) {
                                    addError = true;
                                    break;
                                }
                            }
                        } else {
                            addError = true;
                        }
                    }
                }
                
                if (addError) {
                    errors.add(
                        'Mandatory fields on Regulatory details not entered. Please provide all required information.'
                    );
                }
                else if(appRegList[0].IsUwVerified__c == false){ //LAK-7333
                    errors.add('Please Verify the Regulatory Details before forwarding');
                  }
                
            }
            
            //LAK-7332 UW decision
            if((ln[0].Product__c != 'Business Loan' && ln[0].Product__c != 'Personal Loan')){
            //FOR LAK-5901
            if (
                decision == 'Soft Approve' ||
                decision == 'Forward for Soft Approval'
            ) {
                Integer countApp = 1;
                
                for (Id assetId : assetMap.keyset()) {
                    ApplAsset__c appAss = assetMap.get(assetId);
                    if (appAss != null) {
                        if (String.isEmpty(appAss.PropIdentified__c)) {
                            errors.add(
                                'Mandatory fields on Property Details should be entered. Please fill all required fields for Property ' +
                                countApp
                            );
                        } else if (
                            String.isNotBlank(appAss.PropIdentified__c) &&
                            appAss.PropIdentified__c == 'Yes' &&
                            ((String.isEmpty(appAss.PropSubType__c)) ||
                             (String.isEmpty(appAss.PropSubTypeDesc__c)) ||
                             (String.isEmpty(appAss.NatureofProp__c))|| (appAss.Property_Carpet_area_Sq_Ft__c == null)
                            )
                        ) {
                            errors.add(
                                'Mandatory fields on Property Details should be entered. Please fill all required fields for Property ' +
                                countApp
                            );
                        } else if (appAss.ServiceableCity__c == false) {
                            errors.add(
                                ' Please Check Property in non serviceable location for Property ' +
                                countApp
                            );
                        }
                    }
                    countApp++;
                }
            }
            //FOR LAK-5901
            
            //CV
            
            if (decision == 'Approve' || decision == 'Forward for Approve') {
                Integer count = 1;
                for (Id assetId : assetMap.keyset()) {
                    Case cv = assetCVMap.get(assetId);
                    if (cv == null) {
                        errors.add(
                            'Collateral Visit is not initiated for Property ' + count
                        );
                    } else if (
                        cv.IsCompleted__c && cv.Property_Visit_Final_Status__c == 'Negative'
                    ) {
                        errors.add(
                            'Please check CV Status is Nagative for Property ' + count
                        );
                    } else if (cv.IsCompleted__c == false) {
                        errors.add(
                            'Please close the collateral visit for Property ' + count
                        );
                    }
                    count++;
                }
                // Property details
                
                Integer countApp = 1;
                
                for (Id assetId : assetMap.keyset()) {
                    ApplAsset__c appAss = assetMap.get(assetId);
                    if (appAss != null) {
                        if (String.isEmpty(appAss.PropIdentified__c)) {
                            errors.add(
                                'Mandatory fields on Property Details should be entered. Please fill all required fields for Property ' +
                                countApp
                            );
                        } else if (
                            String.isNotBlank(appAss.PropIdentified__c) &&
                            appAss.PropIdentified__c == 'Yes' &&
                            ((String.isEmpty(appAss.PropSubType__c)) ||
                             (String.isEmpty(appAss.PropSubTypeDesc__c)) ||
                             (String.isEmpty(appAss.NatureofProp__c)) ||
                             (appAss.Property_Usage__c == null) ||
                             (appAss.Approx_Age_of_Prop__c == null) ||
                             (appAss.Resi_Age__c == null) ||
                             (appAss.Property_Carpet_area_Sq_Ft__c == null))
                        ) {
                            errors.add(
                                'Mandatory fields on Property Details should be entered. Please fill all required fields for Property ' +
                                countApp
                            );
                        } else if (appAss.ServiceableCity__c == false) {
                            errors.add(
                                ' Please Check Property in non serviceable location for Property ' +
                                countApp
                            );
                        }
                    }
                    countApp++;
                }
                  // Legal LAK-10143 against this bug commenting code
              /*  Integer legalCount = 1;
                for (Id assetId : assetMap.keyset()) {
                    Case cv = assetLegalMap.get(assetId);
                    if (cv == null) {
                        errors.add(
                            'Legal is not initiated for Property ' + legalCount
                        );
                        
                    }
                    legalCount++;
                }*/
                //Vetting
                Integer vettingCount = 1;
               
                for (Id assetId : assetMap.keyset()) {
                    Case cv = assetVettingMap.get(assetId);
                    case lgCase = assetLegalMap.get(assetId);
                        /*if (cv == null && lgCase != null  && lgCase.WaiveCPV__c != 'Yes') {
                        if(lgCase.Status != 'Closed'){
                        errors.add(
                        'Legal is not closed ' 
                        );
                        }else{
                        errors.add(
                        'Vetting is not initiated for Property ' + vettingCount
                        );
                        }

                        }*/
                                            /* if(!VettingSchemeln.isEmpty()){
                        if (cv == null){
                        errors.add(
                        'Vetting is not initiated for Property ' + vettingCount
                        );
                        }
                        }
                        vettingCount++;*/
                    
                }
                //TSR
                Integer tsrCount = 1;
                for (Id assetId : assetMap.keyset()) {
                    Case cv = assetTsrMap.get(assetId);
                    if (cv == null) {
                        errors.add(
                            'TSR is not initiated for Property ' + tsrCount
                        );
                    }
                    tsrCount++;
                    
                }
                // Technical
                
                for (Id assetId : assetMap.keyset()) {
                    Integer cnt = 1;
                    List<Case> techCases = assetTechMap.get(assetId);
                    if (
                        techCases == null ||
                        techCases.size() <
                        assetMap.get(assetId).TotalNoOfCasesNeedToRaised__c
                    ) {
                        errors.add('Technical Cases are not initiated for Property ' + cnt);
                    } else {
                        for (Case techCase : techCases) {
                            if (techCase.Status != 'Closed') {
                                errors.add('Please Close Technical Cases for Property ' + cnt);
                            }
                        }
                    }
                    cnt++;
                }
        }
        }
            // Banking
            if (
                decision == 'Approve' ||
                decision == 'Soft Approve' ||
                decision == 'Forward for Soft Approval' ||
                decision == 'Forward for Approve'
            ) {
                // if (RCURecord == null) {
                //     errors.add('RCU is not initiated');
                // }else if(RCURecord != null && (RCURecord.AccountId == null || RCURecord.DateofInitiation__c == null || String.isBlank(RCURecord.ReportResult__c))){
                //     errors.add('Please fill RCU Mandatory fields');
                // }
                // else if(RCURecord != null && String.isBlank(RCURecord.RCU_Hold_Reason__c) && RCURecord.ReportResult__c == 'Hold'){
                //     errors.add('Please fill RCU Mandatory fields');
                // }else if(RCURecord != null && String.isBlank(RCURecord.Final_RCU_status_Reason__c) && (RCURecord.ReportResult__c == 'Refer' || RCURecord.ReportResult__c == 'Fraud' || RCURecord.ReportResult__c == 'Negative')){
                //     errors.add('Please fill RCU Mandatory fields');
                // }
                //if(decision == 'Approve'){ }
                
                // LAK-112 RCU Story 
                if (RCURecord == null) {
                    errors.add('RCU is not initiated');
                }else if( ln[0].LANRCUStatus__c != null && ln[0].LANRCUStatus__c == 'Fraud'){
                    errors.add('Loan RCU Status is '+ln[0].LANRCUStatus__c+'.');
                }//LAK-9889
                else if( ln[0].LANRCUStatus__c != null && (ln[0].LANRCUStatus__c == 'Negative' && rcuDevAvl== false)){
                    errors.add('Loan RCU Status is '+ln[0].LANRCUStatus__c+'.');
                }
                
                
                
                // User Level
                if(decision == 'Soft Approve' || decision == 'Approve'){
                    if (spddList == null && spddList.size() == 0) {
                        errors.add('User record not found in SPDD Aproval Config');
                    } else if (!spddList.isEmpty() && spddList[0].Sanction_Amt__c == null) {
                        errors.add(
                            'Please check Sanction Amount in SPDD Aproval Config is null'
                        );
                    } else if (!ln.isEmpty() && (ln[0].ReqLoanAmt__c == null || ln[0].ReqLoanAmt__c == 0)) {
                        errors.add('Please check the Requested Loan amount');
                    } 
                    //LAK-7726
                    else if (
                        (!spddList.isEmpty() && !ln.isEmpty()) &&
                        (ln[0].TotalLoanAmtInclInsurance__c > spddList[0].Sanction_Amt__c)
                    ) {
                        errors.add(System.Label.UwDecision_Approve_ErrorMessage);
                    }
                }
                //Eligibility Details
                if (
                    !ln.isEmpty() &&
                    (ln[0].Loan_Tenure_Months__c == null ||
                     ln[0].InsAmt__c == null ||
                     ln[0].SanLoanAmt__c == null ||
                     ln[0].SanLoanAmt__c == 0)
                ) {
                    errors.add(System.Label.UwDecision_Eligibility_ErrorMessage);
                }
                // changes for story number LAK-5572
                if(decision == 'Soft Approve' || decision == 'Forward for Soft Approval'){
                    if (bankIds.size() != 1) {
                        errors.add(System.Label.UwDecision_Repayment_ErrorMessage);
                    }
                }
                if(decision == 'Approve' || decision == 'Forward for Approve'){
                    if(bankRecList.size() > 0 && bankRecList != null){
                        //system.debug('bankRecList[0].MICR_Code__c'+bankRecList[0].MICR_Code__c);
                        if (bankIds.size() != 1 || bankRecList[0].MICR_Code__c == NULL) {
                            errors.add(System.Label.UwDecision_Repayment_or_MICR_ErrorMessage);
                        }
                        else if(bankIds.size() != 1 || bankRecList[0].IFSC_Code__c == NULL){
                            errors.add(System.Label.UwDecision_Repayment_or_IFSC_ErrorMessage);
                        }
                    }else if(bankRecList.size() == 0){
                        errors.add(System.Label.UwDecision_Repayment_ErrorMessage);
                    }
                }     
            }
            /* LAK-6286- Paresh Drop1-A AND LAK-7351 Forward to another UW */ 
            list<Applicant__c> appl = new list<Applicant__c>(
                [
                    SELECT 
                    Id,
                    Businessproofavailable__c,
                    CustProfile__c,
                    FullName__c,
                    Type_of_Borrower__c,
                    Constitution__c
                    FROM Applicant__c
                    WHERE LoanAppln__c = :loanId
                ]);
            
            list<Applicant_Income__c> appIncomeList = [SELECT id,Applicant__c, RecordType.DeveloperName  FROM Applicant_Income__c
                                                       WHERE RecordType.DeveloperName ='BankCrSal' AND Applicant__c != null AND 
                                                       Applicant__r.LoanAppln__c =: loanId AND Applicant__r.CustProfile__c = 'SALARIED' ];
            
            Map<Id, list<Applicant_Income__c>> appIncMap = new Map<Id, list<Applicant_Income__c>>(); 
            if(!appIncomeList.isEmpty()){
                for(Applicant_Income__c appInc : appIncomeList){
                    if(appIncMap.containskey(appInc.Applicant__c)){
                        appIncMap.get(appInc.Applicant__c).add(appInc);
                    }else{
                        appIncMap.put(appInc.Applicant__c,new list<Applicant_Income__c>{appInc});
                    }
                }
            }       
            list<ApplBanking__c>  appBankingList = new list<ApplBanking__c> ([SELECT Id,  Appl__c, LoanAppl__c, SalaryAccount__c  FROM ApplBanking__c WHERE Appl__c IN : appIncMap.keySet()]);
            Map<Id, list<ApplBanking__c>> appBankingMap = new Map<Id, list<ApplBanking__c>>(); 
            if(!appBankingList.isEmpty()){
                for(ApplBanking__c appBank : appBankingList){
                    if(appBankingMap.containskey(appBank.Appl__c)){
                        appBankingMap.get(appBank.Appl__c).add(appBank);
                    }else{
                        appBankingMap.put(appBank.Appl__c,new list<ApplBanking__c>{appBank});
                    }
                }
            }
            
            if (
                ((decision == 'Approve' ||
                  decision == 'Forward for Approve' ||
                  decision == 'Soft Approve' ||
                  decision == 'Forward for Soft Approval' ) 
                 && (ln[0].Product__c == 'Home Loan' || ln[0].Product__c == 'Small Ticket LAP')) 
                || (decision == 'Approve' && (ln[0].Product__c == 'Business Loan' || ln[0].Product__c == 'Personal Loan'))
            ){
                //BO Handling Validations
                if(!appl.isEmpty()){
                    
                    Set<Id> appIds = new Set<Id> ();
                    Map<Id,List<LoanApplRelationship__c>> appWithRelationShipMap = new Map<Id,List<LoanApplRelationship__c>>();
                    Map<Id,Applicant__c> appWithIdMap = new Map<Id,Applicant__c>();
                    for (Applicant__c app : appl) {
                        if (app.Constitution__c != null && app.Constitution__c != 'INDIVIDUAL') {
                            appIds.add(app.Id);
                            appWithIdMap.put(app.Id,app);
                        }
                    }
                    if(!appIds.isEmpty()){
                        List<LoanApplRelationship__c> apprelationships = [SELECT Id,Relationship_Type__c,BeneficialOwner__c,Shareholding__c,Loan_Applicant__c FROM LoanApplRelationship__c WHERE Loan_Applicant__c IN : appIds AND Relationship_Type__c IN ('ShareHolder','Beneficial Owner')];
                        if(!apprelationships.isEmpty()){
                            for(LoanApplRelationship__c appRel : apprelationships){
                                if(appWithRelationShipMap.containsKey(appRel.Loan_Applicant__c)){
                                    appWithRelationShipMap.get(appRel.Loan_Applicant__c).add(appRel);
                                }else{
                                    appWithRelationShipMap.put(appRel.Loan_Applicant__c,new List<LoanApplRelationship__c>{appRel});
                                }  
                            }
                        }
                        
                        for(Id appIdNew : appIds){
                            List<LoanApplRelationship__c> relashipsList = appWithRelationShipMap.get(appIdNew);
                            System.debug('appWithIdMap =='+appWithIdMap);
                            Applicant__c app = appWithIdMap!=null ? appWithIdMap.get(appIdNew) :null ;
                            if(relashipsList!=null && !relashipsList.isEmpty()){
                                
                                Decimal totalShareHolding = 0;
                                for (LoanApplRelationship__c loanAppRel : relashipsList) {
                                    if (loanAppRel.Shareholding__c != null) {
                                        totalShareHolding += loanAppRel.Shareholding__c;
                                    }
                                }
                                if (totalShareHolding != 100) {
                                    errors.add('Controlling ownership interest % is not equal to 100% For: ' + app.FullName__c);
                                }
                            }else{
                                errors.add('Please add ShareHolding Details For: ' + app.FullName__c);
                            }
                        }
                        
                    }
                    //   for (Applicant__c app : appl) {
                    //     if (app.Constitution__c != null && app.Constitution__c != 'INDIVIDUAL') {
                    //         if (app.Loan_Applicant_Relationships__r != null && !app.Loan_Applicant_Relationships__r.isEmpty()) {
                    //             Decimal totalShareHolding = 0;
                    //             for (LoanApplRelationship__c loanAppRel : app.Loan_Applicant_Relationships__r) {
                    //                 if (loanAppRel.Shareholding__c != null) {
                    //                     totalShareHolding += loanAppRel.Shareholding__c;
                    //                 }
                    //             }
                    //             if (totalShareHolding != 100) {
                    //                 errors.add('Controlling ownership interest % is not equal to 100% For: ' + app.FullName__c);
                    //             }
                    //         } else {
                    //             errors.add('Please add ShareHolding Details For: ' + app.FullName__c);
                    //         }
                    //     }
                    // }
                    
                }
            }
            if (
                decision == 'Approve' ||
                decision == 'Forward for Approve' ||
                decision == 'Soft Approve' ||
                decision == 'Forward for Soft Approval' ||
                decision == 'Forward for Review'
            ){
                for (Applicant__c app : appl) {
                    if(appIncMap != null && appBankingMap.get(app.Id) != null){
                        if(appBankingMap != null ){
                            if(appBankingMap.containsKey(app.Id)){
                                boolean salaryAccNotPresent =  true;
                                for (ApplBanking__c appBank : appBankingMap.get(app.Id)) {
                                    if(appBank.SalaryAccount__c == true){
                                        salaryAccNotPresent = false;
                                        break;
                                    }
                                }
                                if(salaryAccNotPresent){
                                    errors.add(
                                        app.FullName__c +
                                        ' : ' +
                                        System.Label.BankingDetails_SalaryAcc_ErrorMessage
                                    );
                                }
                            } else{
                                
                            }
                        }
                        
                        
                        
                    }
                }
            }
            //IMD
            // Added ORDER BY CreatedDate DESC For LAK-7732
            List<ApplIMD__c> appImdList = [
                SELECT
                Id,
                PaymentMode__c,
                PaymentGateway__c,
                InstrumentAmt__c,
                InstrumentNo__c,
                InstrumentDt__c,
                BankAccountNo__c,
                DealingBank__c,
                InstrHandvrDateToOps__c,
                BankName__c,
                BankBrch__c,
                IMDStatus__c,
                MICRCode__c FROM
                ApplIMD__c WHERE LoanAppln__c = :loanId ORDER BY CreatedDate DESC
            ];
            
            
            // BRE
            if (
                coutTrackers.size() == 0 ||
                (coutTrackers.size() > 0 && coutTrackers[0].IsInvalid__c)
            ) {
                errors.add('Kindly run BRE before ' + decision);
            }
            
            List<Bureau__c> bureauRespnses = [
                SELECT
                Id,
                Applicant__c,
                Applicant__r.Id,
                BureauAPI__c,
                IsLatest__c,
                ErrorMess__c
                FROM Bureau__c
                WHERE BureauAPI__c = 'Consumer' AND LoanApp__c = :loanId
            ];
            
            // Consumer Bureau
            if (
                decision == 'Approve' ||
                decision == 'Soft Approve' ||
                decision == 'Forward for Soft Approval' ||
                decision == 'Forward for Approve'
            ) {
                
                //Changes Started For for LAK-8221
                List<String> consumerProduct = new List<String>{
                    'Auto Loan',
                        'Housing Loan',
                        'Property Loan',
                        'Loan Against Shares/Securities',
                        'Personal Loan',
                        'Consumer Loan',
                        'Education Loan',
                        'Loan to Professional',
                        'Leasing',
                        'Overdraft',
                        'Two-wheeler Loan',
                        'Loan Against Bank Deposits',
                        'Commercial Vehicle Loan',
                        'GECL Loan Secured',
                        'GECL Loan Unsecured',
                        'Used Car Loan',
                        'Construction Equipment Loan',
                        'Tractor Loan',
                        'Loan on Credit Card',
                        'Mudra Loans - Shishu / Kishor / Tarun',
                        'Microfinance - Business Loan',
                        'Microfinance - Personal Loan',
                        'Microfinance - Housing Loan',
                        'Microfinance - Other',
                        'P2P Personal Loan',
                        'P2P Auto Loan',
                        'P2P Education Loan',
                        'Business Loan - Secured',
                        'Business Loan - General',
                        'Business Loan - Priority Sector - Small Business',
                        'Business Loan - Priority Sector - Agriculture',
                        'Business Loan - Priority Sector - Others',
                        'Business Loan - Unsecured',
                        'Other'
                        };
                            List<String> commercialProduct = new List<String>{
                                'Cash credit',
                                    'Overdraft',
                                    'Demand loan',
                                    'Medium term loan (period above 1 year and up to 3 years)',
                                    'Long term loan (period above 3 years)',
                                    'Lease finance',
                                    'Hire purchase',
                                    'Commercial vehicle loan',
                                    'Equipment financing (construction office medical)',
                                    'Unsecured business loan',
                                    'Short term loan (less than 1 year)',
                                    'Auto Loan',
                                    'Property Loan',
                                    'Gold Loan',
                                    'HealthCare Finance',
                                    'Infrastructure Finance',
                                    'GECL Loan',
                                    'Others'
                                    };
                                        Date minCloseDate = Date.today().addYears(-1);
                List<BureauRespDtl__c> bureauRespDtls = [
                    SELECT
                    Id,
                    NatureOfLoan__c,
                    EMI__c,
                    FinancierName__c,
                    CurrentOs__c,
                    Repayment_Bank__c,
                    RepayAc__c,
                    Treatment__c,
                    Applicant__c,
                    Bureau__c,
                    EMISource__c,
                    Source__c,
                    PrsnlDis__c,
                    Overdues__c,
                    Tenure__c,
                    DisbursalDate__c,
                    LoanAmount__c,
                    CrdFacType__c,
                    IsLatest__c,
                    CloseDate__c,
                    Remarks__c,
                    LoanName__c,
                    LoanCapacity__c,
                    RecordType.Name,
                    LoanApplication__r.BonceBTloanSesingless12mths__c, LoanApplication__r.BonceBTloanSesingtreql12mths__c, LoanApplication__r.BonceBTloanSesingtreql18mths__c
                    FROM BureauRespDtl__c
                    WHERE
                    LoanApplication__c = :loanId
                    AND Applicant__r.Type_of_Borrower__c = 'Financial'
                    AND (RecordType.Name = 'Consumer Obligation'
                         OR RecordType.Name = 'Commercial Obligation')
                    AND Treatment__c != 'Already closed'
                    AND CloseDate__c = NULL
                ];
                if (!bureauRespDtls.isEmpty()) {
                    for (BureauRespDtl__c brd : bureauRespDtls) {
                        Integer closeCal = null;
                        if (brd.CloseDate__c != null) {
                            Date currentDate = Date.today();
                            Date closeDate = brd.CloseDate__c;
                            Integer c1 = currentDate.year() - closeDate.year();
                            Integer c2 = currentDate.month() - closeDate.month();
                            closeCal = (c1 * 12) + c2;
                        }
                        if (
                            (String.isBlank(brd.FinancierName__c) ||
                             String.isBlank(brd.Treatment__c) ||
                             String.isBlank(brd.Repayment_Bank__c) ||
                             brd.CurrentOs__c == null ||
                             brd.EMI__c == null ||
                             brd.Overdues__c == null ||
                             brd.Tenure__c == null ||
                             String.isBlank(brd.RepayAc__c) ||
                             String.isBlank(brd.EMISource__c)) &&
                            brd.Source__c != 'Manual' &&
                            (consumerProduct.contains(brd.NatureOfLoan__c) ||
                             (brd.CrdFacType__c != null &&
                              brd.CrdFacType__c == 'Current' &&
                              CommercialProduct.contains(brd.NatureOfLoan__c))) 
                            // removed above condition for LAK-8489
                            //   &&
                            //     (brd.CloseDate__c == null || (closeCal != null && closeCal <= 12))
                        ) {
                            // system.debug('error coming here first ' + brd.Id);
                            errors.add('Required Data Missing on Obligation Details.');
                            
                        } //lak-9574
                        /* else if (
(brd.LoanApplication__r.BonceBTloanSesingless12mths__c==null) ||
(brd.LoanApplication__r.BonceBTloanSesingtreql12mths__c==null) ||
(brd.LoanApplication__r.BonceBTloanSesingtreql18mths__c==null)
) {
// system.debug('error coming here second ' + brd.Id);
errors.add('Required Data Missing on Obligation Details.');
}*/
                        
                        else if (
                            (String.isBlank(brd.FinancierName__c) ||
                             String.isBlank(brd.Treatment__c) ||
                             String.isBlank(brd.Repayment_Bank__c) ||
                             brd.CurrentOs__c == null ||
                             brd.EMI__c == null ||
                             brd.Tenure__c == null ||
                             String.isBlank(brd.RepayAc__c) ||
                             String.isBlank(brd.LoanName__c) ||
                             String.isBlank(brd.NatureOfLoan__c) ||
                             String.isBlank(brd.LoanCapacity__c) ||
                             brd.DisbursalDate__c == null ||
                             brd.LoanAmount__c == null) && brd.Source__c == 'Manual'
                        ) {
                            // system.debug('error coming here second ' + brd.Id);
                            errors.add('Required Data Missing on Obligation Details.');
                        }
                    }
                }
                
                //lak-9574
                List<LoanAppl__c> loanBT = new List<LoanAppl__c>(
                    [
                        SELECT
                        Id,
                        SchmCode__c, BonceBTloanSesingless12mths__c, BonceBTloanSesingtreql12mths__c, BonceBTloanSesingtreql18mths__c
                        FROM LoanAppl__c
                        WHERE Id = :loanId and SchmCode__c like '%BT%'
                    ]
                );
                if (!loanBT.isEmpty()) {
                    if (
                        (loanBT[0].BonceBTloanSesingless12mths__c==null) ||
                        (loanBT[0].BonceBTloanSesingtreql12mths__c==null) ||
                        (loanBT[0].BonceBTloanSesingtreql18mths__c==null)
                    ) {
                        // system.debug('error coming here second ' + brd.Id);
                        errors.add('Required Data Missing on Obligation Details.');
                    }
                }
                
                //Changes Ended For for LAK-8221
                
                //Start of UW Update for dedupe,hunter,watchout,trackwizz,enpa
                if(apiResp != null && apiResp.size() > 0){
                    for(APICoutTrckr__c apiCount : apiResp){
                        //added apiCount.IntgMsgName__c == 'Dedupe API Token' for LAK-9848
                        if(apiCount.Appl__r.TabName__c != null && apiCount.Appl__c != null && apiCount.LtstRespCode__c == 'Failure' && apiCount.APIName__c == 'Dedupe API Token' && apiCount.IntgMsgName__c == 'Dedupe API Token'){
                            errors.add(
                                apiCount.Appl__r.TabName__c + ' : Dedupe is failed , Please Re-Initiate Dedupe'
                            );
                        }else if(apiCount.LtstRespCode__c == 'Failure' && (apiCount.APIName__c == 'Hunter Token' || apiCount.APIName__c == 'Hunter API')){
                            errors.add(
                                'Hunter failed , Please Re-Initiate Hunter'
                            );
                        }else if(apiCount.Appl__r.TabName__c != null && apiCount.Appl__c != null && apiCount.LtstRespCode__c == 'Failure' && apiCount.APIName__c == 'ENPADeatils'){
                            if(enpaId != null && enpaId.size() > 0 && enpaId.contains(apiCount.Appl__r.Id)){
                                errors.add(
                                    apiCount.Appl__r.TabName__c + ' : ENPA is failed , Please Re-Initiate ENPA'
                                );
                            } 
                        }else if(apiCount.Appl__r.TabName__c != null && apiCount.Appl__c != null && apiCount.LtstRespCode__c == 'Failure' && apiCount.APIName__c == 'ScreeningWachout'){
                            errors.add(
                                apiCount.Appl__r.TabName__c + ' : WatchOut is failed , Please Re-Initiate WatchOut'
                            );
                        }else if(apiCount.Appl__r.TabName__c != null && apiCount.Appl__c != null && apiCount.LtstRespCode__c == 'Failure' && (apiCount.APIName__c == 'Screening API' || apiCount.APIName__c == 'Risk API')){
                            errors.add(
                                apiCount.Appl__r.TabName__c + ' : Trackwizz is failed , Please Re-Initiate Trackwizz'
                            );
                        }
                    }
                }
                //End of UW Update for dedupe,hunter,watchout,trackwizz,enpa
                Set<String> appIds = new Set<String>();
                Map<String, Integer> appWithBureau = new Map<String, Integer>();
                if (bureauRespnses != null && bureauRespnses.size() > 0) {
                    for (Bureau__c burea : bureauRespnses) {
                        if (
                            String.isBlank(burea.ErrorMess__c) || burea.ErrorMess__c == null
                        ) {
                            if (appWithBureau.containsKey(burea.Applicant__c)) {
                                Integer count = appWithBureau.get(burea.Applicant__c);
                                count++;
                                appWithBureau.put(burea.Applicant__c, count);
                            } else {
                                appWithBureau.put(burea.Applicant__c, 1);
                            }
                        }
                    }
                }
                for (Applicant__c app : appMap.values()) {
                    if (app.Constitution__c == 'INDIVIDUAL') {
                        Integer res = appWithBureau.get(app.Id);
                        if (res <= 0 || res == null) {
                            errors.add('Please Run the Bureau for ' + app.FullName__c);
                        }
                    }
                }
                // IMD Details            
            if((ln[0].Product__c!='Business Loan' && ln[0].Product__c!='Personal Loan') ){

                if(appImdList.size()>0 && appImdList != null){
                    if(string.isBlank(appImdList[0].PaymentMode__c)){
                        errors.add('Please Fill the IMD required fields ' + decision);
                        
                    }
                    if(!String.isBlank(appImdList[0].PaymentMode__c) && appImdList[0].PaymentMode__c == 'DD' ){
                        if(appImdList[0].InstrumentAmt__c == null || String.isBlank(appImdList[0].InstrumentNo__c) ||
                           appImdList[0].InstrumentDt__c == null || 
                           appImdList[0].DealingBank__c == null || String.isBlank(appImdList[0].MICRCode__c) ||
                           (appImdList[0].InstrHandvrDateToOps__c == null && (appImdList[0].IMDStatus__c != 'Bounced' && appImdList[0].IMDStatus__c != 'Cancelled')) 
                          ){
                              errors.add('Please Fill the IMD required fields ' + decision);
                          }
                        
                    }
                    if(!String.isBlank(appImdList[0].PaymentMode__c) && appImdList[0].PaymentMode__c == 'Cheque'){
                        if(appImdList[0].InstrumentAmt__c == null || String.isBlank(appImdList[0].InstrumentNo__c) ||
                           appImdList[0].InstrumentDt__c == null || String.isBlank(appImdList[0].BankAccountNo__c) || 
                           appImdList[0].DealingBank__c == null || String.isBlank(appImdList[0].MICRCode__c) ||
                           (appImdList[0].InstrHandvrDateToOps__c == null && (appImdList[0].IMDStatus__c != 'Bounced' && appImdList[0].IMDStatus__c != 'Cancelled')) 
                          ){
                              errors.add('Please Fill the IMD required fields ' + decision);
                          }
                        
                    }
                    if(!String.isBlank(appImdList[0].PaymentMode__c) && (appImdList[0].PaymentMode__c == 'Payment Gateway')){
                        if(String.isBlank(appImdList[0].PaymentGateway__c)
                          ){
                              errors.add('Please Fill the IMD required fields ' + decision);
                          }
                        
                    }
                }
            }
                // Watchout
                
                if(watchoutList != null && watchoutList.size() > 0){
                    for (APIVer__c wout : watchoutList) {
                        if (
                            wout.Result_Relevance__c == 'Accurate Match found' &&
                            string.isBlank(wout.IntDedRsltRmrks__c)
                        ) {
                            errors.add('Please fill Watchout Inputs');
                        }
                    }
                }
                
               // Hunter LAK-10088 commenting for against this bug
                
              /*  List<HunterVer__c> hunterList = [
                    SELECT Id, HunMatchSta__c, HunterStatWhereMatchFound__c
                    FROM HunterVer__c
                    WHERE LoanAplcn__c = :loanId AND IsLatest__c = TRUE
                ];
                if (hunterList != null && hunterList.size() > 0) {
                    for (HunterVer__c hunter : hunterList) {
                        if (
                            string.isNotBlank(hunter.HunMatchSta__c) &&
                            hunter.HunMatchSta__c.toLowerCase() == 'match' &&
                            string.isBlank(hunter.FraudStatusDescription__c) &&
                            string.isBlank(hunter.WorkStatusDescription__c)
                        ) {
                            errors.add('Please fill Hunter Inputs');
                        }
                    }
                }
                */
                // CAM Report
                
                List<DocDtl__c> camReport = [
                    SELECT Id
                    FROM DocDtl__c
                    WHERE
                    LAN__c = :loanId
                    AND DocCatgry__c = 'CAM Report'
                    AND IsLatest__c = TRUE
                ];
                
                if (camReport.size() <= 0) {
                    errors.add('Latest CAM Report not found');
                }
                
                // ESG
                List<ApplRegltry__c> esgRecords = [
                    SELECT Id, FundInESGPol__c
                    FROM ApplRegltry__c
                    WHERE LoanAppln__c = :loanId
                ];
                if (
                    esgRecords.size() > 0 &&
                    esgRecords[0].FundInESGPol__c == 'NON FUNDABLE'
                ) {
                    errors.add('Please Check ESG not Fundable');
                }
                // Loan Amount
                if (!ln.isEmpty() &&  (ln[0].ReqLoanAmt__c < ln[0].TotalLoanAmtInclInsurance__c)) {
                    errors.add(System.Label.SanctionLoanGreaterThanRequestLoanAmount);
                }
                //  co-Applicants
                if (appMap.size() < 2) {
                    errors.add('No Coapplicant Found');
                }
            }
            if (
                decision == 'Approve' ||
                decision == 'Soft Approve' 
                
            ) {
                // Deviation
                if (divIds != null && divIds.size() > 0 && divLevelIds.size()==0) {
                    errors.add('Please check Deviations Not Approved/Rejected');
                } else if (divLevelIds.size() > 0) {
                    System.debug('null spdd level');
                    errors.add(
                        'You do not have level of Deviation to Approve the Loan Application'
                    );
                }
            }
            ///LAK-553
            if (decision == 'Approve'){
                List<Case> caseList = [
                    SELECT
                    Id,
                    Final_Status_of_Field_Verification_by_un__c,
                    CreatedDate,
                    Loan_Application__c,
                    Status,
                    RecordType.name
                    FROM
                    Case WHERE Loan_Application__c = :loanId and RecordType.name = 'LIP Vendor case' ORDER BY CreatedDate DESC
                ];
                
                List<Case> negativeCases = new List<Case>();
                List<Case> emptyCases = new List<Case>();
                if (caseList != null && caseList.size() > 0) {
                    for (Case c : caseList) {
                        if (c.Final_Status_of_Field_Verification_by_un__c == 'Negative') {
                            negativeCases.add(c);
                        }
                        if((c.Final_Status_of_Field_Verification_by_un__c == '' || c.Final_Status_of_Field_Verification_by_un__c == null) && c.Status == 'Closed'){
                            emptyCases.add(c);
                        }
                    }
                    if(negativeCases != null && negativeCases.size()>0){
                        errors.add(
                            'Cannot Approve as LIP Verification Report is Negitive.'
                        );
                    }
                    
                    if(emptyCases != null && emptyCases.size()>0){
                        errors.add(
                            'Cannot Approve as LIP Verification Report is In Progress.'
                        );
                    }
                }
                
            }
            
            List<LoanAppeal__c> LoanAppealList = new List<LoanAppeal__c>();//LAK-8504
            LoanAppealList = [SELECT Id, Status__c, LoanAppl__c FROM LoanAppeal__c  WHERE LoanAppl__c =:loanId AND RecordType.Name ='Loan Term Negotiation' AND ( Status__c ='New' OR Status__c ='In Progress')  ];
            if(!LoanAppealList.isEmpty() || LoanAppealList.size()>0 ){
                errors.add(
                    'Case cannot be approved/Soft approved without approving the case.'
                );
            }//LAK-8504
            if (
                decision == 'Approve' ||
                decision == 'Soft Approve' ||
                decision == 'Forward for Soft Approval' ||
                decision == 'Forward for Approve'
            ){
                //add this for LAK-7930 Manual Banking Upload Validations
           		List<ApplBanking__c> conApplBanking = [
                    SELECT
                    Id, Appl__r.CustProfile__c,Appl__r.FullName__c,
                    (SELECT
                        Id FROM Applicant_Banking_Detail__r)
                    FROM ApplBanking__c
                    WHERE
                    Appl__r.Type_of_Borrower__c = 'Financial'
                    AND LoanAppl__c = :loanId
                    AND Type__c = 'Banking Summary'
                ];
                system.debug('conApplBanking>>>>'+conApplBanking.size());
                for(ApplBanking__c conBnk: conApplBanking){
                    if(conBnk.Applicant_Banking_Detail__r.size() > 0 && conBnk.Applicant_Banking_Detail__r != null){
                        if(conBnk.Appl__r.CustProfile__c == 'SALARIED'){
                            if(conBnk.Applicant_Banking_Detail__r.size() < 6){
                                errors.add(conBnk.Appl__r.FullName__c +' should have Atleast 6 Month Bank Statment.');
                            }
                        }else if(conBnk.Appl__r.CustProfile__c == 'SELF EMPLOYED PROFESSIONAL' || conBnk.Appl__r.CustProfile__c == 'SELF EMPLOYED NON PROFESSIONAL'){
                            if(conBnk.Applicant_Banking_Detail__r.size() < 12){
                                errors.add(conBnk.Appl__r.FullName__c +' should have Atleast 12 Month Bank Statment.');
                            }    
                        }
                    }
                    
                }
            }
            return errors;
        } catch (exception e) {
            system.debug(
                'error occured ' +
                e.getMessage() +
                'get line number ' +
                e.getLineNumber() +
                ' get stack trace ' +
                e.getStackTraceString()
            );
            throw new AuraHandledException(e.getMessage());
        }
    }
    /*@AuraEnabled
    public static List<string> validateDataBankStateCri(String loanId){
        List<string> errorForBnk=new List<string>();
        List<MasterData__c> masDataList=[select id, CustomerProfile__c, EligibilityProgram__c, Type__c, StatementPeriodNumber__c, Product__c from MasterData__c where Type__c ='Bank Statement Criteria' ];
        set<id> applIds= new set<id>();
        map<id, Applicant__c> idWithApp= new map<id, Applicant__c>();
        for(Applicant__c app: appRecList){
            applIds.add(app.Id);
            system.debug('app.Id'+app.Id);
            idWithApp.put(app.Id, app);
        }
        
        List<ApplBanking__c> appBnkList=[select id, Appl__c,Appl__r.FullName__c, Appl__r.Type_of_Borrower__c, Type__c, (SELECT Id,Year__c, Month__c FROM Applicant_Banking_Detail__r) from ApplBanking__c where Appl__c IN: applIds  AND Type__c = NULL AND Appl__r.Type_of_Borrower__c = 'Financial' ];
        Map<Id, List<ApplBanking__c>> mapOfAppIdWithBnkRec= new Map<Id, List<ApplBanking__c>>();
        Map<Id, List<ApplBankDetail__c>> mapOfAppIdWithBnkDetailRec= new Map<Id, List<ApplBankDetail__c>>();
        for (ApplBanking__c appBnk : appBnkList) {
            if (!mapOfAppIdWithBnkDetailRec.containsKey(appBnk.Appl__c)) {
                mapOfAppIdWithBnkDetailRec.put(appBnk.Appl__c, new List<ApplBankDetail__c>());
            }
            list<ApplBankDetail__c> appBnkDetailList=appBnk.Applicant_Banking_Detail__r;
            mapOfAppIdWithBnkDetailRec.get(appBnk.Appl__c).addAll(appBnkDetailList);
            if (!mapOfAppIdWithBnkRec.containsKey(appBnk.Appl__c)) {
                mapOfAppIdWithBnkRec.put(appBnk.Appl__c, new List<ApplBanking__c>());
            }
            mapOfAppIdWithBnkRec.get(appBnk.Appl__c).add(appBnk);
        }
        system.debug('mapOfAppIdWithBnkDetailRec'+mapOfAppIdWithBnkDetailRec.keySet());
        system.debug('mapOfAppIdWithBnkRec'+mapOfAppIdWithBnkRec.keySet());
        for(id applId: mapOfAppIdWithBnkDetailRec.keySet()){
            List<ApplBankDetail__c> appBnkDetailList=mapOfAppIdWithBnkDetailRec.get(applId);
            List<ApplBanking__c> bnkRecList=mapOfAppIdWithBnkRec.get(applId);
            system.debug('appBnkDetailList.size'+appBnkDetailList.size());
            system.debug('bnkRecList.size'+bnkRecList.size());
            set<string> monthYearSet=new set<string>();
            if(appBnkDetailList.size()>0 && bnkRecList.size()>0){
                for(ApplBankDetail__c bnkDe: appBnkDetailList){
                    string monthYear=bnkDe.Month__c+'-'+bnkDe.Year__c;
                    monthYearSet.add(monthYear);
                }
            }
            system.debug('monthYearSet.size'+monthYearSet.size());
            if(!string.isBlank(idWithApp.get(applId).CustProfile__c) && masDataList.size() > 0){
                
                for(MasterData__c masData: masDataList){
                    system.debug('masData.CustomerProfile__c'+masData.CustomerProfile__c);
                    if(idWithApp.get(applId).CustProfile__c==masData.CustomerProfile__c && masData.Product__c.contains(loanRec.Product__c)){
                        system.debug('idWithApp.get(applId).CustProfile__c'+idWithApp.get(applId).CustProfile__c);
                        if(monthYearSet.size()< masData.StatementPeriodNumber__c){
                            errorForBnk.add(idWithApp.get(applId).FullName__c+': please upload atleast '+masData.StatementPeriodNumber__c + ' Banking Detail Statment.');
                        }
                    }
                }
            }
            
            
        }
        system.debug('errorForBnk'+errorForBnk);
        
        return errorForBnk;
    } */
}