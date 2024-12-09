public class PerfiosRetrieveReportResponseProcessor implements IintMsgCalloutResponseProcessor {
    
    public static void process(List<IntgMsg__c> responses) {
        Set<Id> ids = new Set<Id>();
        Map<Id,Id> intMsgContentDocMap = new Map<Id,Id>();
        Map<Id,contentVersion> contentVersionMap = new Map<Id,contentVersion>();
        Map<Id,contentVersion> xlsxcontentVersionMap = new Map<Id,contentVersion>();
        Map<Id,IntgMsg__c> intgMsgMap = new Map<Id,IntgMsg__c>();
    	//Map<Id,Blob> responseZipFileMap = new Map<Id,Blob>();
        List<IntgMsg__c> responseList = new List<IntgMsg__c>();
        Set<String> institutionIds = new Set<String>();
        
        for (IntgMsg__c integrationMessage : responses) {
            ids.add(integrationMessage.Id);
            intgMsgMap.put(integrationMessage.Id,integrationMessage);
        }
        
        for(ContentDocumentLink contentDoc : [SELECT LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :ids]){
            intMsgContentDocMap.put(contentDoc.LinkedEntityId,contentDoc.ContentDocumentId);
        }
        
        if(!intMsgContentDocMap.isEmpty()){
            for(ContentVersion ver : [SELECT Id,Title,ContentDocumentId, VersionData,FileType,FileExtension FROM ContentVersion WHERE ContentDocumentId IN: intMsgContentDocMap.values()]){
                contentVersionMap.put(ver.ContentDocumentId,ver);
            }
        } 
        
        Map<Id,PerfiosRetrieveReportResponseWrapper> responseMap = new Map<Id,PerfiosRetrieveReportResponseWrapper>();
        for(IntgMsg__c integrationMessage : responses){
            try{
                if(intMsgContentDocMap.containsKey(integrationMessage.Id) &&  contentVersionMap.containsKey(intMsgContentDocMap.get(integrationMessage.Id))){
                    
                    //if(contentVersionMap.get(intMsgContentDocMap.get(integrationMessage.Id)).FileExtension=='zip'){
                    //    responseZipFileMap.put(integrationMessage.Id,contentVersionMap.get(intMsgContentDocMap.get(integrationMessage.Id)).VersionData);
                    //}
                    if(contentVersionMap.get(intMsgContentDocMap.get(integrationMessage.Id)).FileExtension=='xlsx'){
                        ContentVersion cv = new ContentVersion();
                        cv.Title = contentVersionMap.get(intMsgContentDocMap.get(integrationMessage.Id)).Title;
                        cv.PathOnClient = contentVersionMap.get(intMsgContentDocMap.get(integrationMessage.Id)).Title;
                        cv.VersionData = contentVersionMap.get(intMsgContentDocMap.get(integrationMessage.Id)).VersionData;
                        xlsxcontentVersionMap.put(integrationMessage.Id , cv);
                    }
                    else {
                        String jsonResponse = contentVersionMap.get(intMsgContentDocMap.get(integrationMessage.Id)).VersionData.toString();
                        PerfiosRetrieveReportResponseWrapper response = (PerfiosRetrieveReportResponseWrapper) JSON.deserialize(jsonResponse.replace('date','PerfiosDate').replace('group','PerfiosGroup'), PerfiosRetrieveReportResponseWrapper.class);
                        
                        if(response!=null){
                            
                            if(integrationMessage.ParentRefId__c!=null){
                                responseMap.put(integrationMessage.ParentRefId__c,response);
                                responseList.add(integrationMessage);
                            }
                            if(response.customerInfo!=null && response.customerInfo.instId!=null){
                               institutionIds.add(String.ValueOf(response.customerInfo.instId)); 
                            }
                        }
                    }
                }
            }
            //Exception Handling
            catch(Exception ex){
                GlobalUtility.logMessage('Error', 'PerfiosRetrieveReportResponseProcessor class', 
                                         'Process', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
            }
        }
        if(!responseList.isEmpty() && !responseMap.isEmpty()){
            processResponses(responseList,responseMap,institutionIds);
        }
        
        //if(!intgMsgMap.isEmpty() && !responseZipFileMap.isEmpty()){
        //    System.enQueueJob(new PerfiosExtractZipFilesQueueable(intgMsgMap,responseZipFileMap));
        //}
        
        if(!intgMsgMap.isEmpty() && !xlsxcontentVersionMap.isEmpty()){
            insert xlsxcontentVersionMap.Values();
            createDocDtlWithContentDocumentLink(intgMsgMap,xlsxcontentVersionMap);
        }
    }
    
    public static void processResponses(List<IntgMsg__c> responseList,Map<Id,PerfiosRetrieveReportResponseWrapper> responseMap,Set<String> institutionIds){
        try{
            if(!responseList.isEmpty()){
                Map<Id,ApplBanking__c> applBankMap = new Map<Id,ApplBanking__c>([Select Id,IntegrationStatus__c,IntegrationErrorMessage__c,Appl__c,LoanAppl__c,Source_Type__c from ApplBanking__c where Id IN:responseMap.keySet()]);
                Map<Id,Map<String,Id>> monthlyApplBankmap  = new Map<Id,Map<String,Id>>();
                Map<String,SFDCBANKMaster__c> sfdcBankMasterMap = new Map<String,SFDCBANKMaster__c>();
                for(SFDCBANKMaster__c bank : [Select Id,BankName__c,InstitutionId__c from SFDCBANKMaster__c WHERE InstitutionId__c IN:institutionIds OR BankName__c='OTHERS']){
                    if(bank.BankName__c.equalsIgnoreCase('OTHERS')){
                        sfdcBankMasterMap.put('OTHERS',bank);
                    }
                    else{
                        sfdcBankMasterMap.put(bank.InstitutionId__c,bank);
                    }
                }
                Set<Id> existingApplBankingIds = new Set<Id>();
                for(ApplBankDetail__c detial : [Select Id, ApplBanking__c, Year__c,Month__c from ApplBankDetail__c where ApplBanking__c IN:responseMap.keySet() AND  Type__c IN ('','Account Analysis') AND SubType__c IN ('','Monthly Details')]){
                    if(detial.Year__c!=null && detial.Month__c!=null){
                        if(monthlyApplBankmap.containsKey(detial.ApplBanking__c)){
                            monthlyApplBankmap.get(detial.ApplBanking__c).put(detial.Month__c +'-'+detial.Year__c.right(2),detial.Id);
                        }
                        else{
                            monthlyApplBankmap.put(detial.ApplBanking__c,new Map<String,Id>{detial.Month__c +'-'+detial.Year__c.right(2)=>detial.Id});
                        }
                    }
                }
                List<ApplBanking__c> appBankList = new List<ApplBanking__c>();
                List<ApplBankDetail__c> appBankDetialList = new List<ApplBankDetail__c>();
                
                Set<Id> applicantIds = new Set<Id>();
                Set<Id> loanApplicationIds = new Set<Id>();
                
                for(IntgMsg__c integrationMessage: responseList){
                    if(responseMap.containsKey(integrationMessage.ParentRefId__c)){
                        PerfiosRetrieveReportResponseWrapper response = responseMap.get(integrationMessage.ParentRefId__c);
                        if(response.error==null){
                            ApplBanking__c appBank = new ApplBanking__c();
                            appBank.Id = integrationMessage.ParentRefId__c;
                            appBank.Initiate_Perfios_Status__c = 'Success';
                            appBank.Source__c = 'Perfios';
                            appBank.IntegrationStatus__c = PerfiosAPIController.replaceAndUpdateString('Perfios Retrieve Report: Failure', 'Perfios Retrieve Report: Success', applBankMap.get(integrationMessage.ParentRefId__c).IntegrationStatus__c, ';');
                            appBank.IntegrationErrorMessage__c = PerfiosAPIController.replaceAndUpdateString('Perfios Retrieve Report', '', applBankMap.get(integrationMessage.ParentRefId__c).IntegrationErrorMessage__c, ';');
                            
                            //2024-08-14 Eshan - LAK-6528 - Changes Start
                            if(response.customerInfo!=null){
                                appBank.Name__c = response.customerInfo.name!=null && String.isNotBlank(response.customerInfo.name) ? response.customerInfo.name : '';
                                appBank.Address__c = response.customerInfo.address!=null && String.isNotBlank(response.customerInfo.address) ? response.customerInfo.address : '';
                                appBank.Landline__c = response.customerInfo.landline!=null && String.isNotBlank(response.customerInfo.landline) ? response.customerInfo.landline : '';
                                appBank.Mobile__c = response.customerInfo.mobile!=null && String.isNotBlank(response.customerInfo.mobile) ? response.customerInfo.mobile : '';
                                appBank.Email__c = response.customerInfo.email!=null && String.isNotBlank(response.customerInfo.email) ? response.customerInfo.email : '';
                                appBank.Pan__c = response.customerInfo.pan!=null && String.isNotBlank(response.customerInfo.pan) ? response.customerInfo.pan : '';
                                appBank.CustomerTransactionId__c = response.customerInfo.customerTransactionId!=null && String.isNotBlank(response.customerInfo.customerTransactionId) ? response.customerInfo.customerTransactionId : '';
                                appBank.Perfios_BankName__c = response.customerInfo.bank!=null && String.isNotBlank(response.customerInfo.bank) ? response.customerInfo.bank : '';
                                appBank.Perfios_InstId__c = response.customerInfo.instId;
                                if(applBankMap.containsKey(integrationMessage.ParentRefId__c) && applBankMap.get(integrationMessage.ParentRefId__c).Source_Type__c == 'Fetch Online Perfios'){
                                    appBank.SFDCBankMaster__c = response.customerInfo.instId !=null && sfdcBankMasterMap.containsKey(String.valueOf(response.customerInfo.instId)) ? sfdcBankMasterMap.get(String.valueOf(response.customerInfo.instId)).Id : '';
                                    if(response.customerInfo.instId !=null && sfdcBankMasterMap.containsKey(String.valueOf(response.customerInfo.instId))){
                                        appBank.SFDCBankMaster__c = sfdcBankMasterMap.get(String.valueOf(response.customerInfo.instId)).Id;
                                    }
                                    else if(response.customerInfo.bank!=null && String.isNotBlank(response.customerInfo.bank) && sfdcBankMasterMap.containsKey('OTHERS')){
                                        appBank.SFDCBankMaster__c = sfdcBankMasterMap.get('OTHERS').Id;
                                        appBank.OtherBankName__c = response.customerInfo.bank;
                                    }
                                }
                            }
                            //2024-08-14 Eshan - LAK-6528 - Changes End
                            
                            //2024-05-28 Eshan - LAK-7611 - Changes Start
                            if(applBankMap.get(integrationMessage.ParentRefId__c).Appl__c!=null){
                                applicantIds.add(applBankMap.get(integrationMessage.ParentRefId__c).Appl__c);
                            }
                            if(applBankMap.get(integrationMessage.ParentRefId__c).LoanAppl__c!=null){
                                loanApplicationIds.add(applBankMap.get(integrationMessage.ParentRefId__c).LoanAppl__c);
                            }
                            //2024-05-28 Eshan - LAK-7611 - Changes End
                            
                            //2024-08-14 Eshan - LAK-6528 - Changes Start
                            
                            existingApplBankingIds.add(integrationMessage.ParentRefId__c);
                            
                            //Statement Details
                            if(response.statementdetails!=null && !response.statementdetails.isEmpty()){
                            	List<ApplBankDetail__c> statementDetails = processStatementDetails(integrationMessage.ParentRefId__c,response.statementdetails);
                                if(statementDetails!=null && !statementDetails.isEmpty()){
                                	appBankDetialList.addAll(statementDetails);
                            	}
                        	}
                            
                            //Account Analysis
                            if(response.accountAnalysis!=null && !response.accountAnalysis.isEmpty()){
                                List<ApplBankDetail__c> accountAnalysis = processAccountAnalysis(integrationMessage.ParentRefId__c,response.accountAnalysis);
                                if(accountAnalysis!=null && !accountAnalysis.isEmpty()){
                                	appBankDetialList.addAll(accountAnalysis);
                            	}
                            }
                            
                            //Combined Monthly Details
                            if(response.combinedMonthlyDetails!=null && !response.combinedMonthlyDetails.isEmpty()){
                                for(PerfiosRetrieveReportResponseWrapper.CombinedMonthlyDetails detial : response.combinedMonthlyDetails){
                                    ApplBankDetail__c applBankDtl = new ApplBankDetail__c();
                                    applBankDtl.ApplBanking__c = integrationMessage.ParentRefId__c;
                                    applBankDtl.Type__c = 'Combined Monthly Details';
                                    applBankDtl.IsLatest__c = true;
                                    applBankDtl.MonthName__c = detial.monthName!=null && String.isNotBlank(detial.monthName) ? detial.monthName : '';
                                    if(detial.startDate!=null && String.isNotBlank(detial.startDate)){
                                        applBankDtl.StartDate__c = getConvertedDate(detial.startDate);
                                    }
                                    appBankDetialList.add(applBankDtl);
                                }
                                if(applBankMap.containsKey(integrationMessage.ParentRefId__c) && applBankMap.get(integrationMessage.ParentRefId__c).Source_Type__c == 'Fetch Online Perfios'){
                                    appBank.PeriodOfBankingStart__c = response.combinedMonthlyDetails[0].startDate!=null && String.isNotBlank(response.combinedMonthlyDetails[0].startDate) ? getConvertedDate(response.combinedMonthlyDetails[0].startDate): null;
                                    appBank.PeriodOfBankingEnd__c = response.combinedMonthlyDetails[response.combinedMonthlyDetails.size()-1].startDate!=null && String.isNotBlank(response.combinedMonthlyDetails[response.combinedMonthlyDetails.size()-1].startDate) ? getConvertedDate(response.combinedMonthlyDetails[response.combinedMonthlyDetails.size()-1].startDate): null;
                                }
                            }
                            
                            //Account Xns
                            if(response.accountXns!=null &&  !response.accountXns.isEmpty()){
                                List<ApplBankDetail__c> accountXns = processAccountXns(integrationMessage.ParentRefId__c,response.accountXns);
                                if(accountXns!=null && !accountXns.isEmpty()){
                                	appBankDetialList.addAll(accountXns);
                            	}
                            }
                            
                            //Additional Banking Monthly Details
                            /*if(response.AdditionalBankingMonthlyDetails != null && response.AdditionalBankingMonthlyDetails.MonthlyData1!=null && !response.AdditionalBankingMonthlyDetails.MonthlyData1.isEmpty()){
                                List<ApplBankDetail__c> monthlyData = processAdditionalBankingMonthlyDetails(integrationMessage.ParentRefId__c,response.AdditionalBankingMonthlyDetails.MonthlyData1);
                                if(monthlyData!=null && !monthlyData.isEmpty()){
                                	appBankDetialList.addAll(monthlyData);
                            	}   
                                
                            }*/
                            if(response.AdditionalBankingMonthlyDetails != null){
                                List<PerfiosRetrieveReportResponseWrapper.BankingMonthlyData1> bankingMonthlyData = new List<PerfiosRetrieveReportResponseWrapper.BankingMonthlyData1>();
                                for(String key : response.AdditionalBankingMonthlyDetails.keySet()){
                                    bankingMonthlyData.addAll(response.AdditionalBankingMonthlyDetails.get(key));
                                }
                                if(!bankingMonthlyData.isEmpty()){
                                    List<ApplBankDetail__c> monthlyData = processAdditionalBankingMonthlyDetails(integrationMessage.ParentRefId__c,bankingMonthlyData);
                                    if(monthlyData!=null && !monthlyData.isEmpty()){
                                        appBankDetialList.addAll(monthlyData);
                                    }   
                                }
                            }
                            
                            
                            //Additional Fedfina Monthly Details
                            /*if(response.AdditionalFedfinaMonthlyDetails!=null && response.AdditionalFedfinaMonthlyDetails.MonthlyData1!=null && !response.AdditionalFedfinaMonthlyDetails.MonthlyData1.isEmpty()){
                                List<ApplBankDetail__c> monthlyData = processAdditionalFedfinaMonthlyDetails(integrationMessage.ParentRefId__c,response.AdditionalFedfinaMonthlyDetails.MonthlyData1);
                                if(monthlyData!=null && !monthlyData.isEmpty()){
                                    appBankDetialList.addAll(monthlyData);
                                }
                            }*/
                            if(response.AdditionalFedfinaMonthlyDetails != null){
                                List<PerfiosRetrieveReportResponseWrapper.FedfinaMothlyData1> fedinaMonthlyData = new List<PerfiosRetrieveReportResponseWrapper.FedfinaMothlyData1>();
                                for(String key : response.AdditionalFedfinaMonthlyDetails.keySet()){
                                    fedinaMonthlyData.addAll(response.AdditionalFedfinaMonthlyDetails.get(key));
                                }
                                if(!fedinaMonthlyData.isEmpty()){
                                    List<ApplBankDetail__c> monthlyData = processAdditionalFedfinaMonthlyDetails(integrationMessage.ParentRefId__c,fedinaMonthlyData);
                                    if(monthlyData!=null && !monthlyData.isEmpty()){
                                        appBankDetialList.addAll(monthlyData);
                                    }   
                                }
                            }
                            
                            
                            
                            //Additional Transaction Monthly Details
                            /*if(response.AdditionalTransactionMonthlyDetails!=null && response.AdditionalTransactionMonthlyDetails.MonthlyData1!=null && !response.AdditionalTransactionMonthlyDetails.MonthlyData1.isEmpty()){
                                List<ApplBankDetail__c> monthlyData = processAdditionalTransactionMonthlyDetails(integrationMessage.ParentRefId__c,response.AdditionalTransactionMonthlyDetails.MonthlyData1);
                                if(monthlyData!=null && !monthlyData.isEmpty()){
                                	appBankDetialList.addAll(monthlyData);
                                }
                            }*/
                            if(response.AdditionalTransactionMonthlyDetails != null){
                                List<PerfiosRetrieveReportResponseWrapper.MonthlyData1> transactionMonthlyData = new List<PerfiosRetrieveReportResponseWrapper.MonthlyData1>();
                                for(String key : response.AdditionalTransactionMonthlyDetails.keySet()){
                                    transactionMonthlyData.addAll(response.AdditionalTransactionMonthlyDetails.get(key));
                                }
                                if(!transactionMonthlyData.isEmpty()){
                                    List<ApplBankDetail__c> monthlyData = processAdditionalTransactionMonthlyDetails(integrationMessage.ParentRefId__c,transactionMonthlyData);
                                    if(monthlyData!=null && !monthlyData.isEmpty()){
                                        appBankDetialList.addAll(monthlyData);
                                    }   
                                }
                            }
                            
                            
                            //Additional Summary Info
                            /*if(response.AdditionalSummaryInfo!=null && response.AdditionalSummaryInfo.summaryInfo1!=null && !response.AdditionalSummaryInfo.summaryInfo1.isEmpty()){
                                List<ApplBankDetail__c> summaryInfo = processAdditionalSummaryInfo(integrationMessage.ParentRefId__c,response.AdditionalSummaryInfo.summaryInfo1);
                                if(summaryInfo!=null && !summaryInfo.isEmpty()){
                                	appBankDetialList.addAll(summaryInfo);
                                }
                            }*/
                            if(response.AdditionalSummaryInfo != null){
                                List<PerfiosRetrieveReportResponseWrapper.SummaryInfo1> summaryInfo = new List<PerfiosRetrieveReportResponseWrapper.SummaryInfo1>();
                                for(String key : response.AdditionalSummaryInfo.keySet()){
                                    summaryInfo.addAll(response.AdditionalSummaryInfo.get(key));
                                }
                                if(!summaryInfo.isEmpty()){
                                    List<ApplBankDetail__c> monthlyData = processAdditionalSummaryInfo(integrationMessage.ParentRefId__c,summaryInfo);
                                    if(monthlyData!=null && !monthlyData.isEmpty()){
                                        appBankDetialList.addAll(monthlyData);
                                    }   
                                }
                            }
                            
                            //2024-08-14 Eshan - LAK-6528 - Changes End
                            
                            if(!response.accountAnalysis.isEmpty()){
                                PerfiosRetrieveReportResponseWrapper.AccountAnalysis accountAnalysis = response.accountAnalysis[0];
                                if(applBankMap.containsKey(integrationMessage.ParentRefId__c) && applBankMap.get(integrationMessage.ParentRefId__c).Source_Type__c == 'Fetch Online Perfios'){
                                    appBank.Name_of_the_Primary_Account_Holder_s__c = response.customerInfo.name!=null && String.isNotBlank(response.customerInfo.name) ? response.customerInfo.name : '';
                                    appBank.AC_No__c = accountAnalysis.accountNo!=null && String.isNotBlank(accountAnalysis.accountNo) ? accountAnalysis.accountNo : '';
                                    
                                    if(accountAnalysis.accountType!=null && String.isNotBlank(accountAnalysis.accountType)){
                                        if(accountAnalysis.accountType.containsIgnoreCase('SAVINGS')){
                                            appBank.AccountType__c = 'SAVINGS';
                                        }
                                        else if(accountAnalysis.accountType.containsIgnoreCase('OVERDRAFT')){
                                            appBank.AccountType__c = 'OVERDRAFT';
                                        }
                                        else if(accountAnalysis.accountType.containsIgnoreCase('CURRENT')){
                                            appBank.AccountType__c = 'CURRENT';
                                        }
                                        else if(accountAnalysis.accountType.containsIgnoreCase('CC') || accountAnalysis.accountType.containsIgnoreCase('CASH CREDIT')){
                                            appBank.AccountType__c = 'CC';
                                        }
                                    }
                                    
                                }
                                if(!accountAnalysis.monthlyDetails.isEmpty()){
                                    /*for(PerfiosRetrieveReportResponseWrapper.MonthlyDetails month: accountAnalysis.monthlyDetails){
                                        System.debug('::::'+month.monthName.toUpperCase());
                                        
                                        if(String.isNotBlank(month.monthName.toUpperCase())){
                                        ApplBankDetail__c applBankDetial = new ApplBankDetail__c();
                                        applBankDetial.ApplBanking__c = integrationMessage.ParentRefId__c;
                                        
                                        if(monthlyApplBankmap.containsKey(integrationMessage.ParentRefId__c) && monthlyApplBankmap.get(integrationMessage.ParentRefId__c).containsKey(month.monthName.toUpperCase())){
                                        applBankDetial.Id =  monthlyApplBankmap.get(integrationMessage.ParentRefId__c).get(month.monthName.toUpperCase());
                                        }
                                        List<String> monthString = month.monthName.toUpperCase().split('-');
                                        if(!monthString.isEmpty()){
                                        applBankDetial.Month__c = monthString[0];
                                        applBankDetial.Year__c = '20' + monthString[1];
                                        }
                                        
                                        applBankDetial.BalanceAt_1st__c = month.bal1!=null ? month.bal1 : null;
                                        applBankDetial.BalanceAt_10th__c = month.bal10!=null ? month.bal10 : null;
                                        applBankDetial.BalanceAt_15th__c = month.bal15!=null ? month.bal15 : null;
                                        applBankDetial.BalanceAt_20th__c = month.bal20!=null ? month.bal20 : null;
                                        applBankDetial.BalanceAt_25th__c = month.bal25!=null ? month.bal25 : null;
                                        applBankDetial.BalanceAt_5th__c = month.bal5!=null ? month.bal5 : null;
                                        
                                        applBankDetial.CountofDebit__c = month.debits!=null ? month.debits : null;
                                        applBankDetial.ValueSummationDebit__c = month.totalDebit!=null ? month.totalDebit : null;
                                        
                                        applBankDetial.CountofCredit__c = month.credits!=null ? month.credits : null;
                                        applBankDetial.ValueSummationCredit__c = month.totalCredit!=null ? month.totalCredit : null;
                                        
                                        applBankDetial.InwardReturnsCount__c = month.inwBounces!=null ? month.inwBounces : null;
                                        applBankDetial.OutwardReturnsCount__c = month.outwBounces!=null ? month.outwBounces : null;
                                        
                                        applBankDetial.StopPaymentCount__c = month.stopPayments!=null ? month.stopPayments : null;
                                        
                                        applBankDetial.MinBalanceCharges__c = month.belowMinBalPenalties!=null ?  applBankDetial.MinBalanceCharges__c = month.belowMinBalPenalties > 0 ? 'Y' : 'N' : '';
                                        
                                        //applBankDetial.AverageBankBalance__c = month.balAvg!=null ? month.balAvg : null;
                                        applBankDetial.DailyABBBalance__c = month.balAvg!=null ? month.balAvg : null;
                                        
                                        appBankDetialList.add(applBankDetial);
                                        }

									}*/
                                    List<ApplBankDetail__c> monthlyDetails = processMonthlyDetails(integrationMessage.ParentRefId__c,accountAnalysis.accountNo,accountAnalysis.accountType,'Account Analysis', 'Monthly Details',monthlyApplBankmap,accountAnalysis.monthlyDetails,accountAnalysis.eODBalances);
                                    if(monthlyDetails!=null && !monthlyDetails.isEmpty()){
                                        appBankDetialList.addAll(monthlyDetails);
                                    }
                                }
                            }
                            
                            appBankList.add(appBank);
                            
                            if(integrationMessage.Trigger_Platform_Event__c){
                                publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                                platformWra.intId = integrationMessage.Id; 
                                platformWra.recId = integrationMessage.ParentRefId__c;
                                platformWra.ServiceName = integrationMessage.Svc__c ;
                                platformWra.Status = integrationMessage.Status__c ;
                                platformWra.success = True;
                                publishPlatFormeventControllerClass.publishPlatFormeventmethod(platformWra);
                            }
                            APICalloutTracker.update_ApiTrackerWithIntMsg(integrationMessage.Id,integrationMessage.Svc__c, integrationMessage.RefId__c, 'Success');
                        }
                        else{
                            
                            String errorMessage = (response.error!=null && String.isNotBlank(response.error.message)) ? response.error.message:'';
                            ApplBanking__c appBank = new ApplBanking__c();
                            appBank.Id = integrationMessage.ParentRefId__c;
                            appBank.Initiate_Perfios_Status__c = 'Failure';
                            appBank.IntegrationStatus__c = PerfiosAPIController.replaceAndUpdateString('Perfios Retrieve Report: Success', 'Perfios Retrieve Report: Failure', applBankMap.get(integrationMessage.ParentRefId__c).IntegrationStatus__c, ';');
                            appBank.IntegrationErrorMessage__c = PerfiosAPIController.replaceAndUpdateString('Perfios Retrieve Report', 'Perfios Retrieve Report: ' + errorMessage, applBankMap.get(integrationMessage.ParentRefId__c).IntegrationErrorMessage__c, ';');
                            appBankList.add(appBank);
                            
                            if(integrationMessage.Trigger_Platform_Event__c){
                                publishPlatFormeventControllerClass.platformEventWrapper platformWra = new publishPlatFormeventControllerClass.platformEventWrapper();
                                platformWra.intId = integrationMessage.Id; 
                                platformWra.recId = integrationMessage.ParentRefId__c;
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
                
                //2024-08-14 Eshan - LAK-6528 - Changes Start
                if(!existingApplBankingIds.isEmpty()){
                    List<ApplBankDetail__c> existingApplBankDtlList = [Select Id,IsLatest__c FROM ApplBankDetail__c WHERE IsLatest__c=True AND ApplBanking__c IN :existingApplBankingIds ];
                    if(!existingApplBankDtlList.isEmpty()){
                        IntegrationUtility.updateBooleanFlag(existingApplBankDtlList, 'IsLatest__c', false);
                    }
                }
                //2024-08-14 Eshan - LAK-6528 - Changes End
                
                if(!appBankDetialList.isEmpty()){
                    
                    System.debug(':::::::::::::::Line312: ' + appBankDetialList.size());
                    fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { ApplBankDetail__c.SObjectType });
                    //List<string> fieldNamesList = New List<string>{'ApplBanking__c','Month__c','Year__c','BalanceAt_1st__c','BalanceAt_10th__c','BalanceAt_15th__c','BalanceAt_20th__c','BalanceAt_25th__c','BalanceAt_5th__c','CountofDebit__c','ValueSummationDebit__c','CountofCredit__c','ValueSummationCredit__c','InwardReturnsCount__c','OutwardReturnsCount__c','StopPaymentCount__c','MinBalanceCharges__c','AverageBankBalance__c'};
                    //    String sObjectName = 'ApplBankDetail__c';
                    //Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    //fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                    uow.registerUpsert(appBankDetialList);
                    uow.commitWork();
                }
                if(!appBankList.isEmpty()){
                    fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { ApplBanking__c.SObjectType });
                    List<string> fieldNamesList = New List<string>{'IntegrationStatus__c','IntegrationErrorMessage__c','Initiate_Perfios_Status__c'};
                        String sObjectName = 'ApplBanking__c';
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                    uow.registerDirty(appBankList);
                    uow.commitWork();
                }
                
                //2024-05-28 Eshan - LAK-7611 - Changes Start
                if(!applicantIds.isEmpty()){
                    upsertApplicantBankingSummary(applicantIds);
                }
                if(!loanApplicationIds.isEmpty()){
                    upsertConsolidatedBankingSummary(loanApplicationIds);
                }
                //2024-05-28 Eshan - LAK-7611 - Changes End
            }
        }
        catch(exception ex){
            system.debug('error message and line number '+ ex.getMessage() + 'line' + ex.getLineNumber());
            GlobalUtility.logMessage('Error', 'PerfiosRetrieveReportResponseProcessor class', 
                                         'processResponses', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }      
    }
    
    private static void createDocDtlWithContentDocumentLink(Map<Id,IntgMsg__c> intgMsgMap, Map<Id, ContentVersion> contentVersionMap){
        Map<Id, Id> idConDocMap = new Map<Id, Id>();
        //Map<String,String> refIdMap = new Map<String,String>();
        List<ContentDocumentLink> ContentDocumentLinkList = new List<ContentDocumentLink>();
		Set<Id> applBankingIds = new Set<Id>();
		Map<Id,DocDtl__c>  appBankingdocDtlMap = new Map<Id,DocDtl__c>();
		Set<Id> existingRecordIds = new Set<Id>();
		Map<Id,Id> idDocDtlMap = new Map<Id,Id>();
		
		for(IntgMsg__c intgMsg: intgMsgMap.Values()){
			if(intgMsg.ParentRefId__c!=null){
				applBankingIds.add(intgMsg.ParentRefId__c);
			}
            APICalloutTracker.update_ApiTrackerWithIntMsg(intgMsg.Id,intgMsg.Svc__c, intgMsg.RefId__c, 'Success');
		}
		
		Map<Id,ApplBanking__c> applBankingMap = new Map<Id,ApplBanking__c>([Select Id,Appl__c,LoanAppl__c FROM ApplBanking__c WHERE ID IN:applBankingIds]);
		
        
        for(ContentVersion cv : [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contentVersionMap.Values()]){
            idConDocMap.put(cv.Id, cv.ContentDocumentId);
        }
        
        for(Id key : contentVersionMap.keyset()){
           	
            if(intgMsgMap.containsKey(key) && intgMsgMap.get(key).ParentRefId__c!=null && applBankingMap.containsKey(intgMsgMap.get(key).ParentRefId__c)){
				
				ApplBanking__c applBank = applBankingMap.get(intgMsgMap.get(key).ParentRefId__c);
				existingRecordIds.add(applBank.Id);
				
				DocDtl__c doc = new DocDtl__c();
                doc.Appl__c = applBank.Appl__c;
				doc.ApplBanking__c = applBank.Id;
                doc.LAN__c = applBank.LoanAppl__c;
                doc.DocCatgry__c = 'Perfios Report';
                doc.DocTyp__c = 'Perfios Report';
                doc.DocSubTyp__c = 'Perfios Report';
                doc.IsLatest__c = true;
                appBankingdocDtlMap.put(applBank.Id,doc);
				
			}
		}
        
        if(!existingRecordIds.isEmpty()){
            updateExistingResponse(existingRecordIds);
        }
        if(!appBankingdocDtlMap.isEmpty()){
            insert appBankingdocDtlMap.values();
        }
		
        for(DocDtl__c dtl : [Select ID,ApplBanking__c FROM DocDtl__c WHERE ID IN:appBankingdocDtlMap.values()]){
			idDocDtlMap.put(dtl.ApplBanking__c,dtl.Id);
		}
		
        for(Id key : contentVersionMap.keyset()){
		
			ContentVersion contentVersion = contentVersionMap.get(key);
			ContentDocumentLink cdl = New ContentDocumentLink();
				
			cdl.LinkedEntityId = (intgMsgMap.containsKey(key) && intgMsgMap.get(key).ParentRefId__c!=null && idDocDtlMap.containsKey(intgMsgMap.get(key).ParentRefId__c))  ? idDocDtlMap.get(intgMsgMap.get(key).ParentRefId__c) : key;
			cdl.ContentDocumentId = idConDocMap.get(contentVersion.Id);
			cdl.shareType = 'V';
			ContentDocumentLinkList.add(cdl);
		
		}
		
        if(!ContentDocumentLinkList.isEmpty()){
            insert ContentDocumentLinkList;
        }
        
        
    }
    
    public static void updateExistingResponse(Set<Id> recordids){
        if(!recordids.isEmpty()){
            List<DocDtl__c> responses = new List<DocDtl__c>();
            for(DocDtl__c res : [Select ID,DocCatgry__c, DocTyp__c, DocSubTyp__c,ApplBanking__c,IsLatest__c FROM DocDtl__c WHERE ApplBanking__c IN:recordids AND DocCatgry__c='Perfios Report' AND IsLatest__c =true]){
                res.IsLatest__c=false;
                responses.add(res);
            }
            
            if(!responses.isEmpty()){
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { DocDtl__c.SObjectType });
                List<string> fieldNamesList = New List<string>{'IsLatest__c'};
                    String sObjectName = 'DocDtl__c';
                Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                uow.registerDirty(responses);
                uow.commitWork();
            }
        }
    }
    
    public static void upsertApplicantBankingSummary(Set<Id> applicantIds){
        try{
            if(applicantIds!= null && !applicantIds.isEmpty()){
                Map<Id,Map<String,ApplBankDetail__c>> applicantBankDetailsMap = new Map<Id,Map<String,ApplBankDetail__c>>();
                Map<Id,Map<String,ApplBankDetail__c>> applBankingSummaryMap = new Map<Id,Map<String,ApplBankDetail__c>>();
                Map<Id,Map<String,String>> applBankingSummaryTypeIdMap = new Map<Id,Map<String,String>>();
                
                for(ApplBanking__c appBank : [SELECT Id,Appl__c,  LoanAppl__c,Summary_Type__c, Type__c FROM ApplBanking__c  WHERE Appl__c IN:applicantIds  AND Type__c  ='Banking Summary']){
                    
                    if(appBank.Summary_Type__c!=null && appBank.Appl__c!=null)
                            if(applBankingSummaryTypeIdMap.containsKey(appBank.Appl__c)){
                                if(!applBankingSummaryTypeIdMap.get(appBank.Appl__c).containsKey(appBank.Summary_Type__c)){
                                    applBankingSummaryTypeIdMap.get(appBank.Appl__c).put(appBank.Summary_Type__c,appBank.Id);
                                }
                            }
                            else{
                                applBankingSummaryTypeIdMap.put(appBank.Appl__c,new Map<String,String>{appBank.Summary_Type__c=>appBank.Id});
                            }
                        
                    
                }
                
                for (ApplBankDetail__c applBankDtl: [SELECT Id,ApplBanking__r.LoanAppl__c,ApplBanking__r.Appl__c,ApplBanking__c,ApplBanking__r.Summary_Type__c	,ApplBanking__r.Type__c,ApplBanking__r.AccountType__c,ApplBanking__r.ConsideredForABBProgram__c,Month__c,Year__c,BalanceAt_1st__c, BalanceAt_10th__c,BalanceAt_15th__c,BalanceAt_20th__c,BalanceAt_25th__c,BalanceAt_5th__c,CountofDebit__c,ValueSummationDebit__c,CountofCredit__c,ValueSummationCredit__c,InwardReturnsCount__c,OutwardReturnsCount__c,StopPaymentCount__c,MinBalanceCharges__c,AverageBankBalance__c,MonthlyLimit__c FROM ApplBankDetail__c WHERE ApplBanking__r.Appl__c IN:applicantIds AND Type__c IN ('','Account Analysis') AND SubType__c IN ('','Monthly Details')]){
                    
                    if(String.isBlank(applBankDtl.ApplBanking__r.Type__c)){
                        
                        if(applicantBankDetailsMap.containsKey(applBankDtl.ApplBanking__r.Appl__c)){
                            applicantBankDetailsMap.get(applBankDtl.ApplBanking__r.Appl__c).put(applBankDtl.Id,applBankDtl);
                        }
                        else{
                            applicantBankDetailsMap.put(applBankDtl.ApplBanking__r.Appl__c, new Map<String,ApplBankDetail__c>{applBankDtl.Id =>applBankDtl});
                        }
                    }
                    else if(applBankDtl.ApplBanking__r.Type__c=='Banking Summary'){
                        
                        if(applBankDtl.ApplBanking__r.Summary_Type__c!=null && applBankDtl.Month__c!=null && applBankDtl.Year__c!=null){
                            
                            if(applBankingSummaryMap.containsKey(applBankDtl.ApplBanking__r.Appl__c)){
                                
                                
                                if(!applBankingSummaryMap.get(applBankDtl.ApplBanking__r.Appl__c).containsKey(applBankDtl.ApplBanking__r.Summary_Type__c + ':' + applBankDtl.Month__c + '-' + applBankDtl.Year__c)){
                                    applBankingSummaryMap.get(applBankDtl.ApplBanking__r.Appl__c).put(applBankDtl.ApplBanking__r.Summary_Type__c + ':' + applBankDtl.Month__c + '-' + applBankDtl.Year__c,applBankDtl);
                                }
                                
                            }
                            else {
                                applBankingSummaryMap.put(applBankDtl.ApplBanking__r.Appl__c, new Map<String,ApplBankDetail__c>{applBankDtl.ApplBanking__r.Summary_Type__c + ':' + applBankDtl.Month__c + '-' + applBankDtl.Year__c=>applBankDtl});
                            }
                        }
                        
                    }
                    
                }
                
                system.debug('applicantBankDetailsMap' + applicantBankDetailsMap);
                system.debug('applBankingSummaryMap' + applBankingSummaryMap);
                
                if(!applicantBankDetailsMap.isEmpty()){
                    Map<String,Map<String,BankingDetailsWrapper>> monthBankDetailMap = new Map<String,Map<String,BankingDetailsWrapper>>();
                    Map<String,ApplBanking__c> applBankingMap = new Map<String,ApplBanking__c>();
                    for(Id appl: applicantBankDetailsMap.keySet()){
                        if(applicantBankDetailsMap.containsKey(appl)){
                            
                            Map<String,ApplBankDetail__c> bankDetailsMap = applicantBankDetailsMap.get(appl);
                            if(bankDetailsMap!=null && !bankDetailsMap.isEmpty()){
                                for(ApplBankDetail__c applBankDtl :bankDetailsMap.values()){
                                    
                                    String key = (applBankDtl.ApplBanking__r.AccountType__c=='SAVINGS' || applBankDtl.ApplBanking__r.AccountType__c=='CURRENT' ? 'Combined Banking (CASA)': 'Combined Banking (OD/CC)') + ':'+  applBankDtl.Month__c + '-' + applBankDtl.Year__c;
                                    
                                    if(applBankingSummaryTypeIdMap.containsKey(appl)){
                                        if(!applBankingSummaryTypeIdMap.get(appl).containsKey(key.substringBefore(':'))){
                                            applBankingMap.put(appl +':' + key.substringBefore(':'), new ApplBanking__c(Appl__c=appl,LoanAppl__c=applBankDtl.ApplBanking__r.LoanAppl__c,Summary_Type__c=key.substringBefore(':'),Type__c='Banking Summary'));
                                        }
                                    }
                                    else{
                                        applBankingMap.put(appl +':' + key.substringBefore(':'), new ApplBanking__c(Appl__c=appl,LoanAppl__c=applBankDtl.ApplBanking__r.LoanAppl__c,Summary_Type__c=key.substringBefore(':'),Type__c='Banking Summary'));
                                    }
                                    
                                    if(applBankDtl.ApplBanking__r.AccountType__c!=null && applBankDtl.Month__c!=null && applBankDtl.Year__c!=null){
                                        if(monthBankDetailMap.containsKey(applBankDtl.ApplBanking__r.Appl__c)){
                                            
                                            if(monthBankDetailMap.get(applBankDtl.ApplBanking__r.Appl__c).containsKey(key)){
                                                
                                                if(applBankDtl.BalanceAt_1st__c!=null){
                                                    monthBankDetailMap.get(applBankDtl.ApplBanking__r.Appl__c).get(key).balanceAt1st += applBankDtl.BalanceAt_1st__c; 
                                                }
                                                if(applBankDtl.BalanceAt_10th__c!=null){
                                                    monthBankDetailMap.get(applBankDtl.ApplBanking__r.Appl__c).get(key).balanceAt10th += applBankDtl.BalanceAt_10th__c; 
                                                }
                                                if(applBankDtl.BalanceAt_15th__c!=null){
                                                    monthBankDetailMap.get(applBankDtl.ApplBanking__r.Appl__c).get(key).balanceAt15th += applBankDtl.BalanceAt_15th__c;
                                                }
                                                if(applBankDtl.BalanceAt_20th__c!=null){
                                                    monthBankDetailMap.get(applBankDtl.ApplBanking__r.Appl__c).get(key).balanceAt20th += applBankDtl.BalanceAt_20th__c;  
                                                }
                                                if(applBankDtl.BalanceAt_25th__c!=null){
                                                    monthBankDetailMap.get(applBankDtl.ApplBanking__r.Appl__c).get(key).balanceAt25th += applBankDtl.BalanceAt_25th__c; 
                                                }
                                                if(applBankDtl.BalanceAt_5th__c!=null){
                                                    monthBankDetailMap.get(applBankDtl.ApplBanking__r.Appl__c).get(key).balanceAt5th += applBankDtl.BalanceAt_5th__c; 
                                                }
                                                if(applBankDtl.CountofDebit__c!=null){
                                                    monthBankDetailMap.get(applBankDtl.ApplBanking__r.Appl__c).get(key).countofDebit += applBankDtl.CountofDebit__c;
                                                }
                                                if(applBankDtl.CountofCredit__c!=null){
                                                    monthBankDetailMap.get(applBankDtl.ApplBanking__r.Appl__c).get(key).countofCredit += applBankDtl.CountofCredit__c;
                                                }
                                                if(applBankDtl.ValueSummationCredit__c!=null){
                                                    monthBankDetailMap.get(applBankDtl.ApplBanking__r.Appl__c).get(key).valueSummationCredit += applBankDtl.ValueSummationCredit__c;    
                                                }
                                                if(applBankDtl.ValueSummationDebit__c!=null){
                                                    monthBankDetailMap.get(applBankDtl.ApplBanking__r.Appl__c).get(key).valueSummationDebit += applBankDtl.ValueSummationDebit__c;
                                                }
                                                if(applBankDtl.InwardReturnsCount__c!=null){
                                                    monthBankDetailMap.get(applBankDtl.ApplBanking__r.Appl__c).get(key).inwardReturnsCount += applBankDtl.InwardReturnsCount__c;
                                                }
                                                if(applBankDtl.OutwardReturnsCount__c!=null){
                                                    monthBankDetailMap.get(applBankDtl.ApplBanking__r.Appl__c).get(key).outwardReturnsCount += applBankDtl.OutwardReturnsCount__c;   
                                                }
                                                if(applBankDtl.StopPaymentCount__c!=null){
                                                    monthBankDetailMap.get(applBankDtl.ApplBanking__r.Appl__c).get(key).stopPaymentCount += applBankDtl.StopPaymentCount__c; 
                                                }
                                                if(applBankDtl.MonthlyLimit__c!=null){
                                                    monthBankDetailMap.get(applBankDtl.ApplBanking__r.Appl__c).get(key).monthlyLimit += applBankDtl.MonthlyLimit__c; 
                                                }
                                                monthBankDetailMap.get(applBankDtl.ApplBanking__r.Appl__c).get(key).averageBankBalance = (monthBankDetailMap.get(applBankDtl.ApplBanking__r.Appl__c).get(key).balanceAt1st + monthBankDetailMap.get(applBankDtl.ApplBanking__r.Appl__c).get(key).balanceAt10th + monthBankDetailMap.get(applBankDtl.ApplBanking__r.Appl__c).get(key).balanceAt15th + monthBankDetailMap.get(applBankDtl.ApplBanking__r.Appl__c).get(key).balanceAt20th + monthBankDetailMap.get(applBankDtl.ApplBanking__r.Appl__c).get(key).balanceAt25th +monthBankDetailMap.get(applBankDtl.ApplBanking__r.Appl__c).get(key).balanceAt5th)/6;
                                                monthBankDetailMap.get(applBankDtl.ApplBanking__r.Appl__c).get(key).minBalanceCharges = ((monthBankDetailMap.get(applBankDtl.ApplBanking__r.Appl__c).get(key).minBalanceCharges=='N' || String.isBlank(monthBankDetailMap.get(applBankDtl.ApplBanking__r.Appl__c).get(key).minBalanceCharges)) && applBankDtl.MinBalanceCharges__c=='Y') ? 'Y' : 'N';    
                                                monthBankDetailMap.get(applBankDtl.ApplBanking__r.Appl__c).get(key).month = applBankDtl.Month__c;
                                                monthBankDetailMap.get(applBankDtl.ApplBanking__r.Appl__c).get(key).year = applBankDtl.Year__c;
                                                monthBankDetailMap.get(applBankDtl.ApplBanking__r.Appl__c).get(key).loanApplicationId = applBankDtl.ApplBanking__r.LoanAppl__c;
                                            }
                                            else{
                                                
                                                BankingDetailsWrapper bankDtl = new BankingDetailsWrapper();
                                                bankDtl.balanceAt1st = applBankDtl.BalanceAt_1st__c !=null ? applBankDtl.BalanceAt_1st__c : 0;
                                                bankDtl.balanceAt10th = applBankDtl.BalanceAt_10th__c !=null? applBankDtl.BalanceAt_10th__c : 0 ;
                                                bankDtl.balanceAt15th = applBankDtl.BalanceAt_15th__c !=null? applBankDtl.BalanceAt_15th__c : 0 ;
                                                bankDtl.balanceAt20th = applBankDtl.BalanceAt_20th__c !=null? applBankDtl.BalanceAt_20th__c : 0 ;
                                                bankDtl.balanceAt25th = applBankDtl.BalanceAt_25th__c !=null? applBankDtl.BalanceAt_25th__c : 0 ;
                                                bankDtl.balanceAt5th = applBankDtl.BalanceAt_5th__c !=null? applBankDtl.BalanceAt_5th__c : 0 ; 
                                                bankDtl.countofDebit = applBankDtl.CountofDebit__c !=null? applBankDtl.CountofDebit__c : 0 ;
                                                bankDtl.countofCredit = applBankDtl.CountofCredit__c !=null? applBankDtl.CountofCredit__c : 0 ;
                                                bankDtl.valueSummationCredit = applBankDtl.ValueSummationCredit__c !=null? applBankDtl.ValueSummationCredit__c : 0 ;
                                                bankDtl.valueSummationDebit = applBankDtl.ValueSummationDebit__c !=null? applBankDtl.ValueSummationDebit__c : 0 ;
                                                bankDtl.inwardReturnsCount = applBankDtl.InwardReturnsCount__c !=null? applBankDtl.InwardReturnsCount__c : 0 ;
                                                bankDtl.outwardReturnsCount = applBankDtl.OutwardReturnsCount__c !=null? applBankDtl.OutwardReturnsCount__c : 0 ;
                                                bankDtl.stopPaymentCount = applBankDtl.StopPaymentCount__c !=null? applBankDtl.StopPaymentCount__c : 0 ;
                                                bankDtl.monthlyLimit = applBankDtl.MonthlyLimit__c !=null? applBankDtl.MonthlyLimit__c : 0 ;
                                                bankDtl.minBalanceCharges = applBankDtl.MinBalanceCharges__c!=null ? applBankDtl.MinBalanceCharges__c : 'N';    
                                                bankDtl.averageBankBalance = (bankDtl.balanceAt1st + bankDtl.balanceAt10th + bankDtl.balanceAt15th + bankDtl.balanceAt20th + bankDtl.balanceAt25th +bankDtl.balanceAt5th)/6;
                                                bankDtl.month = applBankDtl.Month__c;
                                                bankDtl.year = applBankDtl.Year__c;
                                                bankDtl.loanApplicationId = applBankDtl.ApplBanking__r.LoanAppl__c;
                                                
                                                monthBankDetailMap.get(applBankDtl.ApplBanking__r.Appl__c).put(key,bankDtl);
                                            }
                                            
                                        }
                                        else {
                                            
                                            BankingDetailsWrapper bankDtl = new BankingDetailsWrapper();
                                            bankDtl.balanceAt1st = applBankDtl.BalanceAt_1st__c !=null ? applBankDtl.BalanceAt_1st__c : 0;
                                            bankDtl.balanceAt10th = applBankDtl.BalanceAt_10th__c !=null? applBankDtl.BalanceAt_10th__c : 0 ;
                                            bankDtl.balanceAt15th = applBankDtl.BalanceAt_15th__c !=null? applBankDtl.BalanceAt_15th__c : 0 ;
                                            bankDtl.balanceAt20th = applBankDtl.BalanceAt_20th__c !=null? applBankDtl.BalanceAt_20th__c : 0 ;
                                            bankDtl.balanceAt25th = applBankDtl.BalanceAt_25th__c !=null? applBankDtl.BalanceAt_25th__c : 0 ;
                                            bankDtl.balanceAt5th = applBankDtl.BalanceAt_5th__c !=null? applBankDtl.BalanceAt_5th__c : 0 ; 
                                            bankDtl.countofDebit = applBankDtl.CountofDebit__c !=null? applBankDtl.CountofDebit__c : 0 ;
                                            bankDtl.countofCredit = applBankDtl.CountofCredit__c !=null? applBankDtl.CountofCredit__c : 0 ;
                                            bankDtl.valueSummationCredit = applBankDtl.ValueSummationCredit__c !=null? applBankDtl.ValueSummationCredit__c : 0 ;
                                            bankDtl.valueSummationDebit = applBankDtl.ValueSummationDebit__c !=null? applBankDtl.ValueSummationDebit__c : 0 ;
                                            bankDtl.inwardReturnsCount = applBankDtl.InwardReturnsCount__c !=null? applBankDtl.InwardReturnsCount__c : 0 ;
                                            bankDtl.outwardReturnsCount = applBankDtl.OutwardReturnsCount__c !=null? applBankDtl.OutwardReturnsCount__c : 0 ;
                                            bankDtl.stopPaymentCount = applBankDtl.StopPaymentCount__c !=null? applBankDtl.StopPaymentCount__c : 0 ;
                                            bankDtl.monthlyLimit = applBankDtl.MonthlyLimit__c !=null? applBankDtl.MonthlyLimit__c : 0 ;
                                            bankDtl.averageBankBalance = (bankDtl.balanceAt1st + bankDtl.balanceAt10th + bankDtl.balanceAt15th + bankDtl.balanceAt20th + bankDtl.balanceAt25th +bankDtl.balanceAt5th)/6;
                                            bankDtl.minBalanceCharges = applBankDtl.MinBalanceCharges__c!=null ? applBankDtl.MinBalanceCharges__c : 'N';   
                                            bankDtl.month = applBankDtl.Month__c;
                                            bankDtl.year = applBankDtl.Year__c;
                                            bankDtl.loanApplicationId = applBankDtl.ApplBanking__r.LoanAppl__c;
                                            
                                            monthBankDetailMap.put(applBankDtl.ApplBanking__r.Appl__c,new Map<String,BankingDetailsWrapper>{key=>bankDtl});
                                            
                                        }
                                    }
                                }
                            }
                        }
                    }
                    //system.debug('monthBankDetailMap' + monthBankDetailMap.get('a0AC4000000OMnNMAW'));
                    //system.debug('monthBankDetailMap' + monthBankDetailMap.get('a0AC4000000OMnNMAW').get('Combined Banking (CASA):SEP-2023'));
                    system.debug('applBankingSummaryTypeIdMap' + applBankingSummaryTypeIdMap);
                    
                    if(!applBankingMap.isEmpty()){
                        system.debug('applBankingMap' + applBankingMap);
                        insert applBankingMap.values();
                        
                        for(ApplBanking__c appBank : [SELECT Id,Appl__c,  LoanAppl__c,Summary_Type__c, Type__c FROM ApplBanking__c  WHERE Id IN:applBankingMap.values()]){
                            
                            if(appBank.Summary_Type__c!=null && appBank.Appl__c!=null)
                                if(applBankingSummaryTypeIdMap.containsKey(appBank.Appl__c)){
                                    if(!applBankingSummaryTypeIdMap.get(appBank.Appl__c).containsKey(appBank.Summary_Type__c)){
                                        applBankingSummaryTypeIdMap.get(appBank.Appl__c).put(appBank.Summary_Type__c,appBank.Id);
                                    }
                                }
                            else{
                                applBankingSummaryTypeIdMap.put(appBank.Appl__c,new Map<String,String>{appBank.Summary_Type__c=>appBank.Id});
                            }
                        }
                    }
                    
                    if(!monthBankDetailMap.isEmpty()){
                        
                        //Map<String,ApplBanking__c> applBankingMap = new Map<String,ApplBanking__c>();
                        List<ApplBankDetail__c> applBankDetailList = new List<ApplBankDetail__c>();
                        for(String appl : monthBankDetailMap.keySet()){
                            
                            if(monthBankDetailMap.containsKey(appl)){
                                Map<String,BankingDetailsWrapper> bankDetailsMap = monthBankDetailMap.get(appl);
                                if(bankDetailsMap!=null && !bankDetailsMap.isEmpty()){
                                    for(String key : bankDetailsMap.keySet()){
                                        BankingDetailsWrapper bankDtl = bankDetailsMap.get(key);
                                        ApplBankDetail__c applBankDetail = new ApplBankDetail__c();
                                        
                                        if(applBankingSummaryMap.containskey(appl) && applBankingSummaryMap.get(appl).containsKey(key)){
                                            applBankDetail.Id = applBankingSummaryMap.get(appl).get(Key).Id;
                                        }
                                        else {
                                            if(applBankingSummaryTypeIdMap.containsKey(appl) && applBankingSummaryTypeIdMap.get(appl).containsKey(key.substringBefore(':'))){
                                                applBankDetail.ApplBanking__c = applBankingSummaryTypeIdMap.get(appl).get(key.substringBefore(':'));   
                                            }
                                        }
                                        /*else {
                                            if(applBankingMap.containsKey(appl +':' + key.substringBefore(':'))){
                                                applBankDetail.ApplBanking__c = applBankingMap.get(appl +':' + key.substringBefore(':')).Id;
                                            }
                                            else{
                                                system.debug('::::'+key.substringBefore(':'));
                                                applBankingMap.put(appl +':' + key.substringBefore(':'), new ApplBanking__c(Appl__c=appl,LoanAppl__c=bankDtl.loanApplicationId,Summary_Type__c=key.substringBefore(':'),Type__c='Banking Summary'));
                                                applBankDetail.ApplBanking__c = applBankingMap.get(appl +':' + key.substringBefore(':')).Id;
                                            }
                                        }*/
                                        
                                        applBankDetail.BalanceAt_1st__c = bankDtl.balanceAt1st;
                                        applBankDetail.BalanceAt_10th__c = bankDtl.balanceAt10th;
                                        applBankDetail.BalanceAt_15th__c = bankDtl.balanceAt15th;
                                        applBankDetail.BalanceAt_20th__c = bankDtl.balanceAt20th;
                                        applBankDetail.BalanceAt_25th__c = bankDtl.balanceAt25th;
                                        applBankDetail.BalanceAt_5th__c = bankDtl.balanceAt5th; 
                                        applBankDetail.CountofDebit__c = bankDtl.countofDebit;
                                        applBankDetail.CountofCredit__c = bankDtl.countofCredit;
                                        applBankDetail.ValueSummationCredit__c = bankDtl.valueSummationCredit;
                                        applBankDetail.ValueSummationDebit__c = bankDtl.valueSummationDebit;
                                        applBankDetail.InwardReturnsCount__c = bankDtl.inwardReturnsCount;
                                        applBankDetail.OutwardReturnsCount__c = bankDtl.outwardReturnsCount;
                                        applBankDetail.StopPaymentCount__c = bankDtl.stopPaymentCount;
                                        applBankDetail.MonthlyLimit__c = bankDtl.monthlyLimit;
                                        applBankDetail.AverageBankBalance__c = bankDtl.averageBankBalance;
                                        applBankDetail.MinBalanceCharges__c = bankDtl.minBalanceCharges;    
                                        applBankDetail.Month__c = bankDtl.month ;
                                        applBankDetail.Year__c = bankDtl.year;
                                        
                                        applBankDetailList.add(applBankDetail);
                                        
                                    }
                                }
                            }
                        }
                        
                        
                        if(!applBankDetailList.isEmpty()){
                            system.debug('applBankDetailList' + applBankDetailList);
                            upsert applBankDetailList;
                        }
                        
                    }
                }
            }
        }
        catch(exception ex){
            system.debug('error message and line number '+ ex.getMessage() + 'line' + ex.getLineNumber());
            GlobalUtility.logMessage('Error', 'PerfiosRetrieveReportResponseProcessor class', 
                                         'upsertApplicantBankingSummary', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }     
    }
    
    public static void upsertConsolidatedBankingSummary(Set<Id> loanApplicationIds){
        try{
            
            if(loanApplicationIds!= null && !loanApplicationIds.isEmpty()){
                Map<Id,Map<String,ApplBankDetail__c>> applicantBankDetailsMap = new Map<Id,Map<String,ApplBankDetail__c>>();
                Map<Id,Map<String,ApplBankDetail__c>> bankingSummaryMap = new Map<Id,Map<String,ApplBankDetail__c>>();
                Map<Id,Map<String,String>> bankingSummaryTypeIdMap = new Map<Id,Map<String,String>>();
                
                for(ApplBanking__c appBank : [SELECT Id,Appl__c,  LoanAppl__c,Summary_Type__c, Type__c FROM ApplBanking__c  WHERE LoanAppl__c IN:loanApplicationIds  AND Type__c  ='Consolidated Banking Summary']){
                    
                    if(appBank.Summary_Type__c!=null && appBank.LoanAppl__c!=null)
                        if(bankingSummaryTypeIdMap.containsKey(appBank.LoanAppl__c)){
                            if(!bankingSummaryTypeIdMap.get(appBank.LoanAppl__c).containsKey(appBank.Summary_Type__c)){
                                bankingSummaryTypeIdMap.get(appBank.LoanAppl__c).put(appBank.Summary_Type__c,appBank.Id);
                            }
                        }
                    else{
                        bankingSummaryTypeIdMap.put(appBank.LoanAppl__c,new Map<String,String>{appBank.Summary_Type__c=>appBank.Id});
                    }
                    
                    
                }
                
                for (ApplBankDetail__c applBankDtl: [SELECT Id,ApplBanking__r.LoanAppl__c,ApplBanking__r.Appl__c,ApplBanking__c,ApplBanking__r.Summary_Type__c	,ApplBanking__r.Type__c,ApplBanking__r.AccountType__c,ApplBanking__r.ConsideredForABBProgram__c,Month__c,Year__c,BalanceAt_1st__c, BalanceAt_10th__c,BalanceAt_15th__c,BalanceAt_20th__c,BalanceAt_25th__c,BalanceAt_5th__c,CountofDebit__c,ValueSummationDebit__c,CountofCredit__c,ValueSummationCredit__c,InwardReturnsCount__c,OutwardReturnsCount__c,StopPaymentCount__c,MinBalanceCharges__c,AverageBankBalance__c,MonthlyLimit__c FROM ApplBankDetail__c WHERE ApplBanking__r.LoanAppl__c IN:loanApplicationIds AND Type__c IN ('','Account Analysis') AND SubType__c IN ('','Monthly Details')]){
                    
                    if(String.isBlank(applBankDtl.ApplBanking__r.Type__c)){
                        
                        if(applicantBankDetailsMap.containsKey(applBankDtl.ApplBanking__r.LoanAppl__c)){
                            applicantBankDetailsMap.get(applBankDtl.ApplBanking__r.LoanAppl__c).put(applBankDtl.Id,applBankDtl);
                        }
                        else{
                            applicantBankDetailsMap.put(applBankDtl.ApplBanking__r.LoanAppl__c, new Map<String,ApplBankDetail__c>{applBankDtl.Id =>applBankDtl});
                        }
                    }
                    else if(applBankDtl.ApplBanking__r.Type__c=='Consolidated Banking Summary'){
                        
                        if(applBankDtl.ApplBanking__r.Summary_Type__c!=null && applBankDtl.Month__c!=null && applBankDtl.Year__c!=null){
                            
                            if(bankingSummaryMap.containsKey(applBankDtl.ApplBanking__r.LoanAppl__c)){
                                
                                
                                if(!bankingSummaryMap.get(applBankDtl.ApplBanking__r.LoanAppl__c).containsKey(applBankDtl.ApplBanking__r.Summary_Type__c + ':' + applBankDtl.Month__c + '-' + applBankDtl.Year__c)){
                                    bankingSummaryMap.get(applBankDtl.ApplBanking__r.LoanAppl__c).put(applBankDtl.ApplBanking__r.Summary_Type__c + ':' + applBankDtl.Month__c + '-' + applBankDtl.Year__c,applBankDtl);
                                }
                                
                            }
                            else {
                                bankingSummaryMap.put(applBankDtl.ApplBanking__r.LoanAppl__c, new Map<String,ApplBankDetail__c>{applBankDtl.ApplBanking__r.Summary_Type__c + ':' + applBankDtl.Month__c + '-' + applBankDtl.Year__c=>applBankDtl});
                            }
                        }
                        
                    }
                    
                }
                
                system.debug('applicantBankDetailsMap' + applicantBankDetailsMap);
                system.debug('bankingSummaryMap' + bankingSummaryMap);
                
                if(!applicantBankDetailsMap.isEmpty()){
                    Map<String,Map<String,BankingDetailsWrapper>> monthBankDetailMap = new Map<String,Map<String,BankingDetailsWrapper>>();
                    Map<String,ApplBanking__c> applBankingMap = new Map<String,ApplBanking__c>();
                    
                    for(Id appl: applicantBankDetailsMap.keySet()){
                        if(applicantBankDetailsMap.containsKey(appl)){
                            
                            Map<String,ApplBankDetail__c> bankDetailsMap = applicantBankDetailsMap.get(appl);
                            if(bankDetailsMap!=null && !bankDetailsMap.isEmpty()){
                                for(ApplBankDetail__c applBankDtl :bankDetailsMap.values()){
                                    
                                    String key = (applBankDtl.ApplBanking__r.AccountType__c=='SAVINGS' || applBankDtl.ApplBanking__r.AccountType__c=='CURRENT' ? 'Combined Banking (CASA)': 'Combined Banking (OD/CC)') + ':'+  applBankDtl.Month__c + '-' + applBankDtl.Year__c;
                                    
                                    if(bankingSummaryTypeIdMap.containsKey(applBankDtl.ApplBanking__r.LoanAppl__c)){
                                        if(!bankingSummaryTypeIdMap.get(applBankDtl.ApplBanking__r.LoanAppl__c).containsKey(key.substringBefore(':'))){
                                            system.debug(':::::::::::::::::::::');
                                            applBankingMap.put(applBankDtl.ApplBanking__r.LoanAppl__c +':' + key.substringBefore(':'), new ApplBanking__c(LoanAppl__c=applBankDtl.ApplBanking__r.LoanAppl__c,Summary_Type__c=key.substringBefore(':'),Type__c='Consolidated Banking Summary'));
                                        }
                                    }
                                    else{
                                        system.debug('::::::::*****:::::::::::::');
                                        applBankingMap.put(applBankDtl.ApplBanking__r.LoanAppl__c +':' + key.substringBefore(':'), new ApplBanking__c(LoanAppl__c=applBankDtl.ApplBanking__r.LoanAppl__c,Summary_Type__c=key.substringBefore(':'),Type__c='Consolidated Banking Summary'));
                                    }
                                    
                                    if(applBankDtl.ApplBanking__r.AccountType__c!=null && applBankDtl.Month__c!=null && applBankDtl.Year__c!=null){
                                        if(monthBankDetailMap.containsKey(applBankDtl.ApplBanking__r.LoanAppl__c)){
                                            
                                            if(monthBankDetailMap.get(applBankDtl.ApplBanking__r.LoanAppl__c).containsKey(key)){
                                                
                                                if(applBankDtl.BalanceAt_1st__c!=null){
                                                    monthBankDetailMap.get(applBankDtl.ApplBanking__r.LoanAppl__c).get(key).balanceAt1st += applBankDtl.BalanceAt_1st__c; 
                                                }
                                                if(applBankDtl.BalanceAt_10th__c!=null){
                                                    monthBankDetailMap.get(applBankDtl.ApplBanking__r.LoanAppl__c).get(key).balanceAt10th += applBankDtl.BalanceAt_10th__c; 
                                                }
                                                if(applBankDtl.BalanceAt_15th__c!=null){
                                                    monthBankDetailMap.get(applBankDtl.ApplBanking__r.LoanAppl__c).get(key).balanceAt15th += applBankDtl.BalanceAt_15th__c;
                                                }
                                                if(applBankDtl.BalanceAt_20th__c!=null){
                                                    monthBankDetailMap.get(applBankDtl.ApplBanking__r.LoanAppl__c).get(key).balanceAt20th += applBankDtl.BalanceAt_20th__c;  
                                                }
                                                if(applBankDtl.BalanceAt_25th__c!=null){
                                                    monthBankDetailMap.get(applBankDtl.ApplBanking__r.LoanAppl__c).get(key).balanceAt25th += applBankDtl.BalanceAt_25th__c; 
                                                }
                                                if(applBankDtl.BalanceAt_5th__c!=null){
                                                    monthBankDetailMap.get(applBankDtl.ApplBanking__r.LoanAppl__c).get(key).balanceAt5th += applBankDtl.BalanceAt_5th__c; 
                                                }
                                                if(applBankDtl.CountofDebit__c!=null){
                                                    monthBankDetailMap.get(applBankDtl.ApplBanking__r.LoanAppl__c).get(key).countofDebit += applBankDtl.CountofDebit__c;
                                                }
                                                if(applBankDtl.CountofCredit__c!=null){
                                                    monthBankDetailMap.get(applBankDtl.ApplBanking__r.LoanAppl__c).get(key).countofCredit += applBankDtl.CountofCredit__c;
                                                }
                                                if(applBankDtl.ValueSummationCredit__c!=null){
                                                    monthBankDetailMap.get(applBankDtl.ApplBanking__r.LoanAppl__c).get(key).valueSummationCredit += applBankDtl.ValueSummationCredit__c;    
                                                }
                                                if(applBankDtl.ValueSummationDebit__c!=null){
                                                    monthBankDetailMap.get(applBankDtl.ApplBanking__r.LoanAppl__c).get(key).valueSummationDebit += applBankDtl.ValueSummationDebit__c;
                                                }
                                                if(applBankDtl.InwardReturnsCount__c!=null){
                                                    monthBankDetailMap.get(applBankDtl.ApplBanking__r.LoanAppl__c).get(key).inwardReturnsCount += applBankDtl.InwardReturnsCount__c;
                                                }
                                                if(applBankDtl.OutwardReturnsCount__c!=null){
                                                    monthBankDetailMap.get(applBankDtl.ApplBanking__r.LoanAppl__c).get(key).outwardReturnsCount += applBankDtl.OutwardReturnsCount__c;   
                                                }
                                                if(applBankDtl.StopPaymentCount__c!=null){
                                                    monthBankDetailMap.get(applBankDtl.ApplBanking__r.LoanAppl__c).get(key).stopPaymentCount += applBankDtl.StopPaymentCount__c; 
                                                }
                                                if(applBankDtl.MonthlyLimit__c!=null){
                                                    monthBankDetailMap.get(applBankDtl.ApplBanking__r.LoanAppl__c).get(key).monthlyLimit += applBankDtl.MonthlyLimit__c; 
                                                }
                                                monthBankDetailMap.get(applBankDtl.ApplBanking__r.LoanAppl__c).get(key).averageBankBalance = (monthBankDetailMap.get(applBankDtl.ApplBanking__r.LoanAppl__c).get(key).balanceAt1st + monthBankDetailMap.get(applBankDtl.ApplBanking__r.LoanAppl__c).get(key).balanceAt10th + monthBankDetailMap.get(applBankDtl.ApplBanking__r.LoanAppl__c).get(key).balanceAt15th + monthBankDetailMap.get(applBankDtl.ApplBanking__r.LoanAppl__c).get(key).balanceAt20th + monthBankDetailMap.get(applBankDtl.ApplBanking__r.LoanAppl__c).get(key).balanceAt25th +monthBankDetailMap.get(applBankDtl.ApplBanking__r.LoanAppl__c).get(key).balanceAt5th)/6;
                                                monthBankDetailMap.get(applBankDtl.ApplBanking__r.LoanAppl__c).get(key).minBalanceCharges = ((monthBankDetailMap.get(applBankDtl.ApplBanking__r.LoanAppl__c).get(key).minBalanceCharges=='N' || String.isBlank(monthBankDetailMap.get(applBankDtl.ApplBanking__r.LoanAppl__c).get(key).minBalanceCharges)) && applBankDtl.MinBalanceCharges__c=='Y') ? 'Y' : 'N';    
                                                monthBankDetailMap.get(applBankDtl.ApplBanking__r.LoanAppl__c).get(key).month = applBankDtl.Month__c;
                                                monthBankDetailMap.get(applBankDtl.ApplBanking__r.LoanAppl__c).get(key).year = applBankDtl.Year__c;
                                                monthBankDetailMap.get(applBankDtl.ApplBanking__r.LoanAppl__c).get(key).loanApplicationId = applBankDtl.ApplBanking__r.LoanAppl__c;
                                            }
                                            else{
                                                
                                                BankingDetailsWrapper bankDtl = new BankingDetailsWrapper();
                                                bankDtl.balanceAt1st = applBankDtl.BalanceAt_1st__c !=null ? applBankDtl.BalanceAt_1st__c : 0;
                                                bankDtl.balanceAt10th = applBankDtl.BalanceAt_10th__c !=null? applBankDtl.BalanceAt_10th__c : 0 ;
                                                bankDtl.balanceAt15th = applBankDtl.BalanceAt_15th__c !=null? applBankDtl.BalanceAt_15th__c : 0 ;
                                                bankDtl.balanceAt20th = applBankDtl.BalanceAt_20th__c !=null? applBankDtl.BalanceAt_20th__c : 0 ;
                                                bankDtl.balanceAt25th = applBankDtl.BalanceAt_25th__c !=null? applBankDtl.BalanceAt_25th__c : 0 ;
                                                bankDtl.balanceAt5th = applBankDtl.BalanceAt_5th__c !=null? applBankDtl.BalanceAt_5th__c : 0 ; 
                                                bankDtl.countofDebit = applBankDtl.CountofDebit__c !=null? applBankDtl.CountofDebit__c : 0 ;
                                                bankDtl.countofCredit = applBankDtl.CountofCredit__c !=null? applBankDtl.CountofCredit__c : 0 ;
                                                bankDtl.valueSummationCredit = applBankDtl.ValueSummationCredit__c !=null? applBankDtl.ValueSummationCredit__c : 0 ;
                                                bankDtl.valueSummationDebit = applBankDtl.ValueSummationDebit__c !=null? applBankDtl.ValueSummationDebit__c : 0 ;
                                                bankDtl.inwardReturnsCount = applBankDtl.InwardReturnsCount__c !=null? applBankDtl.InwardReturnsCount__c : 0 ;
                                                bankDtl.outwardReturnsCount = applBankDtl.OutwardReturnsCount__c !=null? applBankDtl.OutwardReturnsCount__c : 0 ;
                                                bankDtl.stopPaymentCount = applBankDtl.StopPaymentCount__c !=null? applBankDtl.StopPaymentCount__c : 0 ;
                                                bankDtl.monthlyLimit = applBankDtl.MonthlyLimit__c !=null? applBankDtl.MonthlyLimit__c : 0 ;
                                                bankDtl.minBalanceCharges = applBankDtl.MinBalanceCharges__c!=null ? applBankDtl.MinBalanceCharges__c : 'N';    
                                                bankDtl.averageBankBalance = (bankDtl.balanceAt1st + bankDtl.balanceAt10th + bankDtl.balanceAt15th + bankDtl.balanceAt20th + bankDtl.balanceAt25th +bankDtl.balanceAt5th)/6;
                                                bankDtl.month = applBankDtl.Month__c;
                                                bankDtl.year = applBankDtl.Year__c;
                                                bankDtl.loanApplicationId = applBankDtl.ApplBanking__r.LoanAppl__c;
                                                
                                                monthBankDetailMap.get(applBankDtl.ApplBanking__r.LoanAppl__c).put(key,bankDtl);
                                            }
                                            
                                        }
                                        else {
                                            
                                            BankingDetailsWrapper bankDtl = new BankingDetailsWrapper();
                                            bankDtl.balanceAt1st = applBankDtl.BalanceAt_1st__c !=null ? applBankDtl.BalanceAt_1st__c : 0;
                                            bankDtl.balanceAt10th = applBankDtl.BalanceAt_10th__c !=null? applBankDtl.BalanceAt_10th__c : 0 ;
                                            bankDtl.balanceAt15th = applBankDtl.BalanceAt_15th__c !=null? applBankDtl.BalanceAt_15th__c : 0 ;
                                            bankDtl.balanceAt20th = applBankDtl.BalanceAt_20th__c !=null? applBankDtl.BalanceAt_20th__c : 0 ;
                                            bankDtl.balanceAt25th = applBankDtl.BalanceAt_25th__c !=null? applBankDtl.BalanceAt_25th__c : 0 ;
                                            bankDtl.balanceAt5th = applBankDtl.BalanceAt_5th__c !=null? applBankDtl.BalanceAt_5th__c : 0 ; 
                                            bankDtl.countofDebit = applBankDtl.CountofDebit__c !=null? applBankDtl.CountofDebit__c : 0 ;
                                            bankDtl.countofCredit = applBankDtl.CountofCredit__c !=null? applBankDtl.CountofCredit__c : 0 ;
                                            bankDtl.valueSummationCredit = applBankDtl.ValueSummationCredit__c !=null? applBankDtl.ValueSummationCredit__c : 0 ;
                                            bankDtl.valueSummationDebit = applBankDtl.ValueSummationDebit__c !=null? applBankDtl.ValueSummationDebit__c : 0 ;
                                            bankDtl.inwardReturnsCount = applBankDtl.InwardReturnsCount__c !=null? applBankDtl.InwardReturnsCount__c : 0 ;
                                            bankDtl.outwardReturnsCount = applBankDtl.OutwardReturnsCount__c !=null? applBankDtl.OutwardReturnsCount__c : 0 ;
                                            bankDtl.stopPaymentCount = applBankDtl.StopPaymentCount__c !=null? applBankDtl.StopPaymentCount__c : 0 ;
                                            bankDtl.monthlyLimit = applBankDtl.MonthlyLimit__c !=null? applBankDtl.MonthlyLimit__c : 0 ;
                                            bankDtl.averageBankBalance = (bankDtl.balanceAt1st + bankDtl.balanceAt10th + bankDtl.balanceAt15th + bankDtl.balanceAt20th + bankDtl.balanceAt25th +bankDtl.balanceAt5th)/6;
                                            bankDtl.minBalanceCharges = applBankDtl.MinBalanceCharges__c!=null ? applBankDtl.MinBalanceCharges__c : 'N';   
                                            bankDtl.month = applBankDtl.Month__c;
                                            bankDtl.year = applBankDtl.Year__c;
                                            bankDtl.loanApplicationId = applBankDtl.ApplBanking__r.LoanAppl__c;
                                            
                                            monthBankDetailMap.put(applBankDtl.ApplBanking__r.LoanAppl__c,new Map<String,BankingDetailsWrapper>{key=>bankDtl});
                                            
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    system.debug('bankingSummaryTypeIdMap' + bankingSummaryTypeIdMap);
                    
                    if(!applBankingMap.isEmpty()){
                        system.debug('applBankingMap' + applBankingMap);
                        insert applBankingMap.values();
                        
                        for(ApplBanking__c appBank : [SELECT Id,Appl__c,LoanAppl__c,Summary_Type__c, Type__c FROM ApplBanking__c  WHERE Id IN:applBankingMap.values()]){
                            
                            if(appBank.Summary_Type__c!=null && appBank.LoanAppl__c!=null)
                                if(bankingSummaryTypeIdMap.containsKey(appBank.LoanAppl__c)){
                                    if(!bankingSummaryTypeIdMap.get(appBank.LoanAppl__c).containsKey(appBank.Summary_Type__c)){
                                        bankingSummaryTypeIdMap.get(appBank.LoanAppl__c).put(appBank.Summary_Type__c,appBank.Id);
                                    }
                                }
                            else{
                                bankingSummaryTypeIdMap.put(appBank.LoanAppl__c,new Map<String,String>{appBank.Summary_Type__c=>appBank.Id});
                            }
                        }
                    }
                    
                    
                    if(!monthBankDetailMap.isEmpty()){
                        
                        
                        List<ApplBankDetail__c> applBankDetailList = new List<ApplBankDetail__c>();
                        for(String loanApp : monthBankDetailMap.keySet()){
                            
                            if(monthBankDetailMap.containsKey(loanApp)){
                                Map<String,BankingDetailsWrapper> bankDetailsMap = monthBankDetailMap.get(loanApp);
                                if(bankDetailsMap!=null && !bankDetailsMap.isEmpty()){
                                    for(String key : bankDetailsMap.keySet()){
                                        BankingDetailsWrapper bankDtl = bankDetailsMap.get(key);
                                        ApplBankDetail__c applBankDetail = new ApplBankDetail__c();
                                        
                                        if(bankingSummaryMap.containskey(loanApp) && bankingSummaryMap.get(loanApp).containsKey(key)){
                                            applBankDetail.Id = bankingSummaryMap.get(loanApp).get(Key).Id;
                                        }
                                        else{ 
                                            if(bankingSummaryTypeIdMap.containsKey(loanApp) && bankingSummaryTypeIdMap.get(loanApp).containsKey(key.substringBefore(':'))){
                                                applBankDetail.ApplBanking__c = bankingSummaryTypeIdMap.get(loanApp).get(key.substringBefore(':'));   
                                            }
                                        }
                                        /*else {
                                            if(applBankingMap.containsKey(loanApp +':' + key.substringBefore(':'))){
                                                applBankDetail.ApplBanking__c = applBankingMap.get(loanApp +':' + key.substringBefore(':')).Id;
                                            }
                                            else{
                                                applBankingMap.put(loanApp +':' + key.substringBefore(':'), new ApplBanking__c(LoanAppl__c=bankDtl.loanApplicationId,Summary_Type__c=key.substringBefore(':'),Type__c='Consolidated Banking Summary'));
                                                applBankDetail.ApplBanking__c = applBankingMap.get(loanApp +':' + key.substringBefore(':')).Id;
                                            }
                                        }*/
                                        
                                        applBankDetail.BalanceAt_1st__c = bankDtl.balanceAt1st;
                                        applBankDetail.BalanceAt_10th__c = bankDtl.balanceAt10th;
                                        applBankDetail.BalanceAt_15th__c = bankDtl.balanceAt15th;
                                        applBankDetail.BalanceAt_20th__c = bankDtl.balanceAt20th;
                                        applBankDetail.BalanceAt_25th__c = bankDtl.balanceAt25th;
                                        applBankDetail.BalanceAt_5th__c = bankDtl.balanceAt5th; 
                                        applBankDetail.CountofDebit__c = bankDtl.countofDebit;
                                        applBankDetail.CountofCredit__c = bankDtl.countofCredit;
                                        applBankDetail.ValueSummationCredit__c = bankDtl.valueSummationCredit;
                                        applBankDetail.ValueSummationDebit__c = bankDtl.valueSummationDebit;
                                        applBankDetail.InwardReturnsCount__c = bankDtl.inwardReturnsCount;
                                        applBankDetail.OutwardReturnsCount__c = bankDtl.outwardReturnsCount;
                                        applBankDetail.StopPaymentCount__c = bankDtl.stopPaymentCount;
                                        applBankDetail.MonthlyLimit__c = bankDtl.monthlyLimit;
                                        applBankDetail.AverageBankBalance__c = bankDtl.averageBankBalance;
                                        applBankDetail.MinBalanceCharges__c = bankDtl.minBalanceCharges;    
                                        applBankDetail.Month__c = bankDtl.month ;
                                        applBankDetail.Year__c = bankDtl.year;
                                        
                                        applBankDetailList.add(applBankDetail);
                                        
                                    }
                                }
                            }
                        }
                        
                        /*if(!applBankingMap.isEmpty()){
                            system.debug('applBankingMap' + applBankingMap);
                            insert applBankingMap.values();
                            
                        }*/
                        if(!applBankDetailList.isEmpty()){
                            system.debug('applBankDetailList' + applBankDetailList);
                            upsert applBankDetailList;
                        }
                        
                    }
                }
            }
        } 
        catch(exception ex){
            system.debug('error message and line number '+ ex.getMessage() + 'line' + ex.getLineNumber());
            GlobalUtility.logMessage('Error', 'PerfiosRetrieveReportResponseProcessor class', 
                                         'upsertConsolidatedBankingSummary', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
    }
    
    public class BankingDetailsWrapper{
        public Double balanceAt1st;
        public Double balanceAt10th;
        public Double balanceAt15th;
        public Double balanceAt20th;
        public Double balanceAt25th;
        public Double balanceAt5th;
        public Double countofDebit;
        public Double countofCredit;
        public Double valueSummationCredit;
        public Double valueSummationDebit;
        public Double inwardReturnsCount;
        public Double outwardReturnsCount;
        public Double stopPaymentCount;
        public Double averageBankBalance;
        public Double monthlyLimit;
        public String minBalanceCharges;
        public String month;
        public String year;
        public String loanApplicationId;
        
    }
	
    //--------------------------------------------------------------
    public static Date getConvertedDate(string dateString){
        
        List<String> dateParts = dateString.split('-');
        if(dateParts!=null && dateParts.size()>=3){
            Integer year = Integer.valueOf(dateParts[0]);
            Integer month = Integer.valueOf(dateParts[1]);
            Integer day = Integer.valueOf(dateParts[2]);
            return Date.newInstance(year, month, day);
        }
        return null;
    }
    public static ApplBankDetail__c getApplBankDtlInstance(Id ApplicantBankingId,String accountNumber,String accountType,String type,String subType,String category,String subCategory,Boolean isLatest){
        return new ApplBankDetail__c(ApplBanking__c=ApplicantBankingId,Perfios_AccountNo__c = accountNumber,Perfios_AccountType__c = accountType,Type__c = type,SubType__c = subType,Category__c = category,SubCategory__c = subCategory,IsLatest__c=isLatest);
    }
    public static List<ApplBankDetail__c> processTransactions(Id ApplicantBankingId,String AccountNumber,String AccountType,String Type,String SubType,String Category,String SubCategory,List<PerfiosRetrieveReportResponseWrapper.Xns> transactions){
        List<ApplBankDetail__c> applBankingList = new List<ApplBankDetail__c>();
        if(ApplicantBankingId!=null && transactions!=null && Type!=null && SubType!=null){
            for(PerfiosRetrieveReportResponseWrapper.Xns xns : transactions){
                ApplBankDetail__c applBankDtl = new ApplBankDetail__c();
                applBankDtl.ApplBanking__c = ApplicantBankingId;
                applBankDtl.Type__c = Type;
                applBankDtl.SubType__c = SubType;
                applBankDtl.Category__c = Category!=null && String.isNotBlank(Category) ? Category : '';
                applBankDtl.SubCategory__c = SubCategory!=null && String.isNotBlank(SubCategory) ? SubCategory : '';
                applBankDtl.IsLatest__c = true;
                if(xns.PerfiosGroup!=null){
                    applBankDtl.Group__c = Integer.ValueOf(xns.PerfiosGroup);
                }
                if(xns.PerfiosDate!=null && String.isNotBlank(xns.PerfiosDate)){
                    applBankDtl.Date__c = getConvertedDate(xns.PerfiosDate);
                }
                if(xns.chqNo!=null && String.isNotBlank(xns.chqNo)){
                    applBankDtl.ChequeNo__c = xns.chqNo;
                }
                if(xns.narration!=null && String.isNotBlank(xns.narration)){
                    applBankDtl.Narration__c = xns.narration;
                }
                if(xns.amount!=null){
                    applBankDtl.Amount__c = xns.amount;
                }
                if(xns.category!=null && String.isNotBlank(xns.category)){
                    applBankDtl.Perfios_Category__c = xns.category;
                }
                if(xns.balance!=null){
                    applBankDtl.Balance__c = xns.balance;
                }
                if(xns.mode!=null && String.isNotBlank(xns.mode)){
                    applBankDtl.Mode__c = xns.mode;
                }
                applBankingList.add(applBankDtl);
                
                
            }
            
        }
        return  applBankingList;
    }
    public static List<ApplBankDetail__c> processStatementDetails(Id ApplicantBankingId, List<PerfiosRetrieveReportResponseWrapper.StatementDetails> statementDetails){
        List<ApplBankDetail__c> applBankingList = new List<ApplBankDetail__c>();
        if(ApplicantBankingId!=null && statementDetails!=null){
            for(PerfiosRetrieveReportResponseWrapper.Statementdetails statementDetail : statementDetails){
                
                if(statementDetail.statementAccounts!=null && !statementDetail.statementAccounts.isEmpty()){
                    
                    for(PerfiosRetrieveReportResponseWrapper.StatementAccounts statementAccount : statementDetail.statementAccounts){
                        ApplBankDetail__c applBankDtl = new ApplBankDetail__c();
                        applBankDtl.ApplBanking__c = ApplicantBankingId;
                        applBankDtl.Type__c = 'Statement Details';
                        applBankDtl.SubType__c = 'Statement Accounts';
                        applBankDtl.IsLatest__c = true;
                        applBankDtl.Remarks__c = statementDetail.remarks!=null && String.isNotBlank(statementDetail.remarks) ? statementDetail.remarks : '';
                        applBankDtl.FileName__c = statementDetail.fileName!=null && String.isNotBlank(statementDetail.fileName) ? statementDetail.fileName : '';
                        applBankDtl.StatementStatus__c = statementDetail.statementStatus!=null && String.isNotBlank(statementDetail.statementStatus) ? statementDetail.statementStatus : '';
                        if(statementDetail.customerInfo!=null){
                            applBankDtl.Name__c = statementDetail.customerInfo.name!=null && String.isNotBlank(statementDetail.customerInfo.name) ? statementDetail.customerInfo.name : '';
                            applBankDtl.Address__c = statementDetail.customerInfo.address!=null && String.isNotBlank(statementDetail.customerInfo.address) ? statementDetail.customerInfo.address : '';
                            applBankDtl.Landline__c = statementDetail.customerInfo.landline!=null && String.isNotBlank(statementDetail.customerInfo.landline) ? statementDetail.customerInfo.landline : '';
                            applBankDtl.Mobile__c = statementDetail.customerInfo.mobile!=null && String.isNotBlank(statementDetail.customerInfo.mobile) ? statementDetail.customerInfo.mobile : '';
                            applBankDtl.Email__c = statementDetail.customerInfo.email!=null && String.isNotBlank(statementDetail.customerInfo.email) ? statementDetail.customerInfo.email : '';
                            applBankDtl.Pan__c = statementDetail.customerInfo.pan!=null && String.isNotBlank(statementDetail.customerInfo.pan) ? statementDetail.customerInfo.pan : '';
                            applBankDtl.Perfios_BankName__c = statementDetail.customerInfo.bank!=null && String.isNotBlank(statementDetail.customerInfo.bank) ? statementDetail.customerInfo.bank : '';
                        }
                        applBankDtl.AccountNo__c = statementAccount.accountNo!=null && String.isNotBlank(statementAccount.accountNo) ? statementAccount.accountNo : '';
                        applBankDtl.AccountType__c = statementAccount.accountType!=null && String.isNotBlank(statementAccount.accountType) ? statementAccount.accountType : '';
                        if(statementAccount.xnsStartDate!=null && String.isNotBlank(statementAccount.xnsStartDate)){
                            applBankDtl.TransactionStartDate__c = getConvertedDate(statementAccount.xnsStartDate);
                        }
                        if(statementAccount.xnsEndDate!=null && String.isNotBlank(statementAccount.xnsEndDate)){
                            applBankDtl.TransactionEndDate__c = getConvertedDate(statementAccount.xnsEndDate);
                        }
                        applBankingList.add(applBankDtl);
                    }
                }
                else{
                    if(statementDetail.remarks!=null || statementDetail.customerInfo!=null){
                        ApplBankDetail__c applBankDtl = new ApplBankDetail__c();
                        applBankDtl.ApplBanking__c = ApplicantBankingId;
                        applBankDtl.Type__c = 'Statement Details';
                        applBankDtl.IsLatest__c = true;
                        applBankDtl.Remarks__c = String.isNotBlank(statementDetail.remarks) ? statementDetail.remarks : '';
                        if(statementDetail.customerInfo!=null){
                            applBankDtl.Name__c = statementDetail.customerInfo.name!=null && String.isNotBlank(statementDetail.customerInfo.name) ? statementDetail.customerInfo.name : '';
                            applBankDtl.Address__c = statementDetail.customerInfo.address!=null && String.isNotBlank(statementDetail.customerInfo.address) ? statementDetail.customerInfo.address : '';
                            applBankDtl.Landline__c = statementDetail.customerInfo.landline!=null && String.isNotBlank(statementDetail.customerInfo.landline) ? statementDetail.customerInfo.landline : '';
                            applBankDtl.Mobile__c = statementDetail.customerInfo.mobile!=null && String.isNotBlank(statementDetail.customerInfo.mobile) ? statementDetail.customerInfo.mobile : '';
                            applBankDtl.Email__c = statementDetail.customerInfo.email!=null && String.isNotBlank(statementDetail.customerInfo.email) ? statementDetail.customerInfo.email : '';
                            applBankDtl.Pan__c = statementDetail.customerInfo.pan!=null && String.isNotBlank(statementDetail.customerInfo.pan) ? statementDetail.customerInfo.pan : '';
                            applBankDtl.Perfios_BankName__c = statementDetail.customerInfo.bank!=null && String.isNotBlank(statementDetail.customerInfo.bank) ? statementDetail.customerInfo.bank : '';
                        }
                        applBankingList.add(applBankDtl);
                    }
                }        
            }
        }
        return applBankingList;
    }
    public static List<ApplBankDetail__c> processAccountXns(Id ApplicantBankingId,List<PerfiosRetrieveReportResponseWrapper.AccountXns> transactions){
        List<ApplBankDetail__c> applBankingList = new List<ApplBankDetail__c>();
        if(ApplicantBankingId!=null && transactions!=null ){
            for(PerfiosRetrieveReportResponseWrapper.AccountXns accXns : transactions){
                if(accXns.Xns!=null && !accXns.Xns.isEmpty()){
                    for(PerfiosRetrieveReportResponseWrapper.Xns xns : accXns.Xns){
                        ApplBankDetail__c applBankDtl = new ApplBankDetail__c();
                        applBankDtl.ApplBanking__c = ApplicantBankingId;
                        applBankDtl.Type__c = 'Account Transactions';
                        applBankDtl.IsLatest__c = true;
                        
                        if(accXns.accountNo!=null && String.isNotBlank(accXns.accountNo)){
                            applBankDtl.AccountNo__c = accXns.accountNo;
                        }
                        if(accXns.accountType!=null && String.isNotBlank(accXns.accountType)){
                            applBankDtl.AccountType__c = accXns.accountType;
                        }
                        
                        if(xns.PerfiosGroup!=null){
                            applBankDtl.Group__c = Integer.ValueOf(xns.PerfiosGroup);
                        }
                        if(xns.PerfiosDate!=null && String.isNotBlank(xns.PerfiosDate)){
                            applBankDtl.Date__c = getConvertedDate(xns.PerfiosDate);
                        }
                        if(xns.chqNo!=null && String.isNotBlank(xns.chqNo)){
                            applBankDtl.ChequeNo__c = xns.chqNo;
                        }
                        if(xns.narration!=null && String.isNotBlank(xns.narration)){
                            applBankDtl.Narration__c = xns.narration;
                        }
                        if(xns.amount!=null){
                            applBankDtl.Amount__c = xns.amount;
                        }
                        if(xns.category!=null && String.isNotBlank(xns.category)){
                            applBankDtl.Perfios_Category__c = xns.category;
                        }
                        if(xns.balance!=null){
                            applBankDtl.Balance__c = xns.balance;
                        }
                        if(xns.mode!=null && String.isNotBlank(xns.mode)){
                            applBankDtl.Mode__c = xns.mode;
                        }
                        applBankingList.add(applBankDtl);
                    }
                }
                else{
                    
                    if(accXns.accountNo!=null || accXns.accountType!=null){
                        ApplBankDetail__c applBankDtl = new ApplBankDetail__c();
                        applBankDtl.ApplBanking__c = ApplicantBankingId;
                        applBankDtl.Type__c = 'Account Transactions';
                        applBankDtl.IsLatest__c = true;
                        if(String.isNotBlank(accXns.accountNo)){
                            applBankDtl.AccountNo__c = accXns.accountNo;
                        }
                        if(String.isNotBlank(accXns.accountType)){
                            applBankDtl.AccountType__c = accXns.accountType;
                        }
                        applBankingList.add(applBankDtl);
                    }
                }
            }
        }
        return  applBankingList;
    }
    public static List<ApplBankDetail__c> processAdditionalBankingMonthlyDetails(Id ApplicantBankingId,List<PerfiosRetrieveReportResponseWrapper.BankingMonthlyData1> monthlyData){
        List<ApplBankDetail__c> applBankingList = new List<ApplBankDetail__c>();
        if(ApplicantBankingId!=null && monthlyData!=null){
            for(PerfiosRetrieveReportResponseWrapper.BankingMonthlyData1 monthyData : monthlyData){
                ApplBankDetail__c applBankDtl = new ApplBankDetail__c();
                applBankDtl.ApplBanking__c = ApplicantBankingId;
                applBankDtl.Type__c = 'Additional Banking Monthly Details';
                applBankDtl.IsLatest__c = true;
                applBankDtl.MonthName__c = monthyData.monthName!=null && String.isNotBlank(monthyData.monthName) ? monthyData.monthName : '';
                applBankDtl.CountofCredit__c = monthyData.credits;
                applBankDtl.ValueSummationCredit__c = monthyData.totalCredit;
                applBankDtl.CountofDebit__c = monthyData.debits;
                applBankDtl.ValueSummationDebit__c = monthyData.totalDebit;
                applBankDtl.CashDepositPercent__c = monthyData.cashDepositPercent;
                applBankDtl.CashWithdrawalPercent__c = monthyData.cashWithdrawalPercent;
                applBankDtl.InwBouncePercent__c = monthyData.inwBouncePercent;
                applBankDtl.InwTechBouncePercent__c = monthyData.inwTechBouncePercent;
                applBankDtl.InwNonTechBouncePercent__c = monthyData.inwNonTechBouncePercent;
                applBankDtl.OutwBouncePercent__c = monthyData.outwBouncePercent;
                applBankDtl.AvgOverdrawnDay__c = monthyData.avgOverdrawnDay;
                applBankDtl.InwardReturnsCount__c = monthyData.inwardBounces;
                applBankDtl.BankCharges__c = monthyData.bankCharges;
				applBankingList.add(applBankDtl);
				
                
            }
        }
        return  applBankingList;
    }
    public static List<ApplBankDetail__c> processAdditionalFedfinaMonthlyDetails(Id ApplicantBankingId,List<PerfiosRetrieveReportResponseWrapper.FedfinaMothlyData1> monthlyData){
        List<ApplBankDetail__c> applBankingList = new List<ApplBankDetail__c>();
        if(ApplicantBankingId!=null && monthlyData!=null){
            for(PerfiosRetrieveReportResponseWrapper.FedfinaMothlyData1 monthyData : monthlyData){
                ApplBankDetail__c applBankDtl = new ApplBankDetail__c();
                applBankDtl.ApplBanking__c = ApplicantBankingId;
                applBankDtl.Type__c = 'Additional Fedfina Monthly Details';
                applBankDtl.IsLatest__c = true;
                applBankDtl.MonthName__c = monthyData.monthName!=null && String.isNotBlank(monthyData.monthName) ? monthyData.monthName : '';
                applBankDtl.MinBalanceCharges__c = monthyData.belowMinBalPenalties!=null && String.isNotBlank(monthyData.belowMinBalPenalties) ? monthyData.belowMinBalPenalties : '';
                applBankDtl.AverageBankBalance__c =  monthyData.avgBalance;
        		applBankDtl.Utilization__c = monthyData.limitUtilization;
                applBankDtl.InwardReturnsCount__c = monthyData.inwardBounces;
        		applBankDtl.TradeCredits__c = monthyData.tradeCredits;
        		applBankDtl.TotalTradeCredit__c = monthyData.totalTradeCredit;
                applBankingList.add(applBankDtl);
            }
        }
        return  applBankingList;
    }
    public static List<ApplBankDetail__c> processAdditionalTransactionMonthlyDetails(Id ApplicantBankingId,List<PerfiosRetrieveReportResponseWrapper.MonthlyData1> monthlyData){
        List<ApplBankDetail__c> applBankingList = new List<ApplBankDetail__c>();
        if(ApplicantBankingId!=null && monthlyData!=null){
            for(PerfiosRetrieveReportResponseWrapper.MonthlyData1 monthyData : monthlyData){
                ApplBankDetail__c applBankDtl = new ApplBankDetail__c();
                applBankDtl.ApplBanking__c = ApplicantBankingId;
                applBankDtl.Type__c = 'Additional Transaction Monthly Details';
                applBankDtl.IsLatest__c = true;
                applBankDtl.MonthName__c = monthyData.monthName!=null && String.isNotBlank(monthyData.monthName) ? monthyData.monthName : '';
                applBankDtl.OtherTransfer__c = monthyData.otherTransfer;
                applBankDtl.TotalOtherTransfer__c = monthyData.totalOtherTransfer;
                applBankDtl.NonBusiness__c = monthyData.nonBusiness;
                applBankDtl.TotalNonBusiness__c = monthyData.totalNonBusiness;
                applBankDtl.OtherSupplier__c = monthyData.otherSupplier;
                applBankDtl.TotalOtherSupplier__c = monthyData.totalOtherSupplier;
                applBankDtl.InwardBouncesWithBankCharges__c = monthyData.inwardBouncesWithBankCharges;
				applBankingList.add(applBankDtl);
            }
        }
        return  applBankingList;
    }
    public static List<ApplBankDetail__c> processAdditionalSummaryInfo(Id ApplicantBankingId,List<PerfiosRetrieveReportResponseWrapper.SummaryInfo1> summaryInfo){
        List<ApplBankDetail__c> applBankingList = new List<ApplBankDetail__c>();
        if(ApplicantBankingId!=null && summaryInfo!=null){
            for(PerfiosRetrieveReportResponseWrapper.SummaryInfo1 info : summaryInfo){
                ApplBankDetail__c applBankDtl = new ApplBankDetail__c();
                applBankDtl.ApplBanking__c = ApplicantBankingId;
                applBankDtl.Type__c = 'Additional Summary Info';
                applBankDtl.IsLatest__c = true;
                applBankDtl.BalAvgLatestThree__c = info.balAvgLatestThree;
                applBankDtl.BalMinLatestThree__c = info.balMinLatestThree;
                applBankDtl.BalMaxLatestThree__c = info.balMaxLatestThree;
                applBankDtl.BalAvgLatestSix__c = info.balAvgLatestSix;
                applBankDtl.BalMinLatestSix__c = info.balMinLatestSix;
                applBankDtl.BalMaxLatestSix__c = info.balMaxLatestSix;
                applBankDtl.GrossDebitLatestThree__c = info.grossDebitLatestThree;
                applBankDtl.TotalGrossDebitLatestThree__c = info.totalGrossDebitLatestThree;
                applBankDtl.CashWithdrawalLatestThree__c = info.cashWithdrawalLatestThree;
                applBankDtl.TotalCashWithdrawalLatestThree__c = info.totalCashWithdrawalLatestThree;
                applBankDtl.ChqIssuesLatestThree__c = info.chqIssuesLatestThree;
                applBankDtl.TotalChqIssuesLatestThree__c = info.totalChqIssuesLatestThree;
                applBankDtl.InwChqBounceLatestThree__c = info.inwChqBounceLatestThree;
                applBankDtl.TotalInwChqBounceLastestThree__c = info.totalInwChqBounceLatestThree;
                applBankDtl.DebitsSCLatestThree__c = info.debitsSCLatestThree;
                applBankDtl.TotalDebitsSCLatestThree__c = info.totalDebitsSCLatestThree;
                applBankDtl.EMIOrLoansLatestThree__c = info.emiOrLoansLatestThree;
                applBankDtl.TotalEMIOrLoanLatestThree__c = info.totalEmiOrLoanLatestThree;
                applBankDtl.InwEMIBounceLatestThree__c = info.inwEMIBounceLatestThree;
                applBankDtl.TotalInwEMIBounceLatestThree__c = info.totalInwEMIBounceLatestThree;
                applBankDtl.GrossDebitLatestSix__c = info.grossDebitLatestSix;
                applBankDtl.TotalGrossDebitLatestSix__c = info.totalGrossDebitLatestSix;
                applBankDtl.CashWithdrawalLatestSix__c = info.cashWithdrawalLatestSix;
                applBankDtl.TotalCashWithdrawalLatestSix__c = info.totalCashWithdrawalLatestSix;
                applBankDtl.ChqIssuesLatestSix__c = info.chqIssuesLatestSix;
                applBankDtl.TotalChqIssuesLatestSix__c = info.totalChqIssuesLatestSix;
                applBankDtl.InwChqBounceLatestSix__c = info.inwChqBounceLatestSix;
                applBankDtl.TotalInwChqBounceLatestSix__c = info.totalInwChqBounceLatestSix;
                applBankDtl.DebitsSCLatestSix__c = info.debitsSCLatestSix;
                applBankDtl.TotalDebitsSCLatestSix__c = info.totalDebitsSCLatestSix;
                applBankDtl.EMIOrLOansLatestSix__c = info.emiOrLoansLatestSix;
                applBankDtl.TotalEMIOrLOansLatestSix__c = info.totalEmiOrLoanLatestSix;
                applBankDtl.InwEMIBounceLatestSix__c = info.inwEMIBounceLatestSix;
                applBankDtl.TotalInwEMIBounceLatestSix__c = info.totalInwEMIBounceLatestSix;
                applBankDtl.GrossCreditLatestThree__c = info.grossCreditLatestThree;
                applBankDtl.TotalGrossCreditLatestThree__c = info.totalGrossCreditLatestThree;
                applBankDtl.CashDepositLatestThree__c = info.cashDepositLatestThree;
                applBankDtl.TotalCashDepositLatestThree__c = info.totalCashDepositLatestThree;
                applBankDtl.ChqDepositLatestThree__c = info.chqDepositLatestThree;
                applBankDtl.TotalChqDepositLatestThree__c = info.totalChqDepositLatestThree;
                applBankDtl.OutwChqBounceLatestThree__c = info.outwChqBounceLatestThree;
                applBankDtl.TotalOutwChqBounceLatestThree__c = info.totalOutwChqBounceLatestThree;
                applBankDtl.CreditsSCLatestThree__c = info.creditsSCLatestThree;
                applBankDtl.TotalCreditsSCLatestThree__c = info.totalCreditsSCLatestThree;
                applBankDtl.LoanDisbursalLatestThree__c = info.loanDisbursalLatestThree;
                applBankDtl.TotalLoanDisbursalLatestThree__c = info.totalLoanDisbursalLatestThree;
                applBankDtl.GrossCreditLatestSix__c = info.grossCreditLatestSix;
                applBankDtl.TotalGrossCreditLatestSix__c = info.totalGrossCreditLatestSix;
                applBankDtl.CashDepositLatestSix__c = info.cashDepositLatestSix;
                applBankDtl.TotalCashDepositLatestSix__c = info.totalCashDepositLatestSix;
                applBankDtl.ChqDepositLatestSix__c = info.chqDepositLatestSix;
                applBankDtl.TotalChqDepositLatestSix__c = info.totalChqDepositLatestSix;
                applBankDtl.OutwChqBounceLatestSix__c = info.outwChqBounceLatestSix;
                applBankDtl.TotalOutwChqBounceLatestSix__c = info.totalOutwChqBounceLatestSix;
                applBankDtl.CreditsSCLatestSix__c = info.creditsSCLatestSix;
                applBankDtl.CreditsSCLatestSix__c = info.totalCreditsSCLatestSix;
                applBankDtl.LoanDisbursalLatestSix__c = info.loanDisbursalLatestSix;
                applBankDtl.TotalLoanDisbursalLatestSix__c = info.totalLoanDisbursalLatestSix;
                applBankDtl.GrossChargesLatestThree__c = info.grossChargesLatestThree;
                applBankDtl.TotalGrossChargesLatestThree__c = info.totalGrossChargesLatestThree;
                applBankDtl.InwChargesLatestThree__c = info.inwChargesLatestThree;
                applBankDtl.TotalInwChargesLatestThree__c = info.totalInwChargesLatestThree;
                applBankDtl.OutwChargesLatestThree__c = info.outwChargesLatestThree;
                applBankDtl.TotalOutwChargesLatestThree__c = info.totalOutwChargesLatestThree;
                applBankDtl.BelowMinBalPenaltiesLatestThree__c = info.belowMinBalPenaltiesLatestThree;
                applBankDtl.TotalBelowMinBalPenaltyLatestThree__c = info.totalBelowMinBalPenaltyLatestThree;
                applBankDtl.PenalChargesLatestThree__c = info.penalChargesLatestThree;
                applBankDtl.TotalPenalChargeLatestThree__c = info.totalPenalChargeLatestThree;
                applBankDtl.InterestChargesLatestThree__c = info.interestChargesLatestThree;
                applBankDtl.TotalInterestChargedLatestThree__c = info.totalInterestChargedLatestThree;
                applBankDtl.BankChargesLatestThree__c = info.bankChargesLatestThree;
                applBankDtl.TotalBankChargeLatestThree__c = info.totalBankChargeLatestThree;
                applBankDtl.GrossChargesLatestSix__c = info.grossChargesLatestSix;
                applBankDtl.TotalGrossChargesLatestSix__c = info.totalGrossChargesLatestSix;
                applBankDtl.InwChargesLatestSix__c = info.inwChargesLatestSix;
                applBankDtl.TotalInwChargesLatestSix__c = info.totalInwChargesLatestSix;
                applBankDtl.OutwChargesLatestSix__c = info.outwChargesLatestSix;
                applBankDtl.TotalOutwChargesLatestSix__c = info.totalOutwChargesLatestSix;
                applBankDtl.BelowMinBalPenaltiesLatestSix__c = info.belowMinBalPenaltiesLatestSix;
                applBankDtl.TotalBelowMinBalPenaltyLatestSix__c = info.totalBelowMinBalPenaltyLatestSix;
                applBankDtl.PenalChargesLatestSix__c = info.penalChargesLatestSix;
                applBankDtl.TotalPenalChargeLatestSix__c = info.totalPenalChargeLatestSix;
                applBankDtl.InterestChargesLatestSix__c = info.interestChargesLatestSix;
                applBankDtl.TotalInterestChargesLatestSix__c = info.totalInterestChargedLatestSix;
                applBankDtl.BankChargesLatestSix__c = info.bankChargesLatestSix;
                applBankDtl.TotalBankChargesLatestSix__c = info.totalBankChargeLatestSix;
                applBankingList.add(applBankDtl);
                
            }
        }
        return  applBankingList;    
    }
    public static List<ApplBankDetail__c> processAccountAnalysis(Id ApplicantBankingId, List<PerfiosRetrieveReportResponseWrapper.AccountAnalysis> accountAnalysis){
        List<ApplBankDetail__c> appBankDetialList = new List<ApplBankDetail__c>();
        for(PerfiosRetrieveReportResponseWrapper.AccountAnalysis account : accountAnalysis){
            
            String accountNumber = account.accountNo!=null && String.isNotBlank(account.accountNo) ? account.accountNo : '';
            String accountType = account.accountType!=null && String.isNotBlank(account.accountType) ? account.accountType : '';
            
            //Loan Track Details
            if(account.loanTrackDetails!=null && !account.loanTrackDetails.isEmpty()){
                for(PerfiosRetrieveReportResponseWrapper.LoanTrackDetails details : account.loanTrackDetails){
                    ApplBankDetail__c applBankDtl = new ApplBankDetail__c();
                    applBankDtl.ApplBanking__c = ApplicantBankingId;
                    applBankDtl.Type__c = 'Account Analysis';
                    applBankDtl.SubType__c = 'Loan Track Details';
                    applBankDtl.IsLatest__c = true;
                    applBankDtl.Perfios_AccountNo__c = accountNumber;
                    applBankDtl.Perfios_AccountType__c = accountType;
                    applBankDtl.Amount__c = details.amount;
                    applBankDtl.Perfios_Category__c = String.isNotBlank(details.category) ? details.category : '';
                    applBankDtl.TransactionDates__c = String.isNotBlank(details.PerfiosDates) ? details.PerfiosDates : '';
                    appBankDetialList.add(applBankDtl);
                    
                }
            }
            
            //Summary Info
            if(account.summaryInfo!=null){
                if(account.summaryInfo.total!=null){
                    ApplBankDetail__c applBankDtl = new ApplBankDetail__c();
                    applBankDtl.ApplBanking__c = ApplicantBankingId;
                    applBankDtl.Type__c = 'Account Analysis';
                    applBankDtl.SubType__c = 'Summary Info';
                    applBankDtl.SummaryType__c = 'Total';
                    applBankDtl.IsLatest__c = true;
                    applBankDtl.Perfios_AccountNo__c = accountNumber;
                    applBankDtl.Perfios_AccountType__c = accountType;
                    applBankDtl.InstitutionName__c = account.summaryInfo.instName!=null && string.isNotBlank(account.summaryInfo.instName) ? account.summaryInfo.instName : '';
                    applBankDtl.AccountNo__c = account.summaryInfo.accNo!=null && string.isNotBlank(account.summaryInfo.accNo) ? account.summaryInfo.accNo : '';
                    applBankDtl.AccountType__c = account.summaryInfo.accType!=null && string.isNotBlank(account.summaryInfo.accType) ? account.summaryInfo.accType : '';
                    applBankDtl.FullMonthCount__c = account.summaryInfo.fullMonthCount;
                    appBankDetialList.add(processSummaryInfo(applBankDtl,account.summaryInfo.total));
                }
                if(account.summaryInfo.average!=null){
                    ApplBankDetail__c applBankDtl = new ApplBankDetail__c();
                    applBankDtl.ApplBanking__c = ApplicantBankingId;
                    applBankDtl.Type__c = 'Account Analysis';
                    applBankDtl.SubType__c = 'Summary Info';
                    applBankDtl.SummaryType__c = 'Average';
                    applBankDtl.IsLatest__c = true;
                    applBankDtl.Perfios_AccountNo__c = accountNumber;
                    applBankDtl.Perfios_AccountType__c = accountType;
                    applBankDtl.InstitutionName__c = account.summaryInfo.instName!=null && string.isNotBlank(account.summaryInfo.instName) ? account.summaryInfo.instName : '';
                    applBankDtl.AccountNo__c = account.summaryInfo.accNo!=null && string.isNotBlank(account.summaryInfo.accNo) ? account.summaryInfo.accNo : '';
                    applBankDtl.AccountType__c = account.summaryInfo.accType!=null && string.isNotBlank(account.summaryInfo.accType) ? account.summaryInfo.accType : '';
                    applBankDtl.FullMonthCount__c = account.summaryInfo.fullMonthCount;
                    appBankDetialList.add(processSummaryInfo(applBankDtl,account.summaryInfo.average));
                    
                }
            }
            
            //Monthly Details
            //if(account.monthlyDetails!=null && !account.monthlyDetails.isEmpty()){
            //}
            
            //Partial Month Details
            if(account.partialMonthDetails!=null && !account.partialMonthDetails.isEmpty()){
                List<ApplBankDetail__c> monthlyData = processPartialMonthDetails(ApplicantBankingId,accountNumber,accountType,'Account Analysis','Partial Month Details',account.partialMonthDetails);
                if(monthlyData!=null && !monthlyData.isEmpty()){
                    appBankDetialList.addAll(monthlyData);
                }
            }
            
            //EOD Balances
            if(account.eODBalances!=null && !account.eODBalances.isEmpty()){
                List<ApplBankDetail__c> balances = processEODBalances(ApplicantBankingId,accountNumber,accountType,'Account Analysis','EOD Balances',account.eODBalances);
                if(balances!=null && !balances.isEmpty()){
                   appBankDetialList.addAll(balances);
                }
            }
            
            //Partial Month EODBalances
            if(account.partialMonthEODBalances!=null && !account.partialMonthEODBalances.isEmpty()){
                List<ApplBankDetail__c> balances = processEODBalances(ApplicantBankingId,accountNumber,accountType,'Account Analysis','Partial Month EOD Balances',account.partialMonthEODBalances);
            	if(balances!=null && !balances.isEmpty()){
                    appBankDetialList.addAll(balances);
                }
            }
            
            //Online CreditXns
            if(account.onlineCreditXns!=null && !account.onlineCreditXns.isEmpty()){
                List<ApplBankDetail__c> transactions = processTransactions(ApplicantBankingId,accountNumber,accountType,'Account Analysis','Online Credit Transactions','','',account.onlineCreditXns);
                if(transactions!=null && !transactions.isEmpty()){
                    appBankDetialList.addAll(transactions);
                }
            }
            
            //Top 5 Funds Received
            if(account.top5FundsReceived!=null && !account.top5FundsReceived.isEmpty()){
                List<ApplBankDetail__c> transactions = processTop5Funds(ApplicantBankingId,accountNumber,accountType,'Account Analysis','Top  5 Funds Received',account.top5FundsReceived);
                if(transactions!=null && !transactions.isEmpty()){
                    appBankDetialList.addAll(transactions);
                }
            }
            
            //Top 10 Payments Received
            if(account.top10PaymentsReceived!=null && !account.top10PaymentsReceived.isEmpty()){
                List<ApplBankDetail__c> transactions = processTop10Payments(ApplicantBankingId,accountNumber,accountType,'Account Analysis','Top 10 Payments Received',account.top10PaymentsReceived);
                if(transactions!=null && !transactions.isEmpty()){
                    appBankDetialList.addAll(transactions);
                }
            }
            
            //EMI LOANXns
            if(account.eMILOANXns!=null && !account.eMILOANXns.isEmpty()){
                List<ApplBankDetail__c> transactions = processTransactions(ApplicantBankingId,accountNumber,accountType,'Account Analysis','EMI Loan Transactions','','',account.eMILOANXns);
                if(transactions!=null && !transactions.isEmpty()){
                    appBankDetialList.addAll(transactions);
                }
            }
            
            //SalaryXns
            if(account.salaryXns!=null && !account.salaryXns.isEmpty()){
                List<ApplBankDetail__c> transactions = processTransactions(ApplicantBankingId,accountNumber,accountType,'Account Analysis','Salary Transactions','','',account.salaryXns);
                if(transactions!=null && !transactions.isEmpty()){
                    appBankDetialList.addAll(transactions);
                }
            }
            
            //Online DebitXns
            if(account.onlineDebitXns!=null && !account.onlineDebitXns.isEmpty()){
                List<ApplBankDetail__c> transactions = processTransactions(ApplicantBankingId,accountNumber,accountType,'Account Analysis','Online Debit Transactions','','',account.onlineDebitXns);
                if(transactions!=null && !transactions.isEmpty()){
                    appBankDetialList.addAll(transactions);
                }
            }
            
            //Top 5 Funds Transferred
            if(account.top5FundsTransferred!=null && !account.top5FundsTransferred.isEmpty()){
                List<ApplBankDetail__c> transactions = processTop5Funds(ApplicantBankingId,accountNumber,accountType,'Account Analysis','Top 5 Funds Transferred',account.top5FundsTransferred);
                if(transactions!=null && !transactions.isEmpty()){
                    appBankDetialList.addAll(transactions);
                }
            }
            
            //Top 10 Payments Made
            if(account.top10PaymentsMade!=null && !account.top10PaymentsMade.isEmpty()){
                List<ApplBankDetail__c> transactions = processTop10Payments(ApplicantBankingId,accountNumber,accountType,'Account Analysis','Top 10 Payments Made',account.top10PaymentsMade);
                if(transactions!=null && !transactions.isEmpty()){
                    appBankDetialList.addAll(transactions);
                }
            }
            
            //Inward EMI BounceXns
            if(account.inwEMIBounceXns!=null && !account.inwEMIBounceXns.isEmpty()){
                List<ApplBankDetail__c> transactions = processTransactions(ApplicantBankingId,accountNumber,accountType,'Account Analysis','Inwards EMI Bounce Transactions','','',account.inwEMIBounceXns);
                if(transactions!=null && !transactions.isEmpty()){
                    appBankDetialList.addAll(transactions);
                }
            }
            
            //Regular Credits
            if(account.regularCredits!=null && !account.regularCredits.isEmpty()){
                List<ApplBankDetail__c> transactions = processTransactions(ApplicantBankingId,accountNumber,accountType,'Account Analysis','Regular Credits','','',account.regularCredits);
                if(transactions!=null && !transactions.isEmpty()){
                   appBankDetialList.addAll(transactions);
                }
            }
            
            //Regular Debits
            if(account.regularDebits!=null && !account.regularDebits.isEmpty()){
                List<ApplBankDetail__c> transactions = processTransactions(ApplicantBankingId,accountNumber,accountType,'Account Analysis','Regular Debits','','',account.regularDebits);
                if(transactions!=null && !transactions.isEmpty()){
                    appBankDetialList.addAll(transactions);
                }
            }
            
            //Bounced Or Penal ChargeXns
            if(account.bouncedOrPenalChargeXns!=null && !account.bouncedOrPenalChargeXns.isEmpty()){
                List<ApplBankDetail__c> transactions = processTransactions(ApplicantBankingId,accountNumber,accountType,'Account Analysis','Bounced Or Penal Charge Transactions','','',account.bouncedOrPenalChargeXns);
                if(transactions!=null && !transactions.isEmpty()){
                    appBankDetialList.addAll(transactions);
                }
            }
            
            //Transfer From To Inter GroupXns
            if(account.transferFromToInterGroupXns!=null && !account.transferFromToInterGroupXns.isEmpty()){
                List<ApplBankDetail__c> transactions = processTransactions(ApplicantBankingId,accountNumber,accountType,'Account Analysis','Transfer From To InterGroup Transactions','','',account.transferFromToInterGroupXns);
                if(transactions!=null && !transactions.isEmpty()){
                    appBankDetialList.addAll(transactions);
                }
            }
            
            //FCU Analysis
            if(account.fCUAnalysis!=null){
                List<ApplBankDetail__c> fCUAnalysis = processFCUAnalysis(ApplicantBankingId,accountNumber,accountType,'Account Analysis','FCU Analysis',account.fCUAnalysis);
                if(fCUAnalysis!=null && !fCUAnalysis.isEmpty()){
                    appBankDetialList.addAll(fCUAnalysis);
                }
            }
            
        }
        return  appBankDetialList;    
    }
    public static ApplBankDetail__c processSummaryInfo(ApplBankDetail__c applBankDtl, PerfiosRetrieveReportResponseWrapper.Summary summary){
        if(applBankDtl!=null && summary!=null){
            applBankDtl.Utilization__c = summary.avgUtilization;
            applBankDtl.BalanceAt_1st__c = summary.bal1;
            applBankDtl.BalanceAt_10th__c = summary.bal10;
            applBankDtl.BalanceAt_15th__c = summary.bal15;
            applBankDtl.BalanceAt_20th__c = summary.bal20;
            applBankDtl.BalanceAt_25th__c = summary.bal25;
            applBankDtl.BalanceAt_5th__c = summary.bal5;
            applBankDtl.AverageBankBalance__c = summary.balAvg;
            applBankDtl.MaxBalance__c = summary.balMax;
            applBankDtl.MinBalance__c = summary.balMin;
            applBankDtl.BankCharges__c = summary.bankCharges;
            applBankDtl.BelowMinBalPenalties__c = summary.belowMinBalPenalties;
            applBankDtl.CardSettlements__c = summary.cardSettlements;
            applBankDtl.CashBacks__c = summary.cashBacks;
            applBankDtl.CashDeposits__c = summary.cashDeposits;
            applBankDtl.CashWithdrawals__c = summary.cashWithdrawals;
            applBankDtl.ChequeDeposits__c = summary.chqDeposits;
            applBankDtl.ChequeIssues__c = summary.chqIssues;
            applBankDtl.CreditCardPayments__c = summary.creditCardPayments;
            applBankDtl.CountofCredit__c = summary.credits;
            applBankDtl.CreditsSC__c = summary.creditsSC;
            applBankDtl.CreditsSelf__c = summary.creditsSelf;
            applBankDtl.CountofDebit__c = summary.debits;
            applBankDtl.DebitsSC__c = summary.debitsSC;
            applBankDtl.DebitsSelf__c = summary.debitsSelf;
            applBankDtl.DpLimit__c = summary.dpLimit;
            applBankDtl.EMIOrLoans__c = summary.emiOrLoans;
            applBankDtl.HouseRent__c = summary.houseRent;
            applBankDtl.InsuranceExpenses__c = summary.insuranceExpenses;
            applBankDtl.Interestcharges__c = summary.interestCharges;
            applBankDtl.InterestIncomes__c = summary.interestIncomes;
            applBankDtl.InterestPaymentDelay__c = summary.intPayDelay;
            applBankDtl.InvestmentIncomes__c = summary.invIncomes;
            applBankDtl.InwBounceCharges__c = summary.inwBounceCharges;
            applBankDtl.InwBounceNonTechnical__c = summary.inwBounceNonTechnical;
            applBankDtl.InwardReturnsCount__c = summary.inwBounces;
            applBankDtl.InwBounceTechnical__c = summary.inwBounceTechnical;
            applBankDtl.InwChqBounceNonTechnical__c = summary.inwChqBounceNonTechnical;
            applBankDtl.InwEMIBounces__c = summary.inwEMIBounces;
            applBankDtl.LoanDisbursals__c = summary.loanDisbursals;
            applBankDtl.OnlineShopping__c = summary.onlineShopping;
            applBankDtl.OtherExpenses__c = summary.otherExpenses;
            applBankDtl.OtherIncomes__c = summary.otherIncomes;
            applBankDtl.OutwardBounceCharges__c = summary.outwBounceCharges;
            applBankDtl.OutwardReturnsCount__c = summary.outwBounces;
            applBankDtl.OutwChqBounces__c = summary.outwChqBounces;
            applBankDtl.OverDrawnAmountPeak__c = summary.overdrawnAmountPeak;
            applBankDtl.OverDrawnDays__c = summary.overdrawnDays;
            applBankDtl.OverDrawnDaysPeak__c = summary.overdrawnDaysPeak;
            applBankDtl.OverdrawnInstances__c = summary.overdrawnInstances;
            applBankDtl.PaymentFromTop5__c = summary.paymentFromTop5;
            applBankDtl.PaymentToTop5__c = summary.paymentToTop5;
            applBankDtl.PenalCharges__c = summary.penalCharges;
            applBankDtl.Pension__c = summary.pension;
            applBankDtl.POSExpenses__c = summary.posExpenses;
            applBankDtl.RentCredits__c = summary.rentCredits;
            applBankDtl.Salaries__c = summary.salaries;
            applBankDtl.SalaryPaid__c = summary.salaryPaid;
            applBankDtl.SNLimit__c = summary.snLimit;
            applBankDtl.StopPaymentCount__c = summary.stopPayments;
            applBankDtl.TaxPayment__c = summary.taxPayment;
            applBankDtl.TotalAvgCredit__c = summary.totalAvgCredit;
            applBankDtl.TotalBankCharge__c = summary.totalBankCharge;
            applBankDtl.TotalBelowMinBalPenalty__c = summary.totalBelowMinBalPenalty;
            applBankDtl.TotalCardSettlement__c = summary.totalCardSettlement;
            applBankDtl.TotalCashBacK__c = summary.totalCashBack;
            applBankDtl.TotalCashDeposit__c = summary.totalCashDeposit;
            applBankDtl.TotalCashWithdrawal__c = summary.totalCashWithdrawal;
            applBankDtl.TotalChqDeposit__c = summary.totalChqDeposit;
            applBankDtl.TotalChqIssue__c = summary.totalChqIssue;
            applBankDtl.ValueSummationCredit__c = summary.totalCredit;
            applBankDtl.TotalCreditCardPayment__c = summary.totalCreditCardPayment;
            applBankDtl.TotalCreditSC__c = summary.totalCreditSC;
            applBankDtl.TotalCreditSelf__c = summary.totalCreditSelf;
            applBankDtl.ValueSummationDebit__c = summary.totalDebit;
            applBankDtl.TotalDebitSC__c = summary.totalDebitSC;
            applBankDtl.TotalDebitSelf__c = summary.totalDebitSelf;
            applBankDtl.TotalEMIOrLoan__c = summary.totalEmiOrLoan;
            applBankDtl.TotalHouseRent__c = summary.totalHouseRent;
            applBankDtl.TotalInsuranceExpense__c = summary.totalInsuranceExpense;
            applBankDtl.TotalInterestCharged__c = summary.totalInterestCharged;
            applBankDtl.TotalInterestIncome__c = summary.totalInterestIncome;
            applBankDtl.TotalInvIncome__c = summary.totalInvIncome;
            applBankDtl.TotalInwBounce__c = summary.totalInwBounce;
            applBankDtl.TotalInwBounceCharge__c = summary.totalInwBounceCharge;
            applBankDtl.TotalInwChqBounceNonTechnical__c = summary.totalInwChqBounceNonTechnical;
            applBankDtl.TotalInwEMIBounce__c = summary.totalInwEMIBounce;
            applBankDtl.TotalInwEMIBounceNonTechnical__c = summary.totalInwEMIBounceNonTechnical;
            applBankDtl.TotalInwEMIBounceTechnical__c = summary.totalInwEMIBounceTechnical;
            applBankDtl.TotalLoanDisbursal__c = summary.totalLoanDisbursal;
            applBankDtl.TotalOnlineShopping__c = summary.totalOnlineShopping;
            applBankDtl.TotalOtherExpense__c = summary.totalOtherExpense;
            applBankDtl.TotalOtherIncome__c = summary.totalOtherIncome;
            applBankDtl.TotalOutwBounce__c = summary.totalOutwBounce;
            applBankDtl.TotalOutwBounceCharge__c = summary.totalOutwBounceCharge;
            applBankDtl.TotalOutwChqBounce__c = summary.totalOutwChqBounce;
            applBankDtl.TotalPaymentFromTop5__c = summary.totalPaymentFromTop5;
            applBankDtl.TotalPaymentToTop5__c = summary.totalPaymentToTop5;
            applBankDtl.TotalPenalCharge__c = summary.totalPenalCharge;
            applBankDtl.TotalPension__c = summary.totalPension;
            applBankDtl.TotalPOSExpense__c = summary.totalPosExpense;
            applBankDtl.TotalRentCredit__c = summary.totalRentCredit;
            applBankDtl.TotalSalary__c = summary.totalSalary;
            applBankDtl.TotalSalaryPaid__c = summary.totalSalaryPaid;
            applBankDtl.TotalTaxPayment__c = summary.totalTaxPayment;
            applBankDtl.TotalTransferToWallet__c = summary.totalTransferToWallet;
            applBankDtl.TotalUPICredit__c = summary.totalUpiCredit;
            applBankDtl.TotalUPIDebit__c = summary.totalUpiDebit;
            applBankDtl.TotalUtilityExpense__c = summary.totalUtilityExpense;
            applBankDtl.TransferToWallet__c = summary.transferToWallet;
            applBankDtl.UPICredits__c = summary.upiCredits;
            applBankDtl.UPIDebits__c = summary.upiDebits;
            applBankDtl.UtilityExpenses__c = summary.utilityExpenses;
            applBankDtl.TransactionsCount__c = summary.xnsCount;
            
        }
        
        return applBankDtl;
    }
    public static List<ApplBankDetail__c> processPartialMonthDetails(Id ApplicantBankingId,String accountNumber,String accountType, String Type, String SubType,List<PerfiosRetrieveReportResponseWrapper.MonthlyDetails> monthlyDetails){
        List<ApplBankDetail__c> applBankingList = new List<ApplBankDetail__c>();
        if(ApplicantBankingId!=null && Type!=null && SubType!=null && monthlyDetails!=null){
            for(PerfiosRetrieveReportResponseWrapper.MonthlyDetails detail : monthlyDetails){
                ApplBankDetail__c applBankDtl = new ApplBankDetail__c();
                applBankDtl.ApplBanking__c = ApplicantBankingId;
                applBankDtl.Type__c = Type;
                applBankDtl.SubType__c = SubType;
                applBankDtl.IsLatest__c = true;
                applBankDtl.Perfios_AccountNo__c = accountNumber;
                applBankDtl.Perfios_AccountType__c = accountType;
                applBankDtl.Utilization__c = detail.avgUtilization;
                applBankDtl.BalanceAt_1st__c = detail.bal1;
                applBankDtl.BalanceAt_10th__c = detail.bal10;
                applBankDtl.BalanceAt_15th__c = detail.bal15;
                applBankDtl.BalanceAt_20th__c = detail.bal20;
                applBankDtl.BalanceAt_25th__c = detail.bal25;
                applBankDtl.BalanceAt_5th__c = detail.bal5;
                applBankDtl.AverageBankBalance__c = detail.balAvg;
                //applBankDtl.DailyABBBalance__c = detail.balAvg;// Added
                applBankDtl.MaxBalance__c = detail.balMax;
                applBankDtl.MinBalance__c = detail.balMin;
                applBankDtl.BankCharges__c = detail.bankCharges;
                applBankDtl.BelowMinBalPenalties__c = detail.belowMinBalPenalties;
                //applBankDtl.MinBalanceCharges__c = detail.belowMinBalPenalties!=null ?  applBankDtl.MinBalanceCharges__c = detail.belowMinBalPenalties > 0 ? 'Y' : 'N' : ''; //Added
                applBankDtl.CardSettlements__c = detail.cardSettlements;
                applBankDtl.CashBacks__c = detail.cashBacks;
                applBankDtl.CashDeposits__c = detail.cashDeposits;
                applBankDtl.CashWithdrawals__c = detail.cashWithdrawals;
                applBankDtl.ChequeDeposits__c = detail.chqDeposits;
                applBankDtl.ChequeIssues__c = detail.chqIssues;
                applBankDtl.CreditCardPayments__c = detail.creditCardPayments;
                applBankDtl.CountofCredit__c = detail.credits;
                applBankDtl.CreditsSC__c = detail.creditsSC;
                applBankDtl.CreditsSelf__c = detail.creditsSelf;
                applBankDtl.CountofDebit__c = detail.debits;
                applBankDtl.DebitsSC__c = detail.debitsSC;
                applBankDtl.DebitsSelf__c = detail.debitsSelf;
                applBankDtl.DpLimit__c = detail.dpLimit;
                applBankDtl.EMIOrLoans__c = detail.emiOrLoans;
                applBankDtl.HouseRent__c = detail.houseRent;
                applBankDtl.InsuranceExpenses__c = detail.insuranceExpenses;
                applBankDtl.Interestcharges__c = detail.interestCharges;
                applBankDtl.InterestIncomes__c = detail.interestIncomes;
                applBankDtl.InterestPaymentDelay__c = detail.intPayDelay;
                applBankDtl.InvestmentIncomes__c = detail.invIncomes;
                applBankDtl.InwBounceCharges__c = detail.inwBounceCharges;
                applBankDtl.InwBounceNonTechnical__c = detail.inwBounceNonTechnical;
                applBankDtl.InwardReturnsCount__c = detail.inwBounces;
                applBankDtl.InwBounceTechnical__c = detail.inwBounceTechnical;
                applBankDtl.InwChqBounceNonTechnical__c = detail.inwChqBounceNonTechnical;
                applBankDtl.InwEMIBounces__c = detail.inwEMIBounces;
                applBankDtl.LoanDisbursals__c = detail.loanDisbursals;
                applBankDtl.MonthName__c = detail.monthName!=null && String.isNotBlank(detail.monthName) ? detail.monthName : '';
                applBankDtl.OnlineShopping__c = detail.onlineShopping;
                applBankDtl.OtherExpenses__c = detail.otherExpenses;
                applBankDtl.OtherIncomes__c = detail.otherIncomes;
                applBankDtl.OutwardBounceCharges__c = detail.outwBounceCharges;
                applBankDtl.OutwardReturnsCount__c = detail.outwBounces;
                applBankDtl.OutwChqBounces__c = detail.outwChqBounces;
                applBankDtl.OverDrawnAmountPeak__c = detail.overdrawnAmountPeak;
                applBankDtl.OverDrawnDays__c = detail.overdrawnDays;
                applBankDtl.OverDrawnDaysPeak__c = detail.overdrawnDaysPeak;
                applBankDtl.OverdrawnInstances__c = detail.overdrawnInstances;
                applBankDtl.PaymentFromTop5__c = detail.paymentFromTop5;
                applBankDtl.PaymentToTop5__c = detail.paymentToTop5;
                applBankDtl.PenalCharges__c = detail.penalCharges;
                applBankDtl.Pension__c = detail.pension;
                applBankDtl.POSExpenses__c = detail.posExpenses;
                applBankDtl.RentCredits__c = detail.rentCredits;
                applBankDtl.Salaries__c = detail.salaries;
                applBankDtl.SalaryPaid__c = detail.salaryPaid;
                applBankDtl.SNLimit__c = detail.snLimit;
                if(detail.startDate!=null && string.isNotBlank(detail.startDate)){
                    applBankDtl.StartDate__c = getConvertedDate(detail.startDate);
                }
                applBankDtl.StopPaymentCount__c = detail.stopPayments;
                applBankDtl.TaxPayment__c = detail.taxPayment;
                applBankDtl.TotalAvgCredit__c = detail.totalAvgCredit;
                applBankDtl.TotalBankCharge__c = detail.totalBankCharge;
                applBankDtl.TotalBelowMinBalPenalty__c = detail.totalBelowMinBalPenalty;
                applBankDtl.TotalCardSettlement__c = detail.totalCardSettlement;
                applBankDtl.TotalCashBacK__c = detail.totalCashBack;
                applBankDtl.TotalCashDeposit__c = detail.totalCashDeposit;
                applBankDtl.TotalCashWithdrawal__c = detail.totalCashWithdrawal;
                applBankDtl.TotalChqDeposit__c = detail.totalChqDeposit;
                applBankDtl.TotalChqIssue__c = detail.totalChqIssue;
                applBankDtl.ValueSummationCredit__c = detail.totalCredit;
                applBankDtl.TotalCreditCardPayment__c = detail.totalCreditCardPayment;
                applBankDtl.TotalCreditSC__c = detail.totalCreditSC;
                applBankDtl.TotalCreditSelf__c = detail.totalCreditSelf;
                applBankDtl.ValueSummationDebit__c = detail.totalDebit;
                applBankDtl.TotalDebitSC__c = detail.totalDebitSC;
                applBankDtl.TotalDebitSelf__c = detail.totalDebitSelf;
                applBankDtl.TotalEMIOrLoan__c = detail.totalEmiOrLoan;
                applBankDtl.TotalHouseRent__c = detail.totalHouseRent;
                applBankDtl.TotalInsuranceExpense__c = detail.totalInsuranceExpense;
                applBankDtl.TotalInterestCharged__c = detail.totalInterestCharged;
                applBankDtl.TotalInterestIncome__c = detail.totalInterestIncome;
                applBankDtl.TotalInvIncome__c = detail.totalInvIncome;
                applBankDtl.TotalInwBounce__c = detail.totalInwBounce;
                applBankDtl.TotalInwBounceCharge__c = detail.totalInwBounceCharge;
                applBankDtl.TotalInwChqBounceNonTechnical__c = detail.totalInwChqBounceNonTechnical;
                applBankDtl.TotalInwEMIBounce__c = detail.totalInwEMIBounce;
                applBankDtl.TotalInwEMIBounceNonTechnical__c = detail.totalInwEMIBounceNonTechnical;
                applBankDtl.TotalInwEMIBounceTechnical__c = detail.totalInwEMIBounceTechnical;
                applBankDtl.TotalLoanDisbursal__c = detail.totalLoanDisbursal;
                applBankDtl.TotalOnlineShopping__c = detail.totalOnlineShopping;
                applBankDtl.TotalOtherExpense__c = detail.totalOtherExpense;
                applBankDtl.TotalOtherIncome__c = detail.totalOtherIncome;
                applBankDtl.TotalOutwBounce__c = detail.totalOutwBounce;
                applBankDtl.TotalOutwBounceCharge__c = detail.totalOutwBounceCharge;
                applBankDtl.TotalOutwChqBounce__c = detail.totalOutwChqBounce;
                applBankDtl.TotalPaymentFromTop5__c = detail.totalPaymentFromTop5;
                applBankDtl.TotalPaymentToTop5__c = detail.totalPaymentToTop5;
                applBankDtl.TotalPenalCharge__c = detail.totalPenalCharge;
                applBankDtl.TotalPension__c = detail.totalPension;
                applBankDtl.TotalPOSExpense__c = detail.totalPosExpense;
                applBankDtl.TotalRentCredit__c = detail.totalRentCredit;
                applBankDtl.TotalSalary__c = detail.totalSalary;
                applBankDtl.TotalSalaryPaid__c = detail.totalSalaryPaid;
                applBankDtl.TotalTaxPayment__c = detail.totalTaxPayment;
                applBankDtl.TotalTransferToWallet__c = detail.totalTransferToWallet;
                applBankDtl.TotalUPICredit__c = detail.totalUpiCredit;
                applBankDtl.TotalUPIDebit__c = detail.totalUpiDebit;
                applBankDtl.TotalUtilityExpense__c = detail.totalUtilityExpense;
                applBankDtl.TransferToWallet__c = detail.transferToWallet;
                applBankDtl.UPICredits__c = detail.upiCredits;
                applBankDtl.UPIDebits__c = detail.upiDebits;
                applBankDtl.UtilityExpenses__c = detail.utilityExpenses;
                applBankDtl.TransactionsCount__c = detail.xnsCount;
                applBankingList.add(applBankDtl);
                
            }
        }
        
        return  applBankingList;
    }
    public static List<ApplBankDetail__c> processEODBalances(Id ApplicantBankingId,String accountNumber,String accountType, String Type, String SubType,List<PerfiosRetrieveReportResponseWrapper.EODBalances> eODBalances){
        List<ApplBankDetail__c> applBankingList = new List<ApplBankDetail__c>();
        if(ApplicantBankingId!=null && Type!=null && SubType!=null && eODBalances!=null){
            for(PerfiosRetrieveReportResponseWrapper.EODBalances eODbalance : eODBalances){
                ApplBankDetail__c applBankDtl = new ApplBankDetail__c();
                applBankDtl.ApplBanking__c = ApplicantBankingId;
                applBankDtl.Type__c = Type;
                applBankDtl.SubType__c = SubType;
                applBankDtl.IsLatest__c = true;
                applBankDtl.Perfios_AccountNo__c = accountNumber;
                applBankDtl.Perfios_AccountType__c = accountType;
                if(eODbalance.PerfiosDate!=null && String.isNotBlank(eODbalance.PerfiosDate)){
                    applBankDtl.Date__c = getConvertedDate(eODbalance.PerfiosDate);
                }
                applBankDtl.Balance__c = eODbalance.balance;
                applBankingList.add(applBankDtl);
            }
            
        }
        return applBankingList;
    }
    public static List<ApplBankDetail__c> processTop5Funds(Id ApplicantBankingId,String accountNumber,String accountType, String Type, String SubType,List<PerfiosRetrieveReportResponseWrapper.Top5Funds> top5Funds){
        List<ApplBankDetail__c> applBankingList = new List<ApplBankDetail__c>();
        if(ApplicantBankingId!=null && Type!=null && SubType!=null && top5Funds!=null){
            for(PerfiosRetrieveReportResponseWrapper.Top5Funds funds : top5Funds){
                ApplBankDetail__c applBankDtl = new ApplBankDetail__c();
                applBankDtl.ApplBanking__c = ApplicantBankingId;
                applBankDtl.Type__c = Type;
                applBankDtl.SubType__c = SubType;
                applBankDtl.IsLatest__c = true;
                applBankDtl.Perfios_AccountNo__c = accountNumber;
                applBankDtl.Perfios_AccountType__c = accountType;
                applBankDtl.MonthName__c = funds.month!=null && String.isNotBlank(funds.month) ? funds.month : '';
                applBankDtl.Perfios_Category__c = funds.category!=null && String.isNotBlank(funds.category) ? funds.category : '';
                applBankDtl.Amount__c = funds.amount;
                applBankingList.add(applBankDtl);
            }
            
        }
        return applBankingList;
    }
    public static List<ApplBankDetail__c> processTop10Payments(Id ApplicantBankingId,String accountNumber,String accountType, String Type, String SubType,List<PerfiosRetrieveReportResponseWrapper.Top10Payments> top10Payments){
        List<ApplBankDetail__c> applBankingList = new List<ApplBankDetail__c>();
        if(ApplicantBankingId!=null && Type!=null && SubType!=null && top10Payments!=null){
            for(PerfiosRetrieveReportResponseWrapper.Top10Payments payment : top10Payments){
                ApplBankDetail__c applBankDtl = new ApplBankDetail__c();
                applBankDtl.ApplBanking__c = ApplicantBankingId;
                applBankDtl.Type__c = Type;
                applBankDtl.SubType__c = SubType;
                applBankDtl.IsLatest__c = true;
                applBankDtl.Perfios_AccountNo__c = accountNumber;
                applBankDtl.Perfios_AccountType__c = accountType;
                applBankDtl.Party__c = payment.party!=null && String.isNotBlank(payment.party) ? payment.party : '';
                applBankDtl.Amount__c = payment.amount;
                applBankDtl.Count__c = payment.count;
                applBankingList.add(applBankDtl);
            }
            
        }
        return applBankingList;
    }
    public static List<ApplBankDetail__c> processFCUAnalysis(Id ApplicantBankingId,String accountNumber,String accountType,String Type, String SubType, PerfiosRetrieveReportResponseWrapper.FCUAnalysis fCUAnalysis){
        List<ApplBankDetail__c> appBankDetialList = new List<ApplBankDetail__c>();
        if(ApplicantBankingId!=null && Type!=null && SubType!=null && fCUAnalysis!=null){
            
            //Possible Fraud Indicators
            if(fCUAnalysis.possibleFraudIndicators!=null){
                //SuspiciousBankEStatements
                if(fCUAnalysis.possibleFraudIndicators.suspiciousBankEStatements!=null){
                    ApplBankDetail__c applBankDtl = getApplBankDtlInstance(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Possible Fraud Indicators','Suspicious Bank EStatements',true);
                    applBankDtl.Status__c = fCUAnalysis.possibleFraudIndicators.suspiciousBankEStatements.status!=null && String.isNotBlank(fCUAnalysis.possibleFraudIndicators.suspiciousBankEStatements.status) ? fCUAnalysis.possibleFraudIndicators.suspiciousBankEStatements.status : '';
                    appBankDetialList.add(applBankDtl);
                }
                
                //Transaction On HolidayXns
                if(fCUAnalysis.possibleFraudIndicators.transactionOnHolidayXns!=null && fCUAnalysis.possibleFraudIndicators.transactionOnHolidayXns.transactionOnHolidayXns!=null && !fCUAnalysis.possibleFraudIndicators.transactionOnHolidayXns.transactionOnHolidayXns.isEmpty()){
                    List<ApplBankDetail__c> transactions = processTransactions(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Possible Fraud Indicators','Transactions on Holiday',fCUAnalysis.possibleFraudIndicators.transactionOnHolidayXns.transactionOnHolidayXns);
                    if(transactions!=null && !transactions.isEmpty()){
                        appBankDetialList.addAll(transactions);
                    }
                }
                
                //Cheque Deposit On HolidayXns
                if(fCUAnalysis.possibleFraudIndicators.chqDepositOnHolidayXns!=null && fCUAnalysis.possibleFraudIndicators.chqDepositOnHolidayXns.chqDepositOnHolidayXns!=null && !fCUAnalysis.possibleFraudIndicators.chqDepositOnHolidayXns.chqDepositOnHolidayXns.isEmpty()){
                    List<ApplBankDetail__c> transactions = processTransactions(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Possible Fraud Indicators','Cheque Deposit on Holidays',fCUAnalysis.possibleFraudIndicators.chqDepositOnHolidayXns.chqDepositOnHolidayXns);
                    if(transactions!=null && !transactions.isEmpty()){
                        appBankDetialList.addAll(transactions);
                    }
                }
                
                //RTGS Transaction On HolidayXns
                if(fCUAnalysis.possibleFraudIndicators.rtgsTransactionOnHolidayXns!=null && fCUAnalysis.possibleFraudIndicators.rtgsTransactionOnHolidayXns.rtgsTransactionOnHolidayXns!=null && !fCUAnalysis.possibleFraudIndicators.rtgsTransactionOnHolidayXns.rtgsTransactionOnHolidayXns.isEmpty()){
                    List<ApplBankDetail__c> transactions = processTransactions(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Possible Fraud Indicators','RTGS Transactions on Holiday',fCUAnalysis.possibleFraudIndicators.rtgsTransactionOnHolidayXns.rtgsTransactionOnHolidayXns);
                    if(transactions!=null && !transactions.isEmpty()){
                        appBankDetialList.addAll(transactions);
                    }
                }
                
                //NEFT Transaction On HolidayXns
                if(fCUAnalysis.possibleFraudIndicators.neftTransactionOnHolidayXns!=null && fCUAnalysis.possibleFraudIndicators.neftTransactionOnHolidayXns.neftTransactionOnHolidayXns!=null && !fCUAnalysis.possibleFraudIndicators.neftTransactionOnHolidayXns.neftTransactionOnHolidayXns.isEmpty()){
                    List<ApplBankDetail__c> transactions = processTransactions(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Possible Fraud Indicators','NEFT Transactions on Holiday',fCUAnalysis.possibleFraudIndicators.neftTransactionOnHolidayXns.neftTransactionOnHolidayXns);
                    if(transactions!=null && !transactions.isEmpty()){
                        appBankDetialList.addAll(transactions);
                    }
                }
                
                //Cash Deposit On HolidayXns
                if(fCUAnalysis.possibleFraudIndicators.cashDepositOnHolidayXns!=null && fCUAnalysis.possibleFraudIndicators.cashDepositOnHolidayXns.cashDepositOnHolidayXns!=null && !fCUAnalysis.possibleFraudIndicators.cashDepositOnHolidayXns.cashDepositOnHolidayXns.isEmpty()){
                    List<ApplBankDetail__c> transactions = processTransactions(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Possible Fraud Indicators','Cash Deposit on Holidays',fCUAnalysis.possibleFraudIndicators.cashDepositOnHolidayXns.cashDepositOnHolidayXns);
                    if(transactions!=null && !transactions.isEmpty()){
                        appBankDetialList.addAll(transactions);
                    }
                }
                
                //Interest Transaction On HolidayXns
                if(fCUAnalysis.possibleFraudIndicators.interestTransactionOnHolidayXns!=null && fCUAnalysis.possibleFraudIndicators.interestTransactionOnHolidayXns.interestTransactionOnHolidayXns!=null && !fCUAnalysis.possibleFraudIndicators.interestTransactionOnHolidayXns.interestTransactionOnHolidayXns.isEmpty()){
                    List<ApplBankDetail__c> transactions = processTransactions(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Possible Fraud Indicators','Interest Transactions on Holiday',fCUAnalysis.possibleFraudIndicators.interestTransactionOnHolidayXns.interestTransactionOnHolidayXns);
                    if(transactions!=null && !transactions.isEmpty()){
                        appBankDetialList.addAll(transactions);
                    }
                }
                
                //Suspicious ATMXns
                if(fCUAnalysis.possibleFraudIndicators.suspiciousATMXns!=null && fCUAnalysis.possibleFraudIndicators.suspiciousATMXns.suspiciousATMXns!=null && !fCUAnalysis.possibleFraudIndicators.suspiciousATMXns.suspiciousATMXns.isEmpty()){
                    List<ApplBankDetail__c> transactions = processTransactions(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Possible Fraud Indicators','Suspicious ATM Transactions',fCUAnalysis.possibleFraudIndicators.suspiciousATMXns.suspiciousATMXns);
                    if(transactions!=null && !transactions.isEmpty()){
                       	appBankDetialList.addAll(transactions);
                    }
                }
                
                //ATM With ChqNoXns
                if(fCUAnalysis.possibleFraudIndicators.aTMWithChqNoXns!=null && fCUAnalysis.possibleFraudIndicators.aTMWithChqNoXns.aTMWithChqNoXns!=null && !fCUAnalysis.possibleFraudIndicators.aTMWithChqNoXns.aTMWithChqNoXns.isEmpty()){
                    List<ApplBankDetail__c> transactions = processTransactions(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Possible Fraud Indicators','ATM With Cheque Transactions',fCUAnalysis.possibleFraudIndicators.aTMWithChqNoXns.aTMWithChqNoXns);
                    if(transactions!=null && !transactions.isEmpty()){
                        appBankDetialList.addAll(transactions);
                    }
                }
            	
                //ATM With Suspicious AmountXns
                if(fCUAnalysis.possibleFraudIndicators.aTMWithSuspiciousAmountXns!=null && fCUAnalysis.possibleFraudIndicators.aTMWithSuspiciousAmountXns.aTMWithSuspiciousAmountXns!=null && !fCUAnalysis.possibleFraudIndicators.aTMWithSuspiciousAmountXns.aTMWithSuspiciousAmountXns.isEmpty()){
                    List<ApplBankDetail__c> transactions = processTransactions(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Possible Fraud Indicators','ATM With Suspicious Amount Transactions',fCUAnalysis.possibleFraudIndicators.aTMWithSuspiciousAmountXns.aTMWithSuspiciousAmountXns);
                    if(transactions!=null && !transactions.isEmpty()){
                        appBankDetialList.addAll(transactions);
                    }
                }
            
           		//Salary On HolidayXns
           		if(fCUAnalysis.possibleFraudIndicators.salaryOnHolidayXns!=null && fCUAnalysis.possibleFraudIndicators.salaryOnHolidayXns.salaryOnHolidayXns!=null && !fCUAnalysis.possibleFraudIndicators.salaryOnHolidayXns.salaryOnHolidayXns.isEmpty()){
                    List<ApplBankDetail__c> transactions = processTransactions(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Possible Fraud Indicators','Salary on Holiday',fCUAnalysis.possibleFraudIndicators.salaryOnHolidayXns.salaryOnHolidayXns);
                    if(transactions!=null && !transactions.isEmpty()){
                        appBankDetialList.addAll(transactions);
                    }
                }
            	
                //Interest CreditXns
                if(fCUAnalysis.possibleFraudIndicators.interestCreditXns!=null && fCUAnalysis.possibleFraudIndicators.interestCreditXns.interestCreditXns!=null && !fCUAnalysis.possibleFraudIndicators.interestCreditXns.interestCreditXns.isEmpty()){
                    List<ApplBankDetail__c> transactions = processTransactions(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Possible Fraud Indicators','Interest Credit Transactions',fCUAnalysis.possibleFraudIndicators.interestCreditXns.interestCreditXns);
                    if(transactions!=null && !transactions.isEmpty()){
                        appBankDetialList.addAll(transactions);
                    }
                }
                
                //Interest ChargeXns
                if(fCUAnalysis.possibleFraudIndicators.interestChargeXns!=null && fCUAnalysis.possibleFraudIndicators.interestChargeXns.interestChargeXns!=null && !fCUAnalysis.possibleFraudIndicators.interestChargeXns.interestChargeXns.isEmpty()){
                    List<ApplBankDetail__c> transactions = processTransactions(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Possible Fraud Indicators','Interest Charge Transactions',fCUAnalysis.possibleFraudIndicators.interestChargeXns.interestChargeXns);
                    if(transactions!=null && !transactions.isEmpty()){
                        appBankDetialList.addAll(transactions);
                    }
                }
                
                //Suspicious RTGSXns
                if(fCUAnalysis.possibleFraudIndicators.suspiciousRTGSXns!=null && fCUAnalysis.possibleFraudIndicators.suspiciousRTGSXns.suspiciousRTGSXns!=null && !fCUAnalysis.possibleFraudIndicators.suspiciousRTGSXns.suspiciousRTGSXns.isEmpty()){
                    List<ApplBankDetail__c> transactions = processTransactions(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Possible Fraud Indicators','Suspicious RTGS Transactions',fCUAnalysis.possibleFraudIndicators.suspiciousRTGSXns.suspiciousRTGSXns);
                    if(transactions!=null && !transactions.isEmpty()){
                        appBankDetialList.addAll(transactions);
                    }
                }
            	
                //Amount Balance MismatchXns
                if(fCUAnalysis.possibleFraudIndicators.amountBalanceMismatchXns!=null && fCUAnalysis.possibleFraudIndicators.amountBalanceMismatchXns.amountBalanceMismatchXns!=null && !fCUAnalysis.possibleFraudIndicators.amountBalanceMismatchXns.amountBalanceMismatchXns.isEmpty()){
                    List<ApplBankDetail__c> transactions = processTransactions(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Possible Fraud Indicators','Amount Balance Mismatches',fCUAnalysis.possibleFraudIndicators.amountBalanceMismatchXns.amountBalanceMismatchXns);
                    if(transactions!=null && !transactions.isEmpty()){
                        appBankDetialList.addAll(transactions);
                    }
                }
                
                //Rotation Of Money
                if(fCUAnalysis.possibleFraudIndicators.rotationOfMoney!=null){
                    ApplBankDetail__c applBankDtl = getApplBankDtlInstance(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Possible Fraud Indicators','Rotation of Money',true);
                    applBankDtl.Status__c = fCUAnalysis.possibleFraudIndicators.rotationOfMoney.status!=null && String.isNotBlank(fCUAnalysis.possibleFraudIndicators.rotationOfMoney.status) ? fCUAnalysis.possibleFraudIndicators.rotationOfMoney.status : '';
                    appBankDetialList.add(applBankDtl);
                }
                
                //Low Account Vintage
                if(fCUAnalysis.possibleFraudIndicators.lowAccountVintage!=null){
                    ApplBankDetail__c applBankDtl = getApplBankDtlInstance(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Possible Fraud Indicators','Low Account Vintage',true);
                    applBankDtl.Status__c = fCUAnalysis.possibleFraudIndicators.lowAccountVintage.status!=null && String.isNotBlank(fCUAnalysis.possibleFraudIndicators.lowAccountVintage.status) ? fCUAnalysis.possibleFraudIndicators.lowAccountVintage.status : '';
                    appBankDetialList.add(applBankDtl);
                }
            
                //Transactions On SaturdayXns
                if(fCUAnalysis.possibleFraudIndicators.TransactionsOnSaturdayXns!=null && fCUAnalysis.possibleFraudIndicators.TransactionsOnSaturdayXns.TransactionsOnSaturdayXns!=null && !fCUAnalysis.possibleFraudIndicators.TransactionsOnSaturdayXns.TransactionsOnSaturdayXns.isEmpty()){
                    List<ApplBankDetail__c> transactions = processTransactions(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Possible Fraud Indicators','Transactions on Saturday',fCUAnalysis.possibleFraudIndicators.TransactionsOnSaturdayXns.TransactionsOnSaturdayXns);
                    if(transactions!=null && !transactions.isEmpty()){
                        appBankDetialList.addAll(transactions);
                    }
                }
                
                //Cash Deposits With DecimalXns
                if(fCUAnalysis.possibleFraudIndicators.CashDepositsWithDecimalXns!=null && fCUAnalysis.possibleFraudIndicators.CashDepositsWithDecimalXns.CashDepositsWithDecimalXns!=null && !fCUAnalysis.possibleFraudIndicators.CashDepositsWithDecimalXns.CashDepositsWithDecimalXns.isEmpty()){
                    List<ApplBankDetail__c> transactions = processTransactions(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Possible Fraud Indicators','Cash Deposits With Decimal',fCUAnalysis.possibleFraudIndicators.CashDepositsWithDecimalXns.CashDepositsWithDecimalXns);
                    if(transactions!=null && !transactions.isEmpty()){
                        appBankDetialList.addAll(transactions);
                    }
                }
                
                //Irregular AdminFee Transactions Months
                if(fCUAnalysis.possibleFraudIndicators.irregularAdminFeeTransactionsMonths!=null && !fCUAnalysis.possibleFraudIndicators.irregularAdminFeeTransactionsMonths.isEmpty()){
                    for(PerfiosRetrieveReportResponseWrapper.Month month : fCUAnalysis.possibleFraudIndicators.irregularAdminFeeTransactionsMonths){
                        ApplBankDetail__c applBankDtl = getApplBankDtlInstance(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Possible Fraud Indicators','Irregular Admin Fee Transactions Months',true);
                        applBankDtl.MonthName__c = month.month!=null && String.isNotBlank(month.month) ? month.month : ''; 
                        appBankDetialList.add(applBankDtl);
                    }
                }
                
                //Interest Not Present In Few Months
                if(fCUAnalysis.possibleFraudIndicators.interestNotPresentInFewMonthsMonths!=null && !fCUAnalysis.possibleFraudIndicators.interestNotPresentInFewMonthsMonths.isEmpty()){
                    for(PerfiosRetrieveReportResponseWrapper.Month month : fCUAnalysis.possibleFraudIndicators.interestNotPresentInFewMonthsMonths){
                        ApplBankDetail__c applBankDtl = getApplBankDtlInstance(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Possible Fraud Indicators','Interest Not Present In Few Months',true);
                        applBankDtl.MonthName__c = month.month!=null && String.isNotBlank(month.month) ? month.month : ''; 
                        appBankDetialList.add(applBankDtl);
                    }
                }
                
                //Interest Tax Not Present In Few Months
                if(fCUAnalysis.possibleFraudIndicators.interestTaxNotPresentInFewMonthsMonths!=null && !fCUAnalysis.possibleFraudIndicators.interestTaxNotPresentInFewMonthsMonths.isEmpty()){
                    for(PerfiosRetrieveReportResponseWrapper.Month month : fCUAnalysis.possibleFraudIndicators.interestTaxNotPresentInFewMonthsMonths){
                        ApplBankDetail__c applBankDtl = getApplBankDtlInstance(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Possible Fraud Indicators','Interest Tax Not Present In Few Months',true);
                        applBankDtl.MonthName__c = month.month!=null && String.isNotBlank(month.month) ? month.month : ''; 
                        appBankDetialList.add(applBankDtl);
                    }
                }
            
            	//Tax Not Present Compared To InterestXns
                if(fCUAnalysis.possibleFraudIndicators.taxNotPresentComparedToInterestXns!=null && fCUAnalysis.possibleFraudIndicators.taxNotPresentComparedToInterestXns.taxNotPresentComparedToInterestXns!=null && !fCUAnalysis.possibleFraudIndicators.taxNotPresentComparedToInterestXns.taxNotPresentComparedToInterestXns.isEmpty()){
                    List<ApplBankDetail__c> transactions = processTransactions(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Possible Fraud Indicators','Tax Not Present Compared To Interest Transactions',fCUAnalysis.possibleFraudIndicators.taxNotPresentComparedToInterestXns.taxNotPresentComparedToInterestXns);
                    if(transactions!=null && !transactions.isEmpty()){
                        appBankDetialList.addAll(transactions);
                    }
                }
            
            	//Account Number Mismatch
                if(fCUAnalysis.possibleFraudIndicators.accountNumberMismatch!=null){
                    ApplBankDetail__c applBankDtl = getApplBankDtlInstance(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Possible Fraud Indicators','Account Number Mismatches',true);
                    applBankDtl.DeclaredAccountNo__c = fCUAnalysis.possibleFraudIndicators.accountNumberMismatch.declaredAccountNo!=null && String.isNotBlank(fCUAnalysis.possibleFraudIndicators.accountNumberMismatch.declaredAccountNo) ? fCUAnalysis.possibleFraudIndicators.accountNumberMismatch.declaredAccountNo : '';
                    applBankDtl.AccountNo__c = fCUAnalysis.possibleFraudIndicators.accountNumberMismatch.actualAccountNo!=null && String.isNotBlank(fCUAnalysis.possibleFraudIndicators.accountNumberMismatch.actualAccountNo) ? fCUAnalysis.possibleFraudIndicators.accountNumberMismatch.actualAccountNo : '';
                    appBankDetialList.add(applBankDtl);
                }
            }
            
            //Behavioural Transactional Indicators
            if(fCUAnalysis.behaviouralTransactionalIndicators!=null){
                //Big Debit After SalaryXns
                if(fCUAnalysis.behaviouralTransactionalIndicators.bigDebitAfterSalaryXns!=null && fCUAnalysis.behaviouralTransactionalIndicators.bigDebitAfterSalaryXns.bigDebitAfterSalaryXns!=null && !fCUAnalysis.behaviouralTransactionalIndicators.bigDebitAfterSalaryXns.bigDebitAfterSalaryXns.isEmpty()){
                    List<ApplBankDetail__c> transactions = processTransactions(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Behavioural Transactional Indicators','Big Debit After Salary',fCUAnalysis.behaviouralTransactionalIndicators.bigDebitAfterSalaryXns.bigDebitAfterSalaryXns);
                    if(transactions!=null && !transactions.isEmpty()){
                        appBankDetialList.addAll(transactions);
                    }
                }
            	
                //Cash Withdrawal After CashDepositXns
                if(fCUAnalysis.behaviouralTransactionalIndicators.cashWithdrawalAfterCashDepositXns!=null && fCUAnalysis.behaviouralTransactionalIndicators.cashWithdrawalAfterCashDepositXns.cashWithdrawalAfterCashDepositXns!=null && !fCUAnalysis.behaviouralTransactionalIndicators.cashWithdrawalAfterCashDepositXns.cashWithdrawalAfterCashDepositXns.isEmpty()){
                    List<ApplBankDetail__c> transactions = processTransactions(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Behavioural Transactional Indicators','Cash Withdrawal After Cash Deposit',fCUAnalysis.behaviouralTransactionalIndicators.cashWithdrawalAfterCashDepositXns.cashWithdrawalAfterCashDepositXns);
                    if(transactions!=null && !transactions.isEmpty()){
                        appBankDetialList.addAll(transactions);
                    }
                }
            	
                //Cash Withdrawal After CreditXns
                if(fCUAnalysis.behaviouralTransactionalIndicators.cashWithdrawalAfterCreditXns!=null && fCUAnalysis.behaviouralTransactionalIndicators.cashWithdrawalAfterCreditXns.cashWithdrawalAfterCreditXns!=null && !fCUAnalysis.behaviouralTransactionalIndicators.cashWithdrawalAfterCreditXns.cashWithdrawalAfterCreditXns.isEmpty()){
                    List<ApplBankDetail__c> transactions = processTransactions(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Behavioural Transactional Indicators','Cash Withdrawal After Credit',fCUAnalysis.behaviouralTransactionalIndicators.cashWithdrawalAfterCreditXns.cashWithdrawalAfterCreditXns);
                    if(transactions!=null && !transactions.isEmpty()){
                        appBankDetialList.addAll(transactions);
                    }
                }
                
                //Salary Amount Not VaryingXns
                if(fCUAnalysis.behaviouralTransactionalIndicators.salaryAmountNotVaryingXns!=null && fCUAnalysis.behaviouralTransactionalIndicators.salaryAmountNotVaryingXns.salaryAmountNotVaryingXns!=null && !fCUAnalysis.behaviouralTransactionalIndicators.salaryAmountNotVaryingXns.salaryAmountNotVaryingXns.isEmpty()){
                    List<ApplBankDetail__c> transactions = processTransactions(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Behavioural Transactional Indicators','Salary Amount Not Varying',fCUAnalysis.behaviouralTransactionalIndicators.salaryAmountNotVaryingXns.salaryAmountNotVaryingXns);
                    if(transactions!=null && !transactions.isEmpty()){
                        appBankDetialList.addAll(transactions);
                    }
                }
                
                //More CashXns
                if(fCUAnalysis.behaviouralTransactionalIndicators.moreCashXns!=null){
                    ApplBankDetail__c applBankDtl = getApplBankDtlInstance(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Behavioural Transactional Indicators','More Cash Transactions',true);
                    applBankDtl.Status__c = fCUAnalysis.behaviouralTransactionalIndicators.moreCashXns.status!=null && String.isNotBlank(fCUAnalysis.behaviouralTransactionalIndicators.moreCashXns.status) ? fCUAnalysis.behaviouralTransactionalIndicators.moreCashXns.status : '';
                    appBankDetialList.add(applBankDtl);
                }
            	
                //More Cash DepositXns
                if(fCUAnalysis.behaviouralTransactionalIndicators.moreCashDepositXns!=null && fCUAnalysis.behaviouralTransactionalIndicators.moreCashDepositXns.moreCashDepositXns!=null && !fCUAnalysis.behaviouralTransactionalIndicators.moreCashDepositXns.moreCashDepositXns.isEmpty()){
                    List<ApplBankDetail__c> transactions = processTransactions(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Behavioural Transactional Indicators','More Cash Deposit Transactions',fCUAnalysis.behaviouralTransactionalIndicators.moreCashDepositXns.moreCashDepositXns);
                    if(transactions!=null && !transactions.isEmpty()){
                        appBankDetialList.addAll(transactions);
                    }
                }
                
                //Tax PaymentXns
                if(fCUAnalysis.behaviouralTransactionalIndicators.taxPaymentXns!=null && fCUAnalysis.behaviouralTransactionalIndicators.taxPaymentXns.taxPaymentXns!=null && !fCUAnalysis.behaviouralTransactionalIndicators.taxPaymentXns.taxPaymentXns.isEmpty()){
                    List<ApplBankDetail__c> transactions = processTransactions(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Behavioural Transactional Indicators','Tax Payment Transactions',fCUAnalysis.behaviouralTransactionalIndicators.taxPaymentXns.taxPaymentXns);
                    if(transactions!=null && !transactions.isEmpty()){
                        appBankDetialList.addAll(transactions);
                    }
                }
                
                //Negative EOD BalanceXns
                if(fCUAnalysis.behaviouralTransactionalIndicators.negativeEODBalanceXns!=null && fCUAnalysis.behaviouralTransactionalIndicators.negativeEODBalanceXns.negativeEODBalanceXns!=null && !fCUAnalysis.behaviouralTransactionalIndicators.negativeEODBalanceXns.negativeEODBalanceXns.isEmpty()){
                    List<ApplBankDetail__c> transactions = processTransactions(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Behavioural Transactional Indicators','Negative EOD Balance',fCUAnalysis.behaviouralTransactionalIndicators.negativeEODBalanceXns.negativeEODBalanceXns);
                    if(transactions!=null && !transactions.isEmpty()){
                        appBankDetialList.addAll(transactions);
                    }
                }
                
                //Negative All EOD BalanceXns
                if(fCUAnalysis.behaviouralTransactionalIndicators.negativeAllEODBalanceXns!=null && fCUAnalysis.behaviouralTransactionalIndicators.negativeAllEODBalanceXns.negativeAllEODBalanceXns!=null && !fCUAnalysis.behaviouralTransactionalIndicators.negativeAllEODBalanceXns.negativeAllEODBalanceXns.isEmpty()){
                    List<ApplBankDetail__c> transactions = processTransactions(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Behavioural Transactional Indicators','Negative All EOD Balance',fCUAnalysis.behaviouralTransactionalIndicators.negativeAllEODBalanceXns.negativeAllEODBalanceXns);
                    if(transactions!=null && !transactions.isEmpty()){
                        appBankDetialList.addAll(transactions);
                    }
                }
                
                //High Cash DepositXns
                if(fCUAnalysis.behaviouralTransactionalIndicators.highCashDepositXns!=null && fCUAnalysis.behaviouralTransactionalIndicators.highCashDepositXns.highCashDepositXns!=null && !fCUAnalysis.behaviouralTransactionalIndicators.highCashDepositXns.highCashDepositXns.isEmpty()){
                    List<ApplBankDetail__c> transactions = processTransactions(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Behavioural Transactional Indicators','High Cash Deposit Transactions',fCUAnalysis.behaviouralTransactionalIndicators.highCashDepositXns.highCashDepositXns);
                    if(transactions!=null && !transactions.isEmpty()){
                        appBankDetialList.addAll(transactions);
                    }
                }
                
                //Equal Credit DebitXns
                if(fCUAnalysis.behaviouralTransactionalIndicators.equalCreditDebitXns!=null){
                    ApplBankDetail__c applBankDtl = getApplBankDtlInstance(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Behavioural Transactional Indicators','Equal Credit Debit Transactions',true);
                    applBankDtl.Status__c = fCUAnalysis.behaviouralTransactionalIndicators.equalCreditDebitXns.status!=null && String.isNotBlank(fCUAnalysis.behaviouralTransactionalIndicators.equalCreditDebitXns.status) ? fCUAnalysis.behaviouralTransactionalIndicators.equalCreditDebitXns.status : '';
                    appBankDetialList.add(applBankDtl);
                }
                
                //Suspicious Salary DebitXns
                if(fCUAnalysis.behaviouralTransactionalIndicators.SuspiciousSalaryDebitXns!=null && fCUAnalysis.behaviouralTransactionalIndicators.SuspiciousSalaryDebitXns.SuspiciousSalaryDebitXns!=null && !fCUAnalysis.behaviouralTransactionalIndicators.SuspiciousSalaryDebitXns.SuspiciousSalaryDebitXns.isEmpty()){
                    List<ApplBankDetail__c> transactions = processTransactions(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Behavioural Transactional Indicators','Suspicious Salary Debit Transactions',fCUAnalysis.behaviouralTransactionalIndicators.SuspiciousSalaryDebitXns.SuspiciousSalaryDebitXns);
                    if(transactions!=null && !transactions.isEmpty()){
                        appBankDetialList.addAll(transactions);
                    }
                }
                
                //NEFT IMPS With ChqNoXns
                if(fCUAnalysis.behaviouralTransactionalIndicators.neftImpsWithChqNoXns!=null && fCUAnalysis.behaviouralTransactionalIndicators.neftImpsWithChqNoXns.neftImpsWithChqNoXns!=null && !fCUAnalysis.behaviouralTransactionalIndicators.neftImpsWithChqNoXns.neftImpsWithChqNoXns.isEmpty()){
                    List<ApplBankDetail__c> transactions = processTransactions(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Behavioural Transactional Indicators','NEFT IMPS With Cheque Transactions',fCUAnalysis.behaviouralTransactionalIndicators.neftImpsWithChqNoXns.neftImpsWithChqNoXns);
                    if(transactions!=null && !transactions.isEmpty()){
                        appBankDetialList.addAll(transactions);
                    }
                }
                
                //NEFT IMPS RTGS Against SalaryXns
                if(fCUAnalysis.behaviouralTransactionalIndicators.neftImpsRtgsAgainstSalaryXns!=null && fCUAnalysis.behaviouralTransactionalIndicators.neftImpsRtgsAgainstSalaryXns.neftImpsRtgsAgainstSalaryXns!=null && !fCUAnalysis.behaviouralTransactionalIndicators.neftImpsRtgsAgainstSalaryXns.neftImpsRtgsAgainstSalaryXns.isEmpty()){
                    List<ApplBankDetail__c> transactions = processTransactions(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Behavioural Transactional Indicators','NEFT IMPS RTGS Against Salary Transactions',fCUAnalysis.behaviouralTransactionalIndicators.neftImpsRtgsAgainstSalaryXns.neftImpsRtgsAgainstSalaryXns);
                    if(transactions!=null && !transactions.isEmpty()){
                        appBankDetialList.addAll(transactions);
                    }
                }
                
                //Rounded Salary TransactionXns
                if(fCUAnalysis.behaviouralTransactionalIndicators.roundedSalaryTransactionXns!=null && fCUAnalysis.behaviouralTransactionalIndicators.roundedSalaryTransactionXns.roundedSalaryTransactionXns!=null && !fCUAnalysis.behaviouralTransactionalIndicators.roundedSalaryTransactionXns.roundedSalaryTransactionXns.isEmpty()){
                    List<ApplBankDetail__c> transactions = processTransactions(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Behavioural Transactional Indicators','Rounded Salary Transactions',fCUAnalysis.behaviouralTransactionalIndicators.roundedSalaryTransactionXns.roundedSalaryTransactionXns);
                    if(transactions!=null && !transactions.isEmpty()){
                        appBankDetialList.addAll(transactions);
                    }
                }
                
                //Irregular Interest DebitXns
                if(fCUAnalysis.behaviouralTransactionalIndicators.irregularInterestDebitXns!=null && !fCUAnalysis.behaviouralTransactionalIndicators.irregularInterestDebitXns.isEmpty()){
                    List<ApplBankDetail__c> transactions = processTransactions(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Behavioural Transactional Indicators','Irregular Interest Debit Transactions',fCUAnalysis.behaviouralTransactionalIndicators.irregularInterestDebitXns);
                    if(transactions!=null && !transactions.isEmpty()){
                        appBankDetialList.addAll(transactions);
                    }
                }
                
                //Irregular Salary CreditXns
                if(fCUAnalysis.behaviouralTransactionalIndicators.irregularSalaryCreditXns!=null && !fCUAnalysis.behaviouralTransactionalIndicators.irregularSalaryCreditXns.isEmpty()){
                    List<ApplBankDetail__c> transactions = processTransactions(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Behavioural Transactional Indicators','Irregular Salary Credit Transactions',fCUAnalysis.behaviouralTransactionalIndicators.irregularSalaryCreditXns);
                    if(transactions!=null && !transactions.isEmpty()){
                        appBankDetialList.addAll(transactions);
                    }
                }
                
                //Irregular Transfer To PartiesXns
                if(fCUAnalysis.behaviouralTransactionalIndicators.irregularTransferToPartiesXns!=null && !fCUAnalysis.behaviouralTransactionalIndicators.irregularTransferToPartiesXns.isEmpty()){
                    List<ApplBankDetail__c> transactions = processTransactions(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Behavioural Transactional Indicators','Irregular Transfer To Parties',fCUAnalysis.behaviouralTransactionalIndicators.irregularTransferToPartiesXns);
                    if(transactions!=null && !transactions.isEmpty()){
                        appBankDetialList.addAll(transactions);
                    }
                }
            	
                //Irregular EmiEcsXns
                if(fCUAnalysis.behaviouralTransactionalIndicators.irregularEmiEcsXns!=null && !fCUAnalysis.behaviouralTransactionalIndicators.irregularEmiEcsXns.isEmpty()){
                    List<ApplBankDetail__c> transactions = processTransactions(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Behavioural Transactional Indicators','Irregular EMI/ECS Transactions',fCUAnalysis.behaviouralTransactionalIndicators.irregularEmiEcsXns);
                    if(transactions!=null && !transactions.isEmpty()){
                        appBankDetialList.addAll(transactions);
                    }
                }
            
            	//LowXns
            	if(fCUAnalysis.behaviouralTransactionalIndicators.lowXns!=null && !fCUAnalysis.behaviouralTransactionalIndicators.lowXns.isEmpty()){
                    for(PerfiosRetrieveReportResponseWrapper.Month month : fCUAnalysis.behaviouralTransactionalIndicators.lowXns){
                        ApplBankDetail__c applBankDtl = getApplBankDtlInstance(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Behavioural Transactional Indicators','Low Transactions',true);
                        applBankDtl.MonthName__c = month.month!=null && String.isNotBlank(month.month) ? month.month : ''; 
                        appBankDetialList.add(applBankDtl);
                    }
                }
                
                //No XnMonths
            	if(fCUAnalysis.behaviouralTransactionalIndicators.noXnMonths!=null && !fCUAnalysis.behaviouralTransactionalIndicators.noXnMonths.isEmpty()){
                    for(PerfiosRetrieveReportResponseWrapper.Month month : fCUAnalysis.behaviouralTransactionalIndicators.noXnMonths){
                        ApplBankDetail__c applBankDtl = getApplBankDtlInstance(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Behavioural Transactional Indicators','No Monthly Transactions',true);
                        applBankDtl.MonthName__c = month.month!=null && String.isNotBlank(month.month) ? month.month : ''; 
                        appBankDetialList.add(applBankDtl);
                    }
                }
                
                //No POSXnMonths
            	if(fCUAnalysis.behaviouralTransactionalIndicators.noPosXnMonths!=null && !fCUAnalysis.behaviouralTransactionalIndicators.noPosXnMonths.isEmpty()){
                    for(PerfiosRetrieveReportResponseWrapper.Month month : fCUAnalysis.behaviouralTransactionalIndicators.noPosXnMonths){
                        ApplBankDetail__c applBankDtl = getApplBankDtlInstance(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Behavioural Transactional Indicators','No Monthly POS Transactions',true);
                        applBankDtl.MonthName__c = month.month!=null && String.isNotBlank(month.month) ? month.month : ''; 
                        appBankDetialList.add(applBankDtl);
                    }
                }
                
                //Revenue SheriffXns
            	if(fCUAnalysis.behaviouralTransactionalIndicators.revenueSheriffXns!=null && fCUAnalysis.behaviouralTransactionalIndicators.revenueSheriffXns.revenueSheriffXns!=null && !fCUAnalysis.behaviouralTransactionalIndicators.revenueSheriffXns.revenueSheriffXns.isEmpty()){
                    List<ApplBankDetail__c> transactions = processTransactions(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Behavioural Transactional Indicators','Revenue Sheriff Transactions',fCUAnalysis.behaviouralTransactionalIndicators.revenueSheriffXns.revenueSheriffXns);
                    if(transactions!=null && !transactions.isEmpty()){
                        appBankDetialList.addAll(transactions);
                    }
                }
            	
                //Mismatch Summary Against Calculated Values
                if(fCUAnalysis.behaviouralTransactionalIndicators.mismatchSummaryAgainstCalculatedValues!=null){
                    ApplBankDetail__c applBankDtl = getApplBankDtlInstance(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Behavioural Transactional Indicators','Mismatch Summary Against Calculated Values',true);
                    applBankDtl.Status__c = fCUAnalysis.behaviouralTransactionalIndicators.mismatchSummaryAgainstCalculatedValues.status!=null && String.isNotBlank(fCUAnalysis.behaviouralTransactionalIndicators.mismatchSummaryAgainstCalculatedValues.status) ? fCUAnalysis.behaviouralTransactionalIndicators.mismatchSummaryAgainstCalculatedValues.status : '';
                    appBankDetialList.add(applBankDtl);
                }
                
                //Only Atm Debits In Any Of LastThreeMonths
                if(fCUAnalysis.behaviouralTransactionalIndicators.onlyAtmDebitsInAnyOfLastThreeMonths!=null){
                    ApplBankDetail__c applBankDtl = getApplBankDtlInstance(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Behavioural Transactional Indicators','Only Atm Debits In Any of Last Three Months',true);
                    applBankDtl.Status__c = fCUAnalysis.behaviouralTransactionalIndicators.onlyAtmDebitsInAnyOfLastThreeMonths.status!=null && String.isNotBlank(fCUAnalysis.behaviouralTransactionalIndicators.onlyAtmDebitsInAnyOfLastThreeMonths.status) ? fCUAnalysis.behaviouralTransactionalIndicators.onlyAtmDebitsInAnyOfLastThreeMonths.status : '';
                    appBankDetialList.add(applBankDtl);
                }
                
                //Debit Transaction To Employer
                if(fCUAnalysis.behaviouralTransactionalIndicators.debitTransactionToEmployer!=null){
                    ApplBankDetail__c applBankDtl = getApplBankDtlInstance(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Behavioural Transactional Indicators','Debit Transaction To Employer',true);
                    applBankDtl.Status__c = fCUAnalysis.behaviouralTransactionalIndicators.debitTransactionToEmployer.status!=null && String.isNotBlank(fCUAnalysis.behaviouralTransactionalIndicators.debitTransactionToEmployer.status) ? fCUAnalysis.behaviouralTransactionalIndicators.debitTransactionToEmployer.status : '';
                    appBankDetialList.add(applBankDtl);
                }
                
                //Parties In Credits And Debits
                if(fCUAnalysis.behaviouralTransactionalIndicators.partiesInCreditsAndDebits!=null && !fCUAnalysis.behaviouralTransactionalIndicators.partiesInCreditsAndDebits.isEmpty()){
                    for(PerfiosRetrieveReportResponseWrapper.PartiesInCreditsAndDebits party : fCUAnalysis.behaviouralTransactionalIndicators.partiesInCreditsAndDebits){
                        ApplBankDetail__c applBankDtl = getApplBankDtlInstance(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Behavioural Transactional Indicators','Parties In Credits And Debits',true);
                        applBankDtl.Party__c = party.partyName!=null && String.isNotBlank(party.partyName) ? party.partyName : ''; 
                        appBankDetialList.add(applBankDtl);
                    }
                }
                
                //Discontinuity In Credits
                if(fCUAnalysis.behaviouralTransactionalIndicators.discontinuityInCredits!=null){
                    ApplBankDetail__c applBankDtl = getApplBankDtlInstance(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Behavioural Transactional Indicators','Discontinuity In Credits',true);
                    applBankDtl.Status__c = fCUAnalysis.behaviouralTransactionalIndicators.discontinuityInCredits.status!=null && String.isNotBlank(fCUAnalysis.behaviouralTransactionalIndicators.discontinuityInCredits.status) ? fCUAnalysis.behaviouralTransactionalIndicators.discontinuityInCredits.status : '';
                    appBankDetialList.add(applBankDtl);
                }
                
                //Salary Through IMPS Or UPI
                if(fCUAnalysis.behaviouralTransactionalIndicators.salaryThroughIMPSOrUPI!=null && fCUAnalysis.behaviouralTransactionalIndicators.salaryThroughIMPSOrUPI.salaryThroughIMPSOrUPIs!=null && !fCUAnalysis.behaviouralTransactionalIndicators.salaryThroughIMPSOrUPI.salaryThroughIMPSOrUPIs.isEmpty()){
                    List<ApplBankDetail__c> transactions = processTransactions(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Behavioural Transactional Indicators','Salary through IMPS or UPI',fCUAnalysis.behaviouralTransactionalIndicators.salaryThroughIMPSOrUPI.salaryThroughIMPSOrUPIs);
                    if(transactions!=null && !transactions.isEmpty()){
                        appBankDetialList.addAll(transactions);
                    }
                }
                
                //Salary Through IMPS Or MPAY Or CHQ
                if(fCUAnalysis.behaviouralTransactionalIndicators.salaryThroughIMPSOrMPAYOrCHQ!=null && fCUAnalysis.behaviouralTransactionalIndicators.salaryThroughIMPSOrMPAYOrCHQ.salaryThroughIMPSOrMPAYOrCHQs!=null && !fCUAnalysis.behaviouralTransactionalIndicators.salaryThroughIMPSOrMPAYOrCHQ.salaryThroughIMPSOrMPAYOrCHQs.isEmpty()){
                    List<ApplBankDetail__c> transactions = processTransactions(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Behavioural Transactional Indicators','Salary through IMPS or MPAY or CHQ',fCUAnalysis.behaviouralTransactionalIndicators.salaryThroughIMPSOrMPAYOrCHQ.salaryThroughIMPSOrMPAYOrCHQs);
                    if(transactions!=null && !transactions.isEmpty()){
                        appBankDetialList.addAll(transactions);
                    }
                }
                
                //Non Round Figure Credits
                if(fCUAnalysis.behaviouralTransactionalIndicators.nonRoundFigureCredits!=null){
                    ApplBankDetail__c applBankDtl = getApplBankDtlInstance(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Behavioural Transactional Indicators','Non Round Figure Credits',true);
                    applBankDtl.Status__c = fCUAnalysis.behaviouralTransactionalIndicators.nonRoundFigureCredits.status!=null && String.isNotBlank(fCUAnalysis.behaviouralTransactionalIndicators.nonRoundFigureCredits.status) ? fCUAnalysis.behaviouralTransactionalIndicators.nonRoundFigureCredits.status : '';
                    appBankDetialList.add(applBankDtl);
                }
                
                //Huge Balances
                if(fCUAnalysis.behaviouralTransactionalIndicators.hugeBalances!=null){
                    ApplBankDetail__c applBankDtl = getApplBankDtlInstance(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Behavioural Transactional Indicators','Huge Balances',true);
                    applBankDtl.Status__c = fCUAnalysis.behaviouralTransactionalIndicators.hugeBalances.status!=null && String.isNotBlank(fCUAnalysis.behaviouralTransactionalIndicators.hugeBalances.status) ? fCUAnalysis.behaviouralTransactionalIndicators.hugeBalances.status : '';
                    appBankDetialList.add(applBankDtl);
                }
                
                //Credit Interest Not Reflecting
                if(fCUAnalysis.behaviouralTransactionalIndicators.creditInterestNotReflecting!=null){
                    ApplBankDetail__c applBankDtl = getApplBankDtlInstance(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Behavioural Transactional Indicators','Credit Interest Not Reflecting',true);
                    applBankDtl.Status__c = fCUAnalysis.behaviouralTransactionalIndicators.creditInterestNotReflecting.status!=null && String.isNotBlank(fCUAnalysis.behaviouralTransactionalIndicators.creditInterestNotReflecting.status) ? fCUAnalysis.behaviouralTransactionalIndicators.creditInterestNotReflecting.status : '';
                    appBankDetialList.add(applBankDtl);
                }
                
                //Debit Interest Not Reflecting
                if(fCUAnalysis.behaviouralTransactionalIndicators.debitInterestNotReflecting!=null){
                    ApplBankDetail__c applBankDtl = getApplBankDtlInstance(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Behavioural Transactional Indicators','Debit Interest Not Reflecting',true);
                    applBankDtl.Status__c = fCUAnalysis.behaviouralTransactionalIndicators.debitInterestNotReflecting.status!=null && String.isNotBlank(fCUAnalysis.behaviouralTransactionalIndicators.debitInterestNotReflecting.status) ? fCUAnalysis.behaviouralTransactionalIndicators.debitInterestNotReflecting.status : '';
                    appBankDetialList.add(applBankDtl);
                }
                
                //ChequeNumber In SeriesXns
                if(fCUAnalysis.behaviouralTransactionalIndicators.chequeNumberInSeriesXns!=null && fCUAnalysis.behaviouralTransactionalIndicators.chequeNumberInSeriesXns.chequeNumberInSeriesXns!=null && !fCUAnalysis.behaviouralTransactionalIndicators.chequeNumberInSeriesXns.chequeNumberInSeriesXns.isEmpty()){
                    List<ApplBankDetail__c> transactions = processTransactions(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Behavioural Transactional Indicators','Cheque Number In Series',fCUAnalysis.behaviouralTransactionalIndicators.chequeNumberInSeriesXns.chequeNumberInSeriesXns);
                    if(transactions!=null && !transactions.isEmpty()){
                        appBankDetialList.addAll(transactions);
                    }
                }
                
                //Unusual ODCC Activity
                if(fCUAnalysis.behaviouralTransactionalIndicators.unusualODCCActivity!=null){
                    ApplBankDetail__c applBankDtl = getApplBankDtlInstance(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Behavioural Transactional Indicators','Unusual OD/CC Activity',true);
                    applBankDtl.Status__c = fCUAnalysis.behaviouralTransactionalIndicators.unusualODCCActivity.status!=null && String.isNotBlank(fCUAnalysis.behaviouralTransactionalIndicators.unusualODCCActivity.status) ? fCUAnalysis.behaviouralTransactionalIndicators.unusualODCCActivity.status : '';
                    appBankDetialList.add(applBankDtl);
                }
                
                //Irregular Credit Transactions
                if(fCUAnalysis.behaviouralTransactionalIndicators.irregularCreditTransactions!=null){
                    ApplBankDetail__c applBankDtl = getApplBankDtlInstance(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Behavioural Transactional Indicators','Irregular Credit Transactions',true);
                    applBankDtl.Count__c = fCUAnalysis.behaviouralTransactionalIndicators.irregularCreditTransactions.count!=null ? Integer.valueOf(fCUAnalysis.behaviouralTransactionalIndicators.irregularCreditTransactions.count):null;
                    appBankDetialList.add(applBankDtl);
                }
                
                //Consecutive EMI Cheque Bounces
                if(fCUAnalysis.behaviouralTransactionalIndicators.consecutiveEMIChequeBounces!=null){
                    ApplBankDetail__c applBankDtl = getApplBankDtlInstance(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Behavioural Transactional Indicators','Consecutive EMI Cheque Bounces',true);
                    applBankDtl.Status__c = fCUAnalysis.behaviouralTransactionalIndicators.consecutiveEMIChequeBounces.status!=null && String.isNotBlank(fCUAnalysis.behaviouralTransactionalIndicators.consecutiveEMIChequeBounces.status) ? fCUAnalysis.behaviouralTransactionalIndicators.consecutiveEMIChequeBounces.status : '';
                    appBankDetialList.add(applBankDtl);
                }
                
                //Debit EOD BalanceXns
                if(fCUAnalysis.behaviouralTransactionalIndicators.debitEODBalanceXns!=null && fCUAnalysis.behaviouralTransactionalIndicators.debitEODBalanceXns.debitEODBalanceXns!=null && !fCUAnalysis.behaviouralTransactionalIndicators.debitEODBalanceXns.debitEODBalanceXns.isEmpty()){
                    List<ApplBankDetail__c> transactions = processTransactions(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Behavioural Transactional Indicators','Debit EOD Balances',fCUAnalysis.behaviouralTransactionalIndicators.debitEODBalanceXns.debitEODBalanceXns);
                    if(transactions!=null && !transactions.isEmpty()){
                        appBankDetialList.addAll(transactions);
                    }
                }
                
                //Credit EOD BalanceXns
                if(fCUAnalysis.behaviouralTransactionalIndicators.creditEODBalanceXns!=null && fCUAnalysis.behaviouralTransactionalIndicators.creditEODBalanceXns.creditEODBalanceXns!=null && !fCUAnalysis.behaviouralTransactionalIndicators.creditEODBalanceXns.creditEODBalanceXns.isEmpty()){
                    List<ApplBankDetail__c> transactions = processTransactions(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Behavioural Transactional Indicators','Credit EOD Balances',fCUAnalysis.behaviouralTransactionalIndicators.creditEODBalanceXns.creditEODBalanceXns);
                    if(transactions!=null && !transactions.isEmpty()){
                        appBankDetialList.addAll(transactions);
                    }
                }
                
                //Deposits Related To Govt AgenciesXns
                if(fCUAnalysis.behaviouralTransactionalIndicators.depositsRelatedToGovtAgenciesXns!=null && fCUAnalysis.behaviouralTransactionalIndicators.depositsRelatedToGovtAgenciesXns.depositsRelatedToGovtAgenciesXns!=null && !fCUAnalysis.behaviouralTransactionalIndicators.depositsRelatedToGovtAgenciesXns.depositsRelatedToGovtAgenciesXns.isEmpty()){
                    List<ApplBankDetail__c> transactions = processTransactions(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Behavioural Transactional Indicators','Deposits Related To Govt Agencies',fCUAnalysis.behaviouralTransactionalIndicators.depositsRelatedToGovtAgenciesXns.depositsRelatedToGovtAgenciesXns);
                    if(transactions!=null && !transactions.isEmpty()){
                        appBankDetialList.addAll(transactions);
                    }
                }
                
                //Casino RelatedXns
                if(fCUAnalysis.behaviouralTransactionalIndicators.casinoRelatedXns!=null && fCUAnalysis.behaviouralTransactionalIndicators.casinoRelatedXns.casinoRelatedXns!=null && !fCUAnalysis.behaviouralTransactionalIndicators.casinoRelatedXns.casinoRelatedXns.isEmpty()){
                    List<ApplBankDetail__c> transactions = processTransactions(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Behavioural Transactional Indicators','Casino Related Transactions',fCUAnalysis.behaviouralTransactionalIndicators.casinoRelatedXns.casinoRelatedXns);
                    if(transactions!=null && !transactions.isEmpty()){
                        appBankDetialList.addAll(transactions);
                    }
                }
                //Financial Commitment RelatedXns
                if(fCUAnalysis.behaviouralTransactionalIndicators.financialCommitmentRelatedXns!=null && fCUAnalysis.behaviouralTransactionalIndicators.financialCommitmentRelatedXns.financialCommitmentRelatedXns!=null && !fCUAnalysis.behaviouralTransactionalIndicators.financialCommitmentRelatedXns.financialCommitmentRelatedXns.isEmpty()){
                    List<ApplBankDetail__c> transactions = processTransactions(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Behavioural Transactional Indicators','Financial Commitment Related Transactions',fCUAnalysis.behaviouralTransactionalIndicators.financialCommitmentRelatedXns.financialCommitmentRelatedXns);
                    if(transactions!=null && !transactions.isEmpty()){
                        appBankDetialList.addAll(transactions);
                    }
                }
                
                //LargeValueCreditXns
                if(fCUAnalysis.behaviouralTransactionalIndicators.largeValueCreditXns!=null && fCUAnalysis.behaviouralTransactionalIndicators.largeValueCreditXns.largeValueCreditXns!=null && !fCUAnalysis.behaviouralTransactionalIndicators.largeValueCreditXns.largeValueCreditXns.isEmpty()){
                    List<ApplBankDetail__c> transactions = processTransactions(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Behavioural Transactional Indicators','Large Value Credit Transactions',fCUAnalysis.behaviouralTransactionalIndicators.largeValueCreditXns.largeValueCreditXns);
                    if(transactions!=null && !transactions.isEmpty()){
                        appBankDetialList.addAll(transactions);
                    }
                }
                
                //Round FigureXns
                if(fCUAnalysis.behaviouralTransactionalIndicators.roundFigureXns!=null && fCUAnalysis.behaviouralTransactionalIndicators.roundFigureXns.roundFigureXns!=null && !fCUAnalysis.behaviouralTransactionalIndicators.roundFigureXns.roundFigureXns.isEmpty()){
                    List<ApplBankDetail__c> transactions = processTransactions(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Behavioural Transactional Indicators','Round Figure Transactions',fCUAnalysis.behaviouralTransactionalIndicators.roundFigureXns.roundFigureXns);
                    if(transactions!=null && !transactions.isEmpty()){
                        appBankDetialList.addAll(transactions);
                    }
                }
                
                //Cheque ReturnXns
                if(fCUAnalysis.behaviouralTransactionalIndicators.chqReturnXns!=null && fCUAnalysis.behaviouralTransactionalIndicators.chqReturnXns.chqReturnXns!=null && !fCUAnalysis.behaviouralTransactionalIndicators.chqReturnXns.chqReturnXns.isEmpty()){
                    List<ApplBankDetail__c> transactions = processTransactions(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Behavioural Transactional Indicators','Cheque Return Transactions',fCUAnalysis.behaviouralTransactionalIndicators.chqReturnXns.chqReturnXns);
                    if(transactions!=null && !transactions.isEmpty()){
                        appBankDetialList.addAll(transactions);
                    }
                }
                
                //Parties In Credits And Debits When Credit Greater Than AMB
                if(fCUAnalysis.behaviouralTransactionalIndicators.partiesInCreditsAndDebitsWhenCreditGreaterThanAMB!=null && fCUAnalysis.behaviouralTransactionalIndicators.partiesInCreditsAndDebitsWhenCreditGreaterThanAMB.partiesInCreditsAndDebitsWhenCreditGreaterThanAMBs!=null && !fCUAnalysis.behaviouralTransactionalIndicators.partiesInCreditsAndDebitsWhenCreditGreaterThanAMB.partiesInCreditsAndDebitsWhenCreditGreaterThanAMBs.isEmpty()){
                    List<ApplBankDetail__c> transactions = processTransactions(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Behavioural Transactional Indicators','Parties in Credits and Debits when Credit Greater than AMB',fCUAnalysis.behaviouralTransactionalIndicators.partiesInCreditsAndDebitsWhenCreditGreaterThanAMB.partiesInCreditsAndDebitsWhenCreditGreaterThanAMBs);
                    if(transactions!=null && !transactions.isEmpty()){
                        appBankDetialList.addAll(transactions);
                    }
                }
                
                //Cash Deposit Greater ThanAMB
                if(fCUAnalysis.behaviouralTransactionalIndicators.cashDepositGreaterThanAMB!=null && fCUAnalysis.behaviouralTransactionalIndicators.cashDepositGreaterThanAMB.cashDepositGreaterThanAMBs!=null && !fCUAnalysis.behaviouralTransactionalIndicators.cashDepositGreaterThanAMB.cashDepositGreaterThanAMBs.isEmpty()){
                    List<ApplBankDetail__c> transactions = processTransactions(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Behavioural Transactional Indicators','Cash Deposit Greater than AMB',fCUAnalysis.behaviouralTransactionalIndicators.cashDepositGreaterThanAMB.cashDepositGreaterThanAMBs);
                    if(transactions!=null && !transactions.isEmpty()){
                        appBankDetialList.addAll(transactions);
                    }
                }
                
                //NEFT RTGS Greater Than AMB
                if(fCUAnalysis.behaviouralTransactionalIndicators.neftRtgsGreaterThanAMB!=null && fCUAnalysis.behaviouralTransactionalIndicators.neftRtgsGreaterThanAMB.neftRtgsGreaterThanAMBs!=null && !fCUAnalysis.behaviouralTransactionalIndicators.neftRtgsGreaterThanAMB.neftRtgsGreaterThanAMBs.isEmpty()){
                    List<ApplBankDetail__c> transactions = processTransactions(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Behavioural Transactional Indicators','NEFT RTGS Greater than AMB',fCUAnalysis.behaviouralTransactionalIndicators.neftRtgsGreaterThanAMB.neftRtgsGreaterThanAMBs);
                    if(transactions!=null && !transactions.isEmpty()){
                        appBankDetialList.addAll(transactions);
                    }
                }
                
                //Cheque Withdrawal On HolidayXns
                if(fCUAnalysis.behaviouralTransactionalIndicators.chqWithdrawalOnHolidayXns!=null && fCUAnalysis.behaviouralTransactionalIndicators.chqWithdrawalOnHolidayXns.chqWithdrawalOnHolidayXns!=null && !fCUAnalysis.behaviouralTransactionalIndicators.chqWithdrawalOnHolidayXns.chqWithdrawalOnHolidayXns.isEmpty()){
                    List<ApplBankDetail__c> transactions = processTransactions(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Behavioural Transactional Indicators','Cheque Withdrawal on Holiday',fCUAnalysis.behaviouralTransactionalIndicators.chqWithdrawalOnHolidayXns.chqWithdrawalOnHolidayXns);
                    if(transactions!=null && !transactions.isEmpty()){
                        appBankDetialList.addAll(transactions);
                    }
                }
                
                //UPI Above ThresholdXns
                if(fCUAnalysis.behaviouralTransactionalIndicators.upiAboveThresholdXns!=null && fCUAnalysis.behaviouralTransactionalIndicators.upiAboveThresholdXns.upiAboveThresholdXns!=null && !fCUAnalysis.behaviouralTransactionalIndicators.upiAboveThresholdXns.upiAboveThresholdXns.isEmpty()){
                    List<ApplBankDetail__c> transactions = processTransactions(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Behavioural Transactional Indicators','UPI Transactions Above Threshold',fCUAnalysis.behaviouralTransactionalIndicators.upiAboveThresholdXns.upiAboveThresholdXns);
                    if(transactions!=null && !transactions.isEmpty()){
                        appBankDetialList.addAll(transactions);
                    }
                }
                
                //IMPS AboveThresholdXns
                if(fCUAnalysis.behaviouralTransactionalIndicators.impsAboveThresholdXns!=null && fCUAnalysis.behaviouralTransactionalIndicators.impsAboveThresholdXns.impsAboveThresholdXns!=null && !fCUAnalysis.behaviouralTransactionalIndicators.impsAboveThresholdXns.impsAboveThresholdXns.isEmpty()){
                    List<ApplBankDetail__c> transactions = processTransactions(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Behavioural Transactional Indicators','IMPS Transactions Above Threshold',fCUAnalysis.behaviouralTransactionalIndicators.impsAboveThresholdXns.impsAboveThresholdXns);
                    if(transactions!=null && !transactions.isEmpty()){
                        appBankDetialList.addAll(transactions);
                    }
                }
                
                //Salary With Same NarrationXns
                if(fCUAnalysis.behaviouralTransactionalIndicators.salaryWithSameNarrationXns!=null && fCUAnalysis.behaviouralTransactionalIndicators.salaryWithSameNarrationXns.salaryWithSameNarrationXns!=null && !fCUAnalysis.behaviouralTransactionalIndicators.salaryWithSameNarrationXns.salaryWithSameNarrationXns.isEmpty()){
                    List<ApplBankDetail__c> transactions = processTransactions(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Behavioural Transactional Indicators','Salary With Same Narration',fCUAnalysis.behaviouralTransactionalIndicators.salaryWithSameNarrationXns.salaryWithSameNarrationXns);
                    if(transactions!=null && !transactions.isEmpty()){
                        appBankDetialList.addAll(transactions);
                    }
                }
                
                //Majority Round FigureXns
                if(fCUAnalysis.behaviouralTransactionalIndicators.majorityRoundFigureXns!=null && fCUAnalysis.behaviouralTransactionalIndicators.majorityRoundFigureXns.majorityRoundFigureXns!=null && !fCUAnalysis.behaviouralTransactionalIndicators.majorityRoundFigureXns.majorityRoundFigureXns.isEmpty()){
                    List<ApplBankDetail__c> transactions = processTransactions(ApplicantBankingId,accountNumber,accountType,Type,SubType,'Behavioural Transactional Indicators','Majority of Transactions in Round Figure',fCUAnalysis.behaviouralTransactionalIndicators.majorityRoundFigureXns.majorityRoundFigureXns);
                    if(transactions!=null && !transactions.isEmpty()){
                        appBankDetialList.addAll(transactions);
                    }
                }
            }
            
            
        }
        return appBankDetialList;
    }
    
    public static List<ApplBankDetail__c> processMonthlyDetails(Id ApplicantBankingId,String accountNumber,String accountType, String Type, String SubType,Map<Id,Map<String,Id>> monthlyApplBankmap,List<PerfiosRetrieveReportResponseWrapper.MonthlyDetails> monthlyDetails,List<PerfiosRetrieveReportResponseWrapper.EODBalances> eodBalances){
        List<ApplBankDetail__c> applBankingList = new List<ApplBankDetail__c>();
        if(ApplicantBankingId!=null && Type!=null && SubType!=null && monthlyDetails!=null){
            
            
            Map<String,MonthlyData> computedResult = getComputedMonthlyData(eodBalances);
            
            for(PerfiosRetrieveReportResponseWrapper.MonthlyDetails detail : monthlyDetails){
                
                if(detail.monthName !=null && String.isNotBlank(detail.monthName.toUpperCase())){
                    ApplBankDetail__c applBankDtl = new ApplBankDetail__c();
                    applBankDtl.ApplBanking__c = ApplicantBankingId;
                    applBankDtl.Type__c = Type;
                    applBankDtl.SubType__c = SubType;
                    if(monthlyApplBankmap.containsKey(ApplicantBankingId) && monthlyApplBankmap.get(ApplicantBankingId).containsKey(detail.monthName.toUpperCase())){
                        applBankDtl.Id =  monthlyApplBankmap.get(ApplicantBankingId).get(detail.monthName.toUpperCase());
                    }
                    List<String> monthString = detail.monthName.toUpperCase().split('-');
                    if(!monthString.isEmpty()){
                        applBankDtl.Month__c = monthString[0];
                        applBankDtl.Year__c = '20' + monthString[1];
                    }
                    
                    
                    applBankDtl.Perfios_AccountNo__c = accountNumber;
                    applBankDtl.Perfios_AccountType__c = accountType;
                    applBankDtl.Utilization__c = detail.avgUtilization;
                    applBankDtl.BalanceAt_1st__c = detail.bal1;
                    applBankDtl.BalanceAt_10th__c = detail.bal10;
                    applBankDtl.BalanceAt_15th__c = detail.bal15;
                    applBankDtl.BalanceAt_20th__c = detail.bal20;
                    applBankDtl.BalanceAt_25th__c = detail.bal25;
                    applBankDtl.BalanceAt_5th__c = detail.bal5;
                    applBankDtl.AverageBankBalance__c = detail.balAvg;
                    applBankDtl.DailyABBBalance__c = detail.balAvg;// Added
                    applBankDtl.MaxBalance__c = detail.balMax;
                    applBankDtl.MinBalance__c = detail.balMin;
                    applBankDtl.BankCharges__c = detail.bankCharges;
                    applBankDtl.BelowMinBalPenalties__c = detail.belowMinBalPenalties;
                    applBankDtl.MinBalanceCharges__c = detail.belowMinBalPenalties!=null ?  applBankDtl.MinBalanceCharges__c = detail.belowMinBalPenalties > 0 ? 'Y' : 'N' : ''; //Added
                    applBankDtl.CardSettlements__c = detail.cardSettlements;
                    applBankDtl.CashBacks__c = detail.cashBacks;
                    applBankDtl.CashDeposits__c = detail.cashDeposits;
                    applBankDtl.CashWithdrawals__c = detail.cashWithdrawals;
                    applBankDtl.ChequeDeposits__c = detail.chqDeposits;
                    applBankDtl.ChequeIssues__c = detail.chqIssues;
                    applBankDtl.CreditCardPayments__c = detail.creditCardPayments;
                    applBankDtl.CountofCredit__c = detail.credits;
                    applBankDtl.CreditsSC__c = detail.creditsSC;
                    applBankDtl.CreditsSelf__c = detail.creditsSelf;
                    applBankDtl.CountofDebit__c = detail.debits;
                    applBankDtl.DebitsSC__c = detail.debitsSC;
                    applBankDtl.DebitsSelf__c = detail.debitsSelf;
                    applBankDtl.DpLimit__c = detail.dpLimit;
                    applBankDtl.EMIOrLoans__c = detail.emiOrLoans;
                    applBankDtl.HouseRent__c = detail.houseRent;
                    applBankDtl.InsuranceExpenses__c = detail.insuranceExpenses;
                    applBankDtl.Interestcharges__c = detail.interestCharges;
                    applBankDtl.InterestIncomes__c = detail.interestIncomes;
                    applBankDtl.InterestPaymentDelay__c = detail.intPayDelay;
                    applBankDtl.InvestmentIncomes__c = detail.invIncomes;
                    applBankDtl.InwBounceCharges__c = detail.inwBounceCharges;
                    applBankDtl.InwBounceNonTechnical__c = detail.inwBounceNonTechnical;
                    applBankDtl.InwardReturnsCount__c = detail.inwBounces;
                    applBankDtl.InwBounceTechnical__c = detail.inwBounceTechnical;
                    applBankDtl.InwChqBounceNonTechnical__c = detail.inwChqBounceNonTechnical;
                    applBankDtl.InwEMIBounces__c = detail.inwEMIBounces;
                    applBankDtl.LoanDisbursals__c = detail.loanDisbursals;
                    applBankDtl.MonthName__c = detail.monthName!=null && String.isNotBlank(detail.monthName) ? detail.monthName : '';
                    applBankDtl.OnlineShopping__c = detail.onlineShopping;
                    applBankDtl.OtherExpenses__c = detail.otherExpenses;
                    applBankDtl.OtherIncomes__c = detail.otherIncomes;
                    applBankDtl.OutwardBounceCharges__c = detail.outwBounceCharges;
                    applBankDtl.OutwardReturnsCount__c = detail.outwBounces;
                    applBankDtl.OutwChqBounces__c = detail.outwChqBounces;
                    applBankDtl.OverDrawnAmountPeak__c = detail.overdrawnAmountPeak;
                    applBankDtl.OverDrawnDays__c = detail.overdrawnDays;
                    applBankDtl.OverDrawnDaysPeak__c = detail.overdrawnDaysPeak;
                    applBankDtl.OverdrawnInstances__c = detail.overdrawnInstances;
                    applBankDtl.PaymentFromTop5__c = detail.paymentFromTop5;
                    applBankDtl.PaymentToTop5__c = detail.paymentToTop5;
                    applBankDtl.PenalCharges__c = detail.penalCharges;
                    applBankDtl.Pension__c = detail.pension;
                    applBankDtl.POSExpenses__c = detail.posExpenses;
                    applBankDtl.RentCredits__c = detail.rentCredits;
                    applBankDtl.Salaries__c = detail.salaries;
                    applBankDtl.SalaryPaid__c = detail.salaryPaid;
                    applBankDtl.SNLimit__c = detail.snLimit;
                    if(detail.startDate!=null && string.isNotBlank(detail.startDate)){
                        applBankDtl.StartDate__c = getConvertedDate(detail.startDate);
                    }
                    applBankDtl.StopPaymentCount__c = detail.stopPayments;
                    applBankDtl.TaxPayment__c = detail.taxPayment;
                    applBankDtl.TotalAvgCredit__c = detail.totalAvgCredit;
                    applBankDtl.TotalBankCharge__c = detail.totalBankCharge;
                    applBankDtl.TotalBelowMinBalPenalty__c = detail.totalBelowMinBalPenalty;
                    applBankDtl.TotalCardSettlement__c = detail.totalCardSettlement;
                    applBankDtl.TotalCashBacK__c = detail.totalCashBack;
                    applBankDtl.TotalCashDeposit__c = detail.totalCashDeposit;
                    applBankDtl.TotalCashWithdrawal__c = detail.totalCashWithdrawal;
                    applBankDtl.TotalChqDeposit__c = detail.totalChqDeposit;
                    applBankDtl.TotalChqIssue__c = detail.totalChqIssue;
                    applBankDtl.ValueSummationCredit__c = detail.totalCredit;
                    applBankDtl.TotalCreditCardPayment__c = detail.totalCreditCardPayment;
                    applBankDtl.TotalCreditSC__c = detail.totalCreditSC;
                    applBankDtl.TotalCreditSelf__c = detail.totalCreditSelf;
                    applBankDtl.ValueSummationDebit__c = detail.totalDebit;
                    applBankDtl.TotalDebitSC__c = detail.totalDebitSC;
                    applBankDtl.TotalDebitSelf__c = detail.totalDebitSelf;
                    applBankDtl.TotalEMIOrLoan__c = detail.totalEmiOrLoan;
                    applBankDtl.TotalHouseRent__c = detail.totalHouseRent;
                    applBankDtl.TotalInsuranceExpense__c = detail.totalInsuranceExpense;
                    applBankDtl.TotalInterestCharged__c = detail.totalInterestCharged;
                    applBankDtl.TotalInterestIncome__c = detail.totalInterestIncome;
                    applBankDtl.TotalInvIncome__c = detail.totalInvIncome;
                    applBankDtl.TotalInwBounce__c = detail.totalInwBounce;
                    applBankDtl.TotalInwBounceCharge__c = detail.totalInwBounceCharge;
                    applBankDtl.TotalInwChqBounceNonTechnical__c = detail.totalInwChqBounceNonTechnical;
                    applBankDtl.TotalInwEMIBounce__c = detail.totalInwEMIBounce;
                    applBankDtl.TotalInwEMIBounceNonTechnical__c = detail.totalInwEMIBounceNonTechnical;
                    applBankDtl.TotalInwEMIBounceTechnical__c = detail.totalInwEMIBounceTechnical;
                    applBankDtl.TotalLoanDisbursal__c = detail.totalLoanDisbursal;
                    applBankDtl.TotalOnlineShopping__c = detail.totalOnlineShopping;
                    applBankDtl.TotalOtherExpense__c = detail.totalOtherExpense;
                    applBankDtl.TotalOtherIncome__c = detail.totalOtherIncome;
                    applBankDtl.TotalOutwBounce__c = detail.totalOutwBounce;
                    applBankDtl.TotalOutwBounceCharge__c = detail.totalOutwBounceCharge;
                    applBankDtl.TotalOutwChqBounce__c = detail.totalOutwChqBounce;
                    applBankDtl.TotalPaymentFromTop5__c = detail.totalPaymentFromTop5;
                    applBankDtl.TotalPaymentToTop5__c = detail.totalPaymentToTop5;
                    applBankDtl.TotalPenalCharge__c = detail.totalPenalCharge;
                    applBankDtl.TotalPension__c = detail.totalPension;
                    applBankDtl.TotalPOSExpense__c = detail.totalPosExpense;
                    applBankDtl.TotalRentCredit__c = detail.totalRentCredit;
                    applBankDtl.TotalSalary__c = detail.totalSalary;
                    applBankDtl.TotalSalaryPaid__c = detail.totalSalaryPaid;
                    applBankDtl.TotalTaxPayment__c = detail.totalTaxPayment;
                    applBankDtl.TotalTransferToWallet__c = detail.totalTransferToWallet;
                    applBankDtl.TotalUPICredit__c = detail.totalUpiCredit;
                    applBankDtl.TotalUPIDebit__c = detail.totalUpiDebit;
                    applBankDtl.TotalUtilityExpense__c = detail.totalUtilityExpense;
                    applBankDtl.TransferToWallet__c = detail.transferToWallet;
                    applBankDtl.UPICredits__c = detail.upiCredits;
                    applBankDtl.UPIDebits__c = detail.upiDebits;
                    applBankDtl.UtilityExpenses__c = detail.utilityExpenses;
                    applBankDtl.TransactionsCount__c = detail.xnsCount;
                    
                    
                    if(computedResult.containsKey(detail.monthName.toUpperCase())){
                        applBankDtl.Monthend__c = computedResult.get(detail.monthName.toUpperCase()).monthEndBalance;
                        applBankDtl.Average_Daily_Bank_Balance__c =  computedResult.get(detail.monthName.toUpperCase()).dailyAverageBalance;   
                    }
                    
                    applBankingList.add(applBankDtl);
                }
            }
        }
        
        return  applBankingList;
    }
    
    public static Map<String,MonthlyData> getComputedMonthlyData(List<PerfiosRetrieveReportResponseWrapper.EODBalances> eodBalances){
        
        Map<String,MonthlyData> monthlyData = new Map<String,MonthlyData>();
        if(!eodBalances.isEmpty()){
            Map<String,Map<Date,Double>> monthWiseData = new Map<String,Map<Date,Double>>();
            for(PerfiosRetrieveReportResponseWrapper.EODBalances balance : eodBalances){
                if(String.isNotblank(balance.PerfiosDate)){
                    Date currentDate = Date.valueOf(balance.PerfiosDate);
                    if(monthNameMap.containsKey(currentDate.Month())){
                        if(monthWiseData.containsKey(monthNameMap.get(currentDate.Month()) + '-' + currentDate.year())){
                            monthWiseData.get(monthNameMap.get(currentDate.Month()) + '-' + currentDate.year()).put(Date.valueOf(balance.PerfiosDate),balance.balance);
                        }
                        else{
                            monthWiseData.put(monthNameMap.get(currentDate.Month()) + '-' + currentDate.year(), new Map<Date,Double>{Date.valueOf(balance.PerfiosDate) => balance.balance});
                        }
                    }	
                }
            }
            
            if(!monthWiseData.isEmpty()){
                for(String key : monthWiseData.keySet()){
                    Map<Date,Double> monthData = monthWiseData.get(key);
                    Double totalMonthlyBalance = 0;
                    Double totalMonthlyAverage = 0;
                    if(monthData!=null){
                        for(Double balance : monthData.values()){
                            totalMonthlyBalance+=balance;
                        }
                        totalMonthlyAverage = totalMonthlyBalance / monthData.size();
                    }
                    List<String> keyList = key.split('-');
                    if(!keyList.isEmpty() && monthValueMap.containsKey(keyList[0]) ){
                        Date monthStartDate =  Date.newInstance(Integer.valueOf(keyList[1]),monthValueMap.get(keyList[0]),01);
                        Date monthEndDate = monthStartDate.addDays((date.daysInMonth(monthStartDate.year(),monthStartDate.month())-1));
                        
                        if(!monthlyData.containsKey(keyList[0] + '-' + keyList[1].right(2))){
                            MonthlyData data = new MonthlyData();
                            data.monthEndBalance = monthData.containsKey(monthEndDate) ? monthData.get(monthEndDate) : 0;
                            data.dailyAverageBalance = Decimal.valueOf(totalMonthlyAverage).setScale(2,RoundingMode.HALF_EVEN);
                            
                            monthlyData.put(keyList[0] + '-' + keyList[1].right(2),data);
                        }
                    }
                }
            }
        }
        
        return monthlyData;
    }
        
        
    public class MonthlyData{
        public Double monthEndBalance;
        public Double dailyAverageBalance;
    }
    
    public static Map<String, Integer> monthValueMap = new Map<String, Integer>{
            'JAN' => 01, 'FEB' => 02, 'MAR' => 03,
            'APR' => 04, 'MAY' => 05, 'JUN' => 06,
            'JUL' => 07, 'AUG' => 08, 'SEP' => 09,
            'OCT' => 10, 'NOV' => 11, 'DEC' => 12
            };

  	public static Map<Integer,String> monthNameMap = new Map<Integer,String>{
            1 => 'JAN', 2 => 'FEB',3 => 'MAR',
            4 => 'APR',5 => 'MAY',6 => 'JUN',
            7 => 'JUL',8 => 'AUG',9 => 'SEP',
            10 => 'OCT',11 => 'NOV',12 => 'DEC'
            };

    
}