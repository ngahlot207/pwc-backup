public class IntegrationMessage_Populatedate implements TriggerAction.Beforeupdate {
    
    public void Beforeupdate(List<IntgMsg__c> newList,List<IntgMsg__c> oldList) {
        //Map to store Trigger.OldMap
        try{
            Map<Id,IntgMsg__c> OldRecordsMap=New Map<Id,IntgMsg__c>(oldList);
            List<IntgMsg__c> intgMsgList = new List<IntgMsg__c>();
            set<id> Docdtid=new set<id>();
            set<id> Appkycid=new set<id>();
            set<id> Applicantid=new set<id>();
            set<id> repayAccVerifyIds=new set<id>();
            set<id> applIMDIds=new set<id>();
            set<id> nachIds=new set<id>();
            set<id> paymentIds=new set<id>();
            set<id> taskIds=new set<id>();
            set<id> splitDisbursementIds = new set<id>();
            set<Id> APIVerIds = new set<Id>();
            set<Id> ApplBankingIds = new set<Id>();
            set<Id> ApplGSTIds = new set<Id>();
            set<Id> ApplEmpIds = new set<Id>();
            set<Id> userIds = new set<Id>();
            Map<string, id> applicantkycmap=new map<string, id>();
            Map<string, id> docdetailcmap=new map<string, id>();
            Map<string, id> applicantmap=new map<string, id>();
            Map<string, id> docapplicantmap=new map<string, id>();
            Map<string, id> applicantlycmapforapplicant=new map<string, id>();
            Map<string,RepayAccVerify__c> repayAccVerifyMap = new Map<string,RepayAccVerify__c>();
            Map<string,ApplIMD__c> applIMDMap = new Map<string,ApplIMD__c>();
            Map<string,NACH__c> nachMap = new Map<string,NACH__c>();
            Map<string,Payment__c> paymentMap= new Map<string,Payment__c>();		
            Map<string,Id> refLoanApplIdsMap = new Map<string,Id>();
            Map<string,Id> refApplIdsMap = new Map<string,Id>();
            Map<Id,Id> taskRefIdMap = new Map<Id,Id>();
            Map<string,Split_Disbur__c> splitDisbursementMap = new Map<string,Split_Disbur__c>();
            Map<string,APIVer__c> apiVerMap = new Map<string,APIVer__c>();
            Map<string,ApplBanking__c> applBankMap = new Map<string,ApplBanking__c>();
            Map<string,ApplGST__c> applGSTMap = new Map<string,ApplGST__c>();
            Map<string,ApplicantEmployment__c> applEmpMap = new Map<string,ApplicantEmployment__c>();
            
            List<IntgMsg__c> createAPITrackerList = new List<IntgMsg__c>();
            Map<Id,User> userMap = new Map<Id,User>();
            Map<Id,TeamHierarchy__c> userteamHierarchyMap =new Map<Id,TeamHierarchy__c>();
            
            
            for (IntgMsg__c intg : newList) {
                if(String.isBlank(intg.UserName__c) || String.isBlank(intg.UserNameRole__c)){
                    userIds.add(intg.CreatedById);
                }
                
                if ( intg.Status__c == GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS 
                    && intg.Status__c != OldRecordsMap.get(intg.id).Status__c 
                    &&  OldRecordsMap.get(intg.id).Status__c == GlobalConstants.INT_MSG_STATUS_NEW)
                {
                    intg.ReqGenTime__c=system.now();
                    
                }
                
                if ( intg.Status__c == GlobalConstants.INT_MSG_Status_Responded
                    && intg.Status__c != OldRecordsMap.get(intg.id).Status__c 
                    && intg.RespGenTime__c==null )//OldRecordsMap.get(intg.id).Status__c == GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS 
                {
                    intg.RespGenTime__c=system.now();
                    
                }
                
                if ( intg.RefObj__c == 'LoanAppl__c' && intg.RefId__c != '' ){
                    intg.LoanAppln__c=intg.RefId__c;
                }
                if ( intg.RefObj__c == 'DocDtl__c' && intg.RefId__c != '' ){
                    Docdtid.add(intg.RefId__c);
                }
                if ( intg.RefObj__c == 'ApplKyc__c' && intg.RefId__c != '' ){
                    Appkycid.add(intg.RefId__c);
                }
                if ( intg.RefObj__c == 'Applicant__c' && intg.RefId__c != '' ){	
                    if(!intg.RefId__c.contains(',')){	
                        Applicantid.add(intg.RefId__c);
                        intg.Appl__c=intg.RefId__c;
                    }
                    
                    if(intg.ParentRefObj__c == 'LoanAppl__c' && intg.ParentRefId__c !=''){
                        if(intg.RefId__c!=''){
                            refLoanApplIdsMap.put(intg.RefId__c,intg.ParentRefId__c);
                        }
                        else{
                            intg.LoanAppln__c=intg.ParentRefId__c;
                        }
                        
                    }
                }
                if(intg.RefObj__c == 'RepayAccVerify__c' && intg.RefId__c != ''){
                    repayAccVerifyIds.add(intg.RefId__c);   
                }
                if(intg.RefObj__c == 'ApplIMD__c' && intg.RefId__c != ''){
                    applIMDIds.add(intg.RefId__c);
                }
                if(intg.RefObj__c == 'NACH__c' && intg.RefId__c != ''){
                    nachIds.add(intg.RefId__c);
                }
                if(intg.RefObj__c == 'Payment__c' && intg.RefId__c != ''){
                    paymentIds.add(intg.RefId__c);
                }
                if(intg.RefObj__c == 'Task' && intg.RefId__c != ''){
                    taskIds.add(intg.RefId__c);
                }
                if(intg.ParentRefObj__c == 'LoanAppl__c' && intg.ParentRefId__c !=''){
                    intg.LoanAppln__c=intg.ParentRefId__c;   
                }
                if(intg.RefObj__c == 'Split_Disbur__c' && intg.RefId__c != ''){
                    splitDisbursementIds.add(intg.RefId__c);
                }
                if(intg.RefObj__c == 'APIVer__c' && intg.RefId__c != ''){
                    APIVerIds.add(intg.RefId__c);
                }
                if(intg.RefObj__c == 'ApplBanking__c' && intg.RefId__c != ''){
                    ApplBankingIds.add(intg.RefId__c);
                }
                if(intg.RefObj__c == 'ApplGST__c' && intg.RefId__c != ''){
                    ApplGSTIds.add(intg.RefId__c);
                }
                if(intg.RefObj__c == 'ApplicantEmployment__c' && intg.RefId__c != ''){
                    ApplEmpIds.add(intg.RefId__c);
                }
                
            }  
            
            if(!userIds.isEmpty()){
                userMap.putAll([SELECT Id,Name from User Where Id IN: userIds]);
                for(TeamHierarchy__c th : [SELECT Id, Product_Type__c, IsActive__c, Employee__c, EmpRole__c,EmpBrch__r.BrchCode__c from TeamHierarchy__c  WHERE  Employee__c IN:userIds AND IsActive__c=TRUE]){
                    if(!userteamHierarchyMap.containskey(th.Employee__c)){
                       userteamHierarchyMap.put(th.Employee__c,th);
                    }
                }
            }
            
            if(taskIds.size()>0){
                for(Task t : [SELECT Id,WhatId,WhoId FROM Task WHERE Id IN:taskIds]){
                    if(t.WhatId !=null){
                        Id recordId = t.WhatId;
                        string objectName = recordId.getSObjectType().getDescribe().getName();
                        if(objectName == 'LoanAppl__c'){
                            refLoanApplIdsMap.put(t.Id,t.WhatId);
                        }
                        if(objectName == 'Applicant__c'){
                            refApplIdsMap.put(t.Id,t.WhatId);
                            Applicantid.add(t.WhatId);
                        }
                        if(objectName == 'ApplIMD__c'){
                            applIMDIds.add(t.WhatId);
                            taskRefIdMap.put(t.Id,t.WhatId);
                        }
                        if(objectName == 'Payment__c'){
                            paymentIds.add(t.WhatId);
                            taskRefIdMap.put(t.Id,t.WhatId);
                        }
                        if(objectName == 'ApplBanking__c'){
                            ApplBankingIds.add(t.WhatId);
                            taskRefIdMap.put(t.Id,t.WhatId);
                        }
                    }
                }            
            }
            if(Docdtid.size()>0){
                
                for(DocDtl__c dcd: [select id, LAN__c,Appl__c from DocDtl__c where id IN :Docdtid])
                {
                    docdetailcmap.put(dcd.id, dcd.LAN__c);
                    docapplicantmap.put(dcd.id,dcd.Appl__c);
                }         
            }
            if(Appkycid.size()>0){
                
                for(ApplKyc__c APky: [select id, Applicant__r.LoanAppln__c,Applicant__c from ApplKyc__c where id IN :Appkycid])
                {
                    applicantkycmap.put(Apky.id, APky.Applicant__r.LoanAppln__c);
                    applicantlycmapforapplicant.put(Apky.id, APky.Applicant__c);
                }         
            }
            if(Applicantid.size()>0){
                
                for(Applicant__c AP: [select id, LoanAppln__c from Applicant__c where id IN :Applicantid])
                {
                    applicantmap.put(Ap.id, AP.LoanAppln__c);
                }         
            }
            if(repayAccVerifyIds.size()>0){
                for(RepayAccVerify__c repay : [Select Id,LoanAppl__c,LoanAppl__r.Applicant__c from RepayAccVerify__c WHERE ID IN:repayAccVerifyIds]){
                    repayAccVerifyMap.put(repay.Id,repay);
                }
            }
            if(applIMDIds.size()>0){
                
                for(ApplIMD__c applimd : [Select Id,LoanAppln__c, LoanAppln__r.Applicant__c from ApplIMD__c WHERE ID IN:applIMDIds]){
                    applIMDMap.put(applimd.Id,applimd);
                }
                
            }
            if(nachIds.size()>0){
                for(NACH__c nach : [Select Id,LoanAppl__c,LoanAppl__r.Applicant__c from NACH__c WHERE ID IN:nachIds]){
                    nachMap.put(nach.Id,nach);
                }
            }
            if(paymentIds.size()>0){
                for(Payment__c payment : [Select Id,LoanAppl__c,LoanAppl__r.Applicant__c from Payment__c WHERE ID IN:paymentIds]){
                    paymentMap.put(payment.Id,payment);
                }
            }
            if(splitDisbursementIds.size()>0){
                for( Split_Disbur__c splitDisbur : [Select Id,DisburseRela__c, DisburseRela__r.Loan_Appli__c,DisburseRela__r.Loan_Appli__r.Applicant__c from Split_Disbur__c WHERE ID IN:splitDisbursementIds]){
                    splitDisbursementMap.put(splitDisbur.Id,splitDisbur);
                }
            }
            if(APIVerIds.size()>0){
                for(APIVer__c apiVer : [Select Id, Appl__c,Appl__r.LoanAppln__c,LoanAplcn__c from APIVer__c Where Id IN: APIVerIds]){
                    apiVerMap.put(apiVer.Id,apiVer);
                }
            }
            if(ApplBankingIds.size()>0){
                for(ApplBanking__c applBank : [Select Id,Appl__c, Appl__r.LoanAppln__c from ApplBanking__c Where Id IN: ApplBankingIds]){
                    applBankMap.put(applBank.Id,applBank);
                }
            }
            if(ApplGSTIds.size()>0){
                for(ApplGST__c applGST : [Select Id,Applicant__c, Applicant__r.LoanAppln__c from ApplGST__c Where Id IN: ApplGSTIds]){
                    applGSTMap.put(applGST.Id,applGST);
                }
            }
            if(ApplEmpIds.size()>0){
                for(ApplicantEmployment__c applEmp : [Select Id,LoanApplicant__c, LoanApplicant__r.LoanAppln__c from ApplicantEmployment__c Where Id IN: ApplEmpIds]){
                    applEmpMap.put(applEmp.Id,applEmp);
                }
            }
            
            if(!newList.isEmpty()){
                
                for (IntgMsg__c intg : newList) {
                    if(String.isBlank(intg.UserName__c) && userMap.containsKey(intg.CreatedById)){
                        intg.UserName__c = userMap.get(intg.CreatedById).Name;
                    }
                    if(String.isBlank(intg.UserNameRole__c) && userteamHierarchyMap.containsKey(intg.CreatedById)){
                        intg.UserNameRole__c = userteamHierarchyMap.get(intg.CreatedById).EmpRole__c;
                    }
                    if(intg.RefId__c!=''){
                        if(applicantmap.containskey(intg.RefId__c)){
                            intg.LoanAppln__c=applicantmap.get(intg.RefId__c);
                        }
                        if(applicantkycmap.containskey(intg.RefId__c)){
                            intg.LoanAppln__c=applicantkycmap.get(intg.RefId__c);
                        }
                        if(docdetailcmap.containskey(intg.RefId__c)){
                            intg.LoanAppln__c=docdetailcmap.get(intg.RefId__c);
                        }
                        if(docapplicantmap.containskey(intg.RefId__c)){
                            intg.Appl__c=docapplicantmap.get(intg.RefId__c);
                        }
                        if(applicantlycmapforapplicant.containskey(intg.RefId__c)){
                            intg.Appl__c=applicantlycmapforapplicant.get(intg.RefId__c);
                        }
                        if(repayAccVerifyMap.containsKey(intg.RefId__c)){
                            if(repayAccVerifyMap.get(intg.RefId__c).LoanAppl__c!=null){
                                intg.LoanAppln__c = repayAccVerifyMap.get(intg.RefId__c).LoanAppl__c;
                            }
                            if( repayAccVerifyMap.get(intg.RefId__c).LoanAppl__c!=null && repayAccVerifyMap.get(intg.RefId__c).LoanAppl__r.Applicant__c!=null){
                                intg.Appl__c  = repayAccVerifyMap.get(intg.RefId__c).LoanAppl__r.Applicant__c;
                            }    
                        }
                        if(applIMDMap.containsKey(intg.RefId__c)){
                            if(applIMDMap.get(intg.RefId__c).LoanAppln__c!=null){
                                intg.LoanAppln__c = applIMDMap.get(intg.RefId__c).LoanAppln__c;
                                
                            }
                            if( applIMDMap.get(intg.RefId__c).LoanAppln__c!=null && applIMDMap.get(intg.RefId__c).LoanAppln__r.Applicant__c!=null){
                                intg.Appl__c  = applIMDMap.get(intg.RefId__c).LoanAppln__r.Applicant__c;
                                
                            }
                        }
                        if(nachMap.containsKey(intg.RefId__c)){
                            if(nachMap.get(intg.RefId__c).LoanAppl__c!=null){
                                intg.LoanAppln__c = nachMap.get(intg.RefId__c).LoanAppl__c;
                            }
                            if( nachMap.get(intg.RefId__c).LoanAppl__c!=null && nachMap.get(intg.RefId__c).LoanAppl__r.Applicant__c!=null){
                                intg.Appl__c  = nachMap.get(intg.RefId__c).LoanAppl__r.Applicant__c;
                            }
                        }
                        if(paymentMap.containsKey(intg.RefId__c)){
                            if(paymentMap.get(intg.RefId__c).LoanAppl__c!=null){
                                intg.LoanAppln__c = paymentMap.get(intg.RefId__c).LoanAppl__c;
                            }
                            if( paymentMap.get(intg.RefId__c).LoanAppl__c!=null && paymentMap.get(intg.RefId__c).LoanAppl__r.Applicant__c!=null){
                                intg.Appl__c  = paymentMap.get(intg.RefId__c).LoanAppl__r.Applicant__c;
                            }
                        }
                        if(refLoanApplIdsMap.containsKey(intg.RefId__c)){
                            intg.LoanAppln__c = refLoanApplIdsMap.get(intg.RefId__c);
                        }
                        if(refApplIdsMap.containsKey(intg.RefId__c)){
                            intg.Appl__c = refApplIdsMap.get(intg.RefId__c);
                        }
                        if(intg.RefObj__c == 'Task' && taskRefIdMap.containsKey(intg.RefId__c)){
                            if(applIMDMap.containsKey(taskRefIdMap.get(intg.RefId__c))){
                                if(applIMDMap.get(taskRefIdMap.get(intg.RefId__c)).LoanAppln__c!=null){
                                    intg.LoanAppln__c = applIMDMap.get(taskRefIdMap.get(intg.RefId__c)).LoanAppln__c;
                                    
                                }
                                if( applIMDMap.get(taskRefIdMap.get(intg.RefId__c)).LoanAppln__c!=null && applIMDMap.get(taskRefIdMap.get(intg.RefId__c)).LoanAppln__r.Applicant__c!=null){
                                    intg.Appl__c  = applIMDMap.get(taskRefIdMap.get(intg.RefId__c)).LoanAppln__r.Applicant__c;
                                    
                                }
                            }
                            if(paymentMap.containsKey(taskRefIdMap.get(intg.RefId__c))){
                                if(paymentMap.get(taskRefIdMap.get(intg.RefId__c)).LoanAppl__c!=null){
                                    intg.LoanAppln__c = paymentMap.get(taskRefIdMap.get(intg.RefId__c)).LoanAppl__c;
                                }
                                if( paymentMap.get(taskRefIdMap.get(intg.RefId__c)).LoanAppl__c!=null && paymentMap.get(taskRefIdMap.get(intg.RefId__c)).LoanAppl__r.Applicant__c!=null){
                                    intg.Appl__c  = paymentMap.get(taskRefIdMap.get(intg.RefId__c)).LoanAppl__r.Applicant__c;
                                }
                            }
                            if(applBankMap.containsKey(taskRefIdMap.get(intg.RefId__c))){
                                if(applBankMap.get(taskRefIdMap.get(intg.RefId__c)).Appl__c!=null){ 
                                    intg.Appl__c  = applBankMap.get(taskRefIdMap.get(intg.RefId__c)).Appl__c;
                                    if(applBankMap.get(taskRefIdMap.get(intg.RefId__c)).Appl__r.LoanAppln__c!=null){
                                        intg.LoanAppln__c = applBankMap.get(taskRefIdMap.get(intg.RefId__c)).Appl__r.LoanAppln__c;
                                    }
                                }
                            }
                        }
                        if(splitDisbursementMap.containsKey(intg.RefId__c)){
                            
                            if(splitDisbursementMap.get(intg.RefId__c).DisburseRela__c!=null){
                                if(splitDisbursementMap.get(intg.RefId__c).DisburseRela__r.Loan_Appli__c!=null){
                                    
                                    intg.LoanAppln__c = splitDisbursementMap.get(intg.RefId__c).DisburseRela__r.Loan_Appli__c;
                                    
                                    if(splitDisbursementMap.get(intg.RefId__c).DisburseRela__r.Loan_Appli__r.Applicant__c!=null){
                                        intg.Appl__c  = splitDisbursementMap.get(intg.RefId__c).DisburseRela__r.Loan_Appli__r.Applicant__c;
                                    }  
                                }
                            }
                            
                            
                        }
                        if(apiVerMap.containsKey(intg.RefId__c)){
                            if(apiVerMap.get(intg.RefId__c).Appl__c!=null){
                                intg.Appl__c = apiVerMap.get(intg.RefId__c).Appl__c;
                                if(apiVerMap.get(intg.RefId__c).Appl__r.LoanAppln__c!=null){
                                    intg.LoanAppln__c = apiVerMap.get(intg.RefId__c).Appl__r.LoanAppln__c;
                                }
                            }
                        }
                        if(applBankMap.containsKey(intg.RefId__c)){
                            if(applBankMap.get(intg.RefId__c).Appl__c!=null){
                                intg.Appl__c = applBankMap.get(intg.RefId__c).Appl__c;
                                if(applBankMap.get(intg.RefId__c).Appl__r.LoanAppln__c!=null){
                                    intg.LoanAppln__c = applBankMap.get(intg.RefId__c).Appl__r.LoanAppln__c;
                                }
                            }
                        }
                        if(applGSTMap.containsKey(intg.RefId__c)){
                            if(applGSTMap.get(intg.RefId__c).Applicant__c!=null){
                                intg.Appl__c = applGSTMap.get(intg.RefId__c).Applicant__c;
                                if(applGSTMap.get(intg.RefId__c).Applicant__r.LoanAppln__c!=null){
                                    intg.LoanAppln__c = applGSTMap.get(intg.RefId__c).Applicant__r.LoanAppln__c;
                                }
                            }
                        }
                        if(applEmpMap.containsKey(intg.RefId__c)){
                            if(applEmpMap.get(intg.RefId__c).LoanApplicant__c!=null){
                                intg.Appl__c = applEmpMap.get(intg.RefId__c).LoanApplicant__c;
                                if(applEmpMap.get(intg.RefId__c).LoanApplicant__r.LoanAppln__c!=null){
                                    intg.LoanAppln__c = applEmpMap.get(intg.RefId__c).LoanApplicant__r.LoanAppln__c;
                                }
                            }
                        }
                        
                        
                    }
                    
                    if ( intg.Status__c == GlobalConstants.INTEGRATION_MSG_STATUS_INPROGRESS
                        && intg.Status__c != OldRecordsMap.get(intg.id).Status__c 
                        &&  OldRecordsMap.get(intg.id).Status__c == GlobalConstants.INT_MSG_STATUS_NEW) 
                    {
                        createAPITrackerList.add(intg);
                        
                    }
                    
                    
                }
                if(!createAPITrackerList.isEmpty()){
                    APICalloutTracker.create_ApiTracker(createAPITrackerList);
                }
            }
        }
        catch(Exception ex){
            System.debug('error'+ex.getMessage() +':::' + ex.getLineNumber());
        }
    }
    
}