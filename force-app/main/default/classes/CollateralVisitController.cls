public without sharing class CollateralVisitController {
    @AuraEnabled
    public static void initiateCollateralVisit(CVReequestWrapper req) {
        try {
            Id recordTypeId = [
                SELECT Id
                FROM RecordType
                WHERE sobjectType = 'Case' AND name = 'Collateral Visit'
            ]
            .Id; //fetching Staged Lead Record Type
            Case newCase = new Case();
            newCase.Loan_Application__c = req.loanAppId;
            newCase.ApplAssetId__c = req.applicantId;
            newCase.Assigned_To__c = req.assigndTo;
            newCase.SchDate__c = req.schdDate;
            newCase.RecordTypeId = recordTypeId;
            newCase.CVStatus__c = 'Initiated';
            system.debug('newCase' + newCase);
            insert newCase;

            Map<String, Sobject> dataMap = new Map<String, Sobject>();
            LoanAppl__c loanApp = [
                SELECT
                    Id,
                    Product__c,
                    ReqLoanAmt__c,
                    Applicant__c,
                    ProductSubType__c,
                    SchemeId__c
                FROM LoanAppl__c
                WHERE Id = :req.loanAppId
            ];

            dataMap.put('LoanAppl__c', loanApp);
            if (loanApp.SchemeId__c != null) {
                SchMapping__c schm = [
                    SELECT
                        Id,
                        IsFixed__c,
                        SchemeDesc__c,
                        IsInternalTopUp__c,
                        IsBT__c,
                        ProductType__c,
                        ProductSubType__c,
                        IsConstruction__c
                    FROM SchMapping__c
                    WHERE Id = :loanApp.SchemeId__c
                ];
                dataMap.put('SchMapping__c', schm);
            }
            ApplAsset__c applicantAsset = [
                SELECT
                    Id,
                    Property_Usage__c,
                    PropType__c,
                    PropAddrs__c,
                    Prop_Owners__c,
                    Is_the_property_Multi_Tenanted__c,
                    No_of_Tenants__c,
                    AveNetMnthlyRentalAsPerBankCredit__c,
                    Is_it_an_APF__c
                FROM ApplAsset__c
                WHERE Id = :req.applicantId
            ];
            dataMap.put('ApplAsset__c', applicantAsset);
            List<PropQues__c> propQuesList = [
                SELECT
                    DispSeq__c,
                    ValidCnfig__c,
                    DefValCri__c,
                    FiltrCri__c,
                    FileConfig__c,
                    Id,
                    IsReqMob__c,
                    IsReqWeb__c,
                    IsActive__c,
                    Name,
                    PossResp__c,
                    ProdTyp__c,
                    Question_Tiltle__c,
                    RespTyp__c,
                    SecSeq__c,
                    SecTtl__c,
                    VldFrm__c,
                    VldTill__c
                FROM PropQues__c
                WHERE
                    IsActive__c = TRUE
                    AND RecordType.Name = 'Collateral Visit Questions'
                    AND ProdTyp__c INCLUDES (:loanApp.Product__c)
            ];

            Map<String, DocMstr__c> docMstrByDocName = new Map<String, DocMstr__c>();
            for (DocMstr__c dm : [
                SELECT Id, Prod__c, Catgry__c, DocTyp__c, DocSubTyp__c
                FROM DocMstr__c
                WHERE
                    Prod__c = :loanApp.Product__c
                    AND Catgry__c = 'Collateral Visit'
                    AND DocTyp__c = 'Collateral Visit Photographs'
                    AND Active__c = TRUE
            ]) {
                docMstrByDocName.put(dm.DocSubTyp__c, dm);
            }

            Operations opObj = Operations.getInstance();
            opObj.registerOperation(OperationFactory.getInstance('&&'));
            opObj.registerOperation(OperationFactory.getInstance('=='));
            opObj.registerOperation(OperationFactory.getInstance('!='));
            opObj.registerOperation(OperationFactory.getInstance('||'));
            opObj.registerOperation(OperationFactory.getInstance('('));
            opObj.registerOperation(OperationFactory.getInstance(')'));
            opObj.registerOperation(OperationFactory.getInstance('<'));
            opObj.registerOperation(OperationFactory.getInstance('<='));
            opObj.registerOperation(OperationFactory.getInstance('>'));
            opObj.registerOperation(OperationFactory.getInstance('>='));
            Map<String, DocDtl__c> docDtlList = new Map<String, DocDtl__c>();
            for (PropQues__c propQ : propQuesList) {
                if (
                    propQ.RespTyp__c != null &&
                    propQ.FileConfig__c != null &&
                    propQ.RespTyp__c == 'File'
                ) {
                    Boolean createDD = true;
                    if (propQ.FileConfig__c != null) {
                        Map<String, Object> fileConfig = (Map<String, Object>) JSON.deserializeUntyped(
                            propQ.FileConfig__c
                        );
                        if (
                            fileConfig.get('AllowUpload') != null &&
                            (Boolean) fileConfig.get('AllowUpload') == false
                        ) {
                            createDD = false;
                        }
                    }
                    if (createDD) {
                        DocDtl__c dd = new DocDtl__c();
                        dd.Appl__c = loanApp.Applicant__c;
                        dd.DocMstr__c = docMstrByDocName.get(
                                propQ.FileConfig__c
                            ) != null
                            ? docMstrByDocName.get(propQ.FileConfig__c).Id
                            : null;
                        dd.DocCatgry__c = 'Collateral Visit';
                        dd.DocSubTyp__c = propQ.Question_Tiltle__c;
                        dd.DocTyp__c = 'Collateral Visit Photographs';
                        dd.LAN__c = req.loanAppId;
                        dd.Case__c = newCase.Id;
                        docDtlList.put(propQ.FileConfig__c, dd);
                    }
                }
            }
            system.debug('docList ' + docDtlList.Values());
            if (docDtlList.size() > 0) {
                insert docDtlList.Values();
            }

            List<CollateralVisitJn__c> cvResponseList = new List<CollateralVisitJn__c>();
            for (PropQues__c cvQues : propQuesList) {
                FilterCriteria filtrCri = cvQues.FiltrCri__c != null
                    ? (FilterCriteria) JSON.deserialize(
                          cvQues.FiltrCri__c,
                          FilterCriteria.class
                      )
                    : null;
                Boolean isApplicable = true;
                if (filtrCri != null) {
                    Rule r = new Rule().setExpression(filtrCri.criteria);
                    SObject record = dataMap.get(filtrCri.objectName);
                    Map<string, string> bindings = new Map<string, string>();
                    if (record != null) {
                        for (string fl : filtrCri.fields) {
                            List<String> splitVal = fl.trim().split('\\.');
                            System.debug('splitVal==' + splitVal);
                            System.debug('size==' + splitVal.size());
                            String value = '';
                            if (splitVal.size() == 1) {
                                value = record.get(splitVal[0]) != null
                                    ? String.valueOf(record.get(splitVal[0]))
                                    : 'blank';
                            } else if (splitVal.size() == 2) {
                                value = record.getSobject(splitVal[0])
                                        .get(splitVal[1]) != null
                                    ? String.valueOf(
                                          record.getSobject(splitVal[0])
                                              .get(splitVal[1])
                                      )
                                    : 'blank';
                            }
                            value = value.replaceAll('\\s+', '');
                            value = value.replaceAll('\\(', '');
                            value = value.replaceAll('\\)', '');
                            value = value.replaceAll('\\-', '');
                            value = value.replaceAll('\\%', '');
                            bindings.put(fl.trim().toLowerCase(), value);
                        }
                        isApplicable = r.eval(bindings);
                    } else {
                        isApplicable = false;
                    }
                }
                if (isApplicable) {
                    CollateralVisitJn__c cvResp = new CollateralVisitJn__c();
                    cvResp.Case__c = newCase.Id;
                    cvResp.PropQues__c = cvQues.Id;
                    cvResp.Question__c = cvQues.Question_Tiltle__c;
                    cvResp.DocDtl__c = docDtlList.get(cvQues.FileConfig__c) !=
                        null
                        ? docDtlList.get(cvQues.FileConfig__c).Id
                        : null;
                    if (cvQues.DefValCri__c != null) {
                        DefaultDataCri defDataCtri = (DefaultDataCri) JSON.deserialize(
                            cvQues.DefValCri__c,
                            DefaultDataCri.class
                        );
                        Sobject defaulObj = dataMap.get(defDataCtri.objectName);
                        if (defaulObj != null) {
                            if (defDataCtri.childRelationObj != null) {
                                cvResp.Resp__c = String.valueOf(
                                    defaulObj.getSobject(
                                            defDataCtri.childRelationObj
                                        )
                                        .get(defDataCtri.field)
                                );
                            } else {
                                cvResp.Resp__c = String.valueOf(
                                    defaulObj.get(defDataCtri.field)
                                );
                            }
                        }
                    }
                    cvResponseList.add(cvResp);
                }
                // if (
                //     cvQues.RespTyp__c != null &&
                //     cvQues.RespTyp__c == 'DateTime'
                // ) {
                //     cvResp.Resp__c = String.valueOf(System.now());
                // }
                // if(pdQues.DefValCri__c != null) {
                //     DefaultDataCri defDataCtri = (DefaultDataCri) JSON.deserialize(pdQues.DefValCri__c,DefaultDataCri.class);
                //     if(dataMap.get(defDataCtri.objectName) !=null){
                //         cvResp.Resp__c =   String.valueOf(dataMap.get(defDataCtri.objectName).get(defDataCtri.field) ) ;
                //     }

                // }
                //cvResp.Resp__c = defaltValue to calculate
                // if(pdQues.RespTyp__c != null && pdQues.FileConfig__c != null && pdQues.RespTyp__c == 'File' ) {
                //     cvResp.DocDtl__c = docDtlList.get(pdQues.FileConfig__c).Id;
                // }
            }
            insert cvResponseList;
        } catch (exception e) {
            system.debug(
                'error occured ' +
                    e.getMessage() +
                    'get line number ' +
                    e.getLineNumber() +
                    ' get stack trace ' +
                    e.getStackTraceString()
            );
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<CVResponseWrapper> retrieveCV(Id cvId) {
        try {
            system.debug('cvId  ' + cvId);
            //Case cv = [SELECT Id from Case WHERE Id =:cvId];
            Map<Id, List<QuestionCriteria>> quesCriMap = new Map<Id, List<QuestionCriteria>>();
            for (PropQuesCrit__c cri : [
                SELECT Id, ApcblQues__c, EvalCrit__c, EvalQues__c
                FROM PropQuesCrit__c
                WHERE IsActive__c = TRUE
            ]) {
                List<QuestionCriteria> critList = quesCriMap.get(
                    cri.ApcblQues__c
                );
                if (critList == null) {
                    critList = new List<QuestionCriteria>();
                }
                QuestionCriteria newCri = new QuestionCriteria();
                newCri.applicableQues = cri.ApcblQues__c;
                newCri.evalQues = cri.EvalQues__c;
                newCri.criVal = (List<String>) JSON.deserialize(
                    cri.EvalCrit__c,
                    List<String>.class
                );
                critList.add(newCri);
                quesCriMap.put(cri.ApcblQues__c, critList);
            }
            List<CollateralVisitJn__c> cvRespList = [
                SELECT
                    Id,
                    Case__c,
                    Resp__c,
                    DocDtl__c,
                    PropQues__r.DispSeq__c,
                    PropQues__r.FiltrCri__c,
                    PropQues__r.Id,
                    PropQues__r.IsReqMob__c,
                    PropQues__r.IsReqWeb__c,
                    PropQues__r.IsActive__c,
                    PropQues__r.PossResp__c,
                    PropQues__r.Question_Tiltle__c,
                    PropQues__r.RespTyp__c,
                    PropQues__r.IsEditable__c,
                    PropQues__r.SecSeq__c,
                    PropQues__r.SecTtl__c,
                    PropQues__r.QuesConf__c,
                    PropQues__r.DefValCri__c,
                    PropQues__r.ValidCnfig__c,
                    PropQues__r.VisibleMob__c,
                    PropQues__r.VisibleWeb__c,
                    PropQues__r.OverrideConfig__c,
                    PropQues__r.FileConfig__c,
                    PropQues__r.MobValCnfg__c
                FROM CollateralVisitJn__c
                WHERE Case__c = :cvId AND PropQues__r.IsActive__c = TRUE
                ORDER BY PropQues__r.SecSeq__c, PropQues__r.DispSeq__c
            ];
            system.debug('cvRespList  ' + cvRespList.size() + cvRespList);

            Case caseRec = [
                SELECT
                    Id,
                    Loan_Application__c,
                    Loan_Application__r.Status__c,
                    ApplAssetId__c,
                    Assigned_To__r.Name,
                    SchDate__c,
                    IsCompleted__c
                FROM Case
                WHERE Id = :cvId AND RecordType.Name = 'Collateral Visit'
            ];
            Boolean cvNonEditabel =
                caseRec.IsCompleted__c ||
                caseRec.Loan_Application__r.Status__c == 'Hold' ||
                caseRec.Loan_Application__r.Status__c == 'Cancelled' ||
                caseRec.Loan_Application__r.Status__c == 'Rejected';
            Map<String, Sobject> dataMap = new Map<String, Sobject>();
            dataMap.put('Case', caseRec);
            LoanAppl__c loanApp = [
                SELECT Id, Product__c, ReqLoanAmt__c
                FROM LoanAppl__c
                WHERE Id = :caseRec.Loan_Application__c
            ];
            dataMap.put('LoanAppl__c', loanApp);
            ApplAsset__c applicantAsset = [
                SELECT
                    Id,
                    Property_Usage__c,
                    PropType__c,
                    PropAddrs__c,
                    Prop_Owners__c,
                    Is_the_property_Multi_Tenanted__c,
                    No_of_Tenants__c,
                    AveNetMnthlyRentalAsPerBankCredit__c
                FROM ApplAsset__c
                WHERE Id = :caseRec.ApplAssetId__c
            ];
            dataMap.put('ApplAsset__c', applicantAsset);

            List<Applicant__c> priApplicant = [
                SELECT
                    Id,
                    CustProfile__c,
                    Constitution__c,
                    TabName__c,
                    MobNumber__c
                FROM Applicant__c
                WHERE
                    ApplType__c = 'P'
                    AND LoanAppln__c = :caseRec.Loan_Application__c
            ];
            if (priApplicant.size() > 0) {
                dataMap.put('Applicant__c', priApplicant[0]);
            }

            Map<String, List<Sobject>> optionMap = new Map<String, List<Sobject>>();
            List<Applicant__c> applicants = [
                SELECT
                    Id,
                    CustProfile__c,
                    Constitution__c,
                    TabName__c,
                    MobNumber__c
                FROM Applicant__c
                WHERE LoanAppln__c = :caseRec.Loan_Application__c
            ];
            optionMap.put('Applicant__c', applicants);

            List<DocDtl__c> docIds = [
                SELECT Id, DocCatgry__c, DocSubTyp__c
                FROM DocDtl__c
                WHERE Case__c = :caseRec.Id
            ];

            //Map<Id, List<ContentDocumentLink>> cdlByDocdtlId = new Map<Id, List<ContentDocumentLink>>();
            Map<Id, List<ContentVersion>> cvByDocdtlId = new Map<Id, List<ContentVersion>>();
            Map<Id, Id> docIdToDocDtlIdMap = new Map<Id, Id>();

            if (docIds != null && docIds.size() > 0) {
                Map<Id, DocDtl__c> docDtlMap = new Map<Id, DocDtl__c>(docIds);
                List<ContentDocumentLink> dduploaded = [
                    SELECT
                        Id,
                        LinkedEntityId,
                        ContentDocumentId,
                        ContentDocument.CreatedDate,
                        ContentDocument.Title,
                        ContentDocument.ContentSize,
                        ContentDocument.FileType,
                        ContentDocument.FileExtension
                    FROM ContentDocumentLink
                    WHERE LinkedEntityId IN :docDtlMap.keySet()
                ];

                for (ContentDocumentLink cdl : dduploaded) {
                    docIdToDocDtlIdMap.put(
                        cdl.ContentDocumentId,
                        cdl.LinkedEntityId
                    );
                }
            }

            for (ContentVersion cv : [
                SELECT
                    Id,
                    ContentDocument.Title,
                    ContentDocument.FileExtension,
                    ContentDocument.ContentSize,
                    ContentDocumentId,
                    CreatedDate
                FROM ContentVersion
                WHERE ContentDocumentId IN :docIdToDocDtlIdMap.keySet()
                ORDER BY CreatedDate  desc
            ]) {
                Id docDtlId = docIdToDocDtlIdMap.get(cv.ContentDocumentId);
                List<ContentVersion> cvList = cvByDocdtlId.get(docDtlId);
                if (cvList == null) {
                    cvList = new List<ContentVersion>();
                }
                cvList.add(cv);
                cvByDocdtlId.put(docDtlId, cvList);
            }

            List<CVQuesResponse> respList = new List<CVQuesResponse>();
            Map<String, CVResponseWrapper> cvResponseMap = new Map<String, CVResponseWrapper>();
            for (CollateralVisitJn__c resp : cvRespList) {
                CVResponseWrapper respWpr = cvResponseMap.get(
                    resp.PropQues__r.SecTtl__c
                );
                if (respWpr == null) {
                    respWpr = new CVResponseWrapper();
                    respWpr.recordId = resp.Case__c;
                    respWpr.sectionTitle = resp.PropQues__r.SecTtl__c;
                    respWpr.sectionSeq = resp.PropQues__r.SecSeq__c != null
                        ? resp.PropQues__r.SecSeq__c.intValue()
                        : 0;
                    // respWpr.pdComplDate = resp.PrsnlDisc__r.CmpltDt__c.date();
                    // system.debug( 'date error '+resp.PrsnlDisc__r.CmpltDt__c   + +resp.PrsnlDisc__r.CmpltDt__c.date() );
                    // respWpr.pdComplDate = resp.PrsnlDisc__r.CmpltDt__c.date();
                    respWpr.questions = new List<CVQuesResponse>();
                }
                CVQuesResponse cvResp = new CVQuesResponse();
                cvResp.respId = resp.Id;
                cvResp.quesId = resp.PropQues__r.Id;
                cvResp.quesTitle = resp.PropQues__r.Question_Tiltle__c;
                cvResp.quesResp = resp.Resp__c;
                cvResp.mobileValidationConfig = resp.PropQues__r.MobValCnfg__c;
                cvResp.validationConfig = resp.PropQues__r.ValidCnfig__c;
                if (resp.PropQues__r.DefValCri__c != null) {
                    DefaultDataCri defDataCtri = (DefaultDataCri) JSON.deserialize(
                        resp.PropQues__r.DefValCri__c,
                        DefaultDataCri.class
                    );
                    Sobject defaulObj = dataMap.get(defDataCtri.objectName);
                    if (defaulObj != null) {
                        if (defDataCtri.childRelationObj != null) {
                            cvResp.quesResp = String.valueOf(
                                defaulObj.getSobject(
                                        defDataCtri.childRelationObj
                                    )
                                    .get(defDataCtri.field)
                            );
                        } else {
                            cvResp.quesResp = String.valueOf(
                                defaulObj.get(defDataCtri.field)
                            );
                        }
                    }
                    if (
                        resp.PropQues__r.RespTyp__c == 'Date' &&
                        !String.isEmpty(cvResp.quesResp)
                    ) {
                        List<String> dateList = cvResp.quesResp.split(' ');
                        if (dateList != null && dateList.size() > 0) {
                            cvResp.quesResp = dateList[0];
                        }
                    }
                }
                cvResp.criteriaList = quesCriMap.get(resp.PropQues__r.Id);
                cvResp.docDetailId = resp.DocDtl__c;
                cvResp.displaySeq = resp.PropQues__r.DispSeq__c != null
                    ? resp.PropQues__r.DispSeq__c.intValue()
                    : 0;
                cvResp.respType = resp.PropQues__r.RespTyp__c;
                // if(cvResp.respType == 'Table' || cvResp.respType == 'Reference') {
                //     cvResp.quesConfig = resp.PropQues__r.QuesConf__c;
                // }
                cvResp.quesConfig = resp.PropQues__r.QuesConf__c;
                cvResp.visibleOnMobile = resp.PropQues__r.VisibleMob__c;
                cvResp.visibleOnPortal = resp.PropQues__r.VisibleWeb__c;
                if (cvResp.respType == 'File') {
                    Map<String, Object> fileConfig = (Map<String, Object>) JSON.deserializeUntyped(
                        resp.PropQues__r.FileConfig__c
                    );
                    if (cvNonEditabel) {
                        fileConfig.put('AllowUpload', false);
                        fileConfig.put('AllowMultipleFile', false);
                        fileConfig.put('AllowDelete', false);
                    }
                    cvResp.fileConfig = JSON.serialize(fileConfig);
                    List<ContentVersion> cvList = cvByDocdtlId.get(
                        resp.DocDtl__c
                    );
                    List<FileRespWpr> fileRespList = new List<FileRespWpr>();
                    //System.debug('cdlList==' + cdlList);
                    if (cvList != null && cvList.size() > 0) {
                        for (ContentVersion cv : cvList) {
                            FileRespWpr fileResp = new FileRespWpr();
                            fileResp.fileExtension = cv.ContentDocument.FileExtension;
                            fileResp.fileName = cv.ContentDocument.Title;
                            fileResp.fileSize = cv.ContentDocument.ContentSize;
                            fileResp.createdDate = cv.CreatedDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');

                            fileResp.res = new FileRespnse();
                            fileResp.res.id = cv.Id;
                            fileRespList.add(fileResp);
                        }
                        cvResp.quesResp = JSON.serialize(fileRespList);
                    }
                }
                // if(resp.PropQues__r.PossResp__c != null) {
                //     PossibleValues valuesWpr = (PossibleValues) JSON.deserialize(resp.PropQues__r.PossResp__c, PossibleValues.class);
                //     if(valuesWpr.isFixed) {
                //     	cvResp.possibleOptions = valuesWpr.options;
                //     } else {
                //         List<Sobject> objects = applicant.getSobjects(valuesWpr.sourceObject);
                //     }
                // }
                if (resp.PropQues__r.PossResp__c != null) {
                    PossibleValues valuesWpr = (PossibleValues) JSON.deserialize(
                        resp.PropQues__r.PossResp__c,
                        PossibleValues.class
                    );
                    if (valuesWpr.isFixed) {
                        cvResp.possibleOptions = valuesWpr.options;
                    } else {
                        List<Sobject> objects = optionMap.get(
                            valuesWpr.sourceObject
                        );
                        System.debug(
                            'objects==' + optionMap.keySet() + objects
                        );
                        if (objects != null && objects.size() > 0) {
                            List<String> options = new List<String>();
                            for (Sobject obj : objects) {
                                options.add(
                                    (String) obj.get(valuesWpr.sourceField)
                                );
                            }
                            cvResp.possibleOptions = options;
                        }
                    }
                }
                if (resp.PropQues__r.OverrideConfig__c != null) {
                    OverrideConfig overrideCnfg = (OverrideConfig) JSON.deserialize(
                        resp.PropQues__r.OverrideConfig__c,
                        OverrideConfig.class
                    );
                    Sobject ordObj = dataMap.get(overrideCnfg.objectName);
                    if (ordObj != null) {
                        overrideCnfg.recordId = ordObj.Id;
                    }
                    cvResp.overrideCnfg = JSON.serialize(overrideCnfg);
                }
                cvResp.isReqPortal = resp.PropQues__r.IsReqWeb__c;
                cvResp.isReqMobile = resp.PropQues__r.IsReqMob__c;
                cvResp.isEditable = cvNonEditabel
                    ? false
                    : resp.PropQues__r.IsEditable__c;
                cvResp.responseObj = 'CollateralVisitJn__c';
                respWpr.questions.add(cvResp);
                cvResponseMap.put(resp.PropQues__r.SecTtl__c, respWpr);
            }
            return cvResponseMap.Values();
        } catch (exception e) {
            system.debug(
                'error occured ' +
                    e.getMessage() +
                    'get line number ' +
                    e.getLineNumber() +
                    ' get stack trace ' +
                    e.getStackTraceString()
            );
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static string saveCV(
        string cvId,
        List<QuestionsSaveWrapper> cvRecToSave
    ) {
        list<Sobject> upsertRecList = new List<Sobject>();
        set<Id> upsertRecIdSet = new set<Id>();
        map<string,Sobject> upsertRecIdMap = new  map<string,Sobject>();// added for Shekhar LAK-7861 05/06/24
        for (QuestionsSaveWrapper cvsave : cvRecToSave) {
            for (Sobject rec : cvsave.records) {
                if (
                    cvsave.objectType == 'ApplAsset__c' &&
                    rec.get('Addr_of_prop_veri_as_per_Tit__c') != null
                ) {
                    String val = (String) rec.get(
                        'Addr_of_prop_veri_as_per_Tit__c'
                    );
                    rec.put(
                        'Addr_of_prop_veri_as_per_Tit__c',
                        val == 'Yes' ? 'Y' : 'N'
                    );
                }
                if (
                    cvsave.objectType == 'ApplAsset__c' &&
                    rec.get('Bound_are_prop_dem_n_ide__c') != null
                ) {
                    String val = (String) rec.get(
                        'Bound_are_prop_dem_n_ide__c'
                    );
                    rec.put(
                        'Bound_are_prop_dem_n_ide__c',
                        val == 'Yes' ? 'Y' : 'N'
                    );
                }
                String recId = (String) rec.get('Id');
                if(recId != null || recId != '') {// added for Shekhar LAK-7861 05/06/24
                    
                    if(!upsertRecIdMap.containsKey(recId)) {
                        upsertRecList.add(rec);
                        upsertRecIdMap.put(recId,rec);
                    }
                } else {
                    upsertRecList.add(rec);
                }
                //upsertRecList.add(rec);// commented for Shekhar LAK-7861 05/06/24
            }
        }

        if (upsertRecList.size() > 0) {
            upsert upsertRecList;
        }
        return JSON.serialize(upsertRecList);
    }

    public class DefaultDataCri {
        public String objectName;
        public String field;
        public String childRelationObj;
    }

    public class CVReequestWrapper {
        @AuraEnabled
        public Id loanAppId { get; set; }
        @AuraEnabled
        public Id applicantId { get; set; }
        @AuraEnabled
        public Date schdDate { get; set; }
        @AuraEnabled
        public Id assigndTo { get; set; }
    }

    public class CVResponseWrapper {
        @AuraEnabled
        public Id recordId { get; set; }
        @AuraEnabled
        public String sectionTitle { get; set; }
        @AuraEnabled
        public Integer sectionSeq { get; set; }
        @AuraEnabled
        public Id completedBy { get; set; }
        @AuraEnabled
        public List<CVQuesResponse> questions { get; set; }
    }

    public class CVQuesResponse {
        @AuraEnabled
        public Id respId { get; set; }
        @AuraEnabled
        public Id quesId { get; set; }
        @AuraEnabled
        public String quesTitle { get; set; }
        @AuraEnabled
        public String quesResp { get; set; }
        @AuraEnabled
        public Id docDetailId { get; set; }
        @AuraEnabled
        public Integer displaySeq { get; set; }
        @AuraEnabled
        public String respType { get; set; }
        @AuraEnabled
        public String quesConfig { get; set; }
        @AuraEnabled
        public List<String> possibleOptions { get; set; }
        @AuraEnabled
        public Boolean isReqMobile { get; set; }
        @AuraEnabled
        public Boolean isReqPortal { get; set; }
        @AuraEnabled
        public Boolean isEditable { get; set; }
        @AuraEnabled
        public String validationConfig { get; set; }
        @AuraEnabled
        public String responseObj { get; set; }
        @AuraEnabled
        public List<QuestionCriteria> criteriaList { get; set; }
        @AuraEnabled
        public Boolean visibleOnMobile { get; set; }
        @AuraEnabled
        public Boolean visibleOnPortal { get; set; }
        @AuraEnabled
        public String overrideCnfg { get; set; }
        @AuraEnabled
        public String fileConfig { get; set; }
        @AuraEnabled
        public String mobileValidationConfig { get; set; }
    }

    public class PossibleValues {
        public Boolean isFixed { get; set; }
        public String sourceObject { get; set; }
        public String sourceField { get; set; }
        public List<String> options { get; set; }
    }

    public class FilterCriteria {
        public String objectName;
        public List<String> fields;
        public String criteria;
    }

    public class QuestionCriteria {
        @AuraEnabled
        public Id applicableQues { get; set; }
        @AuraEnabled
        public Id evalQues { get; set; }
        @AuraEnabled
        public List<String> criVal { get; set; }
    }

    public class OverrideConfig {
        public String objectName;
        public String field;
        public String recordId;
    }

    public class FileRespWpr {
        public String fileExtension;
        public String fileName;
        public Integer fileSize;
        public String fileUri;
        public FileRespnse res;
        public String createdDate;
    }

    public class FileRespnse {
        String id;
        Boolean success;
    }
}