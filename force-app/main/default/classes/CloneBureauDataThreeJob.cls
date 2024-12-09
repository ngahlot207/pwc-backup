public class CloneBureauDataThreeJob implements Queueable, Database.AllowsCallouts {
    private CloneLoanAppController.CloneLoanAppwrpr inputdata;
    private Id originalLoanAppId;
    private Id clonedLoanAppId;
    
    public CloneBureauDataThreeJob(
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
            Map<Id, Id> appWithOldIdMapNew = new Map<Id, Id>();
            Map<Id, Id> bureauOldIdMap = new Map<Id, Id>();
            Map<Id, Id> personEntiDtlOldIdMap = new Map<Id, Id>();
            Map<Id, Id> locationDtlOldIdMap = new Map<Id, Id>();
            
            List<SObject> recordsToClone = new List<SObject>();
            List<CM_Person_Entity_Detail__c> personEntityDtls = new List<CM_Person_Entity_Detail__c>();
            
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
                    appWithOldIdMapNew.put(applicant.Id, applicant.ClonedFor__c);
                    if (!applicant.Bureau_Responses__r.isEmpty()) {
                        for (Bureau__c bureau : applicant.Bureau_Responses__r) {
                            bureauOldIdMap.put(bureau.ClonedSource__c, bureau.Id);
                        }
                    }
                }
            }
            if (!bureauOldIdMap.keyset().isEmpty()) {
                personEntityDtls = [SELECT Id,BureauResponse__c, LstRepDte__c, Address__c, TeleNum__c, MobNum__c, FaxNum__c, DteIncorp__c, BusIndType__c, Name__c, BusinessCtgy__c, BorrLegalCons__c, SalesFig__c, NumEmp__c, Type__c, Message__c, RelatedType__c,
                                    (SELECT Id,ClsActivityResponse__c,PersonEntity_Detail__c FROM Person_Entity_Class_Activitys__r),
                                    (SELECT Id,CIN__c,PAN__c,PersonEntity_Detail__c,Type__c FROM Person_Entity_ID_Details__r),
                                    (SELECT Id,PersonEntityDetail__c, DeliType__c, Current__c, Lst24mon__c, Message__c, wcOutstanding__c, TlCount__c, FXOutstanding__c, TLOutstanding__c, NFCount__c, FXCount__c, WCCount__c, NFOutstanding__c, Details__c, Relationship__c FROM Borrower_Delinquencys__r) FROM CM_Person_Entity_Detail__c WHERE BureauResponse__c IN:bureauOldIdMap.keyset()]; 
                if(!personEntityDtls.isEmpty()){
                    for (CM_Person_Entity_Detail__c burPersEntDtl : personEntityDtls) {
                        CM_Person_Entity_Detail__c clonedBurPersEntDtl = burPersEntDtl.clone(false, true, false, false);
                        clonedBurPersEntDtl.BureauResponse__c = burPersEntDtl.BureauResponse__c != null
                            ? bureauOldIdMap.get(burPersEntDtl.BureauResponse__c)
                            : null;
                        recordsToClone.add(clonedBurPersEntDtl);
                    }
                }
                if (!recordsToClone.isEmpty()) {
                    // Insert cloned applicants and update map with new IDs
                    insert recordsToClone;
                    
                    for (Integer i = 0; i < recordsToClone.size(); i++) {
                        personEntiDtlOldIdMap.put(
                            personEntityDtls[i].Id,
                            recordsToClone[i].Id
                        );
                    }
                }
                recordsToClone.clear();
            }
            if(!personEntityDtls.isEmpty()){
                // List<CM_Person_Entity_Detail__c> personEntDtlsNew = [SELECT Id,(SELECT Id,ClsActivityResponse__c,PersonEntity_Detail__c FROM Person_Entity_Class_Activitys__r),
                //                                                     (SELECT Id,CIN__c,PAN__c,PersonEntity_Detail__c,Type__c FROM Person_Entity_ID_Details__r),
                //                                                     (SELECT Id,PersonEntityDetail__c, DeliType__c, Current__c, Lst24mon__c, Message__c, wcOutstanding__c, TlCount__c, FXOutstanding__c, TLOutstanding__c, NFCount__c, FXCount__c, WCCount__c, NFOutstanding__c, Details__c, Relationship__c FROM Borrower_Delinquencys__r) FROM CM_Person_Entity_Detail__c WHERE Id IN : personEntiDtlOldIdMap.keyset()];
                // if(!personEntDtlsNew.isEmpty()){
                for(CM_Person_Entity_Detail__c personEntDtl : personEntityDtls){
                    if(!personEntDtl.Person_Entity_Class_Activitys__r.isEmpty()){
                        for (CM_Person_Entity_Class_Activity__c personEntClsAct : personEntDtl.Person_Entity_Class_Activitys__r) {
                            CM_Person_Entity_Class_Activity__c clonedPersonEntClsAct = personEntClsAct.clone(false, true, false, false);
                            clonedPersonEntClsAct.PersonEntity_Detail__c = personEntClsAct.PersonEntity_Detail__c != null
                                ? personEntiDtlOldIdMap.get(personEntClsAct.PersonEntity_Detail__c)
                                : null;
                            recordsToClone.add(clonedPersonEntClsAct);
                        }
                    }
                    if(!personEntDtl.Person_Entity_ID_Details__r.isEmpty()){
                        for (CM_Person_Entity_ID_Detail__c personEntIdDetls : personEntDtl.Person_Entity_ID_Details__r) {
                            CM_Person_Entity_ID_Detail__c clonedPersonEntIdDetls = personEntIdDetls.clone(false, true, false, false);
                            clonedPersonEntIdDetls.PersonEntity_Detail__c = personEntIdDetls.PersonEntity_Detail__c != null
                                ? personEntiDtlOldIdMap.get(personEntIdDetls.PersonEntity_Detail__c)
                                : null;
                            recordsToClone.add(clonedPersonEntIdDetls);
                        }
                    }
                    if(!personEntDtl.Borrower_Delinquencys__r.isEmpty()){
                        for (CM_Borrower_Delinquency__c borrDelqncys : personEntDtl.Borrower_Delinquencys__r) {
                            CM_Borrower_Delinquency__c clonedBorrDelqncys = borrDelqncys.clone(false, true, false, false);
                            clonedBorrDelqncys.PersonEntityDetail__c = borrDelqncys.PersonEntityDetail__c != null
                                ? personEntiDtlOldIdMap.get(borrDelqncys.PersonEntityDetail__c)
                                : null;
                            recordsToClone.add(clonedBorrDelqncys);
                        }
                    }
                }
                // }
            }
            if (!recordsToClone.isEmpty()) {
                insert recordsToClone;
            }
            recordsToClone.clear();
            if (!bureauOldIdMap.keyset().isEmpty()) {
                List<CM_LocationDetail__c> locationDtls = [SELECT Id,BureauResponse__c,ConNum__c,FaxNum__c,Message__c,(SELECT Id,LocationDetail__c,Address__c,BorrowerOficLocType__c,FstRptDte__c,LstReptdDte__c,NumOfInst__c FROM LocationInfos__r) FROM CM_LocationDetail__c WHERE BureauResponse__c IN :bureauOldIdMap.keyset()];
                if(!locationDtls.isEmpty()){
                    for(CM_LocationDetail__c locatDtl : locationDtls){
                        CM_LocationDetail__c clonedLocatDtl = locatDtl.clone(false, true, false, false);
                        clonedLocatDtl.BureauResponse__c = locatDtl.BureauResponse__c != null
                            ? bureauOldIdMap.get(locatDtl.BureauResponse__c)
                            : null;
                        recordsToClone.add(clonedLocatDtl);
                    }
                }
                
                if (!recordsToClone.isEmpty()) {
                    // Insert cloned applicants and update map with new IDs
                    insert recordsToClone;
                    
                    for (Integer i = 0; i < recordsToClone.size(); i++) {
                        locationDtlOldIdMap.put(
                            locationDtls[i].Id,
                            recordsToClone[i].Id
                        );
                    }
                }
                recordsToClone.clear();
                if(!locationDtlOldIdMap.keyset().isEmpty() && !locationDtls.isEmpty()){
                    for(CM_LocationDetail__c locatDtl : locationDtls){
                        if(!locatDtl.LocationInfos__r.isEmpty()){
                            for (CM_LocationInfo__c locInfo : locatDtl.LocationInfos__r) {
                                CM_LocationInfo__c clonedLocInfo = locInfo.clone(false, true, false, false);
                                clonedLocInfo.LocationDetail__c = locInfo.LocationDetail__c != null
                                    ? locationDtlOldIdMap.get(locInfo.LocationDetail__c)
                                    : null;
                                recordsToClone.add(clonedLocInfo);
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
                // Calling Batch Class to Clone Documents
                CloneDocDtlAttachments batchJob = new CloneDocDtlAttachments(
                  inputdata,
                  inputdata.recordId,
                  clonedLoanAppId,
                  appWithOldIdMapNew
                );
                Database.executeBatch(batchJob);
              }
        }catch (Exception e) {
            if (clonedLoanAppId != null) {
                CloneRollbackHanlder.rollbackClonedloanApp(clonedLoanAppId);
              }
            GlobalUtility.logMessage(
                'Error',
                'CloneBureauDataThreeJob',
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