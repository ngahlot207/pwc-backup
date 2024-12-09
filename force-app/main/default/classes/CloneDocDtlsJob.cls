public class CloneDocDtlsJob implements Queueable, Database.AllowsCallouts {
    private CloneLoanAppController.CloneLoanAppwrpr inputdata;
    private String loanProduct;
    private Id clonedLoanAppId;
    
    public CloneDocDtlsJob(
        CloneLoanAppController.CloneLoanAppwrpr inputdata,
        String loanProduct,
        Id clonedLoanAppId
    ) {
        this.inputdata = inputdata;
        this.loanProduct = loanProduct;
        this.clonedLoanAppId = clonedLoanAppId;
    }
    
    public void execute(QueueableContext context) {
        try {
            Map<Id, Id> appWithOldIdMap = new Map<Id, Id>();
            Map<Id, Id> appAssetWithOldIdMap = new Map<Id, Id>();
            Map<Id, Id> appIncomeWithOldMap = new Map<Id, Id>();
            Map<Id, Id> appFinanceWithOldIdMap = new Map<Id, Id>();
            Map<Id, Id> appGSTWithOldIdMap = new Map<Id, Id>();
            Map<Id, Id> appBankingWithOldIdMap = new Map<Id, Id>();
            Map<Id, Id> pdOldIdMap = new Map<Id, Id>();
            Map<Id, Id> applKycOldIdMap = new Map<Id, Id>();
            Map<Id, Id> docDtlOldIdMap = new Map<Id, Id>();
            Map<Id, Id> sanctionCondOldIdMap = new Map<Id, Id>();
            Map<Id, Id> caseOldIdMap = new Map<Id, Id>();
            Map<Id, Case> caseOldIdMapWithCase = new Map<Id, Case>();  //LAK-10131
            Map<Id, Id> refOldIdMap = new Map<Id, Id>();
            List<SObject> recordsToClone = new List<SObject>();
            
            LoanAppl__c loanAppDet = [SELECT Id,SubStage__c,(
              SELECT Id,RecordType.Name,Status   //LAK-10131
              FROM Cases__r
              WHERE
              RecordType.Name IN (
                  'RCU'
              )
          ) FROM LoanAppl__c WHERE Id=: inputdata.recordId LIMIT 1]; //LAK-10183

          if (
            loanAppDet != null &&
            loanAppDet.Cases__r != null &&
            !loanAppDet.Cases__r.isEmpty()
        ) {
            for (Case cas : loanAppDet.Cases__r) {
                caseOldIdMapWithCase.put(cas.Id, cas);  //LAK-10131
            }
        }
            LoanAppl__c clonedLoanRecDetails = [
                SELECT
                Id,
                (SELECT Id, ClonedSource__c FROM Applicant_Banking1__r),
                (SELECT Id, ClonedSource__c FROM Sanction_Conditions__r),
                (
                    SELECT Id, ClonedSource__c
                    FROM Cases__r
                    WHERE
                    RecordType.Name IN (
                        'Collateral Visit',
                        'CPVFI',
                        'Legal',
                        'RCU',
                        'Technical',
                        'TSR',
                        'Vetting',
                        'LIP Vendor case'
                    )
                )
                FROM LoanAppl__c
                WHERE Id = :clonedLoanAppId
                LIMIT 1
            ];
            if (
                clonedLoanRecDetails != null &&
                clonedLoanRecDetails.Applicant_Banking1__r != null &&
                !clonedLoanRecDetails.Applicant_Banking1__r.isEmpty()
            ) {
                for (
                    ApplBanking__c appBanking : clonedLoanRecDetails.Applicant_Banking1__r
                ) {
                    appBankingWithOldIdMap.put(
                        appBanking.ClonedSource__c,
                        appBanking.Id
                    );
                }
            }
            if (
                clonedLoanRecDetails != null &&
                clonedLoanRecDetails.Sanction_Conditions__r != null &&
                !clonedLoanRecDetails.Sanction_Conditions__r.isEmpty()
            ) {
                for (
                    Sanction_Conditions__c sanctionConditon : clonedLoanRecDetails.Sanction_Conditions__r
                ) {
                    sanctionCondOldIdMap.put(
                        sanctionConditon.ClonedSource__c,
                        sanctionConditon.Id
                    );
                }
            }
            if (
                clonedLoanRecDetails != null &&
                clonedLoanRecDetails.Cases__r != null &&
                !clonedLoanRecDetails.Cases__r.isEmpty()
            ) {
                for (Case cas : clonedLoanRecDetails.Cases__r) {
                    caseOldIdMap.put(cas.ClonedSource__c, cas.Id);
                }
            }
            List<Applicant__c> applicants = [
                SELECT
                Id,
                ClonedFor__c,
                (SELECT Id, ClonedSource__c FROM Applicant_Assets__r),
                (SELECT Id, ClonedSource__c FROM Applicant_GST__r),
                (SELECT Id, ClonedSource__c FROM Applicant_Financials__r),
                (SELECT Id, ClonedSource__c FROM Personal_Discussions__r),
                (SELECT Id, ClonedSource__c FROM Applicant_KYC__r),
                (SELECT Id, ClonedSource__c FROM Applicant_Income__r)
                FROM Applicant__c
                WHERE
                LoanAppln__c = :clonedLoanAppId
                AND ApplType__c IN ('P', 'C', 'G')
            ];
            if (!applicants.isEmpty()) {
                for (Applicant__c applicant : applicants) {
                    appWithOldIdMap.put(applicant.ClonedFor__c, applicant.Id);
                    if (!applicant.Applicant_Assets__r.isEmpty()) {
                        for (ApplAsset__c appAsset : applicant.Applicant_Assets__r) {
                            appAssetWithOldIdMap.put(
                                appAsset.ClonedSource__c,
                                appAsset.Id
                            );
                        }
                    }
                    if (!applicant.Applicant_Income__r.isEmpty()) {
                        for (Applicant_Income__c appIncome : applicant.Applicant_Income__r) {
                            appIncomeWithOldMap.put(
                                appIncome.ClonedSource__c,
                                appIncome.Id
                            );
                        }
                    }
                    if (!applicant.Applicant_KYC__r.isEmpty()) {
                        for (ApplKyc__c appKyc : applicant.Applicant_KYC__r) {
                            applKycOldIdMap.put(appKyc.ClonedSource__c, appKyc.Id);
                        }
                    }
                    if (!applicant.Personal_Discussions__r.isEmpty()) {
                        for (PD__c pd : applicant.Personal_Discussions__r) {
                            pdOldIdMap.put(pd.ClonedSource__c, pd.Id);
                        }
                        
                        if (!applicant.Applicant_GST__r.isEmpty()) {
                            for (ApplGST__c appGST : applicant.Applicant_GST__r) {
                                appGSTWithOldIdMap.put(appGST.ClonedSource__c, appGST.Id);
                            }
                        }
                        if (!applicant.Applicant_Financials__r.isEmpty()) {
                            for (
                                Applicant_Financial__c appFinancial : applicant.Applicant_Financials__r
                            ) {
                                appFinanceWithOldIdMap.put(
                                    appFinancial.ClonedSource__c,
                                    appFinancial.Id
                                );
                            }
                        }
                    }
                }
            }
            
            if (inputData.cloneReason != null) {
                CloneMetadataUtility.CloneMtdUtilityWrpr returnDat = CloneMetadataUtility.getCloneStatus(
                    'DocDtl',
                    inputData.cloneReason
                );
                List<String> products = returnDat.productType.split(':');
                if (
                    returnDat.cloneStatus != null &&
                    returnDat.cloneStatus == 'Yes' &&
                    products.contains(loanProduct)
                ) {
                    if (!appWithOldIdMap.keyset().isEmpty()) {
                        List<String> docCatr = new List<String>{
                            'Beneficial Owner Documents',
                                'Beneficial Owner Documents',
                                'KYC Documents',
                                'PAN Documents',
                                'Other Documents',
                                'Verification Documents',
                                'Constitution wise Mandatory documents',
                                'Financial Documents',
                                'Personal Discussion',
                                'Case Documents',
                                'Collateral Visit',
                                /// 'Sanction Letter', LAK-9637
                                // 'CAM Report',LAK-9637
                                //'Disbursement Memo',//LAK-10184
                                'Bureau Report',
                                'Perfios Report',
                                // 'Application Form', LAK-9637
                                'LOD'
                                };
                                    if(inputData.cloneReason != 'Different Property'){
                                        docCatr.add('Collateral Documents');
                                    }
                        if(inputData.cloneReason != 'Top up'){
                            docCatr.add('Income Documents');
                            docCatr.add('Banking Documents');
                        }
                        String docCatrs =
                            '(\'' +
                            String.join(new List<String>(docCatr), '\',\'') +
                            '\')';
                        
                        Set<Id> applicantIds = appWithOldIdMap.keyset();
                        String applicantIdsString =
                            '(\'' +
                            String.join(new List<Id>(applicantIds), '\',\'') +
                            '\')';
                        String docDtlQuery;
                        if(inputData.cloneReason != 'Top up') {
                                docDtlQuery = 'SELECT ' + returnDat.fields + ', PrsnlDis__r.PDStatus__c ' +
                                    'FROM DocDtl__c ' +
                                    'WHERE Appl__c IN ' + applicantIdsString +
                                    ' AND DocCatgry__c IN ' + docCatrs;
                        } else {
                                docDtlQuery = 'SELECT ' + returnDat.fields + ', PrsnlDis__r.PDStatus__c ' +
                                    'FROM DocDtl__c ' +
                                    'WHERE Appl__c IN ' + applicantIdsString +
                                    ' AND (DocCatgry__c IN ' + docCatrs + ' OR DocSubTyp__c = \'Rental Income Proof\')';
                            
                        }
                        System.debug('docDtlQuery ==>> ' + docDtlQuery);
                        
                        List<DocDtl__c> docDtlRecrds = Database.query(docDtlQuery);
                        if (!docDtlRecrds.isEmpty()) {
                            for (DocDtl__c docDtl : docDtlRecrds) {
                                if (docDtl.PrsnlDis__c != null) {
                                    if (
                                        docDtl.PrsnlDis__r.PDStatus__c != null &&
                                        docDtl.PrsnlDis__r.PDStatus__c == 'Completed'
                                    ) {
                                        DocDtl__c clonedDocDtl = docDtl.clone(
                                            false,
                                            true,
                                            false,
                                            false
                                        );
                                        clonedDocDtl.LAN__c = clonedLoanAppId;
                                        clonedDocDtl.Appl__c = docDtl.Appl__c != null
                                            ? appWithOldIdMap.get(docDtl.Appl__c)
                                            : null;
                                        clonedDocDtl.ApplAsset__c = docDtl.ApplAsset__c != null &&
                                            appAssetWithOldIdMap.keyset().size() > 0
                                            ? appAssetWithOldIdMap.get(docDtl.ApplAsset__c)
                                            : null;
                                        clonedDocDtl.ApplBanking__c = docDtl.ApplBanking__c !=
                                            null &&
                                            appBankingWithOldIdMap.keyset().size() > 0
                                            ? appBankingWithOldIdMap.get(docDtl.ApplBanking__c)
                                            : null;
                                        clonedDocDtl.Applicant_Financial__c = docDtl.Applicant_Financial__c !=
                                            null &&
                                            appFinanceWithOldIdMap.keyset().size() > 0
                                            ? appFinanceWithOldIdMap.get(
                                                docDtl.Applicant_Financial__c
                                            )
                                            : null;
                                        clonedDocDtl.Applicant_GST__c = docDtl.Applicant_GST__c !=
                                            null &&
                                            appGSTWithOldIdMap.keyset().size() > 0
                                            ? appGSTWithOldIdMap.get(docDtl.Applicant_GST__c)
                                            : null;
                                        clonedDocDtl.Applicant_KYC__c = docDtl.Applicant_KYC__c !=
                                            null &&
                                            applKycOldIdMap.keyset().size() > 0
                                            ? applKycOldIdMap.get(docDtl.Applicant_KYC__c)
                                            : null;
                                        clonedDocDtl.PrsnlDis__c = docDtl.PrsnlDis__c != null &&
                                            pdOldIdMap.keyset().size() > 0
                                            ? pdOldIdMap.get(docDtl.PrsnlDis__c)
                                            : null;
                                        clonedDocDtl.SancCond__c = docDtl.SancCond__c != null &&
                                            sanctionCondOldIdMap.keyset().size() > 0
                                            ? sanctionCondOldIdMap.get(docDtl.SancCond__c)
                                            : null;
                                        clonedDocDtl.Case__c = docDtl.Case__c != null &&
                                            caseOldIdMap.keyset().size() > 0
                                            ? caseOldIdMap.get(docDtl.Case__c)
                                            : null;
                                            //LAK-10131
                                           /* clonedDocDtl.AgencyAssigned__c = docDtl.Case__c != null &&
                                                !caseOldIdMapWithCase.keyset().isEmpty() && caseOldIdMapWithCase.keyset().size() > 0 && caseOldIdMapWithCase.get(docDtl.Case__c).RecordType.Name != null && caseOldIdMapWithCase.get(docDtl.Case__c).RecordType.Name == 'RCU' && caseOldIdMapWithCase.get(docDtl.Case__c).Status != null && caseOldIdMapWithCase.get(docDtl.Case__c).Status == 'Closed'
                                            ? docDtl.AgencyAssigned__c
                                            : false;
                                        clonedDocDtl.RCUInitiated__c = docDtl.Case__c != null &&
                                                !caseOldIdMapWithCase.keyset().isEmpty() && caseOldIdMapWithCase.keyset().size() > 0 && caseOldIdMapWithCase.get(docDtl.Case__c).RecordType.Name != null && caseOldIdMapWithCase.get(docDtl.Case__c).RecordType.Name == 'RCU' && caseOldIdMapWithCase.get(docDtl.Case__c).Status != null && caseOldIdMapWithCase.get(docDtl.Case__c).Status == 'Closed'
                                                ? docDtl.RCUInitiated__c
                                                : false;*/
                                            clonedDocDtl.AgencyAssigned__c =
        docDtl.Case__c != null &&
        !caseOldIdMapWithCase.isEmpty() &&
        caseOldIdMapWithCase.containsKey(docDtl.Case__c) &&
        caseOldIdMapWithCase.get(docDtl.Case__c) != null &&
        caseOldIdMapWithCase.get(docDtl.Case__c).RecordType != null &&
        caseOldIdMapWithCase.get(docDtl.Case__c).RecordType.Name == 'RCU' &&
        caseOldIdMapWithCase.get(docDtl.Case__c).Status == 'Closed'
            ? docDtl.AgencyAssigned__c
            : false;
     
    clonedDocDtl.RCUInitiated__c =
        docDtl.Case__c != null &&
        !caseOldIdMapWithCase.isEmpty() &&
        caseOldIdMapWithCase.containsKey(docDtl.Case__c) &&
        caseOldIdMapWithCase.get(docDtl.Case__c) != null &&
        caseOldIdMapWithCase.get(docDtl.Case__c).RecordType != null &&
        caseOldIdMapWithCase.get(docDtl.Case__c).RecordType.Name == 'RCU' &&
        caseOldIdMapWithCase.get(docDtl.Case__c).Status == 'Closed'
                                            ? docDtl.RCUInitiated__c
                                            : false;
                                        clonedDocDtl.ClonedSource__c = docDtl.Id;
                                        recordsToClone.add(clonedDocDtl);
                                    }
                                } else {
                                    DocDtl__c clonedDocDtl = docDtl.clone(
                                        false,
                                        true,
                                        false,
                                        false
                                    );
                                    clonedDocDtl.LAN__c = clonedLoanAppId;
                                    clonedDocDtl.Appl__c = docDtl.Appl__c != null &&
                                        appWithOldIdMap.keyset().size() > 0
                                        ? appWithOldIdMap.get(docDtl.Appl__c)
                                        : null;
                                    clonedDocDtl.ApplAsset__c = docDtl.ApplAsset__c != null &&
                                        appAssetWithOldIdMap.keyset().size() > 0
                                        ? appAssetWithOldIdMap.get(docDtl.ApplAsset__c)
                                        : null;
                                    clonedDocDtl.ApplBanking__c = docDtl.ApplBanking__c != null &&
                                        appBankingWithOldIdMap.keyset().size() > 0
                                        ? appBankingWithOldIdMap.get(docDtl.ApplBanking__c)
                                        : null;
                                    clonedDocDtl.Applicant_Financial__c = docDtl.Applicant_Financial__c !=
                                        null &&
                                        appFinanceWithOldIdMap.keyset().size() > 0
                                        ? appFinanceWithOldIdMap.get(docDtl.Applicant_Financial__c)
                                        : null;
                                    clonedDocDtl.Applicant_GST__c = docDtl.Applicant_GST__c !=
                                        null &&
                                        appGSTWithOldIdMap.keyset().size() > 0
                                        ? appGSTWithOldIdMap.get(docDtl.Applicant_GST__c)
                                        : null;
                                    clonedDocDtl.Applicant_KYC__c = docDtl.Applicant_KYC__c !=
                                        null &&
                                        applKycOldIdMap.keyset().size() > 0
                                        ? applKycOldIdMap.get(docDtl.Applicant_KYC__c)
                                        : null;
                                    clonedDocDtl.SancCond__c = docDtl.SancCond__c != null &&
                                        sanctionCondOldIdMap.keyset().size() > 0
                                        ? sanctionCondOldIdMap.get(docDtl.SancCond__c)
                                        : null;
                                    clonedDocDtl.Case__c = docDtl.Case__c != null &&
                                        caseOldIdMap.keyset().size() > 0
                                        ? caseOldIdMap.get(docDtl.Case__c)
                                        : null;
                                       //LAK-10131
                                            // clonedDocDtl.AgencyAssigned__c = docDtl.Case__c != null &&
                                            //     !caseOldIdMapWithCase.keyset().isEmpty() && caseOldIdMapWithCase.keyset().size() > 0 && caseOldIdMapWithCase.get(docDtl.Case__c).RecordType.Name != null && caseOldIdMapWithCase.get(docDtl.Case__c).RecordType.Name == 'RCU' && caseOldIdMapWithCase.get(docDtl.Case__c).Status != null && caseOldIdMapWithCase.get(docDtl.Case__c).Status == 'Closed'
                                            //     ? docDtl.AgencyAssigned__c
                                            //     : false;
                                            // clonedDocDtl.RCUInitiated__c = docDtl.Case__c != null &&
                                            //     !caseOldIdMapWithCase.keyset().isEmpty() && caseOldIdMapWithCase.keyset().size() > 0 && caseOldIdMapWithCase.get(docDtl.Case__c).RecordType.Name != null && caseOldIdMapWithCase.get(docDtl.Case__c).RecordType.Name == 'RCU' && caseOldIdMapWithCase.get(docDtl.Case__c).Status != null && caseOldIdMapWithCase.get(docDtl.Case__c).Status == 'Closed'
                                            //     ? docDtl.RCUInitiated__c
                                            //     : false;

                                              clonedDocDtl.AgencyAssigned__c =
        docDtl.Case__c != null &&
        !caseOldIdMapWithCase.isEmpty() &&
        caseOldIdMapWithCase.containsKey(docDtl.Case__c) &&
        caseOldIdMapWithCase.get(docDtl.Case__c) != null &&
        caseOldIdMapWithCase.get(docDtl.Case__c).RecordType != null &&
        caseOldIdMapWithCase.get(docDtl.Case__c).RecordType.Name == 'RCU' &&
        caseOldIdMapWithCase.get(docDtl.Case__c).Status == 'Closed'
                                            ? docDtl.AgencyAssigned__c
                                            : false;
     
    clonedDocDtl.RCUInitiated__c =
        docDtl.Case__c != null &&
        !caseOldIdMapWithCase.isEmpty() &&
        caseOldIdMapWithCase.containsKey(docDtl.Case__c) &&
        caseOldIdMapWithCase.get(docDtl.Case__c) != null &&
        caseOldIdMapWithCase.get(docDtl.Case__c).RecordType != null &&
        caseOldIdMapWithCase.get(docDtl.Case__c).RecordType.Name == 'RCU' &&
        caseOldIdMapWithCase.get(docDtl.Case__c).Status == 'Closed'
                                            ? docDtl.RCUInitiated__c
                                            : false;
                                    clonedDocDtl.ClonedSource__c = docDtl.Id;
                                    recordsToClone.add(clonedDocDtl);
                                }
                            }
                        }
                        
                        if (!recordsToClone.isEmpty()) {
                            MetadataTriggerHandler.bypass('ApplicantUpdate'); //LAK-8409
                            insert recordsToClone;
                            for (Integer i = 0; i < recordsToClone.size(); i++) {
                                docDtlOldIdMap.put(docDtlRecrds[i].Id, recordsToClone[i].Id);
                            }
                            MetadataTriggerHandler.clearBypass('ApplicantUpdate');//LAK-8409
                            recordsToClone.clear();
                        }
                        
                        if(!caseOldIdMap.keyset().isEmpty()){
                            List<CollateralVisitJn__c> cvJunList = [SELECT Id,Case__c,DocDtl__c,PropQues__c,Question__c,Resp__c FROM CollateralVisitJn__c WHERE Case__c IN : caseOldIdMap.keyset()];
                            if(!cvJunList.isEmpty()){
                                for(CollateralVisitJn__c cvJun : cvJunList){
                                    CollateralVisitJn__c clonedCvJun = cvJun.clone(false, true, false, false);
                                    clonedCvJun.Case__c = cvJun.Case__c != null
                                        ? caseOldIdMap.get(cvJun.Case__c)
                                        : null;
                                    clonedCvJun.DocDtl__c = cvJun.DocDtl__c != null
                                        ? docDtlOldIdMap.get(cvJun.DocDtl__c)
                                        : cvJun.DocDtl__c;
                                    clonedCvJun.ClonedSource__c = cvJun.Id;
                                    recordsToClone.add(clonedCvJun);
                                }
                            }
                        }
                        if(!recordsToClone.isEmpty()){
                            insert recordsToClone;
                            recordsToClone.clear();
                        }
                    }
                }
                CloneMetadataUtility.CloneMtdUtilityWrpr returnDatPd = CloneMetadataUtility.getCloneStatus(
                    'PD',
                    inputData.cloneReason
                );
                List<String> productsPd = returnDatPd.productType.split(':');
                if (
                    returnDatPd.cloneStatus != null &&
                    returnDatPd.cloneStatus == 'Yes' &&
                    productsPd.contains(loanProduct)
                ) {
                    if(!pdOldIdMap.keyset().isEmpty()){
                        List<Ref__c> references = [SELECT Id,RelationWthApp__c,RelationshipWthApp__c,Title__c,Add__c,Applicant__c,Comments__c,ContactNo__c,FName__c,Loan_Application__c,PrsnlDis__c FROM Ref__c WHERE Loan_Application__c =: inputdata.recordId AND PrsnlDis__c IN :pdOldIdMap.keyset()];
                        if(!references.isEmpty()){
                            for(Ref__c ref : references){
                                Ref__c clonedRef = ref.clone(false, true, false, false);
                                clonedRef.Applicant__c = ref.Applicant__c != null
                                    ? appWithOldIdMap.get(ref.Applicant__c)
                                    : null;
                                clonedRef.PrsnlDis__c = ref.PrsnlDis__c != null
                                    ? pdOldIdMap.get(ref.PrsnlDis__c)
                                    : null;
                                clonedRef.Loan_Application__c = clonedLoanAppId;
                                //clonedpd.ClonedSource__c = ref.Id;
                                recordsToClone.add(clonedRef);
                            }
                            if(!recordsToClone.isEmpty()){
                                insert recordsToClone;
                                for (Integer i = 0; i < recordsToClone.size(); i++) {
                                    refOldIdMap.put(references[i].Id, recordsToClone[i].Id);
                                }
                                recordsToClone.clear();
                            }
                        }
                        List<PDResp__c> pDResList = [SELECT Id, PrsnlDisc__c, PDQues__c,PDQues__r.RespTyp__c, Ques__c, Resp__c, Cmnt__c, DocDtl__c FROM PDResp__c WHERE PrsnlDisc__c IN : pdOldIdMap.keyset()];
                        if(!pDResList.isEmpty()){
                            for(PDResp__c pdRes : pDResList){
                                PDResp__c clonedPdResp = pdRes.clone(false, true, false, false);
                                if(pdRes.PDQues__r.RespTyp__c != null && pdRes.PDQues__r.RespTyp__c == 'Reference'){
                                    clonedPdResp.Resp__c = pdRes.Resp__c != null
                                        ? refOldIdMap.get(pdRes.Resp__c)
                                        : pdRes.Resp__c;
                                }
                                clonedPdResp.PrsnlDisc__c = pdRes.PrsnlDisc__c != null
                                    ? pdOldIdMap.get(pdRes.PrsnlDisc__c)
                                    : null;
                                clonedPdResp.DocDtl__c = pdRes.DocDtl__c != null
                                    ? docDtlOldIdMap.get(pdRes.DocDtl__c)
                                    : pdRes.DocDtl__c;
                                recordsToClone.add(clonedPdResp);
                            }
                        }
                        List<PDPrtcpnts__c> pDResDtlList = [SELECT Id, PD__c,Assigned_Date__c,User__c FROM PDPrtcpnts__c WHERE PD__c IN : pdOldIdMap.keyset()];
                        if(!pDResDtlList.isEmpty()){
                            for(PDPrtcpnts__c pdResPart : pDResDtlList){
                                PDPrtcpnts__c clonedPdRespPart = pdResPart.clone(false, true, false, false);
                                clonedPdRespPart.PD__c = pdResPart.PD__c != null
                                    ? pdOldIdMap.get(pdResPart.PD__c)
                                    : null;
                                recordsToClone.add(clonedPdRespPart);
                            }
                        }
                        //LAK-9869
                        List<ApplExpense__c> applExpenses = [SELECT Id, ApplInc__c,ExpAmt__c,ExpType__c,PrsnlDis__c,RecordTypeId FROM ApplExpense__c WHERE PrsnlDis__c IN : pdOldIdMap.keyset()];
                        
                        if(!applExpenses.isEmpty()){
                            for(ApplExpense__c appExp : applExpenses){
                                ApplExpense__c clonedAppExp = appExp.clone(false, true, false, false);
                                clonedAppExp.PrsnlDis__c = appExp.PrsnlDis__c != null
                                    ? pdOldIdMap.get(appExp.PrsnlDis__c)
                                    : null;
                                clonedAppExp.ApplInc__c = appExp.ApplInc__c != null
                                    ? appIncomeWithOldMap.get(appExp.ApplInc__c)
                                    : null;
                                recordsToClone.add(clonedAppExp);
                            }
                        }
                        
                        if (!recordsToClone.isEmpty()) {
                            insert recordsToClone;
                            recordsToClone.clear();
                        }
                    }
                }   
            }
            if (!Test.isRunningTest()) {
                System.enqueueJob(
                    new CloneRegulatoryDtlsJob(inputData, loanProduct, clonedLoanAppId)
                );
            }
        } catch (Exception e) {
            if (clonedLoanAppId != null) {
                CloneRollbackHanlder.rollbackClonedloanApp(clonedLoanAppId);
            }
            GlobalUtility.logMessage(
                'Error',
                'CloneDocDtlsJob',
                'Process',
                null,
                null,
                e.getMessage() + ' line ' + e.getLineNumber(),
                null,
                e,
                null
            );
        }
    }
}