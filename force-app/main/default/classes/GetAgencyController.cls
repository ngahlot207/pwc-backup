public class GetAgencyController {

    @AuraEnabled
    public static List<AgencyWrpr> getAgency(String cityId){
        List<LocMstr__c> LocMasterRecords = new List<LocMstr__c>();
        Set<Id>Accids = new Set<Id>();
        Map<String,List<AgncLocMap__c>> locAgencyMapperrecords = new Map<String,List<AgncLocMap__c>>();
        List<AgncLocMap__c> agncyLocationmap = new List<AgncLocMap__c>(); 
        set<Id> acctIds = new Set<Id>();
        List<Account> accList = new List<Account>();
        List<AgencyWrpr> ageWrprList = new List<AgencyWrpr>();
        if(cityId != null){        
                LocMasterRecords = [SELECT id,Name,CityId__c,(SELECT id,Account__c,LastAllocated__c,Account__r.Name,AgencyType__c from Agency_Location_Mappers__r WHERE IsActive__c =:true AND StartDate__c < TODAY AND EndDate__c >= TODAY AND AgencyType__c includes('CPVFI') ORDER BY LastAllocated__c ASC) 
                                    FROM LocMstr__c WHERE Id =: cityId];  
        }

        if(LocMasterRecords != null && LocMasterRecords.size() > 0){
            system.debug('LocMasterRecords ' + LocMasterRecords);   
            for(LocMstr__c Loc : LocMasterRecords){
                if(LocAgencyMapperrecords.containskey(Loc.Id)){
                    LocAgencyMapperrecords.get(Loc.Id).addAll(Loc.Agency_Location_Mappers__r);
                }else{
                    List<AgncLocMap__c > agencyLocationMpeList = new list<AgncLocMap__c>();
                    agencyLocationMpeList.addAll(Loc.Agency_Location_Mappers__r);
                    LocAgencyMapperrecords.put(Loc.Id,agencyLocationMpeList);
                }  
                system.debug('LocAgencyMapperrecords map ==>'+locAgencyMapperrecords);
            }
        }
        if(LocAgencyMapperrecords != null && LocAgencyMapperrecords.size() > 0){
             agncyLocationmap = LocAgencyMapperrecords.get(cityId);
                    system.debug('agncyLocationmap ' + agncyLocationmap);
        }

        if(agncyLocationmap != null && agncyLocationmap.size() > 0){
            system.debug('agncyLocationmap '+ agncyLocationmap);
            for(AgncLocMap__c agclMpr : agncyLocationmap){
                acctIds.add(agclMpr.Account__c);
            }
        }
        if(accIds != null ){
            accList = [SELECT Id,Name FROM Account WHERE Id IN: acctIds];
        } 
        for(Account ac : accList){
            AgencyWrpr agncWr = new AgencyWrpr();
            agncWr.label = ac.Name;
            agncWr.value = ac.id;
            ageWrprList.add(agncWr);
        }
        if(ageWrprList != null && ageWrprList.size() > 0 ){
            return ageWrprList;
        }else{
            return null;
        }
    }
    public class AgencyWrpr{
        @AuraEnabled
        public String label{get;set;}
        @AuraEnabled
        public String value{get;set;}
    }
}