public with sharing class DocumentEngine {
    public List<LoanAppl__c> loanAppRecords = new List<LoanAppl__c>();
    Public List<RuleExp__mdt> ruleExpr = new List<RuleExp__mdt>();
    public Map<Id, Applicant__c> appRecordsMap = new Map<Id, Applicant__c>();
    public Map<Id, List<ApplicantEmployment__c>> appEmpRecordsMap = new Map<Id, List<ApplicantEmployment__c>>();
    public Map<Id, List<DocDtl__c>> docDtlMap = new Map<Id, List<DocDtl__c>>();
    public DocumentEngine() {}
    public DocumentEngine(Id loanAppId) {
       loanAppRecords = [
                SELECT
                    Id,
                    SubStage__c,
                    Stage__c,
           			Product__c,
                    AssesIncomeAppl__c,
                    AssessedIncAppln__c
                FROM LoanAppl__c
                WHERE Id = :loanAppId
            ];
         appRecordsMap = new Map<Id, Applicant__c>([
                SELECT
                    Id,
                    Constitution__c,
                    CustProfile__c,
                    ApplType__c,
                    Category__c,
                    Type_of_Borrower__c,IsBo__c,
                    LatestyearforwhichITRisavailable__c
                FROM Applicant__c
                WHERE LoanAppln__c = :loanAppId
            ]);
        
        for(ApplicantEmployment__c aapEmpl : [
                SELECT Id, Select_applicability_for_URC_UAC__c, LoanApplicant__c
                FROM ApplicantEmployment__c
                WHERE LoanApplicant__r.LoanAppln__c = :loanAppId
        ]) {
            List<ApplicantEmployment__c> applEmpList = appEmpRecordsMap.get(aapEmpl.LoanApplicant__c);
            if(applEmpList == null) {
                applEmpList = new List<ApplicantEmployment__c>();
            }
            applEmpList.add(aapEmpl);
            appEmpRecordsMap.put(aapEmpl.LoanApplicant__c, applEmpList);
        }
        
        ruleExpr = [
                SELECT
                    ProdTyp__c,
                    RuleExpTyp__c,
                    RsltJsn__c,
                    Stg__c,
                    SubStg__c,
                    IsActive__c,
                    ExpCrt__c,
                    Label
                FROM RuleExp__mdt
                WHERE IsActive__c = TRUE AND ProdTyp__c = :loanAppRecords[0].Product__c
            ];
        
        for(DocDtl__c docDtl : [
                SELECT DocCatgry__c, DocTyp__c, DocSubTyp__c, Appl__c
                FROM DocDtl__c
                WHERE Appl__r.LoanAppln__c = :loanAppId AND IsDeleted__c =false]) {
            List<DocDtl__c> docDtlList = docDtlMap.get(docDtl.Appl__c);
            if(docDtlList == null) {
                docDtlList = new List<DocDtl__c>();
            }
            docDtlList.add(docDtl);
            docDtlMap.put(docDtl.Appl__c, docDtlList);
        }
    }
    public static Map<String, Map<String, List<String>>> fetchAllRequiredDocs(
        String applicantId,
        String loanAppId,
        String productType,
        String stage,
        String subStage
    ) {
        //appid ='a0AC4000000DwqzMAC'  loanAppId ='a08C4000005yfVKIAY'
        //DocumentEngine.fetchAllRequiredDocs('a0AC4000000DwqzMAC', 'a08C4000005yfVKIAY','Home Loan','QDE','RM Data Entry');

        system.debug(
            'applicantId ' +
                applicantId +
                ' loanAppId ' +
                loanAppId +
                'productType ' +
                productType +
                ' stage ' +
                stage +
                ' subStage ' +
                subStage
        );
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

        Map<String, Set<String>> typeWithSubType = new Map<String, Set<String>>();
        Map<String, Map<String, Set<String>>> cateWithTypeAndSubType = new Map<String, Map<String, Set<String>>>();

        try {
            //  List<RuleExpQryCnfg__mdt> ruleExperssConfig = [SELECT ProdTyp__c,
            //                                               RuleExpTyp__c,QryJsn__c,IsActive__c FROM RuleExpQryCnfg__mdt
            //                                               WHERE IsActive__c = true AND ProdTyp__c =:productType];

            List<RuleExp__mdt> ruleExpr = [
                SELECT
                    ProdTyp__c,
                    RuleExpTyp__c,
                    RsltJsn__c,
                    Stg__c,
                    SubStg__c,
                    IsActive__c,
                    ExpCrt__c
                FROM RuleExp__mdt
                WHERE IsActive__c = TRUE AND ProdTyp__c = :productType
            ]; // AND Stg__c =: stage AND SubStg__c =: subStage];

            system.debug('ruleExpr metadata size ' + ruleExpr.size());
            List<LoanAppl__c> loanAppRecords = [
                    SELECT
                        Id,
                        SubStage__c,
                        Stage__c,
                        AssesIncomeAppl__c,
                        AssessedIncAppln__c
                    FROM LoanAppl__c
                    WHERE Id = :loanAppId
                ];
            Applicant__c appRecords = [
                    SELECT
                        Id,
                        Constitution__c,
                        CustProfile__c,
                        ApplType__c,
                        Category__c,
                        Type_of_Borrower__c,IsBo__c,
                        LatestyearforwhichITRisavailable__c
                    FROM Applicant__c
                    WHERE Id = :applicantId
                    LIMIT 1
                ];

            List<ApplicantEmployment__c> appEmpRecords = [
                    SELECT Id, Select_applicability_for_URC_UAC__c
                    FROM ApplicantEmployment__c
                    WHERE LoanApplicant__c = :applicantId
                ];

            if (!ruleExpr.isEmpty()) {
                for (RuleExp__mdt ruelEx : ruleExpr) {
                    system.debug('rule expr- 222' + ruelEx.ExpCrt__c);
                    CriteriaConfigClass expressionCtria = (CriteriaConfigClass) JSON.deserialize(
                        ruelEx.ExpCrt__c,
                        CriteriaConfigClass.class
                    );

                    if (expressionCtria != null) {
                        system.debug(
                            'criteria ' +
                            expressionCtria.criteriaConfig.criteria
                        );

                        List<CriteriaConfigClass.Criteria> criteriaList = expressionCtria.criteriaConfig.criteria;

                        system.debug('criteriaList' + criteriaList);
                        Map<String, String> bindings = new Map<String, String>();
                        for (CriteriaConfigClass.Criteria cri : criteriaList) {
                            system.debug('criteria cri' + cri);
                            if (cri.objectAPIName == 'Applicant__c') {
                                String value = appRecords
                                        .get(cri.fieldName.trim()) != null
                                    ? (String) appRecords
                                          .get(cri.fieldName.trim())
                                    : 'blank';
                                value = removeSpecialCharactor(value);
                                bindings.put(
                                    cri.fieldName.trim().toLowerCase(),
                                    value
                                );
                            } else if (cri.objectAPIName == 'LoanAppl__c') {
                                String value = loanAppRecords[0]
                                        .get(cri.fieldName.trim()) != null
                                    ? (String) loanAppRecords[0]
                                          .get(cri.fieldName.trim())
                                    : 'blank';
                                system.debug('inside loan app');
                                value = removeSpecialCharactor(value);
                                bindings.put(
                                    cri.fieldName.trim().toLowerCase(),
                                    value
                                );
                            } else if (
                                cri.objectAPIName == 'ApplicantEmployment__c'
                            ) {
                                String value = 'blank';
                                if (appEmpRecords.size() > 0) {
                                    value = appEmpRecords[0]
                                            .get(cri.fieldName.trim()) != null
                                        ? (String) appEmpRecords[0]
                                              .get(cri.fieldName.trim())
                                        : 'blank';
                                }
                                system.debug('inside appEmp app');
                                value = removeSpecialCharactor(value);
                                bindings.put(
                                    cri.fieldName.trim().toLowerCase(),
                                    value
                                );
                            }
                        }

                        String expNode = expressionCtria.criteriaConfig.expression;

                        system.debug('expression ' + expNode);

                        Rule r = new Rule().setExpression(expNode);
                        system.debug('rrr' + r);
                        system.debug('bindings' + bindings);

                        Boolean retVal = r.eval(bindings);

                        system.debug('retVal from rule engine ' + retVal);

                        if (retVal) {
                            ResultJson resultJsonList = (ResultJson) JSON.deserialize(
                                ruelEx.RsltJsn__c,
                                ResultJson.class
                            );

                            system.debug('resultJsonList ' + resultJsonList);

                            if (
                                resultJsonList.anyList != null &&
                                !resultJsonList.anyList.isEmpty()
                            ) {
                                cateWithTypeAndSubType = getDocumentsMap(
                                    resultJsonList.anyList,
                                    cateWithTypeAndSubType
                                );
                            }
                            if (
                                resultJsonList.andList != null &&
                                !resultJsonList.andList.isEmpty()
                            ) {
                                cateWithTypeAndSubType = getDocumentsMap(
                                    resultJsonList.andList,
                                    cateWithTypeAndSubType
                                );
                            }

                            if (
                                resultJsonList.orList != null &&
                                !resultJsonList.orList.isEmpty()
                            ) {
                                cateWithTypeAndSubType = getDocumentsMap(
                                    resultJsonList.orList,
                                    cateWithTypeAndSubType
                                );
                            }
                        }
                    }
                }
            }
        } catch (exception e) {
            system.debug(
                'error occured ' +
                    e.getMessage() +
                    'get line number ' +
                    e.getLineNumber()
            );
            throw new AuraHandledException(e.getMessage());
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
                    /*  Boolean ret = cateWithTypeAndSubType.get(key).containsKey('Residence Address proof - Deemed OVD') || cateWithTypeAndSubType.get(key).containsKey('Residence Address proof - OVD');
		           if(ret == false){
                    docTypes.put(docTypeKey, new List<String>(cateWithTypeAndSubType.get(key).get(docTypeKey)));
                }*/
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

    public static List<String> evalAllRequiredDocs(
        String applicantId,
        String loanAppId,
        String productType,
        String stage,
        String subStage,
        List<String> categoriesList
    ) {
        //DocumentEngine.evalAllRequiredDocs('a0AC4000000EYEjMAO', 'a08C4000006Ayh2IAC','Home Loan','QDE','RM Data Entry');
        system.debug('categoriesList ' + categoriesList);

        Boolean alldocsAvailable = false;
        Set<String> missingDocs = new Set<String>();
        Map<String, String> bindings = new Map<String, String>();

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
        Map<String, Map<String, Set<String>>> docCatgryWithTypeAndSubtype = new Map<String, Map<String, Set<String>>>();
        Map<String, Set<String>> typeWithSubtype = new Map<String, Set<String>>();

        try {
             List<LoanAppl__c> loanAppRecords = [
                    SELECT
                        Id,
                        SubStage__c,
                        Stage__c,
                        AssesIncomeAppl__c,
                        AssessedIncAppln__c
                    FROM LoanAppl__c
                    WHERE Id = :loanAppId
                ];

                Applicant__c appRecords = [
                    SELECT
                        Id,
                        Constitution__c,
                        CustProfile__c,
                        ApplType__c,
                        Category__c,
                        Type_of_Borrower__c,IsBo__c,
                        LatestyearforwhichITRisavailable__c
                    FROM Applicant__c
                    WHERE Id = :applicantId
                    LIMIT 1
                ];

            //List<ApplicantEmployment__c> appEmpRecords = appEmpRecordsMap.get(applicantId);
            //if(appEmpRecords == null) {
            List<ApplicantEmployment__c> appEmpRecords = [
                SELECT Id, Select_applicability_for_URC_UAC__c
                FROM ApplicantEmployment__c
                WHERE LoanApplicant__c = :applicantId
            ];

            List<RuleExp__mdt> ruleExpr = [
                SELECT
                    ProdTyp__c,
                    RuleExpTyp__c,
                    RsltJsn__c,
                    Stg__c,
                    SubStg__c,
                    IsActive__c,
                    ExpCrt__c
                FROM RuleExp__mdt
                WHERE IsActive__c = TRUE AND ProdTyp__c = :productType
            ]; // AND Stg__c =: stage AND SubStg__c =: subStage];

            List<DocDtl__c> docDetailList = [
                SELECT DocCatgry__c, DocTyp__c, DocSubTyp__c
                FROM DocDtl__c
                WHERE Appl__c = :applicantId
            ];

            system.debug('docDetailList ' + docDetailList.size());

            if (!docDetailList.isEmpty()) {
                for (DocDtl__c doc : docDetailList) {
                    Map<String, Set<String>> existringRecord = docCatgryWithTypeAndSubtype.get(
                        doc.DocCatgry__c
                    );

                    if (existringRecord == null) {
                        existringRecord = new Map<String, Set<String>>();

                        Set<String> subTypes = new Set<String>();

                        subTypes.add(doc.DocSubTyp__c);

                        existringRecord.put(doc.DocTyp__c, subTypes);
                    } else {
                        Set<String> subTypes = existringRecord.get(
                            doc.DocTyp__c
                        );

                        if (subTypes == null) {
                            subTypes = new Set<String>();
                        }
                        subTypes.add(doc.DocSubTyp__c);

                        existringRecord.put(doc.DocTyp__c, subTypes);
                    }

                    docCatgryWithTypeAndSubtype.put(
                        doc.DocCatgry__c,
                        existringRecord
                    );
                }

                system.debug(
                    'docCatgryWithTypeAndSubtype' + docCatgryWithTypeAndSubtype
                );
                if (!ruleExpr.isEmpty()) {
                    for (RuleExp__mdt ruelEx : ruleExpr) {
                        CriteriaConfigClass expressionCtria = (CriteriaConfigClass) JSON.deserialize(
                            ruelEx.ExpCrt__c,
                            CriteriaConfigClass.class
                        );

                        if (expressionCtria != null) {
                            system.debug('wrpper data ' + expressionCtria);
                            system.debug(
                                'criteria ' +
                                expressionCtria.criteriaConfig.criteria
                            );

                            List<CriteriaConfigClass.Criteria> criteriaList = expressionCtria.criteriaConfig.criteria;

                            system.debug('criteriaList' + criteriaList[0]);

                            for (
                                CriteriaConfigClass.Criteria cri : criteriaList
                            ) {
                                system.debug('criteria cri' + cri);
                                if (cri.objectAPIName == 'Applicant__c') {
                                    String value = appRecords
                                            .get(cri.fieldName.trim()) != null
                                        ? (String) appRecords
                                              .get(cri.fieldName.trim())
                                        : 'test';
                                    value = removeSpecialCharactor(value);

                                    bindings.put(
                                        cri.fieldName.trim().toLowerCase(),
                                        value
                                    );
                                } else if (cri.objectAPIName == 'LoanAppl__c') {
                                    String value = loanAppRecords[0]
                                            .get(cri.fieldName.trim()) != null
                                        ? (String) loanAppRecords[0]
                                              .get(cri.fieldName.trim())
                                        : 'test';
                                    system.debug('inside loan app');
                                    value = removeSpecialCharactor(value);
                                    bindings.put(
                                        cri.fieldName.trim().toLowerCase(),
                                        value
                                    );
                                } else if (
                                    cri.objectAPIName ==
                                    'ApplicantEmployment__c'
                                ) {
                                    String value = 'blank';
                                    if (appEmpRecords.size() > 0) {
                                        value = appEmpRecords[0]
                                                .get(cri.fieldName.trim()) !=
                                            null
                                            ? (String) appEmpRecords[0]
                                                  .get(cri.fieldName.trim())
                                            : 'blank';
                                    }
                                    system.debug('inside appEmp app');
                                    value = removeSpecialCharactor(value);
                                    bindings.put(
                                        cri.fieldName.trim().toLowerCase(),
                                        value
                                    );
                                }
                            }

                            String expNode = expressionCtria.criteriaConfig.expression;

                            system.debug('expression ' + expNode);

                            Rule r = new Rule().setExpression(expNode);
                            system.debug('rrr' + r);
                            system.debug('bindings' + bindings);

                            Boolean retVal = r.eval(bindings);

                            system.debug('retVal from rule engine ' + retVal);

                            if (retVal) {
                                ResultJson resultJsonList = (ResultJson) JSON.deserialize(
                                    ruelEx.RsltJsn__c,
                                    ResultJson.class
                                );

                                system.debug(
                                    'resultJsonList ' + resultJsonList
                                );

                                if (
                                    resultJsonList.andList != null &&
                                    !resultJsonList.andList.isEmpty()
                                ) {
                                    for (
                                        ResultJson.dataVal oneData : resultJsonList.andList
                                    ) {
                                        if (
                                            categoriesList.contains(
                                                oneData.docCategory
                                            )
                                        ) {
                                            system.debug(
                                                'Inside contains doc Category'
                                            );

                                            Map<String, Set<String>> docAndList = docCatgryWithTypeAndSubtype.get(
                                                oneData.docCategory
                                            );

                                            /* 
                                  Integer andCount = 0;
                                Boolean andBoolean = false;
if(docAndList != null && !docAndList.isEmpty()){
List<String> docSubTypes = oneData.docSubType;
system.debug('docSubTypes size' + docSubTypes.size());
List<String> reqDoc = docAndList.get(oneData.docType);
system.debug('reqDoc is ' +reqDoc);
if(reqDoc != null && !reqDoc.isEmpty()){

for(String docc : docSubTypes){
system.debug('docc' + docc);
if(reqDoc.contains(docc)){
andCount++ ;
}else{
andCount-- ;
}
}
}
system.debug('andCount ' + andCount);
if(andCount == docSubTypes.size()-1){
andBoolean = true ;
}else{
if(andBoolean == true){}else{
andBoolean = false;
}}
}*/
                                            if (
                                                docAndList != null &&
                                                !docAndList.isEmpty()
                                            ) {
                                                List<String> docSubTypes = oneData.docSubType;
                                                // set<String> docSubTypesReq = new Set<String>(docSubTypes);
                                                system.debug(
                                                    'docSubTypes size' +
                                                    docSubTypes.size()
                                                );
                                                Set<String> reqDoc = docAndList.get(
                                                    oneData.docType
                                                );
                                                if (
                                                    reqDoc != null &&
                                                    !reqDoc.isEmpty()
                                                ) {
                                                    Boolean result = reqDoc.containsAll(
                                                        docSubTypes
                                                    );
                                                    system.debug(
                                                        'result in and condition ' +
                                                        result
                                                    );
                                                    if (result == false) {
                                                        missingDocs.add(
                                                            oneData.docType
                                                        );
                                                    }
                                                } else {
                                                    missingDocs.add(
                                                        oneData.docType
                                                    );
                                                }
                                            } else {
                                                missingDocs.add(
                                                    oneData.docType
                                                );
                                            }
                                        }
                                    }
                                }
                                if (
                                    resultJsonList.orList != null &&
                                    !resultJsonList.orList.isEmpty()
                                ) {
                                    List<String> docTypeOrList = resultJsonList.docTypeOrList;
                                    List<String> missingDocTypeOrList = new List<String>();
                                    for (
                                        ResultJson.dataVal oneData : resultJsonList.orList
                                    ) {
                                        if (
                                            categoriesList.contains(
                                                oneData.docCategory
                                            )
                                        ) {
                                            system.debug(
                                                'Inside contains doc Or Category'
                                            );
                                            Map<String, Set<String>> docOrExistList = docCatgryWithTypeAndSubtype.get(
                                                oneData.docCategory
                                            );
                                            if (
                                                docOrExistList != null &&
                                                !docOrExistList.isEmpty()
                                            ) {
                                                List<String> docSubTypes = oneData.docSubType;
                                                system.debug(
                                                    'docSubTypes size' +
                                                    docSubTypes.size()
                                                );
                                                Integer count = 0;
                                                Set<String> existDoc = docOrExistList.get(
                                                    oneData.docType
                                                );
                                                if (
                                                    existDoc != null &&
                                                    !existDoc.isEmpty()
                                                ) {
                                                    for (
                                                        String docSubtype : oneData.docSubType
                                                    ) {
                                                        if (
                                                            existDoc.contains(
                                                                docSubtype
                                                            )
                                                        ) {
                                                            count++;
                                                        }
                                                    }
                                                    system.debug(
                                                        'existDoc ' + existDoc
                                                    );
                                                    system.debug(
                                                        'count==' +
                                                            oneData.docType +
                                                            '::::' +
                                                            count
                                                    );
                                                    if (count == 0) {
                                                        if (
                                                            docTypeOrList !=
                                                            null &&
                                                            docTypeOrList.contains(
                                                                oneData.docType
                                                            )
                                                        ) {
                                                            missingDocTypeOrList.add(
                                                                oneData.docType
                                                            );
                                                        } else {
                                                            missingDocs.add(
                                                                oneData.docType
                                                            );
                                                        }
                                                    }
                                                } else {
                                                    if (
                                                        docTypeOrList != null &&
                                                        docTypeOrList.contains(
                                                            oneData.docType
                                                        )
                                                    ) {
                                                        missingDocTypeOrList.add(
                                                            oneData.docType
                                                        );
                                                    } else {
                                                        missingDocs.add(
                                                            oneData.docType
                                                        );
                                                    }
                                                }
                                            } else {
                                                if (
                                                    docTypeOrList != null &&
                                                    docTypeOrList.contains(
                                                        oneData.docType
                                                    )
                                                ) {
                                                    missingDocTypeOrList.add(
                                                        oneData.docType
                                                    );
                                                } else {
                                                    missingDocs.add(
                                                        oneData.docType
                                                    );
                                                }
                                            }
                                        }
                                    }
                                    System.debug(
                                        'missingDocTypeOrList ===' +
                                        missingDocTypeOrList
                                    );
                                    if (
                                        docTypeOrList != null &&
                                        docTypeOrList.size() ==
                                        missingDocTypeOrList.size()
                                    ) {
                                        //  missingDocs.add(String.join(docTypeOrList, '/'));
                                        for (String docTy : docTypeOrList) {
                                            missingDocs.add(docTy);
                                        }
                                    }
                                }
                                /*     Integer orCount = 0 ;
                                Boolean orBoolean = false; 
                                if(resultJsonList.orList != null && !resultJsonList.orList.isEmpty()) {   
                                    for(ResultJson.dataVal oneData : resultJsonList.orList){
                                        if(categoriesList.contains(oneData.docCategory)){
                                            Map<String,Set<String>> docOrList = docCatgryWithTypeAndSubtype.get(oneData.docCategory);
                                            if( docOrList != null && !docOrList.isEmpty()){
                                                List<String> docSubTypes = oneData.docSubType;
                                                system.debug('docSubTypes size' + docSubTypes.size());
                                                Set<String> reqDoc = docOrList.get(oneData.docType);
                                                
                                                if(reqDoc.size() > 0){
                                                    
                                                }else{
                                                    if(reqDoc != null && !reqDoc.isEmpty()){ 
                                                        for(String docc : docSubTypes){
                                                            system.debug('docc' + docc);
                                                            if(reqDoc.contains(docc)){
                                                                orCount++ ;
                                                            }else{
                                                                orCount-- ;
                                                            }
                                                        }
                                                    }   
                                                }
                                            } 
                                        }
                                    }
                                } 
                                system.debug('Final And and Or boolean result is ' + andBoolean + orBoolean);
                                if(andBoolean == true && orBoolean == true){
                                    alldocsAvailable = true;
                                    system.debug('alldocsAvailable inside true>>>>>>>>>>' + alldocsAvailable);
                                }  */
                            }
                        }
                    }
                }
            }
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
        system.debug(
            'Final value for missingDocs ====>>>>>>>>>>' + missingDocs
        );
        system.debug(
            'Final value for alldocsAvailable ====>>>>>>>>>>' + alldocsAvailable
        );
        List<String> missingReqDocs = new List<String>(missingDocs);
        system.debug(
            'Final value for missingReqDocs ====>>>>>>>>>>' + missingReqDocs
        );
        return missingReqDocs;
    }

    public static void returnMissingDocs(
        Map<String, Map<String, List<String>>> docCatgryWithTypeAndSubtype,
        List<ResultJson.dataVal> resultJsonList,
        set<String> missingDoc
    ) {
        system.debug('cateWithTypeAndSub ' + docCatgryWithTypeAndSubtype);
        system.debug('resultJsonList ' + resultJsonList);
        system.debug('missingDoc ' + missingDoc);

        if (resultJsonList != null && !resultJsonList.isEmpty()) {
            for (ResultJson.dataVal oneData : resultJsonList) {
                Map<String, List<String>> docExistList = docCatgryWithTypeAndSubtype.get(
                    oneData.docCategory
                );
            }
        }
    }

    public static Map<String, Map<String, Set<String>>> getDocumentsMap(
        List<ResultJson.dataVal> dataList,
        Map<String, Map<String, Set<String>>> cateWithTypeAndSub
    ) {
        Map<String, Map<String, Set<String>>> cateWithTypeAndSubType = new Map<String, Map<String, Set<String>>>(
            cateWithTypeAndSub
        );

        system.debug(
            'cateWithTypeAndSubType in getDocumentsMap Methods starting ' +
            cateWithTypeAndSubType
        );

        for (ResultJson.dataVal oneData : dataList) {
            system.debug(
                'docType ' +
                    oneData.docType +
                    'docCategory ' +
                    oneData.docCategory +
                    'docSubTypes ' +
                    oneData.docSubType
            );

            Map<String, Set<String>> existringRecord = cateWithTypeAndSubType.get(
                oneData.docCategory
            );

            if (existringRecord == null) {
                existringRecord = new Map<String, Set<String>>();

                Set<String> subTypes = new Set<String>();

                subTypes.addAll(oneData.docSubType);

                system.debug('subTypes ' + subTypes);

                existringRecord.put(oneData.docType, subTypes);

                // cateWithTypeAndSubType.put(oneData.docCategory,existringRecord);
            } else {
                Set<String> subTypes = existringRecord.get(oneData.docType);

                if (subTypes == null) {
                    subTypes = new Set<String>();
                }
                subTypes.addAll(oneData.docSubType);

                existringRecord.put(oneData.docType, subTypes);
            }

            cateWithTypeAndSubType.put(oneData.docCategory, existringRecord);
        }
        if (cateWithTypeAndSubType.size() > 0) {
            system.debug(
                'cateWithTypeAndSubType in getDocumentsMap methods' +
                cateWithTypeAndSubType
            );
            return cateWithTypeAndSubType;
        }
        system.debug(
            'cateWithTypeAndSubType in getDocumentsMap methods' +
            cateWithTypeAndSubType
        );
        return null;
    }

    public static Map<String, List<String>> evalAllRequiredDocsAdd(
        String applicantId,
        String loanAppId,
        String productType,
        String stage,
        String subStage,
        List<String> categoriesList
    ) {
        //DocumentEngine.evalAllRequiredDocs('a0AC4000000EYEjMAO', 'a08C4000006Ayh2IAC','Home Loan','QDE','RM Data Entry');
        system.debug('categoriesList ' + categoriesList);

        Boolean alldocsAvailable = false;
        Set<String> missingDocs = new Set<String>();
        Map<String, Set<String>> missingDocsMap = new Map<String, Set<String>>();
        Map<String, Set<String>> missingDocsOrListMap = new Map<String, Set<String>>();
        Map<String, String> bindings = new Map<String, String>();

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
        Map<String, Map<String, Set<String>>> docCatgryWithTypeAndSubtype = new Map<String, Map<String, Set<String>>>();
        Map<String, Set<String>> typeWithSubtype = new Map<String, Set<String>>();

        try {
            List<LoanAppl__c> loanAppRecords = [
                SELECT
                    Id,
                    SubStage__c,
                    Stage__c,
                    AssesIncomeAppl__c,
                    AssessedIncAppln__c
                FROM LoanAppl__c
                WHERE Id = :loanAppId
            ];

            List<Applicant__c> appRecords = [
                SELECT
                    Id,
                    Constitution__c,
                    CustProfile__c,
                    ApplType__c,
                    Category__c,
                    Type_of_Borrower__c,IsBo__c,
                    LatestyearforwhichITRisavailable__c
                FROM Applicant__c
                WHERE Id = :applicantId
            ];

            List<ApplicantEmployment__c> appEmpRecords = [
                SELECT Id, Select_applicability_for_URC_UAC__c
                FROM ApplicantEmployment__c
                WHERE LoanApplicant__c = :applicantId
            ];

            List<RuleExp__mdt> ruleExpr = [
                SELECT
                    ProdTyp__c,
                    RuleExpTyp__c,
                    RsltJsn__c,
                    Stg__c,
                    SubStg__c,
                    IsActive__c,
                    ExpCrt__c,
                    Label
                FROM RuleExp__mdt
                WHERE IsActive__c = TRUE AND ProdTyp__c = :productType
            ]; // AND Stg__c =: stage AND SubStg__c =: subStage];

            List<DocDtl__c> docDetailList = [
                SELECT DocCatgry__c, DocTyp__c, DocSubTyp__c
                FROM DocDtl__c
                WHERE Appl__c = :applicantId AND IsDeleted__c =false
            ];

            system.debug('docDetailList ' + docDetailList.size());

            if (!docDetailList.isEmpty()) {
                for (DocDtl__c doc : docDetailList) {
                    Map<String, Set<String>> existringRecord = docCatgryWithTypeAndSubtype.get(
                        doc.DocCatgry__c
                    );

                    if (existringRecord == null) {
                        existringRecord = new Map<String, Set<String>>();

                        Set<String> subTypes = new Set<String>();

                        subTypes.add(doc.DocSubTyp__c);

                        existringRecord.put(doc.DocTyp__c, subTypes);
                    } else {
                        Set<String> subTypes = existringRecord.get(
                            doc.DocTyp__c
                        );

                        if (subTypes == null) {
                            subTypes = new Set<String>();
                        }
                        subTypes.add(doc.DocSubTyp__c);

                        existringRecord.put(doc.DocTyp__c, subTypes);
                    }

                    docCatgryWithTypeAndSubtype.put(
                        doc.DocCatgry__c,
                        existringRecord
                    );
                }

                system.debug(
                    'docCatgryWithTypeAndSubtype' + docCatgryWithTypeAndSubtype
                );
                if (!ruleExpr.isEmpty()) {
                    for (RuleExp__mdt ruelEx : ruleExpr) {
                        CriteriaConfigClass expressionCtria = (CriteriaConfigClass) JSON.deserialize(
                            ruelEx.ExpCrt__c,
                            CriteriaConfigClass.class
                        );

                        if (expressionCtria != null) {
                            system.debug('wrpper data ' + expressionCtria);
                            system.debug(
                                'criteria ' +
                                expressionCtria.criteriaConfig.criteria
                            );

                            List<CriteriaConfigClass.Criteria> criteriaList = expressionCtria.criteriaConfig.criteria;

                            system.debug('criteriaList' + criteriaList[0]);

                            for (
                                CriteriaConfigClass.Criteria cri : criteriaList
                            ) {
                                system.debug('criteria cri' + cri);
                                if (cri.objectAPIName == 'Applicant__c') {
                                    String value = appRecords[0]
                                            .get(cri.fieldName.trim()) != null
                                        ? (String) appRecords[0]
                                              .get(cri.fieldName.trim())
                                        : 'test';
                                    value = removeSpecialCharactor(value);

                                    bindings.put(
                                        cri.fieldName.trim().toLowerCase(),
                                        value
                                    );
                                } else if (cri.objectAPIName == 'LoanAppl__c') {
                                    String value = loanAppRecords[0]
                                            .get(cri.fieldName.trim()) != null
                                        ? (String) loanAppRecords[0]
                                              .get(cri.fieldName.trim())
                                        : 'test';
                                    system.debug('inside loan app');
                                    value = removeSpecialCharactor(value);

                                    bindings.put(
                                        cri.fieldName.trim().toLowerCase(),
                                        value
                                    );
                                } else if (
                                    cri.objectAPIName ==
                                    'ApplicantEmployment__c'
                                ) {
                                    String value = 'blank';
                                    if (appEmpRecords.size() > 0) {
                                        value = appEmpRecords[0]
                                                .get(cri.fieldName.trim()) !=
                                            null
                                            ? (String) appEmpRecords[0]
                                                  .get(cri.fieldName.trim())
                                            : 'blank';
                                    }
                                    system.debug('inside appEmp app');
                                    value = removeSpecialCharactor(value);

                                    bindings.put(
                                        cri.fieldName.trim().toLowerCase(),
                                        value
                                    );
                                }
                            }

                            String expNode = expressionCtria.criteriaConfig.expression;

                            system.debug('expression ' + expNode);

                            Rule r = new Rule().setExpression(expNode);
                            system.debug('rrr' + r);
                            system.debug('bindings' + bindings);

                            Boolean retVal = r.eval(bindings);

                            system.debug('retVal from rule engine ' + retVal);

                            if (retVal) {
                                ResultJson resultJsonList = (ResultJson) JSON.deserialize(
                                    ruelEx.RsltJsn__c,
                                    ResultJson.class
                                );

                                system.debug(
                                    'resultJsonList ' + resultJsonList
                                );

                                if (
                                    resultJsonList.andList != null &&
                                    !resultJsonList.andList.isEmpty()
                                ) {
                                    for (
                                        ResultJson.dataVal oneData : resultJsonList.andList
                                    ) {
                                        if (
                                            categoriesList.contains(
                                                oneData.docCategory
                                            )
                                        ) {
                                            system.debug(
                                                'Inside contains doc Category'
                                            );
                                            Map<String, Set<String>> docAndList = docCatgryWithTypeAndSubtype.get(
                                                oneData.docCategory
                                            );

                                            if (
                                                docAndList != null &&
                                                !docAndList.isEmpty()
                                            ) {
                                                List<String> docSubTypes = oneData.docSubType;
                                                // set<String> docSubTypesReq = new Set<String>(docSubTypes);
                                                system.debug(
                                                    'docSubTypes size' +
                                                    docSubTypes.size()
                                                );
                                                Set<String> reqDoc = docAndList.get(
                                                    oneData.docType
                                                );
                                                if (
                                                    reqDoc != null &&
                                                    !reqDoc.isEmpty()
                                                ) {
                                                    for (
                                                        String str : docSubTypes
                                                    ) {
                                                        if (
                                                            !reqDoc.contains(
                                                                str
                                                            )
                                                        ) {
                                                            Set<String> exsDocSubTypes = missingDocsMap.get(
                                                                oneData.docType
                                                            );
                                                            if (
                                                                exsDocSubTypes ==
                                                                null
                                                            ) {
                                                                exsDocSubTypes = new Set<String>();
                                                            }
                                                            exsDocSubTypes.add(
                                                                str
                                                            );
                                                            missingDocsMap.put(
                                                                oneData.docType,
                                                                exsDocSubTypes
                                                            );
                                                        }
                                                    }
                                                    /* Boolean result = reqDoc.containsAll(docSubTypes);
                                                    system.debug('result in and condition ' + result);
                                                    if(result == false){
                                               
                                                       missingDocsMap.put(oneData.docType,new Set<String>(docSubTypes));
                                                    }*/
                                                } else {
                                                    //missingDocs.add(oneData.docType);
                                                    //Set<String> uniqueSet = new Set<String>(docSubTypes);
                                                    missingDocsMap.put(
                                                        oneData.docType,
                                                        new Set<String>(
                                                            docSubTypes
                                                        )
                                                    );
                                                }
                                            } else {
                                                List<String> docSubTypesAre = oneData.docSubType;
                                                //  missingDocs.add(oneData.docType);
                                                missingDocsMap.put(
                                                    oneData.docType,
                                                    new Set<String>(
                                                        docSubTypesAre
                                                    )
                                                );
                                            }
                                        }
                                    }
                                }
                                if (
                                    resultJsonList.orList != null &&
                                    !resultJsonList.orList.isEmpty()
                                ) {
                                    List<String> docTypeOrList = resultJsonList.docTypeOrList;
                                    List<String> missingDocTypeOrList = new List<String>();
                                    Boolean docTypeOrListFound = false;
                                    Boolean docCatFound = false;
                                    String docCat = '';
                                    system.debug(
                                        '  ruelEx.Label  ' + ruelEx.Label
                                    );
                                    for (
                                        ResultJson.dataVal oneData : resultJsonList.orList
                                    ) {
                                        system.debug(
                                            ' categoriesList ' +
                                                categoriesList +
                                                ' oneData.docCategory : ' +
                                                oneData.docCategory +
                                                oneData
                                        );
                                        system.debug(
                                            ' docTypeOrList  : ' + docTypeOrList
                                        );
                                        if (
                                            categoriesList.contains(
                                                oneData.docCategory
                                            )
                                        ) {
                                            if (
                                                docTypeOrList != null &&
                                                docTypeOrList.contains(
                                                    oneData.docType
                                                )
                                            ) {
                                                docCatFound = true;
                                                docCat = oneData.docCategory;
                                            }
                                            system.debug(
                                                'Inside contains doc Or Category'
                                            );
                                            Map<String, Set<String>> docOrExistList = docCatgryWithTypeAndSubtype.get(
                                                oneData.docCategory
                                            );
                                            List<String> docSubTypes = oneData.docSubType;
                                            system.debug(
                                                'docOrExistList : ' +
                                                    docOrExistList +
                                                    ' docSubTypes size' +
                                                    docSubTypes.size()
                                            );
                                            if (
                                                docOrExistList != null &&
                                                !docOrExistList.isEmpty()
                                            ) {
                                                Integer count = 0;
                                                Set<String> existDoc = docOrExistList.get(
                                                    oneData.docType
                                                );
                                                if (
                                                    existDoc != null &&
                                                    !existDoc.isEmpty()
                                                ) {
                                                    for (
                                                        String docSubtype : oneData.docSubType
                                                    ) {
                                                        if (
                                                            existDoc.contains(
                                                                docSubtype
                                                            )
                                                        ) {
                                                            count++;
                                                            if (
                                                                docTypeOrList !=
                                                                null &&
                                                                docTypeOrList.contains(
                                                                    oneData.docType
                                                                )
                                                            ) {
                                                                docTypeOrListFound = true;
                                                                system.debug(
                                                                    'docTypeOrListFound  683 ' +
                                                                        docTypeOrListFound +
                                                                        ' : ' +
                                                                        existDoc.contains(
                                                                            docSubtype
                                                                        ) +
                                                                        ' : docTypeOrList ' +
                                                                        docTypeOrList +
                                                                        ' : ' +
                                                                        docSubtype +
                                                                        ' : ' +
                                                                        applicantId +
                                                                        ' : ' +
                                                                        ruelEx.Label
                                                                );
                                                            }
                                                        }
                                                    }
                                                    system.debug(
                                                        'existDoc ' + existDoc
                                                    );
                                                    system.debug(
                                                        'count==' +
                                                            oneData.docType +
                                                            '::::' +
                                                            count
                                                    );
                                                    if (count == 0) {
                                                        /*if(docTypeOrList != null && docTypeOrList.contains(oneData.docType)){
                                                        // missingDocTypeOrList.add(oneData.docType);

                                                        Set<String> exsDocSubTypes = missingDocsOrListMap.get(oneData.docType);
                                                        if(exsDocSubTypes == null){
                                                            exsDocSubTypes = new Set<String>();
                                                        }
                                                        exsDocSubTypes.addAll(docSubTypes);
                                                        missingDocsOrListMap.put(oneData.docType,exsDocSubTypes);
                                                    }*/ if (
                                                            docTypeOrList ==
                                                            null ||
                                                            !docTypeOrList.contains(
                                                                oneData.docType
                                                            )
                                                        ) {
                                                            Set<String> exsDocSubTypes = missingDocsOrListMap.get(
                                                                oneData.docType
                                                            );
                                                            if (
                                                                exsDocSubTypes ==
                                                                null
                                                            ) {
                                                                exsDocSubTypes = new Set<String>();
                                                            }
                                                            exsDocSubTypes.addAll(
                                                                docSubTypes
                                                            );
                                                            missingDocsOrListMap.put(
                                                                oneData.docType,
                                                                exsDocSubTypes
                                                            );

                                                            //    missingDocsMap.put(oneData.docType,null);
                                                        }
                                                    }
                                                } else {
                                                    /*if(docTypeOrList != null && docTypeOrList.contains(oneData.docType)){
                                                        // missingDocTypeOrList.add(oneData.docType);
                                                        Set<String> exsDocSubTypes = missingDocsOrListMap.get(oneData.docType);
                                                        if(exsDocSubTypes == null){
                                                            exsDocSubTypes = new Set<String>();
                                                        }
                                                        exsDocSubTypes.addAll(docSubTypes);
                                                        missingDocsOrListMap.put(oneData.docType,exsDocSubTypes);
                                                    }*/ if (
                                                        docTypeOrList == null ||
                                                        !docTypeOrList.contains(
                                                            oneData.docType
                                                        )
                                                    ) {
                                                        Set<String> exsDocSubTypes = missingDocsOrListMap.get(
                                                            oneData.docType
                                                        );
                                                        if (
                                                            exsDocSubTypes ==
                                                            null
                                                        ) {
                                                            exsDocSubTypes = new Set<String>();
                                                        }
                                                        exsDocSubTypes.addAll(
                                                            docSubTypes
                                                        );
                                                        missingDocsOrListMap.put(
                                                            oneData.docType,
                                                            exsDocSubTypes
                                                        );
                                                        // missingDocsMap.put(oneData.docType,null);
                                                    }
                                                }
                                            } else {
                                                /*if(docTypeOrList != null && docTypeOrList.contains(oneData.docType) && docTypeOrListFound == false){
                                                        // missingDocTypeOrList.add(oneData.docType);
                                                        Set<String> exsDocSubTypes = missingDocsOrListMap.get(oneData.docType);
                                                        if(exsDocSubTypes == null){
                                                            exsDocSubTypes = new Set<String>();
                                                        }
                                                        exsDocSubTypes.addAll(docSubTypes);
                                                        missingDocsOrListMap.put(oneData.docType,exsDocSubTypes);
                                                    }*/ if (
                                                    docTypeOrList == null ||
                                                    !docTypeOrList.contains(
                                                        oneData.docType
                                                    )
                                                ) {
                                                    // missingDocsMap.put(oneData.docType,null);
                                                    Set<String> exsDocSubTypes = missingDocsOrListMap.get(
                                                        oneData.docType
                                                    );
                                                    if (
                                                        exsDocSubTypes == null
                                                    ) {
                                                        exsDocSubTypes = new Set<String>();
                                                    }
                                                    exsDocSubTypes.addAll(
                                                        docSubTypes
                                                    );
                                                    missingDocsOrListMap.put(
                                                        oneData.docType,
                                                        exsDocSubTypes
                                                    );
                                                }
                                            }
                                        }
                                    }
                                    system.debug(
                                        'docTypeOrListFound  1053 ' +
                                            docTypeOrListFound +
                                            ' :: ' +
                                            docTypeOrList +
                                            ' : ' +
                                            applicantId +
                                            ' : ' +
                                            ruelEx.Label +
                                            ' : ' +
                                            docCatFound
                                    );
                                    if (
                                        docTypeOrList != null &&
                                        docCatFound == true &&
                                        docTypeOrListFound == false
                                    ) {
                                        // missingDocTypeOrList.add(oneData.docType);
                                        system.debug(
                                            'outside for loop 1057 ' +
                                                docTypeOrList +
                                                '  docCatFound :' +
                                                docCatFound +
                                                'docTypeOrListFound : ' +
                                                docTypeOrListFound +
                                                ' :: ' +
                                                docTypeOrList +
                                                ' : ' +
                                                applicantId +
                                                ' : ' +
                                                ruelEx.Label
                                        );
                                        Set<String> exsDocSubTypes = missingDocsOrListMap.get(
                                            docCat
                                        );
                                        if (exsDocSubTypes == null) {
                                            exsDocSubTypes = new Set<String>();
                                        }
                                        exsDocSubTypes.addAll(docTypeOrList);
                                        missingDocsOrListMap.put(
                                            docCat,
                                            exsDocSubTypes
                                        );
                                    }
                                    // System.debug('missingDocTypeOrList ==='+missingDocTypeOrList);
                                    //  if(docTypeOrList != null && docTypeOrList.size() == missingDocTypeOrList.size()) {

                                    //      for(String docTy : docTypeOrList){
                                    //         missingDocsMap.put(docTy,null);
                                    //         // missingDocs.add(docTy);
                                    //      }
                                    //  }
                                }
                            }
                        }
                    }
                }
            }
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
        system.debug(
            'Final value for missingDocs ====>>>>>>>>>>' + missingDocs
        );
        system.debug(
            'Final value for alldocsAvailable ====>>>>>>>>>>' + alldocsAvailable
        );
        List<String> missingReqDocs = new List<String>(missingDocs);
        system.debug(
            'Final value for missingReqDocs ====>>>>>>>>>>' + missingReqDocs
        );

        if (missingDocsMap.size() > 0) {
            Map<String, List<String>> fetchAllDocs = new Map<String, List<String>>();
            system.debug('missingDocsMap final is' + missingDocsMap);
            for (String key : missingDocsMap.keySet()) {
                fetchAllDocs.put(
                    key,
                    new List<String>(missingDocsMap.get(key))
                );
            }
            if (missingDocsOrListMap.size() > 0) {
                for (String key : missingDocsOrListMap.keySet()) {
                    fetchAllDocs.put(
                       ' Atleast One Document is required for '+ key,
                        new List<String>(missingDocsOrListMap.get(key))
                    );
                }
            }
            system.debug('missingDocsMap final before return ' + fetchAllDocs);
            return fetchAllDocs;
        }
        return null;
    }

    public static string removeSpecialCharactor(string value) {
        if (value != null) {
            value = value.replaceAll('\\s+', '');
            value = value.replaceAll('\\(', '');
            value = value.replaceAll('\\)', '');
            value = value.replaceAll('\\!', '');
            value = value.replaceAll('\\@', '');

            value = value.replaceAll('\\#', '');
            value = value.replaceAll('\\$', '');
            value = value.replaceAll('\\%', '');
            value = value.replaceAll('\\^', '');
            value = value.replaceAll('\\&', '');
            value = value.replaceAll('\\*', '');
            value = value.replaceAll('\\-', '');
            value = value.replaceAll('\\_', '');
            value = value.replaceAll('\\?', '');

            value = value.replaceAll('\\<', '');
            value = value.replaceAll('\\>', '');
        }
        return value;
    }

    public MissingDocRetunWrpr evalAllRequiredDocsAddNew(
        String applicantId,
        String loanAppId,
        String productType,
        String stage,
        String subStage,
        List<String> categoriesList
    ) {
        //DocumentEngine.evalAllRequiredDocs('a0AC4000000EYEjMAO', 'a08C4000006Ayh2IAC','Home Loan','QDE','RM Data Entry');
        system.debug('categoriesList ' + categoriesList);

        Boolean alldocsAvailable = false;
        Set<String> missingDocs = new Set<String>();
        Map<String, Set<String>> missingDocsMap = new Map<String, Set<String>>();
        Map<String, Set<String>> missingDocsOrListMap = new Map<String, Set<String>>();
        Map<String, String> bindings = new Map<String, String>();

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
        Map<String, Map<String, Set<String>>> docCatgryWithTypeAndSubtype = new Map<String, Map<String, Set<String>>>();
        Map<String, Set<String>> typeWithSubtype = new Map<String, Set<String>>();

        try {
            if(loanAppRecords.size() == 0){
                loanAppRecords = [
                    SELECT
                        Id,
                        SubStage__c,
                        Stage__c,
                        AssesIncomeAppl__c,
                        AssessedIncAppln__c
                    FROM LoanAppl__c
                    WHERE Id = :loanAppId
                ];
            }

            Applicant__c appRecords = appRecordsMap.get(applicantId);
            if(appRecords == null) {
                appRecords = [
                    SELECT
                        Id,
                        Constitution__c,
                        CustProfile__c,
                        ApplType__c,
                        Category__c,
                        Type_of_Borrower__c,IsBo__c,
                        LatestyearforwhichITRisavailable__c
                    FROM Applicant__c
                    WHERE Id = :applicantId
                    LIMIT 1
                ];
            }

            List<ApplicantEmployment__c> appEmpRecords = appEmpRecordsMap.get(applicantId);
            if(appEmpRecords == null) {
                appEmpRecords = new List<ApplicantEmployment__c>();
            }

            if(ruleExpr.size() == 0) {
                ruleExpr = [
                    SELECT
                        ProdTyp__c,
                        RuleExpTyp__c,
                        RsltJsn__c,
                        Stg__c,
                        SubStg__c,
                        IsActive__c,
                        ExpCrt__c,
                        Label
                    FROM RuleExp__mdt
                    WHERE IsActive__c = TRUE AND ProdTyp__c = :productType
                ]; // AND Stg__c =: stage AND SubStg__c =: subStage];
            }

            List<DocDtl__c> docDetailList = docDtlMap.get(applicantId);
            if(docDetailList == null) {
                docDetailList = new List<DocDtl__c>();
                /*docDetailList = [
                    SELECT DocCatgry__c, DocTyp__c, DocSubTyp__c
                    FROM DocDtl__c
                    WHERE Appl__c = :applicantId
                ];*/
            }

            system.debug('docDetailList ' + docDetailList.size());

            if (docDetailList != null) {
                for (DocDtl__c doc : docDetailList) {
                    Map<String, Set<String>> existringRecord = docCatgryWithTypeAndSubtype.get(
                        doc.DocCatgry__c
                    );

                    if (existringRecord == null) {
                        existringRecord = new Map<String, Set<String>>();

                        Set<String> subTypes = new Set<String>();

                        subTypes.add(doc.DocSubTyp__c);

                        existringRecord.put(doc.DocTyp__c, subTypes);
                    } else {
                        Set<String> subTypes = existringRecord.get(
                            doc.DocTyp__c
                        );

                        if (subTypes == null) {
                            subTypes = new Set<String>();
                        }
                        subTypes.add(doc.DocSubTyp__c);

                        existringRecord.put(doc.DocTyp__c, subTypes);
                    }

                    docCatgryWithTypeAndSubtype.put(
                        doc.DocCatgry__c,
                        existringRecord
                    );
                }

                system.debug(
                    ' docCatgryWithTypeAndSubtype' + docCatgryWithTypeAndSubtype
                );
                if (!ruleExpr.isEmpty()) {
                    for (RuleExp__mdt ruelEx : ruleExpr) {
                        CriteriaConfigClass expressionCtria = (CriteriaConfigClass) JSON.deserialize(
                            ruelEx.ExpCrt__c,
                            CriteriaConfigClass.class
                        );

                        if (expressionCtria != null) {
                            system.debug('wrpper data ' + expressionCtria);
                            system.debug(
                                'criteria ' +
                                expressionCtria.criteriaConfig.criteria
                            );

                            List<CriteriaConfigClass.Criteria> criteriaList = expressionCtria.criteriaConfig.criteria;

                            system.debug('criteriaList' + criteriaList[0]);

                            for (
                                CriteriaConfigClass.Criteria cri : criteriaList
                            ) {
                                system.debug('criteria cri' + cri);
                                if (cri.objectAPIName == 'Applicant__c') {
                                    String value = appRecords
                                            .get(cri.fieldName.trim()) != null
                                        ? (String) appRecords
                                              .get(cri.fieldName.trim())
                                        : 'test';
                                    value = removeSpecialCharactor(value);

                                    bindings.put(
                                        cri.fieldName.trim().toLowerCase(),
                                        value
                                    );
                                } else if (cri.objectAPIName == 'LoanAppl__c') {
                                    String value = loanAppRecords[0]
                                            .get(cri.fieldName.trim()) != null
                                        ? (String) loanAppRecords[0]
                                              .get(cri.fieldName.trim())
                                        : 'test';
                                    system.debug('inside loan app');
                                    value = removeSpecialCharactor(value);

                                    bindings.put(
                                        cri.fieldName.trim().toLowerCase(),
                                        value
                                    );
                                } else if (
                                    cri.objectAPIName ==
                                    'ApplicantEmployment__c'
                                ) {
                                    String value = 'blank';
                                    if (appEmpRecords.size() > 0) {
                                        value = appEmpRecords[0]
                                                .get(cri.fieldName.trim()) !=
                                            null
                                            ? (String) appEmpRecords[0]
                                                  .get(cri.fieldName.trim())
                                            : 'blank';
                                    }
                                    system.debug('inside appEmp app');
                                    value = removeSpecialCharactor(value);

                                    bindings.put(
                                        cri.fieldName.trim().toLowerCase(),
                                        value
                                    );
                                }
                            }

                            String expNode = expressionCtria.criteriaConfig.expression;

                            system.debug('expression ' + expNode);

                            Rule r = new Rule().setExpression(expNode);
                            system.debug('rrr' + r);
                            system.debug('bindings' + bindings);

                            Boolean retVal = r.eval(bindings);

                            system.debug('retVal from rule engine ' + retVal);

                            if (retVal) {
                                ResultJson resultJsonList = (ResultJson) JSON.deserialize(
                                    ruelEx.RsltJsn__c,
                                    ResultJson.class
                                );

                                system.debug(
                                    'resultJsonList ' + resultJsonList
                                );

                                if (
                                    resultJsonList.andList != null &&
                                    !resultJsonList.andList.isEmpty()
                                ) {
                                    for (
                                        ResultJson.dataVal oneData : resultJsonList.andList
                                    ) {
                                        if (
                                            categoriesList.contains(
                                                oneData.docCategory
                                            )
                                        ) {
                                            system.debug(
                                                'Inside contains doc Category'
                                            );
                                            Map<String, Set<String>> docAndList = docCatgryWithTypeAndSubtype.get(
                                                oneData.docCategory
                                            );

                                            if (
                                                docAndList != null &&
                                                !docAndList.isEmpty()
                                            ) {
                                                List<String> docSubTypes = oneData.docSubType;
                                                // set<String> docSubTypesReq = new Set<String>(docSubTypes);
                                                system.debug(
                                                    'docSubTypes size' +
                                                    docSubTypes.size()
                                                );
                                                Set<String> reqDoc = docAndList.get(
                                                    oneData.docType
                                                );
                                                if (
                                                    reqDoc != null &&
                                                    !reqDoc.isEmpty()
                                                ) {
                                                    for (
                                                        String str : docSubTypes
                                                    ) {
                                                        if (
                                                            !reqDoc.contains(
                                                                str
                                                            )
                                                        ) {
                                                            Set<String> exsDocSubTypes = missingDocsMap.get(
                                                                oneData.docType
                                                            );
                                                            if (
                                                                exsDocSubTypes ==
                                                                null
                                                            ) {
                                                                exsDocSubTypes = new Set<String>();
                                                            }
                                                            exsDocSubTypes.add(
                                                                str
                                                            );
                                                            missingDocsMap.put(
                                                                oneData.docType,
                                                                exsDocSubTypes
                                                            );
                                                        }
                                                    }
                                                    /* Boolean result = reqDoc.containsAll(docSubTypes);
                                                    system.debug('result in and condition ' + result);
                                                    if(result == false){
                                               
                                                       missingDocsMap.put(oneData.docType,new Set<String>(docSubTypes));
                                                    }*/
                                                } else {
                                                    //missingDocs.add(oneData.docType);
                                                    //Set<String> uniqueSet = new Set<String>(docSubTypes);
                                                    missingDocsMap.put(
                                                        oneData.docType,
                                                        new Set<String>(
                                                            docSubTypes
                                                        )
                                                    );
                                                }
                                            } else {
                                                List<String> docSubTypesAre = oneData.docSubType;
                                                //  missingDocs.add(oneData.docType);
                                                missingDocsMap.put(
                                                    oneData.docType,
                                                    new Set<String>(
                                                        docSubTypesAre
                                                    )
                                                );
                                            }
                                        }
                                    }
                                }
                                if (
                                    resultJsonList.orList != null &&
                                    !resultJsonList.orList.isEmpty()
                                ) {
                                    List<String> docTypeOrList = resultJsonList.docTypeOrList;
                                    List<String> missingDocTypeOrList = new List<String>();
                                    Boolean docTypeOrListFound = false;
                                    Boolean docCatFound = false;
                                    String docCat = '';
                                    system.debug(
                                        '  ruelEx.Label  ' + ruelEx.Label
                                    );
                                    for (
                                        ResultJson.dataVal oneData : resultJsonList.orList
                                    ) {
                                        system.debug(
                                            ' categoriesList ' +
                                                categoriesList +
                                                ' oneData.docCategory : ' +
                                                oneData.docCategory +
                                                oneData
                                        );
                                        system.debug(
                                            ' docTypeOrList  : ' + docTypeOrList
                                        );
                                        if (
                                            categoriesList.contains(
                                                oneData.docCategory
                                            )
                                        ) {
                                            if (
                                                docTypeOrList != null &&
                                                docTypeOrList.contains(
                                                    oneData.docType
                                                )
                                            ) {
                                                docCatFound = true;
                                                docCat = oneData.docCategory;
                                            }
                                            system.debug(
                                                'Inside contains doc Or Category'
                                            );
                                            Map<String, Set<String>> docOrExistList = docCatgryWithTypeAndSubtype.get(
                                                oneData.docCategory
                                            );
                                            List<String> docSubTypes = oneData.docSubType;
                                            system.debug(
                                                'docOrExistList : ' +
                                                    docOrExistList +
                                                    ' docSubTypes size' +
                                                    docSubTypes.size()
                                            );
                                            if (
                                                docOrExistList != null &&
                                                !docOrExistList.isEmpty()
                                            ) {
                                                Integer count = 0;
                                                Set<String> existDoc = docOrExistList.get(
                                                    oneData.docType
                                                );
                                                if (
                                                    existDoc != null &&
                                                    !existDoc.isEmpty()
                                                ) {
                                                    for (
                                                        String docSubtype : oneData.docSubType
                                                    ) {
                                                        if (
                                                            existDoc.contains(
                                                                docSubtype
                                                            )
                                                        ) {
                                                            count++;
                                                            if (
                                                                docTypeOrList !=
                                                                null &&
                                                                docTypeOrList.contains(
                                                                    oneData.docType
                                                                )
                                                            ) {
                                                                docTypeOrListFound = true;
                                                                system.debug(
                                                                    'docTypeOrListFound  683 ' +
                                                                        docTypeOrListFound +
                                                                        ' : ' +
                                                                        existDoc.contains(
                                                                            docSubtype
                                                                        ) +
                                                                        ' : docTypeOrList ' +
                                                                        docTypeOrList +
                                                                        ' : ' +
                                                                        docSubtype +
                                                                        ' : ' +
                                                                        applicantId +
                                                                        ' : ' +
                                                                        ruelEx.Label
                                                                );
                                                            }
                                                        }
                                                    }
                                                    system.debug(
                                                        'existDoc ' + existDoc
                                                    );
                                                    system.debug(
                                                        'count==' +
                                                            oneData.docType +
                                                            '::::' +
                                                            count
                                                    );
                                                    if (count == 0) {
                                                        /*if(docTypeOrList != null && docTypeOrList.contains(oneData.docType)){
                                                        // missingDocTypeOrList.add(oneData.docType);

                                                        Set<String> exsDocSubTypes = missingDocsOrListMap.get(oneData.docType);
                                                        if(exsDocSubTypes == null){
                                                            exsDocSubTypes = new Set<String>();
                                                        }
                                                        exsDocSubTypes.addAll(docSubTypes);
                                                        missingDocsOrListMap.put(oneData.docType,exsDocSubTypes);
                                                    }*/ if (
                                                            docTypeOrList ==
                                                            null ||
                                                            !docTypeOrList.contains(
                                                                oneData.docType
                                                            )
                                                        ) {
                                                            Set<String> exsDocSubTypes = missingDocsOrListMap.get(
                                                                oneData.docType
                                                            );
                                                            if (
                                                                exsDocSubTypes ==
                                                                null
                                                            ) {
                                                                exsDocSubTypes = new Set<String>();
                                                            }
                                                            exsDocSubTypes.addAll(
                                                                docSubTypes
                                                            );
                                                            missingDocsOrListMap.put(
                                                                oneData.docType,
                                                                exsDocSubTypes
                                                            );

                                                            //    missingDocsMap.put(oneData.docType,null);
                                                        }
                                                    }
                                                } else {
                                                    /*if(docTypeOrList != null && docTypeOrList.contains(oneData.docType)){
                                                        // missingDocTypeOrList.add(oneData.docType);
                                                        Set<String> exsDocSubTypes = missingDocsOrListMap.get(oneData.docType);
                                                        if(exsDocSubTypes == null){
                                                            exsDocSubTypes = new Set<String>();
                                                        }
                                                        exsDocSubTypes.addAll(docSubTypes);
                                                        missingDocsOrListMap.put(oneData.docType,exsDocSubTypes);
                                                    }*/ if (
                                                        docTypeOrList == null ||
                                                        !docTypeOrList.contains(
                                                            oneData.docType
                                                        )
                                                    ) {
                                                        Set<String> exsDocSubTypes = missingDocsOrListMap.get(
                                                            oneData.docType
                                                        );
                                                        if (
                                                            exsDocSubTypes ==
                                                            null
                                                        ) {
                                                            exsDocSubTypes = new Set<String>();
                                                        }
                                                        exsDocSubTypes.addAll(
                                                            docSubTypes
                                                        );
                                                        missingDocsOrListMap.put(
                                                            oneData.docType,
                                                            exsDocSubTypes
                                                        );
                                                        // missingDocsMap.put(oneData.docType,null);
                                                    }
                                                }
                                            } else {
                                                /*if(docTypeOrList != null && docTypeOrList.contains(oneData.docType) && docTypeOrListFound == false){
                                                        // missingDocTypeOrList.add(oneData.docType);
                                                        Set<String> exsDocSubTypes = missingDocsOrListMap.get(oneData.docType);
                                                        if(exsDocSubTypes == null){
                                                            exsDocSubTypes = new Set<String>();
                                                        }
                                                        exsDocSubTypes.addAll(docSubTypes);
                                                        missingDocsOrListMap.put(oneData.docType,exsDocSubTypes);
                                                    }*/ if (
                                                    docTypeOrList == null ||
                                                    !docTypeOrList.contains(
                                                        oneData.docType
                                                    )
                                                ) {
                                                    // missingDocsMap.put(oneData.docType,null);
                                                    Set<String> exsDocSubTypes = missingDocsOrListMap.get(
                                                        oneData.docType
                                                    );
                                                    if (
                                                        exsDocSubTypes == null
                                                    ) {
                                                        exsDocSubTypes = new Set<String>();
                                                    }
                                                    exsDocSubTypes.addAll(
                                                        docSubTypes
                                                    );
                                                    missingDocsOrListMap.put(
                                                        oneData.docType,
                                                        exsDocSubTypes
                                                    );
                                                }
                                            }
                                        }
                                    }
                                    system.debug(
                                        'docTypeOrListFound  1053 ' +
                                            docTypeOrListFound +
                                            ' :: ' +
                                            docTypeOrList +
                                            ' : ' +
                                            applicantId +
                                            ' : ' +
                                            ruelEx.Label +
                                            ' : ' +
                                            docCatFound
                                    );
                                    if (
                                        docTypeOrList != null &&
                                        docCatFound == true &&
                                        docTypeOrListFound == false
                                    ) {
                                        // missingDocTypeOrList.add(oneData.docType);
                                        system.debug(
                                            'outside for loop 1057 ' +
                                                docTypeOrList +
                                                '  docCatFound :' +
                                                docCatFound +
                                                'docTypeOrListFound : ' +
                                                docTypeOrListFound +
                                                ' :: ' +
                                                docTypeOrList +
                                                ' : ' +
                                                applicantId +
                                                ' : ' +
                                                ruelEx.Label
                                        );
                                        Set<String> exsDocSubTypes = missingDocsOrListMap.get(
                                            docCat
                                        );
                                        if (exsDocSubTypes == null) {
                                            exsDocSubTypes = new Set<String>();
                                        }
                                        exsDocSubTypes.addAll(docTypeOrList);
                                        missingDocsOrListMap.put(
                                            docCat,
                                            exsDocSubTypes
                                        );
                                    }
                                    // System.debug('missingDocTypeOrList ==='+missingDocTypeOrList);
                                    //  if(docTypeOrList != null && docTypeOrList.size() == missingDocTypeOrList.size()) {

                                    //      for(String docTy : docTypeOrList){
                                    //         missingDocsMap.put(docTy,null);
                                    //         // missingDocs.add(docTy);
                                    //      }
                                    //  }
                                }
                            }
                        }
                    }
                }
            }
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
        system.debug(
            'Final value for missingDocs ====>>>>>>>>>>' + missingDocs
        );
        system.debug(
            'Final value for alldocsAvailable ====>>>>>>>>>>' + alldocsAvailable
        );
        List<String> missingReqDocs = new List<String>(missingDocs);
        system.debug(
            'Final value for missingReqDocs ====>>>>>>>>>>' + missingReqDocs
        );

        MissingDocRetunWrpr missingDoc = new MissingDocRetunWrpr();
        if (missingDocsOrListMap.size() > 0) {
            Map<String, List<String>> fetchAllDocsOrList = new Map<String, List<String>>();
            system.debug(
                'missingDocsOrListMap final is' + missingDocsOrListMap
            );
            for (String key : missingDocsOrListMap.keySet()) {
                fetchAllDocsOrList.put(
                    key,
                    new List<String>(missingDocsOrListMap.get(key))
                );
            }
            missingDoc.orList = fetchAllDocsOrList;
        }

        if (missingDocsMap.size() > 0) {
            Map<String, List<String>> fetchAllDocs = new Map<String, List<String>>();
            system.debug('missingDocsMap final is' + missingDocsMap);
            for (String key : missingDocsMap.keySet()) {
                fetchAllDocs.put(
                    key,
                    new List<String>(missingDocsMap.get(key))
                );
            }
            // return fetchAllDocs;
            missingDoc.andList = fetchAllDocs;
        }
        if (missingDoc != null) {
            system.debug('missingDoc ' + missingDoc);
            return missingDoc;
        }
        return null;
    }
    public class MissingDocRetunWrpr {
        public Map<String, List<String>> andList { get; set; }
        public Map<String, List<String>> orList { get; set; }
    }
}