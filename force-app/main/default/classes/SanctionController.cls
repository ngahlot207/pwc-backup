public with sharing class SanctionController {
    @AuraEnabled
    public static String upsertSanctionConditions(
        List<Sanction_Conditions__c> records
    ) {
        List<Sanction_Conditions__c> scListToUpdate = new List<Sanction_Conditions__c>();
        Set<Id> loanIds = new Set<Id>();
        List<DocDtl__c> existingDocDetails = new List<DocDtl__c>();
        Map<Id, DocDtl__c> docDetailMap = new Map<Id, DocDtl__c>();
        Map<String, DocMstr__c> docSubTypeToMstr = new Map<String, DocMstr__c>();

        for (DocMstr__c docMst : [
            SELECT Id, DocSubTyp__c
            FROM DocMstr__c
            WHERE
                DocTyp__c = 'Manual Sanction'
                AND Catgry__c = 'Sanction Condition Documents'
        ]) {
            docSubTypeToMstr.put(docMst.DocSubTyp__c, docMst);
        }
        Map<Id, Sanction_Conditions_Master__c> sanMasterMap = new Map<Id, Sanction_Conditions_Master__c>(
            [
                SELECT id, OTC__c, PDD__c, Category__c
                FROM Sanction_Conditions_Master__c
            ]
        );
        try {
            for (Sanction_Conditions__c scon : records) {
                Sanction_Conditions__c sc = new Sanction_Conditions__c(
                    Id = scon.Id,
                    Remarks__c = scon.Remarks__c,
                    Loan_Application__c = scon.Loan_Application__c,
                    Sanction_Con_Master__c = scon.Sanction_Con_Master__c,
                    Condition__c = scon.Condition__c
                );
                scListToUpdate.add(sc);
                loanIds.add(scon.Loan_Application__c);
            }

            if (!scListToUpdate.isEmpty()) {
                upsert scListToUpdate;
            }

            Map<id, LoanAppl__c> loanApplicantMap = new Map<id, LoanAppl__c>(
                [SELECT id, Applicant__c FROM LoanAppl__c WHERE id IN :loanIds]
            );

            existingDocDetails = [
                SELECT Id, SancCond__c
                FROM DocDtl__c
                WHERE SancCond__c IN :scListToUpdate AND LAN__c IN :loanIds
                ORDER BY lastmodifieddate DESC
            ];
            if (!existingDocDetails.isEmpty()) {
                for (DocDtl__c dtl : existingDocDetails) {
                    if (!docDetailMap.containsKey(dtl.SancCond__c)) {
                        docDetailMap.put(dtl.SancCond__c, dtl);
                    }
                }
            }

            List<DocDtl__c> newDocDetails = new List<DocDtl__c>();
            for (Sanction_Conditions__c scon : scListToUpdate) {
                DocDtl__c dd = docDetailMap.get(scon.Id);
                if (dd == null) {
                    dd = new DocDtl__c();
                    dd.Appl__c = loanApplicantMap.get(scon.Loan_Application__c)
                        ?.Applicant__c;
                }

                dd.LAN__c = scon.Loan_Application__c;
                dd.SancCond__c = scon.Id;
                dd.DocCatgry__c = 'Sanction Condition Documents';
                dd.DocTyp__c = 'Manual Sanction';
                dd.DocSubTyp__c = scon.Condition__c;
                dd.Rmrk__c = scon.Remarks__c;
                DocMstr__c docMstr = docSubTypeToMstr.get(scon.Condition__c);
                if (docMstr != null) {
                    dd.DocMstr__c = docMstr.Id;
                    Sanction_Conditions_Master__c sanMaster = sanMasterMap.get(
                        scon.Sanction_Con_Master__c
                    );
                    if (sanMaster != null) {
                        dd.OTC__c = sanMaster.OTC__c;
                        dd.PDD__c = sanMaster.PDD__c;
                        dd.Catgry__c = sanMaster.Category__c;
                    }
                }
                newDocDetails.add(dd);
            }
            upsert newDocDetails;
            return 'Records upserted successfully';
        } catch (Exception e) {
            return 'Failed to upsert records: ' + e.getMessage();
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Sanction_Conditions__c> getRelatedRecords(Id loanId) {
        return [
            SELECT
                Id,
                Name,
                Remarks__c,
                Loan_Application__c,
                Condition__c,
                Sanction_Con_Master__c
            FROM Sanction_Conditions__c
            WHERE Loan_Application__c = :loanId
        ];
    }

    @AuraEnabled
    public static void deleteRecord(Id recordId) {
        try {
            // delete [SELECT id FROM DocDtl__c WHERE SancCond__c = :recordId];
            // delete [SELECT id FROM Sanction_Conditions__c WHERE id = :recordId];
            system.debug('recordId: Sanction'+recordId);
        
            if(recordId != null){
                system.debug('recordId: Sanction 1'+recordId);
        List<DocDtl__c> docDtlsToDelete = [SELECT Id FROM DocDtl__c WHERE SancCond__c = :recordId];
        List<Sanction_Conditions__c> sanctionsToDelete = [SELECT Id FROM Sanction_Conditions__c WHERE Id = :recordId];

        
        if (!docDtlsToDelete.isEmpty()) {
            delete docDtlsToDelete;
        }
        
        if (!sanctionsToDelete.isEmpty()) {
            delete sanctionsToDelete;
        }
        }
        } catch (Exception e) {
            // Handle any exceptions.
        }
    }
}