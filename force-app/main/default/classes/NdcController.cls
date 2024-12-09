public without sharing class NdcController {
    @AuraEnabled
    public static List<NdcDataWrapr> retrieveNdcData(
        String loanAppId,
        String ndcType
    ) {
        List<NdcDataWrapr> ndcWrprList = new List<NdcDataWrapr>();
        Map<String, Object> qryBind = new Map<String, Object>();
        List<LoanAppl__c> loanRecList = new List<LoanAppl__c>();
        List<NDCConfig__c> ndcConfigList = new List<NDCConfig__c>();

        if (loanAppId != null && loanAppId != '') {
            loanRecList = [
                SELECT
                    Id,
                    Stage__c,
                    Product__c,
                    BrchCode__c,
                    NDCType__c,
                    OwnerId,SchemeId__c,
                    SubStage__c
                FROM LoanAppl__c
                WHERE Id = :loanAppId
            ];
            //Added stage check for LAK-7697
            if (
                (loanRecList[0].Stage__c == 'Post Sanction' || loanRecList[0].Stage__c == 'Disbursement Initiation') &&
                (loanRecList[0].SubStage__c == 'Data Entry' ||
                loanRecList[0].SubStage__c == 'Ops Query' || loanRecList[0].SubStage__c =='DI Check') &&
                loanRecList[0].OwnerId == UserInfo.getUserId()
            ) {
                createMandatoryDocs(loanRecList[0]);
                generateNdcRecForScrns(loanAppId);
                if (ndcType != null && ndcType != '') {
                    generateNdcRecord(loanAppId, ndcType);
                }
            }
            // else if(ndcType != null && ndcType != ''){     //Added for LAK-7697
            //         checkNdcRecordIsLatest(loanAppId,ndcType);//Added for LAK-7697
            // }//Added for LAK-7697
            if (loanRecList[0].NDCType__c != ndcType) {
                LoanAppl__c loan = loanRecList[0];
                loan.NDCType__c = ndcType;
                update loan;
            }
        }
        List<ApplAsset__c> appAssets = [
            SELECT Id, Name, PropAddrs__c
            FROM ApplAsset__c
            WHERE LoanAppln__c = :loanAppId
        ];

        List<NDC__c> ndcRecords = [
            SELECT
                Id,
                Name,
                ShowOpsQuery__c,
                OpsVer__c,
                DocDtl__c,
                Case__c,
                ApplAsset__c,
                Applicant__c,
                OpsQuery__c,
                AppCharge__c,
                AppIMD__c,
                LoanAppl__c,
                Deviation__c,
                SplitDisbrsmnt__c,
                NDC_Section__c
            FROM NDC__c
            WHERE LoanAppl__c = :loanAppId AND IsInvalid__c = FALSE
        ];
        Map<Id, String> dataEntryMap = getDataEntry(loanAppId);
        if (loanRecList.size() > 0) {
            qryBind.put('loanId', loanRecList[0].Id);
            ndcConfigList = [
                SELECT Id, DsplyCnfg__c, NDCSection__c, QryCnfg__c, SecOrdr__c
                FROM NDCConfig__c
                WHERE
                    IsActive__c = TRUE
                    AND ProdTyp__c INCLUDES (:loanRecList[0].Product__c)
                ORDER BY SecOrdr__c ASC
            ];
        }
        if (ndcConfigList.size() > 0) {
            // system.debug('ndcConfigList ' + ndcConfigList);
            //system.debug('ndcConfigList size ' + ndcConfigList.size());

            for (NDCConfig__c ndcConfig : ndcConfigList) {
                if (
                    ndcConfig.DsplyCnfg__c != null &&
                    ndcConfig.DsplyCnfg__c != '' &&
                    ndcConfig.QryCnfg__c != null &&
                    ndcConfig.QryCnfg__c != ''
                ) {
                    NdcColumnConfig ndcColumnConfig = (NdcColumnConfig) JSON.deserialize(
                        ndcConfig.DsplyCnfg__c,
                        NdcColumnConfig.class
                    );
                    NdcQueryConfiWrp ndcQueryConfig = (NdcQueryConfiWrp) JSON.deserialize(
                        ndcConfig.QryCnfg__c,
                        NdcQueryConfiWrp.class
                    );

                    Map<String, List<NDCRecord>> groupedDataMap = new Map<String, List<NDCRecord>>();
                    List<SObject> qryResult = Database.queryWithBinds(
                        ndcQueryConfig.query,
                        qryBind,
                        AccessLevel.SYSTEM_MODE
                    );
                    if (
                        ndcConfig.NDCSection__c == 'Borrower Document Details'
                    ) {
                        for (SObject sobj : qryResult) {
                            sobj.put(
                                'DataEntry__c',
                                dataEntryMap.containsKey((Id) sobj.get('Id'))
                                    ? dataEntryMap.get((Id) sobj.get('Id'))
                                    : ''
                            );
                        }
                    }
                    if (ndcColumnConfig.groupBy != null) {
                        for (SObject sobj : qryResult) {
                            List<String> splitVal = ndcColumnConfig.groupBy.split(
                                '\\.'
                            );
                            String key = '';
                            if (splitVal.size() == 1) {
                                key = (String) sobj.get(
                                    ndcColumnConfig.groupBy
                                );
                            } else if (splitVal.size() == 2) {
                                key = (String) sobj.getSObject(splitVal[0])
                                    .get(splitVal[1]);
                            }
                            List<NDCRecord> existRecords = groupedDataMap.get(
                                key
                            );
                            if (existRecords == null) {
                                existRecords = new List<NDCRecord>();
                            }
                            existRecords.add(
                                createNDCRecord(
                                    sobj,
                                    ndcQueryConfig.sobjectType,
                                    ndcConfig.NDCSection__c,
                                    ndcRecords
                                )
                            );
                            groupedDataMap.put(key, existRecords);
                        }
                    }

                    List<NdcController.TableConfig> tableConfigList = new List<NdcController.TableConfig>();
                    if (ndcColumnConfig.groupBy != null) {
                        Integer index = 1;
                        for (ApplAsset__c asset : appAssets) {
                            NdcController.TableConfig tableCon = new NdcController.TableConfig();
                            tableCon.applicantAssetId = asset.Id;
                            tableCon.ndcRecords = groupedDataMap.get(asset.Id);
                            tableCon.allowUpload = ndcColumnConfig.allowUpload;
                            tableCon.allowDelete = ndcColumnConfig.allowDelete;
                            tableCon.addDeviation = ndcColumnConfig.addDeviation;
                            tableCon.deviationCategory = ndcColumnConfig.deviationCategory;
                            tableCon.docCategory = ndcColumnConfig.docCategory;
                            tableCon.title =
                                ndcColumnConfig.title +
                                ' ' +
                                index +
                                ' - ' +
                                asset.PropAddrs__c;
                            tableCon.sobjectType = ndcQueryConfig.sobjectType;
                            tableCon.columnConfig = ndcColumnConfig.columns !=
                                null && !ndcColumnConfig.columns.isEmpty()
                                ? ndcColumnConfig.columns
                                : null;
                            tableConfigList.add(tableCon);
                            index++;
                        }
                        // for (String key : groupedDataMap.keySet()) {
                        //     NdcController.TableConfig tableCon = new NdcController.TableConfig();
                        //     tableCon.applicantAssetId = applAssetId;
                        //     tableCon.ndcRecords = groupedDataMap.get(key);
                        //     tableCon.allowUpload = ndcColumnConfig.allowUpload;
                        //     tableCon.docCategory = ndcColumnConfig.docCategory;
                        //     tableCon.columnConfig = ndcColumnConfig.columns !=
                        //         null && !ndcColumnConfig.columns.isEmpty()
                        //         ? ndcColumnConfig.columns
                        //         : null;
                        //     tableConfigList.add(tableCon);
                        // }
                    } else {
                        List<NDCRecord> ndcRecs = new List<NDCRecord>();
                        for (Sobject obj : qryResult) {
                            NDCRecord rec = createNDCRecord(
                                obj,
                                ndcQueryConfig.sobjectType,
                                ndcConfig.NDCSection__c,
                                ndcRecords
                            );
                            ndcRecs.add(rec);
                        }
                        NdcController.TableConfig tableCon = new NdcController.TableConfig();
                        tableCon.allowUpload = ndcColumnConfig.allowUpload;
                        tableCon.allowDelete = ndcColumnConfig.allowDelete;
                        tableCon.docCategory = ndcColumnConfig.docCategory;
                        tableCon.title = ndcColumnConfig.title;
                        tableCon.addDeviation = ndcColumnConfig.addDeviation;
                        tableCon.deviationCategory = ndcColumnConfig.deviationCategory;
                        tableCon.sobjectType = ndcQueryConfig.sobjectType;
                        tableCon.ndcRecords = ndcRecs;
                        tableCon.columnConfig = ndcColumnConfig.columns !=
                            null && !ndcColumnConfig.columns.isEmpty()
                            ? ndcColumnConfig.columns
                            : null;
                        tableConfigList.add(tableCon);
                    }

                    //  NdcController.TableData tableDt = new  NdcController.TableData();
                    // tableDt.tableData = tableCOnfigList;
                    //system.debug( 'ndcColumnConfig.columns size ' + ndcColumnConfig.columns.size());
                    NdcDataWrapr ndcWrpr = new NdcDataWrapr();
                    //ndcWrpr.ndcRecords = qryResult.size() > 0 ? qryResult : null;
                    // ndcWrpr.columnConfig = ndcColumnConfig.columns != null && !ndcColumnConfig.columns.isEmpty() ? ndcColumnConfig.columns : null;
                    ndcWrpr.sectionOrder = Integer.valueOf(
                        ndcConfig.SecOrdr__c
                    );
                    ndcWrpr.ndcSection = ndcConfig.NDCSection__c;
                    ndcWrpr.tablConfig = tableConfigList;
                    ndcWrprList.add(ndcWrpr);
                }
            }
        }
        if (ndcWrprList.size() > 0) {
            system.debug('ndcWrprList ' + ndcWrprList);
            system.debug('ndcWrprList size ' + ndcWrprList.size());
            return ndcWrprList;
        } else {
            return null;
        }
    }

    @TestVisible
    private static NDCRecord createNDCRecord(
        Sobject obj,
        String objType,
        String ndcSection,
        List<NDC__c> ndcRecords
    ) {
        NDCRecord ndcRec = new NDCRecord();
        ndcRec.record = obj;
        for (NDC__c ndcr : ndcRecords) {
            if (ndcSection == ndcr.NDC_Section__c) {
                if (objType == 'DocDtl__c' && ndcr.DocDtl__c == obj.Id) {
                    ndcRec.ndcId = ndcr.Id;
                    ndcRec.opsQuery = ndcr.OpsQuery__c;
                    ndcRec.showOpsQuery = ndcr.ShowOpsQuery__c;
                    break;
                } else if (
                    objType == 'ApplAsset__c' &&
                    ndcr.ApplAsset__c == obj.Id
                ) {
                    ndcRec.ndcId = ndcr.Id;
                    ndcRec.opsQuery = ndcr.OpsQuery__c;
                    ndcRec.showOpsQuery = ndcr.ShowOpsQuery__c;
                    break;
                } else if (
                    objType == 'ApplIMD__c' &&
                    ndcr.AppIMD__c == obj.Id
                ) {
                    ndcRec.ndcId = ndcr.Id;
                    ndcRec.opsQuery = ndcr.OpsQuery__c;
                    ndcRec.showOpsQuery = ndcr.ShowOpsQuery__c;
                    break;
                } else if (
                    objType == 'Deviation__c' &&
                    ndcr.Deviation__c == obj.Id
                ) {
                    ndcRec.ndcId = ndcr.Id;
                    ndcRec.opsQuery = ndcr.OpsQuery__c;
                    ndcRec.showOpsQuery = ndcr.ShowOpsQuery__c;
                    break;
                } else if (
                    objType == 'LonaApplCharges__c' &&
                    ndcr.AppCharge__c == obj.Id
                ) {
                    ndcRec.ndcId = ndcr.Id;
                    ndcRec.opsQuery = ndcr.OpsQuery__c;
                    ndcRec.showOpsQuery = ndcr.ShowOpsQuery__c;
                    break;
                } else if (
                    objType == 'Applicant__c' &&
                    ndcr.Applicant__c == obj.Id
                ) {
                    ndcRec.ndcId = ndcr.Id;
                    ndcRec.opsQuery = ndcr.OpsQuery__c;
                    ndcRec.showOpsQuery = ndcr.ShowOpsQuery__c;
                    break;
                } else if (
                    objType == 'Split_Disbur__c' &&
                    ndcr.SplitDisbrsmnt__c == obj.Id
                ) {
                    ndcRec.ndcId = ndcr.Id;
                    ndcRec.opsQuery = ndcr.OpsQuery__c;
                    ndcRec.showOpsQuery = ndcr.ShowOpsQuery__c;
                    break;
                }
            }
        }
        return ndcRec;
    }

    @AuraEnabled
    public static void saveNdcData(
        Id loanAppId,
        String ndcType,
        List<NdcDataWraprForSave> ndcSaveData,
        List<SObject> recordsToDelete,
        List<String> ndcIdsToDelete,
        List<DocDispatch__c> disObjDet
    ) {
        List<SObject> sObjectList = new List<SObject>();
        System.debug('ndcSaveData  ' + ndcSaveData);
        try {
            for (NdcDataWraprForSave ndcRec : ndcSaveData) {
                sObjectList.add(ndcRec.record);
            }
            sObjectList.sort();
            upsert sObjectList;
            if (recordsToDelete != null && recordsToDelete.size() > 0) {
                delete recordsToDelete;
            }
            generateNdcRecord(loanAppId, ndcType);
            if (disObjDet.size() > 0 && disObjDet != null) {
                for (DocDispatch__c docDis : disObjDet) {
                    if (docDis.Id == null) {
                        docDis.LoanAppln__c = loanAppId;
                    }
                }
                upsert disObjDet;
            }
            if (ndcIdsToDelete != null && ndcIdsToDelete.size() > 0) {
                List<NDC__c> ndcRecordsToDelete = [
                    SELECT Id, Name
                    FROM NDC__c
                    WHERE Id IN :ndcIdsToDelete
                ];
                delete ndcRecordsToDelete;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @TestVisible
    private static void generateNdcRecord(String loanAppId, String ndcType) {
        Map<String, Object> qryBind = new Map<String, Object>();
        List<LoanAppl__c> loanRecList = new List<LoanAppl__c>();
        List<NDCConfig__c> ndcConfigList = new List<NDCConfig__c>();
        List<NDC__c> ndcList = new List<NDC__c>();

        if (loanAppId != null && loanAppId != '') {
            loanRecList = [
                SELECT Id, Stage__c, Product__c
                FROM LoanAppl__c
                WHERE Id = :loanAppId
            ];
        }
        if (loanRecList.size() > 0) {
            qryBind.put('loanId', loanRecList[0].Id);
            ndcConfigList = [
                SELECT Id, QryCnfg__c, NDCSection__c
                FROM NDCConfig__c
                WHERE
                    IsActive__c = TRUE
                    AND ProdTyp__c INCLUDES (:loanRecList[0].Product__c)
            ];
        }

        List<NDC__c> existNdcRec = [
            SELECT
                Id,
                Name,
                OpsVer__c,
                ShowOpsQuery__c,
                DocDtl__c,
                DocDtl__r.IsLatest__c,
                DocDtl__r.DocTyp__c,
                DocDtl__r.DocCatgry__c,
                DocDtl__r.Case__r.CaseType__c,                
                Case__c,
                OpsQuery__c,
                ApplAsset__c,
                Applicant__c,
                LoanAppl__c,
                AppCharge__c,
                AppIMD__c,
                Deviation__c,
                Deviation__r.Dev_Type__c,
                Deviation__r.BRE__r.IsLatest__c,
                SplitDisbrsmnt__c,
                NDC_Section__c,
                IsInvalid__c,
                ScreenNames__c
            FROM NDC__c
            WHERE LoanAppl__c = :loanAppId AND IsInvalid__c = FALSE
        ];
        List<NDC__c> existNdcRecords = new List<NDC__c>();
        Set<Id> ids = new Set<Id>();
        for(NDC__c ndc: existNdcRec ) {
            if(ndc.DocDtl__c != null && !ids.contains(ndc.DocDtl__c)) {
                ids.add(ndc.DocDtl__c);
                existNdcRecords.add(ndc);
            }
            else if(ndc.ApplAsset__c != null && !ids.contains(ndc.ApplAsset__c)) {
                ids.add(ndc.ApplAsset__c);
                existNdcRecords.add(ndc);
            }
            else if(ndc.AppIMD__c != null && !ids.contains(ndc.AppIMD__c)) {
                ids.add(ndc.AppIMD__c);
                existNdcRecords.add(ndc);
            }
            else if(ndc.Deviation__c != null && !ids.contains(ndc.Deviation__c)) {
                ids.add(ndc.Deviation__c);
                existNdcRecords.add(ndc);
            }
            else if(ndc.AppCharge__c != null && !ids.contains(ndc.AppCharge__c)) {
                ids.add(ndc.AppCharge__c);
                existNdcRecords.add(ndc);
            }
            else if(ndc.SplitDisbrsmnt__c != null && !ids.contains(ndc.SplitDisbrsmnt__c)) {
                ids.add(ndc.SplitDisbrsmnt__c);
                existNdcRecords.add(ndc);
            }
            else if(ndc.Applicant__c != null && !ids.contains(ndc.Applicant__c)) {
                ids.add(ndc.Applicant__c);
                existNdcRecords.add(ndc);
            }
            //LAK-9355
            else if(ndc.ScreenNames__c == null){
                ndc.IsInvalid__c = true;
                ndcList.add(ndc);
            }
        }

        Map<String, List<NDC__c>> ndcRecordsBySection = new Map<String, List<NDC__c>>();
        for (NDC__c ndc : existNdcRecords) {
            List<NDC__c> ndcRecords = ndcRecordsBySection.get(
                ndc.NDC_Section__c
            );
            if (ndcRecords == null) {
                ndcRecords = new List<NDC__c>();
            }
            ndcRecords.add(ndc);
            ndcRecordsBySection.put(ndc.NDC_Section__c, ndcRecords);
        }

        if (ndcConfigList.size() > 0) {
            for (NDCConfig__c ndcConfig : ndcConfigList) {
                NdcQueryConfiWrp ndcQueryConfig = (NdcQueryConfiWrp) JSON.deserialize(
                    ndcConfig.QryCnfg__c,
                    NdcQueryConfiWrp.class
                );
                List<sObject> qryResult = Database.queryWithBinds(
                    ndcQueryConfig.query,
                    qryBind,
                    AccessLevel.SYSTEM_MODE
                );

                if (qryResult.size() > 0) {
                    for (sObject sobj : qryResult) {
                        NDCRecord existNDC = createNDCRecord(
                            sobj,
                            ndcQueryConfig.sobjectType,
                            ndcConfig.NDCSection__c,
                            existNdcRecords
                        );
                        System.debug('existNDC==' + existNDC);
                        NDC__c ndc = new NDC__c();
                        if (existNDC.ndcId != null) {
                            ndc.Id = existNDC.ndcId;
                        } else {
                            ndc.LoanAppl__c = loanAppId;
                            ndc.NDC_Section__c = ndcConfig.NDCSection__c;
                            if (ndcQueryConfig.mappings.size() > 0) {
                                List<MappingWrp> mappingsConfig = ndcQueryConfig.mappings;
                                if (mappingsConfig.size() > 0) {
                                    for (MappingWrp mapWrpr : mappingsConfig) {
                                        List<String> splitVal = mapWrpr.sourceField.split(
                                            '\\.'
                                        );
                                        system.debug('splitVal ' + splitVal);
                                        system.debug(
                                            'splitVal size ' + splitVal.size()
                                        );
                                        if (splitVal.size() == 1) {
                                            ndc.put(
                                                mapWrpr.targetField,
                                                (String) sobj.get(
                                                    mapWrpr.sourceField
                                                )
                                            );
                                        } else if (splitVal.size() == 2) {
                                            ndc.put(
                                                mapWrpr.targetField,
                                                (String) sobj.getSObject(
                                                        splitVal[0]
                                                    )
                                                    .get(splitVal[1])
                                            );
                                        }
                                    }
                                }
                            }
                        }
                        ndc.OpsVer__c = (Boolean) sobj.get('OpsVer__c');
                        ndc.NDC_Type__c = ndcType;
                        ndcList.add(ndc);
                    }
                }
                List<NDC__c> ndcRecords = ndcRecordsBySection.get(
                    ndcConfig.NDCSection__c
                );
                if (ndcRecords != null) {
                    for (NDC__c ndc : ndcRecords) {
                        //Added property docuemnts check For LAK-8478
                        //Added Property Verification Reports check for LAK-9945

                        if (
                            ndcQueryConfig.sobjectType == 'DocDtl__c' &&
                            (ndc.DocDtl__c == null ||
                            ((ndc.DocDtl__r.DocTyp__c == 'CAM Report' ||
                            ndc.DocDtl__r.DocTyp__c == 'Sanction Letter' || ndc.DocDtl__r.DocCatgry__c == 'Insurance documents') &&
                            ndc.DocDtl__r.IsLatest__c == false) || (ndc.DocDtl__r.DocCatgry__c == 'Property Documents' && ndc.ApplAsset__c == null) ||
                            (ndc.DocDtl__r.DocCatgry__c == 'Case Documents' && ndc.ApplAsset__c == null && 
                            (ndc.DocDtl__r.Case__r.CaseType__c == 'Technical'||
                            ndc.DocDtl__r.Case__r.CaseType__c == 'Vetting'||
                            ndc.DocDtl__r.Case__r.CaseType__c == 'Legal'||
                            ndc.DocDtl__r.Case__r.CaseType__c == 'TSR')) || ( ndc.DocDtl__r.DocTyp__c == 'Application Form' && ndc.DocDtl__r.IsLatest__c == false)
                            )
                        ) {
                            ndc.IsInvalid__c = true;
                            ndcList.add(ndc);
                        } else if (
                            ndcQueryConfig.sobjectType == 'ApplAsset__c' &&
                            ndc.ApplAsset__c == null
                        ) {
                            ndc.IsInvalid__c = true;
                            ndcList.add(ndc);
                        } else if (
                            ndcQueryConfig.sobjectType == 'ApplIMD__c' &&
                            ndc.AppIMD__c == null
                        ) {
                            ndc.IsInvalid__c = true;
                            ndcList.add(ndc);
                        } else if (
                            ndcQueryConfig.sobjectType == 'Deviation__c' &&
                            (ndc.Deviation__c == null ||
                            (ndc.NDC_Section__c == 'UW Deviation' &&
                            ndc.Deviation__r.Dev_Type__c == 'System' &&
                            ndc.Deviation__r.BRE__r.IsLatest__c == false))
                        ) {
                            ndc.IsInvalid__c = true;
                            ndcList.add(ndc);
                        } else if (
                            ndcQueryConfig.sobjectType ==
                            'LonaApplCharges__c' &&
                            ndc.AppCharge__c == null
                        ) {
                            ndc.IsInvalid__c = true;
                            ndcList.add(ndc);
                        } else if (
                            ndcQueryConfig.sobjectType == 'Applicant__c' &&
                            ndc.Applicant__c == null
                        ) {
                            ndc.IsInvalid__c = true;
                            ndcList.add(ndc);
                        } else if (
                            ndcQueryConfig.sobjectType == 'Split_Disbur__c' &&
                            ndc.SplitDisbrsmnt__c == null
                        ) {
                            ndc.IsInvalid__c = true;
                            ndcList.add(ndc);
                        }
                    }
                }
            }
        }
        if (ndcList.size() > 0) {
            system.debug('ndcList is ' + ndcList);
            upsert ndcList;
        }
    }
    // @TestVisible
    // private static void checkNdcRecordIsLatest(String loanAppId, String ndcType) {
    //     Map<String, Object> qryBind = new Map<String, Object>();
    //     List<LoanAppl__c> loanRecList = new List<LoanAppl__c>();
    //     List<NDCConfig__c> ndcConfigList = new List<NDCConfig__c>();
    //     List<NDC__c> ndcList = new List<NDC__c>();

    //     if (loanAppId != null && loanAppId != '') {
    //         loanRecList = [
    //             SELECT Id, Stage__c, Product__c
    //             FROM LoanAppl__c
    //             WHERE Id = :loanAppId
    //         ];
    //     }
    //     if (loanRecList.size() > 0) {
    //         qryBind.put('loanId', loanRecList[0].Id);
    //         ndcConfigList = [
    //             SELECT Id, QryCnfg__c, NDCSection__c
    //             FROM NDCConfig__c
    //             WHERE
    //                 IsActive__c = TRUE
    //                 AND ProdTyp__c INCLUDES (:loanRecList[0].Product__c)
    //         ];
    //     }
    //     List<NDC__c> existNdcRecords = [
    //         SELECT
    //             Id,
    //             Name,
    //             OpsVer__c,
    //             ShowOpsQuery__c,
    //             DocDtl__c,
    //             DocDtl__r.IsLatest__c,
    //             DocDtl__r.DocTyp__c,
    //             DocDtl__r.DocCatgry__c,
    //             Case__c,
    //             OpsQuery__c,
    //             ApplAsset__c,
    //             Applicant__c,
    //             LoanAppl__c,
    //             AppCharge__c,
    //             AppIMD__c,
    //             Deviation__c,
    //             Deviation__r.Dev_Type__c,
    //             Deviation__r.BRE__r.IsLatest__c,
    //             SplitDisbrsmnt__c,
    //             NDC_Section__c,
    //             IsInvalid__c
    //         FROM NDC__c
    //         WHERE LoanAppl__c = :loanAppId AND IsInvalid__c = FALSE
    //     ];

    //     Map<String, List<NDC__c>> ndcRecordsBySection = new Map<String, List<NDC__c>>();
    //     for (NDC__c ndc : existNdcRecords) {
    //         List<NDC__c> ndcRecords = ndcRecordsBySection.get(
    //             ndc.NDC_Section__c
    //         );
    //         if (ndcRecords == null) {
    //             ndcRecords = new List<NDC__c>();
    //         }
    //         ndcRecords.add(ndc);
    //         ndcRecordsBySection.put(ndc.NDC_Section__c, ndcRecords);
    //     }

    //     if (ndcConfigList.size() > 0) {
    //         for (NDCConfig__c ndcConfig : ndcConfigList) {
    //             List<NDC__c> ndcRecords = ndcRecordsBySection.get(
    //                 ndcConfig.NDCSection__c
    //             );
    //             if (ndcRecords != null) {
    //                 for (NDC__c ndc : ndcRecords) {
    //              NdcQueryConfiWrp ndcQueryConfig = (NdcQueryConfiWrp) JSON.deserialize(
    //                 ndcConfig.QryCnfg__c,
    //                 NdcQueryConfiWrp.class
    //             );
    //             //  List<sObject> qryResult = Database.queryWithBinds(
    //             //     ndcQueryConfig.query,
    //             //     qryBind,
    //             //     AccessLevel.SYSTEM_MODE
    //             // );

    //                     if (
    //                         ndcQueryConfig.sobjectType == 'DocDtl__c' &&
    //                         (ndc.DocDtl__c == null ||
    //                         ((ndc.DocDtl__r.DocTyp__c == 'CAM Report' ||
    //                         ndc.DocDtl__r.DocTyp__c == 'Sanction Letter' || ndc.DocDtl__r.DocCatgry__c == 'Insurance documents') &&
    //                         ndc.DocDtl__r.IsLatest__c == false))
    //                     ) {
    //                         ndc.IsInvalid__c = true;
    //                         ndcList.add(ndc);
    //                     } else if (
    //                         ndcQueryConfig.sobjectType == 'ApplAsset__c' &&
    //                         ndc.ApplAsset__c == null
    //                     ) {
    //                         ndc.IsInvalid__c = true;
    //                         ndcList.add(ndc);
    //                     } else if (
    //                         ndcQueryConfig.sobjectType == 'ApplIMD__c' &&
    //                         ndc.AppIMD__c == null
    //                     ) {
    //                         ndc.IsInvalid__c = true;
    //                         ndcList.add(ndc);
    //                     } else if (
    //                         ndcQueryConfig.sobjectType == 'Deviation__c' &&
    //                         (ndc.Deviation__c == null ||
    //                         (ndc.NDC_Section__c == 'UW Deviation' &&
    //                         ndc.Deviation__r.Dev_Type__c == 'System' &&
    //                         ndc.Deviation__r.BRE__r.IsLatest__c == false))
    //                     ) {
    //                         ndc.IsInvalid__c = true;
    //                         ndcList.add(ndc);
    //                     } else if (
    //                         ndcQueryConfig.sobjectType ==
    //                         'LonaApplCharges__c' &&
    //                         ndc.AppCharge__c == null
    //                     ) {
    //                         ndc.IsInvalid__c = true;
    //                         ndcList.add(ndc);
    //                     } else if (
    //                         ndcQueryConfig.sobjectType == 'Applicant__c' &&
    //                         ndc.Applicant__c == null
    //                     ) {
    //                         ndc.IsInvalid__c = true;
    //                         ndcList.add(ndc);
    //                     } else if (
    //                         ndcQueryConfig.sobjectType == 'Split_Disbur__c' &&
    //                         ndc.SplitDisbrsmnt__c == null
    //                     ) {
    //                         ndc.IsInvalid__c = true;
    //                         ndcList.add(ndc);
    //                     }
    //                 }
    //             }
    //         }
    //     }
    //     if (ndcList.size() > 0) {
    //         system.debug('ndcList is ' + ndcList);
    //         upsert ndcList;
    //     }
    // }

    @AuraEnabled
    public static DocDtl__c createDocDetailwithApplicantAsset(
        String applicantId,
        String loanAppId,
        string docCategory,
        string docType,
        string docSubType,
        String applicantAssetId,
        Boolean avialeblInFileValue
    ) {
        List<DocMstr__c> docMstrList = new List<DocMstr__c>();
        List<DocMstrCrtr__c> docMstrCritrList = new List<DocMstrCrtr__c>();
        List<ApplAsset__c> appAssetRecList = new List<ApplAsset__c>();
        List<DocDtl__c> docDtlList = new List<DocDtl__c>();
        List<SchMapping__c> schemeMpigList = new List<SchMapping__c>();

        LoanAppl__c loanApp = [
            SELECT
                Id,
                Stage__c,
                Product__c,
                BrchCode__c,
                ProductSubType__c,
                SchemeId__c
            FROM LoanAppl__c
            WHERE Id = :loanAppId
        ];
        if (loanApp.SchemeId__c != null) {
            schemeMpigList = [
                SELECT Id, IsBT__c, SellarBT__c
                FROM SchMapping__c
                WHERE Id = :loanApp.SchemeId__c
            ];
        }
        docMstrList = [
            SELECT Id, Catgry__c, DocSubTyp__c, DocTyp__c
            FROM DocMstr__c
            WHERE
                Catgry__c = :docCategory
                AND DocTyp__c = :docType
                AND DocSubTyp__c = :docSubType
        ];
        if (docMstrList != null && docMstrList.size() > 0) {
            docDtlList = [
                SELECT Id, DocTyp__c, DocSubTyp__c, DocCatgry__c,ApplAsset__c
                FROM DocDtl__c
                WHERE LAN__c = :loanAppId AND DocMstr__c = :docMstrList[0].Id
            ];
            //LAK-9588
            if (docDtlList != null && docDtlList.size() > 0 && docDtlList[0].DocCatgry__c != null && docDtlList[0].DocCatgry__c == 'Property Documents' && docDtlList[0].ApplAsset__c != null) {
                throw new AuraHandledException(
                    docSubType + ' Document Already Exists'
                );
            }else if (docDtlList != null && docDtlList.size() > 0 && docDtlList[0].DocCatgry__c != null && docDtlList[0].DocCatgry__c != 'Property Documents') {
                throw new AuraHandledException(
                    docSubType + ' Document Already Exists'
                );
            }
        }
        String state = '';
        // if (docCategory == 'Mandatory Post Sanction Documents') {
        //     List<LoanAppl__c> loanAplList = [
        //         SELECT Id, Stage__c, Product__c, BrchCode__c
        //         FROM LoanAppl__c
        //         WHERE Id = :loanAppId
        //     ];

        //     List<LocBrchJn__c> locBrchList = [
        //         SELECT Id, Location__r.State__c
        //         FROM LocBrchJn__c
        //         WHERE Branch__r.BrchCode__c = :loanAplList[0].BrchCode__c
        //     ];
        //     if (locBrchList.size() > 0) {
        //         state = locBrchList[0].Location__r.State__c;
        //     }
        // } else
        if (applicantAssetId != null && applicantAssetId != '') {
            appAssetRecList = [
                SELECT Id, State__c
                FROM ApplAsset__c
                WHERE Id = :applicantAssetId
            ];
            if (appAssetRecList.size() > 0) {
                state = appAssetRecList[0].State__c;
            }
        }
        String product = loanApp.Product__c;
        String prodSubType = loanApp.ProductSubType__c;
        Boolean btSchm = schemeMpigList.size() > 0
            ? schemeMpigList[0].IsBT__c
            : false;
        if (docMstrList != null && docMstrList.size() > 0) {
            docMstrCritrList = [
                SELECT id, Criticality__c, OTC__c, PDD__c, Waiver__c, Catgry__c
                FROM DocMstrCrtr__c
                WHERE
                    (State__c = :state
                    OR State__c = NULL
                    OR State__c = '')
                    AND DocMstr__c = :docMstrList[0].Id
                    AND ProdType__c INCLUDES (:product)
                    AND (Product_Sub_Type__c INCLUDES (:prodSubType)
                    OR Product_Sub_Type__c = NULL)
                    AND (BTScheme__c = :btSchm
                    OR AllBT__c = TRUE)
            ];
        }
        DocDtl__c dd = new DocDtl__c();
        dd.Appl__c = applicantId != null ? applicantId : null;
        dd.DocMstr__c = docMstrList.size() > 0 ? docMstrList[0].Id : null;
        dd.DocCatgry__c = docCategory != null ? docCategory : null;
        dd.DocSubTyp__c = docSubType != null ? docSubType : null;
        dd.DocTyp__c = docType != null ? docType : null;
        dd.DocMstrCri__c = docMstrCritrList.size() > 0
            ? docMstrCritrList[0].Id
            : null;
        dd.OTC__c = docMstrCritrList.size() > 0
            ? String.valueOf(docMstrCritrList[0].OTC__c)
            : null;
        dd.PDD__c = docMstrCritrList.size() > 0
            ? String.valueOf(docMstrCritrList[0].PDD__c)
            : null;
        dd.Waiver__c = docMstrCritrList.size() > 0
            ? String.valueOf(docMstrCritrList[0].Waiver__c)
            : null;
        dd.Catgry__c = docMstrCritrList.size() > 0
            ? docMstrCritrList[0].Catgry__c
            : null;
        dd.Criticality__c = docMstrCritrList.size() > 0
            ? docMstrCritrList[0].Criticality__c
            : null;
        dd.LAN__c = loanAppId != null ? loanAppId : null;
        dd.FileAvalbl__c = avialeblInFileValue; //LAK-4916
        if (applicantAssetId != null && applicantAssetId != '') {
            dd.ApplAsset__c = applicantAssetId;
        }

        try {
            insert dd;
            return dd;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, Map<String, List<String>>> getNdcRequiredDoc(
        String docCategory
    ) {
        Map<String, Map<String, Set<String>>> cateWithTypeAndSubType = new Map<String, Map<String, Set<String>>>();

        List<DocMstr__c> docMstrList = new List<DocMstr__c>();
        if (docCategory != '' && docCategory != null) {
            docMstrList = [
                SELECT id, Catgry__c, DocTyp__c, DocSubTyp__c
                FROM DocMstr__c
                WHERE Catgry__c = :docCategory AND Active__c = TRUE
            ];
        }
        if (docMstrList.size() > 0) {
            for (DocMstr__c dcMstr : docMstrList) {
                Map<String, Set<String>> existringRecord = cateWithTypeAndSubType.get(
                    dcMstr.Catgry__c
                );
                if (existringRecord == null) {
                    existringRecord = new Map<String, Set<String>>();
                    Set<String> subTypes = new Set<String>();
                    subTypes.add(dcMstr.DocSubTyp__c);
                    system.debug('subTypes ' + subTypes);
                    existringRecord.put(dcMstr.DocTyp__c, subTypes);
                } else {
                    Set<String> subTypes = existringRecord.get(
                        dcMstr.DocTyp__c
                    );
                    if (subTypes == null) {
                        subTypes = new Set<String>();
                    }
                    subTypes.add(dcMstr.DocSubTyp__c);
                    existringRecord.put(dcMstr.DocTyp__c, subTypes);
                }

                cateWithTypeAndSubType.put(dcMstr.Catgry__c, existringRecord);
            }
        }

        if (cateWithTypeAndSubType.size() > 0) {
            Map<String, Map<String, List<String>>> fetchAllDocs = new Map<String, Map<String, List<String>>>();
            system.debug(
                'cateWithTypeAndSubType final is' + cateWithTypeAndSubType
            );
            for (String key : cateWithTypeAndSubType.keySet()) {
                Map<String, List<String>> docTypes = new Map<String, List<String>>();
                for (
                    String docTypeKey : cateWithTypeAndSubType.get(key).keySet()
                ) {
                    docTypes.put(
                        docTypeKey,
                        new List<String>(
                            cateWithTypeAndSubType.get(key).get(docTypeKey)
                        )
                    );
                }
                fetchAllDocs.put(key, docTypes);
            }
            return fetchAllDocs;
        }
        return null;
    }

    public static void createMandatoryDocs(LoanAppl__c loanApplicationRec) {
        List<DocDtl__c> docDtlListToInsert = new List<DocDtl__c>();
        List<DocMstr__c> docMstrList = new List<DocMstr__c>();
        List<DocMstrCrtr__c> docMstrCritrList = new List<DocMstrCrtr__c>();
        Map<Id, DocMstrCrtr__c> docMstrWithDocMstrCr = new Map<Id, DocMstrCrtr__c>();
        List<SchMapping__c> schmeMapList = new List<SchMapping__c> ();
        //LAK-9736
        if(loanApplicationRec.SchemeId__c != null){
            schmeMapList = [SELECT Id,IsBT__c,SellarBT__c FROM SchMapping__c WHERE Id =: loanApplicationRec.SchemeId__c];
        }
       
        Applicant__c appRecc = [
            SELECT Id
            FROM Applicant__c
            WHERE ApplType__c = 'P' AND LoanAppln__c = :loanApplicationRec.Id
            LIMIT 1
        ];

        Repayment_Account__c repaymentRec;
        List<Repayment_Account__c> repaymentRecList = [
            SELECT id, Repayment_Mode__c
            FROM Repayment_Account__c
            WHERE
                Loan_Application__c = :loanApplicationRec.Id
                AND Is_Active__c = TRUE
        ];
        if (repaymentRecList.size() > 0) {
            repaymentRec = repaymentRecList[0];
        }

        docMstrList = [
            SELECT
                id,
                Catgry__c,
                DocTyp__c,
                DocSubTyp__c,
                (
                    SELECT Id
                    FROM Applicant_Document_Details__r
                    WHERE LAN__c = :loanApplicationRec.Id
                )
            FROM DocMstr__c
            WHERE
                Catgry__c = 'Mandatory Post Sanction Documents'
                AND Active__c = TRUE
        ];

        String state = '';

        List<LocBrchJn__c> locBrchList = [
            SELECT Id, Location__r.State__c
            FROM LocBrchJn__c
            WHERE Branch__r.BrchCode__c = :loanApplicationRec.BrchCode__c
        ];
        if (locBrchList.size() > 0) {
            state = locBrchList[0].Location__r.State__c;
        }
        docMstrCritrList = [
            SELECT
                id,
                Criticality__c,
                OTC__c,
                PDD__c,
                Waiver__c,
                DocMstr__c,
                Catgry__c
            FROM DocMstrCrtr__c
            WHERE State__c = :state
        ];
        for (DocMstrCrtr__c docMstrCrt : docMstrCritrList) {
            docMstrWithDocMstrCr.put(docMstrCrt.DocMstr__c, docMstrCrt);
        }
        Map<String, Integer> docSubTypWithDocDtl = new Map<String, Integer>();
        for (DocMstr__c dm : docMstrList) {
            docSubTypWithDocDtl.put(
                dm.DocSubTyp__c,
                dm.Applicant_Document_Details__r.size()
            );
        }
        Integer count = 0;

        if (docMstrList != null && docMstrList.size() > 0) {
            system.debug('docMstrList size is ' + docMstrList.size());
            system.debug('docMstrList ' + docMstrList);
            for (DocMstr__c dm : docMstrList) {
                system.debug(
                    'Document Details are ' + dm.Applicant_Document_Details__r
                );
                system.debug(
                    'Document Details Size ' +
                    dm.Applicant_Document_Details__r.size()
                );
                system.debug('Document Sub Type ' + dm.DocSubTyp__c);
                if (dm.Applicant_Document_Details__r.size() == 0) {
                    //LAK-9736
                    if(dm.DocTyp__c == 'Disbursal Documents' && dm.DocSubTyp__c == 'Signed BT drafts'){
                         //LAK-9736
                          if(!schmeMapList.isEmpty() && schmeMapList[0].IsBT__c == true){
                            DocDtl__c dd = new DocDtl__c();
                            dd.Appl__c = appRecc != null ? appRecc.Id : null;
                            dd.DocMstr__c = dm.Id;
                            dd.DocCatgry__c = dm.Catgry__c;
                            dd.DocSubTyp__c = dm.DocSubTyp__c;
                            dd.DocTyp__c = dm.DocTyp__c;
                            DocMstrCrtr__c docMstrCrtRec = docMstrWithDocMstrCr.get(
                                dm.Id
                            );
                            dd.DocMstrCri__c = docMstrCrtRec != null
                                ? docMstrWithDocMstrCr.get(dm.Id).Id
                                : null;
                            dd.OTC__c = docMstrCrtRec != null
                                ? String.valueOf(docMstrCrtRec.OTC__c)
                                : null;
                            dd.PDD__c = docMstrCrtRec != null
                                ? String.valueOf(docMstrCrtRec.PDD__c)
                                : null;
                            dd.Waiver__c = docMstrCrtRec != null
                                ? String.valueOf(docMstrCrtRec.Waiver__c)
                                : null;
                            dd.Catgry__c = docMstrCrtRec != null
                                ? docMstrCrtRec.Catgry__c
                                : null;
                            dd.Criticality__c = docMstrCrtRec != null
                                ? docMstrCrtRec.Criticality__c
                                : null;
                            dd.LAN__c = loanApplicationRec != null
                                ? loanApplicationRec.Id
                                : null;
                            docDtlListToInsert.add(dd);
                           }
                    }else{
                        if (
                            dm.DocTyp__c == 'Disbursal Documents' ||
                            (dm.DocTyp__c == 'Repayment Documents' &&
                            dm.DocSubTyp__c == 'Repayment Documents SPDCs')
                        ) {
                            DocDtl__c dd = new DocDtl__c();
                            dd.Appl__c = appRecc != null ? appRecc.Id : null;
                            dd.DocMstr__c = dm.Id;
                            dd.DocCatgry__c = dm.Catgry__c;
                            dd.DocSubTyp__c = dm.DocSubTyp__c;
                            dd.DocTyp__c = dm.DocTyp__c;
                            DocMstrCrtr__c docMstrCrtRec = docMstrWithDocMstrCr.get(
                                dm.Id
                            );
                            dd.DocMstrCri__c = docMstrCrtRec != null
                                ? docMstrWithDocMstrCr.get(dm.Id).Id
                                : null;
                            dd.OTC__c = docMstrCrtRec != null
                                ? String.valueOf(docMstrCrtRec.OTC__c)
                                : null;
                            dd.PDD__c = docMstrCrtRec != null
                                ? String.valueOf(docMstrCrtRec.PDD__c)
                                : null;
                            dd.Waiver__c = docMstrCrtRec != null
                                ? String.valueOf(docMstrCrtRec.Waiver__c)
                                : null;
                            dd.Catgry__c = docMstrCrtRec != null
                                ? docMstrCrtRec.Catgry__c
                                : null;
                            dd.Criticality__c = docMstrCrtRec != null
                                ? docMstrCrtRec.Criticality__c
                                : null;
                            dd.LAN__c = loanApplicationRec != null
                                ? loanApplicationRec.Id
                                : null;
                            docDtlListToInsert.add(dd);
                        } else if (dm.DocTyp__c == 'Repayment Documents') {
                            if (
                                (dm.DocSubTyp__c == 'Repayment Documents NACH' ||
                                dm.DocSubTyp__c == 'Repayment Documents PDCs') &&
                                count == 0 &&
                                docSubTypWithDocDtl.get(
                                    'Repayment Documents PDCs'
                                ) == 0 &&
                                docSubTypWithDocDtl.get(
                                    'Repayment Documents NACH'
                                ) == 0
                            ) {
                                count++;
                                DocDtl__c ddRe = new DocDtl__c();
                                ddRe.Appl__c = appRecc != null ? appRecc.Id : null;
                                ddRe.DocMstr__c = dm.Id;
                                ddRe.DocCatgry__c = dm.Catgry__c;
                                if (
                                    repaymentRec != null &&
                                    repaymentRec.Repayment_Mode__c == 'PDC'
                                ) {
                                    ddRe.DocSubTyp__c = 'Repayment Documents PDCs';
                                } else if (
                                    repaymentRec != null &&
                                    repaymentRec.Repayment_Mode__c == 'NACH'
                                ) {
                                    ddRe.DocSubTyp__c = 'Repayment Documents NACH';
                                } else {
                                    ddRe.DocSubTyp__c = dm.DocSubTyp__c;
                                }
                                ddRe.DocTyp__c = dm.DocTyp__c;
                                DocMstrCrtr__c docMstrCrtRec = docMstrWithDocMstrCr.get(
                                    dm.Id
                                );
                                ddRe.DocMstrCri__c = docMstrCrtRec != null
                                    ? docMstrWithDocMstrCr.get(dm.Id).Id
                                    : null;
                                ddRe.OTC__c = docMstrCrtRec != null
                                    ? String.valueOf(docMstrCrtRec.OTC__c)
                                    : null;
                                ddRe.PDD__c = docMstrCrtRec != null
                                    ? String.valueOf(docMstrCrtRec.PDD__c)
                                    : null;
                                ddRe.Waiver__c = docMstrCrtRec != null
                                    ? String.valueOf(docMstrCrtRec.Waiver__c)
                                    : null;
                                ddRe.Catgry__c = docMstrCrtRec != null
                                    ? docMstrCrtRec.Catgry__c
                                    : null;
                                ddRe.Criticality__c = docMstrCrtRec != null
                                    ? docMstrCrtRec.Criticality__c
                                    : null;
                                ddRe.LAN__c = loanApplicationRec != null
                                    ? loanApplicationRec.Id
                                    : null;
                                docDtlListToInsert.add(ddRe);
                            }
                        }
                    }  
                }
            }
        }

        if (docDtlListToInsert != null && docDtlListToInsert.size() > 0) {
            system.debug('docDtlListToInsert  ' + docDtlListToInsert);
            insert docDtlListToInsert;
        }
    }

    public static Map<Id, String> getDataEntry(Id loanAppId) {
        Map<Id, String> dataEntryMapByDoc = new Map<Id, String>();
        Map<Id, Applicant__c> appMap = new Map<Id, Applicant__c>(
            [
                SELECT
                    Id,
                    CustProfile__c,
                    Constitution__c,
                    LLPIN__c,
                    CIN__c,
                    DOI__c,
                    Partnership_registration_no__c,
                    DOB__c,
                    FullName__c,
                    AadhaarNo__c,
                    DLNo__c,
                    PassNo__c,
                    VotIdEpicNo__c,
                    PAN__c,
                    ApplType__c,
                    (
                        SELECT
                            Id,
                            UdyamAssistCertificate__c,
                            UdyamRegistrationNumber__c
                        FROM Applicant_Employments__r
                    ),
                    (
                        SELECT Main_GSTIN__c, GSTIN__c
                        FROM Applicant_GST__r
                    ),
                    (
                        SELECT Id, OwnType__c, FullAdrs__c, AddrTyp__c
                        FROM Applicant_Addresses__r
                    )
                FROM Applicant__c
                WHERE
                    LoanAppln__c = :loanAppId
                    AND ApplType__c IN ('P', 'G', 'C')
            ]
        );
        Map<Id, Map<String, ApplAddr__c>> applAddressMap = new Map<Id, Map<String, ApplAddr__c>>();
        for (String appId : appMap.keySet()) {
            Applicant__c app = appMap.get(appId);
            Map<String, ApplAddr__c> addrMap = applAddressMap.get(appId);
            if (addrMap == null) {
                addrMap = new Map<String, ApplAddr__c>();
            }
            if (app.Applicant_Addresses__r != null) {
                for (ApplAddr__c addr : app.Applicant_Addresses__r) {
                    addrMap.put(addr.AddrTyp__c, addr);
                }
            }
            applAddressMap.put(appId, addrMap);
        }

        for (DocDtl__c doc : [
            SELECT Id, OpsVer__c, Appl__c, DocTyp__c, DocSubTyp__c
            FROM DocDtl__c
            WHERE
                (DocCatgry__c = 'KYC Documents'
                OR DocCatgry__c = 'PAN Documents')
                AND LAN__c = :loanAppId
                AND Appl__r.ApplType__c IN ('G', 'P', 'C')
        ]) {
            Applicant__c app = appMap.get(doc.Appl__c);
            String dataEntry = '';
            if (doc.DocTyp__c == 'PAN') {
                dataEntry = concatDataEntry(dataEntry, app.FullName__c);
                dataEntry = concatDataEntry(dataEntry, app.PAN__c);
                if (app.Constitution__c == 'INDIVIDUAL') {
                    dataEntry = concatDataEntry(
                        dataEntry,
                        String.valueOf(app.DOB__c)
                    );
                } else {
                    dataEntry = concatDataEntry(
                        dataEntry,
                        String.valueOf(app.DOI__c)
                    );
                }
            } else if (doc.DocTyp__c == 'Aadhaar Consent') {
                dataEntry = concatDataEntry(dataEntry, app.FullName__c);
                dataEntry = concatDataEntry(dataEntry, app.AadhaarNo__c);
            } else if (
                doc.DocTyp__c == 'Identity Proof' ||
                doc.DocTyp__c == 'DOB Proof'
            ) {
                dataEntry = concatDataEntry(dataEntry, app.FullName__c);
                dataEntry = concatDataEntry(
                    dataEntry,
                    String.valueOf(app.DOB__c)
                );
                if (doc.DocSubTyp__c == 'Aadhaar') {
                    dataEntry = concatDataEntry(dataEntry, app.AadhaarNo__c);
                } else if (doc.DocSubTyp__c == 'Driving License') {
                    dataEntry = concatDataEntry(dataEntry, app.DLNo__c);
                } else if (doc.DocSubTyp__c == 'Passport') {
                    dataEntry = concatDataEntry(dataEntry, app.PassNo__c);
                } else if (doc.DocSubTyp__c == 'Voter Id') {
                    dataEntry = concatDataEntry(dataEntry, app.VotIdEpicNo__c);
                } else if (doc.DocSubTyp__c == 'PAN') {
                    dataEntry = concatDataEntry(dataEntry, app.PAN__c);
                }
            } else if (
                doc.DocTyp__c == 'Residence Address proof - OVD' ||
                doc.DocTyp__c == 'Residence Address proof - Deemed OVD'
            ) {
                Map<String, ApplAddr__c> addrMap = applAddressMap.get(
                    doc.Appl__c
                );
                if (addrMap != null) {
                    ApplAddr__c addr = addrMap.containsKey('Residence Address')
                        ? addrMap.get('Residence Address')
                        : addrMap.get('Residence Cum office');
                    if (addr != null) {
                        dataEntry = concatDataEntry(dataEntry, app.FullName__c);
                        if (doc.DocTyp__c == 'Residence Address proof - OVD') {
                            if (doc.DocSubTyp__c == 'Aadhaar') {
                                dataEntry = concatDataEntry(
                                    dataEntry,
                                    app.AadhaarNo__c
                                );
                            } else if (doc.DocSubTyp__c == 'Driving License') {
                                dataEntry = concatDataEntry(
                                    dataEntry,
                                    app.DLNo__c
                                );
                            } else if (doc.DocSubTyp__c == 'Passport') {
                                dataEntry = concatDataEntry(
                                    dataEntry,
                                    app.PassNo__c
                                );
                            } else if (doc.DocSubTyp__c == 'Voter Id') {
                                dataEntry = concatDataEntry(
                                    dataEntry,
                                    app.VotIdEpicNo__c
                                );
                            } else if (doc.DocSubTyp__c == 'PAN') {
                                dataEntry = concatDataEntry(
                                    dataEntry,
                                    app.PAN__c
                                );
                            }
                        }
                        dataEntry = concatDataEntry(
                            dataEntry,
                            addr.FullAdrs__c
                        );
                    }
                }
            } else if (
                doc.DocTyp__c == 'Signature Verification Proof' ||
                doc.DocTyp__c == 'Sign Proof'
            ) {
                dataEntry = concatDataEntry(dataEntry, app.FullName__c);
                if (doc.DocSubTyp__c == 'Aadhaar') {
                    dataEntry = concatDataEntry(dataEntry, app.AadhaarNo__c);
                } else if (doc.DocSubTyp__c == 'Driving License') {
                    dataEntry = concatDataEntry(dataEntry, app.DLNo__c);
                } else if (doc.DocSubTyp__c == 'Passport') {
                    dataEntry = concatDataEntry(dataEntry, app.PassNo__c);
                } else if (doc.DocSubTyp__c == 'Voter Id') {
                    dataEntry = concatDataEntry(dataEntry, app.VotIdEpicNo__c);
                } else if (doc.DocSubTyp__c == 'PAN') {
                    dataEntry = concatDataEntry(dataEntry, app.PAN__c);
                    dataEntry = concatDataEntry(
                        dataEntry,
                        String.valueOf(app.DOB__c)
                    );
                }
            } else if (doc.DocTyp__c == 'Registered office - Address Proof') {
                dataEntry = concatDataEntry(dataEntry, app.FullName__c);
                Map<String, ApplAddr__c> addrMap = applAddressMap.get(
                    doc.Appl__c
                );
                if (addrMap != null) {
                    ApplAddr__c addr = addrMap.containsKey('Office Address')
                        ? addrMap.get('Office Address')
                        : addrMap.containsKey('Residence Cum office')
                              ? addrMap.get('Residence Cum office')
                              : addrMap.get('Registered place for business');
                    if (addr != null) {
                        dataEntry = concatDataEntry(
                            dataEntry,
                            addr.FullAdrs__c
                        );
                    }
                }
            } else if (
                doc.DocTyp__c == 'Principal Place of Business - Address Proof'
            ) {
                dataEntry = concatDataEntry(dataEntry, app.FullName__c);
                if (
                    doc.DocSubTyp__c == 'GST certificate' &&
                    app.Applicant_GST__r.size() > 0
                ) {
                    dataEntry = concatDataEntry(
                        dataEntry,
                        app.Applicant_GST__r[0].GSTIN__c
                    );
                }
                if (
                    doc.DocSubTyp__c == 'Udyam Registration Certificate' &&
                    app.Applicant_Employments__r.size() > 0
                ) {
                    dataEntry = concatDataEntry(
                        dataEntry,
                        app.Applicant_Employments__r[0]
                            .UdyamRegistrationNumber__c
                    );
                }
                if (
                    doc.DocSubTyp__c == 'Udyam Assist Certificate' &&
                    app.Applicant_Employments__r.size() > 0
                ) {
                    dataEntry = concatDataEntry(
                        dataEntry,
                        app.Applicant_Employments__r[0]
                            .UdyamAssistCertificate__c
                    );
                }
                Map<String, ApplAddr__c> addrMap = applAddressMap.get(
                    doc.Appl__c
                );
                if (addrMap != null) {
                    ApplAddr__c addr = addrMap.get(
                        'Principal place for business'
                    );
                    if (addr != null) {
                        dataEntry = concatDataEntry(
                            dataEntry,
                            addr.FullAdrs__c
                        );
                    }
                }
            } else if (
                doc.DocTyp__c == 'Constitution wise Mandatory KYC documents'
            ) {
                dataEntry = concatDataEntry(dataEntry, app.FullName__c);
                if (
                    doc.DocSubTyp__c == 'Udyam Assist Certificate' &&
                    app.Applicant_Employments__r.size() > 0
                ) {
                    dataEntry = concatDataEntry(
                        dataEntry,
                        app.Applicant_Employments__r[0]
                            .UdyamAssistCertificate__c
                    );
                }
                if (
                    doc.DocSubTyp__c == 'Udyam Registration Certificate' &&
                    app.Applicant_Employments__r.size() > 0
                ) {
                    dataEntry = concatDataEntry(
                        dataEntry,
                        app.Applicant_Employments__r[0]
                            .UdyamRegistrationNumber__c
                    );
                }
                if (doc.DocSubTyp__c == 'LLP Registration certificate') {
                    dataEntry = concatDataEntry(dataEntry, app.LLPIN__c);
                }
                if (doc.DocSubTyp__c == 'Partnership deed') {
                    dataEntry = concatDataEntry(
                        dataEntry,
                        app.Partnership_registration_no__c
                    );
                }
                if (
                    doc.DocSubTyp__c ==
                    'Trust / Society Registration Certificate'
                ) {
                    dataEntry = concatDataEntry(
                        dataEntry,
                        String.valueOf(app.DOI__c)
                    );
                }
                if (
                    doc.DocSubTyp__c == 'Certificate of incorporation' ||
                    doc.DocSubTyp__c == 'MOA' ||
                    doc.DocSubTyp__c == 'AOA'
                ) {
                    dataEntry = concatDataEntry(dataEntry, app.CIN__c);
                    dataEntry = concatDataEntry(
                        dataEntry,
                        String.valueOf(app.DOI__c)
                    );
                }
            }
            if (String.isNotBlank(dataEntry)) {
                dataEntry = dataEntry.removeEnd(';    ');
            }
            dataEntryMapByDoc.put(doc.Id, dataEntry);
            System.debug('dataEntryMapByDoc===' + dataEntryMapByDoc);
        }
        return dataEntryMapByDoc;
    }

    public static void generateNdcRecForScrns(String loanId) {
        //removed 'Pricing Approval' for LAK-9500
        Set<String> screenNames = new Set<String>{
            'Tranche Details',
            'Loan Details',
            'Repayment',
            'Insurance',
            'RCU',
            'ROI PF Correction'
        };
        Set<String> exstScrNames = new Set<String>();
        List<NDC__c> ndcRecords = [
            SELECT Id, ScreenNames__c
            FROM NDC__c
            WHERE ScreenNames__c != NULL AND LoanAppl__c = :loanId
        ];

        if (ndcRecords != null && ndcRecords.size() > 0) {
            for (NDC__c ndc : ndcRecords) {
                exstScrNames.add(ndc.ScreenNames__c);
            }
        }
        List<NDC__c> insertNdcList = new List<NDC__c>();
        for (String scrName : screenNames) {
            if (!exstScrNames.contains(scrName)) {
                NDC__c ndc = new NDC__c();
                ndc.ScreenNames__c = scrName;
                ndc.LoanAppl__c = loanId;
                ndc.OpsQuery__c = false;
                //ndc.NDC_Type__c = ndcType != null && ndcType != '' ? ndcType : '';
                insertNdcList.add(ndc);
            }
        }
        if (insertNdcList != null && insertNdcList.size() > 0) {
            insert insertNdcList;
        }
    }

    private static String concatDataEntry(String original, String toConcat) {
        String seprator = ';    ';
        if (String.isNotBlank(toConcat)) {
            original = original + toConcat + seprator;
        }
        return original;
    }

    public class MappingWrp {
        public string targetField { get; set; }
        public string sourceField { get; set; }
    }

    public class NdcDataWraprForSave {
        @AuraEnabled
        public String ndcId { get; set; }
        @AuraEnabled
        public SObject record { get; set; }
    }

    public class NdcDataWrapr {
        @AuraEnabled
        public String ndcSection { get; set; }
        @AuraEnabled
        public Integer sectionOrder { get; set; }
        @AuraEnabled
        public List<TableConfig> tablConfig { get; set; }
    }

    /* public class TableData { 
@AuraEnabled
public List<TableConfig> tableData { get; set; } 
}*/

    public class TableConfig {
        @AuraEnabled
        public List<NDCRecord> ndcRecords { get; set; }
        @AuraEnabled
        public List<NdcColumnConfig.ColumnConfig> columnConfig { get; set; }
        @AuraEnabled
        public Boolean allowUpload { get; set; }
        @AuraEnabled
        public Boolean allowDelete { get; set; }
        @AuraEnabled
        public String applicantAssetId { get; set; }
        @AuraEnabled
        public String docCategory { get; set; }
        @AuraEnabled
        public Boolean addDeviation { get; set; }
        @AuraEnabled
        public String deviationCategory { get; set; }
        @AuraEnabled
        public String sobjectType { get; set; }
        @AuraEnabled
        public String title { get; set; }
    }

    public class NDCRecord {
        @AuraEnabled
        public Sobject record { get; set; }
        @AuraEnabled
        public String ndcId { get; set; }
        @AuraEnabled
        public Boolean opsQuery { get; set; }
        @AuraEnabled
        public Boolean showOpsQuery { get; set; }
    }

    public class NdcQueryConfiWrp {
        public string query { get; set; }
        public String sobjectType { get; set; }
        public MappingWrp[] mappings { get; set; }
    }
}