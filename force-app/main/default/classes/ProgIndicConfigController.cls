public without sharing class ProgIndicConfigController {
    @AuraEnabled
    public static List<StepListsWpr> progIndConfHanlde(String loanAppId,string stepperName) {
        system.debug('stepperName====>' + stepperName);
        List<StepListsWpr> steplistWrapperList = new List<StepListsWpr>();
        List<LoanAppl__c> loanApplicaRecords = new List<LoanAppl__c>();
        
        try{            
		loanApplicaRecords = [SELECT Id,Product__c,Stage__c,SubStage__c FROM LoanAppl__c WHERE Id =:loanAppId];
        if (!loanApplicaRecords.isEmpty()) {
            List<Screen_Config_Switch__mdt> sCS = [SELECT ProdTyp__c,Src__c FROM Screen_Config_Switch__mdt WHERE ProdTyp__c =: loanApplicaRecords[0].Product__c];
            Id userId = UserInfo.getUserId();
            String role = [SELECT Id,EmpRole__c FROM TeamHierarchy__c WHERE Employee__c = :userId WITH SECURITY_ENFORCED LIMIT 1].EmpRole__c;
            String prodType = '%' +loanApplicaRecords[0].Product__c +'%';

            if(!sCS.isEmpty() && sCS[0].Src__c == 'Metadata'){
                if (stepperName == null) {
                    List<ProgIndConfig__mdt> progindicConfigDetails = [
                        SELECT
                            ProdTyp__c,
                            StgApiName__c,
                            SubStgApiName__c,
                            ScrnStgName__c,
                            ScrnStgApiName__c,
                            ScrnSubStgApiName__c,
                            DsplyForRole__c,
                            IsActive__c,
                            ScrnStgSeqNo__c,
                            DsplyCriteria__c
                        FROM ProgIndConfig__mdt
                        WHERE
                            IsActive__c = TRUE
                            AND StgApiName__c = :loanApplicaRecords[0].Stage__c
                            AND SubStgApiName__c = :loanApplicaRecords[0]
                                .SubStage__c
                            AND ScrnSubStgApiName__c = NULL
                            AND Display_Stepper__c = TRUE
                            AND ProdTyp__c LIKE :prodType
                        WITH SECURITY_ENFORCED
                        ORDER BY ScrnStgSeqNo__c
                    ];
                    system.debug('## progindicConfigDetails'+progindicConfigDetails);
                    if (!progindicConfigDetails.isEmpty()) {
                        for (
                            ProgIndConfig__mdt steps : progindicConfigDetails
                        ) {
                            list<string> displayProfiles = (list<string>) JSON.deserialize(
                                steps.DsplyForRole__c,
                                list<string>.class
                            );
                            if (displayProfiles.contains(role)) {
                                StepListsWpr steplistWpr = new StepListsWpr();
                                steplistWpr.label = steps.ScrnStgName__c;
                                steplistWpr.value = steps.ScrnStgApiName__c;
                                steplistWrapperList.add(steplistWpr);
                            }
                        }
                        system.debug(
                            'steplistWrapperList ' + steplistWrapperList
                        );
                        system.debug(
                            'steplistWrapperList size ' +
                            steplistWrapperList.size()
                        );
                    }
                }else{
                    List<ProgIndConfig__mdt> progindicConfigDetails = [
                        SELECT
                            ProdTyp__c,
                            StgApiName__c,
                            SubStgApiName__c,
                            ScrnStgName__c,
                            ScrnStgApiName__c,
                            ScrnSubStgApiName__c,
                            DsplyForRole__c,
                            IsActive__c,
                            ScrnSubStgSeqNo__c,
                            DsplyCriteria__c,
                            ScrnSubStgName__c
                        FROM ProgIndConfig__mdt
                        WHERE
                            IsActive__c = TRUE
                            AND StgApiName__c LIKE :loanApplicaRecords[0]
                                .Stage__c
                            AND SubStgApiName__c = :loanApplicaRecords[0]
                                .SubStage__c
                            AND ScrnStgApiName__c = :stepperName
                            AND ScrnSubStgApiName__c != NULL
                            AND Display_Sub_Stepper__c = TRUE
                            AND ProdTyp__c LIKE :prodType
                            AND Display_Stepper__c = FALSE
                        WITH SECURITY_ENFORCED
                        ORDER BY ScrnSubStgSeqNo__c
                    ];
                    if (!progindicConfigDetails.isEmpty()) {
                        for (
                            ProgIndConfig__mdt steps : progindicConfigDetails
                        ) {
                            list<string> displayProfiles = (list<string>) JSON.deserialize(
                                steps.DsplyForRole__c,
                                list<string>.class
                            );
                            if (displayProfiles.contains(role)) {
                                StepListsWpr steplistWpr = new StepListsWpr();
                                steplistWpr.label = steps.ScrnSubStgName__c;
                                steplistWpr.value = steps.ScrnSubStgApiName__c;
                                steplistWpr.isCompleted = false;
                                steplistWpr.isInActive = false;
                                steplistWpr.isCurrent = false;
                                steplistWrapperList.add(steplistWpr);
                            }
                        }
                        system.debug(
                            'steplistWrapperList ' + steplistWrapperList
                        );
                        system.debug(
                            'steplistWrapperList size ' +
                            steplistWrapperList.size()
                        );
                    }
                }
            }
            else if (!sCS.isEmpty() && sCS[0].Src__c == 'Object'){
                if (stepperName == null) {
                    List<ScrenPrgsConfg__c> progindicConfigDetails = [SELECT Id,ProdTyp__c,StgName__c,SubStgName__c,ScrnStgName__c,ScrnStgApiName__c,ScrnSubStgName__c,ScrnSubStgAPIName__c,DsplyForRole__c,IsActive__c,ScrnStgSeqNo__c,DsplyCriteria__c,RecordTypeId,RecordType.DeveloperName
                            FROM ScrenPrgsConfg__c WHERE IsActive__c = TRUE
                            AND RecordType.DeveloperName = 'Progress_Indicator' 
                            AND StgName__c INCLUDES (:loanApplicaRecords[0].Stage__c)
                            AND SubStgName__c INCLUDES (:loanApplicaRecords[0].SubStage__c)
                            AND ScrnSubStgAPIName__c = NULL
                            AND Display_Stepper__c = TRUE
                            AND ProdTyp__c INCLUDES (:loanApplicaRecords[0].Product__c)
                            ORDER BY ScrnStgSeqNo__c
                    ];
					system.debug('## progindicConfigDetails'+progindicConfigDetails);
                    if (!progindicConfigDetails.isEmpty()) {
                        for (ScrenPrgsConfg__c steps : progindicConfigDetails) {
                            list<string> displayProfiles = (list<string>) JSON.deserialize(
                                steps.DsplyForRole__c,
                                list<string>.class
                            );
                            if (displayProfiles.contains(role)) {
                                StepListsWpr steplistWpr = new StepListsWpr();
                                steplistWpr.label = steps.ScrnStgName__c;
                                steplistWpr.value = steps.ScrnStgApiName__c;
                                steplistWrapperList.add(steplistWpr);
                            }
                        }
                    }
                }else{
                    List<ScrenPrgsConfg__c> progindicConfigDetails = [SELECT Id,ProdTyp__c,StgName__c,SubStgName__c,ScrnStgName__c,ScrnStgApiName__c,ScrnSubStgName__c,ScrnSubStgAPIName__c,DsplyForRole__c,IsActive__c,ScrnSubStgSeqNo__c,DsplyCriteria__c                           
                        FROM ScrenPrgsConfg__c WHERE IsActive__c = TRUE
                            AND RecordType.DeveloperName = 'Progress_Indicator'
                            AND StgName__c INCLUDES (:loanApplicaRecords[0].Stage__c)
                            AND SubStgName__c INCLUDES (:loanApplicaRecords[0].SubStage__c)
                            AND ScrnStgApiName__c = :stepperName
                            AND ScrnSubStgAPIName__c != NULL
                            AND Display_Sub_Stepper__c = TRUE
                            AND ProdTyp__c INCLUDES (:loanApplicaRecords[0].Product__c)
                            AND Display_Stepper__c = FALSE
                        ORDER BY ScrnSubStgSeqNo__c];
                    
                    if (!progindicConfigDetails.isEmpty()) {
                        for(ScrenPrgsConfg__c steps : progindicConfigDetails) {
                            list<string> displayProfiles = (list<string>) JSON.deserialize(steps.DsplyForRole__c,list<string>.class);
                            if (displayProfiles.contains(role)) {
                                StepListsWpr steplistWpr = new StepListsWpr();
                                steplistWpr.label = steps.ScrnSubStgName__c;
                                steplistWpr.value = steps.ScrnSubStgAPIName__c;
                                steplistWpr.isCompleted = false;
                                steplistWpr.isInActive = false;
                                steplistWpr.isCurrent = false;
                                steplistWrapperList.add(steplistWpr);
                            }
                        }
                    }
                }
            }
        }  
        } catch (exception ex) {
            system.debug(ex.getMessage());
            GlobalUtility.logMessage(
                'Error',
                'ProgIndicConfigController class and method names is :: ProgIndConfHanlde' +
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
        return steplistWrapperList;
    }
    @AuraEnabled //(cacheable=true)
    public static List<StepperAvialable> stepperStagesAvailable(
        String loanAppId
    ) {
        List<StepperAvialable> stprList = new List<StepperAvialable>();
        try {
            List<LoanAppl__c> loanApplicaRecords = new List<LoanAppl__c>();

            Id userId = UserInfo.getUserId();

            string role = [
                SELECT
                    Id,
                    Product_Type__c,
                    IsActive__c,
                    Employee__c,
                    EmpLevel__c,
                    EmpRole__c
                FROM TeamHierarchy__c
                WHERE Employee__c = :userId
                WITH SECURITY_ENFORCED
            ]
            .EmpRole__c;
            if (loanAppId != null) {
                loanApplicaRecords = [
                    SELECT Id, Stage__c, Product__c, SubStage__c
                    FROM LoanAppl__c
                    WHERE id = :loanAppId
                    WITH SECURITY_ENFORCED
                ];
            }
            if (!loanApplicaRecords.isEmpty()) {
                String prodType = '%' + loanApplicaRecords[0].Product__c + '%';
                List<ProgIndConfig__mdt> progindicConfigDetails = [
                    SELECT
                        Id,
                        IsActive__c,
                        StgApiName__c,
                        SubStgApiName__c,
                        ProdTyp__c,
                        ScrnStgName__c,
                        ScrnStgApiName__c,
                        ScrnSubStgName__c,
                        ScrnSubStgApiName__c,
                        DsplyForRole__c,
                        ScrnStgSeqNo__c,
                        ScrnSubStgSeqNo__c,
                        DsplyCriteria__c
                    FROM ProgIndConfig__mdt
                    WHERE
                        IsActive__c = TRUE
                        AND StgApiName__c = :loanApplicaRecords[0].Stage__c
                        AND SubStgApiName__c = :loanApplicaRecords[0]
                            .SubStage__c
                        AND ProdTyp__c LIKE :prodType
                    WITH SECURITY_ENFORCED
                    ORDER BY ScrnStgSeqNo__c
                ];
                if (!progindicConfigDetails.isEmpty()) {
                    for (ProgIndConfig__mdt progMdt : progindicConfigDetails) {
                        StepperAvialable stpr = new StepperAvialable();
                        if (progMdt.ScrnSubStgName__c == null) {
                            stpr.label = progMdt.ScrnStgName__c;
                            stpr.value = progMdt.ScrnStgApiName__c;
                            stpr.isSubStpr = false;
                            //stpr.stprSequence = ;
                        } else {
                            stpr.label = progMdt.ScrnSubStgName__c;
                            stpr.value = progMdt.ScrnSubStgApiName__c;
                            stpr.isCompleted = false;
                            stpr.isInActive = false;
                            stpr.isCurrent = false;
                            stpr.isSubStpr = true;
                        }
                        stprList.add(stpr);
                    }
                }
            }
        } catch (exception ex) {
            system.debug(ex.getMessage());
            GlobalUtility.logMessage(
                'Error',
                'ProgIndicConfigController class and method names is :: stepperStagesAvailable' +
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
        return stprList;
    }

    @AuraEnabled //(cacheable=true)
    public static Boolean subStepperQueryConfi(
        String loanAppId,
        string stepperName
    ) {
        system.debug('stepperName====>' + stepperName);
        system.debug('loanAppId====>' + loanAppId);
        List<LoanAppl__c> loanApplicaRecords = new List<LoanAppl__c>();
        Boolean returnVal;
        try {
            Id userId = UserInfo.getUserId();
            string role = [
                SELECT
                    Id,
                    Product_Type__c,
                    IsActive__c,
                    Employee__c,
                    EmpLevel__c,
                    EmpRole__c
                FROM TeamHierarchy__c
                WHERE Employee__c = :userId
                WITH SECURITY_ENFORCED
            ]
            .EmpRole__c;

            if (loanAppId != null) {
                loanApplicaRecords = [
                    SELECT Id, Stage__c, Product__c, SubStage__c
                    FROM LoanAppl__c
                    WHERE id = :loanAppId
                    WITH SECURITY_ENFORCED
                ];
            }
            system.debug('loanApplicaRecords size' + loanApplicaRecords.size());
            if (!loanApplicaRecords.isEmpty()) {
                String prodType = '%' + loanApplicaRecords[0].Product__c + '%';
                List<ProgIndConfig__mdt> progindicConfigDetails = [
                    SELECT ProdTyp__c, StgApiName__c
                    FROM ProgIndConfig__mdt
                    WHERE
                        IsActive__c = TRUE
                        AND StgApiName__c = :loanApplicaRecords[0].Stage__c
                        AND SubStgApiName__c = :loanApplicaRecords[0]
                            .SubStage__c
                        AND ProdTyp__c LIKE :prodType
                        AND ScrnStgApiName__c = :stepperName
                        AND ScrnSubStgApiName__c != NULL
                    WITH SECURITY_ENFORCED
                    ORDER BY ScrnSubStgSeqNo__c
                ];
                system.debug(
                    'progindicConfigDetails size ' +
                        progindicConfigDetails.size() +
                        progindicConfigDetails
                );
                if (!progindicConfigDetails.isEmpty()) {
                    returnVal = true;
                    system.debug('inside true');
                } else {
                    returnVal = false;
                    system.debug('inside false');
                }
            }
            system.debug('returnVal' + returnVal);
            return returnVal;
        } catch (exception ex) {
            system.debug(ex.getMessage());
            GlobalUtility.logMessage(
                'Error',
                'ProgIndicConfigController class and method names is :: ProgIndConfHanlde' +
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
    public class StepListsWpr {
        @AuraEnabled
        public string label { get; set; }
        @AuraEnabled
        public string value { get; set; }
        @AuraEnabled
        public Boolean isCompleted { get; set; }
        @AuraEnabled
        public Boolean isInActive { get; set; }
        @AuraEnabled
        public Boolean isCurrent { get; set; }
    }
    public class StepperAvialable {
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public String value { get; set; }
        @AuraEnabled
        public boolean isSubStpr { get; set; }
        @AuraEnabled
        public integer stprSequence { get; set; }
        @AuraEnabled
        public Boolean isCompleted { get; set; }
        @AuraEnabled
        public Boolean isInActive { get; set; }
        @AuraEnabled
        public Boolean isCurrent { get; set; }
    }
}