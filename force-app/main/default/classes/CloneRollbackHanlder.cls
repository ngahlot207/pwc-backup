public class CloneRollbackHanlder {
    public static void rollbackClonedloanApp(String cloneLoanId) {
        try {
            List<SObject> deleteRecrds = new List<SObject>();
            List<SObject> deleteRecrdsApps = new List<SObject>();
            Set<Id> deleteIds = new Set<Id>();
            
            // Fetch the Loan Application record
            LoanAppl__c loanApp = [
                SELECT Id, ClonedFor__c, (SELECT Id FROM Cases__r)
                FROM LoanAppl__c
                WHERE Id = :cloneLoanId
            ];
            
            if (loanApp != null) {
                // deleteRecrds.add(loanApp);
                //deleteIds.add(loanApp.Id);
                
                // Fetch and add related Cases
                if (!loanApp.Cases__r.isEmpty()) {
                    for (Case caseRec : loanApp.Cases__r) {
                        if (!deleteIds.contains(caseRec.Id)) {
                            deleteRecrds.add(caseRec);
                            deleteIds.add(caseRec.Id);
                        }
                    }
                }
                
                // Fetch Applicants and related records
                List<Applicant__c> applicants = [
                    SELECT
                    Id,
                    (SELECT Id FROM Applicant_Document_Details__r),
                    (SELECT Id FROM Bureau_Responses__r),
                    (SELECT Id FROM BureauRespDtl__r)
                    FROM Applicant__c
                    WHERE LoanAppln__c = :cloneLoanId
                ];
                
                for (Applicant__c app : applicants) {
                    if (!deleteIds.contains(app.Id)) {
                        deleteRecrdsApps.add(app);
                        //deleteIds.add(app.Id);
                    }
                    
                    // Fetch and add Applicant Document Details
                    for (DocDtl__c docDtl : app.Applicant_Document_Details__r) {
                        if (!deleteIds.contains(docDtl.Id)) {
                            deleteRecrds.add(docDtl);
                            deleteIds.add(docDtl.Id);
                        }
                    }
                    
                    // Fetch and add Bureau Responses
                    for (Bureau__c bureau : app.Bureau_Responses__r) {
                        if (!deleteIds.contains(bureau.Id)) {
                            deleteRecrds.add(bureau);
                            deleteIds.add(bureau.Id);
                        }
                        
                        // Fetch and add Bureau Response Details
                        List<CM_BureauRelationShipDetail__c> bureauRelDtl = [
                            SELECT Id, (SELECT Id FROM Bureau_Child_RelationShips__r)
                            FROM CM_BureauRelationShipDetail__c
                            WHERE BureauResponse__c = :bureau.Id
                        ];
                        
                        for (CM_BureauRelationShipDetail__c bureRel : bureauRelDtl) {
                            if (!deleteIds.contains(bureRel.Id)) {
                                deleteRecrds.add(bureRel);
                                deleteIds.add(bureRel.Id);
                            }
                            
                            for (SObject childRel : bureRel.Bureau_Child_RelationShips__r) {
                                if (!deleteIds.contains(childRel.Id)) {
                                    deleteRecrds.add(childRel);
                                    deleteIds.add(childRel.Id);
                                }
                            }
                        }
                        
                        // Fetch and add Person Entity Details
                        List<CM_Person_Entity_Detail__c> personEntityDtls = [
                            SELECT
                            Id,
                            (SELECT Id FROM Person_Entity_Class_Activitys__r),
                            (SELECT Id FROM Person_Entity_ID_Details__r),
                            (SELECT Id FROM Borrower_Delinquencys__r)
                            FROM CM_Person_Entity_Detail__c
                            WHERE BureauResponse__c = :bureau.Id
                        ];
                        
                        for (CM_Person_Entity_Detail__c personEnDtl : personEntityDtls) {
                            if (!deleteIds.contains(personEnDtl.Id)) {
                                deleteRecrds.add(personEnDtl);
                                deleteIds.add(personEnDtl.Id);
                            }
                            
                            for (SObject activity : personEnDtl.Person_Entity_Class_Activitys__r) {
                                if (!deleteIds.contains(activity.Id)) {
                                    deleteRecrds.add(activity);
                                    deleteIds.add(activity.Id);
                                }
                            }
                            
                            for (SObject idDetail : personEnDtl.Person_Entity_ID_Details__r) {
                                if (!deleteIds.contains(idDetail.Id)) {
                                    deleteRecrds.add(idDetail);
                                    deleteIds.add(idDetail.Id);
                                }
                            }
                            
                            for (SObject delinquency : personEnDtl.Borrower_Delinquencys__r) {
                                if (!deleteIds.contains(delinquency.Id)) {
                                    deleteRecrds.add(delinquency);
                                    deleteIds.add(delinquency.Id);
                                }
                            }
                        }
                        
                        // Fetch and add Location Details
                        List<CM_LocationDetail__c> locationDtls = [
                            SELECT Id, (SELECT Id FROM LocationInfos__r)
                            FROM CM_LocationDetail__c
                            WHERE BureauResponse__c = :bureau.Id
                        ];
                        
                        for (CM_LocationDetail__c locDtl : locationDtls) {
                            if (!deleteIds.contains(locDtl.Id)) {
                                deleteRecrds.add(locDtl);
                                deleteIds.add(locDtl.Id);
                            }
                            
                            for (SObject locationInfo : locDtl.LocationInfos__r) {
                                if (!deleteIds.contains(locationInfo.Id)) {
                                    deleteRecrds.add(locationInfo);
                                    deleteIds.add(locationInfo.Id);
                                }
                            }
                        }
                    }
                    
                    // Fetch and add Bureau Response Details
                    for (BureauRespDtl__c bureauResDtl : app.BureauRespDtl__r) {
                        if (!deleteIds.contains(bureauResDtl.Id)) {
                            deleteRecrds.add(bureauResDtl);
                            deleteIds.add(bureauResDtl.Id);
                        }
                    }
                }
                
                // Fetch Content Document Links
                /*   List<ContentDocumentLink> contentDocLinks = [
SELECT Id, ContentDocumentId, LinkedEntityId
FROM ContentDocumentLink
WHERE LinkedEntityId IN :deleteIds
];

for (ContentDocumentLink contentDocLink : contentDocLinks) {
if (!deleteIds.contains(contentDocLink.Id)) {
deleteRecrds.add(contentDocLink);
deleteIds.add(contentDocLink.Id);
}
}
*/
                // Delete records
                if (!deleteRecrds.isEmpty()) {
                    System.debug('deleteRecrds ' + deleteRecrds);
                    delete deleteRecrds;
                }
                // Delete records
                if (!deleteRecrdsApps.isEmpty()) {
                    System.debug('deleteRecrdsApps ' + deleteRecrdsApps);
                    delete deleteRecrdsApps;
                }
                // Delete records
                if (loanApp != null) {
                    System.debug('loanApp ' + loanApp);
                    delete loanApp;
                }
            }
        } catch (Exception e) {
            system.debug('error message is '+ e.getMessage() + ' line ' + e.getLineNumber());
            GlobalUtility.logMessage(
                'Error',
                'CloneRollbackHanlder',
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