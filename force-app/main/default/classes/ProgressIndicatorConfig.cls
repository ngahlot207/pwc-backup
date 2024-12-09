public without sharing class ProgressIndicatorConfig {
    @AuraEnabled(cacheable=false)
    public static List<StepListsWpr> progressDetails(Id loanAppId) {
        list<StepListsWpr> steplistWrapperList = new List<StepListsWpr>();
        try {
            Id userId = UserInfo.getUserId();
            
            string role = [
                SELECT  Id, Product_Type__c, IsActive__c, Employee__c, EmpLevel__c, EmpRole__c 
                FROM TeamHierarchy__c
                WHERE Employee__c = :userId 
               
            ]
                .EmpRole__c;
           /* string stageToQry = '';
            if (role == 'DSA') {
                stageToQry = 'Data Capture'; //'Data Capture' 'Sanction' 'Underwriter' 'Verification' null // 'CPA' 'CPV' 'DSA' 'Underwriter' null
            } else if (role == 'CPA') {
                stageToQry = 'Verification';
            } else if (role == 'Underwriter') {
                stageToQry = 'Underwriter';
            } else {
                stageToQry = 'Data Capture';
            }*/
            LoanAppl__c loanAppRecord = [
                SELECT Id, Name,  Stage__c, SubStage__c, Status__c FROM LoanAppl__c 
                WHERE id = :loanAppId
                WITH SECURITY_ENFORCED
            ];
          /*  if (loanAppRecord.Stage__c == 'Sales') {
                stageToQry = 'Sales';
            }
               List<ProgIndConfig__mdt> progressIndicatorSteps = [
SELECT
Id,
DeveloperName,
MasterLabel,
Language,
NamespacePrefix,
Label,
QualifiedApiName,
Business_Unit__c,
Stage_Name__c,
Stage_API_Name__c,
Stage_Sequence__c,
Sub_Stage_Name__c,
Sub_Stage_API_Name__c,
Sub_Stage_Sequence__c,
Display_Stage__c,
Display_Sub_Stage__c,
IsActive__c,
Display_for_Profiles__c,
Stage__c
FROM ProgIndConfig__mdt
WHERE
Display_Stage__c = TRUE
AND Display_Sub_Stage__c = true
AND IsActive__c = TRUE
AND Stage_API_Name__c = :loanAppRecord.Stage__c
AND Sub_Stage_API_Name__c = :loanAppRecord.SubStage__c
WITH SECURITY_ENFORCED
ORDER BY Stage_Sequence__c
];*/            List<ProgIndConfig__mdt> progressIndicatorSteps = [SELECT ProdTyp__c,StgApiName__c ,SubStgApiName__c,ScrnStgName__c,ScrnStgApiName__c ,ScrnSubStgApiName__c
                                                                   ,DsplyForRole__c ,IsActive__c,ScrnStgSeqNo__c 
                                                                   ,DsplyCriteria__c                                                                   
                                                                   FROM ProgIndConfig__mdt 
                                                                   WHERE IsActive__c = true 
                                                                   
                                                                   AND StgApiName__c=: loanAppRecord.Stage__c 
                                                                   AND SubStgApiName__c =: loanAppRecord.SubStage__c 
                                                                   AND ScrnStgApiName__c = null 
                                                                   
                                                                   WITH SECURITY_ENFORCED 
                                                                   ORDER BY ScrnStgSeqNo__c]; 
            // Stage__c =:loanAppRecord.Stage__c
            // for api name in steplist
            //
            set<string> stepset = new set<string>();
            list<string> steplist = new List<string>();
            
             for (ProgIndConfig__mdt steps : progressIndicatorSteps) {
                 list<string> displayProfiles = (list<string>) JSON.deserialize(
                     steps.DsplyForRole__c,
                     list<string>.class
                );
                 if (displayProfiles.contains(role)) {
                     steplist.add(steps.ScrnStgName__c);
                     StepListsWpr steplistWpr = new StepListsWpr();
                     steplistWpr.label = steps.ScrnStgName__c;
                     steplistWpr.value = steps.ScrnStgApiName__c;
                     steplistWrapperList.add(steplistWpr);
                 }
            //     // for api name in steplist
            
            //     //
             }
             for (string  stepset1 : stepset) {
                 steplist.add(stepset1);
             }
            //system.debug('PROGRESS DETAILS ' + progressIndicatorSteps);
            system.debug(
                'PROGRESS DETAILS steplistWrapperList ' + steplistWrapperList
            );
        } catch (exception ex) {
            GlobalUtility.logMessage(
                'Error',
                'ProgressIndicatorConfig class and method names is :: progressDetails' +
                ex.getLineNumber(),
                'Generate',
                null,
                null,
                ex.getMessage() + ' Line: ' + ex.getLineNumber(),
                null,
                ex,
                null
            );
        }
        return steplistWrapperList;
    }
    
    public class StepListsWpr {
        @AuraEnabled
        public string label { get; set; }
        @AuraEnabled
        public string value { get; set; }       
    }
    
    // @AuraEnabled(cacheable=true)
    // public static list<string> substageDetails(string currentStage) {
    //     list<string> steplist = new List<string>();
    //     try {
    //         List<ProgIndConfig__mdt> progressIndicatorSubSteps = [
    //             SELECT
    //                 Id,
    //                 DeveloperName,
    //                 MasterLabel,
    //                 Language,
    //                 NamespacePrefix,
    //                 Label,
    //                 QualifiedApiName,
    //                 Business_Unit__c,
    //                 Stage_Name__c,
    //                 Stage_API_Name__c,
    //                 Stage_Sequence__c,
    //                 Sub_Stage_Name__c,
    //                 Sub_Stage_API_Name__c,
    //                 Sub_Stage_Sequence__c,
    //                 Display_Stage__c,
    //                 Display_Sub_Stage__c,
    //                 IsActive__c
    //             FROM ProgIndConfig__mdt
    //             WHERE
    //                 Display_Sub_Stage__c = TRUE
    //                 AND IsActive__c = TRUE
    //                 AND Stage_Name__c = :currentStage
    //             WITH SECURITY_ENFORCED
    //             ORDER BY Stage_Sequence__c
    //         ];
    //         set<string> stepset = new Set<string>();
    
    //         for (ProgIndConfig__mdt steps : progressIndicatorSubSteps) {
    //             steplist.add(steps.Sub_Stage_Name__c);
    //         }
    //         for (string stepset1 : stepset) {
    //             steplist.add(stepset1);
    //         }
    //         system.debug('steplist' + steplist);
    //     } catch (exception ex) {
    //         GlobalUtility.logMessage(
    //             'Error',
    //             'ProgressIndicatorConfig class and method names is :: substageDetails' +
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
    //     return steplist;
    // }
    
    // // To Fetch IntgProConfig__mdt based on IsActive__c=True and service Name
    
    // @AuraEnabled
    // public static string intProgressDetails(
    //     string intAPIName,
    //     id applicantId,
    //     string intstageName,
    //     string loanAppId
    // ) {
    //     try {
    //         string response = '';
    //         system.debug('loanAppId integration = ' + loanAppId);
    //         system.debug('loanAppId = ' + applicantId);
    //         system.debug('intAPIName = ' + intAPIName);
    //         system.debug('intstageName = ' + intstageName);
    //         list<IntgMsg__c> intlst = new List<IntgMsg__c>();
    //         List<IntgProConfig__mdt> intIndicatorSteps = [
    //             SELECT
    //                 Id,
    //                 Label,
    //                 BU__c,
    //                 DsplyForStgSubstg__c,
    //                 DsplyForProf__c,
    //                 IntAPIName__c,
    //                 IntName__c,
    //                 IntSeq__c,
    //                 IsActive__c,
    //                 StgAPIName__c,
    //                 SubStgAPIName__c,
    //                 IntValidConfig__c
    //             FROM IntgProConfig__mdt
    //             WHERE
    //                 IsActive__c = TRUE
    //                 AND IntName__c = :intAPIName
    //               //  AND StgAPIName__c = :intstageName
    //             WITH SECURITY_ENFORCED
    //             ORDER BY IntSeq__c
    //         ];
    //         // if(intIndicatorSteps.isEmpty()){
    //         //     throw new AuraHandledException('no stages found wrong attribute values  ///'+	'loanAppId  = ' + loanAppId +'appId = ' + applicantId +'intAPIName = ' + intAPIName + 'intstageName = ' + intstageName );  
    //         // }
    //         system.debug(' intIndicatorSteps == ' + intIndicatorSteps);
    //         system.debug('validate resp for int  values are intAPIName ' + intAPIName +' applicantId '+ applicantId +' intstageName '+ intstageName);
    //         string  validityResponse = ProgressIndicatorConfig.checkValidation(
    //             intAPIName,
    //             applicantId,
    //             intstageName
    //         );
    //         system.debug('validityResponse is '+ validityResponse);
    //         if (validityResponse == 'validated' ) {
    //             boolean  integProcess = IntegrationUiController.updateIntegeationProgress(loanAppId,applicantId,intAPIName,intstageName,'In Progress');
    //             // boolean createdIntMsz = ProgressIndicatorConfig.callIngMsg(
    //             //     intIndicatorSteps,
    //             //     applicantId
    //             // );
    //             system.debug('integProcess is '+ integProcess);
    //             if(integProcess){
    //                // boolean  integProcess = IntegrationUiController.updateIntegeationProgress(loanAppId,applicantId,intAPIName,intstageName,'In Progress');
    //                 boolean createdIntMsz = ProgressIndicatorConfig.callIngMsg(
    //                     intIndicatorSteps,
    //                     applicantId
    //                 );
    
    //                 system.debug('createdIntMsz is '+ createdIntMsz);
    //                 if(createdIntMsz){
    //                 response = 'success';
    //                 }else{
    //                 response = 'faild in creating Integration Msz';
    //             }
    //             }else{
    //                 response =   'faild in creating Integration Progress ' ;
    //             }
    //             //'insered Success'  string loanAppId , Id applicantId, string intStage,string stageName, string status
    
    //         } else {
    //             system.debug('validation not completed ');
    //             response = validityResponse;
    //             //throw new AuraHandledException(validityResponse);
    //         }
    //         return response;  
    //     } catch (Exception e) {
    //         system.debug('inside Catch block intProgressDetails ' + e.getMessage()+ e.getLineNumber());
    //         throw new AuraHandledException(e.getMessage() );
    //     }
    
    // }
    
    // public static string checkValidation(
    //     string intAPIName,
    //     id applicantId,
    //     string intstageName
    // ) {
    //     string  respStr = '';
    //     IntgProConfig__mdt intIndicatorSteps = [
    //         SELECT
    //             Id,
    //             Label,
    //             BU__c,
    //             DsplyForStgSubstg__c,
    //             DsplyForProf__c,
    //             IntAPIName__c,
    //             IntName__c,
    //             IntSeq__c,
    //             IsActive__c,
    //             StgAPIName__c,
    //             SubStgAPIName__c,
    //             IntValidConfig__c
    //         FROM IntgProConfig__mdt
    //         WHERE
    //             IsActive__c = TRUE
    //             AND IntName__c = :intAPIName
    //            // AND StgAPIName__c = :intstageName
    //         WITH SECURITY_ENFORCED
    //         ORDER BY IntSeq__c
    //         LIMIT 1
    //     ];
    //     system.debug('applicantId' + applicantId);
    //     if(intIndicatorSteps!=null){
    //         IntValidConfig intgValid = (IntValidConfig) JSON.deserialize(
    //             intIndicatorSteps.IntValidConfig__c,
    //             IntValidConfig.class
    //         );
    
    //         string condition = intgValid.condition;
    //         system.debug('validation condition =='+ condition);
    //         condition = condition.replace(
    //             ': applicantId',
    //             '\'' + applicantId + '\''
    //         );
    
    //         List<sObject> sobjectList = new List<sObject>();
    
    //         string str =
    //             'select Id from ' +
    //             intgValid.objectName +
    //             ' where ' +
    //             condition;
    //             system.debug('validation sobjectList  str == ' + str);   
    //         sobjectList = System.Database.query(str);
    //         system.debug('validation sobjectList   ==' + sobjectList);
    //         if (sobjectList.isEmpty()) {
    //             //response = false;
    //             respStr = 'Required value Missing for '+ intAPIName +' Integration    ';
    //            //return  throw new AuraHandledException('Required value Missing for '+ intAPIName +' Integration    ');
    //         } else {
    //             respStr = 'validated';
    //         }
    //     }
    //     return respStr;
    // }
    
    // public static boolean callIngMsg(
    //     list<IntgProConfig__mdt> intIndicatorSteps,
    //     id referenceID
    // ) {
    //     boolean response = false;
    //     system.debug('inputs are ::::' + intIndicatorSteps);
    //     system.debug('called::::' + referenceID);
    //     list<IntgMsg__c> intlst = new List<IntgMsg__c>();
    //     fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
    //         new List<SObjectType>{ IntgMsg__c.SObjectType }
    //     );
    
    //     List<string> fieldNamesList = new List<string>{
    //         'BU__c',
    //         'Name',
    //         'Svc__c',
    //         'IsActive__c',
    //         'RefId__c',
    //         'Status__c',
    //         'MStatus__c',
    //         'RefObj__c'
    //     };
    //     String sObjectName = 'IntgMsg__c';
    //     Schema.SObjectType objType = Schema.getGlobalDescribe()
    //         .get(sObjectName);
    //     fflib_SecurityUtils.checkInsert(objType, fieldNamesList);
    
    //     try {
    //         for (IntgProConfig__mdt mt : intIndicatorSteps) {
    //             IntgMsg__c newlit = new IntgMsg__c();
    //             newlit.BU__c = mt.BU__c;
    //             newlit.Name = mt.Label;
    //             newlit.Svc__c = mt.IntName__c;
    //             newlit.IsActive__c = true;
    //             newlit.RefId__c = referenceID;
    //             newlit.Status__c = 'New';
    //             newlit.MStatus__c = 'Blank';
    //             newlit.RefObj__c = 'Applicant__c';
    //             intlst.add(newlit);
    //         }
    //      uow.registernew(intlst);
    //     uow.commitWork();
    //         // return intlst;
    //     } catch (exception ex) {
    
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
    //     }
    
    //     //insert intlst;
    //     system.debug('intlst::::' + intlst);
    //     system.debug('inserted');
    //      response = true;
    //     return response;
    // }
    // public class IntValidConfig {
    //     @AuraEnabled
    //     public string objectName { get; set; }
    //     @AuraEnabled
    //     public string condition { get; set; }
    // }
}