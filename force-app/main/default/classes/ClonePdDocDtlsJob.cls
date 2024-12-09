public class ClonePdDocDtlsJob implements Queueable, Database.AllowsCallouts {
    private CloneLoanAppController.CloneLoanAppwrpr inputdata;
    private String loanProduct;
    private Id clonedLoanAppId;
    
    public ClonePdDocDtlsJob(
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
            Map<Id, Id> pdOldIdMap = new Map<Id, Id>();
            Map<Id, Id> appAssetOldIdMap = new Map<Id, Id>();
            Map<Id, Id> propQueRespOldIdMap = new Map<Id, Id>();
            List<SObject> recordsToClone = new List<SObject>();
            
            List<Applicant__c> applicants = [
                SELECT Id, ClonedFor__c
                FROM Applicant__c
                WHERE LoanAppln__c = :clonedLoanAppId AND ApplType__c IN ('P', 'C', 'G')
            ];
            if (!applicants.isEmpty()) {
                for (Applicant__c applicant : applicants) {
                    appWithOldIdMap.put(applicant.ClonedFor__c, applicant.Id);
                }
            }
            if (
                !appWithOldIdMap.keyset().isEmpty() && inputData.cloneReason != null
            ) {
                CloneMetadataUtility.CloneMtdUtilityWrpr returnDat = CloneMetadataUtility.getCloneStatus(
                    'PD',
                    inputData.cloneReason
                );
                List<String> products = returnDat.productType.split(':');
                if (
                    returnDat.cloneStatus != null &&
                    returnDat.cloneStatus == 'Yes' &&
                    products.contains(loanProduct)
                ) {
                    Set<Id> appIds = appWithOldIdMap.keyset();
                    String appIdsString =
                        '(\'' +
                        String.join(new List<Id>(appIds), '\',\'') +
                        '\')';
                    String pdQuery =
                        'SELECT ' +
                        returnDat.fields +
                        ' FROM PD__c WHERE Appl__c IN ' +
                        appIdsString +
                        ' AND PDStatus__c = \'Completed\'';
                    System.debug('pdQuery ==>> ' + pdQuery);
                    
                    List<PD__c> pdRecords = Database.query(pdQuery);
                    if (!pdRecords.isEmpty()) {
                        for (PD__c pd : pdRecords) {
                            PD__c clonedpd = pd.clone(false, true, false, false);
                            clonedpd.Appl__c = pd.Appl__c != null
                                ? appWithOldIdMap.get(pd.Appl__c)
                                : null;
                            clonedpd.LoanAppl__c = clonedLoanAppId;
                            clonedpd.ClonedSource__c = pd.Id;
                            recordsToClone.add(clonedpd);
                        }
                    }
                    if (!recordsToClone.isEmpty()) {
                        TriggerActionFlow.bypass('Notification_and_Email_when_assigned_the_PD_to_User'); //LAK-10103
                        insert recordsToClone;
                        TriggerActionFlow.clearBypass('Notification_and_Email_when_assigned_the_PD_to_User'); //LAK-10103
                        for (Integer i = 0; i < recordsToClone.size(); i++) {
                            // if (pdSaveResults[i].isSuccess()) {
                            pdOldIdMap.put(pdRecords[i].Id, recordsToClone[i].Id);
                            // }
                        }
                        recordsToClone.clear();
                    }
                }
                
                CloneMetadataUtility.CloneMtdUtilityWrpr returnData = CloneMetadataUtility.getCloneStatus(
                    'ApplAsset',
                    inputData.cloneReason
                );
                List<String> loanProducts = returnData.productType.split(':');
                if (
                    returnData.cloneStatus != null &&
                    returnData.cloneStatus == 'Yes' &&
                    loanProducts.contains(loanProduct)
                ) {
                    Set<Id> applicantIds = appWithOldIdMap.keyset();
                    String applicantIdsString =
                        '(\'' +
                        String.join(new List<Id>(applicantIds), '\',\'') +
                        '\')';
                    
                    String appAssetQuery =
                        'SELECT ' +
                        returnData.fields +
                        ' FROM ApplAsset__c WHERE Appl__c IN ' +
                        applicantIdsString;
                    System.debug('appAssetQuery ==>> ' + appAssetQuery);
                    
                    List<ApplAsset__c> applAssets = Database.query(appAssetQuery);
                    
                    if (!applAssets.isEmpty()) {
                        for (ApplAsset__c appAsset : applAssets) {
                            ApplAsset__c clonedApplAsset = appAsset.clone(
                                false,
                                true,
                                false,
                                false
                            );
                            clonedApplAsset.Appl__c = appAsset.Appl__c != null
                                ? appWithOldIdMap.get(appAsset.Appl__c)
                                : null;
                            clonedApplAsset.LoanAppln__c = clonedLoanAppId;
                            clonedApplAsset.PrsnlDis__c = appAsset.PrsnlDis__c != null
                                ? pdOldIdMap.get(appAsset.PrsnlDis__c)
                                : null;
                            clonedApplAsset.ClonedSource__c = appAsset.Id;
                            recordsToClone.add(clonedApplAsset);
                        }
                        if (!recordsToClone.isEmpty()) {
                            insert recordsToClone;
                            for (Integer i = 0; i < recordsToClone.size(); i++) {
                                appAssetOldIdMap.put(applAssets[i].Id, recordsToClone[i].Id);
                            }
                        }
                        recordsToClone.clear();
                    }
                    if(!appAssetOldIdMap.keyset().isEmpty()){
                        List<ApplAssetJn__c> applAssetJnList = [SELECT Id,Appl__c,ApplAsset__c FROM ApplAssetJn__c WHERE ApplAsset__c IN : appAssetOldIdMap.keyset()];
                        if(!applAssetJnList.isEmpty()){
                            for(ApplAssetJn__c appAssetJn : applAssetJnList){
                                ApplAssetJn__c clonedAppAssetJn = appAssetJn.clone(
                                    false,
                                    true,
                                    false,
                                    false
                                );
                                clonedAppAssetJn.ApplAsset__c = appAssetJn.ApplAsset__c != null
                                    ? appAssetOldIdMap.get(appAssetJn.ApplAsset__c)
                                    : null;
                                clonedAppAssetJn.Appl__c = appAssetJn.Appl__c != null
                                    ? appWithOldIdMap.get(appAssetJn.Appl__c)
                                    : null;
                                recordsToClone.add(clonedAppAssetJn);
                            }
                        }
                        
                        if (!recordsToClone.isEmpty()) {
                            insert recordsToClone;
                        }
                        recordsToClone.clear();
                    }
                    if(!appAssetOldIdMap.keyset().isEmpty()){
                        List<PropQuesResp__c> properQuesResList = [SELECT Id,CmpltBy__c,CmpltDt__c,CreatedBy__c,LoanApplc__c,ProdTyp__c,Property__c FROM PropQuesResp__c WHERE Property__c =: appAssetOldIdMap.keyset()];
                        if(!properQuesResList.isEmpty()){
                            for(PropQuesResp__c propQueResp : properQuesResList){
                                PropQuesResp__c clonedPropQueResp = propQueResp.clone(
                                    false,
                                    true,
                                    false,
                                    false
                                );
                                clonedPropQueResp.Property__c = propQueResp.Property__c != null
                                    ? appAssetOldIdMap.get(propQueResp.Property__c)
                                    : null;
                                clonedPropQueResp.LoanApplc__c = clonedLoanAppId;
                                recordsToClone.add(clonedPropQueResp);
                            }
                        }
                        if (!recordsToClone.isEmpty()) {
                            insert recordsToClone;
                            for (Integer i = 0; i < recordsToClone.size(); i++) {
                                propQueRespOldIdMap.put(properQuesResList[i].Id, recordsToClone[i].Id);
                            }
                        }
                        recordsToClone.clear();
                    }
                    if(!propQueRespOldIdMap.keyset().isEmpty()){
                        List<PropQuesRespJn__c> properQuesResJnList = [SELECT Id,Cmnts__c,PropQuest__c,PropQuesResp__c,Ques__c,Resp__c FROM PropQuesRespJn__c WHERE PropQuesResp__c =: propQueRespOldIdMap.keyset()];
                        if(!properQuesResJnList.isEmpty()){
                            for(PropQuesRespJn__c propQueRespJn : properQuesResJnList){
                                PropQuesRespJn__c clonedPropQueRespJn = propQueRespJn.clone(
                                    false,
                                    true,
                                    false,
                                    false
                                );
                                clonedPropQueRespJn.PropQuesResp__c = propQueRespJn.PropQuesResp__c != null
                                    ? propQueRespOldIdMap.get(propQueRespJn.PropQuesResp__c)
                                    : null;
                                recordsToClone.add(clonedPropQueRespJn);
                            }
                        }
                        if (!recordsToClone.isEmpty()) {
                            insert recordsToClone;
                        }
                        recordsToClone.clear();
                    }
                }
            }
            if(!Test.isRunningTest()){
                System.enqueueJob(
                    new CloneCaseJob(inputData, loanProduct, clonedLoanAppId)
                );
            }
        } catch (Exception e) {
            if (clonedLoanAppId != null) {
                CloneRollbackHanlder.rollbackClonedloanApp(clonedLoanAppId);
            }
            GlobalUtility.logMessage(
                'Error',
                'ClonePdDocDtlsJob',
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