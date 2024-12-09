public without sharing class CurrentStageRefreshing {
    @AuraEnabled
    public static void crntSubStagesUpdate(
        String currentSubStage,
        Id loanApplnId
    ) {
        try {
            system.debug('current stage====' + currentSubStage);
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                new List<SObjectType>{ LoanAppl__c.SObjectType }
            );
            List<string> fieldNamesList = new List<string>{ 'SubStage__c' };
                
                String sObjectName = 'LoanAppl__c';
            Schema.SObjectType objType = Schema.getGlobalDescribe()
                .get(sObjectName);
            fflib_SecurityUtils.checkUpdate(objType, fieldNamesList);
            //
 
        
            StepperNav__c stepNav = new StepperNav__c();
           
            List<StepperNav__c> stepNavList = new List<StepperNav__c>();
            stepNavList = [SELECT 
                            Id,
                            LoanAppln__c, 
                            CurStep__c 
                            FROM StepperNav__c 
                            WHERE LoanAppln__c =:loanApplnId  ];
           
            if(stepNavList.size() >0){
              stepNav = stepNavList[0];     	
            }
            
            	 stepNav.LoanAppln__c = loanApplnId;
            	stepNav.CurStep__c = currentSubStage;   
                upsert stepNav;
            
          //  upsert stepNav;
            
           // uow.registerDirty(stepNav);
            //
            // LoanAppl__c loanapp = new LoanAppl__c();
            // loanapp.Id = loanApplnId;
            // loanapp.Stepper__c = currentSubStage;
            // uow.registerDirty(loanapp);
            // //update loanapp;
            // uow.commitWork();
        } catch (Exception ex) {
            GlobalUtility.logMessage(
                'Error',
                'class name :: CurrentStageRefreshing and method names is :: crntSubStagesUpdate' +
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
    
    @AuraEnabled
    public static string subStageNameUpd(Id loanApplnId) {
        try {
            List<LoanAppl__c>  loanDet = [
                    SELECT id, Stepper__c,SubStage__c,Stage__c,Product__c
                    FROM LoanAppl__c
                    WHERE Id = :loanApplnId
                  
                ];
            List<StepperNav__c>  stepNav = [
                SELECT Id,LoanAppln__c, CurStep__c 
                FROM StepperNav__c 
                WHERE  LoanAppln__c =:loanApplnId
               
            ];
            string updSubStage = null;
            if( stepNav.size() >0  ){
                 updSubStage = stepNav[0].CurStep__c;
            }
          
           // string updSubStage = loanDet[0].Stepper__c;
          
            if (updSubStage == null) {
                List<Screen_Config_Switch__mdt> sCS = [SELECT ProdTyp__c,Src__c FROM Screen_Config_Switch__mdt WHERE ProdTyp__c =: loanDet[0].Product__c];
                if(!sCS.isEmpty() && sCS[0].Src__c == 'Metadata'){
                    String productType = '%'+loanDet[0].Product__c+'%';
                    List<ProgIndConfig__mdt>  progindicConfigDetails = [SELECT Id, IsActive__c, StgApiName__c,  SubStgApiName__c,  ProdTyp__c,   ScrnStgName__c, ScrnStgApiName__c,ScrnSubStgName__c , ScrnSubStgApiName__c,  ScrnStgSeqNo__c, ScrnSubStgSeqNo__c
                                                                    FROM ProgIndConfig__mdt 
                                                                    WHERE IsActive__c = true 
                                                                    AND StgApiName__c=: loanDet[0].Stage__c 
                                                                    AND SubStgApiName__c =: loanDet[0].SubStage__c 
                                                                    AND ScrnStgSeqNo__c=1
                                                                    AND ScrnSubStgApiName__c=null
                                                                    AND ProdTyp__c LIKE :productType
                                                                    WITH SECURITY_ENFORCED 
                                                                    order by ScrnStgSeqNo__c
                                                                   ];
                updSubStage = progindicConfigDetails[0].ScrnStgApiName__c; 
                }else if (!sCS.isEmpty() && sCS[0].Src__c == 'Object'){
                    List<ScrenPrgsConfg__c> progindicConfigDetails = [SELECT Id,ProdTyp__c,StgName__c,SubStgName__c,ScrnStgName__c,ScrnStgApiName__c,ScrnSubStgName__c,ScrnSubStgAPIName__c,DsplyForRole__c,IsActive__c,ScrnStgSeqNo__c,DsplyCriteria__c,RecordTypeId,RecordType.DeveloperName
                                                                      FROM ScrenPrgsConfg__c WHERE IsActive__c = TRUE
                                                                      AND RecordType.DeveloperName = 'Progress_Indicator' 
                                                                      AND StgName__c INCLUDES (:loanDet[0].Stage__c)
                                                                      AND SubStgName__c INCLUDES (:loanDet[0].SubStage__c)
                                                                      AND ScrnStgSeqNo__c=1
                                                                      AND ScrnSubStgAPIName__c = NULL
                                                                      AND ProdTyp__c INCLUDES (:loanDet[0].Product__c)
                                                                      order by ScrnStgSeqNo__c];
                    updSubStage = progindicConfigDetails[0].ScrnStgApiName__c; 
                }
            }
            return updSubStage;
        } catch (Exception ex) {
            GlobalUtility.logMessage(
                'Error',
                'class name :: CurrentStageRefreshing and method names is :: subStageNameUpd' +
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
}