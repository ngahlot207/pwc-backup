public class CaseTATHandler implements TriggerAction.AfterInsert,TriggerAction.AfterUpdate{
     
    public static void afterInsert(List<Case> newList){
        Map<Id,Group> queueMap = new Map<Id,Group>([SELECT Id, Name, DeveloperName, Type FROM Group Where Type = 'Queue']);
        List<CaseAudit__c> caseTatList = new list<CaseAudit__c>();
        set<Id> ownerIds = new Set<Id>();
        Map<Id,TeamHierarchy__c> roleMap = new Map<Id,TeamHierarchy__c>();
        for(Case ca : newList){
            ownerIds.add(ca.ownerId);
        }
        
        system.debug('ownerIds:'+ownerIds);
        if(!ownerIds.isEmpty()){
            for(TeamHierarchy__c th: [Select id,Employee__c,EmpRole__c from TeamHierarchy__c Where Employee__c IN:ownerIds]){
                roleMap.put(th.Employee__c,th);
            }
        }
        for(Case caseObj : newList){
            CaseAudit__c caseAuditObj = new CaseAudit__c();
            caseAuditObj.LoanApplication__c = caseObj.Loan_Application__c;
            caseAuditObj.Status__c = caseObj.Status;
            caseAuditObj.Case__c = caseObj.Id;
            caseAuditObj.EntryTime__c = system.now();
            if(!String.valueOf(caseObj.OwnerId).startsWith('00G')){
                caseAuditObj.Owner__c = caseObj.OwnerId;
                if(roleMap.containsKey(caseObj.OwnerId)){
                caseAuditObj.UserRole__c = roleMap.get(caseObj.OwnerId).EmpRole__c;
                }
            }else{
                caseAuditObj.UserRole__c = 'Queue';
               // caseObj.Queue__c = queueMap.get(ca.OwnerId).Name;
            }
            caseTatList.add(caseAuditObj);
        }
        
        system.debug('caseTatList:'+caseTatList);
        if(!caseTatList.isEmpty()){
            insert caseTatList;
        }
    }
    public static void afterUpdate(List<Case> newList, List<Case> oldList){
        BusinessHours defaultBH = [SELECT Id FROM BusinessHours WHERE IsDefault = true Limit 1];
        List<Case> caseList = new List<Case>();
        List<CaseAudit__c> caseTatList = new List<CaseAudit__c>();
        set<Id> caseIds = new set<Id>();
        
        //Case Old record
        map<id, Case> mapCase = new map<id,Case>(oldList);
        system.debug('oldCaseRecord:'+mapCase);
        
        for(Case caseNew : newList){
            if(caseNew.Status != mapCase.get(caseNew.Id).Status){
                   caseIds.add(caseNew.Id);
                   caseList.add(caseNew); 
               }
        }
        
        system.debug('caseList:'+caseList);
        system.debug('caseIds:'+caseIds);
        
        for(CaseAudit__c lnT : [SELECT ID,LoanApplication__c,EntryTime__c,ExitTime__c
                              FROM CaseAudit__c where Case__c IN : caseIds AND ExitTime__c = null order by EntryTime__c desc ]){
                                  //Update exit Time 
                                  lnT.ExitTime__c =system.now();
                                  decimal result = BusinessHours.diff(defaultBH.Id, lnT.EntryTime__c, lnT.ExitTime__c );
                                  Decimal resultingHours = result/(60*60*1000);
                                  
                                  String HH=String.valueOf(math.floor(resultingHours ));
                                  
                                  String MM= String.valueOf( math.floor((resultingHours -math.floor(resultingHours ))*60) );
                                  
                                  String SS=String.valueOf( math.floor((((resultingHours -math.floor(resultingHours ))*60)- math.floor(((resultingHours -math.floor(resultingHours ))*60)))*60) );
                                  
                                  string finaltime=HH+':'+MM+':'+SS;
                                  lnT.TimeDifference__c = finaltime;
                                  lnT.TimeSpentHrs__c = resultingHours;
                                  
                                  
                                  integer days = integer.valueof(resultingHours/9);
                                  decimal hours = resultingHours.setScale(2) - (9 * days);
                                  lnT.ActualBusinessHrs__c = days + ' days ' + hours  + ' hrs';
                          
                                  Decimal diffMilliSecs = Decimal.valueOf(lnT.ExitTime__c.getTime() - lnT.EntryTime__c.getTime());
                                  Decimal dDays = diffMilliSecs/1000/60/60/24;
                                  Integer iDays = Integer.valueOf(math.floor(dDays));
                                  Decimal remainderDays = dDays- iDays;
                                  
                                  Decimal dHours = remainderDays * 24;
                                  Integer iHours = Integer.valueOf(math.floor(dHours));
                                  Decimal remainderHours = dHours - iHours;
                                  
                                  Decimal dMinutes = remainderHours * 60;
                                  Integer iMinutes = Integer.valueOf(math.floor(dMinutes));
                                  Decimal remainderMinutes = dMinutes - iMinutes;
                                  
                                  Decimal dSeconds = remainderMinutes * 60;
                                  Integer iSeconds = Integer.valueOf(math.floor(dSeconds));
                                  Decimal remainderSeconds = dSeconds - iSeconds; 
                                  System.debug('Days: ' + iDays+'  '+'Hours: ' + iHours+'  '+'Minutes: ' + iMinutes+'  '+'Seconds: ' + iSeconds);
                                  lnT.TotalTimeDiff__c =  iDays+':'+ iHours+':'+ iMinutes+':'+ iSeconds;
                                 // lnT.TotalTimeDiff__c =  iDays+' Day'+'  '+ iHours+' Hours'+'  '+ iMinutes+' Minutes' +'  ' + iSeconds+' Seconds';
                                  caseTatList.add(lnT);
                              }
        if(!caseTatList.isEmpty()){
            update caseTatList;
        }
        if(!caseList.isEmpty()){
            afterInsert(caseList);
        }   
    }

}