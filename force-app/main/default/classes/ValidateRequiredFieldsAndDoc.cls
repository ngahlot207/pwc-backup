public without sharing class ValidateRequiredFieldsAndDoc {
        public static Map<String, List<sObject>> recordByObj;
        @AuraEnabled
        public static List<Responce> getValidationReport(Id loanAppId) {
          List<Responce> respObjList = new List<Responce>();
          loanAppl__c loanAppRecord = [
      SELECT Id, Product__c, Stage__c, SubStage__c, Stepper__c
      FROM loanAppl__c
      WHERE Id = :loanAppId
      //  WITH SECURITY_ENFORCED
    ];
          try {
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
            
            // LoanAppl__c loanAppRecord = [
            //     SELECT Id, Product__c,  Stage__c, SubStage__c, Stepper__c
            //     FROM loanAppl__c
            //     WHERE id = :loanAppId
            //     WITH SECURITY_ENFORCED
            // ];
            string product = loanAppRecord.Product__c;
            string stage = loanAppRecord.Stage__c;
            string subStage = loanAppRecord.SubStage__c;
            string stepper = loanAppRecord.Stepper__c;
            
            List<Sobject> screenConfigList = new List<Sobject>();
            
            List<Screen_Config_Switch__mdt> sCS = [SELECT ProdTyp__c,Src__c FROM Screen_Config_Switch__mdt WHERE ProdTyp__c =:loanAppRecord.Product__c];
            if (!sCS.isEmpty() && sCS[0].Src__c == 'Metadata'){
              list<ScrConfig__mdt> screenConfigMdtList = new List<ScrConfig__mdt>();
              
              String prodType = '%' + product + '%';
              screenConfigMdtList = [SELECT Id, stageValidationConfig__c FROM ScrConfig__mdt
        						WHERE IsActive__c = TRUE AND StgApiName__c = :stage AND SubStgApiName__c = :subStage AND ProdTyp__c LIKE :prodType];
              screenConfigList = screenConfigMdtList;
              
            }else if (!sCS.isEmpty() && sCS[0].Src__c == 'Object'){
              List<ScrenPrgsConfg__c> screenConfigsObjList = new List<ScrenPrgsConfg__c>();
              screenConfigsObjList = [Select Id,stageValidationConfig__c FROM ScrenPrgsConfg__c where IsActive__c = TRUE
                                  AND StgName__c INCLUDES (:stage) AND SubStgName__c INCLUDES (:subStage) AND ProdTyp__c INCLUDES (:product)];
              screenConfigList = screenConfigsObjList;
            }
            
            list<RuleExpQryCnfg__mdt> ruleExpMdtList = new List<RuleExpQryCnfg__mdt>();
            ruleExpMdtList = [
        SELECT Id, QryJsn__c
        FROM RuleExpQryCnfg__mdt
        WHERE
          ProdTyp__c = :product
          AND RuleExpTyp__c = 'Screen Validation'
          AND IsActive__c = TRUE
        //  WITH SECURITY_ENFORCED
      ];
            system.debug('ruleExpMdt  ::' + ruleExpMdtList);
            RuleExpQueryConfig ruleExpQryConfig = new RuleExpQueryConfig();
            if (ruleExpMdtList.size() > 0) {
              ruleExpQryConfig = (RuleExpQueryConfig) System.JSON.deserialize(
                ruleExpMdtList[0].QryJsn__c,
              RuleExpQueryConfig.class
                );
            }
            
            //   List<RuleExpQueryConfig> ruleExpQryConfigList = new  List<RuleExpQueryConfig> ();
            //  ruleExpQryConfigList = ( List<RuleExpQueryConfig>) JSON.deserialize(ruleExpMdt.QryJsn__c ,RuleExpQueryConfig.class);
            // system.debug('ruleExpQryConfigList size::'+ ruleExpQryConfig.size());
            system.debug('ruleExpQryConfigList  ::' + ruleExpQryConfig);
            string loanId = loanAppId;
            Map<String, Object> qryBind = new Map<String, Object>();
            recordByObj = new Map<String, List<sObject>>();
            qryBind.put('loanId', loanAppId);
            if(ruleExpQryConfig.queryConfig.size()>0){
              for (queryConfig qConfig : ruleExpQryConfig.queryConfig) {
                List<sObject> qryResult = Database.queryWithBinds(
                  qConfig.queryStr,
                qryBind,
                AccessLevel.SYSTEM_MODE
                  );
                recordByObj.put(qConfig.objectName, qryResult);
              }
            }
            system.debug('recordByObj' + recordByObj);
            list<Applicant__c> coApplicants = new List<Applicant__c>();
            List<Applicant__c> primaryApplicant = new List<Applicant__c>();
            
            if (recordByObj.get('Applicant__c').size() > 0) {
              list<Applicant__c> applicantList = recordByObj.get('Applicant__c');
              
              for (Applicant__c app : applicantList) {
                Responce respObj = new Responce();
                if (
                  (app.Is_Physical_Consent_Validated__c == false &&
                  app.OTP_Verified__c == false)
                ) {
                  respObj.errorMessage = 'Mobile Consent is Not Provided ';
                  respObj.missingValue = 'Is_Physical_Consent_Validated__c , OTP_Verified__c';
                  // respObj.missingSubDocValue = '';
                  respObj.validated = false;
                  respObj.missingDoc = false;
                  respObj.applicantName = app.TabName__c;
                  respObjList.add(respObj);
                }
                //LAK-9230
                if (!app.Applicant_Addresses__r.isEmpty()) {
                  integer isMainGstCount = 0;
                  Responce respObj1 = new Responce();
                  Set<String> pinCode = new Set<String>();
                  for (ApplAddr__c appAdd : app.Applicant_Addresses__r) {
                    if (appAdd.MailAddr__c == true) {
                      isMainGstCount = isMainGstCount + 1;
                    }
                    if(appAdd.Pincode__c != null){
                      pinCode.add(appAdd.Pincode__c);
                    }
                  }
                  
                  List<PincodeMstr__c> pinCodeMstr = [SELECT ID FROM PincodeMstr__c WHERE PIN__C IN :pinCode];
                  
                  respObj1.validated = false;
                  respObj1.missingDoc = false;
                  respObj1.applicantName = app.TabName__c;
                  if (isMainGstCount == 0) {
                    respObj1.errorMessage = 'Please select at least one address as mailing address';
                    respObj1.missingValue = 'MailAddr__c';
                    respObjList.add(respObj1);
                  } else if (isMainGstCount > 1) {
                    respObj1.errorMessage = 'Please select only one address as mailing address';
                    respObj1.missingValue = 'MailAddr__c';
                    respObjList.add(respObj1);
                  }
                  else if(pinCode.size() != pinCodeMstr.size()){
                    respObj1.errorMessage = 'Please get the Selected Pincode updated in Master. Contact Admin';
                    respObj1.missingValue = 'Pincode__c';
                    respObjList.add(respObj1);
                  }
                }
                if (app.ApplType__c == 'P') {
                  
                  primaryApplicant.add(app);
                  if((product == 'Business Loan' || product =='Personal Loan' ) && app.ConsentType__c != null && app.ConsentType__c == 'Digital Consent' ){
                    boolean fieldMissingForRef = false;
                    
                    if(recordByObj.get('Ref__c') != null && recordByObj.get('Ref__c').size() > 0){
                      
                      list<Ref__c> refList = new List<Ref__c>();
                      refList = recordByObj.get('Ref__c');
                      System.debug('reference detail filds check  refList = '+ refList);
                      for (Ref__c ref : refList) {
                        System.debug('reference detail filds check  = '+ ref);
                        if(ref.FName__c == null || ref.FName__c == '' ||
                          ref.RelationWthApp__c == null ||  ref.RelationWthApp__c == '' ||
                          ref.AddrLine1__c == null || ref.AddrLine1__c == '' ||
                          ref.AddrLine2__c == null  || ref.AddrLine2__c == '' ||
                          ref.HouseNo__c == null ||  ref.HouseNo__c == '' ||
                          ref.City__c == null ||  ref.City__c == '' ||
                        ref.ContactNo__c == null ){
                          
                          fieldMissingForRef = true;
                        }
                      }
                      if(fieldMissingForRef == true){
                        Responce respObj2 = new Responce();
                        respObj2.validated = false;
                        respObj2.missingDoc = false;
                        respObj2.applicantName = app.TabName__c;
                        respObj2.errorMessage = ' Mandatory fields on References details are not entered. Please complete all required fields.';
                        respObj2.missingValue = 'Ref__c';
                        respObjList.add(respObj2);
                      }
                    }
                    if(recordByObj.get('Ref__c') != null && recordByObj.get('Ref__c').size() < 2  ){
                      Responce respObj1 = new Responce();
                      respObj1.validated = false;
                      respObj1.missingDoc = false;
                      respObj1.applicantName = app.TabName__c;
                      respObj1.errorMessage = 'For digital consent, at least two references must be added.' ;
                      respObj1.missingValue = 'Ref__c';
                      respObjList.add(respObj1);
                    }
                    
                  }
                  
                } else {
                  coApplicants.add(app);
                }
                
                //LAK-4952 -(OTP consent validation) Changes made by Prasanna Kawle
                Map<String, DocDtl__c> docDetailMap = new Map<String, DocDtl__c>();
                for (DocDtl__c doc : app.Applicant_Document_Details__r) {
                  docDetailMap.put(doc.DocTyp__c, doc);
                }
                
                if (!app.Applicant_KYC__r.isEmpty()) {
                  boolean passConsentError = true;
                  list<ApplKyc__c> appKYCList = new List<ApplKyc__c>();
                  appKYCList = app.Applicant_KYC__r;
                  for (ApplKyc__c appKYC : appKYCList) {
                    if (appKYC.kycDoc__c == GlobalConstants.AadhaarVariable) {
                      if (
                        appKYC.ValidationStatus__c !=
                        GlobalConstants.AadhaarValidatedVariable &&
                        !docDetailMap.containsKey(
                        GlobalConstants.AadhaarConsentVariable
                        )
                      ) {
                        passConsentError = false;
                        break;
                      }
                    }
                  }
                  // if (
                  //   !(app.LoanAppln__r.Stage__c == 'QDE' &&
                  //   app.LoanAppln__r.SubStage__c == 'RM Data Entry')
                  // ) {}//removed for https://fedfina.atlassian.net/browse/LAK-6007
                  if (!passConsentError) {
                    Responce respObj2 = new Responce();
                    respObj2.errorMessage = GlobalConstants.AadhaarConsentError;
                    respObj2.missingValue = '';
                    // respObj.missingSubDocValue = '';
                    respObj2.validated = false;
                    respObj2.missingDoc = false;
                    respObj2.applicantName = app.TabName__c;
                    respObjList.add(respObj2);
                  }
                  
                }
                //LAK-4952
                
                //LAK-4925 (Interest Waiver Taken) Dhananjay Gadekar
                if (app.ApplType__c == 'P') {
                  boolean waiverDocError = true;
                  
                  if (
                    app.LoanAppln__r.InterestWaiverTaken__c == 'Y' &&
                    !(docDetailMap.containsKey(GlobalConstants.WaiverDocumentType))
                  ) {
                    waiverDocError = false;
                  }
                  
                  if (
                    app.LoanAppln__r.Stage__c != null &&
                    (app.LoanAppln__r.Stage__c == 'Post Sanction' ||
                    app.LoanAppln__r.Stage__c == 'Disbursement Initiation' ||
                    app.LoanAppln__r.Stage__c == 'Disbursed')
                  ) {
                    if (!waiverDocError) {
                      Responce respObj3 = new Responce();
                      respObj3.errorMessage = GlobalConstants.WaiverDocumentError;
                      respObj3.missingValue = '';
                      respObj3.validated = false;
                      respObj3.missingDoc = false;
                      respObj3.applicantName = app.TabName__c;
                      respObjList.add(respObj3);
                    }
                  }
                }
                //LAK-4925
              }
            }
            if (recordByObj.get('LoanAppl__c').size() > 0) {
              list<sObject> loanAppl = recordByObj.get('LoanAppl__c');
            }
            system.debug('coApplicants' + coApplicants.size() + coApplicants);
            system.debug('primaryApplicant' + primaryApplicant);
            List<StageValidationConfig> stageValidationList = new List<StageValidationConfig>();
            system.debug('scConfigList size ::' + screenConfigList.size());
            for (Sobject scConfig : screenConfigList) {
              // system.debug('scConfig.stageValidationConfig__c  main'+ scConfig.stageValidationConfig__c);
              if (scConfig.get('stageValidationConfig__c') != null) {
                system.debug('scConfig.stageValidationConfig__c  is not  null'+ scConfig.get('stageValidationConfig__c'));
                StageValidationConfig stageValidation = new StageValidationConfig();
                stageValidation = (StageValidationConfig) System.JSON.deserialize(
                  String.valueOf(scConfig.get('stageValidationConfig__c')),
                StageValidationConfig.class
                  );
                stageValidationList.add(stageValidation);
              }
            }
            system.debug('stageValidationList  size' + stageValidationList.size());
            DocumentEngine docEng = new DocumentEngine(loanAppId);
            for (StageValidationConfig stageValidation : stageValidationList) {
              // main work on screen config validation starts.
              string errorMsz = (string) stageValidation.errorMessage;
              List<Applicant__c> applicantsToProcess;
              System.debug('applicantType==' + stageValidation.applicantType);
              if (stageValidation.applicantType == null) {
                applicantsToProcess = primaryApplicant;
              } else if (stageValidation.applicantType == 'Applicant') {
                system.debug(
                  'tageValidation.applicantType  is == ' +
                  stageValidation.applicantType
                  );
                applicantsToProcess = primaryApplicant;
              } else if (stageValidation.applicantType == 'CoApplicant') {
                applicantsToProcess = coApplicants;
              } else if (stageValidation.applicantType == 'All') {
                applicantsToProcess = recordByObj.get('Applicant__c');
              }
              
              System.debug('applicantsToProcess==' + applicantsToProcess.size());
              
              for (Applicant__c appl : applicantsToProcess) {
                string applName = appl.TabName__c;
                Map<string, string> bindings = new Map<string, string>();
                if (
                  stageValidation.criteriaFields != null &&
                  stageValidation.criteriaFields.size() > 0
                ) {
                  for (string creteria : stageValidation.criteriaFields) {
                    String value = appl.get(creteria.trim()) != null
                      ? (String) appl.get(creteria.trim())
                      : 'blank';
                    // value = value.replaceAll('\\s+', '');
                    value = removeSpecialCharactor(value);
                    bindings.put(creteria.trim().toLowerCase(), value);
                  }
                }
                if (stageValidation.docConfigList != null) {
                  Responce respObj = new Responce();
                  string productType = product;
                  string docConfigStage = stage;
                  string docConfigSubStage = subStage;
                  
                  // string productType = stageValidation.docConfigList.productType;
                  // string docConfigStage = stageValidation.docConfigList.stage;
                  // string docConfigSubStage = stageValidation.docConfigList.subStage;
                  
                  list<string> categoriesList = stageValidation.docConfigList.docCat;
                  list<string> missingDocList = new List<string>();
                  Map<String, List<String>> missingDocListMap = new Map<String, List<String>>();
                  System.debug(
                    'stageValidation.docConfigList != null  ==' +
                    appl.Id +
                    ':::' +
                    loanAppId +
                    ':::' +
                    productType +
                    ':::' +
                    docConfigStage +
                    ':::' +
                    docConfigSubStage +
                    ':::' +
                    categoriesList
                    );
                  // missingDocList = DocumentEngine.evalAllRequiredDocs(
                  // missingDocListMap = DocumentEngine.evalAllRequiredDocsAdd(
                  //     appl.Id,
                  //     loanAppId,
                  //     productType,
                  //     docConfigStage,
                  //     docConfigSubStage,
                  //     categoriesList
                  // );
                  // if (missingDocListMap != null) {
                    //     System.debug(
                    //         'missingDocList   ===  ' + missingDocListMap
                    //     );
                    //     System.debug(
                    //         'missingDocList size ===  ' +
                    //         missingDocListMap.size()
                    //     );
                    //     respObj.errorMessage = errorMsz;
                    //     string missingDocListStr = '';
                    //     for (
                    //         string missingDocStr : missingDocListMap.keySet()
                    //     ) {
                      //         missingDocListStr =
                      //             missingDocStr +
                      //             ' , ' +
                      //             missingDocListStr;
                    //     }
                    //     missingDocListStr = missingDocListStr.removeEnd(
                    //         ' , '
                    //     );
                    //     respObj.missingValue = missingDocListStr;
                    //     respObj.missingSubDocValue = missingDocListMap;
                    //     respObj.validated = false;
                    //     respObj.missingDoc = true;
                    //     respObj.applicantName = applName;
                    //     respObjList.add(respObj);
                    
                    //     System.debug(
                    //         'Added In respObjList  for  missingDocList ===  ' +
                    //             respObjList.size() +
                    //             respObjList
                    //     );
                  // }
                  List<String> errors = DocumentEngineController.evalAllRequiredDocs(
                    docEng,
                  appl.Id,
                  loanAppId,
                  productType,
                  docConfigStage,
                  docConfigSubStage,
                  categoriesList
                    );
                  if (errors != null && errors.size() > 0) {
                    for (string error : errors) {
                      Responce responseNew = new Responce();
                      responseNew.errorMessage = error;
                      responseNew.validated = false;
                      responseNew.missingDoc = false;
                      responseNew.applicantName = applName;
                      respObjList.add(responseNew);
                    }
                  }
                } else if (stageValidation.reqConfigList != null) {
                  Responce respObjForValidation = new Responce();
                  respObjForValidation.missingDoc = false;
                  // Responce respObj = new Responce();
                  respObjForValidation = ValidateRequiredFieldsAndDoc.getValidationErrorBasedOnAppTypenObjName(
                    errorMsz,
                  stageValidation.reqConfigList,
                  appl,
                  bindings
                    );
                  if (!respObjForValidation.validated) {
                    respObjForValidation.applicantName = applName;
                    respObjList.add(respObjForValidation);
                    System.debug(
                      'Added In respObjList  for  ValidateRequiredFieldsAndDoc ===  ' +
                      respObjForValidation.missingValue +
                      ' ::: ' +
                      respObjList.size()
                      );
                    // for( Responce respOb  : respObjList){
                      //     System.debug('Added In respObjList for  ValidateRequiredFieldsAndDoc  : :: ' + respOb.missingValue);
                      
                    // }
                  }
                }
                
              }
            }
            //respObj.validated = true;
          } catch (Exception ex) {
            system.debug('error occured ' + respObjList);
            system.debug(
              'error message is ' + ex.getMessage() + 'line no ' + ex.getLineNumber()
              );
            // GlobalUtility.logMessage('Error', 'ValidateRequiredFieldsAndDoc' + ex.getLineNumber(),
            // 'Generate', null, null, ex.getMessage() + ' Line: ' + ex.getLineNumber(), null, ex, null);
            throw new AuraHandledException(ex.getMessage());
          }
          
          System.debug(
            'Added In respObjList  Final Before Return ===  ' +
            respObjList.size() +
            respObjList
            );
          for (Responce respObj : respObjList) {
            System.debug('Added In respObjList : :: ' + respObj.missingValue);
          }
          if (respObjList.size() == 0) {
            List<string> panValidationresp = new List<string>();
            panValidationresp = PanValidationCheck.getPanValidationStatus(loanAppId);
            if (panValidationresp.size() > 0) {
              for (string valResp : panValidationresp) {
                Responce respObjNoerror = new Responce();
                respObjNoerror.validated = false;
                respObjNoerror.applicantName = valResp;
                respObjNoerror.errorMessage = 'Pan is Invalid, Kindly Enter Correct PAN Details';
                respObjList.add(respObjNoerror);
              }
            } else {
              Responce respObjNoerror = new Responce();
              respObjNoerror.validated = true;
              respObjList.add(respObjNoerror);
            }
          }
          Map<string, string > panError  = new Map<string, string > ();
          panError = DocumentDetailController.checkPanNoStatus(recordByObj.get('Applicant__c'));
          
          if(!panError.isEmpty()){
            for (string err : panError.keySet()) {
              Responce respObjNoerror = new Responce();
              respObjNoerror.validated = false;
              respObjNoerror.applicantName = err;
              respObjNoerror.errorMessage = panError.get(err);
              respObjList.add(respObjNoerror);
              // errors.add(err);
            }
          }
          if(loanAppRecord != null && loanAppRecord.Stage__c == 'Post Sanction'){
            list<DocDtl__c> ddListForEleBill =  new list<DocDtl__c>();
            ddListForEleBill = [SELECT Id, Name, LAN__c,Appl__c,Appl__r.FullName__c,DocSubTyp__c, IsLatest__c,DocTyp__c,Expiry_Date__c,IsDeleted__c FROM DocDtl__c Where  LAN__c =: loanAppId AND  DocSubTyp__c = 'Electricity Bill' AND IsDeleted__c = false AND IsLatest__c = TRUE AND  Expiry_Date__c < Today];
            for (DocDtl__c doc :ddListForEleBill) {
              System.debug( ' electricity bill date '+ doc );
              if(doc.DocSubTyp__c == GlobalConstants.Verification_Name_Electricity_Bill ){// shek
                Responce respObj2 = new Responce();
                respObj2.errorMessage = GlobalConstants.Verification_Name_Electricity_Bill + ' is Expired ';
                respObj2.missingValue = '';
                // respObj.missingSubDocValue = '';
                respObj2.validated = false;
                respObj2.missingDoc = false;
                respObj2.applicantName = doc.Appl__r.FullName__c;
                respObjList.add(respObj2);
              }
              
            }
          }
          // LAK-9762
          List<BRE__c> breResults = [SELECT Id,LoanAppl__c,  Decision__c ,CreatedDate FROM BRE__c  WHERE  LoanAppl__c =:loanAppId order by CreatedDate desc limit 1];
          string breStatus = '';
          if(!breResults.isEmpty()){
            breStatus = breResults[0].Decision__c;
          }
          if(breStatus =='Hard Reject'  ){
            Responce respObj2 = new Responce();
            respObj2.errorMessage = 'Loan Application is Hard Reject';
            respObj2.missingValue = '';
            //  respObj.missingSubDocValue = 'Lon Application ';
            respObj2.validated = false;
            respObj2.missingDoc = false;
            respObj2.applicantName ='Loan Application';
            respObjList.add(respObj2);
            
            
          }
          
          list<Responce> respObjDup = new List<Responce>();
          respObjDup = DocumentDetailController.findDuplicateDocs(loanAppId);
          respObjList.addAll(respObjDup);
          return respObjList;
        }
        
        private static Responce getValidationErrorBasedOnAppTypenObjName(
          string errorMsz,
        list<ReqConfigList> reqConfigList,
        Applicant__c appToProcess,
        Map<string, string> bindings
        ) {
          Responce respObj = new Responce();
          respObj.validated = true;
          respObj.missingDoc = false;
          for (ReqConfigList reqConfig : reqConfigList) {
            String errorMessage = errorMsz;
            Set<String> reqRcordTypes = new Set<String>();
            Set<String> otherReqRecTypes = new Set<String>();
            Set<String> availableRecTypes = new Set<String>();
            Set<String> availableOtherRecTypes = new Set<String>();
            System.debug('respObj.errorMessage==' + respObj);
            if (respObj.errorMessage != null) {
              break;
            }
            system.debug(
              'getValidationErrorBasedOnAppTypenObjName  ' + reqConfig.objectName
              );
            
            List<Sobject> recordsToProcess = new List<Sobject>();
            if (reqConfig.objectName != null && reqConfig.childRelationName != null) {
              if (reqConfig.objectName == 'Applicant__c') {
                recordsToProcess = appToProcess.getSobjects(
                  reqConfig.childRelationName
                  );
              } else {
                recordsToProcess = recordByObj.get(reqConfig.objectName).size() > 0
                  ? recordByObj.get(reqConfig.objectName)[0]
                  .getSobjects(reqConfig.childRelationName)
                  : null;
              }
            } else if (
            reqConfig.objectName != null &&
              reqConfig.objectName == 'Applicant__c'
            ) {
              recordsToProcess.add(appToProcess);
            } else if (
            reqConfig.objectName != null &&
              reqConfig.objectName == 'LoanAppl__c'
            ) {
              recordsToProcess.addAll(recordByObj.get('LoanAppl__c'));
            }
            
            ReqRecordsCriteria reqRecCriteria = reqConfig.reqRecordsCriteria;
            if (recordsToProcess != null && recordsToProcess.size() > 0) {
              String recordField;
              if (reqRecCriteria != null) {
                recordField = reqRecCriteria.recordField;
                for (CriteriaObj criObj : reqRecCriteria.criteriaList) {
                  Boolean retVal = true;
                  if (criObj.criteria != null) {
                    Rule r = new Rule().setExpression(criObj.criteria);
                    system.debug('rrr' + r);
                    system.debug('bindings' + bindings);
                    retVal = r.eval(bindings);
                  }
                  
                  if (retVal) {
                    reqRcordTypes.addAll(criObj.reqRecTypes);
                    if (
                      criObj.otherReqRecTypes != null &&
                      criObj.otherReqRecTypes.size() > 0
                    ) {
                      otherReqRecTypes.addAll(criObj.otherReqRecTypes);
                    }
                  }
                }
              }
              
              for (Sobject record : recordsToProcess) {
                if (recordField != null) {
                  String recType = (String) record.get(recordField);
                  if (reqRcordTypes.contains(recType)) {
                    availableRecTypes.add(recType);
                  } else if (otherReqRecTypes.contains(recType)) {
                    availableOtherRecTypes.add(recType);
                  }
                }
                System.debug('respObj.errorMessage==' + respObj);
                if (respObj.errorMessage != null) {
                  break;
                }
                if (
                  reqConfig!=null && reqConfig.criteriaFields != null &&
                  reqConfig.criteriaFields.size() > 0
                ) {
                  for (string creteria : reqConfig.criteriaFields) {
                    //LAK-8841
                    List<String> splitVal = creteria!=null ? creteria.trim().split('\\.') : new List<String>();
                    String value = '';
                    if(splitVal!=null && !splitVal.isEmpty()){
                      if (splitVal.size() == 1) {
                        value = record.get(splitVal[0]) != null
                          ? (String) record.get(splitVal[0])
                          : 'blank';
                      } else if (splitVal.size() == 2) {
                        if(record.getSobject(splitVal[0]) !=null){
                          value = record.getSobject(splitVal[0]).get(splitVal[1]) != null
                            ? (String) record.getSobject(splitVal[0]).get(splitVal[1])
                            : 'blank';
                        }else{
                          value ='blank';
                        }
                        
                      }
                    }
                    
                    // String value = record.get(creteria.trim()) != null
                    //     ? (String) record.get(creteria.trim())
                    //     : 'test';
                    //value = value.replaceAll('\\s+', '');
                    // value = value.replaceAll('\\(', '');
                    //value = value.replaceAll('\\)', '');
                    //value = value.replaceAll('\\-', '');
                    //value = value.replaceAll('\\_', '');
                    value = removeSpecialCharactor(value);
                    bindings.put(creteria.trim().toLowerCase(), value);
                  }
                }
                for (FieldDetails fielDetail : reqConfig.fieldDetails) {
                  system.debug(
                    'fielDetail  ' +
                    fielDetail.criteria +
                    'fielDetail.fieldApi' +
                    fielDetail.fieldApi
                    );
                  if (fielDetail.criteria == null) {
                    object dataAvailable = record.get(fielDetail.fieldApi);
                    system.debug('dataAvailable ==  ' + dataAvailable);
                    if (dataAvailable == null || dataAvailable == '') {
                      system.debug('return Initiated   ' + errorMsz);
                      respObj.errorMessage = fielDetail.errorMessage != null
                        ? fielDetail.errorMessage
                        : errorMsz;
                      //respObj.applicantName =(string) sobjRecord.get('TabName__c');
                      // respObj.missingValue = missingDoc;
                      respObj.missingValue = (string) fielDetail.fieldApi;
                      respObj.validated = false;
                      break;
                    }
                  } else {
                    Rule r = new Rule().setExpression(fielDetail.criteria);
                    system.debug('rrr' + r);
                    system.debug('bindings' + bindings);
                    
                    Boolean retVal = r.eval(bindings);
                    if (retVal) {
                      object dataAvailable = record.get(fielDetail.fieldApi);
                      system.debug(
                        'fielDetail.criteria == null ' + fielDetail.criteria
                        );
                      if (dataAvailable == null || dataAvailable == '') {
                        system.debug('return Initiated   ' + errorMsz);
                        respObj.errorMessage = fielDetail.errorMessage != null
                          ? fielDetail.errorMessage
                          : errorMsz;
                        //respObj.applicantName =(string) sobjRecord.get('TabName__c') ;
                        respObj.missingValue = (string) fielDetail.fieldApi;
                        respObj.validated = false;
                        
                        break;
                      }
                    }
                  }
                }
              }
            } else {
              Boolean requiredRecord = true;
              if (reqConfig.requiredRecordCri != null) {
                Rule r = new Rule().setExpression(reqConfig.requiredRecordCri);
                requiredRecord = r.eval(bindings);
              }
              
              if (
                !requiredRecord ||
                (reqConfig.objectName != null &&
                reqConfig.childRelationName != null &&
                reqConfig.childRelationName == 'Applicant_Employments__r' &&
                (appToProcess.CustProfile__c == 'OTHERS' ||
                appToProcess.CustProfile__c == 'HOUSEWIFE'))
              ) {
                respObj.validated = true;
              } else {
                respObj.errorMessage = (string) errorMsz;
                respObj.missingValue = ' :: Mandatory Records Missing';
                //respObj.applicantName =(string) sobjRecord.get('TabName__c');
                respObj.validated = false;
              }
              break;
            }
            
            // Boolean customCheck = false;
            // system.debug(
            //     'reqRecCriteria.criteriaList 360' +
            //     JSON.serializePretty(reqRecCriteria)
            // );
            // if (reqRecCriteria != null) {
              //     for (CriteriaObj criObj : reqRecCriteria.criteriaList) {
                //         if (
                //             criObj.isCustomAddressTypeSelection != null &&
                //             criObj.isCustomAddressTypeSelection
                //         ) {
                  //             customCheck = criObj.isCustomAddressTypeSelection;
                  //             break;
                //         }
              //     }
            // }
            
            // if(customCheck){
              //     // check if reqConfig values are passed through a wrapper class.
              //     if ((availableRecTypes.contains('Principal place for business') && availableRecTypes.contains('Residence Address')) || (availableRecTypes.contains('Residence Cum office'))) {
                
              //     } else {
                //         respObj.errorMessage = (string) errorMsz;
                //         respObj.missingValue = ' :: Test Mandatory Records Missing';
                //         respObj.validated = false;
                //         break;
              //     }
            // }else{
              //     if(reqRcordTypes.size() != availableRecTypes.size()) {
                //         respObj.errorMessage = (string) errorMsz;
                //         respObj.missingValue = ' :: Some Mandatory Records Missing';
                //         //respObj.applicantName =(string) sobjRecord.get('TabName__c');
                //         respObj.validated = false;
                //         break;
              //     }
            // }
            if (
              reqRcordTypes.size() != availableRecTypes.size() &&
              (otherReqRecTypes.size() != availableOtherRecTypes.size() ||
              otherReqRecTypes.size() == 0)
            ) {
              respObj.errorMessage = (string) errorMsz;
              respObj.missingValue = ' :: Some Mandatory Records Missing';
              //respObj.applicantName =(string) sobjRecord.get('TabName__c');
              respObj.validated = false;
              break;
            }
          }
          return respObj;
        }
        
        private static string removeSpecialCharactor(string value) {
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
        
        public class RuleExpQueryConfig {
          @AuraEnabled
          public QueryConfig[] queryConfig { get; set; }
        }
        public class QueryConfig {
          @AuraEnabled
          public String objectName { get; set; }
          @AuraEnabled
          public String queryStr { get; set; }
        }
        
        ///   ////
        public class StageValidationConfig {
          public String applicantType; //Applicant
          public DocConfigObj docConfigList;
          public string[] criteriaFields;
          public String errorMessage; //Mandatory fields on Applicant details not entered. Please provide all required information.
          public ReqConfigList[] reqConfigList;
        }
        public class ReqConfigList {
          public String objectName; //Applicant__c
          public string childRelationName;
          public string[] criteriaFields;
          public String requiredRecordCri;
          public FieldDetails[] fieldDetails;
          public String errorMessage;
          public ReqRecordsCriteria reqRecordsCriteria;
        }
        public class FieldDetails {
          public String fieldApi; //Relationship__c
          public string criteria;
          public String errorMessage;
        }
        
        public class ReqRecordsCriteria {
          public String recordField; //Relationship__c
          public List<CriteriaObj> criteriaList;
        }
        public class CriteriaObj {
          public String criteria; //Relationship__c
          public string[] reqRecTypes;
          public string[] otherReqRecTypes;
          public Boolean isCustomAddressTypeSelection;
        }
        public class DocConfigObj {
          public string[] docCat;
          public String productType;
          public String stage;
          public String subStage;
        }
        public class Responce {
          @AuraEnabled
          public string applicantName { get; set; }
          @AuraEnabled
          public string errorMessage { get; set; }
          @AuraEnabled
          public boolean validated { get; set; }
          @AuraEnabled
          public string missingValue { get; set; }
          @AuraEnabled
          public boolean missingDoc { get; set; }
          @AuraEnabled
          public Map<String, List<String>> missingSubDocValue { get; set; }
        }
      }
      // {
        //     "applicantType": "Applicant",
        //     "docConfigList": {
          //       "docCat": [
          //         "KYC Documents",
          //         "PAN Documents"
          //       ],
          //       "productType": "Home Loan",
          //       "stage": "QDE",
          //       "subStage": "RM Data Capture"
        //     },
        //     "errorMessage": "Mandatory documents for PAN & KYC should be uploaded. Please upload the necessary documents.",
        //     "criteriaFields": null,
        //     "reqConfigList": null
      //   }
      
      //             map<string,StageValidationConfig> stageValidationConfigMap = new map<string,StageValidationConfig>();
      //             string mainQry  =  'SELECT Id , Type__c ' ;
      //             for(ScrConfig__mdt scConfig : screenConfigMdtList ){
        //                 system.debug('scConfig ::::'+ screenConfigMdtList.stageValidationConfig__c);
        //                 if(scConfig.stageValidationConfig__c !=null){
          
          //                     List<StageValidationConfig> stgConfigList = new List<StageValidationConfig>;
          //                     stgConfig = ( List<StageValidationConfig>) JSON.deserialize(scConfig.stageValidationConfig__c ,StageValidationConfig.class);
          //                     stageValidationConfigMap.put(scConfig.Stage_API_Name__c, stgConfig);
          //                     //  objectName ,objectApiName,relationName, condition , requiredFields
          //                     if(stgConfig.objectApiName == 'Applicant__c'){
            //                         for( FieldDetails field : stgConfig.fieldDetails){
              //                             mainQry +=' , ' + field.fieldApi ;
              
            //                         }
          //                     }else{
            //                         String chilsQry = ' , ( SELECT Id  ' ;
            //                         for( FieldDetails field : stgConfig.fieldDetails){
              //                             chilsQry +=' , ' + field.fieldApi ;
              
            //                         }
            //                         chilsQry +=' FROM ' +  stgConfig.relationName ;
            //                         if(stgConfig.condition != null && stgConfig.condition != ''){
              //                             chilsQry +=' WHERE  ' +  stgConfig.condition;
            //                         }
            
            //                         chilsQry += ' ) ';
            //                         mainQry += chilsQry;
            
            //                         // query += ' FROM ' +  childObject;
            //                         // query += ' WHERE ' + parentFieldName + ' = ' + '\'' + recordId +'\'';
            
            //                         // system.debug(query);
          //                     }
        //                 }
        
      //             }
      //             mainQry += '  From Applicant__c where loanAppl__c = : loanAppId AND Id = : applicantId';
      //             system.debug('mainQry  '+ mainQry);
      //             mainQry1 = mainQry;
      //             list<SObject> subjectToVreifyList = new list<SObject>();
      //             subjectToVreifyList = Database.query(mainQry);
      //             system.debug('subjectToVreifyList  '+ subjectToVreifyList);
      //             list<ErrorInValidation> errorInValidationList = new list<ErrorInValidation> ();
      
      //             for(SObject verifyObj :subjectToVreifyList){
        //                 for(ScrConfig__mdt scConfig : scConfigList ){
          //                     if(verifyObj.get('Type__c')  == 'Co-Applicant' ){
            //                         if(scConfig.stageValidationConfig__c !=null && scConfig.Available_For_CoApplicant__c == true){
              //                             system.debug('test  under  76 condition ' +  scConfig.stageValidationConfig__c  !=null +'  ::  '+scConfig.Available_For_CoApplicant__c );
              //                             StageValidationConfig stageConfig =  new StageValidationConfig();
              //                             stageConfig = stageValidationConfigMap.get(scConfig.Stage_API_Name__c);
              //                             if(stageConfig.objectApiName == 'Applicant__c'){
                //                                 ErrorInValidation  errorInValidation = new ErrorInValidation();
                //                                 errorInValidation.objectName = stageConfig.objectName;
                //                                 // stage Configuration
                //                                 errorInValidation.stageName = 'Co-Applicant Details';
                //                                 errorInValidation.stageLabel = scConfig.Stage_Name__c;
                //                                 errorInValidation.stageLabelApi = scConfig.Stage_API_Name__c;
                //                                 errorInValidation.stageApiName = 'Co_Applicant_Details';
                
                //                                 //scConfig.Stage_API_Name__c;
                //                                 errorInValidation.missingRecord = '';
                //                                 list<string> missingFields = new  list<string>();
                //                                // system.debug('test  under  applicant obj');
                
                //                                 for( FieldDetails field : stageConfig.fieldDetails){
                  //                                     system.debug('test  under  field  '  + field);
                  //                                     if(field.controllingField == null){
                    //                                         if(stageConfig.relationName == 'loanAppl__r'){
                      //                                             string fld = field.fieldApi.remove(stageConfig.relationName+'.');
                      //                                             if(verifyObj.getSobject(stageConfig.relationName).get(fld) == null){
                        //                                                 missingFields.add( '    '+field.fieldLabel);
                        //                                                 system.debug('test  under  adding field label 94  ' + field.fieldLabel );
                      //                                             }
                    //                                         }
                    //                                         else if(verifyObj.get(field.fieldApi) == null){
                      
                      //                                             missingFields.add( '    '+field.fieldLabel);
                      //                                             system.debug('test  under  adding field label 97  ' + field.fieldLabel );
                    //                                         }
                    
                  //                                     }else{
                    //                                         if(  field.controllingValues.contains((string)verifyObj.get(field.controllingField))){
                      //                                             if(stageConfig.relationName == 'loanAppl__r'){
                        //                                                 string fld = field.fieldApi.remove(stageConfig.relationName+'.');
                        //                                                 if(verifyObj.getSobject(stageConfig.relationName).get(fld) == null){
                          //                                                     missingFields.add( '    '+field.fieldLabel);
                          //                                                     finalSatus.validationSatus =  false;
                          //                                                     system.debug('test  under  adding field label 109 ' + field.fieldLabel );
                        //                                                 }
                      //                                             }
                      //                                             else if(verifyObj.get(field.fieldApi) == null){
                        //                                                 missingFields.add( '    '+field.fieldLabel);
                        //                                                 finalSatus.validationSatus =  false;
                        //                                                 system.debug('test  under  adding field label 114 ' + field.fieldLabel );
                      //                                             }
                    //                                         }
                  //                                     }
                //                                 }
                //                                 system.debug('errorInValidation 120 '+ errorInValidation);
                //                                 system.debug('missingValueInFields applicant'+ missingFields);
                //                                 errorInValidation.missingValueInFields = missingFields ;
                //                                 errorInValidationList.add(errorInValidation);
                //                                 system.debug('error fields in  applicant'+ errorInValidationList);
              //                             }else{
                //                                 system.debug('else statge '+ stageConfig.objectApiName);
                //                                 ErrorInValidation  errorInValidation = new ErrorInValidation();
                //                                 errorInValidation.objectName = stageConfig.objectName;
                //                                  // stage Configuration
                //                                 errorInValidation.stageName = 'Co-Applicant Details';
                //                                 errorInValidation.stageLabel = scConfig.Stage_Name__c;
                //                                 errorInValidation.stageLabelApi = scConfig.Stage_API_Name__c;
                //                                 errorInValidation.stageApiName = 'Co_Applicant_Details';//scConfig.Stage_API_Name__c;
                
                //                                 errorInValidation.missingRecord = '';
                //                                 list<string> missingFields = new  list<string>();
                //                                 list<sObject> childObjList =  new list<sObject> ();
                
                //                                 system.debug('else statge childObj '+ childObjList);
                //                                 system.debug('else statge relationName '+ stageConfig.relationName);
                //                                 childObjList = verifyObj.getSobjects(stageConfig.relationName);
                //                                 system.debug('else statge childObj   record :: ' + childObjList);
                //                                 if(childObjList == null){
                  //                                     system.debug('else statge childObj   null found :: ');
                  //                                     errorInValidation.missingRecord =  stageConfig.objectName + ' Not Found';
                  //                                    // missingFields.add( '    '+ stageConfig.objectName + ' Not Found');
                //                                 }else {
                  //                                     for(sObject childObj :childObjList){
                    //                                         for( FieldDetails field : stageConfig.fieldDetails){
                      //                                             if(field.controllingField == null){
                        //                                                 if((childObj.get(field.fieldApi) == null) ){
                          //                                                     missingFields.add( '    '+field.fieldLabel);
                          //                                                     finalSatus.validationSatus =  false;
                          //                                                     system.debug('test  under  adding field label 145  ' + field.fieldLabel );
                        //                                                 }
                      //                                             }else{
                        //                                                 if(  field.controllingValues.contains((string)childObj.get(field.controllingField))){
                          //                                                     if((childObj.get(field.fieldApi) == null )){
                            //                                                         missingFields.add( '    '+field.fieldLabel);
                            //                                                         finalSatus.validationSatus =  false;
                            //                                                         system.debug('test  under  adding field label 151  ' + field.fieldLabel );
                          //                                                     }
                        //                                                 }
                      //                                             }
                    //                                         }
                  //                                     }
                  
                //                                 }
                //                                 system.debug('errorInValidation 161 '+ errorInValidation);
                //                                 system.debug('missingValueInFields rest'+ missingFields);
                //                                 errorInValidation.missingValueInFields = missingFields ;
                //                                 errorInValidationList.add(errorInValidation);
                
              //                             }
            //                         }
          //                     }else if(verifyObj.get('Type__c')  == 'Applicant'){
            //                         if(scConfig.stageValidationConfig__c !=null ){
              //                             system.debug('test  under  76 condition ' +  scConfig.stageValidationConfig__c  !=null +'  ::  '+scConfig.Available_For_CoApplicant__c );
              //                             StageValidationConfig stageConfig =  new StageValidationConfig();
              //                             stageConfig = stageValidationConfigMap.get(scConfig.Stage_API_Name__c);
              //                             if(stageConfig.objectApiName == 'Applicant__c'){
                //                                 ErrorInValidation  errorInValidation = new ErrorInValidation();
                //                                 errorInValidation.objectName = stageConfig.objectName;
                //                                 // stage Configuration
                //                                 errorInValidation.stageName = scConfig.Stage_Name__c;
                //                                 errorInValidation.stageLabel = scConfig.Stage_Name__c;
                //                                 errorInValidation.stageLabelApi = scConfig.Stage_API_Name__c;
                //                                 errorInValidation.stageApiName = scConfig.Stage_API_Name__c;
                
                //                                 errorInValidation.missingRecord = '';
                //                                 list<string> missingFields = new  list<string>();
                //                                // system.debug('test  under  applicant obj');
                
                //                                 for( FieldDetails field : stageConfig.fieldDetails){
                  //                                     system.debug('test  under  field  '  + field);
                  //                                     if(field.controllingField == null){
                    //                                         if(stageConfig.relationName == 'loanAppl__r'){
                      //                                             string fld = field.fieldApi.remove(stageConfig.relationName+'.');
                      //                                             if(verifyObj.getSobject(stageConfig.relationName).get(fld) == null){
                        //                                                 missingFields.add( '    '+field.fieldLabel);
                        //                                                 finalSatus.validationSatus =  false;
                        //                                                 system.debug('test  under  adding field label 94  ' + field.fieldLabel );
                      //                                             }
                    //                                         }
                    //                                         else if(verifyObj.get(field.fieldApi) == null){
                      
                      //                                             missingFields.add( '    '+field.fieldLabel);
                      //                                             finalSatus.validationSatus =  false;
                      //                                             system.debug('test  under  adding field label 97  ' + field.fieldLabel );
                    //                                         }
                    
                  //                                     }else{
                    //                                         if(  field.controllingValues.contains((string)verifyObj.get(field.controllingField))){
                      //                                             if(stageConfig.relationName == 'loanAppl__r'){
                        //                                                 string fld = field.fieldApi.remove(stageConfig.relationName+'.');
                        //                                                 if(verifyObj.getSobject(stageConfig.relationName).get(fld) == null){
                          //                                                     missingFields.add( '    '+field.fieldLabel);
                          //                                                     finalSatus.validationSatus =  false;
                          //                                                     system.debug('test  under  adding field label 109 ' + field.fieldLabel );
                        //                                                 }
                      //                                             }
                      //                                             else if(verifyObj.get(field.fieldApi) == null){
                        //                                                 missingFields.add( '    '+field.fieldLabel);
                        //                                                 finalSatus.validationSatus =  false;
                        //                                                 system.debug('test  under  adding field label 114 ' + field.fieldLabel );
                      //                                             }
                    //                                         }
                  //                                     }
                //                                 }
                //                                 system.debug('errorInValidation 120 '+ errorInValidation);
                //                                 system.debug('missingValueInFields applicant'+ missingFields);
                //                                 errorInValidation.missingValueInFields = missingFields ;
                //                                 errorInValidationList.add(errorInValidation);
                //                                 system.debug('error fields in  applicant'+ errorInValidationList);
              //                             }else{
                //                                 system.debug('else statge '+ stageConfig.objectApiName);
                //                                 ErrorInValidation  errorInValidation = new ErrorInValidation();
                //                                 errorInValidation.objectName = stageConfig.objectName;
                //                                 // stage Configuration
                //                                 errorInValidation.stageName = scConfig.Stage_Name__c;
                //                                 errorInValidation.stageLabel = scConfig.Stage_Name__c;
                //                                 errorInValidation.stageLabelApi = scConfig.Stage_API_Name__c;
                //                                 errorInValidation.stageApiName = scConfig.Stage_API_Name__c;
                
                //                                 errorInValidation.missingRecord = '';
                //                                 list<string> missingFields = new  list<string>();
                //                                 list<sObject> childObjList =  new list<sObject> ();
                
                //                                 system.debug('else statge childObj '+ childObjList);
                //                                 system.debug('else statge relationName '+ stageConfig.relationName);
                //                                 childObjList = verifyObj.getSobjects(stageConfig.relationName);
                //                                 system.debug('else statge childObj   record :: ' + childObjList);
                //                                 if(childObjList == null){
                  //                                     system.debug('else statge childObj   null found :: ');
                  //                                     errorInValidation.missingRecord =  stageConfig.objectName + ' Not Found';
                  //                                    // missingFields.add( '    '+ stageConfig.objectName + ' Not Found');
                //                                 }else {
                  //                                     for(sObject childObj :childObjList){
                    //                                         for( FieldDetails field : stageConfig.fieldDetails){
                      //                                             if(field.controllingField == null){
                        //                                                 if((childObj.get(field.fieldApi) == null) ){
                          //                                                     missingFields.add( '    '+field.fieldLabel);
                          //                                                     finalSatus.validationSatus =  false;
                          //                                                     system.debug('test  under  adding field label 145  ' + field.fieldLabel );
                        //                                                 }
                      //                                             }else{
                        //                                                 if(  field.controllingValues.contains((string)childObj.get(field.controllingField))){
                          //                                                     if((childObj.get(field.fieldApi) == null )){
                            //                                                         missingFields.add( '    '+field.fieldLabel);
                            //                                                         finalSatus.validationSatus =  false;
                            //                                                         system.debug('test  under  adding field label 151  ' + field.fieldLabel );
                          //                                                     }
                        //                                                 }
                      //                                             }
                    //                                         }
                  //                                     }
                  
                //                                 }
                //                                 system.debug('errorInValidation 161 '+ errorInValidation);
                //                                 system.debug('missingValueInFields rest'+ missingFields);
                //                                 errorInValidation.missingValueInFields = missingFields ;
                //                                 errorInValidationList.add(errorInValidation);
                
              //                             }
            //                         }
          //                     }
        //                 }
        
      //             }
      //             system.debug('final return missingValueInFields errorInValidationList'+ errorInValidationList);
      //             system.debug('final return missingValueInFields errorInValidationList'+ errorInValidationList.size());
      //             finalSatus.errorInValidation =  errorInValidationList;
      //             return finalSatus;
    //         } catch (Exception e) {
      //             system.debug('message' + e.getMessage()+'  line no ::'+ e.getLineNumber() +'  query '+ mainQry1);
      //             throw new AuraHandledException('message' + e.getMessage()+'  line no ::'+ e.getLineNumber() +'  query '+ mainQry1 );
    //         }
  //     }
// }
//     public class StageValidationConfig {
  //         @AuraEnabled
  //         public String objectName { get; set; }
  //         @AuraEnabled
  //         public String objectApiName { get; set; }
  //         @AuraEnabled
  //         public String errorMessage { get; set; }
  //         @AuraEnabled
  //         public String relationName { get; set; }
  //         @AuraEnabled
  //         public String condition { get; set; }
  //         @AuraEnabled
  //         public List<String> requiredFields { get; set; }
  //         @AuraEnabled
  //         public List<FieldDetails> fieldDetails { get; set; }
  
//     }
//     public class ErrorInValidation {
  //         @AuraEnabled
  //         public String objectName { get; set; }
  //         @AuraEnabled
  //         public String stageLabel { get; set; }
  //         @AuraEnabled
  //         public String stageLabelApi { get; set; }
  //         @AuraEnabled
  //         public String stageName { get; set; }
  //         @AuraEnabled
  //         public String stageApiName { get; set; }
  //         @AuraEnabled
  //         public String missingRecord  { get; set; }
  //         @AuraEnabled
  //         public List<String> missingValueInFields { get; set; }
  
//     }
//     public class FieldDetails {
  //         @AuraEnabled
  //         public String fieldLabel { get; set; }
  //         @AuraEnabled
  //         public String fieldApi { get; set; }
  //         @AuraEnabled
  //         public list<string> controllingValues { get; set; }
  //         @AuraEnabled
  //         public String controllingField { get; set; }
  
//     }
//     public class ValidationStatue {
  //         @AuraEnabled
  //         public boolean validationSatus { get; set; }
  //         @AuraEnabled
  //         public List<ErrorInValidation> errorInValidation { get; set; }
//     }