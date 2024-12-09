public class CloneIntMsgJobData implements Queueable, Database.AllowsCallouts {
    private CloneLoanAppController.CloneLoanAppwrpr inputdata;
    private String loanProduct;
    private Id clonedLoanAppId;
    
    public CloneIntMsgJobData(
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
            Map<Id, Id> docDtlWithOldIdMap = new Map<Id, Id>();
            Map<Id, Id> apiVerWithOldIdMap = new Map<Id, Id>();
            List<SObject> recordsToClone = new List<SObject>();
             //LAK-9375
      LoanAppl__c loanApp = [SELECT Id, Product__c, Stage__c, SubStage__c,LoginAcceptDate__c FROM LoanAppl__c WHERE Id = :inputdata.recordId LIMIT 1];
      Date todayDate = Date.today();
      Boolean loginAccData = true;
      Date comparisonDate = todayDate.addDays(-30);
      if (loanApp.LoginAcceptDate__c != null && loanApp.LoginAcceptDate__c <= comparisonDate) {
        loginAccData = false;
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
                CloneMetadataUtility.CloneMtdUtilityWrpr returnDat = CloneMetadataUtility.getCloneStatus('Watchout', inputData.cloneReason);
                List<String> products = returnDat.productType.split(':');
                if(returnDat.cloneStatus != null && returnDat.cloneStatus == 'Yes' && products.contains(loanProduct) && loginAccData == true){
                    Set<Id> appIds = appWithOldIdMap.keyset();
                    String appIdsString =
                        '(\'' +
                        String.join(new List<Id>(appIds), '\',\'') +
                        '\')';
                    
                    String watchOutQuery =
                        'SELECT ' +
                        returnDat.fields +
                        ' FROM APIVer__c WHERE Appl__c IN ' + appIdsString + ' AND recordtype.Name =\'Watchout\' AND IsLatest__c = true';
                    System.debug('watchOutQuery ==>> ' + watchOutQuery);
                    
                    List<APIVer__c> watchOutData = Database.query(
                        watchOutQuery
                    );
                    
                    if (!watchOutData.isEmpty()) {
                        for (APIVer__c apiVer : watchOutData) {
                            APIVer__c clonedApiVer = apiVer.clone(
                                false,
                                true,
                                false,
                                false
                            );
                            clonedApiVer.Appl__c = apiVer.Appl__c != null
                                ? appWithOldIdMap.get(apiVer.Appl__c)
                                : null;
                            clonedApiVer.LoanAplcn__c = clonedLoanAppId;
                            clonedApiVer.Document_Detail_Id__c = apiVer.Document_Detail_Id__c != null
                                ? docDtlWithOldIdMap.get(apiVer.Document_Detail_Id__c)
                                : null;
                            recordsToClone.add(clonedApiVer);
                        }
                    }
                    if (!recordsToClone.isEmpty()) {
                        MetadataTriggerHandler.bypass('APIVerificationAfterInsert'); //LAK-8409
                        insert recordsToClone;
                        MetadataTriggerHandler.clearBypass('APIVerificationAfterInsert');//LAK-8409
                        recordsToClone.clear();
                    }
                }
                
                CloneMetadataUtility.CloneMtdUtilityWrpr returnDatnew = CloneMetadataUtility.getCloneStatus('Trackwizz', inputData.cloneReason);
                List<String> productsNew = returnDatnew.productType.split(':');
                if(returnDatnew.cloneStatus != null && returnDatnew.cloneStatus == 'Yes' && productsNew.contains(loanProduct) && loginAccData == true){
                    List<String> trackWizzRecTypes = new List<String>{'Screening', 'Risk Rating'};
                        List<String> quotedTrackWizzRecTypes = new List<String>();
                    for (String recType : trackWizzRecTypes) {
                        quotedTrackWizzRecTypes.add('\'' + recType + '\'');
                    }
                    
                    String formattedTrackWizzRecTypes = '(' + String.join(quotedTrackWizzRecTypes, ', ') + ')';
                    String trackwizzQuery = 
                        'SELECT ' + returnDatnew.fields + 
                        ' FROM APIVer__c WHERE LoanAplcn__c = \'' + inputData.recordId + 
                        '\' AND IsLatest__c = true AND recordtype.name IN ' + formattedTrackWizzRecTypes;
                    
                    System.debug('trackwizzQuery ==>> ' + trackwizzQuery);
                    
                    List<APIVer__c> trackwizzData = Database.query(
                        trackwizzQuery
                    );
                    
                    if (!trackwizzData.isEmpty()) {
                        for (APIVer__c apiVer : trackwizzData) {
                            APIVer__c clonedApiVer = apiVer.clone(
                                false,
                                true,
                                false,
                                false
                            );
                            clonedApiVer.Appl__c = apiVer.Appl__c != null
                                ? appWithOldIdMap.get(apiVer.Appl__c)
                                : null;
                            clonedApiVer.LoanAplcn__c = clonedLoanAppId;
                            clonedApiVer.Document_Detail_Id__c = apiVer.Document_Detail_Id__c != null
                                ? docDtlWithOldIdMap.get(apiVer.Document_Detail_Id__c)
                                : null;
                            recordsToClone.add(clonedApiVer);
                        }
                    }
                    if (!recordsToClone.isEmpty()) {
                        MetadataTriggerHandler.bypass('APIVerificationAfterInsert'); //LAK-8409
                        insert recordsToClone;
                        MetadataTriggerHandler.clearBypass('APIVerificationAfterInsert');//LAK-8409
                        recordsToClone.clear();
                    }
                }
                
                
                CloneMetadataUtility.CloneMtdUtilityWrpr returnDatHunter = CloneMetadataUtility.getCloneStatus('Hunter', inputData.cloneReason);
                List<String> productsHunter = returnDatHunter.productType.split(':');
                if(returnDatHunter.cloneStatus != null && returnDatHunter.cloneStatus == 'Yes' && productsHunter.contains(loanProduct) && loginAccData == true){
                    Set<Id> appIdsNew = appWithOldIdMap.keyset();
                    String appIdsStringNew =
                        '(\'' +
                        String.join(new List<Id>(appIdsNew), '\',\'') +
                        '\')';
                    String hunterQuery = 'SELECT ' + returnDatHunter.fields +' FROM HunterVer__c  WHERE Appl__c IN ' + appIdsStringNew + ' AND IsLatest__c = true';
                    
                    System.debug('hunterQuery ==>> ' + hunterQuery);
                    
                    List<HunterVer__c> hunterData = Database.query(
                        hunterQuery
                    );
                    
                    if (!hunterData.isEmpty()) {
                        for (HunterVer__c hunterVer : hunterData) {
                            HunterVer__c clonedHunterVer = hunterVer.clone(
                                false,
                                true,
                                false,
                                false
                            );
                            clonedHunterVer.Appl__c = hunterVer.Appl__c != null
                                ? appWithOldIdMap.get(hunterVer.Appl__c)
                                : null;
                            clonedHunterVer.ClonedSource__c = hunterVer.Id;
                            clonedHunterVer.LoanAplcn__c = clonedLoanAppId;
                            recordsToClone.add(clonedHunterVer);
                        }
                    }
                    if (!recordsToClone.isEmpty()) {
                        insert recordsToClone;
                        recordsToClone.clear();
                    }
                }
                
                
                CloneMetadataUtility.CloneMtdUtilityWrpr returnDataApi = CloneMetadataUtility.getCloneStatus('LitigationCheck', inputData.cloneReason);
                List<String> productsApi = returnDataApi.productType.split(':');
                if(returnDataApi.cloneStatus != null && returnDataApi.cloneStatus == 'Yes' && productsApi.contains(loanProduct) && loginAccData == true){
                    List<String> trackWizzRecTypes = new List<String>{'Crime Check', 'Qualification Check','Udyam','Shop & Establishment','Probe42','GST'};
                        List<String> quotedTrackWizzRecTypes = new List<String>();
                    for (String recType : trackWizzRecTypes) {
                        quotedTrackWizzRecTypes.add('\'' + recType + '\'');
                    }
                    
                    String formattedTrackWizzRecTypes = '(' + String.join(quotedTrackWizzRecTypes, ', ') + ')';
                    Set<Id> appIdsApi = appWithOldIdMap.keyset();
                    String appIdsStringApi =
                        '(\'' +
                        String.join(new List<Id>(appIdsApi), '\',\'') +
                        '\')';
                    String apiVerQuery = 
                        'SELECT ' + returnDataApi.fields + 
                        ' FROM APIVer__c WHERE Appl__c IN ' + appIdsStringApi + ' AND  IsLatest__c = true AND recordtype.name IN ' + formattedTrackWizzRecTypes;
                    
                    System.debug('apiVerQuery ==>> ' + apiVerQuery);
                    
                    List<APIVer__c> apiVerData = Database.query(
                        apiVerQuery
                    );
                    
                    if (!apiVerData.isEmpty()) {
                        for (APIVer__c apiVer : apiVerData) {
                            APIVer__c clonedApiVer = apiVer.clone(
                                false,
                                true,
                                false,
                                false
                            );
                            clonedApiVer.Appl__c = apiVer.Appl__c != null
                                ? appWithOldIdMap.get(apiVer.Appl__c)
                                : null;
                            clonedApiVer.LoanAplcn__c = clonedLoanAppId;
                            clonedApiVer.Document_Detail_Id__c = apiVer.Document_Detail_Id__c != null
                                ? docDtlWithOldIdMap.get(apiVer.Document_Detail_Id__c)
                                : null;
                            recordsToClone.add(clonedApiVer);
                        }
                    }
                    if (!recordsToClone.isEmpty()) {
                        MetadataTriggerHandler.bypass('APIVerificationAfterInsert'); //LAK-8409
                        insert recordsToClone;
                        MetadataTriggerHandler.clearBypass('APIVerificationAfterInsert');//LAK-8409
                        for (Integer i = 0; i < recordsToClone.size(); i++) {
                            apiVerWithOldIdMap.put(apiVerData[i].Id, recordsToClone[i].Id);
                        }
                        recordsToClone.clear();
                    }
                   if(!apiVerWithOldIdMap.keyset().isEmpty()){
                        List<APIVerDtl__c> apiVerDtls = [SELECT Id,APIVerification__c, College__c, QualificationYear__c, Qualification__c, RestorationDt__c, Rmrks__c, SuspensionDt__c, Type__c, University__c, AddrLine1__c, AddrLine2__c, HouseNo__c, Landmark__c, Locality__c, Location__c, NatureofBuisness__c, Pincode__c, StateCode__c, State__c, Street__c, Address__c, ApiVerDetails__c, EmailId__c, Employer_name__c, EpfHistory_Month_1_Name__c, EpfHistory_Month_2_Name__c, EpfHistory_Month_3_Name__c, IsEmployed__c, IsNameExact__c, IsRecent__c, LastMonth__c, MatchName__c, Name_Confidence__c, Name__c, TotalAmountFiledbyEmployer__c, TotalMembers__c, UanNameMatch__c, Uan__c, confidence__c, contactNo__c, emplrScore__c, epfHistory_Month_1__c, epfHistory_Month_2__c, epfHistory_Month_3__c, estId__c, formatted_wage_month__c, isNameUnique__c, memberId__c, settled__c, wageMonth__c FROM APIVerDtl__c WHERE APIVerification__c IN : apiVerWithOldIdMap.keyset()];
                        if(!apiVerDtls.isEmpty()){
                            for(APIVerDtl__c apiVerDtl : apiVerDtls){
                                APIVerDtl__c clonedApiVerDtl = apiVerDtl.clone(
                                    false,
                                    true,
                                    false,
                                    false
                                );
                                clonedApiVerDtl.APIVerification__c = apiVerDtl.APIVerification__c != null
                                    ? apiVerWithOldIdMap.get(apiVerDtl.APIVerification__c)
                                    : null;
                                recordsToClone.add(clonedApiVerDtl);
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
                    new CloneBureauRspnsesJob(inputdata, loanProduct, clonedLoanAppId)
                );
            }
        }catch (Exception e) {
            if (clonedLoanAppId != null) {
                CloneRollbackHanlder.rollbackClonedloanApp(clonedLoanAppId);
            }
            GlobalUtility.logMessage(
                'Error',
                'CloneIntMsgJobData',
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