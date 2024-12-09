public class CloneBureauDataTwoJob implements Queueable, Database.AllowsCallouts {
    private CloneLoanAppController.CloneLoanAppwrpr inputdata;
    private Id originalLoanAppId;
    private Id clonedLoanAppId;
    
    public CloneBureauDataTwoJob(
        CloneLoanAppController.CloneLoanAppwrpr inputdata,
        Id originalLoanAppId,
        Id clonedLoanAppId
    ) {
        this.inputdata = inputdata;
        this.originalLoanAppId = originalLoanAppId;
        this.clonedLoanAppId = clonedLoanAppId;
    }
    
    public void execute(QueueableContext context) {
        try {
            Map<Id, Id> appWithOldIdMap = new Map<Id, Id>();
            Map<Id, Id> bureauOldIdMap = new Map<Id, Id>();
            Map<Id, Id> bureaurelDtlOldIdMap = new Map<Id, Id>();
            List<SObject> recordsToClone = new List<SObject>();
            
            List<Applicant__c> applicants = [
                SELECT
                Id,
                ClonedFor__c,
                (SELECT Id, ClonedSource__c FROM Bureau_Responses__r WHERE RecordType.Name IN ('Consumer Bureau','Commercial Bureau'))
                FROM Applicant__c
                WHERE LoanAppln__c = :clonedLoanAppId AND ApplType__c IN ('P', 'C', 'G')
            ];
            if (!applicants.isEmpty()) {
                for (Applicant__c applicant : applicants) {
                    appWithOldIdMap.put(applicant.ClonedFor__c, applicant.Id);
                    if (!applicant.Bureau_Responses__r.isEmpty()) {
                        for (Bureau__c bureau : applicant.Bureau_Responses__r) {
                            bureauOldIdMap.put(bureau.ClonedSource__c, bureau.Id);
                        }
                    }
                }
            }
            if (!bureauOldIdMap.keyset().isEmpty()) {
                List<Bureau__c> bureaurespnses = [SELECT Id,(SELECT Id, Description__c, Value__c, Name__c, BureauResponse__c FROM CreditVisions__r),
                                                  (SELECT Id,Message__c, BureauResponse__c FROM Credit_Ratings__r),
                                                  (SELECT Id,BureauResponse__c,ExclusionRes__c,Message__c,RankName__c,RankVal__c FROM Ranks__r),
                                                  (SELECT Id,EnqPurpose__c, CrdLender__c, EnqAmt__c, EnqDte__c, BureauResponse__c, Message__c FROM Enquiry_Details__r),
                                                  (SELECT Id,BureauResponse__c, Month__c, OSAmount__c, ACorDPD__c FROM Credit_History_For_AC_or_DPDs__r) FROM Bureau__c WHERE Id IN:bureauOldIdMap.keyset()]; 
                if (!bureaurespnses.isEmpty()) {
                    for(Bureau__c bureau : bureaurespnses){
                        if(!bureau.CreditVisions__r.isEmpty()){
                            for (CM_CreditVision__c bCredVersons : bureau.CreditVisions__r) {
                                CM_CreditVision__c clonedBCredVersons = bCredVersons.clone(false, true, false, false);
                                clonedBCredVersons.BureauResponse__c = bCredVersons.BureauResponse__c != null
                                    ? bureauOldIdMap.get(bCredVersons.BureauResponse__c)
                                    : null;
                                recordsToClone.add(clonedBCredVersons);
                            }
                        }
                        if(!bureau.Credit_Ratings__r.isEmpty()){
                            for (CM_CreditRating__c credRats : bureau.Credit_Ratings__r) {
                                CM_CreditRating__c clonedCredRats = credRats.clone(false, true, false, false);
                                clonedCredRats.BureauResponse__c = credRats.BureauResponse__c != null
                                    ? bureauOldIdMap.get(credRats.BureauResponse__c)
                                    : null;
                                recordsToClone.add(clonedCredRats);
                            }
                        }
                        if(!bureau.Ranks__r.isEmpty()){
                            for (Rank__c rank : bureau.Ranks__r) {
                                Rank__c clonedRank = rank.clone(false, true, false, false);
                                clonedRank.BureauResponse__c = rank.BureauResponse__c != null
                                    ? bureauOldIdMap.get(rank.BureauResponse__c)
                                    : null;
                                recordsToClone.add(clonedRank);
                            }
                        }
                        if(!bureau.Enquiry_Details__r.isEmpty()){
                            for (CM_EnquiryDetail__c enquiryDtl : bureau.Enquiry_Details__r) {
                                CM_EnquiryDetail__c clonedEnquiryDtl = enquiryDtl.clone(false, true, false, false);
                                clonedEnquiryDtl.BureauResponse__c = enquiryDtl.BureauResponse__c != null
                                    ? bureauOldIdMap.get(enquiryDtl.BureauResponse__c)
                                    : null;
                                recordsToClone.add(clonedEnquiryDtl);
                            }
                        }
                        if(!bureau.Credit_History_For_AC_or_DPDs__r.isEmpty()){
                            for (CM_CreditHistoryForACorDPD__c crediHisForAcDPD : bureau.Credit_History_For_AC_or_DPDs__r) {
                                CM_CreditHistoryForACorDPD__c clonedCrediHisForAcDPD = crediHisForAcDPD.clone(false, true, false, false);
                                clonedCrediHisForAcDPD.BureauResponse__c = crediHisForAcDPD.BureauResponse__c != null
                                    ? bureauOldIdMap.get(crediHisForAcDPD.BureauResponse__c)
                                    : null;
                                recordsToClone.add(clonedCrediHisForAcDPD);
                            }
                        }
                    }   
                }
                if (!recordsToClone.isEmpty()) {
                    insert recordsToClone;
                }
                recordsToClone.clear();
            }
            if (!Test.isRunningTest()) {
                System.enqueueJob(
                    new CloneBureauDataThreeJob(
                        inputdata,
                        originalLoanAppId,
                        clonedLoanAppId
                    )
                );
              }
        }catch (Exception e) {
            if (clonedLoanAppId != null) {
                CloneRollbackHanlder.rollbackClonedloanApp(clonedLoanAppId);
              }
            GlobalUtility.logMessage(
                'Error',
                'CloneBureauDataTwoJob',
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