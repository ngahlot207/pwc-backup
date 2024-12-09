public class CloneCaseJob implements Queueable, Database.AllowsCallouts {
    private CloneLoanAppController.CloneLoanAppwrpr inputdata;
    private String loanProduct;
    private Id clonedLoanAppId;
    
    public CloneCaseJob(
        CloneLoanAppController.CloneLoanAppwrpr inputdata,
        string loanProduct,
        Id clonedLoanAppId
    ) {
        this.inputdata = inputdata;
        this.loanProduct = loanProduct;
        this.clonedLoanAppId = clonedLoanAppId;
    }
    
    public void execute(QueueableContext context) {
        try {
            String cloneRes = '';
            String fields = '';
            String cloneLoanSts = '';
            if (inputdata.cloneReason != null) {
                if (inputdata.cloneReason == 'BT + Top Up') {
                    cloneRes = 'CloneBTTopUp__c';
                } else if (inputdata.cloneReason == 'Top up') {
                    cloneRes = 'CloneTopup__c';
                } else if (inputdata.cloneReason == 'Different Property') {
                    cloneRes = 'CloneDiffProp__c';
                } else if (inputdata.cloneReason == 'Other') {
                    cloneRes = 'CloneOthr__c';
                }
            }
            String queryString =
                'SELECT Id, Label, DeveloperName, RecordTypeName__c,Fields__c, ProdTyp__c, CloneTopup__c, CloneOthr__c, CloneDiffProp__c, CloneBTTopUp__c FROM LoanCloningFieldDetails__mdt WHERE Label = \'Case\' AND ' + cloneRes + ' = \'Yes\'';
            
            List<LoanCloningFieldDetails__mdt> loanCloningMdt = Database.query(
                queryString
            );
            
            Map<Id, Id> appWithOldIdMap = new Map<Id, Id>();
            Map<Id, Id> appAddrsWithOldIdMap = new Map<Id, Id>();
            Map<Id, Id> appAssetWithOldIdMap = new Map<Id, Id>();
            Map<Id, Id> applKycOldIdMap = new Map<Id, Id>();
            Map<Id, Id> caseOldMap = new Map<Id, Id>();
            
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
                (SELECT Id, ClonedSource__c FROM Applicant_Addresses__r),
                (SELECT Id, ClonedSource__c FROM Applicant_Assets__r)
                FROM Applicant__c
                WHERE LoanAppln__c = :clonedLoanAppId AND ApplType__c IN ('P', 'C', 'G')
            ];
            
            if (!applicants.isEmpty()) {
                for (Applicant__c applicant : applicants) {
                    appWithOldIdMap.put(applicant.ClonedFor__c, applicant.Id);
                    if (!applicant.Applicant_Assets__r.isEmpty()) {
                        for (ApplAsset__c appAsset : applicant.Applicant_Assets__r) {
                            appAssetWithOldIdMap.put(appAsset.ClonedSource__c, appAsset.Id);
                        }
                    }
                    if (!applicant.Applicant_Addresses__r.isEmpty()) {
                        for (ApplAddr__c appAddrss : applicant.Applicant_Addresses__r) {
                            appAddrsWithOldIdMap.put(appAddrss.ClonedSource__c, appAddrss.Id);
                        }
                    }
                }
            }
            
            if (inputData.recordId != null) {
                if (!loanCloningMdt.isEmpty()) {
                    system.debug('loanCloningMdt ' + loanCloningMdt);
                    List<String> recordTypes = new List<String>();
                    for (LoanCloningFieldDetails__mdt lc : loanCloningMdt) {
                        recordTypes.add(lc.RecordTypeName__c);
                    }
                    system.debug('recordTypes' + recordTypes);
                    // Set<Id> applicantIds = applicantIdMap.keyset();
                    String recordTypesList =
                        '(\'' +
                        String.join(new List<String>(recordTypes), '\',\'') +
                        '\')';
                    system.debug('recordTypesList ' + recordTypesList);
                    String caseQuery =
                        'SELECT ' +
                        loanCloningMdt[0].Fields__c +
                        ',RecordType.Name FROM Case WHERE Loan_Application__c = \'' + inputData.recordId + '\' AND RecordType.Name IN ' + recordTypesList;
                    
                    system.debug('caseQuery ==>> ' + caseQuery);
                    List<Case> caseRecords = Database.query(caseQuery);
                    
                    if (!caseRecords.isEmpty()) {
                        for (Case cas : caseRecords) {
                            //WaiveCPV__c added for LAK-9375             
                            if (
                                (cas.RecordType.Name == 'Collateral Visit' &&
                                 cas.CVStatus__c == 'Completed' && cas.ApplAssetId__c != null) ||
                                (cas.RecordType.Name == 'Vetting' &&
                                 cas.Status == 'Closed' && cas.ApplAssetId__c != null) || 
                                (cas.RecordType.Name == 'CPVFI' &&
                                 (cas.Status == 'Closed' || cas.WaiveCPV__c == 'Yes')) ||
                                (cas.RecordType.Name == 'Legal' &&
                                 cas.HubManagerReview__c == 'Legal Approved' && cas.Status == 'Closed' && cas.ApplAssetId__c != null) ||
                                (cas.RecordType.Name == 'RCU' &&
                                 cas.Status == 'Closed' && cas.AccountId == null && cas.ContactId == null) ||
                                (cas.RecordType.Name == 'Technical' &&
                                 cas.Status == 'Closed' && cas.HubManagerReview__c == 'Technical Approved' && cas.ApplAssetId__c != null) ||
                                (cas.RecordType.Name == 'TSR' &&
                                 cas.Status == 'Closed' && cas.HubManagerReview__c == 'Legal Approved' && cas.ApplAssetId__c != null) ||
                                (cas.RecordType.Name == 'LIP Vendor case' &&
                                 cas.Status == 'Closed')
                            ) {
                                Case clonedCase = cas.clone(false, true, false, false);
                                clonedCase.Loan_Application__c = clonedLoanAppId;
                                clonedCase.Applicant__c = cas.Applicant__c != null
                                    ? appWithOldIdMap.get(cas.Applicant__c)
                                    : null;
                                clonedCase.ApplAddr__c = cas.ApplAddr__c != null
                                    ? appAddrsWithOldIdMap.get(cas.ApplAddr__c)
                                    : null;
                                clonedCase.ApplAssetId__c = cas.ApplAssetId__c != null
                                    ? appAssetWithOldIdMap.get(cas.ApplAssetId__c)
                                    : null;
                                if(cas.ReportResult__c != null && cas.ReportResult__c =='Positive' && cas.RecordType.Name == 'CPVFI'){
                                    clonedCase.Negative_Report_reason__c = null;
                                }
                                //LAK-10379
                                //commented for LAK-10203
                                // if(cas.RecordType.Name != null && cas.RecordType.Name != 'Collateral Visit'){
                                //     clonedCase.Date_of_Report__c = Date.today();
                                //     clonedCase.DateofVisit__c = null;
                                // }else{
                                //     clonedCase.DateofVisit__c = Date.today();
                                //     clonedCase.Date_of_Report__c = null;
                                // }
                                
                                clonedCase.ClonedSource__c = cas.Id;
                                recordsToClone.add(clonedCase);
                            }
                        }
                        if (!recordsToClone.isEmpty()) {
                            insert recordsToClone; 
                            for (Integer i = 0; i < recordsToClone.size(); i++) {
                                // Ensure caseRecords has enough elements to avoid IndexOutOfBoundsException
                                if (i < caseRecords.size()) {
                                    System.debug('RecordType.Name: ' + caseRecords[i].RecordType.Name);
                                    System.debug('recordsToClone record: ' + recordsToClone[i]);
                                    
                                  //  if (caseRecords[i].RecordType.Name == 'RCU') {
                                        // Using dynamic access to check for ClonedSource__c
                                        Object clonedSource = recordsToClone[i].get('ClonedSource__c');
                                        if (clonedSource != null) {
                                            caseOldMap.put((String) clonedSource, recordsToClone[i].Id);
                                        } else {
                                            System.debug('ClonedSource__c is null for record: ' + recordsToClone[i]);
                                        }
                                    //}
                                } else {
                                    System.debug('Index ' + i + ' is out of bounds for caseRecords.');
                                }
                            }
                            
                            
                            system.debug('caseOldMap cases ' + caseOldMap);
                            recordsToClone.clear();
                        }
                        if(!caseOldMap.keyset().isEmpty() && caseOldMap.keyset().size() > 0){
                            
                            List<String> caseIdsList = new List<String>();
                            for (Id casId : caseOldMap.keyset()) {
                                caseIdsList.add(casId);
                            }
                            String caseIds =
                                '(\'' +
                                String.join(new List<String>(caseIdsList), '\',\'') +
                                '\')';
                            String caseChildQuery =
                                'SELECT ' +
                                loanCloningMdt[0].Fields__c +
                                ',RecordType.Name FROM Case WHERE Case__c IN ' + caseIds;
                            system.debug('caseChildQuery ' + caseChildQuery);
                            List<Case> caseChildRecords = Database.query(caseChildQuery);
                            if(!caseChildRecords.isEmpty()){
                                    for (Case cas : caseChildRecords) {
                                if(cas.AccountId != null && cas.ContactId != null){
                                    Case clonedChildCase = cas.clone(false, true, false, false);
                                    clonedChildCase.Loan_Application__c = clonedLoanAppId;
                                    clonedChildCase.Applicant__c = cas.Applicant__c != null
                                        ? appWithOldIdMap.get(cas.Applicant__c)
                                        : null;
                                    clonedChildCase.ApplAddr__c = cas.ApplAddr__c != null
                                        ? appAddrsWithOldIdMap.get(cas.ApplAddr__c)
                                        : null;
                                    clonedChildCase.ApplAssetId__c = cas.ApplAssetId__c != null
                                        ? appAssetWithOldIdMap.get(cas.ApplAssetId__c)
                                        : null;
                                    clonedChildCase.Case__c = cas.Case__c != null
                                        ? caseOldMap.get(cas.Case__c)
                                        : null;
                                    clonedChildCase.ClonedSource__c = cas.Id;
                                    recordsToClone.add(clonedChildCase);
                                } 
                                //}
                            }
                            }
                        }
                        if (!recordsToClone.isEmpty()) {
                            insert recordsToClone; 
                            recordsToClone.clear();
                        }
                        // recordsToClone.clear();
                    }
                }
            }
            if (!appWithOldIdMap.keyset().isEmpty()) {
                
                CloneMetadataUtility.CloneMtdUtilityWrpr returnData = CloneMetadataUtility.getCloneStatus(
                    'ApplKyc',
                    inputData.cloneReason
                );
                List<String> loanProducts = returnData.productType.split(':');
                if (
                    returnData.cloneStatus != null &&
                    returnData.cloneStatus == 'Yes' &&
                    loanProducts.contains(loanProduct)
                ) {
                    recordsToClone.clear();
                    // List<ApplKyc__c> appKycRecrs = [
                    //   SELECT
                    //     Id,
                    //     Applicant__c,
                    //     AadharConsent__c,
                    //     AadharNo__c,
                    //     Address__c,
                    //     AdhrAdd__c,
                    //     AdhrVer__c,
                    //     DLExpDt__c,
                    //     DLIssueDt__c,
                    //     DLIssueDt_del__c,
                    //     DLNo__c,
                    //     DtOfBirth__c,
                    //     DtOfExp__c,
                    //     DtOfIssue__c,
                    //     FatherName__c,
                    //     FileNo__c,
                    //     Gender__c,
                    //     NameInAdhr__c,
                    //     Name__c,
                    //     PassExpDt__c,
                    //     PassIssueDt__c,
                    //     PassNo__c,
                    //     ValidtdOn__c,
                    //     VotIdEpicNo__c,
                    //     OTP__c,
                    //     kycDoc__c,
                    //     kycId__c,
                    //     validated__c,
                    //     Pan__c,
                    //     NameInPan__c,
                    //     OCRStatus__c,
                    //     ValidationStatus__c,
                    //     AddrLine1__c,
                    //     AddrLine2__c,
                    //     Locality__c,
                    //     City__c,
                    //     Country__c,
                    //     HouseNo__c,
                    //     Landmark__c,
                    //     MailAddr__c,
                    //     State__c,
                    //     Pincode__c,
                    //     Street__c,
                    //     UUID__c,
                    //     UUID_Error__c,
                    //     OTP_Count__c,
                    //     DLNonTransportFrom__c,
                    //     DLNonTransportTo__c,
                    //     DLTransportFrom__c,
                    //     DLTransportTo__c,
                    //     District__c,
                    //     AddressType__c,
                    //     DLStatus__c,
                    //     PassNoMatch__c,
                    //     PassApplType__c,
                    //     PassNameMatch__c,
                    //     PassNameMatchScore__c,
                    //     RelationshipType__c,
                    //     OCR_Error_Message__c,
                    //     Validation_Error_Message__c,
                    //     HusbandName__c,
                    //     TransactionId__c,
                    //     LName__c,
                    //     ReferenceId__c,
                    //     AadharMasked__c,
                    //     AadharMaskingError__c,
                    //     VillageTownCity__c,
                    //     SubDistrict__c,
                    //     AadharEncripted__c,
                    //     NPRNumber__c,
                    //     DOBValidationStatus__c,
                    //     OtherDocName__c,
                    //     DateOfUdyamRegistration__c,
                    //     TypeOfEnterprise_URC__c,
                    //     Industry_URC__c,
                    //     SubSector_URC__c,
                    //     Activity_URC__c,
                    //     NIC_URC__c,
                    //     ActivityDescription_URC__c,
                    //     GSTSearchAPIStatus__c,
                    //     AdrsSplitStatus__c,
                    //     OrgType__c,
                    //     AdrsSplitErrMess__c,
                    //     RegNo__c,
                    //     UdyamPrfName__c,
                    //     DteOfIncorp__c,
                    //     DteOfComm__c,
                    //     ConsumerId__c,
                    //     SvcProvider__c,
                    //     BillDist__c,
                    //     Area__c,
                    //     AreaCode__c,
                    //     ScvProviderCode__c,
                    //     ElectBillNo__c,
                    //     ElectConsrName__c,
                    //     Email__c,
                    //     ShopEstCat__c,
                    //     ShopEstStatus__c,
                    //     ShopEstOwnername__c,
                    //     ShopEstEntityname__c,
                    //     DtOfShopEstReg__c,
                    //     ShopEstCon__c,
                    //     ShopEstTotWorkers__c,
                    //     ShopEstNatureBus__c,
                    //     ShopEstValidFrom__c,
                    //     ElectAmtPayable__c,
                    //     ElectBillAmt__c,
                    //     MobileNo__c,
                    //     ElectTotAmt__c,
                    //     Name_Match_Score__c,
                    //     Name_Match_API_Error_Msg__c,
                    //     NameMatchAPIStatus__c,
                    //     GSTSearchAPIErrorMsg__c,
                    //     ClonedSource__c
                    //   FROM ApplKyc__c
                    //   WHERE Applicant__c IN :appWithOldIdMap.keyset()
                    // ];
                    Set<Id> applicantIds = appWithOldIdMap.keyset();
                    String applicantIdsString =
                        '(\'' +
                        String.join(new List<Id>(applicantIds), '\',\'') +
                        '\')';
                    String applKycQuery;
                    //LAK-9732
                    if(loginAccData == true){
                        applKycQuery =
                            'SELECT ' +
                            returnData.fields +
                            ' FROM ApplKyc__c WHERE Applicant__c IN ' +
                            applicantIdsString;
                    }else{
                        applKycQuery =
                            'SELECT Id,OtherDocName__c,kycDoc__c,Applicant__c FROM ApplKyc__c WHERE Applicant__c IN ' +
                            applicantIdsString;
                    }
                    
                    System.debug('applKycQuery ==>> ' + applKycQuery);
                    
                    List<ApplKyc__c> appKycRecrs = Database.query(applKycQuery);
                    if (!appKycRecrs.isEmpty()) {
                        for (ApplKyc__c applKyc : appKycRecrs) {
                            ApplKyc__c clonedApplKyc = applKyc.clone(false, true, false, false);
                            clonedApplKyc.Applicant__c = applKyc.Applicant__c != null
                                ? appWithOldIdMap.get(applKyc.Applicant__c)
                                : null;
                            clonedApplKyc.ClonedSource__c = applKyc.Id;
                            recordsToClone.add(clonedApplKyc);
                        }
                    }
                    if (!recordsToClone.isEmpty()) {
                        insert recordsToClone;
                        for (Integer i = 0; i < recordsToClone.size(); i++) {
                            applKycOldIdMap.put(appKycRecrs[i].Id, recordsToClone[i].Id);
                        }
                        recordsToClone.clear();
                    }
                }
            }
            if(!Test.isRunningTest()){
                System.enqueueJob(
                    new CloneAppIncomeGStJob(inputdata, loanProduct, clonedLoanAppId)
                );
            }
        } catch (Exception e) {
            if (clonedLoanAppId != null) {
                CloneRollbackHanlder.rollbackClonedloanApp(clonedLoanAppId);
            }
            GlobalUtility.logMessage(
                'Error',
                'CloneCaseJob',
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