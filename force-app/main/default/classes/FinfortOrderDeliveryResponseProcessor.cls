public class FinfortOrderDeliveryResponseProcessor implements IintMsgCalloutResponseProcessor{
    
    //This MAP is used for GST only
    private static Map<String, Map<String,Applicant_Financial_Summary__c>> checkFinancialSummaryMap = new Map<String, Map<String,Applicant_Financial_Summary__c>>();
    private static Map<String,Map<String,Applicant_Financial__c>> applicantFinancialMap =new Map<String,Map<String,Applicant_Financial__c>>();
    private static List<Applicant_Financial_Summary__c> financialSummaryList =new List<Applicant_Financial_Summary__c>();
    
    public static void process(List<IntgMsg__c> responses) {
        
        if(!responses.isEmpty()){
            
            Set<Id> intmsgIds =new Set<Id>();
            Map<Id,Id> ContentDocumentMap =new Map<Id,Id>();
            Map<Id,ContentVersion> ContentVersionMap =new Map<Id,ContentVersion>();
            // Map<IntgMsg__c,FinfortOrderDeliveryResponseWrapper> successResponseMap = new Map<IntgMsg__c,FinfortOrderDeliveryResponseWrapper>();
            // Map<IntgMsg__c,String> failureResponseMap = new Map<IntgMsg__c,String>();
            
            for(IntgMsg__c msg :responses){
                
                intmsgIds.add(msg.Id);
            }
            
            if(!intmsgIds.isEmpty()){
                
                //Getting ContentDocumentId
                for(ContentDocumentLink cdl:[SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN:intmsgIds AND 
                                             ContentDocument.Title = 'response.json']){
                                                 ContentDocumentMap.put(cdl.LinkedEntityId,cdl.ContentDocumentId);
                                             }
                //Getting VersionData
                for(ContentVersion cv:[SELECT Id, VersionData,FileType,ContentDocumentId FROM ContentVersion
                                       WHERE ContentDocumentId IN:ContentDocumentMap.values()]){
                                           ContentVersionMap.put(cv.ContentDocumentId,cv);
                                       }
            }
            
            for(IntgMsg__c intmsg :responses){
                
                if(ContentDocumentMap.containsKey(intmsg.Id) && ContentVersionMap.containsKey(ContentDocumentMap.get(intmsg.Id))){
                    
                    ContentVersion cv =ContentVersionMap.get(ContentDocumentMap.get(intmsg.Id));
                    
                    if(cv!=null){
                        
                        string jsonstring=cv.VersionData.toString();
                        
                        if(String.isNotblank(jsonstring)){
                            
                            FinfortQueueable queueableInstance = new FinfortQueueable(intmsg,jsonstring);
                            System.enqueueJob(queueableInstance);
                        }
                    }
                }
            }
            
            //if(!successResponseMap.isEmpty()){
            //    processSuccess(successResponseMap);
            // }
            
            //if(!failureResponseMap.isEmpty()){
            //   processFailure(failureResponseMap);
            //}
        }
        
    }
    //******************************************************************************************************************************************
    public static void processSuccess(Map<IntgMsg__c,FinfortOrderDeliveryResponseWrapper> successResp){
        
        try{
            
            Set<String> finfortOrderId =new Set<String>();
            Map<String,String> finFortTypeMap =new Map<String,String>();
            Map<IntgMsg__c,FinfortOrderDeliveryResponseWrapper> itrMap = new Map<IntgMsg__c,FinfortOrderDeliveryResponseWrapper>();
            Map<IntgMsg__c,FinfortOrderDeliveryResponseWrapper> gstMap = new Map<IntgMsg__c,FinfortOrderDeliveryResponseWrapper>();
            
            for(IntgMsg__c msg:successResp.keyset()){
                
                FinfortOrderDeliveryResponseWrapper response =successResp.get(msg);
                
                if(response!=null && response.headerInfo!=null && String.isNotblank(response.headerInfo.ffOrderNumber)){
                    finfortOrderId.add(response.headerInfo.ffOrderNumber);
                }
            }
            
            if(!finfortOrderId.isEmpty()){
                
                for(Applicant_Financial__c fin:[Select Id,FinFortOrderId__c,IsLatest__c,Type__c from Applicant_Financial__c Where FinFortOrderId__c IN:finfortOrderId AND
                                                IsLatest__c =true]){
                                                    
                                                    if(!finFortTypeMap.containsKey(fin.FinFortOrderId__c)){
                                                        finFortTypeMap.put(fin.FinFortOrderId__c,fin.Type__c);
                                                    }
                                                }
            }
            
            
            for(IntgMsg__c msg:successResp.keyset()){
                
                FinfortOrderDeliveryResponseWrapper response =successResp.get(msg);
                
                //Finfort ITR
                if(response!=null && response.headerInfo!=null && String.isNotblank(response.headerInfo.ffOrderNumber) &&
                   finFortTypeMap.containsKey(response.headerInfo.ffOrderNumber) &&
                   finFortTypeMap.get(response.headerInfo.ffOrderNumber)=='Finfort ITR' ){
                       
                       itrMap.put(msg,response);
                   }
                
                //Finfort GST
                if(response!=null && response.headerInfo!=null && String.isNotblank(response.headerInfo.ffOrderNumber) &&
                   finFortTypeMap.containsKey(response.headerInfo.ffOrderNumber) &&
                   finFortTypeMap.get(response.headerInfo.ffOrderNumber)=='Finfort GST' ){
                       
                       gstMap.put(msg,response);
                   }
            }
            
            
            if(!itrMap.isEmpty()){
                processItr(itrMap);
            }
            
            if(!gstMap.isEmpty()){
                
                processGst(gstMap);
            }
            
        }catch (Exception ex) {
            GlobalUtility.logMessage('Error', 'FinfortOrderDeliveryResponseProcessor Class',
                                     'processSuccess', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        
    }
    //******************************************************************************************************************************************
    public static void processFailure(Map<IntgMsg__c,String> failureResp){
        
        try{
            
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new List<SObjectType> { IntgMsg__c.SObjectType});
            
            List<IntgMsg__c> intMsgList =new List<IntgMsg__c>();
            
            for(IntgMsg__c msg:failureResp.keyset()){
                
                FinfortOrderDeliveryResponseWrapper.CallbackWrapper callWrap =new FinfortOrderDeliveryResponseWrapper.CallbackWrapper();
                
                //constructing Callback Resposne JSON
                
                callWrap.code=400;
                callWrap.lender_name='fedfina';
                //callWrap.lender_referenceNumber='';
                //callWrap.ffOrderId='';
                //callWrap.borrower_pan='';
                callWrap.dataTransferStatus='Failure';
                callWrap.failureReason=failureResp.get(msg);
                
                //Updating IntgMsg__c
                if(callWrap!=null){
                    
                    IntgMsg__c intmsg =new IntgMsg__c();
                    intmsg.Id=msg.Id;
                    intmsg.Resp__c=JSON.serialize(callWrap);
                    intmsg.Status__c='Processed';
                    intMsgList.add(intmsg);
                }
            }
            
            if(!intMsgList.isEmpty()) {
                String sObjectName = 'IntgMsg__c';
                List<String> fieldNamesList = new List<String>{'Resp__c','Status__c'};
                    Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                uow.registerDirty(intMsgList);
            }
            uow.commitWork();
            
        }catch (Exception ex) {
            GlobalUtility.logMessage('Error', 'FinfortOrderDeliveryResponseProcessor Class',
                                     'processResponse', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        
    }
    //************************************************ITR**************************************************************************************
    public static void processItr(Map<IntgMsg__c,FinfortOrderDeliveryResponseWrapper> itrResponse){
        
        try{
            Set<String> finfortOrderId =new Set<String>();
            Map<String,Map<String,Applicant_Financial__c>> applicantFinMap =new Map<String,Map<String,Applicant_Financial__c>>();
            List<IntgMsg__c> intMsgList =new List<IntgMsg__c>();
            List<Applicant_Financial_Summary__c> appFinSummary =new List<Applicant_Financial_Summary__c>();
            
            //Get Finfort order id
            for(IntgMsg__c msg:itrResponse.keyset()){
                
                FinfortOrderDeliveryResponseWrapper response =itrResponse.get(msg);
                
                if(response!=null && response.headerInfo!=null && String.isNotblank(response.headerInfo.ffOrderNumber)){
                    finfortOrderId.add(response.headerInfo.ffOrderNumber);
                }
            }
            
            
            if(!finfortOrderId.isEmpty()){
                
                for(Applicant_Financial__c fin:[Select Id,FinFortOrderId__c,IsLatest__c,Type__c,RecordType.DeveloperName from Applicant_Financial__c Where FinFortOrderId__c IN:finfortOrderId AND
                                                IsLatest__c =true]){
                                                    
                                                    if(applicantFinMap.containsKey(fin.FinFortOrderId__c)){
                                                        applicantFinMap.get(fin.FinFortOrderId__c).put(fin.RecordType.DeveloperName,fin);
                                                    }
                                                    else{
                                                        applicantFinMap.put(fin.FinFortOrderId__c,new Map<String,Applicant_Financial__c>{fin.RecordType.DeveloperName=>fin});
                                                    }
                                                }
            }
            
            //Process Resposne
            for(IntgMsg__c msg:itrResponse.keyset()){
                
                FinfortOrderDeliveryResponseWrapper response =itrResponse.get(msg);
                
                if(response!=null){
                    
                    FinfortOrderDeliveryResponseWrapper.CallbackWrapper callWrap =new FinfortOrderDeliveryResponseWrapper.CallbackWrapper();
                    
                    //constructing Callback Resposne JSON
                    if(response.headerInfo!=null){
                        
                        callWrap.code=200;
                        callWrap.lender_name='fedfina';
                        callWrap.lender_referenceNumber=String.isNotblank(response.headerInfo.lenderRefNumber)?response.headerInfo.lenderRefNumber:'';
                        callWrap.ffOrderId=String.isNotblank(response.headerInfo.ffOrderNumber)?response.headerInfo.ffOrderNumber:'';
                        callWrap.borrower_pan=String.isNotblank(response.headerInfo.pan)?response.headerInfo.pan:'';
                        callWrap.dataTransferStatus='Success';
                        callWrap.failureReason='NA';
                    }
                    
                    //Updating IntgMsg__c
                    if(callWrap!=null){
                        
                        IntgMsg__c intmsg =new IntgMsg__c();
                        intmsg.Id=msg.Id;
                        intmsg.Resp__c=JSON.serialize(callWrap);
                        intmsg.Status__c='Processed';
                        intMsgList.add(intmsg);
                    }
                    
                    //PL record
                    if(response.PL!=null && applicantFinMap.containsKey(response.headerInfo.ffOrderNumber) &&
                       applicantFinMap.get(response.headerInfo.ffOrderNumber).containsKey('Profit_Loss')){
                           
                           Applicant_Financial__c appFin =applicantFinMap.get(response.headerInfo.ffOrderNumber).get('Profit_Loss');
                           
                           if(appFin!=null){
                               List<Applicant_Financial_Summary__c> finSummary=processPL(appFin.Id,response.PL);
                               
                               if(finSummary!=null && !finSummary.isEmpty()){
                                   appFinSummary.addAll(finSummary);
                               }
                           }
                       }
                    
                    //BS record
                    if(response.BS!=null && applicantFinMap.containsKey(response.headerInfo.ffOrderNumber) &&
                       applicantFinMap.get(response.headerInfo.ffOrderNumber).containsKey('Balance_Sheet')){
                           
                           Applicant_Financial__c appFin =applicantFinMap.get(response.headerInfo.ffOrderNumber).get('Balance_Sheet');
                           
                           if(appFin!=null){
                               List<Applicant_Financial_Summary__c> finSummary=processBS(appFin.Id,response.BS);
                               
                               if(finSummary!=null && !finSummary.isEmpty()){
                                   appFinSummary.addAll(finSummary);
                               }
                           }
                       }
                }
            }
            
            if(!intMsgList.isEmpty()){
                
                Update intMsgList;
            }
            
            if(!appFinSummary.isEmpty()){
                
                Insert appFinSummary;
            }
            
        }catch (Exception ex) {
            GlobalUtility.logMessage('Error', 'FinfortOrderDeliveryResponseProcessor Class',
                                     'processItr', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
    }
    //******************************************************************************************************************************************
    public static List<Applicant_Financial_Summary__c> processPL(Id applicantFinId,List<FinfortOrderDeliveryResponseWrapper.ItrPl> plResp){
        
        List<Applicant_Financial_Summary__c> finSummary =new List<Applicant_Financial_Summary__c>();
        
        try{
            
            for(FinfortOrderDeliveryResponseWrapper.ItrPl pl:plResp){
                
                Applicant_Financial_Summary__c afs =new Applicant_Financial_Summary__c();
                afs.Applicant_Financial__c=applicantFinId;
                
                if(string.isNotBlank(pl.FY)){
                    afs.Financial_Year__c=convertFiscalYearToPicklist(pl.FY);
                }
                
                if(string.isNotBlank(pl.Date_of_Filing)){
                    afs.Date_of_Filing_ITR__c=IntegrationUtility.getConvertedDate3(pl.Date_of_Filing);
                }
                
                if(string.isNotBlank(pl.Total_Sales)){
                    afs.Total_Sales__c=Decimal.valueOf(pl.Total_Sales);
                }
                
                if(string.isNotBlank(pl.Other_Operating_Income)){
                    afs.Other_Operating_Income_IncomeIncidental__c=Decimal.valueOf(pl.Other_Operating_Income);
                }
                
                if(string.isNotBlank(pl.Non_Business_Income)){
                    afs.Non_Business_Income__c=Decimal.valueOf(pl.Non_Business_Income);
                }
                
                if(string.isNotBlank(pl.Opening_Stock)){
                    afs.Opening_Stock__c=Decimal.valueOf(pl.Opening_Stock);
                }
                
                if(string.isNotBlank(pl.Closing_Stock)){
                    afs.Closing_Stock__c=Decimal.valueOf(pl.Closing_Stock);
                }
                
                if(string.isNotBlank(pl.Purchases)){
                    afs.Purchases__c=Decimal.valueOf(pl.Purchases);
                }
                
                if(string.isNotBlank(pl.Direct_Expenses)){
                    afs.Direct_Expenses__c=Decimal.valueOf(pl.Direct_Expenses);
                }
                
                if(string.isNotBlank(pl.Gross_Profit)){
                    afs.Gross_Profit__c=Decimal.valueOf(pl.Gross_Profit);
                }
                
                if(string.isNotBlank(pl.Office_And_Administrative_Expenses)){
                    afs.Office_Administrative_Expenses__c=Decimal.valueOf(pl.Office_And_Administrative_Expenses);
                }
                
                if(string.isNotBlank(pl.Other_Indirect_Expenses)){
                    afs.Other_Indirect_Expenses__c=Decimal.valueOf(pl.Other_Indirect_Expenses);
                }
                
                if(string.isNotBlank(pl.Non_Operating_Expenses)){
                    afs.Non_Operating_Expenses_FxLoss_AssetLoss__c=Decimal.valueOf(pl.Non_Operating_Expenses);
                }
                
                if(string.isNotBlank(pl.Salary_To_Partners_or_Directors)){
                    afs.Salary_to_Partner_Directors__c=Decimal.valueOf(pl.Salary_To_Partners_or_Directors);
                }
                
                if(string.isNotBlank(pl.EBITDA)){
                    afs.EBITDA__c=Decimal.valueOf(pl.EBITDA);
                }
                
                if(string.isNotBlank(pl.Interest_On_Term_Loans)){
                    afs.Interest_on_Term_Loans__c=Decimal.valueOf(pl.Interest_On_Term_Loans);
                }
                
                if(string.isNotBlank(pl.Interest_On_CC_or_OD_Limits)){
                    afs.Interest_on_CC_OD_limits__c=Decimal.valueOf(pl.Interest_On_CC_or_OD_Limits);
                }
                
                if(string.isNotBlank(pl.Interest_On_Partners_Capital)){
                    afs.Interest_on_Partner_Capital__c=Decimal.valueOf(pl.Interest_On_Partners_Capital);
                }
                
                if(string.isNotBlank(pl.Profit_Before_Depreciation_and_Tax)){
                    afs.Profit_Before_Depreciation_and_Tax_PBDT__c=Decimal.valueOf(pl.Profit_Before_Depreciation_and_Tax);
                }
                
                if(string.isNotBlank(pl.Depreciation)){
                    afs.Depreciation__c=Decimal.valueOf(pl.Depreciation);
                }
                
                if(string.isNotBlank(pl.Profit_Before_Tax)){
                    afs.ProfitBeforeTax__c=Decimal.valueOf(pl.Profit_Before_Tax);
                }
                
                if(string.isNotBlank(pl.Taxes)){
                    afs.Taxes__c=Decimal.valueOf(pl.Taxes);
                }
                
                if(string.isNotBlank(pl.PAT)){
                    afs.PAT__c=Decimal.valueOf(pl.PAT);
                }
                
                finSummary.add(afs);
                
            }
            
            
            
            
            
        }catch (Exception ex) {
            GlobalUtility.logMessage('Error', 'FinfortOrderDeliveryResponseProcessor Class',
                                     'processPL', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        
        return finSummary;
    }
    
    //******************************************************************************************************************************************
    public static List<Applicant_Financial_Summary__c> processBS(Id applicantFinId,List<FinfortOrderDeliveryResponseWrapper.ItrBs> bsResp){
        
        List<Applicant_Financial_Summary__c> finSummary =new List<Applicant_Financial_Summary__c>();
        
        try{
            
            for(FinfortOrderDeliveryResponseWrapper.ItrBs bs:bsResp){
                
                Applicant_Financial_Summary__c afs =new Applicant_Financial_Summary__c();
                afs.Applicant_Financial__c=applicantFinId;
                
                if(string.isNotBlank(bs.FY)){
                    afs.Financial_Year__c=convertFiscalYearToPicklist(bs.FY);
                }
                
                if(string.isNotBlank(bs.Share_Capital_or_Partners_Capital)){
                    afs.Share_capital_Partner_s_Capital__c=Decimal.valueOf(bs.Share_Capital_or_Partners_Capital);
                }
                
                if(string.isNotBlank(bs.PL_AC)){
                    //afs.=bs.PL_AC;
                }
                
                if(string.isNotBlank(bs.Revaluation_Reserves_Notional_Reserves)){
                    afs.Revaluation_Reserves_Notional_Reserves__c=Decimal.valueOf(bs.Revaluation_Reserves_Notional_Reserves);
                }
                
                if(string.isNotBlank(bs.Net_Worth)){
                    afs.Net_worth__c=Decimal.valueOf(bs.Net_Worth);
                }
                
                if(string.isNotBlank(bs.Advances_To_Group_Co_Or_Friends)){
                    afs.Adavces_to_group_co_friends__c=Decimal.valueOf(bs.Advances_To_Group_Co_Or_Friends);
                }
                
                if(string.isNotBlank(bs.Unsecured_Loans_From_Promoters_And_Family_Members)){
                    afs.unsecured_Loan_from_promoters_family_m__c=Decimal.valueOf(bs.Unsecured_Loans_From_Promoters_And_Family_Members);
                }
                
                if(string.isNotBlank(bs.Misc_Exp_Not_Written_Off)){
                    afs.Misc_Exp_Not_written_off__c=Decimal.valueOf(bs.Misc_Exp_Not_Written_Off);
                }
                
                if(string.isNotBlank(bs.Adjusted_Tangible_Networth)){
                    afs.Adjusted_tangible_Netwroth__c=Decimal.valueOf(bs.Adjusted_Tangible_Networth);
                }
                
                if(string.isNotBlank(bs.Bank_Borrowing_Working_Capital)){
                    afs.Bank_Borrowing_Working_Capital_OD_CC__c=Decimal.valueOf(bs.Bank_Borrowing_Working_Capital);
                }
                
                if(string.isNotBlank(bs.Secured_Debts_Banks_And_Nbfc)){
                    afs.Secured_debts_Banks_Ndfc__c=Decimal.valueOf(bs.Secured_Debts_Banks_And_Nbfc);
                }
                
                if(string.isNotBlank(bs.Unsecured_Debt_Banks_And_Nbfc)){
                    afs.Unsecured_debts_Banks_Ndfc__c=Decimal.valueOf(bs.Unsecured_Debt_Banks_And_Nbfc);
                }
                
                if(string.isNotBlank(bs.Other_Loans)){
                    afs.Other_Loans_From_private_parties__c=Decimal.valueOf(bs.Other_Loans);
                }
                
                if(string.isNotBlank(bs.Total_Loan_Funds)){
                    afs.Total_Loan_funds__c=Decimal.valueOf(bs.Total_Loan_Funds);
                }
                
                if(string.isNotBlank(bs.Sundry_Creditors)){
                    afs.Sundry_creditors__c=Decimal.valueOf(bs.Sundry_Creditors);
                }
                
                if(string.isNotBlank(bs.Advances_From_Customers)){
                    afs.Advances_from_customers__c=Decimal.valueOf(bs.Advances_From_Customers);
                }
                
                if(string.isNotBlank(bs.Other_Current_Liabilities)){
                    afs.Other_current_liabilities__c=Decimal.valueOf(bs.Other_Current_Liabilities);
                }
                
                if(string.isNotBlank(bs.Provisions)){
                    //afs.=bs.Provisions;
                }
                
                if(string.isNotBlank(bs.Deffered_Tax_Liability)){
                    afs.Deffered_Tax_Liability_Assets__c=Decimal.valueOf(bs.Deffered_Tax_Liability);
                }
                
                if(string.isNotBlank(bs.Total_Liabilities)){
                    afs.TotlCurrtLiabilities__c=Decimal.valueOf(bs.Total_Liabilities);
                }
                
                if(string.isNotBlank(bs.Assets)){
                    afs.Assets__c=Decimal.valueOf(bs.Assets);
                }
                
                if(string.isNotBlank(bs.Net_Tangible_Fixed_Assets)){
                    afs.Net_Tangible_Fixed_Assets_Including_Cap__c=Decimal.valueOf(bs.Net_Tangible_Fixed_Assets);
                }
                
                if(string.isNotBlank(bs.Net_Intangible_Fixed_Assets)){
                    afs.Net_Intangible_Fixed_Assets__c=Decimal.valueOf(bs.Net_Intangible_Fixed_Assets);
                }
                
                if(string.isNotBlank(bs.Stock)){
                    afs.Stock__c=Decimal.valueOf(bs.Stock);
                }
                
                if(string.isNotBlank(bs.Debtors_Less_Than_6_Months)){
                    afs.LessSix_months__c=Decimal.valueOf(bs.Debtors_Less_Than_6_Months);
                }
                
                if(string.isNotBlank(bs.Debtors_Greater_Than_6_Months)){
                    afs.Greaterthan6__c=Decimal.valueOf(bs.Debtors_Greater_Than_6_Months);
                }
                
                if(string.isNotBlank(bs.Advances_To_Suppliers)){
                    afs.Advances_to_Suppliers__c=Decimal.valueOf(bs.Advances_To_Suppliers);
                }
                
                if(string.isNotBlank(bs.Investments)){
                    afs.Investments__c=Decimal.valueOf(bs.Investments);
                }
                
                if(string.isNotBlank(bs.Other_Loans_And_Advances)){
                    afs.Other_loans_advances__c=Decimal.valueOf(bs.Other_Loans_And_Advances);
                }
                
                if(string.isNotBlank(bs.Prepaid_Expenses)){
                    afs.Prepaid_expenses__c=Decimal.valueOf(bs.Prepaid_Expenses);
                }
                
                if(string.isNotBlank(bs.Other_Current_Assets)){
                    afs.Other_current_assets__c=Decimal.valueOf(bs.Other_Current_Assets);
                }
                
                if(string.isNotBlank(bs.Other_Non_Current_Assets_Security_Deposits)){
                    afs.Other_Non_Current_assets_Security_Depos__c=Decimal.valueOf(bs.Other_Non_Current_Assets_Security_Deposits);
                }
                
                if(string.isNotBlank(bs.Cash_And_Bank_Balances)){
                    afs.Cash_Bank_Balances__c=Decimal.valueOf(bs.Cash_And_Bank_Balances);
                }
                
                if(string.isNotBlank(bs.Total_Assets)){
                    //afs.=bs.Total_Assets;
                }
                
                if(string.isNotBlank(bs.Difference)){
                    afs.Difference__c=Decimal.valueOf(bs.Difference);
                }
                
                finSummary.add(afs);
            }
            
            
            
            
        }catch (Exception ex) {
            GlobalUtility.logMessage('Error', 'FinfortOrderDeliveryResponseProcessor Class',
                                     'processBS', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        
        return finSummary;
    }
    
    //****************************************************GST**************************************************************************************
    public static void processGst(Map<IntgMsg__c,FinfortOrderDeliveryResponseWrapper> gstResponse){
        
        try{
            
            Set<String> finfortOrderId =new Set<String>();
            Set<String> gstNumber =new Set<String>();
            List<IntgMsg__c> intMsgList =new List<IntgMsg__c>();
            //Id gstrecordTypeId = Schema.SObjectType.Applicant_Financial__c.getRecordTypeInfosByDeveloperName().get('GST').getRecordTypeId();
            
            Map<String,Map<String,List<FinfortOrderDeliveryResponseWrapper.innerCommanTags>>> summaryDataMap =new Map<String,Map<String,List<FinfortOrderDeliveryResponseWrapper.innerCommanTags>>>();
            Map<String,Map<String,List<FinfortOrderDeliveryResponseWrapper.innerCommanTags>>> gst3bDataMap =new Map<String,Map<String,List<FinfortOrderDeliveryResponseWrapper.innerCommanTags>>>();
            Map<String,Map<String,List<FinfortOrderDeliveryResponseWrapper.innerCommanTags>>> summaryAnalysisDataMap =new Map<String,Map<String,List<FinfortOrderDeliveryResponseWrapper.innerCommanTags>>>();
            Map<String,Map<String,List<FinfortOrderDeliveryResponseWrapper.innerCommanTags>>> customerSupplierDataMap=new Map<String,Map<String,List<FinfortOrderDeliveryResponseWrapper.innerCommanTags>>>();
            Map<String,Map<String,List<FinfortOrderDeliveryResponseWrapper.innerCommanTags>>> hsnChapterDataMap=new Map<String,Map<String,List<FinfortOrderDeliveryResponseWrapper.innerCommanTags>>>();
            Map<String,Map<String,List<FinfortOrderDeliveryResponseWrapper.profileexceldata>>> profileExcelDataMap=new Map<String,Map<String,List<FinfortOrderDeliveryResponseWrapper.profileexceldata>>>();
            Map<String,Map<String,List<FinfortOrderDeliveryResponseWrapper.filingdata>>> filingDataMap=new Map<String,Map<String,List<FinfortOrderDeliveryResponseWrapper.filingdata>>>();
            
            //Get Finfort orderId
            for(IntgMsg__c intmsg:gstResponse.keyset()){
                
                FinfortOrderDeliveryResponseWrapper response =gstResponse.get(intmsg);
                
                if(response!=null && response.headerInfo!=null && String.isNotblank(response.headerInfo.ffOrderNumber)){
                    finfortOrderId.add(response.headerInfo.ffOrderNumber);
                }
                
                //Get GST Number
                if(response!=null && response.data!=null && response.data.gst!=null){
                    
                    for(FinfortOrderDeliveryResponseWrapper.GST gt:response.data.gst){
                        
                        if(gt.meta!=null && String.isNotBlank(gt.meta.key)){
                            gstNumber.add(gt.meta.key);
                        }
                        
                    }
                    
                }
                
                
            }
            
            /*if(!finfortOrderId.isEmpty() && !gstNumber.isEmpty()){

List<Applicant_Financial__c> fincal =[Select Id,IsLatest__c,FinFortOrderId__c,GSTIN__c,RecordType.DeveloperName from Applicant_Financial__c 
Where ((FinFortOrderId__c IN :finfortOrderId AND GSTIN=null) OR
(FinFortOrderId__c IN :finfortOrderId AND GSTIN__c IN:gstNumber)) 
AND IsLatest__c=true AND RecordType.DeveloperName='GST'];

if(!fin.isEmpty()){
IntegrationUtility.updateBooleanFlag(fincal,'IsLatest__c',False);
}

}*/
            
            //Getting Applicant Financial
            if(!gstNumber.isEmpty()){
                
                for(Applicant_Financial__c fin:[Select Id,GSTIN__c,RecordType.DeveloperName,FinFortOrderId__c,Loan_Applicant__c from Applicant_Financial__c 
                                                Where GSTIN__c IN :gstNumber AND IsLatest__c=true 
                                                AND RecordType.DeveloperName='GST' AND FinFortOrderId__c IN :finfortOrderId]){
                                                    
                                                    applicantFinancialMap.put(fin.FinFortOrderId__c,new Map<String,Applicant_Financial__c>{fin.GSTIN__c=>fin});
                                                    
                                                }
            }
            
            //Process response to Create Applicant Financial
            for(IntgMsg__c intmsg:gstResponse.keyset()){
                
                FinfortOrderDeliveryResponseWrapper response =gstResponse.get(intmsg);
                
                if(response!=null && response.headerInfo!=null &&response.data!=null && response.data.gst!=null){
                    
                    for(FinfortOrderDeliveryResponseWrapper.GST gstLp:response.data.gst){
                        
                        //summary_data(Month Basic Logic)
                        if(String.isNotBlank(response.headerInfo.ffOrderNumber) && gstLp.summary_data!=null){
                            
                            summaryDataMap.put(response.headerInfo.ffOrderNumber,new Map<String,List<FinfortOrderDeliveryResponseWrapper.innerCommanTags>>{gstLp.meta.key=>gstLp.summary_data});
                        }
                        
                        //gstr3b_data(Month Basic Logic)
                        if(String.isNotBlank(response.headerInfo.ffOrderNumber) && gstLp.gstr3b_data!=null){
                            
                            gst3bDataMap.put(response.headerInfo.ffOrderNumber,new Map<String,List<FinfortOrderDeliveryResponseWrapper.innerCommanTags>>{gstLp.meta.key=>gstLp.gstr3b_data});
                        }
                        
                        //summary_analysis_data (Yearly Basic Logic)
                        if(String.isNotBlank(response.headerInfo.ffOrderNumber) && gstLp.summary_analysis_data!=null){
                            
                            summaryAnalysisDataMap.put(response.headerInfo.ffOrderNumber, new Map<String,List<FinfortOrderDeliveryResponseWrapper.innerCommanTags>>{gstLp.meta.key=>gstLp.summary_analysis_data});
                        }
                        
                        //customer_supplier_data (Creating top 20 record based on Rank Wise)
                        if(String.isNotBlank(response.headerInfo.ffOrderNumber) && gstLp.customer_supplier_data!=null){
                            
                            customerSupplierDataMap.put(response.headerInfo.ffOrderNumber, new Map<String,List<FinfortOrderDeliveryResponseWrapper.innerCommanTags>>{gstLp.meta.key=>gstLp.customer_supplier_data});
                        }
                        
                        //hsn_chapter_data (Creating top 10 record based on Rank Wise)
                        if(String.isNotBlank(response.headerInfo.ffOrderNumber) && gstLp.hsn_chapter_data!=null){
                            
                            hsnChapterDataMap.put(response.headerInfo.ffOrderNumber, new Map<String,List<FinfortOrderDeliveryResponseWrapper.innerCommanTags>>{gstLp.meta.key=>gstLp.hsn_chapter_data});
                        }
                        
                        //profile_excel_data (Creating all the record)
                        if(String.isNotBlank(response.headerInfo.ffOrderNumber) && gstLp.profile_excel_data!=null){
                            
                            profileExcelDataMap.put(response.headerInfo.ffOrderNumber, new Map<String,List<FinfortOrderDeliveryResponseWrapper.profileexceldata>>{gstLp.meta.key=>gstLp.profile_excel_data});
                        }
                        
                        //filing_data (Creating all the record)
                        if(String.isNotBlank(response.headerInfo.ffOrderNumber) && gstLp.filing_data!=null){
                            
                            filingDataMap.put(response.headerInfo.ffOrderNumber, new Map<String,List<FinfortOrderDeliveryResponseWrapper.filingdata>>{gstLp.meta.key=>gstLp.filing_data});
                        }
                    }
                    
                    
                    
                }
                
                //constructing Callback Resposne JSON
                FinfortOrderDeliveryResponseWrapper.CallbackWrapper callWrap =new FinfortOrderDeliveryResponseWrapper.CallbackWrapper();
                
                if(response.headerInfo!=null){
                    
                    callWrap.code=200;
                    callWrap.lender_name='fedfina';
                    callWrap.lender_referenceNumber=String.isNotblank(response.headerInfo.lenderRefNumber)?response.headerInfo.lenderRefNumber:'';
                    callWrap.ffOrderId=String.isNotblank(response.headerInfo.ffOrderNumber)?response.headerInfo.ffOrderNumber:'';
                    callWrap.borrower_pan=String.isNotblank(response.headerInfo.pan)?response.headerInfo.pan:'';
                    callWrap.dataTransferStatus='Success';
                    callWrap.failureReason='NA';
                }
                
                //Updating IntgMsg__c
                if(callWrap!=null){
                    
                    IntgMsg__c msg =new IntgMsg__c();
                    msg.Id=intmsg.Id;
                    msg.Resp__c=JSON.serialize(callWrap);
                    msg.Status__c='Processed';
                    intMsgList.add(msg);
                }
                
            }
            
            
            //Update Integration Message
            if(!intMsgList.isEmpty()){
                
                Update intMsgList;
            }
            
            if(!summaryDataMap.isEmpty()){
                gstSummaryData(summaryDataMap);
            }
            
            if(!gst3bDataMap.isEmpty()){
                gst3bData(gst3bDataMap);
            }
            
            if(!summaryAnalysisDataMap.isEmpty()){
                gstSummaryAnalysis(summaryAnalysisDataMap);
            }
            
            if(!customerSupplierDataMap.isEmpty()){
                list<Applicant_Financial_Summary__c> financialList =gstCustomerSupplierData(customerSupplierDataMap);
                
                if (!financialList.isEmpty()) {
                    financialSummaryList.addAll(financialList);
                }
            }
            
            if (!hsnChapterDataMap.isEmpty()) {
                list<Applicant_Financial_Summary__c> financialList =gstHsnChapterData(hsnChapterDataMap);
                
                if (!financialList.isEmpty()) {
                    financialSummaryList.addAll(financialList);
                }
            }
            
            if (!profileExcelDataMap.isEmpty()) {
                list<Applicant_Financial_Summary__c> financialList =gstProfileExcelData(profileExcelDataMap);
                
                if (!financialList.isEmpty()) {
                    financialSummaryList.addAll(financialList);
                }
            }
            
            if (!filingDataMap.isEmpty()) {
                list<Applicant_Financial_Summary__c> financialList =gstFilingData(filingDataMap);
                
                if (!financialList.isEmpty()) {
                    financialSummaryList.addAll(financialList);
                }
            }
            
            //Process Global Map Logic
            if (!checkFinancialSummaryMap.isEmpty()) {
                
                for (string gstNum : checkFinancialSummaryMap.keySet()) {
                    
                    Map<String,Applicant_Financial_Summary__c> monthOrYear =checkFinancialSummaryMap.get(gstNum);
                    
                    if (!monthOrYear.isEmpty()) {
                        
                        for (string key : monthOrYear.keySet()) {
                            
                            financialSummaryList.add(monthOrYear.get(key));
                        }
                    }
                    
                }
                
            }
            
            //Insert all the Applicant Financial Summary
            if(!financialSummaryList.isEmpty()){
                
                Insert financialSummaryList;
            }
            
            
            
        }catch (Exception ex) {
            GlobalUtility.logMessage('Error', 'FinfortOrderDeliveryResponseProcessor Class',
                                     'processGst', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        
    }
    //**************************************************************************************************************************
    public static void gstSummaryData(Map<String,Map<String,List<FinfortOrderDeliveryResponseWrapper.innerCommanTags>>> summaryDataMap){
        
        
        try{
            
            for(string orderid:summaryDataMap.keySet()){
                
                Map<String,List<FinfortOrderDeliveryResponseWrapper.innerCommanTags>> summarayData=summaryDataMap.get(orderid);
                
                if(!summarayData.isEmpty()){
                    
                    for (string gstnumber :summarayData.keySet()) {
                        
                        //Checking For Applicant_Financial__c
                        
                        if(applicantFinancialMap.containsKey(orderid) &&
                           applicantFinancialMap.get(orderid).containsKey(gstnumber)){
                               
                               Applicant_Financial__c applicantfin =applicantFinancialMap.get(orderid).get(gstnumber);
                               List<FinfortOrderDeliveryResponseWrapper.innerCommanTags>  summaryData =summarayData.get(gstnumber);
                               
                               //Summary Data Logic
                               if(!summaryData.isEmpty()){
                                   
                                   for(FinfortOrderDeliveryResponseWrapper.innerCommanTags smry:summaryData){
                                       
                                       if(String.isNotBlank(smry.period_type) && smry.period_type.toLowerCase()=='monthly' &&
                                          String.isNotBlank(smry.month)){
                                              
                                              Applicant_Financial_Summary__c finSum;
                                              
                                              //Check Applicant_Financial_Summary Record
                                              if(checkFinancialSummaryMap.containsKey(gstnumber) &&
                                                 checkFinancialSummaryMap.get(gstnumber).containsKey(smry.month.toLowerCase())){
                                                     
                                                     finSum = checkFinancialSummaryMap.get(gstnumber).get(smry.month.toLowerCase());
                                                     
                                                 }else{
                                                     finSum =new Applicant_Financial_Summary__c();
                                                     finSum.GST_Month_Year__c = smry.month.toLowerCase();
                                                     finSum.Type__c='Monthly GST Analysis';
                                                     finSum.Applicant_Financial__c=applicantfin.Id;
                                                 }
                                              
                                              //Check Data Object
                                              
                                              if(smry.data!=null){
                                                  
                                                  FinfortOrderDeliveryResponseWrapper.innerData dataval =smry.data;
                                                  
                                                  if (String.isNotBlank(dataval.peak_or_lull)) {
                                                      finSum.PeakorLull__c=dataval.peak_or_lull;
                                                  }
                                                  
                                                  if (dataval.total_adjusted_revenue!=null) {
                                                      finSum.AdjustRevTot__c=dataval.total_adjusted_revenue;
                                                  }
                                                  
                                                  if (dataval.total_purchase_and_expenses!=null) {
                                                      finSum.TotalPurchaseExp__c=dataval.total_purchase_and_expenses;
                                                  }
                                                  
                                                  if (dataval.margin!=null) {
                                                      finSum.Margin__c=dataval.margin;
                                                  }
                                                  
                                                  if (dataval.margin_percentage!=null) {
                                                      finSum.MarginPerc__c=dataval.margin_percentage;
                                                  }
                                              }
                                              
                                              //Assign it to Global Value
                                              if(checkFinancialSummaryMap.containsKey(gstnumber)){
                                                  
                                                  checkFinancialSummaryMap.get(gstnumber).put(smry.month.toLowerCase(),finSum);
                                                  
                                              }else{
                                                  checkFinancialSummaryMap.put(gstnumber,new Map<String,Applicant_Financial_Summary__c>{smry.month.toLowerCase()=>finSum});
                                              }
                                          }
                                   }
                               }
                               
                           }
                        
                    }
                    
                }
                
            }
            
        }catch (Exception ex) {
            GlobalUtility.logMessage('Error', 'FinfortOrderDeliveryResponseProcessor Class',
                                     'summaryData', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
    }
    //**************************************************************************************************************************
    public static void gst3bData(Map<String,Map<String,List<FinfortOrderDeliveryResponseWrapper.innerCommanTags>>> gst3bDataMap){
        
        try {
            
            for(string orderid:gst3bDataMap.keySet()){
                
                Map<String,List<FinfortOrderDeliveryResponseWrapper.innerCommanTags>> gstData=gst3bDataMap.get(orderid);
                
                if(!gstData.isEmpty()){
                    
                    for (string gstnumber :gstData.keySet()) {
                        
                        //Checking For Applicant_Financial__c
                        
                        if(applicantFinancialMap.containsKey(orderid) &&
                           applicantFinancialMap.get(orderid).containsKey(gstnumber)){
                               
                               Applicant_Financial__c applicantfin =applicantFinancialMap.get(orderid).get(gstnumber);
                               List<FinfortOrderDeliveryResponseWrapper.innerCommanTags>  gst3b =gstData.get(gstnumber);
                               
                               //GST3b Data Logic
                               if(!gst3b.isEmpty()){
                                   
                                   for(FinfortOrderDeliveryResponseWrapper.innerCommanTags gst3Data:gst3b){
                                       
                                       if(String.isNotBlank(gst3Data.period_type) && gst3Data.period_type.toLowerCase()=='monthly' &&
                                          String.isNotBlank(gst3Data.month)){
                                              
                                              Applicant_Financial_Summary__c finSum;
                                              
                                              //Check Applicant_Financial_Summary Record
                                              if(checkFinancialSummaryMap.containsKey(gstnumber) &&
                                                 checkFinancialSummaryMap.get(gstnumber).containsKey(gst3Data.month.toLowerCase())){
                                                     
                                                     finSum = checkFinancialSummaryMap.get(gstnumber).get(gst3Data.month.toLowerCase());
                                                     
                                                 }else{
                                                     finSum =new Applicant_Financial_Summary__c();
                                                     finSum.GST_Month_Year__c = gst3Data.month.toLowerCase();
                                                     finSum.Type__c='Monthly GST Analysis';
                                                     finSum.Applicant_Financial__c=applicantfin.Id;
                                                 }
                                              
                                              //Check Data Object
                                              
                                              if(gst3Data.data!=null){
                                                  
                                                  FinfortOrderDeliveryResponseWrapper.innerData dataval =gst3Data.data;
                                                  
                                                  if (dataval.total_adjusted_revenue!=null) {
                                                      finSum.AdjustRevTot__c=dataval.total_adjusted_revenue;
                                                  }
                                                  
                                                  if (dataval.total_taxable_value!=null) {
                                                      finSum.TotalTaxableValue__c=dataval.total_taxable_value;
                                                  }
                                                  
                                                  if (dataval.diff_gstr1_gstr3b!=null) {
                                                      finSum.Diffgstr1gstr3b__c=dataval.diff_gstr1_gstr3b;
                                                  }
                                                  
                                                  if (dataval.out_tax_supplies!=null) {
                                                      finSum.OutTaxSupplies__c=dataval.out_tax_supplies;
                                                  }
                                                  
                                                  if (dataval.out_tax_supplies_zero_rated!=null) {
                                                      finSum.OutTaxSuppZeroRated__c=dataval.out_tax_supplies_zero_rated;
                                                  }
                                                  
                                                  if (dataval.out_tax_supplies_nil_rated_exempted!=null) {
                                                      finSum.OutTaxSuppNilRatedExem__c=dataval.out_tax_supplies_nil_rated_exempted;
                                                  }
                                                  
                                                  if (dataval.out_tax_supplies_non_gst!=null) {
                                                      finSum.OutTaxSuppNonGST__c=dataval.out_tax_supplies_non_gst;
                                                  }
                                              }
                                              
                                              //Assign it to Global Value
                                              if(checkFinancialSummaryMap.containsKey(gstnumber)){
                                                  
                                                  checkFinancialSummaryMap.get(gstnumber).put(gst3Data.month.toLowerCase(),finSum);
                                                  
                                              }else{
                                                  checkFinancialSummaryMap.put(gstnumber,new Map<String,Applicant_Financial_Summary__c>{gst3Data.month.toLowerCase()=>finSum});
                                              }
                                              
                                          }
                                       
                                   }
                                   
                               }
                               
                           }
                        
                    }
                    
                }
            }
            
        } catch (Exception ex) {
            GlobalUtility.logMessage('Error', 'FinfortOrderDeliveryResponseProcessor Class',
                                     'gst3bData', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        
    }
    //**************************************************************************************************************************
    public static void gstSummaryAnalysis(Map<String,Map<String,List<FinfortOrderDeliveryResponseWrapper.innerCommanTags>>> summaryAnalysisMap){
        
        try {
            
            for(string orderid:summaryAnalysisMap.keySet()){
                
                Map<String,List<FinfortOrderDeliveryResponseWrapper.innerCommanTags>> summaryAnalysisData =summaryAnalysisMap.get(orderid);
                
                if (!summaryAnalysisData.isEmpty()) {
                    
                    for (String gstnumber : summaryAnalysisData.keySet()) {
                        
                        //Checking For Applicant_Financial__c
                        
                        if(applicantFinancialMap.containsKey(orderid) &&
                           applicantFinancialMap.get(orderid).containsKey(gstnumber)){
                               
                               Applicant_Financial__c applicantfin =applicantFinancialMap.get(orderid).get(gstnumber);
                               List<FinfortOrderDeliveryResponseWrapper.innerCommanTags> analysisData =summaryAnalysisData.get(gstnumber);
                               
                               //summary analysis data Logic
                               if (!analysisData.isEmpty()) {
                                   
                                   for (FinfortOrderDeliveryResponseWrapper.innerCommanTags alys : analysisData) {
                                       
                                       if (String.isNotBlank(alys.fy) && String.isNotBlank(alys.period_type) &&
                                           alys.period_type.toLowerCase()=='yearly') {
                                               
                                               string fy=alys.fy.left(5)+'20'+alys.fy.right(2);
                                               
                                               Applicant_Financial_Summary__c finSum;
                                               
                                               //Check Applicant_Financial_Summary Record
                                               if(checkFinancialSummaryMap.containsKey(gstnumber) &&
                                                  checkFinancialSummaryMap.get(gstnumber).containsKey(fy)){
                                                      
                                                      finSum = checkFinancialSummaryMap.get(gstnumber).get(fy);
                                                      
                                                  }else{
                                                      finSum =new Applicant_Financial_Summary__c();
                                                      finSum.Financial_Year__c = fy;
                                                      finSum.Type__c = 'Yearly GST Analysis';
                                                      finSum.Applicant_Financial__c=applicantfin.Id;
                                                  }
                                               
                                               //Check Data Object
                                               if (alys.data!=null) {
                                                   
                                                   FinfortOrderDeliveryResponseWrapper.innerData dataval =alys.data;
                                                   
                                                   if (dataval.total_adjusted_revenue!=null) {
                                                       finSum.AdjustRevTot__c = dataval.total_adjusted_revenue;
                                                   }
                                                   
                                                   if (dataval.total_adjusted_revenue_monthly_average!=null) {
                                                       finSum.AdjustedMonthAvg__c = dataval.total_adjusted_revenue_monthly_average;
                                                   }
                                                   
                                                   if (dataval.total_adjusted_revenue_quarterly_average!=null) {
                                                       finSum.AdjustedQuarterlyAvg__c = dataval.total_adjusted_revenue_quarterly_average;
                                                   }
                                                   
                                                   if (dataval.total_purchase_and_expenses!=null) {
                                                       finSum.TotalPurchaseExp__c = dataval.total_purchase_and_expenses;
                                                   }
                                                   
                                                   if (dataval.total_purchase_and_expenses_monthly_average!=null) {
                                                       finSum.TotalPurchaseExpMnthlyAvg__c = dataval.total_purchase_and_expenses_monthly_average;
                                                   }
                                                   
                                                   if (dataval.total_purchase_and_expenses_quarterly_average!=null) {
                                                       finSum.TotalPurcExpQuarAvg__c = dataval.total_purchase_and_expenses_quarterly_average;
                                                   }
                                                   
                                                   if (dataval.margin!=null) {
                                                       finSum.Margin__c = dataval.margin;
                                                   }
                                                   
                                                   if (dataval.margin_percentage!=null) {
                                                       finSum.MarginPerc__c = dataval.margin_percentage;
                                                   }
                                                   
                                                   if (dataval.margin_monthly_average!=null) {
                                                       finSum.MarginMnthlyAvg__c = dataval.margin_monthly_average;
                                                   }
                                                   
                                                   if (dataval.margin_quarterly_average!=null) {
                                                       finSum.MarginQuarterlyAvg__c = dataval.margin_quarterly_average;
                                                   }
                                                   
                                                   if (dataval.revenue_growth_YoY!=null) {
                                                       finSum.RevenueGrowthYOY__c = dataval.revenue_growth_YoY;
                                                   }
                                                   
                                                   if (dataval.margin_growth_YoY!=null) {
                                                       finSum.MarginGrowthYOY__c = dataval.margin_growth_YoY;
                                                   }
                                                   
                                                   if (dataval.top_10_products_revenue_percentage!=null) {
                                                       finSum.Top10ProdRevPerc__c = dataval.top_10_products_revenue_percentage;
                                                   }
                                                   
                                                   if (dataval.products_gt_5_percent_revenue!=null) {
                                                       finSum.Prodgt5PercRev__c = dataval.products_gt_5_percent_revenue;
                                                   }
                                                   
                                                   if (dataval.products_gt_2_percent_revenue!=null) {
                                                       finSum.Prodgt2PercRev__c = dataval.products_gt_2_percent_revenue;
                                                   }
                                                   
                                                   if (dataval.products_gt_1_percent_revenue!=null) {
                                                       finSum.Prodgt1PercRevenue__c = dataval.products_gt_1_percent_revenue;
                                                   }
                                                   
                                                   if (dataval.growing_trend_products_count!=null) {
                                                       finSum.GrowingTrendProdCount__c = dataval.growing_trend_products_count;
                                                   }
                                                   
                                                   if (dataval.growing_trend_products_revenue_percentage!=null) {
                                                       finSum.DegrowingTrendProdRevPercentage__c = dataval.growing_trend_products_revenue_percentage;
                                                   }
                                                   
                                                   if (dataval.degrowing_trend_products_count!=null) {
                                                       finSum.DegrowingTrendProdCount__c = dataval.degrowing_trend_products_count;
                                                   }
                                                   
                                                   if (dataval.degrowing_trend_products_revenue_percentage!=null) {
                                                       finSum.DegrowingTrendProdRevPercentage__c = dataval.degrowing_trend_products_revenue_percentage;
                                                   }
                                                   
                                                   if (dataval.stagnant_products_count!=null) {
                                                       finSum.StagnantProdCount__c = dataval.stagnant_products_count;
                                                   }
                                                   
                                                   if (dataval.stagnant_products_revenue_percentage!=null) {
                                                       finSum.StagnantProdRevPerc__c = dataval.stagnant_products_revenue_percentage;
                                                   }
                                                   
                                                   if (dataval.top_10_new_products_added_count!=null) {
                                                       finSum.Top10NewProdAddedCount__c = dataval.top_10_new_products_added_count;
                                                   }
                                                   
                                                   if (dataval.top_10_new_products_added_revenue!=null) {
                                                       finSum.Top10NewProdAddedRev__c = dataval.top_10_new_products_added_revenue;
                                                   }
                                                   
                                                   if (dataval.top_10_new_products_added_revenue_percentage!=null) {
                                                       finSum.Top10NewProdAddedRevPercentage__c = dataval.top_10_new_products_added_revenue_percentage;
                                                   }
                                                   
                                                   if (dataval.top_20_suppliers_revenue_percentage!=null) {
                                                       finSum.Top20SuppliersRevPerc__c = dataval.top_20_suppliers_revenue_percentage;
                                                   }
                                                   
                                                   if (dataval.suppliers_gt_5_percent_purchases!=null) {
                                                       finSum.Suppliergt5PercPurchase__c = dataval.suppliers_gt_5_percent_purchases;
                                                   }
                                                   
                                                   if (dataval.suppliers_gt_2_percent_purchases!=null) {
                                                       finSum.Suppliersgt2PercPurchase__c = dataval.suppliers_gt_2_percent_purchases;
                                                   }
                                                   
                                                   if (dataval.suppliers_gt_1_percent_purchases!=null) {
                                                       finSum.Suppliersgt1PercPurchase__c = dataval.suppliers_gt_1_percent_purchases;
                                                   }
                                                   
                                                   if (dataval.gst_paid_through_cash!=null) {
                                                       finSum.GSTPaidThroughCash__c = dataval.gst_paid_through_cash;
                                                   }
                                                   
                                                   if (dataval.average_gst_blocked_for_month!=null) {
                                                       finSum.AvgGSTBlkForMnth__c = dataval.average_gst_blocked_for_month;
                                                   }
                                                   
                                                   if (dataval.average_wc_blocked_gst!=null) {
                                                       finSum.AvgWCBlkGST__c = dataval.average_wc_blocked_gst;
                                                   }
                                                   
                                                   if (dataval.circular_transactions!=null) {
                                                       finSum.CircularTrans__c = dataval.circular_transactions;
                                                   }
                                                   
                                                   if (dataval.circular_transactions_revenue_percentage!=null) {
                                                       finSum.CircularTransRevPerc__c = dataval.circular_transactions_revenue_percentage;
                                                   }
                                                   
                                               }
                                               
                                               //Assign it to Global Value
                                               if(checkFinancialSummaryMap.containsKey(gstnumber)){
                                                   
                                                   checkFinancialSummaryMap.get(gstnumber).put(fy,finSum);
                                                   
                                               }else{
                                                   checkFinancialSummaryMap.put(gstnumber,new Map<String,Applicant_Financial_Summary__c>{fy=>finSum});
                                               }
                                               
                                           }
                                       
                                   }
                                   
                               }
                               
                           }
                        
                    }
                    
                }
                
            }
            
        } catch (Exception ex) {
            GlobalUtility.logMessage('Error', 'FinfortOrderDeliveryResponseProcessor Class',
                                     'gstSummaryAnalysis', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
    }
    //**************************************************************************************************************************
    public static List<Applicant_Financial_Summary__c> gstCustomerSupplierData(Map<String,Map<String,List<FinfortOrderDeliveryResponseWrapper.innerCommanTags>>> customerSupplierDataMap){
        
        List<Applicant_Financial_Summary__c> summaryList =new List<Applicant_Financial_Summary__c>();
        try {
            
            for(string orderid:customerSupplierDataMap.keySet()){
                
                Map<String,List<FinfortOrderDeliveryResponseWrapper.innerCommanTags>> customerSupplier=customerSupplierDataMap.get(orderid);
                
                if (!customerSupplier.isEmpty()) {
                    
                    for (string gstnumber :customerSupplier.keySet()) {
                        
                        //Checking For Applicant_Financial__c
                        if(applicantFinancialMap.containsKey(orderid) &&
                           applicantFinancialMap.get(orderid).containsKey(gstnumber)){
                               
                               Applicant_Financial__c applicantfin =applicantFinancialMap.get(orderid).get(gstnumber);
                               List<FinfortOrderDeliveryResponseWrapper.innerCommanTags>  customerSupplierData =customerSupplier.get(gstnumber);
                               
                               if (!customerSupplierData.isEmpty()) {
                                   
                                   for(FinfortOrderDeliveryResponseWrapper.innerCommanTags cust:customerSupplierData){
                                       
                                       //Top 20 Customer and Suppliers based on Fy
                                       if (String.isNotBlank(cust.fy) && String.isNotBlank(cust.cs_type) && String.isNotBlank(cust.period_type) &&
                                           cust.period_type.toLowerCase()=='yearly' && cust.data!=null & cust.data.rank_no!=null && cust.data.rank_no<=20 && 
                                           (cust.cs_type.toLowerCase()=='customer'||cust.cs_type.toLowerCase()=='supplier')) {
                                               
                                               
                                               Applicant_Financial_Summary__c finc =createApplicantFinSumForCustomerSupplier(cust.data,cust.cs_type.toLowerCase(),applicantfin.Id);
                                               finc.Financial_Year__c=cust.fy.left(5)+'20'+cust.fy.right(2);
                                               summaryList.add(finc);
                                           }
                                       
                                       //Top 20 Customer and Suppliers based on TTM
                                       if (String.isNotBlank(cust.period_type) && cust.period_type.toLowerCase()=='ttm' && String.isNotBlank(cust.cs_type)
                                           && cust.data!=null && cust.data.rank_no!=null && cust.data.rank_no<=20 &&
                                           (cust.cs_type.toLowerCase()=='customer'||cust.cs_type.toLowerCase()=='supplier')) {
                                               
                                               
                                               Applicant_Financial_Summary__c finc =createApplicantFinSumForCustomerSupplier(cust.data,cust.cs_type.toLowerCase(),applicantfin.Id);
                                               finc.Financial_Year__c='TTM';
                                               summaryList.add(finc);
                                           }
                                       
                                   }
                                   
                               }
                               
                           }
                        
                        
                    }
                    
                }
                
            }
            
        } catch (Exception ex) {
            GlobalUtility.logMessage('Error', 'FinfortOrderDeliveryResponseProcessor Class',
                                     'gstCustomerSupplierData', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        
        return summaryList;
    }
    
    //***********************************************************************************************************************
    public static Applicant_Financial_Summary__c createApplicantFinSumForCustomerSupplier(FinfortOrderDeliveryResponseWrapper.innerData dataval,string cstype,Id applicantFinancialId){
        
        Applicant_Financial_Summary__c finc =new Applicant_Financial_Summary__c();
        
        try {
            
            finc.Type__c=cstype=='customer'?'Top 20 Customers':'Top 20 Suppliers';
            finc.Applicant_Financial__c =applicantFinancialId;
            
            if (dataval.rank_no!=null) {
                finc.RankNo__c=dataval.rank_no;
            }
            
            if (String.isNotBlank(dataval.gstin)) {
                finc.GSTIN__c=dataval.gstin;
            }
            
            if (String.isNotBlank(dataval.trade_name)) {
                finc.TradeName__c=dataval.trade_name;
            }
            
            if (String.isNotBlank(dataval.cs_active_type)) {
                finc.CSActiveType__c=dataval.cs_active_type;
            }
            
            if (dataval.no_of_months_active!=null) {
                finc.NoofMonthsActive__c=dataval.no_of_months_active;
            }
            
            if (dataval.tax_val!=null) {
                finc.TaxVal__c=dataval.tax_val;
            }
            
            if (dataval.tax_val_percentage!=null) {
                finc.TaxValPerc__c=dataval.tax_val_percentage;
            }
            
            if (dataval.avg_invoice_value!=null) {
                finc.AvgInvoiceValue__c=dataval.avg_invoice_value;
            }
            
            if (dataval.avg_monthly_value!=null) {
                finc.AvgMonthlyVal__c=dataval.avg_monthly_value;
            }
            
            if (String.isNotBlank(dataval.category_flag)) {
                finc.CategoryFlag__c=dataval.category_flag;
            }
            
            if (String.isNotBlank(dataval.is_new)) {
                finc.IsNew__c=dataval.is_new;
            }
            
            if (String.isNotBlank(dataval.legal_name)) {
                finc.LegalName__c=dataval.legal_name;
            }
            
            if (String.isNotBlank(dataval.ctb)) {
                finc.Ctb__c=dataval.ctb;
            }
            
            if (String.isNotBlank(dataval.nba)) {
                finc.NBA__c=dataval.nba;
            }
            
            if (String.isNotBlank(dataval.address)) {
                finc.Address__c=dataval.address;
            }
            
            if (String.isNotBlank(dataval.pr_adr_loc)) {
                finc.PrAdrLoc__c=dataval.pr_adr_loc;
            }
            
            if (String.isNotBlank(dataval.pr_adr_stcd)) {
                finc.PrAdrStcd__c=dataval.pr_adr_stcd;
            }
            
            if (String.isNotBlank(dataval.taxpayer_type)) {
                finc.TaxPayerType__c=dataval.taxpayer_type;
            }
            
            if (String.isNotBlank(dataval.gst_status)) {
                finc.GSTStatus__c=dataval.gst_status;
            }
            
            if (String.isNotBlank(dataval.registration_date)) {
                finc.RegistrationDate__c=IntegrationUtility.getConvertedDate2(dataval.registration_date);
            }
            
            if (String.isNotBlank(dataval.cancellation_date)) {
                finc.CancellationDate__c=IntegrationUtility.getConvertedDate2(dataval.cancellation_date);
            }
            
            if (String.isNotBlank(dataval.filing_regularity)) {
                finc.FilingRegularity__c=dataval.filing_regularity;
            }
            
            if (dataval.sub_total!=null && cstype.toLowerCase()=='customer') {
                finc.SubTotal__c=dataval.sub_total;
            }
            
            if (dataval.others!=null && cstype.toLowerCase()=='customer') {
                finc.Others__c=dataval.others;
            }
            
            if (dataval.total_adjusted_revenue!=null && cstype.toLowerCase()=='customer') {
                finc.AdjustRevTot__c=dataval.total_adjusted_revenue;
            }
            
        } catch (Exception ex) {
            GlobalUtility.logMessage('Error', 'FinfortOrderDeliveryResponseProcessor Class',
                                     'createApplicantFinancialSummary', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        return finc;
    }
    
    //***********************************************************************************************************************
    public static List<Applicant_Financial_Summary__c> gstHsnChapterData(Map<String,Map<String,List<FinfortOrderDeliveryResponseWrapper.innerCommanTags>>> hsnChapterDataMap){
        
        List<Applicant_Financial_Summary__c> summaryList =new List<Applicant_Financial_Summary__c>();
        
        try {
            
            for(string orderid:hsnChapterDataMap.keySet()){
                
                Map<String,List<FinfortOrderDeliveryResponseWrapper.innerCommanTags>> hsnChapterData=hsnChapterDataMap.get(orderid);
                
                if (!hsnChapterData.isEmpty()) {
                    
                    for (string gstnumber :hsnChapterData.keySet()) {
                        
                        //Checking For Applicant_Financial__c
                        
                        if(applicantFinancialMap.containsKey(orderid) &&
                           applicantFinancialMap.get(orderid).containsKey(gstnumber)){
                               
                               Applicant_Financial__c applicantfin =applicantFinancialMap.get(orderid).get(gstnumber);
                               List<FinfortOrderDeliveryResponseWrapper.innerCommanTags>  hsnChapter =hsnChapterData.get(gstnumber);
                               
                               if (!hsnChapter.isEmpty()) {
                                   
                                   for(FinfortOrderDeliveryResponseWrapper.innerCommanTags hsn:hsnChapter){
                                       
                                       //Top 10 record yearly wise based on Rank
                                       if(String.isNotBlank(hsn.fy) && String.isNotBlank(hsn.period_type) &&
                                          hsn.period_type.toLowerCase()=='yearly' && hsn.data!=null &&
                                          string.isNotblank(hsn.data.hsn_chapter) && hsn.data.hsn_chapter.toLowerCase()=='hsn' && 
                                          hsn.data.ranking_of_revenue_from_sale_of_products!=null &&
                                          hsn.data.ranking_of_revenue_from_sale_of_products<=10){
                                              
                                              Applicant_Financial_Summary__c finc=createApplicantFinSumForHsnChapter(hsn.data,applicantfin.id);
                                              finc.Financial_Year__c=hsn.fy.left(5)+'20'+hsn.fy.right(2);
                                              summaryList.add(finc);
                                          }
                                       
                                       //Top 10 record of TTM wise based on Rank
                                       if (String.isNotBlank(hsn.period_type) &&
                                           hsn.period_type.toLowerCase()=='ttm' && hsn.data!=null &&
                                           string.isNotblank(hsn.data.hsn_chapter) && hsn.data.hsn_chapter.toLowerCase()=='hsn' &&
                                           hsn.data.ranking_of_revenue_from_sale_of_products!=null &&
                                           hsn.data.ranking_of_revenue_from_sale_of_products<=10) {
                                               
                                               Applicant_Financial_Summary__c finc=createApplicantFinSumForHsnChapter(hsn.data,applicantfin.id);
                                               finc.Financial_Year__c='TTM';
                                               summaryList.add(finc);
                                           }
                                       
                                   }
                                   
                               }
                           }
                        
                    }
                    
                }
            }
            
            
        } catch (Exception ex) {
            
            GlobalUtility.logMessage('Error', 'FinfortOrderDeliveryResponseProcessor Class',
                                     'gstHsnChapterData', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        
        return summaryList;
    }
    
    //***********************************************************************************************************************
    public static Applicant_Financial_Summary__c createApplicantFinSumForHsnChapter(FinfortOrderDeliveryResponseWrapper.innerData dataval,Id applicantFinancialId){
        
        Applicant_Financial_Summary__c finc =new Applicant_Financial_Summary__c();
        
        try {
            
            finc.Type__c='Top 10 Products';
            finc.Applicant_Financial__c =applicantFinancialId;
            
            if (dataval.ranking_of_revenue_from_sale_of_products!=null) {
                finc.RankingRevSaleProd__c =dataval.ranking_of_revenue_from_sale_of_products;
            }
            
            if (dataval.hsn_of_goods!=null) {
                finc.HsnGoods__c =dataval.hsn_of_goods;
            }
            
            if (dataval.revenue_from_sale_product!=null) {
                finc.RevFromSaleProd__c =dataval.revenue_from_sale_product;
            }
            
            if (dataval.product_revenue_percentage!=null) {
                finc.ProdRevPerc__c =dataval.product_revenue_percentage;
            }
            
            if (String.isNotBlank(dataval.system_description)) {
                finc.SystemDesc__c =dataval.system_description;
            }
            
            if (String.isNotBlank(dataval.peak_months)) {
                finc.PeakMonths__c =dataval.peak_months;
            }
            
            if (dataval.monthly_avg_product_revenue!=null) {
                finc.MonthlyAvgProdRev__c =dataval.monthly_avg_product_revenue;
            }
            
        } catch (Exception ex) {
            GlobalUtility.logMessage('Error', 'FinfortOrderDeliveryResponseProcessor Class',
                                     'createApplicantFinSumForHsnChapter', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        return finc;
    }
    
    //***********************************************************************************************************************
    public static List<Applicant_Financial_Summary__c> gstProfileExcelData(Map<String,Map<String,List<FinfortOrderDeliveryResponseWrapper.profileexceldata>>> profileExcelDataMap){
        
        List<Applicant_Financial_Summary__c> summaryList =new List<Applicant_Financial_Summary__c>();
        
        try {
            
            for(string orderid:profileExcelDataMap.keySet()){
                
                Map<String,List<FinfortOrderDeliveryResponseWrapper.profileexceldata>> profilexcel =profileExcelDataMap.get(orderid);
                
                if (!profilexcel.isEmpty()) {
                    
                    for(string gstnumber:profilexcel.keySet()){
                        
                        //Checking For Applicant_Financial__c
                        
                        if(applicantFinancialMap.containsKey(orderid) &&
                           applicantFinancialMap.get(orderid).containsKey(gstnumber)){
                               
                               Applicant_Financial__c applicantfin =applicantFinancialMap.get(orderid).get(gstnumber);
                               List<FinfortOrderDeliveryResponseWrapper.profileexceldata>  excelData =profilexcel.get(gstnumber);
                               
                               if (!excelData.isEmpty()) {
                                   
                                   for (FinfortOrderDeliveryResponseWrapper.profileexceldata exl : excelData) {
                                       
                                       Applicant_Financial_Summary__c finc =new Applicant_Financial_Summary__c();
                                       finc.Type__c='Profile';
                                       finc.Applicant_Financial__c =applicantfin.Id;
                                       
                                       if (String.isNotBlank(exl.legal_name)) {
                                           finc.LegalName__c =exl.legal_name;
                                       }
                                       
                                       if (String.isNotBlank(exl.trade_name)) {
                                           finc.TradeName__c =exl.trade_name;
                                       }
                                       
                                       if (String.isNotBlank(exl.pan)) {
                                           finc.Pan__c =exl.pan;
                                       }
                                       
                                       if (String.isNotBlank(exl.gstin)) {
                                           finc.GSTIN__c =exl.gstin;
                                       }
                                       
                                       if (String.isNotBlank(exl.registration_date)) {
                                           finc.RegistrationDate__c =IntegrationUtility.getConvertedDate2(exl.registration_date);
                                       }
                                       
                                       if (String.isNotBlank(exl.cancellation_date)) {
                                           finc.CancellationDate__c =IntegrationUtility.getConvertedDate2(exl.cancellation_date);
                                       }
                                       
                                       if (String.isNotBlank(exl.ctb)) {
                                           finc.Ctb__c =exl.ctb;
                                       }
                                       
                                       if (String.isNotBlank(exl.taxpayer_type)) {
                                           finc.TaxPayerType__c =exl.taxpayer_type;
                                       }
                                       
                                       if (String.isNotBlank(exl.gst_status)) {
                                           finc.GSTStatus__c =exl.gst_status;
                                       }
                                       
                                       if (String.isNotBlank(exl.nature_of_core_business)) {
                                           finc.NatureofCoreBusiness__c =exl.nature_of_core_business;
                                       }
                                       
                                       if (String.isNotBlank(exl.nba)) {
                                           finc.NBA__c =exl.nba;
                                       }
                                       
                                       if (String.isNotBlank(exl.adadr)) {
                                           finc.Adadr__c =exl.adadr;
                                       }
                                       
                                       if (String.isNotBlank(exl.pr_adr_loc)) {
                                           finc.PrAdrLoc__c =exl.pr_adr_loc;
                                       }
                                       
                                       if (String.isNotBlank(exl.pr_adr_stcd)) {
                                           finc.PrAdrStcd__c =exl.pr_adr_stcd;
                                       }
                                       
                                       if (String.isNotBlank(exl.state_juisdiction)) {
                                           finc.StateJuisdiction__c =exl.state_juisdiction;
                                       }
                                       
                                       if (String.isNotBlank(exl.state_juisdiction_code)) {
                                           finc.StateJuisdictionCode__c =exl.state_juisdiction_code;
                                       }
                                       
                                       if (String.isNotBlank(exl.central_juisdiction)) {
                                           finc.CentralJuisdiction__c =exl.central_juisdiction;
                                       }
                                       
                                       if (String.isNotBlank(exl.central_juisdiction_code)) {
                                           finc.CentralJuisdictionCode__c =exl.central_juisdiction_code;
                                       }
                                       
                                       if (exl.pr_adr_lt!=null) {
                                           finc.PrAdrLt__c =exl.pr_adr_lt;
                                       }
                                       
                                       if (exl.pr_adr_lg!=null) {
                                           finc.PrAdrLg__c =exl.pr_adr_lg;
                                       }
                                       
                                       if (String.isNotBlank(exl.last_updated_date)) {
                                           finc.LastUpdatedDate__c =IntegrationUtility.getConvertedDate2(exl.last_updated_date);
                                       }
                                       
                                       summaryList.add(finc);
                                       
                                   }
                                   
                               }
                               
                           }
                        
                    }
                    
                }
            }
            
            
        } catch (Exception ex) {
            GlobalUtility.logMessage('Error', 'FinfortOrderDeliveryResponseProcessor Class',
                                     'gstProfileExcelData', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        
        return summaryList;
    }
    //***********************************************************************************************************************
    public static List<Applicant_Financial_Summary__c> gstFilingData(Map<String,Map<String,List<FinfortOrderDeliveryResponseWrapper.filingdata>>> filingDataMap){
        
        List<Applicant_Financial_Summary__c> summaryList =new List<Applicant_Financial_Summary__c>();
        
        try {
            
            for(string orderid:filingDataMap.keySet()){
                
                Map<String,List<FinfortOrderDeliveryResponseWrapper.filingdata>> filingData =filingDataMap.get(orderid);
                
                if (!filingData.isEmpty()) {
                    
                    for(string gstnumber:filingData.keySet()){
                        
                        //Checking For Applicant_Financial__c
                        
                        if(applicantFinancialMap.containsKey(orderid) &&
                           applicantFinancialMap.get(orderid).containsKey(gstnumber)){
                               
                               Applicant_Financial__c applicantfin =applicantFinancialMap.get(orderid).get(gstnumber);
                               List<FinfortOrderDeliveryResponseWrapper.filingdata>  filedata =filingData.get(gstnumber);
                               
                               if (!filedata.isEmpty()) {
                                   
                                   for (FinfortOrderDeliveryResponseWrapper.filingdata fle : filedata) {
                                       
                                       if (String.isNotBlank(fle.returnType) && (fle.returnType.toLowerCase()=='gstr3b' || fle.returnType.toLowerCase()=='gstr1')) {
                                           
                                           Applicant_Financial_Summary__c finc =new Applicant_Financial_Summary__c();
                                           finc.Type__c=(fle.returnType.toLowerCase()=='gstr3b')?'Filing Details - GSTR 3B':'Filing Details - GSTR 1';
                                           finc.Applicant_Financial__c =applicantfin.Id;
                                           
                                           if (String.isNotBlank(fle.financialYear)) {//pl.FY.left(5)+'20'+pl.FY.right(2);
                                               finc.Financial_Year__c =fle.financialYear.left(5)+'20'+fle.financialYear.right(2);
                                           }
                                           
                                           if (String.isNotBlank(fle.taxPeriod)) {
                                               finc.TaxPeriod__c =fle.taxPeriod;
                                           }
                                           
                                           if (String.isNotBlank(fle.dueDate)) {
                                               finc.DueDt__c =IntegrationUtility.getConvertedDate3(fle.dueDate);
                                           }
                                           
                                           if (String.isNotBlank(fle.filingDate)) {
                                               finc.FilingDate__c =IntegrationUtility.getConvertedDate3(fle.filingDate);
                                           }
                                           
                                           if (fle.delayedDays!=null) {
                                               finc.DelayedDays__c =fle.delayedDays;
                                           }
                                           
                                           summaryList.add(finc);
                                       }
                                       
                                       
                                       
                                   }
                                   
                               }
                               
                           }
                        
                    }
                    
                }
            }
            
            
        } catch (Exception ex) {
            GlobalUtility.logMessage('Error', 'FinfortOrderDeliveryResponseProcessor Class',
                                     'gstFilingData', null, null, ex.getMessage() + ' line ' + ex.getLineNumber(), null, ex, null);
        }
        
        return summaryList;
    }
 //*****************************************************************************************************************************************
    public static string convertFiscalYearToPicklist(string fy){
        
        string pickValue;
        
        Integer startYear = Integer.valueOf(fy.split('-')[1])-1;
        Integer endYear = Integer.valueOf(fy.split('-')[1]);
        
        pickValue='20'+startYear + '-' +'20'+ endYear;
        
        return pickValue;
    }   
}