public class CloneRegulatoryDtlsJob implements Queueable, Database.AllowsCallouts {
    private CloneLoanAppController.CloneLoanAppwrpr inputdata;
    private String loanProduct;
    private Id clonedLoanAppId;
    
    public CloneRegulatoryDtlsJob(
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
            Map<Id, Id> appReglryWithOldIdMap = new Map<Id, Id>();
            Map<Id, Id> docDtlWithOldIdMap = new Map<Id, Id>();
            Map<Id, Id> caseOldIdMap = new Map<Id, Id>();
            
            List<SObject> recordsToClone = new List<SObject>();
            
            LoanAppl__c clonedLoanRecDetails = [
                SELECT
                Id,
                (
                    SELECT Id, ClonedSource__c
                    FROM Cases__r
                    WHERE RecordType.Name IN ('CPVFI', 'Technical','Collateral Visit','Technical','TSR')
                )
                FROM LoanAppl__c WHERE Id =:clonedLoanAppId
                LIMIT 1
            ];
            
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
                (SELECT Id, ClonedSource__c FROM Applicant_Document_Details__r)
                FROM Applicant__c
                WHERE LoanAppln__c = :clonedLoanAppId AND ApplType__c IN ('P', 'C', 'G')
            ];
            
            if (!applicants.isEmpty()) {
                for (Applicant__c applicant : applicants) {
                    appWithOldIdMap.put(applicant.ClonedFor__c, applicant.Id);
                    if (!applicant.Applicant_Document_Details__r.isEmpty()) {
                        for (DocDtl__c docDtl : applicant.Applicant_Document_Details__r) {
                            docDtlWithOldIdMap.put(docDtl.ClonedSource__c, docDtl.Id);
                        }
                    }
                }
            }
            
            if (inputData.cloneReason != null) {
                CloneMetadataUtility.CloneMtdUtilityWrpr returnDat = CloneMetadataUtility.getCloneStatus('ApplRegltry', inputData.cloneReason);
                List<String> products = returnDat.productType.split(':');
                if(returnDat.cloneStatus != null && returnDat.cloneStatus == 'Yes' && products.contains(loanProduct)){
                    String appRgltyQuery =
                        'SELECT ' +
                        returnDat.fields +
                        ' FROM ApplRegltry__c WHERE LoanAppln__c = \'' +inputData.recordId + '\'';
                    System.debug('appRgltyQuery ==>> ' + appRgltyQuery);
                    
                    List<ApplRegltry__c> applRegulatories = Database.query(
                        appRgltyQuery
                    );
                    if (!applRegulatories.isEmpty()) {
                        for (ApplRegltry__c applRegulty : applRegulatories) {
                            ApplRegltry__c clonedApplRegulty = applRegulty.clone(
                                false,
                                true,
                                false,
                                false
                            );
                            clonedApplRegulty.Appl__c = applRegulty.Appl__c != null
                                ? appWithOldIdMap.get(applRegulty.Appl__c)
                                : null;
                            clonedApplRegulty.LoanAppln__c = clonedLoanAppId;
                            clonedApplRegulty.ClonedSource__c = applRegulty.Id;
                            recordsToClone.add(clonedApplRegulty);
                        }
                    }
                    if (!recordsToClone.isEmpty()) {
                        insert recordsToClone;
                        
                        for (Integer i = 0; i < recordsToClone.size(); i++) {
                            appReglryWithOldIdMap.put(
                                applRegulatories[i].Id,
                                recordsToClone[i].Id
                            );
                        }
                        //recordsToClone.clear();
                    }
                    recordsToClone.clear();
                    
                    if (!appReglryWithOldIdMap.keyset().isEmpty()) {
                        List<RegltryPrsonl__c> reglaryPersonel = [
                            SELECT
                            Id,
                            Applicant_Regulatory__c,
                            DirName__c,
                            Desgntn__c,
                            Reltnshp__c
                            FROM RegltryPrsonl__c
                            WHERE Applicant_Regulatory__c IN :appReglryWithOldIdMap.keyset()
                        ];
                        if (!reglaryPersonel.isEmpty()) {
                            for (RegltryPrsonl__c reglPersonl : reglaryPersonel) {
                                RegltryPrsonl__c clonedReglPersonl = reglPersonl.clone(
                                    false,
                                    true,
                                    false,
                                    false
                                );
                                clonedReglPersonl.Applicant_Regulatory__c = reglPersonl.Applicant_Regulatory__c !=
                                    null
                                    ? appReglryWithOldIdMap.get(reglPersonl.Applicant_Regulatory__c)
                                    : null;
                                clonedReglPersonl.ClonedSource__c = reglPersonl.Id;
                                recordsToClone.add(clonedReglPersonl);
                            }
                        }
                        if (!recordsToClone.isEmpty()) {
                            insert recordsToClone;
                        }
                        recordsToClone.clear();
                    }
                }
            }
            
            if (
                !docDtlWithOldIdMap.keyset().isEmpty() ||
                !caseOldIdMap.keyset().isEmpty()
            ) {
                List<CaseDoc__c> caseDocs = [
                    SELECT Id, Case__c, DocDetail__c
                    FROM CaseDoc__c
                    WHERE Case__c IN :caseOldIdMap.keyset() AND (Case__r.Status = 'Closed' OR Case__r.CVStatus__c = 'Completed')
                ];
                if (!caseDocs.isEmpty()) {
                    for (CaseDoc__c caseDoc : caseDocs) {
                        CaseDoc__c clonedCaseDoc = caseDoc.clone(false, true, false, false);
                        clonedCaseDoc.Case__c = caseDoc.Case__c != null
                            ? caseOldIdMap.get(caseDoc.Case__c)
                            : null;
                        clonedCaseDoc.DocDetail__c = caseDoc.DocDetail__c != null
                            ? docDtlWithOldIdMap.get(caseDoc.DocDetail__c)
                            : null;
                        clonedCaseDoc.ClonedSource__c = caseDoc.Id;
                        recordsToClone.add(clonedCaseDoc);
                    }
                }
                if (!recordsToClone.isEmpty()) {
                    //TriggerActionFlow.bypass('RT_After_on_Case_Document');
                    insert recordsToClone;
                    // TriggerActionFlow.clearBypass('RT_After_on_Case_Document');
                }
                recordsToClone.clear();
            }
            if (!Test.isRunningTest()) {
                System.enqueueJob(
                    new CloneIntMsgJobData(inputdata, loanProduct, clonedLoanAppId)
                );
            }
            
        } catch (Exception e) {
            if (clonedLoanAppId != null) {
                CloneRollbackHanlder.rollbackClonedloanApp(clonedLoanAppId);
            }
            GlobalUtility.logMessage(
                'Error',
                'CloneRegulatoryDtlsJob',
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