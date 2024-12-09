public class PerfiosAAAnalysedReportResponeProcessor implements IintMsgCalloutResponseProcessor,Queueable {
    public PerfiosAAAnalysedReportResponeProcessor(){}
    public static void process(List<IntgMsg__c> responses) {
        Set<Id> ids = new Set<Id>();
        Map<Id,Id> intMsgContentDocMap = new Map<Id,Id>();
        Map<Id,contentVersion> contentVersionMap = new Map<Id,contentVersion>();
        Map<IntgMsg__c,contentVersion> xlsxResponseMap = new Map<IntgMsg__c,contentVersion>();
        //Map<Id,IntgMsg__c> intgMsgMap = new Map<Id,IntgMsg__c>();
        Map<Id,PerfiosRetrieveReportResponseWrapper> responseMap = new Map<Id,PerfiosRetrieveReportResponseWrapper>();
        List<IntgMsg__c> responseList = new List<IntgMsg__c>();
        Set<String> institutionNames = new Set<String>();
        for (IntgMsg__c integrationMessage : responses) {
            ids.add(integrationMessage.Id);
            //intgMsgMap.put(integrationMessage.Id,integrationMessage);
        }
        
        for(ContentDocumentLink contentDoc : [SELECT LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :ids]){
            intMsgContentDocMap.put(contentDoc.LinkedEntityId,contentDoc.ContentDocumentId);
        }
        
        if(!intMsgContentDocMap.isEmpty()){
            for(ContentVersion ver : [SELECT Id,Title,ContentDocumentId, VersionData,FileType,FileExtension FROM ContentVersion WHERE ContentDocumentId IN: intMsgContentDocMap.values()]){
                contentVersionMap.put(ver.ContentDocumentId,ver);
            }
        } 
        
        for(IntgMsg__c integrationMessage : responses){
            try{
                if(intMsgContentDocMap.containsKey(integrationMessage.Id) &&  contentVersionMap.containsKey(intMsgContentDocMap.get(integrationMessage.Id))){
                    
                    if(contentVersionMap.get(intMsgContentDocMap.get(integrationMessage.Id)).FileExtension=='xlsx'){
                        ContentVersion cv = new ContentVersion();
                        cv.Title = contentVersionMap.get(intMsgContentDocMap.get(integrationMessage.Id)).Title;
                        cv.PathOnClient = contentVersionMap.get(intMsgContentDocMap.get(integrationMessage.Id)).Title;
                        cv.VersionData = contentVersionMap.get(intMsgContentDocMap.get(integrationMessage.Id)).VersionData;
                        xlsxResponseMap.put(integrationMessage,cv);
                    }
                    else {
                        String jsonResponse = contentVersionMap.get(intMsgContentDocMap.get(integrationMessage.Id)).VersionData.toString();
                        PerfiosRetrieveReportResponseWrapper response = (PerfiosRetrieveReportResponseWrapper) JSON.deserialize(jsonResponse.replace('date','PerfiosDate').replace('group','PerfiosGroup'), PerfiosRetrieveReportResponseWrapper.class);
                        
                        if(response!=null){
                            
                            if(integrationMessage.RefId__c!=null){
                                responseMap.put(integrationMessage.RefId__c,response);
                                responseList.add(integrationMessage);
                            }
                            if(!response.accountAnalysis.isEmpty()){
                                for(PerfiosRetrieveReportResponseWrapper.AccountAnalysis analysis : response.accountAnalysis){
                                    if(analysis.summaryInfo!=null && analysis.summaryInfo.instName!=null && String.isNotBlank(analysis.summaryInfo.instName)){
                                        institutionNames.add(analysis.summaryInfo.instName.substringBeforeLast(',').removeEnd('.'));
                                    }
                                }
                            }
                        }
                    }
                }
            }
            catch(Exception ex){
                GlobalUtility.logMessage('Error', 'PerfiosAAAnalysedReportResponeProcessor class', 
                                         'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
        }
        
        if(!xlsxResponseMap.isEmpty()){
            processxlsxResponses(xlsxResponseMap);
        }
        
        if(!responseList.isEmpty() && !responseMap.isEmpty()){
            processResponses(responseList,responseMap,institutionNames);
        }
    }
    
    public void execute(QueueableContext context){
        try{
            
            if(!accountNumberMap.isEmpty() && !accountWiseDataMap.isEmpty()){
                processAccountWiseResponses(appBankList,monthlyApplBankmap,accountNumberMap,accountWiseDataMap);
            }
            
            if(!applicantIds.isEmpty()){
                PerfiosRetrieveReportResponseProcessor.upsertApplicantBankingSummary(applicantIds);
            }
            if(!loanApplicationIds.isEmpty()){
                PerfiosRetrieveReportResponseProcessor.upsertConsolidatedBankingSummary(loanApplicationIds);
            }
        }
        catch(exception ex){
            system.debug('Line Number: ' + ex.getLineNumber() + ' Error Message: ' + ex.getMessage());
            GlobalUtility.logMessage('Error', 'PerfiosAAAnalysedReportResponeProcessor class', 
                                         'execute', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
    }
    
    public PerfiosAAAnalysedReportResponeProcessor(Set<Id> applicantIds, Set<Id> loanApplicationIds, List<ApplBanking__c> appBankList, Map<Id,Map<String,Id>> monthlyApplBankmap, Map<String,Map<Integer,String>> accountNumberMap, Map<String,Map<Integer,AccountWiseDataWrapper>> accountWiseDataMap){
        this.applicantIds = applicantIds;
        this.loanApplicationIds = loanApplicationIds;
        this.appBankList = appBankList;
        this.monthlyApplBankmap = monthlyApplBankmap;
        this.accountNumberMap = accountNumberMap;
        this.accountWiseDataMap = accountWiseDataMap;
        
    }
    
    public static void processxlsxResponses(Map<IntgMsg__c,contentVersion> xlsxResponseMap){
        try{ 
            if(!xlsxResponseMap.isEmpty()){
                
                Map<IntgMsg__c,DocDtl__c> intgMsgDocDtlMap = new Map<IntgMsg__c,DocDtl__c>();
                Map<Id,Id> idDocDtlMap = new Map<Id,Id>();
                Set<Id> existingRecordIds = new Set<Id>();
                
                for(IntgMsg__c intg: xlsxResponseMap.keySet()){
                    if(intg.RefId__c!=null && intg.RefObj__c =='Applicant__c' && intg.ParentRefId__c!=null && intg.ParentRefObj__c=='LoanAppl__c'){
                        DocDtl__c doc = new DocDtl__c();
                        doc.Appl__c = intg.RefId__c;
                        doc.LAN__c = intg.ParentRefId__c;
                        doc.DocCatgry__c = 'Perfios Report';
                        doc.DocTyp__c = 'Perfios Report';
                        doc.DocSubTyp__c = 'Perfios Account Aggregator Report';
                        doc.IsLatest__c = true;
                        doc.ReferenceId__c = intg.Id;
                        intgMsgDocDtlMap.put(intg,doc);
                        existingRecordIds.add(intg.RefId__c);
                    }
                }
                
                if(!existingRecordIds.isEmpty()){
                    List<DocDtl__c> existingDocDtlRecords = new List<DocDtl__c>([SELECT ID,DocCatgry__c, DocTyp__c, DocSubTyp__c,Appl__c,IsLatest__c FROM DocDtl__c WHERE Appl__c IN:existingRecordIds AND DocCatgry__c='Perfios Report' AND DocTyp__c ='Perfios Account Aggregator Report' AND IsLatest__c =true]);
                    if(!existingDocDtlRecords.isEmpty()){
                        IntegrationUtility.updateBooleanFlag(existingDocDtlRecords, 'IsLatest__c', false);
                    }
                }
                if(!intgMsgDocDtlMap.isEmpty()){
                    insert intgMsgDocDtlMap.values();
                    for(DocDtl__c dtl : [Select ID,ReferenceId__c FROM DocDtl__c WHERE ID IN:intgMsgDocDtlMap.values()]){
                        idDocDtlMap.put(dtl.ReferenceId__c,dtl.Id);
                    }
                }
                for(IntgMsg__c intgMsg :xlsxResponseMap.keySet()){
                    if(idDocDtlMap.containsKey(intgMsg.Id)){
                        xlsxResponseMap.get(intgMsg).FirstPublishLocationId = idDocDtlMap.get(intgMsg.Id);
                        APICalloutTracker.update_ApiTrackerWithIntMsg(intgMsg.Id,intgMsg.Svc__c, intgMsg.RefId__c, 'Success');
                    }
                }
                insert xlsxResponseMap.Values();
            }
        }
        catch(exception ex){
            system.debug('Line Number: ' + ex.getLineNumber() + ' Error Message: ' + ex.getMessage());
            GlobalUtility.logMessage('Error', 'PerfiosAAAnalysedReportResponeProcessor class', 
                                     'processxlsxResponses', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        
    }
    public static void processResponses(List<IntgMsg__c> responseList,Map<Id,PerfiosRetrieveReportResponseWrapper> responseMap,Set<String> institutionNames){
        try{
            if(!responseList.isEmpty() && !responseMap.isEmpty()){
                Map<Id,Applicant__c> applicantMap = new Map<Id,Applicant__c>([SELECT Id,LoanAppln__c,TransactionLink__c,IntegrationStatus__c,IntegrationErrorMessage__c FROM Applicant__c WHERE Id IN:responseMap.keySet()]);
                Map<Id,Map<String,ApplBanking__c>> applBankMap = new Map<Id,Map<String,ApplBanking__c>>();
                Map<Id,Map<String,Id>> monthlyApplBankmap  = new Map<Id,Map<String,Id>>();
                Set<Id> applBankingIds = new Set<Id>();
                Set<Id> applicantIds = new Set<Id>();
                Set<Id> loanApplicationIds = new Set<Id>();
                List<Applicant__c> applicantList = new List<Applicant__c>();
                List<ApplBanking__c> appBankList = new List<ApplBanking__c>();
                //List<ApplBankDetail__c> appBankDetialList = new List<ApplBankDetail__c>();
                Map<String,SFDCBANKMaster__c> sfdcBankMasterMap = getSFDCBankMaster(institutionNames);
                
                Map<String,Map<Integer,AccountWiseDataWrapper>> accountWiseDataMap = new Map<String,Map<Integer,AccountWiseDataWrapper>>();
                Map<String,Map<Integer,String>> accountNumberMap = new Map<String,Map<Integer,String>>();
                
                for(ApplBanking__c applbank : [SELECT Id,AC_No__c,Appl__c,LoanAppl__c FROM ApplBanking__c WHERE Appl__c IN:responseMap.keySet()]){
                    applBankingIds.add(applbank.Id);
                    if(applBankMap.containsKey(applbank.Appl__c)){
                        applBankMap.get(applbank.Appl__c).put(applbank.AC_No__c,applbank);
                    }
                    else{
                        applBankMap.put(applbank.Appl__c,new Map<String,ApplBanking__c>{applbank.AC_No__c=>applbank});
                    }
                    
                }
                for(ApplBankDetail__c detial : [Select Id, ApplBanking__c, Year__c,Month__c from ApplBankDetail__c where ApplBanking__c IN:applBankingIds AND  Type__c IN ('','Account Analysis') AND SubType__c IN ('','Monthly Details')]){
                    if(detial.Year__c!=null && detial.Month__c!=null){
                        if(monthlyApplBankmap.containsKey(detial.ApplBanking__c)){
                            monthlyApplBankmap.get(detial.ApplBanking__c).put(detial.Month__c +'-'+detial.Year__c.right(2),detial.Id);
                        }
                        else{
                            monthlyApplBankmap.put(detial.ApplBanking__c,new Map<String,Id>{detial.Month__c +'-'+detial.Year__c.right(2)=>detial.Id});
                        }
                    }
                }
                
                for(IntgMsg__c integrationMessage: responseList){
                    if(responseMap.containsKey(integrationMessage.RefId__c)){
                        PerfiosRetrieveReportResponseWrapper response = responseMap.get(integrationMessage.RefId__c);
                        
                        if(response.error==null){
                            Applicant__c appl = new Applicant__c();
                            appl.Id = integrationMessage.RefId__c;
                            appl.Perfios_AA_Status__c = 'Success';
                            appl.IntegrationStatus__c = PerfiosAPIController.replaceAndUpdateString('Perfios AA Analysed Report:', 'Perfios AA Analysed Report: Success', applicantMap.get(integrationMessage.RefId__c).IntegrationStatus__c, ';');
                            appl.IntegrationErrorMessage__c = PerfiosAPIController.replaceAndUpdateString('Perfios AA Analysed Report', '', applicantMap.get(integrationMessage.RefId__c).IntegrationErrorMessage__c, ';');
                            applicantList.add(appl);
                            
                            if(applicantMap.containsKey(integrationMessage.RefId__c)){
                                if(applicantMap.get(integrationMessage.RefId__c).Id!=null){
                                    applicantIds.add(applicantMap.get(integrationMessage.RefId__c).Id);
                                }
                                if(applicantMap.get(integrationMessage.RefId__c).LoanAppln__c!=null){
                                    loanApplicationIds.add(applicantMap.get(integrationMessage.RefId__c).LoanAppln__c);
                                }
                            }
                            
                            if(response.accountAnalysis!=null && !response.accountAnalysis.isEmpty()){
                                Date startDate = !response.combinedMonthlyDetails.isEmpty() && response.combinedMonthlyDetails[0].startDate!=null && String.isNotBlank(response.combinedMonthlyDetails[0].startDate) ? PerfiosRetrieveReportResponseProcessor.getConvertedDate(response.combinedMonthlyDetails[0].startDate): null;
                                Date endDate = !response.combinedMonthlyDetails.isEmpty() && response.combinedMonthlyDetails[response.combinedMonthlyDetails.size()-1].startDate!=null && String.isNotBlank(response.combinedMonthlyDetails[response.combinedMonthlyDetails.size()-1].startDate) ? PerfiosRetrieveReportResponseProcessor.getConvertedDate(response.combinedMonthlyDetails[response.combinedMonthlyDetails.size()-1].startDate): null;
                                for(Integer i=0; i<response.accountAnalysis.size();i++){
                                        if(response.accountAnalysis[i].accountNo!=null && String.isNotBlank(response.accountAnalysis[i].accountNo)){
                                            ApplBanking__c appBank = new ApplBanking__c();
                                            if(applBankMap.containsKey(integrationMessage.RefId__c) && applBankMap.get(integrationMessage.RefId__c).containsKey(response.accountAnalysis[i].accountNo)){
                                                appBank.Id = applBankMap.get(integrationMessage.RefId__c).get(response.accountAnalysis[i].accountNo).Id;
                                            }
                                            else{
                                                appBank.Appl__c = applicantMap.get(integrationMessage.RefId__c).Id;
                                                appBank.LoanAppl__c = applicantMap.get(integrationMessage.RefId__c).LoanAppln__c;
                                                appBank.AC_No__c =   response.accountAnalysis[i].accountNo; 
                                            }
                                            if(response.accountAnalysis[i].accountType!=null && String.isNotBlank(response.accountAnalysis[i].accountType)){
                                                if(response.accountAnalysis[i].accountType.containsIgnoreCase('SAVINGS')){
                                                    appBank.AccountType__c = 'SAVINGS';
                                                }
                                                else if(response.accountAnalysis[i].accountType.containsIgnoreCase('OVERDRAFT')){
                                                    appBank.AccountType__c = 'OVERDRAFT';
                                                }
                                                else if(response.accountAnalysis[i].accountType.containsIgnoreCase('CURRENT')){
                                                    appBank.AccountType__c = 'CURRENT';
                                                }
                                                else if(response.accountAnalysis[i].accountType.containsIgnoreCase('CC') || response.accountAnalysis[i].accountType.containsIgnoreCase('CASH CREDIT')){
                                                    appBank.AccountType__c = 'CC';
                                                }
                                            }
                                            appBank.Source__c = 'Perfios';
                                            appBank.Source_Type__c = 'Account Aggregator';
                                            appBank.PeriodOfBankingStart__c = startDate;
                                            appBank.PeriodOfBankingEnd__c = endDate;
                                            if(response.customerInfo!=null){
                                                appBank.Name__c = response.customerInfo.name!=null && String.isNotBlank(response.customerInfo.name) ? response.customerInfo.name : '';
                                                appBank.Name_of_the_Primary_Account_Holder_s__c = appBank.Name__c;
                                                appBank.Address__c = response.customerInfo.address!=null && String.isNotBlank(response.customerInfo.address) ? response.customerInfo.address : '';
                                                appBank.Landline__c = response.customerInfo.landline!=null && String.isNotBlank(response.customerInfo.landline) ? response.customerInfo.landline : '';
                                                appBank.Mobile__c = response.customerInfo.mobile!=null && String.isNotBlank(response.customerInfo.mobile) ? response.customerInfo.mobile : '';
                                                appBank.Email__c = response.customerInfo.email!=null && String.isNotBlank(response.customerInfo.email) ? response.customerInfo.email : '';
                                                appBank.Pan__c = response.customerInfo.pan!=null && String.isNotBlank(response.customerInfo.pan) ? response.customerInfo.pan : '';
                                                appBank.CustomerTransactionId__c = response.customerInfo.customerTransactionId!=null && String.isNotBlank(response.customerInfo.customerTransactionId) ? response.customerInfo.customerTransactionId : '';
                                                //appBank.Perfios_BankName__c = response.customerInfo.bank!=null && String.isNotBlank(response.customerInfo.bank) ? response.customerInfo.bank : '';
                                                //appBank.Perfios_InstId__c = response.customerInfo.instId;
                                            }
                                            if(response.accountAnalysis[i].summaryInfo!=null && response.accountAnalysis[i].summaryInfo.instName!=null && String.isNotBlank(response.accountAnalysis[i].summaryInfo.instName)){
                                                appBank.Perfios_BankName__c = response.accountAnalysis[i].summaryInfo.instName;
                                                if(sfdcBankMasterMap.containsKey(response.accountAnalysis[i].summaryInfo.instName.substringBeforeLast(',').removeEnd('.'))){
                                                    appBank.Perfios_InstId__c = Integer.valueOf(sfdcBankMasterMap.get(response.accountAnalysis[i].summaryInfo.instName.substringBeforeLast(',').removeEnd('.')).InstitutionId__c);
                                                    appBank.SFDCBankMaster__c = sfdcBankMasterMap.get(response.accountAnalysis[i].summaryInfo.instName.substringBeforeLast(',').removeEnd('.')).Id;
                                                }
                                                else{
                                                    appBank.SFDCBankMaster__c = sfdcBankMasterMap.get('OTHERS').Id;
                                                    appBank.OtherBankName__c = response.accountAnalysis[i].summaryInfo.instName;
                                                }
                                            }    
                                                
                                            appBankList.add(appBank);
                                            
                                            AccountWiseDataWrapper accountData  = new AccountWiseDataWrapper();
                                            accountData.accountAnalysis = new List<PerfiosRetrieveReportResponseWrapper.AccountAnalysis>{response.accountAnalysis[i]};
                                            if(response.combinedMonthlyDetails!=null && !response.combinedMonthlyDetails.isEmpty()){
                                                accountData.combinedMonthlyDetails = response.combinedMonthlyDetails;
                                            }
                                            if(accountWiseDataMap.containsKey(integrationMessage.RefId__c)){
                                                if(!accountWiseDataMap.get(integrationMessage.RefId__c).containsKey(i)){
                                                    
                                                    accountWiseDataMap.get(integrationMessage.RefId__c).put(i,accountData);
                                                    
                                                }
                                            }
                                            else{
                                                accountWiseDataMap.put(integrationMessage.RefId__c, new Map<Integer,AccountWiseDataWrapper>{i=>accountData});
                                            }
                                            
                                            if(accountNumberMap.containsKey(integrationMessage.RefId__c)){
                                                if(!accountNumberMap.get(integrationMessage.RefId__c).containsKey(i)){
                                                    accountNumberMap.get(integrationMessage.RefId__c).put(i,response.accountAnalysis[i].accountNo);
                                                }
                                            }
                                            else{
                                                accountNumberMap.put(integrationMessage.RefId__c,new Map<Integer,String>{i =>response.accountAnalysis[i].accountNo});
                                            }
                                            
                                        }
                                    }
                            }
                            
                            if(response.accountXns!=null &&  !response.accountXns.isEmpty()){
                                for(Integer i=0; i<response.accountXns.size();i++){
                                    if(accountWiseDataMap.containsKey(integrationMessage.RefId__c) && accountWiseDataMap.get(integrationMessage.RefId__c).containskey(i)){
                                        accountWiseDataMap.get(integrationMessage.RefId__c).get(i).accountXns = new List<PerfiosRetrieveReportResponseWrapper.AccountXns>{response.accountXns[i]};
                                    }
                                }
                            }
                            
                            if(response.AdditionalBankingMonthlyDetails!=null && !response.AdditionalBankingMonthlyDetails.isEmpty()){
                                List<String> keys = new List<String>();
                                keys.addAll(response.AdditionalBankingMonthlyDetails.KeySet());
                                
                                for(Integer i=0; i<keys.size(); i++){
                                    if(accountWiseDataMap.containsKey(integrationMessage.RefId__c) && accountWiseDataMap.get(integrationMessage.RefId__c).containskey(i)){
                                        accountWiseDataMap.get(integrationMessage.RefId__c).get(i).additionalBankingMonthlyDetails = response.AdditionalBankingMonthlyDetails.get(keys[i]);
                                    }
                                }
                            }
                            
                            if(response.AdditionalFedfinaMonthlyDetails!=null && !response.AdditionalFedfinaMonthlyDetails.isEmpty()){
                                List<String> keys = new List<String>();
                                keys.addAll(response.AdditionalFedfinaMonthlyDetails.KeySet());
                                
                                for(Integer i=0; i<keys.size(); i++){
                                    if(accountWiseDataMap.containsKey(integrationMessage.RefId__c) && accountWiseDataMap.get(integrationMessage.RefId__c).containskey(i)){
                                        accountWiseDataMap.get(integrationMessage.RefId__c).get(i).additionalFedfinaMonthlyDetails = response.AdditionalFedfinaMonthlyDetails.get(keys[i]);
                                    }
                                }
                            }
                            
                            if(response.AdditionalTransactionMonthlyDetails!=null && !response.AdditionalTransactionMonthlyDetails.isEmpty()){
                                List<String> keys = new List<String>();
                                keys.addAll(response.AdditionalTransactionMonthlyDetails.KeySet());
                                
                                for(Integer i=0; i<keys.size(); i++){
                                    if(accountWiseDataMap.containsKey(integrationMessage.RefId__c) && accountWiseDataMap.get(integrationMessage.RefId__c).containskey(i)){
                                        accountWiseDataMap.get(integrationMessage.RefId__c).get(i).additionalTransactionMonthlyDetails = response.AdditionalTransactionMonthlyDetails.get(keys[i]);
                                    }
                                }
                            }
                            
                            if(response.AdditionalSummaryInfo!=null && !response.AdditionalSummaryInfo.isEmpty()){
                                List<String> keys = new List<String>();
                                keys.addAll(response.AdditionalSummaryInfo.KeySet());
                                
                                for(Integer i=0; i<keys.size(); i++){
                                    if(accountWiseDataMap.containsKey(integrationMessage.RefId__c) && accountWiseDataMap.get(integrationMessage.RefId__c).containskey(i)){
                                        accountWiseDataMap.get(integrationMessage.RefId__c).get(i).additionalSummaryInfo = response.AdditionalSummaryInfo.get(keys[i]);
                                    }
                                }
                            }
                            
                            
                            if(integrationMessage.Trigger_Platform_Event__c){
                                publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                                platformWra.intId = integrationMessage.Id; 
                                platformWra.recId = integrationMessage.RefId__c;
                                platformWra.ServiceName = integrationMessage.Svc__c ;
                                platformWra.Status = integrationMessage.Status__c ;
                                platformWra.success = True;
                                publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
                            }
                            APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Success');
                        }
                        else{
                            String errorMessage = (response.error!=null && String.isNotBlank(response.error.message)) ? response.error.message:'';
                            Applicant__c appl = new Applicant__c();
                            appl.Id = integrationMessage.RefId__c;
                            appl.Perfios_AA_Status__c = 'Failure';
                            appl.IntegrationStatus__c = PerfiosAPIController.replaceAndUpdateString('Perfios AA Analysed Report:', 'Perfios Retrieve Report: Failure', applicantMap.get(integrationMessage.RefId__c).IntegrationStatus__c, ';');
                            appl.IntegrationErrorMessage__c = PerfiosAPIController.replaceAndUpdateString('Perfios AA Analysed Report', 'Perfios AA Analysed Report: ' + errorMessage, applicantMap.get(integrationMessage.RefId__c).IntegrationErrorMessage__c, ';');
                            applicantList.add(appl);
                            if(integrationMessage.Trigger_Platform_Event__c){
                                publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                                platformWra.intId = integrationMessage.Id; 
                                platformWra.recId = integrationMessage.RefId__c;
                                platformWra.ServiceName = integrationMessage.Svc__c ;
                                platformWra.Status = integrationMessage.Status__c ;
                                platformWra.success = False;
                                platformWra.errorMessage = errorMessage;
                                publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
                            }
                            APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Failure');
                        }
                        
                    }
                }
                
                if(!applicantList.isEmpty()){
                    update applicantList;
                }
                if(!appBankList.isEmpty()){
                    upsert appBankList;
                    if(!accountNumberMap.isEmpty() && !accountWiseDataMap.isEmpty()){
                    	//processAccountWiseResponses(appBankList,monthlyApplBankmap,accountNumberMap,accountWiseDataMap);
                        PerfiosAAAnalysedReportResponeProcessor queueableInstance = new  PerfiosAAAnalysedReportResponeProcessor(applicantIds,loanApplicationIds,appBankList,monthlyApplBankmap,accountNumberMap,accountWiseDataMap);
                        System.enqueueJob(queueableInstance);
                	}
                }
                
                /*if(!applicantIds.isEmpty()){
                    PerfiosRetrieveReportResponseProcessor.upsertApplicantBankingSummary(applicantIds);
                }
                if(!loanApplicationIds.isEmpty()){
                    PerfiosRetrieveReportResponseProcessor.upsertConsolidatedBankingSummary(loanApplicationIds);
                }*/
                
            }
        }
        catch(exception ex){
            system.debug('Line Number: ' + ex.getLineNumber() + ' Error Message: ' + ex.getMessage());
            GlobalUtility.logMessage('Error', 'PerfiosAAAnalysedReportResponeProcessor class', 
                                         'processResponses', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
    }
    
    public static void processAccountWiseResponses(List<ApplBanking__c> appBankList, Map<Id,Map<String,Id>> monthlyApplBankmap , Map<String,Map<Integer,String>> accountNumberMap,Map<String,Map<Integer,AccountWiseDataWrapper>> accountWiseDataMap){
        try{
            if(!appBankList.isEmpty() && !accountNumberMap.isEmpty() && !accountWiseDataMap.isEmpty()){
                Map<Id,Map<String,ApplBanking__c>> applBankMap = new Map<Id,Map<String,ApplBanking__c>>();
                List<ApplBankDetail__c> appBankDetialList = new List<ApplBankDetail__c>();
                Set<Id> existingApplBankingIds = new Set<Id>();
                for(ApplBanking__c applbank : [SELECT Id,AC_No__c,Appl__c,LoanAppl__c FROM ApplBanking__c WHERE Id IN:appBankList]){
                    if(applBankMap.containsKey(applbank.Appl__c)){
                        applBankMap.get(applbank.Appl__c).put(applbank.AC_No__c,applbank);
                    }
                    else{
                        applBankMap.put(applbank.Appl__c,new Map<String,ApplBanking__c>{applbank.AC_No__c=>applbank});
                    }
                    
                }
                
                for(String key : accountWiseDataMap.keySet()){
                    if(applBankMap.containsKey(key)){
                        Map<Integer,AccountWiseDataWrapper> accountWiseData = accountWiseDataMap.get(key);
                        Map<Integer,String> accountNoMap = accountNumberMap.get(key);
                        
                        if(accountWiseData!=null && !accountWiseData.isEmpty()){
                            for(Integer i=0;i<accountWiseData.keySet().size(); i++){
                                if(accountNumberMap.containsKey(key) && accountNumberMap.get(key).containsKey(i) && applBankMap.containskey(key) && applBankMap.get(key).containsKey(accountNumberMap.get(key).get(i))){
                                    Id appBankingId = applBankMap.get(key).get(accountNumberMap.get(key).get(i)).Id;
									existingApplBankingIds.add(appBankingId);
                                    
                                    AccountWiseDataWrapper accData = accountWiseData.get(i);
                                    
                                    //Account Analysis
                                    if(accData.accountAnalysis!=null && !accData.accountAnalysis.isEmpty()){
                                        List<ApplBankDetail__c> accountAnalysis = PerfiosRetrieveReportResponseProcessor.processAccountAnalysis(appBankingId,accData.accountAnalysis);
                                        if(accountAnalysis!=null && !accountAnalysis.isEmpty()){
                                            appBankDetialList.addAll(accountAnalysis);
                                        }
                                        
                                        //Monthly Details
                                        PerfiosRetrieveReportResponseWrapper.AccountAnalysis analysis = accData.accountAnalysis[0];
                                        if(!analysis.monthlyDetails.isEmpty()){
                                            List<ApplBankDetail__c> monthlyDetails = PerfiosRetrieveReportResponseProcessor.processMonthlyDetails(appBankingId,analysis.accountNo,analysis.accountType,'Account Analysis', 'Monthly Details',monthlyApplBankmap,analysis.monthlyDetails,analysis.eODBalances);
                                            if(monthlyDetails!=null && !monthlyDetails.isEmpty()){
                                                appBankDetialList.addAll(monthlyDetails);
                                            }
                                        }
                                    }
                                    
                                    //Combined Monthly Details
                                    if(accData.combinedMonthlyDetails!=null && !accData.combinedMonthlyDetails.isEmpty()){
                                        for(PerfiosRetrieveReportResponseWrapper.CombinedMonthlyDetails detial : accData.combinedMonthlyDetails){
                                            ApplBankDetail__c applBankDtl = new ApplBankDetail__c();
                                            applBankDtl.ApplBanking__c = appBankingId;
                                            applBankDtl.Type__c = 'Combined Monthly Details';
                                            applBankDtl.IsLatest__c = true;
                                            applBankDtl.MonthName__c = detial.monthName!=null && String.isNotBlank(detial.monthName) ? detial.monthName : '';
                                            if(detial.startDate!=null && String.isNotBlank(detial.startDate)){
                                                applBankDtl.StartDate__c = PerfiosRetrieveReportResponseProcessor.getConvertedDate(detial.startDate);
                                            }
                                            appBankDetialList.add(applBankDtl);
                                        }
                                    }
                                    
                                    //Account Xns
                                    if(accData.accountXns!=null && !accData.accountXns.isEmpty()){
                                        List<ApplBankDetail__c> accountXns = PerfiosRetrieveReportResponseProcessor.processAccountXns(appBankingId,accData.accountXns);
                                        if(accountXns!=null && !accountXns.isEmpty()){
                                            appBankDetialList.addAll(accountXns);
                                        }
                                    }
                                    
                                    //Additional Banking Monthly Details
                                    if(accData.additionalBankingMonthlyDetails!=null && !accData.additionalBankingMonthlyDetails.isEmpty()){
                                        List<ApplBankDetail__c> monthlyData = PerfiosRetrieveReportResponseProcessor.processAdditionalBankingMonthlyDetails(appBankingId,accData.additionalBankingMonthlyDetails);
                                        if(monthlyData!=null && !monthlyData.isEmpty()){
                                            appBankDetialList.addAll(monthlyData);
                                        }   
                                    }
                                    
                                    //Additional Fedfina Monthly Details
                                    if(accData.additionalFedfinaMonthlyDetails!=null && !accData.additionalFedfinaMonthlyDetails.isEmpty()){
                                        List<ApplBankDetail__c> monthlyData = PerfiosRetrieveReportResponseProcessor.processAdditionalFedfinaMonthlyDetails(appBankingId,accData.additionalFedfinaMonthlyDetails);
                                        if(monthlyData!=null && !monthlyData.isEmpty()){
                                            appBankDetialList.addAll(monthlyData);
                                        }   
                                    }
                                    
                                    //Additional Transaction Monthly Details
                                    if(accData.additionalTransactionMonthlyDetails!=null && !accData.additionalTransactionMonthlyDetails.isEmpty()){
                                        List<ApplBankDetail__c> monthlyData = PerfiosRetrieveReportResponseProcessor.processAdditionalTransactionMonthlyDetails(appBankingId,accData.additionalTransactionMonthlyDetails);
                                        if(monthlyData!=null && !monthlyData.isEmpty()){
                                            appBankDetialList.addAll(monthlyData);
                                        }   
                                    }
                                    
                                    //Additional Summary Info
                                    if(accData.additionalSummaryInfo!=null && !accData.additionalSummaryInfo.isEmpty()){
                                        List<ApplBankDetail__c> summaryData = PerfiosRetrieveReportResponseProcessor.processAdditionalSummaryInfo(appBankingId,accData.additionalSummaryInfo);
                                        if(summaryData!=null && !summaryData.isEmpty()){
                                            appBankDetialList.addAll(summaryData);
                                        }   
                                    }
                                    
                                    
                                }
                            }
                        }
                    }
                }
                
                if(!appBankDetialList.isEmpty()){
                    upsert appBankDetialList;
                }
                
                if(!existingApplBankingIds.isEmpty()){
                    List<ApplBankDetail__c> existingApplBankDtlList = [Select Id,IsLatest__c FROM ApplBankDetail__c WHERE IsLatest__c=True AND ApplBanking__c IN :existingApplBankingIds ];
                    if(!existingApplBankDtlList.isEmpty()){
                        IntegrationUtility.updateBooleanFlag(existingApplBankDtlList, 'IsLatest__c', false);
                    }
                }
            }
        }
        catch(exception ex){
            system.debug('Line Number: ' + ex.getLineNumber() + ' Error Message: ' + ex.getMessage());
            GlobalUtility.logMessage('Error', 'PerfiosAAAnalysedReportResponeProcessor class', 
                                         'processAccountWiseResponses', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
    }
    
    public static Map<String,SFDCBANKMaster__c> getSFDCBankMaster(Set<String> institutionNames){
        Map<String,SFDCBANKMaster__c> resultMap = new Map<String,SFDCBANKMaster__c>();
        if(!institutionNames.isEmpty()){
            List<String> conditions = new List<String>();
            List<SFDCBANKMaster__c> sfdcBankMaster;
            String query = 'Select Id,BankName__c, InstitutionName__c,InstitutionId__c FROM SFDCBANKMaster__c WHERE BankName__c = \'OTHERS\'';
            for(String name : institutionNames){
                conditions.add('InstitutionName__c LIKE  \'' + name + '%\'');
            }
            if(!conditions.isEmpty()){
                query += ' OR ' + String.join(conditions, ' OR ');
            }
            sfdcBankMaster = Database.query(query);
            for(String name : institutionNames){
                for(SFDCBANKMaster__c sfdcBank : sfdcBankMaster){
                    if(sfdcBank.BankName__c.equalsIgnoreCase('OTHERS')){
                        resultMap.put('OTHERS',sfdcBank);
                    }
                    else if(sfdcBank.InstitutionName__c!=null && sfdcBank.InstitutionName__c.startsWithIgnoreCase(name) && !resultMap.containsKey(name)){
                       resultMap.put(name,sfdcBank);
                    }
                }
            }
        }
		return resultMap;
    }
    public class AccountWiseDataWrapper{
        public List<PerfiosRetrieveReportResponseWrapper.AccountAnalysis> accountAnalysis;
        public List<PerfiosRetrieveReportResponseWrapper.CombinedMonthlyDetails> combinedMonthlyDetails;
        public List<PerfiosRetrieveReportResponseWrapper.AccountXns> accountXns;
        public List<PerfiosRetrieveReportResponseWrapper.BankingMonthlyData1> additionalBankingMonthlyDetails;
        public List<PerfiosRetrieveReportResponseWrapper.FedfinaMothlyData1> additionalFedfinaMonthlyDetails;
        public List<PerfiosRetrieveReportResponseWrapper.MonthlyData1> additionalTransactionMonthlyDetails;
        public List<PerfiosRetrieveReportResponseWrapper.SummaryInfo1> additionalSummaryInfo;
    }
    
    private List<ApplBanking__c> appBankList;
    private Map<Id,Map<String,Id>> monthlyApplBankmap;
    private Map<String,Map<Integer,String>> accountNumberMap; 
    private Map<String,Map<Integer,AccountWiseDataWrapper>> accountWiseDataMap;
    private Set<Id> applicantIds;
    private Set<Id> loanApplicationIds;
  
}