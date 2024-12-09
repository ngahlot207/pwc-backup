public class CloneInProgPdTechCVDataController {
    
    @AuraEnabled
    public static String cloneInProgPdTechCVDataMethod(CloneInProWrpr inputData){
        try {
            String errorMsg ;
            
            if(inputData != null){
                Map<Id, Id> appWithOldIdMap = new Map<Id, Id>();
                Map<Id, Id> pdExstIdMap = new Map<Id, Id>();
                Map<Id, Id> pdOldIdMap = new Map<Id, Id>();
                Map<Id, Id> docDtlWithOldIdMap = new Map<Id, Id>();
                Map<Id, Id> docDtlOldIdMap = new Map<Id, Id>();
                Map<Id, Id> appAssetWithOldIdMap = new Map<Id, Id>();
                Map<Id, Id> appIncomeWithOldMap = new Map<Id, Id>();
                Map<Id, Id> refOldIdMap = new Map<Id, Id>();
                Map<Id, Id> caseOldIdMap = new Map<Id, Id>();
                Map<Id, Id> caseNewMap = new Map<Id, Id>();
                Map<Id, Id> appAddrsWithOldIdMap = new Map<Id, Id>();
                List<ContentDocumentLink> newContentDocLinks = new List<ContentDocumentLink>();
                
                List<SObject> recordsToClone = new List<SObject>();
                
                LoanAppl__c loanApp = [SELECT Id,ClonedFor__c,ClonedForLAN__c,(SELECT Id, ClonedSource__c FROM Cases__r WHERE RecordType.Name IN ('Collateral Visit','Technical')) FROM LoanAppl__c WHERE Id = : inputData.loanAppId];
                
                if (
                    loanApp != null &&
                    loanApp.Cases__r != null &&
                    !loanApp.Cases__r.isEmpty()
                ) {
                    for (Case cas : loanApp.Cases__r) {
                        caseOldIdMap.put(cas.ClonedSource__c, cas.Id);
                    }
                }
                
                if(loanApp != null && loanApp.ClonedFor__c != null){
                    List<Applicant__c> applicants = [
                        SELECT
                        Id,
                        ClonedFor__c,
                        (SELECT Id, ClonedSource__c FROM Applicant_Assets__r),
                        (SELECT Id, ClonedSource__c FROM Applicant_Income__r),
                        (SELECT Id, ClonedSource__c FROM Applicant_Document_Details__r),
                        (SELECT Id, ClonedSource__c FROM Applicant_Addresses__r),
                        (SELECT Id,ClonedSource__c FROM Personal_Discussions__r WHERE PDStatus__c ='Completed')
                        FROM Applicant__c
                        WHERE
                        LoanAppln__c = :inputData.loanAppId
                        AND ApplType__c IN ('P', 'C', 'G')
                    ];
                    if (!applicants.isEmpty()) {
                        for (Applicant__c applicant : applicants) {
                            appWithOldIdMap.put(applicant.ClonedFor__c, applicant.Id);
                            if (!applicant.Applicant_Assets__r.isEmpty()) {
                                for (ApplAsset__c appAsset : applicant.Applicant_Assets__r) {
                                    appAssetWithOldIdMap.put(
                                        appAsset.ClonedSource__c,
                                        appAsset.Id
                                    );
                                }
                            }
                            if (!applicant.Applicant_Addresses__r.isEmpty()) {
                                for (ApplAddr__c appAddrss : applicant.Applicant_Addresses__r) {
                                    appAddrsWithOldIdMap.put(appAddrss.ClonedSource__c, appAddrss.Id);
                                }
                            }
                            if (!applicant.Personal_Discussions__r.isEmpty()) {
                                for (PD__c pd : applicant.Personal_Discussions__r) {
                                    pdExstIdMap.put(pd.ClonedSource__c, pd.Id);
                                }
                            }
                            if (!applicant.Applicant_Document_Details__r.isEmpty()) {
                                for (DocDtl__c docDtl : applicant.Applicant_Document_Details__r) {
                                    docDtlWithOldIdMap.put(docDtl.ClonedSource__c, docDtl.Id);
                                }
                            }
                            if (!applicant.Applicant_Income__r.isEmpty()) {
                                for (Applicant_Income__c appIncome : applicant.Applicant_Income__r) {
                                    appIncomeWithOldMap.put(
                                        appIncome.ClonedSource__c,
                                        appIncome.Id
                                    );
                                }
                            }
                        }
                    }
                    
                    if(inputData.cloneFor != null && inputData.cloneFor == 'PD'){
                        CloneMetadataUtility.CloneMtdUtilityWrpr returnDat = CloneMetadataUtility.getCloneStatus(
                            'PD',
                            'BT + Top Up'
                        );
                        
                        Set<Id> appIds = appWithOldIdMap.keyset();
                        String appIdsString =
                            '(\'' +
                            String.join(new List<Id>(appIds), '\',\'') +
                            '\')';
                        Set<Id> pdIds =  pdExstIdMap.keyset();
                        String pdIdsString =
                            '(\'' +
                            String.join(new List<Id>(pdIds), '\',\'') +
                            '\')';
                        String pdQuery =
                            'SELECT ' +
                            returnDat.fields +
                            ' FROM PD__c WHERE Appl__c IN ' +
                            appIdsString +
                            ' AND PDStatus__c = \'Completed\' AND ID NOT IN ' +
                            pdIdsString +
                            '';
                        System.debug('pdQuery ==>> ' + pdQuery);
                        
                        List<PD__c> pdRecords = Database.query(pdQuery);
                        if (!pdRecords.isEmpty()) {
                            for (PD__c pd : pdRecords) {
                                PD__c clonedpd = pd.clone(false, true, false, false);
                                clonedpd.Appl__c = pd.Appl__c != null
                                    ? appWithOldIdMap.get(pd.Appl__c)
                                    : null;
                                clonedpd.LoanAppl__c = inputData.loanAppId;
                                clonedpd.ClonedSource__c = pd.Id;
                                recordsToClone.add(clonedpd);
                            }
                        }else{
                            errorMsg = 'error';
                        }
                        
                        if (!recordsToClone.isEmpty()) {
                            insert recordsToClone;
                            for (Integer i = 0; i < recordsToClone.size(); i++) {
                                // if (pdSaveResults[i].isSuccess()) {
                                pdOldIdMap.put(pdRecords[i].Id, recordsToClone[i].Id);
                                // }
                            }
                            errorMsg = 'Success';
                            recordsToClone.clear();
                        }
                        if(!pdOldIdMap.keyset().isEmpty()){
                            List<Ref__c> references = [SELECT Id,RelationWthApp__c,RelationshipWthApp__c,Title__c,Add__c,Applicant__c,Comments__c,ContactNo__c,FName__c,Loan_Application__c,PrsnlDis__c FROM Ref__c WHERE Loan_Application__c =: loanApp.ClonedFor__c AND PrsnlDis__c IN :pdOldIdMap.keyset()];
                            if(!references.isEmpty()){
                                for(Ref__c ref : references){
                                    Ref__c clonedRef = ref.clone(false, true, false, false);
                                    clonedRef.Applicant__c = ref.Applicant__c != null
                                        ? appWithOldIdMap.get(ref.Applicant__c)
                                        : null;
                                    clonedRef.PrsnlDis__c = ref.PrsnlDis__c != null
                                        ? pdOldIdMap.get(ref.PrsnlDis__c)
                                        : null;
                                    clonedRef.Loan_Application__c = inputData.loanAppId;
                                    //clonedpd.ClonedSource__c = ref.Id;
                                    recordsToClone.add(clonedRef);
                                }
                                if(!recordsToClone.isEmpty()){
                                    insert recordsToClone;
                                    for (Integer i = 0; i < recordsToClone.size(); i++) {
                                        refOldIdMap.put(references[i].Id, recordsToClone[i].Id);
                                    }
                                    recordsToClone.clear();
                                }
                            }
                            List<PDResp__c> pDResList = [SELECT Id, PrsnlDisc__c, PDQues__c,PDQues__r.RespTyp__c, Ques__c, Resp__c, Cmnt__c, DocDtl__c FROM PDResp__c WHERE PrsnlDisc__c IN : pdOldIdMap.keyset()];
                            if(!pDResList.isEmpty()){
                                for(PDResp__c pdRes : pDResList){
                                    PDResp__c clonedPdResp = pdRes.clone(false, true, false, false);
                                    if(pdRes.PDQues__r.RespTyp__c != null && pdRes.PDQues__r.RespTyp__c == 'Reference'){
                                        clonedPdResp.Resp__c = pdRes.Resp__c != null
                                            ? refOldIdMap.get(pdRes.Resp__c)
                                            : pdRes.Resp__c;
                                    }
                                    clonedPdResp.PrsnlDisc__c = pdRes.PrsnlDisc__c != null
                                        ? pdOldIdMap.get(pdRes.PrsnlDisc__c)
                                        : null;
                                    clonedPdResp.DocDtl__c = (pdRes.DocDtl__c != null && docDtlWithOldIdMap.get(pdRes.DocDtl__c) != null)
                                        ? docDtlWithOldIdMap.get(pdRes.DocDtl__c)
                                        : pdRes.DocDtl__c;
                                    recordsToClone.add(clonedPdResp);
                                }
                            }
                            List<PDPrtcpnts__c> pDResDtlList = [SELECT Id, PD__c,Assigned_Date__c,User__c FROM PDPrtcpnts__c WHERE PD__c IN : pdOldIdMap.keyset()];
                            if(!pDResDtlList.isEmpty()){
                                for(PDPrtcpnts__c pdResPart : pDResDtlList){
                                    PDPrtcpnts__c clonedPdRespPart = pdResPart.clone(false, true, false, false);
                                    clonedPdRespPart.PD__c = pdResPart.PD__c != null
                                        ? pdOldIdMap.get(pdResPart.PD__c)
                                        : null;
                                    recordsToClone.add(clonedPdRespPart);
                                }
                            }
                            //LAK-9869
                            List<ApplExpense__c> applExpenses = [SELECT Id, ApplInc__c,ExpAmt__c,ExpType__c,PrsnlDis__c,RecordTypeId FROM ApplExpense__c WHERE PrsnlDis__c IN : pdOldIdMap.keyset()];
                            
                            if(!applExpenses.isEmpty()){
                                for(ApplExpense__c appExp : applExpenses){
                                    ApplExpense__c clonedAppExp = appExp.clone(false, true, false, false);
                                    clonedAppExp.PrsnlDis__c = appExp.PrsnlDis__c != null
                                        ? pdOldIdMap.get(appExp.PrsnlDis__c)
                                        : null;
                                    clonedAppExp.ApplInc__c = appExp.ApplInc__c != null
                                        ? appIncomeWithOldMap.get(appExp.ApplInc__c)
                                        : null;
                                    recordsToClone.add(clonedAppExp);
                                }
                            }
                            
                            if (!recordsToClone.isEmpty()) {
                                insert recordsToClone;
                                recordsToClone.clear();
                            }
                        }
                        
                    } 
                    else if(inputData.cloneFor != null && inputData.cloneFor == 'CV'){
                        CloneMetadataUtility.CloneMtdUtilityWrpr returnDataN = CloneMetadataUtility.getCloneStatus(
                            'Case',
                            'BT + Top Up'
                        );
                        String recordtypeName = 'Collateral Visit';
                        String closed = 'Completed';
                        //cas.CVStatus__c == 'Completed' && cas.ApplAssetId__c != null
                        Set<Id> caseIds =  caseOldIdMap.keyset();
                        String caseIdsString =
                            '(\'' +
                            String.join(new List<Id>(caseIds), '\',\'') +
                            '\')';
                        String caseQuery =
                            'SELECT ' +
                            returnDataN.fields +
                            ',RecordType.Name FROM Case WHERE Loan_Application__c = \'' + loanApp.ClonedFor__c + '\' AND RecordType.Name = \'' + recordtypeName + '\' AND CVStatus__c = \'' + closed + '\' AND ID NOT IN ' +
                            caseIdsString +
                            '';
                        
                        system.debug('caseQuery ==>> ' + caseQuery);
                        List<Case> caseRecords = Database.query(caseQuery);
                        system.debug('caseRecords ' + caseRecords);
                        if (caseRecords != null && !caseRecords.isEmpty()) {
                            recordsToClone.clear();
                            for (Case cas : caseRecords) {
                                if(cas.RecordType.Name == 'Collateral Visit' &&
                                   cas.CVStatus__c == 'Completed' && cas.ApplAssetId__c != null){
                                       Case clonedCase = cas.clone(false, true, false, false);
                                       clonedCase.Loan_Application__c = inputData.loanAppId;
                                       clonedCase.Applicant__c = cas.Applicant__c != null
                                           ? appWithOldIdMap.get(cas.Applicant__c)
                                           : null;
                                       clonedCase.ApplAddr__c = cas.ApplAddr__c != null
                                           ? appAddrsWithOldIdMap.get(cas.ApplAddr__c)
                                           : null;
                                       clonedCase.ApplAssetId__c = cas.ApplAssetId__c != null
                                           ? appAssetWithOldIdMap.get(cas.ApplAssetId__c)
                                           : null;
                                       clonedCase.ClonedSource__c = cas.Id;
                                       recordsToClone.add(clonedCase);
                                       
                                   }
                                
                            }
                            if (!recordsToClone.isEmpty()) {
                                insert recordsToClone;
                                for (Integer i = 0; i < recordsToClone.size(); i++) {
                                    caseNewMap.put(caseRecords[i].Id, recordsToClone[i].Id);
                                }
                                errorMsg = 'Success';
                            }else{
                                errorMsg = 'error';
                            }
                            recordsToClone.clear();
                            
                            if(!caseOldIdMap.keyset().isEmpty()){
                                List<CollateralVisitJn__c> cvJunList = [SELECT Id,Case__c,DocDtl__c,PropQues__c,Question__c,Resp__c FROM CollateralVisitJn__c WHERE Case__c NOT IN : caseOldIdMap.keyset() AND Case__r.Loan_Application__c =: loanApp.ClonedFor__c];
                                if(!cvJunList.isEmpty()){
                                    for(CollateralVisitJn__c cvJun : cvJunList){
                                        CollateralVisitJn__c clonedCvJun = cvJun.clone(false, true, false, false);
                                        clonedCvJun.Case__c = cvJun.Case__c != null
                                            ? caseNewMap.get(cvJun.Case__c)
                                            : null;
                                        clonedCvJun.DocDtl__c = (cvJun.DocDtl__c != null && docDtlWithOldIdMap.get(cvJun.DocDtl__c) != null)
                                            ? docDtlWithOldIdMap.get(cvJun.DocDtl__c) 
                                            : cvJun.DocDtl__c;
                                        clonedCvJun.ClonedSource__c = cvJun.Id;
                                        recordsToClone.add(clonedCvJun);
                                    }
                                }else{
                                    errorMsg = 'error';
                                }
                                if(!recordsToClone.isEmpty()){
                                    insert recordsToClone;
                                    recordsToClone.clear();
                                    errorMsg = 'Success';
                                }else{
                                    errorMsg = 'error';
                                }
                            }
                        }else{
                            errorMsg = 'error';
                        }
                        
                        
                    }else if(inputData.cloneFor != null && inputData.cloneFor == 'Technical'){
                        CloneMetadataUtility.CloneMtdUtilityWrpr returnDataN = CloneMetadataUtility.getCloneStatus(
                            'CaseTach',
                            'BT + Top Up'
                        );
                        String recordtypeName = 'Technical';
                        String closed = 'Closed';
                        String hubLegaManaRev = 'Technical Approved';
                        Set<Id> caseIds =  caseOldIdMap.keyset();
                        String caseIdsString =
                            '(\'' +
                            String.join(new List<Id>(caseIds), '\',\'') +
                            '\')';
                        String caseQuery =
                            'SELECT ' +
                            returnDataN.fields +
                            ',RecordType.Name FROM Case WHERE Loan_Application__c = \'' + loanApp.ClonedFor__c + '\' AND RecordType.Name = \'' + recordtypeName + '\' AND Status = \'' + closed + '\' AND HubManagerReview__c = \'' + hubLegaManaRev + '\' AND ID NOT IN ' +
                            caseIdsString +
                            '';
                        
                        system.debug('caseQuery ==>> ' + caseQuery);
                        List<Case> caseRecords = Database.query(caseQuery);
                        
                        if (!caseRecords.isEmpty()) {
                            for (Case cas : caseRecords) {
                                Case clonedCase = cas.clone(false, true, false, false);
                                clonedCase.Loan_Application__c = inputData.loanAppId;
                                clonedCase.Applicant__c = cas.Applicant__c != null
                                    ? appWithOldIdMap.get(cas.Applicant__c)
                                    : null;
                                clonedCase.ApplAddr__c = cas.ApplAddr__c != null
                                    ? appAddrsWithOldIdMap.get(cas.ApplAddr__c)
                                    : null;
                                clonedCase.ApplAssetId__c = cas.ApplAssetId__c != null
                                    ? appAssetWithOldIdMap.get(cas.ApplAssetId__c)
                                    : null;
                                clonedCase.ClonedSource__c = cas.Id;
                                recordsToClone.add(clonedCase);
                                
                            }
                            if (!recordsToClone.isEmpty()) {
                                insert recordsToClone;
                                for (Integer i = 0; i < recordsToClone.size(); i++) {
                                    caseNewMap.put(caseRecords[i].Id, recordsToClone[i].Id);
                                }
                                errorMsg = 'Success';
                            }
                            recordsToClone.clear();
                            if (!appWithOldIdMap.keyset().isEmpty()) {
                                CloneMetadataUtility.CloneMtdUtilityWrpr returnDatDoc = CloneMetadataUtility.getCloneStatus(
                                    'DocDtl',
                                    'BT + Top Up'
                                );
                                List<String> docCatr = new List<String>{'Case Documents'};
                                    String docCatrs =
                                    '(\'' +
                                    String.join(new List<String>(docCatr), '\',\'') +
                                    '\')';
                                
                                Set<Id> applicantIds = appWithOldIdMap.keyset();
                                String applicantIdsString =
                                    '(\'' +
                                    String.join(new List<Id>(applicantIds), '\',\'') +
                                    '\')';
                                Set<Id> caseIdsNew =  caseOldIdMap.keyset();
                                String caseIdsStringNew =
                                    '(\'' +
                                    String.join(new List<Id>(caseIdsNew), '\',\'') +
                                    '\')'; 
                                String docDtlQuery;
                                docDtlQuery = 'SELECT ' + returnDatDoc.fields + ', PrsnlDis__r.PDStatus__c ' +
                                    'FROM DocDtl__c ' +
                                    'WHERE Appl__c IN ' + applicantIdsString +
                                    ' AND DocCatgry__c IN ' + docCatrs + ' AND Case__c NOT IN ' +
                                    caseIdsStringNew +
                                    '';
                                System.debug('docDtlQuery ==>> ' + docDtlQuery);
                                
                                List<DocDtl__c> docDtlRecrds = Database.query(docDtlQuery);
                                if (!docDtlRecrds.isEmpty()) {
                                    for (DocDtl__c docDtl : docDtlRecrds) {
                                        DocDtl__c clonedDocDtl = docDtl.clone(
                                            false,
                                            true,
                                            false,
                                            false
                                        );
                                        clonedDocDtl.LAN__c = inputData.loanAppId;
                                        clonedDocDtl.Appl__c = docDtl.Appl__c != null &&
                                            appWithOldIdMap.keyset().size() > 0
                                            ? appWithOldIdMap.get(docDtl.Appl__c)
                                            : null;
                                        clonedDocDtl.ApplAsset__c = docDtl.ApplAsset__c != null &&
                                            appAssetWithOldIdMap.keyset().size() > 0 && appAssetWithOldIdMap.get(docDtl.ApplAsset__c) != null
                                            ? appAssetWithOldIdMap.get(docDtl.ApplAsset__c)
                                            : docDtl.ApplAsset__c;
                                        clonedDocDtl.Case__c = docDtl.Case__c != null &&
                                            caseNewMap.keyset().size() > 0
                                            ? caseNewMap.get(docDtl.Case__c)
                                            : null;
                                        clonedDocDtl.ClonedSource__c = docDtl.Id;
                                        recordsToClone.add(clonedDocDtl);
                                        
                                    }
                                }
                                
                                if (!recordsToClone.isEmpty()) {
                                    MetadataTriggerHandler.bypass('ApplicantUpdate'); //LAK-8409
                                    insert recordsToClone;
                                    MetadataTriggerHandler.clearBypass('ApplicantUpdate');//LAK-8409
                                    for (Integer i = 0; i < recordsToClone.size(); i++) {
                                        docDtlOldIdMap.put(docDtlRecrds[i].Id, recordsToClone[i].Id);
                                    }
                                    recordsToClone.clear();
                                }
                                
                                if (!docDtlOldIdMap.keyset().isEmpty()) {
                                    List<ContentDocumentLink> contentDocLinks = [
                                        SELECT Id, ContentDocumentId, LinkedEntityId
                                        FROM ContentDocumentLink
                                        WHERE LinkedEntityId IN :docDtlOldIdMap.keySet()
                                    ];
                                    for (ContentDocumentLink cdl : contentDocLinks) {
                                        ContentDocumentLink newCdl = new ContentDocumentLink(
                                            ContentDocumentId = cdl.ContentDocumentId,
                                            LinkedEntityId = docDtlOldIdMap.get(cdl.LinkedEntityId)
                                        );
                                        newContentDocLinks.add(newCdl);
                                    }
                                    
                                    if (!newContentDocLinks.isEmpty()) {
                                        system.debug('newContentDocLinks ' + newContentDocLinks);
                                        insert newContentDocLinks;
                                    }
                                }
                            }
                        }else{
                            errorMsg = 'error';
                        }
                    }
                }   
            }
            return errorMsg;  
        }catch (Exception e) {
            GlobalUtility.logMessage(
                'Error',
                'CloneInProgPdTechCVDataController',
                'Process',
                null,
                null,
                e.getMessage() + ' line ' + e.getLineNumber(),
                null,
                e,
                null
            );
            throw new AuraHandledException(
                'Error during cloning process: ' + e.getMessage()
            );
        }
    }
    
    public class CloneInProWrpr {
        @AuraEnabled
        public String loanAppId { get; set; }
        @AuraEnabled
        public String cloneFor { get; set; }
        @AuraEnabled
        public String appAssetId { get; set; }
    }
}