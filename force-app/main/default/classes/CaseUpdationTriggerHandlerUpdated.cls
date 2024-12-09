public class CaseUpdationTriggerHandlerUpdated{
    
    // public static void BeforeInsert(List<Case> newList){
        
    //     fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( 
    //         new List<SObjectType> { Case.SObjectType, AgncLocMap__c.SObjectType, Contact.SObjectType  }
    //     );
    //     set<String> appIds = new Set<String>();
    //     set<String> applAdrrCityIds = new set<String>();  
    //     Map<Id,List<ApplAddr__c>> ApplWithAddressrecords = new Map<Id,List<ApplAddr__c>>();
    //     Map<String,List<AgncLocMap__c>> locAgencyMapperrecords = new Map<String,List<AgncLocMap__c>>();
    //     Set<String>locMasteCityIds = new Set<String>();  
    //     Set<Id>Accids = new Set<Id>();
    //     Map<id,List<Contact>> AccContList = new Map<id,List<Contact>>();
    //     set<id>ContactidsToGetPatnerUsers = new set<id>();
    //     Map<id,User> PatnerUsersWithContacid = new Map<id,User>();
    //     List<Case> caseList = new List<Case>();
    //     AgcLocaWrapperClass[] AGcLocMappList = new List<AgcLocaWrapperClass>();
    //     Set<Id>AccountIds = new Set<Id>();
    //     List<Contact>ContactList = new  List<Contact>();
    //     ContactWrappeClass[] ContactListFromWrapper = new List<ContactWrappeClass>();
    //     List<Contact>UpdateContact = new List<Contact>();
    //     List<AgncLocMap__c>UpdateAgencyLocMap = new List<AgncLocMap__c>();
    //     Map<id,Contact>ContactMap = new Map<id,Contact>(); 
    //     Map<id,AgncLocMap__c>updateAgclocmap = new Map<id,AgncLocMap__c>();
    //     Map<Id,Id> appIdWithLoanAppId = New Map<Id,Id>();
    //     Integer cpvCount = 0;
    //     Integer cpvContactCount = 0;
    //     try{
    //         Id cpvFiRTRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('CPVFI RT').getRecordTypeId();
    //         Map<Id,RecordType> recordTypeMap = new map<Id,RecordType>([ select Id,Name from RecordType where sObjectType='Case']);
    //         for(Case cs: newList){
    //             if(cs.RecordTypeId == cpvFiRTRecordTypeId){
                    
    //                 //collect City Ids and based on city iDs query location mapper
    //                 appIds.add(cs.Applicant__c);
    //             }
    //         }
            
    //         system.debug('applicant ids are ' + appIds);
            
    //         List<ApplAddr__c> ApplAddressrecords = [SELECT id,AddrLine1__c,AddrLine2__c,Applicant__c,CityId__c FROM ApplAddr__c WHERE Applicant__c in :appIds];
            
    //         if(ApplAddressrecords != null && ApplAddressrecords.size() > 0){
                
    //             for(ApplAddr__c appladrr : ApplAddressrecords){
                    
    //                 applAdrrCityIds.add(appladrr.CityId__c);
                    
    //                 if(ApplWithAddressrecords.containskey(appladrr.Applicant__c)){
    //                     ApplWithAddressrecords.get(appladrr.Applicant__c).add(appladrr);
    //                 }else{
    //                     ApplWithAddressrecords.put(appladrr.Applicant__c,new list<ApplAddr__c>{appladrr});
    //                 }                
    //             } 
    //         }    
    //         system.debug('ApplWithAddressrecords Map == >'+ApplWithAddressrecords);
            
    //         List<LocMstr__c> LocMasterRecords = [SELECT id,Name,CityId__c,(SELECT id,Account__c,LastAllocated__c from Agency_Location_Mappers__r WHERE IsActive__c =:true AND StartDate__c < TODAY AND EndDate__c >= TODAY ORDER BY LastAllocated__c) 
    //                                              FROM LocMstr__c WHERE CityId__c in : applAdrrCityIds];
            
    //         if(LocMasterRecords != null && LocMasterRecords.size() > 0){
    //             system.debug('LocMasterRecords ' + LocMasterRecords);   
    //             for(LocMstr__c Loc : LocMasterRecords){
    //                 for(AgncLocMap__c AgcnLoc : Loc.Agency_Location_Mappers__r){
    //                     Accids.add(AgcnLoc.Account__c); 
    //                 }
    //                 locMasteCityIds.add(Loc.CityId__c);
    //                 if(LocAgencyMapperrecords.containskey(Loc.CityId__c)){
    //                     LocAgencyMapperrecords.get(Loc.CityId__c).add(Loc.Agency_Location_Mappers__r);
    //                 }else{
    //                     LocAgencyMapperrecords.put(Loc.CityId__c,new list<AgncLocMap__c>{Loc.Agency_Location_Mappers__r});
    //                 }     
    //             }
    //         }
    //         system.debug('LocAgencyMapperrecords map ==>'+locAgencyMapperrecords);
            
    //         Id ContactAgencyRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Agency Contact').getRecordTypeId();
            
    //         //Add the filters of contacts like IsActive, start date, end date, agency contact type, business unit
    //         List<Contact>ConList = [SELECT Id,RecordTypeId,AccountId,OwnerId,LastAllocated__c FROM Contact 
    //                                 WHERE AccountId in :Accids AND RecordTypeId =: ContactAgencyRecordTypeId AND IsActive__c =:true AND StartDate__c < TODAY AND EndDate__c >= TODAY 
    //                                 AND AgencyContactType__c ='CPV/FI'];
            
    //         if(ConList != null && ConList.size() > 0){
    //             system.debug('ConList==>'+ConList); 
    //             for(Contact Conta:ConList){
    //                 ContactidsToGetPatnerUsers.add(Conta.id);
    //                 if(AccContList.containskey(Conta.AccountId)){
    //                     AccContList.get(Conta.AccountId).add(Conta);
    //                 }else{
    //                     AccContList.put(Conta.AccountId,new list<Contact>{Conta});
    //                 }       
    //             } 
    //         }    
    //         system.debug('AccContList' +AccContList);
            
    //         for(user u: [SELECT id,ContactId FROM user WHERE ContactId in :ContactidsToGetPatnerUsers]){
    //             PatnerUsersWithContacid.put(u.ContactId,u);
    //         }
    //         system.debug('PatnerUsersWithContacid===>' +PatnerUsersWithContacid);
            
    //         if(ApplWithAddressrecords != null && ApplWithAddressrecords.size() > 0){
    //             List<Applicant__c> appListForLoanAppid = [SELECT Id,LoanAppln__c FROM Applicant__c WHERE Id IN :ApplWithAddressrecords.keyset() WITH SECURITY_ENFORCED];
    //             for(Applicant__c ap : appListForLoanAppid){
    //                 appIdWithLoanAppId.put(ap.id,ap.LoanAppln__c);
    //             }
                
    //             for(string applicantId : ApplWithAddressrecords.keyset()){
                    
    //                 List<ApplAddr__c>twoApplicantAddress = new List<ApplAddr__c>();
    //                 Id loanAppId = appIdWithLoanAppId.get(applicantId);
    //                 twoApplicantAddress = ApplWithAddressrecords.get(applicantId);
    //                 system.debug('Size of Applicant Addresses == > '+twoApplicantAddress.size());
    //                 for(Case cas : newList){
    //                     for(ApplAddr__c addr: twoApplicantAddress){ 
                            
    //                         List<AgncLocMap__c>AgncyLocationmap = LocAgencyMapperrecords.get(addr.CityId__c);
    //                         List<AgncLocMap__c> cpvAgencyList = new List<AgncLocMap__c>();
    //                         for(AgncLocMap__c agc : AgncyLocationmap){
    //                             if(agc.AgencyType__c.contains(recordTypeMap.get(cas.RecordTypeId).Name)){
    //                                 cpvAgencyList.add(agc);
    //                             }
    //                             AGcLocMappList.add( new AgcLocaWrapperClass(agc));
    //                             AccountIds.add(agc.Account__c);
    //                         }
                            
                            
    //                         system.debug('before sorting agc loc mapper==>'+AGcLocMappList);
    //                         AGcLocMappList.sort();
    //                         system.debug('After sorting agc loc mapper==>'+AGcLocMappList);
    //                         user PatnerUserRecord;
    //                         if(recordTypeMap.get(cas.RecordTypeId).Name == 'CPVFI'){
                                			
    //                             ContactList = AccContList.get(cpvAgencyList[math.mod(cpvCount, cpvAgencyList.size())].Id);
    //                             PatnerUserRecord = PatnerUsersWithContacid.get(ContactList[math.mod(cpvContactCount,ContactList.size())].Id);
    //                            	cpvCount++;
    //                             cpvContactCount++;
    //                         }
                            
                            
                            /*for(Contact con : ContactList){
                                ContactListFromWrapper.add( new ContactWrappeClass(con));
                                
                            }*/
    //                         system.debug('before sorting contact mapper==>'+ContactListFromWrapper);
    //                         ContactListFromWrapper.sort();
    //                         system.debug('After sorting contact mapper==>'+ContactListFromWrapper);
                            
                            
                            
    //                         case addressCPV =New case();
                            
    //                         AgncLocMap__c updateAgcLocMapper = new AgncLocMap__c();
                            
    //                         Contact updateContactRec = new Contact();               
    //                         List<string> fieldNames = New List<string>{'LastAllocated__c'};
                                
    //                             String sObjectNames = 'AgncLocMap__c';
    //                         Schema.SObjectType obj  = Schema.getGlobalDescribe().get(sObjectNames);
    //                         fflib_SecurityUtils.checkUpdate(obj,fieldNames);
                            
    //                         List<string> fieldNamess = New List<string>{'LastAllocated__c'};
                                
    //                             String sObjectNamess = 'Contact';
    //                         Schema.SObjectType objj  = Schema.getGlobalDescribe().get(sObjectNamess);
    //                         fflib_SecurityUtils.checkUpdate(objj,fieldNamess);
                            
    //                         updateAgcLocMapper.Id =AGcLocMappList[0].AGLM.id;
    //                         updateAgcLocMapper.LastAllocated__c = system.now();
                            
    //                         updateAgclocmap.put( updateAgcLocMapper.Id,updateAgcLocMapper);
                            
                            
    //                         updateContactRec.Id= ContactListFromWrapper[0].con.id;
    //                         updateContactRec.LastAllocated__c = system.now();
                            
    //                         ContactMap.put(updateContactRec.Id,updateContactRec);    
                            
    //                         if(PatnerUserRecord != null){
    //                             cas.OwnerId =  PatnerUserRecord.id;  
    //                         }else{
    //                             cas.OwnerId =  ContactListFromWrapper[0].con.OwnerId; 
    //                         }
    //                         cas.AccountId = AGcLocMappList[0].AGLM.Account__c != null ? AGcLocMappList[0].AGLM.Account__c : '';
    //                         cas.ContactId = ContactListFromWrapper[0].con.id != null ? ContactListFromWrapper[0].con.id : '';
    //                     }
    //                 }
    //             }
    //         }
            
            
    //         if(!updateAgclocmap.isEmpty()){
    //             system.debug('UpdateAgencyLocMap == >'+updateAgclocmap);
    //             UpdateAgencyLocMap = updateAgclocmap.values();
    //             uow.registerDirty(UpdateAgencyLocMap);
    //             //update UpdateAgencyLocMap;
    //             system.debug('updated agency location mapper');
    //         }
    //         if(!ContactMap.isEmpty()){
    //             UpdateContact = ContactMap.values();
    //             system.debug('UpdateContact '+ UpdateContact);
    //             uow.registerDirty(UpdateContact);
    //             //update UpdateContact;
    //             system.debug('updated contact');
    //         }
    //         uow.commitWork(); 
    //     }catch (Exception e){
    //         System.debug('An exception occurred: ' + e.getMessage() + ' \n' + 'line number==>'+ e.getLineNumber()
    //                      +'\nstack tracke '+ e.getStackTraceString() +'\n'+e.getCause() );
    //     }
    // }
}