public without sharing class ShowMultipleComponentEnhancement {
    @testVisible
    @AuraEnabled(cacheable=false)
    public static list<string> getDiplayConfigAsRoleNStatus(
        string loanAppId,
        string currentStepper,
        string currentSubStepper,
        string applicantId
    ) { 
        system.debug(  ' input attributes ' + ' loanAppId  :  ' + loanAppId + '  currentStepper  : ' + currentStepper + '  applicantId :: '+applicantId + ' currentSubStepper ' +currentSubStepper);
        // applicantTypeId it has appid or coappid
        try { 
            Id userId = UserInfo.getUserId();

            string role = [SELECT  Id, Product_Type__c, IsActive__c, Employee__c, EmpLevel__c, EmpRole__c  FROM TeamHierarchy__c
                WHERE Employee__c = :userId limit 1].EmpRole__c;
            
            loanAppl__c loanAppRec = [SELECT Id, Product__c,  Stage__c, SubStage__c, Stepper__c FROM loanAppl__c WHERE Id = :loanAppId];
            string product = '%' + loanAppRec.Product__c + '%';
            string stage = loanAppRec.Stage__c;
            string subStage = loanAppRec.SubStage__c;
            string stepper = loanAppRec.Stepper__c;
            
            List<Screen_Config_Switch__mdt> sCS = [SELECT ProdTyp__c,Src__c FROM Screen_Config_Switch__mdt WHERE ProdTyp__c =:loanAppRec.Product__c];            
			List<Sobject> screenConfigList = new List<Sobject>();
            if (!sCS.isEmpty() && sCS[0].Src__c == 'Metadata'){
                list<ScrConfig__mdt> screenConfigMdtList = new List<ScrConfig__mdt>();
                if(currentSubStepper != null){
                    screenConfigMdtList = [ 
                        SELECT
                        Id,
                        StgApiName__c,
                        SubStgName__c,
                        SubStgApiName__c,
                        ScrnStgName__c,
                        ScrnStgApiName__c ,
                        ScrnSubStgName__c ,
                        ScrnSubStgAPIName__c ,
                        Sub_Stage_Sequence__c,
                        Display_Stepper__c,
                        Display_Sub_Stepper__c,
                        IsActive__c,
                        DsplyCconfig__c ,
                        Stage__c, 
                        SubStage__c,
                        Stepper__c,
                        QryConfig__c,
                        ProdTyp__c
                        FROM ScrConfig__mdt
                        WHERE 
                        IsActive__c = true
                        AND StgApiName__c=: stage 
                        AND SubStgApiName__c =:subStage
                        AND  ScrnStgApiName__c =:currentStepper 
                        AND ScrnSubStgAPIName__c =: currentSubStepper
                        AND ProdTyp__c LIKE :product
                        AND Display_Sub_Stepper__c =true
                    ];
                    List<Sobject> metaList = screenConfigMdtList;
            	}else{
                    screenConfigMdtList = [ 
                        SELECT
                        Id,
                        //Stage_Name__c,
                        StgApiName__c,
                        SubStgName__c,
                        SubStgApiName__c,
                        ScrnStgName__c,
                        ScrnStgApiName__c ,
                        ScrnSubStgName__c ,
                        ScrnSubStgAPIName__c ,
                        Sub_Stage_Sequence__c,
                        Display_Stepper__c,
                        Display_Sub_Stepper__c,
                        IsActive__c,
                        DsplyCconfig__c ,
                        Stage__c, 
                        SubStage__c,
                        Stepper__c,
                        QryConfig__c,
                        ProdTyp__c
                        FROM ScrConfig__mdt
                        WHERE 
                        IsActive__c = true
                        AND StgApiName__c=: stage 
                        AND SubStgApiName__c =:subStage
                        AND  ScrnStgApiName__c =:currentStepper 
                        AND ProdTyp__c LIKE :product
                        AND Display_Stepper__c =true                        
                    ];
            	}
                screenConfigList = screenConfigMdtList;
            }
            else if (!sCS.isEmpty() && sCS[0].Src__c == 'Object'){
                List<ScrenPrgsConfg__c> screenConfigsObj = new List<ScrenPrgsConfg__c>();
                if(currentSubStepper != null){
                    screenConfigsObj =[SELECT Id,ProdTyp__c,StgName__c,SubStgName__c,ScrnStgName__c,ScrnStgApiName__c,ScrnSubStgName__c,ScrnSubStgAPIName__c,DsplyForRole__c,IsActive__c,ScrnStgSeqNo__c,Sub_Stage_Sequence__c,DsplyCriteria__c,Display_Sub_Stepper__c,DsplyCconfig__c,QryConfig__c,RecordType.DeveloperName
                            FROM ScrenPrgsConfg__c WHERE IsActive__c = TRUE
                            AND RecordType.DeveloperName = 'Screen_Configuration' 
                            AND StgName__c INCLUDES (:stage)
                            AND SubStgName__c INCLUDES (:subStage)
                            AND ScrnStgApiName__c = :currentStepper
                            AND ScrnSubStgAPIName__c = :currentSubStepper
                            AND ProdTyp__c INCLUDES (:loanAppRec.Product__c)
                            AND Display_Sub_Stepper__c = TRUE
                            ORDER BY ScrnStgSeqNo__c];
                }else{
                    screenConfigsObj =[SELECT Id,ProdTyp__c,StgName__c,SubStgName__c,ScrnStgName__c,ScrnStgApiName__c,ScrnSubStgName__c,DsplyForRole__c,IsActive__c,ScrnStgSeqNo__c,Sub_Stage_Sequence__c,DsplyCriteria__c,Display_Sub_Stepper__c,DsplyCconfig__c,QryConfig__c,RecordType.DeveloperName
                            FROM ScrenPrgsConfg__c WHERE IsActive__c = TRUE
                            AND RecordType.DeveloperName = 'Screen_Configuration' 
                            AND StgName__c INCLUDES (:stage)
                            AND SubStgName__c INCLUDES (:subStage)
                            AND ScrnStgApiName__c = :currentStepper                             
                            AND ProdTyp__c INCLUDES (:loanAppRec.Product__c)
                            AND Display_Stepper__c = TRUE
                            ORDER BY ScrnStgSeqNo__c];
                }
                screenConfigList = screenConfigsObj;
            }
			system.debug('## screenConfigList'+screenConfigList);
            List<Object> scrConfigs = new  List<Object>();
            List<Object> configQuery = new List<Object>();
            //   List<QueryVal> configQueryVal = new List<QueryVal>();
            Map<String, Object> configByRoleMap = new Map<String, Object>();
            Map<String, Object> configQueryMap = new Map<String, Object>();
            // List<QueryValMain> configQueryMap = new List<QueryValMain>();
            string returnVal = '';
            Map<String, object> idMap = new Map<String, object>();
            Map<String, Object> qryBind = new Map<String, Object>();
            qryBind.put('loanAppId', loanAppId);
            qryBind.put('userId', userId);
            if(applicantId == null){
                list<Applicant__c> applicantList = new List<Applicant__c>();
                applicantList=  [select id, ApplType__c,LoanAppln__c from Applicant__c where ApplType__c ='P' AND LoanAppln__c =:loanAppId];
                if(applicantList.size() > 0){
                    qryBind.put('applicantId', applicantList[0]);  
                }else{
                    qryBind.put('applicantId', applicantId);   
                }
                
            }else{
                qryBind.put('applicantId', applicantId);    
            }
            
            system.debug('qryBind ' + qryBind);
            if (screenConfigList.size() > 0) {
                system.debug('## screenConfigList[0]'+screenConfigList[0]);
                if(String.isNotBlank(String.valueOf(screenConfigList[0].get('DsplyCconfig__c')))){
                    system.debug('## str'+String.valueOf(screenConfigList[0].get('DsplyCconfig__c')));
                	configByRoleMap = (Map<String, Object>) System.JSON.deserializeUntyped(String.valueOf(screenConfigList[0].get('DsplyCconfig__c')));
                }
                system.debug('configByRoleMap ' + configByRoleMap + '  role is '+ role +'  stage is  ' + stage);
                scrConfigs = (List<Object>) configByRoleMap.get(role);
                system.debug('scrConfigs ' + scrConfigs); 
                if(screenConfigList[0].get('QryConfig__c') !=null){
                    configQueryMap =(Map<String, Object>) JSON.deserializeUntyped(String.valueOf(screenConfigList[0].get('QryConfig__c')));
                    string configQueryMapStr = JSON.serialize(configQueryMap.get('Qry'));
                    system.debug('configQueryMapStr'+ configQueryMapStr);
                    
                    List<QueryVal> configQueryList = (List<QueryVal> ) JSON.deserialize(configQueryMapStr,List<QueryVal>.class);
                    system.debug('configQueryList  : '+ configQueryList);
                    for(QueryVal qv : configQueryList){
                        
                        system.debug('qv'+ qv);
                        //returnVal = returnVal + qv.query ;
                        List<sObject> qryResult =Database.queryWithBinds(qv.query,qryBind, AccessLevel.USER_MODE ); 
                        system.debug('qryResult ' + qryResult);
                        for(Container  cont  : qv.containerList){
                            
                            if(qryResult.size() > 0  ){
                                
                                object contVall = qryResult[0].get(cont.keyField);
                                string contIdMapKey =cont.containerVar+qv.key;  
                                idMap.put(contIdMapKey,contVall);   
                              
                              
                               
                               
                            }
                        }
                        
                        
                    }
                    returnVal = returnVal +' :: idmap   ::' +  JSON.serialize(idMap)+ '-----------------------------------------' ; 
                    system.debug('scrConfigs  last '+ scrConfigs);
                    for(object sc:  scrConfigs){
                        Map<String, Object> mp = (Map<String, Object>) sc;
                        
                        //  mp.put('loanAppId', idMap.get('loanId'));
                        //   mp.put('recordId', idMap.get('applicantId'));
                        for(QueryVal qv : configQueryList){
                            if(mp.get('key') ==  qv.key && qv.containerList.size()>0  ){
                                for(Container  cont  : qv.containerList){
                                    // string vall =(string) qryResult[0].get(cont.keyField);
                                    // idMap.put(cont.containerVar,vall);
                                    // mp.put(cont.containerVar, idMap.get(cont.containerVar));
                                    
                                    string contIdMapKey =cont.containerVar+qv.key;  
                                    mp.put(cont.containerVar, idMap.get(contIdMapKey));
                                }
                            }
                            
                        }
                        
                    }
                    returnVal = returnVal +'___ scConfig ___'+  JSON.serialize(scrConfigs);
                    
                }
            }
            list<string> responceList = new list<string>(); 
            responceList.add(returnVal);
            responceList.add(JSON.serialize(scrConfigs));
            system.debug('responceList::::::::'+responceList);
            return  responceList ;  
            // return  JSON.serialize(scrConfigs) ;  
            
            
        } catch (Exception ex) {
            
            GlobalUtility.logMessage(
                'Error',
                'class name :: ShowMultipleComponent and method names is :: getDiplayConfigAsRoleNStatus' +
                ex.getLineNumber(),
                'Generate',
                null,
                null,
                ex.getMessage() + ' Line: ' + ex.getLineNumber(),
                null,
                ex,
                null
            );
            string str = '' + ex;
            // system.debug(str);
            System.debug(
                'The following exception has occurred: ' + ex.getMessage()
            );
            System.debug('Line no error ' + ex.getLineNumber());
            throw new AuraHandledException('message' + ex.getMessage()+'  line no ::'+ ex.getLineNumber());
        }
    }
    
    public class QueryVal {     
        public string key { get; set; }  
        public string query { get; set; }
        public list<Container> containerList {get; set; }
    } 
    public class Container {     
        public string keyField { get; set; }   
        public string containerVar { get; set; }
    } 
    
}