public without sharing class RetriggerUpsertHandler {
    @AuraEnabled
    public static void createRetriggerRecords(InputData inputData) {
        Set<Id> loanAppIds = new Set<Id>();
        Set<String> productType = new Set<String>();
        Set<String> retAduitData = new Set<String>();
        List<LoanTAT__c> loanTATList = new List<LoanTAT__c>();
        List<LoanAppl__c> loanAppList = new List<LoanAppl__c>();
        List<RetriggerUpsertAudit__c> retAduitRecord = new List<RetriggerUpsertAudit__c>();
        Map<integer, List<APIRetriggerTracker__c>> apiRetriggerTrcrMap = new Map<integer, List<APIRetriggerTracker__c>>();
        List<RetriggerUpsertAudit__c> retriggerUpsertAuditList = new List<RetriggerUpsertAudit__c>();
        List<APIRetriggerTracker__c> insertapiRetriggerTrcrList = new List<APIRetriggerTracker__c>();
        List<RetriggerUpsertMstr__mdt> retriggerUpsertMstrList = new List<RetriggerUpsertMstr__mdt>();
        List<IntgMsg__c> intMsgList = new List<IntgMsg__c>();
        Map<Id, Set<String>> stageMap = new Map<Id, Set<String>>();
        Map<Id, Set<String>> subStageMap = new Map<Id, Set<String>>();
        Map<Id, SObject> oldRecordsMap = new Map<Id, SObject>();
        Map<Id, Set<String>> platfromEventMap = new Map<Id, Set<String>>();

        if (inputData.oldList != null && inputData.oldList.size() > 0) {
            //oldRecordsMap = inputData.oldList;
            for (SObject rec : inputData.oldList) {
                oldRecordsMap.put(rec.Id, rec);
            }
        }
        // Map<Id,SObject> oldRecordsMap = new Map<Id,SObject>(inputData.oldList);
        //Added for LAK-517
        Set<String> emailCodes = new Set<String>();
        List<MasterData__c> emailMasterData = [SELECT Id, Name, SalesforceCode__c, Type__c FROM MasterData__c WHERE Type__c ='Email Providers'];
        if (!emailMasterData.isEmpty()) {
            for (MasterData__c emailMasterData1 : emailMasterData) {  
                emailCodes.add(emailMasterData1.SalesforceCode__c);
            }
        }
        Id userId = UserInfo.getUserId();
        system.debug('userId is ' + userId);
        String role;
        List<TeamHierarchy__c> teamHiera = [
            SELECT Id, EmpRole__c
            FROM TeamHierarchy__c
            WHERE Employee__c = :userId
            LIMIT 1
        ];
         //system.debug('teamHiera '+ teamHiera);
        if (teamHiera != null && teamHiera.size() > 0) {      
            role = teamHiera[0].EmpRole__c;
        }
        for (SObject rec : inputData.newList) {
            Id loanId = (Id) rec.get(inputData.loanFieldAPIName);
            system.debug('loanId ' + rec.get(inputData.loanFieldAPIName));
            if (loanId != null) {
                loanAppIds.add(loanId);
            }
        }
        if (loanAppIds != null && loanAppIds.size() > 0) {
            loanTATList = [
                SELECT Id, Stage__c, Sub_Stage__c, LoanApplication__c
                FROM LoanTAT__c
                WHERE LoanApplication__c IN :loanAppIds
            ];
           loanAppList = [SELECT Id, Product__c
                FROM LoanAppl__c
                WHERE Id IN :loanAppIds]; 

                retAduitRecord = [SELECT Id, LoanApp__c , ObjApiName__c, FieldApiName__c,Appl__c
                FROM RetriggerUpsertAudit__c 
                WHERE LoanApp__c IN :loanAppIds AND IsActive__c  = true];
        }

        if (loanAppList != null && loanAppList.size() > 0) {
            for (LoanAppl__c loanApp : loanAppList) {
                productType.add(loanApp.Product__c);

            }
        }

        if (retAduitRecord != null && retAduitRecord.size() > 0) {
            for (RetriggerUpsertAudit__c retRec : retAduitRecord) {
                retAduitData.add((retRec.Appl__c+'-'+retRec.ObjApiName__c+'-'+retRec.FieldApiName__c).toLowerCase());
            }
        }
        if (loanTATList != null && loanTATList.size() > 0) {
            system.debug('loanTATList  ' + loanTATList);
            system.debug('loanTATList size ' + loanTATList.size());

            for (LoanTAT__c loanTAT : loanTATList) {
                Set<String> stageList = stageMap.get(
                    loanTAT.LoanApplication__c
                );
                Set<String> subStageList = subStageMap.get(
                    loanTAT.LoanApplication__c
                );
                if (stageList == null) {
                    stageList = new Set<String>();
                }
                if (subStageList == null) {
                    subStageList = new Set<String>();
                }
                stageList.add(loanTAT.Stage__c);
                subStageList.add(loanTAT.Sub_Stage__c);
                stageMap.put(loanTAT.LoanApplication__c, stageList);
                subStageMap.put(loanTAT.LoanApplication__c, subStageList);
                system.debug('stageMap  ' + stageMap);
                system.debug('subStageMap  ' + subStageMap);
            }
        }
        //List<String> roleSet = new List<String>(role);
        String roleNew = '%' + role + '%';
        retriggerUpsertMstrList = [
            SELECT
                Id,
                AppStage__c,
                Mes__c,
                FieldApiName__c,
                AppSubStage__c,
                ModType__c,
                ModifierRole__c,
                RetriggerApiNames__c,
                ObjApiName__c,
                ValidFrom__c,
                ValidTill__c
            FROM RetriggerUpsertMstr__mdt
            WHERE
                IsActive__c = TRUE
                AND ObjApiName__c = :inputData.objectApiName
               // AND ModifierRole__c LIKE :roleNew
                AND ModType__c = :inputData.modificationType AND ProductType__c IN : productType
        ];

        system.debug(
            'retriggerUpsertMstrList before if condition ' +
            retriggerUpsertMstrList
        );

        if (
            retriggerUpsertMstrList != null &&
            retriggerUpsertMstrList.size() > 0 &&
            inputData.newList != null &&
            inputData.newList.size() > 0
        ) {
            system.debug(
                'retriggerUpsertMstrList  ' + retriggerUpsertMstrList.size()
            );

            for (SObject record : inputData.newList) {
                Id sampleID = (Id) record.get('Id');
					system.debug('record'+record);
                for (
                    RetriggerUpsertMstr__mdt retrUpRec : retriggerUpsertMstrList
                ) {
                    Id loanAppId = (Id) record.get(inputData.loanFieldAPIName);
                    Id applicantId = (Id) record.get(inputData.applFieldAPIName );

                    Set<String> stageList = stageMap.get(loanAppId);

                    Set<String> subStageList = subStageMap.get(loanAppId);
                    
                    if (
                        stageList != null &&
                        stageList.size() > 0 &&
                        subStageList != null &&
                        retrUpRec.AppStage__c != null &&
                        subStageList.size() > 0 &&
                        retrUpRec.AppSubStage__c != null
                    ) {
                        // if(stageList.size() > 0 && subStageList.size() > 0){
                        if (
                            stageList.contains(retrUpRec.AppStage__c) &&
                            subStageList.contains(retrUpRec.AppSubStage__c)
                        ) {
                            if (
                                (inputData.modificationType == 'Insert') ||
                                (inputData.modificationType == 'Delete') ||
                                (inputData.modificationType == 'Update' &&
                                oldRecordsMap != null &&
                                record.get(retrUpRec.FieldApiName__c) !=
                                oldRecordsMap.get(record.Id)
                                    .get(retrUpRec.FieldApiName__c) && 
                                    (oldRecordsMap.get(record.Id).get(retrUpRec.FieldApiName__c) !=null ||
                                    retAduitData.contains((applicantId+'-'+retrUpRec.ObjApiName__c+'-'+retrUpRec.FieldApiName__c).toLowerCase())
                                    ))
                            ) {
                                system.debug('retrUpRec.FieldApiName__c'+retrUpRec.FieldApiName__c);
                                RetriggerUpsertAudit__c rtrUpsertAudit = new RetriggerUpsertAudit__c();
                                rtrUpsertAudit.LoanApp__c = (Id) record.get(
                                    inputData.loanFieldAPIName
                                );
                                rtrUpsertAudit.Appl__c = (Id) record.get(
                                    inputData.applFieldAPIName
                                );
                                rtrUpsertAudit.IsActive__c = true;
                                rtrUpsertAudit.RefObj__c = sampleID.getsobjecttype()
                                    .getDescribe()
                                    .getName();
                                rtrUpsertAudit.RefID__c = (String) record.get(
                                    'Id'
                                );
                                rtrUpsertAudit.FieldApiName__c = retrUpRec.FieldApiName__c;
                                rtrUpsertAudit.ObjApiName__c = retrUpRec.ObjApiName__c;
                                rtrUpsertAudit.ModType__c = inputData.modificationType;
                                rtrUpsertAudit.AppStage__c = retrUpRec.AppStage__c;
                                rtrUpsertAudit.AppSubStage__c = retrUpRec.AppSubStage__c;
                                rtrUpsertAudit.ModifierRole__c = role;
                                rtrUpsertAudit.ModTime__c = Datetime.now();
                                rtrUpsertAudit.ModBy__c = userId;
                                rtrUpsertAudit.OldValue__c = inputData.modificationType ==
                                    'Update'
                                    ? String.valueOf(
                                          oldRecordsMap.get(record.Id)
                                              .get(retrUpRec.FieldApiName__c)
                                      )
                                    : '';
                                rtrUpsertAudit.NewValue__c = String.valueOf(
                                    record.get(retrUpRec.FieldApiName__c)
                                );
                                retriggerUpsertAuditList.add(rtrUpsertAudit);
                                list<string> triggerApiNames = (list<string>) JSON.deserialize(
                                    retrUpRec.RetriggerApiNames__c,
                                    list<string>.class
                                );
                                system.debug('triggerApiNames.size()'+triggerApiNames.size());
                                if (
                                    triggerApiNames != null &&
                                    triggerApiNames.size() > 0
                                ) {
                                    if (inputData.objectApiName == 'Applicant__c' && (retrUpRec.FieldApiName__c == 'ProfQual__c' || retrUpRec.FieldApiName__c =='MembershipNumber__c')) {
                                        String profQual =(String) record.get('ProfQual__c');
                                        
                                        if (profQual == 'CA') {
                                            triggerApiNames.clear();
                                            triggerApiNames.add('CA Membership Authentication');
                                            // triggerApiNames.remove('Architect Authentication'); 
                                            // triggerApiNames.remove('NMC Membership Authentication'); 
                                        } else if (profQual == 'ART') {
                                            triggerApiNames.clear();
                                            triggerApiNames.add('Architect Authentication');
                                            // triggerApiNames.remove('CA Membership Authentication'); 
                                            // triggerApiNames.remove('NMC Membership Authentication'); 
                                        } else if (profQual == 'DOCBM' || profQual == 'DOCB' || profQual == 'DOC' || profQual == 'DOCS') {
                                            triggerApiNames.clear();
                                            triggerApiNames.add('NMC Membership Authentication');
                                            // triggerApiNames.remove('CA Membership Authentication'); 
                                            // triggerApiNames.remove('Architect Authentication'); 
                                        }
                                    }else if(inputData.objectApiName == 'Applicant__c' && retrUpRec.FieldApiName__c == 'DOB__c'){
                                        String consiType =(String) record.get('Constitution__c');
                                        if (consiType == 'PROPERITORSHIP' || consiType == 'INDIVIDUAL'){
                                            triggerApiNames.add('Crime Add Report API - Individual');
                                        }else{
                                            triggerApiNames.add('Crime Add Report API - Company');
                                        }
                                    }
                                    else if(inputData.objectApiName == 'ApplAddr__c'){
                                        String applId =(String) record.get('Applicant__c');
                                        Applicant__c applRec=[select Id, Constitution__c from Applicant__c where Id=: applId];
                                        if((retrUpRec.FieldApiName__c == 'AddrLine1__c' || retrUpRec.FieldApiName__c == 'AddrLine2__c') && (String) record.get('AddrTyp__c') == 'Residence Address'){
                                            if (applRec.Constitution__c == 'PROPERITORSHIP' || applRec.Constitution__c == 'INDIVIDUAL'){
                                                triggerApiNames.add('Crime Add Report API - Individual');
                                            }else{
                                                triggerApiNames.add('Crime Add Report API - Company');
                                            }
                                        }else if(retrUpRec.FieldApiName__c == 'AddrLine2__c' && ((String) record.get('AddrTyp__c') == 'Office Address' || (String) record.get('AddrTyp__c') == 'Residence Cum office' || (String) record.get('AddrTyp__c') == 'Principal place for business')){
                                            if (applRec.Constitution__c == 'PROPERITORSHIP' || applRec.Constitution__c == 'INDIVIDUAL'){
                                                triggerApiNames.add('Crime Add Report API - Individual');
                                            }else{
                                                triggerApiNames.add('Crime Add Report API - Company');
                                            }
                                        }else if(retrUpRec.FieldApiName__c == 'Pincode__c' && ((String) record.get('AddrTyp__c') == 'Office Address' || (String) record.get('AddrTyp__c') == 'Residence Cum office' || (String) record.get('AddrTyp__c') == 'Principal place for business' || (String) record.get('AddrTyp__c') == 'Residence Address')){
                                            if (applRec.Constitution__c == 'PROPERITORSHIP' || applRec.Constitution__c == 'INDIVIDUAL'){
                                                triggerApiNames.add('Crime Add Report API - Individual');
                                            }else{
                                                triggerApiNames.add('Crime Add Report API - Company');
                                            }
                                        }
                                    }
                                    if (inputData.objectApiName == 'Applicant__c' && retrUpRec.FieldApiName__c == 'EmailId__c') {
                                        String emailVal = (String) record.get('EmailId__c');
                                        Boolean returnval = containsAny(emailVal,emailCodes);
                                        if(returnval == true){
                                            triggerApiNames.clear();
                                            triggerApiNames.add('Email Verification');
                                        }else{
                                            triggerApiNames.clear();
                                            triggerApiNames.add('Email Authentication Advanced');
                                        }
                                    }
                                    
                                    for (String str : triggerApiNames) {
                                        if (
                                            (inputData.objectApiName ==
                                            'Applicant__c' 
                                            )
                                        ) {
                                            if((str == 'Consumer ACK Request' &&
                                            record.get('Constitution__c') !=
                                            'INDIVIDUAL') ||
                                            (str == 'Commercial ACK Request' &&
                                            record.get('Constitution__c') ==
                                            'INDIVIDUAL')){
                                                if(str == 'Consumer ACK Request'){
                                                    Id applicationId = (Id) record.get(inputData.applFieldAPIName);
                                                    IntgMsg__c intMsg = new IntgMsg__c();
                                                    intMsg.Name='Consumer ACK Request';
                                                    intMsg.Svc__c='Consumer ACK Request';
                                                    intMsg.BU__c='HL / STL';
                                                    intMsg.IsActive__c=true;
                                                    intMsg.ExecType__c='Async';
                                                    intMsg.Status__c='New';
                                                    intMsg.Mresp__c='Blank';
                                                    intMsg.Outbound__c=true;
                                                    intMsg.Trigger_Platform_Event__c=false;
                                                    intMsg.TriggerType__c='System';
                                                    intMsg.RefObj__c=inputData.objectApiName;
                                                    intMsg.RefId__c=applicationId;
                                                    intMsg.ParentRefObj__c=inputData.loanFieldAPIName;
                                                    intMsg.ParentRefId__c=loanAppId;
                                                    intMsgList.add(intMsg);
                                                }
                                                continue;
                                            }                                           
                                        }
                                       
                                        APIRetriggerTracker__c apiRetriggerTrckr = new APIRetriggerTracker__c();
                                        apiRetriggerTrckr.LoanApp__c = (Id) record.get(
                                            inputData.loanFieldAPIName
                                        );
                                        if (str != 'Hunter Token') {
                                            apiRetriggerTrckr.App__c = (Id) record.get(
                                                inputData.applFieldAPIName
                                            );
                                        }
                                        apiRetriggerTrckr.RefObj__c = sampleID.getsobjecttype()
                                            .getDescribe()
                                            .getName();
                                        apiRetriggerTrckr.RefID__c = (String) record.get(
                                            'Id'
                                        );
                                        apiRetriggerTrckr.APIName__c = str;
                                        apiRetriggerTrckr.CurrentStatus__c = 'In Progress';
                                        apiRetriggerTrckr.IsActive__c = true;
                                        List<APIRetriggerTracker__c> apiRetrgrList = apiRetriggerTrcrMap.get(
                                            retriggerUpsertAuditList.size() - 1
                                        );
                                        if (apiRetrgrList == null) {
                                            apiRetrgrList = new List<APIRetriggerTracker__c>();
                                        }
                                        apiRetrgrList.add(apiRetriggerTrckr);
                                        apiRetriggerTrcrMap.put(
                                            retriggerUpsertAuditList.size() - 1,
                                            apiRetrgrList
                                        );
                                    }
                                }
                                Set<String> messageSet = platfromEventMap.get(
                                    loanAppId
                                );

                                if (messageSet == null) {
                                    messageSet = new Set<String>();
                                }
                                //LAK-8719
                               if(inputData.objectApiName =='Applicant__c' && retrUpRec.FieldApiName__c == 'MobNumber__c' && record.get('CustProfile__c') !='SALARIED'){
                                messageSet.add('Mobile Number has been changed. Kindly Verify the same.');
                               }else{
                                messageSet.add(retrUpRec.Mes__c);
                               }                
                                platfromEventMap.put(loanAppId, messageSet);                            
                            }
                        }
                        // }
                    }
                }
            }
        }

        publishPlatformEvent(platfromEventMap);
        if (
            retriggerUpsertAuditList != null &&
            retriggerUpsertAuditList.size() > 0
        ) {
            system.debug(
                'retriggerUpsertAuditList  ' + retriggerUpsertAuditList
            );
            insert retriggerUpsertAuditList;
            system.debug(
                'retriggerUpsertAuditList after insert ' +
                retriggerUpsertAuditList.size()
            );
        }
        for (Integer intg : apiRetriggerTrcrMap.keyset()) {
            SObject sobjt = retriggerUpsertAuditList.get(intg);
            List<APIRetriggerTracker__c> apiRetrgtRcrds = apiRetriggerTrcrMap.get(
                intg
            );
            for (APIRetriggerTracker__c upd : apiRetrgtRcrds) {
                upd.RetriggerUpsertAudit__c = (Id) sobjt.get('Id');
            }
        }
        if (apiRetriggerTrcrMap != null && apiRetriggerTrcrMap.size() > 0) {
            for (
                List<APIRetriggerTracker__c> grouping : apiRetriggerTrcrMap.values()
            ) {
                insertapiRetriggerTrcrList.addAll(grouping);
            }
            system.debug(
                'insertapiRetriggerTrcrList  ' + insertapiRetriggerTrcrList
            );
            system.debug(
                'insertapiRetriggerTrcrList size ' +
                insertapiRetriggerTrcrList.size()
            );
            insert insertapiRetriggerTrcrList;
        }
        if( intMsgList != null &&  intMsgList.size() > 0){
            insert intMsgList;
        }
    }

    public static void publishPlatformEvent(Map<Id, Set<String>> inputData) {
        system.debug('LoanAppId__c == >' + inputData);

        for (Id val : inputData.keyset()) {
            List<RetriggerUpsertCreated__e> resEvents = new List<RetriggerUpsertCreated__e>();

            RetriggerUpsertCreated__e intevent = new RetriggerUpsertCreated__e();
            intevent.LoanAppId__c = val;
            //String setString = string.valueof(inputData.get(val)).replace("{', ").replace('}', ");
           // String setStringLoop = '';
           /* for (String eachElement : inputData.get(val)) {
                setStringLoop += eachElement + ',';
            }*/
            //setStringLoop = setStringLoop.removeEnd(',');
            intevent.Mes__c = JSON.serialize(inputData.get(val)); 
            system.debug('messages is ==>' + inputData.get(val));
            resEvents.add(intevent);
            system.debug('resEvents ==>' + resEvents);
            List<Database.SaveResult> results = EventBus.publish(resEvents);
            system.debug('PlatForm Evnet Published');
            for (Database.SaveResult sr : results) {
                if (sr.isSuccess()) {
                    System.debug('Successfully published event.');
                } else {
                    for (Database.Error err : sr.getErrors()) {
                        System.debug('Error returned: ' + err.getStatusCode());
                    }
                }
            }
        }
    }

    public static Boolean containsAny(String targetString, Set<String> stringSet) {
        Boolean returnVal = false;
        if (String.isNotBlank(targetString) && stringSet != null && !stringSet.isEmpty()) {
            for (String value : stringSet) {
                if (targetString.contains(value)) {
                    returnVal = true;
                }
            }
        }
        return returnVal; 
    }
    public class InputData {
        @AuraEnabled
        public List<SObject> newList { get; set; }
        @AuraEnabled
        public List<SObject> oldList { get; set; }
        @AuraEnabled
        public String modificationType { get; set; }
        @AuraEnabled
        public String objectApiName { get; set; }
        @AuraEnabled
        public String loanFieldAPIName { get; set; }
        @AuraEnabled
        public String applFieldAPIName { get; set; }
    }
}