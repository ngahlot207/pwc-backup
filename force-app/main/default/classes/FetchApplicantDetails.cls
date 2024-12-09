public without sharing class FetchApplicantDetails {
    // @auraEnabled(cacheable=true)
    // public static string fetchApplicantDetailsMethod(String recordId) {
    //     try{
    //         List<Applicant__c> applicantDetails = [
    //             SELECT  Id,  LoanAppln__c,Constitution__c ,  FName__c, LName__c 
    //             FROM Applicant__c 
    //             WHERE LoanAppln__c = :recordId
    //             WITH SECURITY_ENFORCED
    //         ];
    //         system.debug('Applicant Details==>' + applicantDetails);
    //         string appId = applicantDetails[0].Id;
    //         return Json.serialize(applicantDetails);
    //     }catch(exception ex) {
    //         GlobalUtility.logMessage(
    //             'Error',
    //             'ProgressIndicatorConfig class and method names is :: callIngMsg' +
    //             ex.getLineNumber(),
    //             'Generate',
    //             null,
    //             null,
    //             ex.getMessage() + ' Line: ' + ex.getLineNumber(),
    //             null,
    //             ex,
    //             null
    //         );
    //         throw new AuraHandledException(ex.getMessage());
    //     }
    // }
    // @auraEnabled(cacheable=true)
    // public static String getCaseDetailsMethod(String applicantId) {
    //     List<Case> caseDetails;
    //     try {
    //         caseDetails = [
    //             SELECT
    //                 ID,
    //                 Applicant__c,
    //                 AprvlStatus__c,
    //                 LastModifiedBy.Name,
    //                 LastModifiedDate,
    //                 Comments__c
    //             FROM Case
    //             WHERE Applicant__c = :applicantId
    //             WITH SECURITY_ENFORCED
    //         ];
    //         system.debug('Case Details==>' + caseDetails);
    //     } catch (exception ex) {
    //         GlobalUtility.logMessage(
    //             'Error',
    //             'class name :: FetchApplicantDetails and method names is :: getCaseDetailsMethod' +
    //             ex.getLineNumber(),
    //             'Generate',
    //             null,
    //             null,
    //             ex.getMessage() + ' Line: ' + ex.getLineNumber(),
    //             null,
    //             ex,
    //             null
    //         );
    //         throw new AuraHandledException(ex.getMessage());
    //     }
    
    //     return Json.serialize(caseDetails);
    // }
    
    // @auraEnabled(cacheable=true)
    // public static String getverificationDetails(String loanAppId) {
    //     try {
    //         List<Verification__c> verDetails = [
    //             SELECT Id, LoanApp__c
    //             FROM Verification__c
    //             WHERE LoanApp__c = :loanAppId
    //             WITH SECURITY_ENFORCED
    //         ];
    //         system.debug('Verification Details==>' + verDetails);
    //         string varId = verDetails[0].Id;
    //         return Json.serialize(verDetails);
    //     } catch (exception ex) {
    //         GlobalUtility.logMessage(
    //             'Error',
    //             'class name :: FetchApplicantDetails and method names is :: getverificationDetails' +
    //             ex.getLineNumber(),
    //             'Generate',
    //             null,
    //             null,
    //             ex.getMessage() + ' Line: ' + ex.getLineNumber(),
    //             null,
    //             ex,
    //             null
    //         );
    //         throw new AuraHandledException(ex.getMessage());
    //     }
    // }
    // @auraEnabled
    // public static String getScreenConfiMetdata(
    //     String loanAppId,
    //     String stepperName,
    //     String subStepperName
    // ) {
    //     list<ScrConfig__mdt> fetchMeta;
        
    //     try {
    //         LoanAppl__c loanAppdetails = [
    //             SELECT Id,  Stage__c, SubStage__c, Stepper__c 
    //             FROM LoanAppl__c
    //             WHERE id = :loanAppId
    //             WITH SECURITY_ENFORCED
    //         ];
            
    //         if (loanAppdetails != null) {
                
    //             if(subStepperName != null){
    //                 fetchMeta = [ 
    //                     SELECT
    //                     Id,
    //                     Show_Tabset__c,
    //                     StgApiName__c,
    //                     SubStgName__c,
    //                     SubStgApiName__c,
    //                     ScrnStgName__c,
    //                     ScrnStgApiName__c ,
    //                     ScrnSubStgName__c ,
    //                     ScrnSubStgAPIName__c ,
    //                     Sub_Stage_Sequence__c,
    //                     Display_Stepper__c,
    //                     Display_Sub_Stepper__c,
    //                     IsActive__c,
    //                     DsplyCconfig__c ,
    //                     Stage__c, 
    //                     SubStage__c,
    //                     Stepper__c,
    //                     QryConfig__c
    //                     FROM ScrConfig__mdt
    //                     WHERE 
    //                     IsActive__c = true
    //                     AND StgApiName__c=: loanAppdetails.Stage__c 
    //                     AND SubStgApiName__c =: loanAppdetails.SubStage__c
    //                     AND  ScrnStgApiName__c =:stepperName 
    //                     AND ScrnSubStgAPIName__c =: subStepperName
    //                     AND Display_Sub_Stepper__c = true
    //                 ];
    //             }else{
    //                 fetchMeta = [ 
    //                     SELECT
    //                     Id,
    //                     Show_Tabset__c,
    //                     StgApiName__c,
    //                     SubStgName__c,
    //                     SubStgApiName__c,
    //                     ScrnStgName__c,
    //                     ScrnStgApiName__c ,
    //                     ScrnSubStgName__c ,
    //                     ScrnSubStgAPIName__c ,
    //                     Sub_Stage_Sequence__c,
    //                     Display_Stepper__c,
    //                     Display_Sub_Stepper__c,
    //                     IsActive__c,
    //                     DsplyCconfig__c ,
    //                     Stage__c, 
    //                     SubStage__c,
    //                     Stepper__c,
    //                     QryConfig__c
    //                     FROM ScrConfig__mdt
    //                     WHERE 
    //                     IsActive__c = true
    //                     AND StgApiName__c=: loanAppdetails.Stage__c 
    //                     AND SubStgApiName__c =: loanAppdetails.SubStage__c
    //                     AND  ScrnStgApiName__c =:stepperName 
    //                     AND Display_Stepper__c =true
                        
    //                 ];
    //             }
    //             system.debug('line128'+JSON.serialize(fetchMeta));
    //             //string lnId = loanAppdetails.Id;
    //             if(fetchMeta.size() != 0){
    //                 return JSON.serialize(fetchMeta);
    //             }else{
    //                 return null;
    //             }
                
    //         } else {
    //             return null;
    //         }
    //     } catch (exception ex) {
    //         GlobalUtility.logMessage(
    //             'Error',
    //             'class name :: FetchApplicantDetails and method names is :: getScreenConfiMetdata' +
    //             ex.getLineNumber(),
    //             'Generate',
    //             null,
    //             null,
    //             ex.getMessage() + ' Line: ' + ex.getLineNumber(),
    //             null,
    //             ex,
    //             null
    //         );
    //         throw new AuraHandledException(ex.getMessage());
    //     }
    // }
    
    @auraEnabled
    public static string fetchQryRecordMethod(String qry , string loanAppId, DefinetabVal tabsetFields, string newTabLabel) {
        try{
            system.debug('tabsetFields  ==> ' + tabsetFields); 
            list<sobject> qryresult = new list<sobject>();
           
            if(qry != null){
                qryresult = database.query(qry);
            }
            system.debug('qryresult  ==> ' + qryresult);
            list<TabsetObj> tabsetObjList = new list<TabsetObj>(); 
            if(qryresult.size()>0){  
                integer btnIncVal = 1;
                for(sobject qryObj:  qryresult){
                    
                    TabsetObj tabsetObj = new TabsetObj();
                    string tabLabel= '';  
                    tabsetObj.value = (string)qryObj.get(tabsetFields.key);
                    if(tabsetFields.labelContent.size() >0){
                        for(Integer i=0; i<tabsetFields.labelContent.size(); i++){
                            if(qryObj.get(tabsetFields.labelContent[i]) !=null){
                                string tabName = (string) qryObj.get(tabsetFields.labelContent[i]);
                                tabName =   tabName.length() > 30 ? tabName.substring(0, 30) + ' . . .' : tabName;
                               
                                tabLabel = tabLabel +' '+tabName; 
                            }else{
                                tabLabel = tabLabel + newTabLabel ;
                            }
                            
                    }
                    }else{
                        tabLabel = tabLabel + newTabLabel ;
                    }
                    
                    if(tabsetFields.showButtonLabelIncremented == true){
                         Integer cnt = btnIncVal++;
                         tabLabel = tabLabel + ' '+ String.valueOf(cnt);
                        }
                    //btnIncVal = btnIncVal + 1;
                    tabsetObj.label =tabLabel;
                    tabsetObjList.add(tabsetObj);
                }
                system.debug('tabsetObjList  ==> ' + tabsetObjList);
                return Json.serialize(tabsetObjList); 
            }else{
                return null;
            }
            
        }catch(exception ex) {
            GlobalUtility.logMessage(
                'Error',
                'ProgressIndicatorConfig class and method names is :: callIngMsg' +
                ex.getLineNumber(),
                'Generate',
                null,
                null,
                ex.getMessage() + ' Line: ' + ex.getLineNumber(),
                null,
                ex,
                null
            );
            throw new AuraHandledException(ex.getMessage());
        }
    }
    public class TabsetObj {
        @AuraEnabled
        public string label { get; set; }
        @AuraEnabled
        public string value { get; set; }
         @AuraEnabled
        public boolean removable { get; set; }
    }
     public class DefinetabVal {
        @AuraEnabled
        public string key { get; set; }
         @AuraEnabled
        public boolean showButtonLabelIncremented { get; set; }
        @AuraEnabled
        public list<string> labelContent { get; set; }
    }
}