public without sharing class SendToOpsValidations {
    @AuraEnabled
    public static List<String> validateData(String loanId) {
        List<String> errors = new List<String>();
        try {
            Set<String> sectionNames = new Set<String>();
            Set<String> screenNames = new Set<String>();
            Map<string, Case> mapOfappplicantAndAddressToCpv = new Map<string,Case>();
            
            
                //LAK-9154
                list<APIVer__c> lgitationList = [
                    SELECT
                    Id,
                    RiskType__c,
                    LoanAplcn__c,
                    Appl__c,
                    Appl__r.FullName__c
                    FROM APIVer__c
                    WHERE LoanAplcn__c = :loanId AND RecordType.DeveloperName = 'CrimeCheck' AND IsLatest__c  = True
                ];
                
                        system.debug('ligit.loanId'+ loanId);
                        system.debug('ligit.lgitationList :'+ lgitationList);

                if (lgitationList != null && lgitationList.size() > 0) {
                    for (APIVer__c ligit : lgitationList) {
                        system.debug('ligit.RiskType__c :'+ ligit.RiskType__c);
                        if (ligit.RiskType__c == 'High Risk' || ligit.RiskType__c == 'Very High Risk'
                            ) {
                                errors.add(
                                    ligit.Appl__r.FullName__c +
                                    ': Please Re-Initiate Litigation detailed check as the case has been marked as High Risk/Very High Risk'
                                );
                            }
                    }

                }

                //Changes Ended for LAK-9154
            
            LoanAppl__c loan = [
                SELECT
                Id,
                Stage__c,
                Product__c,
                SubStage__c,
                DisbursedAmount__c,
                TotalLoanAmountIncCharges__c,
                Final_Loan_Disbursal_Amount__c,
                DisbursalType__c,
                DocGenReRequired__c,
                Disbursal_Document_Required__c,
          		App_Form_End_Use_Letter_Doc_Required__c,
                EffectiveNextIntStartDt__c,
                PendingDisbursalAmount__c,
                SchemeId__c,
                OwnContriCash__c,
                LANRCUStatus__c
                FROM LoanAppl__c
                WHERE Id = :loanId
            ];
            
            
            Map<Id, Applicant__c> appMap = new Map<Id, Applicant__c>(
                [
                    SELECT
                    Id,
                    CustProfile__c,
                    Constitution__c,
                    Type_of_Borrower__c,
                    TabName__c,
                    FullName__c,
                    UCID__c,
                    OTP_Verified__c,
                    Is_Physical_Consent_Validated__c,
                    ApplType__c,
                    (
                        SELECT
                        id,
                        DocCatgry__c,
                        DocTyp__c,
                        DocSubTyp__c,
                        TargetDt__c,
                        DocStatus__c,
                        Applicant_KYC__r.kycDoc__c,
                        Applicant_KYC__r.AadharNo__c,
                        Applicant_KYC__r.DLNo__c,
                        Applicant_KYC__r.PassNo__c,
                        Applicant_KYC__r.VotIdEpicNo__c,
                        Applicant_KYC__r.OtherDocName__c
                        FROM Applicant_Document_Details__r
                        WHERE DocCatgry__c = 'Insurance documents'
                    )
                    FROM Applicant__c
                    WHERE LoanAppln__c = :loanId AND ApplType__c IN ('P', 'C', 'G')
                ]
            );
            List<Disbursement__c> disburseList = [
                SELECT
                Id,
                ApplicationID__c,
                Appl_Name__c,
                Product__c,
                Split_Disbursement_s_Amount__c,
                Scheme__c,
                Loan_Tenu__c,
                Total_Disb_Amt__c,
                Disbur_To__c,
                No_of_Disbur__c,
                Princ_Rec_on__c,
                Princ_Start_Date__c,
                Disbur_No__c,
                Disbur_Desrp__c,
                Date_of_Disbur__c,
                DisbrDiscription__c,
                Disbur_Status__c,
                Loan_Appli__c,
                Pend_Disbur_Amt__c,
                Loan_Appli__r.DisbursalType__c,
                Loan_Appli__r.DisbursedAmount__c,
                Loan_Appli__r.Final_Loan_Disbursal_Amount__c,
                Loan_Appli__r.PendingDisbursalAmount__c,
                (
                    SELECT
                    Id,
                    Disbur_To__c,
                    Split_Cheque_Amt__c,
                    Date_of_Disbur__c,
                    Custo_Name__c,
                    Pay_Mode__c,
                    Penny_Drop_Nm_Sta__c,
                    Pay_City_Id__c,
                    Fund_Transf_Mode__c,
                    IFSC_Detail__c,
                    Cheq_DD_Date__c,
                    Cheq_DD_No__c,
                    Effec_Date__c,
                    Fedbank_Acc_Nm__c,
                    Payable_At__c,
                    Fedbank_Acc_No__c,
                    Cheq_Favor_Dets__c,
                    Remarks__c,
                    Cheq_Favor_Acc_No__c,
                    Benef_Nm_of_Penny_Drop__c,
                    DisburseRela__c,
                    Payment_to__c,
                    RefId__c,
                    RemitterAccNo__c,
                    BeneficiaryAccNo__c,
                    UTR__c,
                    ResponseReason__c,
                    CashBankAccountId__c,
                    OpsVer__c,
                    DisburseAmt__c
                    FROM Split_Disbursements__r
                )
                FROM Disbursement__c
                WHERE Loan_Appli__c = :loanId
            ];
            
            List<PDC__c> pdcList = [
                SELECT
                Loan_Application__c,
                Cheque_Amount__c,
                Cheque_Number_To__c,
                Cheque_Number_From__c,
                No_of_Cheques__c,
                Cheque_Purpose__c,
                Account_No__c,
                MICR_Code__c
                FROM PDC__c
                WHERE
                PDC_Type__c = 'SPDC'
                AND Loan_Application__c = :loanId
                AND Repayment_Account__r.Is_Active__c = TRUE
            ];
            
            String loanProductCode;
            List<Case> rcuCases = [
                SELECT Id, Loan_Application__c, ReportResult__c
                FROM Case
                WHERE RecordType.Name = 'RCU' AND Loan_Application__c = :loanId
            ];
            if (loan != null) {
                if (loan.Product__c == 'Home Loan') {
                    loanProductCode = '5935';
                } else if (loan.Product__c == 'Small Ticket LAP') {
                    loanProductCode = '5934';
                }
            }
            List<Deviation__c> postSanAutoDevRecrds = [
                SELECT id
                FROM Deviation__c
                WHERE
                DeviationCategory__c = 'Post Sanction Auto Deviation'
                AND LoanAppln__c = :loanId
                AND Deviation__c = :loanProductCode
            ];
            
            // validation for documents for LAK-9901 start
            if (
                loan.Stage__c == 'Post Sanction' && loan.subStage__c == 'Ops Query'
            ){
                List<DocDtl__c> LoanAgreeLetter = [ SELECT Id, DocStatus__c, DocTyp__c FROM DocDtl__c WHERE LAN__c = :loanId AND DocTyp__c = 'Loan Agreement'
                ]; 
                if (LoanAgreeLetter.size() == 0 || loan.Disbursal_Document_Required__c) {
                    errors.add('Please Generate Disbursal Documents.');
                }
                List<DocDtl__c> LoanAppliLetter = [
                    SELECT Id, DocStatus__c, DocTyp__c
                    FROM DocDtl__c
                    WHERE LAN__c = :loanId AND DocTyp__c = 'Application Form'
                ]; 
                if (LoanAppliLetter.size() == 0 || loan.App_Form_End_Use_Letter_Doc_Required__c) {
                    errors.add('Please Generate Application Form and End Use Letter.');
                }
            }
            
            // validation for documents for LAK-9901 end
            
            Set<String> docCate = new Set<String>{
                'Mandatory Post Sanction Documents',
                    'Additional Post Sanction Documents',
                    'Property Documents'
                    };
                        Set<String> docStatus = new Set<String>{ 'OTC', 'PDD', 'Waiver' };
                            if (loan.Stage__c == 'Post Sanction' || loan.Stage__c == 'Disbursed') {
                                List<DocDtl__c> docDtlRecrds = [
                                    SELECT Id, Appr_Actn__c
                                    FROM DocDtl__c
                                    WHERE
                                    LAN__c = :loanId
                                    AND DocCatgry__c IN :docCate
                                    AND DocStatus__c IN :docStatus
                                ];
                                if (docDtlRecrds != null && docDtlRecrds.size() > 0) {
                                    Boolean docApproved = true;
                                    for (DocDtl__c docDtl : docDtlRecrds) {
                                        if (docDtl.Appr_Actn__c != 'Approved') {
                                            docApproved = false;
                                            break;
                                        }   
                                    }
                                    if (!docApproved) {
                                        errors.add(System.Label.send_to_ops_decoument_appro_error);
                                    }
                                }
                                
                                Set<String> devCat = new Set<String>{
                                    'Legal',
                                        'Post Sanction Auto Deviation',
                                        'Disbursal'
                                        };
                                            List<Deviation__c> devRecrds = [
                                                SELECT Id, Appr_Actn__c
                                                FROM Deviation__c
                                                WHERE
                                                LoanAppln__c = :loanId
                                                AND ((DeviationCategory__c IN :devCat
                                                     OR (BRE__r.Call_Id__c = '5.0'
                                                         AND BRE__r.IsLatest__c = TRUE
                                                         AND Dev_Type__c = 'System'))
                                                    OR (DeviationCategory__c = null AND  (Dev_Type__c = 'Manual' OR (Dev_Type__c = 'System' AND BRE__r.IsLatest__c = TRUE))))
                                                ORDER BY DeviationCategory__c
                                            ];
                                if (devRecrds != null && devRecrds.size() > 0) {
                                    Boolean divApproved = true;
                                    for (Deviation__c devRec : devRecrds) {
                                        if (devRec.Appr_Actn__c != 'Approved') {
                                            divApproved = false;
                                            break;
                                        }
                                    }
                                    if (!divApproved) {
                                        errors.add(System.Label.send_to_ops_deviation_appro_error);
                                    }
                                }
                                
                                if (pdcList != null && pdcList.size() > 0) {
                                    Decimal checkCount = 0;
                                    for (PDC__c pdc : pdcList) {
                                        if (pdc.No_of_Cheques__c != null) {
                                            checkCount += pdc.No_of_Cheques__c;
                                        }
                                        if (
                                            String.isBlank(pdc.Cheque_Number_To__c) ||
                                            String.isBlank(pdc.Cheque_Number_From__c) ||
                                            pdc.Cheque_Amount__c == null ||
                                            String.isBlank(pdc.MICR_Code__c) ||
                                            String.isBlank(pdc.Cheque_Purpose__c) ||
                                            String.isBlank(pdc.Account_No__c)
                                        ) {
                                            errors.add(
                                                'Please provide all required information for SPDC on Repayment Screen.'
                                            );
                                            break;
                                        }
                                    }
                                    if (checkCount < 3) {
                                        errors.add('Atleast 3 No Of Cheques should be in SPDC');
                                    }
                                } else {
                                    errors.add(
                                        'Atleast 1 SPDC record should be there on Repayment Screen'
                                    );
                                }
                                
                                Boolean opsQuery = false;
                                for (NDC__c ndc : [
                                    SELECT Id, OpsQuery__c, ScreenNames__c, NDC_Section__c
                                    FROM NDC__c
                                    WHERE LoanAppl__c = :loanId AND IsInvalid__c = FALSE
                                ]) {
                                    if (ndc.OpsQuery__c) {
                                        // opsQuery = true;
                                        //LAK-9355
                                        if (ndc.ScreenNames__c != null) {
                                            if(ndc.ScreenNames__c == 'Pricing Approval'){
                                                screenNames.add('ROI/PF Correction');
                                            }else{
                                                screenNames.add(ndc.ScreenNames__c);
                                            }
                                        } else if (ndc.NDC_Section__c != null) {
                                            sectionNames.add(ndc.NDC_Section__c);
                                        }
                                    }
                                }
                                if (screenNames != null && screenNames.size() > 0) {
                                    string allstring = string.join(screenNames, ',');
                                    errors.add(
                                        'Please respond on Query Before Sending the Application back to Ops : (' +
                                        allstring +
                                        ')'
                                    );
                                }
                                if (sectionNames != null && sectionNames.size() > 0) {
                                    string allstring = string.join(sectionNames, ',');
                                    errors.add(
                                        'Please respond on Query Before Sending the Application back to Ops : (' +
                                        allstring +
                                        ')'
                                    );
                                }
                            }
            
            if (disburseList != null && disburseList.size() > 0) {
                for (Disbursement__c disurse : disburseList) {
                    if (
                        disurse.Total_Disb_Amt__c != null &&
                        String.isNotBlank(disurse.Disbur_To__c) &&
                        ((String.isNotBlank(disurse.Princ_Rec_on__c) &&
                          disurse.Princ_Start_Date__c != null &&
                          loan.DisbursalType__c == 'MULTIPLE') ||
                         loan.DisbursalType__c == 'SINGLE') &&
                        disurse.Date_of_Disbur__c != null &&
                        String.isNotBlank(disurse.DisbrDiscription__c)
                    ) {
                        if (disurse.DisbrDiscription__c == 'TRANCHE-1') {
                            if (
                                disurse.Split_Disbursements__r != null &&
                                disurse.Split_Disbursements__r.size() > 0
                            ) {
                                for (
                                    Split_Disbur__c splitDis : disurse.Split_Disbursements__r
                                ) {
                                    if (
                                        String.isEmpty(splitDis.Pay_Mode__c) ||
                                        String.isEmpty(splitDis.Disbur_To__c) ||
                                        splitDis.Split_Cheque_Amt__c == null ||
                                        String.isEmpty(splitDis.Fedbank_Acc_Nm__c) ||
                                        String.isEmpty(splitDis.Payable_At__c)
                                    ) {
                                        errors.add(
                                            'Tranche and Multi Tranche details has to be mandatorily filled. Atleast one Split Disbursal row has to be there.'
                                        );
                                        break;
                                    } else {
                                        if (
                                            (splitDis.Pay_Mode__c == 'Cheque' ||
                                             splitDis.Pay_Mode__c == 'Draft') &&
                                            (splitDis.Cheq_DD_Date__c == null ||
                                             splitDis.Cheq_DD_No__c == null)
                                        ) {
                                            errors.add(
                                                'Tranche and Multi Tranche details has to be mandatorily filled. Atleast one Split Disbursal row has to be there.'
                                            );
                                            break;
                                        }
                                    }
                                }
                            } else {
                                errors.add(
                                    'Tranche and Multi Tranche details has to be mandatorily filled. Atleast one Split Disbursal row has to be there.'
                                );
                                break;
                            }
                        }
                    } else {
                        errors.add(
                            'Tranche and Multi Tranche details has to be mandatorily filled. Atleast one Split Disbursal row has to be there.'
                        );
                        break;
                    }
                }
            }
            if (disburseList != null && disburseList.size() > 0) {
                for (Disbursement__c disurse : disburseList) {
                    if (disurse.Loan_Appli__r.PendingDisbursalAmount__c != 0) {
                        errors.add(
                            'Sum of Disbursement Amount mismatched with Loan Disbursal Amount.'
                        );
                        break;
                    } else {
                        if (
                            disurse.Split_Disbursements__r != null &&
                            disurse.Split_Disbursements__r.size() > 0 &&
                            disurse.Split_Disbursement_s_Amount__c != null
                        ) {
                            Decimal splitSumAmount = disurse.Split_Disbursement_s_Amount__c;
                            Decimal disbAmount = disurse.Total_Disb_Amt__c != null
                                ? disurse.Total_Disb_Amt__c
                                : 0;
                            if (splitSumAmount != disbAmount) {
                                errors.add(
                                    'Sum of Split Disbursement(s) Amount is not aligned with Disbursement Amount. Please provide correct details.'
                                );
                                break;
                            }
                        } else if (
                            disurse.DisbrDiscription__c == 'TRANCHE-1' &&
                            disurse.Split_Disbursements__r == null
                        ) {
                            errors.add(
                                'Split Disbursement(s) missing for TRANCHE-1. Please provide Split Disbursement Details'
                            );
                            break;
                        }
                    }
                }
            }
            if (loan.Stage__c == 'Post Sanction') {
                List<DocumentCheckController.DocDetailWrapper> ndcDocs = DocumentCheckController.ndcDocumentCheck(
                    loanId
                );
                if (ndcDocs != null && ndcDocs.size() > 0) {
                    for (DocumentCheckController.DocDetailWrapper item : ndcDocs) {
                        errors.add(
                            item.docCategry +
                            ' : Please Upload Document For ' +
                            item.docDetName +
                            ' on Ndc Screen.'
                        );
                    }
                }
            }
            if (loan.Stage__c == 'Post Sanction') {
                // List<String> expiryList = VerificationExpiryController.checkExpiry(
                //   loanId
                // );
                // if (expiryList != null && expiryList.size() > 0) {
                //   String expApiNames;
                //   for (String expName : expiryList) {
                //     expApiNames += expName + ',';
                //   }
                //   expApiNames = expApiNames.removeEnd(',');
                //   errors.add('Verification Expired for ' + expApiNames);
                // }
                List<String> expiryList = VerificationExpiry.expiryDetail(loanId);
                if (expiryList != null && expiryList.size() > 0) {
                    for (String expName : expiryList) {
                        errors.add(expName + ' is expired');
                    }
                }
                List<APICoutTrckr__c> coutTrackers = [
                    SELECT Id, LtstRespCode__c, IsInvalid__c
                    FROM APICoutTrckr__c
                    WHERE APIName__c = 'Crif Auth Login' AND LAN__c = :loanId
                ];
                if (
                    coutTrackers.size() == 0 ||
                    (coutTrackers.size() > 0 && coutTrackers[0].IsInvalid__c)
                ) {
                    errors.add(System.Label.Send_to_Oops_BRE_Error_Message);
                }
                
                //LAK-6401
                if (
                    rcuCases != null &&
                    rcuCases.size() > 0 &&
                    rcuCases[0].ReportResult__c == 'Pending'
                ) {
                    if (postSanAutoDevRecrds.size() == 0) {
                        errors.add(
                            'RCU status is Pending. Kindly add applicable deviation'
                        );
                    }
                }
                //LAK-6401
            }
            
            List<ValidateRequiredFieldsAndDoc.Responce> valRespData = ValidateRequiredFieldsAndDoc.getValidationReport(
                loanId
            );
            for (ValidateRequiredFieldsAndDoc.Responce res : valRespData) {
                if (res.validated == false) {
                    String resp = res.applicantName + ' : ' + res.errorMessage;
                    errors.add(resp);
                }
            }
            
            if (loan.Stage__c == 'Post Sanction' && loan.subStage__c == 'Ops Query') {
                if (loan.PendingDisbursalAmount__c != 0) {
                    errors.add('Pending Disbursal amount should be 0');
                }
                if (loan.EffectiveNextIntStartDt__c < Date.today()) {
                    errors.add(
                        'Effective/interest date should be equal to Today Date/Future Date'
                    );
                }
                List<Disbursement__c> firstTracncheDets = [
                    SELECT Id, Date_of_Disbur__c
                    FROM Disbursement__c
                    WHERE Loan_Appli__c = :loanId AND DisbrDiscription__c = 'TRANCHE-1'
                ];
                
                if (
                    firstTracncheDets != null &&
                    firstTracncheDets.size() > 0 &&
                    firstTracncheDets[0].Date_of_Disbur__c != Date.today()
                ) {
                    errors.add(
                        'First Tranche Date of Disbursement should be Equal to today date'
                    );
                }
            }
            
            //Enach Rejection Reason Validation
            if (loan.Stage__c == 'Post Sanction' && loan.subStage__c == 'Ops Query') {
                List<DocDtl__c> otherImpDocs = [
                    SELECT
                    Id,
                    OpsVer__c,
                    DocTyp__c,
                    NDCDataEntry__c,
                    DocSubTyp__c,
                    Case__r.CaseType__c,
                    Case__r.ApplAssetId__c,
                    ApplAsset__c,
                    DocCatgry__c,
                    OriDoc__c
                    FROM DocDtl__c
                    WHERE
                    LAN__c = :loanId
                    AND (DocTyp__c = 'CAM Report'
                         OR DocTyp__c = 'Sanction Letter'
                         OR  (DocTyp__c ='Application Form' AND DocCatgry__c = 'System Generated Documents')
                         OR DocCatgry__c = 'Property Documents'
                         OR DocCatgry__c = 'Case Documents')
                    AND IsLatest__c = TRUE
                ];
                
                List<NACH__c> nachRecrds = [
                    SELECT Id, eNACH_Rejection_Reasons__c, eNACH_Registration_Status__c
                    FROM NACH__c
                    WHERE
                    LoanAppl__c = :loanId
                    AND RepayAcc__c != NULL
                    AND RepayAcc__r.Repayment_Mode__c = 'NACH'
                    AND RepayAcc__r.Is_Active__c = TRUE
                    AND Mandate_Type__c = 'Enach'
                    AND IsActive__c = TRUE
                ];
                if (nachRecrds != null && nachRecrds.size() > 0) {
                    List<RejectReason_eNACH__c> rejectionRason = [
                        SELECT
                        id,
                        Actionable__c,
                        ImpactOnJourney__c,
                        RejectionReason__c,
                        ValidationMsg__c,
                        Notification__c
                        FROM RejectReason_eNACH__c
                        WHERE RejectionReason__c = :nachRecrds[0].eNACH_Rejection_Reasons__c
                    ];
                    if (
                        rejectionRason != null &&
                        rejectionRason.size() > 0 &&
                        String.isNotBlank(rejectionRason[0].ValidationMsg__c)
                    ) {
                        errors.add(rejectionRason[0].ValidationMsg__c);
                    }
                }
                
                Map<String, List<DocDtl__c>> docDtlMap = new Map<String, List<DocDtl__c>>();
                if (otherImpDocs != null && otherImpDocs.size() > 0) {
                    for (DocDtl__c docDtl : otherImpDocs) {
                        if (docDtlMap.containsKey(docDtl.DocCatgry__c)) {
                            docDtlMap.get(docDtl.DocCatgry__c).add(docDtl);
                        } else {
                            docDtlMap.put(docDtl.DocCatgry__c, new List<DocDtl__c>{ docDtl });
                        }
                    }
                }
                if (docDtlMap != null && docDtlMap.size() > 0) {
                    List<DocDtl__c> otherImpDocsRecs = new List<DocDtl__c>();
                    if (
                        docDtlMap.get('CAM Report') != null &&
                        docDtlMap.get('CAM Report').size() > 0
                    ) {
                        otherImpDocsRecs.addAll(docDtlMap.get('CAM Report'));
                    }
                    if (
                        docDtlMap.get('Sanction Letter') != null &&
                        docDtlMap.get('Sanction Letter').size() > 0
                    ) {
                        otherImpDocsRecs.addAll(docDtlMap.get('Sanction Letter'));
                    }
                    if (
                        docDtlMap.get('System Generated Documents') != null &&
                        docDtlMap.get('System Generated Documents').size() > 0
                    ) {
                        otherImpDocsRecs.addAll(docDtlMap.get('System Generated Documents'));
                    }
                    List<DocDtl__c> propertyDocs = new List<DocDtl__c>();
                    if (
                        docDtlMap.get('Property Documents') != null &&
                        docDtlMap.get('Property Documents').size() > 0
                    ) {
                        propertyDocs.addAll(docDtlMap.get('Property Documents'));
                    }
                    List<DocDtl__c> caseDocts = new List<DocDtl__c>();
                    if (
                        docDtlMap.get('Case Documents') != null &&
                        docDtlMap.get('Case Documents').size() > 0
                    ) {
                        caseDocts.addAll(docDtlMap.get('Case Documents'));
                    }
                    if (otherImpDocsRecs != null && otherImpDocsRecs.size() > 0) {
                        for (DocDtl__c docDt : otherImpDocsRecs) {
                            if (String.isBlank(docDt.NDCDataEntry__c)) {
                                errors.add('NDC DataEntry need to be filled on Ndc Stepper');
                            }
                        }
                    }
                    if (loan.Product__c != 'Business Loan' && loan.Product__c == 'Personal Loan') {
                            
                        
                        if (propertyDocs != null && propertyDocs.size() > 0) {
                        for (DocDtl__c docDt : propertyDocs) {
                            if (
                                String.isBlank(docDt.OriDoc__c) && docDt.ApplAsset__c != null
                            ) {
                                errors.add(
                                    'Original Document field value need to be filled on Ndc Stepper'
                                );
                            }
                        }
                    }
                    if (caseDocts != null && caseDocts.size() > 0) {
                        for (DocDtl__c docDt : caseDocts) {
                            if (
                                String.isBlank(docDt.NDCDataEntry__c) &&
                                docDt.Case__r.CaseType__c != null &&
                                (docDt.Case__r.CaseType__c == 'Technical' ||
                                docDt.Case__r.CaseType__c == 'Vetting' ||
                                docDt.Case__r.CaseType__c == 'Legal' ||
                                docDt.Case__r.CaseType__c == 'TSR') &&
                                docDt.Case__r.ApplAssetId__c != null
                                ) {
                                    errors.add('NDC DataEntry need to be filled on Ndc Stepper');
                                }
                            }
                        }
                        
                    }
                    
                    
                }
            }
            //LAK-551
            if (loan.Product__c != 'Business Loan' && loan.Product__c == 'Personal Loan') {

            if (
                loan.Stage__c == 'Post Sanction' &&
                (loan.SubStage__c == 'Data Entry' ||
                 loan.SubStage__c == 'Ops Query')
            ) {
                boolean tsrStatus = false;
                list<Case> lstCases = [SELECT id,FinalStatusTSRReportFromHLM__c,ApplAssetId__c,WaiveCPV__c from Case where Loan_Application__c =:loanId AND RecordType.DeveloperName ='TSR' AND ApplAssetId__c != NULL AND WaiveCPV__c !='Yes']; 
                if(!lstCases.isEmpty()){
                    for(Case c : lstCases){
                        if(c.FinalStatusTSRReportFromHLM__c != 'Positive'){
                            tsrStatus =true;
                        }
                    }
                }
                
                if (tsrStatus) {
                    errors.add(
                        'TSR Report Result must be positive.'
                    );
                }
            }
            
              //LAK-552
        if (
        loan.Stage__c == 'Post Sanction' &&
        (loan.SubStage__c == 'Data Entry' ||
        loan.SubStage__c == 'Ops Query')
        ) {
            boolean tsrStatus = false;
            list<Case> lstCases = [SELECT id,FinalStatusTSRReportFromHLM__c,WaiveCPV__c from Case where Loan_Application__c =:loanId AND RecordType.DeveloperName ='Vetting' AND WaiveCPV__c !='Yes'  ORDER By CreatedDate DESC LIMIT 1]; 
             if(!lstCases.isEmpty()){
                 for(Case c : lstCases){
                if(c.FinalStatusTSRReportFromHLM__c != 'Positive'){
                    tsrStatus =true;
                }
            }
            }
            if (tsrStatus) {
           // errors.add(  'Vetting Report Result must be positive.');
          }
        }
        
        //changes for 9389
        if (
            loan.Stage__c == 'Post Sanction' &&
            (loan.SubStage__c == 'Data Entry')
            ){
                List<LoanAppl__c> ln = new List<LoanAppl__c>(
                    [
                    SELECT
                    Id,
                    SchemeId__c, SchmCode__c
                    FROM LoanAppl__c
                    WHERE
    				Id = :loanId]);
                    SchMapping__c schemeMaping = new SchMapping__c();
                    if (!ln.isEmpty() && ln[0].SchemeId__c != null) {
                        schemeMaping = [
                            SELECT
                    Id,SchmId__c,
                    SchemeDesc__c,
                    Verification_Initiation__c
                    FROM SchMapping__c
                    WHERE Id = :ln[0].SchemeId__c
                    LIMIT 1
                    ];
                }
                list<DocDtl__c>  DocDtl = new list<DocDtl__c> ();
                if (!ln.isEmpty() ) {
                    DocDtl = [
                   select id ,LAN__c, DocStatus__c, DocTyp__c,DocSubTyp__c,DocCatgry__c from DocDtl__c where LAN__c =:loanId and DocStatus__c in ('OTC','PDD') and DocTyp__c='Disbursal Documents' and DocSubTyp__c='Vetting report by Lawyer'
                   
                   ];
                }               
                list<Case> lstCases = [SELECT id,FinalStatusTSRReportFromHLM__c,WaiveCPV__c,Status from Case where Loan_Application__c =:loanId AND RecordType.DeveloperName ='Vetting'  and ApplAssetId__c!=null ORDER By CreatedDate DESC ]; 
                
                if (schemeMaping != null && (schemeMaping.Verification_Initiation__c != null && 
    						schemeMaping.Verification_Initiation__c.contains('Vetting Post Disbursement'))){
                    if (!DocDtl.isEmpty()){
                        boolean isOtcRecordPresent = true;
                        boolean isPddRecordPresent = true;
                        for (DocDtl__c record : DocDtl) {
                            if (record.DocStatus__c == 'OTC') {
                                isOtcRecordPresent = false;
                            } else if (record.DocStatus__c == 'PDD') {
                                isPddRecordPresent=false;
                            }                            
                    	}
                        /*if(isOtcRecordPresent){
                            errors.add('There Should be OTC Document added in NDC.');
                            }
                            if(isPddRecordPresent){
                                errors.add('There Should be PDD Document added in NDC.');
                                }*/
                                if(isOtcRecordPresent && isPddRecordPresent){
                                    errors.add('Kindly add Vetting report as OTC/PDD since vetting is not closed.');
                                }
                            }
                            else{
                                errors.add('Kindly add Vetting report as OTC/PDD since vetting is not closed.');
                            }
                        }
                        else{
                            if(!lstCases.isEmpty()){
                                for(Case c : lstCases){
                                    if(c.WaiveCPV__c  != 'Yes'){
                                        if(c.Status  != 'Closed'){
                                            // errors.add('Kindly add Vetting report as OTC/PDD since vetting is not closed.');
                                            if (!DocDtl.isEmpty()){
                                                boolean isOtcRecordPresent = true;
                                                boolean isPddRecordPresent = true;
                                                for (DocDtl__c record : DocDtl) {
                                                    if (record.DocStatus__c == 'OTC') {
                                                        isOtcRecordPresent = false;
                                                    } else if (record.DocStatus__c == 'PDD') {
                                                        isPddRecordPresent=false;
                                                    }                            
                                                      }
                                                      /*if(isOtcRecordPresent){
                                                        errors.add('There Should be OTC Document added in NDC.');
                                                        }
                                                        if(isPddRecordPresent){
                                                            errors.add('There Should be PDD Document added in NDC.');
                                                            }*/
                                                            if(isOtcRecordPresent && isPddRecordPresent){
                                                                errors.add('Kindly add Vetting report as OTC/PDD since vetting is not closed.');
                                                      }
                                                  }
                                                  else{
                                                           errors.add('Kindly add Vetting report as OTC/PDD since vetting is not closed.');
                                                      }
                        	}
                           
                        }
                    	if(c.Status  != 'Closed'){
                            // errors.add('Kindly add Vetting report as OTC/PDD since vetting is not closed.');
                            if (!DocDtl.isEmpty()){
                                boolean isOtcRecordPresent = true;
                                boolean isPddRecordPresent = true;
                                for (DocDtl__c record : DocDtl) {
                                    if (record.DocStatus__c == 'OTC') {
                                        isOtcRecordPresent = false;
                                    } else if (record.DocStatus__c == 'PDD') {
                                        isPddRecordPresent=false;
                                    }                            
                                }
                                /*if(isOtcRecordPresent){
                                    errors.add('There Should be OTC Document added in NDC.');
                                    }
                                    if(isPddRecordPresent){
                                        errors.add('There Should be PDD Document added in NDC.');
                                        }*/
                                        if(isOtcRecordPresent && isPddRecordPresent){
                                            errors.add('Kindly add Vetting report as OTC/PDD since vetting is not closed.');
                                        }
                                    }
                                    else{
                                        errors.add('Kindly add Vetting report as OTC/PDD since vetting is not closed.');
                                    }
                                }
                            }
                        }else{
                            errors.add('Vetting Should be Initiated.');
                        }
                    }
                }
            }
                
                //Changes Started for LAK-6958
                if (
                    loan.Stage__c == 'Post Sanction' && 
                    loan.subStage__c == 'Ops Query'
                    ) {
                        if (appMap.keyset().size() > 0) {
                            Map<Id, List<DocDtl__c>> appWithDocDtl = new Map<Id, List<DocDtl__c>>();
                            for (Applicant__c app : appMap.values()) {
                                if (
                                    app.Applicant_Document_Details__r != null &&
                                    app.Applicant_Document_Details__r.size() > 0
                                    ) {
                                        for (DocDtl__c docDtl : app.Applicant_Document_Details__r) {
                                            if (docDtl.DocCatgry__c == 'Insurance documents') {
                                    if (appWithDocDtl.containsKey(app.id)) {
                                        appWithDocDtl.get(app.Id).add(docDtl);
                                    } else {
                                        appWithDocDtl.put(app.Id, new List<DocDtl__c>{ docDtl });
                                    }
                                }
                            }
                        }
                    }
                    
                    list<Insurance__c> insList = [
                        SELECT
                        Id,
                        LoanAppln__c,
                        Appl__c,
                        Appl__r.id,
                        Appl__r.FullName__c,
                        IsActive__c,
                        InsProvider__c,
                        InsProvider__r.Name,
                        InsProvider__r.MPHnm__c,
                        InsProvider__r.MPno__c,
                        InsType__c,
                        SumAmount__c,
                        SumInsuredType__c,
                        PolicyTenute__c,
                        PremiumAmount__c,
                        Penettration__c,
                        isCoBorrNominee__c
                        FROM Insurance__c
                        WHERE LoanAppln__c = :loanId
                    ];
                    if (insList != null && insList.size() > 0) {
                        for (Insurance__c ins : insList) {
                            if (
                                ins.IsActive__c == true &&
                                ins.Appl__c != null &&
                                ins.InsType__c != null &&
                                ins.InsType__c == 'Life Insurance'
                            ) {
                                List<DocDtl__c> docDtlList = appWithDocDtl.get(ins.Appl__c);
                                if (docDtlList != null && docDtlList.size() > 0) {
                                    for (DocDtl__c doctl : docDtlList) {
                                        if (doctl.DocTyp__c == 'Life Insurance documents') {
                                            list<GetDocumentDetails.PreviewWrpr> returnVal = GetDocumentDetails.getFilePreviewDataList(
                                                doctl.id
                                            );
                                            if (returnVal.isEmpty()) {
                                                errors.add(
                                                    ins.Appl__r.FullName__c +
                                                    ': Please Upload Life Insurance Form'
                                                );
                                            }
                                        }
                                    }
                                }
                            } else if (
                                ins.IsActive__c == true &&
                                ins.Appl__c != null &&
                                ins.InsType__c != null &&
                                ins.InsType__c == 'General Insurance'
                            ) {
                                List<DocDtl__c> docDtlList = appWithDocDtl.get(ins.Appl__c);
                                if (docDtlList != null && docDtlList.size() > 0) {
                                    for (DocDtl__c doctl : docDtlList) {
                                        if (doctl.DocTyp__c == 'General Insurance documents') {
                                            list<GetDocumentDetails.PreviewWrpr> returnVal = GetDocumentDetails.getFilePreviewDataList(
                                                doctl.id
                                            );
                                            if (returnVal.isEmpty()) {
                                                errors.add(
                                                    ins.Appl__r.FullName__c +
                                                    ': Please Upload General Insurance Form'
                                                );
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            //Changes Ended for LAK-6958
            
            //CPV Case - Latest IsReinitiated expired case should not Cancelled
            For(Case objCase : [SELECT ID,CaseType__c,ApplAddr__c,Date_of_Report__c,ExpiryDate__c,Applicant__c,status,IsReinitiated__c,IsReinitiatedExpired__c from Case WHERE Loan_Application__c =:loanId AND CaseType__c = 'CPVFI' AND ApplAddr__c != null AND Applicant__c !=null AND IsMandatory__c = TRUE   order by Date_of_Report__c DESC]){
                if(!mapOfappplicantAndAddressToCpv.containsKey(objCase.ApplAddr__c+'-'+objCase.Applicant__c) ){
                    mapOfappplicantAndAddressToCpv.Put(objCase.ApplAddr__c+'-'+objCase.Applicant__c, objCase);  
                    if(objCase.Status == 'Cancelled' && (objCase.IsReinitiatedExpired__c || objCase.ExpiryDate__c < date.today())){
                        errors.add('The CPV case has been cancelled. Please create a new case.');  
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
}