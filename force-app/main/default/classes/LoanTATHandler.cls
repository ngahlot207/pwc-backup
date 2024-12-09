public class LoanTATHandler implements TriggerAction.AfterInsert,TriggerAction.AfterUpdate {
    public static void afterInsert(List<LoanAppl__c> newList){
        Map<Id,Group> queueMap = new Map<Id,Group>([SELECT Id, Name, DeveloperName, Type FROM Group Where Type = 'Queue']);
        List<LoanTAT__c> loanTatList = new list<LoanTAT__c>();
        set<Id> ownerIds = new Set<Id>();
        Map<String,List<String>> stagetoTATMapping = new Map<String,List<String>>();
        for(TATApplicability__mdt tatmdt: [SELECT Id,Stage__c,Substage__c,TATName__c FROM TATApplicability__mdt]){
            if(stagetoTATMapping.containsKey(tatmdt.Stage__c+'-'+tatmdt.Substage__c)){
                stagetoTATMapping.get(tatmdt.Stage__c+'-'+tatmdt.Substage__c).add(tatmdt.TATName__c);
            }else{
                stagetoTATMapping.put(tatmdt.Stage__c+'-'+tatmdt.Substage__c,new List<String>{tatmdt.TATName__c});
            }   
            
        }
        Map<Id,TeamHierarchy__c> roleMap = new Map<Id,TeamHierarchy__c>();
        for(LoanAppl__c loan : newList){
            ownerIds.add(loan.ownerId);
        }
        if(!ownerIds.isEmpty()){
            for(TeamHierarchy__c th: [Select id,Employee__c,EmpRole__c from TeamHierarchy__c Where Employee__c IN:ownerIds]){
                roleMap.put(th.Employee__c,th);
            }
        }
        for(LoanAppl__c loan : newList){
            
            LoanTAT__c lt = new LoanTAT__c();
            lt.LoanApplication__c = loan.Id;
            lt.Status__c = loan.Status__c;
            if(loan.Status__c == 'Hold'){
                lt.HoldReason__c = loan.Hold_Reason__c;
            }
            lt.Stage__c = loan.Stage__c;
            lt.Sub_Stage__c = loan.SubStage__c;
            if(stagetoTATMapping.containsKey(loan.Stage__c+'-'+loan.SubStage__c)){
                String tatNames =  String.join(stagetoTATMapping.get(loan.Stage__c+'-'+loan.SubStage__c),';');
                lt.ApplicableTATs__c = tatNames;
            }
            
            lt.EntryTime__c = system.now();
            if(!String.valueOf(loan.OwnerId).startsWith('00G')){
                lt.Owner__c = loan.OwnerId;
                if(roleMap.containsKey(loan.OwnerId)){
                    lt.UserRole__c = roleMap.get(loan.OwnerId).EmpRole__c;
                }
                
            }else{
                lt.UserRole__c = 'Queue';
                lt.Queue__c = queueMap.get(loan.OwnerId).Name;
            }
            
            loanTatList.add(lt);
            
            
        }
        if(!loanTatList.isEmpty()){
            insert loanTatList;
        }
    }
    public static void afterUpdate(List<LoanAppl__c> newList, List<LoanAppl__c> oldList){
        BusinessHours defaultBH; 
        List<LoanAppl__c> loanList = new List<LoanAppl__c>();
        List<LoanTAT__c> loanTatList = new List<LoanTAT__c>();
        set<Id> loanIds = new set<Id>();
        
        map<id, LoanAppl__c> mapLoan = new map<id,LoanAppl__c>(oldList);
        
        for(LoanAppl__c loanNew : newList){
            if(TriggerBase.idToNumberOfTimesSeenAfterUpdate.get(loanNew.Id) == 1 && (loanNew.SubStage__c != mapLoan.get(loanNew.Id).SubStage__c || loanNew.Status__c != mapLoan.get(loanNew.Id).Status__c
               || loanNew.Stage__c != mapLoan.get(loanNew.Id).Stage__c || loanNew.OwnerId != mapLoan.get(loanNew.Id).OwnerId)){
                   loanIds.add(loanNew.Id);
                   loanList.add(loanNew); 
               }
        }
        if(!loanIds.isEmpty()){ 
            defaultBH = [SELECT Id FROM BusinessHours WHERE IsDefault = true Limit 1];
            for(LoanTat__c lnT : [SELECT ID,LoanApplication__c,EntryTime__c,ExitTime__c
                                  FROM LoanTat__c where LoanApplication__c IN : loanIds AND ExitTime__c = null order by EntryTime__c desc ]){
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
                                      
                                      /*   Integer elapsedDays = Integer.valueOf(lnT.ExitTime__c.day() - lnT.EntryTime__c.day());
Integer elapsedHours = Integer.valueOf(lnT.ExitTime__c.hour() - lnT.EntryTime__c.hour());
Integer elapsedMinutes = Integer.valueOf(lnT.ExitTime__c.minute() - lnT.EntryTime__c.minute());
Integer elapsedSeconds = Integer.valueOf(lnT.ExitTime__c.second() - lnT.EntryTime__c.second());
//Integer total = ((elapsedHours * 60 * 60) +(elapsedMinutes * 60) + elapsedSeconds );

string totalDiff = elapsedDays +':' + elapsedHours + ':' + elapsedMinutes +':'+elapsedSeconds;
system.debug('TOTAL DIFFERENCE:::::::'+totalDiff);
lnT.TotalTimeDiff__c = totalDiff;*/
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
                                      loanTatList.add(lnT);
                                  }
        }
        if(!loanTatList.isEmpty()){
            update loanTatList;
        }
        if(!loanList.isEmpty()){
            afterInsert(loanList);
           CalculateLoanTatMatrix.calculateTAT(loanIds);
        }
        
    }
}