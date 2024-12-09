public class CaseUpdationTriggerHandler implements TriggerAction.BeforeInsert{
    
    public static void BeforeInsert(List<Case> newList){
        
        set<String> applAdrrCityIds = new set<String>(); 
        Set<Id>Accids = new Set<Id>();
        Set<Id>conIds = new Set<Id>();
        Map<String,List<AgncLocMap__c>> LocAgencyMapperrecords = new Map<String,List<AgncLocMap__c>>();
        Set<String>locMasteCityIds = new Set<String>();
        List<LocMstr__c> LocMasterRecords = new List<LocMstr__c>(); 
        List<Contact> ConList = new List<Contact> ();
        Map<id,List<Contact>> AccContList = new Map<id,List<Contact>>();
        set<id>ContactidsToGetPatnerUsers = new set<id>();
        Map<id,User> PatnerUsersWithContacid = new Map<id,User>();
        List<Contact>ContactList = new  List<Contact>();
        Map<id,Contact>ContactMap = new Map<id,Contact>(); 
        Map<id,AgncLocMap__c> updateAgclocmap = new Map<id,AgncLocMap__c>();
        List<Contact>UpdateContact = new List<Contact>();
        List<AgncLocMap__c>UpdateAgencyLocMap = new List<AgncLocMap__c>();
        
        Map<String,List<TeamHierarchy__c>> teamHierMapper = new Map<String,List<TeamHierarchy__c>>();
        List<TeamHierarchy__c> teamHierRecords = new List<TeamHierarchy__c>(); 
        List<TeamHierarchy__c>updateTeamList = new List<TeamHierarchy__c>();
        
          Map<String,List<TeamHierarchy__c>> extTeamHierMapper = new Map<String,List<TeamHierarchy__c>>();
          Map<String,List<TeamHierarchy__c>> intTeamHierMapper = new Map<String,List<TeamHierarchy__c>>();
        Integer cpvCount = 0;
        Integer cpvContactCount = 0;
        Integer rcuCount=0;
        Map<Id,RecordType> recordTypeMap = new map<Id,RecordType>([ select Id,Name from RecordType where sObjectType='Case']);
        system.debug('recordTypeMap ' + recordTypeMap);
        try{
            for(Case cs: newList){
                if(cs.IsRouRobAllowd__c == true){    
                    applAdrrCityIds.add(cs.City__c);
                }
            }
            system.debug('applAdrrCityIds ' + applAdrrCityIds);
            if(applAdrrCityIds != null && applAdrrCityIds.size() > 0){
                LocMasterRecords = [SELECT id,Name,City__c,CityId__c,(SELECT id,Account__c,AgencyType__c,Account__r.IsPartner,Contact__c from Agency_Location_Mappers__r WHERE IsActive__c =:true AND StartDate__c < TODAY AND EndDate__c >= TODAY ORDER BY LastAllocated__c ASC) 
                                    FROM LocMstr__c WHERE City__c in : applAdrrCityIds];
                teamHierRecords =[SELECT id,Employee__c, Employee__r.IsActive,EmpLoc__r.City__c,LstAssDtTime__c,EmpBrch__r.BrchCode__c,
                                  EmpRole__c FROM TeamHierarchy__c WHERE EmpBrch__r.BrchCode__c IN : applAdrrCityIds AND
                                  Employee__c != null AND Employee__r.IsActive =true AND EmpRole__c in ('RCUIV','RCUEV')
                                  ORDER BY LstAssDtTime__c ASC];
            }
            
            system.debug('LocMasterRecords::36 ' + LocMasterRecords);
            system.debug('teamHierRecords::45 ' + teamHierRecords);
            if(LocMasterRecords != null && LocMasterRecords.size() > 0){
                for(LocMstr__c Loc : LocMasterRecords){
                    for(AgncLocMap__c AgcnLoc : Loc.Agency_Location_Mappers__r){
                        
                        if(AgcnLoc.Account__r.IsPartner){
                            Accids.add(AgcnLoc.Account__c); 
                            conIds.add(AgcnLoc.Contact__c);
                        }
                        
                    }
                    locMasteCityIds.add(Loc.City__c);
                    system.debug('locMasteCityIds::48 ' + locMasteCityIds);
                    if(LocAgencyMapperrecords.containskey(Loc.City__c)){
                        LocAgencyMapperrecords.get(Loc.City__c).addAll(Loc.Agency_Location_Mappers__r);
                    }else{
                        List<AgncLocMap__c > agencyLocationMpeList = new list<AgncLocMap__c>();
                        agencyLocationMpeList.addAll(Loc.Agency_Location_Mappers__r);
                        LocAgencyMapperrecords.put(Loc.City__c,agencyLocationMpeList);
                    }  
                    system.debug('LocAgencyMapperrecords map ==>'+locAgencyMapperrecords);
                }
            }
            
            if(teamHierRecords != null && teamHierRecords.size()>0){
                for(TeamHierarchy__c tm :teamHierRecords){
                    if(teamHierMapper.containsKey(tm.EmpBrch__r.BrchCode__c)){
                        teamHierMapper.get(tm.EmpBrch__r.BrchCode__c).add(tm);
                    }else{
                        teamHierMapper.put(tm.EmpBrch__r.BrchCode__c,new list<TeamHierarchy__c>{tm});
                    }
                    if(tm.EmpRole__c == 'RCUEV'){
                        extTeamHierMapper.put(tm.EmpBrch__r.BrchCode__c,new list<TeamHierarchy__c>{tm});
                    }else if(tm.EmpRole__c == 'RCUIV'){
                        intTeamHierMapper.put(tm.EmpBrch__r.BrchCode__c,new list<TeamHierarchy__c>{tm});
                    }
                }
            }
            
            
           
            /*Id ContactAgencyRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Agency Contact').getRecordTypeId();    
if(Accids != null && Accids.size() > 0 && ContactAgencyRecordTypeId != null){
ConList = [SELECT Id,RecordTypeId,AccountId,OwnerId,AgencyContactType__c FROM Contact 
WHERE AccountId in :Accids AND RecordTypeId =: ContactAgencyRecordTypeId AND IsActive__c =:true AND StartDate__c < TODAY AND EndDate__c >= TODAY ORDER BY LastAllocated__c ASC];
}*/
            
            /*system.debug('ConList ' + ConList);*/
            
            /*if(ConList != null && ConList.size() > 0){
// system.debug('ConList==>'+ConList); 
for(Contact Conta:ConList){
ContactidsToGetPatnerUsers.add(Conta.id);
if(AccContList.containskey(Conta.AccountId)){
AccContList.get(Conta.AccountId).add(Conta);
}else{
AccContList.put(Conta.AccountId,new list<Contact>{Conta});
}       
}
// system.debug('AccContList' +AccContList);
}*/
            
            if(conIds != null && conIds.size() > 0){
                for(user u: [SELECT id,ContactId FROM user WHERE ContactId in :conIds]){
                    PatnerUsersWithContacid.put(u.ContactId,u);
                }
                system.debug('PatnerUsersWithContacid===>84' +PatnerUsersWithContacid); 
            } 
            for(Case cas : newList){
                if(LocAgencyMapperrecords != null && LocAgencyMapperrecords.size() > 0 && cas.IsRouRobAllowd__c == true){
                    List<AgncLocMap__c> agncyLocationmap = LocAgencyMapperrecords.get(cas.City__c);
                    system.debug('agncyLocationmap ' + agncyLocationmap);
                    List<AgncLocMap__c> cpvAgencyList = new List<AgncLocMap__c>();
                    for(AgncLocMap__c agc : agncyLocationmap){
                        system.debug('agc::::::#90 ' + agc+'::::'+recordTypeMap.get(cas.RecordTypeId).Name+' '+agc.Account__r.IsPartner);
                        if(agc.AgencyType__c.contains(recordTypeMap.get(cas.RecordTypeId).Name) && agc.Account__r.IsPartner){
                            system.debug('agc in IF BLOCK::::::#91 ');
                            cpvAgencyList.add(agc);
                            system.debug('cpvAgencyList in IF BLOCK::::::#93 '+cpvAgencyList);
                        }    
                        
                    }
                    
                    user PatnerUserRecord;
                    if(recordTypeMap.get(cas.RecordTypeId).Name == 'CPVFI' && cpvAgencyList.size()>0){
                        system.debug('AccContList in IF BLOCK::::::#99 '+AccContList);
                        /*if(AccContList.get(cpvAgencyList[math.mod(cpvCount, cpvAgencyList.size())].Account__c) != null){
system.debug('AccContList in IF BLOCK::::::#101 '+AccContList);
}*/
                        AgncLocMap__c updateAgcLocMapper = new AgncLocMap__c();
                        updateAgcLocMapper.Id = cpvAgencyList[math.mod(cpvCount, cpvAgencyList.size())].Id;
                        updateAgcLocMapper.LastAllocated__c = system.now(); 
                        UpdateAgencyLocMap.add(updateAgcLocMapper);
                        //ContactList = AccContList.get(cpvAgencyList[math.mod(cpvCount, cpvAgencyList.size())].Account__c);
                        AgncLocMap__c assigneedMap = cpvAgencyList[math.mod(cpvCount, cpvAgencyList.size())];
                        if(assigneedMap.Contact__c != null){     
                            system.debug('ContactList ' + ContactList);  
                            /*Contact updateContactRec = new Contact();
updateContactRec.Id = ContactList[math.mod(cpvContactCount,ContactList.size())].Id;
updateContactRec.LastAllocated__c = system.now(); 
UpdateContact.add(updateContactRec);*/
                            PatnerUserRecord = PatnerUsersWithContacid.get(assigneedMap.Contact__c);                            
                            if(PatnerUserRecord != null){
                                cas.OwnerId =  PatnerUserRecord.id;  
                            }/*else{
cas.OwnerId =  ContactList[math.mod(cpvContactCount,ContactList.size())].OwnerId; 
}*/
                            cas.ContactId = assigneedMap.Contact__c;//ContactList[math.mod(cpvContactCount,ContactList.size())].Id != null ? ContactList[math.mod(cpvContactCount,ContactList.size())].Id : '';
                        }                        
                        
                        cas.AccountId = assigneedMap.Account__c;//cpvAgencyList[math.mod(cpvCount, cpvAgencyList.size())].Account__c != null ? cpvAgencyList[math.mod(cpvCount, cpvAgencyList.size())].Account__c : '';   
                        cas.IsRouRobAllowd__c = false;
                        cpvCount++;
                        cpvContactCount++;
                    }  
                
                	     if(recordTypeMap.get(cas.RecordTypeId).Name == 'Legal' && cpvAgencyList.size()>0){
                        system.debug('AccContList in IF BLOCK::::::#154 '+AccContList);
                  
                        AgncLocMap__c updateAgcLocMapper = new AgncLocMap__c();
                        updateAgcLocMapper.Id = cpvAgencyList[math.mod(cpvCount, cpvAgencyList.size())].Id;
                        updateAgcLocMapper.LastAllocated__c = system.now(); 
                        UpdateAgencyLocMap.add(updateAgcLocMapper);
                        //ContactList = AccContList.get(cpvAgencyList[math.mod(cpvCount, cpvAgencyList.size())].Account__c);
                        AgncLocMap__c assigneedMap = cpvAgencyList[math.mod(cpvCount, cpvAgencyList.size())];
                        if(assigneedMap.Contact__c != null){     
                            system.debug('ContactList ' + ContactList);  
                            /*Contact updateContactRec = new Contact();
updateContactRec.Id = ContactList[math.mod(cpvContactCount,ContactList.size())].Id;
updateContactRec.LastAllocated__c = system.now(); 
UpdateContact.add(updateContactRec);*/
                            PatnerUserRecord = PatnerUsersWithContacid.get(assigneedMap.Contact__c);                            
                            if(PatnerUserRecord != null){
                                cas.OwnerId =  PatnerUserRecord.id;  
                            }/*else{
cas.OwnerId =  ContactList[math.mod(cpvContactCount,ContactList.size())].OwnerId; 
}*/
                            cas.ContactId = assigneedMap.Contact__c;//ContactList[math.mod(cpvContactCount,ContactList.size())].Id != null ? ContactList[math.mod(cpvContactCount,ContactList.size())].Id : '';
                        }                        
                        
                        cas.AccountId = assigneedMap.Account__c;//cpvAgencyList[math.mod(cpvCount, cpvAgencyList.size())].Account__c != null ? cpvAgencyList[math.mod(cpvCount, cpvAgencyList.size())].Account__c : '';   
                        cas.IsRouRobAllowd__c = false;
                        cpvCount++;
                        cpvContactCount++;
                    }  
               
                }
                system.debug('teamHierMapper::184 ' + teamHierMapper);
                if(recordTypeMap.get(cas.RecordTypeId).Name == 'RCU' && cas.IsRouRobAllowd__c == true){
                if(!teamHierMapper.isEmpty() && teamHierMapper.size()>0){
                    //list<TeamHierarchy__c> lstTeam = teamHierMapper.get(cas.City__c);
                     list <TeamHierarchy__c> extrTeamList =extTeamHierMapper.containsKey(cas.City__c) ? extTeamHierMapper.get(cas.City__c) : null;
                      list <TeamHierarchy__c> intTeamList =intTeamHierMapper.containsKey(cas.City__c) ? intTeamHierMapper.get(cas.City__c) : null;
                     system.debug('lstTeam::202 ' + extrTeamList);
                    system.debug('lstTeam::203 ' + intTeamList);
                    //List<TeamHierarchy__c> teamList = new List<TeamHierarchy__c>();
                 //   if(lstTeam.size()>0){
                        //for(TeamHierarchy__c tmTh :lstTeam){
                     
                        if(!extrTeamList.isEmpty()){
                            cas.OwnerId =extrTeamList[math.mod(rcuCount, extrTeamList.size())].Employee__c;
                             	TeamHierarchy__c t = new TeamHierarchy__c();
                                t.Id = extrTeamList[math.mod(rcuCount, extrTeamList.size())].Id;
                                t.LstAssDtTime__c = system.now(); 
                                updateTeamList.add(t); 
                        }else if(!intTeamList.isEmpty()){
                            	cas.OwnerId =intTeamList[math.mod(rcuCount, intTeamList.size())].Employee__c;
                             	TeamHierarchy__c t = new TeamHierarchy__c();
                                t.Id = intTeamList[math.mod(rcuCount, intTeamList.size())].Id;
                                t.LstAssDtTime__c = system.now(); 
                            	updateTeamList.add(t); 
                        }
                       
                             //	cas.OwnerId =lstTeam[math.mod(rcuCount, lstTeam.size())].Employee__c;
                               // TeamHierarchy__c t = new TeamHierarchy__c();
                              //  t.Id = lstTeam[math.mod(rcuCount, lstTeam.size())].Id;
                              //  t.LstAssDtTime__c = system.now(); 
                               // updateTeamList.add(t); 
                      //  }
                        
                       	 		cas.IsRouRobAllowd__c = false;
                        		rcuCount++;
                             system.debug('rcuCount::199 ' + rcuCount);
                        
                  //  }
                    
                }
                    else{
                        cas.addError('Verifiers are not available for '+ cas.City__c);
                    }
                }
            }
            
            if(UpdateAgencyLocMap != null  && UpdateAgencyLocMap.size() > 0 ){
                system.debug('UpdateAgencyLocMap == >'+UpdateAgencyLocMap);
                update UpdateAgencyLocMap;
                // system.debug('updated agency location mapper');
            }
            if(updateTeamList != null && updateTeamList.size()>0){
                update updateTeamList;
            }
            /*if(UpdateContact != null  && UpdateContact.size() > 0){
// system.debug('UpdateContact '+ UpdateContact);
update UpdateContact;
// system.debug('updated contact');
}*/
        }catch (Exception e){
            System.debug('An exception occurred: ' + e.getMessage() + ' \n' + 'line number==>'+ e.getLineNumber()
                         +'\nstack tracke '+ e.getStackTraceString() +'\n'+e.getCause() );
        }
    }
}