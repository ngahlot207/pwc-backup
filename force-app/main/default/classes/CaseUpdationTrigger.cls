public class CaseUpdationTrigger implements TriggerAction.BeforeInsert{
    
    public static void BeforeInsert(List<Case> newList){
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( 
            new List<SObjectType> { Case.SObjectType, AgncLocMap__c.SObjectType, Contact.SObjectType }
        );
        set<String> applAdrrCityIds = new set<String>(); 
        Set<Id>Accids = new Set<Id>();
        Map<String,List<AgncLocMap__c>> locAgencyMapperrecords = new Map<String,List<AgncLocMap__c>>();
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
        
        Integer cpvCount = 0;
        Integer cpvContactCount = 0;
        Map<Id,RecordType> recordTypeMap = new map<Id,RecordType>([ select Id,Name from RecordType where sObjectType='Case']);
        try{
            for(Case cs: newList){
                if(cs.IsRouRobAllowd__c == true){    
                    //collect City Ids and based on city iDs query location mapper
                    applAdrrCityIds.add(cs.CityId__c);
                }
            }
            if(applAdrrCityIds != null && applAdrrCityIds.size() > 0){
                LocMasterRecords = [SELECT id,Name,CityId__c,(SELECT id,Account__c,LastAllocated__c,AgencyType__c from Agency_Location_Mappers__r WHERE IsActive__c =:true AND StartDate__c < TODAY AND EndDate__c >= TODAY ORDER BY LastAllocated__c ASC) 
                                    FROM LocMstr__c WHERE CityId__c in : applAdrrCityIds];  
            }
            
            if(LocMasterRecords != null && LocMasterRecords.size() > 0){
                system.debug('LocMasterRecords ' + LocMasterRecords);   
                for(LocMstr__c Loc : LocMasterRecords){
                    for(AgncLocMap__c AgcnLoc : Loc.Agency_Location_Mappers__r){
                        Accids.add(AgcnLoc.Account__c); 
                    }
                    locMasteCityIds.add(Loc.CityId__c);
                    if(LocAgencyMapperrecords.containskey(Loc.CityId__c)){
                        LocAgencyMapperrecords.get(Loc.CityId__c).add(Loc.Agency_Location_Mappers__r);
                    }else{
                        LocAgencyMapperrecords.put(Loc.CityId__c,new list<AgncLocMap__c>{Loc.Agency_Location_Mappers__r});
                    }     
                }
                system.debug('LocAgencyMapperrecords map ==>'+locAgencyMapperrecords);
            }
            
            Id ContactAgencyRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Agency Contact').getRecordTypeId();    
            if(Accids != null && Accids.size() > 0){
                ConList = [SELECT Id,RecordTypeId,AccountId,OwnerId,LastAllocated__c,AgencyContactType__c FROM Contact 
                           WHERE AccountId in :Accids AND RecordTypeId =: ContactAgencyRecordTypeId AND IsActive__c =:true AND StartDate__c < TODAY AND EndDate__c >= TODAY ORDER BY LastAllocated__c ASC];
            }
            
            if(ConList != null && ConList.size() > 0){
                system.debug('ConList==>'+ConList); 
                for(Contact Conta:ConList){
                    ContactidsToGetPatnerUsers.add(Conta.id);
                    if(AccContList.containskey(Conta.AccountId)){
                        AccContList.get(Conta.AccountId).add(Conta);
                    }else{
                        AccContList.put(Conta.AccountId,new list<Contact>{Conta});
                    }       
                }
                system.debug('AccContList' +AccContList);
            }
            
            if(ContactidsToGetPatnerUsers != null && ContactidsToGetPatnerUsers.size() > 0){
                for(user u: [SELECT id,ContactId FROM user WHERE ContactId in :ContactidsToGetPatnerUsers]){
                    PatnerUsersWithContacid.put(u.ContactId,u);
                }
                system.debug('PatnerUsersWithContacid===>' +PatnerUsersWithContacid); 
            } 
            for(Case cas : newList){
                if(LocAgencyMapperrecords != null && LocAgencyMapperrecords.size() > 0){
                    List<AgncLocMap__c>AgncyLocationmap = LocAgencyMapperrecords.get(cas.CityId__c);
                    List<AgncLocMap__c> cpvAgencyList = new List<AgncLocMap__c>();
                    for(AgncLocMap__c agc : AgncyLocationmap){
                        if(agc.AgencyType__c.contains(recordTypeMap.get(cas.RecordTypeId).Name)){
                            cpvAgencyList.add(agc);
                        }    
                    }
                    user PatnerUserRecord;
                    if(recordTypeMap.get(cas.RecordTypeId).Name == 'CPVFI'){
                        AgncLocMap__c updateAgcLocMapper = new AgncLocMap__c();
                        updateAgcLocMapper.Id = cpvAgencyList[math.mod(cpvCount, cpvAgencyList.size())].Id;
                        updateAgcLocMapper.LastAllocated__c = system.now(); 
                        updateAgclocmap.put( cpvAgencyList[math.mod(cpvCount, cpvAgencyList.size())].Id,cpvAgencyList[math.mod(cpvCount, cpvAgencyList.size())]);
                        
                        ContactList = AccContList.get(cpvAgencyList[math.mod(cpvCount, cpvAgencyList.size())].Id);
                        
                        Contact updateContactRec = new Contact();
                        updateContactRec.Id = ContactList[math.mod(cpvContactCount,ContactList.size())].Id;
                        updateContactRec.LastAllocated__c = system.now();
                        
                        ContactMap.put(ContactList[math.mod(cpvContactCount,ContactList.size())].Id , ContactList[math.mod(cpvContactCount,ContactList.size())]);
                        
                        PatnerUserRecord = PatnerUsersWithContacid.get(ContactList[math.mod(cpvContactCount,ContactList.size())].Id);
                        
                        if(PatnerUserRecord != null){
                            cas.OwnerId =  PatnerUserRecord.id;  
                        }else{
                            cas.OwnerId =  ContactList[math.mod(cpvContactCount,ContactList.size())].OwnerId; 
                        }
                        cas.AccountId = cpvAgencyList[math.mod(cpvCount, cpvAgencyList.size())].Account__c != null ? cpvAgencyList[math.mod(cpvCount, cpvAgencyList.size())].Account__c : '';
                        cas.ContactId = ContactList[math.mod(cpvContactCount,ContactList.size())].Id != null ? ContactList[math.mod(cpvContactCount,ContactList.size())].Id : '';
                        cpvCount++;
                        cpvContactCount++;
                    }  
                } 
            }
            
            if(!updateAgclocmap.isEmpty()){
                system.debug('UpdateAgencyLocMap == >'+updateAgclocmap);
                UpdateAgencyLocMap = updateAgclocmap.values();
                //uow.registerDirty(UpdateAgencyLocMap);
                update UpdateAgencyLocMap;
                system.debug('updated agency location mapper');
            }
            if(!ContactMap.isEmpty()){
                UpdateContact = ContactMap.values();
                system.debug('UpdateContact '+ UpdateContact);
                //uow.registerDirty(UpdateContact);
                update UpdateContact;
                system.debug('updated contact');
            }
            // uow.commitWork();
        }catch (Exception e){
            System.debug('An exception occurred: ' + e.getMessage() + ' \n' + 'line number==>'+ e.getLineNumber()
                         +'\nstack tracke '+ e.getStackTraceString() +'\n'+e.getCause() );
        }
    }
}