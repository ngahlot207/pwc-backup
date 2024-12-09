public class FinnOneCallBackResponseProcessor {
    
    public Static void process(List<IntgMsg__c> responses){
        
        try {
            
            //fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { IntgMsg__c.SObjectType });           
            //List<IntgMsg__c> updateIntRecords = new List<IntgMsg__c>();
            Map<String,String> intgMsgRefIdsMap = new Map<String,String>();
            Map<String,JsonBody> responseMap= new Map<String,JsonBody>();
            
            for(IntgMsg__c integrationMessage:responses){
                
                JsonBody res=(JsonBody) JSON.deserialize(integrationMessage.Req__c, JsonBody.class); 
                responseMap.put(res.lmsApplicationID,res);
                intgMsgRefIdsMap.put(integrationMessage.Id,res.lmsApplicationID);
                
                /*IntgMsg__c intg=New IntgMsg__c();
                intg.id=integrationMessage.Id;
                intg.Status__c = 'Processed';
                updateIntRecords.add(intg);*/
            }
            if(!responseMap.isempty()){
                FinnoneCallback(intgMsgRefIdsMap,responseMap);
            }
            
            /*if(!updateIntRecords.isEmpty()) {
                List<String> fieldNamesList = new List<String>{'Status__c'};
                    String sObjectName = 'IntgMsg__c';
                Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                uow.registerDirty(updateIntRecords);
            }
            uow.commitWork();*/
            
        } catch (Exception ex) {
            system.debug('error message and line number '+ ex.getMessage() + 'line' + ex.getLineNumber());
        }
        
        
    }
    //*****************************************************************************************************************************************
    public static void FinnoneCallback(Map<String,String> intgMsgRefIdsMap, Map<String,JsonBody> resmap){
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { LoanAppl__c.SObjectType,Disbursement__c.SObjectType,Split_Disbur__c.SObjectType,IntgMsg__c.SObjectType});
        
        Set<String> decimalKeys = new Set<String>();
        
        // Extract Decimal keys for comparison
        for (String key : resmap.keySet()) {
            //Decimal decKey = Decimal.valueOf(key);
            decimalKeys.add(key);
        }
        
        try {
            
            if(!resmap.isempty()){
                Set<Id> loanids=new Set<Id>();
                Set<Id> disbursementIds = new Set<Id>();
                List<LoanAppl__c> updateLoanAppl =new List<LoanAppl__c>();
                
                List<Disbursement__c> updateDisbursement =new List<Disbursement__c>();
                
                List<Split_Disbur__c> updateSplitDisbur =new List<Split_Disbur__c>();
                List<IntgMsg__c> updateIntgMsgRecords = new List<IntgMsg__c>(); 
                Map<String,LoanAppl__c> loanApplMap = new Map<String,LoanAppl__c>();
                ID CPAPoolQueueID = [Select Id,DeveloperName, Type FROM Group  Where Type='Queue' AND DeveloperName='CPA_Pool'].Id;
                ID systemQueueId = [Select Id,DeveloperName, Type FROM Group  Where Type='Queue' AND DeveloperName='System_Queue'].Id;
                
                for(LoanAppl__c loanapp:[SELECT Id, FinnoneAppid__c,Status__c,DisbursalType__c,NDCType__c,CPA_User__c,(SELECT Id, Loan_Appli__c, Disbur_Status__c,Disbur_Desrp__c FROM Disbursements__r 
                                                           LIMIT 1) ,(Select Id,DocStatus__c FROM Applicant_Document_Details__r WHERE DocStatus__c IN ('OTC', 'PDD')) FROM LoanAppl__c WHERE FinnoneAppid__c IN :decimalKeys]){
                    loanApplMap.put(loanapp.FinnoneAppid__c,loanapp);
                    if(resmap.containskey(String.valueof(loanapp.FinnoneAppid__c))){
                        
                        LoanAppl__c loan =new LoanAppl__c();
                        
                        loan.Id=loanapp.Id;
                        loanids.add(loanapp.Id);
                        
                        if(!string.isBlank(resmap.get(String.valueof(loanapp.FinnoneAppid__c)).lmsLanNo)){
                            loan.Finnone_Loan_Number__c=resmap.get(String.valueof(loanapp.FinnoneAppid__c)).lmsLanNo;
                            
                            if(loanapp.Status__c=='Finnone Pending'){
                                if(loanapp.DisbursalType__c=='MULTIPLE'){
                                    loan.Status__c = 'Partially Disbursed';
                                    loan.Stage__c = 'Disbursed';
                                    //LAK-6245
                                    if(loanapp.NDCType__c=='Scan Based Disbursement'){
                                        loan.SubStage__c = 'Additional Processing';
                                    	loan.OwnerId = loanapp.CPA_User__c;
                                    }else{
                                        loan.SubStage__c = 'Additional Processing Pool';
                                    	loan.OwnerId = CPAPoolQueueID;
                                    }
                                    
                                }
                                else{
                                    /*List<DocDtl__c> docDtlList = loanapp.Applicant_Document_Details__r;
                                    loanapp.Stage__c ='Disbursed';
                                    if(docDtlList!=null && !docDtlList.isEmpty()){
                                        loanapp.Status__c = 'Partially Disbursed';
                                        loanapp.SubStage__c = 'Additional Processing Pool';
                                        loanapp.OwnerId = CPAPoolQueueID;
                                    }else{
                                        loanapp.Status__c = 'Fully Disbursed';
                                        loanapp.SubStage__c = 'Completed';   
                                    }*/
                                    loan.Stage__c ='Disbursed';
                                    loan.Status__c = 'Fully Disbursed';
                                    //LAK-6245
                                    if(loanapp.NDCType__c=='Scan Based Disbursement'){
                                        loan.SubStage__c = 'Additional Processing';
                                    	loan.OwnerId = loanapp.CPA_User__c;
                                    }
                                    else{
                                        loan.SubStage__c = 'Completed'; 
                                        loan.OwnerId = systemQueueId;
                                    }
                                }
                            }
                        } 
                        
                        if(!string.isBlank(resmap.get(String.valueof(loanapp.FinnoneAppid__c)).lanDisbursementDate)){
                            loan.DisbursementDate__c=convertToDate(resmap.get(String.valueof(loanapp.FinnoneAppid__c)).lanDisbursementDate);
                        } 
                        
                        
                        RoiPfCorrectionController.calculateRoiSum(Date.today());
                        updateLoanAppl.add(loan);
                        
                        if(loanapp.DisbursalType__c=='SINGLE' && !loanapp.Disbursements__r.isEmpty()){
                            for(Disbursement__c disbursement : loanapp.Disbursements__r){
                                disbursementIds.add(disbursement.Id);
                                Disbursement__c dis = new Disbursement__c();
                                dis.id= disbursement.Id;
                                dis.Disbur_Status__c='Disbursed';
                                dis.Finnone_Tranche_Disbursed_Amount__c = dis.Total_Disb_Amt__c;
                                if(!string.isBlank(resmap.get(String.valueof(loanapp.FinnoneAppid__c)).lanDisbursementDate)){
                                    dis.Date_of_Disbur__c=convertToDate(resmap.get(String.valueof(loanapp.FinnoneAppid__c)).lanDisbursementDate);
                                } 
                                updateDisbursement.add(dis);
                            }
                            
                            
                        }
                        
                        /*for(Disbursement__c Disbursement:[SELECT Id, Loan_Appli__c, Disbur_Status__c,Disbur_Desrp__c FROM Disbursement__c 
                                                          WHERE Loan_Appli__c =:loan.Id AND Disbur_Status__c = '' ORDER BY Disbur_Desrp__c ASC LIMIT 1]){
                                                              
                                                              Disbursement__c dis = new Disbursement__c();
                                                              
                                                              dis.id=Disbursement.id!=null?Disbursement.id:'';
                                                              dis.Disbur_Status__c='Disbursed';
                                                              
                                                              
                                                              if(!string.isBlank(resmap.get(String.valueof(loanapp.FinnoneAppid__c)).lanDisbursementDate)){
                                                                  dis.Date_of_Disbur__c=convertToDate(resmap.get(String.valueof(loanapp.FinnoneAppid__c)).lanDisbursementDate);
                                                              } 
                                                              
                                                              updateDisbursement.add(dis);
                                                              
                                                              
                                                              for(Split_Disbur__c spiltdis:[select id,DisburseRela__c from Split_Disbur__c where DisburseRela__c =:dis.id]){
                                                                  
                                                                  
                                                                  Split_Disbur__c sd = new Split_Disbur__c();
                                                                  
                                                                  sd.id=spiltdis.id!=null?spiltdis.id:'';
                                                                  
                                                                  if(!string.isBlank(resmap.get(String.valueof(loanapp.FinnoneAppid__c)).lmsDisburseAmt)){
                                                                      sd.DisburseAmt__c=decimal.valueof(resmap.get(String.valueof(loanapp.FinnoneAppid__c)).lmsDisburseAmt);
                                                                  } 
                                                                  
                                                                  updateSplitDisbur.add(sd);
                                                                  
                                                              }
                                                              
                                                          }  */
                    }
                }
                
               /* for(Split_Disbur__c spiltdis:[select id,DisburseRela__c,DisburseRela__r.Loan_Appli__r.FinnoneAppid__c from Split_Disbur__c where DisburseRela__c IN:disbursementIds]){
                    
                    system.debug('1');
                    Split_Disbur__c sd = new Split_Disbur__c();
                    
                    sd.id=spiltdis.id!=null?spiltdis.id:'';
                    
                    if(!string.isBlank(resmap.get(String.valueof(spiltdis.DisburseRela__r.Loan_Appli__r.FinnoneAppid__c)).lmsDisburseAmt)){
                        system.debug('2');
                        sd.DisburseAmt__c=decimal.valueof(resmap.get(String.valueof(spiltdis.DisburseRela__r.Loan_Appli__r.FinnoneAppid__c)).lmsDisburseAmt);
                    } 
                    
                    updateSplitDisbur.add(sd);
                    
                }*/
                
                if (!updateLoanAppl.isEmpty()) {
                    List<string> fieldNamesList = new List<string>{'Finnone_Loan_Number__c','DisbursementDate__c','Status__c','Stage__c','SubStage__c'};
                        String sObjectName = 'LoanAppl__c';
                    Schema.SObjectType objType = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType, fieldNamesList);
                    uow.registerDirty(updateLoanAppl);
                    
                }
                
                if (!updateDisbursement.isEmpty()) {
                    List<string> fieldNamesList = new List<string>{'Disbur_Status__c','Date_of_Disbur__c','Finnone_Tranche_Disbursed_Amount__c'};
                        String sObjectName = 'Disbursement__c';
                    Schema.SObjectType objType = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType, fieldNamesList);
                    uow.registerDirty(updateDisbursement);
                    
                }
                
                /*if (!updateSplitDisbur.isEmpty()) {
                    List<string> fieldNamesList = new List<string>{'DisburseAmt__c'};
                        String sObjectName = 'Split_Disbur__c';
                    Schema.SObjectType objType = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType, fieldNamesList);
                    uow.registerDirty(updateSplitDisbur);
                    
                }*/
                
                if(!intgMsgRefIdsMap.isEmpty()){
                    for(String intgMsgId : intgMsgRefIdsMap.keySet()){
                        IntgMsg__c intg = new IntgMsg__c();
                        intg.id =  intgMsgId;
                        intg.Status__c = 'Processed';
                        if(loanApplMap.containskey(intgMsgRefIdsMap.get(intgMsgId))){
                            if(loanApplMap.get(intgMsgRefIdsMap.get(intgMsgId)).Id!=null){
                                intg.LoanAppln__c = loanApplMap.get(intgMsgRefIdsMap.get(intgMsgId)).Id;
                            }
                        }
                        updateIntgMsgRecords.add(intg);
                    }
                }
                if(updateIntgMsgRecords!=null && !updateIntgMsgRecords.isEmpty()){
                    String sObjectName = 'IntgMsg__c';
                    List<String> fieldNamesList = new List<String>{'Status__c','LoanAppln__c'};
                        Schema.SObjectType objType  = Schema.getGlobalDescribe().get(sObjectName);
                    fflib_SecurityUtils.checkUpdate(objType,fieldNamesList);
                    uow.registerDirty(updateIntgMsgRecords);
                }
                uow.commitWork();
                
                if(!loanids.isempty()){
                     createCKYCIntegeration(loanids);
                }
                
            }
        } 
        catch (Exception ex) {
            System.debug('error message and line number ' + ex.getMessage() + ' line ' + ex.getLineNumber());
        }
        
    }
    
    //********************************************************************************************************************************* 
    public static Date convertToDate(String dateString) {
        Map<String, String> monthMap = new Map<String, String>{
            'JAN' => '01', 'FEB' => '02', 'MAR' => '03',
                'APR' => '04', 'MAY' => '05', 'JUN' => '06',
                'JUL' => '07', 'AUG' => '08', 'SEP' => '09',
                'OCT' => '10', 'NOV' => '11', 'DEC' => '12'
                };
                    
                    List<String> dateParts = dateString.split('-');
        
        if (dateParts.size() == 3) {
            String year = dateParts[2];
            String month = monthMap.get(dateParts[1].toUpperCase());
            String day = dateParts[0];
            
            String salesforceDateFormat = year + '-' + month + '-' + day;
            
            return Date.valueOf(salesforceDateFormat);
        }
        
        return null; 
    }
    //*********************************************JSON BODY Wrapper*********************************************************************** 
    public class JsonBody{
        public string lmsRequestId;
        public string lmsApplicationID;
        public string lmsErrorCode;
        public string lmsErrorMsg;
        public string lmsLanNo;
        public string lanDisbursementDate;
        public string lmsDisburseAmt;
    } 
    
    
    //@future
    public static void createCKYCIntegeration(Set<Id> loanAppIds) {
        
       CreateCKYCIntegrationMessageQueueable intmsg =new CreateCKYCIntegrationMessageQueueable(loanAppIds);
        System.enqueueJob(intmsg);
       /* List<Applicant__c> applicantList = [SELECT Id, Name FROM Applicant__c WHERE LoanAppln__c IN :loanAppIds];
        List<IntgMsg__c> createRequestList = new List<IntgMsg__c>(); 
        if(!applicantList.isempty()){
            
            for (Applicant__c app : applicantList) {
                
                //Creating Intg Msg for CKYC API  
                IntgMsg__c intMsgCkyc =new IntgMsg__c();
                intMsgCkyc.Name='CKYC API';
                intMsgCkyc.BU__c='HL / STL';
                intMsgCkyc.RefId__c=app.Id;
                intMsgCkyc.Status__c='New';
                intMsgCkyc.MStatus__c='Blank';
                intMsgCkyc.RefObj__c='Applicant__c';
                intMsgCkyc.Svc__c='CKYC API';
                intMsgCkyc.IsActive__c=true;
                
                createRequestList.add(intMsgCkyc);
                
                
                //Creating Intg Msg for CKYC ATTACHMENT  
                IntgMsg__c intMsgCkycAtt =new IntgMsg__c();
                intMsgCkycAtt.Name='CKYC ATTACHMENT';
                intMsgCkycAtt.BU__c='HL / STL';
                intMsgCkycAtt.RefId__c=app.Id;
                intMsgCkycAtt.Status__c='New';
                intMsgCkycAtt.MStatus__c='Blank';
                intMsgCkycAtt.RefObj__c='Applicant__c';
                intMsgCkycAtt.Svc__c='CKYC ATTACHMENT';
                intMsgCkycAtt.IsActive__c=true;
                
                createRequestList.add(intMsgCkycAtt);
                
             
            }
            
            
           
            
            if(createRequestList!=null && !createRequestList.isEmpty()){
                fflib_SObjectUnitOfWork uowInt = new fflib_SObjectUnitOfWork( new List<SObjectType> { IntgMsg__c.SObjectType});
                List<string> fieldNamesListInt = New List<string>{'Name','BU__c','RefId__c','Status__c','MStatus__c','RefObj__c','Svc__c','ApiVendor__c',
                    'IsActive__c','ParentRefId__c','ParentRefObj__c'};
                        String sObjectNameInt = 'IntgMsg__c';
                Schema.SObjectType objTypeInt  = Schema.getGlobalDescribe().get(sObjectNameInt);
                fflib_SecurityUtils.checkInsert(objTypeInt,fieldNamesListInt); 
                uowInt.registerNew(createRequestList);
                uowInt.commitWork();
            }
        }*/
    }
    
}